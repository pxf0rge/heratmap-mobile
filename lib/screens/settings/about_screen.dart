import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heratmap/core/app_config.dart';
import 'package:heratmap/gen/assets.gen.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';
import 'package:heratmap/widgets/app_ui.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          AppPageHeader(
            title: AppStrings.aboutApp.tr,
            showBack: true,
            onBack: () => Get.back(),
          ),
          Padding(
            padding: const EdgeInsets.all(Dimentions.spaces16),
            child: Column(
              children: [
                AppSurfaceCard(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppSurfaces.primarySoft(context),
                          borderRadius:
                              BorderRadius.circular(Dimentions.radius20),
                        ),
                        child: Assets.image.logo.image(width: 44),
                      ),
                      const SizedBox(height: Dimentions.spaces12),
                      Text(
                        AppStrings.appName.tr,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: Dimentions.spaces4),
                      Text(
                        AppStrings.appTagline.tr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppSurfaces.muted(context),
                        ),
                      ),
                      const SizedBox(height: Dimentions.spaces8),
                      Text(
                        '${AppStrings.version.tr} ${AppConfig.appVersion}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: NeutralColors.n400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimentions.spaces12),
                AppSurfaceCard(
                  child: Column(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: primary,
                        size: 28,
                      ),
                      const SizedBox(height: Dimentions.spaces8),
                      Text(
                        AppStrings.aboutMission.tr,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: primary,
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimentions.spaces12),
                AppSurfaceCard(
                  child: Text(
                    AppStrings.aboutDescription.tr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.9,
                      color: AppSurfaces.muted(context),
                    ),
                  ),
                ),
                const SizedBox(height: Dimentions.spaces20),
                _InfoRow(
                  icon: Icons.storage_rounded,
                  text: AppStrings.dataCredit.tr,
                ),
                _InfoRow(
                  icon: Icons.map_outlined,
                  text: AppStrings.mapCredit.tr,
                ),
                const SizedBox(height: Dimentions.spaces12),
                AppSurfaceCard(
                  padding: EdgeInsets.zero,
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: AppStrings.appName.tr,
                    applicationVersion: AppConfig.appVersion,
                    applicationLegalese: AppStrings.creditsTech.tr,
                  ),
                  child: ListTile(
                    leading: AppIconBox(icon: Icons.article_outlined),
                    title: Text(
                      AppStrings.licenses.tr,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: NeutralColors.n300,
                    ),
                  ),
                ),
                const SizedBox(height: Dimentions.spaces16),
                Text(
                  AppStrings.creditsTech.tr,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: NeutralColors.n400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimentions.spaces6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconBox(icon: icon, size: 32, iconSize: 16),
          const SizedBox(width: Dimentions.spaces12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppSurfaces.muted(context),
                    height: 1.6,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
