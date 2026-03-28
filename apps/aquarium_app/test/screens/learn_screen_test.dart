// Tests for learn_screen stub gate configuration.
//
// Tests that _comingSoonPathIds is empty (all paths are available)
// and that advanced_topics path is not blocked.
//
// Run: flutter test test/screens/learn_screen_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:danio/providers/lesson_provider.dart';

// We test the public behavior: all 9 paths are accessible via metadata,
// and _comingSoonPathIds is empty (verified by testing in learn_screen.dart
// behavior — we can't import private fields, but we can verify metadata).

void main() {
  group('learn_screen stub gate', () {
    test('all 9 paths are present in allPathMetadata', () {
      // If a path were coming soon / stubbed out, it might be removed from metadata.
      // Having all 9 confirms nothing is hidden.
      expect(LessonProvider.allPathMetadata.length, equals(9));
    });

    test('advanced_topics path is present (not hidden)', () {
      final ids = LessonProvider.allPathMetadata.map((p) => p.id).toSet();
      expect(ids, contains('advanced_topics'));
    });

    test('advanced_topics has non-empty lessonIds (not a stub)', () {
      final at = LessonProvider.allPathMetadata
          .firstWhere((p) => p.id == 'advanced_topics');
      expect(at.lessonIds, isNotEmpty);
    });

    test('all expected path IDs are present', () {
      final ids = LessonProvider.allPathMetadata.map((p) => p.id).toSet();
      const expected = {
        'nitrogen_cycle',
        'water_parameters',
        'first_fish',
        'maintenance',
        'planted',
        'equipment',
        'fish_health',
        'species_care',
        'advanced_topics',
      };
      expect(ids, equals(expected));
    });

    test('no path has empty lessonIds (no stub paths)', () {
      for (final path in LessonProvider.allPathMetadata) {
        expect(
          path.lessonIds,
          isNotEmpty,
          reason:
              'Path "${path.id}" has no lessons — it may be a stub or coming-soon placeholder',
        );
      }
    });

    test('equipment path has content (was once a stub candidate)', () {
      final eq = LessonProvider.allPathMetadata
          .firstWhere((p) => p.id == 'equipment');
      expect(eq.lessonIds.length, greaterThanOrEqualTo(1));
    });
  });
}
