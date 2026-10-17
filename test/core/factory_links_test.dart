import 'package:flutter_test/flutter_test.dart';
import 'package:heratmap/core/factory_links.dart';
import 'package:heratmap/data/models/factory_model.dart';

FactoryModel _factory({
  String id = '1',
  String name = 'زلال موفق',
  String category = 'برق و قدرت',
  String phase = 'فاز 1',
  double lat = 34.217654,
  double lon = 62.207864,
  String address = 'خیابان اول',
  String phone = '0791323424',
  String workStart = '07:00',
  String workEnd = '19:00',
  String lotNumber = '',
  bool isActive = true,
  String description = '',
  String image = '',
  String websiteUrl = '',
}) => FactoryModel(
  id: id,
  name: name,
  category: category,
  phase: phase,
  lat: lat,
  lon: lon,
  address: address,
  phone: phone,
  workStart: workStart,
  workEnd: workEnd,
  lotNumber: lotNumber,
  isActive: isActive,
  description: description,
  image: image,
  websiteUrl: websiteUrl,
);

void main() {
  group('normalizePhoneNumber', () {
    test('شماره‌ی ساده دست‌نخورده می‌ماند', () {
      expect(normalizePhoneNumber('0791323424'), '0791323424');
    });

    test('ارقام فارسی/عربی و فاصله و خط تیره پاک می‌شوند', () {
      expect(
        normalizePhoneNumber('\u06F0\u06F7\u06F9\u06F1 ۳۲۳-۴۲۴'),
        '0791323424',
      );
      expect(normalizePhoneNumber('+93 79 123 4567'), '+93791234567');
      expect(normalizePhoneNumber('(0791) 323-424'), '0791323424');
    });

    test('شماره‌ی ناقص یا خالی نامعتبر است', () {
      expect(normalizePhoneNumber('0791'), isNull);
      expect(normalizePhoneNumber(''), isNull);
      expect(normalizePhoneNumber('   '), isNull);
      expect(normalizePhoneNumber('تماس: ندارد'), isNull);
      expect(normalizePhoneNumber('12345678901234567890'), isNull);
    });

    test('+ فقط در ابتدای شماره مجاز است', () {
      expect(normalizePhoneNumber('0791+323424'), '0791323424');
    });
  });

  group('factoryTelUri', () {
    test('برای شماره‌ی معتبر لینک tel ساخته می‌شود', () {
      expect(factoryTelUri('0791323424')!.toString(), 'tel:0791323424');
    });

    test('برای شماره‌ی نامعتبر هیچ لینکی ساخته نمی‌شود', () {
      expect(factoryTelUri('0791'), isNull);
      expect(factoryTelUri(''), isNull);
    });
  });

  group('لینک‌های مکان', () {
    test('مختصات معتبر → لینک مکان و مسیریابی', () {
      final factory = _factory();
      expect(
        factoryLocationUri(factory)!.toString(),
        contains('34.217654,62.207864'),
      );
      expect(
        factoryDirectionsUri(factory)!.toString(),
        contains('destination=34.217654,62.207864'),
      );
      expect(
        factoryNavigationAppUri(factory)!.toString(),
        'google.navigation:q=34.217654,62.207864&mode=d',
      );
    });

    test(
      'مختصات صفر → هیچ لینکی ساخته نمی‌شود (کاربر به وسط اقیانوس نمی‌رود)',
      () {
        final noLocation = _factory(lat: 0, lon: 0);
        expect(noLocation.hasValidLocation, isFalse);
        expect(factoryLocationUri(noLocation), isNull);
        expect(factoryDirectionsUri(noLocation), isNull);
        expect(factoryNavigationAppUri(noLocation), isNull);
      },
    );
  });

  group('buildFactoryShareText', () {
    // ترجمه‌ی جعلی: کلید → «<کلید>» تا وجود/ترتیب برچسب‌ها بررسی شود
    String fakeTranslate(String key) => '<$key>';

    test('برچسب‌ها ترجمه‌شده‌اند، نه رشته‌ی هاردکد', () {
      final text = buildFactoryShareText(_factory(), translate: fakeTranslate);

      expect(text, contains('زلال موفق'));
      expect(text, contains('<phone>: 0791323424'));
      expect(text, contains('<address>: خیابان اول'));
      expect(text, contains('<working_hours>: 07:00 - 19:00'));
      expect(text, contains('maps/search'));
    });

    test('ردیف‌های خالی حذف می‌شوند', () {
      final text = buildFactoryShareText(
        _factory(
          lat: 0,
          lon: 0,
          category: '',
          phase: '',
          address: '',
          phone: '',
          workStart: '',
          workEnd: '',
          description: '',
        ),
        translate: fakeTranslate,
      );

      // فقط خط سرصفحه می‌ماند: نام اپ — نام شرکت
      expect(text.trim().split('\n').length, 1);
      expect(text, contains('زلال موفق'));
    });

    test('بدون مختصات، لینک نقشه در متن نمی‌آید', () {
      final text = buildFactoryShareText(
        _factory(lat: 0, lon: 0),
        translate: fakeTranslate,
      );

      expect(text, isNot(contains('maps')));
    });
  });
}
