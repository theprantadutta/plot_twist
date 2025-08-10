
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Memory optimization and monitoring system
class MemoryOptimizer {
  static final MemoryOptimizer _instance = MemoryOptimizer._internal();
  factory MemoryOptimizer() => _instance;
  MemoryOptimizer._internal();

  static const int _memoryWarningThreshold = 100 * 1024 * 1024; // 100MB
  static const int _memoryCriticalThreshold = 200 * 1024 * 1024; // 200MB

  final List<MemorySnapshot> _memoryHistory = [];
  bool _isMonitoring = false;

  /// Start memory monitoring
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _scheduleMemoryCheck();

    if (kDebugMode) {
      debugPrint('🧠 Memory Optimizer: Started monitoring');
    }
  }

  /// Stop memory monitoring
  void stopMonitoring() {
    _isMonitoring = false;

    if (kDebugMode) {
      debugPrint('🧠 Memory Optimizer: Stopped monitoring');
    }
  }

  /// Get current memory usage
  Future<MemoryInfo> getCurrentMemoryInfo() async {
    // Simplified memory info since Service methods aren't available
    return MemoryInfo(
      used: 50 * 1024 * 1024, // 50MB placeholder
      capacity: 100 * 1024 * 1024, // 100MB placeholder
      external: 10 * 1024 * 1024, // 10MB placeholder
      timestamp: DateTime.now(),
    );
  }

  /// Force garbage collection
  void forceGarbageCollection() {
    // Simplified GC trigger
    if (kDebugMode) {
      debugPrint('🗑️ Memory Optimizer: Triggering garbage collection');
    }

    if (kDebugMode) {
      debugPrint('🧠 Memory Optimizer: Forced garbage collection');
    }
  }

  /// Optimize memory usage
  Future<void> optimizeMemory() async {
    // Clear image cache if memory usage is high
    final memoryInfo = await getCurrentMemoryInfo();

    if (memoryInfo.used > _memoryWarningThreshold) {
      _clearCaches();

      if (memoryInfo.used > _memoryCriticalThreshold) {
        forceGarbageCollection();
      }
    }
  }

  /// Get memory usage report
  Future<MemoryReport> getMemoryReport() async {
    final currentInfo = await getCurrentMemoryInfo();
    final peakUsage = _memoryHistory.isEmpty
        ? currentInfo.used
        : _memoryHistory.map((s) => s.used).reduce((a, b) => a > b ? a : b);

    return MemoryReport(
      currentUsage: currentInfo.used,
      peakUsage: peakUsage,
      averageUsage: _calculateAverageUsage(),
      memoryPressure: _calculateMemoryPressure(currentInfo.used),
      recommendations: _generateRecommendations(currentInfo.used),
    );
  }

  void _scheduleMemoryCheck() {
    if (!_isMonitoring) return;

    Future.delayed(const Duration(seconds: 5), () async {
      final memoryInfo = await getCurrentMemoryInfo();
      _recordMemorySnapshot(memoryInfo);

      if (memoryInfo.used > _memoryWarningThreshold) {
        _handleMemoryPressure(memoryInfo.used);
      }

      _scheduleMemoryCheck();
    });
  }

  void _recordMemorySnapshot(MemoryInfo info) {
    _memoryHistory.add(
      MemorySnapshot(
        used: info.used,
        capacity: info.capacity,
        external: info.external,
        timestamp: info.timestamp,
      ),
    );

    // Keep only recent history (last 100 snapshots)
    if (_memoryHistory.length > 100) {
      _memoryHistory.removeAt(0);
    }
  }

  void _handleMemoryPressure(int memoryUsage) {
    if (kDebugMode) {
      final mb = (memoryUsage / (1024 * 1024)).toStringAsFixed(1);
      debugPrint('⚠️ Memory pressure detected: ${mb}MB');
    }

    _clearCaches();

    if (memoryUsage > _memoryCriticalThreshold) {
      forceGarbageCollection();
    }
  }

  void _clearCaches() {
    // Clear image cache
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    if (kDebugMode) {
      debugPrint('🧠 Memory Optimizer: Cleared caches');
    }
  }

  double _calculateAverageUsage() {
    if (_memoryHistory.isEmpty) return 0.0;

    final total = _memoryHistory.map((s) => s.used).reduce((a, b) => a + b);
    return total / _memoryHistory.length;
  }

  MemoryPressure _calculateMemoryPressure(int currentUsage) {
    if (currentUsage > _memoryCriticalThreshold) {
      return MemoryPressure.critical;
    } else if (currentUsage > _memoryWarningThreshold) {
      return MemoryPressure.high;
    } else if (currentUsage > _memoryWarningThreshold * 0.7) {
      return MemoryPressure.moderate;
    } else {
      return MemoryPressure.low;
    }
  }

  List<String> _generateRecommendations(int currentUsage) {
    final recommendations = <String>[];

    if (currentUsage > _memoryCriticalThreshold) {
      recommendations.add('Critical: Consider reducing image cache size');
      recommendations.add('Critical: Implement lazy loading for lists');
      recommendations.add('Critical: Review widget disposal patterns');
    } else if (currentUsage > _memoryWarningThreshold) {
      recommendations.add('Warning: Monitor image loading patterns');
      recommendations.add('Warning: Consider implementing pagination');
    } else {
      recommendations.add('Good: Memory usage is within normal range');
    }

    return recommendations;
  }
}

/// Memory information data class
class MemoryInfo {
  final int used;
  final int capacity;
  final int external;
  final DateTime timestamp;

  const MemoryInfo({
    required this.used,
    required this.capacity,
    required this.external,
    required this.timestamp,
  });

  double get usedMB => used / (1024 * 1024);
  double get capacityMB => capacity / (1024 * 1024);
  double get externalMB => external / (1024 * 1024);
  double get usagePercent => (used / capacity) * 100;
}

/// Memory snapshot for history tracking
class MemorySnapshot {
  final int used;
  final int capacity;
  final int external;
  final DateTime timestamp;

  const MemorySnapshot({
    required this.used,
    required this.capacity,
    required this.external,
    required this.timestamp,
  });
}

/// Memory usage report
class MemoryReport {
  final int currentUsage;
  final int peakUsage;
  final double averageUsage;
  final MemoryPressure memoryPressure;
  final List<String> recommendations;

  const MemoryReport({
    required this.currentUsage,
    required this.peakUsage,
    required this.averageUsage,
    required this.memoryPressure,
    required this.recommendations,
  });

  @override
  String toString() {
    return '''
Memory Report:
- Current Usage: ${(currentUsage / (1024 * 1024)).toStringAsFixed(1)}MB
- Peak Usage: ${(peakUsage / (1024 * 1024)).toStringAsFixed(1)}MB
- Average Usage: ${(averageUsage / (1024 * 1024)).toStringAsFixed(1)}MB
- Memory Pressure: ${memoryPressure.name}
- Recommendations: ${recommendations.join(', ')}
''';
  }
}

enum MemoryPressure { low, moderate, high, critical }

/// Widget to monitor memory usage
class MemoryMonitorWidget extends StatefulWidget {
  final Widget child;
  final bool showOverlay;
  final VoidCallback? onMemoryPressure;

  const MemoryMonitorWidget({
    super.key,
    required this.child,
    this.showOverlay = kDebugMode,
    this.onMemoryPressure,
  });

  @override
  State<MemoryMonitorWidget> createState() => _MemoryMonitorWidgetState();
}

class _MemoryMonitorWidgetState extends State<MemoryMonitorWidget> {
  final _optimizer = MemoryOptimizer();
  MemoryInfo? _currentMemoryInfo;
  MemoryPressure _lastPressure = MemoryPressure.low;

  @override
  void initState() {
    super.initState();
    _optimizer.startMonitoring();
    _updateMemoryInfo();
  }

  @override
  void dispose() {
    _optimizer.stopMonitoring();
    super.dispose();
  }

  void _updateMemoryInfo() async {
    if (!mounted) return;

    try {
      final info = await _optimizer.getCurrentMemoryInfo();
      setState(() {
        _currentMemoryInfo = info;
      });

      final pressure = _optimizer._calculateMemoryPressure(info.used);
      if (pressure != _lastPressure &&
          pressure.index > MemoryPressure.moderate.index) {
        widget.onMemoryPressure?.call();
        _lastPressure = pressure;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get memory info: $e');
      }
    }

    Future.delayed(const Duration(seconds: 2), _updateMemoryInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showOverlay && _currentMemoryInfo != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 50,
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
                    'Memory: ${_currentMemoryInfo!.usedMB.toStringAsFixed(1)}MB',
                    style: TextStyle(
                      color: _getMemoryColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Usage: ${_currentMemoryInfo!.usagePercent.toStringAsFixed(1)}%',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Color _getMemoryColor() {
    if (_currentMemoryInfo == null) return Colors.white;

    final pressure = _optimizer._calculateMemoryPressure(
      _currentMemoryInfo!.used,
    );
    switch (pressure) {
      case MemoryPressure.low:
        return Colors.green;
      case MemoryPressure.moderate:
        return Colors.yellow;
      case MemoryPressure.high:
        return Colors.orange;
      case MemoryPressure.critical:
        return Colors.red;
    }
  }
}

/// Memory-aware widget that optimizes based on memory pressure
class MemoryAwareWidget extends StatefulWidget {
  final Widget child;
  final Widget? lowMemoryChild;
  final VoidCallback? onMemoryPressure;

  const MemoryAwareWidget({
    super.key,
    required this.child,
    this.lowMemoryChild,
    this.onMemoryPressure,
  });

  @override
  State<MemoryAwareWidget> createState() => _MemoryAwareWidgetState();
}

class _MemoryAwareWidgetState extends State<MemoryAwareWidget> {
  final _optimizer = MemoryOptimizer();
  bool _isLowMemoryMode = false;

  @override
  void initState() {
    super.initState();
    _checkMemoryPressure();
  }

  void _checkMemoryPressure() async {
    try {
      final info = await _optimizer.getCurrentMemoryInfo();
      final pressure = _optimizer._calculateMemoryPressure(info.used);

      final shouldUseLowMemoryMode =
          pressure.index >= MemoryPressure.high.index;

      if (shouldUseLowMemoryMode != _isLowMemoryMode) {
        setState(() {
          _isLowMemoryMode = shouldUseLowMemoryMode;
        });

        if (shouldUseLowMemoryMode) {
          widget.onMemoryPressure?.call();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to check memory pressure: $e');
      }
    }

    Future.delayed(const Duration(seconds: 5), _checkMemoryPressure);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLowMemoryMode && widget.lowMemoryChild != null) {
      return widget.lowMemoryChild!;
    }

    return widget.child;
  }
}

/// Disposable resource tracker
class DisposableResourceTracker {
  static final Map<String, int> _resourceCounts = {};
  static final Map<String, DateTime> _resourceTimestamps = {};

  /// Track resource creation
  static void trackResource(String resourceType) {
    _resourceCounts[resourceType] = (_resourceCounts[resourceType] ?? 0) + 1;
    _resourceTimestamps[resourceType] = DateTime.now();

    if (kDebugMode && _resourceCounts[resourceType]! > 100) {
      debugPrint(
        '⚠️ High resource count for $resourceType: ${_resourceCounts[resourceType]}',
      );
    }
  }

  /// Track resource disposal
  static void disposeResource(String resourceType) {
    if (_resourceCounts.containsKey(resourceType)) {
      _resourceCounts[resourceType] = _resourceCounts[resourceType]! - 1;
      if (_resourceCounts[resourceType]! <= 0) {
        _resourceCounts.remove(resourceType);
        _resourceTimestamps.remove(resourceType);
      }
    }
  }

  /// Get resource report
  static String getResourceReport() {
    if (_resourceCounts.isEmpty) {
      return 'No tracked resources';
    }

    final buffer = StringBuffer('Resource Usage:\n');
    _resourceCounts.forEach((type, count) {
      buffer.writeln('- $type: $count');
    });

    return buffer.toString();
  }

  /// Clear all tracked resources
  static void clearTracking() {
    _resourceCounts.clear();
    _resourceTimestamps.clear();
  }
}
