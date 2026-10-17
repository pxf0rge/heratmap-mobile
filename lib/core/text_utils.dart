/// ابزارهای نرمال‌سازی متن فارسی/پشتو.
///
/// هدف: کاربر «فاز ۱» یا «فاز 1» یا «زلال» را تایپ کند و در هر حالت درست پیدا شود.
/// همچنین کلید مقایسه‌ی نام فازها (که در دیتابیس با ارقام لاتین ذخیره شده‌اند) همین است.
library;

/// نگاشت نویسه‌های عربی/انواع مختلف به شکل استاندارد فارسی.
const Map<int, String> _charMap = {
  0x064A: 'ی', // ي عربی
  0x0649: 'ی', // ى
  0x06CC: 'ی', // ی
  0x0643: 'ک', // ك عربی
  0x06A9: 'ک', // ک
  0x0622: 'ا', // آ
  0x0623: 'ا', // أ
  0x0625: 'ا', // إ
  0x0627: 'ا', // ا
  0x0671: 'ا', // ٱ
  0x0624: 'و', // ؤ
  0x0626: 'ی', // ئ
  0x0629: 'ه', // ة
  0x06C0: 'ه', // ۀ
  0x0640: '', // کشیدگی (tatweel)
  0x200B: '', // فاصله‌ی صفرعرض
  0x200C: '', // نیم‌فاصله
  0x200D: '', // ZWJ
  0x200E: '', // LRM
  0x200F: '', // RLM
  0xFEFF: '', // BOM
};

/// نرمال‌سازی برای جستجو و مقایسه:
/// - تبدیل انواع ی/ک/ا به شکل استاندارد
/// - حذف نیم‌فاصله، کشیدگی و نویسه‌های جهت
/// - تبدیل ارقام فارسی/عربی به لاتین (فاز ۱ ≡ فاز 1)
/// - یکسان‌سازی فاصله‌ها و حروف بزرگ/کوچک
String normalizeSearchText(String input) {
  final buffer = StringBuffer();

  for (final rune in input.runes) {
    // ارقام عربی ٠..٩
    if (rune >= 0x0660 && rune <= 0x0669) {
      buffer.write(rune - 0x0660);
      continue;
    }
    // ارقام فارسی ۰..۹
    if (rune >= 0x06F0 && rune <= 0x06F9) {
      buffer.write(rune - 0x06F0);
      continue;
    }
    // حرکات (فتحه، کسره، ...) و الف مقصوره‌ی کوچک
    if ((rune >= 0x064B && rune <= 0x0652) || rune == 0x0670) continue;

    final mapped = _charMap[rune];
    if (mapped != null) {
      buffer.write(mapped);
      continue;
    }
    buffer.writeCharCode(rune);
  }

  return buffer.toString().toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// آیا [haystack] با [query] مطابقت دارد؟ (همه‌ی کلمات باید موجود باشند، ترتیب مهم نیست)
bool matchesQuery(String haystack, String query) {
  final normalizedQuery = normalizeSearchText(query);
  if (normalizedQuery.isEmpty) return true;

  final normalizedHaystack = normalizeSearchText(haystack);
  if (normalizedHaystack.contains(normalizedQuery)) return true;

  final words = normalizedQuery.split(' ').where((w) => w.isNotEmpty);
  return words.isNotEmpty && words.every(normalizedHaystack.contains);
}

/// مقایسه‌ی نام فازها با نادیده‌گرفتن تفاوت‌های نگارشی و ارقام.
bool phaseNamesMatch(String a, String b) =>
    normalizeSearchText(a) == normalizeSearchText(b);

// ── فیلترهای متنی PostgREST ─────────────────────────────────────────────────

/// نویسه‌هایی که در گرامر فیلتر `or` پستگرس‌REST معنا دارند و باید از عبارت
/// کاربر پاک شوند:
/// - `,` جداکننده‌ی شرط‌هاست و وجودش در مقدار، خطای `PGRST100` می‌دهد
///   (سنجیده‌شده روی دیتابیس واقعی: خطای ۴۰۰ حتی وقتی کلاینت کاما را
///   `%2C` کرده باشد، چون سرور اول decode و بعد گرامر را تجزیه می‌کند).
///   یعنی بدون این پاک‌سازی، یک جستجوی حاوی کاما کل درخواست را می‌شکند.
/// - `(` و `)` و `*` نویسه‌های ساختاری همین گرامرند.
/// - `\\` نویسه‌ی escape است.
///   بقیه‌ی نویسه‌ها (مثل `%` و `_`) بی‌خطرند و دست‌نخورده می‌مانند.
final RegExp _postgrestReserved = RegExp(r'[,()*\\\x00-\x1F\x7F]');

final RegExp _whitespaceRun = RegExp(r'\s+');

/// پاک‌سازی عبارت کاربر برای ارسال به فیلتر متنی سرور.
String sanitizePostgrestTerm(String query) => query
    .replaceAll(_postgrestReserved, ' ')
    .replaceAll(_whitespaceRun, ' ')
    .trim();

/// ساخت شرط `or` برای جستجوی متنی سمت سرور.
///
/// الگو با `*` ساخته می‌شود: در PostgREST نویسه‌ی `*` در `like`/`ilike`
/// به `%` تبدیل می‌شود و شکل مستندشده‌ی همین است. با `%` هم کار می‌کند
/// (هر دو روی دیتابیس واقعی سنجیده شد و نتیجه یکسان بود)، ولی آن شکل به
/// round-trip نقطه‌زنجیره‌ی `%25` وابسته است.
///
/// عبارت با [sanitizePostgrestTerm] پاک می‌شود؛ پاک‌کردن کاما اینجا نقشی
/// حیاتی دارد (وگرنه جستجوی حاوی کاما با خطای ۴۰۰ از کار می‌افتد).
///
/// خروجی بدون پرانتز بیرونی است؛ خودِ کلاینت Supabase آن را اضافه می‌کند.
/// اگر پس از پاک‌سازی چیزی از عبارت نماند (مثلاً کاربر فقط `,` تایپ کرده)
/// `null` برمی‌گردد: فیلتر سرور قابل ساخت نیست و باید مسیر محلی رفت.
String? postgrestIlikeFilter(
  String query, {
  List<String> columns = const ['name', 'category', 'address', 'phase'],
}) {
  final term = sanitizePostgrestTerm(query);
  if (term.isEmpty) return null;

  final pattern = '*$term*';
  return [for (final column in columns) '$column.ilike.$pattern'].join(',');
}
