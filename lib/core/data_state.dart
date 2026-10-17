import 'package:get/get.dart';
import 'package:heratmap/data/result.dart';

/// متن ترجمه‌شده‌ی خطا برای نمایش در UI.
extension DataErrorText on DataError {
  String get text => messageKey.tr;

  /// متن فنی برای لاگ (نه نمایش).
  String get technicalText => '[$kind] ${detail ?? ''}'.trim();
}

/// وضعیت مشترک کنترلرها هنگام خواندن داده: بارگذاری، خطا، منبع و زمان.
///
/// با این mixin هر کنترلر فقط داده‌ی خودش را نگه می‌دارد و «چطور نمایش داده
/// شود» (اسپینر/بنر/خطا) از همین چهار مقدار خوانده می‌شود.
mixin DataStateMixin on GetxController {
  final isLoading = false.obs;

  /// آخرین خطا؛ در شروع هر بارگذاری پاک می‌شود.
  final dataError = Rxn<DataError>();

  /// منبع داده‌ی فعلی (شبکه یا حافظه‌ی محلی).
  final dataSource = Rxn<DataSource>();

  /// زمان دریافت/ذخیره‌ی داده‌ی فعلی.
  final lastUpdatedAt = Rxn<DateTime>();

  bool get hasError => dataError.value != null;

  String? get errorText => dataError.value?.text;

  /// آیا داده‌ی نمایش‌داده‌شده از حافظه‌ی محلی است؟
  bool get isFromCache => dataSource.value == DataSource.cache;

  /// انتقال منبع/زمان از نتیجه به وضعیت کنترلر (بدون دست‌زدن به بارگذاری).
  void applyResult<T>(DataResult<T> result) {
    switch (result) {
      case DataSuccess<T>(:final source, :final fetchedAt):
        dataError.value = null;
        dataSource.value = source;
        lastUpdatedAt.value = fetchedAt;
      case DataFailure<T>(:final error):
        dataError.value = error;
    }
  }
}
