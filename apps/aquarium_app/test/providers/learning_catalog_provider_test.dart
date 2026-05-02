// Tests for derived learning catalog summary counts.
//
// Run: flutter test test/providers/learning_catalog_provider_test.dart

import 'package:flutter_test/flutter_test.dart';

import 'package:danio/data/achievements.dart';
import 'package:danio/providers/learning_catalog_provider.dart';
import 'package:danio/providers/lesson_provider.dart';

void main() {
  group('LearningCatalogSummary', () {
    test('derives path, lesson, and achievement counts from source data', () {
      final summary = LearningCatalogSummary.fromMetadata(
        paths: LessonProvider.allPathMetadata,
        achievements: AchievementDefinitions.all,
      );

      expect(summary.pathCount, equals(12));
      expect(summary.lessonCount, equals(82));
      expect(
        summary.achievementCount,
        equals(AchievementDefinitions.all.length),
      );
    });
  });
}
