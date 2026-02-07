/// User profile model for personalized experience
/// This powers the "Duolingo for fishkeeping" learning journey

import 'package:flutter/foundation.dart';
import 'lesson_progress.dart';

enum ExperienceLevel {
  beginner,
  intermediate,
  expert,
}

enum TankType {
  freshwater,
  planted,
  saltwater,
  reef,
  brackish,
}

enum UserGoal {
  keepFishAlive,    // Just want healthy fish
  beautifulDisplay, // Aesthetic focus
  breeding,         // Want to breed fish
  competition,      // Show quality
  relaxation,       // Stress relief, zen
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
  final int currentStreak;        // Days in a row
  final int longestStreak;
  final DateTime? lastActivityDate;
  final List<String> achievements; // Achievement IDs
  final List<String> completedLessons; // Legacy - kept for backward compatibility
  final Map<String, LessonProgress> lessonProgress; // Spaced repetition tracking
  
  // Placement Test
  final bool hasCompletedPlacementTest;
  final String? placementResultId; // Reference to PlacementResult
  final DateTime? placementTestDate;
  
  // Daily Goals
  final int dailyXpGoal;          // Target XP per day (default 50)
  final Map<String, int> dailyXpHistory; // 'YYYY-MM-DD' -> XP earned that day
  
  // Streak Freeze (1 free skip per week)
  final bool hasStreakFreeze;     // Currently has a freeze available
  final DateTime? streakFreezeUsedDate; // When was it last used
  final DateTime? streakFreezeGrantedDate; // When was it granted (weekly reset)
  
  // Preferences
  final bool dailyTipsEnabled;
  final bool streakRemindersEnabled;
  final String? reminderTime;     // "09:00" format (deprecated - use morningReminderTime)
  final String? morningReminderTime;  // "09:00" format
  final String? eveningReminderTime;  // "19:00" format
  final String? nightReminderTime;    // "23:00" format
  
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
    this.hasCompletedPlacementTest = false,
    this.placementResultId,
    this.placementTestDate,
    this.dailyXpGoal = 50,
    this.dailyXpHistory = const {},
    this.hasStreakFreeze = true,
    this.streakFreezeUsedDate,
    this.streakFreezeGrantedDate,
    this.dailyTipsEnabled = true,
    this.streakRemindersEnabled = true,
    this.reminderTime,
    this.morningReminderTime = '09:00',
    this.eveningReminderTime = '19:00',
    this.nightReminderTime = '23:00',
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
    
    // Get the Monday of current week
    final currentMonday = now.subtract(Duration(days: now.weekday - 1));
    final grantedMonday = granted.subtract(Duration(days: granted.weekday - 1));
    
    // Different weeks = reset
    return currentMonday.isAfter(grantedMonday) || 
           currentMonday.day != grantedMonday.day;
  }
  
  /// Check if freeze was used this week
  bool get streakFreezeUsedThisWeek {
    if (streakFreezeUsedDate == null) return false;
    
    final now = DateTime.now();
    final used = streakFreezeUsedDate!;
    
    // Get the Monday of current week
    final currentMonday = now.subtract(Duration(days: now.weekday - 1));
    final usedMonday = used.subtract(Duration(days: used.weekday - 1));
    
    // Same week = used this week
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
    bool? hasCompletedPlacementTest,
    String? placementResultId,
    DateTime? placementTestDate,
    int? dailyXpGoal,
    Map<String, int>? dailyXpHistory,
    bool? hasStreakFreeze,
    DateTime? streakFreezeUsedDate,
    DateTime? streakFreezeGrantedDate,
    bool? dailyTipsEnabled,
    bool? streakRemindersEnabled,
    String? reminderTime,
    String? morningReminderTime,
    String? eveningReminderTime,
    String? nightReminderTime,
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
      hasCompletedPlacementTest: hasCompletedPlacementTest ?? this.hasCompletedPlacementTest,
      placementResultId: placementResultId ?? this.placementResultId,
      placementTestDate: placementTestDate ?? this.placementTestDate,
      dailyXpGoal: dailyXpGoal ?? this.dailyXpGoal,
      dailyXpHistory: dailyXpHistory ?? this.dailyXpHistory,
      hasStreakFreeze: hasStreakFreeze ?? this.hasStreakFreeze,
      streakFreezeUsedDate: streakFreezeUsedDate ?? this.streakFreezeUsedDate,
      streakFreezeGrantedDate: streakFreezeGrantedDate ?? this.streakFreezeGrantedDate,
      dailyTipsEnabled: dailyTipsEnabled ?? this.dailyTipsEnabled,
      streakRemindersEnabled: streakRemindersEnabled ?? this.streakRemindersEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      morningReminderTime: morningReminderTime ?? this.morningReminderTime,
      eveningReminderTime: eveningReminderTime ?? this.eveningReminderTime,
      nightReminderTime: nightReminderTime ?? this.nightReminderTime,
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
    'lessonProgress': lessonProgress.map((key, value) => MapEntry(key, value.toJson())),
    'hasCompletedPlacementTest': hasCompletedPlacementTest,
    'placementResultId': placementResultId,
    'placementTestDate': placementTestDate?.toIso8601String(),
    'dailyXpGoal': dailyXpGoal,
    'dailyXpHistory': dailyXpHistory,
    'hasStreakFreeze': hasStreakFreeze,
    'streakFreezeUsedDate': streakFreezeUsedDate?.toIso8601String(),
    'streakFreezeGrantedDate': streakFreezeGrantedDate?.toIso8601String(),
    'dailyTipsEnabled': dailyTipsEnabled,
    'streakRemindersEnabled': streakRemindersEnabled,
    'reminderTime': reminderTime,
    'morningReminderTime': morningReminderTime,
    'eveningReminderTime': eveningReminderTime,
    'nightReminderTime': nightReminderTime,
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
      goals: (json['goals'] as List<dynamic>?)
          ?.map((g) => UserGoal.values.firstWhere(
                (e) => e.name == g,
                orElse: () => UserGoal.keepFishAlive,
              ))
          .toList() ?? [UserGoal.keepFishAlive],
      totalXp: json['totalXp'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastActivityDate: json['lastActivityDate'] != null
          ? DateTime.parse(json['lastActivityDate'] as String)
          : null,
      achievements: (json['achievements'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      completedLessons: (json['completedLessons'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      lessonProgress: (json['lessonProgress'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, LessonProgress.fromJson(value as Map<String, dynamic>)))
          ?? {},
      hasCompletedPlacementTest: json['hasCompletedPlacementTest'] as bool? ?? false,
      placementResultId: json['placementResultId'] as String?,
      placementTestDate: json['placementTestDate'] != null
          ? DateTime.parse(json['placementTestDate'] as String)
          : null,
      dailyXpGoal: json['dailyXpGoal'] as int? ?? 50,
      dailyXpHistory: (json['dailyXpHistory'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as int))
          ?? {},
      hasStreakFreeze: json['hasStreakFreeze'] as bool? ?? true,
      streakFreezeUsedDate: json['streakFreezeUsedDate'] != null
          ? DateTime.parse(json['streakFreezeUsedDate'] as String)
          : null,
      streakFreezeGrantedDate: json['streakFreezeGrantedDate'] != null
          ? DateTime.parse(json['streakFreezeGrantedDate'] as String)
          : null,
      dailyTipsEnabled: json['dailyTipsEnabled'] as bool? ?? true,
      streakRemindersEnabled: json['streakRemindersEnabled'] as bool? ?? true,
      reminderTime: json['reminderTime'] as String?,
      morningReminderTime: json['morningReminderTime'] as String? ?? '09:00',
      eveningReminderTime: json['eveningReminderTime'] as String? ?? '19:00',
      nightReminderTime: json['nightReminderTime'] as String? ?? '23:00',
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
      case TankType.planted:
        return 'Planted';
      case TankType.saltwater:
        return 'Saltwater';
      case TankType.reef:
        return 'Reef';
      case TankType.brackish:
        return 'Brackish';
    }
  }

  String get description {
    switch (this) {
      case TankType.freshwater:
        return 'Tropical or coldwater fish without live plants';
      case TankType.planted:
        return 'Freshwater with live aquatic plants';
      case TankType.saltwater:
        return 'Marine fish only';
      case TankType.reef:
        return 'Saltwater with corals and invertebrates';
      case TankType.brackish:
        return 'Mixture of fresh and saltwater';
    }
  }

  String get emoji {
    switch (this) {
      case TankType.freshwater:
        return '🐠';
      case TankType.planted:
        return '🌿';
      case TankType.saltwater:
        return '🐡';
      case TankType.reef:
        return '🪸';
      case TankType.brackish:
        return '🦐';
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
    }
  }
}
