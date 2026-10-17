import 'package:flutter/material.dart';
import 'package:heratmap/core/working_hours.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';

/// نشانگر وضعیت باز/بسته بودن شرکت.
///
/// رنگ‌ها معنا دارند: سبز = باز، قرمز = بسته، طلایی = ساعت کاری نامشخص.
/// متن وضعیت از بیرون (ترجمه‌شده) می‌آید تا این ویجت بدون i18n بماند.
class WorkingStatusBadge extends StatelessWidget {
  const WorkingStatusBadge({
    super.key,
    required this.kind,
    required this.label,
    this.detail,
    this.semanticsLabel,
  });

  final OpenStatusKind kind;
  final String label;

  /// «تا ساعت 19:00» یا «از ساعت 07:00 باز می‌شود».
  final String? detail;

  /// برچسب ترکیبی برای صفحه‌خوان (ترجمه‌شده، از بیرون).
  /// اگر ندهند، فقط [label] خوانده می‌شود تا متن ناقص اعلام نشود.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (background, foreground, icon) = switch (kind) {
      OpenStatusKind.open => (
        StatusColors.greenLight,
        StatusColors.green,
        Icons.check_circle_rounded,
      ),
      OpenStatusKind.closed => (
        StatusColors.redLight,
        StatusColors.red,
        Icons.cancel_rounded,
      ),
      OpenStatusKind.unknown => (
        StatusColors.yellowLight,
        StatusColors.yellow,
        Icons.schedule_rounded,
      ),
    };

    return Semantics(
      label: semanticsLabel ?? label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimentions.spaces8,
              vertical: Dimentions.spaces4,
            ),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(Dimentions.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: Dimentions.icon16, color: foreground),
                const SizedBox(width: Dimentions.spaces4),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (detail != null) ...[
            const SizedBox(width: Dimentions.spaces8),
            Flexible(
              child: Text(
                detail!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: OtherColors.textgreyLightColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
