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
