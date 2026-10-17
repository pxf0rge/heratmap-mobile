class AnnouncementModel {
  final String id;
  final String title;
  final String body;
  final String image;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final bool isActive;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.body,
    required this.image,
    this.publishedAt,
    this.expiresAt,
    this.isActive = true,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> data) {
    return AnnouncementModel(
      id: _asText(data['id']),
      title: _asText(data['title']),
      body: _asText(data['body']),
      image: _asText(data['image']),
      publishedAt: _asDateTime(data['published_at']),
      expiresAt: _asDateTime(data['expires_at']),
      isActive: _asBool(data['is_active']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'image': image,
        'published_at': publishedAt?.toIso8601String(),
        'expires_at': expiresAt?.toIso8601String(),
        'is_active': isActive,
      };

  String get imageUrl => image;

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  static String _asText(Object? value) => value?.toString().trim() ?? '';
  static DateTime? _asDateTime(Object? value) {
    if (value == null || value.toString().isEmpty) return null;
    return DateTime.tryParse(value.toString());
  }
  static bool _asBool(Object? value) => value == true || value == 'true';
}
