import 'package:flutter_test/flutter_test.dart';
import 'package:heratmap/data/models/factory_model.dart';
import 'package:heratmap/data/repository/factory_repository.dart';

FactoryModel _factory({
  required String id,
  required String name,
  String category = '',
  String address = '',
  String phase = 'فاز 1',
}) => FactoryModel(
  id: id,
  name: name,
  category: category,
  phase: phase,
  lat: 34.2,
  lon: 62.2,
  address: address,
  phone: '0790000000',
  workStart: '07:00',
  workEnd: '19:00',
  lotNumber: '',
  isActive: true,
  description: '',
  image: '',
  websiteUrl: '',
);

void main() {
  group('mergeSearchResults', () {
    test('اجتماع نتیجه‌ی سرور و محلی، بدون تکرار بر اساس شناسه', () {
      final remote = [_factory(id: '1', name: 'زلال'), _factory(id: '2', name: 'زلال ۲')];
      final local = [_factory(id: '2', name: 'زلال ۲'), _factory(id: '3', name: 'زلال ۳')];

      final merged = FactoryRepository.mergeSearchResults(
        remote: remote,
        local: local,
      );

      expect(merged.map((f) => f.id), ['1', '2', '3']);
    });

    test('ردیف بدون شناسه حذف نمی‌شود', () {
      final merged = FactoryRepository.mergeSearchResults(
        remote: [_factory(id: '', name: 'بی‌شناسه')],
        local: [_factory(id: '', name: 'بی‌شناسه‌ی دیگر')],
      );
      expect(merged.length, 2);
    });
  });

  group('rankByRelevance', () {
    test('نامِ شروع‌شونده با عبارت، اول می‌آید', () {
      final items = [
        _factory(id: '3', name: 'شرکت برق هرات', category: 'زلال'),
        _factory(id: '2', name: 'صنایع زلال', address: 'خیابان زلال'),
        _factory(id: '1', name: 'زلال موفق'),
      ];

      final ranked = FactoryRepository.rankByRelevance(items, 'زلال');

      expect(ranked.map((f) => f.id), ['1', '2', '3']);
    });

    test('نگارش‌های فارسی/عربی و ارقام نادیده گرفته می‌شوند', () {
      final items = [
        _factory(id: '1', name: 'شرکت الف'),
        _factory(id: '2', name: 'فاز \u06F1 تولیدی'),
      ];

      // مدل فاز با ارقام لاتین ذخیره شده؛ کاربر با ارقام فارسی جستجو می‌کند
      final ranked = FactoryRepository.rankByRelevance(items, 'فاز 1');

      expect(ranked.first.id, '2');
    });

    test('ترتیب ورودی با عبارت خالی دست‌نخورده می‌ماند', () {
      final items = [
        _factory(id: '2', name: 'ب'),
        _factory(id: '1', name: 'الف'),
      ];
      expect(FactoryRepository.rankByRelevance(items, '').map((f) => f.id), [
        '2',
        '1',
      ]);
    });
  });
}
