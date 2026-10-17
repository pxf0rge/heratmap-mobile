/// لینک‌ها و متن اشتراک‌گذاری شرکت — توابع خالص و تست‌پذیر.
///
/// این‌ها عمداً از UI جدا هستند تا بتوان بدون اجرای اپ (و بدون پلاگین‌های
/// پلتفرمی) سنجید که با داده‌ی ناقص، لینک غلط ساخته **نمی‌شود**:
/// مهم‌ترینش مختصات صفر است که قبلاً کاربر را به `0,0` (وسط اقیانوس) می‌فرستاد.
library;

import 'package:get/get.dart';
import 'package:heratmap/data/models/factory_model.dart';
import 'package:heratmap/l10n/app_translations.dart';

/// ارقام فارسی/عربی را به لاتین برمی‌گرداند.
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

/// شماره‌ی تماس را به شکل قابل‌استفاده در `tel:` برمی‌گرداند.
///
/// - ارقام فارسی/عربی تبدیل می‌شوند (`۰۷۹۱…` کار می‌کند).
/// - فاصله، خط تیره، پرانتز و نقطه حذف می‌شوند.
/// - `+` فقط در ابتدا مجاز است.
/// - اگر پس از پاک‌سازی کمتر از ۷ یا بیشتر از ۱۵ رقم بماند، `null` می‌دهد
///   (شماره‌ی ناقص مثل `0791` نباید دکمه‌ی تماس را فعال کند).
String? normalizePhoneNumber(String raw) {
  final text = _latinDigits(raw).trim();
  if (text.isEmpty) return null;

  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    final char = text[i];
    if (char == '+' && i == 0) {
      buffer.write('+');
    } else if (RegExp(r'[0-9]').hasMatch(char)) {
      buffer.write(char);
    }
  }

  final value = buffer.toString();
  final digits = value.startsWith('+') ? value.substring(1) : value;
  if (digits.length < 7 || digits.length > 15) return null;
  if (value.startsWith('+') && digits.isEmpty) return null;

  return value;
}

/// `tel:` برای دکمه‌ی تماس؛ `null` = شماره‌ی نامعتبر.
Uri? factoryTelUri(String phone) {
  final normalized = normalizePhoneNumber(phone);
  return normalized == null ? null : Uri(scheme: 'tel', path: normalized);
}

/// لینک نمایش مکان روی Google Maps (برای اشتراک‌گذاری).
/// `null` = مختصات معتبر نیست (مثلاً صفر).
Uri? factoryLocationUri(FactoryModel factory) {
  if (!factory.hasValidLocation) return null;
  return Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=${factory.lat},${factory.lon}',
  );
}

/// لینک مسیریابی وب Google Maps.
Uri? factoryDirectionsUri(FactoryModel factory) {
  if (!factory.hasValidLocation) return null;
  return Uri.parse(
    'https://www.google.com/maps/dir/?api=1'
    '&destination=${factory.lat},${factory.lon}&travelmode=driving',
  );
}

/// URI اپ رسمی ناوبری گوگل (اندروید).
Uri? factoryNavigationAppUri(FactoryModel factory) {
  if (!factory.hasValidLocation) return null;
  return Uri.parse('google.navigation:q=${factory.lat},${factory.lon}&mode=d');
}

/// متن اشتراک‌گذاری به **زبان فعلی اپ**.
///
/// [translate] برای تست تزریق می‌شود؛ پیش‌فرض، ترجمه‌ی GetX همان کلید است.
/// ردیف‌های خالی حذف می‌شوند تا متن اشتراک‌گذاری خط خالی نداشته باشد.
String buildFactoryShareText(
  FactoryModel factory, {
  String Function(String key)? translate,
}) {
  String tr(String key) => (translate ?? (key) => key.tr)(key);

  final lines = <String>[
    '${tr(AppStrings.appName)} — ${factory.name}',
    if (factory.phase.isNotEmpty)
      '${tr(AppStrings.phaseLabel)}: ${factory.phase}',
    if (factory.lotNumber.isNotEmpty)
      'نمره/قطعه: ${factory.lotNumber}',
    if (factory.category.isNotEmpty)
      '${tr(AppStrings.category)}: ${factory.category}',
    if (factory.address.isNotEmpty)
      '${tr(AppStrings.address)}: ${factory.address}',
    if (factory.phone.isNotEmpty) '${tr(AppStrings.phone)}: ${factory.phone}',
    if (factory.workStart.isNotEmpty || factory.workEnd.isNotEmpty)
      '${tr(AppStrings.workingHours)}: ${factory.workStart} - ${factory.workEnd}',
    if (factory.websiteUrl.isNotEmpty) '${tr(AppStrings.supportWebsite)}: ${factory.websiteUrl}',
  ];

  final location = factoryLocationUri(factory);
  if (location != null) lines.add(location.toString());

  return lines.join('\n');
}
