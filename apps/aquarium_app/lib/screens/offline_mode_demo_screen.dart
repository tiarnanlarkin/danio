import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/offline_indicator.dart';
import '../widgets/sync_indicator.dart';
import '../services/sync_service.dart';
import '../services/offline_aware_service.dart';
import '../providers/user_profile_provider.dart';
import '../providers/gems_provider.dart';
import '../models/gem_transaction.dart';

/// Demo screen showing offline mode features
/// Useful for testing and demonstrating offline functionality
class OfflineModeDemoScreen extends ConsumerWidget {
  const OfflineModeDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncServiceProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final statusMessage = ref.watch(syncStatusMessageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Mode Demo'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: OfflineIndicatorCompact(),
          ),
          Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: SyncIndicatorCompact(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline and sync indicators
          const OfflineIndicator(),
          const SyncIndicator(),

          // Main content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Connection status
                _StatusCard(
                  title: 'Connection Status',
                  icon: isOnline ? Icons.wifi : Icons.wifi_off,
                  iconColor: isOnline ? Colors.green : Colors.orange,
                  children: [
                    _InfoRow(
                      label: 'Status',
                      value: isOnline ? 'Online' : 'Offline',
                      valueColor: isOnline ? Colors.green : Colors.orange,
                    ),
                    if (statusMessage != null)
                      _InfoRow(label: 'Message', value: statusMessage),
                  ],
                ),

                const SizedBox(height: 16),

                // Sync queue status
                _StatusCard(
                  title: 'Sync Queue',
                  icon: Icons.cloud_sync,
                  iconColor: Colors.blue,
                  children: [
                    _InfoRow(
                      label: 'Queued Actions',
                      value: '${syncState.queuedCount}',
                    ),
                    _InfoRow(
                      label: 'Syncing',
                      value: syncState.isSyncing ? 'Yes' : 'No',
                    ),
                    if (syncState.lastSyncTime != null)
                      _InfoRow(
                        label: 'Last Sync',
                        value: _formatTime(syncState.lastSyncTime!),
                      ),
                    if (syncState.lastError != null)
                      _InfoRow(
                        label: 'Error',
                        value: syncState.lastError!,
                        valueColor: Colors.red,
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Queued actions list
                if (syncState.queuedActions.isNotEmpty) ...[
                  _StatusCard(
                    title: 'Queued Actions',
                    icon: Icons.list,
                    iconColor: Colors.purple,
                    children: syncState.queuedActions.map((action) {
                      final description = SyncService.getActionDescription(
                        action,
                      );
                      final time = _formatTime(action.timestamp);
                      return ListTile(
                        dense: true,
                        leading: _getActionIcon(action.type),
                        title: Text(description),
                        subtitle: Text(time),
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Test actions
                _StatusCard(
                  title: 'Test Actions',
                  icon: Icons.science,
                  iconColor: Colors.orange,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'These actions will work offline and automatically queue for sync:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                    _TestActionButton(
                      label: 'Award 50 XP',
                      icon: Icons.stars,
                      onPressed: () => _testAwardXP(ref),
                    ),
                    _TestActionButton(
                      label: 'Earn 10 Gems',
                      icon: Icons.diamond,
                      onPressed: () => _testEarnGems(ref),
                    ),
                    _TestActionButton(
                      label: 'Complete Lesson',
                      icon: Icons.check_circle,
                      onPressed: () => _testCompleteLesson(ref, context),
                    ),
                    _TestActionButton(
                      label: 'Update Profile',
                      icon: Icons.person,
                      onPressed: () => _testUpdateProfile(ref),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Manual controls
                _StatusCard(
                  title: 'Manual Controls',
                  icon: Icons.settings,
                  iconColor: Colors.blueGrey,
                  children: [
                    ElevatedButton.icon(
                      onPressed:
                          syncState.isSyncing || !syncState.hasQueuedActions
                          ? null
                          : () {
                              ref.read(syncServiceProvider.notifier).syncNow();
                            },
                      icon: const Icon(Icons.sync),
                      label: const Text('Sync Now'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: syncState.queuedActions.isEmpty
                          ? null
                          : () {
                              ref
                                  .read(syncServiceProvider.notifier)
                                  .clearQueue();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Queue cleared')),
                              );
                            },
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Clear Queue'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Instructions
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'How to Test',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '1. Turn on Airplane Mode\n'
                          '2. Perform test actions\n'
                          '3. See actions queued\n'
                          '4. Turn off Airplane Mode\n'
                          '5. Watch auto-sync happen!',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testAwardXP(WidgetRef ref) async {
    final offlineService = ref.read(offlineAwareServiceProvider);
    await offlineService.awardXp(
      amount: 50,
      localUpdate: () async {
        await ref.read(userProfileProvider.notifier).addXp(50);
      },
    );
  }

  Future<void> _testEarnGems(WidgetRef ref) async {
    final offlineService = ref.read(offlineAwareServiceProvider);
    await offlineService.earnGems(
      amount: 10,
      reason: 'Test reward',
      localUpdate: () async {
        await ref
            .read(gemsProvider.notifier)
            .addGems(
              amount: 10,
              reason: GemEarnReason.promotional,
              customReason: 'Test reward',
            );
      },
    );
  }

  Future<void> _testCompleteLesson(WidgetRef ref, BuildContext context) async {
    final offlineService = ref.read(offlineAwareServiceProvider);
    await offlineService.completeLesson(
      lessonId: 'test_lesson_${DateTime.now().millisecondsSinceEpoch}',
      xpReward: 50,
      localUpdate: () async {
        // Would normally update profile here
        // Simplified for demo
      },
    );

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lesson completed (demo)')));
    }
  }

  Future<void> _testUpdateProfile(WidgetRef ref) async {
    final offlineService = ref.read(offlineAwareServiceProvider);
    await offlineService.updateProfile(
      updates: {'lastUpdated': DateTime.now().toIso8601String()},
      localUpdate: () async {
        // Would normally update profile here
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Icon _getActionIcon(SyncActionType type) {
    switch (type) {
      case SyncActionType.xpAward:
        return const Icon(Icons.stars, size: 20);
      case SyncActionType.gemPurchase:
      case SyncActionType.gemEarn:
        return const Icon(Icons.diamond, size: 20);
      case SyncActionType.profileUpdate:
        return const Icon(Icons.person, size: 20);
      case SyncActionType.lessonComplete:
        return const Icon(Icons.check_circle, size: 20);
      case SyncActionType.achievementUnlock:
        return const Icon(Icons.emoji_events, size: 20);
      case SyncActionType.streakUpdate:
        return const Icon(Icons.local_fire_department, size: 20);
    }
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const _StatusCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TestActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _TestActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
        ),
      ),
    );
  }
}
