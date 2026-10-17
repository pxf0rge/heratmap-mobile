import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heratmap/data/models/factory_model.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/routes/app_routes.dart';
import 'package:heratmap/screens/home/controller/home_controller.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';
import 'package:heratmap/widgets/data_status_banner.dart';
import 'package:latlong2/latlong.dart';

class HomeBottomSheet extends StatelessWidget {
  const HomeBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();

    return DraggableScrollableSheet(
      controller: ctrl.sheetController,
      initialChildSize: 0.32,
      minChildSize: 0.18,
      maxChildSize: 0.85,
      snap: true,
      snapSizes: const [0.18, 0.32, 0.85],
      builder: (context, scrollController) {
        final surface = AppSurfaces.card(context);
        final border = AppSurfaces.border(context);

        return Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            border: Border(top: BorderSide(color: border)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppSurfaces.border(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Obx(() {
                  if (ctrl.isLoading.value) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: PrimaryColors.primary,
                            ),
                          ),
                          const SizedBox(height: Dimentions.spaces12),
                          Text(
                            AppStrings.loading.tr,
                            style: const TextStyle(
                              fontSize: 13,
                              color: NeutralColors.n400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (ctrl.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: NeutralColors.n100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.wifi_off_rounded,
                              size: 28,
                              color: NeutralColors.n400,
                            ),
                          ),
                          const SizedBox(height: Dimentions.spaces12),
                          Text(
                            ctrl.errorText ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: NeutralColors.n500,
                            ),
                          ),
                          const SizedBox(height: Dimentions.spaces12),
                          FilledButton.tonal(
                            onPressed: ctrl.reload,
                            child: Text(AppStrings.retry.tr),
                          ),
                        ],
                      ),
                    );
                  }

                  if (ctrl.factories.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: PrimaryColors.p50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.factory_outlined,
                              size: 28,
                              color: PrimaryColors.p300,
                            ),
                          ),
                          const SizedBox(height: Dimentions.spaces12),
                          Text(
                            AppStrings.noCompaniesFound.tr,
                            style: const TextStyle(
                              fontSize: 13,
                              color: NeutralColors.n500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final selected = ctrl.selectedFactory.value;

                  return ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimentions.spaces16,
                      vertical: Dimentions.spaces8,
                    ),
                    children: [
                      DataStatusBanner(
                        source: ctrl.dataSource.value,
                        fetchedAt: ctrl.lastUpdatedAt.value,
                        onRefresh: ctrl.reload,
                      ),
                      if (selected != null) ...[
                        _SelectedFactoryCard(factory: selected, ctrl: ctrl),
                        const SizedBox(height: Dimentions.spaces8),
                      ],
                      _SheetHeader(ctrl: ctrl),
                      const SizedBox(height: Dimentions.spaces4),
                      ...ctrl.nearestFactories.map(
                        (f) => _FactoryTile(factory: f, ctrl: ctrl),
                      ),
                      const SizedBox(height: Dimentions.spaces16),
                    ],
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SelectedFactoryCard extends StatelessWidget {
  final FactoryModel factory;
  final HomeController ctrl;
  const _SelectedFactoryCard({required this.factory, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasLocation = ctrl.userLocation.value != null;
    final timeText = hasLocation ? ctrl.estimatedArrivalTime(factory) : null;

    final primary = theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(top: Dimentions.spaces4),
      decoration: BoxDecoration(
        color: AppSurfaces.primarySoft(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PrimaryColors.p200.withValues(alpha: 0.7)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.toNamed(AppRoutes.factoryDetail, arguments: factory),
          child: Padding(
            padding: const EdgeInsets.all(Dimentions.spaces12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Chip(
                      label: factory.phase.isNotEmpty
                          ? factory.phase
                          : AppStrings.phase.tr,
                      color: PrimaryColors.primary,
                      icon: Icons.layers_rounded,
                    ),
                    if (factory.lotNumber.isNotEmpty) ...[
                      const SizedBox(width: Dimentions.spaces6),
                      _Chip(
                        label: factory.lotNumber,
                        color: SecondaryColors.primary,
                        icon: Icons.pin_outlined,
                      ),
                    ],
                    if (hasLocation) ...[
                      const SizedBox(width: Dimentions.spaces6),
                      _Chip(
                        label: ctrl.formattedDistance(factory),
                        color: SecondaryColors.p700,
                        icon: Icons.near_me_rounded,
                      ),
                      if (timeText != null) ...[
                        const SizedBox(width: Dimentions.spaces6),
                      _Chip(
                        label: timeText,
                        color: SecondaryColors.p700,
                        icon: Icons.access_time_rounded,
                      ),
                      ],
                    ],
                    const Spacer(),
                    InkWell(
                      onTap: ctrl.clearSelection,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: NeutralColors.n500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimentions.spaces8),
                Row(
                  children: [
                    if (factory.imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          factory.imageUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: PrimaryColors.p50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.factory_rounded,
                              color: PrimaryColors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: PrimaryColors.p50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.factory_rounded,
                          color: PrimaryColors.primary,
                          size: 20,
                        ),
                      ),
                    const SizedBox(width: Dimentions.spaces10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  factory.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!factory.isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: StatusColors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    AppStrings.inactive.tr,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: StatusColors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (factory.category.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: Dimentions.spaces2),
                              child: Text(
                                factory.category,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: PrimaryColors.p700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (factory.address.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: Dimentions.spaces2),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: NeutralColors.n400,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            factory.address,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: Dimentions.spaces12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Get.toNamed(
                          AppRoutes.factoryDetail,
                          arguments: factory,
                        ),
                        icon: const Icon(Icons.info_outline_rounded, size: 18),
                        label: Text(AppStrings.details.tr),
                        style: FilledButton.styleFrom(
                          backgroundColor: primary,
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimentions.spaces8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => ctrl.moveCamera(
                          factory.hasValidLocation
                              ? LatLng(factory.lat, factory.lon)
                              : ctrl.initialCenter,
                          17,
                        ),
                        icon: const Icon(
                          Icons.center_focus_strong_rounded,
                          size: 18,
                        ),
                        label: Text(AppStrings.showOnMap.tr),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(44),
                          foregroundColor: primary,
                          side: BorderSide(
                            color: PrimaryColors.p200.withValues(alpha: 0.8),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const _Chip({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final HomeController ctrl;
  const _SheetHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: PrimaryColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: Dimentions.spaces8),
            Text(
              AppStrings.nearestCompanies.tr,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () => ctrl.changeTab(1),
          child: Text(
            AppStrings.viewAll.tr,
            style: theme.textTheme.bodySmall?.copyWith(
              color: PrimaryColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _FactoryTile extends StatelessWidget {
  final FactoryModel factory;
  final HomeController ctrl;
  const _FactoryTile({required this.factory, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeText = ctrl.estimatedArrivalTime(factory);
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppSurfaces.softFill(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppSurfaces.border(context)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Get.toNamed(AppRoutes.factoryDetail, arguments: factory),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimentions.spaces12,
              vertical: Dimentions.spaces10,
            ),
            child: Row(
              children: [
                if (factory.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      factory.imageUrl,
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppSurfaces.primarySoft(context),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.factory_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppSurfaces.primarySoft(context),
                      borderRadius: BorderRadius.circular(10),
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              factory.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!factory.isActive)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: StatusColors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                AppStrings.inactive.tr,
                                style: TextStyle(
                                  fontSize: 8,
                                  color: StatusColors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      if (factory.lotNumber.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '${AppStrings.lotNumberLabel.tr}: ${factory.lotNumber}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: NeutralColors.n500,
                            ),
                          ),
                        ),
                      Text(
                        factory.address.isNotEmpty
                            ? factory.address
                            : factory.category,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Dimentions.spaces8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimentions.spaces8,
                        vertical: Dimentions.spaces4,
                      ),
                      decoration: BoxDecoration(
                        color: SecondaryColors.p50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ctrl.formattedDistance(factory),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: SecondaryColors.p800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (timeText != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        timeText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: NeutralColors.n400,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(width: Dimentions.spaces4),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: NeutralColors.n300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
