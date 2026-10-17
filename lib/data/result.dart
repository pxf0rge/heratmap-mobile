import 'dart:async';
import 'dart:io';

import 'package:heratmap/l10n/app_translations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// منبع داده‌ای که به کاربر نشان داده می‌شود.
enum DataSource {
  /// داده‌ی تازه از شبکه.
  network,

  /// داده‌ی ذخیره‌شده در حافظه‌ی محلی (اپ آفلاین یا شبکه ضعیف).
  cache,
}

/// نوع خطا — مبنای تصمیم‌گیری برای «تلاش مجدد» و «انتخاب متن ترجمه».
enum DataErrorKind {
  offline,
  timeout,
  unauthorized,
  notFound,
  server,
  malformed,
  unknown,
}

/// خطای لایه‌ی داده با نوع مشخص و کلید ترجمه.
class DataError implements Exception {
  final DataErrorKind kind;

  /// متن فنی (برای لاگ/دیباگ)، نه برای نمایش به کاربر.
  final String? detail;
  final int? statusCode;
  final Object? cause;

  /// بازنویسی صریح «گذرا بودن» وقتی نوع خطا گویا نیست.
  /// مثال: خطای محدودیت دیتابیس (`23xxx`) از نوع `server` است ولی تکرارش بی‌فایده است.
  final bool? transientOverride;

  const DataError(
    this.kind, {
    this.detail,
    this.statusCode,
    this.cause,
    this.transientOverride,
  });

  /// کلید ترجمه‌ی متناسب برای نمایش به کاربر.
  String get messageKey => switch (kind) {
    DataErrorKind.offline => AppStrings.errorOffline,
    DataErrorKind.timeout => AppStrings.errorTimeout,
    DataErrorKind.unauthorized => AppStrings.errorUnauthorized,
    DataErrorKind.notFound => AppStrings.errorNotFound,
    DataErrorKind.server => AppStrings.errorServer,
    DataErrorKind.malformed => AppStrings.errorMalformed,
    DataErrorKind.unknown => AppStrings.errorUnknown,
  };

  /// خطای گذرا: تلاش مجدد یا بازگشت به کش منطقی است.
  bool get isTransient =>
      transientOverride ??
      switch (kind) {
        DataErrorKind.offline => true,
        DataErrorKind.timeout => true,
        DataErrorKind.server => true,
        _ => false,
      };

  /// آیا نمایش دکمه‌ی «تلاش مجدد» به کاربر معنا دارد؟
  bool get isRetryable => isTransient;

  /// تبدیل هر استثنایی به خطای تایپ‌دار.
  static DataError fromException(Object error) {
    if (error is DataError) return error;

    if (error is TimeoutException) {
      return DataError(
        DataErrorKind.timeout,
        detail: error.message,
        cause: error,
      );
    }

    if (error is SocketException) {
      return DataError(
        DataErrorKind.offline,
        detail: error.osError?.message ?? error.message,
        cause: error,
      );
    }

    if (error is HandshakeException || error is HttpException) {
      return DataError(DataErrorKind.offline, detail: '$error', cause: error);
    }

    if (error is PostgrestException) {
      final code = error.code;
      if (code == 'PGRST116') {
        return DataError(
          DataErrorKind.notFound,
          detail: error.message,
          statusCode: 404,
          cause: error,
        );
      }
      if (code == '401' ||
          code == '403' ||
          code == '42501' ||
          code == 'PGRST301') {
        return DataError(
          DataErrorKind.unauthorized,
          detail: error.message,
          statusCode: 401,
          cause: error,
        );
      }
      final rawCode = code ?? '';
      // دردسترس‌نبودن موقت دیتابیس/شبکه‌ی PostgREST → تکرار منطقی است
      final isTransientServer =
          rawCode == 'PGRST000' ||
          rawCode == 'PGRST002' ||
          rawCode == 'PGRST003';
      // خطای ساختار/محدودیت (22xxx, 23xxx, 42xxx) → تکرار بی‌فایده است
      final isRejectedRequest =
          rawCode.startsWith('22') ||
          rawCode.startsWith('23') ||
          rawCode.startsWith('42') ||
          rawCode.startsWith('PGRST1') ||
          rawCode.startsWith('PGRST2');

      return DataError(
        DataErrorKind.server,
        detail: '$rawCode ${error.message}'.trim(),
        cause: error,
        transientOverride: isTransientServer
            ? true
            : (isRejectedRequest ? false : null),
      );
    }

    if (error is AuthException) {
      return DataError(
        DataErrorKind.unauthorized,
        detail: error.message,
        cause: error,
      );
    }

    if (error is FormatException || error is TypeError) {
      return DataError(DataErrorKind.malformed, detail: '$error', cause: error);
    }

    // خطاهای لایه‌ی http بدون وابستگی تایپی قابل تشخیص نیستند
    final text = error.toString();
    if (text.contains('SocketException') ||
        text.contains('ClientException') ||
        text.contains('Failed host lookup') ||
        text.contains('Connection refused') ||
        text.contains('Connection closed')) {
      return DataError(DataErrorKind.offline, detail: text, cause: error);
    }
    if (text.contains('TimeoutException')) {
      return DataError(DataErrorKind.timeout, detail: text, cause: error);
    }

    return DataError(DataErrorKind.unknown, detail: text, cause: error);
  }

  @override
  String toString() => 'DataError($kind, detail: $detail)';
}

/// نتیجه‌ی یک عملیات داده: یا موفق (با منبع و زمان) یا ناموفق (با علت تایپ‌دار).
sealed class DataResult<T> {
  const DataResult();

  /// داده در صورت موفقیت، وگرنه null.
  T? get dataOrNull => switch (this) {
    DataSuccess<T>(:final data) => data,
    DataFailure<T>() => null,
  };

  /// خطا در صورت شکست، وگرنه null.
  DataError? get errorOrNull => switch (this) {
    DataSuccess<T>() => null,
    DataFailure<T>(:final error) => error,
  };

  bool get isSuccess => this is DataSuccess<T>;
}

/// نتیجه‌ی موفق همراه با منبع و زمان دریافت.
class DataSuccess<T> extends DataResult<T> {
  final T data;
  final DataSource source;

  /// زمان دریافت از شبکه؛ برای داده‌ی کش‌شده، زمان ذخیره در حافظه.
  final DateTime? fetchedAt;

  const DataSuccess(
    this.data, {
    this.source = DataSource.network,
    this.fetchedAt,
  });

  /// سن داده نسبت به لحظه‌ی [now].
  Duration age({DateTime? now}) {
    if (fetchedAt == null) return Duration.zero;
    final diff = (now ?? DateTime.now()).difference(fetchedAt!);
    return diff.isNegative ? Duration.zero : diff;
  }

  bool isOlderThan(Duration maxAge, {DateTime? now}) => age(now: now) > maxAge;

  @override
  String toString() => 'DataSuccess($source, $data)';
}

/// نتیجه‌ی ناموفق.
class DataFailure<T> extends DataResult<T> {
  final DataError error;

  const DataFailure(this.error);

  @override
  String toString() => 'DataFailure($error)';
}
