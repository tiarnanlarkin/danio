/// Tank type — freshwater only for MVP
enum TankType {
  freshwater,
  marine, // Later
}

/// Target water parameter ranges for a tank
class WaterTargets {
  final double? tempMin; // °C
  final double? tempMax;
  final double? phMin;
  final double? phMax;
  final double? ghMin; // General hardness (dGH)
  final double? ghMax;
  final double? khMin; // Carbonate hardness (dKH)
  final double? khMax;

  const WaterTargets({
    this.tempMin,
    this.tempMax,
    this.phMin,
    this.phMax,
    this.ghMin,
    this.ghMax,
    this.khMin,
    this.khMax,
  });

  /// Default freshwater tropical targets
  factory WaterTargets.freshwaterTropical() => const WaterTargets(
    tempMin: 24,
    tempMax: 28,
    phMin: 6.5,
    phMax: 7.5,
    ghMin: 4,
    ghMax: 12,
    khMin: 3,
    khMax: 8,
  );

  /// Default freshwater coldwater targets
  factory WaterTargets.freshwaterColdwater() => const WaterTargets(
    tempMin: 15,
    tempMax: 22,
    phMin: 7.0,
    phMax: 8.0,
    ghMin: 8,
    ghMax: 18,
    khMin: 4,
    khMax: 10,
  );

  WaterTargets copyWith({
    double? tempMin,
    double? tempMax,
    double? phMin,
    double? phMax,
    double? ghMin,
    double? ghMax,
    double? khMin,
    double? khMax,
  }) {
    return WaterTargets(
      tempMin: tempMin ?? this.tempMin,
      tempMax: tempMax ?? this.tempMax,
      phMin: phMin ?? this.phMin,
      phMax: phMax ?? this.phMax,
      ghMin: ghMin ?? this.ghMin,
      ghMax: ghMax ?? this.ghMax,
      khMin: khMin ?? this.khMin,
      khMax: khMax ?? this.khMax,
    );
  }
}

/// A fish tank — the core object in the app
class Tank {
  final String id;
  final String name;
  final TankType type;
  final double volumeLitres;
  final double? lengthCm;
  final double? widthCm;
  final double? heightCm;
  final DateTime startDate;
  final WaterTargets targets;
  final String? notes;
  final String? imageUrl; // Local path or URL
  final DateTime createdAt;
  final DateTime updatedAt;

  Tank({
    required this.id,
    required this.name,
    required this.type,
    required this.volumeLitres,
    this.lengthCm,
    this.widthCm,
    this.heightCm,
    required this.startDate,
    required this.targets,
    this.notes,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Volume in gallons (US)
  double get volumeGallons => volumeLitres * 0.264172;

  Tank copyWith({
    String? id,
    String? name,
    TankType? type,
    double? volumeLitres,
    double? lengthCm,
    double? widthCm,
    double? heightCm,
    DateTime? startDate,
    WaterTargets? targets,
    String? notes,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tank(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      volumeLitres: volumeLitres ?? this.volumeLitres,
      lengthCm: lengthCm ?? this.lengthCm,
      widthCm: widthCm ?? this.widthCm,
      heightCm: heightCm ?? this.heightCm,
      startDate: startDate ?? this.startDate,
      targets: targets ?? this.targets,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
