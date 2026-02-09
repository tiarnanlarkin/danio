/// Performance Monitoring Utility
/// Tracks FPS, memory usage, and widget rebuilds
/// 
/// Resource Management:
/// - Uses SchedulerBinding callback for frame timing (must be removed on cleanup)
/// - Uses periodic Timer for memory sampling (must be cancelled on cleanup)
/// - Tracks collections with size limits to prevent unbounded growth
/// - Provides dispose() for complete resource cleanup
/// - stopMonitoring() pauses monitoring, dispose() releases all resources
library;

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Global performance monitor instance
final performanceMonitor = PerformanceMonitor();

class PerformanceMonitor {
  static const _targetFrameTime = Duration(microseconds: 16667); // 60 FPS
  static const _sampleWindow = Duration(seconds: 1);
  static const _maxRebuildEntries = 100; // Prevent unbounded growth

  final List<Duration> _frameTimes = [];
  DateTime? _lastSampleTime;
  int _droppedFrames = 0;
  int _totalFrames = 0;

  // Memory tracking
  final List<MemorySample> _memorySamples = [];
  Timer? _memoryTimer;

  // Widget rebuild tracking
  final Map<String, int> _rebuildCounts = {};

  bool _isMonitoring = false;
  bool _isDisposed = false;

  /// Start monitoring performance
  /// Throws StateError if monitor has been disposed
  void startMonitoring() {
    if (_isDisposed) {
      throw StateError('Cannot start monitoring on a disposed PerformanceMonitor');
    }
    if (_isMonitoring) return;
    _isMonitoring = true;

    // Frame timing callback - MUST be removed in stopMonitoring/dispose
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);

    // Memory sampling every 5 seconds - MUST be cancelled in stopMonitoring/dispose
    _memoryTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _sampleMemory();
    });

    developer.log('Performance monitoring started', name: 'PerformanceMonitor');
  }

  /// Stop monitoring (pauses monitoring but keeps data)
  /// Resources are cleaned up but can be restarted with startMonitoring()
  /// For complete cleanup, use dispose()
  void stopMonitoring() {
    if (!_isMonitoring) return;
    _isMonitoring = false;

    // Remove frame timing callback to prevent memory leak
    try {
      SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
    } catch (e) {
      developer.log('Error removing timings callback: $e', name: 'PerformanceMonitor');
    }

    // Cancel and nullify timer to prevent memory leak
    _memoryTimer?.cancel();
    _memoryTimer = null;

    developer.log('Performance monitoring stopped', name: 'PerformanceMonitor');
  }

  /// Dispose of all resources and cleanup
  /// After calling dispose(), this monitor cannot be reused
  /// Call stopMonitoring() first if you want to preserve data
  void dispose() {
    if (_isDisposed) return;

    developer.log('Disposing PerformanceMonitor', name: 'PerformanceMonitor');

    // Stop monitoring if active (cleans up callback and timer)
    if (_isMonitoring) {
      stopMonitoring();
    }

    // Double-check timer cleanup (defensive programming)
    _memoryTimer?.cancel();
    _memoryTimer = null;

    // Clear all collections to free memory
    _frameTimes.clear();
    _memorySamples.clear();
    _rebuildCounts.clear();

    // Reset counters
    _droppedFrames = 0;
    _totalFrames = 0;
    _lastSampleTime = null;

    // Mark as disposed
    _isDisposed = true;

    developer.log('PerformanceMonitor disposed', name: 'PerformanceMonitor');
  }

  /// Reset all metrics (clears data but keeps monitor active)
  void reset() {
    if (_isDisposed) {
      developer.log('Cannot reset disposed monitor', name: 'PerformanceMonitor');
      return;
    }

    _frameTimes.clear();
    _memorySamples.clear();
    _rebuildCounts.clear();
    _droppedFrames = 0;
    _totalFrames = 0;
    _lastSampleTime = null;

    developer.log('Metrics reset', name: 'PerformanceMonitor');
  }

  /// Frame timing callback
  void _onFrameTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      final buildTime = timing.buildDuration;
      final rasterTime = timing.rasterDuration;
      final totalTime = buildTime + rasterTime;

      _frameTimes.add(totalTime);
      _totalFrames++;

      // Check for dropped frames (>16.67ms)
      if (totalTime > _targetFrameTime) {
        _droppedFrames++;
      }
    }

    // Clean old samples
    final now = DateTime.now();
    if (_lastSampleTime == null || now.difference(_lastSampleTime!) > _sampleWindow) {
      _cleanOldSamples();
      _lastSampleTime = now;
    }
  }

  /// Remove frame times older than sample window
  void _cleanOldSamples() {
    if (_frameTimes.length > 60) {
      _frameTimes.removeRange(0, _frameTimes.length - 60);
    }
  }

  /// Sample current memory usage
  void _sampleMemory() {
    // Note: This is an approximation. For accurate memory profiling,
    // use DevTools in profile mode
    final sample = MemorySample(
      timestamp: DateTime.now(),
      estimatedMB: _estimateMemoryUsage(),
    );
    _memorySamples.add(sample);

    // Keep last 20 samples (100 seconds)
    if (_memorySamples.length > 20) {
      _memorySamples.removeAt(0);
    }

    developer.log(
      'Memory: ${sample.estimatedMB.toStringAsFixed(1)} MB',
      name: 'PerformanceMonitor',
    );
  }

  /// Estimate memory usage (rough approximation)
  double _estimateMemoryUsage() {
    // This is a placeholder - real memory profiling requires DevTools
    // We can't accurately measure memory from within the app
    return 0.0;
  }

  /// Track widget rebuild
  /// Maintains a maximum of _maxRebuildEntries to prevent unbounded growth
  void trackRebuild(String widgetName) {
    if (_isDisposed) return; // Ignore if disposed

    _rebuildCounts[widgetName] = (_rebuildCounts[widgetName] ?? 0) + 1;

    // Prevent unbounded growth: if we exceed max entries, remove the least rebuilt widget
    if (_rebuildCounts.length > _maxRebuildEntries) {
      final entries = _rebuildCounts.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value)); // Sort ascending
      _rebuildCounts.remove(entries.first.key); // Remove widget with fewest rebuilds
    }
  }

  /// Check if monitor is currently active
  bool get isMonitoring => _isMonitoring && !_isDisposed;

  /// Check if monitor has been disposed
  bool get isDisposed => _isDisposed;

  /// Get current FPS
  double get currentFPS {
    if (_frameTimes.isEmpty) return 60.0;
    
    final avgFrameTime = _frameTimes.fold<Duration>(
      Duration.zero,
      (sum, time) => sum + time,
    ) ~/ _frameTimes.length;

    return avgFrameTime.inMicroseconds > 0
        ? 1000000.0 / avgFrameTime.inMicroseconds
        : 60.0;
  }

  /// Get percentage of dropped frames
  double get droppedFramePercentage {
    return _totalFrames > 0 ? (_droppedFrames / _totalFrames) * 100 : 0.0;
  }

  /// Get average frame time in milliseconds
  double get avgFrameTimeMs {
    if (_frameTimes.isEmpty) return 0.0;
    
    final avgDuration = _frameTimes.fold<Duration>(
      Duration.zero,
      (sum, time) => sum + time,
    ) ~/ _frameTimes.length;

    return avgDuration.inMicroseconds / 1000.0;
  }

  /// Get current memory estimate
  double get currentMemoryMB {
    return _memorySamples.isNotEmpty 
        ? _memorySamples.last.estimatedMB 
        : 0.0;
  }

  /// Get rebuild count for a widget
  int getRebuilds(String widgetName) {
    return _rebuildCounts[widgetName] ?? 0;
  }

  /// Get all rebuild counts
  Map<String, int> get allRebuilds => Map.unmodifiable(_rebuildCounts);

  /// Log current metrics
  void logMetrics() {
    developer.log(
      'FPS: ${currentFPS.toStringAsFixed(1)} | '
      'Avg Frame: ${avgFrameTimeMs.toStringAsFixed(2)}ms | '
      'Dropped: ${droppedFramePercentage.toStringAsFixed(1)}%',
      name: 'PerformanceMonitor',
    );

    if (_rebuildCounts.isNotEmpty) {
      final topRebuilders = _rebuildCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      developer.log(
        'Top rebuilders: ${topRebuilders.take(5).map((e) => '${e.key}:${e.value}').join(', ')}',
        name: 'PerformanceMonitor',
      );
    }
  }

  /// Get performance report
  PerformanceReport getReport() {
    return PerformanceReport(
      fps: currentFPS,
      avgFrameTimeMs: avgFrameTimeMs,
      droppedFramePercentage: droppedFramePercentage,
      totalFrames: _totalFrames,
      droppedFrames: _droppedFrames,
      memoryMB: currentMemoryMB,
      rebuilds: Map.from(_rebuildCounts),
    );
  }
}

/// Memory sample data
class MemorySample {
  final DateTime timestamp;
  final double estimatedMB;

  MemorySample({
    required this.timestamp,
    required this.estimatedMB,
  });
}

/// Performance report
class PerformanceReport {
  final double fps;
  final double avgFrameTimeMs;
  final double droppedFramePercentage;
  final int totalFrames;
  final int droppedFrames;
  final double memoryMB;
  final Map<String, int> rebuilds;

  PerformanceReport({
    required this.fps,
    required this.avgFrameTimeMs,
    required this.droppedFramePercentage,
    required this.totalFrames,
    required this.droppedFrames,
    required this.memoryMB,
    required this.rebuilds,
  });

  /// Check if performance meets targets
  bool get meetsTarget {
    return fps >= 55 && // Allow slight variance from 60 FPS
           avgFrameTimeMs <= 16.67 &&
           droppedFramePercentage <= 5.0;
  }

  @override
  String toString() {
    return '''
Performance Report:
  FPS: ${fps.toStringAsFixed(1)} (target: 60)
  Avg Frame Time: ${avgFrameTimeMs.toStringAsFixed(2)}ms (target: <16.67ms)
  Dropped Frames: $droppedFrames / $totalFrames (${droppedFramePercentage.toStringAsFixed(1)}%)
  Memory: ${memoryMB.toStringAsFixed(1)} MB
  Status: ${meetsTarget ? '✅ PASS' : '❌ NEEDS OPTIMIZATION'}
''';
  }
}

/// Widget mixin to track rebuilds
mixin PerformanceTracking<T extends StatefulWidget> on State<T> {
  String get performanceLabel => widget.runtimeType.toString();

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (kDebugMode) {
      performanceMonitor.trackRebuild(performanceLabel);
    }
  }
}

/// Widget wrapper for rebuild tracking
class RebuildTracker extends StatefulWidget {
  final String label;
  final Widget child;

  const RebuildTracker({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  State<RebuildTracker> createState() => _RebuildTrackerState();
}

class _RebuildTrackerState extends State<RebuildTracker> {
  @override
  void didUpdateWidget(RebuildTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (kDebugMode) {
      performanceMonitor.trackRebuild(widget.label);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
