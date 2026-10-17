class FactoryModel {
  final String id;
  final String name;
  final String category;
  final String phase;
  final double lat;
  final double lon;
  final String address;
  final String phone;
  final String workStart;
  final String workEnd;
  final String lotNumber;
  final bool isActive;
  final String description;
  final String websiteUrl;

  /// چند آدرس تصویر که با `|` جدا شده‌اند، مثال: `"url1|url2|url3"`
  final String image;

  const FactoryModel({
    required this.id,
    required this.name,
    required this.category,
    required this.phase,
    required this.lat,
    required this.lon,
    required this.address,
    required this.phone,
    required this.workStart,
    required this.workEnd,
    required this.lotNumber,
    required this.isActive,
    required this.description,
    required this.image,
    required this.websiteUrl,
  });

  /// نگاشت از ردیف خام Supabase/JSON.
  ///
  /// این تابع هرگز خطا پرتاب نمی‌کند: مقادیر ناقص، از نوع اشتباه یا با فاصله‌ی
  /// اضافی به مقدار امن تبدیل می‌شوند تا داده‌ی خراب کش باعث کرش نشود.
  factory FactoryModel.fromMap(Map<String, dynamic> data) {
    return FactoryModel(
      id: _asText(data['id']),
      name: _asText(data['name']),
      category: _asText(data['category']),
      phase: _asText(data['phase']),
      lat: _asDouble(data['lat']),
      lon: _asDouble(data['lon']),
      address: _asText(data['address']),
      phone: _asText(data['phone']),
      workStart: _asText(data['work_start']),
      workEnd: _asText(data['work_end']),
      lotNumber: _asText(data['lot_number']),
      isActive: _asBool(data['is_active']),
      description: _asText(data['description']),
      image: _asText(data['image']),
      websiteUrl: _asText(data['website_url']),
    );
  }

  /// نگاشت به JSON برای ذخیره در کش محلی.
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'phase': phase,
    'lat': lat,
    'lon': lon,
    'address': address,
    'phone': phone,
    'work_start': workStart,
    'work_end': workEnd,
    'lot_number': lotNumber,
    'is_active': isActive,
    'description': description,
    'image': image,
    'website_url': websiteUrl,
  };

  /// همه‌ی آدرس‌های تصویر — بدون تکرار، بدون مقدار خالی.
  List<String> get imageUrls {
    if (image.isEmpty) return const [];
    final seen = <String>{};
    final urls = <String>[];
    for (final part in image.split('|')) {
      final url = part.trim();
      if (url.isEmpty) continue;
      if (seen.add(url)) urls.add(url);
    }
    return urls;
  }

  /// اولین تصویر (برای کارت‌ها و مارکرها).
  String get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  /// مختصات معتبر (صفر یا NaN یعنی نامعلوم).
  bool get hasValidLocation =>
      lat.isFinite && lon.isFinite && lat != 0.0 && lon != 0.0;

  @override
  String toString() => 'FactoryModel($id, $name, $phase)';

  // ── تبدیل‌های امن ─────────────────────────────────────────────────────────

  static String _asText(Object? value) => value?.toString().trim() ?? '';

  static double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? 0.0;
    return 0.0;
  }

  static bool _asBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true';
    return true;
  }
}
