/// Achievement service - Handles checking and unlocking achievements
/// Integrates with user actions to award achievements automatically
library;

import 'package:flutter/foundation.dart';
import '../models/achievements.dart';
import '../models/user_profile.dart';
import '../data/achievements.dart';
import '../providers/lesson_provider.dart';

/// Statistics for achievement checking
class AchievementStats {
  final int lessonsCompleted;
  final int currentStreak;
  final int totalXp;
  final int perfectScores;
  final int friendsCount;
  final int dailyTipsRead;
  final int practiceSessions;
  final int shopVisits;
  final int weekendStreaks;
  final int dailyGoalStreaks;
  final bool hasCompletedPlacementTest;
  final DateTime? lastActivityDate;
  final DateTime? lastLessonCompletedAt;
  final int? lastLessonDuration; // in seconds
  final int? lastLessonScore; // 0-100
  final int todayLessonsCompleted;
  final List<String> completedLessonIds;
  final int fullHeartsStreak;
  final int reviewsCompleted;
  final int reviewStreak;

  const AchievementStats({
    this.lessonsCompleted = 0,
    this.currentStreak = 0,
    this.totalXp = 0,
    this.perfectScores = 0,
    this.friendsCount = 0,
    this.dailyTipsRead = 0,
    this.practiceSessions = 0,
    this.shopVisits = 0,
    this.weekendStreaks = 0,
    this.dailyGoalStreaks = 0,
    this.hasCompletedPlacementTest = false,
    this.lastActivityDate,
    this.lastLessonCompletedAt,
    this.lastLessonDuration,
    this.lastLessonScore,
    this.todayLessonsCompleted = 0,
    this.completedLessonIds = const [],
    this.fullHeartsStreak = 0,
    this.reviewsCompleted = 0,
    this.reviewStreak = 0,
  });
}

/// Service for managing achievements
class AchievementService {
  /// Check all achievements and return newly unlocked ones
  static List<AchievementUnlockResult> checkAchievements({
    required UserProfile userProfile,
    required AchievementStats stats,
    required Map<String, AchievementProgress> progressMap,
  }) {
    final List<AchievementUnlockResult> results = [];

    for (final achievement in AchievementDefinitions.all) {
      final progress =
          progressMap[achievement.id] ??
          AchievementProgress(achievementId: achievement.id);

      // Skip if already unlocked
      if (progress.isUnlocked) continue;

      final result = _checkSingleAchievement(
        achievement: achievement,
        progress: progress,
        stats: stats,
        userProfile: userProfile,
      );

      if (result != null) {
        results.add(result);
      }
    }

    return results;
  }

  /// Check a single achievement
  static AchievementUnlockResult? _checkSingleAchievement({
    required Achievement achievement,
    required AchievementProgress progress,
    required AchievementStats stats,
    required UserProfile userProfile,
  }) {
    int newCount = progress.currentCount;
    bool shouldUnlock = false;

    // Check based on achievement ID
    switch (achievement.id) {
      // ====================================================================
      // LEARNING PROGRESS
      // ====================================================================
      case 'first_lesson':
        newCount = stats.lessonsCompleted;
        shouldUnlock = stats.lessonsCompleted >= 1;
        break;

      case 'lessons_10':
        newCount = stats.lessonsCompleted;
        shouldUnlock = stats.lessonsCompleted >= 10;
        break;

      case 'lessons_50':
        newCount = stats.lessonsCompleted;
        shouldUnlock = stats.lessonsCompleted >= 50;
        break;

      case 'lessons_100':
        newCount = stats.lessonsCompleted;
        shouldUnlock = stats.lessonsCompleted >= 100;
        break;

      case 'beginner_master':
      case 'intermediate_master':
      case 'advanced_master':
      case 'water_chemistry_master':
      case 'plants_master':
      case 'livestock_master':
        // Not implemented: Requires LessonContent.allPaths integration
        // Deferred to future release when lesson path system is finalized
        shouldUnlock = false;
        break;

      case 'placement_complete':
        shouldUnlock = stats.hasCompletedPlacementTest;
        break;

      // ====================================================================
      // STREAKS
      // ====================================================================
      case 'streak_3':
        newCount = stats.currentStreak;
        shouldUnlock = stats.currentStreak >= 3;
        break;

      case 'streak_7':
        newCount = stats.currentStreak;
        shouldUnlock = stats.currentStreak >= 7;
        break;

      case 'streak_14':
        newCount = stats.currentStreak;
        shouldUnlock = stats.currentStreak >= 14;
        break;

      case 'streak_30':
        newCount = stats.currentStreak;
        shouldUnlock = stats.currentStreak >= 30;
        break;

      case 'streak_60':
        newCount = stats.currentStreak;
        shouldUnlock = stats.currentStreak >= 60;
        break;

      case 'streak_100':
        newCount = stats.currentStreak;
        shouldUnlock = stats.currentStreak >= 100;
        break;

      case 'streak_365':
        newCount = stats.currentStreak;
        shouldUnlock = stats.currentStreak >= 365;
        break;

      case 'weekend_warrior':
        newCount = stats.weekendStreaks;
        shouldUnlock = stats.weekendStreaks >= 10;
        break;

      case 'daily_goal_streak':
        newCount = stats.dailyGoalStreaks;
        shouldUnlock = stats.dailyGoalStreaks >= 7;
        break;

      // ====================================================================
      // XP MILESTONES
      // ====================================================================
      case 'xp_100':
        newCount = stats.totalXp;
        shouldUnlock = stats.totalXp >= 100;
        break;

      case 'xp_500':
        newCount = stats.totalXp;
        shouldUnlock = stats.totalXp >= 500;
        break;

      case 'xp_1000':
        newCount = stats.totalXp;
        shouldUnlock = stats.totalXp >= 1000;
        break;

      case 'xp_2500':
        newCount = stats.totalXp;
        shouldUnlock = stats.totalXp >= 2500;
        break;

      case 'xp_5000':
        newCount = stats.totalXp;
        shouldUnlock = stats.totalXp >= 5000;
        break;

      case 'xp_10000':
        newCount = stats.totalXp;
        shouldUnlock = stats.totalXp >= 10000;
        break;

      case 'xp_25000':
        newCount = stats.totalXp;
        shouldUnlock = stats.totalXp >= 25000;
        break;

      case 'xp_50000':
        newCount = stats.totalXp;
        shouldUnlock = stats.totalXp >= 50000;
        break;

      // ====================================================================
      // SPECIAL
      // ====================================================================
      case 'early_bird':
        if (stats.lastLessonCompletedAt != null) {
          final hour = stats.lastLessonCompletedAt!.hour;
          shouldUnlock = hour < 8;
        }
        break;

      case 'night_owl':
        if (stats.lastLessonCompletedAt != null) {
          final hour = stats.lastLessonCompletedAt!.hour;
          shouldUnlock = hour >= 22;
        }
        break;

      case 'perfectionist':
        newCount = stats.perfectScores;
        shouldUnlock = stats.perfectScores >= 10;
        break;

      case 'speed_demon':
        if (stats.lastLessonDuration != null) {
          shouldUnlock = stats.lastLessonDuration! < 120; // 2 minutes
        }
        break;

      case 'marathon_learner':
        shouldUnlock = stats.todayLessonsCompleted >= 5;
        break;

      case 'comeback':
        if (stats.lastActivityDate != null &&
            stats.lastLessonCompletedAt != null) {
          final daysSinceLastActivity = stats.lastLessonCompletedAt!
              .difference(stats.lastActivityDate!)
              .inDays;
          shouldUnlock = daysSinceLastActivity >= 30;
        }
        break;

      case 'social_butterfly':
        newCount = stats.friendsCount;
        shouldUnlock = stats.friendsCount >= 10;
        break;

      case 'teachers_pet':
        // Count all lessons across all paths using lightweight metadata
        final allLessons = LessonProvider.allPathMetadata
            .expand((meta) => meta.lessonIds)
            .toSet();
        shouldUnlock =
            stats.completedLessonIds.length >= allLessons.length &&
            allLessons.isNotEmpty;
        break;

      case 'completionist':
        // Unlock when all other non-hidden achievements are unlocked
        final otherAchievements = AchievementDefinitions.all
            .where((a) => a.id != 'completionist' && !a.isHidden)
            .length;
        final unlockedCount = userProfile.achievements.length;
        shouldUnlock = unlockedCount >= otherAchievements;
        break;

      case 'midnight_scholar':
        if (stats.lastLessonCompletedAt != null) {
          final time = stats.lastLessonCompletedAt!;
          shouldUnlock = time.hour == 0; // Any time between midnight and 1AM
        }
        break;

      case 'heart_collector':
        newCount = stats.fullHeartsStreak;
        shouldUnlock = stats.fullHeartsStreak >= 7;
        break;

      case 'league_climber':
        shouldUnlock = userProfile.league.index >= 2; // Gold or higher
        break;

      // ====================================================================
      // ENGAGEMENT
      // ====================================================================
      case 'daily_tips_10':
        newCount = stats.dailyTipsRead;
        shouldUnlock = stats.dailyTipsRead >= 10;
        break;

      case 'daily_tips_50':
        newCount = stats.dailyTipsRead;
        shouldUnlock = stats.dailyTipsRead >= 50;
        break;

      case 'daily_tips_100':
        newCount = stats.dailyTipsRead;
        shouldUnlock = stats.dailyTipsRead >= 100;
        break;

      case 'practice_10':
        newCount = stats.practiceSessions;
        shouldUnlock = stats.practiceSessions >= 10;
        break;

      case 'practice_50':
        newCount = stats.practiceSessions;
        shouldUnlock = stats.practiceSessions >= 50;
        break;

      case 'practice_100':
        newCount = stats.practiceSessions;
        shouldUnlock = stats.practiceSessions >= 100;
        break;

      case 'shop_visitor':
        newCount = stats.shopVisits;
        shouldUnlock = stats.shopVisits >= 5;
        break;

      // ====================================================================
      // REVIEWS (Spaced Repetition)
      // ====================================================================
      case 'first_review':
        newCount = stats.reviewsCompleted;
        shouldUnlock = stats.reviewsCompleted >= 1;
        break;

      case 'reviews_10':
        newCount = stats.reviewsCompleted;
        shouldUnlock = stats.reviewsCompleted >= 10;
        break;

      case 'reviews_50':
        newCount = stats.reviewsCompleted;
        shouldUnlock = stats.reviewsCompleted >= 50;
        break;

      case 'reviews_100':
        newCount = stats.reviewsCompleted;
        shouldUnlock = stats.reviewsCompleted >= 100;
        break;

      case 'review_streak_3':
        newCount = stats.reviewStreak;
        shouldUnlock = stats.reviewStreak >= 3;
        break;

      case 'review_streak_7':
        newCount = stats.reviewStreak;
        shouldUnlock = stats.reviewStreak >= 7;
        break;

      case 'review_streak_14':
        newCount = stats.reviewStreak;
        shouldUnlock = stats.reviewStreak >= 14;
        break;

      case 'review_streak_30':
        newCount = stats.reviewStreak;
        shouldUnlock = stats.reviewStreak >= 30;
        break;
    }

    // Update progress
    final updatedProgress = progress.copyWith(
      currentCount: newCount,
      isUnlocked: shouldUnlock,
      unlockedAt: shouldUnlock ? DateTime.now() : null,
    );

    // Return result if there's a change
    if (updatedProgress.currentCount != progress.currentCount ||
        updatedProgress.isUnlocked != progress.isUnlocked) {
      return AchievementUnlockResult(
        achievement: achievement,
        wasJustUnlocked: shouldUnlock && !progress.isUnlocked,
        xpAwarded: (shouldUnlock && !progress.isUnlocked)
            ? achievement.rarity.xpReward
            : 0,
        progress: updatedProgress,
      );
    }

    return null;
  }

  /// Get completion percentage
  static double getCompletionPercentage(List<String> unlockedIds) {
    if (AchievementDefinitions.all.isEmpty) return 0.0;
    return unlockedIds.length / AchievementDefinitions.all.length;
  }

  /// Get achievements grouped by category
  static Map<AchievementCategory, List<Achievement>>
  getAchievementsByCategory() {
    final Map<AchievementCategory, List<Achievement>> grouped = {};

    for (final category in AchievementCategory.values) {
      grouped[category] = AchievementDefinitions.getByCategory(category);
    }

    return grouped;
  }

  /// Get next achievable achievements (closest to unlocking)
  static List<Achievement> getNextAchievements({
    required Map<String, AchievementProgress> progressMap,
    int limit = 3,
  }) {
    final List<MapEntry<Achievement, double>> withProgress = [];

    for (final achievement in AchievementDefinitions.all) {
      final progress = progressMap[achievement.id];
      if (progress == null || progress.isUnlocked) continue;

      final progressPercent = progress.getProgress(achievement.targetCount);
      if (progressPercent > 0) {
        withProgress.add(MapEntry(achievement, progressPercent));
      }
    }

    // Sort by progress (descending)
    withProgress.sort((a, b) => b.value.compareTo(a.value));

    return withProgress.take(limit).map((e) => e.key).toList();
  }
}
