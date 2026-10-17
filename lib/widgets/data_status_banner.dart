import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heratmap/core/time_utils.dart';
import 'package:heratmap/data/result.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';

/// نوار وضعیت داده.
///
/// وقتی داده از حافظه‌ی محلی نمایش داده می‌شود (اینترنت ضعیف/آفلاین) کاربر باید
/// بداند داده «ذخیره‌شده» است، چه‌قدر قدیمی است و بتواند تازه‌سازی کند.
/// در حالت داده‌ی زنده‌ی شبکه، این ویجت هیچ چیزی نشان نمی‌دهد.
class DataStatusBanner extends StatelessWidget {
  const DataStatusBanner({
    super.key,
    required this.source,
    this.fetchedAt,
    this.onRefresh,
    this.compact = false,
  });

  final DataSource? source;
  final DateTime? fetchedAt;
  final Future<void> Function()? onRefresh;

  /// حالت فشرده (بدون دکمه‌ی تازه‌سازی) برای فضاهای تنگ.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (source != DataSource.cache) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final textStyle = theme.textTheme.labelSmall?.copyWith(
      color: OtherColors.textgreyLightColor,
      fontWeight: FontWeight.w500,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: Dimentions.spaces8),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimentions.spaces12,
        vertical: Dimentions.spaces8,
      ),
      decoration: BoxDecoration(
        color: StatusColors.yellowLight.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(Dimentions.radius12),
        border: Border.all(color: StatusColors.yellow.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: Dimentions.icon20,
            color: StatusColors.yellow,
          ),
          const SizedBox(width: Dimentions.spaces8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.fromCache.tr,
                  style: textStyle?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (fetchedAt != null)
                  Text(
                    '${AppStrings.lastUpdated.tr}: '
                    '${relativeTimeText(fetchedAt!)}',
                    style: textStyle,
                  ),
              ],
            ),
          ),
          if (!compact && onRefresh != null)
            IconButton(
              onPressed: () => onRefresh!(),
              tooltip: AppStrings.refresh.tr,
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.refresh_rounded,
                size: Dimentions.icon20,
                color: StatusColors.yellow,
              ),
            ),
        ],
      ),
    );
  }
}
