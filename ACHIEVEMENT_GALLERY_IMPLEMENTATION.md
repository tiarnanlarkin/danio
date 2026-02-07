# Achievement Gallery Implementation Guide
**Aquarium App - Trophy Case Feature**

## 📋 Overview
This document provides a complete implementation guide for the Achievement Gallery - a visual trophy case showing all achievements (locked/unlocked) with progress tracking, categories, and beautiful UI.

---

## 🏗️ Architecture

### 1. Extended Achievement Model
**File:** `lib/models/achievement.dart` (new file)

```dart
import 'package:flutter/foundation.dart';

/// Achievement categories for organization
enum AchievementCategory {
  learning,    // Complete lessons, paths, quizzes
  streaks,     // Daily activity consistency  
  social,      // Friends, sharing, community (future)
  milestones,  // XP levels, totals
  tracking,    // Water tests, logs, data
  exploration, // Using features, discovering content
  hidden,      // Secret achievements (easter eggs)
}

/// Achievement rarity/difficulty tiers
enum AchievementRarity {
  common,      // Easy to get (10-20% unlock rate)
  rare,        // Moderate effort (5-10% unlock rate)
  epic,        // Significant commitment (1-5% unlock rate)
  legendary,   // Very rare/hard (< 1% unlock rate)
}

/// Achievement definition with progress tracking support
@immutable
class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final AchievementCategory category;
  final AchievementRarity rarity;
  
  // Progress tracking for incremental achievements
  final int? progressMax;  // null = one-time achievement
  final bool isHidden;     // Show ??? until unlocked
  
  // Unlock criteria description (shown for locked achievements)
  final String unlockCriteria;
  
  // Rewards
  final int xpReward;
  
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.category,
    this.rarity = AchievementRarity.common,
    this.progressMax,
    this.isHidden = false,
    required this.unlockCriteria,
    required this.xpReward,
  });
  
  bool get isIncremental => progressMax != null;
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'emoji': emoji,
    'category': category.name,
    'rarity': rarity.name,
    'progressMax': progressMax,
    'isHidden': isHidden,
    'unlockCriteria': unlockCriteria,
    'xpReward': xpReward,
  };
  
  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    emoji: json['emoji'] as String,
    category: AchievementCategory.values.firstWhere(
      (e) => e.name == json['category'],
    ),
    rarity: AchievementRarity.values.firstWhere(
      (e) => e.name == json['rarity'],
      orElse: () => AchievementRarity.common,
    ),
    progressMax: json['progressMax'] as int?,
    isHidden: json['isHidden'] as bool? ?? false,
    unlockCriteria: json['unlockCriteria'] as String,
    xpReward: json['xpReward'] as int,
  );
}

/// User's progress toward a specific achievement
@immutable
class AchievementProgress {
  final String achievementId;
  final int currentProgress;
  final DateTime? unlockedAt;
  final bool isUnlocked;
  
  const AchievementProgress({
    required this.achievementId,
    this.currentProgress = 0,
    this.unlockedAt,
    this.isUnlocked = false,
  });
  
  AchievementProgress copyWith({
    int? currentProgress,
    DateTime? unlockedAt,
    bool? isUnlocked,
  }) => AchievementProgress(
    achievementId: achievementId,
    currentProgress: currentProgress ?? this.currentProgress,
    unlockedAt: unlockedAt ?? this.unlockedAt,
    isUnlocked: isUnlocked ?? this.isUnlocked,
  );
  
  Map<String, dynamic> toJson() => {
    'achievementId': achievementId,
    'currentProgress': currentProgress,
    'unlockedAt': unlockedAt?.toIso8601String(),
    'isUnlocked': isUnlocked,
  };
  
  factory AchievementProgress.fromJson(Map<String, dynamic> json) =>
    AchievementProgress(
      achievementId: json['achievementId'] as String,
      currentProgress: json['currentProgress'] as int? ?? 0,
      unlockedAt: json['unlockedAt'] != null
        ? DateTime.parse(json['unlockedAt'] as String)
        : null,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
    );
}

/// Extension methods for enums
extension AchievementCategoryExt on AchievementCategory {
  String get displayName {
    switch (this) {
      case AchievementCategory.learning:
        return 'Learning';
      case AchievementCategory.streaks:
        return 'Streaks';
      case AchievementCategory.social:
        return 'Social';
      case AchievementCategory.milestones:
        return 'Milestones';
      case AchievementCategory.tracking:
        return 'Tracking';
      case AchievementCategory.exploration:
        return 'Exploration';
      case AchievementCategory.hidden:
        return 'Hidden';
    }
  }
  
  String get emoji {
    switch (this) {
      case AchievementCategory.learning:
        return '📚';
      case AchievementCategory.streaks:
        return '🔥';
      case AchievementCategory.social:
        return '👥';
      case AchievementCategory.milestones:
        return '🏆';
      case AchievementCategory.tracking:
        return '📊';
      case AchievementCategory.exploration:
        return '🗺️';
      case AchievementCategory.hidden:
        return '❓';
    }
  }
}

extension AchievementRarityExt on AchievementRarity {
  String get displayName {
    switch (this) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.epic:
        return 'Epic';
      case AchievementRarity.legendary:
        return 'Legendary';
    }
  }
  
  Color get color {
    switch (this) {
      case AchievementRarity.common:
        return const Color(0xFF9E9E9E); // Gray
      case AchievementRarity.rare:
        return const Color(0xFF2196F3); // Blue
      case AchievementRarity.epic:
        return const Color(0xFF9C27B0); // Purple
      case AchievementRarity.legendary:
        return const Color(0xFFFFA726); // Orange/Gold
    }
  }
  
  int get baseXp {
    switch (this) {
      case AchievementRarity.common:
        return 25;
      case AchievementRarity.rare:
        return 50;
      case AchievementRarity.epic:
        return 100;
      case AchievementRarity.legendary:
        return 250;
    }
  }
}
```

---

## 🏆 Achievement Catalog (40 Achievements)

**File:** `lib/data/achievement_catalog.dart`

```dart
import '../models/achievement.dart';

/// Complete catalog of all achievements in the app
class AchievementCatalog {
  
  // ==========================================
  // LEARNING ACHIEVEMENTS (10)
  // ==========================================
  
  static const firstLesson = Achievement(
    id: 'first_lesson',
    title: 'First Steps',
    description: 'Complete your first lesson',
    emoji: '📖',
    category: AchievementCategory.learning,
    rarity: AchievementRarity.common,
    unlockCriteria: 'Complete any lesson',
    xpReward: 25,
  );
  
  static const lessonsCompleted10 = Achievement(
    id: 'lessons_10',
    title: 'Eager Learner',
    description: 'Complete 10 lessons',
    emoji: '📚',
    category: AchievementCategory.learning,
    rarity: AchievementRarity.common,
    progressMax: 10,
    unlockCriteria: 'Complete 10 lessons',
    xpReward: 50,
  );
  
  static const lessonsCompleted25 = Achievement(
    id: 'lessons_25',
    title: 'Knowledge Seeker',
    description: 'Complete 25 lessons',
    emoji: '🎓',
    category: AchievementCategory.learning,
    rarity: AchievementRarity.rare,
    progressMax: 25,
    unlockCriteria: 'Complete 25 lessons',
    xpReward: 100,
  );
  
  static const allLessons = Achievement(
    id: 'all_lessons',
    title: 'Master Scholar',
    description: 'Complete every single lesson',
    emoji: '🏅',
    category: AchievementCategory.learning,
    rarity: AchievementRarity.legendary,
    unlockCriteria: 'Complete all lessons in all paths',
    xpReward: 250,
  );
  
  static const nitrogenCyclePath = Achievement(
    id: 'nitrogen_cycle_path',
    title: 'Cycle Master',
    description: 'Complete the Nitrogen Cycle path',
    emoji: '🔄',
    category: AchievementCategory.learning,
    rarity: AchievementRarity.common,
    unlockCriteria: 'Complete all lessons in Nitrogen Cycle path',
    xpReward: 50,
  );
  
  static const allPaths = Achievement(
    id: 'all_paths',
    title: 'Path Conqueror',
    description: 'Complete all learning paths',
    emoji: '🗺️',
    category: AchievementCategory.learning,
    rarity: AchievementRarity.epic,
    unlockCriteria: 'Complete all learning paths',
    xpReward: 150,
  );
  
  static const perfectQuiz = Achievement(
    id: 'perfect_quiz',
    title: 'Quiz Ace',
    description: 'Get 100% on any quiz',
    emoji: '🎯',
    category: AchievementCategory.learning,
    rarity: AchievementRarity.rare,
    unlockCriteria: 'Score 100% on any quiz',
    xpReward: 50,
  );
  
  static const perfectQuizStreak5 = Achievement(
    id: 'perfect_quiz_5',
    title: 'Quiz Master',
    description: 'Get 100% on 5 quizzes',
    emoji: '🏆',
    category: AchievementCategory.learning,
    rarity: AchievementRarity.epic,
    progressMax: 5,
    unlockCriteria: 'Score 100% on 5 different quizzes',
    xpReward: 100,
  );
  
  static const placementTest = Achievement(
    id: 'placement_test',
    title: 'Assessed',
    description: 'Complete the placement test',
    emoji: '📋',
    category: AchievementCategory.learning,
    rarity: AchievementRarity.common,
    unlockCriteria: 'Complete the placement test',
    xpReward: 25,
  );
  
  static const speedLearner = Achievement(
    id: 'speed_learner',
    title: 'Speed Learner',
    description: 'Complete 5 lessons in one day',
    emoji: '⚡',
    category: AchievementCategory.learning,
    rarity: AchievementRarity.rare,
    unlockCriteria: 'Complete 5 lessons in a single day',
    xpReward: 75,
  );
  
  // ==========================================
  // STREAK ACHIEVEMENTS (8)
  // ==========================================
  
  static const streak3 = Achievement(
    id: 'streak_3',
    title: 'Getting Started',
    description: 'Maintain a 3-day streak',
    emoji: '🔥',
    category: AchievementCategory.streaks,
    rarity: AchievementRarity.common,
    unlockCriteria: 'Complete activities 3 days in a row',
    xpReward: 25,
  );
  
  static const streak7 = Achievement(
    id: 'streak_7',
    title: 'Weekly Warrior',
    description: 'Maintain a 7-day streak',
    emoji: '🔥',
    category: AchievementCategory.streaks,
    rarity: AchievementRarity.rare,
    unlockCriteria: 'Complete activities 7 days in a row',
    xpReward: 50,
  );
  
  static const streak30 = Achievement(
    id: 'streak_30',
    title: 'Monthly Master',
    description: 'Maintain a 30-day streak',
    emoji: '🔥',
    category: AchievementCategory.streaks,
    rarity: AchievementRarity.epic,
    unlockCriteria: 'Complete activities 30 days in a row',
    xpReward: 150,
  );
  
  static const streak100 = Achievement(
    id: 'streak_100',
    title: 'Unstoppable',
    description: 'Maintain a 100-day streak',
    emoji: '🔥',
    category: AchievementCategory.streaks,
    rarity: AchievementRarity.legendary,
    unlockCriteria: 'Complete activities 100 days in a row',
    xpReward: 300,
  );
  
  static const streakRecovered = Achievement(
    id: 'streak_recovered',
    title: 'Never Give Up',
    description: 'Use a streak freeze to save your streak',
    emoji: '🛡️',
    category: AchievementCategory.streaks,
    rarity: AchievementRarity.rare,
    unlockCriteria: 'Use a streak freeze',
    xpReward: 50,
  );
  
  static const perfectWeek = Achievement(
    id: 'perfect_week',
    title: 'Perfect Week',
    description: 'Meet your daily XP goal 7 days in a row',
    emoji: '⭐',
    category: AchievementCategory.streaks,
    rarity: AchievementRarity.rare,
    unlockCriteria: 'Reach daily XP goal every day for a week',
    xpReward: 75,
  );
  
  static const perfectMonth = Achievement(
    id: 'perfect_month',
    title: 'Perfect Month',
    description: 'Meet your daily XP goal 30 days in a row',
    emoji: '🌟',
    category: AchievementCategory.streaks,
    rarity: AchievementRarity.epic,
    unlockCriteria: 'Reach daily XP goal every day for 30 days',
    xpReward: 200,
  );
  
  static const weekendWarrior = Achievement(
    id: 'weekend_warrior',
    title: 'Weekend Warrior',
    description: 'Complete lessons on 4 consecutive weekends',
    emoji: '📅',
    category: AchievementCategory.streaks,
    rarity: AchievementRarity.rare,
    unlockCriteria: 'Complete activities on Saturday or Sunday for 4 weeks',
    xpReward: 50,
  );
  
  // ==========================================
  // MILESTONE ACHIEVEMENTS (8)
  // ==========================================
  
  static const level5 = Achievement(
    id: 'level_5',
    title: 'Hobbyist',
    description: 'Reach level 5',
    emoji: '⭐',
    category: AchievementCategory.milestones,
    rarity: AchievementRarity.common,
    unlockCriteria: 'Earn 300 total XP',
    xpReward: 25,
  );
  
  static const level10 = Achievement(
    id: 'level_10',
    title: 'Aquarist',
    description: 'Reach level 10',
    emoji: '🌟',
    category: AchievementCategory.milestones,
    rarity: AchievementRarity.rare,
    unlockCriteria: 'Earn 600 total XP',
    xpReward: 50,
  );
  
  static const level15 = Achievement(
    id: 'level_15',
    title: 'Expert',
    description: 'Reach level 15',
    emoji: '💫',
    category: AchievementCategory.milestones,
    rarity: AchievementRarity.epic,
    unlockCriteria: 'Earn 1000 total XP',
    xpReward: 100,
  );
  
  static const level25 = Achievement(
    id: 'level_25',
    title: 'Guru',
    description: 'Reach level 25',
    emoji: '✨',
    category: AchievementCategory.milestones,
    rarity: AchievementRarity.legendary,
    unlockCriteria: 'Earn 2500 total XP',
    xpReward: 250,
  );
  
  static const xp1000 = Achievement(
    id: 'xp_1000',
    title: 'Thousand Club',
    description: 'Earn 1,000 total XP',
    emoji: '💯',
    category: AchievementCategory.milestones,
    rarity: AchievementRarity.epic,
    unlockCriteria: 'Accumulate 1,000 XP',
    xpReward: 100,
  );
  
  static const xp5000 = Achievement(
    id: 'xp_5000',
    title: 'Five Grand',
    description: 'Earn 5,000 total XP',
    emoji: '💎',
    category: AchievementCategory.milestones,
    rarity: AchievementRarity.legendary,
    unlockCriteria: 'Accumulate 5,000 XP',
    xpReward: 250,
  );
  
  static const xpInOneDay100 = Achievement(
    id: 'xp_day_100',
    title: 'Productive Day',
    description: 'Earn 100 XP in a single day',
    emoji: '🚀',
    category: AchievementCategory.milestones,
    rarity: AchievementRarity.rare,
    unlockCriteria: 'Earn 100 XP in one day',
    xpReward: 50,
  );
  
  static const xpInOneDay200 = Achievement(
    id: 'xp_day_200',
    title: 'Power User',
    description: 'Earn 200 XP in a single day',
    emoji: '⚡',
    category: AchievementCategory.milestones,
    rarity: AchievementRarity.epic,
    unlockCriteria: 'Earn 200 XP in one day',
    xpReward: 100,
  );
  
  // ==========================================
  // TRACKING ACHIEVEMENTS (6)
  // ==========================================
  
  static const firstWaterTest = Achievement(
    id: 'first_water_test',
    title: 'Scientist',
    description: 'Log your first water test',
    emoji: '🔬',
    category: AchievementCategory.tracking,
    rarity: AchievementRarity.common,
    unlockCriteria: 'Log any water parameter test',
    xpReward: 25,
  );
  
  static const waterTests25 = Achievement(
    id: 'water_tests_25',
    title: 'Diligent Tester',
    description: 'Log 25 water tests',
    emoji: '📊',
    category: AchievementCategory.tracking,
    rarity: AchievementRarity.rare,
    progressMax: 25,
    unlockCriteria: 'Log 25 water parameter tests',
    xpReward: 75,
  );
  
  static const waterTests100 = Achievement(
    id: 'water_tests_100',
    title: 'Data Master',
    description: 'Log 100 water tests',
    emoji: '📈',
    category: AchievementCategory.tracking,
    rarity: AchievementRarity.epic,
    progressMax: 100,
    unlockCriteria: 'Log 100 water parameter tests',
    xpReward: 150,
  );
  
  static const stableParameters30Days = Achievement(
    id: 'stable_params_30',
    title: 'Tank Master',
    description: 'Maintain stable parameters for 30 days',
    emoji: '⚖️',
    category: AchievementCategory.tracking,
    rarity: AchievementRarity.legendary,
    unlockCriteria: 'Keep all parameters in safe range for 30 days',
    xpReward: 250,
  );
  
  static const firstWaterChange = Achievement(
    id: 'first_water_change',
    title: 'Maintenance Novice',
    description: 'Log your first water change',
    emoji: '💧',
    category: AchievementCategory.tracking,
    rarity: AchievementRarity.common,
    unlockCriteria: 'Log a water change',
    xpReward: 25,
  );
  
  static const waterChanges50 = Achievement(
    id: 'water_changes_50',
    title: 'Maintenance Master',
    description: 'Log 50 water changes',
    emoji: '🌊',
    category: AchievementCategory.tracking,
    rarity: AchievementRarity.epic,
    progressMax: 50,
    unlockCriteria: 'Log 50 water changes',
    xpReward: 100,
  );
  
  // ==========================================
  // EXPLORATION ACHIEVEMENTS (5)
  // ==========================================
  
  static const firstTank = Achievement(
    id: 'first_tank',
    title: 'Tank Owner',
    description: 'Add your first tank',
    emoji: '🐟',
    category: AchievementCategory.exploration,
    rarity: AchievementRarity.common,
    unlockCriteria: 'Create your first tank profile',
    xpReward: 25,
  );
  
  static const multiTank = Achievement(
    id: 'multi_tank',
    title: 'Tank Collector',
    description: 'Manage 3 or more tanks',
    emoji: '🏠',
    category: AchievementCategory.exploration,
    rarity: AchievementRarity.rare,
    unlockCriteria: 'Have 3 active tank profiles',
    xpReward: 50,
  );
  
  static const photoGallery10 = Achievement(
    id: 'photo_10',
    title: 'Photographer',
    description: 'Add 10 photos to your gallery',
    emoji: '📷',
    category: AchievementCategory.exploration,
    rarity: AchievementRarity.common,
    progressMax: 10,
    unlockCriteria: 'Upload 10 photos',
    xpReward: 25,
  );
  
  static const speciesResearcher = Achievement(
    id: 'species_researcher',
    title: 'Species Researcher',
    description: 'View 20 different species profiles',
    emoji: '🔍',
    category: AchievementCategory.exploration,
    rarity: AchievementRarity.rare,
    progressMax: 20,
    unlockCriteria: 'Browse 20 species in the database',
    xpReward: 50,
  );
  
  static const plantExpert = Achievement(
    id: 'plant_expert',
    title: 'Plant Expert',
    description: 'View 15 different plant profiles',
    emoji: '🌿',
    category: AchievementCategory.exploration,
    rarity: AchievementRarity.rare,
    progressMax: 15,
    unlockCriteria: 'Browse 15 plants in the database',
    xpReward: 50,
  );
  
  // ==========================================
  // HIDDEN ACHIEVEMENTS (3)
  // ==========================================
  
  static const nightOwl = Achievement(
    id: 'night_owl',
    title: 'Night Owl',
    description: 'The fish sleep, but you don\'t',
    emoji: '🦉',
    category: AchievementCategory.hidden,
    rarity: AchievementRarity.rare,
    isHidden: true,
    unlockCriteria: 'Log activity between 2am-4am',
    xpReward: 50,
  );
  
  static const earlyBird = Achievement(
    id: 'early_bird',
    title: 'Early Bird',
    description: 'First one awake, feeding the fish',
    emoji: '🐦',
    category: AchievementCategory.hidden,
    rarity: AchievementRarity.rare,
    isHidden: true,
    unlockCriteria: 'Log activity between 5am-6am',
    xpReward: 50,
  );
  
  static const appExplorer = Achievement(
    id: 'app_explorer',
    title: 'App Explorer',
    description: 'You found everything!',
    emoji: '🗺️',
    category: AchievementCategory.hidden,
    rarity: AchievementRarity.legendary,
    isHidden: true,
    unlockCriteria: 'Visit every screen in the app',
    xpReward: 100,
  );
  
  // ==========================================
  // CATALOG
  // ==========================================
  
  static final List<Achievement> all = [
    // Learning (10)
    firstLesson,
    lessonsCompleted10,
    lessonsCompleted25,
    allLessons,
    nitrogenCyclePath,
    allPaths,
    perfectQuiz,
    perfectQuizStreak5,
    placementTest,
    speedLearner,
    
    // Streaks (8)
    streak3,
    streak7,
    streak30,
    streak100,
    streakRecovered,
    perfectWeek,
    perfectMonth,
    weekendWarrior,
    
    // Milestones (8)
    level5,
    level10,
    level15,
    level25,
    xp1000,
    xp5000,
    xpInOneDay100,
    xpInOneDay200,
    
    // Tracking (6)
    firstWaterTest,
    waterTests25,
    waterTests100,
    stableParameters30Days,
    firstWaterChange,
    waterChanges50,
    
    // Exploration (5)
    firstTank,
    multiTank,
    photoGallery10,
    speciesResearcher,
    plantExpert,
    
    // Hidden (3)
    nightOwl,
    earlyBird,
    appExplorer,
  ];
  
  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
  
  static List<Achievement> getByCategory(AchievementCategory category) {
    return all.where((a) => a.category == category).toList();
  }
  
  static List<Achievement> getUnhidden() {
    return all.where((a) => !a.isHidden).toList();
  }
}
```

---

## 🎨 UI Specifications

### Achievement Gallery Screen Layout

```
┌─────────────────────────────────────┐
│  🏆 Achievements          [Stats]   │  ← Header with unlock count
├─────────────────────────────────────┤
│  📚 Learning  🔥 Streaks  🏆 All... │  ← Category tabs
├─────────────────────────────────────┤
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐  │
│  │ 📖  │ │ 📚  │ │ 🎓  │ │ 🏅  │  │  ← Achievement grid
│  │✓ 25 │ │7/10 │ │     │ │     │  │    (unlocked/progress/locked)
│  └─────┘ └─────┘ └─────┘ └─────┘  │
│                                     │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐  │
│  │ 🔄  │ │ 🗺️  │ │ 🎯  │ │ 🏆  │  │
│  │ ... │ │ ... │ │ ... │ │ ... │  │
│  └─────┘ └─────┘ └─────┘ └─────┘  │
└─────────────────────────────────────┘
```

### Achievement Card States

1. **Unlocked** - Full color, emoji visible, checkmark badge
2. **In Progress** - Partial color, progress bar (7/10), emoji visible
3. **Locked** - Grayscale, lock icon overlay, emoji dimmed
4. **Hidden Locked** - Grayscale, "???" placeholder, mystery icon

### Achievement Detail Modal

Tap any achievement to expand:

```
┌─────────────────────────────────────┐
│              📚                      │
│        Eager Learner                │
│           (RARE)                    │
├─────────────────────────────────────┤
│  Complete 10 lessons                │
│                                     │
│  ▓▓▓▓▓▓▓░░░░░░░░░░░ 7/10           │  ← Progress bar
│                                     │
│  How to unlock:                     │
│  • Complete any lesson to make      │
│    progress toward this achievement │
│                                     │
│  Reward: +50 XP                     │
│                                     │
│  Unlocked by: 45% of users          │  ← Social proof
└─────────────────────────────────────┘
```

---

## 💻 Implementation Files

### 1. Achievement Provider
**File:** `lib/providers/achievement_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import '../data/achievement_catalog.dart';
import 'user_profile_provider.dart';
import 'storage_provider.dart';

/// Provider for achievement progress tracking
final achievementProgressProvider = StateNotifierProvider<
  AchievementProgressNotifier, 
  Map<String, AchievementProgress>
>((ref) {
  return AchievementProgressNotifier(ref);
});

class AchievementProgressNotifier extends StateNotifier<Map<String, AchievementProgress>> {
  final Ref ref;
  
  AchievementProgressNotifier(this.ref) : super({}) {
    _loadProgress();
  }
  
  Future<void> _loadProgress() async {
    final storage = ref.read(storageServiceProvider);
    final data = await storage.read('achievement_progress');
    
    if (data != null && data is Map) {
      state = data.map((key, value) => 
        MapEntry(
          key as String, 
          AchievementProgress.fromJson(value as Map<String, dynamic>)
        )
      );
    }
  }
  
  Future<void> _saveProgress() async {
    final storage = ref.read(storageServiceProvider);
    final data = state.map((key, value) => MapEntry(key, value.toJson()));
    await storage.write('achievement_progress', data);
  }
  
  /// Update progress for an achievement
  Future<void> updateProgress(String achievementId, int progress) async {
    final achievement = AchievementCatalog.getById(achievementId);
    if (achievement == null) return;
    
    final current = state[achievementId] ?? AchievementProgress(achievementId: achievementId);
    
    // Check if unlocked
    final isUnlocked = achievement.isIncremental 
      ? progress >= (achievement.progressMax ?? 0)
      : progress > 0;
    
    final updated = current.copyWith(
      currentProgress: progress,
      isUnlocked: isUnlocked,
      unlockedAt: isUnlocked && !current.isUnlocked ? DateTime.now() : current.unlockedAt,
    );
    
    state = {...state, achievementId: updated};
    await _saveProgress();
    
    // Award XP if newly unlocked
    if (isUnlocked && !current.isUnlocked) {
      await _awardAchievementXp(achievement);
    }
  }
  
  /// Increment progress by 1
  Future<void> incrementProgress(String achievementId) async {
    final current = state[achievementId] ?? AchievementProgress(achievementId: achievementId);
    await updateProgress(achievementId, current.currentProgress + 1);
  }
  
  Future<void> _awardAchievementXp(Achievement achievement) async {
    final profileActions = ref.read(userProfileActionsProvider);
    await profileActions.addXp(achievement.xpReward);
  }
  
  /// Get progress for specific achievement
  AchievementProgress? getProgress(String achievementId) {
    return state[achievementId];
  }
  
  /// Get unlock count by category
  Map<AchievementCategory, int> getUnlockCountByCategory() {
    final Map<AchievementCategory, int> counts = {};
    
    for (final achievement in AchievementCatalog.all) {
      final progress = state[achievement.id];
      if (progress?.isUnlocked ?? false) {
        counts[achievement.category] = (counts[achievement.category] ?? 0) + 1;
      }
    }
    
    return counts;
  }
}

/// Helper provider for triggering achievement checks
final achievementTrackerProvider = Provider((ref) {
  return AchievementTracker(ref);
});

class AchievementTracker {
  final Ref ref;
  
  AchievementTracker(this.ref);
  
  /// Call after completing a lesson
  Future<void> onLessonComplete() async {
    final notifier = ref.read(achievementProgressProvider.notifier);
    
    // First lesson
    await notifier.updateProgress('first_lesson', 1);
    
    // Count lessons (would track in user profile)
    final profile = ref.read(userProfileProvider).value;
    if (profile != null) {
      final lessonCount = profile.completedLessons.length;
      await notifier.updateProgress('lessons_10', lessonCount);
      await notifier.updateProgress('lessons_25', lessonCount);
    }
  }
  
  /// Call when streak updates
  Future<void> onStreakUpdate(int streakDays) async {
    final notifier = ref.read(achievementProgressProvider.notifier);
    
    if (streakDays >= 3) await notifier.updateProgress('streak_3', streakDays);
    if (streakDays >= 7) await notifier.updateProgress('streak_7', streakDays);
    if (streakDays >= 30) await notifier.updateProgress('streak_30', streakDays);
    if (streakDays >= 100) await notifier.updateProgress('streak_100', streakDays);
  }
  
  /// Call when XP changes
  Future<void> onXpGained(int totalXp, int dailyXp) async {
    final notifier = ref.read(achievementProgressProvider.notifier);
    
    // Level milestones
    if (totalXp >= 300) await notifier.updateProgress('level_5', 1);
    if (totalXp >= 600) await notifier.updateProgress('level_10', 1);
    if (totalXp >= 1000) await notifier.updateProgress('level_15', 1);
    if (totalXp >= 2500) await notifier.updateProgress('level_25', 1);
    
    // XP milestones
    await notifier.updateProgress('xp_1000', totalXp >= 1000 ? 1 : 0);
    await notifier.updateProgress('xp_5000', totalXp >= 5000 ? 1 : 0);
    
    // Daily XP
    if (dailyXp >= 100) await notifier.updateProgress('xp_day_100', 1);
    if (dailyXp >= 200) await notifier.updateProgress('xp_day_200', 1);
  }
  
  /// Call after water test logged
  Future<void> onWaterTestLogged() async {
    final notifier = ref.read(achievementProgressProvider.notifier);
    await notifier.updateProgress('first_water_test', 1);
    await notifier.incrementProgress('water_tests_25');
    await notifier.incrementProgress('water_tests_100');
  }
  
  /// Call after tank created
  Future<void> onTankCreated(int tankCount) async {
    final notifier = ref.read(achievementProgressProvider.notifier);
    await notifier.updateProgress('first_tank', 1);
    if (tankCount >= 3) await notifier.updateProgress('multi_tank', 1);
  }
}
```

### 2. Achievement Gallery Screen
**File:** `lib/screens/achievement_gallery_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import '../data/achievement_catalog.dart';
import '../providers/achievement_provider.dart';
import '../theme/app_theme.dart';

class AchievementGalleryScreen extends ConsumerStatefulWidget {
  const AchievementGalleryScreen({super.key});

  @override
  ConsumerState<AchievementGalleryScreen> createState() => _AchievementGalleryScreenState();
}

class _AchievementGalleryScreenState extends ConsumerState<AchievementGalleryScreen> 
  with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  
  final List<AchievementCategory?> _categories = [
    null, // All
    AchievementCategory.learning,
    AchievementCategory.streaks,
    AchievementCategory.milestones,
    AchievementCategory.tracking,
    AchievementCategory.exploration,
    AchievementCategory.hidden,
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressMap = ref.watch(achievementProgressProvider);
    final totalUnlocked = progressMap.values.where((p) => p.isUnlocked).length;
    final totalAchievements = AchievementCatalog.all.length;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Achievements'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$totalUnlocked/$totalAchievements',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categories.map((cat) {
            if (cat == null) {
              return const Tab(text: '🏆 All');
            }
            return Tab(text: '${cat.emoji} ${cat.displayName}');
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((cat) {
          final achievements = cat == null 
            ? AchievementCatalog.all 
            : AchievementCatalog.getByCategory(cat);
          
          return _AchievementGrid(achievements: achievements);
        }).toList(),
      ),
    );
  }
}

class _AchievementGrid extends ConsumerWidget {
  final List<Achievement> achievements;
  
  const _AchievementGrid({required this.achievements});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _AchievementCard(achievement: achievement);
      },
    );
  }
}

class _AchievementCard extends ConsumerWidget {
  final Achievement achievement;
  
  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(achievementProgressProvider)[achievement.id];
    final isUnlocked = progress?.isUnlocked ?? false;
    final currentProgress = progress?.currentProgress ?? 0;
    
    return GestureDetector(
      onTap: () => _showDetail(context, achievement, progress),
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked 
            ? achievement.rarity.color.withOpacity(0.1)
            : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked 
              ? achievement.rarity.color 
              : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Emoji
                Text(
                  achievement.isHidden && !isUnlocked ? '❓' : achievement.emoji,
                  style: TextStyle(
                    fontSize: 40,
                    color: isUnlocked ? null : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Progress/Status
                if (achievement.isIncremental && !isUnlocked)
                  Text(
                    '$currentProgress/${achievement.progressMax}',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                if (isUnlocked)
                  Icon(
                    Icons.check_circle,
                    color: achievement.rarity.color,
                    size: 16,
                  ),
                  
                if (!achievement.isIncremental && !isUnlocked)
                  Icon(
                    Icons.lock,
                    color: Colors.grey.shade400,
                    size: 16,
                  ),
                
                const SizedBox(height: 4),
                
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    achievement.isHidden && !isUnlocked ? '???' : achievement.title,
                    style: AppTypography.labelSmall.copyWith(
                      color: isUnlocked ? null : Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            // XP badge
            if (isUnlocked)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: achievement.rarity.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+${achievement.xpReward}',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  void _showDetail(BuildContext context, Achievement achievement, AchievementProgress? progress) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AchievementDetailSheet(
        achievement: achievement,
        progress: progress,
      ),
    );
  }
}

class _AchievementDetailSheet extends StatelessWidget {
  final Achievement achievement;
  final AchievementProgress? progress;
  
  const _AchievementDetailSheet({
    required this.achievement,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = progress?.isUnlocked ?? false;
    final currentProgress = progress?.currentProgress ?? 0;
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Emoji
          Text(
            achievement.isHidden && !isUnlocked ? '❓' : achievement.emoji,
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 16),
          
          // Title
          Text(
            achievement.isHidden && !isUnlocked ? 'Hidden Achievement' : achievement.title,
            style: AppTypography.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Rarity badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: achievement.rarity.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: achievement.rarity.color),
            ),
            child: Text(
              achievement.rarity.displayName.toUpperCase(),
              style: AppTypography.labelSmall.copyWith(
                color: achievement.rarity.color,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Description
          if (!achievement.isHidden || isUnlocked)
            Text(
              achievement.description,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 24),
          
          // Progress bar (for incremental)
          if (achievement.isIncremental && !isUnlocked) ...[
            LinearProgressIndicator(
              value: currentProgress / (achievement.progressMax ?? 1),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(achievement.rarity.color),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '$currentProgress / ${achievement.progressMax}',
              style: AppTypography.labelMedium.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Unlock criteria
          if (!isUnlocked) ...[
            Text(
              'How to unlock:',
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.unlockCriteria,
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
          
          // Unlocked date
          if (isUnlocked && progress?.unlockedAt != null) ...[
            Text(
              'Unlocked on ${_formatDate(progress!.unlockedAt!)}',
              style: AppTypography.bodySmall.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Reward
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stars, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Reward: +${achievement.xpReward} XP',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
```

---

## 🔗 Integration Points

### 1. Add to Navigation
In `home_screen.dart` or profile screen, add a button/card to access the gallery:

```dart
ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AchievementGalleryScreen(),
      ),
    );
  },
  icon: const Icon(Icons.emoji_events),
  label: const Text('View Achievements'),
)
```

### 2. Hook Achievement Tracking
Update existing providers to trigger achievement checks:

**In `user_profile_provider.dart`:**
```dart
// After adding XP
await ref.read(achievementTrackerProvider).onXpGained(totalXp, dailyXp);

// After completing lesson
await ref.read(achievementTrackerProvider).onLessonComplete();

// After streak update
await ref.read(achievementTrackerProvider).onStreakUpdate(currentStreak);
```

**In `tank_provider.dart`:**
```dart
// After creating tank
await ref.read(achievementTrackerProvider).onTankCreated(tanks.length);
```

### 3. Achievement Unlock Toast
Create a widget to show when achievements unlock:

**File:** `lib/widgets/achievement_unlock_toast.dart`

```dart
import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../theme/app_theme.dart';

void showAchievementUnlockToast(BuildContext context, Achievement achievement) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: achievement.rarity.color,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          Text(
            achievement.emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Achievement Unlocked!',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  achievement.title,
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '+${achievement.xpReward} XP',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
```

---

## 📱 UI Assets & Icons

### Achievement Icons
Use emoji for simplicity and consistency:
- Learning: 📖 📚 🎓 🏅 🔄 🗺️ 🎯 🏆
- Streaks: 🔥 🛡️ ⭐ 🌟 📅
- Milestones: ⭐ 🌟 💫 ✨ 💯 💎 🚀 ⚡
- Tracking: 🔬 📊 📈 ⚖️ 💧 🌊
- Exploration: 🐟 🏠 📷 🔍 🌿
- Hidden: 🦉 🐦 🗺️

### Color Scheme (Already defined in `app_theme.dart`)
- Common: Gray (#9E9E9E)
- Rare: Blue (#2196F3)
- Epic: Purple (#9C27B0)
- Legendary: Orange/Gold (#FFA726)

---

## ✅ Testing Checklist

### Functionality
- [ ] Achievements load from catalog
- [ ] Progress tracks correctly for incremental achievements
- [ ] One-time achievements unlock properly
- [ ] Hidden achievements show "???" when locked
- [ ] XP rewards granted on unlock
- [ ] Progress persists across app restarts
- [ ] Category filters work
- [ ] Detail modal shows correct info
- [ ] Achievement unlock toast appears

### UI/UX
- [ ] Grid layout responsive on different screen sizes
- [ ] Locked achievements clearly distinguishable
- [ ] Progress bars accurate
- [ ] Animations smooth
- [ ] Colors match rarity tiers
- [ ] Text readable in all states
- [ ] Modal sheet scrollable on small screens

### Integration
- [ ] Profile screen links to gallery
- [ ] Lesson completion triggers achievements
- [ ] Streak updates trigger achievements
- [ ] XP milestones trigger achievements
- [ ] Water test logging triggers achievements
- [ ] Tank creation triggers achievements

---

## 🚀 Future Enhancements

1. **Achievement Sharing** - Share unlocked achievements to social media
2. **Leaderboard Integration** - Show achievement counts in leaderboard
3. **Achievement Collections** - Group related achievements (e.g., "Master all nitrogen cycle achievements")
4. **Time-Limited Achievements** - Seasonal/event-based achievements
5. **Custom Icons** - Replace emojis with custom illustrated badges
6. **Sound Effects** - Play celebration sound on unlock
7. **Animation** - Confetti or particle effects on unlock
8. **Statistics Page** - Detailed stats (unlock rate, rarest achievements, etc.)
9. **Achievement Hints** - Show hints for hidden achievements after certain conditions
10. **Profile Badge Display** - Show top 3 achievements on profile screen

---

## 📝 Summary

This implementation provides:
- ✅ **40 achievements** across 6 categories
- ✅ **Progress tracking** for incremental achievements
- ✅ **Rarity system** (common/rare/epic/legendary)
- ✅ **Hidden achievements** with mystery reveals
- ✅ **Beautiful gallery UI** with grid layout and detail modal
- ✅ **Category filtering** via tabs
- ✅ **XP rewards** on unlock
- ✅ **Persistent storage** of progress
- ✅ **Achievement tracking** integrated into existing systems
- ✅ **Unlock notifications** via toast

### Files to Create:
1. `lib/models/achievement.dart` - Extended model
2. `lib/data/achievement_catalog.dart` - 40 achievements
3. `lib/providers/achievement_provider.dart` - Progress tracking
4. `lib/screens/achievement_gallery_screen.dart` - Gallery UI
5. `lib/widgets/achievement_unlock_toast.dart` - Unlock notification

### Files to Modify:
1. `lib/providers/user_profile_provider.dart` - Add achievement triggers
2. `lib/providers/tank_provider.dart` - Add tank creation trigger
3. `lib/screens/home_screen.dart` or profile - Add navigation to gallery

**Estimated Implementation Time:** 6-8 hours

Ready to make fishkeeping achievement-worthy! 🏆🐟
