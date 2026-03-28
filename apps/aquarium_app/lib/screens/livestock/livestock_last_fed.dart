import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/tank_provider.dart';
import '../../theme/app_theme.dart';

/// Shows "Last fed: X hours ago" based on the most recent feeding log.
class LivestockLastFedInfo extends ConsumerWidget {
  final String tankId;
  const LivestockLastFedInfo({super.key, required this.tankId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(logsProvider(tankId));
    return logsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 14, color: AppColors.warning),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Unable to load',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.warning),
            ),
          ],
        ),
      ),
      data: (logs) {
        final lastFeeding = logs
            .where((l) => l.type == LogType.feeding)
            .toList();
        if (lastFeeding.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              'No feedings logged yet — time to feed your fish! 🐟',
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          );
        }
        final last = lastFeeding.first; // logs are sorted newest first
        final diff = DateTime.now().difference(last.timestamp);
        String timeAgo;
        if (diff.inMinutes < 60) {
          timeAgo = '${diff.inMinutes}m ago';
        } else if (diff.inHours < 24) {
          timeAgo = '${diff.inHours}h ago';
        } else {
          timeAgo = '${diff.inDays}d ago';
        }
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Row(
            children: [
              Icon(
                Icons.restaurant,
                size: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Last fed: $timeAgo',
                style: AppTypography.bodySmall.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
