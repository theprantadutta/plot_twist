import 'package:flutter/material.dart';

// A centralized place for all the app's colors, for both light and dark themes.
class AppColors {
  // --- DARK THEME COLORS ---
  static const Color darkBackground = Color(0xFF100F1C); // Midnight Indigo
  static const Color darkSurface = Color(0xFF1C1B2A); // Elevated Surface

  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFA0A0A0);

  // Aurora Gradient
  static const Color auroraPink = Color(0xFFFF00A8);
  static const Color auroraPurple = Color(0xFF8B00FF);
  static const LinearGradient auroraGradient = LinearGradient(
    colors: [auroraPink, auroraPurple],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Functional Accent Colors
  static const Color darkStarlightGold = Color(0xFFFFD700);
  static const Color darkInfoCyan = Color(0xFF00B2FF);
  static const Color darkSuccessGreen = Color(0xFF00FFAA);
  static const Color darkErrorRed = Color(0xFFFF5252);

  // --- LIGHT THEME COLORS ---
  static const Color lightBackground = Color(0xFFF7F7F9); // Very light grey
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure White

  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF6B6B6B);

  // Accents can often be shared, but we can tweak them if needed.
  // The vibrant Aurora gradient works well on both light and dark backgrounds.
  static const Color lightStarlightGold = Color(
    0xFFEAA400,
  ); // Slightly deeper gold for contrast
  static const Color lightInfoCyan = Color(0xFF0095D1);
  static const Color lightSuccessGreen = Color(0xFF00C48C);
  static const Color lightErrorRed = Color(0xFFD92D2D);
}
