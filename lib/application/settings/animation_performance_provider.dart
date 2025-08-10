import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/core/performance/performance_integration.dart';
import '../home/home_providers.dart';

part 'animation_performance_provider.g.dart';

/// Performance modes for different device capabilities
enum PerformanceMode { battery, balanced, performance }

/// Animation performance settings state
class AnimationPerformanceSettings {
  final PerformanceMode performanceMode;
  final bool reduceMotion;
  final bool useHighRefreshRate;
  final bool useHardwareAcceleration;
  final double animationDurationMultiplier;
  final bool enablePerformanceMonitoring;

  const AnimationPerformanceSettings({
    this.performanceMode = PerformanceMode.balanced,
    this.reduceMotion = false,
    this.useHighRefreshRate = true,
    this.useHardwareAcceleration = true,
    this.animationDurationMultiplier = 1.0,
    this.enablePerformanceMonitoring = false,
  });

  AnimationPerformanceSettings copyWith({
    PerformanceMode? performanceMode,
    bool? reduceMotion,
    bool? useHighRefreshRate,
    bool? useHardwareAcceleration,
    double? animationDurationMultiplier,
    bool? enablePerformanceMonitoring,
  }) {
    return AnimationPerformanceSettings(
      performanceMode: performanceMode ?? this.performanceMode,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      useHighRefreshRate: useHighRefreshRate ?? this.useHighRefreshRate,
      useHardwareAcceleration:
          useHardwareAcceleration ?? this.useHardwareAcceleration,
      animationDurationMultiplier:
          animationDurationMultiplier ?? this.animationDurationMultiplier,
      enablePerformanceMonitoring:
          enablePerformanceMonitoring ?? this.enablePerformanceMonitoring,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'performanceMode': performanceMode.index,
      'reduceMotion': reduceMotion,
      'useHighRefreshRate': useHighRefreshRate,
      'useHardwareAcceleration': useHardwareAcceleration,
      'animationDurationMultiplier': animationDurationMultiplier,
      'enablePerformanceMonitoring': enablePerformanceMonitoring,
    };
  }

  factory AnimationPerformanceSettings.fromJson(Map<String, dynamic> json) {
    return AnimationPerformanceSettings(
      performanceMode: PerformanceMode.values[json['performanceMode'] ?? 1],
      reduceMotion: json['reduceMotion'] ?? false,
      useHighRefreshRate: json['useHighRefreshRate'] ?? true,
      useHardwareAcceleration: json['useHardwareAcceleration'] ?? true,
      animationDurationMultiplier: (json['animationDurationMultiplier'] ?? 1.0)
          .toDouble(),
      enablePerformanceMonitoring: json['enablePerformanceMonitoring'] ?? false,
    );
  }
}

/// Provider for animation performance settings
@riverpod
class AnimationPerformanceNotifier extends _$AnimationPerformanceNotifier {
  static const String _storageKey = 'animation_performance_settings';

  @override
  AnimationPerformanceSettings build() {
    _loadSettings();
    return const AnimationPerformanceSettings();
  }

  /// Load settings from storage
  Future<void> _loadSettings() async {
    try {
      final persistenceService = ref.read(persistenceServiceProvider);
      final data = await persistenceService.getData(_storageKey);

      if (data != null) {
        state = AnimationPerformanceSettings.fromJson(data);
      }
    } catch (e) {
      // Use default settings if loading fails
      state = const AnimationPerformanceSettings();
    }
  }

  /// Save settings to storage
  Future<void> _saveSettings() async {
    try {
      final persistenceService = ref.read(persistenceServiceProvider);
      await persistenceService.saveData(_storageKey, state.toJson());
    } catch (e) {
      // Handle save error silently
    }
  }

  /// Set performance mode
  Future<void> setPerformanceMode(PerformanceMode mode) async {
    state = state.copyWith(performanceMode: mode);
    await _saveSettings();
  }

  /// Set reduce motion
  Future<void> setReduceMotion(bool value) async {
    state = state.copyWith(reduceMotion: value);
    await _saveSettings();
  }

  /// Set high refresh rate usage
  Future<void> setUseHighRefreshRate(bool value) async {
    state = state.copyWith(useHighRefreshRate: value);
    await _saveSettings();
  }

  /// Set hardware acceleration usage
  Future<void> setUseHardwareAcceleration(bool value) async {
    state = state.copyWith(useHardwareAcceleration: value);
    await _saveSettings();
  }

  /// Set animation duration multiplier
  Future<void> setAnimationDurationMultiplier(double multiplier) async {
    if (multiplier >= 0.5 && multiplier <= 2.0) {
      state = state.copyWith(animationDurationMultiplier: multiplier);
      await _saveSettings();
    }
  }

  /// Set performance monitoring
  Future<void> setEnablePerformanceMonitoring(bool value) async {
    state = state.copyWith(enablePerformanceMonitoring: value);
    await _saveSettings();
  }

  /// Reset to default settings
  Future<void> resetToDefaults() async {
    state = const AnimationPerformanceSettings();
    await _saveSettings();
  }

  /// Get current performance metrics
  dynamic getCurrentMetrics() {
    return PerformanceIntegration.instance.getCurrentMetrics();
  }

  /// Get recommended animation duration based on settings and performance
  Duration getRecommendedDuration(Duration baseDuration) {
    Duration duration = baseDuration;

    // Apply animation duration multiplier
    duration = Duration(
      milliseconds:
          (duration.inMilliseconds * state.animationDurationMultiplier).round(),
    );

    // Apply reduce motion
    if (state.reduceMotion) {
      duration = Duration(
        milliseconds: (duration.inMilliseconds * 0.5).round(),
      );
    }

    // Apply performance mode adjustments
    switch (state.performanceMode) {
      case PerformanceMode.battery:
        duration = Duration(
          milliseconds: (duration.inMilliseconds * 0.7).round(),
        );
        break;
      case PerformanceMode.performance:
        duration = PerformanceIntegration.instance
            .getRecommendedAnimationDuration(defaultDuration: duration);
        break;
      case PerformanceMode.balanced:
        // Use default duration
        break;
    }

    return duration;
  }
}
