import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_theme.dart';
import '../models/smart_models.dart';
import '../smart_providers.dart';
import '../../../theme/app_theme.dart';

/// Card widget that displays active anomalies for a tank on its dashboard.
class AnomalyCard extends ConsumerWidget {
  final String tankId;

  const AnomalyCard({super.key, required this.tankId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAnomalies = ref.watch(anomalyHistoryProvider);
    final anomalies = allAnomalies
        .where((a) => a.tankId == tankId && !a.dismissed)
        .toList();

    if (anomalies.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Card(
      elevation: AppElevation.level1,
      color: _cardColor(anomalies),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.md2Radius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: _iconColor(anomalies),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${anomalies.length} Anomal${anomalies.length == 1 ? 'y' : 'ies'} Detected',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...anomalies.take(3).map((a) => _AnomalyRow(anomaly: a)),
            if (anomalies.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  '+${anomalies.length - 3} more',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).shake(
      hz: 2,
      duration: 500.ms,
      offset: const Offset(2, 0),
    );
  }

  Color _cardColor(List<Anomaly> anomalies) {
    if (anomalies.any((a) => a.severity == AnomalySeverity.critical)) {
      return AppColors.error.withValues(alpha: 0.08);
    }
    if (anomalies.any((a) => a.severity == AnomalySeverity.alert)) {
      return AppColors.warning.withValues(alpha: 0.08);
    }
    return AppColors.info.withValues(alpha: 0.08);
  }

  Color _iconColor(List<Anomaly> anomalies) {
    if (anomalies.any((a) => a.severity == AnomalySeverity.critical)) {
      return AppColors.error;
    }
    if (anomalies.any((a) => a.severity == AnomalySeverity.alert)) {
      return AppColors.warning;
    }
    return AppColors.info;
  }
}

class _AnomalyRow extends ConsumerWidget {
  final Anomaly anomaly;

  const _AnomalyRow({required this.anomaly});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          _severityDot(anomaly.severity),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              anomaly.description,
              style: theme.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            visualDensity: VisualDensity.compact,
            onPressed: () {
              ref.read(anomalyHistoryProvider.notifier).dismiss(anomaly.id);
            },
            tooltip: 'Dismiss',
          ),
        ],
      ),
    );
  }

  Widget _severityDot(AnomalySeverity severity) {
    final color = switch (severity) {
      AnomalySeverity.critical => AppColors.error,
      AnomalySeverity.alert => AppColors.warning,
      AnomalySeverity.warning => AppColors.textSecondary,
    };
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
