import 'package:flutter/material.dart';

import 'performance_integration.dart';
import 'performance_tests.dart';

/// Demo widget showcasing performance optimizations
class PerformanceDemoWidget extends StatefulWidget {
  const PerformanceDemoWidget({super.key});

  @override
  State<PerformanceDemoWidget> createState() => _PerformanceDemoWidgetState();
}

class _PerformanceDemoWidgetState extends State<PerformanceDemoWidget>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final AnimationController _slideController;
  late final AnimationController _rotationController;

  bool _useOptimizedAnimations = true;
  TestSuiteResult? _lastTestResult;
  bool _isRunningTests = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() {
    _fadeController.repeat(reverse: true);
    _scaleController.repeat(reverse: true);
    _slideController.repeat(reverse: true);
    _rotationController.repeat();
  }

  void _stopAnimations() {
    _fadeController.stop();
    _scaleController.stop();
    _slideController.stop();
    _rotationController.stop();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animation Performance Demo'),
        actions: [
          IconButton(
            icon: Icon(
              _useOptimizedAnimations ? Icons.speed : Icons.speed_outlined,
            ),
            onPressed: () {
              setState(() {
                _useOptimizedAnimations = !_useOptimizedAnimations;
              });
            },
            tooltip: _useOptimizedAnimations
                ? 'Using Optimized'
                : 'Using Standard',
          ),
        ],
      ),
      body: Column(
        children: [
          // Performance toggle
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Text(
                  'Animation Mode: ',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Switch(
                  value: _useOptimizedAnimations,
                  onChanged: (value) {
                    setState(() {
                      _useOptimizedAnimations = value;
                    });
                  },
                ),
                Text(
                  _useOptimizedAnimations ? 'Optimized' : 'Standard',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _useOptimizedAnimations
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Animation demos
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildAnimationDemo(
                  title: 'Fade Animation',
                  child: _buildFadeAnimation(),
                ),
                _buildAnimationDemo(
                  title: 'Scale Animation',
                  child: _buildScaleAnimation(),
                ),
                _buildAnimationDemo(
                  title: 'Slide Animation',
                  child: _buildSlideAnimation(),
                ),
                _buildAnimationDemo(
                  title: 'Rotation Animation',
                  child: _buildRotationAnimation(),
                ),
              ],
            ),
          ),

          // Performance metrics and test controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Performance Metrics',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isRunningTests
                              ? null
                              : _runPerformanceTests,
                          child: _isRunningTests
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Run Tests'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (_fadeController.isAnimating) {
                              _stopAnimations();
                            } else {
                              _startAnimations();
                            }
                            setState(() {});
                          },
                          child: Text(
                            _fadeController.isAnimating ? 'Stop' : 'Start',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildPerformanceMetrics(),
                if (_lastTestResult != null) ...[
                  const SizedBox(height: 16),
                  _buildTestResults(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationDemo({required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(child: Center(child: child)),
          ],
        ),
      ),
    );
  }

  Widget _buildFadeAnimation() {
    if (_useOptimizedAnimations) {
      return context.performance.buildOptimizedAnimation(
        type: AnimationType.fade,
        animation: _fadeController,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } else {
      return FadeTransition(
        opacity: _fadeController,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Widget _buildScaleAnimation() {
    if (_useOptimizedAnimations) {
      return context.performance.buildOptimizedAnimation(
        type: AnimationType.scale,
        animation: _scaleController,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } else {
      return ScaleTransition(
        scale: _scaleController,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Widget _buildSlideAnimation() {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: const Offset(0.5, 0),
    ).animate(_slideController);

    if (_useOptimizedAnimations) {
      return context.performance.buildOptimizedAnimation(
        type: AnimationType.slide,
        animation: _slideController,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } else {
      return SlideTransition(
        position: slideAnimation,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Widget _buildRotationAnimation() {
    if (_useOptimizedAnimations) {
      return context.performance.buildOptimizedAnimation(
        type: AnimationType.rotation,
        animation: _rotationController,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } else {
      return RotationTransition(
        turns: _rotationController,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Widget _buildPerformanceMetrics() {
    final metrics = context.performance.getCurrentMetrics();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Frame Time: ${metrics.averageFrameTime.toStringAsFixed(2)}ms'),
        Text('Dropped Frames: ${metrics.droppedFrames}'),
        Text('Memory Usage: ${metrics.memoryUsage.toStringAsFixed(2)}MB'),
        Text(
          'Animation Mode: ${_useOptimizedAnimations ? "Optimized" : "Standard"}',
        ),
      ],
    );
  }

  Widget _buildTestResults() {
    if (_lastTestResult == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Test Results', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Text('Overall Passed: ${_lastTestResult!.overallPassed ? "✅" : "❌"}'),
        ...(_lastTestResult!.testResults.entries.map((entry) {
          final result = entry.value as OptimizationComparisonResult;
          return Text(
            '${entry.key}: ${result.improvementPercentage.toStringAsFixed(1)}% improvement',
          );
        })),
      ],
    );
  }

  Future<void> _runPerformanceTests() async {
    setState(() {
      _isRunningTests = true;
    });

    try {
      final result = await AnimationPerformanceTests.runFullTestSuite();
      setState(() {
        _lastTestResult = result;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Test failed: $e')));
      }
    } finally {
      setState(() {
        _isRunningTests = false;
      });
    }
  }
}
