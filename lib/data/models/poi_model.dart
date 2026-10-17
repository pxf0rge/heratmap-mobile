class PoiModel {
  final String id;
  final String name;
  final String nameEn;
  final double lat;
  final double lon;
  final String icon;
  final String category;
  final bool isActive;
  final int sortOrder;

  const PoiModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.lat,
    required this.lon,
    required this.icon,
    required this.category,
    required this.isActive,
    required this.sortOrder,
  });

  factory PoiModel.fromMap(Map<String, dynamic> data) {
    return PoiModel(
      id: _asText(data['id']),
      name: _asText(data['name']),
      nameEn: _asText(data['name_en']),
      lat: _asDouble(data['lat']),
      lon: _asDouble(data['lon']),
      icon: _asText(data['icon']),
      category: _asText(data['category']),
      isActive: _asBool(data['is_active']),
      sortOrder: _asInt(data['sort_order']),
    );
  }

  bool get hasValidLocation =>
      lat.isFinite && lon.isFinite && lat != 0.0 && lon != 0.0;

  @override
  String toString() => 'PoiModel($id, $name)';

  static String _asText(Object? value) => value?.toString().trim() ?? '';

  static double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? 0.0;
    return 0.0;
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  static bool _asBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true';
    return true;
  }
}
