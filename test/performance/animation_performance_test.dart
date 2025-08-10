import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plot_twist/application/settings/animation_performance_provider.dart';
import 'package:plot_twist/presentation/core/performance/performance_integration.dart';
import 'package:plot_twist/presentation/core/performance/optimized_animations.dart'
    hide AnimationType;
import 'package:plot_twist/presentation/core/performance/performance_tests.dart';
import 'package:plot_twist/presentation/pages/settings/animation_performance_settings_page.dart';

void main() {
  group('Animation Performance Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('AnimationPerformanceSettingsPage renders correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: const AnimationPerformanceSettingsPage()),
        ),
      );

      expect(find.text('Animation Performance'), findsOneWidget);
      expect(find.text('Performance Mode'), findsOneWidget);
      expect(find.text('Animation Settings'), findsOneWidget);
    });

    testWidgets('Performance mode can be changed', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: const AnimationPerformanceSettingsPage()),
        ),
      );

      // Find and tap the high performance radio button
      await tester.tap(find.text('High Performance'));
      await tester.pump();

      // Verify the setting was changed
      final notifier = container.read(
        animationPerformanceNotifierProvider.notifier,
      );
      expect(notifier.state.performanceMode, PerformanceMode.performance);
    });

    testWidgets('OptimizedFadeTransition works correctly', (tester) async {
      const testKey = Key('fade_test');
      late AnimationController controller;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                controller = AnimationController(
                  duration: const Duration(milliseconds: 300),
                  vsync: Scaffold.of(context),
                );
                return OptimizedFadeTransition(
                  key: testKey,
                  opacity: controller,
                  child: Container(width: 100, height: 100, color: Colors.blue),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byKey(testKey), findsOneWidget);

      // Start animation
      controller.forward();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.byKey(testKey), findsOneWidget);

      controller.dispose();
    });

    testWidgets('OptimizedScaleTransition works correctly', (tester) async {
      const testKey = Key('scale_test');
      late AnimationController controller;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                controller = AnimationController(
                  duration: const Duration(milliseconds: 300),
                  vsync: Scaffold.of(context),
                );
                return OptimizedScaleTransition(
                  key: testKey,
                  scale: controller,
                  child: Container(width: 100, height: 100, color: Colors.red),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byKey(testKey), findsOneWidget);

      // Start animation
      controller.forward();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.byKey(testKey), findsOneWidget);

      controller.dispose();
    });

    testWidgets('OptimizedSlideTransition works correctly', (tester) async {
      const testKey = Key('slide_test');
      late AnimationController controller;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                controller = AnimationController(
                  duration: const Duration(milliseconds: 300),
                  vsync: Scaffold.of(context),
                );
                return OptimizedSlideTransition(
                  key: testKey,
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(controller),
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Colors.green,
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byKey(testKey), findsOneWidget);

      // Start animation
      controller.forward();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.byKey(testKey), findsOneWidget);

      controller.dispose();
    });

    test('AnimationPerformanceSettings serialization works', () {
      const settings = AnimationPerformanceSettings(
        performanceMode: PerformanceMode.performance,
        reduceMotion: true,
        useHighRefreshRate: false,
        animationDurationMultiplier: 1.5,
      );

      final json = settings.toJson();
      final restored = AnimationPerformanceSettings.fromJson(json);

      expect(restored.performanceMode, settings.performanceMode);
      expect(restored.reduceMotion, settings.reduceMotion);
      expect(restored.useHighRefreshRate, settings.useHighRefreshRate);
      expect(
        restored.animationDurationMultiplier,
        settings.animationDurationMultiplier,
      );
    });

    test('Performance integration initializes correctly', () async {
      final integration = PerformanceIntegration.instance;
      await integration.initialize();

      // Test that we can get metrics without errors
      final metrics = integration.getCurrentMetrics();
      expect(metrics, isNotNull);
      expect(metrics.averageFrameTime, isA<double>());
      expect(metrics.droppedFrames, isA<int>());
      expect(metrics.memoryUsage, isA<double>());
    });

    test('Optimized animation builder creates correct widgets', () {
      final integration = PerformanceIntegration.instance;
      final animation = AlwaysStoppedAnimation<double>(0.5);
      final child = Container();

      final fadeWidget = integration.buildOptimizedAnimation(
        type: AnimationType.fade,
        animation: animation,
        child: child,
      );
      expect(fadeWidget, isA<OptimizedFadeTransition>());

      final scaleWidget = integration.buildOptimizedAnimation(
        type: AnimationType.scale,
        animation: animation,
        child: child,
      );
      expect(scaleWidget, isA<OptimizedScaleTransition>());

      final slideWidget = integration.buildOptimizedAnimation(
        type: AnimationType.slide,
        animation: animation,
        child: child,
      );
      expect(slideWidget, isA<OptimizedSlideTransition>());
    });

    test('Performance test results have correct structure', () {
      const result = PerformanceTestResult(
        testName: 'test',
        averageFrameTime: 16.67,
        frameDropRate: 0.02,
        totalFrameDrops: 5,
        memoryUsage: 50.0,
        passed: true,
      );

      expect(result.testName, 'test');
      expect(result.averageFrameTime, 16.67);
      expect(result.frameDropRate, 0.02);
      expect(result.totalFrameDrops, 5);
      expect(result.memoryUsage, 50.0);
      expect(result.passed, true);

      final stringRepresentation = result.toString();
      expect(stringRepresentation, contains('test'));
      expect(stringRepresentation, contains('16.67'));
      expect(stringRepresentation, contains('2.00%'));
    });

    test('Memory test results have correct structure', () {
      const result = MemoryTestResult(
        testName: 'memory_test',
        initialMemory: 40.0,
        finalMemory: 45.0,
        maxMemory: 50.0,
        memoryGrowth: 5.0,
        memoryLeakDetected: false,
      );

      expect(result.testName, 'memory_test');
      expect(result.initialMemory, 40.0);
      expect(result.finalMemory, 45.0);
      expect(result.maxMemory, 50.0);
      expect(result.memoryGrowth, 5.0);
      expect(result.memoryLeakDetected, false);
    });

    test('Optimization comparison results calculate correctly', () {
      const standardResult = PerformanceTestResult(
        testName: 'standard',
        averageFrameTime: 20.0,
        frameDropRate: 0.1,
        totalFrameDrops: 10,
        memoryUsage: 60.0,
        passed: false,
      );

      const optimizedResult = PerformanceTestResult(
        testName: 'optimized',
        averageFrameTime: 16.0,
        frameDropRate: 0.05,
        totalFrameDrops: 5,
        memoryUsage: 55.0,
        passed: true,
      );

      const comparison = OptimizationComparisonResult(
        testName: 'comparison',
        standardResult: standardResult,
        optimizedResult: optimizedResult,
        improvement: 0.05,
        improvementPercentage: 50.0,
      );

      expect(comparison.improvement, 0.05);
      expect(comparison.improvementPercentage, 50.0);
      expect(comparison.optimizedResult.passed, true);
      expect(comparison.standardResult.passed, false);
    });
  });
}
