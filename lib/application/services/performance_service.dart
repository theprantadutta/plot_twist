import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'performance_service.g.dart';

/// Service for monitoring and optimizing app performance
class PerformanceService {
  // static const int _targetFps = 60;
  static const Duration _frameTime = Duration(
    microseconds: 16667,
  ); // 60fps = 16.67ms per frame

  final List<Duration> _frameTimes = [];
  final List<int> _memoryUsage = [];
  int _frameCount = 0;
  DateTime? _lastFrameTime;

  /// Initialize performance monitoring
  void initialize() {
    if (kDebugMode) {
      SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);
      _startMemoryMonitoring();
    }
  }

  /// Monitor frame rendering performance
  void _onFrame(Duration timestamp) {
    final now = DateTime.now();

    if (_lastFrameTime != null) {
      final frameDuration = now.difference(_lastFrameTime!);
      _frameTimes.add(frameDuration);

      // Keep only last 60 frames for analysis
      if (_frameTimes.length > 60) {
        _frameTimes.removeAt(0);
      }

      // Log performance issues
      if (frameDuration > _frameTime * 1.5) {
        developer.log(
          'Frame drop detected: ${frameDuration.inMicroseconds}μs',
          name: 'PerformanceService',
        );
      }
    }

    _lastFrameTime = now;
    _frameCount++;
  }

  /// Start monitoring memory usage
  void _startMemoryMonitoring() {
    if (Platform.isAndroid || Platform.isIOS) {
      // Monitor memory every 5 seconds
      Stream.periodic(const Duration(seconds: 5)).listen((_) {
        _recordMemoryUsage();
      });
    }
  }

  /// Record current memory usage
  void _recordMemoryUsage() {
    // This is a simplified memory monitoring
    // In production, you might want to use platform-specific APIs
    final memoryInfo = ProcessInfo.currentRss;
    _memoryUsage.add(memoryInfo);

    // Keep only last 20 measurements
    if (_memoryUsage.length > 20) {
      _memoryUsage.removeAt(0);
    }

    // Log memory warnings
    if (memoryInfo > 100 * 1024 * 1024) {
      // 100MB threshold
      developer.log(
        'High memory usage: ${(memoryInfo / 1024 / 1024).toStringAsFixed(1)}MB',
        name: 'PerformanceService',
      );
    }
  }

  /// Get current FPS
  double getCurrentFps() {
    if (_frameTimes.isEmpty) return 0.0;

    final averageFrameTime =
        _frameTimes.map((d) => d.inMicroseconds).reduce((a, b) => a + b) /
        _frameTimes.length;

    return 1000000 / averageFrameTime; // Convert to FPS
  }

  /// Get performance metrics
  PerformanceMetrics getMetrics() {
    return PerformanceMetrics(
      currentFps: getCurrentFps(),
      averageFrameTime: _getAverageFrameTime(),
      frameDrops: _getFrameDropCount(),
      memoryUsage: _getCurrentMemoryUsage(),
      frameCount: _frameCount,
    );
  }

  Duration _getAverageFrameTime() {
    if (_frameTimes.isEmpty) return Duration.zero;

    final totalMicroseconds = _frameTimes
        .map((d) => d.inMicroseconds)
        .reduce((a, b) => a + b);

    return Duration(microseconds: totalMicroseconds ~/ _frameTimes.length);
  }

  int _getFrameDropCount() {
    return _frameTimes.where((duration) => duration > _frameTime * 1.5).length;
  }

  int _getCurrentMemoryUsage() {
    return _memoryUsage.isNotEmpty ? _memoryUsage.last : 0;
  }

  /// Optimize image loading for better performance
  static ImageProvider optimizeImageProvider(String imageUrl) {
    return NetworkImage(
      imageUrl,
      // Add caching headers
      headers: {'Cache-Control': 'max-age=3600'},
    );
  }

  /// Create optimized animation controller
  static AnimationController createOptimizedController({
    required Duration duration,
    required TickerProvider vsync,
    double? value,
    Duration? reverseDuration,
  }) {
    return AnimationController(
      duration: duration,
      reverseDuration: reverseDuration,
      vsync: vsync,
      value: value,
      // Use lower bound to prevent unnecessary rebuilds
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  /// Optimize list performance with viewport awareness
  static Widget optimizeListView({
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    ScrollController? controller,
    Axis scrollDirection = Axis.vertical,
    double? itemExtent,
    Widget Function(BuildContext, int)? separatorBuilder,
  }) {
    if (separatorBuilder != null) {
      return ListView.separated(
        controller: controller,
        scrollDirection: scrollDirection,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        separatorBuilder: separatorBuilder,
        // Optimize for performance
        cacheExtent: 250.0, // Cache 250 pixels ahead
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        addSemanticIndexes: false,
      );
    }

    return ListView.builder(
      controller: controller,
      scrollDirection: scrollDirection,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      itemExtent: itemExtent,
      // Optimize for performance
      cacheExtent: 250.0,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      addSemanticIndexes: false,
    );
  }

  /// Create performance-optimized grid view
  static Widget optimizeGridView({
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    required SliverGridDelegate gridDelegate,
    ScrollController? controller,
    Axis scrollDirection = Axis.vertical,
  }) {
    return GridView.builder(
      controller: controller,
      scrollDirection: scrollDirection,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      gridDelegate: gridDelegate,
      // Optimize for performance
      cacheExtent: 250.0,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      addSemanticIndexes: false,
    );
  }

  /// Dispose resources
  void dispose() {
    _frameTimes.clear();
    _memoryUsage.clear();
  }
}

/// Performance metrics data class
class PerformanceMetrics {
  final double currentFps;
  final Duration averageFrameTime;
  final int frameDrops;
  final int memoryUsage;
  final int frameCount;

  const PerformanceMetrics({
    required this.currentFps,
    required this.averageFrameTime,
    required this.frameDrops,
    required this.memoryUsage,
    required this.frameCount,
  });

  bool get isPerformanceGood => currentFps >= 55 && frameDrops < 5;

  String get memoryUsageFormatted {
    final mb = memoryUsage / 1024 / 1024;
    return '${mb.toStringAsFixed(1)}MB';
  }

  @override
  String toString() {
    return 'PerformanceMetrics('
        'fps: ${currentFps.toStringAsFixed(1)}, '
        'frameTime: ${averageFrameTime.inMicroseconds}μs, '
        'drops: $frameDrops, '
        'memory: $memoryUsageFormatted'
        ')';
  }
}

@riverpod
PerformanceService performanceService(Ref ref) {
  final service = PerformanceService();
  service.initialize();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
}
