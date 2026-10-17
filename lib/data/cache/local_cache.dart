import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:heratmap/data/cache/key_value_store.dart';

/// یک مقدار کش‌شده همراه با زمان ذخیره و نسخه‌ی اسکیما.
class CacheEntry<T> {
  final T value;
  final DateTime storedAt;
  final int schemaVersion;

  const CacheEntry(
    this.value, {
    required this.storedAt,
    required this.schemaVersion,
  });

  Duration age({DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(storedAt);
    return diff.isNegative ? Duration.zero : diff;
  }

  bool isOlderThan(Duration maxAge, {DateTime? now}) => age(now: now) > maxAge;
}

/// کش محلی نسخه‌دار.
///
/// همه‌ی کلیدها با پیشوند [keyPrefix] ذخیره می‌شوند تا با سایر داده‌های اپ
/// (مثل زبان انتخاب‌شده) قاطی نشوند.
///
/// قالب ذخیره: `{"v": <schemaVersion>, "at": "<ISO8601>", "d": <payload>}`
/// - اگر `v` با نسخه‌ی فعلی نخواند، مقدار باطل و حذف می‌شود (تغییر مدل‌ها = بی‌اعتبار شدن کش).
/// - ردیف‌های خراب در `readList` دور ریخته می‌شوند و باعث کرش نمی‌شوند.
class LocalCache {
  LocalCache({KeyValueStore? store}) : _store = store ?? GetStorageStore();

  static const int schemaVersion = 1;
  static const String keyPrefix = 'hm_cache_';

  static const String _versionField = 'v';
  static const String _storedAtField = 'at';
  static const String _dataField = 'd';

  final KeyValueStore _store;

  String key(String name) => '$keyPrefix$name';

  /// خواندن یک لیست از کش. در صورت نبود/خرابی/نسخه‌ی ناهمخوان، null برمی‌گردد.
  CacheEntry<List<T>>? readList<T>(
    String name,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    final envelope = _readEnvelope(name);
    if (envelope == null) return null;

    final raw = envelope.data[_dataField];
    if (raw is! List) return null;

    final items = <T>[];
    for (final element in raw) {
      try {
        if (element is Map) {
          items.add(fromMap(Map<String, dynamic>.from(element)));
        }
      } catch (error) {
        debugPrint('LocalCache: dropped corrupt row in "$name" → $error');
      }
    }

    // اگر همه‌ی ردیف‌ها خراب بودند، کش را معتبر ندان (خطای شبکه را پنهان نکن)
    if (raw.isNotEmpty && items.isEmpty) return null;

    return CacheEntry(
      items,
      storedAt: envelope.storedAt,
      schemaVersion: schemaVersion,
    );
  }

  void writeList<T>(
    String name,
    List<T> items,
    Map<String, dynamic> Function(T) toMap,
  ) {
    final payload = items.map(toMap).toList();
    _writeEnvelope(name, payload);
  }

  /// خواندن یک شیء ساده (مثلاً نقشه‌ی شمارش شرکت‌ها در هر فاز).
  CacheEntry<Map<String, dynamic>>? readMap(String name) {
    final envelope = _readEnvelope(name);
    if (envelope == null) return null;

    final raw = envelope.data[_dataField];
    if (raw is! Map) return null;

    return CacheEntry(
      Map<String, dynamic>.from(raw),
      storedAt: envelope.storedAt,
      schemaVersion: schemaVersion,
    );
  }

  void writeMap(String name, Map<String, dynamic> value) {
    _writeEnvelope(name, value);
  }

  /// زمان آخرین ذخیره‌ی یک کلید (بدون توجه به نسخه‌ی payload).
  DateTime? storedAt(String name) {
    final raw = _store.read(key(name));
    if (raw is! String) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return DateTime.tryParse(decoded[_storedAtField]?.toString() ?? '');
    } catch (_) {
      return null;
    }
  }

  void remove(String name) => _store.remove(key(name));

  /// باطل‌کردن کل کش اپ (فقط کلیدهای همین لایه).
  void invalidateAll() {
    for (final existing in _store.keys()) {
      if (existing.startsWith(keyPrefix)) _store.remove(existing);
    }
  }

  /// نام کلیدهای کش‌شده (بدون پیشوند).
  List<String> cachedKeys() => _store
      .keys()
      .where((k) => k.startsWith(keyPrefix))
      .map((k) => k.substring(keyPrefix.length))
      .toList();

  // ── داخلی ─────────────────────────────────────────────────────────────────

  void _writeEnvelope(String name, Object? payload) {
    try {
      _store.write(
        key(name),
        jsonEncode({
          _versionField: schemaVersion,
          _storedAtField: DateTime.now().toIso8601String(),
          _dataField: payload,
        }),
      );
    } catch (error) {
      debugPrint('LocalCache: write "$name" failed → $error');
    }
  }

  ({Map<String, dynamic> data, DateTime storedAt})? _readEnvelope(String name) {
    final raw = _store.read(key(name));
    if (raw is! String || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      final version = decoded[_versionField];
      if (version != schemaVersion) {
        // نسخه‌ی قدیمی → بی‌اعتبار
        remove(name);
        return null;
      }

      final storedAt = DateTime.tryParse(
        decoded[_storedAtField]?.toString() ?? '',
      );
      if (storedAt == null) return null;

      return (data: Map<String, dynamic>.from(decoded), storedAt: storedAt);
    } catch (error) {
      debugPrint('LocalCache: read "${key(name)}" failed → $error');
      return null;
    }
  }
}
