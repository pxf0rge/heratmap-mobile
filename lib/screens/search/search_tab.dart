import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heratmap/core/locale_format.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/routes/app_routes.dart';
import 'package:heratmap/screens/phases/controller/phases_controller.dart';
import 'package:heratmap/screens/search/controller/search_controller.dart'
    as app;
import 'package:heratmap/screens/search/widgets/search_field.dart';
import 'package:heratmap/screens/search/widgets/search_filter_chips.dart';
import 'package:heratmap/screens/search/widgets/search_history_panel.dart';
import 'package:heratmap/screens/search/widgets/search_result_tile.dart';
import 'package:heratmap/screens/search/widgets/search_states.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';
import 'package:heratmap/widgets/app_ui.dart';
import 'package:heratmap/widgets/data_status_banner.dart';
import 'package:heratmap/widgets/skeleton.dart';

class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<app.SearchController>();
    final phasesCtrl = Get.find<PhasesController>();

    return Scaffold(
      body: Column(
        children: [
          AppPageHeader(
            title: AppStrings.search.tr,
            icon: Icons.search_rounded,
          ),
          const SizedBox(height: Dimentions.spaces16),
          SearchField(ctrl: ctrl),
          SearchFilterChips(ctrl: ctrl),
          Expanded(
            child: Obx(() {
              if (ctrl.isInitialLoading) return const FactoryListSkeleton();

              if (ctrl.isHistoryVisible.value) {
                return SearchHistoryPanel(ctrl: ctrl);
              }

              if (ctrl.hasError && ctrl.results.isEmpty) {
                return SearchErrorView(ctrl: ctrl);
              }

              if (ctrl.results.isEmpty) {
                return ctrl.hasActiveFilter
                    ? SearchNoResultsView(ctrl: ctrl)
                    : _EmptyDatasetView(ctrl: ctrl);
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimentions.spaces16,
                    ),
                    child: Column(
                      children: [
                        if (ctrl.isFromCache)
                          DataStatusBanner(
                            source: ctrl.dataSource.value,
                            fetchedAt: ctrl.lastUpdatedAt.value,
                            onRefresh: ctrl.retry,
                          ),
                        if (ctrl.serverSearchBlocked.value)
                          SearchInlineNotice(
                            text: AppStrings.serverSearchUnavailable.tr,
                            onRetry: ctrl.retry,
                          ),
                      ],
                    ),
                  ),
                  if (ctrl.isSearching.value)
                    LinearProgressIndicator(
                      minHeight: 2,
                      color: Theme.of(context).colorScheme.primary,
                      backgroundColor: Colors.transparent,
                    ),
                  _ResultCount(count: ctrl.results.length),
                  Expanded(
                    child: ListView.separated(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimentions.spaces16,
                        vertical: Dimentions.spaces4,
                      ),
                      itemCount: ctrl.results.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: Dimentions.spaces8),
                      itemBuilder: (_, i) {
                        final factory = ctrl.results[i];
                        return SearchResultTile(
                          factory: factory,
                          phaseName: phasesCtrl.labelFor(factory.phase),
                          onTap: () {
                            ctrl.rememberQuery();
                            Get.toNamed(
                              AppRoutes.factoryDetail,
                              arguments: factory,
                            );
                          },
                        );
                      },
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

class _ResultCount extends StatelessWidget {
  const _ResultCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimentions.spaces16,
        Dimentions.spaces4,
        Dimentions.spaces16,
        Dimentions.spaces4,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          AppStrings.searchResultCount.trParams({'n': formatInteger(count)}),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppSurfaces.muted(context),
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _EmptyDatasetView extends StatelessWidget {
  const _EmptyDatasetView({required this.ctrl});

  final app.SearchController ctrl;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.factory_outlined,
      message: AppStrings.noCompaniesFound.tr,
      actionLabel: AppStrings.refresh.tr,
      onAction: ctrl.retry,
    );
  }
}
