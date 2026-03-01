/// Performance Overlay Widget
/// Shows real-time FPS, frame time, and memory metrics during development
library;
import 'package:danio/theme/app_theme.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/performance_monitor.dart';

/// Development overlay displaying real-time performance metrics.
///
/// Shows FPS, frame time, memory usage, and frame drops. Toggleable via [showOverlay]
/// flag. For development and debugging use only-not shown in release builds.
class AppPerformanceOverlay extends StatefulWidget {
  final Widget child;
  final bool showOverlay;

  const AppPerformanceOverlay({
    super.key,
    required this.child,
    this.showOverlay = false,
  });

  @override
  State<AppPerformanceOverlay> createState() => _AppPerformanceOverlayState();
}

class _AppPerformanceOverlayState extends State<AppPerformanceOverlay> {
  Timer? _updateTimer;
  double _fps = 60.0;
  double _frameTime = 0.0;
  double _droppedPercent = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.showOverlay) {
      _startMonitoring();
    }
  }

  @override
  void didUpdateWidget(AppPerformanceOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showOverlay != oldWidget.showOverlay) {
      if (widget.showOverlay) {
        _startMonitoring();
      } else {
        _stopMonitoring();
      }
    }
  }

  @override
  void dispose() {
    _stopMonitoring();
    super.dispose();
  }

  void _startMonitoring() {
    performanceMonitor.startMonitoring();
    _updateTimer = Timer.periodic(AppDurations.long2, (_) {
      if (mounted) {
        setState(() {
          _fps = performanceMonitor.currentFPS;
          _frameTime = performanceMonitor.avgFrameTimeMs;
          _droppedPercent = performanceMonitor.droppedFramePercentage;
        });
      }
    });
  }

  void _stopMonitoring() {
    _updateTimer?.cancel();
    _updateTimer = null;
    performanceMonitor.stopMonitoring();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showOverlay)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: _buildOverlay(),
          ),
      ],
    );
  }

  Widget _buildOverlay() {
    final fpsColor = _fps >= 55
        ? Colors.green
        : _fps >= 45
        ? Colors.orange
        : Colors.red;

    return Material(
      color: Colors.black87,
      borderRadius: AppRadius.smallRadius,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMetric('FPS', _fps.toStringAsFixed(1), fpsColor),
            const SizedBox(height: AppSpacing.xs),
            _buildMetric(
              'Frame',
              '${_frameTime.toStringAsFixed(1)}ms',
              _frameTime <= 16.67 ? Colors.green : Colors.red,
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildMetric(
              'Dropped',
              '${_droppedPercent.toStringAsFixed(1)}%',
              _droppedPercent <= 5.0 ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

/// Performance debugging screen
class PerformanceDebugScreen extends StatefulWidget {
  const PerformanceDebugScreen({super.key});

  @override
  State<PerformanceDebugScreen> createState() => _PerformanceDebugScreenState();
}

class _PerformanceDebugScreenState extends State<PerformanceDebugScreen> {
  Timer? _updateTimer;
  PerformanceReport? _report;

  @override
  void initState() {
    super.initState();
    performanceMonitor.startMonitoring();
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _report = performanceMonitor.getReport();
        });
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final report = _report;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              performanceMonitor.reset();
              setState(() {
                _report = null;
              });
            },
            tooltip: 'Reset metrics',
          ),
        ],
      ),
      body: report == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStatusCard(report),
                const SizedBox(height: AppSpacing.md),
                _buildMetricsCard(report),
                const SizedBox(height: AppSpacing.md),
                _buildRebuildsCard(report),
              ],
            ),
    );
  }

  Widget _buildStatusCard(PerformanceReport report) {
    return Card(
      color: report.meetsTarget ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              report.meetsTarget ? Icons.check_circle : Icons.warning,
              size: AppIconSizes.xl,
              color: report.meetsTarget ? Colors.green : Colors.red,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              report.meetsTarget ? 'Performance OK' : 'Needs Optimization',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: report.meetsTarget
                    ? Colors.green.shade900
                    : Colors.red.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsCard(PerformanceReport report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frame Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildMetricRow(
              'FPS',
              report.fps.toStringAsFixed(1),
              '60',
              report.fps >= 55,
            ),
            const Divider(),
            _buildMetricRow(
              'Avg Frame Time',
              '${report.avgFrameTimeMs.toStringAsFixed(2)}ms',
              '<16.67ms',
              report.avgFrameTimeMs <= 16.67,
            ),
            const Divider(),
            _buildMetricRow(
              'Dropped Frames',
              '${report.droppedFrames} / ${report.totalFrames}',
              '<5%',
              report.droppedFramePercentage <= 5.0,
            ),
            const Divider(),
            _buildMetricRow(
              'Dropped %',
              '${report.droppedFramePercentage.toStringAsFixed(1)}%',
              '<5%',
              report.droppedFramePercentage <= 5.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    String label,
    String value,
    String target,
    bool meetsTarget,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: meetsTarget ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Target: $target',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRebuildsCard(PerformanceReport report) {
    final rebuilds = report.rebuilds.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (rebuilds.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No rebuild data yet'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Widget Rebuilds (Top 10)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Widgets with excessive rebuilds may need optimization',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: AppSpacing.md),
            ...rebuilds.take(10).map((entry) {
              final isHigh = entry.value > 50;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isHigh ? Colors.orange : Colors.grey.shade200,
                        borderRadius: AppRadius.xsRadius,
                      ),
                      child: Text(
                        '${entry.value}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isHigh ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
