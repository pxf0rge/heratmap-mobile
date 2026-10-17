import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/screens/home/controller/home_controller.dart';
import 'package:heratmap/screens/search/controller/search_controller.dart'
    as app;
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';
import 'package:heratmap/widgets/app_ui.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Get.find<HomeController>().changeTab(1);
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => Get.find<app.SearchController>().focusNode.requestFocus(),
        );
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppSurfaces.card(context),
          borderRadius: BorderRadius.circular(Dimentions.radius16),
          border: Border.all(color: AppSurfaces.border(context)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimentions.spaces12),
        child: Row(
          children: [
            AppIconBox(
              icon: Icons.search_rounded,
              size: 36,
              iconSize: 18,
            ),
            const SizedBox(width: Dimentions.spaces12),
            Expanded(
              child: Text(
                AppStrings.searchHint.tr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: NeutralColors.n400,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(Dimentions.spaces6),
              decoration: BoxDecoration(
                color: AppSurfaces.softFill(context),
                borderRadius: BorderRadius.circular(Dimentions.radius8),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: AppSurfaces.muted(context),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
