/// User profile model for personalized experience
/// This powers the "Duolingo for fishkeeping" learning journey
library;

import 'package:flutter/foundation.dart';
import 'lesson_progress.dart';
import 'tank.dart'; // For TankType enum
import 'leaderboard.dart'; // For League enum
import 'shop_item.dart'; // For InventoryItem

enum ExperienceLevel { beginner, intermediate, expert }

enum UserGoal {
  keepFishAlive, // Just want healthy fish
  beautifulDisplay, // Aesthetic focus
  breeding, // Want to breed fish
  competition, // Show quality
  relaxation, // Stress relief, zen
  learnTheScience, // Understand the science behind fishkeeping
  masterTheHobby, // Become a master aquarist
}

@immutable
class UserProfile {
  final String id;
  final String? name;
  final ExperienceLevel experienceLevel;
  final TankType primaryTankType;
  final List<UserGoal> goals;

  // Gamification
  final int totalXp;
  final int currentStreak; // Days in a row
  final int longestStreak;
  final DateTime? lastActivityDate;
  final List<String> achievements; // Achievement IDs
  final List<String>
  completedLessons; // Legacy - kept for backward compatibility
  final Map<String, LessonProgress>
  lessonProgress; // Spaced repetition tracking

  // Story Mode
  final List<String> completedStories; // Story IDs
  final Map<String, dynamic> storyProgress; // Story ID -> StoryProgress JSON

  // Placement Test
  final bool hasCompletedPlacementTest;
  final bool hasSkippedPlacementTest;
  final String? placementResultId; // Reference to PlacementResult
  final DateTime? placementTestDate;

  // Daily Goals
  final int dailyXpGoal; // Target XP per day (default 50)
  final Map<String, int> dailyXpHistory; // 'YYYY-MM-DD' -> XP earned that day

  // Streak Freeze (1 free skip per week)
  final bool hasStreakFreeze; // Currently has a freeze available
  final DateTime? streakFreezeUsedDate; // When was it last used
  final DateTime? streakFreezeGrantedDate; // When was it granted (weekly reset)

  // Hearts/Lives System (Duolingo-style)
  final int hearts; // Current hearts (0-5)
  final DateTime? lastHeartRefill; // Last time hearts auto-refilled

  // Leaderboard/Competition
  final League
  league; // Current competitive league (Bronze/Silver/Gold/Diamond)
  final int weeklyXP; // XP earned this week (Monday-Sunday)
  final DateTime?
  weekStartDate; // When current week started (for reset tracking)

  // Shop & Inventory
  final List<InventoryItem> inventory; // Purchased shop items

  // Preferences
  final bool dailyTipsEnabled;
  final bool streakRemindersEnabled;
  final bool hasSeenTutorial; // Whether user has seen first-launch tutorial
  final String? morningReminderTime; // "09:00" format
  final String? eveningReminderTime; // "19:00" format
  final String? nightReminderTime; // "23:00" format

  // Learning style preference: "quick", "deep", or "adaptive"
  final String? learningStylePreference;

  // Achievement tracking
  final List<String> weekendActivityDates; // 'YYYY-MM-DD' dates of weekend activity
  final List<String> fullHeartDates; // 'YYYY-MM-DD' dates where hearts were full at session end
  final int perfectScoreCount; // Number of 100% quiz scores (for Perfectionist achievement)

  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    this.name,
    this.experienceLevel = ExperienceLevel.beginner,
    this.primaryTankType = TankType.freshwater,
    this.goals = const [UserGoal.keepFishAlive],
    this.totalXp = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivityDate,
    this.achievements = const [],
    this.completedLessons = const [],
    this.lessonProgress = const {},
    this.completedStories = const [],
    this.storyProgress = const {},
    this.hasCompletedPlacementTest = false,
    this.hasSkippedPlacementTest = false,
    this.placementResultId,
    this.placementTestDate,
    this.dailyXpGoal = 50,
    this.dailyXpHistory = const {},
    this.hasStreakFreeze = true,
    this.streakFreezeUsedDate,
    this.streakFreezeGrantedDate,
    this.hearts = 5,
    this.lastHeartRefill,
    this.league = League.bronze,
    this.weeklyXP = 0,
    this.weekStartDate,
    this.inventory = const [],
    this.dailyTipsEnabled = true,
    this.streakRemindersEnabled = true,
    this.hasSeenTutorial = false,
    this.morningReminderTime = '09:00',
    this.eveningReminderTime = '19:00',
    this.nightReminderTime = '23:00',
    this.learningStylePreference,
    this.weekendActivityDates = const [],
    this.fullHeartDates = const [],
    this.perfectScoreCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // XP thresholds for levels
  static const Map<int, String> levels = {
    0: 'Beginner',
    100: 'Novice',
    300: 'Hobbyist',
    600: 'Aquarist',
    1000: 'Expert',
    1500: 'Master',
    2500: 'Guru',
    5000: 'Sage',
    10000: 'Grandmaster',
  };

  String get levelTitle {
    String title = 'Beginner';
    for (final entry in levels.entries) {
      if (totalXp >= entry.key) {
        title = entry.value;
      } else {
        break;
      }
    }
    return title;
  }

  int get currentLevel {
    int level = 0;
    for (final threshold in levels.keys) {
      if (totalXp >= threshold) {
        level++;
      } else {
        break;
      }
    }
    return level;
  }

  int get xpToNextLevel {
    final thresholds = levels.keys.toList();
    for (int i = 0; i < thresholds.length; i++) {
      if (totalXp < thresholds[i]) {
        return thresholds[i] - totalXp;
      }
    }
    return 0; // Max level
  }

  double get levelProgress {
    final thresholds = levels.keys.toList();
    for (int i = 0; i < thresholds.length; i++) {
      if (totalXp < thresholds[i]) {
        final prevThreshold = i > 0 ? thresholds[i - 1] : 0;
        final range = thresholds[i] - prevThreshold;
        final progress = totalXp - prevThreshold;
        return progress / range;
      }
    }
    return 1.0; // Max level
  }

  bool get hasStreak => currentStreak > 0;

  bool get isStreakActive {
    if (lastActivityDate == null) return false;
    final now = DateTime.now();
    final lastDate = DateTime(
      lastActivityDate!.year,
      lastActivityDate!.month,
      lastActivityDate!.day,
    );
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    return lastDate == today || lastDate == yesterday;
  }

  /// Check if streak freeze should be reset (weekly reset on Monday)
  bool get shouldResetStreakFreeze {
    if (streakFreezeGrantedDate == null) return true;

    final now = DateTime.now();
    final granted = streakFreezeGrantedDate!;

    // Normalize to midnight to avoid time-of-day issues
    final nowNormalized = DateTime(now.year, now.month, now.day);
    final grantedNormalized = DateTime(granted.year, granted.month, granted.day);

    // Get the Monday of current week (normalize first, then subtract)
    final currentMonday = nowNormalized.subtract(Duration(days: nowNormalized.weekday - 1));
    final grantedMonday = grantedNormalized.subtract(Duration(days: grantedNormalized.weekday - 1));

    // Different weeks = reset (compare normalized dates)
    return currentMonday.isAfter(grantedMonday);
  }

  /// Check if freeze was used this week
  bool get streakFreezeUsedThisWeek {
    if (streakFreezeUsedDate == null) return false;

    final now = DateTime.now();
    final used = streakFreezeUsedDate!;

    // Normalize to midnight to avoid time-of-day issues
    final nowNormalized = DateTime(now.year, now.month, now.day);
    final usedNormalized = DateTime(used.year, used.month, used.day);

    // Get the Monday of current week (normalize first, then subtract)
    final currentMonday = nowNormalized.subtract(Duration(days: nowNormalized.weekday - 1));
    final usedMonday = usedNormalized.subtract(Duration(days: usedNormalized.weekday - 1));

    // Same week = used this week (compare normalized dates)
    return currentMonday.year == usedMonday.year &&
        currentMonday.month == usedMonday.month &&
        currentMonday.day == usedMonday.day;
  }

  UserProfile copyWith({
    String? id,
    String? name,
    ExperienceLevel? experienceLevel,
    TankType? primaryTankType,
    List<UserGoal>? goals,
    int? totalXp,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    List<String>? achievements,
    List<String>? completedLessons,
    Map<String, LessonProgress>? lessonProgress,
    List<String>? completedStories,
    Map<String, dynamic>? storyProgress,
    bool? hasCompletedPlacementTest,
    bool? hasSkippedPlacementTest,
    String? placementResultId,
    DateTime? placementTestDate,
    int? dailyXpGoal,
    Map<String, int>? dailyXpHistory,
    bool? hasStreakFreeze,
    DateTime? streakFreezeUsedDate,
    DateTime? streakFreezeGrantedDate,
    int? hearts,
    DateTime? lastHeartRefill,
    League? league,
    int? weeklyXP,
    DateTime? weekStartDate,
    List<InventoryItem>? inventory,
    bool? dailyTipsEnabled,
    bool? streakRemindersEnabled,
    bool? hasSeenTutorial,
    String? morningReminderTime,
    String? eveningReminderTime,
    String? nightReminderTime,
    String? learningStylePreference,
    List<String>? weekendActivityDates,
    List<String>? fullHeartDates,
    int? perfectScoreCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      primaryTankType: primaryTankType ?? this.primaryTankType,
      goals: goals ?? this.goals,
      totalXp: totalXp ?? this.totalXp,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      achievements: achievements ?? this.achievements,
      completedLessons: completedLessons ?? this.completedLessons,
      lessonProgress: lessonProgress ?? this.lessonProgress,
      completedStories: completedStories ?? this.completedStories,
      storyProgress: storyProgress ?? this.storyProgress,
      hasCompletedPlacementTest:
          hasCompletedPlacementTest ?? this.hasCompletedPlacementTest,
      hasSkippedPlacementTest:
          hasSkippedPlacementTest ?? this.hasSkippedPlacementTest,
      placementResultId: placementResultId ?? this.placementResultId,
      placementTestDate: placementTestDate ?? this.placementTestDate,
      dailyXpGoal: dailyXpGoal ?? this.dailyXpGoal,
      dailyXpHistory: dailyXpHistory ?? this.dailyXpHistory,
      hasStreakFreeze: hasStreakFreeze ?? this.hasStreakFreeze,
      streakFreezeUsedDate: streakFreezeUsedDate ?? this.streakFreezeUsedDate,
      streakFreezeGrantedDate:
          streakFreezeGrantedDate ?? this.streakFreezeGrantedDate,
      hearts: hearts ?? this.hearts,
      lastHeartRefill: lastHeartRefill ?? this.lastHeartRefill,
      league: league ?? this.league,
      weeklyXP: weeklyXP ?? this.weeklyXP,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      inventory: inventory ?? this.inventory,
      dailyTipsEnabled: dailyTipsEnabled ?? this.dailyTipsEnabled,
      streakRemindersEnabled:
          streakRemindersEnabled ?? this.streakRemindersEnabled,
      hasSeenTutorial: hasSeenTutorial ?? this.hasSeenTutorial,
      morningReminderTime: morningReminderTime ?? this.morningReminderTime,
      eveningReminderTime: eveningReminderTime ?? this.eveningReminderTime,
      nightReminderTime: nightReminderTime ?? this.nightReminderTime,
      learningStylePreference: learningStylePreference ?? this.learningStylePreference,
      weekendActivityDates: weekendActivityDates ?? this.weekendActivityDates,
      fullHeartDates: fullHeartDates ?? this.fullHeartDates,
      perfectScoreCount: perfectScoreCount ?? this.perfectScoreCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'experienceLevel': experienceLevel.name,
    'primaryTankType': primaryTankType.name,
    'goals': goals.map((g) => g.name).toList(),
    'totalXp': totalXp,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lastActivityDate': lastActivityDate?.toIso8601String(),
    'achievements': achievements,
    'completedLessons': completedLessons,
    'lessonProgress': lessonProgress.map(
      (key, value) => MapEntry(key, value.toJson()),
    ),
    'completedStories': completedStories,
    'storyProgress': storyProgress,
    'hasCompletedPlacementTest': hasCompletedPlacementTest,
    'hasSkippedPlacementTest': hasSkippedPlacementTest,
    'placementResultId': placementResultId,
    'placementTestDate': placementTestDate?.toIso8601String(),
    'dailyXpGoal': dailyXpGoal,
    'dailyXpHistory': dailyXpHistory,
    'hasStreakFreeze': hasStreakFreeze,
    'streakFreezeUsedDate': streakFreezeUsedDate?.toIso8601String(),
    'streakFreezeGrantedDate': streakFreezeGrantedDate?.toIso8601String(),
    'hearts': hearts,
    'lastHeartRefill': lastHeartRefill?.toIso8601String(),
    'league': league.toJson(),
    'weeklyXP': weeklyXP,
    'weekStartDate': weekStartDate?.toIso8601String(),
    'inventory': inventory.map((item) => item.toJson()).toList(),
    'dailyTipsEnabled': dailyTipsEnabled,
    'streakRemindersEnabled': streakRemindersEnabled,
    'hasSeenTutorial': hasSeenTutorial,
    'morningReminderTime': morningReminderTime,
    'eveningReminderTime': eveningReminderTime,
    'nightReminderTime': nightReminderTime,
    'learningStylePreference': learningStylePreference,
    'weekendActivityDates': weekendActivityDates,
    'fullHeartDates': fullHeartDates,
    'perfectScoreCount': perfectScoreCount,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String?,
      experienceLevel: ExperienceLevel.values.firstWhere(
        (e) => e.name == json['experienceLevel'],
        orElse: () => ExperienceLevel.beginner,
      ),
      primaryTankType: TankType.values.firstWhere(
        (e) => e.name == json['primaryTankType'],
        orElse: () => TankType.freshwater,
      ),
      goals:
          (json['goals'] as List<dynamic>?)
              ?.map(
                (g) => UserGoal.values.firstWhere(
                  (e) => e.name == g,
                  orElse: () => UserGoal.keepFishAlive,
                ),
              )
              .toList() ??
          [UserGoal.keepFishAlive],
      totalXp: json['totalXp'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastActivityDate: json['lastActivityDate'] != null
          ? DateTime.parse(json['lastActivityDate'] as String)
          : null,
      achievements:
          (json['achievements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      completedLessons:
          (json['completedLessons'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      lessonProgress:
          (json['lessonProgress'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              LessonProgress.fromJson(value as Map<String, dynamic>),
            ),
          ) ??
          {},
      completedStories:
          (json['completedStories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      storyProgress: (json['storyProgress'] as Map<String, dynamic>?) ?? {},
      hasCompletedPlacementTest:
          json['hasCompletedPlacementTest'] as bool? ?? false,
      hasSkippedPlacementTest:
          json['hasSkippedPlacementTest'] as bool? ?? false,
      placementResultId: json['placementResultId'] as String?,
      placementTestDate: json['placementTestDate'] != null
          ? DateTime.parse(json['placementTestDate'] as String)
          : null,
      dailyXpGoal: json['dailyXpGoal'] as int? ?? 50,
      dailyXpHistory:
          (json['dailyXpHistory'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int),
          ) ??
          {},
      hasStreakFreeze: json['hasStreakFreeze'] as bool? ?? true,
      streakFreezeUsedDate: json['streakFreezeUsedDate'] != null
          ? DateTime.parse(json['streakFreezeUsedDate'] as String)
          : null,
      streakFreezeGrantedDate: json['streakFreezeGrantedDate'] != null
          ? DateTime.parse(json['streakFreezeGrantedDate'] as String)
          : null,
      hearts: json['hearts'] as int? ?? 5,
      lastHeartRefill: json['lastHeartRefill'] != null
          ? DateTime.parse(json['lastHeartRefill'] as String)
          : null,
      league: json['league'] != null
          ? League.fromJson(json['league'] as String)
          : League.bronze,
      weeklyXP: json['weeklyXP'] as int? ?? 0,
      weekStartDate: json['weekStartDate'] != null
          ? DateTime.parse(json['weekStartDate'] as String)
          : null,
      inventory:
          (json['inventory'] as List<dynamic>?)
              ?.map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dailyTipsEnabled: json['dailyTipsEnabled'] as bool? ?? true,
      streakRemindersEnabled: json['streakRemindersEnabled'] as bool? ?? true,
      hasSeenTutorial: json['hasSeenTutorial'] as bool? ?? false,
      morningReminderTime: json['morningReminderTime'] as String? ?? '09:00',
      eveningReminderTime: json['eveningReminderTime'] as String? ?? '19:00',
      nightReminderTime: json['nightReminderTime'] as String? ?? '23:00',
      learningStylePreference: json['learningStylePreference'] as String?,
      weekendActivityDates:
          (json['weekendActivityDates'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      fullHeartDates:
          (json['fullHeartDates'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      perfectScoreCount: json['perfectScoreCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

// Extension for display names
extension ExperienceLevelExt on ExperienceLevel {
  String get displayName {
    switch (this) {
      case ExperienceLevel.beginner:
        return 'New to fishkeeping';
      case ExperienceLevel.intermediate:
        return 'Some experience';
      case ExperienceLevel.expert:
        return 'Experienced aquarist';
    }
  }

  String get description {
    switch (this) {
      case ExperienceLevel.beginner:
        return "I'm just getting started or thinking about my first tank";
      case ExperienceLevel.intermediate:
        return "I've kept fish before and know the basics";
      case ExperienceLevel.expert:
        return "I'm comfortable with water chemistry and have multiple tanks";
    }
  }

  String get emoji {
    switch (this) {
      case ExperienceLevel.beginner:
        return '🐣';
      case ExperienceLevel.intermediate:
        return '🐟';
      case ExperienceLevel.expert:
        return '🦈';
    }
  }
}

extension TankTypeExt on TankType {
  String get displayName {
    switch (this) {
      case TankType.freshwater:
        return 'Freshwater';
      case TankType.marine:
        return 'Marine';
    }
  }

  String get description {
    switch (this) {
      case TankType.freshwater:
        return 'Tropical or coldwater fish';
      case TankType.marine:
        return 'Saltwater fish — arriving soon!';
    }
  }

  String get emoji {
    switch (this) {
      case TankType.freshwater:
        return '🐠';
      case TankType.marine:
        return '🐡';
    }
  }
}

extension UserGoalExt on UserGoal {
  String get displayName {
    switch (this) {
      case UserGoal.keepFishAlive:
        return 'Happy, healthy fish';
      case UserGoal.beautifulDisplay:
        return 'Beautiful display';
      case UserGoal.breeding:
        return 'Breeding fish';
      case UserGoal.competition:
        return 'Show quality';
      case UserGoal.relaxation:
        return 'Relaxation & zen';
      case UserGoal.learnTheScience:
        return 'Learn the science';
      case UserGoal.masterTheHobby:
        return 'Master the hobby';
    }
  }

  String get emoji {
    switch (this) {
      case UserGoal.keepFishAlive:
        return '❤️';
      case UserGoal.beautifulDisplay:
        return '✨';
      case UserGoal.breeding:
        return '🥚';
      case UserGoal.competition:
        return '🏆';
      case UserGoal.relaxation:
        return '🧘';
      case UserGoal.learnTheScience:
        return '🔬';
      case UserGoal.masterTheHobby:
        return '🎓';
    }
  }
}
