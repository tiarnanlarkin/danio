# Wave 3 API Documentation

Complete API reference for all Wave 3 features with parameter descriptions, return values, and usage examples.

---

## Table of Contents

1. [Adaptive Difficulty API](#adaptive-difficulty-api)
2. [Achievement System API](#achievement-system-api)
3. [Hearts System API](#hearts-system-api)
4. [Spaced Repetition API](#spaced-repetition-api)
5. [Analytics API](#analytics-api)
6. [Social/Friends API](#socialfriends-api)

---

## Adaptive Difficulty API

### DifficultyService

Main service for difficulty adaptation and skill tracking.

#### `calculateSkillLevel`

Calculates user skill level from performance history.

**Signature:**
```dart
double calculateSkillLevel(PerformanceHistory history)
```

**Parameters:**
- `history` (PerformanceHistory): Rolling window of recent performance records

**Returns:**
- `double`: Skill level from 0.0 (beginner) to 1.0 (expert)

**Algorithm:**
- Accuracy: 40% weight
- Time efficiency: 20% weight
- Consistency: 20% weight (inverse of standard deviation)
- Consecutive correct: 20% weight
- Improvement trend: 15% bonus/penalty

**Example:**
```dart
final difficultyService = DifficultyService();
final history = PerformanceHistory(
  attempts: [/* recent attempts */],
);

final skillLevel = difficultyService.calculateSkillLevel(history);
print('Skill: ${(skillLevel * 100).toInt()}%');
// Output: Skill: 65%
```

---

#### `getDifficultyRecommendation`

Returns AI-powered difficulty recommendation for a topic.

**Signature:**
```dart
DifficultyRecommendation getDifficultyRecommendation({
  required String topicId,
  required UserSkillProfile profile,
})
```

**Parameters:**
- `topicId` (String): Unique identifier for the learning topic
- `profile` (UserSkillProfile): User's complete skill profile

**Returns:**
- `DifficultyRecommendation`: Object containing:
  - `suggestedLevel` (DifficultyLevel): Recommended difficulty
  - `confidence` (double): 0.0-1.0 confidence score
  - `reason` (String): Human-readable explanation
  - `shouldIncrease` (bool): Suggests increasing difficulty
  - `shouldDecrease` (bool): Suggests decreasing difficulty

**Logic:**
1. Checks for manual override first
2. Uses topic-specific history if available (3+ attempts)
3. Falls back to overall skill level for new topics
4. Adjusts based on recent performance trends

**Example:**
```dart
final recommendation = difficultyService.getDifficultyRecommendation(
  topicId: 'nitrogen_cycle',
  profile: userProfile.skillProfile ?? UserSkillProfile.empty(),
);

print('Recommended: ${recommendation.suggestedLevel}');
print('Because: ${recommendation.reason}');
print('Confidence: ${(recommendation.confidence * 100).toInt()}%');

// Output:
// Recommended: DifficultyLevel.medium
// Because: You've shown consistent progress. Time to level up!
// Confidence: 85%
```

---

#### `checkForMidLessonAdjustment`

Checks if difficulty should change during an active lesson.

**Signature:**
```dart
DifficultyLevel? checkForMidLessonAdjustment({
  required DifficultyLevel currentDifficulty,
  required List<PerformanceRecord> lessonAttempts,
})
```

**Parameters:**
- `currentDifficulty` (DifficultyLevel): Current lesson difficulty
- `lessonAttempts` (List<PerformanceRecord>): Attempts in current lesson

**Returns:**
- `DifficultyLevel?`: New difficulty level if adjustment needed, `null` otherwise

**Triggers:**
- **Increase**: 3+ consecutive perfect answers (100% accuracy, fast time)
- **Decrease**: 3+ consecutive failures (<40% accuracy)
- **Minimum**: 3 questions answered before adjustment

**Example:**
```dart
List<PerformanceRecord> attempts = [];

// After each question:
attempts.add(PerformanceRecord(/* ... */));

final newDifficulty = difficultyService.checkForMidLessonAdjustment(
  currentDifficulty: DifficultyLevel.medium,
  lessonAttempts: attempts,
);

if (newDifficulty != null) {
  print('Adjusting difficulty to $newDifficulty');
  currentDifficulty = newDifficulty;
}
```

---

#### `updateProfileAfterLesson`

Updates user skill profile after lesson completion.

**Signature:**
```dart
UserSkillProfile updateProfileAfterLesson({
  required UserSkillProfile currentProfile,
  required PerformanceRecord lessonRecord,
})
```

**Parameters:**
- `currentProfile` (UserSkillProfile): Current profile state
- `lessonRecord` (PerformanceRecord): Final lesson performance

**Returns:**
- `UserSkillProfile`: Updated profile with new history and skill levels

**Updates:**
1. Adds performance record to topic history
2. Maintains rolling window (last 10 attempts)
3. Recalculates skill level
4. Updates performance trend
5. Clears manual overrides if user improving

**Example:**
```dart
final lessonRecord = PerformanceRecord(
  timestamp: DateTime.now(),
  topicId: 'water_chemistry',
  difficulty: DifficultyLevel.medium,
  score: 8,
  maxScore: 10,
  mistakeCount: 2,
  timeSpent: Duration(seconds: 300),
  completed: true,
);

final updatedProfile = difficultyService.updateProfileAfterLesson(
  currentProfile: userProfile.skillProfile ?? UserSkillProfile.empty(),
  lessonRecord: lessonRecord,
);

// Save updated profile
userProfile = userProfile.copyWith(skillProfile: updatedProfile);
```

---

#### `hasTopicMastery`

Checks if user has mastered a specific topic.

**Signature:**
```dart
bool hasTopicMastery({
  required String topicId,
  required UserSkillProfile profile,
})
```

**Parameters:**
- `topicId` (String): Topic to check
- `profile` (UserSkillProfile): User's skill profile

**Returns:**
- `bool`: `true` if topic is mastered

**Criteria:**
- Skill level ≥ 0.85 (85%)
- At least 5 successful attempts
- Consistent high performance

**Example:**
```dart
if (difficultyService.hasTopicMastery(
  topicId: 'nitrogen_cycle',
  profile: userProfile.skillProfile!,
)) {
  print('🏆 Congratulations! You\'ve mastered this topic!');
  // Award mastery badge
}
```

---

#### Helper Methods

**`getDifficultyName`**
```dart
String getDifficultyName(DifficultyLevel level)
// Returns: "Easy", "Medium", "Hard", "Expert"
```

**`getDifficultyIcon`**
```dart
String getDifficultyIcon(DifficultyLevel level)
// Returns: "🌱", "⭐", "🔥", "💎"
```

**`getDifficultyColor`**
```dart
Color getDifficultyColor(DifficultyLevel level)
// Returns: Color for UI display
```

**`getDifficultyDescription`**
```dart
String getDifficultyDescription(DifficultyLevel level)
// Returns: Human-readable description
```

**`getSkillChangeMessage`**
```dart
String? getSkillChangeMessage({
  required double oldSkill,
  required double newSkill,
  required String topicName,
})
// Returns motivational message if significant change
```

---

### Models

#### DifficultyLevel (enum)

```dart
enum DifficultyLevel {
  easy,    // 🌱 Basic concepts with hints
  medium,  // ⭐ Standard difficulty
  hard,    // 🔥 Advanced concepts
  expert,  // 💎 Expert challenges
}
```

#### PerformanceRecord

```dart
class PerformanceRecord {
  final DateTime timestamp;
  final String topicId;
  final DifficultyLevel difficulty;
  final int score;
  final int maxScore;
  final int mistakeCount;
  final Duration timeSpent;
  final bool completed;
  
  // Calculated properties
  double get accuracy => score / maxScore;
  double get timeEfficiency; // Calculated based on expected time
}
```

#### PerformanceHistory

```dart
class PerformanceHistory {
  final List<PerformanceRecord> attempts; // Max 10 recent
  
  // Calculated metrics
  double get averageAccuracy;
  double get averageTimeEfficiency;
  int get consecutiveCorrect;
  bool get isStruggling; // 3+ recent failures
  PerformanceTrend get trend; // improving/stable/declining
}
```

#### UserSkillProfile

```dart
class UserSkillProfile {
  final Map<String, double> skillLevels;              // topicId → 0.0-1.0
  final Map<String, PerformanceHistory> performanceHistory;
  final Map<String, DifficultyLevel> manualOverrides; // User preferences
  
  // Methods
  double getSkillLevel(String topicId);
  PerformanceHistory? getHistory(String topicId);
  DifficultyLevel? getManualOverride(String topicId);
  bool hasHistory(String topicId);
  
  factory UserSkillProfile.empty(); // Default for new users
}
```

---

## Achievement System API

### AchievementChecker (Provider)

Manages achievement unlocking and progress tracking.

#### `checkAfterLesson`

Checks for achievement unlocks after lesson completion.

**Signature:**
```dart
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
})
```

**Parameters:**
- `lessonsCompleted` (int): Total lessons completed
- `currentStreak` (int): Current daily streak
- `totalXp` (int): Total XP earned
- `perfectScores` (int): Count of perfect scores
- `lessonCompletedAt` (DateTime): Timestamp of completion
- `lessonDuration` (int): Duration in seconds
- `lessonScore` (double): Score percentage (0.0-1.0)
- `todayLessonsCompleted` (int): Lessons completed today
- `completedLessonIds` (List<String>): All completed lesson IDs

**Returns:**
- `List<AchievementUnlockResult>`: List of checked achievements with unlock status

**Example:**
```dart
final achievementChecker = ref.read(achievementCheckerProvider);

final results = await achievementChecker.checkAfterLesson(
  lessonsCompleted: userProfile.lessonsCompleted + 1,
  currentStreak: userProfile.currentStreak,
  totalXp: userProfile.xp + xpEarned,
  perfectScores: userProfile.perfectScores + (isPerfect ? 1 : 0),
  lessonCompletedAt: DateTime.now(),
  lessonDuration: lessonDuration.inSeconds,
  lessonScore: totalCorrect / totalQuestions,
  todayLessonsCompleted: todayCount + 1,
  completedLessonIds: [...userProfile.completedLessons, lessonId],
);

// Show notifications for newly unlocked
for (final result in results.where((r) => r.wasJustUnlocked)) {
  await AchievementNotification.show(
    context,
    result.achievement,
    result.xpAwarded,
  );
}
```

**Checks for:**
- Lesson count achievements (First Steps, Getting Started, etc.)
- Streak achievements (3-day, 7-day, 30-day, etc.)
- XP milestones (100, 500, 1000, etc.)
- Special achievements (Early Bird, Night Owl, Speed Demon, etc.)
- Daily challenges (Marathon Learner)

---

#### `checkAfterDailyTip`

**Signature:**
```dart
Future<List<AchievementUnlockResult>> checkAfterDailyTip({
  required int tipsReadCount,
})
```

**Checks for:**
- Tip Explorer (10 tips)
- Tip Enthusiast (50 tips)
- Wisdom Seeker (100 tips)

---

#### `checkAfterPractice`

**Signature:**
```dart
Future<List<AchievementUnlockResult>> checkAfterPractice({
  required int practiceSessionsCompleted,
})
```

**Checks for:**
- Practice Makes Progress (10 sessions)
- Practice Champion (50 sessions)
- Practice Master (100 sessions)

---

#### `checkAfterSocialAction`

**Signature:**
```dart
Future<List<AchievementUnlockResult>> checkAfterSocialAction({
  required int friendsCount,
})
```

**Checks for:**
- Social Butterfly (10 friends)

---

#### Helper Methods

**`getCompletionPercentage`**
```dart
double getCompletionPercentage()
// Returns: 0-100 percentage of achievements unlocked
```

**`getNextAchievements`**
```dart
List<Achievement> getNextAchievements({int limit = 3})
// Returns: Achievable achievements sorted by proximity
```

**`unlockedAchievements`**
```dart
List<Achievement> get unlockedAchievements
// Returns: List of all unlocked achievements
```

---

### Models

#### Achievement

```dart
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;                    // Emoji
  final AchievementRarity rarity;       // bronze/silver/gold/platinum
  final AchievementCategory category;   // learning/streaks/xp/special/engagement
  final bool isHidden;                  // Hide until unlocked
  final int maxProgress;                // For incremental achievements
  
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

#### AchievementUnlockResult

```dart
class AchievementUnlockResult {
  final Achievement achievement;
  final bool wasJustUnlocked;  // True if unlocked in this check
  final int xpAwarded;
  final int currentProgress;
  final int maxProgress;
  
  double get progressPercentage => currentProgress / maxProgress;
}
```

#### AchievementProgress

```dart
class AchievementProgress {
  final String achievementId;
  final int currentProgress;
  final int maxProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  
  double get percentage => currentProgress / maxProgress;
  bool get isComplete => currentProgress >= maxProgress;
}
```

---

## Hearts System API

### UserProfile Extensions

Hearts functionality is implemented as extensions on the UserProfile model.

#### `hasHearts`

Check if user has hearts available.

**Signature:**
```dart
bool get hasHearts
```

**Returns:**
- `bool`: `true` if hearts > 0 OR unlimited hearts enabled

**Example:**
```dart
if (!userProfile.hasHearts) {
  // Navigate to practice mode
  Navigator.push(context, MaterialPageRoute(
    builder: (context) => PracticeRequiredScreen(),
  ));
}
```

---

#### `needsRefill`

Check if hearts need refilling.

**Signature:**
```dart
bool get needsRefill
```

**Returns:**
- `bool`: `true` if hearts < 5 and unlimited mode is disabled

---

#### `calculateRefillableHearts`

Calculate how many hearts should be refilled based on elapsed time.

**Signature:**
```dart
int calculateRefillableHearts()
```

**Returns:**
- `int`: Number of hearts to refill (0 to 5)

**Formula:**
- 1 heart per 5 hours elapsed since last heart lost
- Capped at (5 - current hearts)

**Example:**
```dart
// User lost heart 12 hours ago, currently has 2 hearts
final refillable = userProfile.calculateRefillableHearts();
print(refillable); // Output: 2 (12 hours / 5 hours = 2.4, floored to 2)
// New total: 2 + 2 = 4 hearts
```

---

#### `getTimeUntilNextHeart`

Get time remaining until next heart refill.

**Signature:**
```dart
Duration? getTimeUntilNextHeart()
```

**Returns:**
- `Duration?`: Time until next heart, `null` if at max hearts or no refill pending

**Example:**
```dart
final timeLeft = userProfile.getTimeUntilNextHeart();
if (timeLeft != null) {
  final hours = timeLeft.inHours;
  final minutes = timeLeft.inMinutes % 60;
  print('Next heart in $hours:${minutes.toString().padLeft(2, '0')}');
}
```

---

### UserProfileProvider Methods

#### `loseHeart`

Deduct one heart (called on wrong answer).

**Signature:**
```dart
Future<void> loseHeart()
```

**Behavior:**
- No effect if unlimited hearts enabled
- No effect if hearts already at 0
- Sets `lastHeartLost` to current time
- Saves profile to storage

**Example:**
```dart
Future<void> onIncorrectAnswer() async {
  await ref.read(userProfileProvider.notifier).loseHeart();
  
  final profile = ref.read(userProfileProvider);
  if (!profile.hasHearts) {
    // Handle hearts depleted
    showOutOfHeartsDialog();
  }
}
```

---

#### `refillHearts`

Refill hearts based on elapsed time.

**Signature:**
```dart
Future<void> refillHearts()
```

**Behavior:**
- Calculates hearts to refill using `calculateRefillableHearts()`
- Updates heart count (max 5)
- Saves profile to storage

**Example:**
```dart
// Call on app startup and before quizzes
@override
void initState() {
  super.initState();
  _refillHearts();
}

Future<void> _refillHearts() async {
  await ref.read(userProfileProvider.notifier).refillHearts();
}
```

---

#### `earnHeartFromPractice`

Award one heart from practice completion.

**Signature:**
```dart
Future<void> earnHeartFromPractice()
```

**Behavior:**
- Increases hearts by 1 (max 5)
- No effect if already at 5 hearts
- Saves profile to storage

**Example:**
```dart
Future<void> onPracticeComplete() async {
  await ref.read(userProfileProvider.notifier).earnHeartFromPractice();
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Earned 1 heart! ❤️')),
  );
}
```

---

#### `toggleUnlimitedHearts`

Toggle unlimited hearts mode.

**Signature:**
```dart
Future<void> toggleUnlimitedHearts(bool enabled)
```

**Parameters:**
- `enabled` (bool): Enable or disable unlimited hearts

**Example:**
```dart
SwitchListTile(
  title: Text('Unlimited Hearts'),
  value: userProfile.unlimitedHeartsEnabled,
  onChanged: (value) {
    ref.read(userProfileProvider.notifier).toggleUnlimitedHearts(value);
  },
)
```

---

### Widgets

#### HeartsDisplay

**Props:**
```dart
HeartsDisplay({
  required int hearts,        // Current hearts (0-5)
  required int maxHearts,     // Maximum hearts (usually 5)
  double size = 32,           // Icon size
  bool showTimer = false,     // Show refill timer
  Duration? timeUntilNextHeart,
  VoidCallback? onTap,
})
```

**Example:**
```dart
Consumer(
  builder: (context, ref, child) {
    final profile = ref.watch(userProfileProvider);
    
    return HeartsDisplay(
      hearts: profile.hearts,
      maxHearts: 5,
      showTimer: true,
      timeUntilNextHeart: profile.getTimeUntilNextHeart(),
      onTap: () => _showHeartsInfo(context),
    );
  },
)
```

---

## Spaced Repetition API

### SpacedRepetitionProvider

#### `addCards`

Add new review cards to the queue.

**Signature:**
```dart
Future<void> addCards(List<ReviewCard> cards)
```

**Example:**
```dart
final cards = [
  ReviewCard(
    id: 'card_${lesson.id}',
    conceptId: lesson.id,
    conceptType: ConceptType.lesson,
    strength: lessonScore,
    lastReviewed: DateTime.now(),
    nextReview: DateTime.now().add(Duration(days: 1)),
    currentInterval: ReviewInterval.day1,
  ),
];

await ref.read(spacedRepetitionProvider.notifier).addCards(cards);
```

---

#### `updateCard`

Update a card after review.

**Signature:**
```dart
Future<void> updateCard(ReviewCard card)
```

**Example:**
```dart
// After user answers review question
final updatedCard = card.afterReview(correct: isCorrect);
await ref.read(spacedRepetitionProvider.notifier).updateCard(updatedCard);
```

---

#### `getDueCards`

Get all cards due for review.

**Signature:**
```dart
List<ReviewCard> getDueCards()
```

**Returns:**
- Cards where `nextReview <= DateTime.now()`

---

#### `getUrgentCards`

Get urgent cards (overdue by >1 day).

**Signature:**
```dart
List<ReviewCard> getUrgentCards()
```

---

#### `getWeakCards`

Get weak cards (strength < 0.5).

**Signature:**
```dart
List<ReviewCard> getWeakCards()
```

---

#### `getDueCount`

**Signature:**
```dart
int getDueCount()
```

**Returns:**
- Count of cards due for review

---

### ReviewCard

#### `afterReview`

Create updated card after review attempt.

**Signature:**
```dart
ReviewCard afterReview({
  required bool correct,
  DateTime? reviewedAt,
})
```

**Parameters:**
- `correct` (bool): Whether answer was correct
- `reviewedAt` (DateTime?): Timestamp (defaults to now)

**Returns:**
- `ReviewCard`: New card with updated strength and schedule

**Strength Adjustment:**
- Correct: +0.2 (capped at 1.0)
- Incorrect: -0.3 (minimum 0.0)

**Interval Calculation:**
Based on new strength:
- 0.0-0.2: immediate retry
- 0.2-0.4: 4 hours
- 0.4-0.6: 1 day
- 0.6-0.75: 3 days
- 0.75-0.85: 1 week
- 0.85-0.92: 2 weeks
- 0.92-0.96: 1 month
- 0.96+: 3-6 months

**Example:**
```dart
// User gets answer correct
final updatedCard = currentCard.afterReview(correct: true);

print('Strength: ${currentCard.strength} → ${updatedCard.strength}');
print('Next review: ${updatedCard.nextReview}');
```

---

#### Properties

```dart
class ReviewCard {
  // Identity
  final String id;
  final String conceptId;
  final ConceptType conceptType;
  
  // Performance
  final double strength;        // 0.0-1.0
  final int reviewCount;
  final int correctCount;
  final int incorrectCount;
  
  // Scheduling
  final DateTime lastReviewed;
  final DateTime nextReview;
  final ReviewInterval currentInterval;
  
  // Calculated
  bool get isDue => DateTime.now().isAfter(nextReview);
  bool get isWeak => strength < 0.5;
  bool get isStrong => strength >= 0.8;
  MasteryLevel get masteryLevel;
  double get successRate => correctCount / reviewCount;
}
```

---

### ReviewInterval (enum)

```dart
enum ReviewInterval {
  immediate,  // 0 hours
  hour4,      // 4 hours
  day1,       // 1 day
  day3,       // 3 days
  week1,      // 1 week
  week2,      // 2 weeks
  month1,     // 1 month
  month3,     // 3 months
  month6,     // 6 months
}

extension ReviewIntervalExtension on ReviewInterval {
  Duration get duration;  // Get Duration for each interval
}
```

---

## Analytics API

### AnalyticsService

#### `recordActivity`

Record daily activity.

**Signature:**
```dart
Future<void> recordActivity({
  required DateTime date,
  required int xp,
  required int lessonsCompleted,
  required int practiceMinutes,
  required String topicId,
  String? activityId,
})
```

**Example:**
```dart
final analyticsService = ref.read(analyticsServiceProvider);

await analyticsService.recordActivity(
  date: DateTime.now(),
  xp: 10,
  lessonsCompleted: 1,
  practiceMinutes: (lessonDuration.inSeconds / 60).ceil(),
  topicId: lesson.pathId,
  activityId: lesson.id,
);
```

---

#### `getTodayStats`

**Signature:**
```dart
DailyStats getTodayStats()
```

**Returns:**
- `DailyStats`: Statistics for today

---

#### `getStatsForDate`

**Signature:**
```dart
DailyStats getStatsForDate(DateTime date)
```

---

#### `getStatsForRange`

**Signature:**
```dart
List<DailyStats> getStatsForRange(DateTime start, DateTime end)
```

**Example:**
```dart
// Get last 7 days
final now = DateTime.now();
final start = now.subtract(Duration(days: 6));
final stats = analyticsService.getStatsForRange(start, now);

for (final dayStat in stats) {
  print('${dayStat.dateKey}: ${dayStat.xp} XP');
}
```

---

#### `getWeekStats`

**Signature:**
```dart
WeeklyStats getWeekStats()
```

**Returns:**
- `WeeklyStats`: Aggregated stats for current week

---

#### `getXPByTopic`

**Signature:**
```dart
Map<String, int> getXPByTopic({DateTime? since})
```

**Parameters:**
- `since` (DateTime?): Only count XP since this date

**Returns:**
- `Map<String, int>`: Topic ID → XP earned

---

### Models

#### DailyStats

```dart
class DailyStats {
  final DateTime date;
  final int xp;
  final int lessonsCompleted;
  final int practiceMinutes;
  final int timeSpentSeconds;
  final Map<String, int> topicXp;
  final List<String> activitiesCompleted;
  
  String get dateKey; // YYYY-MM-DD
}
```

#### WeeklyStats

```dart
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
```

---

## Social/Friends API

### FriendsProvider

#### `addFriend`

**Signature:**
```dart
Future<Friend> addFriend(String username)
```

**Parameters:**
- `username` (String): Username to add

**Returns:**
- `Friend`: Friend object

**Throws:**
- `FriendNotFoundException`: Username not found
- `AlreadyFriendsException`: Already friends with user

**Example:**
```dart
try {
  final friend = await ref.read(friendsProvider.notifier).addFriend('alex123');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Added ${friend.displayName}!')),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e')),
  );
}
```

---

#### `removeFriend`

**Signature:**
```dart
Future<void> removeFriend(String friendId)
```

---

#### `getFriend`

**Signature:**
```dart
Friend? getFriend(String friendId)
```

---

#### `getActivities`

**Signature:**
```dart
List<FriendActivity> getActivities({int limit = 20})
```

**Returns:**
- Recent friend activities, sorted by timestamp

---

#### `refreshFriends`

**Signature:**
```dart
Future<void> refreshFriends()
```

**Behavior:**
- Fetches latest friend data from server
- Updates local cache

---

### Friend Model

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
  final List<String> achievements;
  
  bool get isOnline => DateTime.now().difference(lastActive).inMinutes < 5;
}
```

---

## Error Handling

### Common Exceptions

```dart
// Adaptive Difficulty
class InsufficientDataException implements Exception {}

// Achievements
class AchievementNotFoundException implements Exception {}

// Hearts
class HeartsDepleted implements Exception {}

// Spaced Repetition
class CardNotFoundException implements Exception {}

// Friends
class FriendNotFoundException implements Exception {}
class AlreadyFriendsException implements Exception {}
```

### Example Error Handling

```dart
try {
  final recommendation = difficultyService.getDifficultyRecommendation(
    topicId: topicId,
    profile: profile,
  );
} on InsufficientDataException {
  // Fall back to default difficulty
  recommendation = DifficultyRecommendation(
    suggestedLevel: DifficultyLevel.easy,
    confidence: 0.0,
    reason: 'Not enough data yet. Starting with Easy.',
  );
}
```

---

## Type Definitions

### Enums

```dart
// Difficulty
enum DifficultyLevel { easy, medium, hard, expert }
enum PerformanceTrend { improving, stable, declining }

// Achievements
enum AchievementRarity { bronze, silver, gold, platinum }
enum AchievementCategory { learningProgress, streaks, xpMilestones, special, engagement }

// Spaced Repetition
enum ConceptType { lesson, question, term, concept }
enum MasteryLevel { new_, learning, familiar, proficient, mastered }
enum ReviewInterval { immediate, hour4, day1, day3, week1, week2, month1, month3, month6 }
```

---

## Best Practices

### 1. Always await async operations
```dart
// ❌ Wrong
ref.read(userProfileProvider.notifier).loseHeart();

// ✅ Correct
await ref.read(userProfileProvider.notifier).loseHeart();
```

### 2. Check for null before using optional values
```dart
// ❌ Wrong
final skillLevel = profile.skillProfile.getSkillLevel(topicId);

// ✅ Correct
final skillLevel = profile.skillProfile?.getSkillLevel(topicId) ?? 0.0;
```

### 3. Use try-catch for external operations
```dart
try {
  final friend = await friendsProvider.addFriend(username);
} catch (e) {
  // Handle error gracefully
  showErrorDialog(context, e.toString());
}
```

### 4. Persist after state changes
```dart
// After updating profile
await ref.read(storageProvider).saveUserProfile(updatedProfile);
```

### 5. Filter for new unlocks
```dart
// Only show notifications for newly unlocked achievements
for (final result in results.where((r) => r.wasJustUnlocked)) {
  await AchievementNotification.show(context, result.achievement, result.xpAwarded);
}
```

---

## Version Information

- **API Version:** 1.0.0
- **Last Updated:** 2025-02-07
- **Compatibility:** Flutter 3.0+, Dart 3.0+
- **Dependencies:**
  - flutter_riverpod: ^2.4.0
  - shared_preferences: ^2.2.0

---

## Support

For questions or issues:
1. Check the [Integration Guide](WAVE3_INTEGRATION_GUIDE.md)
2. Review [Testing Guide](WAVE3_TESTING_GUIDE.md)
3. See [Troubleshooting FAQ](WAVE3_INTEGRATION_GUIDE.md#troubleshooting-faq)

**Happy coding! 🚀**
