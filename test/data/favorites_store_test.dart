import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:heratmap/data/cache/favorites_store.dart';
import 'package:heratmap/data/cache/key_value_store.dart';

void main() {
  late InMemoryStore store;
  late FavoritesStore favorites;

  setUp(() {
    store = InMemoryStore();
    favorites = FavoritesStore(store: store);
  });

  test('در ابتدا خالی است', () {
    expect(favorites.ids, isEmpty);
    expect(favorites.count, 0);
    expect(favorites.contains('1'), isFalse);
  });

  test('toggle نشان می‌کند و دوباره برمی‌دارد', () {
    expect(favorites.toggle('1'), isTrue);
    expect(favorites.contains('1'), isTrue);
    expect(favorites.count, 1);

    expect(favorites.toggle('1'), isFalse);
    expect(favorites.contains('1'), isFalse);
    expect(favorites.count, 0);
  });

  test('ترتیب نشان‌کردن حفظ می‌شود', () {
    favorites.toggle('3');
    favorites.toggle('1');
    favorites.toggle('2');

    expect(favorites.ids, ['3', '1', '2']);
  });

  test('روی دستگاه ذخیره می‌شود و در نمونه‌ی بعدی خوانده می‌شود', () {
    favorites.toggle('7');

    final restored = FavoritesStore(store: store);
    expect(restored.ids, ['7']);
    expect(restored.contains('7'), isTrue);
  });

  test('شناسه‌ی خالی نشان نمی‌شود', () {
    expect(favorites.toggle(''), isFalse);
    expect(favorites.ids, isEmpty);
  });

  test('clear همه را پاک می‌کند و کلید را از حافظه برمی‌دارد', () {
    favorites.toggle('1');
    favorites.toggle('2');

    favorites.clear();

    expect(favorites.ids, isEmpty);
    expect(store.read(FavoritesStore.key), isNull);
  });

  test('داده‌ی خراب در حافظه کرش نمی‌کند', () {
    store.write(FavoritesStore.key, '{not json');
    expect(FavoritesStore(store: store).ids, isEmpty);

    store.write(FavoritesStore.key, jsonEncode({'a': 1}));
    expect(FavoritesStore(store: store).ids, isEmpty);

    store.write(FavoritesStore.key, jsonEncode(['1', 42, '']));
    expect(FavoritesStore(store: store).ids, ['1']);
  });
}
