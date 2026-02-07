# Spaced Repetition System Implementation

## Overview
This document describes the implementation of a spaced repetition system for the Aquarium App learning module. The system helps users review forgotten lessons using a forgetting curve algorithm, ensuring long-term knowledge retention.

## Features Implemented

### 1. LessonProgress Model
**File:** `lib/models/lesson_progress.dart`

A new model to track individual lesson completion and review history:

```dart
class LessonProgress {
  final String lessonId;
  final DateTime completedDate;      // When first completed
  final DateTime? lastReviewDate;    // Most recent review
  final int reviewCount;             // Number of times reviewed
  final double strength;             // 0-100, decays over time
}
```

**Key Properties:**
- `currentStrength` - Calculated property that applies the forgetting curve algorithm
- `needsReview` - Boolean indicating if strength < 50%
- `isWeak` - Boolean indicating if strength < 70%
- `reviewed()` - Method to create updated progress after review

### 2. Forgetting Curve Algorithm

**Decay Schedule:**
- **Day 0 (completion/review):** 100% strength
- **Day 1:** 70% strength
- **Day 7:** 40% strength
- **Day 30+:** 0% strength

**Implementation:**
```dart
double get currentStrength {
  final daysSinceReview = DateTime.now().difference(referenceDate).inDays;
  
  if (daysSinceReview == 0) return 100.0;
  else if (daysSinceReview == 1) return 70.0;
  else if (daysSinceReview <= 7) {
    // Linear interpolation between 70% and 40%
    return 70.0 - ((daysSinceReview - 1) / 6) * 30.0;
  } else if (daysSinceReview <= 30) {
    // Linear interpolation between 40% and 0%
    return 40.0 - ((daysSinceReview - 7) / 23) * 40.0;
  } else {
    return 0.0;
  }
}
```

The algorithm uses linear interpolation for smooth transitions between milestones.

### 3. UserProfile Updates
**File:** `lib/models/user_profile.dart`

**Added field:**
```dart
final Map<String, LessonProgress> lessonProgress;
```

This map stores lesson progress keyed by lesson ID. The legacy `completedLessons` list is maintained for backward compatibility.

**JSON Serialization:**
- `toJson()` - Converts lessonProgress map to JSON
- `fromJson()` - Reconstructs lessonProgress map from JSON
- Handles migration from old format (no lessonProgress) gracefully

### 4. UserProfileProvider Enhancements
**File:** `lib/providers/user_profile_provider.dart`

**New Methods:**

#### completeLesson() - Updated
Now creates a `LessonProgress` entry when a lesson is completed:
```dart
Future<void> completeLesson(String lessonId, int xpReward) async {
  final progress = LessonProgress(
    lessonId: lessonId,
    completedDate: DateTime.now(),
    reviewCount: 0,
    strength: 100.0,
  );
  // Updates lessonProgress map and awards XP
}
```

#### reviewLesson() - New
Handles lesson reviews in practice mode:
```dart
Future<void> reviewLesson(String lessonId, int xpReward) async {
  // Updates existing progress with review timestamp
  // Resets strength to 100%
  // Increments reviewCount
  // Awards half XP (lesson.xpReward / 2)
}
```

#### getLessonsNeedingReview() - New
Returns all lessons with strength < 50%, sorted by weakest first:
```dart
List<LessonProgress> getLessonsNeedingReview() {
  return lessonProgress.values
    .where((p) => p.needsReview)
    .toList()
    ..sort((a, b) => a.currentStrength.compareTo(b.currentStrength));
}
```

#### getWeakestLessons() - New
Returns the N weakest lessons for practice:
```dart
List<LessonProgress> getWeakestLessons({int count = 5}) {
  return getLessonsNeedingReview().take(count).toList();
}
```

### 5. Practice Screen
**File:** `lib/screens/practice_screen.dart`

A new screen showing lessons that need review:

**Features:**
- **Empty State** - Shows encouraging message when no reviews needed
- **Practice List** - Displays up to 5 weakest lessons
- **Strength Indicator** - Visual progress bar showing current strength
  - Green (70-100%): Good retention
  - Yellow (40-69%): Needs attention
  - Red (0-39%): Critical - review urgently
- **Review Stats** - Shows review count and time since last review
- **XP Reward** - Half XP for reviews (prevents farming)

**UI Components:**
- Header with practice mode explanation
- Info card explaining the forgetting curve
- Lesson cards with:
  - Lesson title and path
  - Current strength percentage and visual bar
  - Review history
  - Time since last review
  - XP reward (50% of original)

### 6. Practice Lesson Screen
**File:** `lib/screens/practice_screen.dart` (PracticeLessonScreen)

Extended version of `LessonScreen` that handles both initial completion and reviews:

**Key Differences:**
- **isReview flag** - Determines behavior
- **XP Calculation** - Half XP when reviewing
- **Visual Indicator** - Blue banner showing "Review Mode"
- **Completion Logic** - Calls `reviewLesson()` instead of `completeLesson()`

**Review Flow:**
1. User selects weak lesson from Practice screen
2. Reads lesson content again
3. Takes quiz (if available)
4. Strength resets to 100%
5. Review count increments
6. Half XP awarded
7. Streak updated (reviews count as daily activity)

## Integration Points

### How to Add Practice Button to Learn Screen

To add a "Practice" button to your main learn/lessons screen:

```dart
// In your learn screen widget
FloatingActionButton(
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PracticeScreen(),
      ),
    );
  },
  child: const Icon(Icons.fitness_center),
  tooltip: 'Practice weak lessons',
)
```

Or as a card in the lesson list:
```dart
Card(
  child: ListTile(
    leading: Icon(Icons.refresh, color: AppColors.primary),
    title: Text('Practice'),
    subtitle: Text('Review lessons before you forget them'),
    trailing: Consumer(
      builder: (context, ref, _) {
        final weakCount = ref
            .read(userProfileProvider.notifier)
            .getWeakestLessons()
            .length;
        if (weakCount == 0) return null;
        return Chip(
          label: Text('$weakCount'),
          backgroundColor: AppColors.error,
        );
      },
    ),
    onTap: () => Navigator.push(...),
  ),
)
```

## Data Flow

### Initial Lesson Completion
```
User completes lesson
    ↓
LessonScreen._completeLesson()
    ↓
UserProfileProvider.completeLesson()
    ↓
Creates LessonProgress(strength: 100%)
    ↓
Saves to lessonProgress map
    ↓
Awards full XP
```

### Review Flow
```
Practice screen shows weak lessons
    ↓
User selects lesson
    ↓
PracticeLessonScreen (isReview: true)
    ↓
User completes review
    ↓
UserProfileProvider.reviewLesson()
    ↓
Updates LessonProgress.reviewed()
    ↓
Strength → 100%, reviewCount++
    ↓
Awards half XP
```

### Strength Decay (Automatic)
```
Every time currentStrength is accessed
    ↓
Calculates days since last review
    ↓
Applies forgetting curve formula
    ↓
Returns decayed strength value
```

## Testing Recommendations

### Manual Testing Scenarios

1. **First Lesson Completion**
   - Complete a lesson
   - Verify LessonProgress created with strength 100%
   - Check XP awarded correctly

2. **Practice Screen Empty State**
   - With no lessons completed → Empty state
   - With all lessons at 100% strength → "All caught up!"

3. **Strength Decay**
   - Complete lesson
   - Manually adjust system date forward
   - Verify strength decays according to curve
   - Day 1 → 70%, Day 7 → 40%, Day 30+ → 0%

4. **Review Lesson**
   - Find weak lesson in practice screen
   - Complete review
   - Verify strength resets to 100%
   - Verify half XP awarded
   - Verify reviewCount incremented

5. **Weak Lessons Selection**
   - Complete multiple lessons
   - Fast-forward dates to create varied strengths
   - Verify practice screen shows 5 weakest
   - Verify sorted by strength (weakest first)

### Unit Test Examples

```dart
test('Forgetting curve calculates correctly', () {
  final progress = LessonProgress(
    lessonId: 'test',
    completedDate: DateTime.now().subtract(Duration(days: 7)),
  );
  expect(progress.currentStrength, equals(40.0));
});

test('Review resets strength to 100', () {
  final progress = LessonProgress(
    lessonId: 'test',
    completedDate: DateTime.now().subtract(Duration(days: 10)),
  );
  final reviewed = progress.reviewed();
  expect(reviewed.strength, equals(100.0));
  expect(reviewed.reviewCount, equals(1));
});
```

## Future Enhancements

### Potential Improvements

1. **Adaptive Difficulty**
   - Track quiz scores per lesson
   - Adjust decay rate based on performance
   - Faster decay for lessons with poor quiz results

2. **Smart Scheduling**
   - Predict optimal review time
   - Send notifications when lessons need review
   - "Review Streak" gamification

3. **Statistics Dashboard**
   - Graph showing strength over time
   - Review completion rate
   - Knowledge retention metrics

4. **Custom Review Sessions**
   - User-selected lessons
   - Review entire learning paths
   - Focus mode for specific topics

5. **Advanced Algorithms**
   - SM-2 (SuperMemo 2) algorithm
   - Leitner system
   - Customizable forgetting curves

## Migration Notes

### Backward Compatibility

The implementation maintains backward compatibility:

- `completedLessons` list is still maintained
- Users without `lessonProgress` data get empty map
- First access of old profiles auto-migrates on next lesson completion

### Data Migration Script

If needed, migrate existing profiles:

```dart
Future<void> migrateLessonProgress() async {
  final profile = userProfile; // Get current profile
  final now = DateTime.now();
  
  final newProgress = <String, LessonProgress>{};
  for (final lessonId in profile.completedLessons) {
    if (!profile.lessonProgress.containsKey(lessonId)) {
      // Create progress for old lessons (assume completed long ago)
      newProgress[lessonId] = LessonProgress(
        lessonId: lessonId,
        completedDate: now.subtract(Duration(days: 30)),
        strength: 0.0, // Force review
      );
    }
  }
  
  // Save updated profile
  await updateProfile(lessonProgress: {
    ...profile.lessonProgress,
    ...newProgress,
  });
}
```

## Performance Considerations

- **Strength Calculation:** Computed on-demand, not stored
- **Sorting:** Only sorts lessons needing review (typically < 20 items)
- **JSON Serialization:** Map structure is efficient for lookups
- **Memory:** LessonProgress objects are small (~200 bytes each)

## Accessibility

- Practice screen uses semantic labels
- Strength indicators have both visual (color) and text (percentage)
- Empty states provide clear guidance
- Buttons have descriptive tooltips

## Conclusion

This implementation provides a solid foundation for spaced repetition learning. The forgetting curve algorithm ensures lessons are reviewed at optimal intervals, improving long-term retention while rewarding users with XP to maintain engagement.

The system is extensible and can be enhanced with more sophisticated algorithms, analytics, and personalization features in future iterations.
