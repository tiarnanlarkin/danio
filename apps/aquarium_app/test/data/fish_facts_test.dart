// R-062: Real unit tests for fish_facts.dart data completeness and behaviour.
//
// QA-BT1-003 companion: verifies the data backing the Globe Fish Facts Dialog
// (R-064) is complete and correct.
//
// Run: flutter test test/data/fish_facts_test.dart

import 'package:flutter_test/flutter_test.dart';

import 'package:danio/data/fish_facts.dart';
import 'package:danio/data/species_unlock_map.dart';

void main() {
  // ── Test 1: kFishFacts completeness ────────────────────────────────────────

  test('kFishFacts contains entries for all 15 species', () {
    const expectedSpecies = [
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

    for (final species in expectedSpecies) {
      expect(
        kFishFacts.containsKey(species),
        isTrue,
        reason: 'kFishFacts is missing entry for "$species"',
      );
    }

    expect(
      kFishFacts.length,
      equals(expectedSpecies.length),
      reason: 'kFishFacts has unexpected extra or missing species',
    );
  });

  // ── Test 2: Each species has at least 3 facts ──────────────────────────────

  test('every species in kFishFacts has at least 3 non-empty facts', () {
    for (final entry in kFishFacts.entries) {
      expect(
        entry.value.length,
        greaterThanOrEqualTo(3),
        reason: '"${entry.key}" only has ${entry.value.length} fact(s) — needs 3+',
      );
      for (final fact in entry.value) {
        expect(
          fact.trim(),
          isNotEmpty,
          reason: '"${entry.key}" has a blank fact string',
        );
      }
    }
  });

  // ── Test 3: getRandomFishFact returns a fact for known species ─────────────

  test('getRandomFishFact returns a real fact for every known species', () {
    for (final speciesId in kFishFacts.keys) {
      final fact = getRandomFishFact(speciesId);
      expect(
        fact,
        isNot(equals(
            'Every fish has its own personality — spend time watching yours and you\'ll see it!')),
        reason: '"$speciesId" returned the generic fallback — facts map is probably broken',
      );
      expect(fact.trim(), isNotEmpty, reason: '"$speciesId" returned an empty fact');
    }
  });

  // ── Test 4: getRandomFishFact returns fallback for unknown species ──────────

  test('getRandomFishFact returns the generic fallback for unknown species IDs',
      () {
    const unknownId = 'purple_unicorn_fish';
    final fact = getRandomFishFact(unknownId);
    expect(
      fact,
      equals(
          'Every fish has its own personality — spend time watching yours and you\'ll see it!'),
    );
  });

  // ── Test 5: speciesDisplayName formats IDs correctly ──────────────────────

  test('speciesDisplayName converts snake_case IDs to Title Case correctly', () {
    expect(speciesDisplayName('neon_tetra'), equals('Neon Tetra'));
    expect(speciesDisplayName('zebra_danio'), equals('Zebra Danio'));
    expect(speciesDisplayName('bristlenose_pleco'), equals('Bristlenose Pleco'));
    expect(speciesDisplayName('amano_shrimp'), equals('Amano Shrimp'));
    expect(speciesDisplayName('betta'), equals('Betta'));
    expect(speciesDisplayName('harlequin_rasbora'), equals('Harlequin Rasbora'));
  });

  // ── Test 6: kFishFacts keys are consistent with speciesDisplayNames ─────────

  test('all kFishFacts keys exist in speciesDisplayNames (single source of truth)',
      () {
    for (final speciesId in kFishFacts.keys) {
      expect(
        speciesDisplayNames.containsKey(speciesId),
        isTrue,
        reason:
            '"$speciesId" is in kFishFacts but missing from speciesDisplayNames',
      );
    }
  });
}
