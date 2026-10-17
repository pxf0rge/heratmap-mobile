class NewsModel {
  final String id;
  final String title;
  final String summary;
  final String body;
  final String image;
  final String coverImage;
  final DateTime? publishedAt;
  final bool isActive;

  const NewsModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.image,
    required this.coverImage,
    this.publishedAt,
    this.isActive = true,
  });

  factory NewsModel.fromMap(Map<String, dynamic> data) {
    return NewsModel(
      id: _asText(data['id']),
      title: _asText(data['title']),
      summary: _asText(data['summary']),
      body: _asText(data['body']),
      image: _asText(data['image']),
      coverImage: _asText(data['cover_image'] ?? data['cover_image']),
      publishedAt: _asDateTime(data['published_at']),
      isActive: _asBool(data['is_active']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'summary': summary,
        'body': body,
        'image': image,
        'cover_image': coverImage,
        'published_at': publishedAt?.toIso8601String(),
        'is_active': isActive,
      };

  String get imageUrl => image;
  String get coverImageUrl => coverImage;

  static String _asText(Object? value) => value?.toString().trim() ?? '';
  static DateTime? _asDateTime(Object? value) {
    if (value == null || value.toString().isEmpty) return null;
    return DateTime.tryParse(value.toString());
  }
  static bool _asBool(Object? value) => value == true || value == 'true';
}
