/// Log entry types
enum LogType {
  waterTest,
  waterChange,
  feeding,
  medication,
  observation, // General notes, algae, behavior
  livestockAdded,
  livestockRemoved,
  equipmentMaintenance,
  taskCompleted,
  other,
}

/// Water test results - all nullable since not all tests done each time
class WaterTestResults {
  final double? temperature; // °C
  final double? ph;
  final double? ammonia; // NH3/NH4 ppm
  final double? nitrite; // NO2 ppm
  final double? nitrate; // NO3 ppm
  final double? gh; // dGH
  final double? kh; // dKH
  final double? phosphate; // PO4 ppm
  final double? co2; // mg/L (usually calculated)

  const WaterTestResults({
    this.temperature,
    this.ph,
    this.ammonia,
    this.nitrite,
    this.nitrate,
    this.gh,
    this.kh,
    this.phosphate,
    this.co2,
  });

  /// Check if any values are present
  bool get hasValues =>
      temperature != null ||
      ph != null ||
      ammonia != null ||
      nitrite != null ||
      nitrate != null ||
      gh != null ||
      kh != null ||
      phosphate != null ||
      co2 != null;


  factory WaterTestResults.fromJson(Map<String, dynamic> json) {
    return WaterTestResults(
      temperature: (json['temperature'] as num?)?.toDouble(),
      ph: (json['ph'] as num?)?.toDouble(),
      ammonia: (json['ammonia'] as num?)?.toDouble(),
      nitrite: (json['nitrite'] as num?)?.toDouble(),
      nitrate: (json['nitrate'] as num?)?.toDouble(),
      gh: (json['gh'] as num?)?.toDouble(),
      kh: (json['kh'] as num?)?.toDouble(),
      phosphate: (json['phosphate'] as num?)?.toDouble(),
      co2: (json['co2'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'ph': ph,
      'ammonia': ammonia,
      'nitrite': nitrite,
      'nitrate': nitrate,
      'gh': gh,
      'kh': kh,
      'phosphate': phosphate,
      'co2': co2,
    };
  }

  WaterTestResults copyWith({
    double? temperature,
    double? ph,
    double? ammonia,
    double? nitrite,
    double? nitrate,
    double? gh,
    double? kh,
    double? phosphate,
    double? co2,
  }) {
    return WaterTestResults(
      temperature: temperature ?? this.temperature,
      ph: ph ?? this.ph,
      ammonia: ammonia ?? this.ammonia,
      nitrite: nitrite ?? this.nitrite,
      nitrate: nitrate ?? this.nitrate,
      gh: gh ?? this.gh,
      kh: kh ?? this.kh,
      phosphate: phosphate ?? this.phosphate,
      co2: co2 ?? this.co2,
    );
  }
}

/// A log entry - water tests, events, observations
class LogEntry {
  final String id;
  final String tankId;
  final LogType type;
  final DateTime timestamp;
  final WaterTestResults? waterTest; // Only for waterTest type
  final int? waterChangePercent; // Only for waterChange type
  final String? title; // Brief description
  final String? notes; // Detailed notes
  final List<String>? photoUrls; // Local paths or URLs
  final String? relatedEquipmentId; // For equipment maintenance logs
  final String? relatedLivestockId; // For livestock events
  final String? relatedTaskId; // For task-completion logs
  final DateTime createdAt;

  LogEntry({
    required this.id,
    required this.tankId,
    required this.type,
    required this.timestamp,
    this.waterTest,
    this.waterChangePercent,
    this.title,
    this.notes,
    this.photoUrls,
    this.relatedEquipmentId,
    this.relatedLivestockId,
    this.relatedTaskId,
    required this.createdAt,
  });

  /// Friendly type name
  String get typeName {
    switch (type) {
      case LogType.waterTest:
        return 'Water Test';
      case LogType.waterChange:
        return 'Water Change';
      case LogType.feeding:
        return 'Feeding';
      case LogType.medication:
        return 'Medication';
      case LogType.observation:
        return 'Observation';
      case LogType.livestockAdded:
        return 'Livestock Added';
      case LogType.livestockRemoved:
        return 'Livestock Removed';
      case LogType.equipmentMaintenance:
        return 'Equipment Maintenance';
      case LogType.taskCompleted:
        return 'Task Completed';
      case LogType.other:
        return 'Other';
    }
  }


  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'] as String,
      tankId: json['tankId'] as String,
      type: LogType.values.firstWhere((e) => e.name == json['type']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      waterTest: json['waterTest'] != null
          ? WaterTestResults.fromJson(Map<String, dynamic>.from(json['waterTest'] as Map))
          : null,
      waterChangePercent: json['waterChangePercent'] as int?,
      title: json['title'] as String?,
      notes: json['notes'] as String?,
      photoUrls: json['photoUrls'] != null
          ? List<String>.from(json['photoUrls'] as List)
          : null,
      relatedEquipmentId: json['relatedEquipmentId'] as String?,
      relatedLivestockId: json['relatedLivestockId'] as String?,
      relatedTaskId: json['relatedTaskId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tankId': tankId,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'waterTest': waterTest?.toJson(),
      'waterChangePercent': waterChangePercent,
      'title': title,
      'notes': notes,
      'photoUrls': photoUrls,
      'relatedEquipmentId': relatedEquipmentId,
      'relatedLivestockId': relatedLivestockId,
      'relatedTaskId': relatedTaskId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  LogEntry copyWith({
    String? id,
    String? tankId,
    LogType? type,
    DateTime? timestamp,
    WaterTestResults? waterTest,
    int? waterChangePercent,
    String? title,
    String? notes,
    List<String>? photoUrls,
    String? relatedEquipmentId,
    String? relatedLivestockId,
    String? relatedTaskId,
    DateTime? createdAt,
  }) {
    return LogEntry(
      id: id ?? this.id,
      tankId: tankId ?? this.tankId,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      waterTest: waterTest ?? this.waterTest,
      waterChangePercent: waterChangePercent ?? this.waterChangePercent,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      photoUrls: photoUrls ?? this.photoUrls,
      relatedEquipmentId: relatedEquipmentId ?? this.relatedEquipmentId,
      relatedLivestockId: relatedLivestockId ?? this.relatedLivestockId,
      relatedTaskId: relatedTaskId ?? this.relatedTaskId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
