import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

import '../models/models.dart';
import 'storage_service.dart';

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

  static const int _schemaVersion = 1;
  static const String _fileName = 'aquarium_data.json';

  // P0-1 FIX: Lock to prevent race conditions during concurrent saves
  final Lock _persistLock = Lock();

  bool _loaded = false;
  Future<void>? _loadFuture;

  final Map<String, Tank> _tanks = {};
  final Map<String, Livestock> _livestock = {};
  final Map<String, Equipment> _equipment = {};
  final Map<String, LogEntry> _logs = {};
  final Map<String, Task> _tasks = {};

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _loadFuture ??= _loadFromDisk();
    await _loadFuture;
  }

  Future<File> _dataFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, _fileName));
  }

  // P0-2 FIX: Enhanced error handling with backup/recovery
  Future<void> _loadFromDisk() async {
    try {
      final file = await _dataFile();
      if (!await file.exists()) {
        _loaded = true;
        return;
      }

      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        _loaded = true;
        return;
      }

      // Attempt to parse JSON
      Map<String, dynamic> json;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! Map<String, dynamic>) {
          throw FormatException('Root JSON is not a Map');
        }
        json = decoded;
      } catch (parseError) {
        // P0-2: Save corrupted file as backup
        final corruptedPath = '${file.path}.corrupted';
        await file.copy(corruptedPath);
        
        // Log error for debugging
        debugPrint('❌ STORAGE ERROR: Failed to parse JSON');
        debugPrint('   Error: $parseError');
        debugPrint('   Corrupted file saved to: $corruptedPath');
        debugPrint('   Timestamp: ${DateTime.now().toIso8601String()}');
        
        // Throw custom exception with recovery options
        throw StorageCorruptionException(
          'Failed to load aquarium data. The storage file appears to be corrupted.',
          corruptedFilePath: corruptedPath,
          originalError: parseError,
        );
      }

      // Parse entities with error handling
      try {
        final tanks = (json['tanks'] as Map?)?.cast<String, dynamic>() ?? const {};
        final livestock = (json['livestock'] as Map?)?.cast<String, dynamic>() ?? const {};
        final equipment = (json['equipment'] as Map?)?.cast<String, dynamic>() ?? const {};
        final logs = (json['logs'] as Map?)?.cast<String, dynamic>() ?? const {};
        final tasks = (json['tasks'] as Map?)?.cast<String, dynamic>() ?? const {};

        _tanks
          ..clear()
          ..addEntries(tanks.entries.map((e) => MapEntry(e.key, _tankFromJson(e.value))));

        _livestock
          ..clear()
          ..addEntries(livestock.entries.map((e) => MapEntry(e.key, _livestockFromJson(e.value))));

        _equipment
          ..clear()
          ..addEntries(equipment.entries.map((e) => MapEntry(e.key, _equipmentFromJson(e.value))));

        _logs
          ..clear()
          ..addEntries(logs.entries.map((e) => MapEntry(e.key, _logFromJson(e.value))));

        _tasks
          ..clear()
          ..addEntries(tasks.entries.map((e) => MapEntry(e.key, _taskFromJson(e.value))));

        _loaded = true;
        debugPrint('✅ Storage loaded successfully: ${_tanks.length} tanks, ${_livestock.length} livestock');
      } catch (entityError) {
        // Error during entity parsing (malformed data structure)
        final corruptedPath = '${file.path}.corrupted';
        await file.copy(corruptedPath);
        
        debugPrint('❌ STORAGE ERROR: Failed to parse entities');
        debugPrint('   Error: $entityError');
        debugPrint('   Corrupted file saved to: $corruptedPath');
        debugPrint('   Timestamp: ${DateTime.now().toIso8601String()}');
        
        throw StorageCorruptionException(
          'Failed to load aquarium data. Data structure is corrupted.',
          corruptedFilePath: corruptedPath,
          originalError: entityError,
        );
      }
    } catch (e) {
      // Re-throw StorageCorruptionException as-is
      if (e is StorageCorruptionException) {
        rethrow;
      }
      
      // For other errors (file I/O, etc.), log and mark as loaded (soft fail)
      debugPrint('⚠️  STORAGE WARNING: Unexpected error during load: $e');
      _loaded = true;
    }
  }

  // P0-1 FIX: Synchronized persist to prevent race conditions
  Future<void> _persist() async {
    // Use lock to ensure only one save operation happens at a time
    return _persistLock.synchronized(() async {
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

      // Atomic write using temp file
      final tmp = File('${file.path}.tmp');
      await tmp.writeAsString(jsonEncode(payload));
      await tmp.rename(file.path);
      
      // Log successful saves (can be removed in production)
      debugPrint('💾 Storage persisted: ${_tanks.length} tanks, ${_livestock.length} livestock');
    });
  }

  /// Recovery method: Clear all data and start fresh
  /// This should be called from the UI when user chooses "Start Fresh"
  Future<void> clearAllData() async {
    _tanks.clear();
    _livestock.clear();
    _equipment.clear();
    _logs.clear();
    _tasks.clear();
    
    final file = await _dataFile();
    if (await file.exists()) {
      await file.delete();
    }
    
    _loaded = true;
    debugPrint('🗑️  All storage data cleared');
  }

  // --- Tanks ---
  @override
  Future<List<Tank>> getAllTanks() async {
    await _ensureLoaded();
    return _tanks.values.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<Tank?> getTank(String id) async {
    await _ensureLoaded();
    return _tanks[id];
  }

  @override
  Future<void> saveTank(Tank tank) async {
    await _ensureLoaded();
    _tanks[tank.id] = tank;
    await _persist();
  }

  @override
  Future<void> deleteTank(String id) async {
    await _ensureLoaded();
    _tanks.remove(id);
    _livestock.removeWhere((_, v) => v.tankId == id);
    _equipment.removeWhere((_, v) => v.tankId == id);
    _logs.removeWhere((_, v) => v.tankId == id);
    _tasks.removeWhere((_, v) => v.tankId == id);
    await _persist();
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
    _livestock[livestock.id] = livestock;
    await _persist();
  }

  @override
  Future<void> deleteLivestock(String id) async {
    await _ensureLoaded();
    _livestock.remove(id);
    await _persist();
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
    _equipment[equipment.id] = equipment;
    await _persist();
  }

  @override
  Future<void> deleteEquipment(String id) async {
    await _ensureLoaded();
    _equipment.remove(id);
    await _persist();
  }

  // --- Logs ---
  @override
  Future<List<LogEntry>> getLogsForTank(String tankId, {int? limit}) async {
    await _ensureLoaded();
    var logs = _logs.values.where((l) => l.tankId == tankId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (limit != null && logs.length > limit) logs = logs.take(limit).toList();
    return logs;
  }

  @override
  Future<void> saveLog(LogEntry log) async {
    await _ensureLoaded();
    _logs[log.id] = log;
    await _persist();
  }

  @override
  Future<void> deleteLog(String id) async {
    await _ensureLoaded();
    _logs.remove(id);
    await _persist();
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
    _tasks[task.id] = task;
    await _persist();
  }

  @override
  Future<void> deleteTask(String id) async {
    await _ensureLoaded();
    _tasks.remove(id);
    await _persist();
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
        'createdAt': t.createdAt.toIso8601String(),
        'updatedAt': t.updatedAt.toIso8601String(),
      };

  Tank _tankFromJson(dynamic raw) {
    final m = (raw as Map).cast<String, dynamic>();
    return Tank(
      id: m['id'] as String,
      name: m['name'] as String,
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
      lastServiced: m['lastServiced'] != null ? DateTime.parse(m['lastServiced'] as String) : null,
      installedDate: m['installedDate'] != null ? DateTime.parse(m['installedDate'] as String) : null,
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
    if (raw is! Map) return const WaterTestResults();
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
      waterTest: m['waterTest'] != null ? _waterTestFromJson(m['waterTest']) : null,
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
      dueDate: m['dueDate'] != null ? DateTime.parse(m['dueDate'] as String) : null,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == (m['priority'] ?? 'normal'),
        orElse: () => TaskPriority.normal,
      ),
      isEnabled: (m['isEnabled'] as bool?) ?? true,
      isAutoGenerated: (m['isAutoGenerated'] as bool?) ?? false,
      lastCompletedAt:
          m['lastCompletedAt'] != null ? DateTime.parse(m['lastCompletedAt'] as String) : null,
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
