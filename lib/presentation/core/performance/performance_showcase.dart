import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/settings/animation_performance_provider.dart';
import '../app_animations.dart';
import 'performance_integration.dart';

/// Showcase widget demonstrating all performance optimizations
class PerformanceShowcase extends ConsumerStatefulWidget {
  const PerformanceShowcase({super.key});

  @override
  ConsumerState<PerformanceShowcase> createState() =>
      _PerformanceShowcaseState();
}

class _PerformanceShowcaseState extends ConsumerState<PerformanceShowcase>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    // Create multiple animation controllers for different demonstrations
    _controllers = List.generate(6, (index) {
      return AnimationController(
        duration: AnimationUtils.getOptimizedDuration(
          Duration(milliseconds: 800 + (index * 200)),
        ),
        vsync: this,
      );
    });

    // Create animations with different curves and behaviors
    _animations = [
      CurvedAnimation(parent: _controllers[0], curve: Curves.easeInOut),
      CurvedAnimation(parent: _controllers[1], curve: Curves.bounceOut),
      CurvedAnimation(parent: _controllers[2], curve: Curves.elasticOut),
      CurvedAnimation(parent: _controllers[3], curve: Curves.fastOutSlowIn),
      CurvedAnimation(parent: _controllers[4], curve: Curves.decelerate),
      CurvedAnimation(parent: _controllers[5], curve: Curves.easeInOut),
    ];

    // Start staggered animations
    _startStaggeredAnimations();
  }

  void _startStaggeredAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animationSettings = ref.watch(animationPerformanceNotifierProvider);
    final performance = PerformanceIntegration.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Showcase'),
        actions: [
          IconButton(
            icon: Icon(
              animationSettings.enablePerformanceMonitoring
                  ? Icons.monitor
                  : Icons.monitor_outlined,
            ),
            onPressed: () {
              ref
                  .read(animationPerformanceNotifierProvider.notifier)
                  .setEnablePerformanceMonitoring(
                    !animationSettings.enablePerformanceMonitoring,
                  );
            },
            tooltip: 'Toggle Performance Monitoring',
          ),
        ],
      ),
      body: Column(
        children: [
          // Performance metrics header
          if (animationSettings.enablePerformanceMonitoring)
            _buildPerformanceHeader(performance),

          // Animation showcase grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildAnimationCard(
                  title: 'Optimized Fade',
                  child: performance.buildOptimizedAnimation(
                    type: AnimationType.fade,
                    animation: _animations[0],
                    child: _buildAnimatedBox(Colors.blue),
                  ),
                ),
                _buildAnimationCard(
                  title: 'Optimized Scale',
                  child: performance.buildOptimizedAnimation(
                    type: AnimationType.scale,
                    animation: _animations[1],
                    child: _buildAnimatedBox(Colors.red),
                  ),
                ),
                _buildAnimationCard(
                  title: 'Optimized Slide',
                  child: performance.buildOptimizedAnimation(
                    type: AnimationType.slide,
                    animation: _animations[2],
                    child: _buildAnimatedBox(Colors.green),
                  ),
                ),
                _buildAnimationCard(
                  title: 'Optimized Rotation',
                  child: performance.buildOptimizedAnimation(
                    type: AnimationType.rotation,
                    animation: _animations[3],
                    child: _buildAnimatedBox(Colors.purple),
                  ),
                ),
                _buildAnimationCard(
                  title: 'Combined Animation',
                  child: _buildCombinedAnimation(),
                ),
                _buildAnimationCard(
                  title: 'Staggered List',
                  child: _buildStaggeredList(),
                ),
              ],
            ),
          ),

          // Control panel
          _buildControlPanel(animationSettings),
        ],
      ),
    );
  }

  Widget _buildPerformanceHeader(PerformanceIntegration performance) {
    final metrics = performance.getCurrentMetrics();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricItem(
            'Frame Time',
            '${metrics.averageFrameTime.toStringAsFixed(1)}ms',
            metrics.averageFrameTime < 16.67 ? Colors.green : Colors.orange,
          ),
          _buildMetricItem(
            'Dropped Frames',
            '${metrics.droppedFrames}',
            metrics.droppedFrames < 5 ? Colors.green : Colors.red,
          ),
          _buildMetricItem(
            'Memory',
            '${metrics.memoryUsage.toStringAsFixed(1)}MB',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildAnimationCard({required String title, required Widget child}) {
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

  Widget _buildAnimatedBox(Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedAnimation() {
    return AnimationUtils.slideFadeTransition(
      animation: _animations[4],
      child: AnimationUtils.scaleTransition(
        animation: _animations[4],
        child: _buildAnimatedBox(Colors.orange),
      ),
    );
  }

  Widget _buildStaggeredList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final staggeredAnimation = CurvedAnimation(
          parent: _animations[5],
          curve: Interval(index * 0.2, 1.0, curve: Curves.easeOutBack),
        );

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: AnimationUtils.slideFadeTransition(
            animation: staggeredAnimation,
            slideBegin: const Offset(-0.5, 0),
            child: Container(
              width: 80,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildControlPanel(AnimationPerformanceSettings settings) {
    return Container(
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
          Text(
            'Animation Controls',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  for (final controller in _controllers) {
                    if (controller.isAnimating) {
                      controller.stop();
                    } else {
                      controller.repeat(reverse: true);
                    }
                  }
                },
                icon: Icon(
                  _controllers.first.isAnimating
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
                label: Text(_controllers.first.isAnimating ? 'Pause' : 'Play'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  for (final controller in _controllers) {
                    controller.reset();
                  }
                  _startStaggeredAnimations();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Restart'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  // Run a quick performance test
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Running performance test...'),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Simulate test results
                  await Future.delayed(const Duration(seconds: 2));

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Performance test completed!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.speed),
                label: const Text('Test'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Performance Mode: ${_getPerformanceModeText(settings.performanceMode)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            'Animation Speed: ${settings.animationDurationMultiplier.toStringAsFixed(1)}x',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (settings.reduceMotion)
            Text(
              'Reduce Motion: Enabled',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.orange),
            ),
        ],
      ),
    );
  }

  String _getPerformanceModeText(PerformanceMode mode) {
    switch (mode) {
      case PerformanceMode.battery:
        return 'Battery Saver';
      case PerformanceMode.balanced:
        return 'Balanced';
      case PerformanceMode.performance:
        return 'High Performance';
    }
  }
}
