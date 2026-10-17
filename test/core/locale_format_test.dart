import 'package:flutter_test/flutter_test.dart';
import 'package:heratmap/core/locale_format.dart';

void main() {
  group('localizeDigits', () {
    test('انگلیسی ارقام لاتین را نگه می‌دارد', () {
      expect(localizeDigits('019', localeCode: 'en'), '019');
    });

    test('دری/پشتو ارقام را تبدیل می‌کند', () {
      expect(localizeDigits('019', localeCode: 'fa'), '\u06F0\u06F1\u06F9');
      expect(localizeDigits('019', localeCode: 'ps'), '\u06F0\u06F1\u06F9');
    });

    test('متن غیرعددی دست‌نخورده می‌ماند', () {
      expect(localizeDigits('فاز 1', localeCode: 'fa'), 'فاز \u06F1');
      expect(localizeDigits('07:30', localeCode: 'fa'), '\u06F0\u06F7:\u06F3\u06F0');
    });
  });

  group('formatInteger', () {
    test('جداکننده‌ی هزارگان بر اساس زبان', () {
      expect(formatInteger(1234, localeCode: 'en'), '1,234');
      expect(formatInteger(1234, localeCode: 'fa'), '\u06F1\u066C\u06F2\u06F3\u06F4');
      expect(formatInteger(999, localeCode: 'en'), '999');
      expect(formatInteger(1234567, localeCode: 'en'), '1,234,567');
    });

    test('عدد منفی', () {
      expect(formatInteger(-42, localeCode: 'en'), '-42');
      expect(formatInteger(-42, localeCode: 'fa'), '-\u06F4\u06F2');
    });

    test('عدد اعشاری گرد می‌شود', () {
      expect(formatInteger(12.6, localeCode: 'en'), '13');
    });

    test('سال با جداکننده‌ی هزارگان نوشته نمی‌شود', () {
      expect(formatInteger(2026, localeCode: 'en'), '2,026');
      expect(
        formatInteger(2026, localeCode: 'en', group: false),
        '2026',
      );
    });
  });

  group('formatDecimal', () {
    test('جداکننده‌ی اعشار بر اساس زبان', () {
      expect(formatDecimal(1.5, localeCode: 'en'), '1.5');
      expect(formatDecimal(1.5, localeCode: 'fa'), '\u06F1\u066B\u06F5');
      expect(
        formatDecimal(1234.25, fractionDigits: 2, localeCode: 'fa'),
        '\u06F1\u066C\u06F2\u06F3\u06F4\u066B\u06F2\u06F5',
      );
    });
  });

  group('formatLocalDate', () {
    test('نام ماه و ارقام زبان مقصد', () {
      final date = DateTime(2026, 9, 12);
      expect(formatLocalDate(date, localeCode: 'en'), '12 Sep 2026');
      expect(
        formatLocalDate(date, localeCode: 'fa'),
        '\u06F1\u06F2 \u0633\u067E\u062A\u0645\u0628\u0631 \u06F2\u06F0\u06F2\u06F6',
      );
    });

    test('بدون سال', () {
      expect(
        formatLocalDate(DateTime(2026, 1, 3), localeCode: 'en', withYear: false),
        '3 Jan',
      );
    });
  });

  group('formatClockLabel', () {
    test('ساعت با ارقام مقصد', () {
      expect(formatClockLabel('19:00', localeCode: 'en'), '19:00');
      expect(formatClockLabel('19:00', localeCode: 'fa'), '\u06F1\u06F9:\u06F0\u06F0');
    });
  });

  test('جهت زبان', () {
    expect(isRtlLocale('fa'), isTrue);
    expect(isRtlLocale('ps'), isTrue);
    expect(isRtlLocale('en'), isFalse);
  });
}
