/// Achievement system models for gamification
/// Tracks user accomplishments across learning, streaks, XP, and engagement
library;


import 'package:flutter/foundation.dart';

/// Rarity levels for achievements
enum AchievementRarity {
  bronze,
  silver,
  gold,
  platinum;

  /// XP reward for unlocking this rarity
  int get xpReward {
    switch (this) {
      case AchievementRarity.bronze:
        return 50;
      case AchievementRarity.silver:
        return 100;
      case AchievementRarity.gold:
        return 150;
      case AchievementRarity.platinum:
        return 200;
    }
  }

  /// Display name
  String get displayName {
    switch (this) {
      case AchievementRarity.bronze:
        return 'Bronze';
      case AchievementRarity.silver:
        return 'Silver';
      case AchievementRarity.gold:
        return 'Gold';
      case AchievementRarity.platinum:
        return 'Platinum';
    }
  }

  /// Color for UI (hex string)
  String get colorHex {
    switch (this) {
      case AchievementRarity.bronze:
        return '#CD7F32';
      case AchievementRarity.silver:
        return '#C0C0C0';
      case AchievementRarity.gold:
        return '#FFD700';
      case AchievementRarity.platinum:
        return '#E5E4E2';
    }
  }
}

/// Categories for organizing achievements
enum AchievementCategory {
  learningProgress,
  streaks,
  xpMilestones,
  special,
  engagement;

  String get displayName {
    switch (this) {
      case AchievementCategory.learningProgress:
        return 'Learning Progress';
      case AchievementCategory.streaks:
        return 'Streaks';
      case AchievementCategory.xpMilestones:
        return 'XP Milestones';
      case AchievementCategory.special:
        return 'Special';
      case AchievementCategory.engagement:
        return 'Engagement';
    }
  }

  String get icon {
    switch (this) {
      case AchievementCategory.learningProgress:
        return '📚';
      case AchievementCategory.streaks:
        return '🔥';
      case AchievementCategory.xpMilestones:
        return '⭐';
      case AchievementCategory.special:
        return '✨';
      case AchievementCategory.engagement:
        return '💪';
    }
  }
}

/// Main achievement definition
@immutable
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon; // Emoji or icon name
  final AchievementRarity rarity;
  final AchievementCategory category;
  
  /// For incremental achievements (e.g., complete 10 lessons)
  /// null means it's a one-time achievement
  final int? targetCount;
  
  /// Hidden achievements (revealed when unlocked)
  final bool isHidden;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.category,
    this.targetCount,
    this.isHidden = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'rarity': rarity.name,
    'category': category.name,
    'targetCount': targetCount,
    'isHidden': isHidden,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.name == json['rarity'],
      ),
      category: AchievementCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      targetCount: json['targetCount'] as int?,
      isHidden: json['isHidden'] as bool? ?? false,
    );
  }
}

/// User's progress toward an achievement
@immutable
class AchievementProgress {
  final String achievementId;
  final int currentCount;
  final DateTime? unlockedAt;
  final bool isUnlocked;

  const AchievementProgress({
    required this.achievementId,
    this.currentCount = 0,
    this.unlockedAt,
    this.isUnlocked = false,
  });

  /// Progress as a percentage (0.0 to 1.0)
  double getProgress(int? targetCount) {
    if (targetCount == null) return isUnlocked ? 1.0 : 0.0;
    if (targetCount == 0) return 1.0;
    return (currentCount / targetCount).clamp(0.0, 1.0);
  }

  AchievementProgress copyWith({
    String? achievementId,
    int? currentCount,
    DateTime? unlockedAt,
    bool? isUnlocked,
  }) {
    return AchievementProgress(
      achievementId: achievementId ?? this.achievementId,
      currentCount: currentCount ?? this.currentCount,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  Map<String, dynamic> toJson() => {
    'achievementId': achievementId,
    'currentCount': currentCount,
    'unlockedAt': unlockedAt?.toIso8601String(),
    'isUnlocked': isUnlocked,
  };

  factory AchievementProgress.fromJson(Map<String, dynamic> json) {
    return AchievementProgress(
      achievementId: json['achievementId'] as String,
      currentCount: json['currentCount'] as int? ?? 0,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
    );
  }
}

/// Result of checking/unlocking an achievement
class AchievementUnlockResult {
  final Achievement achievement;
  final bool wasJustUnlocked;
  final int xpAwarded;
  final AchievementProgress progress;

  const AchievementUnlockResult({
    required this.achievement,
    required this.wasJustUnlocked,
    required this.xpAwarded,
    required this.progress,
  });
}
