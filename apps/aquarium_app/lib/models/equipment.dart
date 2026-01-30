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

/// Equipment item — filters, heaters, lights, etc.
/// Each has its own maintenance schedule.
class Equipment {
  final String id;
  final String tankId;
  final EquipmentType type;
  final String name; // e.g., "Fluval 307"
  final String? brand;
  final String? model;
  final Map<String, dynamic>? settings; // Type-specific settings (e.g., temp for heater)
  final int? maintenanceIntervalDays; // How often to service
  final DateTime? lastServiced;
  final DateTime? installedDate;
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

  /// Friendly type name
  String get typeName {
    switch (type) {
      case EquipmentType.filter: return 'Filter';
      case EquipmentType.heater: return 'Heater';
      case EquipmentType.light: return 'Light';
      case EquipmentType.airPump: return 'Air Pump';
      case EquipmentType.co2System: return 'CO₂ System';
      case EquipmentType.autoFeeder: return 'Auto Feeder';
      case EquipmentType.thermometer: return 'Thermometer';
      case EquipmentType.wavemaker: return 'Wavemaker';
      case EquipmentType.skimmer: return 'Skimmer';
      case EquipmentType.other: return 'Other';
    }
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
      maintenanceIntervalDays: maintenanceIntervalDays ?? this.maintenanceIntervalDays,
      lastServiced: lastServiced ?? this.lastServiced,
      installedDate: installedDate ?? this.installedDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
