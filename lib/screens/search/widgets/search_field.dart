import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/screens/search/controller/search_controller.dart'
    as app;
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';

/// فیلد جستجو با دکمه‌ی پاک‌کردن و دکمه‌ی جستجوی کیبورد.
class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.ctrl});

  final app.SearchController ctrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimentions.spaces16),
      child: Container(
        decoration: BoxDecoration(
          color: AppSurfaces.card(context),
          borderRadius: BorderRadius.circular(Dimentions.radius14),
          border: Border.all(color: AppSurfaces.border(context)),
        ),
        child: TextField(
          controller: ctrl.textController,
          focusNode: ctrl.focusNode,
          textInputAction: TextInputAction.search,
          onChanged: ctrl.onQueryInput,
          onSubmitted: ctrl.onQuerySubmitted,
          onTapOutside: (_) => ctrl.focusNode.unfocus(),
          decoration: InputDecoration(
            hintText: AppStrings.searchHint.tr,
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppSurfaces.muted(context),
              size: Dimentions.icon20,
            ),
            suffixIcon: Obx(
              () => ctrl.query.value.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      tooltip: AppStrings.clearSearchField.tr,
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.close_rounded,
                        size: Dimentions.icon20,
                        color: AppSurfaces.muted(context),
                      ),
                      onPressed: ctrl.clearQuery,
                    ),
            ),
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: Dimentions.spaces14,
              horizontal: Dimentions.spaces16,
            ),
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: NeutralColors.n400,
            ),
          ),
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}
