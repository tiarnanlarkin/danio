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
        // Show detailed sync status dialog
        showDialog(
          context: context,
          builder: (context) => const SyncDebugDialog(),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isError
              ? Colors.red.shade100
              : hasConflicts
                  ? Colors.orange.shade100
                  : isSyncing
                      ? Colors.blue.shade100
                      : Colors.grey.shade100,
          border: Border(
            bottom: BorderSide(
              color: isError
                  ? Colors.red.shade300
                  : hasConflicts
                      ? Colors.orange.shade300
                      : isSyncing
                          ? Colors.blue.shade300
                          : Colors.grey.shade300,
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
                    Colors.blue.shade900,
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
                    ? Colors.red.shade900
                    : hasConflicts
                        ? Colors.orange.shade900
                        : isSyncing
                            ? Colors.blue.shade900
                            : Colors.grey.shade700,
                size: 20,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                statusMessage,
                style: TextStyle(
                  color: isError
                      ? Colors.red.shade900
                      : hasConflicts
                          ? Colors.orange.shade900
                          : isSyncing
                              ? Colors.blue.shade900
                              : Colors.grey.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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
              Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.grey.shade600,
              ),
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
            ? Colors.blue.shade100
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
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
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.blue.shade900,
                ),
              ),
            )
          else
            Icon(
              Icons.cloud_upload,
              color: Colors.grey.shade700,
              size: 12,
            ),
          const SizedBox(width: 4),
          Text(
            syncState.isSyncing ? 'Syncing' : '${syncState.queuedCount}',
            style: TextStyle(
              color: syncState.isSyncing
                  ? Colors.blue.shade900
                  : Colors.grey.shade700,
              fontSize: 12,
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
      backgroundColor: Colors.blue,
    );
  }
}
