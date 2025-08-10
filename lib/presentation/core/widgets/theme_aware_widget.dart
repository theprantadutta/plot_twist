import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/settings/appearance_provider.dart';
import '../app_colors.dart';

/// A widget that automatically adapts to theme changes with smooth transitions
class ThemeAwareWidget extends ConsumerWidget {
  final Widget Function(
    BuildContext context,
    bool isDarkMode,
    AppearanceState state,
  )
  builder;
  final Duration transitionDuration;
  final Curve transitionCurve;

  const ThemeAwareWidget({
    super.key,
    required this.builder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionCurve = Curves.easeInOutCubic,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearanceState = ref.watch(appearanceNotifierProvider);
    final isDarkMode = appearanceState.isDarkMode(context);

    return AnimatedSwitcher(
      duration: transitionDuration,
      switchInCurve: transitionCurve,
      switchOutCurve: transitionCurve,
      child: builder(context, isDarkMode, appearanceState),
    );
  }
}

/// A container that smoothly transitions its colors based on theme
class ThemeAwareContainer extends ConsumerWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final Color? lightColor;
  final Color? darkColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final Gradient? lightGradient;
  final Gradient? darkGradient;
  final Duration transitionDuration;
  final Curve transitionCurve;

  const ThemeAwareContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
    this.lightColor,
    this.darkColor,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.lightGradient,
    this.darkGradient,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionCurve = Curves.easeInOutCubic,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearanceState = ref.watch(appearanceNotifierProvider);
    final isDarkMode = appearanceState.isDarkMode(context);

    final effectiveColor = isDarkMode
        ? (darkColor ?? AppColors.darkSurface)
        : (lightColor ?? AppColors.lightSurface);

    final effectiveGradient = isDarkMode ? darkGradient : lightGradient;

    return AnimatedContainer(
      duration: transitionDuration,
      curve: transitionCurve,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      alignment: alignment,
      decoration: BoxDecoration(
        color: effectiveGradient == null ? effectiveColor : null,
        gradient: effectiveGradient,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
        border: border,
      ),
      child: child,
    );
  }
}

/// A text widget that smoothly transitions its color based on theme
class ThemeAwareText extends ConsumerWidget {
  final String text;
  final TextStyle? style;
  final Color? lightColor;
  final Color? darkColor;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Duration transitionDuration;
  final Curve transitionCurve;

  const ThemeAwareText(
    this.text, {
    super.key,
    this.style,
    this.lightColor,
    this.darkColor,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionCurve = Curves.easeInOutCubic,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearanceState = ref.watch(appearanceNotifierProvider);
    final isDarkMode = appearanceState.isDarkMode(context);

    final effectiveColor = isDarkMode
        ? (darkColor ?? AppColors.darkTextPrimary)
        : (lightColor ?? AppColors.lightTextPrimary);

    return AnimatedDefaultTextStyle(
      duration: transitionDuration,
      curve: transitionCurve,
      style: (style ?? Theme.of(context).textTheme.bodyMedium!).copyWith(
        color: effectiveColor,
      ),
      child: Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

/// An icon that smoothly transitions its color based on theme
class ThemeAwareIcon extends ConsumerWidget {
  final IconData icon;
  final double? size;
  final Color? lightColor;
  final Color? darkColor;
  final Duration transitionDuration;
  final Curve transitionCurve;

  const ThemeAwareIcon(
    this.icon, {
    super.key,
    this.size,
    this.lightColor,
    this.darkColor,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionCurve = Curves.easeInOutCubic,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearanceState = ref.watch(appearanceNotifierProvider);
    final isDarkMode = appearanceState.isDarkMode(context);

    final effectiveColor = isDarkMode
        ? (darkColor ?? AppColors.darkTextPrimary)
        : (lightColor ?? AppColors.lightTextPrimary);

    return TweenAnimationBuilder<Color?>(
      duration: transitionDuration,
      curve: transitionCurve,
      tween: ColorTween(end: effectiveColor),
      builder: (context, color, child) {
        return Icon(icon, size: size, color: color);
      },
    );
  }
}

/// A card that adapts to theme changes with smooth transitions
class ThemeAwareCard extends ConsumerWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? lightColor;
  final Color? darkColor;
  final BorderRadius? borderRadius;
  final Duration transitionDuration;
  final Curve transitionCurve;

  const ThemeAwareCard({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.lightColor,
    this.darkColor,
    this.borderRadius,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionCurve = Curves.easeInOutCubic,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearanceState = ref.watch(appearanceNotifierProvider);
    final isDarkMode = appearanceState.isDarkMode(context);

    final effectiveColor = isDarkMode
        ? (darkColor ?? AppColors.darkSurface)
        : (lightColor ?? AppColors.lightSurface);

    return AnimatedContainer(
      duration: transitionDuration,
      curve: transitionCurve,
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: elevation != null
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.1),
                  blurRadius: elevation! * 2,
                  offset: Offset(0, elevation!),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

/// A button that adapts to theme changes with smooth transitions
class ThemeAwareButton extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? lightBackgroundColor;
  final Color? darkBackgroundColor;
  final Color? lightForegroundColor;
  final Color? darkForegroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Duration transitionDuration;
  final Curve transitionCurve;

  const ThemeAwareButton({
    super.key,
    required this.child,
    this.onPressed,
    this.lightBackgroundColor,
    this.darkBackgroundColor,
    this.lightForegroundColor,
    this.darkForegroundColor,
    this.padding,
    this.borderRadius,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionCurve = Curves.easeInOutCubic,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearanceState = ref.watch(appearanceNotifierProvider);
    final isDarkMode = appearanceState.isDarkMode(context);

    final effectiveBackgroundColor = isDarkMode
        ? (darkBackgroundColor ?? AppColors.cinematicGold)
        : (lightBackgroundColor ?? AppColors.cinematicGold);

    final effectiveForegroundColor = isDarkMode
        ? (darkForegroundColor ?? AppColors.darkBackground)
        : (lightForegroundColor ?? AppColors.lightBackground);

    return TweenAnimationBuilder<Color?>(
      duration: transitionDuration,
      curve: transitionCurve,
      tween: ColorTween(end: effectiveBackgroundColor),
      builder: (context, backgroundColor, _) {
        return TweenAnimationBuilder<Color?>(
          duration: transitionDuration,
          curve: transitionCurve,
          tween: ColorTween(end: effectiveForegroundColor),
          builder: (context, foregroundColor, _) {
            return ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                padding:
                    padding ??
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius ?? BorderRadius.circular(12),
                ),
              ),
              child: child,
            );
          },
        );
      },
    );
  }
}
