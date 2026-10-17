import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/screens/home/controller/home_controller.dart';
import 'package:heratmap/screens/home/widgets/home_bottom_sheet.dart';
import 'package:heratmap/screens/home/widgets/home_search_bar.dart';
import 'package:heratmap/screens/home/widgets/map_widget.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';
import 'package:heratmap/widgets/data_status_banner.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeMapTab extends StatelessWidget {
  const HomeMapTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    final topOffset = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: MapWidget()),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _MapAppBar(ctrl: ctrl, topOffset: topOffset),
          ),
          Positioned(
            top: topOffset + 64,
            left: Dimentions.spaces16,
            right: Dimentions.spaces16,
            child: const HomeSearchBar(),
          ),
          Positioned(
            top: topOffset + 124,
            left: Dimentions.spaces16,
            right: Dimentions.spaces16,
            child: Obx(
              () => ctrl.isFromCache
                  ? DataStatusBanner(
                      source: ctrl.dataSource.value,
                      fetchedAt: ctrl.lastUpdatedAt.value,
                      onRefresh: ctrl.reload,
                      compact: true,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          const HomeBottomSheet(),
        ],
      ),
    );
  }
}

class _MapAppBar extends StatelessWidget {
  final HomeController ctrl;
  final double topOffset;

  const _MapAppBar({required this.ctrl, required this.topOffset});

  @override
  Widget build(BuildContext context) {
    final surface = AppSurfaces.card(context);
    final border = AppSurfaces.border(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.96),
        border: Border(bottom: BorderSide(color: border)),
      ),
      padding: EdgeInsets.only(
        top: topOffset,
        left: Dimentions.spaces16,
        right: Dimentions.spaces16,
        bottom: Dimentions.spaces12,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppSurfaces.primarySoft(context),
              borderRadius: BorderRadius.circular(Dimentions.radius12),
            ),
            child: Icon(
              Icons.factory_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: Dimentions.spaces12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.appName.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  AppStrings.appTagline.tr,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppSurfaces.muted(context),
                  ),
                ),
              ],
            ),
          ),
          _AppBarButton(
            icon: Icons.fit_screen_rounded,
            tooltip: AppStrings.showAllFactories.tr,
            onTap: ctrl.fitAllFactories,
          ),
          const SizedBox(width: Dimentions.spaces6),
          _AppBarButton(
            icon: ctrl.locationState.value == LocationState.granted
                ? Icons.my_location_rounded
                : Icons.location_searching_rounded,
            tooltip: AppStrings.myLocation.tr,
            onTap: () => _goToUserLocation(context, ctrl),
          ),
        ],
      ),
    );
  }
}

class _AppBarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _AppBarButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppSurfaces.softFill(context),
        borderRadius: BorderRadius.circular(Dimentions.radius12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Dimentions.radius12),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 20, color: Theme.of(context).iconTheme.color),
          ),
        ),
      ),
    );
  }
}

Future<void> _goToUserLocation(
  BuildContext context,
  HomeController ctrl,
) async {
  final state = await ctrl.centerOnUser();
  if (!context.mounted) return;

  switch (state) {
    case LocationState.granted:
      break;
    case LocationState.permanentlyDenied:
      await _showSettingsDialog(context, ctrl);
    case LocationState.serviceDisabled:
      _showMessage(AppStrings.locationServiceDisabled);
    case LocationState.unavailable:
      _showMessage(AppStrings.locationUnavailable);
    case LocationState.denied:
    case LocationState.unknown:
      _showMessage(AppStrings.locationDenied);
  }
}

void _showMessage(String key) {
  Get.snackbar(
    AppStrings.myLocation.tr,
    key.tr,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(Dimentions.spaces16),
    duration: const Duration(seconds: 4),
  );
}

Future<void> _showSettingsDialog(
  BuildContext context,
  HomeController ctrl,
) async {
  final shouldOpen = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(AppStrings.locationPermissionTitle.tr),
      content: Text(AppStrings.locationPermissionMessage.tr),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(AppStrings.cancel.tr),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(AppStrings.openAppSettings.tr),
        ),
      ],
    ),
  );

  if (shouldOpen ?? false) {
    await openAppSettings();
    if (ctrl.locationState.value == LocationState.permanentlyDenied) {
      await ctrl.refreshUserLocation();
    }
  }
}
