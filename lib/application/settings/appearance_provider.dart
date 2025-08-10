import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/local/persistence_service.dart';
import '../home/home_providers.dart';
import 'theme_transition_service.dart';

part 'appearance_provider.g.dart';

// A class to hold our appearance state
@immutable
class AppearanceState {
  final ThemeMode themeMode;
  final Color accentColor;
  final bool useTrueBlack;
  final bool isTransitioning;
  final bool followSystemTheme;

  const AppearanceState({
    required this.themeMode,
    required this.accentColor,
    required this.useTrueBlack,
    this.isTransitioning = false,
    this.followSystemTheme = false,
  });

  AppearanceState copyWith({
    ThemeMode? themeMode,
    Color? accentColor,
    bool? useTrueBlack,
    bool? isTransitioning,
    bool? followSystemTheme,
  }) {
    return AppearanceState(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      useTrueBlack: useTrueBlack ?? this.useTrueBlack,
      isTransitioning: isTransitioning ?? this.isTransitioning,
      followSystemTheme: followSystemTheme ?? this.followSystemTheme,
    );
  }

  /// Get the effective brightness based on theme mode and system settings
  Brightness getEffectiveBrightness(BuildContext context) {
    switch (themeMode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness;
    }
  }

  /// Check if currently using dark theme
  bool isDarkMode(BuildContext context) {
    return getEffectiveBrightness(context) == Brightness.dark;
  }
}

// The Notifier that manages the state
@Riverpod(keepAlive: true)
class AppearanceNotifier extends _$AppearanceNotifier {
  late PersistenceService _persistenceService;

  @override
  AppearanceState build() {
    _persistenceService = ref.watch(persistenceServiceProvider);
    return AppearanceState(
      themeMode: _persistenceService.getThemeMode(),
      accentColor: Color(_persistenceService.getAccentColorValue()),
      useTrueBlack: _persistenceService.getTrueBlackEnabled(),
      followSystemTheme: _persistenceService.getThemeMode() == ThemeMode.system,
    );
  }

  /// Set theme mode with smooth transition animation
  Future<void> setThemeModeWithTransition(
    BuildContext context,
    ThemeMode mode,
  ) async {
    // Apply haptic feedback
    ThemeTransitionService.applyHapticFeedback();

    // Set transitioning state
    state = state.copyWith(isTransitioning: true);

    // Animate the transition
    await ThemeTransitionService.animateThemeTransition(
      context: context,
      onTransition: () {
        _persistenceService.setThemeMode(mode);
        state = state.copyWith(
          themeMode: mode,
          followSystemTheme: mode == ThemeMode.system,
        );
      },
    );

    // Clear transitioning state
    state = state.copyWith(isTransitioning: false);
  }

  /// Set theme mode without animation (for system changes)
  void setThemeMode(ThemeMode mode) {
    _persistenceService.setThemeMode(mode);
    state = state.copyWith(
      themeMode: mode,
      followSystemTheme: mode == ThemeMode.system,
    );
  }

  /// Toggle between light and dark mode with animation
  Future<void> toggleThemeWithTransition(BuildContext context) async {
    final currentBrightness = state.getEffectiveBrightness(context);
    final newMode = currentBrightness == Brightness.dark
        ? ThemeMode.light
        : ThemeMode.dark;

    await setThemeModeWithTransition(context, newMode);
  }

  /// Set accent color with smooth transition
  Future<void> setAccentColorWithTransition(
    BuildContext context,
    Color color,
  ) async {
    // Apply haptic feedback
    HapticFeedback.selectionClick();

    // Set transitioning state
    state = state.copyWith(isTransitioning: true);

    // Small delay for visual feedback
    await Future.delayed(const Duration(milliseconds: 100));

    _persistenceService.setAccentColorValue(color.toARGB32());
    state = state.copyWith(accentColor: color, isTransitioning: false);
  }

  void setAccentColor(Color color) {
    _persistenceService.setAccentColorValue(color.toARGB32());
    state = state.copyWith(accentColor: color);
  }

  void setTrueBlack(bool isEnabled) {
    _persistenceService.setTrueBlackEnabled(isEnabled);
    state = state.copyWith(useTrueBlack: isEnabled);
  }

  /// Handle system theme changes automatically
  void handleSystemThemeChange(BuildContext context) {
    if (state.followSystemTheme) {
      final systemBrightness = MediaQuery.of(context).platformBrightness;
      final currentBrightness = state.getEffectiveBrightness(context);

      if (systemBrightness != currentBrightness) {
        // System theme changed, update silently
        state = state.copyWith(themeMode: ThemeMode.system);
      }
    }
  }
}
