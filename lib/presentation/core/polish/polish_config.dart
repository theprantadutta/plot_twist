import 'package:flutter/material.dart';

import '../app_colors.dart';

import 'ui_polish_system.dart';
import '../performance/performance_integration.dart';
import 'visual_hierarchy.dart';
import 'accessibility_system.dart';

/// Central configuration for UI polish and refinement
class PolishConfig {
  // --- ANIMATION REFINEMENTS ---

  /// Refined animation curves for premium feel
  static const Map<String, Curve> refinedCurves = {
    'cinematic': UIPolishSystem.cinematicEase,
    'smooth_entry': UIPolishSystem.smoothEntry,
    'smooth_exit': UIPolishSystem.smoothExit,
    'bounce_entry': UIPolishSystem.bounceEntry,
    'sharp_entry': UIPolishSystem.sharpEntry,
  };

  /// Refined animation durations
  static const Map<String, Duration> refinedDurations = {
    'micro': Duration(milliseconds: 100),
    'quick': Duration(milliseconds: 200),
    'standard': Duration(milliseconds: 300),
    'moderate': Duration(milliseconds: 400),
    'slow': Duration(milliseconds: 600),
  };

  // --- SPACING REFINEMENTS ---

  /// Consistent spacing scale
  static const Map<String, double> spacing = {
    'micro': VisualHierarchy.spacingMicro,
    'xs': VisualHierarchy.spacingXS,
    's': VisualHierarchy.spacingS,
    'm': VisualHierarchy.spacingM,
    'l': VisualHierarchy.spacingL,
    'xl': VisualHierarchy.spacingXL,
    'xxl': VisualHierarchy.spacingXXL,
    'massive': VisualHierarchy.spacingMassive,
  };

  // --- ELEVATION REFINEMENTS ---

  /// Consistent elevation scale
  static const Map<String, double> elevation = {
    'surface': VisualHierarchy.elevationSurface,
    'low': VisualHierarchy.elevationLow,
    'medium': VisualHierarchy.elevationMedium,
    'high': VisualHierarchy.elevationHigh,
    'max': VisualHierarchy.elevationMax,
  };

  // --- BORDER RADIUS REFINEMENTS ---

  /// Consistent border radius scale
  static const Map<String, double> borderRadius = {
    'xs': UIPolishSystem.radiusXS,
    's': UIPolishSystem.radiusS,
    'm': UIPolishSystem.radiusM,
    'l': UIPolishSystem.radiusL,
    'xl': UIPolishSystem.radiusXL,
    'xxl': UIPolishSystem.radiusXXL,
  };

  // --- COLOR REFINEMENTS ---

  /// Refined color palette with accessibility considerations
  static Map<String, Color> getRefinedColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return {
      'primary': AppColors.cinematicGold,
      'secondary': AppColors.cinematicPurple,
      'tertiary': AppColors.cinematicBlue,
      'error': isDark ? AppColors.darkErrorRed : AppColors.lightErrorRed,
      'success': isDark ? AppColors.darkSuccessGreen : AppColors.lightSuccessGreen,
      'warning': isDark ? AppColors.darkWarningOrange : AppColors.lightWarningOrange,
      'info': isDark ? AppColors.darkInfoCyan : AppColors.lightInfoCyan,
      'surface': isDark ? AppColors.darkSurface : AppColors.lightSurface,
      'background': isDark ? AppColors.darkBackground : AppColors.lightBackground,
      'text_primary': VisualHierarchy.primaryContent(context),
      'text_secondary': VisualHierarchy.secondaryContent(context),
      'text_tertiary': VisualHierarchy.tertiaryContent(context),
      'text_disabled': VisualHierarchy.disabledContent(context),
    };
  }

  // --- TYPOGRAPHY REFINEMENTS ---

  /// Refined typography scale
  static Map<String, TextStyle> getRefinedTypography(BuildContext context) {
    return {
      'primary_heading': VisualHierarchy.primaryHeading(context),
      'secondary_heading': VisualHierarchy.secondaryHeading(context),
      'tertiary_heading': VisualHierarchy.tertiaryHeading(context),
      'body_text': VisualHierarchy.bodyText(context),
      'body_text_secondary': VisualHierarchy.bodyTextSecondary(context),
      'caption_text': VisualHierarchy.captionText(context),
      'button_text': VisualHierarchy.buttonText(context),
    };
  }

  // --- COMPONENT CONFIGURATIONS ---

  /// Button configuration
  static ButtonStyle getRefinedButtonStyle(BuildContext context, {
    bool isPrimary = true,
    bool isLarge = false,
  }) {
    final colors = getRefinedColors(context);
    
    return ElevatedButton.styleFrom(
      backgroundColor: isPrimary ? colors['primary'] : Colors.transparent,
      foregroundColor: isPrimary ? Colors.black : colors['primary'],
      elevation: isPrimary ? elevation['medium'] : 0,
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? spacing['xl']! : spacing['l']!,
        vertical: isLarge ? spacing['m']! : spacing['s']!,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius['m']!),
        side: isPrimary ? BorderSide.none : BorderSide(
          color: colors['primary']!,
          width: 1.5,
        ),
      ),
      textStyle: getRefinedTypography(context)['button_text'],
    );
  }

  /// Card configuration
  static BoxDecoration getRefinedCardDecoration(BuildContext context, {
    double? customElevation,
    Color? customColor,
    double? customRadius,
  }) {
    final colors = getRefinedColors(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BoxDecoration(
      color: customColor ?? colors['surface'],
      borderRadius: BorderRadius.circular(
        customRadius ?? borderRadius['l']!,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
          blurRadius: (customElevation ?? elevation['medium']!) * 2,
          offset: Offset(0, customElevation ?? elevation['medium']!),
        ),
      ],
    );
  }

  /// Input field configuration
  static InputDecorationTheme getRefinedInputTheme(BuildContext context) {
    final colors = getRefinedColors(context);
    
    return InputDecorationTheme(
      filled: true,
      fillColor: colors['surface'],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius['m']!),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius['m']!),
        borderSide: BorderSide(
          color: colors['text_tertiary']!,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius['m']!),
        borderSide: BorderSide(
          color: colors['primary']!,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius['m']!),
        borderSide: BorderSide(
          color: colors['error']!,
          width: 1,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: spacing['m']!,
        vertical: spacing['s']!,
      ),
    );
  }

  // --- ACCESSIBILITY CONFIGURATIONS ---

  /// Get accessibility-compliant color scheme
  static ColorScheme getAccessibleColorScheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseScheme = isDark 
        ? const ColorScheme.dark()
        : const ColorScheme.light();
    
    return baseScheme.copyWith(
      primary: AccessibilitySystem.ensureAccessibleColor(
        AppColors.cinematicGold,
        baseScheme.surface,
      ),
      secondary: AccessibilitySystem.ensureAccessibleColor(
        AppColors.cinematicPurple,
        baseScheme.surface,
      ),
      error: AccessibilitySystem.ensureAccessibleColor(
        isDark ? AppColors.darkErrorRed : AppColors.lightErrorRed,
        baseScheme.surface,
      ),
    );
  }

  // --- PERFORMANCE CONFIGURATIONS ---

  /// Get performance-optimized animation duration
  static Duration getOptimizedDuration(String durationType) {
    final baseDuration = refinedDurations[durationType] ?? 
                        refinedDurations['standard']!;
    return PerformanceIntegration.instance.getRecommendedAnimationDuration(
      defaultDuration: baseDuration,
    );
  }

  /// Get performance-optimized curve
  static Curve getOptimizedCurve(String curveType) {
    return refinedCurves[curveType] ?? refinedCurves['cinematic']!;
  }

  // --- VALIDATION METHODS ---

  /// Validate component accessibility
  static AccessibilityReport validateComponentAccessibility(
    BuildContext context,
    Widget component,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return AccessibilitySystem.getColorSchemeReport(colorScheme);
  }

  /// Validate visual hierarchy
  static List<String> validateVisualHierarchy(BuildContext context) {
    final issues = <String>[];
    final typography = getRefinedTypography(context);
    
    // Check heading hierarchy
    final primarySize = typography['primary_heading']!.fontSize ?? 24;
    final secondarySize = typography['secondary_heading']!.fontSize ?? 20;
    final tertiarySize = typography['tertiary_heading']!.fontSize ?? 18;
    
    if (primarySize <= secondarySize) {
      issues.add('Primary heading should be larger than secondary heading');
    }
    
    if (secondarySize <= tertiarySize) {
      issues.add('Secondary heading should be larger than tertiary heading');
    }
    
    return issues;
  }

  // --- UTILITY METHODS ---

  /// Apply polish configuration to theme
  static ThemeData applyPolishToTheme(ThemeData baseTheme, BuildContext context) {
    return baseTheme.copyWith(
      colorScheme: getAccessibleColorScheme(context),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: getRefinedButtonStyle(context),
      ),
      inputDecorationTheme: getRefinedInputTheme(context),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius['l']!),
        ),
        elevation: elevation['medium'],
      ),
    );
  }

  /// Get component spacing
  static EdgeInsets getComponentPadding(String size) {
    final spacingValue = spacing[size] ?? spacing['m']!;
    return EdgeInsets.all(spacingValue);
  }

  /// Get component margin
  static EdgeInsets getComponentMargin(String size) {
    final spacingValue = spacing[size] ?? spacing['s']!;
    return EdgeInsets.all(spacingValue);
  }
}