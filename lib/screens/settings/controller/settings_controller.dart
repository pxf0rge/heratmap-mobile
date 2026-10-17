import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:heratmap/core/app_config.dart';
import 'package:heratmap/data/repository/announcement_repository.dart';
import 'package:heratmap/data/repository/factory_repository.dart';
import 'package:heratmap/data/repository/news_repository.dart';
import 'package:heratmap/data/repository/phase_repository.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/values/dimentions.dart';

class SettingsController extends GetxController {
  final appVersion = AppConfig.appVersion.obs;

  static const _langKey = 'selected_language';
  static const _themeKey = 'theme_mode';

  /// Supported locales: Dari, Pashto, English
  static const List<LangOption> supportedLanguages = [
    LangOption(code: 'fa', label: 'دری', nativeLabel: 'Dari'),
    LangOption(code: 'ps', label: 'پښتو', nativeLabel: 'Pashto'),
    LangOption(code: 'en', label: 'English', nativeLabel: 'English'),
  ];

  late final RxString selectedLangCode;
  late final Rx<ThemeMode> themeMode;

  @override
  void onInit() {
    super.onInit();
    final stored = GetStorage().read<String>(_langKey) ?? 'fa';
    selectedLangCode = stored.obs;

    final storedTheme = GetStorage().read<String>(_themeKey);
    themeMode = _parseThemeMode(storedTheme).obs;
  }

  void changeThemeMode(ThemeMode mode) {
    if (themeMode.value == mode) return;
    themeMode.value = mode;
    GetStorage().write(_themeKey, mode.name);
    Get.changeThemeMode(mode);
  }

  ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  void changeLanguage(String langCode) {
    if (selectedLangCode.value == langCode) return;
    selectedLangCode.value = langCode;
    GetStorage().write(_langKey, langCode);

    final locale = Locale(langCode);
    Get.updateLocale(locale);
  }

  /// Returns true when the current language is RTL.
  bool get isRtl => selectedLangCode.value != 'en';

  /// Returns the TextDirection for the current language.
  TextDirection get textDirection =>
      isRtl ? TextDirection.rtl : TextDirection.ltr;

  /// پاکسازی همهی دادههای محلی ذخیرهشده روی دستگاه.
  void clearCache() {
    if (Get.isRegistered<FactoryRepository>()) {
      Get.find<FactoryRepository>().clearCache();
    }
    if (Get.isRegistered<PhaseRepository>()) {
      Get.find<PhaseRepository>().clearCache();
    }
    if (Get.isRegistered<NewsRepository>()) {
      Get.find<NewsRepository>().clearCache();
    }
    if (Get.isRegistered<AnnouncementRepository>()) {
      Get.find<AnnouncementRepository>().clearCache();
    }
    Get.snackbar(
      AppStrings.settings.tr,
      AppStrings.cacheCleared.tr,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(Dimentions.spaces16),
      duration: const Duration(seconds: 2),
    );
  }
}

/// یک گزینه‌ی زبان برای انتخاب‌گر تنظیمات.
class LangOption {
  final String code;
  final String label;
  final String nativeLabel;
  const LangOption({
    required this.code,
    required this.label,
    required this.nativeLabel,
  });
}
