import 'package:get_storage/get_storage.dart';

/// انتزاع سبک روی ذخیره‌سازی کلید/مقدار؛ لایه‌ی کش به GetStorage وابسته نمی‌شود
/// و در تست‌ها می‌توان پیاده‌سازی درون‌حافظه‌ای تزریق کرد.
abstract class KeyValueStore {
  Object? read(String key);
  void write(String key, Object? value);
  void remove(String key);
  bool has(String key);
  List<String> keys();
}

/// پیاده‌سازی روی GetStorage (ذخیره‌سازی روی دستگاه).
class GetStorageStore implements KeyValueStore {
  GetStorageStore([GetStorage? box]) : _box = box ?? GetStorage();

  final GetStorage _box;

  @override
  Object? read(String key) => _box.read(key);

  @override
  void write(String key, Object? value) => _box.write(key, value);

  @override
  void remove(String key) => _box.remove(key);

  @override
  bool has(String key) => _box.hasData(key);

  @override
  List<String> keys() => _box.getKeys()?.toList() ?? const <String>[];
}

/// پیاده‌سازی درون‌حافظه‌ای برای تست‌ها.
class InMemoryStore implements KeyValueStore {
  InMemoryStore([Map<String, Object?>? seed]) : _values = {...?seed};

  final Map<String, Object?> _values;

  @override
  Object? read(String key) => _values[key];

  @override
  void write(String key, Object? value) => _values[key] = value;

  @override
  void remove(String key) => _values.remove(key);

  @override
  bool has(String key) => _values.containsKey(key);

  @override
  List<String> keys() => _values.keys.toList();
}
