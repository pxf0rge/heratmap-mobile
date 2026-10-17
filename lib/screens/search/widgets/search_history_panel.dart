import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/screens/search/controller/search_controller.dart'
    as app;
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';

/// پنل «جستجوهای اخیر».
///
/// وقتی فیلد جستجو فوکوس دارد و عبارت خالی است نشان داده می‌شود؛ با لمس هر
/// ردیف همان جستجو دوباره اجرا می‌شود و با آیکن حذف، آن ردیف پاک می‌شود.
class SearchHistoryPanel extends StatelessWidget {
  const SearchHistoryPanel({super.key, required this.ctrl});

  final app.SearchController ctrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final items = ctrl.history;
      if (items.isEmpty) return const SizedBox.shrink();

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimentions.spaces16,
              vertical: Dimentions.spaces4,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.history_rounded,
                  size: Dimentions.icon20,
                  color: NeutralColors.n400,
                ),
                const SizedBox(width: Dimentions.spaces8),
                Expanded(
                  child: Text(
                    AppStrings.searchHistory.tr,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: NeutralColors.n500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: ctrl.clearHistory,
                  child: Text(AppStrings.clearHistory.tr),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(
                horizontal: Dimentions.spaces8,
              ),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 48),
              itemBuilder: (_, i) {
                final value = items[i];
                return InkWell(
                  onTap: () => ctrl.applyHistory(value),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimentions.spaces4,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: Dimentions.spaces8),
                        const Icon(
                          Icons.history_rounded,
                          size: 18,
                          color: NeutralColors.n300,
                        ),
                        const SizedBox(width: Dimentions.spaces12),
                        Expanded(
                          child: Text(
                            value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        IconButton(
                          tooltip: AppStrings.removeItem.tr,
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: NeutralColors.n400,
                          ),
                          onPressed: () => ctrl.removeHistoryItem(value),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
