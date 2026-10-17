import 'package:flutter/material.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';

/// هدر یکپارچه برای تمام صفحات — سطح تم + خط جداکننده ملایم.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.showBack = false,
    this.onBack,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool showBack;
  final VoidCallback? onBack;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = AppSurfaces.card(context);
    final border = AppSurfaces.border(context);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border(bottom: BorderSide(color: border)),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: Dimentions.spaces16,
        right: Dimentions.spaces16,
        bottom: Dimentions.spaces14,
      ),
      child: Row(
        children: [
          if (showBack)
            _HeaderIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
            )
          else if (leading != null)
            leading!
          else if (icon != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppSurfaces.primarySoft(context),
                borderRadius: BorderRadius.circular(Dimentions.radius12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: Dimentions.spaces12),
          ],
          if (showBack) const SizedBox(width: Dimentions.spaces12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppSurfaces.muted(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppSurfaces.softFill(context),
      borderRadius: BorderRadius.circular(Dimentions.radius12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimentions.radius12),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: Theme.of(context).iconTheme.color),
        ),
      ),
    );
  }
}

/// کارت سطحی مینیمال با حاشیه نازک — بدون سایه سنگین.
class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius ?? Dimentions.radius16);

    final content = Container(
      width: double.infinity,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(Dimentions.spaces16),
      decoration: BoxDecoration(
        color: AppSurfaces.card(context),
        borderRadius: radius,
        border: Border.all(color: AppSurfaces.border(context)),
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: AppSurfaces.card(context),
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: AppSurfaces.border(context)),
            ),
            padding: padding ?? const EdgeInsets.all(Dimentions.spaces16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// جعبه آیکن یکدست برای لیست‌ها و تنظیمات.
class AppIconBox extends StatelessWidget {
  const AppIconBox({
    super.key,
    required this.icon,
    this.color,
    this.background,
    this.size = 40,
    this.iconSize = 20,
  });

  final IconData icon;
  final Color? color;
  final Color? background;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? AppSurfaces.primarySoft(context),
        borderRadius: BorderRadius.circular(Dimentions.radius12),
      ),
      child: Icon(icon, color: accent, size: iconSize),
    );
  }
}

/// وضعیت خالی/خطا با ظاهر یکسان در همه صفحات.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.hint,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? hint;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimentions.spaces24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppSurfaces.primarySoft(context),
                borderRadius: BorderRadius.circular(Dimentions.radius20),
              ),
              child: Icon(
                icon,
                size: 32,
                color: theme.colorScheme.primary.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: Dimentions.spaces16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppSurfaces.muted(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (hint != null) ...[
              const SizedBox(height: Dimentions.spaces6),
              Text(
                hint!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: NeutralColors.n400,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: Dimentions.spaces16),
              FilledButton.tonal(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// عنوان بخش برای تنظیمات و لیست‌ها.
class AppSectionLabel extends StatelessWidget {
  const AppSectionLabel(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: Dimentions.spaces4,
        bottom: Dimentions.spaces8,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppSurfaces.muted(context),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}
