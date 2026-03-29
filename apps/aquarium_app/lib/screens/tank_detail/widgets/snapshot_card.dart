import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';

enum ParamStatus { unknown, safe, warning, danger }

class LatestSnapshotCard extends StatelessWidget {
  final Tank tank;
  final List<LogEntry> logs;

  const LatestSnapshotCard({super.key, required this.tank, required this.logs});

  @override
  Widget build(BuildContext context) {
    final latest = logs.firstWhereOrNull(
      (l) =>
          l.type == LogType.waterTest &&
          l.waterTest != null &&
          l.waterTest!.hasValues,
    );

    if (latest == null) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Latest Water Snapshot', style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'No water tests yet — your first one unlocks insights!',
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    final t = latest.waterTest!;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Latest Water Snapshot',
                  style: AppTypography.headlineSmall,
                ),
                const Spacer(),
                Text(
                  DateFormat('d MMM').format(latest.timestamp),
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm2),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ParamPill(
                  label: 'Temp',
                  value: _fmt(t.temperature, decimals: 1),
                  unit: '°C',
                  status: _rangeStatus(
                    value: t.temperature,
                    min: tank.targets.tempMin,
                    max: tank.targets.tempMax,
                  ),
                ),
                ParamPill(
                  label: 'pH',
                  value: _fmt(t.ph, decimals: 1),
                  status: _rangeStatus(
                    value: t.ph,
                    min: tank.targets.phMin,
                    max: tank.targets.phMax,
                  ),
                ),
                ParamPill(
                  label: 'NH₃',
                  value: _fmt(t.ammonia, decimals: 2),
                  unit: 'ppm',
                  status: _thresholdStatus(
                    value: t.ammonia,
                    warn: 0.25,
                    danger: 0.5,
                  ),
                ),
                ParamPill(
                  label: 'NO₂',
                  value: _fmt(t.nitrite, decimals: 2),
                  unit: 'ppm',
                  status: _thresholdStatus(
                    value: t.nitrite,
                    warn: 0.25,
                    danger: 0.5,
                  ),
                ),
                ParamPill(
                  label: 'NO₃',
                  value: _fmt(t.nitrate, decimals: 0),
                  unit: 'ppm',
                  status: _thresholdStatus(
                    value: t.nitrate,
                    warn: 20,
                    danger: 40,
                  ),
                ),
                ParamPill(
                  label: 'GH',
                  value: _fmt(t.gh, decimals: 0),
                  unit: 'dGH',
                  status: _rangeStatus(
                    value: t.gh,
                    min: tank.targets.ghMin,
                    max: tank.targets.ghMax,
                  ),
                ),
                ParamPill(
                  label: 'KH',
                  value: _fmt(t.kh, decimals: 0),
                  unit: 'dKH',
                  status: _rangeStatus(
                    value: t.kh,
                    min: tank.targets.khMin,
                    max: tank.targets.khMax,
                  ),
                ),
                ParamPill(
                  label: 'PO₄',
                  value: _fmt(t.phosphate, decimals: 2),
                  unit: 'ppm',
                  status: _thresholdStatus(
                    value: t.phosphate,
                    warn: 1.0,
                    danger: 2.0,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tip: Tap a trend below to jump straight to charts.',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double? v, {required int decimals}) {
    if (v == null) return '–';
    return v.toStringAsFixed(decimals);
  }

  ParamStatus _thresholdStatus({
    required double? value,
    required double warn,
    required double danger,
  }) {
    if (value == null) return ParamStatus.unknown;
    if (value >= danger) return ParamStatus.danger;
    if (value >= warn) return ParamStatus.warning;
    return ParamStatus.safe;
  }

  ParamStatus _rangeStatus({
    required double? value,
    required double? min,
    required double? max,
  }) {
    if (value == null) return ParamStatus.unknown;
    if (min == null && max == null) return ParamStatus.unknown;

    final below = min != null && value < min;
    final above = max != null && value > max;

    if (below || above) return ParamStatus.warning;
    return ParamStatus.safe;
  }
}

class ParamPill extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final ParamStatus status;

  const ParamPill({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    required this.status,
  });

  Color _statusColor(BuildContext context) {
    switch (status) {
      case ParamStatus.safe:
        return AppColors.paramSafe;
      case ParamStatus.warning:
        return AppColors.paramWarning;
      case ParamStatus.danger:
        return AppColors.paramDanger;
      case ParamStatus.unknown:
        return context.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _statusColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm2,
        vertical: AppSpacing.sm3,
      ),
      decoration: BoxDecoration(
        color: c.withAlpha(36),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: c.withAlpha(89)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.bodySmall),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                (unit == null || value == '–') ? value : '$value $unit',
                style: AppTypography.labelLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
