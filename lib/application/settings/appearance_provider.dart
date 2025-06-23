import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/local/persistence_service.dart';
import '../home/home_providers.dart';

part 'appearance_provider.g.dart';

// A class to hold our appearance state
@immutable
class AppearanceState {
  final ThemeMode themeMode;
  final Color accentColor;
  final bool useTrueBlack;

  const AppearanceState({
    required this.themeMode,
    required this.accentColor,
    required this.useTrueBlack,
  });

  AppearanceState copyWith({
    ThemeMode? themeMode,
    Color? accentColor,
    bool? useTrueBlack,
  }) {
    return AppearanceState(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      useTrueBlack: useTrueBlack ?? this.useTrueBlack,
    );
  }
}

// The Notifier that manages the state
@riverpod
class AppearanceNotifier extends _$AppearanceNotifier {
  late PersistenceService _persistenceService;

  @override
  AppearanceState build() {
    _persistenceService = ref.watch(persistenceServiceProvider);
    return AppearanceState(
      themeMode: _persistenceService.getThemeMode(),
      accentColor: Color(_persistenceService.getAccentColorValue()),
      useTrueBlack: _persistenceService.getTrueBlackEnabled(),
    );
  }

  void setThemeMode(ThemeMode mode) {
    _persistenceService.setThemeMode(mode);
    state = state.copyWith(themeMode: mode);
  }

  void setAccentColor(Color color) {
    _persistenceService.setAccentColorValue(color.value);
    state = state.copyWith(accentColor: color);
  }

  void setTrueBlack(bool isEnabled) {
    _persistenceService.setTrueBlackEnabled(isEnabled);
    state = state.copyWith(useTrueBlack: isEnabled);
  }
}
