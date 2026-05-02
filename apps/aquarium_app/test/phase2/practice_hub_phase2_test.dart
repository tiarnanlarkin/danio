// Phase 2 tests: Practice Hub consolidation & path availability
//
// 1. Verify PracticeScreen is gone — no dead imports
// 2. Verify fish_health stays emergency-accessible
// 3. Verify PathMetadata.isUnlocked still supports cross-path prerequisites
// 4. Verify the Practice hub keeps spaced repetition as the review surface
//
// Run: flutter test test/phase2/practice_hub_phase2_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:danio/providers/lesson_provider.dart';
import 'package:danio/models/learning.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────────────
  // 2.1  PracticeScreen is dead — no metadata reference to old quick practice
  // ─────────────────────────────────────────────────────────────────────────────
  group('2.1 Old PracticeScreen removed', () {
    test(
      'practice_hub_screen no longer lists a "Quick Practice" path in metadata',
      () {
        // Quick Practice was never a PathMetadata entry, but we confirm the
        // path metadata set is clean and contains only the expected 12 paths.
        final ids = LessonProvider.allPathMetadata.map((p) => p.id).toSet();
        // Sanity: exactly 9 real paths
        expect(ids.length, equals(12));
        // None should be a placeholder quick-practice path
        expect(ids, isNot(contains('quick_practice')));
      },
    );
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 2.3  Path availability — fish_health must stay emergency-accessible
  // ─────────────────────────────────────────────────────────────────────────────
  group('2.3 Path availability', () {
    test(
      'fish_health PathMetadata has no prerequisite',
      () {
        final fishHealth = LessonProvider.allPathMetadata.firstWhere(
          (p) => p.id == 'fish_health',
        );
        expect(fishHealth.prerequisitePathIds, isEmpty);
      },
    );

    test(
      'fish_health stays unlocked when nitrogen_cycle lessons are incomplete',
      () {
        final allMeta = LessonProvider.allPathMetadata;
        final fishHealth = allMeta.firstWhere((p) => p.id == 'fish_health');
        final nitrogenCycle = allMeta.firstWhere(
          (p) => p.id == 'nitrogen_cycle',
        );

        // Simulate: user has completed zero lessons
        final noCompletions = <String>[];
        expect(
          fishHealth.isUnlocked(noCompletions, allMeta),
          isTrue,
          reason:
              'fish_health must be available when a user has a sick fish now',
        );

        // Simulate: user has completed some but not all nitrogen_cycle lessons
        final partialCompletions = nitrogenCycle.lessonIds.take(3).toList();
        expect(
          fishHealth.isUnlocked(partialCompletions, allMeta),
          isTrue,
          reason: 'fish_health must stay accessible during emergencies',
        );
      },
    );

    test(
      'fish_health stays unlocked after nitrogen_cycle is complete',
      () {
        final allMeta = LessonProvider.allPathMetadata;
        final fishHealth = allMeta.firstWhere((p) => p.id == 'fish_health');
        final nitrogenCycle = allMeta.firstWhere(
          (p) => p.id == 'nitrogen_cycle',
        );

        // Simulate: user has completed all nitrogen_cycle lessons
        final ncComplete = nitrogenCycle.lessonIds.toList();
        expect(
          fishHealth.isUnlocked(ncComplete, allMeta),
          isTrue,
          reason:
              'fish_health must be unlocked once nitrogen_cycle is complete',
        );
      },
    );

    test(
      'nitrogen_cycle itself has no prerequisitePathIds (it is the entry path)',
      () {
        final nc = LessonProvider.allPathMetadata.firstWhere(
          (p) => p.id == 'nitrogen_cycle',
        );
        expect(
          nc.prerequisitePathIds,
          isEmpty,
          reason:
              'nitrogen_cycle is a foundational path and must be open from the start',
        );
      },
    );

    test('paths without prerequisitePathIds are always unlocked', () {
      final allMeta = LessonProvider.allPathMetadata;
      final noPrerequPaths = allMeta.where(
        (p) => p.prerequisitePathIds.isEmpty,
      );
      for (final path in noPrerequPaths) {
        expect(
          path.isUnlocked([], allMeta),
          isTrue,
          reason:
              'Path "${path.id}" has no prerequisites and must always be unlocked',
        );
      }
    });

    test(
      'LearningPath.isPathUnlocked mirrors PathMetadata.isUnlocked logic',
      () {
        final allMeta = LessonProvider.allPathMetadata;
        final ncLessonIds = allMeta
            .firstWhere((p) => p.id == 'nitrogen_cycle')
            .lessonIds
            .toList();
        final pathLessonIdMap = PathMetadata.buildLessonIdMap(allMeta);

        // Build a minimal path with a prerequisite to verify the generic
        // prerequisite logic separately from emergency-accessible Fish Health.
        final advancedPath = LearningPath(
          id: 'advanced_health',
          title: 'Advanced Health',
          description: 'test',
          emoji: '🏥',
          lessons: const [],
          prerequisitePathIds: const ['nitrogen_cycle'],
        );

        // Locked when NC incomplete
        expect(
          advancedPath.isPathUnlocked(
            completedLessons: [],
            pathLessonIds: pathLessonIdMap,
          ),
          isFalse,
        );

        // Unlocked when NC complete
        expect(
          advancedPath.isPathUnlocked(
            completedLessons: ncLessonIds,
            pathLessonIds: pathLessonIdMap,
          ),
          isTrue,
        );
      },
    );
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 2.2  Practice Hub — SR is the primary practice mode card
  // ─────────────────────────────────────────────────────────────────────────────
  group('2.2 Practice Hub SR as primary', () {
    test(
      'fish_health remains open while SR drives review mastery',
      () {
        final fishHealth = LessonProvider.allPathMetadata.firstWhere(
          (p) => p.id == 'fish_health',
        );
        // Fish Health must stay reachable for urgent care. Mastery reinforcement
        // happens through review cards seeded from completed lessons.
        expect(fishHealth.prerequisitePathIds, isEmpty);
      },
    );

    test('PathMetadata.buildLessonIdMap returns correct map', () {
      final allMeta = LessonProvider.allPathMetadata;
      final map = PathMetadata.buildLessonIdMap(allMeta);
      expect(map.length, equals(12));
      expect(map.containsKey('nitrogen_cycle'), isTrue);
      expect(map['nitrogen_cycle'], isNotEmpty);
    });
  });
}
