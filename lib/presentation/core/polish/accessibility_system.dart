import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';



/// Comprehensive accessibility system for WCAG compliance
class AccessibilitySystem {
  // --- ACCESSIBILITY CONSTANTS ---

  /// Minimum touch target size (44x44 dp for iOS, 48x48 dp for Android)
  static const double minTouchTargetSize = 48.0;

  /// Minimum contrast ratios for WCAG AA compliance
  static const double minContrastRatioNormal = 4.5;
  static const double minContrastRatioLarge = 3.0;

  /// Large text threshold (18pt regular or 14pt bold)
  static const double largeTextThreshold = 18.0;

  // --- COLOR CONTRAST VALIDATION ---

  /// Calculate relative luminance of a color
  static double _getRelativeLuminance(Color color) {
    final r = _getColorComponent(color.red);
    final g = _getColorComponent(color.green);
    final b = _getColorComponent(color.blue);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _getColorComponent(int component) {
    final c = component / 255.0;
    return c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4);
  }

  /// Calculate contrast ratio between two colors
  static double getContrastRatio(Color color1, Color color2) {
    final luminance1 = _getRelativeLuminance(color1);
    final luminance2 = _getRelativeLuminance(color2);
    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if color combination meets WCAG AA standards
  static bool meetsContrastRequirement(
    Color foreground,
    Color background, {
    bool isLargeText = false,
  }) {
    final ratio = getContrastRatio(foreground, background);
    final requiredRatio = isLargeText ? minContrastRatioLarge : minContrastRatioNormal;
    return ratio >= requiredRatio;
  }

  /// Get accessible text color for given background
  static Color getAccessibleTextColor(Color backgroundColor) {
    final whiteContrast = getContrastRatio(Colors.white, backgroundColor);
    final blackContrast = getContrastRatio(Colors.black, backgroundColor);
    
    return whiteContrast > blackContrast ? Colors.white : Colors.black;
  }

  /// Validate and adjust color for accessibility
  static Color ensureAccessibleColor(
    Color foreground,
    Color background, {
    bool isLargeText = false,
  }) {
    if (meetsContrastRequirement(foreground, background, isLargeText: isLargeText)) {
      return foreground;
    }
    
    // Return high contrast alternative
    return getAccessibleTextColor(background);
  }

  // --- SEMANTIC WIDGETS ---

  /// Create an accessible button with proper semantics
  static Widget accessibleButton({
    required String label,
    required VoidCallback? onPressed,
    String? tooltip,
    String? semanticLabel,
    bool isEnabled = true,
    Widget? child,
    ButtonStyle? style,
  }) {
    return Semantics(
      label: semanticLabel ?? label,
      hint: tooltip,
      button: true,
      enabled: isEnabled,
      child: Tooltip(
        message: tooltip ?? label,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: minTouchTargetSize,
            minHeight: minTouchTargetSize,
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: style,
            child: child ?? Text(label),
          ),
        ),
      ),
    );
  }

  /// Create an accessible text field with proper semantics
  static Widget accessibleTextField({
    required String label,
    String? hint,
    String? errorText,
    String? helperText,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    bool obscureText = false,
    TextInputType? keyboardType,
    bool isRequired = false,
  }) {
    return Semantics(
      label: isRequired ? '$label (required)' : label,
      hint: hint,
      textField: true,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          hintText: hint,
          errorText: errorText,
          helperText: helperText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  /// Create an accessible card with proper semantics
  static Widget accessibleCard({
    required Widget child,
    String? semanticLabel,
    String? tooltip,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    double? elevation,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: tooltip,
      button: onTap != null,
      child: Card(
        elevation: elevation ?? 4,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Create an accessible list item with proper semantics
  static Widget accessibleListTile({
    required String title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    return Semantics(
      label: semanticLabel ?? title,
      hint: subtitle,
      button: onTap != null,
      child: ListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
        minVerticalPadding: 12,
      ),
    );
  }

  /// Create an accessible icon button with proper semantics
  static Widget accessibleIconButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    String? tooltip,
    double? iconSize,
    Color? color,
  }) {
    return Semantics(
      label: label,
      hint: tooltip ?? label,
      button: true,
      child: Tooltip(
        message: tooltip ?? label,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: minTouchTargetSize,
            minHeight: minTouchTargetSize,
          ),
          child: IconButton(
            icon: Icon(icon),
            onPressed: onPressed,
            iconSize: iconSize ?? 24,
            color: color,
          ),
        ),
      ),
    );
  }

  /// Create an accessible switch with proper semantics
  static Widget accessibleSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool>? onChanged,
    String? description,
  }) {
    return Semantics(
      label: label,
      hint: description,
      toggled: value,
      child: SwitchListTile(
        title: Text(label),
        subtitle: description != null ? Text(description) : null,
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  /// Create an accessible slider with proper semantics
  static Widget accessibleSlider({
    required String label,
    required double value,
    required ValueChanged<double>? onChanged,
    double min = 0.0,
    double max = 1.0,
    int? divisions,
    String Function(double)? semanticFormatterCallback,
  }) {
    return Semantics(
      label: label,
      value: semanticFormatterCallback?.call(value) ?? value.toString(),
      increasedValue: semanticFormatterCallback?.call((value + (max - min) / 10).clamp(min, max)) ?? 
                     ((value + (max - min) / 10).clamp(min, max)).toString(),
      decreasedValue: semanticFormatterCallback?.call((value - (max - min) / 10).clamp(min, max)) ?? 
                     ((value - (max - min) / 10).clamp(min, max)).toString(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          Slider(
            value: value,
            onChanged: onChanged,
            min: min,
            max: max,
            divisions: divisions,
            label: semanticFormatterCallback?.call(value) ?? value.toString(),
          ),
        ],
      ),
    );
  }

  // --- FOCUS MANAGEMENT ---

  /// Create a focus traversal group for keyboard navigation
  static Widget focusTraversalGroup({
    required Widget child,
    FocusTraversalPolicy? policy,
  }) {
    return FocusTraversalGroup(
      policy: policy ?? OrderedTraversalPolicy(),
      child: child,
    );
  }

  /// Create an auto-focus widget
  static Widget autoFocus({
    required Widget child,
    bool autofocus = true,
  }) {
    return Focus(
      autofocus: autofocus,
      child: child,
    );
  }

  // --- SCREEN READER SUPPORT ---

  /// Announce a message to screen readers
  static void announceToScreenReader(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Create a live region for dynamic content updates
  static Widget liveRegion({
    required Widget child,
    String? label,
    bool assertive = false,
  }) {
    return Semantics(
      label: label,
      liveRegion: true,
      child: child,
    );
  }

  /// Create a heading for screen reader navigation
  static Widget heading({
    required String text,
    required TextStyle style,
    int level = 1,
  }) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: style,
      ),
    );
  }

  // --- VALIDATION HELPERS ---

  /// Validate if widget meets minimum touch target size
  static bool validateTouchTargetSize(Size size) {
    return size.width >= minTouchTargetSize && size.height >= minTouchTargetSize;
  }

  /// Get accessibility report for a color scheme
  static AccessibilityReport getColorSchemeReport(ColorScheme colorScheme) {
    final issues = <String>[];
    final warnings = <String>[];

    // Check primary color contrast
    final primaryContrast = getContrastRatio(colorScheme.onPrimary, colorScheme.primary);
    if (primaryContrast < minContrastRatioNormal) {
      issues.add('Primary color contrast ratio ($primaryContrast) is below WCAG AA standard');
    }

    // Check surface color contrast
    final surfaceContrast = getContrastRatio(colorScheme.onSurface, colorScheme.surface);
    if (surfaceContrast < minContrastRatioNormal) {
      issues.add('Surface color contrast ratio ($surfaceContrast) is below WCAG AA standard');
    }

    // Check error color contrast
    final errorContrast = getContrastRatio(colorScheme.onError, colorScheme.error);
    if (errorContrast < minContrastRatioNormal) {
      issues.add('Error color contrast ratio ($errorContrast) is below WCAG AA standard');
    }

    return AccessibilityReport(
      issues: issues,
      warnings: warnings,
      isCompliant: issues.isEmpty,
    );
  }

  // --- UTILITY FUNCTIONS ---

  /// Check if reduce motion is enabled
  static bool isReduceMotionEnabled(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Get text scale factor
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }

  /// Check if high contrast is enabled
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }
}

// --- HELPER CLASSES ---

class AccessibilityReport {
  final List<String> issues;
  final List<String> warnings;
  final bool isCompliant;

  const AccessibilityReport({
    required this.issues,
    required this.warnings,
    required this.isCompliant,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Accessibility Report:');
    buffer.writeln('Compliant: $isCompliant');
    
    if (issues.isNotEmpty) {
      buffer.writeln('\nIssues:');
      for (final issue in issues) {
        buffer.writeln('- $issue');
      }
    }
    
    if (warnings.isNotEmpty) {
      buffer.writeln('\nWarnings:');
      for (final warning in warnings) {
        buffer.writeln('- $warning');
      }
    }
    
    return buffer.toString();
  }
}

// --- MATH HELPER ---
double pow(double base, double exponent) {
  if (exponent == 0) return 1.0;
  if (exponent == 1) return base;
  if (exponent == 2) return base * base;
  if (exponent == 2.4) {
    // Approximation for gamma correction
    final sqrt = base * base;
    return sqrt * sqrt * (base * 0.4);
  }
  // Fallback for other exponents
  return base;
}