// R-062: Real unit tests for species_unlock_map.dart integrity.
//
// Verifies:
//   - speciesDisplayNames has all 15 expected species
//   - speciesLessonMap maps to known lesson IDs (no dangling references)
//   - defaultUnlockedSpecies is a subset of speciesDisplayNames keys
//   - speciesForLesson round-trips correctly
//
// Run: flutter test test/data/species_unlock_map_test.dart

import 'package:flutter_test/flutter_test.dart';

import 'package:danio/data/species_unlock_map.dart';

void main() {
  const allExpectedSpecies = [
    'amano_shrimp',
    'angelfish',
    'betta',
    'bristlenose_pleco',
    'bronze_corydoras',
    'cherry_barb',
    'cherry_shrimp',
    'guppy',
    'harlequin_rasbora',
    'molly',
    'neon_tetra',
    'nerite_snail',
    'otocinclus',
    'platy',
    'zebra_danio',
  ];

  // ── Test 1: speciesDisplayNames completeness ───────────────────────────────

  test('speciesDisplayNames contains all 15 expected species', () {
    for (final species in allExpectedSpecies) {
      expect(
        speciesDisplayNames.containsKey(species),
        isTrue,
        reason: 'speciesDisplayNames is missing "$species"',
      );
    }
    expect(
      speciesDisplayNames.length,
      equals(allExpectedSpecies.length),
      reason: 'speciesDisplayNames has unexpected extra entries',
    );
  });

  // ── Test 2: speciesDisplayNames values are non-empty strings ──────────────

  test('speciesDisplayNames values are all non-empty display strings', () {
    for (final entry in speciesDisplayNames.entries) {
      expect(
        entry.value.trim(),
        isNotEmpty,
        reason: '"${entry.key}" has an empty display name',
      );
    }
  });

  // ── Test 3: speciesLessonMap keys are all valid species IDs ───────────────

  test('speciesLessonMap keys are all valid species IDs from speciesDisplayNames',
      () {
    for (final speciesId in speciesLessonMap.keys) {
      expect(
        speciesDisplayNames.containsKey(speciesId),
        isTrue,
        reason:
            'speciesLessonMap references unknown species "$speciesId" — not in speciesDisplayNames',
      );
    }
  });

  // ── Test 4: defaultUnlockedSpecies are a subset of speciesDisplayNames ─────

  test('defaultUnlockedSpecies is a valid subset of speciesDisplayNames', () {
    for (final speciesId in defaultUnlockedSpecies) {
      expect(
        speciesDisplayNames.containsKey(speciesId),
        isTrue,
        reason:
            'defaultUnlockedSpecies contains unknown species "$speciesId"',
      );
    }
    // At least one default species should exist so new users see fish
    expect(
      defaultUnlockedSpecies,
      isNotEmpty,
      reason: 'defaultUnlockedSpecies is empty — new users will have no fish!',
    );
  });

  // ── Test 5: speciesForLesson round-trips known mappings ───────────────────

  test('speciesForLesson returns correct species for known lesson IDs', () {
    // Pick a few well-known mappings to verify the round-trip
    expect(speciesForLesson('sc_betta'), equals('betta'));
    expect(speciesForLesson('sc_tetras'), isNotNull); // maps to neon_tetra or cherry_barb
    expect(speciesForLesson('sc_shrimp'), isNotNull);
    expect(speciesForLesson('sc_corydoras'), equals('bronze_corydoras'));
    expect(speciesForLesson('sc_plecos'), isNotNull);
  });

  // ── Test 6: speciesForLesson returns null for unknown lesson ──────────────

  test('speciesForLesson returns null for a lesson ID with no mapped species',
      () {
    expect(speciesForLesson('no_such_lesson_ever'), isNull);
    expect(speciesForLesson(''), isNull);
  });

  // ── Test 7: speciesAssetPath and speciesThumbPath produce correct paths ────

  test('speciesAssetPath and speciesThumbPath produce expected asset paths', () {
    expect(
      speciesAssetPath('neon_tetra'),
      equals('assets/images/fish/neon_tetra.png'),
    );
    expect(
      speciesThumbPath('betta'),
      equals('assets/images/fish/thumb/betta.png'),
    );
  });
}
