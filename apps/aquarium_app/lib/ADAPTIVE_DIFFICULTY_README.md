# Adaptive Difficulty System

Complete AI-powered difficulty adjustment system that dynamically adapts to user performance.

## Overview

The adaptive difficulty system tracks user performance across different learning topics and automatically recommends appropriate difficulty levels. It provides real-time feedback, mid-lesson adjustments, and detailed performance analytics.

## Features

✅ **Per-Topic Skill Tracking**: Individual skill levels (0.0-1.0) for each topic  
✅ **Performance History**: Rolling window of last 10 attempts per topic  
✅ **Dynamic Recommendations**: AI-powered difficulty suggestions based on:
- Score accuracy
- Time efficiency
- Mistake patterns
- Improvement trends
- Consistency (standard deviation)

✅ **Mid-Lesson Adjustments**: Real-time difficulty changes during lessons  
✅ **Manual Overrides**: Users can override automatic recommendations  
✅ **Visual Feedback**: Progress bars, badges, animations, and trend indicators  
✅ **Mastery Detection**: Identifies when users have mastered a topic  

## Components

### Models (`lib/models/adaptive_difficulty.dart`)

#### `DifficultyLevel` (enum)
- `easy` 🌱 - Basic concepts with hints
- `medium` ⭐ - Standard difficulty
- `hard` 🔥 - Advanced concepts
- `expert` 💎 - Expert level challenges

#### `PerformanceRecord`
Records a single attempt:
```dart
PerformanceRecord(
  timestamp: DateTime.now(),
  topicId: 'nitrogen_cycle',
  difficulty: DifficultyLevel.medium,
  score: 8,
  maxScore: 10,
  mistakeCount: 2,
  timeSpent: Duration(seconds: 300),
  completed: true,
)
```

#### `PerformanceHistory`
Maintains rolling window of 10 recent attempts:
- `averageAccuracy` - Mean accuracy (0.0-1.0)
- `averageTimeEfficiency` - Time performance metric
- `consecutiveCorrect` - Current streak
- `isStruggling` - True if 3+ recent failures
- `trend` - `improving` / `stable` / `declining`

#### `UserSkillProfile`
Global profile across all topics:
- `skillLevels` - Map of topic ID → skill level (0.0-1.0)
- `performanceHistory` - Map of topic ID → PerformanceHistory
- `manualOverrides` - User-set difficulty preferences

#### `DifficultyRecommendation`
AI recommendation output:
- `suggestedLevel` - Recommended DifficultyLevel
- `confidence` - 0.0-1.0 confidence score
- `reason` - Human-readable explanation
- `shouldIncrease/shouldDecrease` - Flags for UI

### Service (`lib/services/difficulty_service.dart`)

#### Key Methods

**`calculateSkillLevel(PerformanceHistory history) → double`**
Calculates 0.0-1.0 skill level based on:
- Accuracy (40% weight)
- Time efficiency (20%)
- Consistency (20%)
- Consecutive correct (20%)
- Improvement trend (15% bonus/penalty)

**`getDifficultyRecommendation(...) → DifficultyRecommendation`**
Returns recommended difficulty with explanation:
- Checks manual override first
- Uses overall profile for new topics
- Analyzes performance patterns
- Detects consecutive success → increase
- Detects struggling (3+ failures) → decrease

**`checkForMidLessonAdjustment(...) → DifficultyLevel?`**
Checks if difficulty should change during lesson:
- Needs 3+ questions answered
- 3 perfect answers → increase
- 3 failures → decrease
- Returns `null` if no change needed

**`updateProfileAfterLesson(...) → UserSkillProfile`**
Updates profile after lesson completion:
- Adds performance record
- Recalculates skill level
- Maintains rolling window

**`hasTopicMastery(...) → bool`**
Determines if topic is mastered:
- Skill level > 0.85
- 5+ attempts
- Last 3 attempts all > 80%
- Low variance (consistency)

### Screens (`lib/screens/difficulty_settings_screen.dart`)

Complete UI for viewing and managing difficulty:

**Overall Skill Card**
- Shows combined skill level across all topics
- Current difficulty badge
- Percentage mastery

**Skills by Topic**
- Individual skill bars for each topic
- Performance stats (attempts, avg score, trend)
- Mastery badges for completed topics

**Performance History**
- Recent 5 attempts
- Timestamp, topic, difficulty, score

**Manual Overrides**
- Dropdown per topic
- Override auto-recommendations
- Clear indication of current setting

**AI Recommendations**
- Cards for topics that should increase/decrease
- Explanations for each recommendation

### Widgets (`lib/widgets/difficulty_badge.dart`)

Reusable UI components:

**`DifficultyBadge`**
```dart
DifficultyBadge(
  difficulty: DifficultyLevel.hard,
  showLabel: true,
  size: 1.0,
)
```

**`SkillLevelIndicator`**
```dart
SkillLevelIndicator(
  skillLevel: 0.75,
  label: 'Water Chemistry',
  showPercentage: true,
)
```

**`PerformanceTrendWidget`**
```dart
PerformanceTrendWidget(
  trend: PerformanceTrend.improving,
  showLabel: true,
)
```

**`SkillLevelUpAnimation`**
Animated "Level Up" notification with emoji and message.

**`DifficultyChangeNotification`**
Shows when difficulty adjusts mid-lesson.

**`MasteryBadge`**
Gold trophy badge for mastered topics.

## Integration

### Step 1: Add to Storage Service

```dart
class StorageService {
  static const String _skillProfileKey = 'user_skill_profile';
  
  Future<void> saveSkillProfile(UserSkillProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_skillProfileKey, jsonEncode(profile.toJson()));
  }
  
  Future<UserSkillProfile> loadSkillProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_skillProfileKey);
    return json != null 
        ? UserSkillProfile.fromJson(jsonDecode(json))
        : UserSkillProfile.empty();
  }
}
```

### Step 2: Load in Main App

```dart
class _MyAppState extends State<MyApp> {
  late UserSkillProfile _skillProfile;
  final StorageService _storage = StorageService();
  final DifficultyService _difficultyService = DifficultyService();
  
  @override
  void initState() {
    super.initState();
    _loadSkillProfile();
  }
  
  Future<void> _loadSkillProfile() async {
    final profile = await _storage.loadSkillProfile();
    setState(() => _skillProfile = profile);
  }
  
  void _updateSkillProfile(UserSkillProfile newProfile) {
    setState(() => _skillProfile = newProfile);
    _storage.saveSkillProfile(newProfile);
  }
}
```

### Step 3: Integrate with Lesson Screen

**Before Lesson:**
```dart
final recommendation = _difficultyService.getDifficultyRecommendation(
  topicId: lesson.pathId,
  profile: _skillProfile,
);
DifficultyLevel currentDifficulty = recommendation.suggestedLevel;
```

**During Lesson:**
```dart
// After each question
final newDifficulty = _difficultyService.checkForMidLessonAdjustment(
  currentDifficulty: currentDifficulty,
  lessonAttempts: attemptsSoFar,
);

if (newDifficulty != null) {
  // Show notification
  // Update currentDifficulty
}
```

**After Lesson:**
```dart
final lessonRecord = PerformanceRecord(
  timestamp: DateTime.now(),
  topicId: lesson.pathId,
  difficulty: currentDifficulty,
  score: score,
  maxScore: totalQuestions,
  mistakeCount: mistakes,
  timeSpent: totalTime,
  completed: true,
);

final oldSkill = _skillProfile.getSkillLevel(lesson.pathId);

final updatedProfile = _difficultyService.updateProfileAfterLesson(
  currentProfile: _skillProfile,
  lessonRecord: lessonRecord,
);

final newSkill = updatedProfile.getSkillLevel(lesson.pathId);

final message = _difficultyService.getSkillChangeMessage(
  oldSkill: oldSkill,
  newSkill: newSkill,
  topicName: lesson.title,
);

if (message != null) {
  // Show "Level Up!" animation
}

_updateSkillProfile(updatedProfile);
```

### Step 4: Add Settings Button

```dart
IconButton(
  icon: Icon(Icons.insights),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DifficultySettingsScreen(
          skillProfile: _skillProfile,
          onProfileUpdated: _updateSkillProfile,
        ),
      ),
    );
  },
)
```

## Algorithm Details

### Skill Level Calculation

Weighted formula:
```
skill = (
  accuracy * 0.4 +
  timeEfficiency * 0.2 +
  consistency * 0.2 +
  (consecutiveCorrect / 10) * 0.2
) * improvementMultiplier

where:
  accuracy = averageScore / maxScore
  timeEfficiency = 1.0 for 30-60s per question
  consistency = 1.0 - standardDeviation
  improvementMultiplier = 1.15 (improving) | 1.0 (stable) | 0.85 (declining)
```

### Difficulty Mapping

| Skill Level | Difficulty |
|-------------|------------|
| < 0.3       | Easy 🌱    |
| 0.3 - 0.6   | Medium ⭐  |
| 0.6 - 0.8   | Hard 🔥    |
| > 0.8       | Expert 💎  |

### Mid-Lesson Triggers

**Increase Difficulty:**
- 3 consecutive questions with 95%+ accuracy
- Current difficulty < Expert
- → Move up one level

**Decrease Difficulty:**
- 3 consecutive questions with < 40% accuracy
- Current difficulty > Easy
- → Move down one level

### Mastery Requirements

ALL must be true:
- ✅ Skill level > 0.85
- ✅ At least 5 attempts
- ✅ Last 3 attempts all > 80% accuracy
- ✅ Standard deviation < 0.15 (consistent)

## Testing

Run tests:
```bash
cd /mnt/c/Users/larki/Documents/Aquarium\ App\ Dev/repo/apps/aquarium_app
flutter test test/difficulty_service_test.dart
```

Test coverage:
- ✅ Skill level calculation
- ✅ Difficulty recommendations
- ✅ Mid-lesson adjustments
- ✅ Profile updates
- ✅ Topic mastery detection
- ✅ Edge cases (zero division, extreme values)

## Topics

Current topics from `lesson_content.dart`:
- `nitrogen_cycle` - Nitrogen Cycle
- `water_parameters` - Water Parameters
- `first_fish` - First Fish
- `maintenance` - Maintenance
- `planted_tank` - Planted Tanks
- `equipment` - Equipment

Add new topics by:
1. Create lessons with unique `pathId`
2. System automatically tracks performance
3. Add display name to `_topicNames` map in settings screen

## Performance Considerations

- **Storage**: ~1-2KB per topic (10 records max)
- **Memory**: Lightweight - all data structures immutable
- **Computation**: O(n) where n = 10 (rolling window size)
- **Persistence**: JSON serialization via SharedPreferences

## Future Enhancements

Possible additions:
- [ ] Machine learning model for more accurate predictions
- [ ] Comparative analytics (vs other users)
- [ ] Streak bonuses for daily practice
- [ ] Difficulty-specific question pools
- [ ] Export performance data as CSV
- [ ] Time-of-day performance analytics
- [ ] Spaced repetition integration

## Troubleshooting

**Problem:** Difficulty doesn't change  
**Solution:** Check that `onProfileUpdated` callback saves to storage

**Problem:** Skills reset to 0  
**Solution:** Verify JSON serialization/deserialization in storage service

**Problem:** Recommendations seem wrong  
**Solution:** Ensure at least 3-5 attempts for accurate assessment

**Problem:** Mid-lesson adjustment too aggressive  
**Solution:** Adjust thresholds in `checkForMidLessonAdjustment` (currently 0.95 for increase, 0.4 for decrease)

## Credits

Designed and implemented for the Aquarium Hobby Learning App.  
Inspired by duolingo-style adaptive learning systems.

---

**Last Updated:** February 2025  
**Version:** 1.0.0
