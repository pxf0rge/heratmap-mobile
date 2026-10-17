import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:heratmap/data/cache/key_value_store.dart';

/// شرکت‌های نشان‌شده (Favorites) روی دستگاه.
///
/// از [GetxController] ارث می‌برد چون این «وضعیت مشترک اپ» است: صفحه‌ی جزئیات
/// و تب جستجو باید هم‌زمان با یک لمس به‌روز شوند. ذخیره‌سازی از [KeyValueStore]
/// می‌آید تا در تست‌ها با حافظه‌ی درون‌برنامه‌ای جایگزین شود.
class FavoritesStore extends GetxController {
  FavoritesStore({KeyValueStore? store}) : _store = store ?? GetStorageStore() {
    // در سازنده خوانده می‌شود، نه در `onInit`: این داده باید حتی وقتی خارج از
    // چرخه‌ی GetX ساخته می‌شود (تست/بازیابی) هم درست بارگذاری شود.
    ids.value = _read();
  }

  /// کلید ذخیره‌سازی — داده‌ی کاربر است، پس پیشوند کش را ندارد.
  static const String key = 'favorite_factory_ids';

  final KeyValueStore _store;

  /// شناسه‌های نشان‌شده (ترتیب = ترتیب نشان‌کردن).
  final ids = <String>[].obs;

  bool contains(String id) => id.isNotEmpty && ids.contains(id);

  int get count => ids.length;

  bool get isEmpty => ids.isEmpty;

  /// نشان‌کردن/برداشتن نشان و برگرداندن وضعیت جدید.
  ///
  /// [id] خالی (ردیف بدون شناسه) نشان نمی‌شود، چون کلید ذخیره‌سازی ناپایدار است.
  bool toggle(String id) {
    if (id.isEmpty) return false;

    final updated = [...ids];
    final index = updated.indexOf(id);
    final nowFavorite = index < 0;
    if (nowFavorite) {
      updated.add(id);
    } else {
      updated.removeAt(index);
    }

    ids.value = updated;
    _write(updated);
    return nowFavorite;
  }

  void clear() {
    ids.value = [];
    _store.remove(key);
  }

  List<String> _read() {
    final raw = _store.read(key);
    if (raw is! String || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return [
        for (final item in decoded)
          if (item is String && item.isNotEmpty) item,
      ];
    } catch (error) {
      debugPrint('FavoritesStore: read failed → $error');
      return const [];
    }
  }

  void _write(List<String> value) {
    _store.write(key, jsonEncode(value));
  }
}
