import 'package:flutter/material.dart';

import '../app_colors.dart';


/// Visual hierarchy system for consistent content organization
class VisualHierarchy {
  // --- TYPOGRAPHY HIERARCHY ---

  /// Primary heading for page titles and major sections
  static TextStyle primaryHeading(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
      height: 1.2,
    );
  }

  /// Secondary heading for section titles
  static TextStyle secondaryHeading(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
      height: 1.3,
    );
  }

  /// Tertiary heading for subsections
  static TextStyle tertiaryHeading(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall!.copyWith(
      fontWeight: FontWeight.w600,
      height: 1.4,
    );
  }

  /// Body text for main content
  static TextStyle bodyText(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
      height: 1.6,
      letterSpacing: 0.15,
    );
  }

  /// Secondary body text for supporting content
  static TextStyle bodyTextSecondary(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      height: 1.5,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
    );
  }

  /// Caption text for metadata and labels
  static TextStyle captionText(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
      height: 1.4,
      letterSpacing: 0.4,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
    );
  }

  /// Button text styling
  static TextStyle buttonText(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge!.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );
  }

  // --- SPACING HIERARCHY ---

  /// Micro spacing for tight layouts
  static const double spacingMicro = 2.0;

  /// Extra small spacing
  static const double spacingXS = 4.0;

  /// Small spacing for related elements
  static const double spacingS = 8.0;

  /// Medium spacing for standard gaps
  static const double spacingM = 16.0;

  /// Large spacing for section separation
  static const double spacingL = 24.0;

  /// Extra large spacing for major sections
  static const double spacingXL = 32.0;

  /// Extra extra large spacing for page sections
  static const double spacingXXL = 48.0;

  /// Massive spacing for hero sections
  static const double spacingMassive = 64.0;

  // --- ELEVATION HIERARCHY ---

  /// Surface level (cards, sheets)
  static const double elevationSurface = 1.0;

  /// Low elevation for subtle lift
  static const double elevationLow = 2.0;

  /// Medium elevation for interactive elements
  static const double elevationMedium = 4.0;

  /// High elevation for important elements
  static const double elevationHigh = 8.0;

  /// Maximum elevation for modals and overlays
  static const double elevationMax = 16.0;

  // --- COLOR HIERARCHY ---

  /// Primary content color
  static Color primaryContent(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Secondary content color
  static Color secondaryContent(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
  }

  /// Tertiary content color
  static Color tertiaryContent(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
  }

  /// Disabled content color
  static Color disabledContent(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38);
  }

  /// Accent color for highlights
  static Color accentColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  /// Error color for warnings and errors
  static Color errorColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  /// Success color for positive feedback
  static Color successColor(BuildContext context) {
    return AppColors.darkSuccessGreen;
  }

  // --- COMPONENT BUILDERS ---

  /// Create a hierarchical section with proper spacing and typography
  static Widget section({
    required BuildContext context,
    required String title,
    required Widget content,
    String? subtitle,
    Widget? action,
    EdgeInsetsGeometry? padding,
    bool showDivider = false,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: secondaryHeading(context),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: spacingXS),
                      Text(
                        subtitle,
                        style: bodyTextSecondary(context),
                      ),
                    ],
                  ],
                ),
              ),
              if (action != null) action,
            ],
          ),
          
          const SizedBox(height: spacingM),
          
          // Section content
          content,
          
          // Optional divider
          if (showDivider) ...[
            const SizedBox(height: spacingL),
            Divider(
              color: tertiaryContent(context),
              thickness: 0.5,
            ),
          ],
        ],
      ),
    );
  }

  /// Create a card with proper hierarchy
  static Widget card({
    required BuildContext context,
    required Widget child,
    String? title,
    String? subtitle,
    Widget? action,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? elevation,
    Color? color,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.all(spacingS),
      child: Card(
        elevation: elevation ?? elevationMedium,
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null || action != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: tertiaryHeading(context),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: spacingXS),
                                Text(
                                  subtitle,
                                  style: captionText(context),
                                ),
                              ],
                            ],
                          ),
                        ),
                      if (action != null) action,
                    ],
                  ),
                  const SizedBox(height: spacingM),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Create a list item with proper hierarchy
  static Widget listItem({
    required BuildContext context,
    required Widget content,
    Widget? leading,
    Widget? trailing,
    String? title,
    String? subtitle,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingS,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading,
              const SizedBox(width: spacingM),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title,
                      style: bodyText(context),
                    ),
                  if (subtitle != null) ...[
                    const SizedBox(height: spacingXS),
                    Text(
                      subtitle,
                      style: captionText(context),
                    ),
                  ],
                  if (title == null && subtitle == null)
                    content,
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: spacingM),
              trailing,
            ],
          ],
        ),
      ),
    );
  }

  /// Create a hero section with proper hierarchy
  static Widget heroSection({
    required BuildContext context,
    required String title,
    String? subtitle,
    Widget? backgroundImage,
    Widget? action,
    EdgeInsetsGeometry? padding,
    double? height,
    Gradient? gradient,
  }) {
    return Container(
      height: height ?? 300,
      padding: padding ?? const EdgeInsets.all(spacingL),
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.heroGradient,
        image: backgroundImage != null
            ? DecorationImage(
                image: backgroundImage is Image
                    ? (backgroundImage).image
                    : const AssetImage('assets/images/placeholder.jpg'),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: primaryHeading(context).copyWith(
              color: Colors.white,
              shadows: [
                const Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: spacingS),
            Text(
              subtitle,
              style: bodyText(context).copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                shadows: [
                  const Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 2,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: spacingL),
            action,
          ],
        ],
      ),
    );
  }

  /// Create a stat display with proper hierarchy
  static Widget statDisplay({
    required BuildContext context,
    required String value,
    required String label,
    Widget? icon,
    Color? valueColor,
    Color? labelColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          icon,
          const SizedBox(height: spacingS),
        ],
        Text(
          value,
          style: primaryHeading(context).copyWith(
            color: valueColor ?? accentColor(context),
            fontSize: 32,
          ),
        ),
        const SizedBox(height: spacingXS),
        Text(
          label,
          style: captionText(context).copyWith(
            color: labelColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Create a badge with proper hierarchy
  static Widget badge({
    required BuildContext context,
    required String text,
    Color? backgroundColor,
    Color? textColor,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: spacingS,
        vertical: spacingXS,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? accentColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: captionText(context).copyWith(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}