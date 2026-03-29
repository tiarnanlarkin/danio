import '../data/species_database.dart';
import '../models/models.dart';

/// Compatibility check result
enum CompatibilityLevel {
  compatible, // All good
  warning, // Potential issues
  incompatible, // Serious mismatch
}

/// A single compatibility issue
class CompatibilityIssue {
  final CompatibilityLevel level;
  final String title;
  final String description;
  final String? suggestion;

  const CompatibilityIssue({
    required this.level,
    required this.title,
    required this.description,
    this.suggestion,
  });
}

/// Service for checking livestock compatibility with tank parameters.
class CompatibilityService {
  /// Check compatibility of a livestock entry against tank targets.
  static List<CompatibilityIssue> checkLivestockCompatibility({
    required Livestock livestock,
    required Tank tank,
    required List<Livestock> existingLivestock,
  }) {
    final issues = <CompatibilityIssue>[];

    // Try to find species info
    final species =
        SpeciesDatabase.lookup(livestock.commonName) ??
        (livestock.scientificName != null
            ? SpeciesDatabase.lookup(livestock.scientificName!)
            : null);

    if (species == null) {
      // No species data - can't check compatibility
      return [];
    }

    final targets = tank.targets;

    // Temperature check
    if (targets.tempMin != null || targets.tempMax != null) {
      final tankMin = targets.tempMin ?? 0;
      final tankMax = targets.tempMax ?? 100;

      if (species.maxTempC < tankMin) {
        issues.add(
          CompatibilityIssue(
            level: CompatibilityLevel.incompatible,
            title: 'Temperature too high',
            description:
                '${species.commonName} prefers ${species.minTempC}-${species.maxTempC}°C, but tank target is ${tankMin.toStringAsFixed(0)}°C minimum.',
            suggestion:
                'Consider lowering tank temperature or choosing a different species.',
          ),
        );
      } else if (species.minTempC > tankMax) {
        issues.add(
          CompatibilityIssue(
            level: CompatibilityLevel.incompatible,
            title: 'Temperature too low',
            description:
                '${species.commonName} needs ${species.minTempC}-${species.maxTempC}°C, but tank target is ${tankMax.toStringAsFixed(0)}°C maximum.',
            suggestion:
                'Consider raising tank temperature or choosing a different species.',
          ),
        );
      } else if (species.minTempC < tankMin - 2 ||
          species.maxTempC > tankMax + 2) {
        issues.add(
          CompatibilityIssue(
            level: CompatibilityLevel.warning,
            title: 'Temperature at edge of range',
            description:
                '${species.commonName} prefers ${species.minTempC}-${species.maxTempC}°C. Tank targets (${tankMin.toStringAsFixed(0)}-${tankMax.toStringAsFixed(0)}°C) are workable but not ideal.',
          ),
        );
      }
    }

    // pH check
    if (targets.phMin != null || targets.phMax != null) {
      final tankPhMin = targets.phMin ?? 0;
      final tankPhMax = targets.phMax ?? 14;

      if (species.maxPh < tankPhMin - 0.5) {
        issues.add(
          CompatibilityIssue(
            level: CompatibilityLevel.incompatible,
            title: 'pH too high',
            description:
                '${species.commonName} prefers pH ${species.minPh}-${species.maxPh}, but tank target is ${tankPhMin.toStringAsFixed(1)} minimum.',
            suggestion: 'This species needs softer, more acidic water.',
          ),
        );
      } else if (species.minPh > tankPhMax + 0.5) {
        issues.add(
          CompatibilityIssue(
            level: CompatibilityLevel.incompatible,
            title: 'pH too low',
            description:
                '${species.commonName} needs pH ${species.minPh}-${species.maxPh}, but tank target is ${tankPhMax.toStringAsFixed(1)} maximum.',
            suggestion: 'This species needs harder, more alkaline water.',
          ),
        );
      } else if (species.minPh < tankPhMin - 0.3 ||
          species.maxPh > tankPhMax + 0.3) {
        issues.add(
          CompatibilityIssue(
            level: CompatibilityLevel.warning,
            title: 'pH at edge of comfort zone',
            description:
                '${species.commonName} prefers pH ${species.minPh}-${species.maxPh}. May adapt to tank pH, but not ideal.',
          ),
        );
      }
    }

    // GH check
    if (species.minGh != null && species.maxGh != null) {
      if (targets.ghMin != null || targets.ghMax != null) {
        final tankGhMin = targets.ghMin ?? 0;
        final tankGhMax = targets.ghMax ?? 30;

        if (species.maxGh! < tankGhMin - 2) {
          issues.add(
            CompatibilityIssue(
              level: CompatibilityLevel.warning,
              title: 'Water may be too hard',
              description:
                  '${species.commonName} prefers GH ${species.minGh}-${species.maxGh} dGH. Tank is harder at ${tankGhMin.toStringAsFixed(0)}+ dGH.',
              suggestion:
                  'Consider using RO water or peat filtration to soften.',
            ),
          );
        } else if (species.minGh! > tankGhMax + 2) {
          issues.add(
            CompatibilityIssue(
              level: CompatibilityLevel.warning,
              title: 'Water may be too soft',
              description:
                  '${species.commonName} prefers GH ${species.minGh}-${species.maxGh} dGH. Tank is softer at ${tankGhMax.toStringAsFixed(0)} dGH.',
              suggestion:
                  'Consider adding mineral supplements or crushed coral.',
            ),
          );
        }
      }
    }

    // Tank size check
    if (tank.volumeLitres < species.minTankLitres) {
      issues.add(
        CompatibilityIssue(
          level: species.minTankLitres > tank.volumeLitres * 1.5
              ? CompatibilityLevel.incompatible
              : CompatibilityLevel.warning,
          title: 'Tank may be too small',
          description:
              '${species.commonName} needs at least ${species.minTankLitres.toStringAsFixed(0)}L. Your tank is ${tank.volumeLitres.toStringAsFixed(0)}L.',
          suggestion: 'Consider a larger tank or fewer/smaller fish.',
        ),
      );
    }

    // School size check
    if (species.minSchoolSize > 1 && livestock.count < species.minSchoolSize) {
      issues.add(
        CompatibilityIssue(
          level: CompatibilityLevel.warning,
          title: 'Needs a larger school',
          description:
              '${species.commonName} should be kept in groups of ${species.minSchoolSize}+. You have ${livestock.count}.',
          suggestion:
              'Consider adding more to reduce stress and encourage natural behaviour.',
        ),
      );
    }

    // Check against existing livestock for species conflicts
    for (final existing in existingLivestock) {
      if (existing.id == livestock.id) continue; // Skip self

      final existingSpecies =
          SpeciesDatabase.lookup(existing.commonName) ??
          (existing.scientificName != null
              ? SpeciesDatabase.lookup(existing.scientificName!)
              : null);

      if (existingSpecies == null) continue;

      // Check avoidWith lists
      final speciesLower = species.commonName.toLowerCase();
      final existingLower = existingSpecies.commonName.toLowerCase();

      for (final avoid in species.avoidWith) {
        if (existingLower.contains(avoid.toLowerCase()) ||
            avoid.toLowerCase().contains(existingLower)) {
          issues.add(
            CompatibilityIssue(
              level: CompatibilityLevel.warning,
              title: 'Potential conflict with ${existingSpecies.commonName}',
              description:
                  '${species.commonName} may not be compatible with ${existingSpecies.commonName}.',
              suggestion: 'Monitor closely for aggression or stress.',
            ),
          );
          break;
        }
      }

      for (final avoid in existingSpecies.avoidWith) {
        if (speciesLower.contains(avoid.toLowerCase()) ||
            avoid.toLowerCase().contains(speciesLower)) {
          issues.add(
            CompatibilityIssue(
              level: CompatibilityLevel.warning,
              title: '${existingSpecies.commonName} may conflict',
              description:
                  '${existingSpecies.commonName} may not be compatible with ${species.commonName}.',
              suggestion: 'Monitor closely for aggression or stress.',
            ),
          );
          break;
        }
      }

      // Check temperament conflicts
      if (species.temperament == 'Aggressive' &&
          existingSpecies.temperament == 'Peaceful') {
        issues.add(
          CompatibilityIssue(
            level: CompatibilityLevel.warning,
            title: 'Temperament mismatch',
            description:
                '${species.commonName} (${species.temperament}) may bully ${existingSpecies.commonName} (${existingSpecies.temperament}).',
          ),
        );
      }

      // Check size difference (predation risk)
      if (species.adultSizeCm > existingSpecies.adultSizeCm * 3) {
        issues.add(
          CompatibilityIssue(
            level: CompatibilityLevel.warning,
            title: 'Size difference concern',
            description:
                '${species.commonName} (${species.adultSizeCm.toStringAsFixed(0)}cm adult) is much larger than ${existingSpecies.commonName} (${existingSpecies.adultSizeCm.toStringAsFixed(0)}cm).',
            suggestion: 'Larger fish may see smaller ones as food.',
          ),
        );
      } else if (existingSpecies.adultSizeCm > species.adultSizeCm * 3) {
        issues.add(
          CompatibilityIssue(
            level: CompatibilityLevel.warning,
            title: 'Size difference concern',
            description:
                '${existingSpecies.commonName} (${existingSpecies.adultSizeCm.toStringAsFixed(0)}cm adult) is much larger than ${species.commonName} (${species.adultSizeCm.toStringAsFixed(0)}cm).',
            suggestion: 'Larger fish may see smaller ones as food.',
          ),
        );
      }
    }

    return issues;
  }

  /// Get overall compatibility level from a list of issues.
  static CompatibilityLevel overallLevel(List<CompatibilityIssue> issues) {
    if (issues.any((i) => i.level == CompatibilityLevel.incompatible)) {
      return CompatibilityLevel.incompatible;
    }
    if (issues.any((i) => i.level == CompatibilityLevel.warning)) {
      return CompatibilityLevel.warning;
    }
    return CompatibilityLevel.compatible;
  }
}
