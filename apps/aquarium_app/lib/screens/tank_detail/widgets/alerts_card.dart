import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';

enum AlertSeverity { info, warning, danger }

class AlertItem {
  final AlertSeverity severity;
  final String title;
  final String? detail;

  const AlertItem({required this.severity, required this.title, this.detail});
}

class AlertsCard extends StatelessWidget {
  final Tank tank;
  final List<LogEntry> logs;

  const AlertsCard({super.key, required this.tank, required this.logs});

  @override
  Widget build(BuildContext context) {
    final tests =
        logs
            .where((l) => l.type == LogType.waterTest && l.waterTest != null)
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final latest = tests.firstOrNull;
    if (latest == null) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Alerts', style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'No water tests yet - nothing to flag.',
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    final latestTest = latest.waterTest!;
    final alerts = <AlertItem>[];

    // Recency
    final daysSince = DateTime.now().difference(latest.timestamp).inDays;
    if (daysSince >= 14) {
      alerts.add(
        AlertItem(
          severity: AlertSeverity.info,
          title: 'No water test in $daysSince days',
          detail: 'Consider logging a quick test to keep trends accurate.',
        ),
      );
    }

    // Targets (range)
    void rangeAlert({
      required String label,
      required double? value,
      required double? min,
      required double? max,
      String? unit,
    }) {
      if (value == null) return;
      if (min == null && max == null) return;

      final below = min != null && value < min;
      final above = max != null && value > max;
      if (!below && !above) return;

      final targetText = [
        if (min != null) 'min ${min.toStringAsFixed(1)}',
        if (max != null) 'max ${max.toStringAsFixed(1)}',
      ].join(' / ');

      alerts.add(
        AlertItem(
          severity: AlertSeverity.warning,
          title: '$label out of target range',
          detail:
              'Latest: ${value.toStringAsFixed(2)}${unit != null ? ' $unit' : ''} (targets: $targetText)',
        ),
      );
    }

    rangeAlert(
      label: 'Temperature',
      value: latestTest.temperature,
      min: tank.targets.tempMin,
      max: tank.targets.tempMax,
      unit: '°C',
    );
    rangeAlert(
      label: 'pH',
      value: latestTest.ph,
      min: tank.targets.phMin,
      max: tank.targets.phMax,
    );
    rangeAlert(
      label: 'GH',
      value: latestTest.gh,
      min: tank.targets.ghMin,
      max: tank.targets.ghMax,
      unit: 'dGH',
    );
    rangeAlert(
      label: 'KH',
      value: latestTest.kh,
      min: tank.targets.khMin,
      max: tank.targets.khMax,
      unit: 'dKH',
    );

    // Threshold parameters
    void thresholdAlert({
      required String label,
      required double? value,
      required double warn,
      required double danger,
      required int decimals,
      String unit = 'ppm',
    }) {
      if (value == null) return;
      if (value >= danger) {
        alerts.add(
          AlertItem(
            severity: AlertSeverity.danger,
            title: '$label is high',
            detail: 'Latest: ${value.toStringAsFixed(decimals)} $unit',
          ),
        );
      } else if (value >= warn) {
        alerts.add(
          AlertItem(
            severity: AlertSeverity.warning,
            title: '$label is elevated',
            detail: 'Latest: ${value.toStringAsFixed(decimals)} $unit',
          ),
        );
      }
    }

    thresholdAlert(
      label: 'Ammonia (NH₃)',
      value: latestTest.ammonia,
      warn: 0.25,
      danger: 0.5,
      decimals: 2,
    );
    thresholdAlert(
      label: 'Nitrite (NO₂)',
      value: latestTest.nitrite,
      warn: 0.25,
      danger: 0.5,
      decimals: 2,
    );
    thresholdAlert(
      label: 'Nitrate (NO₃)',
      value: latestTest.nitrate,
      warn: 40,
      danger: 80,
      decimals: 0,
    );
    thresholdAlert(
      label: 'Phosphate (PO₄)',
      value: latestTest.phosphate,
      warn: 1.0,
      danger: 2.0,
      decimals: 2,
    );

    // Simple delta trend (nitrate)
    final recentNitrateTests = tests
        .where((l) => l.waterTest?.nitrate != null)
        .take(2)
        .toList();
    if (recentNitrateTests.length == 2) {
      final a = recentNitrateTests[0];
      final b = recentNitrateTests[1];
      final delta = (a.waterTest!.nitrate! - b.waterTest!.nitrate!);
      final gapDays = a.timestamp.difference(b.timestamp).inDays.abs();

      if (gapDays <= 7 && delta >= 10) {
        alerts.add(
          AlertItem(
            severity: AlertSeverity.warning,
            title: 'Nitrate jumped +${delta.toStringAsFixed(0)} ppm',
            detail:
                'Since the previous test (${DateFormat('MMM d').format(b.timestamp)}).',
          ),
        );
      }
    }

    // If nothing, celebrate stability.
    if (alerts.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Alerts', style: AppTypography.headlineSmall),
                    const SizedBox(height: 6),
                    Text(
                      'All looks stable based on your latest test.',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Sort so danger shows first.
    alerts.sort((x, y) => y.severity.index.compareTo(x.severity.index));

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Alerts', style: AppTypography.headlineSmall),
                const Spacer(),
                Text('${alerts.length}', style: AppTypography.bodySmall),
              ],
            ),
            const SizedBox(height: 12),
            ...alerts.map((a) => AlertRow(item: a)),
          ],
        ),
      ),
    );
  }
}

class AlertRow extends StatelessWidget {
  final AlertItem item;

  const AlertRow({super.key, required this.item});

  Color _color() {
    switch (item.severity) {
      case AlertSeverity.danger:
        return AppColors.paramDanger;
      case AlertSeverity.warning:
        return AppColors.paramWarning;
      case AlertSeverity.info:
        return AppColors.info;
    }
  }

  IconData _icon() {
    switch (item.severity) {
      case AlertSeverity.danger:
        return Icons.error_outline;
      case AlertSeverity.warning:
        return Icons.warning_amber_rounded;
      case AlertSeverity.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.sm2),
        decoration: BoxDecoration(
          color: c.withAlpha(26),
          borderRadius: AppRadius.mediumRadius,
          border: Border.all(color: c.withAlpha(64)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_icon(), color: c),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: AppTypography.labelLarge),
                  if (item.detail != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(item.detail!, style: AppTypography.bodySmall),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
