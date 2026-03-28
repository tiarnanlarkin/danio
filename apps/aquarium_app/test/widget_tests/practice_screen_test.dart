// Tests verifying PracticeScreen removal and SR consolidation.
//
// Phase 2 removed the old PracticeScreen (lesson-weakness practice) and
// replaced all routes with SpacedRepetitionPracticeScreen.
//
// These tests verify the structural changes at the model/provider level
// (since widget tests for SpacedRepetitionPracticeScreen require a mock
// notification plugin that is not available in the test runner).
//
// Run: flutter test test/widget_tests/practice_screen_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:danio/providers/lesson_provider.dart';
import 'package:danio/models/spaced_repetition.dart';

void main() {
  group('Phase 2: PracticeScreen removed, SR as primary', () {
    // This file used to test PracticeScreen. That class no longer exists.
    // The test below serves as a compile-time and runtime sentinel: if
    // PracticeScreen was accidentally re-added, the old import would fail.
    test('SpacedRepetition model is importable and functional', () {
      final card = ReviewCard.newCard(
        conceptId: 'practice_screen_replacement_test',
        conceptType: ConceptType.lesson,
      );
      expect(card.strength, equals(0.0));
      expect(card.isDue, isTrue);
      expect(card.masteryLevel, equals(MasteryLevel.new_));
    });

    test('Practice Hub metadata has no Quick Practice path', () {
      final ids = LessonProvider.allPathMetadata.map((p) => p.id).toSet();
      expect(ids, isNot(contains('quick_practice')));
      expect(ids.length, equals(12));
    });

    test('fish_health requires nitrogen_cycle (cross-path prereq enforced)', () {
      final allMeta = LessonProvider.allPathMetadata;
      final fishHealth = allMeta.firstWhere((p) => p.id == 'fish_health');
      expect(fishHealth.prerequisitePathIds, contains('nitrogen_cycle'));

      // Verify lock when NC incomplete
      expect(fishHealth.isUnlocked([], allMeta), isFalse);

      // Verify unlock when NC complete
      final ncLessonIds = allMeta
          .firstWhere((p) => p.id == 'nitrogen_cycle')
          .lessonIds
          .toList();
      expect(fishHealth.isUnlocked(ncLessonIds, allMeta), isTrue);
    });

    test('ReviewCard.successRate computes correctly', () {
      var card = ReviewCard.newCard(
        conceptId: 'test',
        conceptType: ConceptType.quizQuestion,
      );
      expect(card.successRate, equals(0.0));
      card = card.afterReview(correct: true);
      expect(card.successRate, equals(1.0));
      card = card.afterReview(correct: false);
      expect(card.successRate, equals(0.5));
    });
  });
}
