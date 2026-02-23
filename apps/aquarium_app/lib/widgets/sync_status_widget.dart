import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/cloud_sync_service.dart';

/// Compact sync-status indicator designed to sit in an AppBar's actions.
///
/// Shows:
/// - ✓ cloud_done (green)  — synced
/// - ↻ sync (blue)         — syncing
/// - ☁ cloud_off (orange)  — offline (changes queued)
/// - ✕ error (red)         — sync error
/// - nothing               — cloud disabled / not signed in
class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(cloudSyncStatusProvider);

    // Don't show anything when cloud is disabled
    if (status == CloudSyncStatus.disabled) {
      return const SizedBox.shrink();
    }

    final (IconData icon, Color color, String tooltip) = switch (status) {
      CloudSyncStatus.synced => (
          Icons.cloud_done_outlined,
          Colors.green,
          'Synced',
        ),
      CloudSyncStatus.syncing => (
          Icons.sync,
          Colors.blue,
          'Syncing…',
        ),
      CloudSyncStatus.offline => (
          Icons.cloud_off_outlined,
          Colors.orange,
          'Offline — changes queued',
        ),
      CloudSyncStatus.error => (
          Icons.error_outline,
          Colors.red,
          'Sync error',
        ),
      CloudSyncStatus.disabled => (
          Icons.cloud_off,
          Colors.grey,
          'Cloud disabled',
        ),
    };

    return Tooltip(
      message: tooltip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: status == CloudSyncStatus.syncing
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            : Icon(icon, color: color, size: AppIconSizes.sm),
      ),
    );
  }
}
