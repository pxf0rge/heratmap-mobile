/// پارس «ساعت کاری» و تعیین باز/بسته بودن بر اساس ساعت محلی افغانستان.
///
/// داده‌ی دیتابیس یک متن آزاد است (`7 - 7`, `۷-۷`, `7:30 - 16:00`, …)، پس
/// اینجا یک پارسر تحمل‌کننده داریم که قالب‌های رایج را می‌فهمد و در غیر آن
/// حالت «نامشخص» برمی‌گرداند تا UI چیز نادرست ادعا نکند.
library;

/// افغانستان UTC+04:30 است و از ۱۹۴۵ ساعت تابستانی ندارد، پس تبدیل ثابت است
/// و به پایگاه‌داده‌ی منطقه‌زمانی نیازی نیست.
const Duration afghanistanUtcOffset = Duration(hours: 4, minutes: 30);

/// ساعت محلی افغانستان در لحظه‌ی [utcNow] (پیش‌فرض: اکنون).
DateTime afghanistanTime({DateTime? utcNow}) {
  final utc = (utcNow ?? DateTime.now()).toUtc();
  return utc.add(afghanistanUtcOffset);
}

/// یک بازه‌ی کاری در قالب «دقیقه از نیمه‌شب».
class WorkingHours {
  const WorkingHours(this.openMinute, this.closeMinute);

  /// دقیقه‌ی شروع کار (۰ تا ۱۴۳۹).
  final int openMinute;

  /// دقیقه‌ی پایان کار؛ اگر کوچک‌تر از [openMinute] باشد، پایان در روز بعد است.
  final int closeMinute;

  /// آیا بازه از نیمه‌شب می‌گذرد؟ (مثل `22 - 6`)
  bool get isOvernight => closeMinute < openMinute;

  /// مدت باز بودن به دقیقه.
  int get durationMinutes => isOvernight
      ? (1440 - openMinute + closeMinute)
      : closeMinute - openMinute;

  /// ساعت شروع به شکل `07:00`.
  String get openLabel => formatMinuteOfDay(openMinute);

  /// ساعت پایان به شکل `19:00`.
  String get closeLabel => formatMinuteOfDay(closeMinute);

  @override
  String toString() => 'WorkingHours($openLabel-$closeLabel)';
}

/// وضعیت لحظه‌ای نسبت به ساعت کاری.
enum OpenStatusKind {
  open,

  /// بسته است (ولی ساعت کاری معلوم است → زمان باز شدن را می‌دانیم)
  closed,

  /// متن ساعت کاری قابل فهم نبود
  unknown,
}

/// نتیجه‌ی ارزیابی ساعت کاری در یک لحظه.
class OpenStatus {
  const OpenStatus._(this.kind, this.hours, this.minutesUntilChange);

  const OpenStatus.open(WorkingHours hours, int minutesUntilChange)
    : this._(OpenStatusKind.open, hours, minutesUntilChange);

  const OpenStatus.closed(WorkingHours hours, int minutesUntilChange)
    : this._(OpenStatusKind.closed, hours, minutesUntilChange);

  const OpenStatus.unknown() : this._(OpenStatusKind.unknown, null, null);

  final OpenStatusKind kind;

  /// ساعت کاری فهمیده‌شده (در حالت `unknown` تهی است).
  final WorkingHours? hours;

  /// دقیقه تا تغییر وضعیت: تا بسته‌شدن (اگر باز است) یا تا باز شدن.
  final int? minutesUntilChange;

  bool get isOpen => kind == OpenStatusKind.open;
  bool get isKnown => kind != OpenStatusKind.unknown;
}

/// ساعت کاری را از متن دیتابیس می‌خواند.
///
/// قالب‌های پشتیبانی‌شده:
/// `7 - 7`، `7-7`، `۷-۷`، `7:30 - 16:00`، `7 تا 17`، `8 الی 16`، `9am-5pm`،
/// `۸ صبح تا ۵ عصر`.
///
/// اگر متن چند بازه داشته باشد (مثل `8-12, 13-17`)، **اولین** بازه برداشته
/// می‌شود؛ پشتیبانی چندبازه‌ای کار آینده است.
WorkingHours? parseWorkingHours(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;

  final tokens = _timeTokens(text);
  if (tokens.length < 2) return null;

  var open = tokens[0];
  var close = tokens[1];

  // نشانه‌های بعدازظهر: «۵ عصر» یعنی ۱۷
  final lowered = text.toLowerCase();
  final hasPm =
      lowered.contains('pm') ||
      text.contains('عصر') ||
      text.contains('شب') ||
      text.contains('بعدازظهر') ||
      text.contains('بعد از ظهر');
  final hasAm =
      lowered.contains('am') ||
      text.contains('صبح') ||
      text.contains('قبل از ظهر');

  const noon = 12 * 60;
  const maxPlausibleShift = 14 * 60;

  if (hasAm && hasPm) {
    // «۸ صبح تا ۵ عصر» → نیمه‌ی اول قبل از ظهر، نیمه‌ی دوم بعد از ظهر
    if (open == noon) open = 0;
    if (close < noon) close += noon;
  } else if (hasPm) {
    if (open < noon) open += noon;
    if (close < noon) close += noon;
  } else if (hasAm) {
    if (open == noon) open = 0;
    if (close == noon) close = 0;
  }

  // «7 - 7» یعنی هفت صبح تا هفت عصر، نه بیست‌وچهار ساعت کار
  if (close == open && close < noon) close += noon;

  // «9 - 5» را نباید شیفت شبانه (09:00 – 05:00، یعنی ۲۰ ساعت کار) خواند.
  // اگر تفسیر شبانه غیرواقعی باشد و تفسیر روزانه معقول، روزانه انتخاب می‌شود؛
  // در غیر این صورت (مثل «2 - 6» یا «22 - 6») شیفت شبانه حفظ می‌شود.
  if (close < open && close < noon && open < noon) {
    final overnightDuration = 1440 - open + close;
    if (overnightDuration > maxPlausibleShift) close += noon;
  }

  if (open > 1440 || close > 1440) return null;
  // 24:00 را مثل نیمه‌شب روز بعد می‌گیریم
  if (open == 1440) open = 0;
  if (close == 1440) close = 0;

  if (open == close) return null; // بی‌معنا
  return WorkingHours(open, close);
}

/// وضعیت [hours] در ساعت [localTime] (ساعتی که به کاربر مربوط است).
OpenStatus openStatusAt(WorkingHours hours, DateTime localTime) {
  final now = localTime.hour * 60 + localTime.minute;
  final open = hours.openMinute;
  final close = hours.closeMinute;

  final isOpen = hours.isOvernight
      ? (now >= open || now < close)
      : (now >= open && now < close);

  if (isOpen) {
    final untilClose = hours.isOvernight && now >= open
        ? (1440 - now + close)
        : close - now;
    return OpenStatus.open(hours, untilClose);
  }

  final untilOpen = open >= now ? open - now : (1440 - now + open);
  return OpenStatus.closed(hours, untilOpen);
}

/// وضعیت «اکنون» بر اساس ساعت محلی افغانستان.
OpenStatus currentWorkingStatus(String raw, {DateTime? utcNow}) {
  final hours = parseWorkingHours(raw);
  if (hours == null) return const OpenStatus.unknown();
  return openStatusAt(hours, afghanistanTime(utcNow: utcNow));
}

/// `435` → `07:15`
String formatMinuteOfDay(int minuteOfDay) {
  final safe = minuteOfDay % 1440;
  final hour = (safe ~/ 60).toString().padLeft(2, '0');
  final minute = (safe % 60).toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// همه‌ی «ساعت:دقیقه»های متن را به دقیقه از نیمه‌شب تبدیل می‌کند.
List<int> _timeTokens(String text) {
  final normalized = _latinDigits(text);
  final matches = RegExp(r'(\d{1,2})(?::(\d{2}))?').allMatches(normalized);

  final result = <int>[];
  for (final match in matches) {
    final hour = int.tryParse(match.group(1) ?? '');
    if (hour == null) continue;
    final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
    if (minute > 59 || hour > 24) return const [];
    result.add(hour * 60 + minute);
  }
  return result;
}

/// ارقام فارسی/عربی را به لاتین برمی‌گرداند و بقیه‌ی متن را دست نمی‌زند.
String _latinDigits(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    if (rune >= 0x0660 && rune <= 0x0669) {
      buffer.write(rune - 0x0660);
    } else if (rune >= 0x06F0 && rune <= 0x06F9) {
      buffer.write(rune - 0x06F0);
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

/// بازه‌ی کاری به شکل «07:00 - 19:00» برای نمایش.
String workingHoursLabel(WorkingHours hours) =>
    '${hours.openLabel} - ${hours.closeLabel}';

/// نرمال‌سازی متن ساعت کاری برای نمایش یکدست (اگر پارس نشد، خود متن).
String displayWorkingHours(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';
  final hours = parseWorkingHours(trimmed);
  return hours == null ? trimmed : workingHoursLabel(hours);
}
