import 'package:flutter/material.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';

class DetailInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final Color? valueColor;

  /// اکشن اختیاری انتهای ردیف (مثل دکمه‌ی رونوشت شماره).
  final Widget? trailing;

  const DetailInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.valueColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimentions.spaces8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: PrimaryColors.p50,
              borderRadius: BorderRadius.circular(Dimentions.radius8),
            ),
            child: Icon(
              icon,
              color: PrimaryColors.primary,
              size: Dimentions.icon20,
            ),
          ),
          const SizedBox(width: Dimentions.spaces12),

          // Label + value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: OtherColors.textgreyLightColor,
                  ),
                ),
                const SizedBox(height: Dimentions.spaces2),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: valueColor ?? OtherColors.textLightColor,
                      fontWeight: FontWeight.w500,
                      decoration: onTap != null
                          ? TextDecoration.underline
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
