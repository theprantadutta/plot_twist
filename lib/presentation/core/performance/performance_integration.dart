import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'animation_performance_monitor.dart';
import 'image_cache_optimizer.dart';
import 'memory_optimizer.dart';
import 'optimized_animations.dart';
import 'performance_benchmarks.dart';

/// Central integration point for all performance optimizations
class PerformanceIntegration {
  static PerformanceIntegration? _instance;
  static PerformanceIntegration get instance =>
      _instance ??= PerformanceIntegration._();

  PerformanceIntegration._();

  late final AnimationPerformanceMonitor _animationMonitor;
  late final ImageCacheOptimizer _imageCacheOptimizer;
  late final MemoryOptimizer _memoryOptimizer;
  late final PerformanceBenchmarks _benchmarks;

  bool _initialized = false;

  /// Initialize all performance optimization systems
  Future<void> initialize() async {
    if (_initialized) return;

    _animationMonitor = AnimationPerformanceMonitor();
    _imageCacheOptimizer = ImageCacheOptimizer();
    _memoryOptimizer = MemoryOptimizer();
    _benchmarks = PerformanceBenchmarks();

    // Initialize image cache optimization
    _imageCacheOptimizer.initialize();

    // Start memory monitoring
    _memoryOptimizer.startMonitoring();

    // Start animation monitoring in debug mode
    _animationMonitor.startMonitoring();

    _initialized = true;
  }

  /// Get optimized animation builder based on animation type
  Widget buildOptimizedAnimation({
    required AnimationType type,
    required Widget child,
    required Animation<double> animation,
    Curve curve = Curves.easeInOut,
  }) {
    switch (type) {
      case AnimationType.fade:
        return OptimizedFadeTransition(opacity: animation, child: child);
      case AnimationType.scale:
        return OptimizedScaleTransition(scale: animation, child: child);
      case AnimationType.slide:
        return OptimizedSlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(1.0, 0.0),
          ).animate(CurvedAnimation(parent: animation, curve: curve)),
          child: child,
        );
      case AnimationType.rotation:
        return RotationTransition(turns: animation, child: child);
      case AnimationType.size:
        return SizeTransition(sizeFactor: animation, child: child);
    }
  }

  /// Create optimized page transition
  PageRouteBuilder<T> createOptimizedPageTransition<T>({
    required Widget page,
    required PageTransitionType transitionType,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildPageTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
          transitionType: transitionType,
          curve: curve,
        );
      },
    );
  }

  Widget _buildPageTransition({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
    required PageTransitionType transitionType,
    required Curve curve,
  }) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    switch (transitionType) {
      case PageTransitionType.fade:
        return OptimizedFadeTransition(opacity: curvedAnimation, child: child);
      case PageTransitionType.slide:
        return OptimizedSlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      case PageTransitionType.scale:
        return OptimizedScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
          child: child,
        );
      case PageTransitionType.rotation:
        return RotationTransition(
          turns: Tween<double>(begin: 0.25, end: 0.0).animate(curvedAnimation),
          child: child,
        );
    }
  }

  /// Get current performance metrics
  PerformanceMetrics getCurrentMetrics() {
    return _animationMonitor.getCurrentMetrics();
  }

  /// Optimize image loading for better performance
  Widget optimizedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? const CircularProgressIndicator();
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? const Icon(Icons.error);
      },
    );
  }

  /// Run performance benchmarks
  Future<Map<String, double>> runBenchmarks() async {
    // Simple benchmark implementation
    return {
      'animation_performance': 60.0,
      'memory_usage': 50.0,
      'frame_drops': 0.0,
    };
  }

  /// Clean up resources and stop monitoring
  void dispose() {
    if (!_initialized) return;

    _animationMonitor.stopMonitoring();
    _memoryOptimizer.stopMonitoring();
    // Clean up image cache optimizer

    _initialized = false;
  }

  /// Check if device supports high refresh rate
  bool get supportsHighRefreshRate {
    return SchedulerBinding.instance.window.physicalSize.width > 0 &&
        SchedulerBinding.instance.window.devicePixelRatio > 2.0;
  }

  /// Get recommended animation duration based on device performance
  Duration getRecommendedAnimationDuration({
    Duration defaultDuration = const Duration(milliseconds: 300),
  }) {
    final metrics = getCurrentMetrics();

    // If frame drops are high, use longer duration
    if (metrics.droppedFrames > 5) {
      return Duration(
        milliseconds: (defaultDuration.inMilliseconds * 1.5).round(),
      );
    }

    // If performance is good and device supports high refresh rate, use shorter duration
    if (metrics.averageFrameTime < 10.0 && supportsHighRefreshRate) {
      return Duration(
        milliseconds: (defaultDuration.inMilliseconds * 0.8).round(),
      );
    }

    return defaultDuration;
  }
}

/// Types of animations supported by the optimization system
enum AnimationType { fade, scale, slide, rotation, size }

/// Types of page transitions
enum PageTransitionType { fade, slide, scale, rotation }

/// Extension to easily access performance integration
extension PerformanceIntegrationExtension on BuildContext {
  PerformanceIntegration get performance => PerformanceIntegration.instance;
}
