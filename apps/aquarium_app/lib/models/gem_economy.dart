/// Gem economy configuration and reward values
/// Defines how many gems users earn for different actions

import 'learning.dart';

class GemRewards {
  // Lesson & Learning
  static const int lessonComplete = 5;
  static const int quizPass = 3;
  static const int quizPerfect = 5;
  static const int placementTest = 10;
  static const int reviewLesson = 2;

  // Daily Goals & Streaks
  static const int dailyGoalMet = 5;
  static const int streak7Days = 10;
  static const int streak30Days = 25;
  static const int streak100Days = 100;

  // Level Progression
  static const int levelUp = 10;
  static const int reachExpert = 50;
  static const int reachMaster = 100;
  static const int reachGuru = 200;

  // Achievements
  static const int achievementBronze = 5;
  static const int achievementSilver = 10;
  static const int achievementGold = 20;
  static const int achievementPlatinum = 50;

  // Bonuses
  static const int weeklyActive = 10;      // Logged in 5+ days this week
  static const int perfectWeek = 25;       // Met daily goal all 7 days
  static const int referralBonus = 50;     // Friend completes onboarding

  /// Calculate gems for streak milestone
  static int getStreakMilestoneReward(int streakDays) {
    if (streakDays == 7) return streak7Days;
    if (streakDays == 14) return streak7Days;
    if (streakDays == 30) return streak30Days;
    if (streakDays == 50) return streak30Days;
    if (streakDays == 100) return streak100Days;
    if (streakDays == 365) return 365;
    return 0;
  }

  /// Calculate gems for level milestone
  static int getLevelUpReward(int newLevel) {
    // Levels from UserProfile.levels map
    if (newLevel == 4) return levelUp;        // Aquarist
    if (newLevel == 5) return reachExpert;    // Expert
    if (newLevel == 6) return reachMaster;    // Master
    if (newLevel == 7) return reachGuru;      // Guru
    return levelUp; // Default for other levels
  }

  /// Calculate gems for achievement tier
  static int getAchievementReward(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return achievementBronze;
      case AchievementTier.silver:
        return achievementSilver;
      case AchievementTier.gold:
        return achievementGold;
      case AchievementTier.platinum:
        return achievementPlatinum;
    }
  }
}
