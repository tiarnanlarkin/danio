import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

import '../models/models.dart';
import 'storage_service.dart';
import '../utils/logger.dart';

/// Custom exception for storage corruption/parse failures
class StorageCorruptionException implements Exception {
  final String message;
  final String? corruptedFilePath;
  final Object? originalError;

  StorageCorruptionException(
    this.message, {
    this.corruptedFilePath,
    this.originalError,
  });

  @override
  String toString() => 'StorageCorruptionException: $message';
}

/// Storage service loading state
enum StorageState {
  idle, // Not yet loaded
  loading, // Currently loading
  loaded, // Successfully loaded
  corrupted, // Failed to load due to corruption
  ioError, // Failed to load due to I/O error
}

/// Information about a storage error
class StorageError {
  final StorageState state;
  final String message;
  final String? corruptedFilePath;
  final DateTime timestamp;
  final Object? originalError;

  StorageError({
    required this.state,
    required this.message,
    this.corruptedFilePath,
    required this.timestamp,
    this.originalError,
  });

  @override
  String toString() => 'StorageError[$state]: $message';
}

/// Local JSON-file persistence for MVP.
///
/// Stores all entities in a single JSON file under app documents.
/// This is intentionally simple (good enough for MVP) and can be
/// swapped later for Hive/SQLite without changing the StorageService API.
class LocalJsonStorageService implements StorageService {
  // Singleton
  static final LocalJsonStorageService _instance = LocalJsonStorageService._();
  factory LocalJsonStorageService() => _instance;
  LocalJsonStorageService._();

  /// Bump this constant whenever the stored JSON shape changes.
  /// [_migrateJson] must handle all transitions from lower versions.
  static const int _schemaVersion = 2;
  static const String _fileName = 'aquarium_data.json';

  // P0-1 FIX: Lock to prevent race conditions during concurrent saves
  final Lock _persistLock = Lock();

  bool _firstSaveDone = false;

  // P0-2 FIX: Enhanced state tracking for error handling
  StorageState _state = StorageState.idle;
  StorageError? _lastError;
  Future<void>? _loadFuture;

  /// Public getters for UI to check service state
  StorageState get state => _state;
  StorageError? get lastError => _lastError;
  bool get isHealthy => _state == StorageState.loaded;
  bool get hasError =>
      _state == StorageState.corrupted || _state == StorageState.ioError;

  final Map<String, Tank> _tanks = {};
  final Map<String, Livestock> _livestock = {};
  final Map<String, Equipment> _equipment = {};
  final Map<String, LogEntry> _logs = {};
  final Map<String, Task> _tasks = {};

  /// Ensures data is loaded, handles errors gracefully
  /// Throws StorageCorruptionException if data is corrupted and can't be recovered
  Future<void> _ensureLoaded() async {
    // If already loaded successfully, return
    if (_state == StorageState.loaded) return;

    // If already in error state, throw the stored error
    if (_state == StorageState.corrupted) {
      throw _lastError!.originalError ??
          StorageCorruptionException(_lastError!.message);
    }

    // If loading is in progress, wait for it
    if (_loadFuture != null) {
      await _loadFuture;
      return;
    }

    // Start loading
    _loadFuture = _loadFromDisk();
    await _loadFuture;
  }

  Future<File> _dataFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, _fileName));
  }

  // P0-2 FIX: Enhanced error handling with backup/recovery and proper state management
  Future<void> _loadFromDisk() async {
    _state = StorageState.loading;
    _lastError = null;

    try {
      final file = await _dataFile();

      // File doesn't exist - this is a fresh install
      if (!await file.exists()) {
        appLog('📦 Storage: No data file found, starting fresh', tag: 'LocalJsonStorageService');
        _state = StorageState.loaded;
        return;
      }

      // File exists but is empty - treat as fresh start
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        appLog('📦 Storage: Empty data file, starting fresh', tag: 'LocalJsonStorageService');
        _state = StorageState.loaded;
        return;
      }

      // Attempt to parse JSON
      Map<String, dynamic> json;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! Map<String, dynamic>) {
          throw FormatException(
            'Root JSON is not a Map, got: ${decoded.runtimeType}',
          );
        }
        json = decoded;

        // FB-T3: Run forward-only schema migrations before loading entities.
        json = _migrateJson(json);
      } catch (parseError) {
        // P0-2: Save corrupted file as backup before handling error
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final corruptedPath = '${file.path}.corrupted.$timestamp';

        try {
          await file.copy(corruptedPath);
          logError('💾 Corrupted file backed up to: $corruptedPath', tag: 'LocalJsonStorageService');
        } catch (backupError) {
          logError('⚠️  Failed to backup corrupted file: $backupError', tag: 'LocalJsonStorageService');
        }

        // Log detailed error for debugging
        logError('❌ STORAGE ERROR: JSON Parsing Failed', tag: 'LocalJsonStorageService');
        logError('   Error: $parseError', tag: 'LocalJsonStorageService');
        logError('   File: ${file.path}', tag: 'LocalJsonStorageService');
        appLog('   Backup: $corruptedPath', tag: 'LocalJsonStorageService');
        appLog('   Timestamp: ${DateTime.now().toIso8601String()}', tag: 'LocalJsonStorageService');

        // Store error state
        final error = StorageCorruptionException(
          'Failed to load aquarium data. The storage file appears to be corrupted.',
          corruptedFilePath: corruptedPath,
          originalError: parseError,
        );

        _lastError = StorageError(
          state: StorageState.corrupted,
          message: 'JSON parsing failed: ${parseError.toString()}',
          corruptedFilePath: corruptedPath,
          timestamp: DateTime.now(),
          originalError: error,
        );

        _state = StorageState.corrupted;
        throw error;
      }

      // Parse entities with robust error handling
      try {
        _parseAndLoadEntities(json);

        _state = StorageState.loaded;
        appLog('✅ Storage loaded successfully: ${_tanks.length} tanks, ${_livestock.length} livestock, ${_equipment.length} equipment', tag: 'LocalJsonStorageService');
      } catch (entityError) {
        // Error during entity parsing (malformed data structure)
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final corruptedPath = '${file.path}.corrupted.$timestamp';

        try {
          await file.copy(corruptedPath);
          logError('💾 Corrupted file backed up to: $corruptedPath', tag: 'LocalJsonStorageService');
        } catch (backupError) {
          logError('⚠️  Failed to backup corrupted file: $backupError', tag: 'LocalJsonStorageService');
        }

        logError('❌ STORAGE ERROR: Entity Parsing Failed', tag: 'LocalJsonStorageService');
        logError('   Error: $entityError', tag: 'LocalJsonStorageService');
        logError('   File: ${file.path}', tag: 'LocalJsonStorageService');
        logError('   Backup: $corruptedPath', tag: 'LocalJsonStorageService');
        appLog('   Timestamp: ${DateTime.now().toIso8601String()}', tag: 'LocalJsonStorageService');

        // Store error state
        final error = StorageCorruptionException(
          'Failed to load aquarium data. Data structure is corrupted.',
          corruptedFilePath: corruptedPath,
          originalError: entityError,
        );

        _lastError = StorageError(
          state: StorageState.corrupted,
          message: 'Entity parsing failed: ${entityError.toString()}',
          corruptedFilePath: corruptedPath,
          timestamp: DateTime.now(),
          originalError: error,
        );

        _state = StorageState.corrupted;
        throw error;
      }
    } on StorageCorruptionException {
      // Already handled above, just rethrow
      rethrow;
    } catch (e, stackTrace) {
      // Unexpected errors (file I/O, permissions, etc.)
      logError('⚠️  STORAGE ERROR: Unexpected error during load', stackTrace: stackTrace, tag: 'LocalJsonStorageService');
      logError('   Error: $e', stackTrace: stackTrace, tag: 'LocalJsonStorageService');
      logError('   Stack: $stackTrace', stackTrace: stackTrace, tag: 'LocalJsonStorageService');

      // Store error but allow service to continue with empty data
      _lastError = StorageError(
        state: StorageState.ioError,
        message: 'I/O error: ${e.toString()}',
        timestamp: DateTime.now(),
        originalError: e,
      );

      // Mark as loaded with empty data (soft fail for I/O errors)
      _state = StorageState.loaded;
      appLog('⚠️  Continuing with empty data due to I/O error', tag: 'LocalJsonStorageService');
    }
  }

  // ── FB-T3: Schema migration ──────────────────────────────────────────────

  /// Applies forward-only, safe-default migrations to the raw JSON payload.
  ///
  /// Rules:
  ///  * Never delete existing keys — only add new ones with safe defaults.
  ///  * Each version block is guarded by `storedVersion < N`.
  ///  * On completion the `version` key is stamped with [_schemaVersion].
  ///  * A migration event is logged so it is visible in crash reports.
  Map<String, dynamic> _migrateJson(Map<String, dynamic> json) {
    final int storedVersion = (json['version'] as int?) ?? 0;

    if (storedVersion >= _schemaVersion) {
      return json; // Fast path — nothing to do.
    }

    appLog(
      '📦 Storage migration: v$storedVersion → v$_schemaVersion',
      tag: 'LocalJsonStorageService',
    );

    // Work on a mutable copy so callers can decide what to do with the result.
    final migrated = Map<String, dynamic>.from(json);

    // ── v0 → v1 ───────────────────────────────────────────────────────────
    // Original schema: tanks/livestock/equipment/logs/tasks maps.
    // No structural changes required; stamp the version key.
    if (storedVersion < 1) {
      migrated['version'] = 1;
      appLog('Migration v0 → v1 complete (version stamp)', tag: 'LocalJsonStorageService');
    }

    // ── v1 → v2 ───────────────────────────────────────────────────────────
    // Added `sortOrder` to Tank and `isDemoTank` to Tank.
    // Both fields are nullable/have defaults in [_tankFromJson], so no
    // structural transform is needed — we just ensure the version is stamped
    // so the file is not re-migrated on every launch.
    if (storedVersion < 2) {
      migrated['version'] = 2;
      appLog('Migration v1 → v2 complete (tank sortOrder/isDemoTank defaults applied on read)', tag: 'LocalJsonStorageService');
    }

    // ── Future migrations ─────────────────────────────────────────────────
    // if (storedVersion < 3) {
    //   // Add new field with safe default, e.g.:
    //   // final tanks = (migrated['tanks'] as Map?)?.cast<String, dynamic>() ?? {};
    //   // for (final entry in tanks.entries) {
    //   //   final t = Map<String, dynamic>.from(entry.value as Map);
    //   //   t['newField'] ??= 'defaultValue';
    //   //   tanks[entry.key] = t;
    //   // }
    //   // migrated['tanks'] = tanks;
    //   migrated['version'] = 3;
    // }

    return migrated;
  }

  /// Parse and load all entities from JSON, with error recovery
  void _parseAndLoadEntities(Map<String, dynamic> json) {
    // Clear existing data
    _tanks.clear();
    _livestock.clear();
    _equipment.clear();
    _logs.clear();
    _tasks.clear();

    // Track parsing errors for partial recovery
    final errors = <String>[];

    // Parse tanks with individual error handling
    final tanksJson =
        (json['tanks'] as Map?)?.cast<String, dynamic>() ?? const {};
    for (final entry in tanksJson.entries) {
      try {
        _tanks[entry.key] = _tankFromJson(entry.value);
      } catch (e) {
        errors.add('Tank ${entry.key}: $e');
        logError('⚠️  Skipping corrupted tank: ${entry.key} - $e', tag: 'LocalJsonStorageService');
      }
    }

    // Parse livestock with individual error handling
    final livestockJson =
        (json['livestock'] as Map?)?.cast<String, dynamic>() ?? const {};
    for (final entry in livestockJson.entries) {
      try {
        _livestock[entry.key] = _livestockFromJson(entry.value);
      } catch (e) {
        errors.add('Livestock ${entry.key}: $e');
        logError('⚠️  Skipping corrupted livestock: ${entry.key} - $e', tag: 'LocalJsonStorageService');
      }
    }

    // Parse equipment with individual error handling
    final equipmentJson =
        (json['equipment'] as Map?)?.cast<String, dynamic>() ?? const {};
    for (final entry in equipmentJson.entries) {
      try {
        _equipment[entry.key] = _equipmentFromJson(entry.value);
      } catch (e) {
        errors.add('Equipment ${entry.key}: $e');
        logError('⚠️  Skipping corrupted equipment: ${entry.key} - $e', tag: 'LocalJsonStorageService');
      }
    }

    // Parse logs with individual error handling
    final logsJson =
        (json['logs'] as Map?)?.cast<String, dynamic>() ?? const {};
    for (final entry in logsJson.entries) {
      try {
        _logs[entry.key] = _logFromJson(entry.value);
      } catch (e) {
        errors.add('Log ${entry.key}: $e');
        logError('⚠️  Skipping corrupted log: ${entry.key} - $e', tag: 'LocalJsonStorageService');
      }
    }

    // Parse tasks with individual error handling
    final tasksJson =
        (json['tasks'] as Map?)?.cast<String, dynamic>() ?? const {};
    for (final entry in tasksJson.entries) {
      try {
        _tasks[entry.key] = _taskFromJson(entry.value);
      } catch (e) {
        errors.add('Task ${entry.key}: $e');
        logError('⚠️  Skipping corrupted task: ${entry.key} - $e', tag: 'LocalJsonStorageService');
      }
    }

    // If too many errors occurred, this might indicate a serious problem
    if (errors.length > 10) {
      throw FormatException(
        'Too many entity parsing errors (${errors.length}). Data may be severely corrupted.',
      );
    }

    if (errors.isNotEmpty) {
      appLog('⚠️  Loaded with ${errors.length} corrupted entities skipped', tag: 'LocalJsonStorageService');
    }
  }

  // P0-1 FIX: Private persistence method WITHOUT lock
  // This is called from within synchronized blocks in public methods
  Future<void> _persistUnlocked() async {
    final file = await _dataFile();

    final payload = <String, dynamic>{
      'version': _schemaVersion,
      'updatedAt': DateTime.now().toIso8601String(),
      'tanks': _tanks.map((k, v) => MapEntry(k, _tankToJson(v))),
      'livestock': _livestock.map((k, v) => MapEntry(k, _livestockToJson(v))),
      'equipment': _equipment.map((k, v) => MapEntry(k, _equipmentToJson(v))),
      'logs': _logs.map((k, v) => MapEntry(k, _logToJson(v))),
      'tasks': _tasks.map((k, v) => MapEntry(k, _taskToJson(v))),
    };

    // Atomic write: .tmp → rename, with .bak of previous version
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode(payload));

    // Keep a backup of the previous version for crash recovery (first save only)
    if (!_firstSaveDone && await file.exists()) {
      final bak = File('${file.path}.bak');
      try {
        await file.copy(bak.path);
        _firstSaveDone = true;
      } catch (e) {
        logError('Storage: backup creation failed before save: $e', tag: 'LocalJsonStorageService');
      }
    }

    await tmp.rename(file.path);

    // Log successful saves (can be removed in production)
    appLog('💾 Storage persisted: ${_tanks.length} tanks, ${_livestock.length} livestock', tag: 'LocalJsonStorageService');
  }

  /// Recovery method: Clear all data and start fresh
  /// This should be called from the UI when user chooses "Start Fresh"
  Future<void> clearAllData() async {
    // P0-1 FIX: Wrap modify+persist in lock to prevent race conditions
    await _persistLock.synchronized(() async {
      _tanks.clear();
      _livestock.clear();
      _equipment.clear();
      _logs.clear();
      _tasks.clear();

      final file = await _dataFile();
      if (await file.exists()) {
        await file.delete();
      }

      // P0-2: Reset error state
      _state = StorageState.loaded;
      _lastError = null;
      _loadFuture = null;

      appLog('🗑️  All storage data cleared, service reset to healthy state', tag: 'LocalJsonStorageService');
    });
  }

  /// Recovery method: Attempt to reload data from disk
  /// Useful if corruption was temporary or file was manually fixed
  Future<void> retryLoad() async {
    appLog('🔄 Attempting to reload storage data...', tag: 'LocalJsonStorageService');

    // Reset state
    _state = StorageState.idle;
    _lastError = null;
    _loadFuture = null;

    // Clear existing data
    _tanks.clear();
    _livestock.clear();
    _equipment.clear();
    _logs.clear();
    _tasks.clear();

    // Attempt reload
    try {
      await _ensureLoaded();
      appLog('✅ Reload successful', tag: 'LocalJsonStorageService');
    } catch (e) {
      logError('❌ Reload failed: $e', tag: 'LocalJsonStorageService');
      rethrow;
    }
  }

  /// Recovery method: Delete corrupted file and start fresh
  /// This preserves the backup but allows the app to continue
  Future<void> recoverFromCorruption() async {
    appLog('🔧 Recovering from storage corruption...', tag: 'LocalJsonStorageService');

    // Delete the main data file
    final file = await _dataFile();
    if (await file.exists()) {
      await file.delete();
      appLog('🗑️  Deleted corrupted data file', tag: 'LocalJsonStorageService');
    }

    // Clear all data and reset state
    await clearAllData();

    appLog('✅ Recovery complete - starting with fresh data', tag: 'LocalJsonStorageService');
  }

  // --- Tanks ---
  @override
  Future<List<Tank>> getAllTanks() async {
    await _ensureLoaded();
    return _tanks.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<Tank?> getTank(String id) async {
    await _ensureLoaded();
    return _tanks[id];
  }

  @override
  Future<void> saveTank(Tank tank) async {
    await _ensureLoaded();
    // P0-1 FIX: Wrap modify+persist in lock to prevent race conditions
    await _persistLock.synchronized(() async {
      _tanks[tank.id] = tank;
      await _persistUnlocked();
    });
  }

  @override
  Future<void> saveTanks(List<Tank> tanks) async {
    await _ensureLoaded();
    await _persistLock.synchronized(() async {
      for (final tank in tanks) {
        _tanks[tank.id] = tank;
      }
      await _persistUnlocked();
    });
  }

  @override
  Future<void> deleteTank(String id) async {
    await _ensureLoaded();
    // P0-1 FIX: Wrap modify+persist in lock to prevent race conditions
    await _persistLock.synchronized(() async {
      _tanks.remove(id);
      _livestock.removeWhere((_, v) => v.tankId == id);
      _equipment.removeWhere((_, v) => v.tankId == id);
      _logs.removeWhere((_, v) => v.tankId == id);
      _tasks.removeWhere((_, v) => v.tankId == id);
      await _persistUnlocked();
    });
  }

  @override
  Future<void> deleteAllTanks(List<String> ids) async {
    await _ensureLoaded();
    await _persistLock.synchronized(() async {
      final idSet = ids.toSet();
      _tanks.removeWhere((id, _) => idSet.contains(id));
      _livestock.removeWhere((_, v) => idSet.contains(v.tankId));
      _equipment.removeWhere((_, v) => idSet.contains(v.tankId));
      _logs.removeWhere((_, v) => idSet.contains(v.tankId));
      _tasks.removeWhere((_, v) => idSet.contains(v.tankId));
      await _persistUnlocked();
    });
  }

  // --- Livestock ---
  @override
  Future<List<Livestock>> getLivestockForTank(String tankId) async {
    await _ensureLoaded();
    return _livestock.values.where((l) => l.tankId == tankId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> saveLivestock(Livestock livestock) async {
    await _ensureLoaded();
    // P0-1 FIX: Wrap modify+persist in lock to prevent race conditions
    await _persistLock.synchronized(() async {
      _livestock[livestock.id] = livestock;
      await _persistUnlocked();
    });
  }

  @override
  Future<void> deleteLivestock(String id) async {
    await _ensureLoaded();
    // P0-1 FIX: Wrap modify+persist in lock to prevent race conditions
    await _persistLock.synchronized(() async {
      _livestock.remove(id);
      await _persistUnlocked();
    });
  }

  // --- Equipment ---
  @override
  Future<List<Equipment>> getEquipmentForTank(String tankId) async {
    await _ensureLoaded();
    return _equipment.values.where((e) => e.tankId == tankId).toList()
      ..sort((a, b) => a.type.index.compareTo(b.type.index));
  }

  @override
  Future<void> saveEquipment(Equipment equipment) async {
    await _ensureLoaded();
    // P0-1 FIX: Wrap modify+persist in lock to prevent race conditions
    await _persistLock.synchronized(() async {
      _equipment[equipment.id] = equipment;
      await _persistUnlocked();
    });
  }

  @override
  Future<void> deleteEquipment(String id) async {
    await _ensureLoaded();
    // P0-1 FIX: Wrap modify+persist in lock to prevent race conditions
    await _persistLock.synchronized(() async {
      _equipment.remove(id);
      await _persistUnlocked();
    });
  }

  // --- Logs ---
  @override
  Future<List<LogEntry>> getLogsForTank(
    String tankId, {
    int? limit,
    DateTime? after,
  }) async {
    await _ensureLoaded();
    var logs = _logs.values.where((l) => l.tankId == tankId).toList();
    if (after != null) {
      logs = logs.where((l) => l.timestamp.isAfter(after)).toList();
    }
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (limit != null && logs.length > limit) logs = logs.take(limit).toList();
    return logs;
  }

  @override
  Future<LogEntry?> getLatestWaterTest(String tankId) async {
    await _ensureLoaded();
    LogEntry? latest;
    for (final log in _logs.values) {
      if (log.tankId == tankId && log.type == LogType.waterTest) {
        if (latest == null || log.timestamp.isAfter(latest.timestamp)) {
          latest = log;
        }
      }
    }
    return latest;
  }

  @override
  Future<void> saveLog(LogEntry log) async {
    await _ensureLoaded();
    // P0-1 FIX: Wrap modify+persist in lock to prevent race conditions
    await _persistLock.synchronized(() async {
      _logs[log.id] = log;
      await _persistUnlocked();
    });
  }

  @override
  Future<void> deleteLog(String id) async {
    await _ensureLoaded();
    // P0-1 FIX: Wrap modify+persist in lock to prevent race conditions
    await _persistLock.synchronized(() async {
      _logs.remove(id);
      await _persistUnlocked();
    });
  }

  // --- Tasks ---
  @override
  Future<List<Task>> getTasksForTank(String? tankId) async {
    await _ensureLoaded();
    var tasks = _tasks.values.toList();
    if (tankId != null) tasks = tasks.where((t) => t.tankId == tankId).toList();

    tasks.sort((a, b) {
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });

    return tasks;
  }

  @override
  Future<void> saveTask(Task task) async {
    await _ensureLoaded();
    // P0-1 FIX: Wrap modify+persist in lock to prevent race conditions
    await _persistLock.synchronized(() async {
      _tasks[task.id] = task;
      await _persistUnlocked();
    });
  }

  @override
  Future<void> deleteTask(String id) async {
    await _ensureLoaded();
    // P0-1 FIX: Wrap modify+persist in lock to prevent race conditions
    await _persistLock.synchronized(() async {
      _tasks.remove(id);
      await _persistUnlocked();
    });
  }

  // ---- Serialization helpers ----
  Map<String, dynamic> _tankToJson(Tank t) => {
    'id': t.id,
    'name': t.name,
    'type': t.type.name,
    'volumeLitres': t.volumeLitres,
    'lengthCm': t.lengthCm,
    'widthCm': t.widthCm,
    'heightCm': t.heightCm,
    'startDate': t.startDate.toIso8601String(),
    'targets': _targetsToJson(t.targets),
    'notes': t.notes,
    'imageUrl': t.imageUrl,
    'sortOrder': t.sortOrder,
    'isDemoTank': t.isDemoTank,
    'createdAt': t.createdAt.toIso8601String(),
    'updatedAt': t.updatedAt.toIso8601String(),
  };

  Tank _tankFromJson(dynamic raw) {
    final m = (raw as Map).cast<String, dynamic>();
    // BUG-001: Defensively decode any accidentally URL-encoded tank names
    // (e.g. "My%20Tank" → "My Tank"). Uri.decodeComponent throws on malformed
    // input, so we fall back to the raw value if decoding fails.
    final rawName = m['name'] as String;
    final decodedName = rawName.contains('%')
        ? (() {
            try {
              return Uri.decodeComponent(rawName);
            } catch (_) {
              return rawName;
            }
          })()
        : rawName;
    return Tank(
      id: m['id'] as String,
      name: decodedName,
      type: TankType.values.firstWhere(
        (e) => e.name == (m['type'] ?? 'freshwater'),
        orElse: () => TankType.freshwater,
      ),
      volumeLitres: _toDouble(m['volumeLitres']) ?? 0,
      lengthCm: _toDouble(m['lengthCm']),
      widthCm: _toDouble(m['widthCm']),
      heightCm: _toDouble(m['heightCm']),
      startDate: DateTime.parse(m['startDate'] as String),
      targets: _targetsFromJson(m['targets']),
      notes: m['notes'] as String?,
      imageUrl: m['imageUrl'] as String?,
      sortOrder: (m['sortOrder'] as int?) ?? 0,
      isDemoTank: (m['isDemoTank'] as bool?) ?? false,
      createdAt: DateTime.parse(m['createdAt'] as String),
      updatedAt: DateTime.parse(m['updatedAt'] as String),
    );
  }

  Map<String, dynamic> _targetsToJson(WaterTargets t) => {
    'tempMin': t.tempMin,
    'tempMax': t.tempMax,
    'phMin': t.phMin,
    'phMax': t.phMax,
    'ghMin': t.ghMin,
    'ghMax': t.ghMax,
    'khMin': t.khMin,
    'khMax': t.khMax,
  };

  WaterTargets _targetsFromJson(dynamic raw) {
    if (raw is! Map) return WaterTargets.freshwaterTropical();
    final m = raw.cast<String, dynamic>();
    return WaterTargets(
      tempMin: _toDouble(m['tempMin']),
      tempMax: _toDouble(m['tempMax']),
      phMin: _toDouble(m['phMin']),
      phMax: _toDouble(m['phMax']),
      ghMin: _toDouble(m['ghMin']),
      ghMax: _toDouble(m['ghMax']),
      khMin: _toDouble(m['khMin']),
      khMax: _toDouble(m['khMax']),
    );
  }

  Map<String, dynamic> _livestockToJson(Livestock l) => {
    'id': l.id,
    'tankId': l.tankId,
    'commonName': l.commonName,
    'scientificName': l.scientificName,
    'count': l.count,
    'sizeCm': l.sizeCm,
    'maxSizeCm': l.maxSizeCm,
    'dateAdded': l.dateAdded.toIso8601String(),
    'source': l.source,
    'temperament': l.temperament?.name,
    'healthStatus': l.healthStatus.name,
    'notes': l.notes,
    'imageUrl': l.imageUrl,
    'createdAt': l.createdAt.toIso8601String(),
    'updatedAt': l.updatedAt.toIso8601String(),
  };

  Livestock _livestockFromJson(dynamic raw) {
    final m = (raw as Map).cast<String, dynamic>();
    return Livestock(
      id: m['id'] as String,
      tankId: m['tankId'] as String,
      commonName: m['commonName'] as String,
      scientificName: m['scientificName'] as String?,
      count: (m['count'] as num?)?.toInt() ?? 1,
      sizeCm: _toDouble(m['sizeCm']),
      maxSizeCm: _toDouble(m['maxSizeCm']),
      dateAdded: DateTime.parse(m['dateAdded'] as String),
      source: m['source'] as String?,
      temperament: (m['temperament'] == null)
          ? null
          : Temperament.values.firstWhere(
              (e) => e.name == m['temperament'],
              orElse: () => Temperament.peaceful,
            ),
      healthStatus: m['healthStatus'] != null
          ? HealthStatus.values.firstWhere(
              (e) => e.name == m['healthStatus'],
              orElse: () => HealthStatus.healthy,
            )
          : HealthStatus.healthy,
      notes: m['notes'] as String?,
      imageUrl: m['imageUrl'] as String?,
      createdAt: DateTime.parse(m['createdAt'] as String),
      updatedAt: DateTime.parse(m['updatedAt'] as String),
    );
  }

  Map<String, dynamic> _equipmentToJson(Equipment e) => {
    'id': e.id,
    'tankId': e.tankId,
    'type': e.type.name,
    'name': e.name,
    'brand': e.brand,
    'model': e.model,
    'settings': e.settings,
    'maintenanceIntervalDays': e.maintenanceIntervalDays,
    'lastServiced': e.lastServiced?.toIso8601String(),
    'installedDate': e.installedDate?.toIso8601String(),
    'notes': e.notes,
    'createdAt': e.createdAt.toIso8601String(),
    'updatedAt': e.updatedAt.toIso8601String(),
  };

  Equipment _equipmentFromJson(dynamic raw) {
    final m = (raw as Map).cast<String, dynamic>();
    return Equipment(
      id: m['id'] as String,
      tankId: m['tankId'] as String,
      type: EquipmentType.values.firstWhere(
        (e) => e.name == (m['type'] ?? 'other'),
        orElse: () => EquipmentType.other,
      ),
      name: m['name'] as String,
      brand: m['brand'] as String?,
      model: m['model'] as String?,
      settings: (m['settings'] as Map?)?.cast<String, dynamic>(),
      maintenanceIntervalDays: (m['maintenanceIntervalDays'] as num?)?.toInt(),
      lastServiced: m['lastServiced'] != null
          ? DateTime.parse(m['lastServiced'] as String)
          : null,
      installedDate: m['installedDate'] != null
          ? DateTime.parse(m['installedDate'] as String)
          : null,
      notes: m['notes'] as String?,
      createdAt: DateTime.parse(m['createdAt'] as String),
      updatedAt: DateTime.parse(m['updatedAt'] as String),
    );
  }

  Map<String, dynamic> _waterTestToJson(WaterTestResults t) => {
    'temperature': t.temperature,
    'ph': t.ph,
    'ammonia': t.ammonia,
    'nitrite': t.nitrite,
    'nitrate': t.nitrate,
    'gh': t.gh,
    'kh': t.kh,
    'phosphate': t.phosphate,
    'co2': t.co2,
  };

  WaterTestResults _waterTestFromJson(dynamic raw) {
    if (raw is! Map) return WaterTestResults();
    final m = raw.cast<String, dynamic>();
    return WaterTestResults(
      temperature: _toDouble(m['temperature']),
      ph: _toDouble(m['ph']),
      ammonia: _toDouble(m['ammonia']),
      nitrite: _toDouble(m['nitrite']),
      nitrate: _toDouble(m['nitrate']),
      gh: _toDouble(m['gh']),
      kh: _toDouble(m['kh']),
      phosphate: _toDouble(m['phosphate']),
      co2: _toDouble(m['co2']),
    );
  }

  Map<String, dynamic> _logToJson(LogEntry l) => {
    'id': l.id,
    'tankId': l.tankId,
    'type': l.type.name,
    'timestamp': l.timestamp.toIso8601String(),
    'waterTest': l.waterTest != null ? _waterTestToJson(l.waterTest!) : null,
    'waterChangePercent': l.waterChangePercent,
    'title': l.title,
    'notes': l.notes,
    'photoUrls': l.photoUrls,
    'relatedEquipmentId': l.relatedEquipmentId,
    'relatedLivestockId': l.relatedLivestockId,
    'relatedTaskId': l.relatedTaskId,
    'createdAt': l.createdAt.toIso8601String(),
  };

  LogEntry _logFromJson(dynamic raw) {
    final m = (raw as Map).cast<String, dynamic>();
    return LogEntry(
      id: m['id'] as String,
      tankId: m['tankId'] as String,
      type: LogType.values.firstWhere(
        (e) => e.name == (m['type'] ?? 'other'),
        orElse: () => LogType.other,
      ),
      timestamp: DateTime.parse(m['timestamp'] as String),
      waterTest: m['waterTest'] != null
          ? _waterTestFromJson(m['waterTest'])
          : null,
      waterChangePercent: (m['waterChangePercent'] as num?)?.toInt(),
      title: m['title'] as String?,
      notes: m['notes'] as String?,
      photoUrls: (m['photoUrls'] as List?)?.map((e) => e.toString()).toList(),
      relatedEquipmentId: m['relatedEquipmentId'] as String?,
      relatedLivestockId: m['relatedLivestockId'] as String?,
      relatedTaskId: m['relatedTaskId'] as String?,
      createdAt: DateTime.parse(m['createdAt'] as String),
    );
  }

  Map<String, dynamic> _taskToJson(Task t) => {
    'id': t.id,
    'tankId': t.tankId,
    'title': t.title,
    'description': t.description,
    'recurrence': t.recurrence.name,
    'intervalDays': t.intervalDays,
    'dueDate': t.dueDate?.toIso8601String(),
    'priority': t.priority.name,
    'isEnabled': t.isEnabled,
    'isAutoGenerated': t.isAutoGenerated,
    'lastCompletedAt': t.lastCompletedAt?.toIso8601String(),
    'completionCount': t.completionCount,
    'relatedEquipmentId': t.relatedEquipmentId,
    'createdAt': t.createdAt.toIso8601String(),
    'updatedAt': t.updatedAt.toIso8601String(),
  };

  Task _taskFromJson(dynamic raw) {
    final m = (raw as Map).cast<String, dynamic>();
    return Task(
      id: m['id'] as String,
      tankId: m['tankId'] as String?,
      title: m['title'] as String,
      description: m['description'] as String?,
      recurrence: RecurrenceType.values.firstWhere(
        (e) => e.name == (m['recurrence'] ?? 'none'),
        orElse: () => RecurrenceType.none,
      ),
      intervalDays: (m['intervalDays'] as num?)?.toInt(),
      dueDate: m['dueDate'] != null
          ? DateTime.parse(m['dueDate'] as String)
          : null,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == (m['priority'] ?? 'normal'),
        orElse: () => TaskPriority.normal,
      ),
      isEnabled: (m['isEnabled'] as bool?) ?? true,
      isAutoGenerated: (m['isAutoGenerated'] as bool?) ?? false,
      lastCompletedAt: m['lastCompletedAt'] != null
          ? DateTime.parse(m['lastCompletedAt'] as String)
          : null,
      completionCount: (m['completionCount'] as num?)?.toInt() ?? 0,
      relatedEquipmentId: m['relatedEquipmentId'] as String?,
      createdAt: DateTime.parse(m['createdAt'] as String),
      updatedAt: DateTime.parse(m['updatedAt'] as String),
    );
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
