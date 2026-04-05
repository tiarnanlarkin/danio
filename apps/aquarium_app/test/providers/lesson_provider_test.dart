// Tests for LessonProvider path metadata.
//
// Verifies the static allPathMetadata list matches the expected lesson structure
// without loading any deferred lesson content.
//
// Run: flutter test test/providers/lesson_provider_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:danio/providers/lesson_provider.dart';

void main() {
  group('LessonProvider.allPathMetadata', () {
    test('has exactly 12 paths', () {
      expect(LessonProvider.allPathMetadata.length, equals(12));
    });

    test('each path has a non-empty lessonIds list', () {
      for (final path in LessonProvider.allPathMetadata) {
        expect(
          path.lessonIds,
          isNotEmpty,
          reason: 'Path "${path.id}" has empty lessonIds',
        );
      }
    });

    test('total lesson count across all paths is 81', () {
      final total = LessonProvider.allPathMetadata
          .fold<int>(0, (sum, path) => sum + path.lessonIds.length);
      expect(total, equals(81));
    });

    test('no duplicate lesson IDs across all paths', () {
      final allIds = LessonProvider.allPathMetadata
          .expand((path) => path.lessonIds)
          .toList();
      final uniqueIds = allIds.toSet();
      expect(
        allIds.length,
        equals(uniqueIds.length),
        reason: 'Found duplicate lesson IDs in path metadata',
      );
    });

    test("path ID 'planted' exists (not 'planted_tank')", () {
      final ids = LessonProvider.allPathMetadata.map((p) => p.id).toList();
      expect(ids, contains('planted'));
      expect(ids, isNot(contains('planted_tank')));
    });

    test("'fish_health' path starts with 'fh_prevention'", () {
      final fishHealth = LessonProvider.allPathMetadata
          .firstWhere((p) => p.id == 'fish_health');
      expect(fishHealth.lessonIds.first, equals('fh_prevention'));
    });

    test('paths have unique IDs', () {
      final pathIds = LessonProvider.allPathMetadata.map((p) => p.id).toList();
      expect(pathIds.length, equals(pathIds.toSet().length));
    });

    test('paths have sequential orderIndex values starting at 0', () {
      final indices = LessonProvider.allPathMetadata
          .map((p) => p.orderIndex)
          .toList()
        ..sort();
      // Verify indices span 0..length-1 without gaps
      expect(indices.first, equals(0));
      expect(indices.last, equals(LessonProvider.allPathMetadata.length - 1));
      for (int i = 0; i < indices.length; i++) {
        expect(indices[i], equals(i));
      }
    });

    test('each path has non-empty title, description, and emoji', () {
      for (final path in LessonProvider.allPathMetadata) {
        expect(path.title, isNotEmpty,
            reason: 'Path "${path.id}" has empty title');
        expect(path.description, isNotEmpty,
            reason: 'Path "${path.id}" has empty description');
        expect(path.emoji, isNotEmpty,
            reason: 'Path "${path.id}" has empty emoji');
      }
    });

    test("'nitrogen_cycle' path has 6 lessons", () {
      final nc = LessonProvider.allPathMetadata
          .firstWhere((p) => p.id == 'nitrogen_cycle');
      expect(nc.lessonIds.length, equals(6));
    });

    test("'advanced_topics' path exists and has lessons", () {
      final at = LessonProvider.allPathMetadata
          .firstWhere((p) => p.id == 'advanced_topics');
      expect(at.lessonIds, isNotEmpty);
    });
  });
}
