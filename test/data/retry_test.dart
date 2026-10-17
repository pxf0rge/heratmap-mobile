import 'dart:async';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:heratmap/data/result.dart';
import 'package:heratmap/data/retry.dart';

void main() {
  group('withRetry', () {
    test('اجرای موفق در تلاش اول، بدون تأخیر', () async {
      var attempts = 0;
      final delays = <Duration>[];

      final result = await withRetry(() async {
        attempts++;
        return 'ok';
      }, sleep: (d) async => delays.add(d));

      expect(result, 'ok');
      expect(attempts, 1);
      expect(delays, isEmpty);
    });

    test('خطای گذرا تا موفقیت تکرار می‌شود', () async {
      var attempts = 0;
      final delays = <Duration>[];

      final result = await withRetry(() async {
        attempts++;
        if (attempts < 3) throw const DataError(DataErrorKind.offline);
        return 'ok';
      }, sleep: (d) async => delays.add(d), random: Random(7));

      expect(result, 'ok');
      expect(attempts, 3);
      expect(delays.length, 2);
      // تأخیر نمایی: تلاش دوم ≥ تلاش اول
      expect(delays[1].inMilliseconds, greaterThanOrEqualTo(300));
    });

    test('خطای غیرگذرا بلافاصله پرتاب می‌شود', () async {
      var attempts = 0;

      await expectLater(
        withRetry(() async {
          attempts++;
          throw const DataError(DataErrorKind.unauthorized);
        }, sleep: (_) async {}),
        throwsA(isA<DataError>()),
      );

      expect(attempts, 1);
    });

    test('پس از تمام تلاش‌ها، آخرین خطا پرتاب می‌شود', () async {
      var attempts = 0;

      await expectLater(
        withRetry(() async {
          attempts++;
          throw const DataError(DataErrorKind.timeout);
        }, maxAttempts: 4, sleep: (_) async {}),
        throwsA(isA<DataError>()),
      );

      expect(attempts, 4);
    });

    test('isRetryable سفارشی رعایت می‌شود', () async {
      var attempts = 0;

      await expectLater(
        withRetry(() async {
          attempts++;
          throw StateError('boom');
        }, isRetryable: (_) => false, sleep: (_) async {}),
        throwsA(isA<StateError>()),
      );

      expect(attempts, 1);
    });

    test('onRetry شماره‌ی تلاش‌های ناموفق را گزارش می‌دهد', () async {
      final reported = <int>[];

      final result = await withRetry(() async {
        if (reported.length < 2) throw const DataError(DataErrorKind.offline);
        return 1;
      }, sleep: (_) async {}, onRetry: (attempt, _) => reported.add(attempt));

      expect(result, 1);
      expect(reported, [1, 2]);
    });
  });

  group('delayForAttempt', () {
    test('نمایی رشد می‌کند و به سقف+jitter محدود می‌شود', () {
      final random = Random(1);
      const base = Duration(milliseconds: 100);
      const max = Duration(seconds: 1);

      final first = delayForAttempt(1, base, max, random);
      final second = delayForAttempt(2, base, max, random);
      final far = delayForAttempt(8, base, max, random);

      expect(first.inMilliseconds, greaterThanOrEqualTo(100));
      expect(second.inMilliseconds, greaterThanOrEqualTo(200));
      expect(far.inMilliseconds, lessThanOrEqualTo(1250)); // سقف + ۲۵٪ jitter
    });
  });

  group('SingleFlight', () {
    test('درخواست‌های هم‌زمان با یک کلید، یک بار اجرا می‌شوند', () async {
      final single = SingleFlight();
      var calls = 0;
      final completer = Completer<int>();

      Future<int> action() {
        calls++;
        return completer.future;
      }

      final first = single.run('k', action);
      final second = single.run('k', action);

      expect(single.activeCount, 1);

      completer.complete(7);

      expect(await first, 7);
      expect(await second, 7);
      expect(calls, 1);
      expect(single.isEmpty, isTrue);
    });

    test('پس از پایان، اجرای بعدی از نو انجام می‌شود', () async {
      final single = SingleFlight();
      var calls = 0;

      await single.run('k', () async {
        calls++;
        return calls;
      });
      final second = await single.run('k', () async {
        calls++;
        return calls;
      });

      expect(second, 2);
    });

    test('کلیدهای متفاوت جدا اجرا می‌شوند', () async {
      final single = SingleFlight();
      var calls = 0;

      await Future.wait([
        single.run('a', () async => calls++),
        single.run('b', () async => calls++),
      ]);

      expect(calls, 2);
    });

    test('خطای درخواست به همه‌ی منتظران می‌رسد و کلید آزاد می‌شود', () async {
      final single = SingleFlight();

      Future<void> failing() => Future<void>.delayed(
        const Duration(milliseconds: 1),
        () => throw const DataError(DataErrorKind.offline),
      );

      final first = single.run('k', failing);
      final second = single.run('k', failing);

      await expectLater(first, throwsA(isA<DataError>()));
      await expectLater(second, throwsA(isA<DataError>()));
      expect(single.isEmpty, isTrue);
      expect(single.activeCount, 0);
    });
  });
}
