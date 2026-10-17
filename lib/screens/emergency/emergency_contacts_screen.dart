import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:heratmap/data/models/emergency_contact_model.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/screens/emergency/controller/emergency_controller.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';
import 'package:heratmap/widgets/app_ui.dart';
import 'package:url_launcher/url_launcher.dart';

IconData _iconForService(String iconKey) {
  return switch (iconKey.trim().toLowerCase()) {
    'policy' => Icons.policy_rounded,
    'hospital' || 'local_hospital' => Icons.local_hospital_rounded,
    'fire' || 'fire_truck' || 'fire_extinguisher' => Icons.fire_truck_rounded,
    'electric' || 'bolt' || 'electric_car' => Icons.bolt_rounded,
    'water' || 'water_drop' => Icons.water_drop_rounded,
    'factory' => Icons.factory_rounded,
    'ambulance' => Icons.volunteer_activism_rounded,
    _ => Icons.phone_rounded,
  };
}

class EmergencyContactsScreen extends StatelessWidget {
  const EmergencyContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<EmergencyContactController>();

    return Scaffold(
      body: Column(
        children: [
          AppPageHeader(
            title: AppStrings.emergencyContacts.tr,
            showBack: true,
            onBack: () => Get.back(),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimentions.spaces10,
                vertical: Dimentions.spaces4,
              ),
              decoration: BoxDecoration(
                color: StatusColors.redLight,
                borderRadius: BorderRadius.circular(Dimentions.radiusFull),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_rounded, size: 14, color: StatusColors.red),
                  SizedBox(width: 4),
                  Text(
                    'SOS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: StatusColors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value && ctrl.contacts.isEmpty) {
                return const ContactListSkeleton();
              }
              if (ctrl.hasError && ctrl.contacts.isEmpty) {
                return AppEmptyState(
                  icon: Icons.wifi_off_rounded,
                  message: ctrl.errorText ?? '',
                  actionLabel: AppStrings.retry.tr,
                  onAction: ctrl.reload,
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(Dimentions.spaces16),
                itemCount: ctrl.contacts.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: Dimentions.spaces8),
                itemBuilder: (_, i) => _ContactTile(contact: ctrl.contacts[i]),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final EmergencyContactModel contact;
  const _ContactTile({required this.contact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurfaceCard(
      onTap: () => _call(contact.phone),
      padding: const EdgeInsets.all(Dimentions.spaces12),
      child: Row(
        children: [
          AppIconBox(
            icon: _iconForService(contact.icon),
            size: 48,
            iconSize: 22,
            color: StatusColors.red,
            background: StatusColors.redLight,
          ),
          const SizedBox(width: Dimentions.spaces12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact.phone,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppSurfaces.muted(context),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: StatusColors.redLight,
            borderRadius: BorderRadius.circular(Dimentions.radius12),
            child: InkWell(
              onTap: () => _call(contact.phone),
              borderRadius: BorderRadius.circular(Dimentions.radius12),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.call_rounded,
                  color: StatusColors.red,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await Clipboard.setData(ClipboardData(text: phone));
      Get.snackbar(
        AppStrings.copyValue.tr,
        AppStrings.copied.tr,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(Dimentions.spaces16),
        duration: const Duration(seconds: 2),
      );
    }
  }
}

class ContactListSkeleton extends StatelessWidget {
  const ContactListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(Dimentions.spaces16),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: Dimentions.spaces8),
        height: 72,
        decoration: BoxDecoration(
          color: AppSurfaces.softFill(context),
          borderRadius: BorderRadius.circular(Dimentions.radius16),
        ),
      ),
    );
  }
}
