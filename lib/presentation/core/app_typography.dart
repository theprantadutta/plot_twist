import 'package:flutter/material.dart';

/// Enhanced typography system for PlotTwists app
/// Combines Inter (modern, clean) with Playfair Display (cinematic elegance)
class AppTypography {
  // --- FONT FAMILIES ---
  static const String _primaryFont = 'Inter';
  static const String _displayFont = 'Playfair Display';

  // --- DISPLAY STYLES (Playfair Display for cinematic elegance) ---

  /// Large display text for hero sections and major headings
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _displayFont,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// Medium display text for section headers
  static const TextStyle displayMedium = TextStyle(
    fontFamily: _displayFont,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.25,
  );

  /// Small display text for card titles
  static const TextStyle displaySmall = TextStyle(
    fontFamily: _displayFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  // --- HEADLINE STYLES (Inter for modern readability) ---

  /// Large headlines for page titles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  /// Medium headlines for section titles
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.35,
  );

  /// Small headlines for subsection titles
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.4,
  );

  // --- TITLE STYLES ---

  /// Large titles for prominent content
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  /// Medium titles for card headers
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.45,
  );

  /// Small titles for list items
  static const TextStyle titleSmall = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.5,
  );

  // --- BODY STYLES ---

  /// Large body text for main content
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  /// Medium body text for descriptions
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.55,
  );

  /// Small body text for captions
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.6,
  );

  // --- LABEL STYLES ---

  /// Large labels for buttons and important UI elements
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  /// Medium labels for form fields and secondary buttons
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  /// Small labels for tags and metadata
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    height: 1.5,
  );

  // --- SPECIALIZED STYLES ---

  /// Movie title style with cinematic flair
  static const TextStyle movieTitle = TextStyle(
    fontFamily: _displayFont,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.3,
  );

  /// Rating display style
  static const TextStyle rating = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.2,
  );

  /// Genre tag style
  static const TextStyle genreTag = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.2,
  );

  /// Button text style
  static const TextStyle button = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.2,
  );

  /// Navigation label style
  static const TextStyle navigation = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.2,
  );

  // --- UTILITY METHODS ---

  /// Apply color to any text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply opacity to any text style
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(color: style.color?.withValues(alpha: opacity));
  }

  /// Create a text style with custom font weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Create a text style with custom font size
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  // --- THEME INTEGRATION ---

  /// Generate TextTheme for Material Design integration
  static TextTheme get textTheme => const TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );

  /// Generate dark theme TextTheme with appropriate colors
  static TextTheme get darkTextTheme => textTheme.apply(
    bodyColor: const Color(0xFFF8F8FF), // darkTextPrimary
    displayColor: const Color(0xFFF8F8FF), // darkTextPrimary
  );

  /// Generate light theme TextTheme with appropriate colors
  static TextTheme get lightTextTheme => textTheme.apply(
    bodyColor: const Color(0xFF1A1A1F), // lightTextPrimary
    displayColor: const Color(0xFF1A1A1F), // lightTextPrimary
  );
}
