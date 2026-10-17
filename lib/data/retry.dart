import 'dart:math';

import 'package:heratmap/data/result.dart';

/// تابع خواب قابل تزریق — در تست‌ها بدون تأخیر واقعی استفاده می‌شود.
typedef Sleeper = Future<void> Function(Duration duration);

/// اجرای [action] با تلاش مجدد نمایی + jitter، فقط برای خطاهای گذرا.
///
/// - خطاهای غیرگذرا (۴xx، داده‌ی خراب) بلافاصله پرتاب می‌شوند.
/// - تلاش‌ها: ۱ اجرای اول + `maxAttempts - 1` تلاش مجدد.
Future<T> withRetry<T>(
  Future<T> Function() action, {
  int maxAttempts = 3,
  Duration baseDelay = const Duration(milliseconds: 300),
  Duration maxDelay = const Duration(seconds: 4),
  bool Function(Object error)? isRetryable,
  Sleeper? sleep,
  void Function(int attempt, Object error)? onRetry,
  Random? random,
}) async {
  final shouldRetry =
      isRetryable ?? (error) => DataError.fromException(error).isTransient;
  final sleepFor = sleep ?? ((duration) => Future<void>.delayed(duration));
  final randomSource = random ?? Random();

  var attempt = 0;
  while (true) {
    attempt++;
    try {
      return await action();
    } catch (error) {
      final lastAttempt = attempt >= maxAttempts;
      if (lastAttempt || !shouldRetry(error)) rethrow;
      onRetry?.call(attempt, error);
      await sleepFor(
        delayForAttempt(attempt, baseDelay, maxDelay, randomSource),
      );
    }
  }
}

/// تأخیر نمایی: ۱x، ۲x، ۴x ... با سقف [maxDelay] و jitter تا ۲۵٪.
Duration delayForAttempt(
  int attempt,
  Duration baseDelay,
  Duration maxDelay,
  Random random,
) {
  final exponential = baseDelay.inMilliseconds * (1 << (attempt - 1));
  final capped = exponential.clamp(0, maxDelay.inMilliseconds);
  final jitter = (capped * 0.25 * random.nextDouble()).round();
  return Duration(milliseconds: capped + jitter);
}

/// ادغام درخواست‌های هم‌زمان برای یک کلید؛ نتیجه‌ی یک درخواست به همه‌ی منتظران داده می‌شود.
class SingleFlight {
  final Map<String, Future<dynamic>> _inFlight = {};

  /// تعداد درخواست‌های در جریان (برای تست/دیباگ).
  int get activeCount => _inFlight.length;

  bool get isEmpty => _inFlight.isEmpty;

  Future<T> run<T>(String key, Future<T> Function() action) {
    final existing = _inFlight[key];
    if (existing != null) return existing.then((value) => value as T);

    final future = Future<T>.sync(action);
    _inFlight[key] = future;
    return future.whenComplete(() {
      if (identical(_inFlight[key], future)) _inFlight.remove(key);
    });
  }

  void clear() => _inFlight.clear();
}
