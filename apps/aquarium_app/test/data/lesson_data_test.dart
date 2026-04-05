// Tests for lesson data integrity.
//
// Verifies all lesson data files have valid structure:
//   - Non-empty titles and content sections
//   - Quiz questions have 4 options each
//   - correctIndex is 0-3
//   - No duplicate lesson IDs across all data files
//   - Every lesson ID in LessonProvider.allPathMetadata exists in data files
//
// Run: flutter test test/data/lesson_data_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:danio/models/learning.dart';
import 'package:danio/providers/lesson_provider.dart';

// Import lesson data files directly (no deferred needed in tests)
import 'package:danio/data/lessons/nitrogen_cycle.dart';
import 'package:danio/data/lessons/water_parameters.dart';
import 'package:danio/data/lessons/first_fish.dart';
import 'package:danio/data/lessons/maintenance.dart';
import 'package:danio/data/lessons/planted_tank.dart';
import 'package:danio/data/lessons/equipment.dart';
import 'package:danio/data/lessons/fish_health.dart';
import 'package:danio/data/lessons/species_care.dart';
import 'package:danio/data/lessons/advanced_topics.dart';
import 'package:danio/data/lessons/equipment_expanded.dart';
import 'package:danio/data/lessons/species_care_expanded.dart';
import 'package:danio/data/lessons/aquascaping.dart';
import 'package:danio/data/lessons/breeding.dart';
import 'package:danio/data/lessons/troubleshooting.dart';

/// Build merged equipment path (base + expanded)
LearningPath get _mergedEquipmentPath => LearningPath(
      id: equipmentPath.id,
      title: equipmentPath.title,
      description: equipmentPath.description,
      emoji: equipmentPath.emoji,
      recommendedFor: equipmentPath.recommendedFor,
      orderIndex: equipmentPath.orderIndex,
      lessons: [...equipmentPath.lessons, ...equipmentExpandedLessons],
    );

/// Build merged species care path (base + expanded)
LearningPath get _mergedSpeciesCarePath => LearningPath(
      id: speciesCarePath.id,
      title: speciesCarePath.title,
      description: speciesCarePath.description,
      emoji: speciesCarePath.emoji,
      recommendedFor: speciesCarePath.recommendedFor,
      orderIndex: speciesCarePath.orderIndex,
      lessons: [...speciesCarePath.lessons, ...speciesCareExpandedLessons],
    );

/// All paths, combined for cross-file tests.
List<LearningPath> get _allPaths => [
      nitrogenCyclePath,
      waterParametersPath,
      firstFishPath,
      maintenancePath,
      plantedTankPath,
      _mergedEquipmentPath,
      fishHealthPath,
      _mergedSpeciesCarePath,
      advancedTopicsPath,
      aquascapingPath,
      breedingBasicsPath,
      troubleshootingPath,
    ];

/// All lessons across every path.
List<Lesson> get _allLessons =>
    _allPaths.expand((p) => p.lessons).toList();

void main() {
  group('Lesson data — individual lesson integrity', () {
    test('every lesson has a non-empty title', () {
      for (final lesson in _allLessons) {
        expect(
          lesson.title,
          isNotEmpty,
          reason: 'Lesson "${lesson.id}" has an empty title',
        );
      }
    });

    test('every lesson has at least 1 section', () {
      for (final lesson in _allLessons) {
        expect(
          lesson.sections,
          isNotEmpty,
          reason: 'Lesson "${lesson.id}" has no sections',
        );
      }
    });

    test('every lesson section has non-empty content', () {
      for (final lesson in _allLessons) {
        for (int i = 0; i < lesson.sections.length; i++) {
          final section = lesson.sections[i];
          expect(
            section.content,
            isNotEmpty,
            reason:
                'Lesson "${lesson.id}" section $i (${section.type}) has empty content',
          );
        }
      }
    });

    test('every lesson has a non-empty description', () {
      for (final lesson in _allLessons) {
        expect(
          lesson.description,
          isNotEmpty,
          reason: 'Lesson "${lesson.id}" has an empty description',
        );
      }
    });

    test('every lesson has a positive xpReward', () {
      for (final lesson in _allLessons) {
        expect(
          lesson.xpReward,
          greaterThan(0),
          reason: 'Lesson "${lesson.id}" has xpReward <= 0',
        );
      }
    });
  });

  group('Lesson data — quiz integrity', () {
    test('every quiz has at least 1 question', () {
      for (final lesson in _allLessons) {
        if (lesson.quiz != null) {
          expect(
            lesson.quiz!.questions.length,
            greaterThanOrEqualTo(1),
            reason: 'Lesson "${lesson.id}" quiz has no questions',
          );
        }
      }
    });

    test('every quiz question has exactly 4 options', () {
      for (final lesson in _allLessons) {
        if (lesson.quiz != null) {
          for (final q in lesson.quiz!.questions) {
            expect(
              q.options.length,
              equals(4),
              reason:
                  'Lesson "${lesson.id}" question "${q.id}" has ${q.options.length} options (expected 4)',
            );
          }
        }
      }
    });

    test('every quiz question correctIndex is 0-3', () {
      for (final lesson in _allLessons) {
        if (lesson.quiz != null) {
          for (final q in lesson.quiz!.questions) {
            expect(
              q.correctIndex,
              inInclusiveRange(0, 3),
              reason:
                  'Lesson "${lesson.id}" question "${q.id}" correctIndex is ${q.correctIndex} (must be 0-3)',
            );
          }
        }
      }
    });

    test('every quiz question has non-empty question text and options', () {
      for (final lesson in _allLessons) {
        if (lesson.quiz != null) {
          for (final q in lesson.quiz!.questions) {
            expect(
              q.question,
              isNotEmpty,
              reason:
                  'Lesson "${lesson.id}" question "${q.id}" has empty question text',
            );
            for (int i = 0; i < q.options.length; i++) {
              expect(
                q.options[i],
                isNotEmpty,
                reason:
                    'Lesson "${lesson.id}" question "${q.id}" option $i is empty',
              );
            }
          }
        }
      }
    });
  });

  group('Lesson data — cross-file integrity', () {
    test('no duplicate lesson IDs across all data files', () {
      final allIds = _allLessons.map((l) => l.id).toList();
      final uniqueIds = allIds.toSet();
      // Find duplicates for error message
      final seen = <String>{};
      final duplicates = <String>{};
      for (final id in allIds) {
        if (!seen.add(id)) duplicates.add(id);
      }
      expect(
        allIds.length,
        equals(uniqueIds.length),
        reason: 'Duplicate lesson IDs found: $duplicates',
      );
    });

    test(
        'every lesson ID in LessonProvider.allPathMetadata exists in data files',
        () {
      final dataIds = _allLessons.map((l) => l.id).toSet();
      for (final path in LessonProvider.allPathMetadata) {
        for (final lessonId in path.lessonIds) {
          expect(
            dataIds,
            contains(lessonId),
            reason:
                'Lesson "$lessonId" (in path "${path.id}") not found in data files',
          );
        }
      }
    });

    test('total lesson count matches LessonProvider metadata (82)', () {
      expect(_allLessons.length, equals(82));
    });

    test('each LearningPath ID matches its lessons pathId field', () {
      for (final path in _allPaths) {
        for (final lesson in path.lessons) {
          expect(
            lesson.pathId,
            equals(path.id),
            reason:
                'Lesson "${lesson.id}" has pathId "${lesson.pathId}" but is in path "${path.id}"',
          );
        }
      }
    });

    test('no duplicate lesson IDs within any single path', () {
      for (final path in _allPaths) {
        final ids = path.lessons.map((l) => l.id).toList();
        expect(
          ids.length,
          equals(ids.toSet().length),
          reason: 'Path "${path.id}" has duplicate lesson IDs',
        );
      }
    });
  });
}
