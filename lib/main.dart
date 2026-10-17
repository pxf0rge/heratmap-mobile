import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:heratmap/core/app_config.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/routes/app_pages.dart';
import 'package:heratmap/routes/app_routes.dart';
import 'package:heratmap/theme/app_theme.dart';
import 'package:heratmap/widgets/app_directionality.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local storage for factory cache and language preference
  await GetStorage.init();

  // Supabase — مقادیر از AppConfig می‌آیند و با --dart-define قابل‌تغییرند
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // FMTC tile cache — creates the store if it doesn't exist
  await FMTCObjectBoxBackend().initialise();
  await FMTCStore('heratMap').manage.create();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const HeratMapApp());
}

class HeratMapApp extends StatelessWidget {
  const HeratMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Read persisted language; default to Dari (fa)
    final storedLang = GetStorage().read<String>('selected_language') ?? 'fa';

    // Read persisted theme mode; default to system
    final storedTheme = GetStorage().read<String>('theme_mode');
    ThemeMode themeMode = ThemeMode.system;
    if (storedTheme == 'dark') {
      themeMode = ThemeMode.dark;
    } else if (storedTheme == 'light') {
      themeMode = ThemeMode.light;
    }

    return GetMaterialApp(
      // نام اپ در سوییچر برنامه‌ها؛ با زبان اپ عوض می‌شود (`onGenerateTitle`
      // برخلاف `title` با تغییر زبان بازسازی می‌شود).
      onGenerateTitle: (_) => AppStrings.appName.tr,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Localization
      translations: AppTranslations(),
      locale: Locale(storedLang),
      fallbackLocale: const Locale('fa'),
      supportedLocales: const [
        Locale('fa'), // Dari
        Locale('ps'), // Pashto
        Locale('en'), // English
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        // Cupertino doesn't ship with ps/fa — fall back to English
        _FallbackCupertinoDelegate(),
      ],

      // جهت چیدمان همه‌ی مسیرها از زبان انتخاب‌شده می‌آید، نه rtl هاردکد
      builder: (context, child) =>
          AppDirectionality(child: child ?? const SizedBox.shrink()),

      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}

/// A [CupertinoLocalizations] delegate that accepts every locale and falls
/// back to the default English implementation. This prevents the Flutter
/// framework from emitting "locale not supported" warnings for locales like
/// Pashto (ps) and Dari (fa) that have no built-in Cupertino translation.
class _FallbackCupertinoDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  @override
  bool isSupported(Locale locale) => true; // accept all locales

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      DefaultCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(_FallbackCupertinoDelegate old) => false;
}
