import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:heratmap/data/cache/key_value_store.dart';
import 'package:heratmap/data/cache/local_cache.dart';
import 'package:heratmap/data/models/factory_model.dart';

FactoryModel _factory({String id = '1', String name = 'زلال موفق'}) =>
    FactoryModel(
      id: id,
      name: name,
      category: 'برق و قدرت',
      phase: 'فاز 1',
      lat: 34.217654,
      lon: 62.207864,
      address: 'خیابان اول',
      phone: '0791323424',
      workStart: '07:00',
  workEnd: '19:00',
  lotNumber: '',
  isActive: true,
      description: 'شرکت تولید کننده نوشیدنی',
      image: 'https://example.com/a.jpg',
      websiteUrl: '',
    );

void main() {
  late InMemoryStore store;
  late LocalCache cache;

  setUp(() {
    store = InMemoryStore();
    cache = LocalCache(store: store);
  });

  test('نوشتن و خواندن لیست، زمان ذخیره را نگه می‌دارد', () {
    final before = DateTime.now().subtract(const Duration(seconds: 1));
    cache.writeList('factories_all', [_factory()], (f) => f.toMap());

    final entry = cache.readList('factories_all', FactoryModel.fromMap);
    expect(entry, isNotNull);
    expect(entry!.value.single.name, 'زلال موفق');
    expect(entry.value.single.lat, closeTo(34.217654, 0.000001));
    expect(entry.storedAt.isAfter(before), isTrue);
    expect(entry.schemaVersion, LocalCache.schemaVersion);
  });

  test('نسخه‌ی ناهمخوان، کش را باطل و حذف می‌کند', () {
    store.write(
      '${LocalCache.keyPrefix}factories_all',
      jsonEncode({
        'v': LocalCache.schemaVersion + 99,
        'at': DateTime.now().toIso8601String(),
        'd': [_factory().toMap()],
      }),
    );

    expect(cache.readList('factories_all', FactoryModel.fromMap), isNull);
    expect(store.has('${LocalCache.keyPrefix}factories_all'), isFalse);
  });

  test('payload خراب کرش نمی‌کند', () {
    store.write('${LocalCache.keyPrefix}broken', '{not json');
    expect(cache.readList('broken', FactoryModel.fromMap), isNull);

    store.write(
      '${LocalCache.keyPrefix}wrong_shape',
      jsonEncode({'v': LocalCache.schemaVersion, 'at': 'x', 'd': 42}),
    );
    expect(cache.readList('wrong_shape', FactoryModel.fromMap), isNull);

    store.write('${LocalCache.keyPrefix}no_at', jsonEncode({'v': 1, 'd': []}));
    expect(cache.readList('no_at', FactoryModel.fromMap), isNull);
  });

  test('ردیف‌های خراب دور ریخته می‌شوند و بقیه می‌مانند', () {
    store.write(
      '${LocalCache.keyPrefix}factories_all',
      jsonEncode({
        'v': LocalCache.schemaVersion,
        'at': DateTime.now().toIso8601String(),
        'd': [
          _factory().toMap(),
          'این ردیف اصلاً نقشه نیست',
          42,
          {'id': 2, 'name': 'ثانی', 'lat': '35.1', 'lon': '62.3'},
        ],
      }),
    );

    final entry = cache.readList('factories_all', FactoryModel.fromMap);
    expect(entry!.value.length, 2);
    // مقدار عددی رشته‌ای هم به double تبدیل می‌شود
    expect(entry.value.last.lat, 35.1);
  });

  test('اگر همه‌ی ردیف‌ها خراب باشند، کش معتبر دانسته نمی‌شود', () {
    store.write(
      '${LocalCache.keyPrefix}factories_all',
      jsonEncode({
        'v': LocalCache.schemaVersion,
        'at': DateTime.now().toIso8601String(),
        'd': ['x', 'y'],
      }),
    );
    // ردیف‌های غیرنقشه نادیده گرفته می‌شوند → لیست خالی ولی ورودی غیرخالی
    // → باید null برگردد تا خطای شبکه پنهان نشود
    expect(cache.readList('factories_all', FactoryModel.fromMap), isNull);
  });

  test('نقشه (map) ذخیره و خوانده می‌شود', () {
    cache.writeMap('factory_counts_by_phase', {'فاز 1': 3, 'فاز 2': 5});
    final entry = cache.readMap('factory_counts_by_phase');
    expect(entry!.value['فاز 1'], 3);
    expect(entry.value['فاز 2'], 5);
  });

  test('invalidateAll فقط کلیدهای همین لایه را پاک می‌کند', () {
    store.write('selected_language', 'fa');
    cache.writeList('factories_all', [_factory()], (f) => f.toMap());
    cache.writeMap('factory_counts_by_phase', {'فاز 1': 1});

    cache.invalidateAll();

    expect(store.read('selected_language'), 'fa');
    expect(cache.cachedKeys(), isEmpty);
    expect(cache.readList('factories_all', FactoryModel.fromMap), isNull);
  });

  test('age و isOlderThan بر اساس زمان ذخیره کار می‌کنند', () {
    cache.writeList('factories_all', [_factory()], (f) => f.toMap());
    final entry = cache.readList('factories_all', FactoryModel.fromMap)!;

    expect(entry.isOlderThan(const Duration(minutes: 10)), isFalse);
    expect(
      entry.isOlderThan(
        const Duration(minutes: 10),
        now: DateTime.now().add(const Duration(hours: 2)),
      ),
      isTrue,
    );
  });

  test('storedAt برای کلید ناموجود null می‌دهد', () {
    expect(cache.storedAt('nope'), isNull);
  });
}
