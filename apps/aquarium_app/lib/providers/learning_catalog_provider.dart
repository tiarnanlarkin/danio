/// Derived learning catalog statistics.
///
/// Keeps marketing copy, onboarding nudges, and tests tied to the real catalog
/// rather than stale hand-entered counts.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/achievements.dart';
import '../models/achievements.dart';
import '../models/learning.dart';
import 'lesson_provider.dart';

class LearningCatalogSummary {
  final int pathCount;
  final int lessonCount;
  final int quizQuestionCount;
  final int achievementCount;

  const LearningCatalogSummary({
    required this.pathCount,
    required this.lessonCount,
    required this.quizQuestionCount,
    required this.achievementCount,
  });

  factory LearningCatalogSummary.fromMetadata({
    required List<PathMetadata> paths,
    required List<Achievement> achievements,
  }) {
    final lessonIds = paths.expand((path) => path.lessonIds).toSet();
    return LearningCatalogSummary(
      pathCount: paths.length,
      lessonCount: lessonIds.length,
      quizQuestionCount: 0,
      achievementCount: achievements.length,
    );
  }

  factory LearningCatalogSummary.fromLoadedPaths({
    required List<LearningPath> paths,
    required List<Achievement> achievements,
  }) {
    final lessonIds = paths.expand((path) => path.lessons.map((l) => l.id));
    final quizQuestions = paths
        .expand((path) => path.lessons)
        .fold<int>(
          0,
          (sum, lesson) => sum + (lesson.quiz?.questions.length ?? 0),
        );

    return LearningCatalogSummary(
      pathCount: paths.length,
      lessonCount: lessonIds.toSet().length,
      quizQuestionCount: quizQuestions,
      achievementCount: achievements.length,
    );
  }
}

final learningCatalogSummaryProvider = Provider<LearningCatalogSummary>((ref) {
  final paths = ref.watch(pathMetadataProvider);
  return LearningCatalogSummary.fromMetadata(
    paths: paths,
    achievements: AchievementDefinitions.all,
  );
});

final learningCatalogFullSummaryProvider =
    FutureProvider<LearningCatalogSummary>((ref) async {
      final metadata = ref.watch(pathMetadataProvider);
      final notifier = ref.read(lessonProvider.notifier);
      await notifier.loadPaths(metadata.map((path) => path.id).toList());

      final loadedPaths = ref.read(lessonProvider).loadedPaths.values.toList();
      return LearningCatalogSummary.fromLoadedPaths(
        paths: loadedPaths,
        achievements: AchievementDefinitions.all,
      );
    });
