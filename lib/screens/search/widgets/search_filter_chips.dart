import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heratmap/core/locale_format.dart';
import 'package:heratmap/data/cache/favorites_store.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/screens/phases/controller/phases_controller.dart';
import 'package:heratmap/screens/search/controller/search_controller.dart'
    as app;
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';
import 'package:heratmap/widgets/skeleton.dart';

/// چیپ‌های فیلتر فاز.
///
/// گزینه‌ها **فقط** از جدول `phases` می‌آیند (هیچ فاز جعلی‌ای ساخته نمی‌شود) و
/// تعداد شرکت‌های هر فاز از شمارش تجمیعی فاز ۲ روی چیپ نوشته می‌شود.
class SearchFilterChips extends StatelessWidget {
  final app.SearchController ctrl;
  const SearchFilterChips({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final phasesCtrl = Get.find<PhasesController>();
    final favorites = Get.isRegistered<FavoritesStore>()
        ? Get.find<FavoritesStore>()
        : null;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.only(
        top: Dimentions.spaces16,
        bottom: Dimentions.spaces8,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Dimentions.spaces16),
        child: Obx(() {
          final phases = phasesCtrl.phases;
          // داخل Obx خوانده می‌شود تا با تغییر فیلتر، چیپ انتخاب‌شده هم رندر شود
          final selected = ctrl.selectedPhaseName.value;
          final favoriteCount = favorites?.ids.length ?? 0;

          final showSkeleton = phases.isEmpty && phasesCtrl.isLoading.value;
          if (phases.isEmpty && favoriteCount == 0 && !showSkeleton) {
            return const SizedBox.shrink();
          }

          return Row(
            children: [
              // فیلتر نشان‌شده‌ها فقط وقتی چیزی نشان شده باشد معنا دارد
              if (favoriteCount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: Dimentions.spaces8),
                  child: _Chip(
                    label: AppStrings.favorites.tr,
                    count: favoriteCount,
                    icon: Icons.favorite_rounded,
                    selected: ctrl.showOnlyFavorites.value,
                    onTap: () => ctrl.setShowOnlyFavorites(
                      !ctrl.showOnlyFavorites.value,
                    ),
                  ),
                ),

              // تا وقتی فازها از سرور نرسیده‌اند، اسکلتون؛ اگر سرور فازی ندارد،
              // هیچ چیپ فازی ساخته نمی‌شود (فیلتر فاز بی‌معنا است).
              if (showSkeleton)
                const FilterChipsSkeleton()
              else if (phases.isNotEmpty) ...[
                _Chip(
                  label: AppStrings.all.tr,
                  count: phasesCtrl.countedTotal,
                  selected: selected == null,
                  onTap: () => ctrl.setPhaseName(null),
                ),
                for (final phase in phases)
                  Padding(
                    padding: const EdgeInsets.only(right: Dimentions.spaces8),
                    child: _Chip(
                      label: phase.name,
                      count: phasesCtrl.countFor(phase.name),
                      selected: selected == phase.name,
                      onTap: () => ctrl.setPhaseName(phase.name),
                    ),
                  ),
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  /// آیکن اختیاری ابتدای چیپ (برای فیلتر نشان‌شده‌ها).
  final IconData? icon;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count = 0,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimentions.spaces16,
          vertical: Dimentions.spaces6,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : AppSurfaces.card(context),
          borderRadius: BorderRadius.circular(Dimentions.radiusFull),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : AppSurfaces.border(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected ? Colors.white : StatusColors.red,
              ),
              const SizedBox(width: Dimentions.spaces4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected
                    ? Colors.white
                    : AppSurfaces.muted(context),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: Dimentions.spaces6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.22)
                      : AppSurfaces.softFill(context),
                  borderRadius: BorderRadius.circular(Dimentions.radiusFull),
                ),
                child: Text(
                  formatInteger(count),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : NeutralColors.n500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
