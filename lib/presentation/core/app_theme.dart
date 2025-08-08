import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Enhanced theme system for PlotTwists app
/// Provides dark-first design with cinematic styling and glassmorphism effects
class AppTheme {
  // --- THEME CONFIGURATION ---

  /// Primary dark theme (default)
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Color Scheme
    colorScheme: _darkColorScheme,

    // Typography
    textTheme: AppTypography.darkTextTheme,

    // App Bar Theme
    appBarTheme: _darkAppBarTheme,

    // Bottom Navigation Theme
    bottomNavigationBarTheme: _darkBottomNavigationTheme,

    // Card Theme
    cardTheme: _darkCardTheme,

    // Elevated Button Theme
    elevatedButtonTheme: _darkElevatedButtonTheme,

    // Text Button Theme
    textButtonTheme: _darkTextButtonTheme,

    // Outlined Button Theme
    outlinedButtonTheme: _darkOutlinedButtonTheme,

    // Icon Theme
    iconTheme: _darkIconTheme,

    // Input Decoration Theme
    inputDecorationTheme: _darkInputDecorationTheme,

    // Chip Theme
    chipTheme: _darkChipTheme,

    // Dialog Theme
    dialogTheme: _darkDialogTheme,

    // Bottom Sheet Theme
    bottomSheetTheme: _darkBottomSheetTheme,

    // Scaffold Background
    scaffoldBackgroundColor: AppColors.darkBackground,

    // Divider Theme
    dividerTheme: _darkDividerTheme,

    // List Tile Theme
    listTileTheme: _darkListTileTheme,

    // Tab Bar Theme
    tabBarTheme: _darkTabBarTheme,

    // Floating Action Button Theme
    floatingActionButtonTheme: _darkFabTheme,

    // Progress Indicator Theme
    progressIndicatorTheme: _darkProgressIndicatorTheme,

    // Switch Theme
    switchTheme: _darkSwitchTheme,

    // Slider Theme
    sliderTheme: _darkSliderTheme,
  );

  /// Secondary light theme
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color Scheme
    colorScheme: _lightColorScheme,

    // Typography
    textTheme: AppTypography.lightTextTheme,

    // App Bar Theme
    appBarTheme: _lightAppBarTheme,

    // Bottom Navigation Theme
    bottomNavigationBarTheme: _lightBottomNavigationTheme,

    // Card Theme
    cardTheme: _lightCardTheme,

    // Elevated Button Theme
    elevatedButtonTheme: _lightElevatedButtonTheme,

    // Text Button Theme
    textButtonTheme: _lightTextButtonTheme,

    // Outlined Button Theme
    outlinedButtonTheme: _lightOutlinedButtonTheme,

    // Icon Theme
    iconTheme: _lightIconTheme,

    // Input Decoration Theme
    inputDecorationTheme: _lightInputDecorationTheme,

    // Chip Theme
    chipTheme: _lightChipTheme,

    // Dialog Theme
    dialogTheme: _lightDialogTheme,

    // Bottom Sheet Theme
    bottomSheetTheme: _lightBottomSheetTheme,

    // Scaffold Background
    scaffoldBackgroundColor: AppColors.lightBackground,

    // Divider Theme
    dividerTheme: _lightDividerTheme,

    // List Tile Theme
    listTileTheme: _lightListTileTheme,

    // Tab Bar Theme
    tabBarTheme: _lightTabBarTheme,

    // Floating Action Button Theme
    floatingActionButtonTheme: _lightFabTheme,

    // Progress Indicator Theme
    progressIndicatorTheme: _lightProgressIndicatorTheme,

    // Switch Theme
    switchTheme: _lightSwitchTheme,

    // Slider Theme
    sliderTheme: _lightSliderTheme,
  );

  // --- DARK THEME COMPONENTS ---

  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: AppColors.cinematicGold,
    onPrimary: AppColors.darkBackground,
    secondary: AppColors.cinematicPurple,
    onSecondary: AppColors.darkTextPrimary,
    tertiary: AppColors.cinematicBlue,
    onTertiary: AppColors.darkTextPrimary,
    error: AppColors.darkErrorRed,
    onError: AppColors.darkTextPrimary,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkTextPrimary,
    surfaceContainerHighest: AppColors.darkSurfaceVariant,
    outline: AppColors.darkTextTertiary,
    outlineVariant: AppColors.darkTextSecondary,
  );

  static const AppBarTheme _darkAppBarTheme = AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: AppTypography.headlineMedium,
    iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
    actionsIconTheme: IconThemeData(color: AppColors.darkTextPrimary),
    systemOverlayStyle: SystemUiOverlayStyle.light,
  );

  static const BottomNavigationBarThemeData _darkBottomNavigationTheme =
      BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.cinematicGold,
        unselectedItemColor: AppColors.darkTextSecondary,
        selectedLabelStyle: AppTypography.navigation,
        unselectedLabelStyle: AppTypography.navigation,
        type: BottomNavigationBarType.fixed,
      );

  static const CardThemeData _darkCardTheme = CardThemeData(
    color: AppColors.darkSurface,
    elevation: 8,
    shadowColor: Colors.black26,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    margin: EdgeInsets.all(8),
  );

  static final ElevatedButtonThemeData _darkElevatedButtonTheme =
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cinematicGold,
          foregroundColor: AppColors.darkBackground,
          textStyle: AppTypography.button,
          elevation: 4,
          shadowColor: AppColors.cinematicGold.withValues(alpha: 0.3),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      );

  static final TextButtonThemeData _darkTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.cinematicGold,
      textStyle: AppTypography.button,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );

  static final OutlinedButtonThemeData _darkOutlinedButtonTheme =
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.cinematicGold,
          textStyle: AppTypography.button,
          side: const BorderSide(color: AppColors.cinematicGold, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      );

  static const IconThemeData _darkIconTheme = IconThemeData(
    color: AppColors.darkTextPrimary,
    size: 24,
  );

  static const InputDecorationTheme _darkInputDecorationTheme =
      InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.darkTextTertiary, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.cinematicGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.darkErrorRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.darkErrorRed, width: 2),
        ),
        labelStyle: AppTypography.bodyMedium,
        hintStyle: AppTypography.bodyMedium,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );

  static final ChipThemeData _darkChipTheme = ChipThemeData(
    backgroundColor: AppColors.darkSurfaceVariant,
    selectedColor: AppColors.cinematicGold,
    disabledColor: AppColors.darkTextTertiary,
    labelStyle: AppTypography.genreTag,
    secondaryLabelStyle: AppTypography.genreTag,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
  );

  static const DialogThemeData _darkDialogTheme = DialogThemeData(
    backgroundColor: AppColors.darkSurface,
    elevation: 16,
    shadowColor: Colors.black38,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    titleTextStyle: AppTypography.headlineSmall,
    contentTextStyle: AppTypography.bodyMedium,
  );

  static const BottomSheetThemeData _darkBottomSheetTheme =
      BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 16,
        modalElevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      );

  static const DividerThemeData _darkDividerTheme = DividerThemeData(
    color: AppColors.darkTextTertiary,
    thickness: 0.5,
    space: 1,
  );

  static const ListTileThemeData _darkListTileTheme = ListTileThemeData(
    textColor: AppColors.darkTextPrimary,
    iconColor: AppColors.darkTextSecondary,
    tileColor: Colors.transparent,
    selectedTileColor: AppColors.darkSurfaceVariant,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  );

  static const TabBarThemeData _darkTabBarTheme = TabBarThemeData(
    labelColor: AppColors.cinematicGold,
    unselectedLabelColor: AppColors.darkTextSecondary,
    labelStyle: AppTypography.labelLarge,
    unselectedLabelStyle: AppTypography.labelLarge,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(color: AppColors.cinematicGold, width: 2),
    ),
    indicatorSize: TabBarIndicatorSize.tab,
  );

  static const FloatingActionButtonThemeData _darkFabTheme =
      FloatingActionButtonThemeData(
        backgroundColor: AppColors.cinematicGold,
        foregroundColor: AppColors.darkBackground,
        elevation: 8,
        focusElevation: 12,
        hoverElevation: 10,
        highlightElevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      );

  static const ProgressIndicatorThemeData _darkProgressIndicatorTheme =
      ProgressIndicatorThemeData(
        color: AppColors.cinematicGold,
        linearTrackColor: AppColors.darkSurfaceVariant,
        circularTrackColor: AppColors.darkSurfaceVariant,
      );

  static final SwitchThemeData _darkSwitchTheme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.cinematicGold;
      }
      return AppColors.darkTextSecondary;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.cinematicGold.withValues(alpha: 0.3);
      }
      return AppColors.darkSurfaceVariant;
    }),
  );

  static final SliderThemeData _darkSliderTheme = SliderThemeData(
    activeTrackColor: AppColors.cinematicGold,
    inactiveTrackColor: AppColors.darkSurfaceVariant,
    thumbColor: AppColors.cinematicGold,
    overlayColor: AppColors.cinematicGold.withValues(alpha: 0.2),
    valueIndicatorColor: AppColors.cinematicGold,
    valueIndicatorTextStyle: AppTypography.labelSmall,
  );

  // --- LIGHT THEME COMPONENTS ---

  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: AppColors.cinematicGold,
    onPrimary: AppColors.lightBackground,
    secondary: AppColors.cinematicPurple,
    onSecondary: AppColors.lightTextPrimary,
    tertiary: AppColors.cinematicBlue,
    onTertiary: AppColors.lightTextPrimary,
    error: AppColors.lightErrorRed,
    onError: AppColors.lightTextPrimary,
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightTextPrimary,
    surfaceContainerHighest: AppColors.lightSurfaceVariant,
    outline: AppColors.lightTextTertiary,
    outlineVariant: AppColors.lightTextSecondary,
  );

  static const AppBarTheme _lightAppBarTheme = AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: AppTypography.headlineMedium,
    iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
    actionsIconTheme: IconThemeData(color: AppColors.lightTextPrimary),
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  );

  static const BottomNavigationBarThemeData _lightBottomNavigationTheme =
      BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.cinematicGold,
        unselectedItemColor: AppColors.lightTextSecondary,
        selectedLabelStyle: AppTypography.navigation,
        unselectedLabelStyle: AppTypography.navigation,
        type: BottomNavigationBarType.fixed,
      );

  static const CardThemeData _lightCardTheme = CardThemeData(
    color: AppColors.lightSurface,
    elevation: 4,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    margin: EdgeInsets.all(8),
  );

  static final ElevatedButtonThemeData _lightElevatedButtonTheme =
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cinematicGold,
          foregroundColor: AppColors.lightBackground,
          textStyle: AppTypography.button,
          elevation: 2,
          shadowColor: AppColors.cinematicGold.withValues(alpha: 0.2),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      );

  static final TextButtonThemeData _lightTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.cinematicGold,
      textStyle: AppTypography.button,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );

  static final OutlinedButtonThemeData _lightOutlinedButtonTheme =
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.cinematicGold,
          textStyle: AppTypography.button,
          side: const BorderSide(color: AppColors.cinematicGold, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      );

  static const IconThemeData _lightIconTheme = IconThemeData(
    color: AppColors.lightTextPrimary,
    size: 24,
  );

  static const InputDecorationTheme _lightInputDecorationTheme =
      InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.lightTextTertiary, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.cinematicGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.lightErrorRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.lightErrorRed, width: 2),
        ),
        labelStyle: AppTypography.bodyMedium,
        hintStyle: AppTypography.bodyMedium,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );

  static final ChipThemeData _lightChipTheme = ChipThemeData(
    backgroundColor: AppColors.lightSurfaceVariant,
    selectedColor: AppColors.cinematicGold,
    disabledColor: AppColors.lightTextTertiary,
    labelStyle: AppTypography.genreTag,
    secondaryLabelStyle: AppTypography.genreTag,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
  );

  static const DialogThemeData _lightDialogTheme = DialogThemeData(
    backgroundColor: AppColors.lightSurface,
    elevation: 8,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    titleTextStyle: AppTypography.headlineSmall,
    contentTextStyle: AppTypography.bodyMedium,
  );

  static const BottomSheetThemeData _lightBottomSheetTheme =
      BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 8,
        modalElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      );

  static const DividerThemeData _lightDividerTheme = DividerThemeData(
    color: AppColors.lightTextTertiary,
    thickness: 0.5,
    space: 1,
  );

  static const ListTileThemeData _lightListTileTheme = ListTileThemeData(
    textColor: AppColors.lightTextPrimary,
    iconColor: AppColors.lightTextSecondary,
    tileColor: Colors.transparent,
    selectedTileColor: AppColors.lightSurfaceVariant,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  );

  static const TabBarThemeData _lightTabBarTheme = TabBarThemeData(
    labelColor: AppColors.cinematicGold,
    unselectedLabelColor: AppColors.lightTextSecondary,
    labelStyle: AppTypography.labelLarge,
    unselectedLabelStyle: AppTypography.labelLarge,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(color: AppColors.cinematicGold, width: 2),
    ),
    indicatorSize: TabBarIndicatorSize.tab,
  );

  static const FloatingActionButtonThemeData _lightFabTheme =
      FloatingActionButtonThemeData(
        backgroundColor: AppColors.cinematicGold,
        foregroundColor: AppColors.lightBackground,
        elevation: 4,
        focusElevation: 8,
        hoverElevation: 6,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      );

  static const ProgressIndicatorThemeData _lightProgressIndicatorTheme =
      ProgressIndicatorThemeData(
        color: AppColors.cinematicGold,
        linearTrackColor: AppColors.lightSurfaceVariant,
        circularTrackColor: AppColors.lightSurfaceVariant,
      );

  static final SwitchThemeData _lightSwitchTheme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.cinematicGold;
      }
      return AppColors.lightTextSecondary;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.cinematicGold.withValues(alpha: 0.3);
      }
      return AppColors.lightSurfaceVariant;
    }),
  );

  static final SliderThemeData _lightSliderTheme = SliderThemeData(
    activeTrackColor: AppColors.cinematicGold,
    inactiveTrackColor: AppColors.lightSurfaceVariant,
    thumbColor: AppColors.cinematicGold,
    overlayColor: AppColors.cinematicGold.withValues(alpha: 0.2),
    valueIndicatorColor: AppColors.cinematicGold,
    valueIndicatorTextStyle: AppTypography.labelSmall,
  );

  // --- UTILITY METHODS ---

  /// Get current theme based on brightness
  static ThemeData getTheme(Brightness brightness) {
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }

  /// Create a custom theme with overrides
  static ThemeData createCustomTheme({
    required Brightness brightness,
    Color? primaryColor,
    Color? backgroundColor,
    TextTheme? textTheme,
  }) {
    final baseTheme = brightness == Brightness.dark ? darkTheme : lightTheme;

    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: primaryColor ?? baseTheme.colorScheme.primary,
      ),
      scaffoldBackgroundColor:
          backgroundColor ?? baseTheme.scaffoldBackgroundColor,
      textTheme: textTheme ?? baseTheme.textTheme,
    );
  }

  /// Apply glassmorphism effect to a container
  static BoxDecoration glassmorphismDecoration({
    double borderRadius = 16,
    double opacity = 0.8,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: AppColors.glassmorphismBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? AppColors.glassmorphismBorder,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Create a cinematic gradient container decoration
  static BoxDecoration cinematicGradientDecoration({
    required Gradient gradient,
    double borderRadius = 16,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow:
          boxShadow ??
          [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
    );
  }

  /// Create a card decoration with elevation effect
  static BoxDecoration cardDecoration({
    required Brightness brightness,
    double borderRadius = 16,
    double elevation = 4,
  }) {
    final isDark = brightness == Brightness.dark;

    return BoxDecoration(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
          blurRadius: elevation * 2,
          offset: Offset(0, elevation),
        ),
      ],
    );
  }

  /// Create a hero section overlay decoration
  static BoxDecoration heroOverlayDecoration({
    double borderRadius = 0,
    Gradient? gradient,
  }) {
    return BoxDecoration(
      gradient: gradient ?? AppColors.heroGradient,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }
}
