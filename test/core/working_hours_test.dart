import 'package:flutter_test/flutter_test.dart';
import 'package:heratmap/core/working_hours.dart';

void main() {
  group('parseWorkingHours', () {
    test('قالب ساده‌ی «7 - 7» یعنی هفت صبح تا هفت عصر', () {
      final hours = parseWorkingHours('7 - 7')!;
      expect(hours.openMinute, 7 * 60);
      expect(hours.closeMinute, 19 * 60);
      expect(hours.openLabel, '07:00');
      expect(hours.closeLabel, '19:00');
      expect(hours.isOvernight, isFalse);
    });

    test('ارقام فارسی و چسبیده پذیرفته می‌شوند', () {
      final hours = parseWorkingHours('\u06F7-\u06F7')!;
      expect(hours.openMinute, 7 * 60);
      expect(hours.closeMinute, 19 * 60);

      final attached = parseWorkingHours('7:30-16:00')!;
      expect(attached.openLabel, '07:30');
      expect(attached.closeLabel, '16:00');
    });

    test('نشانه‌های قبل/بعد از ظهر', () {
      final english = parseWorkingHours('9am-5pm')!;
      expect(english.openLabel, '09:00');
      expect(english.closeLabel, '17:00');

      final persian = parseWorkingHours(
        '\u06F8 \u0635\u0628\u062D \u062A\u0627 \u06F5 \u0639\u0635\u0631',
      )!;
      expect(persian.openLabel, '08:00');
      expect(persian.closeLabel, '17:00');
    });

    test('«9 - 5» پنج عصر فهمیده می‌شود، نه پنج صبح', () {
      final hours = parseWorkingHours('9 - 5')!;
      expect(hours.openLabel, '09:00');
      expect(hours.closeLabel, '17:00');
    });

    test('شیفت شبانه (22 - 6) از نیمه‌شب می‌گذرد', () {
      final hours = parseWorkingHours('22 - 6')!;
      expect(hours.isOvernight, isTrue);
      expect(hours.durationMinutes, 8 * 60);
      expect(hours.closeLabel, '06:00');
    });

    test('«تا» و «الی» هم جداکننده‌اند', () {
      expect(parseWorkingHours('8 \u062A\u0627 16')!.closeLabel, '16:00');
      expect(parseWorkingHours('8 \u0627\u0644\u06CC 16')!.closeLabel, '16:00');
    });

    test('متن نامفهوم یا خالی → null (ادعای نادرست نمی‌کنیم)', () {
      expect(parseWorkingHours(''), isNull);
      expect(parseWorkingHours('   '), isNull);
      expect(parseWorkingHours('همیشه باز'), isNull);
      expect(parseWorkingHours('7'), isNull);
      expect(parseWorkingHours('7 - 7 - 7 - 7'), isNotNull);
    });

    test('ساعت بی‌معنا رد می‌شود', () {
      expect(parseWorkingHours('7 - 25'), isNull);
      expect(parseWorkingHours('7:99 - 8:00'), isNull);
    });
  });

  group('openStatusAt', () {
    final hours = parseWorkingHours('7 - 7')!;

    test('ساعت ۱۰ صبح باز است و تا ۹ ساعت دیگر باز می‌ماند', () {
      final status = openStatusAt(hours, DateTime(2026, 9, 12, 10));
      expect(status.kind, OpenStatusKind.open);
      expect(status.minutesUntilChange, 9 * 60);
    });

    test('ساعت ۲۲ بسته است و ۹ ساعت تا باز شدن مانده', () {
      final status = openStatusAt(hours, DateTime(2026, 9, 12, 22));
      expect(status.kind, OpenStatusKind.closed);
      expect(status.minutesUntilChange, 9 * 60);
    });

    test('مرزها: شروع باز، پایان بسته', () {
      expect(
        openStatusAt(hours, DateTime(2026, 9, 12, 7, 0)).kind,
        OpenStatusKind.open,
      );
      expect(
        openStatusAt(hours, DateTime(2026, 9, 12, 19, 0)).kind,
        OpenStatusKind.closed,
      );
    });

    test('شیفت شبانه در ۲۳ باز و در ۱۲ بسته است', () {
      final night = parseWorkingHours('22 - 6')!;
      expect(
        openStatusAt(night, DateTime(2026, 9, 12, 23)).kind,
        OpenStatusKind.open,
      );
      expect(
        openStatusAt(night, DateTime(2026, 9, 12, 12)).kind,
        OpenStatusKind.closed,
      );
    });
  });

  group('ساعت محلی افغانستان', () {
    test('افست ثابت +4:30 است', () {
      expect(afghanistanUtcOffset, const Duration(hours: 4, minutes: 30));

      final kabul = afghanistanTime(utcNow: DateTime.utc(2026, 9, 12, 5, 0));
      expect(kabul.hour, 9);
      expect(kabul.minute, 30);
    });

    test('وضعیت اکنون با ساعت کابل محاسبه می‌شود', () {
      // ۰۵:۰۰ UTC → ۰۹:۳۰ کابل → باز
      expect(
        currentWorkingStatus(
          '7 - 7',
          utcNow: DateTime.utc(2026, 9, 12, 5),
        ).kind,
        OpenStatusKind.open,
      );

      // ۱۸:۰۰ UTC → ۲۲:۳۰ کابل → بسته
      expect(
        currentWorkingStatus(
          '7 - 7',
          utcNow: DateTime.utc(2026, 9, 12, 18),
        ).kind,
        OpenStatusKind.closed,
      );

      expect(
        currentWorkingStatus('', utcNow: DateTime.utc(2026, 9, 12, 5)).kind,
        OpenStatusKind.unknown,
      );
    });
  });

  group('نمایش ساعت', () {
    test('formatMinuteOfDay دو رقمی است', () {
      expect(formatMinuteOfDay(0), '00:00');
      expect(formatMinuteOfDay(7 * 60 + 5), '07:05');
      expect(formatMinuteOfDay(23 * 60 + 59), '23:59');
    });

    test(
      'displayWorkingHours متن را یکدست می‌کند و متن ناشناس را دست‌نخورده می‌گذارد',
      () {
        expect(displayWorkingHours('7 - 7'), '07:00 - 19:00');
        expect(displayWorkingHours('  7:30-16:00  '), '07:30 - 16:00');
        expect(displayWorkingHours('همیشه باز'), 'همیشه باز');
        expect(displayWorkingHours(''), '');
      },
    );
  });
}
