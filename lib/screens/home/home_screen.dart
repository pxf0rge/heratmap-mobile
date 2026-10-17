import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/screens/home/controller/home_controller.dart';
import 'package:heratmap/screens/home/widgets/home_map_tab.dart';
import 'package:heratmap/screens/news/news_tab.dart';
import 'package:heratmap/screens/phases/phases_tab.dart';
import 'package:heratmap/screens/search/search_tab.dart';
import 'package:heratmap/screens/settings/settings_tab.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    final internalTabs = [
      const HomeMapTab(),
      const SearchTab(),
      const PhasesTab(),
      const NewsTab(),
      const SettingsTab(),
    ];

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: internalTabs,
        ),
        bottomNavigationBar: _BottomNav(controller: controller),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final HomeController controller;
  const _BottomNav({required this.controller});

  @override
  Widget build(BuildContext context) {
    final surface = AppSurfaces.card(context);
    final border = AppSurfaces.border(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimentions.spaces8,
            vertical: Dimentions.spaces6,
          ),
          child: Obx(
            () => Row(
              children: [
                _NavItem(
                  icon: Icons.map_outlined,
                  activeIcon: Icons.map_rounded,
                  label: AppStrings.navMap.tr,
                  selected: controller.currentIndex.value == 0,
                  primary: primary,
                  onTap: () => controller.changeTab(0),
                ),
                _NavItem(
                  icon: Icons.search_rounded,
                  activeIcon: Icons.search_rounded,
                  label: AppStrings.navSearch.tr,
                  selected: controller.currentIndex.value == 1,
                  primary: primary,
                  onTap: () => controller.changeTab(1),
                ),
                _NavItem(
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view_rounded,
                  label: AppStrings.navPhases.tr,
                  selected: controller.currentIndex.value == 2,
                  primary: primary,
                  onTap: () => controller.changeTab(2),
                ),
                _NavItem(
                  icon: Icons.newspaper_outlined,
                  activeIcon: Icons.newspaper_rounded,
                  label: AppStrings.navNews.tr,
                  selected: controller.currentIndex.value == 3,
                  primary: primary,
                  onTap: () => controller.changeTab(3),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: AppStrings.navSettings.tr,
                  selected: controller.currentIndex.value == 4,
                  primary: primary,
                  onTap: () => controller.changeTab(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.primary,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final Color primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? primary : NeutralColors.n400;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimentions.radius12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimentions.spaces6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimentions.spaces12,
                  vertical: Dimentions.spaces4,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(Dimentions.radiusFull),
                ),
                child: Icon(
                  selected ? activeIcon : icon,
                  size: 22,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
