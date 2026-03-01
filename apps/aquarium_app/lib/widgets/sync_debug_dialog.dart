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
            const SizedBox(height: 12),

            // Last sync time
            if (syncState.lastSyncTime != null)
              _InfoRow(
                label: 'Last Sync',
                value: _formatDateTime(syncState.lastSyncTime!),
                icon: Icons.sync,
              ),
            if (syncState.lastSyncTime != null) const SizedBox(height: 12),

            // Conflicts resolved
            _InfoRow(
              label: 'Conflicts Resolved',
              value: '${syncState.conflictsResolved}',
              icon: Icons.merge,
              color: syncState.conflictsResolved > 0 ? Colors.orange : null,
            ),
            const SizedBox(height: 12),

            // Recent conflicts
            if (syncState.hasConflicts) ...[
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Recent Conflicts:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                        color: Colors.orange,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          conflict,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Queued actions detail
            if (syncState.hasQueuedActions) ...[
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Queued Actions:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              _formatDateTime(action.timestamp),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
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
                padding: const EdgeInsets.all(AppSpacing.sm2),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: AppRadius.smallRadius,
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade900),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        syncState.lastError!,
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontSize: 12,
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
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
