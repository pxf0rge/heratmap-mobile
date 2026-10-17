import 'package:flutter_test/flutter_test.dart';
import 'package:heratmap/data/models/factory_model.dart';
import 'package:heratmap/data/models/phase_model.dart';

void main() {
  group('FactoryModel.fromMap', () {
    test('ردیف کامل را درست نگاشت می‌کند', () {
      final factory = FactoryModel.fromMap({
        'id': 1,
        'name': ' زلال موفق ',
        'category': 'برق و قدرت',
        'phase': 'فاز 1',
        'lat': 34.217654,
        'lon': 62.207864,
        'address': 'خیابان اول',
        'phone': '0791323424',
        'work_start': '07:00',
        'work_end': '19:00',
        'lot_number': '۱۲',
        'is_active': true,
        'description': 'شرکت تولید کننده نوشیدنی',
        'image': 'https://example.com/a.jpg',
        'website_url': 'https://example.com',
      });

      expect(factory.id, '1');
      expect(factory.name, 'زلال موفق'); // فاصله‌ی اضافی حذف می‌شود
      expect(factory.lat, closeTo(34.217654, 0.000001));
      expect(factory.workStart, '07:00');
      expect(factory.workEnd, '19:00');
      expect(factory.lotNumber, '۱۲');
      expect(factory.isActive, isTrue);
      expect(factory.websiteUrl, 'https://example.com');
      expect(factory.hasValidLocation, isTrue);
    });

    test('ردیف ناقص یا با نوع اشتباه، کرش نمی‌کند', () {
      final factory = FactoryModel.fromMap({
        'id': 7,
        'name': null,
        'lat': '34.5', // رشته به‌جای عدد
        'lon': 'not-a-number',
      });

      expect(factory.id, '7');
      expect(factory.name, '');
      expect(factory.category, '');
      expect(factory.lat, 34.5);
      expect(factory.lon, 0.0);
      expect(factory.hasValidLocation, isFalse);
    });

    test('ردیف کاملاً خالی', () {
      final factory = FactoryModel.fromMap(const {});

      expect(factory.id, '');
      expect(factory.name, '');
      expect(factory.imageUrls, isEmpty);
      expect(factory.imageUrl, '');
      expect(factory.hasValidLocation, isFalse);
    });

    test('مختصات صفر یا NaN نامعتبر است', () {
      expect(
        FactoryModel.fromMap({'lat': 0, 'lon': 0}).hasValidLocation,
        isFalse,
      );
      expect(
        FactoryModel.fromMap({'lat': double.nan, 'lon': 62.2}).hasValidLocation,
        isFalse,
      );
    });
  });

  group('FactoryModel.imageUrls', () {
    test('چند آدرس جداشده با | را جدا می‌کند', () {
      final factory = FactoryModel.fromMap({
        'image': 'https://a.jpg|https://b.jpg|https://c.jpg',
      });
      expect(factory.imageUrls, [
        'https://a.jpg',
        'https://b.jpg',
        'https://c.jpg',
      ]);
      expect(factory.imageUrl, 'https://a.jpg');
    });

    test('آدرس تکراری را یک‌بار برمی‌گرداند', () {
      final factory = FactoryModel.fromMap({
        'image': 'https://a.jpg|https://a.jpg',
      });
      expect(factory.imageUrls, ['https://a.jpg']);
    });

    test('مقدارهای خالی و | اضافی را نادیده می‌گیرد', () {
      final factory = FactoryModel.fromMap({
        'image': ' https://a.jpg || |https://b.jpg| ',
      });
      expect(factory.imageUrls, ['https://a.jpg', 'https://b.jpg']);
    });
  });

  group('FactoryModel.toMap', () {
    test('رفت‌وبرگشت نگاشت، داده را حفظ می‌کند', () {
      const original = FactoryModel(
        id: '3',
        name: 'شرکت نمونه',
        category: 'فلزات',
        phase: 'فاز 2',
        lat: 34.2,
        lon: 62.2,
        address: 'خیابان دوم',
        phone: '0700000000',
        workStart: '08:00',
        workEnd: '16:00',
        lotNumber: '',
        isActive: true,
        description: 'توضیح',
        image: 'https://a.jpg|https://b.jpg',
        websiteUrl: 'https://example.com',
      );

      final restored = FactoryModel.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.phase, original.phase);
      expect(restored.lat, original.lat);
      expect(restored.lon, original.lon);
      expect(restored.workStart, original.workStart);
      expect(restored.workEnd, original.workEnd);
      expect(restored.lotNumber, original.lotNumber);
      expect(restored.isActive, original.isActive);
      expect(restored.imageUrls, original.imageUrls);
      expect(restored.websiteUrl, original.websiteUrl);
    });
  });

  group('PhaseModel.fromMap', () {
    test('ردیف کامل را نگاشت می‌کند', () {
      final phase = PhaseModel.fromMap({
        'id': 2,
        'name': ' فاز 2 ',
        'number': 2,
        'image': 'https://example.com/phase2.jpg',
        'description': 'توضیحات فاز دوم',
        'area': '۱۵ هکتار',
        'is_active': true,
        'boundary': [[34.21, 62.20], [34.22, 62.21], [34.23, 62.20]],
      });

      expect(phase.id, '2');
      expect(phase.name, 'فاز 2');
      expect(phase.number, 2);
      expect(phase.hasImage, isTrue);
      expect(phase.imageUrl, 'https://example.com/phase2.jpg');
      expect(phase.description, 'توضیحات فاز دوم');
      expect(phase.area, '۱۵ هکتار');
      expect(phase.isActive, isTrue);
      expect(phase.hasBoundary, isTrue);
      expect(phase.boundary.length, 3);
    });

    test('image تهی و number رشته‌ای را تحمل می‌کند', () {
      final phase = PhaseModel.fromMap({'id': 1, 'name': 'فاز 1', 'number': '1'});

      expect(phase.number, 1);
      expect(phase.hasImage, isFalse);
      expect(phase.imageUrl, '');
      expect(phase.description, '');
      expect(phase.area, '');
      expect(phase.isActive, isTrue);
      expect(phase.hasBoundary, isFalse);
      expect(phase.boundary, isEmpty);
    });

    test('number نامعتبر صفر می‌شود', () {
      expect(PhaseModel.fromMap({'number': 'x'}).number, 0);
      expect(PhaseModel.fromMap(const {}).number, 0);
    });

    test('boundary خراب کرش نمی‌کند', () {
      final phase = PhaseModel.fromMap({'boundary': 'not-a-list'});
      expect(phase.boundary, isEmpty);
      expect(phase.hasBoundary, isFalse);
    });

    test('toMap رفت‌وبرگشت درست دارد', () {
      const phase = PhaseModel(id: '5', name: 'فاز 5', number: 5, image: '', description: 'توضیح', area: '۱۰ هکتار', isActive: true, boundary: [[34.21, 62.20], [34.22, 62.21], [34.23, 62.20]]);
      final restored = PhaseModel.fromMap(phase.toMap());
      expect(restored.id, '5');
      expect(restored.name, 'فاز 5');
      expect(restored.number, 5);
      expect(restored.description, 'توضیح');
      expect(restored.area, '۱۰ هکتار');
      expect(restored.isActive, isTrue);
      expect(restored.boundary.length, 3);
      expect(restored.boundary[0][0], closeTo(34.21, 0.001));
      expect(restored.boundary[0][1], closeTo(62.20, 0.001));
      expect(restored.boundary[1][0], closeTo(34.22, 0.001));
      expect(restored.boundary[1][1], closeTo(62.21, 0.001));
      expect(restored.boundary[2][0], closeTo(34.23, 0.001));
      expect(restored.boundary[2][1], closeTo(62.20, 0.001));
      expect(restored.hasBoundary, isTrue);
    });
  });
}
