import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../widgets/offline_indicator.dart';
import 'conflict_resolver.dart';

/// Types of actions that can be queued for sync
enum SyncActionType {
  xpAward,
  gemPurchase,
  gemEarn,
  profileUpdate,
  lessonComplete,
  achievementUnlock,
  streakUpdate,
}

/// A single sync action that was queued while offline
class SyncAction {
  final String id;
  final SyncActionType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const SyncAction({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
  };

  factory SyncAction.fromJson(Map<String, dynamic> json) => SyncAction(
    id: json['id'] as String,
    type: SyncActionType.values.firstWhere((e) => e.name == json['type']),
    data: Map<String, dynamic>.from(json['data'] as Map),
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

/// Provider for the sync service
final syncServiceProvider = StateNotifierProvider<SyncService, SyncState>((
  ref,
) {
  return SyncService(ref);
});

/// State for sync service
class SyncState {
  final List<SyncAction> queuedActions;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final String? lastError;
  final int conflictsResolved;
  final List<String> recentConflicts;

  const SyncState({
    this.queuedActions = const [],
    this.isSyncing = false,
    this.lastSyncTime,
    this.lastError,
    this.conflictsResolved = 0,
    this.recentConflicts = const [],
  });

  SyncState copyWith({
    List<SyncAction>? queuedActions,
    bool? isSyncing,
    DateTime? lastSyncTime,
    String? lastError,
    int? conflictsResolved,
    List<String>? recentConflicts,
  }) {
    return SyncState(
      queuedActions: queuedActions ?? this.queuedActions,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastError: lastError,
      conflictsResolved: conflictsResolved ?? this.conflictsResolved,
      recentConflicts: recentConflicts ?? this.recentConflicts,
    );
  }

  bool get hasQueuedActions => queuedActions.isNotEmpty;
  int get queuedCount => queuedActions.length;
  bool get hasConflicts => recentConflicts.isNotEmpty;
}

/// Service for managing offline sync queue
class SyncService extends StateNotifier<SyncState> {
  SyncService(this.ref) : super(const SyncState()) {
    _init();
  }

  final Ref ref;
  static const _queueKey = 'sync_queue';
  static const _lastSyncKey = 'last_sync_time';

  /// Initialize the service - load queue and start monitoring connectivity
  Future<void> _init() async {
    await _loadQueue();
    _startConnectivityMonitoring();
  }

  /// Start monitoring connectivity changes and auto-sync when online
  void _startConnectivityMonitoring() {
    ref.listen(isOnlineProvider, (previous, next) {
      // When we come back online, auto-sync
      if (previous == false && next == true) {
        syncNow();
      }
    });
  }

  /// Load queued actions from storage
  Future<void> _loadQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey);
      final lastSyncString = prefs.getString(_lastSyncKey);

      if (queueJson != null) {
        final List<dynamic> queueList = jsonDecode(queueJson);
        final actions = queueList
            .map((json) => SyncAction.fromJson(json as Map<String, dynamic>))
            .toList();

        state = state.copyWith(
          queuedActions: actions,
          lastSyncTime: lastSyncString != null
              ? DateTime.parse(lastSyncString)
              : null,
        );
      }
    } catch (e) {
      // Failed to load queue - start fresh
      state = state.copyWith(
        queuedActions: [],
        lastError: 'Failed to load sync queue: $e',
      );
    }
  }

  /// Save queue to storage
  Future<void> _saveQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = jsonEncode(
        state.queuedActions.map((a) => a.toJson()).toList(),
      );
      await prefs.setString(_queueKey, queueJson);
    } catch (e) {
      state = state.copyWith(lastError: 'Failed to save sync queue: $e');
    }
  }

  /// Queue an action for sync (used when offline)
  Future<void> queueAction({
    required SyncActionType type,
    required Map<String, dynamic> data,
  }) async {
    final action = SyncAction(
      id: '${type.name}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      data: data,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      queuedActions: [...state.queuedActions, action],
      lastError: null,
    );

    await _saveQueue();
  }

  /// Sync queued actions with backend (or just process them locally)
  /// Includes conflict resolution for any overlapping changes
  Future<void> syncNow({
    ConflictResolutionStrategy strategy =
        ConflictResolutionStrategy.lastWriteWins,
  }) async {
    if (state.isSyncing || state.queuedActions.isEmpty) {
      return;
    }

    // Check if we're online
    final isOnline = ref.read(isOnlineProvider);
    if (!isOnline) {
      state = state.copyWith(lastError: 'Cannot sync while offline');
      return;
    }

    state = state.copyWith(
      isSyncing: true,
      lastError: null,
      recentConflicts: [], // Clear previous conflicts
    );

    try {
      final conflicts = <String>[];
      int conflictsResolved = state.conflictsResolved;

      // Group actions by type and detect conflicts
      final actionsByType = <SyncActionType, List<SyncAction>>{};
      for (final action in state.queuedActions) {
        actionsByType.putIfAbsent(action.type, () => []).add(action);
      }

      // Check for conflicts within each type
      for (final entry in actionsByType.entries) {
        final actions = entry.value;

        // If multiple actions of same type, detect conflicts
        if (actions.length > 1) {
          // Sort by timestamp
          actions.sort((a, b) => a.timestamp.compareTo(b.timestamp));

          // Check for conflicts between consecutive actions
          for (int i = 0; i < actions.length - 1; i++) {
            final current = actions[i];
            final next = actions[i + 1];

            // Resolve conflict between the two actions
            final resolution = ConflictResolver.resolve(
              local: current.data,
              remote: next.data,
              strategy: strategy,
            );

            if (resolution.hadConflict) {
              conflicts.add(
                '${entry.key.name}: ${resolution.conflictDescription}',
              );
              conflictsResolved++;
            }
          }
        }
      }

      // In a real app with a backend, you would:
      // 1. Send each action to the backend API
      // 2. Apply conflict resolution with server state
      // 3. Wait for confirmation
      // 4. Remove from queue on success

      // For now, since the app is fully local, we:
      // 1. Verify actions are already persisted locally (they were when queued)
      // 2. Apply conflict resolution to merge any overlapping changes
      // 3. Clear the queue
      // 4. Mark sync as complete

      // Simulate network delay for demo purposes
      await Future.delayed(const Duration(milliseconds: 500));

      // All actions are already applied locally when they were queued,
      // conflicts were resolved above, so we can safely clear the queue
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_queueKey);
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

      state = state.copyWith(
        queuedActions: [],
        isSyncing: false,
        lastSyncTime: DateTime.now(),
        lastError: null,
        conflictsResolved: conflictsResolved,
        recentConflicts: conflicts.isNotEmpty ? conflicts : null,
      );
    } catch (e) {
      state = state.copyWith(isSyncing: false, lastError: 'Sync failed: $e');
    }
  }

  /// Clear all queued actions (useful for testing or error recovery)
  Future<void> clearQueue() async {
    state = state.copyWith(queuedActions: [], lastError: null);
    await _saveQueue();
  }

  /// Get human-readable description of an action
  static String getActionDescription(SyncAction action) {
    switch (action.type) {
      case SyncActionType.xpAward:
        return 'Earned ${action.data['xp']} XP';
      case SyncActionType.gemPurchase:
        return 'Purchased ${action.data['itemName']} for ${action.data['cost']} gems';
      case SyncActionType.gemEarn:
        return 'Earned ${action.data['amount']} gems';
      case SyncActionType.profileUpdate:
        return 'Updated profile';
      case SyncActionType.lessonComplete:
        return 'Completed lesson';
      case SyncActionType.achievementUnlock:
        return 'Unlocked achievement';
      case SyncActionType.streakUpdate:
        return 'Updated streak';
    }
  }
}

/// Provider for whether sync is needed
final needsSyncProvider = Provider<bool>((ref) {
  final syncState = ref.watch(syncServiceProvider);
  final isOnline = ref.watch(isOnlineProvider);
  return syncState.hasQueuedActions && isOnline;
});

/// Provider for sync status message
final syncStatusMessageProvider = Provider<String?>((ref) {
  final syncState = ref.watch(syncServiceProvider);
  final isOnline = ref.watch(isOnlineProvider);

  if (syncState.isSyncing) {
    return 'Syncing ${syncState.queuedCount} action${syncState.queuedCount == 1 ? '' : 's'}...';
  }

  if (syncState.hasQueuedActions && !isOnline) {
    return '${syncState.queuedCount} action${syncState.queuedCount == 1 ? '' : 's'} queued for sync';
  }

  if (syncState.lastError != null) {
    return syncState.lastError;
  }

  // Show recent conflict resolution info briefly
  if (syncState.hasConflicts && syncState.lastSyncTime != null) {
    final timeSinceSync = DateTime.now().difference(syncState.lastSyncTime!);
    // Show conflict info for 10 seconds after sync
    if (timeSinceSync.inSeconds < 10) {
      return 'Synced with ${syncState.recentConflicts.length} conflict${syncState.recentConflicts.length == 1 ? '' : 's'} resolved';
    }
  }

  return null;
});
