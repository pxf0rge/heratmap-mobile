import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:heratmap/data/cache/key_value_store.dart';
import 'package:heratmap/data/cache/search_history.dart';

void main() {
  late InMemoryStore store;
  late SearchHistoryStore history;

  setUp(() {
    store = InMemoryStore();
    history = SearchHistoryStore(store: store, maxEntries: 3);
  });

  test('تاریچه خالی است', () {
    expect(history.read(), isEmpty);
  });

  test('تازه‌ترین جستجو اول می‌آید', () {
    history.add('زلال');
    history.add('برق');
    history.add('فاز 1');

    expect(history.read(), ['فاز 1', 'برق', 'زلال']);
  });

  test('تکرار با نگارش متفاوت ردیف جدید نمی‌سازد', () {
    history.add('فاز 1');
    history.add('زلال');
    // ارقام فارسی باید همان «فاز 1» شمرده شوند
    history.add('فاز \u06F1');

    expect(history.read(), ['فاز \u06F1', 'زلال']);
  });

  test('خط‌مشی نقطه‌گذاری و کوتاه‌سازی عبارت خالی', () {
    history.add('  زلال  ');
    expect(history.read(), ['زلال']);

    history.add('   ');
    expect(history.read(), ['زلال']);
  });

  test('تعداد ردیف‌ها از maxEntries بیشتر نمی‌شود', () {
    for (final value in ['a', 'b', 'c', 'd']) {
      history.add(value);
    }
    expect(history.read(), ['d', 'c', 'b']);
  });

  test('حذف یک ردیف و پاک‌کردن همه', () {
    history.add('زلال');
    history.add('برق');

    expect(history.remove('زلال'), ['برق']);

    expect(history.clear(), isEmpty);
    expect(history.read(), isEmpty);
    expect(store.read(SearchHistoryStore.key), isNull);
  });

  test('داده‌ی خراب در حافظه، تاریخچه را خالی می‌کند (بدون کرش)', () {
    store.write(SearchHistoryStore.key, '{not json');
    expect(history.read(), isEmpty);

    store.write(SearchHistoryStore.key, jsonEncode({'a': 1}));
    expect(history.read(), isEmpty);

    store.write(SearchHistoryStore.key, jsonEncode(['ok', 42, '', '  ']));
    expect(history.read(), ['ok']);
  });
}
