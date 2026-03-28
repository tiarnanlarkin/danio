/// Learning system models for the "Duolingo for fishkeeping" experience
/// Lessons, quizzes, achievements, and learning paths
library;

import 'package:flutter/foundation.dart';
import 'tank.dart'; // For TankType enum
import 'user_profile.dart';

/// A learning path is a collection of related lessons
@immutable
class LearningPath {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final List<ExperienceLevel> recommendedFor;
  final List<TankType> relevantTankTypes;
  final List<Lesson> lessons;
  final int orderIndex;

  /// Path IDs that must be fully completed before this path unlocks.
  /// Cross-path prerequisites (e.g. fish_health requires nitrogen_cycle).
  final List<String> prerequisitePathIds;

  const LearningPath({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.recommendedFor = const [ExperienceLevel.beginner],
    this.relevantTankTypes = const [],
    required this.lessons,
    this.orderIndex = 0,
    this.prerequisitePathIds = const [],
  });

  int get totalXp => lessons.fold(0, (sum, l) => sum + l.xpReward);

  bool isRelevantFor(UserProfile profile) {
    if (relevantTankTypes.isEmpty) return true;
    return relevantTankTypes.contains(profile.primaryTankType);
  }

  /// Check whether this path is unlocked given the set of completed lesson IDs
  /// and the map of path-id → total-lesson-count.
  ///
  /// A path is locked if any [prerequisitePathIds] path is not yet complete
  /// (i.e. the user hasn't completed every lesson in that path).
  bool isPathUnlocked({
    required List<String> completedLessons,
    required Map<String, List<String>> pathLessonIds,
  }) {
    if (prerequisitePathIds.isEmpty) return true;
    return prerequisitePathIds.every((prereqPathId) {
      final lessonIds = pathLessonIds[prereqPathId];
      if (lessonIds == null || lessonIds.isEmpty) return true;
      return lessonIds.every((id) => completedLessons.contains(id));
    });
  }
}

/// A single lesson with content and optional quiz
@immutable
class Lesson {
  final String id;
  final String pathId;
  final String title;
  final String description;
  final int orderIndex;
  final int xpReward;
  final int estimatedMinutes;
  final List<LessonSection> sections;
  final Quiz? quiz;
  final List<String> prerequisites; // Lesson IDs that must be completed first

  const Lesson({
    required this.id,
    required this.pathId,
    required this.title,
    required this.description,
    required this.orderIndex,
    this.xpReward = 50,
    this.estimatedMinutes = 5,
    required this.sections,
    this.quiz,
    this.prerequisites = const [],
  });

  bool isUnlocked(List<String> completedLessons) {
    if (prerequisites.isEmpty) return true;
    return prerequisites.every((p) => completedLessons.contains(p));
  }
}

/// A section within a lesson (text, image, tip, etc.)
@immutable
class LessonSection {
  final LessonSectionType type;
  final String content;
  final String? imageUrl;
  final String? caption;

  const LessonSection({
    required this.type,
    required this.content,
    this.imageUrl,
    this.caption,
  });
}

enum LessonSectionType {
  text,
  heading,
  tip,
  warning,
  image,
  bulletList,
  numberedList,
  keyPoint,
  funFact,
}

/// Quiz at the end of a lesson
@immutable
class Quiz {
  final String id;
  final String lessonId;
  final List<QuizQuestion> questions;
  final int passingScore; // Percentage needed to pass
  final int bonusXp; // Extra XP for passing

  const Quiz({
    required this.id,
    required this.lessonId,
    required this.questions,
    this.passingScore = 70,
    this.bonusXp = 25,
  });

  int get maxScore => questions.length;
}

/// A single quiz question
@immutable
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });
}


/// Daily tip with personalization
@immutable
class DailyTip {
  final String id;
  final String title;
  final String content;
  final List<ExperienceLevel> targetExperience;
  final List<TankType> targetTankTypes;
  final String? relatedLessonId;

  const DailyTip({
    required this.id,
    required this.title,
    required this.content,
    this.targetExperience = const [],
    this.targetTankTypes = const [],
    this.relatedLessonId,
  });

  bool isRelevantFor(UserProfile profile) {
    final expMatch =
        targetExperience.isEmpty ||
        targetExperience.contains(profile.experienceLevel);
    final tankMatch =
        targetTankTypes.isEmpty ||
        targetTankTypes.contains(profile.primaryTankType);
    return expMatch && tankMatch;
  }
}

// ==========================================
// PREDEFINED CONTENT
// ==========================================

/// XP reward values for different actions
class XpRewards {
  // Lesson completion
  static const int lessonComplete = 50;

  // Quiz rewards (pass bonus is awarded on top of the question XP)
  static const int quizPass = 25;
  static const int quizPerfect = 50; // Perfect score bonus (on top of quizPass)

  // Per-question XP scaled by difficulty
  static const int quizQuestionEasy = 10;
  static const int quizQuestionMedium = 20;
  static const int quizQuestionHard = 30;

  // Tank management activities
  static const int waterTest = 15;
  static const int waterChange = 10;
  static const int taskComplete = 20;
  static const int dailyStreak = 25;
  static const int addLivestock = 10;
  static const int addPhoto = 5;
  static const int journalEntry = 10;

  // Hobby activity rewards
  static const int createTank = 25;
  static const int addEquipment = 10;
  static const int speciesResearched = 5;
  static const int plantResearched = 5;

  /// Get XP for a quiz question by difficulty label.
  /// Falls back to [quizQuestionMedium] for unknown values.
  static int forQuizQuestion(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return quizQuestionEasy;
      case 'hard':
        return quizQuestionHard;
      case 'medium':
      default:
        return quizQuestionMedium;
    }
  }
}
