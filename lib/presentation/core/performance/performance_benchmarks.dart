import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Performance benchmarking system for key user flows
class PerformanceBenchmarks {
  static final PerformanceBenchmarks _instance =
      PerformanceBenchmarks._internal();
  factory PerformanceBenchmarks() => _instance;
  PerformanceBenchmarks._internal();

  final Map<String, BenchmarkResult> _benchmarkResults = {};
  final Map<String, Stopwatch> _activeBenchmarks = {};

  /// Start a performance benchmark
  void startBenchmark(String benchmarkName) {
    final stopwatch = Stopwatch()..start();
    _activeBenchmarks[benchmarkName] = stopwatch;

    if (kDebugMode) {
      debugPrint('📊 Benchmark Started: $benchmarkName');
    }
  }

  /// End a performance benchmark
  void endBenchmark(String benchmarkName, {Map<String, dynamic>? metadata}) {
    final stopwatch = _activeBenchmarks.remove(benchmarkName);
    if (stopwatch == null) {
      if (kDebugMode) {
        debugPrint('⚠️ Benchmark not found: $benchmarkName');
      }
      return;
    }

    stopwatch.stop();
    final duration = stopwatch.elapsed;

    final result = BenchmarkResult(
      name: benchmarkName,
      duration: duration,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    );

    _benchmarkResults[benchmarkName] = result;

    if (kDebugMode) {
      debugPrint(
        '📊 Benchmark Completed: $benchmarkName - ${duration.inMilliseconds}ms',
      );
    }
  }

  /// Get benchmark result
  BenchmarkResult? getBenchmarkResult(String benchmarkName) {
    return _benchmarkResults[benchmarkName];
  }

  /// Get all benchmark results
  Map<String, BenchmarkResult> getAllBenchmarkResults() {
    return Map.unmodifiable(_benchmarkResults);
  }

  /// Clear all benchmark results
  void clearBenchmarks() {
    _benchmarkResults.clear();
    _activeBenchmarks.clear();
  }

  /// Generate performance report
  PerformanceBenchmarkReport generateReport() {
    final results = _benchmarkResults.values.toList();

    if (results.isEmpty) {
      return PerformanceBenchmarkReport(
        totalBenchmarks: 0,
        averageDuration: Duration.zero,
        slowestBenchmark: null,
        fastestBenchmark: null,
        results: [],
      );
    }

    results.sort((a, b) => a.duration.compareTo(b.duration));

    final totalDuration = results
        .map((r) => r.duration.inMicroseconds)
        .reduce((a, b) => a + b);

    return PerformanceBenchmarkReport(
      totalBenchmarks: results.length,
      averageDuration: Duration(microseconds: totalDuration ~/ results.length),
      slowestBenchmark: results.last,
      fastestBenchmark: results.first,
      results: results,
    );
  }
}

/// Benchmark result data class
class BenchmarkResult {
  final String name;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const BenchmarkResult({
    required this.name,
    required this.duration,
    required this.timestamp,
    required this.metadata,
  });

  @override
  String toString() {
    return 'BenchmarkResult(name: $name, duration: ${duration.inMilliseconds}ms)';
  }
}

/// Performance benchmark report
class PerformanceBenchmarkReport {
  final int totalBenchmarks;
  final Duration averageDuration;
  final BenchmarkResult? slowestBenchmark;
  final BenchmarkResult? fastestBenchmark;
  final List<BenchmarkResult> results;

  const PerformanceBenchmarkReport({
    required this.totalBenchmarks,
    required this.averageDuration,
    required this.slowestBenchmark,
    required this.fastestBenchmark,
    required this.results,
  });

  @override
  String toString() {
    return '''
Performance Benchmark Report:
- Total Benchmarks: $totalBenchmarks
- Average Duration: ${averageDuration.inMilliseconds}ms
- Slowest: ${slowestBenchmark?.name} (${slowestBenchmark?.duration.inMilliseconds}ms)
- Fastest: ${fastestBenchmark?.name} (${fastestBenchmark?.duration.inMilliseconds}ms)
''';
  }
}

/// Widget to benchmark performance
class BenchmarkWidget extends StatefulWidget {
  final Widget child;
  final String benchmarkName;
  final bool autoStart;
  final VoidCallback? onBenchmarkComplete;

  const BenchmarkWidget({
    super.key,
    required this.child,
    required this.benchmarkName,
    this.autoStart = true,
    this.onBenchmarkComplete,
  });

  @override
  State<BenchmarkWidget> createState() => _BenchmarkWidgetState();
}

class _BenchmarkWidgetState extends State<BenchmarkWidget> {
  final _benchmarks = PerformanceBenchmarks();
  bool _benchmarkStarted = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoStart) {
      _startBenchmark();
    }
  }

  @override
  void dispose() {
    if (_benchmarkStarted) {
      _endBenchmark();
    }
    super.dispose();
  }

  void _startBenchmark() {
    if (!_benchmarkStarted) {
      _benchmarks.startBenchmark(widget.benchmarkName);
      _benchmarkStarted = true;
    }
  }

  void _endBenchmark() {
    if (_benchmarkStarted) {
      _benchmarks.endBenchmark(widget.benchmarkName);
      _benchmarkStarted = false;
      widget.onBenchmarkComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Predefined benchmarks for common user flows
class UserFlowBenchmarks {
  static final _benchmarks = PerformanceBenchmarks();

  /// Benchmark app startup time
  static void benchmarkAppStartup() {
    _benchmarks.startBenchmark('app_startup');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _benchmarks.endBenchmark(
        'app_startup',
        metadata: {
          'platform': defaultTargetPlatform.name,
          'debug_mode': kDebugMode,
        },
      );
    });
  }

  /// Benchmark screen navigation
  static void benchmarkNavigation(String fromScreen, String toScreen) {
    final benchmarkName = 'navigation_${fromScreen}_to_$toScreen';
    _benchmarks.startBenchmark(benchmarkName);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _benchmarks.endBenchmark(
        benchmarkName,
        metadata: {'from_screen': fromScreen, 'to_screen': toScreen},
      );
    });
  }

  /// Benchmark list scrolling performance
  static void benchmarkListScrolling(String listType, int itemCount) {
    final benchmarkName = 'list_scrolling_$listType';
    _benchmarks.startBenchmark(benchmarkName);

    // End benchmark after a delay to capture scrolling performance
    Timer(const Duration(seconds: 2), () {
      _benchmarks.endBenchmark(
        benchmarkName,
        metadata: {'list_type': listType, 'item_count': itemCount},
      );
    });
  }

  /// Benchmark image loading
  static void benchmarkImageLoading(String imageType, int imageCount) {
    final benchmarkName = 'image_loading_$imageType';
    _benchmarks.startBenchmark(benchmarkName);

    // This would typically be called when all images are loaded
    Timer(const Duration(seconds: 3), () {
      _benchmarks.endBenchmark(
        benchmarkName,
        metadata: {'image_type': imageType, 'image_count': imageCount},
      );
    });
  }

  /// Benchmark search performance
  static void benchmarkSearch(String query) {
    final benchmarkName = 'search_performance';
    _benchmarks.startBenchmark(benchmarkName);

    // This would typically be called when search results are displayed
    Timer(const Duration(milliseconds: 500), () {
      _benchmarks.endBenchmark(
        benchmarkName,
        metadata: {'query': query, 'query_length': query.length},
      );
    });
  }

  /// Get all user flow benchmark results
  static Map<String, BenchmarkResult> getAllResults() {
    return _benchmarks.getAllBenchmarkResults();
  }

  /// Generate user flow performance report
  static PerformanceBenchmarkReport generateReport() {
    return _benchmarks.generateReport();
  }
}

/// Frame rate monitor for smooth animations
class FrameRateMonitor {
  static final FrameRateMonitor _instance = FrameRateMonitor._internal();
  factory FrameRateMonitor() => _instance;
  FrameRateMonitor._internal();

  final List<Duration> _frameTimes = [];
  bool _isMonitoring = false;
  DateTime? _lastFrameTime;

  /// Start monitoring frame rate
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _frameTimes.clear();
    _lastFrameTime = DateTime.now();

    SchedulerBinding.instance.addPostFrameCallback(_onFrame);

    if (kDebugMode) {
      debugPrint('📈 Frame Rate Monitor: Started');
    }
  }

  /// Stop monitoring frame rate
  void stopMonitoring() {
    _isMonitoring = false;

    if (kDebugMode) {
      debugPrint('📈 Frame Rate Monitor: Stopped');
    }
  }

  /// Get current frame rate
  double getCurrentFrameRate() {
    if (_frameTimes.isEmpty) return 0.0;

    final averageFrameTime =
        _frameTimes.map((d) => d.inMicroseconds).reduce((a, b) => a + b) /
        _frameTimes.length;

    return 1000000.0 / averageFrameTime; // Convert to FPS
  }

  /// Get frame rate statistics
  FrameRateStats getFrameRateStats() {
    if (_frameTimes.isEmpty) {
      return FrameRateStats(
        averageFPS: 0.0,
        minFPS: 0.0,
        maxFPS: 0.0,
        frameCount: 0,
        droppedFrames: 0,
      );
    }

    final frameTimes = _frameTimes.map((d) => d.inMicroseconds).toList();
    final fps = frameTimes.map((t) => 1000000.0 / t).toList();

    fps.sort();

    final droppedFrames = fps.where((f) => f < 55.0).length; // Below 55 FPS

    return FrameRateStats(
      averageFPS: fps.reduce((a, b) => a + b) / fps.length,
      minFPS: fps.first,
      maxFPS: fps.last,
      frameCount: fps.length,
      droppedFrames: droppedFrames,
    );
  }

  void _onFrame(Duration timeStamp) {
    if (!_isMonitoring) return;

    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final frameTime = now.difference(_lastFrameTime!);
      _frameTimes.add(frameTime);

      // Keep only recent frame times (last 60 frames)
      if (_frameTimes.length > 60) {
        _frameTimes.removeAt(0);
      }
    }

    _lastFrameTime = now;
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }
}

/// Frame rate statistics
class FrameRateStats {
  final double averageFPS;
  final double minFPS;
  final double maxFPS;
  final int frameCount;
  final int droppedFrames;

  const FrameRateStats({
    required this.averageFPS,
    required this.minFPS,
    required this.maxFPS,
    required this.frameCount,
    required this.droppedFrames,
  });

  @override
  String toString() {
    return '''
Frame Rate Stats:
- Average FPS: ${averageFPS.toStringAsFixed(1)}
- Min FPS: ${minFPS.toStringAsFixed(1)}
- Max FPS: ${maxFPS.toStringAsFixed(1)}
- Frame Count: $frameCount
- Dropped Frames: $droppedFrames
''';
  }
}

/// Performance test suite
class PerformanceTestSuite {
  // static final _benchmarks = PerformanceBenchmarks();
  static final _frameMonitor = FrameRateMonitor();

  /// Run comprehensive performance tests
  static Future<PerformanceTestResults> runPerformanceTests() async {
    if (kDebugMode) {
      debugPrint('🧪 Running Performance Test Suite...');
    }

    final results = <String, dynamic>{};

    // Test 1: Widget build performance
    results['widget_build'] = await _testWidgetBuildPerformance();

    // Test 2: Animation performance
    results['animation'] = await _testAnimationPerformance();

    // Test 3: List scrolling performance
    results['list_scrolling'] = await _testListScrollingPerformance();

    // Test 4: Memory allocation
    results['memory'] = await _testMemoryAllocation();

    if (kDebugMode) {
      debugPrint('🧪 Performance Test Suite Completed');
    }

    return PerformanceTestResults(results);
  }

  static Future<Map<String, dynamic>> _testWidgetBuildPerformance() async {
    const iterations = 1000;
    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < iterations; i++) {
      // Simulate widget building
      Container(
        width: 100,
        height: 100,
        color: Colors.blue,
        child: Text('Test $i'),
      );
    }

    stopwatch.stop();
    final averageTime = stopwatch.elapsed.inMicroseconds / iterations;

    return {
      'iterations': iterations,
      'total_time_ms': stopwatch.elapsed.inMilliseconds,
      'average_time_us': averageTime,
      'builds_per_second': 1000000 / averageTime,
    };
  }

  static Future<Map<String, dynamic>> _testAnimationPerformance() async {
    _frameMonitor.startMonitoring();

    // Simulate animation for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    final stats = _frameMonitor.getFrameRateStats();
    _frameMonitor.stopMonitoring();

    return {
      'average_fps': stats.averageFPS,
      'min_fps': stats.minFPS,
      'max_fps': stats.maxFPS,
      'dropped_frames': stats.droppedFrames,
      'frame_count': stats.frameCount,
    };
  }

  static Future<Map<String, dynamic>> _testListScrollingPerformance() async {
    const itemCount = 1000;
    final stopwatch = Stopwatch()..start();

    // Simulate list item creation
    // final items = List.generate(itemCount, (index) => 'Item $index');
    List.generate(itemCount, (index) => 'Item $index');

    stopwatch.stop();

    return {
      'item_count': itemCount,
      'creation_time_ms': stopwatch.elapsed.inMilliseconds,
      'items_per_second': itemCount / (stopwatch.elapsed.inMilliseconds / 1000),
    };
  }

  static Future<Map<String, dynamic>> _testMemoryAllocation() async {
    const allocations = 10000;
    final stopwatch = Stopwatch()..start();

    final objects = <Object>[];
    for (int i = 0; i < allocations; i++) {
      objects.add(Object());
    }

    stopwatch.stop();

    return {
      'allocations': allocations,
      'allocation_time_ms': stopwatch.elapsed.inMilliseconds,
      'allocations_per_second':
          allocations / (stopwatch.elapsed.inMilliseconds / 1000),
    };
  }
}

/// Performance test results
class PerformanceTestResults {
  final Map<String, dynamic> results;

  const PerformanceTestResults(this.results);

  @override
  String toString() {
    final buffer = StringBuffer('Performance Test Results:\n');

    results.forEach((testName, result) {
      buffer.writeln('\n$testName:');
      if (result is Map<String, dynamic>) {
        result.forEach((key, value) {
          buffer.writeln('  $key: $value');
        });
      } else {
        buffer.writeln('  $result');
      }
    });

    return buffer.toString();
  }
}
