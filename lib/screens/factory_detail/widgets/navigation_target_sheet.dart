import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/screens/factory_detail/controller/factory_detail_controller.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';

/// انتخاب مقصد مسیریابی.
///
/// کاربر افغانی معمولاً گوگل‌مپ دارد، ولی اگر نداشته باشد باید بتواند همین
/// شرکت را داخل نقشه‌ی خودِ اپ ببیند — به‌جای خطای «اپی پیدا نشد».
Future<NavigationTarget?> showNavigationTargetSheet(BuildContext context) {
  return showModalBottomSheet<NavigationTarget>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(Dimentions.radius20),
      ),
    ),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimentions.spaces20,
              vertical: Dimentions.spaces16,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.navigation_rounded,
                  color: PrimaryColors.primary,
                  size: Dimentions.icon20,
                ),
                const SizedBox(width: Dimentions.spaces8),
                Text(
                  AppStrings.navigateWith.tr,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(
              Icons.map_rounded,
              color: PrimaryColors.primary,
            ),
            title: Text(AppStrings.openInGoogleMaps.tr),
            onTap: () => Navigator.of(context).pop(NavigationTarget.googleMaps),
          ),
          ListTile(
            leading: const Icon(
              Icons.my_location_rounded,
              color: PrimaryColors.primary,
            ),
            title: Text(AppStrings.openInAppMap.tr),
            onTap: () => Navigator.of(context).pop(NavigationTarget.inAppMap),
          ),
          const Divider(height: 1),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.cancel.tr),
          ),
          const SizedBox(height: Dimentions.spaces8),
        ],
      ),
    ),
  );
}
