import '../data/species_database.dart';
import '../models/models.dart';

/// Simple stocking level indicator
enum StockingLevel { understocked, good, moderate, heavy, overstocked }

/// Result of stocking calculation
class StockingResult {
  final StockingLevel level;
  final double percentFull;
  final String summary;
  final List<String> warnings;
  final List<String> suggestions;

  const StockingResult({
    required this.level,
    required this.percentFull,
    required this.summary,
    this.warnings = const [],
    this.suggestions = const [],
  });
}

/// Simple stocking calculator using the "inch per gallon" heuristic
/// with adjustments for fish size and bioload.
class StockingCalculator {
  /// Calculate stocking level for a tank.
  static StockingResult calculate({
    required Tank tank,
    required List<Livestock> livestock,
  }) {
    if (livestock.isEmpty) {
      return const StockingResult(
        level: StockingLevel.understocked,
        percentFull: 0,
        summary: 'No livestock - room for new additions!',
        suggestions: [
          'Consider starting with hardy species like tetras or guppies.',
        ],
      );
    }

    // Calculate total "fish inches" with bioload multiplier
    double totalInches = 0;
    final warnings = <String>[];
    final suggestions = <String>[];

    for (final l in livestock) {
      final species =
          SpeciesDatabase.lookup(l.commonName) ??
          (l.scientificName != null
              ? SpeciesDatabase.lookup(l.scientificName!)
              : null);

      double sizeCm;
      double bioloadMultiplier = 1.0;

      if (species != null) {
        sizeCm = species.adultSizeCm;

        // Adjust for high-bioload fish
        if (species.diet.toLowerCase().contains('carnivore') ||
            species.commonName.toLowerCase().contains('pleco') ||
            species.commonName.toLowerCase().contains('goldfish')) {
          bioloadMultiplier = 1.5;
        }

        // Check school size
        if (species.minSchoolSize > 1 && l.count < species.minSchoolSize) {
          warnings.add(
            '${l.commonName} should be in groups of ${species.minSchoolSize}+',
          );
        }

        // Check minimum tank size
        if (species.minTankLitres > tank.volumeLitres) {
          warnings.add(
            '${l.commonName} needs at least ${species.minTankLitres.toStringAsFixed(0)}L',
          );
        }
      } else {
        // Unknown species - estimate 5cm
        sizeCm = l.sizeCm ?? 5.0;
      }

      // Convert to inches and apply multiplier
      final inchesPerFish = (sizeCm / 2.54) * bioloadMultiplier;
      totalInches += inchesPerFish * l.count;
    }

    // Convert tank volume to gallons
    final tankGallons = tank.volumeLitres / 3.785;

    // Calculate percentage (1 inch per gallon = 100%)
    final percentFull = (totalInches / tankGallons) * 100;

    // Determine stocking level
    StockingLevel level;
    String summary;

    if (percentFull < 30) {
      level = StockingLevel.understocked;
      summary = 'Lightly stocked - plenty of room for growth or additions.';
      suggestions.add('Consider adding more fish or plants.');
    } else if (percentFull < 60) {
      level = StockingLevel.good;
      summary = 'Well balanced - healthy stocking level.';
    } else if (percentFull < 80) {
      level = StockingLevel.moderate;
      summary = 'Moderately stocked - keep up with maintenance.';
      suggestions.add('Stay on top of water changes.');
    } else if (percentFull < 100) {
      level = StockingLevel.heavy;
      summary = 'Heavily stocked - requires diligent maintenance.';
      warnings.add('Consider more frequent water changes.');
      suggestions.add('Good filtration is essential.');
    } else {
      level = StockingLevel.overstocked;
      summary = 'Overstocked - risk of water quality issues.';
      warnings.add('Tank may be overstocked.');
      suggestions.add('Consider rehoming some fish or upgrading tank size.');
    }

    return StockingResult(
      level: level,
      percentFull: percentFull.clamp(0, 150),
      summary: summary,
      warnings: warnings,
      suggestions: suggestions,
    );
  }
}
