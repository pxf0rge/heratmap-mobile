/// قالب‌بندی محلی اعداد و تاریخ — بدون وابستگی به `intl`.
///
/// `intl` فقط به‌صورت وابستگی غیرمستقیم در دسترس است و افزودنش به `pubspec`
/// از این شبکه (pub.dev مسدود) ممکن نیست؛ پس همان چیزی که لازم داریم اینجا
/// پیاده شده و تست می‌شود: ارقام زبان مقصد، جداکننده‌ی هزارگان و اعشار، و
/// نام ماه‌ها.
library;

import 'package:get/get.dart';

/// نام ماه‌های میلادی به دری/پشتو — در افغانستان همین شکل رایج است
/// (جنوری، فبروری، …). نام‌های شمسی (حمل، ثور، …) کار آینده است.
const List<String> _dariMonths = [
  'جنوری',
  'فبروری',
  'مارچ',
  'اپریل',
  'می',
  'جون',
  'جولای',
  'اگست',
  'سپتمبر',
  'اکتوبر',
  'نومبر',
  'دسمبر',
];

const List<String> _englishMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// ارقام فارسی/پشتو.
const String _persianDigits =
    '\u06F0\u06F1\u06F2\u06F3\u06F4\u06F5\u06F6\u06F7\u06F8\u06F9';

const String _persianThousandsSeparator = '\u066C';
const String _persianDecimalSeparator = '\u066B';

/// کد زبان فعلی اپ (پیش‌فرض `fa`).
String currentLocaleCode() => Get.locale?.languageCode ?? 'fa';

/// آیا زبان مقصد راست‌به‌چپ است؟
bool isRtlLocale(String localeCode) => localeCode != 'en';

/// ارقام لاتین را به ارقام زبان مقصد تبدیل می‌کند (`12` → `۱۲`).
///
/// متن غیرعددی دست‌نخورده می‌ماند، پس برای ساعت و نسخه هم قابل استفاده است.
String localizeDigits(String input, {String? localeCode}) {
  final code = localeCode ?? currentLocaleCode();
  if (code == 'en') return input;

  final buffer = StringBuffer();
  for (final rune in input.runes) {
    if (rune >= 0x30 && rune <= 0x39) {
      buffer.writeCharCode(_persianDigits.runes.first + (rune - 0x30));
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

/// عدد صحیح با جداکننده‌ی هزارگان زبان مقصد: `1234` → `۱٬۲۳۴`.
///
/// برای شماره‌های شناسه‌مانند (سال، کد) [group] را `false` بدهید تا `2026`
/// به `2,026` تبدیل نشود.
String formatInteger(num value, {String? localeCode, bool group = true}) {
  final code = localeCode ?? currentLocaleCode();
  final whole = value.isFinite ? value.round() : 0;
  final negative = whole < 0;

  final digits = whole.abs().toString();
  final text = group
      ? _groupThousands(digits, code == 'en' ? ',' : _persianThousandsSeparator)
      : digits;
  return '${negative ? '-' : ''}${localizeDigits(text, localeCode: code)}';
}

/// عدد اعشاری با جداکننده‌ی اعشار زبان مقصد: `1.5` → `۱٫۵`.
String formatDecimal(
  double value, {
  int fractionDigits = 1,
  String? localeCode,
}) {
  final code = localeCode ?? currentLocaleCode();
  final safe = value.isFinite ? value : 0.0;
  final negative = safe < 0;

  final parts = safe.abs().toStringAsFixed(fractionDigits).split('.');
  final whole = formatInteger(int.parse(parts.first), localeCode: code);
  if (parts.length < 2) return '${negative ? '-' : ''}$whole';

  final fraction = localizeDigits(parts[1], localeCode: code);
  final separator = code == 'en' ? '.' : _persianDecimalSeparator;
  return '${negative ? '-' : ''}$whole$separator$fraction';
}

/// تاریخ میلادی با نام ماه زبان مقصد.
///
/// `formatLocalDate(DateTime(2026, 9, 12))` → `۱۲ سپتمبر ۲۰۲۶` (fa) و
/// `12 Sep 2026` (en).
String formatLocalDate(
  DateTime date, {
  String? localeCode,
  bool withYear = true,
}) {
  final code = localeCode ?? currentLocaleCode();
  final months = code == 'en' ? _englishMonths : _dariMonths;

  return [
    formatInteger(date.day, localeCode: code, group: false),
    months[date.month - 1],
    if (withYear) formatInteger(date.year, localeCode: code, group: false),
  ].join(' ');
}

/// ساعت `HH:mm` با ارقام زبان مقصد (`19:00` → `۱۹:۰۰`).
String formatClockLabel(String hourMinute, {String? localeCode}) =>
    localizeDigits(hourMinute, localeCode: localeCode);

String _groupThousands(String digits, String separator) {
  if (digits.length <= 3) return digits;

  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(separator);
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
