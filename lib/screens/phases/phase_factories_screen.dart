import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/routes/app_routes.dart';
import 'package:heratmap/screens/phases/controller/phase_factories_controller.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';
import 'package:heratmap/widgets/app_ui.dart';
import 'package:heratmap/widgets/data_status_banner.dart';
import 'package:heratmap/widgets/skeleton.dart';

class PhaseFactoriesScreen extends StatelessWidget {
  const PhaseFactoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PhaseFactoriesController>();
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      body: Column(
        children: [
          AppPageHeader(
            title: ctrl.phase.name,
            showBack: true,
            onBack: () => Get.back(),
          ),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value && ctrl.factories.isEmpty) {
                return const FactoryListSkeleton(items: 5);
              }

              if (ctrl.hasError && ctrl.factories.isEmpty) {
                return AppEmptyState(
                  icon: Icons.wifi_off_rounded,
                  message: ctrl.errorText ?? '',
                  actionLabel: AppStrings.retry.tr,
                  onAction: ctrl.retry,
                );
              }

              if (ctrl.factories.isEmpty) {
                return AppEmptyState(
                  icon: Icons.factory_outlined,
                  message: AppStrings.noCompaniesFound.tr,
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
                        onRefresh: ctrl.retry,
                      ),
                    ),
                  if (ctrl.phase.description.isNotEmpty ||
                      ctrl.phase.area.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Dimentions.spaces16,
                        Dimentions.spaces12,
                        Dimentions.spaces16,
                        0,
                      ),
                      child: AppSurfaceCard(
                        padding: const EdgeInsets.all(Dimentions.spaces12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (ctrl.phase.area.isNotEmpty)
                              Row(
                                children: [
                                  Icon(
                                    Icons.straighten_rounded,
                                    size: 14,
                                    color: primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    ctrl.phase.area,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            if (ctrl.phase.area.isNotEmpty &&
                                ctrl.phase.description.isNotEmpty)
                              const SizedBox(height: 6),
                            if (ctrl.phase.description.isNotEmpty)
                              Text(
                                ctrl.phase.description,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppSurfaces.muted(context),
                                  height: 1.6,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(child: _FactoryList(ctrl: ctrl)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FactoryList extends StatelessWidget {
  const _FactoryList({required this.ctrl});

  final PhaseFactoriesController ctrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return ListView.separated(
      padding: const EdgeInsets.all(Dimentions.spaces16),
      itemCount: ctrl.factories.length,
      separatorBuilder: (_, __) => const SizedBox(height: Dimentions.spaces8),
      itemBuilder: (_, i) {
        final f = ctrl.factories[i];
        return AppSurfaceCard(
          onTap: () => Get.toNamed(AppRoutes.factoryDetail, arguments: f),
          padding: const EdgeInsets.all(Dimentions.spaces12),
          child: Row(
            children: [
              AppIconBox(icon: Icons.factory_rounded),
              const SizedBox(width: Dimentions.spaces12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (f.category.isNotEmpty)
                      Text(
                        f.category,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (f.address.isNotEmpty)
                      Text(
                        f.address,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: NeutralColors.n300,
              ),
            ],
          ),
        );
      },
    );
  }
}
