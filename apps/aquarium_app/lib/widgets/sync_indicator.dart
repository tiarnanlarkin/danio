import 'package:danio/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sync_service.dart';
import 'sync_debug_dialog.dart';

/// A widget that shows sync status (e.g., "Syncing..." or queued count)
/// Appears as a banner below the offline indicator
class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncServiceProvider);
    final statusMessage = ref.watch(syncStatusMessageProvider);

    // Don't show if nothing to display
    if (statusMessage == null) {
      return const SizedBox.shrink();
    }

    final isError = syncState.lastError != null;
    final isSyncing = syncState.isSyncing;
    final hasConflicts = syncState.hasConflicts;

    return GestureDetector(
      onTap: () {
        if (kDebugMode) {
          // Show detailed sync status dialog (debug only)
          showDialog(
            context: context,
            builder: (context) => const SyncDebugDialog(),
          );
        }
      },
      child: AnimatedContainer(
        duration: AppDurations.medium4,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isError
              ? AppColors.errorAlpha10
              : hasConflicts
              ? AppColors.warningAlpha10
              : isSyncing
              ? AppColors.warningAlpha10
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border(
            bottom: BorderSide(
              color: isError
                  ? AppColors.errorAlpha30
                  : hasConflicts
                  ? AppColors.warningAlpha30
                  : isSyncing
                  ? AppColors.warningAlpha40
                  : Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            if (isSyncing)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFFFF6F00),
                  ),
                ),
              )
            else
              Icon(
                isError
                    ? Icons.error_outline
                    : hasConflicts
                    ? Icons.merge
                    : Icons.cloud_upload,
                color: isError
                    ? AppColors.error
                    : hasConflicts
                    ? AppColors.warning
                    : isSyncing
                    ? AppColors.warning
                    : context.textSecondary,
                size: AppIconSizes.sm,
              ),
            const SizedBox(width: AppSpacing.sm2),
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: Text(
                  statusMessage,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: isError
                        ? AppColors.error
                        : hasConflicts
                        ? AppColors.warning
                        : isSyncing
                        ? AppColors.warning
                        : context.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            if (!isSyncing && syncState.hasQueuedActions)
              TextButton(
                onPressed: () {
                  ref.read(syncServiceProvider.notifier).syncNow();
                },
                child: const Text('Retry'),
              )
            else
              Icon(Icons.info_outline, size: AppIconSizes.xs, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }
}

/// A compact sync indicator that can be used in app bar or other tight spaces
class SyncIndicatorCompact extends ConsumerWidget {
  const SyncIndicatorCompact({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncServiceProvider);

    if (!syncState.isSyncing && !syncState.hasQueuedActions) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: syncState.isSyncing
            ? const Color(0xFFFFECB3)
            : Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: AppRadius.mediumRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (syncState.isSyncing)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFFF6F00)),
              ),
            )
          else
            Icon(Icons.cloud_upload, color: context.textSecondary, size: 12),
          const SizedBox(width: AppSpacing.xs),
          Text(
            syncState.isSyncing ? 'Syncing' : '${syncState.queuedCount}',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: syncState.isSyncing
                  ? AppColors.warning
                  : context.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// A floating action button style sync button
/// Shows when there are queued actions and user is online
class SyncFloatingButton extends ConsumerWidget {
  const SyncFloatingButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needsSync = ref.watch(needsSyncProvider);
    final syncState = ref.watch(syncServiceProvider);

    if (!needsSync || syncState.isSyncing) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      onPressed: () {
        ref.read(syncServiceProvider.notifier).syncNow();
      },
      icon: const Icon(Icons.cloud_upload),
      label: Text('Sync ${syncState.queuedCount}'),
      backgroundColor: AppColors.primary,
    );
  }
}
