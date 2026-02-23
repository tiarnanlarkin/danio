/// Shared JSON serialization helpers for models that don't have built-in
/// toJson/fromJson.
///
/// These are extracted from backup_restore_screen.dart and
/// local_json_storage_service.dart so cloud services can reuse them.
library;

import '../models/models.dart';

// ---------------------------------------------------------------------------
// Livestock
// ---------------------------------------------------------------------------

Map<String, dynamic> livestockToJson(Livestock l) => {
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

Livestock livestockFromJson(Map<String, dynamic> m) => Livestock(
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
      notes: m['notes'] as String?,
      imageUrl: m['imageUrl'] as String?,
      createdAt: DateTime.parse(m['createdAt'] as String),
      updatedAt: DateTime.parse(m['updatedAt'] as String),
    );

// ---------------------------------------------------------------------------
// Equipment
// ---------------------------------------------------------------------------

Map<String, dynamic> equipmentToJson(Equipment e) => {
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

Equipment equipmentFromJson(Map<String, dynamic> m) => Equipment(
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
      maintenanceIntervalDays:
          (m['maintenanceIntervalDays'] as num?)?.toInt(),
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

// ---------------------------------------------------------------------------
// LogEntry
// ---------------------------------------------------------------------------

Map<String, dynamic> logEntryToJson(LogEntry l) => {
      'id': l.id,
      'tankId': l.tankId,
      'type': l.type.name,
      'timestamp': l.timestamp.toIso8601String(),
      'waterTest':
          l.waterTest != null ? waterTestToJson(l.waterTest!) : null,
      'waterChangePercent': l.waterChangePercent,
      'title': l.title,
      'notes': l.notes,
      'photoUrls': l.photoUrls,
      'relatedEquipmentId': l.relatedEquipmentId,
      'relatedLivestockId': l.relatedLivestockId,
      'relatedTaskId': l.relatedTaskId,
      'createdAt': l.createdAt.toIso8601String(),
    };

LogEntry logEntryFromJson(Map<String, dynamic> m) => LogEntry(
      id: m['id'] as String,
      tankId: m['tankId'] as String,
      type: LogType.values.firstWhere(
        (e) => e.name == (m['type'] ?? 'other'),
        orElse: () => LogType.other,
      ),
      timestamp: DateTime.parse(m['timestamp'] as String),
      waterTest: m['waterTest'] != null
          ? waterTestFromJson(m['waterTest'] as Map<String, dynamic>)
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

Map<String, dynamic> waterTestToJson(WaterTestResults t) => {
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

WaterTestResults waterTestFromJson(Map<String, dynamic> m) =>
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

// ---------------------------------------------------------------------------
// Task
// ---------------------------------------------------------------------------

Map<String, dynamic> taskToJson(Task t) => {
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

Task taskFromJson(Map<String, dynamic> m) => Task(
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
