import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/screens/search/controller/search_controller.dart'
    as app;
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';
import 'package:heratmap/widgets/app_ui.dart';

/// حالت‌های خالی/خطای تب جستجو.
class SearchNoResultsView extends StatelessWidget {
  const SearchNoResultsView({super.key, required this.ctrl});

  final app.SearchController ctrl;

  @override
  Widget build(BuildContext context) {
    final query = ctrl.query.value.trim();

    return AppEmptyState(
      icon: Icons.search_off_rounded,
      message: ctrl.hasQuery
          ? AppStrings.searchNoResultsFor.trParams({'q': query})
          : AppStrings.noCompaniesFound.tr,
      hint: AppStrings.searchSuggestOther.tr,
      actionLabel: AppStrings.clearFilters.tr,
      onAction: ctrl.clearFilters,
    );
  }
}

/// خطای شبکه/سرور بدون داده‌ی قابل نمایش.
class SearchErrorView extends StatelessWidget {
  const SearchErrorView({super.key, required this.ctrl});

  final app.SearchController ctrl;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.wifi_off_rounded,
      message: ctrl.errorText ?? AppStrings.actionFailed.tr,
      actionLabel: AppStrings.retry.tr,
      onAction: ctrl.retry,
    );
  }
}

class SearchInlineNotice extends StatelessWidget {
  const SearchInlineNotice({
    super.key,
    required this.text,
    this.onRetry,
  });

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimentions.spaces8),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimentions.spaces12,
        vertical: Dimentions.spaces8,
      ),
      decoration: BoxDecoration(
        color: StatusColors.yellowLight.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(Dimentions.radius12),
        border: Border.all(
          color: StatusColors.yellow.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
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
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppSurfaces.muted(context),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(AppStrings.retry.tr),
            ),
        ],
      ),
    );
  }
}
