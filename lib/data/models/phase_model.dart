class PhaseModel {
  final String id;
  final String name;
  final int number;
  final String description;
  final String area;
  final bool isActive;

  /// آدرس کامل تصویر در Supabase Storage (یا رشته‌ی خالی).
  final String image;

  /// نقاط مرز فاز روی نقشه — لیستی از [lat, lon].
  final List<List<double>> boundary;

  const PhaseModel({
    required this.id,
    required this.name,
    required this.number,
    required this.image,
    required this.description,
    required this.area,
    required this.isActive,
    required this.boundary,
  });

  /// نگاشت از ردیف خام Supabase/JSON — هیچ‌گاه خطا پرتاب نمی‌کند.
  factory PhaseModel.fromMap(Map<String, dynamic> data) {
    return PhaseModel(
      id: _asText(data['id']),
      name: _asText(data['name']),
      number: _asInt(data['number']),
      image: _asText(data['image']),
      description: _asText(data['description']),
      area: _asText(data['area']),
      isActive: _asBool(data['is_active']),
      boundary: _asBoundary(data['boundary']),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'number': number,
    'image': image,
    'description': description,
    'area': area,
    'is_active': isActive,
    'boundary': boundary,
  };

  String get imageUrl => image;

  bool get hasImage => image.isNotEmpty;

  bool get hasBoundary => boundary.length >= 3;

  @override
  String toString() => 'PhaseModel($id, $name, #$number)';

  static String _asText(Object? value) => value?.toString().trim() ?? '';

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

  static List<List<double>> _asBoundary(Object? value) {
    if (value is! List) return const [];
    final result = <List<double>>[];
    for (final item in value) {
      if (item is List && item.length >= 2) {
        final lat = (item[0] is num) ? (item[0] as num).toDouble() : double.tryParse(item[0].toString());
        final lon = (item[1] is num) ? (item[1] as num).toDouble() : double.tryParse(item[1].toString());
        if (lat != null && lon != null && lat.isFinite && lon.isFinite) {
          result.add([lat, lon]);
        }
      }
    }
    return result;
  }
}
