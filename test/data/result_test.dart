import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:heratmap/data/result.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('DataError.fromException', () {
    test('TimeoutException → timeout و گذرا', () {
      final error = DataError.fromException(TimeoutException('too slow'));
      expect(error.kind, DataErrorKind.timeout);
      expect(error.isTransient, isTrue);
      expect(error.isRetryable, isTrue);
    });

    test('SocketException → offline و گذرا', () {
      final error = DataError.fromException(SocketException('no route'));
      expect(error.kind, DataErrorKind.offline);
      expect(error.isTransient, isTrue);
    });

    test('FormatException → malformed و غیرگذرا', () {
      final error = DataError.fromException(const FormatException('bad json'));
      expect(error.kind, DataErrorKind.malformed);
      expect(error.isTransient, isFalse);
    });

    test('PostgrestException بدون ردیف → notFound', () {
      final error = DataError.fromException(
        PostgrestException(message: 'no rows', code: 'PGRST116'),
      );
      expect(error.kind, DataErrorKind.notFound);
      expect(error.isRetryable, isFalse);
    });

    test('PostgrestException نقض دسترسی → unauthorized', () {
      final error = DataError.fromException(
        PostgrestException(message: 'denied', code: '42501'),
      );
      expect(error.kind, DataErrorKind.unauthorized);
      expect(error.isTransient, isFalse);
    });

    test('نقض کلید خارجی → server ولی غیرقابل‌تکرار', () {
      final error = DataError.fromException(
        PostgrestException(
          message: 'violates foreign key constraint',
          code: '23503',
        ),
      );
      expect(error.kind, DataErrorKind.server);
      expect(error.isTransient, isFalse);
    });

    test('خطای موقت PostgREST → server و گذرا', () {
      final error = DataError.fromException(
        PostgrestException(message: 'db unavailable', code: 'PGRST000'),
      );
      expect(error.kind, DataErrorKind.server);
      expect(error.isTransient, isTrue);
    });

    test('خطای ناشناخته → unknown و غیرگذرا', () {
      final error = DataError.fromException(StateError('???'));
      expect(error.kind, DataErrorKind.unknown);
      expect(error.isTransient, isFalse);
    });

    test('DataError ورودی دست‌نخورده برمی‌گردد', () {
      const original = DataError(DataErrorKind.offline, detail: 'x');
      expect(identical(DataError.fromException(original), original), isTrue);
    });

    test('هر نوع خطا کلید ترجمه‌ی یکتا و موجود در هر سه زبان دارد', () {
      final translations = AppTranslations();
      final seenKeys = <String>{};

      for (final kind in DataErrorKind.values) {
        final key = DataError(kind).messageKey;
        expect(key, isNotEmpty);
        expect(key.startsWith('error_'), isTrue, reason: 'کلید: $key');
        expect(seenKeys.add(key), isTrue, reason: 'کلید تکراری: $key');

        for (final lang in ['fa', 'ps', 'en']) {
          expect(
            translations.keys[lang]?[key],
            isNotNull,
            reason: 'ترجمه‌ی $lang برای $key موجود نیست',
          );
        }
      }

      // کلید ثابت برای نمایش به کاربر
      expect(AppStrings.errorOffline, 'error_offline');
    });

    test('متن فنی شامل نوع خطاست', () {
      const error = DataError(DataErrorKind.server, detail: 'boom');
      expect(error.toString(), contains('server'));
      expect(error.toString(), contains('boom'));
    });
  });

  group('DataResult', () {
    test('DataSuccess مقادیر را درست ارائه می‌دهد', () {
      final fetchedAt = DateTime(2026, 9, 11, 10);
      final result = DataSuccess<List<int>>(
        [1, 2, 3],
        fetchedAt: fetchedAt,
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, [1, 2, 3]);
      expect(result.errorOrNull, isNull);
      expect(result.source, DataSource.network);
      expect(
        result.age(now: fetchedAt.add(const Duration(hours: 3))),
        const Duration(hours: 3),
      );
      expect(
        result.isOlderThan(
          const Duration(hours: 1),
          now: fetchedAt.add(const Duration(hours: 3)),
        ),
        isTrue,
      );
    });

    test('لیست خالی یک موفقیت معتبر است، نه خطا', () {
      const result = DataSuccess<List<int>>([]);
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isEmpty);
    });

    test('DataFailure خطا را نگه می‌دارد و داده ندارد', () {
      const failure = DataFailure<List<int>>(
        DataError(DataErrorKind.offline),
      );

      expect(failure.isSuccess, isFalse);
      expect(failure.dataOrNull, isNull);
      expect(failure.errorOrNull?.kind, DataErrorKind.offline);
    });

    test('سن داده‌ی آینده منفی نمی‌شود', () {
      final future = DateTime.now().add(const Duration(hours: 1));
      final result = DataSuccess<int>(1, fetchedAt: future);
      expect(result.age(), Duration.zero);
    });

    test('بدون fetchedAt، سن صفر است', () {
      const result = DataSuccess<int>(1);
      expect(result.age(), Duration.zero);
      expect(result.isOlderThan(const Duration(seconds: 1)), isFalse);
    });
  });
}
