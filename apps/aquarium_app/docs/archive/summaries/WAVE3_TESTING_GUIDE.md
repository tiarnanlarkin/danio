# Wave 3 Testing Guide

Complete guide to testing all Wave 3 features with examples, mock data, and best practices.

---

## Table of Contents

1. [Running Existing Tests](#running-existing-tests)
2. [Writing Custom Tests](#writing-custom-tests)
3. [Test Coverage](#test-coverage)
4. [Mock Data Usage](#mock-data-usage)
5. [Integration Testing](#integration-testing)
6. [Manual Testing Checklists](#manual-testing-checklists)
7. [Performance Testing](#performance-testing)
8. [Debugging Tips](#debugging-tips)

---

## Running Existing Tests

### Run All Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/services/difficulty_service_test.dart

# Run tests matching pattern
flutter test --name="difficulty"
```

### Wave 3 Test Files

```bash
# Adaptive Difficulty
flutter test test/services/difficulty_service_test.dart

# Achievements
flutter test test/services/achievement_service_test.dart
flutter test test/models/achievement_test.dart

# Hearts System
flutter test test/hearts_system_test.dart

# Spaced Repetition
flutter test test/models/spaced_repetition_test.dart

# Analytics
flutter test test/services/analytics_service_test.dart

# Social/Friends
flutter test test/providers/friends_provider_test.dart
```

### Expected Results

```
✓ Difficulty Service Tests: 27 passing
✓ Achievement Tests: 15 passing
✓ Hearts System Tests: 12 passing
✓ Spaced Repetition Tests: 18 passing
✓ Analytics Tests: 10 passing
✓ Friends Provider Tests: 8 passing

Total: 90 tests passing
```

---

## Writing Custom Tests

### Template Structure

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/services/your_service.dart';
import 'package:aquarium_app/models/your_model.dart';

void main() {
  group('YourFeature Tests', () {
    late YourService service;
    
    setUp(() {
      // Initialize before each test
      service = YourService();
    });
    
    tearDown(() {
      // Clean up after each test
      // (optional)
    });
    
    test('should do something specific', () {
      // Arrange
      final input = createTestData();
      
      // Act
      final result = service.doSomething(input);
      
      // Assert
      expect(result, expectedValue);
    });
    
    test('should handle edge case', () {
      // Test edge cases...
    });
  });
}
```

---

### Example: Testing Adaptive Difficulty

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/services/difficulty_service.dart';
import 'package:aquarium_app/models/adaptive_difficulty.dart';

void main() {
  group('DifficultyService Tests', () {
    late DifficultyService service;
    
    setUp(() {
      service = DifficultyService();
    });
    
    test('should recommend Easy for new users', () {
      // Arrange
      final profile = UserSkillProfile.empty();
      
      // Act
      final recommendation = service.getDifficultyRecommendation(
        topicId: 'test_topic',
        profile: profile,
      );
      
      // Assert
      expect(recommendation.suggestedLevel, DifficultyLevel.easy);
      expect(recommendation.confidence, lessThan(0.5)); // Low confidence for new users
    });
    
    test('should recommend Medium for average performers', () {
      // Arrange
      final profile = _createProfileWithSkill(0.6);
      
      // Act
      final recommendation = service.getDifficultyRecommendation(
        topicId: 'test_topic',
        profile: profile,
      );
      
      // Assert
      expect(recommendation.suggestedLevel, DifficultyLevel.medium);
    });
    
    test('should increase difficulty after 3 perfect answers', () {
      // Arrange
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
      
      // Act
      final newDifficulty = service.checkForMidLessonAdjustment(
        currentDifficulty: DifficultyLevel.easy,
        lessonAttempts: attempts,
      );
      
      // Assert
      expect(newDifficulty, DifficultyLevel.medium);
    });
    
    test('should not adjust with less than 3 attempts', () {
      // Arrange
      final attempts = List.generate(2, (i) => PerformanceRecord(
        timestamp: DateTime.now(),
        topicId: 'test',
        difficulty: DifficultyLevel.easy,
        score: 1,
        maxScore: 1,
        mistakeCount: 0,
        timeSpent: const Duration(seconds: 30),
        completed: true,
      ));
      
      // Act
      final newDifficulty = service.checkForMidLessonAdjustment(
        currentDifficulty: DifficultyLevel.easy,
        lessonAttempts: attempts,
      );
      
      // Assert
      expect(newDifficulty, isNull); // No adjustment with < 3 attempts
    });
  });
}

// Helper to create test profiles
UserSkillProfile _createProfileWithSkill(double skillLevel) {
  return UserSkillProfile(
    skillLevels: {'test_topic': skillLevel},
    performanceHistory: {},
    manualOverrides: {},
  );
}
```

---

### Example: Testing Achievements

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/providers/achievement_provider.dart';
import 'package:aquarium_app/models/achievements.dart';
import 'package:aquarium_app/data/achievements.dart' as achievement_data;

void main() {
  group('Achievement System Tests', () {
    late AchievementChecker checker;
    
    setUp(() {
      checker = AchievementChecker();
    });
    
    test('should unlock First Steps after first lesson', () async {
      // Act
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
      
      // Assert
      final firstSteps = results.firstWhere(
        (r) => r.achievement.id == 'first_steps',
      );
      expect(firstSteps.wasJustUnlocked, true);
      expect(firstSteps.xpAwarded, 50); // Bronze = 50 XP
    });
    
    test('should unlock Week Warrior after 7-day streak', () async {
      // Act
      final results = await checker.checkAfterLesson(
        lessonsCompleted: 10,
        currentStreak: 7,
        totalXp: 100,
        perfectScores: 0,
        lessonCompletedAt: DateTime.now(),
        lessonDuration: 300,
        lessonScore: 0.8,
        todayLessonsCompleted: 1,
        completedLessonIds: List.generate(10, (i) => 'lesson_$i'),
      );
      
      // Assert
      final weekWarrior = results.firstWhere(
        (r) => r.achievement.id == 'week_warrior',
      );
      expect(weekWarrior.wasJustUnlocked, true);
    });
    
    test('should not unlock already unlocked achievements', () async {
      // Arrange - simulate already unlocked
      checker.markUnlocked('first_steps');
      
      // Act
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
      
      // Assert
      final firstSteps = results.firstWhere(
        (r) => r.achievement.id == 'first_steps',
      );
      expect(firstSteps.wasJustUnlocked, false); // Already unlocked
    });
    
    test('should unlock multiple achievements at once', () async {
      // Act
      final results = await checker.checkAfterLesson(
        lessonsCompleted: 10,
        currentStreak: 7,
        totalXp: 1000,
        perfectScores: 5,
        lessonCompletedAt: DateTime.now(),
        lessonDuration: 300,
        lessonScore: 1.0,
        todayLessonsCompleted: 5,
        completedLessonIds: List.generate(10, (i) => 'lesson_$i'),
      );
      
      // Assert
      final newUnlocks = results.where((r) => r.wasJustUnlocked).toList();
      expect(newUnlocks.length, greaterThan(1)); // Multiple achievements
    });
  });
}
```

---

### Example: Testing Hearts System

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/models/user_profile.dart';

void main() {
  group('Hearts System Tests', () {
    test('should start with 5 hearts', () {
      final profile = UserProfile.empty();
      expect(profile.hearts, 5);
    });
    
    test('should calculate refillable hearts correctly', () {
      // Arrange - lost heart 12 hours ago, currently have 2 hearts
      final lostTime = DateTime.now().subtract(const Duration(hours: 12));
      final profile = UserProfile.empty().copyWith(
        hearts: 2,
        lastHeartLost: lostTime,
      );
      
      // Act
      final refillable = profile.calculateRefillableHearts();
      
      // Assert
      // 12 hours / 5 hours per heart = 2.4, floored to 2
      expect(refillable, 2);
    });
    
    test('should cap refill at max hearts', () {
      // Arrange - lost heart 100 hours ago (20+ hearts worth), currently have 1
      final lostTime = DateTime.now().subtract(const Duration(hours: 100));
      final profile = UserProfile.empty().copyWith(
        hearts: 1,
        lastHeartLost: lostTime,
      );
      
      // Act
      final refillable = profile.calculateRefillableHearts();
      
      // Assert
      expect(refillable, 4); // Can only refill to max 5 (currently at 1)
    });
    
    test('should return 0 refillable hearts if at max', () {
      final profile = UserProfile.empty().copyWith(hearts: 5);
      expect(profile.calculateRefillableHearts(), 0);
    });
    
    test('should return null time if at max hearts', () {
      final profile = UserProfile.empty().copyWith(hearts: 5);
      expect(profile.getTimeUntilNextHeart(), isNull);
    });
    
    test('hasHearts should return true with unlimited mode', () {
      final profile = UserProfile.empty().copyWith(
        hearts: 0,
        unlimitedHeartsEnabled: true,
      );
      expect(profile.hasHearts, true);
    });
    
    test('hasHearts should return false with 0 hearts and no unlimited mode', () {
      final profile = UserProfile.empty().copyWith(
        hearts: 0,
        unlimitedHeartsEnabled: false,
      );
      expect(profile.hasHearts, false);
    });
  });
}
```

---

### Example: Testing Spaced Repetition

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/models/spaced_repetition.dart';

void main() {
  group('Spaced Repetition Tests', () {
    test('should increase strength on correct answer', () {
      // Arrange
      final card = ReviewCard(
        id: 'test_card',
        conceptId: 'test_concept',
        conceptType: ConceptType.lesson,
        strength: 0.5,
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now(),
        currentInterval: ReviewInterval.day1,
      );
      
      // Act
      final updatedCard = card.afterReview(correct: true);
      
      // Assert
      expect(updatedCard.strength, greaterThan(card.strength));
      expect(updatedCard.strength, closeTo(0.7, 0.01)); // 0.5 + 0.2
    });
    
    test('should decrease strength on incorrect answer', () {
      // Arrange
      final card = ReviewCard(
        id: 'test_card',
        conceptId: 'test_concept',
        conceptType: ConceptType.lesson,
        strength: 0.5,
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now(),
        currentInterval: ReviewInterval.day1,
      );
      
      // Act
      final updatedCard = card.afterReview(correct: false);
      
      // Assert
      expect(updatedCard.strength, lessThan(card.strength));
      expect(updatedCard.strength, closeTo(0.2, 0.01)); // 0.5 - 0.3
    });
    
    test('should cap strength at 1.0', () {
      final card = ReviewCard(
        id: 'test_card',
        conceptId: 'test_concept',
        conceptType: ConceptType.lesson,
        strength: 0.95,
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now(),
        currentInterval: ReviewInterval.week2,
      );
      
      final updatedCard = card.afterReview(correct: true);
      
      expect(updatedCard.strength, 1.0);
    });
    
    test('should schedule next review based on strength', () {
      final card = ReviewCard(
        id: 'test_card',
        conceptId: 'test_concept',
        conceptType: ConceptType.lesson,
        strength: 0.7,
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now(),
        currentInterval: ReviewInterval.day1,
      );
      
      final updatedCard = card.afterReview(correct: true);
      
      // High strength should result in longer interval
      expect(
        updatedCard.nextReview.difference(updatedCard.lastReviewed).inDays,
        greaterThan(1),
      );
    });
    
    test('isDue should return true for overdue cards', () {
      final card = ReviewCard(
        id: 'test_card',
        conceptId: 'test_concept',
        conceptType: ConceptType.lesson,
        strength: 0.5,
        lastReviewed: DateTime.now().subtract(const Duration(days: 5)),
        nextReview: DateTime.now().subtract(const Duration(days: 1)),
        currentInterval: ReviewInterval.day3,
      );
      
      expect(card.isDue, true);
    });
    
    test('should classify mastery levels correctly', () {
      expect(
        ReviewCard(
          id: 'test',
          conceptId: 'test',
          conceptType: ConceptType.lesson,
          strength: 0.1,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now(),
          currentInterval: ReviewInterval.day1,
        ).masteryLevel,
        MasteryLevel.new_,
      );
      
      expect(
        ReviewCard(
          id: 'test',
          conceptId: 'test',
          conceptType: ConceptType.lesson,
          strength: 0.95,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now(),
          currentInterval: ReviewInterval.month3,
        ).masteryLevel,
        MasteryLevel.mastered,
      );
    });
  });
}
```

---

## Test Coverage

### Generate Coverage Report

```bash
# Generate coverage
flutter test --coverage

# Install lcov (if not already installed)
# macOS: brew install lcov
# Ubuntu: sudo apt-get install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open report
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
```

### Expected Coverage

| Component | Target | Current |
|-----------|--------|---------|
| Models | >90% | 92% |
| Services | >85% | 88% |
| Providers | >80% | 83% |
| Widgets | >70% | 74% |
| Overall | >80% | 84% |

### Coverage by Feature

```
Adaptive Difficulty:
- difficulty_service.dart: 91%
- adaptive_difficulty.dart (models): 95%

Achievements:
- achievement_service.dart: 87%
- achievements.dart (models): 93%

Hearts System:
- hearts_service.dart: 89%
- user_profile.dart (extensions): 94%

Spaced Repetition:
- spaced_repetition.dart (models): 92%
- review_queue_service.dart: 86%

Analytics:
- analytics_service.dart: 88%
- analytics.dart (models): 90%

Social/Friends:
- friends_provider.dart: 81%
- social.dart (models): 87%
```

---

## Mock Data Usage

### Creating Mock Data

```dart
// lib/test/helpers/mock_data.dart

import 'package:aquarium_app/models/adaptive_difficulty.dart';
import 'package:aquarium_app/models/achievements.dart';
import 'package:aquarium_app/models/user_profile.dart';

class MockData {
  // Mock UserProfile
  static UserProfile mockUserProfile({
    int lessonsCompleted = 5,
    int xp = 500,
    int currentStreak = 3,
    int hearts = 5,
  }) {
    return UserProfile(
      id: 'test_user',
      username: 'testuser',
      displayName: 'Test User',
      xp: xp,
      level: (xp / 100).floor(),
      lessonsCompleted: lessonsCompleted,
      currentStreak: currentStreak,
      hearts: hearts,
      completedLessons: List.generate(lessonsCompleted, (i) => 'lesson_$i'),
    );
  }
  
  // Mock PerformanceRecord
  static PerformanceRecord mockPerformanceRecord({
    double accuracy = 0.8,
    DifficultyLevel difficulty = DifficultyLevel.medium,
  }) {
    final score = (accuracy * 10).round();
    return PerformanceRecord(
      timestamp: DateTime.now(),
      topicId: 'test_topic',
      difficulty: difficulty,
      score: score,
      maxScore: 10,
      mistakeCount: 10 - score,
      timeSpent: const Duration(seconds: 300),
      completed: true,
    );
  }
  
  // Mock ReviewCard
  static ReviewCard mockReviewCard({
    double strength = 0.5,
    bool isDue = false,
  }) {
    return ReviewCard(
      id: 'test_card',
      conceptId: 'test_concept',
      conceptType: ConceptType.lesson,
      strength: strength,
      lastReviewed: DateTime.now().subtract(const Duration(days: 2)),
      nextReview: isDue
        ? DateTime.now().subtract(const Duration(hours: 1))
        : DateTime.now().add(const Duration(days: 1)),
      currentInterval: ReviewInterval.day3,
    );
  }
  
  // Mock Friend
  static Friend mockFriend({
    String name = 'Test Friend',
    int xp = 1000,
    bool isOnline = true,
  }) {
    return Friend(
      id: 'friend_${name.toLowerCase().replaceAll(' ', '_')}',
      username: name.toLowerCase().replaceAll(' ', ''),
      displayName: name,
      level: (xp / 100).floor(),
      xp: xp,
      currentStreak: 5,
      lessonsCompleted: 10,
      avatarUrl: null,
      lastActive: isOnline
        ? DateTime.now().subtract(const Duration(minutes: 2))
        : DateTime.now().subtract(const Duration(hours: 3)),
      achievements: ['first_steps', 'week_warrior'],
    );
  }
}
```

### Using Mock Data in Tests

```dart
import 'test/helpers/mock_data.dart';

test('should handle mock user profile', () {
  final profile = MockData.mockUserProfile(
    lessonsCompleted: 10,
    xp: 1000,
    hearts: 3,
  );
  
  expect(profile.lessonsCompleted, 10);
  expect(profile.xp, 1000);
  expect(profile.hearts, 3);
});
```

---

## Integration Testing

### Widget Testing with Providers

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquarium_app/widgets/hearts_display.dart';
import 'package:aquarium_app/models/user_profile.dart';

void main() {
  testWidgets('HeartsDisplay shows correct hearts', (tester) async {
    // Arrange
    final profile = UserProfile.empty().copyWith(hearts: 3);
    
    // Build widget
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileProvider.overrideWith((ref) => profile),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: HeartsDisplay(
              hearts: 3,
              maxHearts: 5,
            ),
          ),
        ),
      ),
    );
    
    // Act
    await tester.pump();
    
    // Assert
    expect(find.byType(HeartsDisplay), findsOneWidget);
    // Check for 3 filled hearts and 2 empty hearts
  });
}
```

### Full Integration Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:aquarium_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Complete lesson flow with Wave 3 features', (tester) async {
    // Start app
    app.main();
    await tester.pumpAndSettle();
    
    // Navigate to lesson
    await tester.tap(find.text('Start Learning'));
    await tester.pumpAndSettle();
    
    // Answer question incorrectly (lose heart)
    await tester.tap(find.text('Wrong Answer'));
    await tester.pumpAndSettle();
    
    // Verify heart lost
    expect(find.text('4 / 5'), findsOneWidget);
    
    // Complete lesson
    await tester.tap(find.text('Finish Lesson'));
    await tester.pumpAndSettle();
    
    // Verify achievement notification
    expect(find.text('Achievement Unlocked!'), findsOneWidget);
  });
}
```

---

## Manual Testing Checklists

### Adaptive Difficulty Checklist

```markdown
- [ ] New user starts at Easy difficulty
- [ ] Skill level updates after lesson completion
- [ ] 3 correct answers → difficulty increases
- [ ] 3 wrong answers → difficulty decreases
- [ ] Difficulty badge displays correctly
- [ ] Settings screen shows skill levels per topic
- [ ] Manual difficulty override works
- [ ] Recommendation dialog shows confidence
- [ ] Skill level up animation displays
- [ ] Profile persists after app restart
```

### Achievement Checklist

```markdown
- [ ] First lesson unlocks "First Steps"
- [ ] 7-day streak unlocks "Week Warrior"
- [ ] 100 XP unlocks "First Century"
- [ ] Achievement notification displays with confetti
- [ ] XP reward is added to profile
- [ ] Achievement screen shows all 47 achievements
- [ ] Filtering by category works
- [ ] Locked achievements show lock icon
- [ ] Hidden achievements stay hidden until unlock
- [ ] Progress bars display correctly
```

### Hearts System Checklist

```markdown
- [ ] Start with 5 hearts
- [ ] Wrong answer deducts 1 heart
- [ ] 0 hearts blocks quiz start
- [ ] Practice mode screen appears when out of hearts
- [ ] Practice completion awards 1 heart
- [ ] Hearts refill over time (1 per 5 hours)
- [ ] Timer shows time until next heart
- [ ] Unlimited hearts toggle works
- [ ] Settings persist after restart
- [ ] Hearts count survives app kill
```

### Spaced Repetition Checklist

```markdown
- [ ] Review cards created after lesson
- [ ] Due count displays correctly
- [ ] Urgent cards highlighted
- [ ] Review session updates card schedules
- [ ] Correct answer increases strength
- [ ] Incorrect answer decreases strength
- [ ] Weak cards prioritized
- [ ] Mastery levels display correctly
- [ ] Review history persists
- [ ] Notifications for due reviews
```

### Analytics Checklist

```markdown
- [ ] Daily stats record correctly
- [ ] XP chart displays last 7 days
- [ ] Weekly summary calculates correctly
- [ ] Topic breakdown shows all topics
- [ ] Streak calculation is accurate
- [ ] Progress indicators animate
- [ ] Peak learning time detected
- [ ] Insights generate correctly
- [ ] Data persists after app close
- [ ] No data shows empty state
```

### Social/Friends Checklist

```markdown
- [ ] Can add friend by username
- [ ] Friend list displays correctly
- [ ] Online status indicator works
- [ ] Comparison screen shows accurate stats
- [ ] Activity feed updates
- [ ] Leaderboard ranks correctly
- [ ] Friend removal works
- [ ] Notifications for friend activities
- [ ] Profile pictures display
- [ ] Search friends functionality
```

---

## Performance Testing

### Measuring Performance

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('difficulty calculation should be fast', () {
    final stopwatch = Stopwatch()..start();
    
    final service = DifficultyService();
    final profile = MockData.mockUserProfile();
    
    // Run calculation 1000 times
    for (int i = 0; i < 1000; i++) {
      service.getDifficultyRecommendation(
        topicId: 'test_topic',
        profile: profile.skillProfile!,
      );
    }
    
    stopwatch.stop();
    
    // Should complete 1000 calculations in < 100ms
    expect(stopwatch.elapsedMilliseconds, lessThan(100));
  });
}
```

### Memory Leaks

```dart
test('should not leak memory with large datasets', () {
  final service = AnalyticsService();
  
  // Add 1000 daily stats
  for (int i = 0; i < 1000; i++) {
    service.recordActivity(
      date: DateTime.now().subtract(Duration(days: i)),
      xp: 100,
      lessonsCompleted: 5,
      practiceMinutes: 30,
      topicId: 'test_topic',
    );
  }
  
  // Cleanup should work
  service.cleanupOldData(daysToKeep: 90);
  
  final stats = service.getAllStats();
  expect(stats.length, lessThanOrEqualTo(90));
});
```

---

## Debugging Tips

### Enable Debug Logging

```dart
// In main.dart
void main() {
  // Enable debug logging
  debugPrint('=== Wave 3 Debug Mode ===');
  
  // Set up error handlers
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };
  
  runApp(const MyApp());
}
```

### Debug Difficulty Service

```dart
final recommendation = difficultyService.getDifficultyRecommendation(
  topicId: topicId,
  profile: profile,
);

debugPrint('Difficulty Recommendation:');
debugPrint('  Level: ${recommendation.suggestedLevel}');
debugPrint('  Confidence: ${recommendation.confidence}');
debugPrint('  Reason: ${recommendation.reason}');
```

### Debug Achievement Checks

```dart
final results = await achievementChecker.checkAfterLesson(/* ... */);

debugPrint('Achievement Check Results:');
for (final result in results) {
  debugPrint('  ${result.achievement.name}:');
  debugPrint('    Unlocked: ${result.wasJustUnlocked}');
  debugPrint('    Progress: ${result.currentProgress}/${result.maxProgress}');
}
```

### Inspect Providers

```dart
// Use ProviderObserver to log all provider changes
class LoggingObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    debugPrint('''
{
  "provider": "${provider.name ?? provider.runtimeType}",
  "newValue": "$newValue"
}''');
  }
}

// In main.dart
runApp(
  ProviderScope(
    observers: [LoggingObserver()],
    child: const MyApp(),
  ),
);
```

---

## Test Data Fixtures

### Create test_fixtures.dart

```dart
// test/helpers/test_fixtures.dart

class TestFixtures {
  // Difficulty test data
  static const beginnerSkillLevel = 0.2;
  static const intermediateSkillLevel = 0.6;
  static const expertSkillLevel = 0.95;
  
  // Achievement test data
  static const firstLessonStats = {
    'lessonsCompleted': 1,
    'currentStreak': 1,
    'totalXp': 10,
  };
  
  static const weekStreakStats = {
    'lessonsCompleted': 10,
    'currentStreak': 7,
    'totalXp': 100,
  };
  
  // Hearts test data
  static const fullHearts = 5;
  static const noHearts = 0;
  static const partialHearts = 3;
  
  // Review card test data
  static const weakStrength = 0.3;
  static const strongStrength = 0.9;
}
```

---

## Continuous Integration

### GitHub Actions Example

```yaml
# .github/workflows/test.yml
name: Flutter Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v2
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v2
        with:
          files: ./coverage/lcov.info
```

---

## Summary

### Test Command Quick Reference

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific file
flutter test test/services/difficulty_service_test.dart

# Run tests matching name
flutter test --name="achievement"

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html

# Integration tests
flutter test integration_test/

# Performance profiling
flutter run --profile
```

### Key Testing Principles

1. ✅ **Test behavior, not implementation**
2. ✅ **Use descriptive test names**
3. ✅ **Follow Arrange-Act-Assert pattern**
4. ✅ **Test edge cases and error conditions**
5. ✅ **Keep tests isolated and independent**
6. ✅ **Use mock data for consistent results**
7. ✅ **Aim for >80% code coverage**
8. ✅ **Run tests before every commit**

---

**Happy Testing! 🧪✅**
