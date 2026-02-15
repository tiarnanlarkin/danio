# Analytics Events Tracking

## Overview
This document describes all analytics events tracked in the Aquarium App using Firebase Analytics.

**Status:** Currently disabled pending Firebase configuration.  
**To enable:** Follow [FIREBASE_SETUP_GUIDE.md](./FIREBASE_SETUP_GUIDE.md)

## Screen Views

Screen views are automatically tracked via `FirebaseAnalyticsObserver` added to MaterialApp.

### Tracked Screens
- `home` - Main home/living room screen
- `tank_detail` - Tank detail view
- `create_tank` - Tank creation screen
- `edit_tank` - Tank editing screen
- `learn` - Learning/education screen
- `lesson_detail` - Individual lesson view
- `quiz` - Quiz/test screen
- `achievements` - Achievements gallery
- `settings` - App settings
- `profile` - User profile screen
- `livestock_detail` - Fish/livestock detail
- `equipment_detail` - Equipment detail
- `journal` - User journal/diary
- `search` - Search screen
- `shop` - In-app shop (if implemented)
- `analytics` - Analytics dashboard
- `leaderboard` - Leaderboard screen
- `backup_restore` - Backup/restore screen
- `onboarding` - Initial app onboarding
- `profile_creation` - Profile creation

**Implementation:** Add in each screen's `initState()`:
```dart
@override
void initState() {
  super.initState();
  // FirebaseAnalyticsService().logScreenView('screen_name');
}
```

## Custom Events

### Tank Events

#### tank_created
User creates a new aquarium tank.

**Parameters:**
- `tank_type` (String): Type of tank (freshwater, saltwater, planted, reef, etc.)
- `size` (double): Tank size in liters
- `difficulty` (String): beginner, intermediate, advanced

**Trigger:** When user successfully creates a tank

**Code location:** `create_tank_screen.dart`, `tank_provider.dart`

```dart
// FirebaseAnalyticsService().logTankCreated(
//   tankType: tank.type,
//   size: tank.volumeLiters,
// );
```

---

#### tank_deleted
User deletes a tank.

**Parameters:**
- `tank_id` (String): Unique tank identifier
- `tank_type` (String): Type of tank

**Trigger:** When user confirms tank deletion

---

#### tank_edited
User updates tank details.

**Parameters:**
- `tank_id` (String): Unique tank identifier
- `tank_type` (String): Type of tank
- `field_changed` (String): What was edited (name, size, type, etc.)

**Trigger:** When user saves tank edits

---

### Learning Events

#### lesson_started
User opens/starts a lesson.

**Parameters:**
- `lesson_id` (String): Unique lesson identifier
- `topic` (String): Learning topic/category
- `difficulty` (String): beginner, intermediate, advanced

**Trigger:** When lesson view loads

```dart
// FirebaseAnalyticsService().logLessonStarted(
//   lessonId: lesson.id,
//   topic: lesson.topic,
// );
```

---

#### lesson_completed
User finishes a lesson.

**Parameters:**
- `lesson_id` (String): Unique lesson identifier
- `topic` (String): Learning topic/category
- `score` (int): User's score (0-100)
- `time_spent_seconds` (int): Time spent on lesson
- `attempts` (int): Number of attempts

**Trigger:** When user completes lesson

```dart
// FirebaseAnalyticsService().logLessonCompleted(
//   lessonId: lesson.id,
//   topic: lesson.topic,
//   score: score,
// );
```

---

#### quiz_attempt
User takes a quiz/test.

**Parameters:**
- `quiz_id` (String): Unique quiz identifier
- `score` (int): Score achieved
- `total_questions` (int): Total questions in quiz
- `percentage` (int): Score percentage (auto-calculated)
- `topic` (String): Quiz topic
- `difficulty` (String): Quiz difficulty

**Trigger:** When quiz is submitted

```dart
// FirebaseAnalyticsService().logQuizAttempt(
//   quizId: quiz.id,
//   score: correctAnswers,
//   totalQuestions: quiz.questions.length,
// );
```

---

### Gamification Events

#### achievement_unlocked
User unlocks an achievement.

**Parameters:**
- `achievement_id` (String): Achievement identifier
- `achievement_name` (String): Achievement display name
- `category` (String): Achievement category

**Trigger:** When achievement criteria is met

```dart
// FirebaseAnalyticsService().logAchievementUnlocked(
//   achievementId: achievement.id,
//   achievementName: achievement.name,
// );
```

---

#### streak_milestone
User reaches a streak milestone.

**Parameters:**
- `streak_days` (int): Current streak length
- `is_record` (bool): Whether this is a personal record

**Trigger:** At 7, 14, 30, 60, 90, 180, 365 day milestones

```dart
// FirebaseAnalyticsService().logStreakMilestone(
//   streakDays: profile.currentStreak,
// );
```

---

#### xp_milestone
User reaches an XP milestone.

**Parameters:**
- `total_xp` (int): User's total XP
- `milestone` (int): Milestone reached (100, 500, 1000, etc.)

**Trigger:** At 100, 500, 1000, 2000, 5000, 10000 XP milestones

```dart
// FirebaseAnalyticsService().logXpMilestone(
//   totalXp: profile.totalXp,
//   milestone: milestone,
// );
```

---

#### level_up
User levels up.

**Parameters:**
- `level` (int): New level
- `character` (String): User's character/profile type

**Trigger:** When XP threshold is crossed

```dart
// FirebaseAnalyticsService().logLevelUp(
//   level: newLevel,
//   character: profile.experienceLevel,
// );
```

---

### User Actions

#### search_performed
User performs a search.

**Parameters:**
- `query` (String): Search query text (sanitized)
- `results_count` (int): Number of results returned
- `category` (String): What they're searching (tanks, livestock, equipment, lessons)

**Trigger:** When search is executed

```dart
// FirebaseAnalyticsService().logSearchPerformed(
//   query: query.substring(0, min(50, query.length)), // Limit length
//   resultsCount: results.length,
// );
```

---

#### filter_applied
User applies a filter.

**Parameters:**
- `filter_type` (String): Type of filter (difficulty, category, status, etc.)
- `filter_value` (String): Value selected
- `screen` (String): Where filter was applied

**Trigger:** When filter is applied

```dart
// FirebaseAnalyticsService().logFilterApplied(
//   filterType: 'difficulty',
//   filterValue: selectedDifficulty,
// );
```

---

#### settings_changed
User modifies a setting.

**Parameters:**
- `setting_name` (String): Setting that was changed
- `new_value` (String): New value (sanitized)
- `old_value` (String): Previous value (optional)

**Trigger:** When setting is saved

```dart
// FirebaseAnalyticsService().logSettingsChanged(
//   settingName: 'theme_mode',
//   newValue: themeMode.toString(),
// );
```

---

### Standard Firebase Events

#### app_open
App is opened.

**Automatic** - logged via `FirebaseAnalytics.instance.logAppOpen()`

**Call in:** `main.dart` when app initializes

---

#### tutorial_begin
User starts onboarding tutorial.

**Trigger:** When onboarding screen loads

```dart
// FirebaseAnalyticsService().logTutorialBegin();
```

---

#### tutorial_complete
User completes onboarding.

**Trigger:** When onboarding is finished

```dart
// FirebaseAnalyticsService().logTutorialComplete();
```

---

## User Properties

User properties persist across sessions and are used for segmentation.

### experience_level
User's skill level: `beginner`, `intermediate`, `advanced`

**Set when:** User creates profile or updates skill level

```dart
// FirebaseAnalyticsService().setExperienceLevel('intermediate');
```

---

### tank_count
Number of tanks user has.

**Set when:** Tank is created or deleted

```dart
// FirebaseAnalyticsService().setTankCount(tanks.length);
```

---

### preferred_tank_type
User's most common tank type.

**Set when:** Calculated from tank collection

```dart
// FirebaseAnalyticsService().setPreferredTankType('planted');
```

---

### learning_style
How user engages with learning content: `casual`, `dedicated`, `completionist`

**Set when:** Calculated from learning patterns

```dart
// FirebaseAnalyticsService().setUserProperty(
//   name: 'learning_style',
//   value: 'dedicated',
// );
```

---

### days_since_install
Days since app was first installed.

**Set when:** Calculated periodically

---

### total_sessions
Total number of app sessions.

**Updated:** On each app open

---

## Implementation Checklist

### Phase 1: Core Events (10-15 screens)
- [ ] Home screen - screen_view
- [ ] Tank detail - screen_view
- [ ] Create tank - screen_view + tank_created event
- [ ] Learn screen - screen_view
- [ ] Lesson detail - lesson_started, lesson_completed
- [ ] Quiz screen - quiz_attempt
- [ ] Achievements - screen_view + achievement_unlocked
- [ ] Settings - screen_view + settings_changed
- [ ] Profile creation - tutorial_begin, tutorial_complete
- [ ] Search - search_performed
- [ ] Onboarding - screen_view

### Phase 2: Additional Events
- [ ] Tank editing - tank_edited, tank_deleted
- [ ] Gamification milestones - streak_milestone, xp_milestone
- [ ] User properties - experience_level, tank_count
- [ ] Filters - filter_applied
- [ ] Detailed learning metrics

### Phase 3: Advanced Analytics
- [ ] Session duration tracking
- [ ] Feature usage heatmaps
- [ ] A/B testing integration
- [ ] Crash correlation with user properties
- [ ] Performance monitoring integration

## Analytics Dashboard Views

### Key Metrics to Track
1. **Engagement**
   - Daily Active Users (DAU)
   - Weekly Active Users (WAU)
   - Session duration
   - Sessions per user

2. **Learning Progress**
   - Lessons completed per user
   - Quiz completion rate
   - Average quiz scores
   - Learning time distribution

3. **Retention**
   - Day 1, 7, 30 retention
   - Streak maintenance rate
   - Churn prediction

4. **Feature Usage**
   - Most viewed screens
   - Tank creation rate
   - Learning vs tank management time split
   - Search query patterns

5. **User Segmentation**
   - By experience level
   - By tank type preference
   - By learning engagement
   - By device type

## Privacy & Compliance

### PII Protection
- ❌ Never log personally identifiable information
- ❌ No email addresses, usernames, or real names
- ❌ No location data without explicit consent
- ✅ Use anonymized user IDs
- ✅ Sanitize search queries (remove potential PII)
- ✅ Limit string lengths in parameters

### GDPR Compliance
- Users can opt-out of analytics in settings
- Respect system-level tracking preferences
- Provide data deletion mechanism
- Document data retention policies

### Implementation
```dart
// Check user consent before initializing analytics
final hasConsent = await checkAnalyticsConsent();
if (hasConsent) {
  await FirebaseAnalyticsService().initialize();
}
```

## Testing

### Debug Mode
Analytics is disabled in debug mode by default (see `firebase_analytics_service.dart`).

To test analytics in debug mode:
1. Temporarily set `kDebugMode` check to false
2. Run app
3. Check Firebase Console → Analytics → DebugView
4. Verify events appear correctly

### Production Testing
1. Test with internal users first
2. Verify event parameters are correct
3. Check user properties are set
4. Monitor for missing/incorrect data
5. Validate funnels and conversion tracking

## Resources

- [Firebase Analytics Documentation](https://firebase.google.com/docs/analytics)
- [Best Practices for Analytics](https://firebase.google.com/docs/analytics/best-practices)
- [Privacy and Security](https://firebase.google.com/support/privacy)
- [Event Reference](https://support.google.com/analytics/answer/9267735)
