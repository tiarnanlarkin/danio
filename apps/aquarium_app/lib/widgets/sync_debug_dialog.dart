import 'package:danio/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sync_service.dart';
import '../services/conflict_resolver.dart';

/// Debug/info dialog showing detailed sync status
class SyncDebugDialog extends ConsumerWidget {
  const SyncDebugDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncServiceProvider);

    return AlertDialog(
      title: const Text('Sync Status'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Queue status
            _InfoRow(
              label: 'Queued Actions',
              value: '${syncState.queuedCount}',
              icon: Icons.queue,
            ),
            const SizedBox(height: AppSpacing.sm2),

            // Last sync time
            if (syncState.lastSyncTime != null)
              _InfoRow(
                label: 'Last Sync',
                value: _formatDateTime(syncState.lastSyncTime!),
                icon: Icons.sync,
              ),
            if (syncState.lastSyncTime != null) const SizedBox(height: AppSpacing.sm2),

            // Conflicts resolved
            _InfoRow(
              label: 'Conflicts Resolved',
              value: '${syncState.conflictsResolved}',
              icon: Icons.merge,
              color: syncState.conflictsResolved > 0 ? AppColors.warning : null,
            ),
            const SizedBox(height: AppSpacing.sm2),

            // Recent conflicts
            if (syncState.hasConflicts) ...[
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Recent Conflicts:',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...syncState.recentConflicts.map(
                (conflict) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber,
                        size: AppIconSizes.xs,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          conflict,
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm2),
            ],

            // Queued actions detail
            if (syncState.hasQueuedActions) ...[
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Queued Actions:',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...syncState.queuedActions.map(
                (action) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(_getActionIcon(action.type), size: AppIconSizes.xs),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              SyncService.getActionDescription(action),
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(),
                            ),
                            Text(
                              _formatDateTime(action.timestamp),
                              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Error
            if (syncState.lastError != null) ...[
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: EdgeInsets.all(AppSpacing.sm2),
                decoration: BoxDecoration(
                  color: AppColors.errorAlpha10,
                  borderRadius: AppRadius.smallRadius,
                  border: Border.all(color: AppColors.errorAlpha30),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        syncState.lastError!,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (syncState.hasQueuedActions) ...[
          TextButton(
            onPressed: () {
              ref.read(syncServiceProvider.notifier).clearQueue();
              Navigator.of(context).pop();
            },
            child: const Text('Clear Queue'),
          ),
          TextButton(
            onPressed: () {
              ref.read(syncServiceProvider.notifier).syncNow();
              Navigator.of(context).pop();
            },
            child: const Text('Sync Now'),
          ),
        ],
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  IconData _getActionIcon(SyncActionType type) {
    switch (type) {
      case SyncActionType.xpAward:
        return Icons.star;
      case SyncActionType.gemPurchase:
        return Icons.shopping_cart;
      case SyncActionType.gemEarn:
        return Icons.diamond;
      case SyncActionType.profileUpdate:
        return Icons.person;
      case SyncActionType.lessonComplete:
        return Icons.school;
      case SyncActionType.achievementUnlock:
        return Icons.emoji_events;
      case SyncActionType.streakUpdate:
        return Icons.local_fire_department;
    }
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppIconSizes.sm, color: color ?? AppColors.primary),
        const SizedBox(width: AppSpacing.sm2),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith( fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
