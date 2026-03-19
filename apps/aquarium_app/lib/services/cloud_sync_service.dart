import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/auth_provider.dart';
import '../models/models.dart';
import 'local_json_storage_service.dart';
import 'supabase_service.dart';

// ---------------------------------------------------------------------------
// Sync status
// ---------------------------------------------------------------------------

/// High-level sync status for the UI.
enum CloudSyncStatus { synced, syncing, offline, error, disabled }

/// Riverpod provider for current sync status.
final cloudSyncStatusProvider = StateProvider<CloudSyncStatus>((ref) {
  if (!SupabaseService.isInitialised) return CloudSyncStatus.disabled;
  final auth = ref.watch(authProvider);
  if (!auth.isSignedIn) return CloudSyncStatus.disabled;
  return CloudSyncStatus.synced;
});

/// Provider for the cloud sync service singleton.
final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  final service = CloudSyncService(ref);
  ref.onDispose(() => service.stopListening());
  return service;
});

/// Model for sync conflict notifications.
class SyncConflict {
  final String table;
  final String recordId;
  final DateTime detectedAt;

  SyncConflict({
    required this.table,
    required this.recordId,
    required this.detectedAt,
  });
}

/// Provider for the latest sync conflict (UI can watch this to show snackbar).
final _syncConflictProvider = StateProvider<SyncConflict?>((ref) => null);

/// Public provider for UI to watch sync conflicts.
final syncConflictProvider = Provider<SyncConflict?>((ref) {
  return ref.watch(_syncConflictProvider);
});

// ---------------------------------------------------------------------------
// Sync tables
// ---------------------------------------------------------------------------

/// The Supabase tables we sync.
const List<String> kSyncTables = [
  'user_tanks',
  'user_fish',
  'water_parameters',
  'tasks',
  'inventory_items',
  'journal_entries',
];

// ---------------------------------------------------------------------------
// Offline queue entry
// ---------------------------------------------------------------------------

class OfflineQueueEntry {
  final String id;
  final String table;
  final String operation; // 'upsert' | 'delete'
  final Map<String, dynamic> data;
  final DateTime createdAt;

  OfflineQueueEntry({
    required this.id,
    required this.table,
    required this.operation,
    required this.data,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'table': table,
    'operation': operation,
    'data': data,
    'createdAt': createdAt.toIso8601String(),
  };

  factory OfflineQueueEntry.fromJson(Map<String, dynamic> json) {
    return OfflineQueueEntry(
      id: json['id'] as String,
      table: json['table'] as String,
      operation: json['operation'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

// ---------------------------------------------------------------------------
// Cloud Sync Service
// ---------------------------------------------------------------------------

/// Handles real-time sync with Supabase, offline queue, and conflict resolution.
///
/// Sync strategy:
/// - Last-write-wins based on updated_at for most tables
/// - Water parameters: always append (never overwrite history)
/// - Soft deletes via deleted_at column
/// - Offline queue: queued in SharedPreferences, flushed on reconnect
///
/// Sync triggers:
/// - On app foreground (via lifecycle listener in main)
/// - On data change (debounced 5 seconds)
/// - On demand (manual trigger)
class CloudSyncService {
  CloudSyncService(this._ref);

  final Ref _ref;
  Timer? _debounceTimer;
  final List<RealtimeChannel> _channels = [];
  bool _isRunning = false;

  static const String _queueKey = 'cloud_sync_offline_queue';
  static const Duration _debounceDuration = Duration(seconds: 5);

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Start listening for realtime changes on all sync tables.
  void startListening() {
    if (!SupabaseService.isInitialised) return;
    final userId = SupabaseService.instance.currentUser?.id;
    if (userId == null) return;

    stopListening();

    for (final table in kSyncTables) {
      final channel = SupabaseService.instance.client.channel('sync_$table');
      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: table,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) => _handleRemoteChange(table, payload),
          )
          .subscribe();

      _channels.add(channel);
    }

    debugPrint('[CloudSync] Listening on ${kSyncTables.length} tables');
  }

  /// Stop all realtime subscriptions.
  void stopListening() {
    for (final channel in _channels) {
      SupabaseService.instance.client.removeChannel(channel);
    }
    _channels.clear();
    _debounceTimer?.cancel();
  }

  // ---------------------------------------------------------------------------
  // Remote change handler
  // ---------------------------------------------------------------------------

  void _handleRemoteChange(String table, PostgresChangePayload payload) {
    debugPrint('[CloudSync] Remote change on $table: ${payload.eventType}');

    // For water_parameters, always append (never overwrite local history)
    if (table == 'water_parameters') {
      _handleWaterParameterChange(payload);
      return;
    }

    // For other tables: last-write-wins
    final newRecord = payload.newRecord;
    if (newRecord.isEmpty) return;

    final remoteUpdatedAt = DateTime.tryParse(
      newRecord['updated_at'] as String? ?? '',
    );

    // Merge into local storage
    // The actual merge is table-specific and delegates to LocalJsonStorageService
    _mergeRemoteRecord(table, newRecord, remoteUpdatedAt);
  }

  Future<void> _handleWaterParameterChange(
    PostgresChangePayload payload,
  ) async {
    // Water parameters: always append, never overwrite
    final newRecord = payload.newRecord;
    if (newRecord.isEmpty) return;

    debugPrint('[CloudSync] Appending water parameter from cloud');

    // Merge into local water parameter history: append if not already present
    final storage = LocalJsonStorageService();
    final tankId = newRecord['tank_id'] as String?;
    final recordId = newRecord['id'] as String?;
    if (tankId == null || recordId == null) return;

    try {
      final existingLogs = await storage.getLogsForTank(tankId);
      final alreadyExists = existingLogs.any((log) => log.id == recordId);

      if (!alreadyExists) {
        // Create a LogEntry from the remote water parameter record
        final now = DateTime.now();
        final log = LogEntry(
          id: recordId,
          tankId: tankId,
          timestamp:
              DateTime.tryParse(newRecord['tested_at'] as String? ?? '') ?? now,
          type: LogType.waterTest,
          notes: newRecord['notes'] as String? ?? 'Synced from cloud',
          waterTest: _parseWaterTestFromRemote(newRecord),
          createdAt:
              DateTime.tryParse(newRecord['created_at'] as String? ?? '') ??
              now,
        );
        await storage.saveLog(log);
        debugPrint(
          '[CloudSync] Appended water parameter $recordId for tank $tankId',
        );
      }
    } catch (e) {
      debugPrint('[CloudSync] Failed to merge water parameter: $e');
    }
  }

  /// Parse a remote water parameter record into WaterTestResults.
  WaterTestResults? _parseWaterTestFromRemote(Map<String, dynamic> record) {
    try {
      return WaterTestResults(
        ph: (record['ph'] as num?)?.toDouble(),
        ammonia: (record['ammonia'] as num?)?.toDouble(),
        nitrite: (record['nitrite'] as num?)?.toDouble(),
        nitrate: (record['nitrate'] as num?)?.toDouble(),
        temperature: (record['temperature'] as num?)?.toDouble(),
        kh: (record['kh'] as num?)?.toDouble(),
        gh: (record['gh'] as num?)?.toDouble(),
      );
    } catch (e) {
      debugPrint('CloudSync: failed to parse water test record: $e');
      return null;
    }
  }

  /// Parse equipment type string to EquipmentType enum.
  EquipmentType _parseEquipmentType(String? type) {
    if (type == null) return EquipmentType.other;
    return EquipmentType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => EquipmentType.other,
    );
  }

  Future<void> _mergeRemoteRecord(
    String table,
    Map<String, dynamic> record,
    DateTime? remoteUpdatedAt,
  ) async {
    // Check for significant divergence (>24h gap)
    if (remoteUpdatedAt != null) {
      final gap = DateTime.now().difference(remoteUpdatedAt);
      if (gap.inHours > 24) {
        debugPrint(
          '[CloudSync] WARNING: >24h divergence on $table '
          'record ${record['id']}',
        );
        // Show conflict notification via a global key snackbar
        _showConflictNotification(table, record['id'] as String? ?? 'unknown');
      }
    }

    // Per-table merge into LocalJsonStorageService using last-write-wins
    await _mergeIntoLocalStorage(table, record, remoteUpdatedAt);
    debugPrint('[CloudSync] Merged remote $table record: ${record['id']}');
  }

  /// Show a conflict notification via the sync conflict provider.
  /// UI widgets can watch [syncConflictProvider] to show snackbars.
  void _showConflictNotification(String table, String recordId) {
    debugPrint(
      '[CloudSync] ⚠️ CONFLICT: $table/$recordId has >24h divergence. '
      'Remote data may differ from local. Latest version kept.',
    );

    // Post to a conflict notification provider that the UI can listen to
    _ref.read(_syncConflictProvider.notifier).state = SyncConflict(
      table: table,
      recordId: recordId,
      detectedAt: DateTime.now(),
    );
  }

  /// Merge a remote record into LocalJsonStorageService.
  /// Strategy: last-write-wins on updated_at, soft delete preservation.
  Future<void> _mergeIntoLocalStorage(
    String table,
    Map<String, dynamic> record,
    DateTime? remoteUpdatedAt,
  ) async {
    final storage = LocalJsonStorageService();
    final recordId = record['id'] as String?;
    if (recordId == null) return;

    // Check for soft delete
    final deletedAt = record['deleted_at'] as String?;
    if (deletedAt != null) {
      // Remote was soft-deleted - apply locally
      await _deleteFromLocal(storage, table, recordId);
      return;
    }

    try {
      switch (table) {
        case 'user_tanks':
          await _mergeTank(storage, record, remoteUpdatedAt);
          break;
        case 'user_fish':
          await _mergeLivestock(storage, record, remoteUpdatedAt);
          break;
        case 'inventory_items':
          await _mergeEquipment(storage, record, remoteUpdatedAt);
          break;
        case 'tasks':
          await _mergeTask(storage, record, remoteUpdatedAt);
          break;
        case 'journal_entries':
          await _mergeJournalEntry(storage, record, remoteUpdatedAt);
          break;
        // water_parameters handled separately in _handleWaterParameterChange
      }
    } catch (e) {
      debugPrint('[CloudSync] Failed to merge $table/$recordId: $e');
    }
  }

  Future<void> _mergeTank(
    LocalJsonStorageService storage,
    Map<String, dynamic> record,
    DateTime? remoteUpdatedAt,
  ) async {
    final id = record['id'] as String;
    final localTank = await storage.getTank(id);

    // Last-write-wins: only overwrite if remote is newer or local doesn't exist
    if (localTank != null && remoteUpdatedAt != null) {
      if (localTank.updatedAt.isAfter(remoteUpdatedAt)) return;
    }

    final now = DateTime.now();
    final tank = Tank(
      id: id,
      name: record['name'] as String? ?? 'Unnamed Tank',
      type: (record['tank_type'] as String?) == 'marine'
          ? TankType.marine
          : TankType.freshwater,
      volumeLitres: (record['volume_litres'] as num?)?.toDouble() ?? 0,
      startDate:
          DateTime.tryParse(record['start_date'] as String? ?? '') ?? now,
      targets: WaterTargets.freshwaterTropical(),
      createdAt:
          DateTime.tryParse(record['created_at'] as String? ?? '') ?? now,
      updatedAt: remoteUpdatedAt ?? now,
    );
    await storage.saveTank(tank);
  }

  Future<void> _mergeLivestock(
    LocalJsonStorageService storage,
    Map<String, dynamic> record,
    DateTime? remoteUpdatedAt,
  ) async {
    final id = record['id'] as String;
    final tankId = record['tank_id'] as String? ?? '';
    final existing = (await storage.getLivestockForTank(
      tankId,
    )).where((l) => l.id == id).firstOrNull;

    if (existing != null && remoteUpdatedAt != null) {
      if (existing.updatedAt.isAfter(remoteUpdatedAt)) return;
    }

    final now = DateTime.now();
    final livestock = Livestock(
      id: id,
      tankId: tankId,
      commonName:
          record['common_name'] as String? ??
          record['name'] as String? ??
          'Unknown',
      scientificName: record['scientific_name'] as String?,
      count:
          (record['count'] as num?)?.toInt() ??
          (record['quantity'] as num?)?.toInt() ??
          1,
      dateAdded:
          DateTime.tryParse(record['date_added'] as String? ?? '') ?? now,
      createdAt:
          DateTime.tryParse(record['created_at'] as String? ?? '') ?? now,
      updatedAt: remoteUpdatedAt ?? now,
    );
    await storage.saveLivestock(livestock);
  }

  Future<void> _mergeEquipment(
    LocalJsonStorageService storage,
    Map<String, dynamic> record,
    DateTime? remoteUpdatedAt,
  ) async {
    final id = record['id'] as String;
    final tankId = record['tank_id'] as String? ?? '';
    final existing = (await storage.getEquipmentForTank(
      tankId,
    )).where((e) => e.id == id).firstOrNull;

    if (existing != null && remoteUpdatedAt != null) {
      if (existing.updatedAt.isAfter(remoteUpdatedAt)) return;
    }

    final now = DateTime.now();
    final equipmentType = _parseEquipmentType(record['type'] as String?);
    final equipment = Equipment(
      id: id,
      tankId: tankId,
      name: record['name'] as String? ?? 'Unknown',
      type: equipmentType,
      brand: record['brand'] as String?,
      createdAt:
          DateTime.tryParse(record['created_at'] as String? ?? '') ?? now,
      updatedAt: remoteUpdatedAt ?? now,
    );
    await storage.saveEquipment(equipment);
  }

  Future<void> _mergeTask(
    LocalJsonStorageService storage,
    Map<String, dynamic> record,
    DateTime? remoteUpdatedAt,
  ) async {
    final id = record['id'] as String;
    final tankId = record['tank_id'] as String?;
    final existingTasks = await storage.getTasksForTank(tankId);
    final existing = existingTasks.where((t) => t.id == id).firstOrNull;

    if (existing != null && remoteUpdatedAt != null) {
      if (existing.updatedAt.isAfter(remoteUpdatedAt)) return;
    }

    final now = DateTime.now();
    final task = Task(
      id: id,
      tankId: tankId,
      title: record['title'] as String? ?? 'Untitled Task',
      description: record['description'] as String?,
      recurrence: RecurrenceType.none,
      dueDate: DateTime.tryParse(record['due_date'] as String? ?? ''),
      isEnabled: record['is_enabled'] as bool? ?? true,
      createdAt:
          DateTime.tryParse(record['created_at'] as String? ?? '') ?? now,
      updatedAt: remoteUpdatedAt ?? now,
    );
    await storage.saveTask(task);
  }

  Future<void> _mergeJournalEntry(
    LocalJsonStorageService storage,
    Map<String, dynamic> record,
    DateTime? remoteUpdatedAt,
  ) async {
    final id = record['id'] as String;
    final tankId = record['tank_id'] as String? ?? '';
    final existingLogs = await storage.getLogsForTank(tankId);
    final existing = existingLogs.where((l) => l.id == id).firstOrNull;

    if (existing != null) {
      // Journal entries: skip if already exists (append-only like water params)
      return;
    }

    final now = DateTime.now();
    final log = LogEntry(
      id: id,
      tankId: tankId,
      timestamp:
          DateTime.tryParse(record['entry_date'] as String? ?? '') ?? now,
      type: LogType.observation,
      notes: record['notes'] as String? ?? '',
      createdAt:
          DateTime.tryParse(record['created_at'] as String? ?? '') ?? now,
    );
    await storage.saveLog(log);
  }

  Future<void> _deleteFromLocal(
    LocalJsonStorageService storage,
    String table,
    String recordId,
  ) async {
    try {
      switch (table) {
        case 'user_tanks':
          await storage.deleteTank(recordId);
          break;
        case 'user_fish':
          await storage.deleteLivestock(recordId);
          break;
        case 'inventory_items':
          await storage.deleteEquipment(recordId);
          break;
        case 'tasks':
          await storage.deleteTask(recordId);
          break;
        case 'journal_entries':
        case 'water_parameters':
          await storage.deleteLog(recordId);
          break;
      }
      debugPrint('[CloudSync] Soft-deleted $table/$recordId locally');
    } catch (e) {
      debugPrint('[CloudSync] Failed to delete $table/$recordId: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Sync (push local → cloud)
  // ---------------------------------------------------------------------------

  /// Trigger a full sync. Called on foreground, on data change, or manually.
  Future<void> syncNow() async {
    if (!SupabaseService.isInitialised) return;
    if (_isRunning) return;
    final userId = SupabaseService.instance.currentUser?.id;
    if (userId == null) return;

    _isRunning = true;
    _ref.read(cloudSyncStatusProvider.notifier).state = CloudSyncStatus.syncing;

    try {
      // 1. Flush offline queue first
      await _flushOfflineQueue();

      // 2. Pull latest from each table and merge
      for (final table in kSyncTables) {
        await _pullTable(table, userId);
      }

      _ref.read(cloudSyncStatusProvider.notifier).state =
          CloudSyncStatus.synced;
      debugPrint('[CloudSync] Full sync completed');
    } catch (e) {
      debugPrint('[CloudSync] Sync error: $e');
      _ref.read(cloudSyncStatusProvider.notifier).state = CloudSyncStatus.error;
    } finally {
      _isRunning = false;
    }
  }

  Future<void> _pullTable(String table, String userId) async {
    try {
      final response = await SupabaseService.instance
          .from(table)
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      final rows = response as List<dynamic>;
      for (final row in rows) {
        final record = row as Map<String, dynamic>;
        final remoteUpdatedAt = DateTime.tryParse(
          record['updated_at'] as String? ?? '',
        );
        await _mergeRemoteRecord(table, record, remoteUpdatedAt);
      }
    } catch (e) {
      debugPrint('[CloudSync] Failed to pull $table: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Debounced push (called when local data changes)
  // ---------------------------------------------------------------------------

  /// Schedule a sync after a 5-second debounce.
  void scheduleSync() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, syncNow);
  }

  // ---------------------------------------------------------------------------
  // Offline queue
  // ---------------------------------------------------------------------------

  /// Queue a change for later sync (when offline).
  Future<void> queueOfflineChange(OfflineQueueEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_queueKey) ?? [];
    existing.add(json.encode(entry.toJson()));
    await prefs.setStringList(_queueKey, existing);
    debugPrint('[CloudSync] Queued offline change: ${entry.table}/${entry.id}');
  }

  /// Flush all queued offline changes to Supabase.
  Future<void> _flushOfflineQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_queueKey) ?? [];
    if (queue.isEmpty) return;

    debugPrint('[CloudSync] Flushing ${queue.length} offline changes');
    final failed = <String>[];

    for (final entryJson in queue) {
      try {
        final entry = OfflineQueueEntry.fromJson(
          json.decode(entryJson) as Map<String, dynamic>,
        );
        await _pushEntry(entry);
      } catch (e) {
        debugPrint('[CloudSync] Failed to flush entry: $e');
        failed.add(entryJson);
      }
    }

    // Keep failed entries for retry
    await prefs.setStringList(_queueKey, failed);
    if (failed.isNotEmpty) {
      debugPrint('[CloudSync] ${failed.length} entries remain in queue');
    }
  }

  Future<void> _pushEntry(OfflineQueueEntry entry) async {
    if (entry.operation == 'delete') {
      // Soft delete - set deleted_at
      await SupabaseService.instance
          .from(entry.table)
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', entry.id);
    } else {
      // Upsert
      await SupabaseService.instance.from(entry.table).upsert(entry.data);
    }
  }

  // ---------------------------------------------------------------------------
  // Push a single record now (or queue if offline)
  // ---------------------------------------------------------------------------

  /// Push a local change to the cloud. If offline, queues it.
  Future<void> pushChange({
    required String table,
    required String id,
    required Map<String, dynamic> data,
    String operation = 'upsert',
  }) async {
    final isOnline = await _checkConnectivity();

    if (!isOnline || !SupabaseService.isInitialised) {
      await queueOfflineChange(
        OfflineQueueEntry(
          id: id,
          table: table,
          operation: operation,
          data: data,
        ),
      );
      return;
    }

    try {
      await _pushEntry(
        OfflineQueueEntry(
          id: id,
          table: table,
          operation: operation,
          data: data,
        ),
      );
    } catch (e) {
      // Network error - queue for retry
      await queueOfflineChange(
        OfflineQueueEntry(
          id: id,
          table: table,
          operation: operation,
          data: data,
        ),
      );
    }

    scheduleSync();
  }

  Future<bool> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (e) {
      debugPrint('CloudSync: connectivity check failed: $e');
      return false;
    }
  }
}
