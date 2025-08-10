import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'animation_performance_monitor.dart';
import 'optimized_animations.dart';

/// Performance tests for animation optimization
class AnimationPerformanceTests {
  static const int _testDuration = 5000; // 5 seconds
  static const int _targetFps = 60;
  static const double _acceptableFrameDropThreshold = 0.05; // 5%

  /// Test animation frame rate consistency
  static Future<PerformanceTestResult> testAnimationFrameRate({
    required Widget animationWidget,
    required String testName,
  }) async {
    final completer = Completer<PerformanceTestResult>();
    final monitor = AnimationPerformanceMonitor();
    final frameDrops = <double>[];
    final frameTimes = <double>[];

    late Timer testTimer;
    late Timer sampleTimer;

    // Start monitoring
    monitor.startMonitoring();

    // Sample frame data every 100ms
    sampleTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final metrics = monitor.getCurrentMetrics();
      frameTimes.add(metrics.averageFrameTime);

      if (metrics.droppedFrames > 0) {
        frameDrops.add(metrics.droppedFrames.toDouble());
      }
    });

    // Stop test after duration
    testTimer = Timer(Duration(milliseconds: _testDuration), () {
      sampleTimer.cancel();
      monitor.stopMonitoring();

      final finalMetrics = monitor.getCurrentMetrics();
      final averageFrameTime = frameTimes.isNotEmpty
          ? frameTimes.reduce((a, b) => a + b) / frameTimes.length
          : 0.0;

      final frameDropRate = frameDrops.isNotEmpty
          ? frameDrops.reduce((a, b) => a + b) /
                (_testDuration / 16.67) // 60fps baseline
          : 0.0;

      final result = PerformanceTestResult(
        testName: testName,
        averageFrameTime: averageFrameTime,
        frameDropRate: frameDropRate,
        totalFrameDrops: finalMetrics.droppedFrames,
        memoryUsage: finalMetrics.memoryUsage,
        passed: frameDropRate <= _acceptableFrameDropThreshold,
      );

      completer.complete(result);
    });

    return completer.future;
  }

  /// Test memory usage during animations
  static Future<MemoryTestResult> testAnimationMemoryUsage({
    required Widget animationWidget,
    required String testName,
  }) async {
    final completer = Completer<MemoryTestResult>();
    final monitor = AnimationPerformanceMonitor();
    final memorySnapshots = <double>[];

    late Timer testTimer;
    late Timer sampleTimer;

    // Start monitoring
    monitor.startMonitoring();
    final initialMemory = monitor.getCurrentMetrics().memoryUsage;

    // Sample memory every 200ms
    sampleTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      final metrics = monitor.getCurrentMetrics();
      memorySnapshots.add(metrics.memoryUsage);
    });

    // Stop test after duration
    testTimer = Timer(Duration(milliseconds: _testDuration), () {
      sampleTimer.cancel();
      monitor.stopMonitoring();

      final finalMemory = monitor.getCurrentMetrics().memoryUsage;
      final maxMemory = memorySnapshots.isNotEmpty
          ? memorySnapshots.reduce(max)
          : finalMemory;

      final memoryGrowth = finalMemory - initialMemory;
      final memoryLeakDetected =
          memoryGrowth > (initialMemory * 0.1); // 10% growth threshold

      final result = MemoryTestResult(
        testName: testName,
        initialMemory: initialMemory,
        finalMemory: finalMemory,
        maxMemory: maxMemory,
        memoryGrowth: memoryGrowth,
        memoryLeakDetected: memoryLeakDetected,
      );

      completer.complete(result);
    });

    return completer.future;
  }

  /// Test animation smoothness with different optimization levels
  static Future<OptimizationComparisonResult> compareOptimizationLevels({
    required Widget standardAnimation,
    required Widget optimizedAnimation,
    required String testName,
  }) async {
    // Test standard animation
    final standardResult = await testAnimationFrameRate(
      animationWidget: standardAnimation,
      testName: '${testName}_standard',
    );

    // Test optimized animation
    final optimizedResult = await testAnimationFrameRate(
      animationWidget: optimizedAnimation,
      testName: '${testName}_optimized',
    );

    final improvement =
        standardResult.frameDropRate - optimizedResult.frameDropRate;
    final improvementPercentage = standardResult.frameDropRate > 0
        ? (improvement / standardResult.frameDropRate) * 100
        : 0.0;

    return OptimizationComparisonResult(
      testName: testName,
      standardResult: standardResult,
      optimizedResult: optimizedResult,
      improvement: improvement,
      improvementPercentage: improvementPercentage,
    );
  }

  /// Run comprehensive animation performance test suite
  static Future<TestSuiteResult> runFullTestSuite() async {
    final results = <String, dynamic>{};

    // Test fade animations
    final fadeComparison = await compareOptimizationLevels(
      standardAnimation: _createStandardFadeAnimation(),
      optimizedAnimation: OptimizedFadeTransition(
        opacity: AlwaysStoppedAnimation(0.5),
        child: Container(width: 100, height: 100, color: Colors.blue),
      ),
      testName: 'fade_animation',
    );
    results['fade_animation'] = fadeComparison;

    // Test scale animations
    final scaleComparison = await compareOptimizationLevels(
      standardAnimation: _createStandardScaleAnimation(),
      optimizedAnimation: OptimizedScaleTransition(
        scale: AlwaysStoppedAnimation(1.2),
        child: Container(width: 100, height: 100, color: Colors.red),
      ),
      testName: 'scale_animation',
    );
    results['scale_animation'] = scaleComparison;

    // Test slide animations
    final slideComparison = await compareOptimizationLevels(
      standardAnimation: _createStandardSlideAnimation(),
      optimizedAnimation: OptimizedSlideTransition(
        position: AlwaysStoppedAnimation(const Offset(0.5, 0)),
        child: Container(width: 100, height: 100, color: Colors.green),
      ),
      testName: 'slide_animation',
    );
    results['slide_animation'] = slideComparison;

    return TestSuiteResult(
      testResults: results,
      overallPassed: results.values.every(
        (result) =>
            result is OptimizationComparisonResult &&
            result.optimizedResult.passed,
      ),
    );
  }

  // Helper methods to create standard animations for comparison
  static Widget _createStandardFadeAnimation() {
    return AnimatedOpacity(
      opacity: 0.5,
      duration: const Duration(milliseconds: 300),
      child: Container(width: 100, height: 100, color: Colors.blue),
    );
  }

  static Widget _createStandardScaleAnimation() {
    return AnimatedScale(
      scale: 1.2,
      duration: const Duration(milliseconds: 300),
      child: Container(width: 100, height: 100, color: Colors.red),
    );
  }

  static Widget _createStandardSlideAnimation() {
    return AnimatedSlide(
      offset: const Offset(0.5, 0),
      duration: const Duration(milliseconds: 300),
      child: Container(width: 100, height: 100, color: Colors.green),
    );
  }
}

/// Result of a performance test
class PerformanceTestResult {
  final String testName;
  final double averageFrameTime;
  final double frameDropRate;
  final int totalFrameDrops;
  final double memoryUsage;
  final bool passed;

  const PerformanceTestResult({
    required this.testName,
    required this.averageFrameTime,
    required this.frameDropRate,
    required this.totalFrameDrops,
    required this.memoryUsage,
    required this.passed,
  });

  @override
  String toString() {
    return 'PerformanceTestResult('
        'testName: $testName, '
        'averageFrameTime: ${averageFrameTime.toStringAsFixed(2)}ms, '
        'frameDropRate: ${(frameDropRate * 100).toStringAsFixed(2)}%, '
        'totalFrameDrops: $totalFrameDrops, '
        'memoryUsage: ${memoryUsage.toStringAsFixed(2)}MB, '
        'passed: $passed'
        ')';
  }
}

/// Result of a memory usage test
class MemoryTestResult {
  final String testName;
  final double initialMemory;
  final double finalMemory;
  final double maxMemory;
  final double memoryGrowth;
  final bool memoryLeakDetected;

  const MemoryTestResult({
    required this.testName,
    required this.initialMemory,
    required this.finalMemory,
    required this.maxMemory,
    required this.memoryGrowth,
    required this.memoryLeakDetected,
  });

  @override
  String toString() {
    return 'MemoryTestResult('
        'testName: $testName, '
        'initialMemory: ${initialMemory.toStringAsFixed(2)}MB, '
        'finalMemory: ${finalMemory.toStringAsFixed(2)}MB, '
        'maxMemory: ${maxMemory.toStringAsFixed(2)}MB, '
        'memoryGrowth: ${memoryGrowth.toStringAsFixed(2)}MB, '
        'memoryLeakDetected: $memoryLeakDetected'
        ')';
  }
}

/// Result comparing standard vs optimized animations
class OptimizationComparisonResult {
  final String testName;
  final PerformanceTestResult standardResult;
  final PerformanceTestResult optimizedResult;
  final double improvement;
  final double improvementPercentage;

  const OptimizationComparisonResult({
    required this.testName,
    required this.standardResult,
    required this.optimizedResult,
    required this.improvement,
    required this.improvementPercentage,
  });

  @override
  String toString() {
    return 'OptimizationComparisonResult('
        'testName: $testName, '
        'improvement: ${(improvement * 100).toStringAsFixed(2)}%, '
        'improvementPercentage: ${improvementPercentage.toStringAsFixed(2)}%'
        ')';
  }
}

/// Result of the full test suite
class TestSuiteResult {
  final Map<String, dynamic> testResults;
  final bool overallPassed;

  const TestSuiteResult({
    required this.testResults,
    required this.overallPassed,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('TestSuiteResult:');
    buffer.writeln('Overall Passed: $overallPassed');
    buffer.writeln('Individual Results:');

    testResults.forEach((key, value) {
      buffer.writeln('  $key: $value');
    });

    return buffer.toString();
  }
}
