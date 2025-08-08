import 'package:flutter/material.dart';

/// Enhanced cinematic color palette for PlotTwists app
/// Provides dark-first design with rich cinematic colors and gradients
class AppColors {
  // --- ENHANCED DARK THEME COLORS (Primary) ---

  // Core Background Colors
  static const Color darkBackground = Color(0xFF0A0A0F); // Deep Space Black
  static const Color darkSurface = Color(0xFF1A1A24); // Elevated Charcoal
  static const Color darkSurfaceVariant = Color(0xFF2A2A38); // Card Background

  // Text Colors
  static const Color darkTextPrimary = Color(0xFFF8F8FF); // Pure White
  static const Color darkTextSecondary = Color(0xFFB8B8C8); // Muted Silver
  static const Color darkTextTertiary = Color(0xFF888898); // Subtle Grey

  // Cinematic Accent Colors
  static const Color cinematicGold = Color(0xFFFFD700); // Awards Gold
  static const Color cinematicRed = Color(0xFFE50914); // Netflix Red
  static const Color cinematicBlue = Color(0xFF0078FF); // Letterboxd Blue
  static const Color cinematicPurple = Color(0xFF8B5CF6); // Premium Purple

  // Legacy Aurora Colors (maintained for compatibility)
  static const Color auroraPink = Color(0xFFFF00A8);
  static const Color auroraPurple = Color(0xFF8B00FF);

  // Functional Colors
  static const Color darkSuccessGreen = Color(0xFF00FFAA);
  static const Color darkErrorRed = Color(0xFFFF5252);

  // Rating Colors
  static const Color ratingExcellent = Color(0xFF00FF88); // 8.5+
  static const Color ratingGood = Color(0xFF88FF00); // 7.0-8.4
  static const Color ratingAverage = Color(0xFFFFD700); // 5.5-6.9
  static const Color ratingPoor = Color(0xFFFF8800); // 4.0-5.4
  static const Color ratingBad = Color(0xFFFF4444); // <4.0

  /// Get color based on rating value (0-10 scale)
  static Color getRatingColor(double rating) {
    if (rating >= 8.5) return ratingExcellent;
    if (rating >= 7.0) return ratingGood;
    if (rating >= 5.5) return ratingAverage;
    if (rating >= 4.0) return ratingPoor;
    return ratingBad;
  }

  // Gradients
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkSurface, darkSurfaceVariant],
  );

  static const Color darkWarningOrange = Color(0xFFFF9500);
  static const Color darkInfoCyan = Color(0xFF00B2FF);

  // --- LIGHT THEME COLORS (Secondary) ---
  static const Color lightBackground = Color(0xFFFAFAFC); // Soft White
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure White
  static const Color lightSurfaceVariant = Color(0xFFF5F5F7); // Card Background

  static const Color lightTextPrimary = Color(0xFF1A1A1F); // Near Black
  static const Color lightTextSecondary = Color(0xFF6B6B78); // Muted Dark
  static const Color lightTextTertiary = Color(0xFF9B9BA8); // Subtle Dark

  // Light theme functional colors
  static const Color lightSuccessGreen = Color(0xFF00C48C);
  static const Color lightErrorRed = Color(0xFFD92D2D);
  static const Color lightWarningOrange = Color(0xFFFF8A00);
  static const Color lightInfoCyan = Color(0xFF0095D1);

  // --- CINEMATIC GRADIENTS ---

  /// Hero section gradient overlay
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0x00000000), Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 1.0],
  );

  /// Aurora gradient (legacy compatibility)
  static const LinearGradient auroraGradient = LinearGradient(
    colors: [auroraPink, auroraPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Cinematic accent gradient
  static const LinearGradient cinematicGradient = LinearGradient(
    colors: [cinematicRed, cinematicPurple],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Gold shimmer gradient for premium elements
  static const LinearGradient goldShimmerGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFFD700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Card elevation gradient
  // static const LinearGradient cardGradient = LinearGradient(
  //   colors: [Color(0xFF2A2A38), Color(0xFF1A1A24)],
  //   begin: Alignment.topLeft,
  //   end: Alignment.bottomRight,
  // );

  // --- GLASSMORPHISM COLORS ---

  /// Glassmorphism background with blur effect
  static Color get glassmorphismBackground =>
      darkSurface.withValues(alpha: 0.8);

  /// Glassmorphism border color
  static Color get glassmorphismBorder => Colors.white.withValues(alpha: 0.1);

  /// Navigation bar glassmorphism
  static Color get navigationGlass => darkSurface.withValues(alpha: 0.9);

  // --- SEMANTIC COLORS ---

  /// Rating colors based on score
  // static Color getRatingColor(double rating) {
  //   if (rating >= 8.0) return cinematicGold;
  //   if (rating >= 7.0) return cinematicBlue;
  //   if (rating >= 6.0) return cinematicPurple;
  //   if (rating >= 5.0) return darkWarningOrange;
  //   return darkErrorRed;
  // }

  /// Genre tag colors
  static const Map<String, Color> genreColors = {
    'Action': Color(0xFFE50914),
    'Adventure': Color(0xFF0078FF),
    'Comedy': Color(0xFFFF9500),
    'Drama': Color(0xFF8B5CF6),
    'Horror': Color(0xFF8B0000),
    'Romance': Color(0xFFFF69B4),
    'Sci-Fi': Color(0xFF00FFAA),
    'Thriller': Color(0xFF4B0082),
    'Fantasy': Color(0xFF9370DB),
    'Mystery': Color(0xFF2F4F4F),
  };

  // --- LEGACY COMPATIBILITY ---
  // Maintaining old color names for backward compatibility
  static const Color darkStarlightGold = cinematicGold;
  static const Color lightStarlightGold = Color(0xFFEAA400);
}
