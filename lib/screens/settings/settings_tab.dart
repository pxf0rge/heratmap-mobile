import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heratmap/core/app_config.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/routes/app_routes.dart';
import 'package:heratmap/screens/settings/controller/settings_controller.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';
import 'package:heratmap/widgets/app_ui.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SettingsController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          AppPageHeader(
            title: AppStrings.navSettings.tr,
            icon: Icons.settings_rounded,
            trailing: Obx(
              () => Text(
                '${AppStrings.version.tr} ${ctrl.appVersion.value}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppSurfaces.muted(context),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Dimentions.spaces16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSurfaceCard(
                  padding: const EdgeInsets.all(Dimentions.spaces16),
                  child: Row(
                    children: [
                      AppIconBox(
                        icon: Icons.factory_rounded,
                        size: 48,
                        iconSize: 24,
                      ),
                      const SizedBox(width: Dimentions.spaces14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.appName.tr,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppStrings.appTagline.tr,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppSurfaces.muted(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimentions.spaces24),
                AppSectionLabel(AppStrings.language.tr),
                _LanguageSelector(ctrl: ctrl),
                const SizedBox(height: Dimentions.spaces24),
                AppSectionLabel(AppStrings.darkMode.tr),
                _ThemeSelector(ctrl: ctrl),
                const SizedBox(height: Dimentions.spaces24),
                AppSectionLabel(AppStrings.about.tr),
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: AppStrings.aboutApp.tr,
                  onTap: () => Get.toNamed(AppRoutes.aboutApp),
                ),
                _SettingsTile(
                  icon: Icons.phone_outlined,
                  title: AppStrings.contactUs.tr,
                  subtitle: AppConfig.hasSupportContact
                      ? null
                      : AppStrings.contactUnavailable.tr,
                  onTap: () => Get.toNamed(AppRoutes.contactUs),
                ),
                _SettingsTile(
                  icon: Icons.emergency_rounded,
                  title: AppStrings.emergencyContacts.tr,
                  accent: StatusColors.red,
                  accentBg: StatusColors.redLight,
                  onTap: () => Get.toNamed(AppRoutes.emergencyContacts),
                ),
                const SizedBox(height: Dimentions.spaces24),
                AppSectionLabel(AppStrings.clearCache.tr),
                _SettingsTile(
                  icon: Icons.delete_outline_rounded,
                  title: AppStrings.clearCache.tr,
                  subtitle: AppStrings.clearCacheDesc.tr,
                  accent: StatusColors.red,
                  accentBg: StatusColors.redLight,
                  onTap: () => _confirmClearCache(context, ctrl),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _confirmClearCache(
  BuildContext context,
  SettingsController ctrl,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(AppStrings.clearCache.tr),
      content: Text(AppStrings.clearCacheDesc.tr),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(AppStrings.cancel.tr),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(AppStrings.clearCache.tr),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  ctrl.clearCache();
}

class _LanguageSelector extends StatelessWidget {
  final SettingsController ctrl;
  const _LanguageSelector({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = SettingsController.supportedLanguages.firstWhere(
        (l) => l.code == ctrl.selectedLangCode.value,
        orElse: () => SettingsController.supportedLanguages.first,
      );

      return AppSurfaceCard(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimentions.spaces16,
          vertical: Dimentions.spaces4,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selected.code,
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppSurfaces.muted(context),
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            onChanged: (code) {
              if (code != null) ctrl.changeLanguage(code);
            },
            items: SettingsController.supportedLanguages.map((lang) {
              final active = lang.code == ctrl.selectedLangCode.value;
              return DropdownMenuItem<String>(
                value: lang.code,
                child: Row(
                  children: [
                    AppIconBox(
                      icon: Icons.language_rounded,
                      size: 32,
                      iconSize: 16,
                      color: active
                          ? Theme.of(context).colorScheme.primary
                          : NeutralColors.n400,
                      background: active
                          ? AppSurfaces.primarySoft(context)
                          : AppSurfaces.softFill(context),
                    ),
                    const SizedBox(width: Dimentions.spaces12),
                    Text(lang.label),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }
}

class _ThemeSelector extends StatelessWidget {
  final SettingsController ctrl;
  const _ThemeSelector({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = ctrl.themeMode.value;
      return AppSurfaceCard(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimentions.spaces16,
          vertical: Dimentions.spaces4,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<ThemeMode>(
            value: current,
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppSurfaces.muted(context),
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            onChanged: (mode) {
              if (mode != null) ctrl.changeThemeMode(mode);
            },
            items: [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Row(
                  children: [
                    const Icon(Icons.brightness_auto_rounded, size: 20),
                    const SizedBox(width: Dimentions.spaces12),
                    Text(AppStrings.themeSystem.tr),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Row(
                  children: [
                    const Icon(Icons.light_mode_rounded, size: 20),
                    const SizedBox(width: Dimentions.spaces12),
                    Text(AppStrings.themeLight.tr),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Row(
                  children: [
                    const Icon(Icons.dark_mode_rounded, size: 20),
                    const SizedBox(width: Dimentions.spaces12),
                    Text(AppStrings.themeDark.tr),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? accent;
  final Color? accentBg;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.accent,
    this.accentBg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accent ?? theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimentions.spaces8),
      child: AppSurfaceCard(
        onTap: onTap,
        padding: const EdgeInsets.all(Dimentions.spaces12),
        child: Row(
          children: [
            AppIconBox(
              icon: icon,
              color: color,
              background: accentBg ?? AppSurfaces.primarySoft(context),
            ),
            const SizedBox(width: Dimentions.spaces12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppSurfaces.muted(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: NeutralColors.n300,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
