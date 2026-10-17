import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:heratmap/core/app_config.dart';
import 'package:heratmap/core/factory_links.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';
import 'package:heratmap/widgets/app_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phoneUri = factoryTelUri(AppConfig.supportPhone);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          AppPageHeader(
            title: AppStrings.contactUs.tr,
            showBack: true,
            onBack: () => Get.back(),
          ),
          Padding(
            padding: const EdgeInsets.all(Dimentions.spaces16),
            child: Column(
              children: [
                AppSurfaceCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppIconBox(icon: Icons.support_agent_rounded),
                      const SizedBox(width: Dimentions.spaces12),
                      Expanded(
                        child: Text(
                          AppStrings.contactIntro.tr,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimentions.spaces16),
                if (!AppConfig.hasSupportContact)
                  _Notice(text: AppStrings.contactUnavailable.tr)
                else ...[
                  if (phoneUri != null)
                    _ContactTile(
                      icon: Icons.call_rounded,
                      label: AppStrings.supportPhone.tr,
                      value: AppConfig.supportPhone,
                      actionLabel: AppStrings.call.tr,
                      onAction: () => _launch(phoneUri),
                      onCopy: () => _copy(AppConfig.supportPhone),
                    ),
                  if (AppConfig.supportEmail.isNotEmpty)
                    _ContactTile(
                      icon: Icons.alternate_email_rounded,
                      label: AppStrings.supportEmail.tr,
                      value: AppConfig.supportEmail,
                      actionLabel: AppStrings.sendEmail.tr,
                      onAction: () => _launch(
                        Uri(
                          scheme: 'mailto',
                          path: AppConfig.supportEmail,
                          queryParameters: {
                            'subject': AppStrings.emailSubject.tr,
                          },
                        ),
                      ),
                      onCopy: () => _copy(AppConfig.supportEmail),
                    ),
                  if (AppConfig.supportWebsite.isNotEmpty)
                    _ContactTile(
                      icon: Icons.public_rounded,
                      label: AppStrings.supportWebsite.tr,
                      value: AppConfig.supportWebsite,
                      actionLabel: AppStrings.openWebsite.tr,
                      onAction: () => _launch(
                        _webUri(AppConfig.supportWebsite),
                        mode: LaunchMode.externalApplication,
                      ),
                      onCopy: () => _copy(AppConfig.supportWebsite),
                    ),
                ],
                const SizedBox(height: Dimentions.spaces8),
                _ContactTile(
                  icon: Icons.location_on_rounded,
                  label: AppStrings.townLocation.tr,
                  value: AppStrings.appName.tr,
                  actionLabel: AppStrings.showOnMap.tr,
                  onAction: () => _launch(
                    AppConfig.townLocationUri,
                    mode: LaunchMode.externalApplication,
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

Future<void> _launch(
  Uri uri, {
  LaunchMode mode = LaunchMode.platformDefault,
}) async {
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: mode);
      return;
    }
  } catch (_) {}
  _message(AppStrings.actionFailed.tr);
}

Future<void> _copy(String value) async {
  await Clipboard.setData(ClipboardData(text: value));
  _message(AppStrings.copied.tr);
}

void _message(String text) {
  Get.snackbar(
    AppStrings.contactUs.tr,
    text,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(Dimentions.spaces16),
    duration: const Duration(seconds: 3),
  );
}

Uri _webUri(String raw) {
  final value = raw.trim();
  return Uri.parse(value.contains('://') ? value : 'https://$value');
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.actionLabel,
    required this.onAction,
    this.onCopy,
  });

  final IconData icon;
  final String label;
  final String value;
  final String actionLabel;
  final VoidCallback onAction;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimentions.spaces8),
      child: AppSurfaceCard(
        onTap: onAction,
        padding: const EdgeInsets.all(Dimentions.spaces12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIconBox(icon: icon),
                const SizedBox(width: Dimentions.spaces12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppSurfaces.muted(context),
                        ),
                      ),
                      const SizedBox(height: Dimentions.spaces2),
                      Text(
                        value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onCopy != null)
                  IconButton(
                    tooltip: AppStrings.copyValue.tr,
                    onPressed: onCopy,
                    icon: Icon(
                      Icons.copy_rounded,
                      size: Dimentions.icon20,
                      color: AppSurfaces.muted(context),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Dimentions.spaces8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: Dimentions.spaces8),
      padding: const EdgeInsets.all(Dimentions.spaces12),
      decoration: BoxDecoration(
        color: StatusColors.yellowLight,
        borderRadius: BorderRadius.circular(Dimentions.radius16),
        border: Border.all(
          color: StatusColors.yellow.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: Dimentions.icon20,
            color: StatusColors.yellow,
          ),
          const SizedBox(width: Dimentions.spaces8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppSurfaces.muted(context),
                    height: 1.7,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
