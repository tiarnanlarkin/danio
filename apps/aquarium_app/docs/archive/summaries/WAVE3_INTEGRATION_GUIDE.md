# Wave 3 Features - Complete Integration Guide

**Making integration dead-simple for developers**

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Feature 1: Adaptive Difficulty System](#feature-1-adaptive-difficulty-system)
4. [Feature 2: Achievement System](#feature-2-achievement-system)
5. [Feature 3: Hearts/Lives System](#feature-3-heartslives-system)
6. [Feature 4: Spaced Repetition System](#feature-4-spaced-repetition-system)
5. [Feature 5: Analytics Dashboard](#feature-5-analytics-dashboard)
6. [Feature 6: Social/Friends Features](#feature-6-socialfriends-features)
7. [Database Schema Updates](#database-schema-updates)
8. [Testing Guide](#testing-guide)
9. [Troubleshooting FAQ](#troubleshooting-faq)
10. [Migration Guide](#migration-guide)

---

## Overview

Wave 3 introduces 6 powerful features that transform your learning app into an engaging, adaptive, and social experience:

| Feature | Description | Integration Time | Complexity |
|---------|-------------|------------------|------------|
| **Adaptive Difficulty** | AI-powered difficulty adjustment | 2-3 hours | Medium |
| **Achievements** | 47 achievements across 5 categories | 1-2 hours | Low |
| **Hearts/Lives** | Duolingo-style mistake limiting | 3-4 hours | Medium |
| **Spaced Repetition** | Forgetting curve review system | 4-6 hours | High |
| **Analytics** | Progress tracking dashboard | 2-3 hours | Medium |
| **Social/Friends** | Friend activities & comparison | 2-3 hours | Medium |

**Total Integration Time: 14-21 hours**

### Key Benefits

✅ **Personalized Learning** - Adaptive difficulty matches user skill level  
✅ **Engagement** - Achievements and hearts create compelling gamification  
✅ **Retention** - Spaced repetition ensures long-term knowledge retention  
✅ **Motivation** - Social features and analytics drive continued use  
✅ **Data-Driven** - Comprehensive analytics inform product decisions  

---

## Quick Start

### Prerequisites

```bash
# Required packages (already in pubspec.yaml)
dependencies:
  flutter_riverpod: ^2.4.0
  shared_preferences: ^2.2.0
  fl_chart: ^0.65.0
  confetti: ^0.7.0
```

### 5-Minute Demo

```dart
// 1. Import the demo screen
import 'package:aquarium_app/examples/wave3_demo_screen.dart';

// 2. Navigate to it
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const Wave3DemoScreen()),
);

// 3. Explore all 6 features interactively!
```

### Integration Checklist

```markdown
- [ ] Review this guide (30 min)
- [ ] Run Wave3DemoScreen to see features (15 min)
- [ ] Update UserProfile model with new fields (30 min)
- [ ] Integrate Adaptive Difficulty (2-3 hours)
- [ ] Integrate Achievements (1-2 hours)
- [ ] Integrate Hearts System (3-4 hours)
- [ ] Integrate Spaced Repetition (4-6 hours)
- [ ] Integrate Analytics (2-3 hours)
- [ ] Integrate Social Features (2-3 hours)
- [ ] Run all tests (30 min)
- [ ] Deploy and monitor (1 hour)
```

---

## Feature 1: Adaptive Difficulty System

### Overview

The Adaptive Difficulty System uses AI-powered algorithms to dynamically adjust lesson difficulty based on user performance. It tracks skill levels per topic and provides real-time recommendations.

### Time to Integrate: 2-3 hours

### Step-by-Step Integration

#### Step 1: Update UserProfile (15 minutes)

The UserProfile model already has a `skillProfile` field. Ensure it's properly initialized:

```dart
// In lib/models/user_profile.dart (already implemented)
class UserProfile {
  final UserSkillProfile? skillProfile; // Optional for backward compatibility
  
  // ... other fields
}
```

#### Step 2: Initialize DifficultyService (10 minutes)

```dart
// In your app initialization (e.g., main.dart or app state)
import 'package:aquarium_app/services/difficulty_service.dart';

final difficultyService = DifficultyService();
```

#### Step 3: Get Difficulty Recommendation Before Lesson (30 minutes)

```dart
// In your lesson start logic (e.g., LessonScreen)
import 'package:aquarium_app/services/difficulty_service.dart';
import 'package:aquarium_app/models/adaptive_difficulty.dart';

class _LessonScreenState extends State<LessonScreen> {
  late DifficultyService _difficultyService;
  late DifficultyLevel _currentDifficulty;
  
  @override
  void initState() {
    super.initState();
    _difficultyService = DifficultyService();
    _initializeDifficulty();
  }
  
  Future<void> _initializeDifficulty() async {
    // Get user's skill profile from UserProfile
    final skillProfile = userProfile.skillProfile ?? UserSkillProfile.empty();
    
    // Get AI recommendation
    final recommendation = _difficultyService.getDifficultyRecommendation(
      topicId: widget.lesson.pathId,
      profile: skillProfile,
    );
    
    setState(() {
      _currentDifficulty = recommendation.suggestedLevel;
    });
    
    // Optionally show recommendation dialog
    if (recommendation.confidence > 0.7 && mounted) {
      await _showDifficultyRecommendationDialog(recommendation);
    }
  }
  
  Future<void> _showDifficultyRecommendationDialog(
    DifficultyRecommendation recommendation,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recommended Difficulty'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_difficultyService.getDifficultyIcon(recommendation.suggestedLevel)} '
              '${_difficultyService.getDifficultyName(recommendation.suggestedLevel)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(recommendation.reason),
            const SizedBox(height: 8),
            Text(
              'Confidence: ${(recommendation.confidence * 100).toStringAsFixed(0)}%',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Use Recommendation'),
          ),
          TextButton(
            onPressed: () {
              // Show manual difficulty selector
              Navigator.pop(context);
              _showDifficultySelector();
            },
            child: const Text('Choose Manually'),
          ),
        ],
      ),
    );
  }
}
```

#### Step 4: Track Performance During Lesson (45 minutes)

```dart
// Track attempts during lesson
List<PerformanceRecord> _lessonAttempts = [];
DateTime _questionStartTime = DateTime.now();

void _onQuestionStarted() {
  _questionStartTime = DateTime.now();
}

void _onAnswerSubmitted(bool isCorrect) {
  // Record the attempt
  final record = PerformanceRecord(
    timestamp: DateTime.now(),
    topicId: widget.lesson.pathId,
    difficulty: _currentDifficulty,
    score: isCorrect ? 1 : 0,
    maxScore: 1,
    mistakeCount: isCorrect ? 0 : 1,
    timeSpent: DateTime.now().difference(_questionStartTime),
    completed: true,
  );
  
  _lessonAttempts.add(record);
  
  // Check for mid-lesson adjustment
  final newDifficulty = _difficultyService.checkForMidLessonAdjustment(
    currentDifficulty: _currentDifficulty,
    lessonAttempts: _lessonAttempts,
  );
  
  if (newDifficulty != null) {
    _showDifficultyAdjustment(_currentDifficulty, newDifficulty);
    setState(() {
      _currentDifficulty = newDifficulty;
    });
  }
  
  // Start timer for next question
  _questionStartTime = DateTime.now();
}

void _showDifficultyAdjustment(
  DifficultyLevel oldLevel,
  DifficultyLevel newLevel,
) {
  // Show notification using DifficultyChangeNotification widget
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        newLevel.index > oldLevel.index
          ? '🎯 Great job! Increasing difficulty'
          : '💡 Let\'s try an easier level',
      ),
      backgroundColor: newLevel.index > oldLevel.index
        ? Colors.green
        : Colors.orange,
      duration: const Duration(seconds: 3),
    ),
  );
}
```

#### Step 5: Update Profile After Lesson (30 minutes)

```dart
void _onLessonComplete() async {
  final totalTime = DateTime.now().difference(_lessonStartTime);
  
  // Create final performance record
  final lessonRecord = PerformanceRecord(
    timestamp: DateTime.now(),
    topicId: widget.lesson.pathId,
    difficulty: _currentDifficulty,
    score: _totalCorrect,
    maxScore: _totalQuestions,
    mistakeCount: _totalMistakes,
    timeSpent: totalTime,
    completed: true,
  );
  
  // Get old skill for comparison
  final skillProfile = userProfile.skillProfile ?? UserSkillProfile.empty();
  final oldSkill = skillProfile.getSkillLevel(widget.lesson.pathId);
  
  // Update profile
  final updatedProfile = _difficultyService.updateProfileAfterLesson(
    currentProfile: skillProfile,
    lessonRecord: lessonRecord,
  );
  
  // Check for skill change
  final newSkill = updatedProfile.getSkillLevel(widget.lesson.pathId);
  final message = _difficultyService.getSkillChangeMessage(
    oldSkill: oldSkill,
    newSkill: newSkill,
    topicName: widget.lesson.title,
  );
  
  if (message != null && mounted) {
    _showSkillLevelUpAnimation(message);
  }
  
  // Save updated profile
  await _updateUserProfile(updatedProfile);
}

Future<void> _updateUserProfile(UserSkillProfile skillProfile) async {
  // Update user profile with new skill profile
  final updatedProfile = userProfile.copyWith(
    skillProfile: skillProfile,
  );
  
  // Save to storage (using your storage service)
  await ref.read(storageProvider).saveUserProfile(updatedProfile);
}

void _showSkillLevelUpAnimation(String message) {
  // Use SkillLevelUpAnimation widget
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => SkillLevelUpAnimation(
      message: message,
      onComplete: () => Navigator.pop(context),
    ),
  );
}
```

#### Step 6: Display Difficulty in UI (15 minutes)

```dart
// In lesson app bar
import 'package:aquarium_app/widgets/difficulty_badge.dart';

AppBar(
  title: Text(widget.lesson.title),
  actions: [
    Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Center(
        child: DifficultyBadge(
          difficulty: _currentDifficulty,
          size: 0.9,
        ),
      ),
    ),
  ],
)

// Before quiz starts - show skill level
import 'package:aquarium_app/widgets/difficulty_badge.dart';

Widget _buildLessonHeader() {
  return Column(
    children: [
      SkillLevelIndicator(
        skillLevel: skillProfile.getSkillLevel(widget.lesson.pathId),
        label: 'Your ${widget.lesson.title} Skill',
      ),
      const SizedBox(height: 16),
      DifficultyBadge(
        difficulty: _currentDifficulty,
        showLabel: true,
      ),
    ],
  );
}
```

#### Step 7: Add Difficulty Settings Navigation (10 minutes)

```dart
// In settings screen or profile
import 'package:aquarium_app/screens/difficulty_settings_screen.dart';

ListTile(
  leading: const Icon(Icons.insights),
  title: const Text('Difficulty Settings'),
  subtitle: const Text('View skill levels and adjust difficulty'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DifficultySettingsScreen(
          skillProfile: userProfile.skillProfile ?? UserSkillProfile.empty(),
          onProfileUpdated: (newProfile) async {
            await _updateUserProfile(newProfile);
          },
        ),
      ),
    );
  },
)
```

### API Reference

#### DifficultyService

```dart
class DifficultyService {
  /// Calculate skill level from performance history (0.0 - 1.0)
  /// Uses weighted algorithm: accuracy (40%), time (20%), consistency (20%), streak (20%)
  double calculateSkillLevel(PerformanceHistory history);
  
  /// Get AI-powered difficulty recommendation
  /// Returns suggested level, confidence score, and human-readable reason
  DifficultyRecommendation getDifficultyRecommendation({
    required String topicId,
    required UserSkillProfile profile,
  });
  
  /// Check if difficulty should change mid-lesson
  /// Returns new level if adjustment needed, null otherwise
  /// Triggers on 3 perfect answers (increase) or 3 failures (decrease)
  DifficultyLevel? checkForMidLessonAdjustment({
    required DifficultyLevel currentDifficulty,
    required List<PerformanceRecord> lessonAttempts,
  });
  
  /// Update skill profile after lesson completion
  /// Returns new profile with updated history and skill levels
  UserSkillProfile updateProfileAfterLesson({
    required UserSkillProfile currentProfile,
    required PerformanceRecord lessonRecord,
  });
  
  /// Check if user has mastered a topic
  /// Requires skill >= 0.85 and 5+ successful attempts
  bool hasTopicMastery({
    required String topicId,
    required UserSkillProfile profile,
  });
  
  /// Get skill level change message for UI display
  /// Returns motivational message or null if no significant change
  String? getSkillChangeMessage({
    required double oldSkill,
    required double newSkill,
    required String topicName,
  });
  
  // Helper methods for UI
  String getDifficultyName(DifficultyLevel level);
  String getDifficultyIcon(DifficultyLevel level);
  Color getDifficultyColor(DifficultyLevel level);
  String getDifficultyDescription(DifficultyLevel level);
}
```

### Common Pitfalls

❌ **Forgetting to initialize skill profile** - Always check for null and use `UserSkillProfile.empty()` as fallback  
❌ **Not saving profile after updates** - Must persist to storage or changes are lost  
❌ **Ignoring confidence scores** - Low confidence (<0.5) means insufficient data  
❌ **Hardcoding difficulty** - Always use recommendations unless user explicitly overrides  

### Testing

```bash
# Run difficulty system tests
flutter test test/services/difficulty_service_test.dart

# Expected: 27 tests passing
```

---

## Feature 2: Achievement System

### Overview

The Achievement System provides 47 achievements across 5 categories with progress tracking, unlock notifications, and XP rewards.

### Time to Integrate: 1-2 hours

### Step-by-Step Integration

#### Step 1: Initialize Achievement Provider (10 minutes)

```dart
// In your app initialization (wrap app with ProviderScope if not already)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquarium_app/providers/achievement_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// Achievement provider is auto-initialized on first use
```

#### Step 2: Check Achievements After Lesson (30 minutes)

```dart
// In lesson completion logic
import 'package:aquarium_app/providers/achievement_provider.dart';
import 'package:aquarium_app/widgets/achievement_notification.dart';

Future<void> _onLessonCompleted() async {
  // Update user stats first
  final updatedProfile = userProfile.copyWith(
    lessonsCompleted: userProfile.lessonsCompleted + 1,
    xp: userProfile.xp + xpEarned,
    completedLessons: [...userProfile.completedLessons, widget.lesson.id],
  );
  
  await _saveUserProfile(updatedProfile);
  
  // Check for achievement unlocks
  final achievementChecker = ref.read(achievementCheckerProvider);
  
  final newAchievements = await achievementChecker.checkAfterLesson(
    lessonsCompleted: updatedProfile.lessonsCompleted,
    currentStreak: updatedProfile.currentStreak,
    totalXp: updatedProfile.xp,
    perfectScores: updatedProfile.perfectScores,
    lessonCompletedAt: DateTime.now(),
    lessonDuration: _lessonDuration.inSeconds,
    lessonScore: _totalCorrect / _totalQuestions,
    todayLessonsCompleted: _getTodayLessonsCount(),
    completedLessonIds: updatedProfile.completedLessons,
  );

  // Show notifications for newly unlocked achievements
  if (mounted) {
    for (final result in newAchievements.where((r) => r.wasJustUnlocked)) {
      await AchievementNotification.show(
        context,
        result.achievement,
        result.xpAwarded,
      );
      
      // Small delay between notifications
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}
```

#### Step 3: Check Achievements After Other Events (20 minutes)

```dart
// After reading daily tip
Future<void> _onDailyTipRead() async {
  final achievementChecker = ref.read(achievementCheckerProvider);
  
  final newAchievements = await achievementChecker.checkAfterDailyTip(
    tipsReadCount: userProfile.tipsRead + 1,
  );
  
  _showAchievementNotifications(newAchievements);
}

// After practice session
Future<void> _onPracticeSessionComplete() async {
  final achievementChecker = ref.read(achievementCheckerProvider);
  
  final newAchievements = await achievementChecker.checkAfterPractice(
    practiceSessionsCompleted: userProfile.practiceSessionsCompleted + 1,
  );
  
  _showAchievementNotifications(newAchievements);
}

// After adding friend
Future<void> _onFriendAdded() async {
  final achievementChecker = ref.read(achievementCheckerProvider);
  
  final newAchievements = await achievementChecker.checkAfterSocialAction(
    friendsCount: userProfile.friends.length,
  );
  
  _showAchievementNotifications(newAchievements);
}

// Helper to show notifications
void _showAchievementNotifications(List<AchievementUnlockResult> results) async {
  for (final result in results.where((r) => r.wasJustUnlocked)) {
    if (mounted) {
      await AchievementNotification.show(
        context,
        result.achievement,
        result.xpAwarded,
      );
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}
```

#### Step 4: Add Achievements Screen Navigation (10 minutes)

```dart
// In main navigation or settings screen
ListTile(
  leading: const Icon(Icons.emoji_events),
  title: const Text('Achievements'),
  subtitle: const Text('View your trophy case'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () {
    Navigator.pushNamed(context, 'achievements');
    // Or: context.go('/achievements'); if using go_router
  },
)
```

#### Step 5: Display Achievement Progress Widget (15 minutes)

```dart
// In home screen or profile
import 'package:aquarium_app/examples/achievement_integration_example.dart';

Widget build(BuildContext context) {
  return Column(
    children: [
      // Achievement progress summary
      Consumer(
        builder: (context, ref, child) {
          final achievementChecker = ref.watch(achievementCheckerProvider);
          final progress = achievementChecker.getCompletionPercentage();
          final unlockedCount = achievementChecker.unlockedAchievements.length;
          
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber),
                      const SizedBox(width: 8),
                      const Text(
                        'Achievements',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$unlockedCount / 47 unlocked (${progress.toStringAsFixed(0)}%)',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ],
  );
}
```

### API Reference

#### AchievementChecker (Provider)

```dart
class AchievementChecker {
  /// Check achievements after lesson completion
  /// Returns list of results with wasJustUnlocked flag
  Future<List<AchievementUnlockResult>> checkAfterLesson({
    required int lessonsCompleted,
    required int currentStreak,
    required int totalXp,
    required int perfectScores,
    required DateTime lessonCompletedAt,
    required int lessonDuration,
    required double lessonScore,
    required int todayLessonsCompleted,
    required List<String> completedLessonIds,
  });
  
  /// Check achievements after reading daily tip
  Future<List<AchievementUnlockResult>> checkAfterDailyTip({
    required int tipsReadCount,
  });
  
  /// Check achievements after practice session
  Future<List<AchievementUnlockResult>> checkAfterPractice({
    required int practiceSessionsCompleted,
  });
  
  /// Check achievements after social action (add friend, etc.)
  Future<List<AchievementUnlockResult>> checkAfterSocialAction({
    required int friendsCount,
  });
  
  /// Get completion percentage (0-100)
  double getCompletionPercentage();
  
  /// Get list of unlocked achievements
  List<Achievement> get unlockedAchievements;
  
  /// Get next achievable achievements
  List<Achievement> getNextAchievements({int limit = 3});
}
```

#### Achievement Model

```dart
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon; // Emoji
  final AchievementRarity rarity; // bronze, silver, gold, platinum
  final AchievementCategory category; // learning, streaks, xp, special, engagement
  final bool isHidden; // Hide until unlocked
  final int maxProgress; // For incremental achievements (e.g., 100 lessons)
  
  // XP rewards by rarity
  int get xpReward {
    switch (rarity) {
      case AchievementRarity.bronze: return 50;
      case AchievementRarity.silver: return 100;
      case AchievementRarity.gold: return 150;
      case AchievementRarity.platinum: return 200;
    }
  }
}
```

### Common Pitfalls

❌ **Checking achievements too early** - Update user stats BEFORE checking achievements  
❌ **Showing duplicate notifications** - Always filter for `wasJustUnlocked`  
❌ **Not awaiting async checks** - Achievement checks are async, must await  
❌ **Missing check points** - Implement all integration points (lesson, tip, practice, social)  

### Testing

```bash
# Run achievement tests
flutter test test/services/achievement_service_test.dart
flutter test test/models/achievement_test.dart
```

---

## Feature 3: Hearts/Lives System

### Overview

Duolingo-style lives system where users start with 5 hearts, lose 1 per wrong answer, and can earn them back through practice mode or waiting for auto-refill (1 heart per 5 hours).

### Time to Integrate: 3-4 hours

### Step-by-Step Integration

#### Step 1: Update UserProfile Model (30 minutes)

```dart
// In lib/models/user_profile.dart (add these fields)
class UserProfile {
  // ... existing fields
  
  // Hearts system fields
  final int hearts; // Current hearts (0-5)
  final DateTime? lastHeartLost; // For refill calculations
  final bool unlimitedHeartsEnabled; // Settings toggle
  
  // Constructor
  UserProfile({
    // ... existing parameters
    this.hearts = 5,
    this.lastHeartLost,
    this.unlimitedHeartsEnabled = false,
  });
  
  // Extension methods
  bool get hasHearts => hearts > 0 || unlimitedHeartsEnabled;
  bool get needsRefill => hearts < 5 && !unlimitedHeartsEnabled;
  
  // Calculate hearts that should be refilled based on time
  int calculateRefillableHearts() {
    if (lastHeartLost == null || hearts >= 5) return 0;
    
    final timeSinceLastLoss = DateTime.now().difference(lastHeartLost!);
    const refillDuration = Duration(hours: 5);
    
    final heartsToRefill = (timeSinceLastLoss.inMilliseconds / 
                           refillDuration.inMilliseconds).floor();
    
    return (heartsToRefill).clamp(0, 5 - hearts);
  }
  
  // Get time until next heart refill
  Duration? getTimeUntilNextHeart() {
    if (hearts >= 5 || lastHeartLost == null) return null;
    
    const refillDuration = Duration(hours: 5);
    final timeSinceLastLoss = DateTime.now().difference(lastHeartLost!);
    final timeElapsedInCurrentPeriod = Duration(
      milliseconds: timeSinceLastLoss.inMilliseconds % refillDuration.inMilliseconds,
    );
    
    return refillDuration - timeElapsedInCurrentPeriod;
  }
  
  // JSON serialization (add to existing toJson/fromJson)
  Map<String, dynamic> toJson() => {
    // ... existing fields
    'hearts': hearts,
    'lastHeartLost': lastHeartLost?.toIso8601String(),
    'unlimitedHeartsEnabled': unlimitedHeartsEnabled,
  };
  
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      // ... existing fields
      hearts: json['hearts'] as int? ?? 5,
      lastHeartLost: json['lastHeartLost'] != null 
        ? DateTime.parse(json['lastHeartLost'] as String)
        : null,
      unlimitedHeartsEnabled: json['unlimitedHeartsEnabled'] as bool? ?? false,
    );
  }
}
```

#### Step 2: Add Hearts Provider Methods (30 minutes)

```dart
// In your user profile provider (or create HeartsService)
class UserProfileProvider extends StateNotifier<UserProfile> {
  // ... existing code
  
  /// Lose a heart (called on wrong answer)
  Future<void> loseHeart() async {
    if (state.unlimitedHeartsEnabled) return;
    if (state.hearts <= 0) return;
    
    state = state.copyWith(
      hearts: state.hearts - 1,
      lastHeartLost: DateTime.now(),
    );
    
    await _saveProfile();
  }
  
  /// Refill hearts based on elapsed time
  Future<void> refillHearts() async {
    final heartsToAdd = state.calculateRefillableHearts();
    if (heartsToAdd > 0) {
      state = state.copyWith(
        hearts: (state.hearts + heartsToAdd).clamp(0, 5),
      );
      await _saveProfile();
    }
  }
  
  /// Earn a heart from practice (max 5)
  Future<void> earnHeartFromPractice() async {
    if (state.hearts >= 5) return;
    
    state = state.copyWith(
      hearts: (state.hearts + 1).clamp(0, 5),
    );
    
    await _saveProfile();
  }
  
  /// Toggle unlimited hearts setting
  Future<void> toggleUnlimitedHearts(bool enabled) async {
    state = state.copyWith(
      unlimitedHeartsEnabled: enabled,
    );
    await _saveProfile();
  }
}
```

#### Step 3: Create HeartsDisplay Widget (45 minutes)

```dart
// Create lib/widgets/hearts_display.dart
import 'package:aquarium_app/widgets/hearts_widgets.dart';

// Use existing HeartsDisplay widget (already implemented)
// Located in lib/widgets/hearts_widgets.dart

// Example usage:
Widget build(BuildContext context) {
  return Consumer(
    builder: (context, ref, child) {
      final userProfile = ref.watch(userProfileProvider);
      
      return HeartsDisplay(
        hearts: userProfile.hearts,
        maxHearts: 5,
        showTimer: true,
        timeUntilNextHeart: userProfile.getTimeUntilNextHeart(),
        onTap: () => _showHeartsInfo(context),
      );
    },
  );
}
```

#### Step 4: Check Hearts Before Quiz (20 minutes)

```dart
// In lesson/quiz screen initialization
class _LessonScreenState extends State<LessonScreen> {
  @override
  void initState() {
    super.initState();
    _checkHeartsBeforeQuiz();
  }
  
  Future<void> _checkHeartsBeforeQuiz() async {
    final userProfile = ref.read(userProfileProvider);
    
    // Refill hearts based on time elapsed
    await ref.read(userProfileProvider.notifier).refillHearts();
    
    // Check if user has hearts
    if (!userProfile.hasHearts) {
      // Navigate to practice required screen
      if (mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PracticeRequiredScreen(),
          ),
        );
        
        // If user didn't complete practice, go back
        if (result != true && mounted) {
          Navigator.pop(context);
        }
      }
    }
  }
}
```

#### Step 5: Deduct Hearts on Wrong Answers (30 minutes)

```dart
// In quiz answer submission logic
Future<void> _onAnswerSubmitted(bool isCorrect) async {
  if (!isCorrect) {
    // Deduct a heart
    await ref.read(userProfileProvider.notifier).loseHeart();
    
    // Check if hearts depleted mid-quiz
    final userProfile = ref.read(userProfileProvider);
    if (!userProfile.hasHearts && mounted) {
      await _handleHeartsDepletedMidQuiz();
      return;
    }
  }
  
  // Continue with normal quiz logic
  _moveToNextQuestion();
}

Future<void> _handleHeartsDepletedMidQuiz() async {
  // Show dialog
  final shouldContinue = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Out of Hearts!'),
      content: const Text(
        'You\'ve run out of hearts. Complete a practice session to earn hearts, '
        'or wait for them to refill (1 heart per 5 hours).',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('End Lesson'),
        ),
        FilledButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PracticeModeScreen(),
              ),
            );
            if (context.mounted) {
              Navigator.pop(context, result == true);
            }
          },
          child: const Text('Practice Mode'),
        ),
      ],
    ),
  );
  
  if (shouldContinue != true && mounted) {
    // End lesson early
    Navigator.pop(context);
  }
}
```

#### Step 6: Create Practice Mode Screen (60 minutes)

```dart
// Practice mode is already implemented in:
// lib/screens/spaced_repetition_practice_screen.dart

// For dedicated hearts practice, create a simple wrapper:
import 'package:aquarium_app/screens/spaced_repetition_practice_screen.dart';

class PracticeModeScreen extends StatelessWidget {
  const PracticeModeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return SpacedRepetitionPracticeScreen(
      isPracticeMode: true, // Flag to indicate practice mode
      onComplete: (bool success) {
        if (success) {
          // Award a heart
          ref.read(userProfileProvider.notifier).earnHeartFromPractice();
        }
        Navigator.pop(context, success);
      },
    );
  }
}

// Or create a custom simple practice screen
class SimplePracticeModeScreen extends StatefulWidget {
  const SimplePracticeModeScreen({super.key});
  
  @override
  State<SimplePracticeModeScreen> createState() => _SimplePracticeModeScreenState();
}

class _SimplePracticeModeScreenState extends State<SimplePracticeModeScreen> {
  // Implement a simple quiz with unlimited attempts
  // Green-themed UI, reduced XP
  // Award 1 heart on completion
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Practice Mode'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Practice mode banner
          Container(
            color: Colors.green[100],
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.school, color: Colors.green),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Practice Mode: Learn safely without losing hearts!',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          // Quiz content here...
        ],
      ),
    );
  }
}
```

#### Step 7: Add Hearts Settings Toggle (15 minutes)

```dart
// In settings screen
import 'package:flutter_riverpod/flutter_riverpod.dart';

Consumer(
  builder: (context, ref, child) {
    final userProfile = ref.watch(userProfileProvider);
    
    return SwitchListTile(
      title: const Text('Unlimited Hearts'),
      subtitle: const Text('Disable hearts system for unrestricted learning'),
      value: userProfile.unlimitedHeartsEnabled,
      onChanged: (value) {
        ref.read(userProfileProvider.notifier).toggleUnlimitedHearts(value);
      },
      secondary: const Icon(Icons.favorite),
    );
  },
)
```

### API Reference

#### Hearts Methods

```dart
// UserProfile extensions
class UserProfile {
  /// Check if user has hearts available (considers unlimited mode)
  bool get hasHearts;
  
  /// Check if hearts need refilling
  bool get needsRefill;
  
  /// Calculate how many hearts should be refilled based on elapsed time
  /// 1 heart per 5 hours
  int calculateRefillableHearts();
  
  /// Get time until next heart refill
  /// Returns null if at max hearts or no refill pending
  Duration? getTimeUntilNextHeart();
}

// Provider methods
class UserProfileProvider {
  /// Deduct one heart (called on wrong answer)
  /// No effect if unlimited hearts enabled
  Future<void> loseHeart();
  
  /// Refill hearts based on time elapsed since last heart lost
  /// Should be called on app startup and before quizzes
  Future<void> refillHearts();
  
  /// Award one heart from practice completion
  /// Caps at 5 hearts maximum
  Future<void> earnHeartFromPractice();
  
  /// Toggle unlimited hearts mode
  Future<void> toggleUnlimitedHearts(bool enabled);
}
```

### Common Pitfalls

❌ **Not calling refillHearts() on app startup** - Hearts won't refill across app restarts  
❌ **Forgetting to check hasHearts before quiz** - Users may start quiz with 0 hearts  
❌ **Not handling mid-quiz depletion** - Quiz continues even when hearts = 0  
❌ **Missing practice mode exit** - Users feel trapped if they can't skip practice  

### Testing

```bash
# Run hearts system tests
flutter test test/hearts_system_test.dart
```

---

## Feature 4: Spaced Repetition System

### Overview

Implements forgetting curve algorithm for intelligent review scheduling. Cards are reviewed at increasing intervals based on performance, optimizing long-term retention.

### Time to Integrate: 4-6 hours

### Step-by-Step Integration

#### Step 1: Understand the Model (30 minutes)

```dart
// Review the spaced repetition models
// lib/models/spaced_repetition.dart

/// ReviewCard - Core unit representing a learnable concept
class ReviewCard {
  final String id;
  final String conceptId; // Reference to lesson/question
  final ConceptType conceptType; // lesson, question, term, concept
  final double strength; // 0.0 - 1.0 mastery level
  final DateTime lastReviewed;
  final DateTime nextReview; // When card is due
  final ReviewInterval currentInterval; // day1, day3, week1, week2, month1, etc.
  
  /// Check if card is due for review
  bool get isDue => DateTime.now().isAfter(nextReview);
  
  /// Check if card is weak (needs priority)
  bool get isWeak => strength < 0.5;
  
  /// Check if card is mastered
  bool get isStrong => strength >= 0.8;
  
  /// Get mastery level (new, learning, familiar, proficient, mastered)
  MasteryLevel get masteryLevel;
  
  /// Create new card after review attempt
  ReviewCard afterReview({required bool correct});
}

/// ReviewInterval - Predefined intervals based on forgetting curve
enum ReviewInterval {
  immediate,    // 0 hours (for failed reviews)
  hour4,        // 4 hours
  day1,         // 1 day
  day3,         // 3 days
  week1,        // 1 week
  week2,        // 2 weeks
  month1,       // 1 month
  month3,       // 3 months
  month6,       // 6 months
}
```

#### Step 2: Initialize Review Queue (45 minutes)

```dart
// When user completes a lesson, create review cards
import 'package:aquarium_app/models/spaced_repetition.dart';
import 'package:aquarium_app/providers/spaced_repetition_provider.dart';

Future<void> _onLessonCompleted() async {
  final reviewQueueProvider = ref.read(spacedRepetitionProvider.notifier);
  
  // Create review cards for important concepts
  final cards = <ReviewCard>[];
  
  // Create card for the lesson itself
  cards.add(ReviewCard(
    id: 'lesson_${widget.lesson.id}',
    conceptId: widget.lesson.id,
    conceptType: ConceptType.lesson,
    strength: _lessonScore, // Based on performance
    lastReviewed: DateTime.now(),
    nextReview: DateTime.now().add(const Duration(days: 1)),
    reviewCount: 1,
    correctCount: _totalCorrect,
    incorrectCount: _totalMistakes,
    currentInterval: ReviewInterval.day1,
    history: [],
  ));
  
  // Optionally create cards for individual questions
  for (final question in widget.lesson.questions) {
    if (_isImportantConcept(question)) {
      cards.add(ReviewCard(
        id: 'question_${question.id}',
        conceptId: question.id,
        conceptType: ConceptType.question,
        strength: _getQuestionScore(question.id),
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now().add(const Duration(days: 1)),
        currentInterval: ReviewInterval.day1,
      ));
    }
  }
  
  // Add cards to review queue
  await reviewQueueProvider.addCards(cards);
}

bool _isImportantConcept(Question question) {
  // Add cards for:
  // - Questions user got wrong
  // - Key concepts flagged in lesson data
  // - Terms/definitions
  return question.isKeyTopic || !_wasAnsweredCorrectly(question.id);
}
```

#### Step 3: Display Due Reviews (60 minutes)

```dart
// In home screen or dedicated review section
import 'package:aquarium_app/providers/spaced_repetition_provider.dart';
import 'package:aquarium_app/screens/spaced_repetition_practice_screen.dart';

Widget build(BuildContext context) {
  return Consumer(
    builder: (context, ref, child) {
      final reviewQueue = ref.watch(spacedRepetitionProvider);
      final dueCount = reviewQueue.getDueCount();
      final urgentCount = reviewQueue.getUrgentCount(); // Overdue by >1 day
      
      if (dueCount == 0) {
        return const SizedBox.shrink();
      }
      
      return Card(
        color: urgentCount > 0 ? Colors.red[50] : Colors.blue[50],
        child: ListTile(
          leading: Icon(
            urgentCount > 0 ? Icons.warning : Icons.refresh,
            color: urgentCount > 0 ? Colors.red : Colors.blue,
            size: 32,
          ),
          title: Text(
            '$dueCount Review${dueCount == 1 ? '' : 's'} Due',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            urgentCount > 0
              ? '$urgentCount urgent (overdue)'
              : 'Strengthen your knowledge',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SpacedRepetitionPracticeScreen(),
              ),
            );
            
            // Refresh after review session
            ref.invalidate(spacedRepetitionProvider);
          },
        ),
      );
    },
  );
}
```

#### Step 4: Implement Review Session (90 minutes)

```dart
// The review screen is already implemented!
// lib/screens/spaced_repetition_practice_screen.dart

// Basic usage:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const SpacedRepetitionPracticeScreen(
      maxCards: 20, // Optional: limit review session size
      focusOnWeak: true, // Optional: prioritize weak cards
    ),
  ),
);

// The screen handles:
// - Fetching due cards
// - Presenting questions
// - Recording answers
// - Updating card schedules
// - Showing progress

// For custom integration, handle review manually:
class CustomReviewScreen extends StatefulWidget {
  final List<ReviewCard> cards;
  
  @override
  State<CustomReviewScreen> createState() => _CustomReviewScreenState();
}

class _CustomReviewScreenState extends State<CustomReviewScreen> {
  int _currentIndex = 0;
  
  Future<void> _onAnswerSubmitted(bool correct) async {
    final card = widget.cards[_currentIndex];
    
    // Update card based on performance
    final updatedCard = card.afterReview(correct: correct);
    
    // Save updated card
    await ref.read(spacedRepetitionProvider.notifier).updateCard(updatedCard);
    
    // Move to next card
    if (_currentIndex < widget.cards.length - 1) {
      setState(() => _currentIndex++);
    } else {
      // Session complete
      _showSessionSummary();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.cards.length) {
      return _buildCompletionScreen();
    }
    
    final card = widget.cards[_currentIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Review ${_currentIndex + 1}/${widget.cards.length}'),
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentIndex + 1) / widget.cards.length,
          ),
          
          // Card strength indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Mastery: '),
                Expanded(
                  child: LinearProgressIndicator(
                    value: card.strength,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getStrengthColor(card.strength),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${(card.strength * 100).toInt()}%'),
              ],
            ),
          ),
          
          // Question content
          Expanded(
            child: _buildQuestionContent(card),
          ),
          
          // Answer buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () => _onAnswerSubmitted(false),
                    child: const Text('Incorrect'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () => _onAnswerSubmitted(true),
                    child: const Text('Correct'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getStrengthColor(double strength) {
    if (strength >= 0.8) return Colors.green;
    if (strength >= 0.5) return Colors.orange;
    return Colors.red;
  }
}
```

#### Step 5: Add Review Reminders (30 minutes)

```dart
// Schedule daily notification for due reviews
import 'package:aquarium_app/services/notification_service.dart';

Future<void> _scheduleDailyReviewReminder() async {
  final notificationService = NotificationService();
  
  // Check every day at 9 AM
  await notificationService.scheduleDailyNotification(
    id: 'daily_review_reminder',
    title: 'Review Time!',
    body: 'You have concepts due for review today.',
    time: const TimeOfDay(hour: 9, minute: 0),
    payload: 'review_screen',
  );
}

// On app startup, check and notify
Future<void> _checkReviewsOnStartup() async {
  final reviewQueue = ref.read(spacedRepetitionProvider);
  final dueCount = reviewQueue.getDueCount();
  
  if (dueCount > 0) {
    // Show in-app notification or badge
    _showReviewBadge(dueCount);
  }
}
```

#### Step 6: Analytics Integration (45 minutes)

```dart
// Track review statistics
import 'package:aquarium_app/services/analytics_service.dart';

Future<void> _trackReviewSession({
  required int cardsReviewed,
  required int correctCount,
  required int incorrectCount,
  required Duration sessionDuration,
}) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  
  await analyticsService.recordReviewSession(
    cardsReviewed: cardsReviewed,
    accuracy: correctCount / cardsReviewed,
    duration: sessionDuration,
    timestamp: DateTime.now(),
  );
  
  // Update user profile stats
  final profile = ref.read(userProfileProvider);
  final updatedProfile = profile.copyWith(
    totalReviewsCompleted: profile.totalReviewsCompleted + cardsReviewed,
    reviewAccuracy: _calculateNewAverage(
      profile.reviewAccuracy,
      correctCount / cardsReviewed,
      profile.totalReviewsCompleted,
    ),
  );
  
  await ref.read(userProfileProvider.notifier).updateProfile(updatedProfile);
}
```

### API Reference

#### SpacedRepetitionProvider

```dart
class SpacedRepetitionProvider extends StateNotifier<ReviewQueue> {
  /// Add new review cards to the queue
  Future<void> addCards(List<ReviewCard> cards);
  
  /// Update an existing card (after review)
  Future<void> updateCard(ReviewCard card);
  
  /// Remove a card from the queue
  Future<void> removeCard(String cardId);
  
  /// Get all due cards (nextReview <= now)
  List<ReviewCard> getDueCards();
  
  /// Get urgent cards (overdue by >1 day)
  List<ReviewCard> getUrgentCards();
  
  /// Get weak cards (strength < 0.5)
  List<ReviewCard> getWeakCards();
  
  /// Get count of due reviews
  int getDueCount();
  
  /// Get statistics
  ReviewStatistics getStatistics();
}

class ReviewQueue {
  /// All review cards
  final List<ReviewCard> cards;
  
  /// Get due count
  int getDueCount() => cards.where((c) => c.isDue).length;
  
  /// Get urgent count (overdue >1 day)
  int getUrgentCount() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return cards.where((c) => c.nextReview.isBefore(yesterday)).length;
  }
  
  /// Get average strength
  double getAverageStrength() {
    if (cards.isEmpty) return 0.0;
    return cards.map((c) => c.strength).reduce((a, b) => a + b) / cards.length;
  }
}
```

#### ReviewCard Methods

```dart
class ReviewCard {
  /// Create updated card after review attempt
  /// Adjusts strength (+0.2 for correct, -0.3 for incorrect)
  /// Calculates next review interval based on new strength
  ReviewCard afterReview({
    required bool correct,
    DateTime? reviewedAt,
  });
  
  /// Check if due for review
  bool get isDue;
  
  /// Check if weak (priority review)
  bool get isWeak;
  
  /// Check if mastered
  bool get isStrong;
  
  /// Get mastery level
  MasteryLevel get masteryLevel; // new, learning, familiar, proficient, mastered
  
  /// Calculate success rate
  double get successRate;
}
```

### Common Pitfalls

❌ **Creating too many cards** - Only create cards for key concepts, not every question  
❌ **Not prioritizing weak cards** - Focus on cards with low strength first  
❌ **Ignoring overdue cards** - Urgent cards should be reviewed immediately  
❌ **No review reminders** - Users forget to review without notifications  
❌ **Poor card content** - Cards should be clear, focused questions  

### Testing

```bash
# Run spaced repetition tests
flutter test test/models/spaced_repetition_test.dart
```

---

## Feature 5: Analytics Dashboard

### Overview

Comprehensive progress tracking dashboard with daily/weekly stats, XP trends, topic analysis, and performance insights.

### Time to Integrate: 2-3 hours

### Step-by-Step Integration

#### Step 1: Record Daily Stats (45 minutes)

```dart
// Update UserProfile with analytics data
// In lib/models/user_profile.dart (add field)
class UserProfile {
  // ... existing fields
  final Map<String, DailyStats> dailyStats; // dateKey -> stats
  
  // Add to constructor and serialization
}

// After each lesson/activity, update daily stats
import 'package:aquarium_app/models/analytics.dart';
import 'package:aquarium_app/services/analytics_service.dart';

Future<void> _updateDailyStats({
  required int xpEarned,
  required int practiceMinutes,
  required String topicId,
  String? activityId,
}) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  
  await analyticsService.recordActivity(
    date: DateTime.now(),
    xp: xpEarned,
    lessonsCompleted: 1,
    practiceMinutes: practiceMinutes,
    topicId: topicId,
    activityId: activityId,
  );
}

// Example: After lesson completion
Future<void> _onLessonCompleted() async {
  final xpEarned = 10;
  final practiceMinutes = (_lessonDuration.inSeconds / 60).ceil();
  
  await _updateDailyStats(
    xpEarned: xpEarned,
    practiceMinutes: practiceMinutes,
    topicId: widget.lesson.pathId,
    activityId: widget.lesson.id,
  );
  
  // Rest of lesson completion logic...
}
```

#### Step 2: Navigate to Analytics Screen (10 minutes)

```dart
// In main navigation or home screen
ListTile(
  leading: const Icon(Icons.insights),
  title: const Text('Analytics'),
  subtitle: const Text('View your progress and insights'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () {
    Navigator.pushNamed(context, 'analytics');
    // Or: context.go('/analytics');
  },
)
```

#### Step 3: Display Mini Analytics Widget (30 minutes)

```dart
// In home screen - show quick stats summary
import 'package:aquarium_app/widgets/mini_analytics_widget.dart';

Widget build(BuildContext context) {
  return Consumer(
    builder: (context, ref, child) {
      final analyticsService = ref.watch(analyticsServiceProvider);
      final todayStats = analyticsService.getTodayStats();
      final weekStats = analyticsService.getWeekStats();
      
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Today's stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    icon: Icons.auto_awesome,
                    label: 'Today XP',
                    value: '${todayStats.xp}',
                    color: Colors.amber,
                  ),
                  _buildStatColumn(
                    icon: Icons.timer,
                    label: 'Minutes',
                    value: '${todayStats.practiceMinutes}',
                    color: Colors.blue,
                  ),
                  _buildStatColumn(
                    icon: Icons.school,
                    label: 'Lessons',
                    value: '${todayStats.lessonsCompleted}',
                    color: Colors.green,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Weekly summary
              Text(
                'This week: ${weekStats.totalXP} XP • ${weekStats.lessonsCompleted} lessons',
                style: TextStyle(color: Colors.grey[600]),
              ),
              
              const SizedBox(height: 8),
              
              // View full analytics button
              TextButton(
                onPressed: () => Navigator.pushNamed(context, 'analytics'),
                child: const Text('View Full Analytics →'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildStatColumn({
  required IconData icon,
  required String label,
  required String value,
  required Color color,
}) {
  return Column(
    children: [
      Icon(icon, color: color, size: 32),
      const SizedBox(height: 8),
      Text(
        value,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
    ],
  );
}
```

#### Step 4: Customize Analytics Screen (60 minutes)

```dart
// The analytics screen is already implemented at:
// lib/screens/analytics_screen.dart

// It includes:
// - Daily XP chart (last 7 days)
// - Weekly trends
// - Topic breakdown
// - Performance metrics
// - Streak calendar
// - Learning insights

// To customize, you can:

// 1. Add custom metrics
class AnalyticsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsService = ref.watch(analyticsServiceProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Existing charts...
          _buildDailyXPChart(analyticsService),
          _buildWeeklyTrends(analyticsService),
          _buildTopicBreakdown(analyticsService),
          
          // Add your custom section
          _buildCustomMetric(analyticsService),
        ],
      ),
    );
  }
  
  Widget _buildCustomMetric(AnalyticsService service) {
    // Add custom analytics here
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Custom Metric',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Your custom visualization
          ],
        ),
      ),
    );
  }
}
```

### API Reference

#### AnalyticsService

```dart
class AnalyticsService {
  /// Record daily activity
  Future<void> recordActivity({
    required DateTime date,
    required int xp,
    required int lessonsCompleted,
    required int practiceMinutes,
    required String topicId,
    String? activityId,
  });
  
  /// Get stats for today
  DailyStats getTodayStats();
  
  /// Get stats for a specific date
  DailyStats getStatsForDate(DateTime date);
  
  /// Get stats for date range
  List<DailyStats> getStatsForRange(DateTime start, DateTime end);
  
  /// Get current week stats
  WeeklyStats getWeekStats();
  
  /// Get weekly stats for specific week
  WeeklyStats getWeekStatsFor(DateTime weekStart);
  
  /// Get XP by topic
  Map<String, int> getXPByTopic({DateTime? since});
  
  /// Get learning insights
  List<LearningInsight> getInsights();
  
  /// Calculate streak
  int calculateStreak();
  
  /// Get peak learning time
  TimeOfDay getPeakLearningTime();
}
```

#### Models

```dart
class DailyStats {
  final DateTime date;
  final int xp;
  final int lessonsCompleted;
  final int practiceMinutes;
  final int timeSpentSeconds;
  final Map<String, int> topicXp; // Topic-specific XP
  final List<String> activitiesCompleted;
  
  String get dateKey; // YYYY-MM-DD format
}

class WeeklyStats {
  final DateTime weekStart;
  final int totalXP;
  final int lessonsCompleted;
  final double avgDailyXP;
  final int peakDayXP;
  final DateTime peakDay;
  final int daysActive;
  final Map<String, int> topicXp;
}

class LearningInsight {
  final String title;
  final String description;
  final InsightType type; // positive, warning, suggestion
  final IconData icon;
}
```

### Common Pitfalls

❌ **Not recording every activity** - Miss recording = inaccurate analytics  
❌ **Storing too much data** - Keep rolling window (e.g., last 90 days)  
❌ **Complex queries on main thread** - Use isolates for heavy calculations  
❌ **No data validation** - Validate dates and values before storing  

### Testing

```bash
# Test analytics service
flutter test test/services/analytics_service_test.dart
```

---

## Feature 6: Social/Friends Features

### Overview

Social features including friend profiles, activity feeds, comparison screens, and leaderboards to create a motivating community.

### Time to Integrate: 2-3 hours

### Step-by-Step Integration

#### Step 1: Add Friends to UserProfile (20 minutes)

```dart
// In lib/models/user_profile.dart (already has friends field)
class UserProfile {
  final List<String> friends; // List of friend user IDs
  
  // Already implemented in model
}

// Friend model is in lib/models/friend.dart
class Friend {
  final String id;
  final String username;
  final String displayName;
  final int level;
  final int xp;
  final int currentStreak;
  final String? avatarUrl;
  final DateTime lastActive;
  
  // ... methods
}
```

#### Step 2: Add Friend (30 minutes)

```dart
// Add friend functionality
import 'package:aquarium_app/providers/friends_provider.dart';
import 'package:aquarium_app/models/friend.dart';

Future<void> _addFriend(String username) async {
  final friendsProvider = ref.read(friendsProviderNotifier);
  
  try {
    // In real app, this would call backend API
    // For now, using mock data
    final friend = await friendsProvider.addFriend(username);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${friend.displayName} as friend!')),
      );
    }
    
    // Check for achievement unlock
    final userProfile = ref.read(userProfileProvider);
    if (userProfile.friends.length >= 10) {
      // Unlock "Social Butterfly" achievement
      await ref.read(achievementCheckerProvider).checkAfterSocialAction(
        friendsCount: userProfile.friends.length,
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding friend: $e')),
      );
    }
  }
}

// UI for adding friend
Future<void> _showAddFriendDialog() async {
  final controller = TextEditingController();
  
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add Friend'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Username',
          hintText: 'Enter username',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            _addFriend(controller.text);
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
```

#### Step 3: Display Friends Screen (30 minutes)

```dart
// Navigate to friends screen (already implemented)
// lib/screens/friends_screen.dart

Navigator.pushNamed(context, 'friends');

// The screen includes:
// - List of friends with stats
// - Add friend button
// - Remove friend option
// - View friend profile
// - Compare with friend

// Example friend list widget:
Widget _buildFriendsList() {
  return Consumer(
    builder: (context, ref, child) {
      final friends = ref.watch(friendsProvider);
      
      if (friends.isEmpty) {
        return const Center(
          child: Text('No friends yet. Add some friends to get started!'),
        );
      }
      
      return ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: friend.avatarUrl != null
                ? NetworkImage(friend.avatarUrl!)
                : null,
              child: friend.avatarUrl == null
                ? Text(friend.displayName[0].toUpperCase())
                : null,
            ),
            title: Text(friend.displayName),
            subtitle: Text(
              'Level ${friend.level} • ${friend.xp} XP • ${friend.currentStreak} day streak',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (friend.isOnline)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () => _viewFriendProfile(friend),
          );
        },
      );
    },
  );
}
```

#### Step 4: Friend Comparison Screen (45 minutes)

```dart
// Navigate to comparison (already implemented)
// lib/screens/friend_comparison_screen.dart

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => FriendComparisonScreen(
      friend: selectedFriend,
      currentUser: userProfile,
    ),
  ),
);

// The screen shows:
// - Side-by-side stat comparison
// - XP trends chart
// - Achievements comparison
// - Topic strengths comparison

// Example comparison widget:
Widget _buildStatComparison(Friend friend, UserProfile user) {
  return Column(
    children: [
      _buildComparisonRow(
        label: 'XP',
        userValue: user.xp,
        friendValue: friend.xp,
        icon: Icons.auto_awesome,
      ),
      _buildComparisonRow(
        label: 'Streak',
        userValue: user.currentStreak,
        friendValue: friend.currentStreak,
        icon: Icons.local_fire_department,
      ),
      _buildComparisonRow(
        label: 'Lessons',
        userValue: user.lessonsCompleted,
        friendValue: friend.lessonsCompleted,
        icon: Icons.school,
      ),
    ],
  );
}

Widget _buildComparisonRow({
  required String label,
  required int userValue,
  required int friendValue,
  required IconData icon,
}) {
  final userAhead = userValue > friendValue;
  final difference = (userValue - friendValue).abs();
  
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        // User stat
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$userValue',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: userAhead ? Colors.green : Colors.grey,
                ),
              ),
              if (userAhead)
                Text(
                  '+$difference',
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                ),
            ],
          ),
        ),
        
        // Icon & label
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 4),
              Text(label),
            ],
          ),
        ),
        
        // Friend stat
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$friendValue',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: !userAhead ? Colors.green : Colors.grey,
                ),
              ),
              if (!userAhead)
                Text(
                  '+$difference',
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
```

#### Step 5: Activity Feed (30 minutes)

```dart
// Display friend activities
// lib/widgets/friend_activity_widget.dart (already implemented)

import 'package:aquarium_app/widgets/friend_activity_widget.dart';

Widget build(BuildContext context) {
  return Consumer(
    builder: (context, ref, child) {
      final activities = ref.watch(friendActivitiesProvider);
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Friend Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          
          if (activities.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No recent activity'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return FriendActivityCard(activity: activity);
              },
            ),
        ],
      );
    },
  );
}
```

#### Step 6: Leaderboard (15 minutes)

```dart
// Navigate to leaderboard (already implemented)
// lib/screens/leaderboard_screen.dart

Navigator.pushNamed(context, 'leaderboard');

// The screen shows:
// - Global leaderboard (if backend connected)
// - Friends leaderboard
// - Weekly/monthly/all-time views
// - User's rank

// Example leaderboard entry:
Widget _buildLeaderboardEntry({
  required int rank,
  required Friend friend,
  required bool isCurrentUser,
}) {
  return Container(
    color: isCurrentUser ? Colors.blue[50] : null,
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        // Rank
        SizedBox(
          width: 40,
          child: Text(
            '#$rank',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: rank <= 3 ? Colors.amber : Colors.grey,
            ),
          ),
        ),
        
        // Trophy for top 3
        if (rank <= 3)
          Icon(
            Icons.emoji_events,
            color: rank == 1 ? Colors.amber : 
                   rank == 2 ? Colors.grey[400] :
                   Colors.brown,
          ),
        
        const SizedBox(width: 12),
        
        // Avatar
        CircleAvatar(
          backgroundImage: friend.avatarUrl != null
            ? NetworkImage(friend.avatarUrl!)
            : null,
          child: friend.avatarUrl == null
            ? Text(friend.displayName[0])
            : null,
        ),
        
        const SizedBox(width: 12),
        
        // Name & level
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                friend.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Level ${friend.level}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        
        // XP
        Text(
          '${friend.xp} XP',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}
```

### API Reference

#### FriendsProvider

```dart
class FriendsProvider extends StateNotifier<List<Friend>> {
  /// Add friend by username
  /// Returns Friend object or throws error
  Future<Friend> addFriend(String username);
  
  /// Remove friend
  Future<void> removeFriend(String friendId);
  
  /// Get friend by ID
  Friend? getFriend(String friendId);
  
  /// Get friend activities
  List<FriendActivity> getActivities({int limit = 20});
  
  /// Update friend data (call periodically)
  Future<void> refreshFriends();
}
```

#### Friend Model

```dart
class Friend {
  final String id;
  final String username;
  final String displayName;
  final int level;
  final int xp;
  final int currentStreak;
  final int lessonsCompleted;
  final String? avatarUrl;
  final DateTime lastActive;
  final List<String> achievements; // Achievement IDs
  
  /// Check if friend is currently online
  bool get isOnline {
    return DateTime.now().difference(lastActive).inMinutes < 5;
  }
}
```

### Common Pitfalls

❌ **No backend integration** - Friends won't persist without server  
❌ **Privacy concerns** - Always get user consent before sharing data  
❌ **Stale friend data** - Refresh periodically  
❌ **No offline mode** - Cache friend data locally  

### Testing

```bash
# Test friends provider
flutter test test/providers/friends_provider_test.dart
```

---

## Database Schema Updates

### UserProfile Schema Changes

```dart
// Updated UserProfile model with all Wave 3 fields
class UserProfile {
  // Existing fields
  final String id;
  final String username;
  final String displayName;
  final int xp;
  final int level;
  final int lessonsCompleted;
  
  // Wave 3: Adaptive Difficulty
  final UserSkillProfile? skillProfile;
  
  // Wave 3: Achievements
  final List<String> unlockedAchievements;
  final Map<String, AchievementProgress> achievementProgress;
  
  // Wave 3: Hearts System
  final int hearts;
  final DateTime? lastHeartLost;
  final bool unlimitedHeartsEnabled;
  
  // Wave 3: Spaced Repetition
  final int totalReviewsCompleted;
  final double reviewAccuracy;
  
  // Wave 3: Analytics
  final Map<String, DailyStats> dailyStats; // dateKey -> stats
  final int currentStreak;
  final DateTime? lastActivityDate;
  
  // Wave 3: Social
  final List<String> friends;
  final String? avatarUrl;
  
  // ... rest of model
}
```

### Migration Script

```dart
// Run this migration for existing users
Future<UserProfile> migrateToWave3(UserProfile oldProfile) async {
  return oldProfile.copyWith(
    // Initialize adaptive difficulty
    skillProfile: UserSkillProfile.empty(),
    
    // Initialize achievements
    unlockedAchievements: [],
    achievementProgress: {},
    
    // Initialize hearts (full)
    hearts: 5,
    lastHeartLost: null,
    unlimitedHeartsEnabled: false,
    
    // Initialize reviews
    totalReviewsCompleted: 0,
    reviewAccuracy: 0.0,
    
    // Initialize analytics
    dailyStats: {},
    currentStreak: 0,
    lastActivityDate: DateTime.now(),
    
    // Initialize social
    friends: [],
    avatarUrl: null,
  );
}

// Apply migration on app startup
Future<void> _checkAndMigrateUserProfile() async {
  final profile = await ref.read(storageProvider).loadUserProfile();
  
  // Check if migration needed
  if (profile.skillProfile == null) {
    final migratedProfile = await migrateToWave3(profile);
    await ref.read(storageProvider).saveUserProfile(migratedProfile);
  }
}
```

### Storage Size Considerations

```dart
// Estimated storage per user:
// - UserSkillProfile: ~2-5 KB (depends on topics)
// - Achievement progress: ~3-5 KB (47 achievements)
// - Daily stats (90 days): ~15-20 KB
// - Review cards: ~1 KB per card
// Total: ~25-40 KB per user

// Cleanup old data periodically:
Future<void> cleanupOldData() async {
  final profile = ref.read(userProfileProvider);
  
  // Remove daily stats older than 90 days
  final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
  final cleanedStats = Map.fromEntries(
    profile.dailyStats.entries.where((entry) {
      final date = DateTime.parse(entry.key);
      return date.isAfter(cutoffDate);
    }),
  );
  
  final cleanedProfile = profile.copyWith(dailyStats: cleanedStats);
  await ref.read(storageProvider).saveUserProfile(cleanedProfile);
}
```

---

## Testing Guide

### Running All Tests

```bash
# Run all Wave 3 tests
flutter test test/services/difficulty_service_test.dart
flutter test test/services/achievement_service_test.dart
flutter test test/hearts_system_test.dart
flutter test test/models/spaced_repetition_test.dart
flutter test test/services/analytics_service_test.dart
flutter test test/providers/friends_provider_test.dart

# Run all tests at once
flutter test
```

### Writing Custom Tests

#### Example: Testing Adaptive Difficulty

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/services/difficulty_service.dart';
import 'package:aquarium_app/models/adaptive_difficulty.dart';

void main() {
  group('Custom Difficulty Tests', () {
    late DifficultyService service;
    
    setUp(() {
      service = DifficultyService();
    });
    
    test('should recommend Easy for new users', () {
      final profile = UserSkillProfile.empty();
      final recommendation = service.getDifficultyRecommendation(
        topicId: 'test_topic',
        profile: profile,
      );
      
      expect(recommendation.suggestedLevel, DifficultyLevel.easy);
    });
    
    test('should increase difficulty after 3 perfect answers', () {
      final attempts = List.generate(3, (i) => PerformanceRecord(
        timestamp: DateTime.now(),
        topicId: 'test',
        difficulty: DifficultyLevel.easy,
        score: 1,
        maxScore: 1,
        mistakeCount: 0,
        timeSpent: const Duration(seconds: 30),
        completed: true,
      ));
      
      final newDifficulty = service.checkForMidLessonAdjustment(
        currentDifficulty: DifficultyLevel.easy,
        lessonAttempts: attempts,
      );
      
      expect(newDifficulty, DifficultyLevel.medium);
    });
  });
}
```

#### Example: Testing Achievement Unlocks

```dart
test('should unlock First Steps achievement after first lesson', () async {
  final checker = AchievementChecker();
  
  final results = await checker.checkAfterLesson(
    lessonsCompleted: 1,
    currentStreak: 1,
    totalXp: 10,
    perfectScores: 0,
    lessonCompletedAt: DateTime.now(),
    lessonDuration: 300,
    lessonScore: 0.8,
    todayLessonsCompleted: 1,
    completedLessonIds: ['lesson_1'],
  );
  
  final firstSteps = results.firstWhere(
    (r) => r.achievement.id == 'first_steps',
  );
  
  expect(firstSteps.wasJustUnlocked, true);
  expect(firstSteps.xpAwarded, 50); // Bronze achievement
});
```

### Manual Testing Checklist

```markdown
## Adaptive Difficulty
- [ ] Complete lesson with good performance → difficulty increases
- [ ] Complete lesson with poor performance → difficulty decreases
- [ ] Mid-lesson adjustment triggers correctly
- [ ] Skill level updates after lesson
- [ ] Manual difficulty override works
- [ ] Difficulty settings screen displays correctly

## Achievements
- [ ] First lesson unlocks "First Steps"
- [ ] 7-day streak unlocks "Week Warrior"
- [ ] Achievement notification displays with confetti
- [ ] XP reward is added to profile
- [ ] Achievement screen filters work
- [ ] Progress bars display correctly

## Hearts System
- [ ] Start with 5 hearts
- [ ] Wrong answer deducts 1 heart
- [ ] Out of hearts blocks quiz start
- [ ] Practice mode awards 1 heart
- [ ] Hearts refill over time (1 per 5 hours)
- [ ] Unlimited hearts toggle works
- [ ] Timer displays correctly

## Spaced Repetition
- [ ] Review cards created after lesson
- [ ] Due count displays correctly
- [ ] Review session updates card schedules
- [ ] Weak cards prioritized
- [ ] Mastery level increases with correct answers
- [ ] Review reminders work

## Analytics
- [ ] Daily stats record correctly
- [ ] XP chart displays last 7 days
- [ ] Weekly summary calculates correctly
- [ ] Topic breakdown shows all topics
- [ ] Streak calculation is accurate
- [ ] Peak learning time detected

## Social/Friends
- [ ] Can add friend by username
- [ ] Friend list displays correctly
- [ ] Comparison screen shows stats
- [ ] Activity feed updates
- [ ] Leaderboard ranks correctly
- [ ] Friend removal works
```

### Test Coverage Report

```bash
# Generate test coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Expected coverage:
# - Models: >90%
# - Services: >85%
# - Providers: >80%
# - Widgets: >70% (UI tests harder to cover)
```

---

## Troubleshooting FAQ

### Adaptive Difficulty

**Q: Skill levels not updating after lesson?**
```dart
// Make sure you're calling updateProfileAfterLesson
final updatedProfile = difficultyService.updateProfileAfterLesson(
  currentProfile: skillProfile,
  lessonRecord: lessonRecord,
);

// And saving the updated profile
await ref.read(storageProvider).saveUserProfile(
  userProfile.copyWith(skillProfile: updatedProfile),
);
```

**Q: Recommendations seem inaccurate?**
- Need at least 3-5 attempts for accurate recommendations
- Check that topicId matches between lessons and profile
- Verify performance records are being added correctly

**Q: Mid-lesson adjustments not triggering?**
- Must have 3+ consecutive perfect (for increase) or failed (for decrease) answers
- Check that lessonAttempts list is accumulating correctly

### Achievements

**Q: Achievements not unlocking?**
- Verify stats are updated BEFORE calling checkAfterLesson
- Check achievement logic matches your use case
- Ensure wasJustUnlocked filter is applied when showing notifications

**Q: Duplicate notifications showing?**
```dart
// Always filter for newly unlocked
for (final result in newAchievements.where((r) => r.wasJustUnlocked)) {
  await AchievementNotification.show(context, result.achievement, result.xpAwarded);
}
```

**Q: Progress not saving?**
- Check SharedPreferences initialization
- Verify JSON serialization works
- Ensure async/await is used correctly

### Hearts System

**Q: Hearts not refilling?**
```dart
// Call refillHearts() on app startup and before quizzes
await ref.read(userProfileProvider.notifier).refillHearts();
```

**Q: Timer showing wrong time?**
- Verify lastHeartLost is being set when hearts are lost
- Check timezone handling in Duration calculations

**Q: Practice mode not awarding hearts?**
```dart
// Ensure earnHeartFromPractice() is called on completion
await ref.read(userProfileProvider.notifier).earnHeartFromPractice();
```

### Spaced Repetition

**Q: Too many review cards?**
- Only create cards for key concepts and mistakes
- Limit cards per lesson (e.g., max 5)
- Batch similar concepts into single cards

**Q: Review intervals seem off?**
- Check that afterReview() is being called with correct flag
- Verify strength is being calculated properly
- Review interval calculation is based on strength level

**Q: Cards not saving?**
```dart
// Ensure updateCard is called and awaited
await ref.read(spacedRepetitionProvider.notifier).updateCard(updatedCard);
```

### Analytics

**Q: Daily stats not recording?**
- Verify recordActivity is called after each lesson/activity
- Check that date keys are formatted correctly (YYYY-MM-DD)
- Ensure async operations are awaited

**Q: Charts showing no data?**
- Need at least 2 days of data for meaningful charts
- Verify date range is correct
- Check that stats are being retrieved properly

### Social/Friends

**Q: Can't add friends?**
- Backend integration required for real friend system
- For development, use mock data
- Verify username exists in system

**Q: Friend data stale?**
```dart
// Refresh friend data periodically
await ref.read(friendsProvider.notifier).refreshFriends();
```

**Q: Comparison showing wrong stats?**
- Ensure both user and friend profiles are up-to-date
- Verify stat calculations are consistent
- Check for timezone issues with timestamps

### General Issues

**Q: App crashing after Wave 3 integration?**
1. Check for null safety issues (use ? and ??)
2. Ensure all async operations are awaited
3. Verify JSON serialization for new fields
4. Check that ProviderScope wraps app

**Q: Performance issues?**
```dart
// Use pagination for large lists
itemCount: min(items.length, 50),

// Cache expensive calculations
final _cachedStats = useMemoized(() => calculateStats());

// Use const where possible
const Icon(Icons.star),
```

**Q: Storage quota exceeded?**
```dart
// Clean up old data periodically (every 90 days)
await cleanupOldData();

// Limit history sizes
const maxPerformanceRecords = 10;
const maxDailyStats = 90;
```

---

## Migration Guide

### From No Wave 3 → Full Wave 3

#### Step 1: Backup Existing Data (CRITICAL)

```dart
// Before migration, backup user data
import 'package:aquarium_app/services/backup_service.dart';

Future<void> backupBeforeMigration() async {
  final backupService = BackupService();
  
  final backupPath = await backupService.createBackup(
    includePhotos: false, // Faster migration
  );
  
  print('Backup created at: $backupPath');
  // Store this path in case rollback is needed
}
```

#### Step 2: Update Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^2.4.0  # Already present
  shared_preferences: ^2.2.0  # Already present
  fl_chart: ^0.65.0  # For analytics charts
  confetti: ^0.7.0  # For achievement celebrations
```

```bash
flutter pub get
```

#### Step 3: Migrate UserProfile Model

```dart
// Create migration function
Future<void> migrateUserProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final profileJson = prefs.getString('user_profile');
  
  if (profileJson == null) return;
  
  final oldProfile = UserProfile.fromJson(jsonDecode(profileJson));
  
  // Add Wave 3 fields with defaults
  final migratedProfile = oldProfile.copyWith(
    // Adaptive Difficulty
    skillProfile: UserSkillProfile.empty(),
    
    // Achievements
    unlockedAchievements: [],
    achievementProgress: {},
    
    // Hearts
    hearts: 5,
    lastHeartLost: null,
    unlimitedHeartsEnabled: false,
    
    // Spaced Repetition
    totalReviewsCompleted: 0,
    reviewAccuracy: 0.0,
    
    // Analytics
    dailyStats: {},
    currentStreak: _calculateExistingStreak(oldProfile),
    lastActivityDate: DateTime.now(),
    
    // Social
    friends: [],
    avatarUrl: null,
  );
  
  // Save migrated profile
  await prefs.setString(
    'user_profile',
    jsonEncode(migratedProfile.toJson()),
  );
  
  print('✅ UserProfile migrated successfully');
}

int _calculateExistingStreak(UserProfile profile) {
  // Calculate streak from existing data if available
  // Otherwise start fresh
  return 0;
}
```

#### Step 4: Run Migration on App Startup

```dart
// In main.dart or app initialization
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Run migration before app starts
  await _runMigrations();
  
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _runMigrations() async {
  final prefs = await SharedPreferences.getInstance();
  final migrationVersion = prefs.getInt('migration_version') ?? 0;
  
  if (migrationVersion < 3) {
    print('Running Wave 3 migration...');
    
    try {
      // Backup first
      await backupBeforeMigration();
      
      // Run migration
      await migrateUserProfile();
      
      // Mark migration complete
      await prefs.setInt('migration_version', 3);
      
      print('✅ Migration complete!');
    } catch (e) {
      print('❌ Migration failed: $e');
      print('Restore from backup if needed');
      rethrow;
    }
  }
}
```

#### Step 5: Initialize Wave 3 Features

```dart
// Initialize features after migration
class MyApp extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeWave3Features();
  }
  
  Future<void> _initializeWave3Features() async {
    // Refill hearts based on time elapsed
    await ref.read(userProfileProvider.notifier).refillHearts();
    
    // Initialize review queue
    await ref.read(spacedRepetitionProvider.notifier).loadReviewQueue();
    
    // Check for daily achievements (comeback, etc.)
    await _checkDailyAchievements();
    
    // Refresh friend data
    await ref.read(friendsProvider.notifier).refreshFriends();
  }
  
  Future<void> _checkDailyAchievements() async {
    final userProfile = ref.read(userProfileProvider);
    final achievementChecker = ref.read(achievementCheckerProvider);
    
    // Check for comeback achievement
    if (userProfile.lastActivityDate != null) {
      final daysSinceLastActivity = DateTime.now()
        .difference(userProfile.lastActivityDate!)
        .inDays;
      
      if (daysSinceLastActivity >= 30) {
        await achievementChecker.checkAfterLesson(
          lessonsCompleted: userProfile.lessonsCompleted,
          currentStreak: 0, // Reset after long break
          totalXp: userProfile.xp,
          perfectScores: userProfile.perfectScores ?? 0,
          lessonCompletedAt: DateTime.now(),
          lessonDuration: 0,
          lessonScore: 0,
          todayLessonsCompleted: 0,
          completedLessonIds: userProfile.completedLessons,
        );
      }
    }
  }
}
```

#### Step 6: Gradual Feature Rollout

```dart
// Use feature flags for gradual rollout
class FeatureFlags {
  static const bool adaptiveDifficultyEnabled = true;
  static const bool achievementsEnabled = true;
  static const bool heartsSystemEnabled = true;
  static const bool spacedRepetitionEnabled = true;
  static const bool analyticsEnabled = true;
  static const bool socialFeaturesEnabled = false; // Rollout last
}

// In your code, check flags before showing features
if (FeatureFlags.heartsSystemEnabled) {
  return HeartsDisplay(...);
} else {
  return const SizedBox.shrink();
}
```

#### Step 7: Monitor Migration

```dart
// Track migration success
import 'package:aquarium_app/services/analytics_service.dart';

Future<void> _trackMigrationSuccess() async {
  final analytics = AnalyticsService();
  
  await analytics.logEvent(
    'wave3_migration_complete',
    parameters: {
      'timestamp': DateTime.now().toIso8601String(),
      'user_lessons_completed': userProfile.lessonsCompleted,
      'user_xp': userProfile.xp,
    },
  );
}
```

### Rollback Plan

If migration fails:

```dart
// Restore from backup
Future<void> rollbackMigration() async {
  final backupService = BackupService();
  
  // Load backup (use stored backup path)
  await backupService.restoreBackup(backupPath);
  
  // Reset migration version
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('migration_version', 2);
  
  print('✅ Rolled back to pre-Wave 3 state');
}
```

### Post-Migration Checklist

```markdown
- [ ] All existing user data preserved
- [ ] New fields initialized with sensible defaults
- [ ] App starts without crashes
- [ ] Existing features still work
- [ ] Wave 3 features accessible
- [ ] No data loss reported
- [ ] Performance is acceptable
- [ ] Analytics tracking migration success
- [ ] Backup created before migration
- [ ] Rollback plan tested
```

---

## Summary

You've now integrated all 6 Wave 3 features! Here's what you've accomplished:

✅ **Adaptive Difficulty** - Personalized learning experience  
✅ **Achievements** - Motivating gamification with 47 achievements  
✅ **Hearts System** - Balanced challenge with practice mode  
✅ **Spaced Repetition** - Long-term knowledge retention  
✅ **Analytics** - Comprehensive progress tracking  
✅ **Social Features** - Community engagement and motivation  

### Next Steps

1. **Test thoroughly** - Run through all features manually
2. **Gather feedback** - Beta test with users
3. **Monitor metrics** - Track engagement and performance
4. **Iterate** - Refine based on user behavior
5. **Scale** - Add backend for social features

### Resources

- 📖 [Adaptive Difficulty README](./lib/ADAPTIVE_DIFFICULTY_README.md)
- 🏆 [Achievements README](./ACHIEVEMENTS_README.md)
- ❤️ [Hearts System README](./HEARTS_SYSTEM_README.md)
- 🔄 [Spaced Repetition Models](./lib/models/spaced_repetition.dart)
- 📊 [Analytics Models](./lib/models/analytics.dart)
- 👥 [Social Models](./lib/models/social.dart)
- 🎮 [Wave 3 Demo Screen](./lib/examples/wave3_demo_screen.dart)

### Support

If you need help:
1. Check the [Troubleshooting FAQ](#troubleshooting-faq) section
2. Review example code in `lib/examples/`
3. Run tests to verify integration
4. Consult individual feature READMEs

---

**Congratulations on integrating Wave 3! 🎉**

You've transformed your app into a comprehensive learning platform with adaptive difficulty, engaging gamification, and intelligent review systems. Your users will love it!
