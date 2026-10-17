/// پیکربندی ساخت (build-time configuration).
///
/// مقادیر پیش‌فرض همان پروژه‌ی فعلی هستند تا اجرای معمولی چیزی نیاز نداشته باشد،
/// اما می‌توان با `--dart-define` محیط دلخواه (استیجینگ/پروداکشن) را داد:
///
/// ```bash
/// flutter run \
///   --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=sb_publishable_xxx \
///   --dart-define=APP_VERSION=1.0.0
/// ```
class AppConfig {
  const AppConfig._();

  // ── Supabase ──────────────────────────────────────────────────────────────
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://uphftjsckmyrxjubfsal.supabase.co',
  );

  /// کلید عمومی (anon / publishable). این کلید از سمت کلاینت خوانده می‌شود و
  /// دسترسی نوشتن ندارد؛ دسترسی‌ها با RLS در دیتابیس کنترل می‌شوند.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_sOE66rlBH_WmeulXr8ExcQ_lt99mjOX',
  );

  /// باکت عمومی Supabase Storage که تصاویر شرکت‌ها/فازها در آن نگه‌داری می‌شود.
  static const String storageBucket = 'images';

  /// حداکثر زمان انتظار برای هر درخواست شبکه؛ بعد از آن مسیر «کش محلی» فعال می‌شود.
  static const Duration requestTimeout = Duration(seconds: 10);

  /// داده‌ی محلی تا این مدت «تازه» شمرده می‌شود و بدون رفت‌وبرگشت شبکه نمایش داده می‌شود.
  static const Duration freshCacheAge = Duration(minutes: 10);

  // ── App ───────────────────────────────────────────────────────────────────
  /// نسخه‌ی نمایشی اپ؛ مقدار پیش‌فرض با `version` در pubspec.yaml یکسان است.
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );

  /// آیا بک‌اند از طریق `--dart-define` تنظیم شده است؟
  static const bool hasCustomBackend =
      bool.hasEnvironment('SUPABASE_URL') &&
      bool.hasEnvironment('SUPABASE_ANON_KEY');

  /// آدرس عمومی یک فایل در باکت تصاویر.
  static String publicImageUrl(String fileName) =>
      '$supabaseUrl/storage/v1/object/public/$storageBucket/$fileName';

  // ── مکان شهرک ─────────────────────────────────────────────────────────────
  /// مرکز شهرک صنعتی هرات — پیش‌فرض نقشه و مبنای پیوند «موقعیت شهرک».
  static const double townLatitude = 34.203014;
  static const double townLongitude = 62.214955;

  /// پیوند گوگل‌مپ برای موقعیت شهرک (بدون داده‌ی وارد‌شده، قابل استفاده است).
  static Uri get townLocationUri => Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$townLatitude,$townLongitude',
  );

  // ── تماس با پشتیبانی (فاز ۶) ──────────────────────────────────────────────
  /// هیچ مقدار پیش‌فرضی برای شماره/ایمیل گذاشته نشده: عدد ساختگی بدتر از
  /// نبودنش است. با `--dart-define` تنظیم می‌شوند، مثال:
  /// ```bash
  /// flutter run --dart-define=SUPPORT_PHONE=+93791234567 \
  ///             --dart-define=SUPPORT_EMAIL=info@example.com
  /// ```
  static const String supportPhone = String.fromEnvironment('SUPPORT_PHONE');
  static const String supportEmail = String.fromEnvironment('SUPPORT_EMAIL');
  static const String supportWebsite = String.fromEnvironment(
    'SUPPORT_WEBSITE',
  );

  /// آیا حداقل یک راه تماس با پشتیبانی تنظیم شده است؟
  static const bool hasSupportContact =
      supportPhone != '' || supportEmail != '' || supportWebsite != '';
}
