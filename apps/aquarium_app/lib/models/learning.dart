/// Learning system models for the "Duolingo for fishkeeping" experience
/// Lessons, quizzes, achievements, and learning paths

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

  const LearningPath({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.recommendedFor = const [ExperienceLevel.beginner],
    this.relevantTankTypes = const [],
    required this.lessons,
    this.orderIndex = 0,
  });

  int get totalXp => lessons.fold(0, (sum, l) => sum + l.xpReward);
  
  bool isRelevantFor(UserProfile profile) {
    if (relevantTankTypes.isEmpty) return true;
    return relevantTankTypes.contains(profile.primaryTankType);
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

/// Achievement/badge the user can earn
@immutable
class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final AchievementCategory category;
  final AchievementTier tier;
  final bool isSecret;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.category,
    this.tier = AchievementTier.bronze,
    this.isSecret = false,
  });
}

enum AchievementCategory {
  learning,    // Complete lessons
  tracking,    // Log data
  streak,      // Consistency
  milestones,  // XP/level milestones
  exploration, // Use features
  special,     // Easter eggs, events
}

enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum,
}

extension AchievementTierExt on AchievementTier {
  String get displayName {
    switch (this) {
      case AchievementTier.bronze:
        return 'Bronze';
      case AchievementTier.silver:
        return 'Silver';
      case AchievementTier.gold:
        return 'Gold';
      case AchievementTier.platinum:
        return 'Platinum';
    }
  }

  int get xpBonus {
    switch (this) {
      case AchievementTier.bronze:
        return 25;
      case AchievementTier.silver:
        return 50;
      case AchievementTier.gold:
        return 100;
      case AchievementTier.platinum:
        return 200;
    }
  }
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
    final expMatch = targetExperience.isEmpty || 
        targetExperience.contains(profile.experienceLevel);
    final tankMatch = targetTankTypes.isEmpty || 
        targetTankTypes.contains(profile.primaryTankType);
    return expMatch && tankMatch;
  }
}

// ==========================================
// PREDEFINED CONTENT
// ==========================================

/// All achievements available in the app
class Achievements {
  static const List<Achievement> all = [
    // Learning achievements
    Achievement(
      id: 'first_lesson',
      title: 'First Steps',
      description: 'Complete your first lesson',
      emoji: '📚',
      category: AchievementCategory.learning,
      tier: AchievementTier.bronze,
    ),
    Achievement(
      id: 'nitrogen_master',
      title: 'Cycle Master',
      description: 'Complete the Nitrogen Cycle path',
      emoji: '🔄',
      category: AchievementCategory.learning,
      tier: AchievementTier.silver,
    ),
    Achievement(
      id: 'quiz_ace',
      title: 'Quiz Ace',
      description: 'Get 100% on any quiz',
      emoji: '🎯',
      category: AchievementCategory.learning,
      tier: AchievementTier.gold,
    ),
    Achievement(
      id: 'all_paths',
      title: 'Scholar',
      description: 'Complete all learning paths',
      emoji: '🎓',
      category: AchievementCategory.learning,
      tier: AchievementTier.platinum,
    ),

    // Tracking achievements
    Achievement(
      id: 'first_test',
      title: 'Scientist',
      description: 'Log your first water test',
      emoji: '🔬',
      category: AchievementCategory.tracking,
      tier: AchievementTier.bronze,
    ),
    Achievement(
      id: 'test_week',
      title: 'Consistent Tester',
      description: 'Log water tests 7 days in a row',
      emoji: '📊',
      category: AchievementCategory.tracking,
      tier: AchievementTier.silver,
    ),
    Achievement(
      id: 'test_month',
      title: 'Data Driven',
      description: 'Log 30 water tests',
      emoji: '📈',
      category: AchievementCategory.tracking,
      tier: AchievementTier.gold,
    ),
    Achievement(
      id: 'stable_params',
      title: 'Tank Master',
      description: 'Maintain stable parameters for 30 days',
      emoji: '⚖️',
      category: AchievementCategory.tracking,
      tier: AchievementTier.platinum,
    ),

    // Streak achievements
    Achievement(
      id: 'streak_3',
      title: 'Getting Started',
      description: '3 day streak',
      emoji: '🔥',
      category: AchievementCategory.streak,
      tier: AchievementTier.bronze,
    ),
    Achievement(
      id: 'streak_7',
      title: 'On a Roll',
      description: '7 day streak',
      emoji: '🔥',
      category: AchievementCategory.streak,
      tier: AchievementTier.silver,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Dedicated',
      description: '30 day streak',
      emoji: '🔥',
      category: AchievementCategory.streak,
      tier: AchievementTier.gold,
    ),
    Achievement(
      id: 'streak_100',
      title: 'Unstoppable',
      description: '100 day streak',
      emoji: '🔥',
      category: AchievementCategory.streak,
      tier: AchievementTier.platinum,
    ),

    // Milestone achievements
    Achievement(
      id: 'xp_100',
      title: 'Level Up',
      description: 'Earn 100 XP',
      emoji: '⭐',
      category: AchievementCategory.milestones,
      tier: AchievementTier.bronze,
    ),
    Achievement(
      id: 'xp_500',
      title: 'Rising Star',
      description: 'Earn 500 XP',
      emoji: '🌟',
      category: AchievementCategory.milestones,
      tier: AchievementTier.silver,
    ),
    Achievement(
      id: 'xp_1000',
      title: 'Expert Status',
      description: 'Earn 1000 XP',
      emoji: '💫',
      category: AchievementCategory.milestones,
      tier: AchievementTier.gold,
    ),

    // Exploration achievements  
    Achievement(
      id: 'first_tank',
      title: 'Tank Owner',
      description: 'Add your first tank',
      emoji: '🐟',
      category: AchievementCategory.exploration,
      tier: AchievementTier.bronze,
    ),
    Achievement(
      id: 'multi_tank',
      title: 'Tank Collector',
      description: 'Add 3 or more tanks',
      emoji: '🏠',
      category: AchievementCategory.exploration,
      tier: AchievementTier.silver,
    ),
    Achievement(
      id: 'photo_album',
      title: 'Photographer',
      description: 'Add 10 photos to your gallery',
      emoji: '📷',
      category: AchievementCategory.exploration,
      tier: AchievementTier.bronze,
    ),

    // Special achievements
    Achievement(
      id: 'night_owl',
      title: 'Night Owl',
      description: 'Log activity after midnight',
      emoji: '🦉',
      category: AchievementCategory.special,
      isSecret: true,
    ),
    Achievement(
      id: 'early_bird',
      title: 'Early Bird',
      description: 'Log activity before 6am',
      emoji: '🐦',
      category: AchievementCategory.special,
      isSecret: true,
    ),
  ];

  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// XP reward values for different actions
class XpRewards {
  static const int lessonComplete = 50;
  static const int quizPass = 25;
  static const int quizPerfect = 50;
  static const int waterTest = 10;
  static const int waterChange = 10;
  static const int taskComplete = 15;
  static const int dailyStreak = 25;
  static const int addLivestock = 5;
  static const int addPhoto = 5;
  static const int journalEntry = 10;
}
