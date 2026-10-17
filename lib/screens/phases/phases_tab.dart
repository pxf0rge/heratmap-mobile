import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:heratmap/core/locale_format.dart';
import 'package:heratmap/data/models/phase_model.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/routes/app_routes.dart';
import 'package:heratmap/screens/phases/controller/phases_controller.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';
import 'package:heratmap/widgets/app_ui.dart';
import 'package:heratmap/widgets/data_status_banner.dart';
import 'package:heratmap/widgets/skeleton.dart';

class PhasesTab extends StatelessWidget {
  const PhasesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PhasesController>();

    return Scaffold(
      body: Column(
        children: [
          AppPageHeader(
            title: AppStrings.phases.tr,
            icon: Icons.grid_view_rounded,
          ),
          Expanded(
            child: Obx(() {
              final phases = ctrl.phases;

              if (ctrl.isLoading.value && phases.isEmpty) {
                return const PhaseGridSkeleton();
              }

              if (ctrl.hasError && phases.isEmpty) {
                return AppEmptyState(
                  icon: Icons.wifi_off_rounded,
                  message: ctrl.errorText ?? '',
                  actionLabel: AppStrings.retry.tr,
                  onAction: ctrl.reload,
                );
              }

              if (phases.isEmpty) {
                return AppEmptyState(
                  icon: Icons.grid_view_rounded,
                  message: AppStrings.noPhasesFound.tr,
                  hint: AppStrings.noPhasesFoundHint.tr,
                  actionLabel: AppStrings.refresh.tr,
                  onAction: ctrl.reload,
                );
              }

              return Column(
                children: [
                  if (ctrl.isFromCache)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: Dimentions.spaces16,
                        right: Dimentions.spaces16,
                        top: Dimentions.spaces12,
                      ),
                      child: DataStatusBanner(
                        source: ctrl.dataSource.value,
                        fetchedAt: ctrl.lastUpdatedAt.value,
                        onRefresh: ctrl.reload,
                      ),
                    ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: ctrl.reload,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(Dimentions.spaces16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: Dimentions.spaces12,
                          mainAxisSpacing: Dimentions.spaces12,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: phases.length,
                        itemBuilder: (_, i) => _PhaseCard(phase: phases[i]),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PhaseCard extends StatelessWidget {
  final PhaseModel phase;
  const _PhaseCard({required this.phase});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ctrl = Get.find<PhasesController>();
    final primary = theme.colorScheme.primary;

    return Material(
      color: AppSurfaces.card(context),
      borderRadius: BorderRadius.circular(Dimentions.radius16),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.phaseFactories, arguments: phase),
        borderRadius: BorderRadius.circular(Dimentions.radius16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimentions.radius16),
            border: Border.all(color: AppSurfaces.border(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(Dimentions.radius16),
                  ),
                  child: phase.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: phase.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppSurfaces.primarySoft(context),
                            child: Icon(
                              Icons.image_outlined,
                              color: primary.withValues(alpha: 0.35),
                              size: 36,
                            ),
                          ),
                          errorWidget: (_, __, ___) =>
                              _PlaceholderImage(number: phase.number),
                        )
                      : _PlaceholderImage(number: phase.number),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Dimentions.spaces12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phase.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (phase.area.isNotEmpty) ...[
                      const SizedBox(height: Dimentions.spaces4),
                      Text(
                        phase.area,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: Dimentions.spaces4),
                    Obx(() {
                      final count = ctrl.countFor(phase.name);
                      return Text(
                        count > 0
                            ? AppStrings.phaseCompanyCount.trParams({
                                'n': formatInteger(count),
                              })
                            : AppStrings.viewCompanies.tr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppSurfaces.muted(context),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final int number;
  const _PlaceholderImage({required this.number});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      color: AppSurfaces.primarySoft(context),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.factory_rounded,
              color: primary.withValues(alpha: 0.45),
              size: 36,
            ),
            const SizedBox(height: Dimentions.spaces4),
            Text(
              '${AppStrings.phase.tr} $number',
              style: TextStyle(
                fontSize: 13,
                color: primary.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
