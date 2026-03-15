/// Equipment types
enum EquipmentType {
  filter,
  heater,
  light,
  airPump,
  co2System,
  autoFeeder,
  thermometer,
  wavemaker,
  skimmer, // For marine later
  other,
}

/// Equipment item - filters, heaters, lights, etc.
/// Each has its own maintenance schedule.
class Equipment {
  final String id;
  final String tankId;
  final EquipmentType type;
  final String name; // e.g., "Fluval 307"
  final String? brand;
  final String? model;
  final Map<String, dynamic>?
  settings; // Type-specific settings (e.g., temp for heater)
  final int? maintenanceIntervalDays; // How often to service
  final DateTime? lastServiced;
  final DateTime? installedDate;
  final DateTime? purchaseDate; // When equipment was purchased
  final int? expectedLifespanMonths; // Expected lifespan in months
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Equipment({
    required this.id,
    required this.tankId,
    required this.type,
    required this.name,
    this.brand,
    this.model,
    this.settings,
    this.maintenanceIntervalDays,
    this.lastServiced,
    this.installedDate,
    this.purchaseDate,
    this.expectedLifespanMonths,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Is maintenance overdue?
  bool get isMaintenanceOverdue {
    if (maintenanceIntervalDays == null || lastServiced == null) return false;
    final dueDate = lastServiced!.add(Duration(days: maintenanceIntervalDays!));
    return DateTime.now().isAfter(dueDate);
  }

  /// Days until next maintenance (negative if overdue)
  int? get daysUntilMaintenance {
    if (maintenanceIntervalDays == null || lastServiced == null) return null;
    final dueDate = lastServiced!.add(Duration(days: maintenanceIntervalDays!));
    return dueDate.difference(DateTime.now()).inDays;
  }

  /// Age of equipment in months
  int? get ageInMonths {
    final date = purchaseDate ?? installedDate;
    if (date == null) return null;
    final diff = DateTime.now().difference(date);
    return (diff.inDays / 30).floor();
  }

  /// Percentage of lifespan used (0-100+)
  double? get lifespanUsedPercent {
    if (expectedLifespanMonths == null || ageInMonths == null) return null;
    return (ageInMonths! / expectedLifespanMonths!) * 100;
  }

  /// Is equipment nearing end of lifespan (>80%)
  bool get isNearingReplacement {
    final percent = lifespanUsedPercent;
    return percent != null && percent >= 80;
  }

  /// Is equipment past expected lifespan
  bool get isPastLifespan {
    final percent = lifespanUsedPercent;
    return percent != null && percent >= 100;
  }

  /// Expected replacement date
  DateTime? get expectedReplacementDate {
    if (expectedLifespanMonths == null) return null;
    final date = purchaseDate ?? installedDate;
    if (date == null) return null;
    return DateTime(date.year, date.month + expectedLifespanMonths!, date.day);
  }

  /// Default lifespan for equipment type (in months)
  static int defaultLifespanMonths(EquipmentType type) {
    switch (type) {
      case EquipmentType.filter:
        return 60; // 5 years
      case EquipmentType.heater:
        return 36; // 3 years
      case EquipmentType.light:
        return 24; // 2 years (LED degradation)
      case EquipmentType.airPump:
        return 36; // 3 years
      case EquipmentType.co2System:
        return 60; // 5 years
      case EquipmentType.autoFeeder:
        return 24; // 2 years
      case EquipmentType.thermometer:
        return 24; // 2 years
      case EquipmentType.wavemaker:
        return 48; // 4 years
      case EquipmentType.skimmer:
        return 48; // 4 years
      case EquipmentType.other:
        return 36; // 3 years default
    }
  }

  /// Friendly type name
  String get typeName {
    switch (type) {
      case EquipmentType.filter:
        return 'Filter';
      case EquipmentType.heater:
        return 'Heater';
      case EquipmentType.light:
        return 'Light';
      case EquipmentType.airPump:
        return 'Air Pump';
      case EquipmentType.co2System:
        return 'CO₂ System';
      case EquipmentType.autoFeeder:
        return 'Auto Feeder';
      case EquipmentType.thermometer:
        return 'Thermometer';
      case EquipmentType.wavemaker:
        return 'Wavemaker';
      case EquipmentType.skimmer:
        return 'Skimmer';
      case EquipmentType.other:
        return 'Other';
    }
  }


  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'] as String,
      tankId: json['tankId'] as String,
      type: EquipmentType.values.firstWhere((e) => e.name == json['type'], orElse: () => EquipmentType.filter),
      name: json['name'] as String,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      settings: json['settings'] != null
          ? Map<String, dynamic>.from(json['settings'] as Map)
          : null,
      maintenanceIntervalDays: json['maintenanceIntervalDays'] as int?,
      lastServiced: json['lastServiced'] != null
          ? DateTime.parse(json['lastServiced'] as String)
          : null,
      installedDate: json['installedDate'] != null
          ? DateTime.parse(json['installedDate'] as String)
          : null,
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'] as String)
          : null,
      expectedLifespanMonths: json['expectedLifespanMonths'] as int?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tankId': tankId,
      'type': type.name,
      'name': name,
      'brand': brand,
      'model': model,
      'settings': settings,
      'maintenanceIntervalDays': maintenanceIntervalDays,
      'lastServiced': lastServiced?.toIso8601String(),
      'installedDate': installedDate?.toIso8601String(),
      'purchaseDate': purchaseDate?.toIso8601String(),
      'expectedLifespanMonths': expectedLifespanMonths,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Equipment copyWith({
    String? id,
    String? tankId,
    EquipmentType? type,
    String? name,
    String? brand,
    String? model,
    Map<String, dynamic>? settings,
    int? maintenanceIntervalDays,
    DateTime? lastServiced,
    DateTime? installedDate,
    DateTime? purchaseDate,
    int? expectedLifespanMonths,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Equipment(
      id: id ?? this.id,
      tankId: tankId ?? this.tankId,
      type: type ?? this.type,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      settings: settings ?? this.settings,
      maintenanceIntervalDays:
          maintenanceIntervalDays ?? this.maintenanceIntervalDays,
      lastServiced: lastServiced ?? this.lastServiced,
      installedDate: installedDate ?? this.installedDate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expectedLifespanMonths:
          expectedLifespanMonths ?? this.expectedLifespanMonths,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
