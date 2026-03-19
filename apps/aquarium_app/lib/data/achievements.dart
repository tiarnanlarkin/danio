/// Achievement definitions - Trophy case with 40+ achievements
/// Organized by category: Learning, Streaks, XP, Special, Engagement
library;

import 'package:flutter/foundation.dart';
import '../models/achievements.dart';

/// All available achievements in the app
class AchievementDefinitions {
  // ========================================================================
  // LEARNING PROGRESS (10 achievements)
  // ========================================================================

  static const firstLesson = Achievement(
    id: 'first_lesson',
    name: 'First Steps',
    description:
        'You completed your very first lesson! Every expert started right here.',
    icon: '🐣',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.learningProgress,
    targetCount: 1,
  );

  static const lessons10 = Achievement(
    id: 'lessons_10',
    name: 'Getting Started',
    description:
        'Ten lessons down! You are building a real foundation of fish knowledge.',
    icon: '🐠',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.learningProgress,
    targetCount: 10,
  );

  static const lessons50 = Achievement(
    id: 'lessons_50',
    name: 'Dedicated Learner',
    description:
        'Fifty lessons conquered! Your fish are lucky to have such a dedicated keeper.',
    icon: '🐟',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.learningProgress,
    targetCount: 50,
  );

  static const lessons100 = Achievement(
    id: 'lessons_100',
    name: 'Century Club',
    description:
        'One hundred lessons! You know more about fishkeeping than most people ever will.',
    icon: '🦈',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.learningProgress,
    targetCount: 100,
  );

  static const beginnerMaster = Achievement(
    id: 'beginner_master',
    name: 'Beginner Graduate',
    description: 'You have mastered every beginner lesson. Time to level up!',
    icon: '🎓',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.learningProgress,
    isHidden: true,
  );

  static const intermediateMaster = Achievement(
    id: 'intermediate_master',
    name: 'Intermediate Expert',
    description:
        'All intermediate lessons complete! You are becoming a serious aquarist.',
    icon: '🏅',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.learningProgress,
    isHidden: true,
  );

  static const advancedMaster = Achievement(
    id: 'advanced_master',
    name: 'Advanced Scholar',
    description:
        'You have conquered every advanced topic. You are truly a scholar of the aquatic world.',
    icon: '🏆',
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.learningProgress,
    isHidden: true,
  );

  static const waterChemistryMaster = Achievement(
    id: 'water_chemistry_master',
    name: 'Chemistry Whiz',
    description:
        'Every water chemistry topic mastered! pH, GH, KH — you speak fluent water.',
    icon: '⚗️',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.learningProgress,
    isHidden: true,
  );

  static const plantsMaster = Achievement(
    id: 'plants_master',
    name: 'Green Thumb',
    description:
        'All plant topics complete! Your underwater garden skills are blooming.',
    icon: '🌿',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.learningProgress,
    isHidden: true,
  );

  static const livestockMaster = Achievement(
    id: 'livestock_master',
    name: 'Fish Whisperer',
    description:
        'Every fish care topic conquered! Your aquatic residents are in expert hands.',
    icon: '🐡',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.learningProgress,
    isHidden: true,
  );

  // ========================================================================
  // STREAKS (8 achievements)
  // ========================================================================

  static const streak3 = Achievement(
    id: 'streak_3',
    name: 'Getting Consistent',
    description: 'Three days running! You are building a great habit.',
    icon: '🔥',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.streaks,
    targetCount: 3,
  );

  static const streak7 = Achievement(
    id: 'streak_7',
    name: 'Week Warrior',
    description:
        'A full week of learning! Consistency is the secret to fishkeeping mastery.',
    icon: '📅',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.streaks,
    targetCount: 7,
  );

  static const streak14 = Achievement(
    id: 'streak_14',
    name: 'Two Week Wonder',
    description:
        'Two solid weeks! They say it takes 14 days to form a habit. You are hooked!',
    icon: '🌟',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.streaks,
    targetCount: 14,
  );

  static const streak30 = Achievement(
    id: 'streak_30',
    name: 'Monthly Marathon',
    description:
        'Thirty days straight! Your dedication is truly impressive. Keep that flame alive!',
    icon: '💪',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.streaks,
    targetCount: 30,
  );

  static const streak60 = Achievement(
    id: 'streak_60',
    name: 'Unstoppable',
    description: 'Sixty days and counting! Nothing can stop you now.',
    icon: '⚡',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.streaks,
    targetCount: 60,
  );

  static const streak100 = Achievement(
    id: 'streak_100',
    name: 'Centurion',
    description:
        'One hundred days of dedication! You are an inspiration to fishkeepers everywhere.',
    icon: '🏛️',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.streaks,
    targetCount: 100,
  );

  static const streak365 = Achievement(
    id: 'streak_365',
    name: 'Year of Learning',
    description:
        'An entire year of daily learning. You are a living legend of the fishkeeping world!',
    icon: '👑',
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.streaks,
    targetCount: 365,
  );

  static const weekendWarrior = Achievement(
    id: 'weekend_warrior',
    name: 'Weekend Warrior',
    description:
        'Ten weekends in a row! Who needs a lie-in when there are fish facts to learn?',
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
    description:
        'Your first century of XP! The journey of a thousand points begins with one lesson.',
    icon: '⭐',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.xpMilestones,
    targetCount: 100,
  );

  static const xp500 = Achievement(
    id: 'xp_500',
    name: 'Rising Star',
    description: 'Five hundred XP! You are rising through the ranks fast.',
    icon: '🌠',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.xpMilestones,
    targetCount: 500,
  );

  static const xp1000 = Achievement(
    id: 'xp_1000',
    name: 'Thousand Club',
    description:
        'A thousand XP earned! You are officially in the big leagues now.',
    icon: '💫',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.xpMilestones,
    targetCount: 1000,
  );

  static const xp2500 = Achievement(
    id: 'xp_2500',
    name: 'Power Learner',
    description:
        'Two and a half thousand XP! Your knowledge grows deeper with every lesson.',
    icon: '🌟',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.xpMilestones,
    targetCount: 2500,
  );

  static const xp5000 = Achievement(
    id: 'xp_5000',
    name: 'Elite Scholar',
    description:
        'Five thousand XP! You have earned your place among the elite.',
    icon: '✨',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.xpMilestones,
    targetCount: 5000,
  );

  static const xp10000 = Achievement(
    id: 'xp_10000',
    name: 'Master of Knowledge',
    description:
        'Ten thousand XP! Your mastery of aquarium knowledge is truly remarkable.',
    icon: '🎖️',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.xpMilestones,
    targetCount: 10000,
  );

  static const xp25000 = Achievement(
    id: 'xp_25000',
    name: 'Legendary Learner',
    description:
        'Twenty-five thousand XP! Legends are written about dedication like yours.',
    icon: '🏅',
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.xpMilestones,
    targetCount: 25000,
  );

  static const xp50000 = Achievement(
    id: 'xp_50000',
    name: 'Apex Aquarist',
    description:
        'Fifty thousand XP! You have reached the absolute pinnacle. Take a bow!',
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
    description:
        'Up with the sunrise! You completed a lesson before 8 AM. Early fish gets the worm.',
    icon: '🌅',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.special,
  );

  static const nightOwl = Achievement(
    id: 'night_owl',
    name: 'Night Owl',
    description:
        'Burning the midnight oil! Late-night learning hits different.',
    icon: '🦉',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.special,
  );

  static const perfectionist = Achievement(
    id: 'perfectionist',
    name: 'Perfectionist',
    description:
        'Ten perfect quizzes! Your attention to detail would make any fish proud.',
    icon: '💯',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.special,
    targetCount: 10,
  );

  static const speedDemon = Achievement(
    id: 'speed_demon',
    name: 'Speed Demon',
    description:
        'Lightning fast! You blazed through a lesson in under 2 minutes.',
    icon: '⚡',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.special,
  );

  static const marathonLearner = Achievement(
    id: 'marathon_learner',
    name: 'Marathon Learner',
    description:
        'Five lessons in a single day! Your thirst for knowledge is unquenchable.',
    icon: '🏃',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.special,
  );

  static const comeback = Achievement(
    id: 'comeback',
    name: 'The Comeback',
    description:
        'Welcome back! Your fish missed you. What matters is you came back.',
    icon: '🎯',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.special,
  );

  static const socialButterfly = Achievement(
    id: 'social_butterfly',
    name: 'Social Butterfly',
    description: 'Ten friends and counting! Fishkeeping is better together.',
    icon: '🦋',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.special,
    targetCount: 10,
    isHidden: true, // Hidden: friends feature behind CA-002
  );

  static const teachersPet = Achievement(
    id: 'teachers_pet',
    name: "Teacher's Pet",
    description:
        'Every lesson in the app, completed! You have truly earned this one.',
    icon: '🍎',
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.special,
  );

  static const completionist = Achievement(
    id: 'completionist',
    name: 'Completionist',
    description:
        'Every single achievement unlocked. You are the ultimate Danio champion!',
    icon: '🎊',
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.special,
    isHidden: true,
  );

  static const midnightScholar = Achievement(
    id: 'midnight_scholar',
    name: 'Midnight Scholar',
    description:
        'A lesson at the stroke of midnight! True dedication knows no bedtime.',
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
    description:
        'Ten tips absorbed! Each one makes you a slightly better fishkeeper.',
    icon: '💡',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.engagement,
    targetCount: 10,
  );

  static const dailyTips50 = Achievement(
    id: 'daily_tips_50',
    name: 'Tip Enthusiast',
    description: 'Fifty tips! You are a sponge for knowledge (pun intended).',
    icon: '📖',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.engagement,
    targetCount: 50,
  );

  static const dailyTips100 = Achievement(
    id: 'daily_tips_100',
    name: 'Wisdom Seeker',
    description:
        'One hundred tips read! You are now the person your friends ask for fish advice.',
    icon: '📚',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.engagement,
    targetCount: 100,
  );

  static const practice10 = Achievement(
    id: 'practice_10',
    name: 'Practice Makes Progress',
    description:
        'Ten practice sessions done! Repetition is how knowledge sticks.',
    icon: '🎯',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.engagement,
    targetCount: 10,
  );

  static const practice50 = Achievement(
    id: 'practice_50',
    name: 'Practice Champion',
    description:
        'Fifty practice rounds! Your knowledge retention must be incredible.',
    icon: '🎪',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.engagement,
    targetCount: 50,
  );

  static const practice100 = Achievement(
    id: 'practice_100',
    name: 'Practice Master',
    description:
        'One hundred practice sessions! You have truly mastered the art of review.',
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
    description:
        'You completed your knowledge quiz! Now we know exactly where your journey should begin.',
    icon: '📝',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.learningProgress,
  );

  static const shopVisitor = Achievement(
    id: 'shop_visitor',
    name: 'Window Shopper',
    description:
        'Five visits to the shop! Just browsing, or planning something special?',
    icon: '🛍️',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.engagement,
    targetCount: 5,
  );

  static const heartCollector = Achievement(
    id: 'heart_collector',
    name: 'Full Hearts',
    description: 'A full week with all hearts intact! Flawless performance.',
    icon: '❤️',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.special,
  );

  static const leagueClimber = Achievement(
    id: 'league_climber',
    name: 'League Climber',
    description:
        'You climbed to Gold league! Your competitive spirit shines bright.',
    icon: '🥇',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.special,
  );

  static const dailyGoalStreak = Achievement(
    id: 'daily_goal_streak',
    name: 'Goal Getter',
    description:
        'Seven days of hitting your goal! That is what commitment looks like.',
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
    description:
        'Your first review session complete! The secret to remembering things? Coming back to them. You\'re already doing it! 🧠',
    icon: '📝',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.engagement,
  );

  static const reviews10 = Achievement(
    id: 'reviews_10',
    name: 'Reviewer',
    description:
        'Ten reviews completed! Your long-term memory is getting a serious workout.',
    icon: '📚',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.engagement,
    targetCount: 10,
  );

  static const reviews50 = Achievement(
    id: 'reviews_50',
    name: 'Dedicated Reviewer',
    description:
        'Fifty reviews! The knowledge you have built is rock-solid by now.',
    icon: '📖',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.engagement,
    targetCount: 50,
  );

  static const reviews100 = Achievement(
    id: 'reviews_100',
    name: 'Review Master',
    description:
        'One hundred reviews! Your recall is sharper than a swordtail fin.',
    icon: '🎓',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.engagement,
    targetCount: 100,
  );

  static const reviewStreak3 = Achievement(
    id: 'review_streak_3',
    name: 'Consistent Reviewer',
    description: 'Three days of reviews! Building the habit one day at a time.',
    icon: '🔥',
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.streaks,
    targetCount: 3,
  );

  static const reviewStreak7 = Achievement(
    id: 'review_streak_7',
    name: 'Weekly Reviewer',
    description:
        'A full week of daily reviews! Your memory muscles are getting strong.',
    icon: '📅',
    rarity: AchievementRarity.silver,
    category: AchievementCategory.streaks,
    targetCount: 7,
  );

  static const reviewStreak14 = Achievement(
    id: 'review_streak_14',
    name: 'Review Devotee',
    description:
        'Two weeks of daily reviews! Your dedication to retention is admirable.',
    icon: '💪',
    rarity: AchievementRarity.gold,
    category: AchievementCategory.streaks,
    targetCount: 14,
  );

  static const reviewStreak30 = Achievement(
    id: 'review_streak_30',
    name: 'Memory Champion',
    description:
        'Thirty days of reviews! You have the memory of an elephant — just, you know, a fishy one.',
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
    } catch (e) {
      debugPrint('Achievement lookup failed for id "$id": $e');
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
