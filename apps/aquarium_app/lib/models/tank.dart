import 'package:flutter/foundation.dart';

/// Tank type - freshwater only for MVP
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
  }) : assert(
         tempMin == null || tempMax == null || tempMin <= tempMax,
         'tempMin must be <= tempMax',
       ),
       assert(
         phMin == null || phMax == null || phMin <= phMax,
         'phMin must be <= phMax',
       ),
       assert(
         ghMin == null || ghMax == null || ghMin <= ghMax,
         'ghMin must be <= ghMax',
       ),
       assert(
         khMin == null || khMax == null || khMin <= khMax,
         'khMin must be <= khMax',
       );

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
    // Auto-swap inverted ranges so min is always <= max
    double? resolveMin(double? newMin, double? currentMin, double? newMax, double? currentMax) {
      final min = newMin ?? currentMin;
      final max = newMax ?? currentMax;
      if (min != null && max != null && min > max) return max;
      return min;
    }
    double? resolveMax(double? newMin, double? currentMin, double? newMax, double? currentMax) {
      final min = newMin ?? currentMin;
      final max = newMax ?? currentMax;
      if (min != null && max != null && min > max) return min;
      return max;
    }

    return WaterTargets(
      tempMin: resolveMin(tempMin, this.tempMin, tempMax, this.tempMax),
      tempMax: resolveMax(tempMin, this.tempMin, tempMax, this.tempMax),
      phMin: resolveMin(phMin, this.phMin, phMax, this.phMax),
      phMax: resolveMax(phMin, this.phMin, phMax, this.phMax),
      ghMin: resolveMin(ghMin, this.ghMin, ghMax, this.ghMax),
      ghMax: resolveMax(ghMin, this.ghMin, ghMax, this.ghMax),
      khMin: resolveMin(khMin, this.khMin, khMax, this.khMax),
      khMax: resolveMax(khMin, this.khMin, khMax, this.khMax),
    );
  }
}

/// A fish tank - the core object in the app
@immutable
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
  final int sortOrder; // For custom tank ordering (lower = first)
  final bool isDemoTank; // Whether this is a demo/sample tank
  final DateTime createdAt;
  final DateTime updatedAt;

  const Tank({
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
    this.sortOrder = 0,
    this.isDemoTank = false,
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
    int? sortOrder,
    bool? isDemoTank,
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
      sortOrder: sortOrder ?? this.sortOrder,
      isDemoTank: isDemoTank ?? this.isDemoTank,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Serialize to JSON for export/backup
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'volumeLitres': volumeLitres,
    'lengthCm': lengthCm,
    'widthCm': widthCm,
    'heightCm': heightCm,
    'startDate': startDate.toIso8601String(),
    'targets': {
      'tempMin': targets.tempMin,
      'tempMax': targets.tempMax,
      'phMin': targets.phMin,
      'phMax': targets.phMax,
      'ghMin': targets.ghMin,
      'ghMax': targets.ghMax,
      'khMin': targets.khMin,
      'khMax': targets.khMax,
    },
    'notes': notes,
    'imageUrl': imageUrl,
    'sortOrder': sortOrder,
    'isDemoTank': isDemoTank,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Create from JSON (for import/restore)
  factory Tank.fromJson(Map<String, dynamic> json) {
    final targetsJson = json['targets'] as Map<String, dynamic>?;
    return Tank(
      id: json['id'] as String,
      name: json['name'] as String,
      type: TankType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'freshwater'),
        orElse: () => TankType.freshwater,
      ),
      volumeLitres: (json['volumeLitres'] as num?)?.toDouble() ?? 0,
      lengthCm: (json['lengthCm'] as num?)?.toDouble(),
      widthCm: (json['widthCm'] as num?)?.toDouble(),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      targets: targetsJson != null
          ? WaterTargets(
              tempMin: (targetsJson['tempMin'] as num?)?.toDouble(),
              tempMax: (targetsJson['tempMax'] as num?)?.toDouble(),
              phMin: (targetsJson['phMin'] as num?)?.toDouble(),
              phMax: (targetsJson['phMax'] as num?)?.toDouble(),
              ghMin: (targetsJson['ghMin'] as num?)?.toDouble(),
              ghMax: (targetsJson['ghMax'] as num?)?.toDouble(),
              khMin: (targetsJson['khMin'] as num?)?.toDouble(),
              khMax: (targetsJson['khMax'] as num?)?.toDouble(),
            )
          : WaterTargets.freshwaterTropical(),
      notes: json['notes'] as String?,
      imageUrl: json['imageUrl'] as String?,
      sortOrder: (json['sortOrder'] as int?) ?? 0,
      isDemoTank: (json['isDemoTank'] as bool?) ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
