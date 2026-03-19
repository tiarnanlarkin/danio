// SCAFFOLDING: Backend sync not yet implemented. Queued actions execute locally only.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/offline_indicator.dart';
import 'sync_service.dart';
import 'package:danio/utils/logger.dart';

/// A helper service that wraps actions to make them offline-aware
/// Automatically queues actions when offline and executes them when online
class OfflineAwareService {
  OfflineAwareService(this.ref);

  final Ref ref;

  /// Execute an action, queueing it for sync if offline
  /// Returns true if executed immediately, false if queued
  Future<bool> executeOrQueue({
    required SyncActionType actionType,
    required Map<String, dynamic> actionData,
    required Future<void> Function() executeNow,
  }) async {
    final isOnline = ref.read(isOnlineProvider);

    if (isOnline) {
      // Execute immediately when online
      await executeNow();
      return true;
    } else {
      // Queue for later sync when offline
      // But also execute locally so the app still works
      await executeNow(); // Execute locally first

      // Then queue for backend sync when connection returns
      appLog('Note: Sync queue is scaffolding — action executed locally only', tag: 'OfflineAwareService');
      await ref
          .read(syncServiceProvider.notifier)
          .queueAction(type: actionType, data: actionData);

      return false;
    }
  }

  /// Award XP (offline-aware)
  Future<void> awardXp({
    required int amount,
    required Future<void> Function() localUpdate,
  }) async {
    await executeOrQueue(
      actionType: SyncActionType.xpAward,
      actionData: {'xp': amount, 'timestamp': DateTime.now().toIso8601String()},
      executeNow: localUpdate,
    );
  }

  /// Complete lesson (offline-aware)
  Future<void> completeLesson({
    required String lessonId,
    required int xpReward,
    required Future<void> Function() localUpdate,
  }) async {
    await executeOrQueue(
      actionType: SyncActionType.lessonComplete,
      actionData: {
        'lessonId': lessonId,
        'xpReward': xpReward,
        'timestamp': DateTime.now().toIso8601String(),
      },
      executeNow: localUpdate,
    );
  }

  /// Purchase with gems (offline-aware)
  Future<void> purchaseWithGems({
    required String itemId,
    required String itemName,
    required int cost,
    required Future<void> Function() localUpdate,
  }) async {
    await executeOrQueue(
      actionType: SyncActionType.gemPurchase,
      actionData: {
        'itemId': itemId,
        'itemName': itemName,
        'cost': cost,
        'timestamp': DateTime.now().toIso8601String(),
      },
      executeNow: localUpdate,
    );
  }

  /// Earn gems (offline-aware)
  Future<void> earnGems({
    required int amount,
    required String reason,
    required Future<void> Function() localUpdate,
  }) async {
    await executeOrQueue(
      actionType: SyncActionType.gemEarn,
      actionData: {
        'amount': amount,
        'reason': reason,
        'timestamp': DateTime.now().toIso8601String(),
      },
      executeNow: localUpdate,
    );
  }

  /// Update profile (offline-aware)
  Future<void> updateProfile({
    required Map<String, dynamic> updates,
    required Future<void> Function() localUpdate,
  }) async {
    await executeOrQueue(
      actionType: SyncActionType.profileUpdate,
      actionData: {...updates, 'timestamp': DateTime.now().toIso8601String()},
      executeNow: localUpdate,
    );
  }

  /// Unlock achievement (offline-aware)
  Future<void> unlockAchievement({
    required String achievementId,
    required Future<void> Function() localUpdate,
  }) async {
    await executeOrQueue(
      actionType: SyncActionType.achievementUnlock,
      actionData: {
        'achievementId': achievementId,
        'timestamp': DateTime.now().toIso8601String(),
      },
      executeNow: localUpdate,
    );
  }

  /// Update streak (offline-aware)
  Future<void> updateStreak({
    required int currentStreak,
    required Future<void> Function() localUpdate,
  }) async {
    await executeOrQueue(
      actionType: SyncActionType.streakUpdate,
      actionData: {
        'currentStreak': currentStreak,
        'timestamp': DateTime.now().toIso8601String(),
      },
      executeNow: localUpdate,
    );
  }
}

/// Provider for offline-aware service
final offlineAwareServiceProvider = Provider<OfflineAwareService>((ref) {
  return OfflineAwareService(ref);
});
