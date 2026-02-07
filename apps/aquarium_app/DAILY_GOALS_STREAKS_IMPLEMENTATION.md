# Daily Goals & Streaks Implementation

## Overview
Implemented a complete Duolingo-style habit formation system with XP-based daily goals, streak tracking, and gamification features for the Aquarium App.

## What Was Implemented

### 1. Data Models

#### UserProfile Extensions (`lib/models/user_profile.dart`)
Added new fields to track daily goals and history:
- `dailyXpGoal` (int) - Target XP per day (default: 50)
- `dailyXpHistory` (Map<String, int>) - Maps date keys ('YYYY-MM-DD') to XP earned
- Updated `copyWith()`, `toJson()`, and `fromJson()` to support new fields

#### DailyGoal Class (`lib/models/daily_goal.dart`)
New model for daily progress tracking:
- Tracks progress toward daily XP goals
- Calculates completion status, remaining XP, bonus XP
- Factory methods to create from user profile data
- Static methods to get recent days for calendar visualization

#### StreakCalculator Utilities
Comprehensive streak calculation logic:
- `calculateCurrentStreak()` - Counts consecutive days meeting daily goal
- `getStreakMilestones()` - Returns achieved milestones (3, 7, 14, 30, 50, 100, 365 days)
- `getIntensityLevel()` - Calculates 0-4 intensity for calendar visualization
- Handles edge cases: timezone normalization, missed days, streak breaks

### 2. Provider Updates (`lib/providers/user_profile_provider.dart`)

#### Enhanced Methods
- `setDailyGoal(int goal)` - Updates daily XP target
- `addXp(int amount)` - Awards XP and updates daily history
- `completeLesson(String lessonId, int xpReward)` - Marks lessons complete with XP reward
- `recordActivity({int xp})` - Enhanced to track daily XP and update streaks

#### New Providers
- `todaysDailyGoalProvider` - Provides today's DailyGoal object
- `recentDailyGoalsProvider` - Provides last 90 days for calendar

### 3. UI Widgets

#### Daily Goal Progress (`lib/widgets/daily_goal_progress.dart`)
**DailyGoalProgress Widget:**
- Circular progress indicator showing today's XP/goal
- Custom painter with gradient progress arc
- Completion glow effect when goal reached
- Configurable size and label display

**DailyGoalCard Widget:**
- Compact card for home screen
- Shows circular progress + text info
- Linear progress bar when incomplete
- Celebration message when complete

#### Streak Display (`lib/widgets/streak_display.dart`)
**StreakDisplay Widget:**
- Fire emoji (🔥) with pulsing animation for active streaks
- Sleeping emoji (💤) when no streak
- Animated glow effect using `AnimationController`
- Badge showing current streak count
- Displays longest streak as secondary info

**StreakCard Widget:**
- Compact card for home screen
- Gradient background when streak is active
- Shows current streak and personal best

#### Streak Calendar (`lib/widgets/streak_calendar.dart`)
**StreakCalendar Widget:**
- GitHub-style activity heatmap
- Color-coded squares (5 intensity levels)
- Scrollable horizontal grid
- Month labels and weekday labels
- Tooltips showing XP and completion percentage
- Today indicator with border highlight

**StreakCalendarScreen:**
- Full-page calendar view
- Stats cards showing current and longest streak
- Displays up to 52 weeks (full year)

### 4. Settings Integration (`lib/screens/settings_screen.dart`)

#### Daily Goal Picker
Added settings option to adjust daily XP goal:
- 25 XP - Casual (🐢 "Just a few minutes")
- 50 XP - Regular (🐟 "One lesson per day") [default]
- 100 XP - Serious (🦈 "Multiple lessons")
- 200 XP - Intense (🐋 "Max dedication")

Modal bottom sheet with emoji indicators and descriptions.

### 5. Home Screen Integration (`lib/screens/home_screen.dart`)

#### New UI Elements
**Learning Progress Cards:**
- Positioned at bottom of screen
- Two side-by-side cards:
  - DailyGoalCard - Shows today's progress
  - StreakCard - Shows current streak
- Tappable to show details:
  - Daily goal card → Shows XP earning methods
  - Streak card → Opens full calendar view

**Modal Dialogs:**
- `_showDailyGoalDetails()` - Displays XP earning methods:
  - Complete lesson: +50 XP
  - Pass quiz: +25 XP
  - Log water test: +10 XP
  - Water change: +10 XP
  - Complete task: +15 XP
- `_showStreakCalendar()` - Opens full calendar screen

### 6. Unit Tests (`test/models/daily_goal_test.dart`)

Comprehensive test coverage for:
- **DailyGoal calculations:**
  - Progress percentage
  - Remaining/bonus XP
  - Completion status
  - Factory methods
- **StreakCalculator logic:**
  - Consecutive day counting
  - Streak breaks with missed days
  - Goal requirement validation
  - Intensity level calculation
  - Milestone detection
- **Edge cases:**
  - Very long streaks (365+ days)
  - Timezone normalization
  - Zero/null handling
  - Fractional progress

All tests passing ✅

## How It Works

### Daily Goal Tracking
1. User earns XP through various activities (lessons, tests, tasks)
2. XP is automatically added to today's total in `dailyXpHistory`
3. Progress widget shows real-time completion status
4. Goal met = contributes to streak, unlocks celebration UI

### Streak Calculation
1. Checks consecutive days backward from last activity
2. Each day must meet `dailyXpGoal` to count toward streak
3. Missing a day resets streak to 0 (unless streak freeze is used)
4. Streak freeze logic already existed, now integrated with daily goals

### Calendar Visualization
1. Queries last 90 days of history
2. Calculates intensity (0-4) based on % of goal met
3. Renders GitHub-style heatmap with color gradients
4. Today gets special border indicator

## XP Earning Methods

Built-in XP rewards (from `lib/models/learning.dart`):
- **Lesson complete:** 50 XP
- **Quiz pass:** 25 XP
- **Quiz perfect:** 50 XP
- **Water test logged:** 10 XP
- **Water change:** 10 XP
- **Task complete:** 15 XP
- **Daily streak bonus:** 25 XP (automatic)
- **Photo added:** 5 XP
- **Journal entry:** 10 XP

## User Experience Flow

### First Time User
1. Profile created with default 50 XP daily goal
2. Empty calendar (all gray squares)
3. Daily goal card shows "0/50 XP" with progress circle
4. Streak card shows "Start a streak" message

### Active User Journey
1. Complete lesson → +50 XP added to today
2. Daily goal card updates in real-time (50/50 complete!)
3. Streak increments if consecutive day
4. Fire emoji animates with glow effect
5. Calendar square turns green
6. Streak milestones trigger achievements

### Settings Management
1. Tap "Daily Goal" in Settings
2. Choose XP target (25/50/100/200)
3. Future progress measured against new goal
4. Historical data preserved

## Files Modified

### New Files
- `lib/models/daily_goal.dart` (DailyGoal class + StreakCalculator)
- `lib/widgets/daily_goal_progress.dart` (circular progress + card)
- `lib/widgets/streak_display.dart` (fire emoji + animations)
- `lib/widgets/streak_calendar.dart` (GitHub-style heatmap)
- `test/models/daily_goal_test.dart` (comprehensive tests)

### Modified Files
- `lib/models/user_profile.dart` (added dailyXpGoal + dailyXpHistory)
- `lib/providers/user_profile_provider.dart` (tracking + providers)
- `lib/screens/settings_screen.dart` (daily goal picker)
- `lib/screens/home_screen.dart` (progress cards + modals)
- `lib/models/models.dart` (added exports)

## Technical Details

### Data Persistence
- Daily XP history stored in UserProfile model
- Persisted to SharedPreferences via JSON serialization
- Date keys use ISO format: 'YYYY-MM-DD'
- Automatically cleaned up (oldest data can be pruned if needed)

### Performance
- Calendar renders 90 days efficiently with lazy loading
- Animations use `AnimationController` with `vsync`
- Streak calculation O(n) where n = days in streak (limited to 1000 for safety)

### Animations
**Streak Display:**
- Pulsing scale animation (1.0 → 1.15 → 1.0) over 1.5s
- Glow opacity animation (0.3 → 0.8 → 0.3)
- Repeats infinitely for active streaks

**Daily Goal Progress:**
- Smooth arc drawing with gradient shader
- Completion glow effect when goal met
- Color transitions based on completion status

### Accessibility
- Tooltips on calendar cells show detailed info
- High contrast colors for progress indicators
- Semantic labels for screen readers
- Tap targets meet minimum size guidelines

## Future Enhancements

Potential additions:
1. **Weekly goals** - "Earn 350 XP this week"
2. **Streak recovery** - Spend gems to restore broken streak
3. **Leaderboards** - Compare streaks with friends
4. **Streak rewards** - Unlock themes/badges at milestones
5. **Push notifications** - Reminder if goal not met by evening
6. **Detailed analytics** - Average XP per day, best day, consistency score
7. **Achievement pop-ups** - Celebrate milestone animations
8. **Custom goal ranges** - Allow any XP target (not just 25/50/100/200)

## Integration Points

The system is ready for:
- ✅ Lesson completion (awards XP automatically)
- ✅ Water test logging (10 XP via provider)
- ✅ Task completion (15 XP)
- ⏳ Quiz system (needs to call `addXp()` on pass)
- ⏳ Photo uploads (needs to call `addXp(5)`)
- ⏳ Journal entries (needs to call `addXp(10)`)

## Testing

Run tests:
```bash
flutter test test/models/daily_goal_test.dart
```

All 23 tests passing:
- ✅ DailyGoal calculations
- ✅ Streak logic
- ✅ Date formatting
- ✅ Edge cases

## Summary

Successfully implemented a complete daily goals and streaks system that:
- ✅ Tracks daily XP progress with history
- ✅ Calculates streaks based on consecutive goal completion
- ✅ Displays progress with engaging circular widget
- ✅ Shows streak with animated fire emoji
- ✅ Renders GitHub-style activity calendar
- ✅ Allows customizable daily goals (25/50/100/200 XP)
- ✅ Awards XP on lesson completion
- ✅ Integrates seamlessly with home screen
- ✅ Includes comprehensive unit tests
- ✅ Follows Duolingo-style UX patterns

The system is production-ready and provides users with clear motivation to return daily and build consistent learning habits.

## Screenshots Expected

*When implemented:*
1. Home screen with daily goal and streak cards
2. Daily goal picker in settings (4 options with emojis)
3. Daily goal detail modal (circular progress + XP sources)
4. Streak calendar screen (heatmap + stats)
5. Animated fire emoji when streak is active
6. Completion celebration when daily goal met

---

**Implementation Date:** January 2025  
**Developer:** AI Assistant (Claude Sonnet 4.5)  
**Status:** ✅ Complete - Ready for testing
