import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:heratmap/core/text_utils.dart';
import 'package:heratmap/data/cache/key_value_store.dart';

/// تاریخچه‌ی جستجوهای اخیر کاربر.
///
/// روی دستگاه (GetStorage) نگه‌داری می‌شود و از [KeyValueStore] استفاده
/// می‌کند تا در تست‌ها با حافظه‌ی درون‌برنامه‌ای جایگزین شود.
/// تکرار بر اساس نگارش نرمال‌شده حذف می‌شود، بنابراین «فاز ۱» و «فاز 1»
/// در تاریخچه دو ردیف جدا نمی‌سازند.
class SearchHistoryStore {
  SearchHistoryStore({KeyValueStore? store, this.maxEntries = 8})
    : _store = store ?? GetStorageStore();

  /// کلید ذخیره‌سازی. بدون پیشوند لایه‌ی کش است چون داده‌ی کاربر است، نه کش.
  static const String key = 'search_history';

  final KeyValueStore _store;
  final int maxEntries;

  /// عبارت‌های ذخیره‌شده، تازه‌ترین اول.
  List<String> read() {
    final raw = _store.read(key);
    if (raw is! String || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return [
        for (final item in decoded)
          if (item is String && item.trim().isNotEmpty) item,
      ];
    } catch (error) {
      debugPrint('SearchHistoryStore: read failed → $error');
      return const [];
    }
  }

  /// افزودن یک جستجو به بالای تاریخچه و برگرداندن فهرست جدید.
  List<String> add(String query) {
    final value = query.trim();
    if (value.isEmpty) return read();

    final normalized = normalizeSearchText(value);
    final updated = <String>[
      value,
      for (final item in read())
        if (normalizeSearchText(item) != normalized) item,
    ];

    if (updated.length > maxEntries) {
      updated.removeRange(maxEntries, updated.length);
    }
    _write(updated);
    return updated;
  }

  /// حذف یک عبارت (با مقایسه‌ی نرمال‌شده).
  List<String> remove(String query) {
    final normalized = normalizeSearchText(query);
    final updated = [
      for (final item in read())
        if (normalizeSearchText(item) != normalized) item,
    ];
    _write(updated);
    return updated;
  }

  /// پاک‌کردن کل تاریخچه.
  List<String> clear() {
    _store.remove(key);
    return const [];
  }

  void _write(List<String> items) {
    _store.write(key, jsonEncode(items));
  }
}
