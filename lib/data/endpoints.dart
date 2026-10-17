/// Supabase table names.
class Endpoints {
  // ── Tables ────────────────────────────────────────────────────────────────

  /// Factories / companies.
  /// Columns: id (bigint), name, category, lat, lon, address,
  ///          phone, working_hours, description, image (url), phase (text)
  static const String factories = 'factories';

  /// Phases of the industrial town.
  /// Columns: id (bigint), name, number (int), image (url)
  static const String phases = 'phases';

  /// News articles.
  /// Columns: id (bigint), title, summary, body, image, cover_image,
  ///          published_at, created_at, is_active (bool)
  static const String news = 'news';

  /// Announcements / notices.
  /// Columns: id (bigint), title, body, image, published_at, expires_at,
  ///          created_at, is_active (bool)
  static const String announcements = 'announcements';

  /// Emergency contact numbers.
  /// Columns: id (bigint), name, phone, icon, sort_order, created_at, is_active (bool)
  static const String emergencyContacts = 'emergency_contacts';
}
