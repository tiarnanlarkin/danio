import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../utils/logger.dart';
import 'backup_import_relationships.dart';
import 'shared_preferences_backup.dart';
import 'storage_service.dart';

typedef BackupImportIdFactory = String Function();
typedef BackupImportClock = DateTime Function();
typedef BackupPreferencesRestore =
    Future<int> Function(
      Map<String, dynamic> data,
    );
typedef BackupImportInvalidation = void Function();

class BackupImportException implements Exception {
  final String message;
  final Object originalError;
  final StackTrace originalStackTrace;
  final Object? rollbackError;

  const BackupImportException(
    this.message, {
    required this.originalError,
    required this.originalStackTrace,
    this.rollbackError,
  });

  @override
  String toString() {
    if (rollbackError == null) {
      return 'BackupImportException: $message ($originalError)';
    }
    return 'BackupImportException: $message ($originalError; rollback failed: $rollbackError)';
  }
}

class BackupImportResult {
  final int importedTanks;
  final Map<String, String> tankIdMap;
  final Map<String, String> livestockIdMap;
  final Map<String, String> equipmentIdMap;
  final Map<String, String> taskIdMap;

  const BackupImportResult({
    required this.importedTanks,
    required this.tankIdMap,
    required this.livestockIdMap,
    required this.equipmentIdMap,
    required this.taskIdMap,
  });
}

class BackupRestoreImportFlowResult {
  final int importedTanks;
  final bool preferencesRestored;
  final bool preferencesRestoreFailed;
  final Object? preferencesRestoreError;
  final StackTrace? preferencesRestoreStackTrace;

  const BackupRestoreImportFlowResult({
    required this.importedTanks,
    required this.preferencesRestored,
    required this.preferencesRestoreFailed,
    this.preferencesRestoreError,
    this.preferencesRestoreStackTrace,
  });
}

typedef BackupImportFailureCleanup = Future<void> Function();

class BackupRestoreImportFlow {
  final BackupImportService importService;
  final BackupPreferencesRestore restorePreferences;
  final BackupImportInvalidation? onTanksImported;
  final BackupImportInvalidation? onPreferencesRestored;
  final BackupImportFailureCleanup? onImportFailureCleanup;

  BackupRestoreImportFlow({
    required this.importService,
    BackupPreferencesRestore? restorePreferences,
    this.onTanksImported,
    this.onPreferencesRestored,
    this.onImportFailureCleanup,
  }) : restorePreferences =
           restorePreferences ??
           ((data) => SharedPreferencesBackup.restoreFromJson(data));

  Future<BackupRestoreImportFlowResult> importBackupData(
    Map<String, dynamic> backupData,
  ) async {
    late final BackupImportResult importResult;
    try {
      importResult = await importService.importTankScopedData(backupData);
    } catch (error, stackTrace) {
      try {
        await onImportFailureCleanup?.call();
      } catch (cleanupError, cleanupStackTrace) {
        logError(
          'Backup import failure cleanup failed: $cleanupError',
          stackTrace: cleanupStackTrace,
          tag: 'BackupRestoreImportFlow',
        );
      }
      Error.throwWithStackTrace(error, stackTrace);
    }

    final imported = importResult.importedTanks;
    if (imported > 0) {
      onTanksImported?.call();
    }

    var preferencesRestored = false;
    var preferencesRestoreFailed = false;
    Object? preferencesRestoreError;
    StackTrace? preferencesRestoreStackTrace;
    final prefsData = backupData['sharedPreferences'];
    if (imported > 0 && prefsData != null) {
      try {
        if (prefsData is! Map) {
          throw const FormatException(
            'Invalid format: sharedPreferences must be an object',
          );
        }
        await restorePreferences(Map<String, dynamic>.from(prefsData));
        preferencesRestored = true;
        onPreferencesRestored?.call();
      } catch (error, stackTrace) {
        preferencesRestoreFailed = true;
        preferencesRestoreError = error;
        preferencesRestoreStackTrace = stackTrace;
      }
    }

    return BackupRestoreImportFlowResult(
      importedTanks: imported,
      preferencesRestored: preferencesRestored,
      preferencesRestoreFailed: preferencesRestoreFailed,
      preferencesRestoreError: preferencesRestoreError,
      preferencesRestoreStackTrace: preferencesRestoreStackTrace,
    );
  }
}

class BackupImportService {
  static const int _maxIdGenerationAttempts = 20;

  final StorageService storage;
  final BackupImportIdFactory newId;
  final BackupImportClock now;

  BackupImportService({
    required this.storage,
    BackupImportIdFactory? newId,
    BackupImportClock? now,
  }) : newId = newId ?? const Uuid().v4,
       now = now ?? DateTime.now;

  Future<BackupImportResult> importTankScopedData(
    Map<String, dynamic> backupData,
  ) async {
    final importedTankIds = <String>[];

    try {
      return await _importTankScopedData(backupData, importedTankIds);
    } catch (error, stackTrace) {
      Object? rollbackError;
      if (importedTankIds.isNotEmpty) {
        try {
          await storage.deleteAllTanks(importedTankIds);
        } catch (rollback) {
          rollbackError = rollback;
          logError(
            'Backup import rollback failed: $rollback',
            tag: 'BackupImportService',
          );
        }
      }

      throw BackupImportException(
        'Backup import failed before all local data could be saved; imported tanks were rolled back.',
        originalError: error,
        originalStackTrace: stackTrace,
        rollbackError: rollbackError,
      );
    }
  }

  Future<BackupImportResult> _importTankScopedData(
    Map<String, dynamic> backupData,
    List<String> importedTankIds,
  ) async {
    final importTime = now();
    final tankIdMap = <String, String>{};
    final livestockIdMap = <String, String>{};
    final equipmentIdMap = <String, String>{};
    final taskIdMap = <String, String>{};
    final existingChildIds = await _loadExistingChildIds();

    final tanksJson = _listFrom(backupData, 'tanks');
    final livestockJson = _listFrom(backupData, 'livestock');
    final equipmentJson = _listFrom(backupData, 'equipment');
    final tasksJson = _listFrom(backupData, 'tasks');
    final logsJson = _listFrom(backupData, 'logs');

    final backupTankIds = _validateUniqueTankIds(tanksJson);
    _validateUniqueChildIds(livestockJson, 'livestock');
    _validateUniqueChildIds(equipmentJson, 'equipment');
    _validateUniqueChildIds(tasksJson, 'task');
    _validateUniqueChildIds(logsJson, 'log');
    _validateChildTankReferences(livestockJson, backupTankIds, 'livestock');
    _validateChildTankReferences(equipmentJson, backupTankIds, 'equipment');
    _validateChildTankReferences(tasksJson, backupTankIds, 'task');
    _validateChildTankReferences(logsJson, backupTankIds, 'log');
    _validateSameTankRelationshipTargets(
      logsJson: logsJson,
      tasksJson: tasksJson,
      equipmentJson: equipmentJson,
      livestockJson: livestockJson,
    );

    for (final tankJson in tanksJson) {
      final tankMap = _mapFrom(tankJson, 'tank');
      final oldTankId = _requiredString(tankMap, 'id', 'tank');
      final newTankId = await _newUnusedTankId();
      tankIdMap[oldTankId] = newTankId;

      final tank = Tank.fromJson({
        ...tankMap,
        'id': newTankId,
        'createdAt': importTime.toIso8601String(),
        'updatedAt': importTime.toIso8601String(),
      });

      importedTankIds.add(newTankId);
      await storage.saveTank(tank);
    }

    _prepareEntityIdMap(
      livestockJson,
      tankIdMap,
      livestockIdMap,
      existingChildIds.livestockIds,
      'livestock',
    );
    _prepareEntityIdMap(
      equipmentJson,
      tankIdMap,
      equipmentIdMap,
      existingChildIds.equipmentIds,
      'equipment',
    );
    _prepareEntityIdMap(
      tasksJson,
      tankIdMap,
      taskIdMap,
      existingChildIds.taskIds,
      'task',
    );

    for (final itemJson in livestockJson) {
      final itemMap = _mapFrom(itemJson, 'livestock');
      final newTankId = _mappedTankId(itemMap, tankIdMap, 'livestock');
      final oldLivestockId = _requiredString(itemMap, 'id', 'livestock');
      final newLivestockId = livestockIdMap[oldLivestockId];
      if (newLivestockId == null) continue;

      final livestock = _livestockFromJson({
        ...itemMap,
        'id': newLivestockId,
        'tankId': newTankId,
        'createdAt': importTime.toIso8601String(),
        'updatedAt': importTime.toIso8601String(),
      });

      await storage.saveLivestock(livestock);
    }

    for (final itemJson in equipmentJson) {
      final itemMap = _mapFrom(itemJson, 'equipment');
      final newTankId = _mappedTankId(itemMap, tankIdMap, 'equipment');
      final oldEquipmentId = _requiredString(itemMap, 'id', 'equipment');
      final newEquipmentId = equipmentIdMap[oldEquipmentId];
      if (newEquipmentId == null) continue;

      final equipment = _equipmentFromJson({
        ...itemMap,
        'id': newEquipmentId,
        'tankId': newTankId,
        'createdAt': importTime.toIso8601String(),
        'updatedAt': importTime.toIso8601String(),
      });

      await storage.saveEquipment(equipment);
    }

    for (final itemJson in tasksJson) {
      final itemMap = _mapFrom(itemJson, 'task');
      final newTankId = _mappedTankId(itemMap, tankIdMap, 'task');
      final oldTaskId = _requiredString(itemMap, 'id', 'task');
      final newTaskId = taskIdMap[oldTaskId];
      if (newTaskId == null) continue;

      final task = _taskFromJson({
        ...remapBackupTaskRelationships(
          itemMap,
          equipmentIdMap: equipmentIdMap,
        ),
        'id': newTaskId,
        'tankId': newTankId,
        'createdAt': importTime.toIso8601String(),
        'updatedAt': importTime.toIso8601String(),
      });

      await storage.saveTask(task);
    }

    for (final itemJson in logsJson) {
      final itemMap = _mapFrom(itemJson, 'log');
      final newTankId = _mappedTankId(itemMap, tankIdMap, 'log');

      final log = _logFromJson({
        ...remapBackupLogRelationships(
          itemMap,
          equipmentIdMap: equipmentIdMap,
          livestockIdMap: livestockIdMap,
          taskIdMap: taskIdMap,
        ),
        'id': _newUnusedChildId(existingChildIds.logIds, 'log'),
        'tankId': newTankId,
        'createdAt': importTime.toIso8601String(),
      });

      await storage.saveLog(log);
    }

    return BackupImportResult(
      importedTanks: importedTankIds.length,
      tankIdMap: Map.unmodifiable(tankIdMap),
      livestockIdMap: Map.unmodifiable(livestockIdMap),
      equipmentIdMap: Map.unmodifiable(equipmentIdMap),
      taskIdMap: Map.unmodifiable(taskIdMap),
    );
  }

  Future<String> _newUnusedTankId() async {
    for (var attempt = 0; attempt < _maxIdGenerationAttempts; attempt++) {
      final candidateId = newId();
      if (await storage.getTank(candidateId) == null) {
        return candidateId;
      }
    }
    throw StateError(
      'Could not generate an unused tank id for backup import',
    );
  }

  String _newUnusedChildId(Set<String> usedIds, String label) {
    for (var attempt = 0; attempt < _maxIdGenerationAttempts; attempt++) {
      final candidateId = newId();
      if (usedIds.add(candidateId)) {
        return candidateId;
      }
    }
    throw StateError(
      'Could not generate an unused $label id for backup import',
    );
  }

  Future<_ExistingChildIds> _loadExistingChildIds() async {
    final existingTanks = await storage.getAllTanks();
    final livestockIds = <String>{};
    final equipmentIds = <String>{};
    final logIds = <String>{};

    for (final tank in existingTanks) {
      livestockIds.addAll(
        (await storage.getLivestockForTank(tank.id)).map((item) => item.id),
      );
      equipmentIds.addAll(
        (await storage.getEquipmentForTank(tank.id)).map((item) => item.id),
      );
      logIds.addAll(
        (await storage.getLogsForTank(tank.id)).map((item) => item.id),
      );
    }

    return _ExistingChildIds(
      livestockIds: livestockIds,
      equipmentIds: equipmentIds,
      logIds: logIds,
      taskIds: (await storage.getTasksForTank(
        null,
      )).map((item) => item.id).toSet(),
    );
  }

  List<dynamic> _listFrom(Map<String, dynamic> backupData, String key) {
    final value = backupData[key];
    if (value == null) return const [];
    if (value is List) return value;
    throw FormatException('Invalid backup: $key must be a list');
  }

  Map<String, dynamic> _mapFrom(Object? value, String label) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    throw FormatException('Invalid backup: $label entries must be objects');
  }

  String _requiredString(
    Map<String, dynamic> item,
    String key,
    String label,
  ) {
    final value = item[key];
    if (value is String && value.trim().isNotEmpty) return value;
    throw FormatException('Invalid backup: $label entries must include $key');
  }

  String _mappedTankId(
    Map<String, dynamic> item,
    Map<String, String> tankIdMap,
    String label,
  ) {
    final oldTankId = _requiredString(item, 'tankId', label);
    final newTankId = tankIdMap[oldTankId];
    if (newTankId == null) {
      throw FormatException(
        'Invalid backup: $label entries reference unknown tank id "$oldTankId"',
      );
    }
    return newTankId;
  }

  void _validateUniqueChildIds(List<dynamic> jsonItems, String label) {
    final seenIds = <String>{};
    for (final item in jsonItems) {
      final itemMap = _mapFrom(item, label);
      final id = _requiredString(itemMap, 'id', label);
      final comparisonId = label == 'livestock' ? id.trim() : id;
      if (!seenIds.add(comparisonId)) {
        throw FormatException('Invalid backup: duplicate $label id "$id"');
      }
    }
  }

  Set<String> _validateUniqueTankIds(List<dynamic> jsonItems) {
    final seenIds = <String>{};
    for (final item in jsonItems) {
      final itemMap = _mapFrom(item, 'tank');
      final id = _requiredString(itemMap, 'id', 'tank');
      if (!seenIds.add(id)) {
        throw FormatException('Invalid backup: duplicate tank id "$id"');
      }
    }
    return seenIds;
  }

  void _validateChildTankReferences(
    List<dynamic> jsonItems,
    Set<String> backupTankIds,
    String label,
  ) {
    for (final item in jsonItems) {
      final itemMap = _mapFrom(item, label);
      final tankId = _requiredString(itemMap, 'tankId', label);
      if (!backupTankIds.contains(tankId)) {
        throw FormatException(
          'Invalid backup: $label entries reference unknown tank id "$tankId"',
        );
      }
    }
  }

  void _prepareEntityIdMap(
    List<dynamic> jsonItems,
    Map<String, String> tankIdMap,
    Map<String, String> output,
    Set<String> usedIds,
    String label,
  ) {
    for (final item in jsonItems) {
      final itemMap = _mapFrom(item, 'child');
      final oldId = itemMap['id'];
      final oldTankId = itemMap['tankId'];
      if (oldId is! String || oldId.isEmpty) continue;
      if (oldTankId is! String || !tankIdMap.containsKey(oldTankId)) continue;
      output.putIfAbsent(
        oldId,
        () => _newUnusedChildId(usedIds, label),
      );
    }
  }

  void _validateSameTankRelationshipTargets({
    required List<dynamic> logsJson,
    required List<dynamic> tasksJson,
    required List<dynamic> equipmentJson,
    required List<dynamic> livestockJson,
  }) {
    final equipmentTankIds = _backupChildTankIds(equipmentJson, 'equipment');
    final livestockTankIds = _backupChildTankIds(livestockJson, 'livestock');
    final taskTankIds = _backupChildTankIds(tasksJson, 'task');

    _validateRelationshipTargetTank(
      logsJson,
      sourceCollection: 'logs',
      sourceLabel: 'log',
      field: 'relatedEquipmentId',
      targetTankIds: equipmentTankIds,
      targetLabel: 'equipment',
    );
    _validateRelationshipTargetTank(
      logsJson,
      sourceCollection: 'logs',
      sourceLabel: 'log',
      field: 'relatedLivestockId',
      targetTankIds: livestockTankIds,
      targetLabel: 'livestock',
    );
    _validateRelationshipTargetTank(
      logsJson,
      sourceCollection: 'logs',
      sourceLabel: 'log',
      field: 'relatedTaskId',
      targetTankIds: taskTankIds,
      targetLabel: 'task',
    );
    _validateRelationshipTargetTank(
      tasksJson,
      sourceCollection: 'tasks',
      sourceLabel: 'task',
      field: 'relatedEquipmentId',
      targetTankIds: equipmentTankIds,
      targetLabel: 'equipment',
    );
  }

  Map<String, String> _backupChildTankIds(
    List<dynamic> jsonItems,
    String label,
  ) {
    final tankIdsByChildId = <String, String>{};
    for (final item in jsonItems) {
      final itemMap = _mapFrom(item, label);
      tankIdsByChildId[_requiredString(itemMap, 'id', label)] = _requiredString(
        itemMap,
        'tankId',
        label,
      );
    }
    return tankIdsByChildId;
  }

  void _validateRelationshipTargetTank(
    List<dynamic> sourceJson, {
    required String sourceCollection,
    required String sourceLabel,
    required String field,
    required Map<String, String> targetTankIds,
    required String targetLabel,
  }) {
    for (final source in sourceJson) {
      final sourceMap = _mapFrom(source, sourceLabel);
      final value = sourceMap[field];
      if (value == null) continue;
      if (value is! String) {
        throw FormatException(
          'Invalid backup: $sourceCollection $field values must be strings',
        );
      }
      if (value.isEmpty) continue;

      final liveLivestockIdMapKey = field == 'relatedLivestockId'
          ? backupLiveLivestockIdMapKey(value, targetTankIds.keys)
          : null;
      final targetTankId = targetTankIds[liveLivestockIdMapKey ?? value];
      if (targetTankId == null) {
        if (field == 'relatedLivestockId' &&
            isBackupLivestockRemovalTombstone(
              sourceMap,
              hasLiveLivestockTarget: false,
            )) {
          continue;
        }
        throw FormatException(
          'Invalid backup: $sourceCollection $field values must reference imported $targetLabel records',
        );
      }

      final sourceTankId = _requiredString(sourceMap, 'tankId', sourceLabel);
      if (targetTankId != sourceTankId) {
        throw FormatException(
          'Invalid backup: $sourceCollection $field values must reference records in the same backup tank',
        );
      }
    }
  }

  Livestock _livestockFromJson(Map<String, dynamic> m) => Livestock(
    id: m['id'] as String,
    tankId: m['tankId'] as String,
    commonName: m['commonName'] as String,
    scientificName: m['scientificName'] as String?,
    count: (m['count'] as num?)?.toInt() ?? 1,
    sizeCm: (m['sizeCm'] as num?)?.toDouble(),
    maxSizeCm: (m['maxSizeCm'] as num?)?.toDouble(),
    dateAdded: DateTime.parse(m['dateAdded'] as String),
    source: m['source'] as String?,
    temperament: m['temperament'] == null
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

  Equipment _equipmentFromJson(Map<String, dynamic> m) => Equipment(
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
    purchaseDate: m['purchaseDate'] != null
        ? DateTime.parse(m['purchaseDate'] as String)
        : null,
    expectedLifespanMonths: (m['expectedLifespanMonths'] as num?)?.toInt(),
    notes: m['notes'] as String?,
    createdAt: DateTime.parse(m['createdAt'] as String),
    updatedAt: DateTime.parse(m['updatedAt'] as String),
  );

  LogEntry _logFromJson(Map<String, dynamic> m) => LogEntry(
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
    photoUrls: (m['photoUrls'] as List?)?.cast<String>(),
    relatedEquipmentId: m['relatedEquipmentId'] as String?,
    relatedLivestockId: m['relatedLivestockId'] as String?,
    relatedTaskId: m['relatedTaskId'] as String?,
    createdAt: DateTime.parse(m['createdAt'] as String),
  );

  WaterTestResults _waterTestFromJson(Map<String, dynamic> m) =>
      WaterTestResults(
        temperature: (m['temperature'] as num?)?.toDouble(),
        ph: (m['ph'] as num?)?.toDouble(),
        ammonia: (m['ammonia'] as num?)?.toDouble(),
        nitrite: (m['nitrite'] as num?)?.toDouble(),
        nitrate: (m['nitrate'] as num?)?.toDouble(),
        gh: (m['gh'] as num?)?.toDouble(),
        kh: (m['kh'] as num?)?.toDouble(),
        phosphate: (m['phosphate'] as num?)?.toDouble(),
        co2: (m['co2'] as num?)?.toDouble(),
      );

  Task _taskFromJson(Map<String, dynamic> m) => Task(
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

class _ExistingChildIds {
  final Set<String> livestockIds;
  final Set<String> equipmentIds;
  final Set<String> logIds;
  final Set<String> taskIds;

  const _ExistingChildIds({
    required this.livestockIds,
    required this.equipmentIds,
    required this.logIds,
    required this.taskIds,
  });
}
