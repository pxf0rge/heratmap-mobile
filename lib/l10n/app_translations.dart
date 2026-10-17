import 'package:get/get.dart';

/// Translation keys — use these constants everywhere instead of raw strings.
abstract class AppStrings {
  // App
  static const appName = 'app_name';
  static const appTagline = 'app_tagline';

  // Bottom nav
  static const navMap = 'nav_map';
  static const navSearch = 'nav_search';
  static const navPhases = 'nav_phases';
  static const navSettings = 'nav_settings';
  static const navNews = 'nav_news';

  // Home / Map
  static const searchHint = 'search_hint';
  static const nearestCompanies = 'nearest_companies';
  static const viewAll = 'view_all';
  static const loading = 'loading';
  static const retry = 'retry';
  static const noCompaniesFound = 'no_companies_found';

  // Search
  static const search = 'search';
  static const noResults = 'no_results';
  static const all = 'all';
  static const searchHistory = 'search_history';
  static const clearHistory = 'clear_history';
  static const removeItem = 'remove_item';
  static const searchResultCount = 'search_result_count';
  static const searchNoResultsFor = 'search_no_results_for';
  static const searchSuggestOther = 'search_suggest_other';
  static const clearFilters = 'clear_filters';
  static const searching = 'searching';
  static const clearSearchField = 'clear_search_field';
  static const serverSearchUnavailable = 'server_search_unavailable';

  // Phases
  static const phases = 'phases';
  static const phase = 'phase';
  static const viewCompanies = 'view_companies';
  static const companies = 'companies';
  static const noPhasesFound = 'no_phases_found';
  static const noPhasesFoundHint = 'no_phases_found_hint';

  // Factory detail
  static const phaseLabel = 'phase_label';
  static const category = 'category';
  static const phone = 'phone';
  static const address = 'address';
  static const workingHours = 'working_hours';
  static const description = 'description';
  static const navigate = 'navigate';
  static const call = 'call';
  static const share = 'share';
  static const openNow = 'open_now';
  static const closedNow = 'closed_now';
  static const closesAt = 'closes_at';
  static const opensAt = 'opens_at';
  static const workingHoursUnknown = 'working_hours_unknown';

  /// برچسب دسترس‌پذیری ترکیبی: وضعیت + توضیح ساعت.
  static const a11yStatusJoin = 'a11y_status_join';
  static const copyPhone = 'copy_phone';
  static const phoneCopied = 'phone_copied';
  static const invalidPhone = 'invalid_phone';
  static const noLocation = 'no_location';
  static const navigateWith = 'navigate_with';
  static const openInGoogleMaps = 'open_in_google_maps';
  static const openInAppMap = 'open_in_app_map';
  static const favorites = 'favorites';
  static const favorite = 'favorite';
  static const addToFavorites = 'add_to_favorites';
  static const removeFromFavorites = 'remove_from_favorites';
  static const addedToFavorites = 'added_to_favorites';
  static const removedFromFavorites = 'removed_from_favorites';
  static const imageCounter = 'image_counter';
  static const tapToZoom = 'tap_to_zoom';
  static const actionFailed = 'action_failed';

  // Units / counts
  static const distanceMeters = 'distance_meters';
  static const distanceKilometers = 'distance_kilometers';
  static const estimatedMinutes = 'estimated_minutes';
  static const phaseCompanyCount = 'phase_company_count';
  static const lotNumberLabel = 'lot_number_label';

  // Errors (لایه‌ی داده → متن نمایشی)
  static const errorOffline = 'error_offline';
  static const errorTimeout = 'error_timeout';
  static const errorUnauthorized = 'error_unauthorized';
  static const errorNotFound = 'error_not_found';
  static const errorServer = 'error_server';
  static const errorMalformed = 'error_malformed';
  static const errorUnknown = 'error_unknown';

  // Offline / cache indicators
  static const fromCache = 'from_cache';
  static const lastUpdated = 'last_updated';
  static const refresh = 'refresh';
  static const timeNow = 'time_now';
  static const timeMinutesAgo = 'time_minutes_ago';
  static const timeHoursAgo = 'time_hours_ago';
  static const timeDaysAgo = 'time_days_ago';

  // Map / location
  static const myLocation = 'my_location';
  static const showAllFactories = 'show_all_factories';
  static const locationPermissionTitle = 'location_permission_title';
  static const locationPermissionMessage = 'location_permission_message';
  static const openAppSettings = 'open_app_settings';
  static const cancel = 'cancel';
  static const locationDenied = 'location_denied';
  static const locationServiceDisabled = 'location_service_disabled';
  static const locationUnavailable = 'location_unavailable';
  static const details = 'details';
  static const showOnMap = 'show_on_map';

  // Settings
  static const settings = 'settings';
  static const version = 'version';
  static const about = 'about';
  static const aboutApp = 'about_app';
  static const contactUs = 'contact_us';
  static const language = 'language';
  static const selectLanguage = 'select_language';

  // About / Contact (فاز ۶)
  static const aboutMission = 'about_mission';
  static const aboutDescription = 'about_description';
  static const dataCredit = 'data_credit';
  static const mapCredit = 'map_credit';
  static const licenses = 'licenses';
  static const creditsTech = 'credits_tech';
  static const contactIntro = 'contact_intro';
  static const contactUnavailable = 'contact_unavailable';
  static const supportPhone = 'support_phone';
  static const supportEmail = 'support_email';
  static const supportWebsite = 'support_website';
  static const copyValue = 'copy_value';
  static const copied = 'copied';
  static const openWebsite = 'open_website';
  static const sendEmail = 'send_email';
  static const townLocation = 'town_location';
  static const emailSubject = 'email_subject';

  // Settings (فاز ۷)
  static const clearCache = 'clear_cache';
  static const clearCacheDesc = 'clear_cache_desc';
  static const cacheCleared = 'cache_cleared';

  // News (V2)
  static const news = 'news';
  static const noNewsFound = 'no_news_found';
  static const readMore = 'read_more';

  // Announcements
  static const announcements = 'announcements';
  static const noAnnouncementsFound = 'no_announcements_found';
  static const announcementExpired = 'announcement_expired';

  // Emergency (V2)
  static const emergencyContacts = 'emergency_contacts';

  // Dark mode
  static const darkMode = 'dark_mode';
  static const themeSystem = 'theme_system';
  static const themeLight = 'theme_light';
  static const themeDark = 'theme_dark';

  // Status
  static const inactive = 'inactive';

  // Language names
  static const langDari = 'lang_dari';
  static const langPashto = 'lang_pashto';
  static const langEnglish = 'lang_english';
}

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'fa': _dari,
    'ps': _pashto,
    'en': _english,
  };
}

// ── Dari (دری) ────────────────────────────────────────────────────────────────
const Map<String, String> _dari = {
  AppStrings.appName: 'شهرک صنعتی هرات',
  AppStrings.appTagline: 'نقشه هوشمند صنعتی',

  AppStrings.navMap: 'نقشه',
  AppStrings.navSearch: 'جستجو',
  AppStrings.navPhases: 'فازها',
  AppStrings.navNews: 'اخبار',
  AppStrings.navSettings: 'تنظیمات',

  AppStrings.searchHint: 'جستجوی شرکت یا فاز...',
  AppStrings.nearestCompanies: 'نزدیک‌ترین شرکت‌ها',
  AppStrings.viewAll: 'مشاهده همه',
  AppStrings.loading: 'در حال بارگذاری...',
  AppStrings.retry: 'تلاش مجدد',
  AppStrings.noCompaniesFound: 'شرکتی یافت نشد',

  AppStrings.search: 'جستجو',
  AppStrings.noResults: 'نتیجه‌ای یافت نشد',
  AppStrings.all: 'همه',
  AppStrings.searchHistory: 'جستجوهای اخیر',
  AppStrings.clearHistory: 'پاک کردن همه',
  AppStrings.removeItem: 'حذف',
  AppStrings.searchResultCount: '@n نتیجه',
  AppStrings.searchNoResultsFor: 'نتیجه‌ای برای «@q» پیدا نشد',
  AppStrings.searchSuggestOther:
      'واژه‌ی دیگری را امتحان کنید یا فیلترها را پاک کنید.',
  AppStrings.clearFilters: 'پاک کردن فیلترها',
  AppStrings.searching: 'در حال جستجو...',
  AppStrings.clearSearchField: 'پاک کردن جستجو',
  AppStrings.serverSearchUnavailable:
      'جستجوی آنلاین در دسترس نیست؛ نتیجه‌ها از حافظه‌ی دستگاه نمایش داده می‌شوند.',

  AppStrings.phases: 'فازها',
  AppStrings.phase: 'فاز',
  AppStrings.viewCompanies: 'مشاهده شرکت‌ها',
  AppStrings.companies: 'شرکت',
  AppStrings.noPhasesFound: 'فازی ثبت نشده',
  AppStrings.noPhasesFoundHint: 'هنوز فازی در سیستم ثبت نشده است.',

  AppStrings.phaseLabel: 'فاز',
  AppStrings.category: 'دسته‌بندی',
  AppStrings.phone: 'شماره تماس',
  AppStrings.address: 'آدرس',
  AppStrings.workingHours: 'ساعات کاری',
  AppStrings.description: 'توضیحات',
  AppStrings.navigate: 'مسیریابی',
  AppStrings.call: 'تماس',
  AppStrings.share: 'اشتراک‌گذاری',
  AppStrings.openNow: 'باز است',
  AppStrings.closedNow: 'بسته است',
  AppStrings.closesAt: 'تا ساعت @t',
  AppStrings.opensAt: 'از ساعت @t باز می‌شود',
  AppStrings.workingHoursUnknown: 'ساعت کاری نامشخص',
  AppStrings.a11yStatusJoin: '@s، @d',
  AppStrings.copyPhone: 'رونوشت شماره',
  AppStrings.phoneCopied: 'شماره رونوشت شد',
  AppStrings.invalidPhone: 'شماره‌ی تماس معتبر نیست',
  AppStrings.noLocation: 'موقعیت این شرکت ثبت نشده؛ مسیریابی ممکن نیست.',
  AppStrings.navigateWith: 'مسیریابی با',
  AppStrings.openInGoogleMaps: 'Google Maps',
  AppStrings.openInAppMap: 'نقشه‌ی همین اپ',
  AppStrings.favorites: 'نشان‌شده‌ها',
  AppStrings.favorite: 'نشان‌شده',
  AppStrings.addToFavorites: 'افزودن به نشان‌شده‌ها',
  AppStrings.removeFromFavorites: 'برداشتن از نشان‌شده‌ها',
  AppStrings.addedToFavorites: 'به نشان‌شده‌ها افزوده شد',
  AppStrings.removedFromFavorites: 'از نشان‌شده‌ها برداشته شد',
  AppStrings.imageCounter: 'تصویر @i از @n',
  AppStrings.tapToZoom: 'برای بزرگ‌نمایی لمس کنید',
  AppStrings.actionFailed: 'انجام این کار ممکن نشد؛ دوباره تلاش کنید.',
  AppStrings.distanceMeters: '@n متر',
  AppStrings.distanceKilometers: '@n کیلومتر',
  AppStrings.estimatedMinutes: '@n دقیقه پیاده',
  AppStrings.phaseCompanyCount: '@n شرکت',
  AppStrings.lotNumberLabel: 'نمره/قطعه',

  AppStrings.errorOffline: 'اتصال به اینترنت برقرار نیست',
  AppStrings.errorTimeout: 'پاسخ سرور دیر رسید؛ دوباره تلاش کنید',
  AppStrings.errorUnauthorized: 'دسترسی به این اطلاعات مجاز نیست',
  AppStrings.errorNotFound: 'موردی یافت نشد',
  AppStrings.errorServer: 'خطای سرور؛ کمی بعد دوباره تلاش کنید',
  AppStrings.errorMalformed: 'اطلاعات دریافتی معتبر نیست',
  AppStrings.errorUnknown: 'خطای نامشخص؛ دوباره تلاش کنید',

  AppStrings.fromCache: 'نمایش از حافظه‌ی دستگاه',
  AppStrings.lastUpdated: 'آخرین به‌روزرسانی',
  AppStrings.refresh: 'تازه‌سازی',
  AppStrings.timeNow: 'اکنون',
  AppStrings.timeMinutesAgo: '@n دقیقه پیش',
  AppStrings.timeHoursAgo: '@n ساعت پیش',
  AppStrings.timeDaysAgo: '@n روز پیش',

  AppStrings.myLocation: 'موقعیت من',
  AppStrings.showAllFactories: 'نمایش همه‌ی شرکت‌ها',
  AppStrings.locationPermissionTitle: 'دسترسی به موقعیت',
  AppStrings.locationPermissionMessage:
      'برای نمایش موقعیت شما روی نقشه و محاسبه‌ی فاصله‌ی شرکت‌ها، اجازه‌ی دسترسی به موقعیت لازم است. می‌توانید آن را از تنظیمات اپ فعال کنید.',
  AppStrings.openAppSettings: 'باز کردن تنظیمات',
  AppStrings.cancel: 'لغو',
  AppStrings.locationDenied:
      'برای استفاده از این قابلیت، دسترسی به موقعیت لازم است.',
  AppStrings.locationServiceDisabled:
      'سرویس موقعیت دستگاه خاموش است؛ آن را روشن کنید.',
  AppStrings.locationUnavailable:
      'موقعیت فعلی شما در دسترس نیست؛ کمی بعد دوباره تلاش کنید.',
  AppStrings.details: 'جزئیات',
  AppStrings.showOnMap: 'نمایش روی نقشه',

  AppStrings.settings: 'تنظیمات',
  AppStrings.version: 'نسخه',
  AppStrings.about: 'درباره',
  AppStrings.aboutApp: 'درباره اپلیکیشن',
  AppStrings.contactUs: 'تماس با ما',
  AppStrings.language: 'زبان',
  AppStrings.selectLanguage: 'انتخاب زبان',
  AppStrings.aboutMission:
      'پیدا کردن هر شرکت شهرک صنعتی هرات در کم‌تر از سی ثانیه.',
  AppStrings.aboutDescription:
      'شهرک صنعتی هرات صدها شرکت تولیدی و خدماتی دارد. این اپ نقشه، فازبندی، اطلاعات تماس و مسیریابی آن‌ها را یک‌جا می‌آورد تا کارآفرین، خریدار یا راننده بدون پرسیدن از این و آن، شرکت درست را پیدا کند. اطلاعات از دیتابیس شهرک خوانده می‌شود و روی دستگاه ذخیره می‌شود تا در اینترنت ضعیف هم کار کند.',
  AppStrings.dataCredit: 'منبع داده: دیتابیس شهرک صنعتی هرات',
  AppStrings.mapCredit: 'داده‌ی نقشه: مشارکت‌کنندگان OpenStreetMap (مجوز ODbL)',
  AppStrings.licenses: 'مجوزهای متن‌باز',
  AppStrings.creditsTech: 'ساخته‌شده با Flutter و Supabase',
  AppStrings.contactIntro:
      'برای پیشنهاد، اصلاح اطلاعات یک شرکت یا گزارش اشکال فنی با ما در تماس شوید.',
  AppStrings.contactUnavailable:
      'اطلاعات تماس پشتیبانی هنوز تنظیم نشده است؛ از طریق مدیر شهرک پیگیری کنید.',
  AppStrings.supportPhone: 'شماره‌ی پشتیبانی',
  AppStrings.supportEmail: 'ایمیل پشتیبانی',
  AppStrings.supportWebsite: 'وبسایت',
  AppStrings.copyValue: 'رونوشت',
  AppStrings.copied: 'رونوشت شد',
  AppStrings.openWebsite: 'باز کردن در مرورگر',
  AppStrings.sendEmail: 'ارسال ایمیل',
  AppStrings.townLocation: 'موقعیت شهرک روی نقشه',
  AppStrings.emailSubject: 'درباره‌ی اپ شهرک صنعتی هرات',
  AppStrings.clearCache: 'پاکسازی حافظهٔ محلی',
  AppStrings.clearCacheDesc: 'دادههای ذخیرهشده روی دستگاه پاک میشوند و دفعهی بعد دوباره بارگذاری میگردند.',
  AppStrings.cacheCleared: 'حافظهٔ محلی پاک شد',


  AppStrings.news: 'اخبار',
  AppStrings.noNewsFound: 'خبری یافت نشد',
  AppStrings.readMore: 'ادامهٔ مطلب',
  AppStrings.announcements: 'اطلاعیه‌ها',
  AppStrings.noAnnouncementsFound: 'اطلاعیه‌ای یافت نشد',
  AppStrings.announcementExpired: 'منقضی شده',
  AppStrings.emergencyContacts: 'شماره‌های ضروری',

  AppStrings.darkMode: 'حالت تاریک',
  AppStrings.themeSystem: 'سیستم',
  AppStrings.themeLight: 'روشن',
  AppStrings.themeDark: 'تاریک',
  AppStrings.inactive: 'غیرفعال',
  AppStrings.langDari: 'دری',
  AppStrings.langPashto: 'پښتو',
  AppStrings.langEnglish: 'English',
};

// ── Pashto (پښتو) ─────────────────────────────────────────────────────────────
const Map<String, String> _pashto = {
  AppStrings.appName: 'د هرات صنعتي ښارګوټی',
  AppStrings.appTagline: 'هوښیار صنعتي نقشه',

  AppStrings.navMap: 'نقشه',
  AppStrings.navSearch: 'لټون',
  AppStrings.navNews: 'اخبارات',
  AppStrings.navPhases: 'مرحلې',
  AppStrings.navSettings: 'ترتیبات',

  AppStrings.searchHint: 'د شرکت یا مرحلې لټون...',
  AppStrings.nearestCompanies: 'نږدې شرکتونه',
  AppStrings.viewAll: 'ټول وګورئ',
  AppStrings.loading: 'د بارولو په حال کې...',
  AppStrings.retry: 'بیا هڅه وکړئ',
  AppStrings.noCompaniesFound: 'هیڅ شرکت ونه موندل شو',

  AppStrings.search: 'لټون',
  AppStrings.noResults: 'هیڅ پایله ونه موندل شوه',
  AppStrings.all: 'ټول',
  AppStrings.searchHistory: 'وروستي لټونونه',
  AppStrings.clearHistory: 'ټول پاک کړئ',
  AppStrings.removeItem: 'حذف',
  AppStrings.searchResultCount: '@n پایلې',
  AppStrings.searchNoResultsFor: 'د «@q» لپاره پایلې ونه موندل شوې',
  AppStrings.searchSuggestOther: 'بله کلمه وآزموئ یا فلټرونه پاک کړئ.',
  AppStrings.clearFilters: 'فلټرونه پاک کړئ',
  AppStrings.searching: 'لټون روان دی...',
  AppStrings.clearSearchField: 'لټون پاک کړئ',
  AppStrings.serverSearchUnavailable:
      'آنلاین لټون شونی نه دی؛ پایلې د وسیلې له حافظې ښودل کیږي.',

  AppStrings.phases: 'مرحلې',
  AppStrings.phase: 'مرحله',
  AppStrings.viewCompanies: 'شرکتونه وګورئ',
  AppStrings.companies: 'شرکت',
  AppStrings.noPhasesFound: 'هیڅ مرحله نه ده ثبت شوې',
  AppStrings.noPhasesFoundHint: 'تر اوسه په سیستم کې هیڅ مرحله نه ده ثبت شوې.',

  AppStrings.phaseLabel: 'مرحله',
  AppStrings.category: 'کټګوري',
  AppStrings.phone: 'د اړیکې شمیره',
  AppStrings.address: 'پته',
  AppStrings.workingHours: 'د کار ساعتونه',
  AppStrings.description: 'توضیحات',
  AppStrings.navigate: 'لارښوونه',
  AppStrings.call: 'اړیکه',
  AppStrings.share: 'شریکول',
  AppStrings.openNow: 'اوس خلاص دی',
  AppStrings.closedNow: 'بند دی',
  AppStrings.closesAt: 'تر @t پورې',
  AppStrings.opensAt: 'له @t څخه خلاصیږي',
  AppStrings.workingHoursUnknown: 'د کار ساعتونه ناڅرګند دي',
  AppStrings.a11yStatusJoin: '@s، @d',
  AppStrings.copyPhone: 'شمېره کاپي کړئ',
  AppStrings.phoneCopied: 'شمېره کاپي شوه',
  AppStrings.invalidPhone: 'د اړیکې شمېره سمه نه ده',
  AppStrings.noLocation: 'د دې شرکت موقعیت ثبت نه دی؛ لارښوونه شونې نه ده.',
  AppStrings.navigateWith: 'لارښوونه د',
  AppStrings.openInGoogleMaps: 'Google Maps',
  AppStrings.openInAppMap: 'د همدې اپ نقشه',
  AppStrings.favorites: 'نښه شوي',
  AppStrings.favorite: 'نښه شوی',
  AppStrings.addToFavorites: 'نښه شویو ته اضافه کړئ',
  AppStrings.removeFromFavorites: 'له نښه شویو لرې کړئ',
  AppStrings.addedToFavorites: 'نښه شویو ته اضافه شو',
  AppStrings.removedFromFavorites: 'له نښه شویو لرې شو',
  AppStrings.imageCounter: 'انځور @i له @n',
  AppStrings.tapToZoom: 'د لویولو لپاره یې کېکاږئ',
  AppStrings.actionFailed: 'دا کار ممکن نه شو؛ بېا هڅه وکړئ.',
  AppStrings.distanceMeters: '@n متره',
  AppStrings.distanceKilometers: '@n کیلومتره',
  AppStrings.estimatedMinutes: '@n دقیقې پیاده',
  AppStrings.phaseCompanyCount: '@n شرکت',
  AppStrings.lotNumberLabel: 'نمره/قطعه',

  AppStrings.errorOffline: 'د انټرنیټ سره اړیکه نشته',
  AppStrings.errorTimeout: 'د سرور ځواب ناوخته راغى؛ بیا هڅه وکړئ',
  AppStrings.errorUnauthorized: 'دې معلوماتو ته لاسرسی اجازه نلري',
  AppStrings.errorNotFound: 'هیڅ ونه موندل شو',
  AppStrings.errorServer: 'د سرور تېروتنه؛ لږ وروسته بیا هڅه وکړئ',
  AppStrings.errorMalformed: 'ترلاسه شوي معلومات سم ندي',
  AppStrings.errorUnknown: 'ناڅرګنده تېروتنه؛ بیا هڅه وکړئ',

  AppStrings.fromCache: 'د وسیلې له حافظې ښودل کیږي',
  AppStrings.lastUpdated: 'وروستى تازه کول',
  AppStrings.refresh: 'تازه کول',
  AppStrings.timeNow: 'اوس',
  AppStrings.timeMinutesAgo: '@n دقیقې دمخه',
  AppStrings.timeHoursAgo: '@n ساعته دمخه',
  AppStrings.timeDaysAgo: '@n ورځې دمخه',

  AppStrings.myLocation: 'زما موقعیت',
  AppStrings.showAllFactories: 'ټول شرکتونه وګورئ',
  AppStrings.locationPermissionTitle: 'موقعیت ته لاسرسی',
  AppStrings.locationPermissionMessage:
      'د نقشې پر سر ستاسو موقعیت ښودلو او د شرکتونو فاصله محاسبه کولو لپاره موقعیت ته اجازه اړینه ده. کولی شئ د اپ ترتیباتو څخه یې فعال کړئ.',
  AppStrings.openAppSettings: 'د اپ ترتیبات پرانیستل',
  AppStrings.cancel: 'لغوه',
  AppStrings.locationDenied: 'دې ځانګړتیا لپاره موقعیت ته لاسرسی اړین دی.',
  AppStrings.locationServiceDisabled:
      'د وسیلې موقعیت خدمت بند دی؛ هغه فعال کړئ.',
  AppStrings.locationUnavailable:
      'ستاسو اوسنی موقعیت نه ترلاسه کیږي؛ لږ وروسته بیا هڅه وکړئ.',
  AppStrings.details: 'تفصیلات',
  AppStrings.showOnMap: 'په نقشه کې ښودل',

  AppStrings.settings: 'ترتیبات',
  AppStrings.version: 'نسخه',
  AppStrings.about: 'د اړه',
  AppStrings.aboutApp: 'د اپلیکیشن اړه',
  AppStrings.contactUs: 'له موږ سره اړیکه',
  AppStrings.language: 'ژبه',
  AppStrings.selectLanguage: 'ژبه غوره کړئ',
  AppStrings.aboutMission:
      'د هرات صنعتي ښارګوټي هر شرکت په دېرشو ثانیو کې ومومئ.',
  AppStrings.aboutDescription:
      'د هرات صنعتي ښارګوټی سلګونه تولیدي او خدمتي شرکتونه لري. دا اپ نقشه، مرحلې، د اړیکې معلومات او لارښوونه یوځای کوي ترڅو سوداګر، پیرودونکی یا موټر چلوونکی پرته له پوښتنې سم شرکت ومومي. معلومات د ښارګوټي رسمي ډاټابیس څخه راځي او په وسیله کې ساتل کیږي ترڅو په کمزوري انټرنیټ کې هم کار وکړي.',
  AppStrings.dataCredit: 'د معلوماتو سرچینه: د هرات صنعتي ښارګوټي ډاټابیس',
  AppStrings.mapCredit:
      'د نقشې معلومات: OpenStreetMap مرسته کوونکي (ODbL جواز)',
  AppStrings.licenses: 'د پرانیستې سرچینې جوازونه',
  AppStrings.creditsTech: 'د Flutter او Supabase سره جوړ شوی',
  AppStrings.contactIntro:
      'د وړاندیز، د یو شرکت د معلوماتو اصلاح یا د تخنیکي ستونزې د راپور لپاره له موږ سره اړیکه ونیسئ.',
  AppStrings.contactUnavailable:
      'د ملاتړ د اړیکې معلومات لا نه دي تنظیم شوي؛ له ښارګوټي مدیر سره اړیکه ونیسئ.',
  AppStrings.supportPhone: 'د ملاتړ شمېره',
  AppStrings.supportEmail: 'د ملاتړ برېښنالیک',
  AppStrings.supportWebsite: 'وېبسایټ',
  AppStrings.copyValue: 'کاپي',
  AppStrings.copied: 'کاپي شو',
  AppStrings.openWebsite: 'په براوزر کې پرانیستل',
  AppStrings.sendEmail: 'برېښنالیک لېږل',
  AppStrings.townLocation: 'د ښارګوټي موقعیت پر نقشه',
  AppStrings.news: 'اخبارات',
  AppStrings.noNewsFound: 'هیڅ خبر ونه موندل شو',
  AppStrings.readMore: 'نور یې ولولئ',
  AppStrings.announcements: 'خبرتیاوې',
  AppStrings.noAnnouncementsFound: 'هیڅ خبرتیا ونه موندل شوه',
  AppStrings.announcementExpired: 'پای ته رسېدلی',
  AppStrings.emergencyContacts: 'ضروري شمېرې',

  AppStrings.emailSubject: 'د هرات صنعتي ښارګوټي اپ په اړه',
  AppStrings.clearCache: 'د وسیلې حافظه پاکه کړئ',
  AppStrings.clearCacheDesc: 'هغه معلومات چې په وسیله کې خوندي شوي پاک کیږي او بل ځل بیا بارولی کیږي.',
  AppStrings.cacheCleared: 'د وسیلې حافظه پاکه شوه',

  AppStrings.darkMode: 'تیاره حالت',
  AppStrings.themeSystem: 'سیسټم',
  AppStrings.themeLight: 'روښانه',
  AppStrings.themeDark: 'تیاره',
  AppStrings.inactive: 'غیر فعال',
  AppStrings.langDari: 'دری',
  AppStrings.langPashto: 'پښتو',
  AppStrings.langEnglish: 'English',
};

// ── English ───────────────────────────────────────────────────────────────────
const Map<String, String> _english = {
  AppStrings.appName: 'Herat Industrial Town',
  AppStrings.appTagline: 'Smart Industrial Map',

  AppStrings.navMap: 'Map',
  AppStrings.navNews: 'News',
  AppStrings.navSearch: 'Search',
  AppStrings.navPhases: 'Phases',
  AppStrings.navSettings: 'Settings',

  AppStrings.searchHint: 'Search company or phase...',
  AppStrings.nearestCompanies: 'Nearest Companies',
  AppStrings.viewAll: 'View All',
  AppStrings.loading: 'Loading...',
  AppStrings.retry: 'Retry',
  AppStrings.noCompaniesFound: 'No companies found',

  AppStrings.search: 'Search',
  AppStrings.noResults: 'No results found',
  AppStrings.all: 'All',
  AppStrings.searchHistory: 'Recent searches',
  AppStrings.clearHistory: 'Clear all',
  AppStrings.removeItem: 'Remove',
  AppStrings.searchResultCount: '@n results',
  AppStrings.searchNoResultsFor: 'No results for “@q”',
  AppStrings.searchSuggestOther: 'Try a different word or clear the filters.',
  AppStrings.clearFilters: 'Clear filters',
  AppStrings.searching: 'Searching...',
  AppStrings.clearSearchField: 'Clear search',
  AppStrings.serverSearchUnavailable:
      'Online search is unavailable; results come from this device.',

  AppStrings.phases: 'Phases',
  AppStrings.phase: 'Phase',
  AppStrings.viewCompanies: 'View Companies',
  AppStrings.companies: 'companies',
  AppStrings.noPhasesFound: 'No phases yet',
  AppStrings.noPhasesFoundHint: 'No phases have been added yet.',

  AppStrings.phaseLabel: 'Phase',
  AppStrings.category: 'Category',
  AppStrings.phone: 'Phone Number',
  AppStrings.address: 'Address',
  AppStrings.workingHours: 'Working Hours',
  AppStrings.description: 'Description',
  AppStrings.navigate: 'Navigate',
  AppStrings.call: 'Call',
  AppStrings.share: 'Share',
  AppStrings.openNow: 'Open now',
  AppStrings.closedNow: 'Closed',
  AppStrings.closesAt: 'until @t',
  AppStrings.opensAt: 'opens at @t',
  AppStrings.workingHoursUnknown: 'Working hours unknown',
  AppStrings.a11yStatusJoin: '@s, @d',
  AppStrings.copyPhone: 'Copy number',
  AppStrings.phoneCopied: 'Number copied',
  AppStrings.invalidPhone: 'The phone number is not valid',
  AppStrings.noLocation:
      'This company has no saved location; navigation is unavailable.',
  AppStrings.navigateWith: 'Navigate with',
  AppStrings.openInGoogleMaps: 'Google Maps',
  AppStrings.openInAppMap: 'In-app map',
  AppStrings.favorites: 'Favorites',
  AppStrings.favorite: 'Favorite',
  AppStrings.addToFavorites: 'Add to favorites',
  AppStrings.removeFromFavorites: 'Remove from favorites',
  AppStrings.addedToFavorites: 'Added to favorites',
  AppStrings.removedFromFavorites: 'Removed from favorites',
  AppStrings.imageCounter: 'Image @i of @n',
  AppStrings.tapToZoom: 'Tap to zoom in',
  AppStrings.actionFailed: 'Could not complete this action; please try again.',
  AppStrings.distanceMeters: '@n m',
  AppStrings.distanceKilometers: '@n km',
  AppStrings.estimatedMinutes: '@n min walk',
  AppStrings.phaseCompanyCount: '@n companies',
  AppStrings.lotNumberLabel: 'Lot number',

  AppStrings.errorOffline: 'No internet connection',
  AppStrings.errorTimeout: 'The server took too long to respond; try again',
  AppStrings.errorUnauthorized: 'You are not allowed to access this data',
  AppStrings.errorNotFound: 'Nothing found',
  AppStrings.errorServer: 'Server error; please try again later',
  AppStrings.errorMalformed: 'The received data is not valid',
  AppStrings.errorUnknown: 'Something went wrong; please try again',

  AppStrings.fromCache: 'Showing data saved on this device',
  AppStrings.lastUpdated: 'Last updated',
  AppStrings.refresh: 'Refresh',
  AppStrings.timeNow: 'just now',
  AppStrings.timeMinutesAgo: '@n minutes ago',
  AppStrings.timeHoursAgo: '@n hours ago',
  AppStrings.timeDaysAgo: '@n days ago',

  AppStrings.myLocation: 'My location',
  AppStrings.showAllFactories: 'Show all companies',
  AppStrings.locationPermissionTitle: 'Location access',
  AppStrings.locationPermissionMessage:
      'To show your position on the map and compute distances to companies, location access is required. You can enable it from the app settings.',
  AppStrings.openAppSettings: 'Open app settings',
  AppStrings.cancel: 'Cancel',
  AppStrings.locationDenied: 'Location access is required for this feature.',
  AppStrings.locationServiceDisabled:
      'Device location service is off; please turn it on.',
  AppStrings.locationUnavailable:
      'Your current position is unavailable; please try again shortly.',
  AppStrings.details: 'Details',
  AppStrings.showOnMap: 'Show on map',

  AppStrings.settings: 'Settings',
  AppStrings.version: 'Version',
  AppStrings.about: 'About',
  AppStrings.aboutApp: 'About App',
  AppStrings.contactUs: 'Contact Us',
  AppStrings.language: 'Language',
  AppStrings.selectLanguage: 'Select Language',
  AppStrings.aboutMission:
      'Find any company in Herat Industrial Town in under thirty seconds.',
  AppStrings.aboutDescription:
      'Herat Industrial Town hosts hundreds of manufacturing and service companies. This app brings its map, phases, contact details and directions together so a business owner, buyer or driver can find the right company without asking around. Data comes from the town database and is stored on the device, so it keeps working on a weak connection.',
  AppStrings.dataCredit: 'Data source: Herat Industrial Town database',
  AppStrings.mapCredit: 'Map data: OpenStreetMap contributors (ODbL)',
  AppStrings.licenses: 'Open-source licenses',
  AppStrings.creditsTech: 'Built with Flutter and Supabase',
  AppStrings.contactIntro:
      'Get in touch for suggestions, corrections to a company record, or to report a technical problem.',
  AppStrings.contactUnavailable:
      'Support contact details are not configured yet; please follow up with the town administration.',
  AppStrings.supportPhone: 'Support phone',
  AppStrings.supportEmail: 'Support email',
  AppStrings.supportWebsite: 'Website',
  AppStrings.news: 'News',
  AppStrings.noNewsFound: 'No news found',
  AppStrings.readMore: 'Read more',
  AppStrings.announcements: 'Announcements',
  AppStrings.noAnnouncementsFound: 'No announcements found',
  AppStrings.announcementExpired: 'Expired',
  AppStrings.emergencyContacts: 'Emergency contacts',

  AppStrings.copyValue: 'Copy',
  AppStrings.copied: 'Copied',
  AppStrings.openWebsite: 'Open in browser',
  AppStrings.sendEmail: 'Send email',
  AppStrings.townLocation: 'Town location on the map',
  AppStrings.emailSubject: 'About the Herat Industrial Town app',
  AppStrings.clearCache: 'Clear local cache',
  AppStrings.clearCacheDesc: 'Data saved on this device will be erased and re-downloaded next time.',
  AppStrings.cacheCleared: 'Local cache cleared',

  AppStrings.darkMode: 'Dark Mode',
  AppStrings.themeSystem: 'System',
  AppStrings.themeLight: 'Light',
  AppStrings.themeDark: 'Dark',
  AppStrings.inactive: 'Inactive',
  AppStrings.langDari: 'دری',
  AppStrings.langPashto: 'پښتو',
  AppStrings.langEnglish: 'English',
};
