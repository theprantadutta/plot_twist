import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/settings/animation_performance_provider.dart';
import '../../core/performance/performance_integration.dart';
import '../../core/performance/performance_demo_widget.dart';

/// Settings page for animation performance configuration
class AnimationPerformanceSettingsPage extends ConsumerWidget {
  const AnimationPerformanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationSettings = ref.watch(animationPerformanceNotifierProvider);
    final notifier = ref.read(animationPerformanceNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Animation Performance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.science),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PerformanceDemoWidget(),
                ),
              );
            },
            tooltip: 'Performance Demo',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Performance Mode Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Mode',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose the performance mode that best suits your device capabilities.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ...PerformanceMode.values.map((mode) {
                    return RadioListTile<PerformanceMode>(
                      title: Text(_getPerformanceModeTitle(mode)),
                      subtitle: Text(_getPerformanceModeDescription(mode)),
                      value: mode,
                      groupValue: animationSettings.performanceMode,
                      onChanged: (value) {
                        if (value != null) {
                          notifier.setPerformanceMode(value);
                        }
                      },
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Animation Settings Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Animation Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: const Text('Reduce Motion'),
                    subtitle: const Text(
                      'Minimize animations for better performance',
                    ),
                    value: animationSettings.reduceMotion,
                    onChanged: notifier.setReduceMotion,
                  ),

                  SwitchListTile(
                    title: const Text('High Refresh Rate'),
                    subtitle: const Text(
                      'Use higher frame rates when available',
                    ),
                    value: animationSettings.useHighRefreshRate,
                    onChanged: notifier.setUseHighRefreshRate,
                  ),

                  SwitchListTile(
                    title: const Text('Hardware Acceleration'),
                    subtitle: const Text('Use GPU acceleration for animations'),
                    value: animationSettings.useHardwareAcceleration,
                    onChanged: notifier.setUseHardwareAcceleration,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Animation Duration Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Animation Duration',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adjust animation speed: ${animationSettings.animationDurationMultiplier.toStringAsFixed(1)}x',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: animationSettings.animationDurationMultiplier,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    label:
                        '${animationSettings.animationDurationMultiplier.toStringAsFixed(1)}x',
                    onChanged: notifier.setAnimationDurationMultiplier,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Faster (0.5x)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Slower (2.0x)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Performance Monitoring Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Monitoring',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: const Text('Enable Performance Monitoring'),
                    subtitle: const Text('Track animation performance metrics'),
                    value: animationSettings.enablePerformanceMonitoring,
                    onChanged: notifier.setEnablePerformanceMonitoring,
                  ),

                  if (animationSettings.enablePerformanceMonitoring) ...[
                    const SizedBox(height: 16),
                    _buildPerformanceMetrics(context),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Reset Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reset Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reset all animation performance settings to default values.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _showResetDialog(context, notifier),
                      child: const Text('Reset to Defaults'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPerformanceModeTitle(PerformanceMode mode) {
    switch (mode) {
      case PerformanceMode.battery:
        return 'Battery Saver';
      case PerformanceMode.balanced:
        return 'Balanced';
      case PerformanceMode.performance:
        return 'High Performance';
    }
  }

  String _getPerformanceModeDescription(PerformanceMode mode) {
    switch (mode) {
      case PerformanceMode.battery:
        return 'Minimal animations, optimized for battery life';
      case PerformanceMode.balanced:
        return 'Standard animations with good performance';
      case PerformanceMode.performance:
        return 'Full animations, maximum visual quality';
    }
  }

  Widget _buildPerformanceMetrics(BuildContext context) {
    final metrics = PerformanceIntegration.instance.getCurrentMetrics();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Performance Metrics',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Average Frame Time:'),
              Text('${metrics.averageFrameTime.toStringAsFixed(2)}ms'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Dropped Frames:'),
              Text('${metrics.droppedFrames}'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Memory Usage:'),
              Text('${metrics.memoryUsage.toStringAsFixed(2)}MB'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (metrics.averageFrameTime / 16.67).clamp(0.0, 1.0),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              metrics.averageFrameTime < 16.67
                  ? Colors.green
                  : metrics.averageFrameTime < 33.33
                  ? Colors.orange
                  : Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Frame time target: 16.67ms (60 FPS)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _showResetDialog(
    BuildContext context,
    AnimationPerformanceNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all animation performance settings to their default values?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              notifier.resetToDefaults();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
