import 'package:get/get.dart';
import 'package:heratmap/core/locale_format.dart';
import 'package:heratmap/l10n/app_translations.dart';

/// متن «چند وقت پیش» به زبان فعلی اپ.
///
/// مثال: `اکنون`، `۵ دقیقه پیش`، `۳ ساعت پیش`، `۲ روز پیش`.
/// ارقام با زبان اپ محلی می‌شوند (`۱۲` در برابر `12`).
///
/// برای داده‌ی قدیمی‌تر از یک هفته، «۷ روز پیش» اطلاعات کمی می‌دهد؛ پس تاریخ
/// محلی می‌آید: «۱۲ سپتمبر» / `12 Sep`.
String relativeTimeText(DateTime time, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(time);
  final elapsed = diff.isNegative ? Duration.zero : diff;

  if (elapsed.inMinutes < 1) return AppStrings.timeNow.tr;
  if (elapsed.inHours < 1) {
    return AppStrings.timeMinutesAgo.trParams({
      'n': formatInteger(elapsed.inMinutes),
    });
  }
  if (elapsed.inDays < 1) {
    return AppStrings.timeHoursAgo.trParams({
      'n': formatInteger(elapsed.inHours),
    });
  }
  if (elapsed.inDays < 7) {
    return AppStrings.timeDaysAgo.trParams({
      'n': formatInteger(elapsed.inDays),
    });
  }
  return formatLocalDate(time, withYear: false);
}
