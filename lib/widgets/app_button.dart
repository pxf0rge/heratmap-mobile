import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';

enum ButtonModeEnum { primary, secondary, outlined, link }

class AppButton extends StatelessWidget {
  final VoidCallback onTap;
  final String? title;
  final double containerHeight;
  final double? containerWidth;

  final Color? backgroundColor;
  final Color? splashColor;
  final Color? textColor;
  final Color? borderColor;
  final Color? loadingColor;
  final Color? disabledBackgroundColor;
  final Color? disabledTextColor;
  final Color? disabledBorderColor;

  final Widget? iconWidget;
  final Widget? disabledIconWidget;
  final bool? isLoading;
  final bool? enable;
  final TextDirection? textDirection;
  final ButtonModeEnum? buttonMode;
  final TextStyle? titleStyle;
  final double? borderRadius;
  final double? borderWidth;
  final EdgeInsets? padding;
  final double? loadingSize;
  final double? iconSpacing;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;

  const AppButton({
    super.key,
    this.title,
    required this.onTap,
    this.containerHeight = 48,
    this.backgroundColor,
    this.splashColor,
    this.textColor,
    this.borderColor,
    this.loadingColor,
    this.disabledBackgroundColor,
    this.disabledTextColor,
    this.disabledBorderColor,
    this.iconWidget,
    this.disabledIconWidget,
    this.isLoading = false,
    this.enable = true,
    this.textDirection,
    this.buttonMode = ButtonModeEnum.primary,
    this.titleStyle,
    this.containerWidth,
    this.borderRadius = 14,
    this.borderWidth = 1,
    this.padding,
    this.loadingSize = 26,
    this.iconSpacing = Dimentions.spaces8,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final modeColors = _getModeColors();
    final isEnabled = enable == true;

    final effectiveBackgroundColor = isEnabled
        ? modeColors.backgroundColor
        : (disabledBackgroundColor ?? modeColors.disabledBackgroundColor);

    final effectiveTextColor = isEnabled
        ? (textColor ?? modeColors.textColor)
        : (disabledTextColor ?? modeColors.disabledTextColor);

    final effectiveBorderColor = isEnabled
        ? (borderColor ?? modeColors.borderColor)
        : (disabledBorderColor ?? modeColors.disabledBorderColor);

    final effectiveSplashColor = splashColor ?? modeColors.splashColor;
    final effectiveLoadingColor = loadingColor ?? modeColors.loadingColor;

    final defaultTextStyle = Theme.of(context).textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.w600,
      color: effectiveTextColor,
    );

    final showBorder = buttonMode == ButtonModeEnum.outlined && isEnabled;
    final effectiveIcon = isEnabled ? iconWidget : (disabledIconWidget ?? iconWidget);

    return InkWell(
      onTap: isEnabled ? onTap : null,
      highlightColor: effectiveSplashColor,
      focusColor: effectiveSplashColor,
      hoverColor: effectiveSplashColor,
      splashColor: effectiveSplashColor,
      radius: 0,
      borderRadius: BorderRadius.circular(borderRadius ?? 14),
      enableFeedback: true,
      child: Ink(
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: BorderRadius.circular(borderRadius ?? 14),
        ),
        child: AnimatedContainer(
          width: containerWidth,
          duration: const Duration(milliseconds: 200),
          height: containerHeight,
          padding: padding,
          decoration: BoxDecoration(
            border: showBorder
                ? Border.all(
                    color: effectiveBorderColor,
                    width: borderWidth ?? 1,
                  )
                : null,
            borderRadius: BorderRadius.circular(borderRadius ?? 14),
          ),
          child: isLoading == true
              ? Center(
                  child: LoadingAnimationWidget.waveDots(
                    color: effectiveLoadingColor,
                    size: loadingSize ?? 26,
                  ),
                )
              : Directionality(
                  textDirection: textDirection ?? Directionality.of(context),
                  child: Row(
                    mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
                    crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
                    children: [
                      if (effectiveIcon != null) effectiveIcon,
                      if (title != null && effectiveIcon != null)
                        SizedBox(width: iconSpacing),
                      if (title != null)
                        Flexible(
                          child: Text(
                            textAlign: TextAlign.center,
                            title!,
                            style: titleStyle ?? defaultTextStyle,
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  _ModeColors _getModeColors() {
    switch (buttonMode) {
      case ButtonModeEnum.secondary:
        return _ModeColors(
          backgroundColor: backgroundColor ?? PrimaryColors.p50,
          textColor: textColor ?? PrimaryColors.p800,
          splashColor: splashColor ?? PrimaryColors.p100,
          borderColor: borderColor ?? Colors.transparent,
          loadingColor: loadingColor ?? PrimaryColors.p800,
          disabledBackgroundColor: disabledBackgroundColor ?? NeutralColors.n100,
          disabledTextColor: disabledTextColor ?? NeutralColors.n400,
          disabledBorderColor: disabledBorderColor ?? Colors.transparent,
        );

      case ButtonModeEnum.outlined:
        return _ModeColors(
          backgroundColor: backgroundColor ?? Colors.transparent,
          textColor: textColor ?? PrimaryColors.primary,
          splashColor: splashColor ?? PrimaryColors.p50,
          borderColor: borderColor ?? PrimaryColors.p200,
          loadingColor: loadingColor ?? PrimaryColors.primary,
          disabledBackgroundColor: disabledBackgroundColor ?? Colors.transparent,
          disabledTextColor: disabledTextColor ?? NeutralColors.n400,
          disabledBorderColor: disabledBorderColor ?? NeutralColors.n300,
        );

      case ButtonModeEnum.link:
        return _ModeColors(
          backgroundColor: backgroundColor ?? Colors.transparent,
          textColor: textColor ?? PrimaryColors.primary,
          splashColor: splashColor ?? Colors.transparent,
          borderColor: borderColor ?? Colors.transparent,
          loadingColor: loadingColor ?? PrimaryColors.primary,
          disabledBackgroundColor: disabledBackgroundColor ?? Colors.transparent,
          disabledTextColor: disabledTextColor ?? NeutralColors.n400,
          disabledBorderColor: disabledBorderColor ?? Colors.transparent,
        );

      case ButtonModeEnum.primary:
      default:
        return _ModeColors(
          backgroundColor: backgroundColor ?? PrimaryColors.primary,
          textColor: textColor ?? Colors.white,
          splashColor: splashColor ?? PrimaryColors.p700,
          borderColor: borderColor ?? Colors.transparent,
          loadingColor: loadingColor ?? Colors.white,
          disabledBackgroundColor: disabledBackgroundColor ?? NeutralColors.n200,
          disabledTextColor: disabledTextColor ?? NeutralColors.n400,
          disabledBorderColor: disabledBorderColor ?? Colors.transparent,
        );
    }
  }
}

class _ModeColors {
  final Color backgroundColor;
  final Color textColor;
  final Color splashColor;
  final Color borderColor;
  final Color loadingColor;
  final Color disabledBackgroundColor;
  final Color disabledTextColor;
  final Color disabledBorderColor;

  _ModeColors({
    required this.backgroundColor,
    required this.textColor,
    required this.splashColor,
    required this.borderColor,
    required this.loadingColor,
    required this.disabledBackgroundColor,
    required this.disabledTextColor,
    required this.disabledBorderColor,
  });
}
