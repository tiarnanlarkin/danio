/// Temperament flags for compatibility checking
enum Temperament { peaceful, semiAggressive, aggressive }

/// Livestock entry — fish, snails, shrimp, etc.
class Livestock {
  final String id;
  final String tankId;
  final String commonName;
  final String? scientificName;
  final int count;
  final double? sizeCm; // Estimated current size
  final double? maxSizeCm; // Adult size from species data
  final DateTime dateAdded;
  final String? source; // Where purchased
  final Temperament? temperament;
  final String? notes;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Livestock({
    required this.id,
    required this.tankId,
    required this.commonName,
    this.scientificName,
    required this.count,
    this.sizeCm,
    this.maxSizeCm,
    required this.dateAdded,
    this.source,
    this.temperament,
    this.notes,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });


  factory Livestock.fromJson(Map<String, dynamic> json) {
    return Livestock(
      id: json['id'] as String,
      tankId: json['tankId'] as String,
      commonName: json['commonName'] as String,
      scientificName: json['scientificName'] as String?,
      count: json['count'] as int,
      sizeCm: (json['sizeCm'] as num?)?.toDouble(),
      maxSizeCm: (json['maxSizeCm'] as num?)?.toDouble(),
      dateAdded: DateTime.parse(json['dateAdded'] as String),
      source: json['source'] as String?,
      temperament: json['temperament'] != null
          ? Temperament.values.firstWhere((e) => e.name == json['temperament'])
          : null,
      notes: json['notes'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tankId': tankId,
      'commonName': commonName,
      'scientificName': scientificName,
      'count': count,
      'sizeCm': sizeCm,
      'maxSizeCm': maxSizeCm,
      'dateAdded': dateAdded.toIso8601String(),
      'source': source,
      'temperament': temperament?.name,
      'notes': notes,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Livestock copyWith({
    String? id,
    String? tankId,
    String? commonName,
    String? scientificName,
    int? count,
    double? sizeCm,
    double? maxSizeCm,
    DateTime? dateAdded,
    String? source,
    Temperament? temperament,
    String? notes,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Livestock(
      id: id ?? this.id,
      tankId: tankId ?? this.tankId,
      commonName: commonName ?? this.commonName,
      scientificName: scientificName ?? this.scientificName,
      count: count ?? this.count,
      sizeCm: sizeCm ?? this.sizeCm,
      maxSizeCm: maxSizeCm ?? this.maxSizeCm,
      dateAdded: dateAdded ?? this.dateAdded,
      source: source ?? this.source,
      temperament: temperament ?? this.temperament,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
