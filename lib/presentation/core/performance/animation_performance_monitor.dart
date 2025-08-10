import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Performance monitoring system for animations
class AnimationPerformanceMonitor {
  static final AnimationPerformanceMonitor _instance =
      AnimationPerformanceMonitor._internal();
  factory AnimationPerformanceMonitor() => _instance;
  AnimationPerformanceMonitor._internal();

  final List<FrameTiming> _frameMetrics = [];
  final Map<String, AnimationMetrics> _animationMetrics = {};
  bool _isMonitoring = false;

  /// Start monitoring animation performance
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    SchedulerBinding.instance.addTimingsCallback(_onFrameMetrics);

    if (kDebugMode) {
      debugPrint('🎬 Animation Performance Monitor: Started');
    }
  }

  /// Stop monitoring animation performance
  void stopMonitoring() {
    if (!_isMonitoring) return;

    _isMonitoring = false;
    SchedulerBinding.instance.removeTimingsCallback(_onFrameMetrics);

    if (kDebugMode) {
      debugPrint('🎬 Animation Performance Monitor: Stopped');
    }
  }

  /// Record animation metrics
  void recordAnimation(
    String animationName,
    Duration duration,
    int frameCount,
  ) {
    final metrics = AnimationMetrics(
      name: animationName,
      duration: duration,
      frameCount: frameCount,
      timestamp: DateTime.now(),
    );

    _animationMetrics[animationName] = metrics;

    if (kDebugMode) {
      final fps = (frameCount * 1000) / duration.inMilliseconds;
      debugPrint(
        '🎬 Animation "$animationName": ${fps.toStringAsFixed(1)} FPS',
      );
    }
  }

  /// Get performance report
  PerformanceReport getPerformanceReport() {
    final averageFPS = _calculateAverageFPS();
    final droppedFrames = _calculateDroppedFrames();
    final slowAnimations = _getSlowAnimations();

    return PerformanceReport(
      averageFPS: averageFPS,
      droppedFrames: droppedFrames,
      slowAnimations: slowAnimations,
      totalAnimations: _animationMetrics.length,
      monitoringDuration: _getMonitoringDuration(),
    );
  }

  /// Get current performance metrics
  PerformanceMetrics getCurrentMetrics() {
    final averageFrameTime = _calculateAverageFrameTime();
    final droppedFrames = _calculateDroppedFrames();
    final memoryUsage = _getMemoryUsage();

    return PerformanceMetrics(
      averageFrameTime: averageFrameTime,
      droppedFrames: droppedFrames,
      memoryUsage: memoryUsage,
    );
  }

  /// Clear all metrics
  void clearMetrics() {
    _frameMetrics.clear();
    _animationMetrics.clear();
  }

  double _calculateAverageFrameTime() {
    if (_frameMetrics.isEmpty) return 0.0;

    final totalFrameTime = _frameMetrics
        .map((m) => m.totalSpan.inMicroseconds)
        .where((time) => time > 0)
        .fold(0, (a, b) => a + b);

    return totalFrameTime > 0 
        ? (totalFrameTime / _frameMetrics.length) / 1000.0 
        : 0.0;
  }

  double _getMemoryUsage() {
    // This is a simplified memory usage calculation
    // In a real implementation, you might use dart:developer or platform channels
    return 50.0; // Placeholder value in MB
  }

  void _onFrameMetrics(List<FrameTiming> metrics) {
    _frameMetrics.addAll(metrics);

    // Keep only recent metrics (last 1000 frames)
    if (_frameMetrics.length > 1000) {
      _frameMetrics.removeRange(0, _frameMetrics.length - 1000);
    }
  }

  double _calculateAverageFPS() {
    if (_frameMetrics.isEmpty) return 0.0;

    final totalFrameTime = _frameMetrics
        .map((m) => m.totalSpan.inMicroseconds)
        .where((time) => time > 0)
        .fold(0, (a, b) => a + b);

    if (totalFrameTime == 0) return 0.0;
    
    final averageFrameTime = totalFrameTime / _frameMetrics.length;
    return 1000000.0 / averageFrameTime; // Convert to FPS
  }

  int _calculateDroppedFrames() {
    if (_frameMetrics.isEmpty) return 0;

    const targetFrameTime = Duration(microseconds: 16667); // 60 FPS
    return _frameMetrics
        .where((m) => m.totalSpan.inMicroseconds > targetFrameTime.inMicroseconds)
        .length;
  }

  List<String> _getSlowAnimations() {
    const slowThreshold = 30.0; // FPS threshold

    return _animationMetrics.entries
        .where((entry) {
          final metrics = entry.value;
          final fps =
              (metrics.frameCount * 1000) / metrics.duration.inMilliseconds;
          return fps < slowThreshold;
        })
        .map((entry) => entry.key)
        .toList();
  }

  Duration _getMonitoringDuration() {
    if (_frameMetrics.isEmpty) return Duration.zero;

    // FrameTiming doesn't have vsyncStart, use totalSpan as approximation
    final totalMilliseconds = _frameMetrics.length * 16;
    return Duration(milliseconds: totalMilliseconds);
  }
}

/// Performance metrics data class
class PerformanceMetrics {
  final double averageFrameTime;
  final int droppedFrames;
  final double memoryUsage;

  const PerformanceMetrics({
    required this.averageFrameTime,
    required this.droppedFrames,
    required this.memoryUsage,
  });
}

/// Animation metrics data class
class AnimationMetrics {
  final String name;
  final Duration duration;
  final int frameCount;
  final DateTime timestamp;

  const AnimationMetrics({
    required this.name,
    required this.duration,
    required this.frameCount,
    required this.timestamp,
  });

  double get fps => (frameCount * 1000) / duration.inMilliseconds;
}

/// Performance report data class
class PerformanceReport {
  final double averageFPS;
  final int droppedFrames;
  final List<String> slowAnimations;
  final int totalAnimations;
  final Duration monitoringDuration;

  const PerformanceReport({
    required this.averageFPS,
    required this.droppedFrames,
    required this.slowAnimations,
    required this.totalAnimations,
    required this.monitoringDuration,
  });

  @override
  String toString() {
    return '''
Performance Report:
- Average FPS: ${averageFPS.toStringAsFixed(1)}
- Dropped Frames: $droppedFrames
- Slow Animations: ${slowAnimations.join(', ')}
- Total Animations: $totalAnimations
- Monitoring Duration: ${monitoringDuration.inSeconds}s
''';
  }
}

/// Widget to monitor animation performance
class AnimationPerformanceWidget extends StatefulWidget {
  final Widget child;
  final String? animationName;
  final bool enableMonitoring;

  const AnimationPerformanceWidget({
    super.key,
    required this.child,
    this.animationName,
    this.enableMonitoring = kDebugMode,
  });

  @override
  State<AnimationPerformanceWidget> createState() =>
      _AnimationPerformanceWidgetState();
}

class _AnimationPerformanceWidgetState extends State<AnimationPerformanceWidget>
    with TickerProviderStateMixin {
  final _monitor = AnimationPerformanceMonitor();
  int _frameCount = 0;
  DateTime? _animationStart;

  @override
  void initState() {
    super.initState();
    if (widget.enableMonitoring) {
      _monitor.startMonitoring();
      _startAnimationTracking();
    }
  }

  @override
  void dispose() {
    if (widget.enableMonitoring) {
      _stopAnimationTracking();
    }
    super.dispose();
  }

  void _startAnimationTracking() {
    _animationStart = DateTime.now();
    _frameCount = 0;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _trackFrame();
    });
  }

  void _trackFrame() {
    if (!mounted) return;

    _frameCount++;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _trackFrame();
    });
  }

  void _stopAnimationTracking() {
    if (_animationStart != null && widget.animationName != null) {
      final duration = DateTime.now().difference(_animationStart!);
      _monitor.recordAnimation(widget.animationName!, duration, _frameCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Performance overlay for debugging
class PerformanceOverlay extends StatefulWidget {
  final Widget child;
  final bool showOverlay;

  const PerformanceOverlay({
    super.key,
    required this.child,
    this.showOverlay = kDebugMode,
  });

  @override
  State<PerformanceOverlay> createState() => _PerformanceOverlayState();
}

class _PerformanceOverlayState extends State<PerformanceOverlay> {
  final _monitor = AnimationPerformanceMonitor();
  PerformanceReport? _lastReport;

  @override
  void initState() {
    super.initState();
    if (widget.showOverlay) {
      _monitor.startMonitoring();
      _updateReport();
    }
  }

  @override
  void dispose() {
    _monitor.stopMonitoring();
    super.dispose();
  }

  void _updateReport() {
    if (!mounted) return;

    setState(() {
      _lastReport = _monitor.getPerformanceReport();
    });

    Future.delayed(const Duration(seconds: 1), _updateReport);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showOverlay && _lastReport != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'FPS: ${_lastReport!.averageFPS.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: _lastReport!.averageFPS >= 55
                          ? Colors.green
                          : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Dropped: ${_lastReport!.droppedFrames}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    'Anims: ${_lastReport!.totalAnimations}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
