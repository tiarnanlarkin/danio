import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

/// Compact trend arrows for pH, Temperature, and Ammonia.
/// Reads the last 5 water-test logs and shows direction + colour.
class WaterTrendArrows extends StatelessWidget {
  final List<LogEntry> logs;
  final Tank tank;

  const WaterTrendArrows({super.key, required this.logs, required this.tank});

  @override
  Widget build(BuildContext context) {
    final tests =
        logs
            .where((l) => l.type == LogType.waterTest && l.waterTest != null)
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // newest first

    if (tests.length < 2) return const SizedBox.shrink();

    final recent = tests.take(5).toList();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _TrendChip(
              label: 'pH',
              values: recent.map((l) => l.waterTest!.ph).toList(),
              idealMin: tank.targets.phMin ?? 6.5,
              idealMax: tank.targets.phMax ?? 7.5,
              decimals: 1,
            ),
            _TrendChip(
              label: 'Temp',
              values: recent.map((l) => l.waterTest!.temperature).toList(),
              idealMin: tank.targets.tempMin ?? 24,
              idealMax: tank.targets.tempMax ?? 28,
              decimals: 1,
              unit: '\u00B0C',
            ),
            _TrendChip(
              label: 'NH\u2083',
              values: recent.map((l) => l.waterTest!.ammonia).toList(),
              idealMin: 0,
              idealMax: 0.25,
              decimals: 2,
              unit: 'ppm',
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendChip extends StatelessWidget {
  final String label;
  final List<double?> values; // newest first
  final double idealMin;
  final double idealMax;
  final int decimals;
  final String? unit;

  const _TrendChip({
    required this.label,
    required this.values,
    required this.idealMin,
    required this.idealMax,
    required this.decimals,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final nonNull = values.whereType<double>().toList();
    if (nonNull.isEmpty) return const SizedBox.shrink();

    final latest = nonNull.first;
    final direction = _direction(nonNull);
    final status = _status(latest);

    final color = switch (status) {
      _ParamHealth.good => AppColors.success,
      _ParamHealth.borderline => AppColors.warning,
      _ParamHealth.concerning => AppColors.error,
    };

    final arrow = switch (direction) {
      _Trend.up => '\u2191',
      _Trend.down => '\u2193',
      _Trend.stable => '\u2192',
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTypography.bodySmall),
        const SizedBox(height: AppSpacing.xxs),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${latest.toStringAsFixed(decimals)}${unit != null ? ' $unit' : ''}',
              style: AppTypography.labelLarge.copyWith(color: color),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              arrow,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ],
    );
  }

  _Trend _direction(List<double> vals) {
    if (vals.length < 2) return _Trend.stable;
    final diff = vals.first - vals.last;
    final threshold = (idealMax - idealMin) * 0.1; // 10% of range
    if (diff > threshold) return _Trend.up;
    if (diff < -threshold) return _Trend.down;
    return _Trend.stable;
  }

  _ParamHealth _status(double value) {
    if (value >= idealMin && value <= idealMax) return _ParamHealth.good;
    final margin = (idealMax - idealMin) * 0.2;
    if (value >= idealMin - margin && value <= idealMax + margin) {
      return _ParamHealth.borderline;
    }
    return _ParamHealth.concerning;
  }
}

enum _Trend { up, down, stable }

enum _ParamHealth { good, borderline, concerning }
