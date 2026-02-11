/// Achievement definitions - Trophy case with 40+ achievements
/// Organized by category: Learning, Streaks, XP, Special, Engagement
library;

import '../models/achievements.dart';

/// All available achievements in the app
class AchievementDefinitions {
  // ========================================================================
  // LEARNING PROGRESS (10 achievements)
  // ========================================================================

  static const firstLesson = Achievement(
    id: 'first_lesson',
    name: 'First Steps',
    description: 'Complete your first lesson',
    icon: '🐣',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.learningProgress,
    targetCount: 1,
  );

  static const lessons10 = Achievement(
    id: 'lessons_10',
    name: 'Getting Started',
    description: 'Complete 10 lessons',
    icon: '🐠',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.learningProgress,
    targetCount: 10,
  );

  static const lessons50 = Achievement(
    id: 'lessons_50',
    name: 'Dedicated Learner',
    description: 'Complete 50 lessons',
    icon: '🐟',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.learningProgress,
    targetCount: 50,
  );

  static const lessons100 = Achievement(
    id: 'lessons_100',
    name: 'Century Club',
    description: 'Complete 100 lessons',
    icon: '🦈',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.learningProgress,
    targetCount: 100,
  );

  static const beginnerMaster = Achievement(
    id: 'beginner_master',
    name: 'Beginner Graduate',
    description: 'Complete all beginner lessons',
    icon: '🎓',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.learningProgress,
  );

  static const intermediateMaster = Achievement(
    id: 'intermediate_master',
    name: 'Intermediate Expert',
    description: 'Complete all intermediate lessons',
    icon: '🏅',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.learningProgress,
  );

  static const advancedMaster = Achievement(
    id: 'advanced_master',
    name: 'Advanced Scholar',
    description: 'Complete all advanced lessons',
    icon: '🏆',
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.learningProgress,
  );

  static const waterChemistryMaster = Achievement(
    id: 'water_chemistry_master',
    name: 'Chemistry Whiz',
    description: 'Master all water chemistry topics',
    icon: '⚗️',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.learningProgress,
  );

  static const plantsMaster = Achievement(
    id: 'plants_master',
    name: 'Green Thumb',
    description: 'Master all plant care topics',
    icon: '🌿',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.learningProgress,
  );

  static const livestockMaster = Achievement(
    id: 'livestock_master',
    name: 'Fish Whisperer',
    description: 'Master all livestock care topics',
    icon: '🐡',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.learningProgress,
  );

  // ========================================================================
  // STREAKS (8 achievements)
  // ========================================================================

  static const streak3 = Achievement(
    id: 'streak_3',
    name: 'Getting Consistent',
    description: 'Maintain a 3-day streak',
    icon: '🔥',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.streaks,
    targetCount: 3,
  );

  static const streak7 = Achievement(
    id: 'streak_7',
    name: 'Week Warrior',
    description: 'Maintain a 7-day streak',
    icon: '📅',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.streaks,
    targetCount: 7,
  );

  static const streak14 = Achievement(
    id: 'streak_14',
    name: 'Two Week Wonder',
    description: 'Maintain a 14-day streak',
    icon: '🌟',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.streaks,
    targetCount: 14,
  );

  static const streak30 = Achievement(
    id: 'streak_30',
    name: 'Monthly Marathon',
    description: 'Maintain a 30-day streak',
    icon: '💪',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.streaks,
    targetCount: 30,
  );

  static const streak60 = Achievement(
    id: 'streak_60',
    name: 'Unstoppable',
    description: 'Maintain a 60-day streak',
    icon: '⚡',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.streaks,
    targetCount: 60,
  );

  static const streak100 = Achievement(
    id: 'streak_100',
    name: 'Centurion',
    description: 'Maintain a 100-day streak',
    icon: '🏛️',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.streaks,
    targetCount: 100,
  );

  static const streak365 = Achievement(
    id: 'streak_365',
    name: 'Year of Learning',
    description: 'Maintain a 365-day streak',
    icon: '👑',
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.streaks,
    targetCount: 365,
  );

  static const weekendWarrior = Achievement(
    id: 'weekend_warrior',
    name: 'Weekend Warrior',
    description: 'Complete lessons on 10 consecutive weekends',
    icon: '🏖️',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.streaks,
    targetCount: 10,
  );

  // ========================================================================
  // XP MILESTONES (8 achievements)
  // ========================================================================

  static const xp100 = Achievement(
    id: 'xp_100',
    name: 'First Century',
    description: 'Earn 100 XP',
    icon: '⭐',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.xpMilestones,
    targetCount: 100,
  );

  static const xp500 = Achievement(
    id: 'xp_500',
    name: 'Rising Star',
    description: 'Earn 500 XP',
    icon: '🌠',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.xpMilestones,
    targetCount: 500,
  );

  static const xp1000 = Achievement(
    id: 'xp_1000',
    name: 'Thousand Club',
    description: 'Earn 1,000 XP',
    icon: '💫',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.xpMilestones,
    targetCount: 1000,
  );

  static const xp2500 = Achievement(
    id: 'xp_2500',
    name: 'Power Learner',
    description: 'Earn 2,500 XP',
    icon: '🌟',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.xpMilestones,
    targetCount: 2500,
  );

  static const xp5000 = Achievement(
    id: 'xp_5000',
    name: 'Elite Scholar',
    description: 'Earn 5,000 XP',
    icon: '✨',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.xpMilestones,
    targetCount: 5000,
  );

  static const xp10000 = Achievement(
    id: 'xp_10000',
    name: 'Master of Knowledge',
    description: 'Earn 10,000 XP',
    icon: '🎖️',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.xpMilestones,
    targetCount: 10000,
  );

  static const xp25000 = Achievement(
    id: 'xp_25000',
    name: 'Legendary Learner',
    description: 'Earn 25,000 XP',
    icon: '🏅',
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.xpMilestones,
    targetCount: 25000,
  );

  static const xp50000 = Achievement(
    id: 'xp_50000',
    name: 'Apex Aquarist',
    description: 'Earn 50,000 XP',
    icon: '👑',
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.xpMilestones,
    targetCount: 50000,
  );

  // ========================================================================
  // SPECIAL (10 achievements)
  // ========================================================================

  static const earlyBird = Achievement(
    id: 'early_bird',
    name: 'Early Bird',
    description: 'Complete a lesson before 8:00 AM',
    icon: '🌅',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.special,
  );

  static const nightOwl = Achievement(
    id: 'night_owl',
    name: 'Night Owl',
    description: 'Complete a lesson after 10:00 PM',
    icon: '🦉',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.special,
  );

  static const perfectionist = Achievement(
    id: 'perfectionist',
    name: 'Perfectionist',
    description: 'Earn 10 perfect scores (100%)',
    icon: '💯',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.special,
    targetCount: 10,
  );

  static const speedDemon = Achievement(
    id: 'speed_demon',
    name: 'Speed Demon',
    description: 'Complete a lesson in under 2 minutes',
    icon: '⚡',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.special,
  );

  static const marathonLearner = Achievement(
    id: 'marathon_learner',
    name: 'Marathon Learner',
    description: 'Complete 5 lessons in one day',
    icon: '🏃',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.special,
  );

  static const comeback = Achievement(
    id: 'comeback',
    name: 'The Comeback',
    description: 'Return after a 30-day break',
    icon: '🎯',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.special,
  );

  static const socialButterfly = Achievement(
    id: 'social_butterfly',
    name: 'Social Butterfly',
    description: 'Add 10 friends',
    icon: '🦋',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.special,
    targetCount: 10,
  );

  static const teachersPet = Achievement(
    id: 'teachers_pet',
    name: "Teacher's Pet",
    description: 'Complete all available lessons',
    icon: '🍎',
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.special,
  );

  static const completionist = Achievement(
    id: 'completionist',
    name: 'Completionist',
    description: 'Unlock all other achievements',
    icon: '🎊',
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.special,
    isHidden: true,
  );

  static const midnightScholar = Achievement(
    id: 'midnight_scholar',
    name: 'Midnight Scholar',
    description: 'Complete a lesson at exactly midnight',
    icon: '🌙',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.special,
  );

  // ========================================================================
  // ENGAGEMENT (6 achievements)
  // ========================================================================

  static const dailyTips10 = Achievement(
    id: 'daily_tips_10',
    name: 'Tip Explorer',
    description: 'Read 10 daily tips',
    icon: '💡',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.engagement,
    targetCount: 10,
  );

  static const dailyTips50 = Achievement(
    id: 'daily_tips_50',
    name: 'Tip Enthusiast',
    description: 'Read 50 daily tips',
    icon: '📖',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.engagement,
    targetCount: 50,
  );

  static const dailyTips100 = Achievement(
    id: 'daily_tips_100',
    name: 'Wisdom Seeker',
    description: 'Read 100 daily tips',
    icon: '📚',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.engagement,
    targetCount: 100,
  );

  static const practice10 = Achievement(
    id: 'practice_10',
    name: 'Practice Makes Progress',
    description: 'Complete 10 practice sessions',
    icon: '🎯',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.engagement,
    targetCount: 10,
  );

  static const practice50 = Achievement(
    id: 'practice_50',
    name: 'Practice Champion',
    description: 'Complete 50 practice sessions',
    icon: '🎪',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.engagement,
    targetCount: 50,
  );

  static const practice100 = Achievement(
    id: 'practice_100',
    name: 'Practice Master',
    description: 'Complete 100 practice sessions',
    icon: '🏆',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.engagement,
    targetCount: 100,
  );

  // ========================================================================
  // ADDITIONAL ACHIEVEMENTS (Bonus - bringing total to 47)
  // ========================================================================

  static const placement = Achievement(
    id: 'placement_complete',
    name: 'Assessed & Ready',
    description: 'Complete the placement test',
    icon: '📝',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.learningProgress,
  );

  static const shopVisitor = Achievement(
    id: 'shop_visitor',
    name: 'Window Shopper',
    description: 'Visit the shop 5 times',
    icon: '🛍️',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.engagement,
    targetCount: 5,
  );

  static const heartCollector = Achievement(
    id: 'heart_collector',
    name: 'Full Hearts',
    description: 'Maintain 5/5 hearts for 7 days',
    icon: '❤️',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.special,
  );

  static const leagueClimber = Achievement(
    id: 'league_climber',
    name: 'League Climber',
    description: 'Reach Gold league or higher',
    icon: '🥇',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.special,
  );

  static const dailyGoalStreak = Achievement(
    id: 'daily_goal_streak',
    name: 'Goal Getter',
    description: 'Meet your daily XP goal for 7 days straight',
    icon: '🎯',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.streaks,
    targetCount: 7,
  );

  // ========================================================================
  // SPACED REPETITION & REVIEW (8 achievements)
  // ========================================================================

  static const firstReview = Achievement(
    id: 'first_review',
    name: 'First Review',
    description: 'Complete your first review session',
    icon: '📝',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.engagement,
  );

  static const reviews10 = Achievement(
    id: 'reviews_10',
    name: 'Reviewer',
    description: 'Complete 10 review sessions',
    icon: '📚',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.engagement,
    targetCount: 10,
  );

  static const reviews50 = Achievement(
    id: 'reviews_50',
    name: 'Dedicated Reviewer',
    description: 'Complete 50 review sessions',
    icon: '📖',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.engagement,
    targetCount: 50,
  );

  static const reviews100 = Achievement(
    id: 'reviews_100',
    name: 'Review Master',
    description: 'Complete 100 review sessions',
    icon: '🎓',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.engagement,
    targetCount: 100,
  );

  static const reviewStreak3 = Achievement(
    id: 'review_streak_3',
    name: 'Consistent Reviewer',
    description: 'Review for 3 days in a row',
    icon: '🔥',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.streaks,
    targetCount: 3,
  );

  static const reviewStreak7 = Achievement(
    id: 'review_streak_7',
    name: 'Weekly Reviewer',
    description: 'Review for 7 days in a row',
    icon: '📅',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.streaks,
    targetCount: 7,
  );

  static const reviewStreak14 = Achievement(
    id: 'review_streak_14',
    name: 'Review Devotee',
    description: 'Review for 14 days in a row',
    icon: '💪',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.streaks,
    targetCount: 14,
  );

  static const reviewStreak30 = Achievement(
    id: 'review_streak_30',
    name: 'Memory Champion',
    description: 'Review for 30 days in a row',
    icon: '🏆',
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.streaks,
    targetCount: 30,
  );

  // ========================================================================
  // ALL ACHIEVEMENTS LIST
  // ========================================================================

  /// All achievements (55 total)
  static final List<Achievement> all = [
    // Learning Progress (11)
    firstLesson,
    lessons10,
    lessons50,
    lessons100,
    beginnerMaster,
    intermediateMaster,
    advancedMaster,
    waterChemistryMaster,
    plantsMaster,
    livestockMaster,
    placement,

    // Streaks (13)
    streak3,
    streak7,
    streak14,
    streak30,
    streak60,
    streak100,
    streak365,
    weekendWarrior,
    dailyGoalStreak,
    reviewStreak3,
    reviewStreak7,
    reviewStreak14,
    reviewStreak30,

    // XP Milestones (8)
    xp100,
    xp500,
    xp1000,
    xp2500,
    xp5000,
    xp10000,
    xp25000,
    xp50000,

    // Special (11)
    earlyBird,
    nightOwl,
    perfectionist,
    speedDemon,
    marathonLearner,
    comeback,
    socialButterfly,
    teachersPet,
    completionist,
    midnightScholar,
    heartCollector,
    leagueClimber,

    // Engagement (12)
    dailyTips10,
    dailyTips50,
    dailyTips100,
    practice10,
    practice50,
    practice100,
    shopVisitor,
    firstReview,
    reviews10,
    reviews50,
    reviews100,
  ];

  /// Get achievement by ID
  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get achievements by category
  static List<Achievement> getByCategory(AchievementCategory category) {
    return all.where((a) => a.category == category).toList();
  }

  /// Get achievements by rarity
  static List<Achievement> getByRarity(AchievementRarity rarity) {
    return all.where((a) => a.rarity == rarity).toList();
  }
}
