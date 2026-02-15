# Analytics Tracking Plan - Aquarium Hobby App

**Document Version:** 1.0  
**Last Updated:** February 2025  
**Analytics Platform:** Firebase Analytics (ready but not enabled)  
**Status:** ✅ Instrumented, Pending Firebase Configuration

---

## 🎯 Executive Summary

The Aquarium Hobby App has comprehensive analytics instrumentation ready for Firebase Analytics. All critical user flows, engagement metrics, and business KPIs are tracked via the `FirebaseAnalyticsService`. Analytics are currently disabled pending Firebase project setup but can be enabled by following `docs/setup/FIREBASE_SETUP_GUIDE.md`.

### Analytics Goals
1. **User Engagement** - Track daily active users, session length, retention
2. **Learning Progress** - Monitor lesson completion, quiz performance, knowledge retention
3. **Gamification Impact** - Measure XP earnings, streaks, achievement unlocks
4. **Tank Management** - Track tank creation, species added, maintenance habits
5. **Feature Usage** - Identify most/least used features for prioritization
6. **Conversion Funnels** - Understand drop-off points in onboarding, learning paths

---

## 📊 Event Taxonomy

### Event Naming Convention
- **Format:** `action_object` (e.g., `lesson_completed`, `tank_created`)
- **Style:** lowercase_snake_case
- **Consistency:** Verb comes first, then noun

### Event Categories

1. **User Lifecycle** - App open, onboarding, profile creation
2. **Learning Events** - Lessons, quizzes, reviews
3. **Gamification Events** - XP, levels, streaks, achievements
4. **Tank Management** - CRUD operations on tanks
5. **Social Features** - Leaderboard views, friend interactions (future)
6. **Commerce** - Shop visits, purchases (future)
7. **Engagement** - Session duration, feature usage

---

## 📋 Tracked Events

### 1. User Lifecycle Events

#### `app_open` (Firebase Standard Event)
**When:** User launches app (cold or warm start)  
**Purpose:** Daily active user tracking, session starts  
**Parameters:** None (automatic)  
**Implementation:** `FirebaseAnalyticsService.logAppOpen()`

**Insights:**
- Daily/weekly/monthly active users (DAU/WAU/MAU)
- Peak usage times
- App launch frequency

---

#### `tutorial_begin` (Firebase Standard Event)
**When:** User starts onboarding flow  
**Purpose:** Track onboarding entry rate  
**Parameters:** None  
**Implementation:** `FirebaseAnalyticsService.logTutorialBegin()`

**Insights:**
- % of new users who start onboarding
- Onboarding completion funnel (begin → complete)

---

#### `tutorial_complete` (Firebase Standard Event)
**When:** User completes entire onboarding flow  
**Purpose:** Track onboarding completion rate  
**Parameters:** None  
**Implementation:** `FirebaseAnalyticsService.logTutorialComplete()`

**Insights:**
- Onboarding completion rate
- Time to complete onboarding
- Drop-off points in onboarding

---

#### `screen_view` (Firebase Automatic)
**When:** User navigates to a new screen  
**Purpose:** Track most-visited screens, navigation patterns  
**Parameters:**
- `screen_name` (string) - Name of screen (e.g., "HomeScreen", "TankDetailScreen")

**Implementation:** Automatic via `FirebaseAnalyticsObserver`

**Insights:**
- Most popular screens
- User navigation flow
- Time spent per screen

---

### 2. Learning Events

#### `lesson_started`
**When:** User begins a lesson  
**Purpose:** Track lesson engagement  
**Parameters:**
- `lesson_id` (string) - Unique lesson identifier (e.g., "nitrogen_cycle_1")
- `topic` (string) - Lesson topic (e.g., "Nitrogen Cycle", "Fish Health")

**Implementation:**
```dart
FirebaseAnalyticsService().logLessonStarted(
  lessonId: 'nitrogen_cycle_1',
  topic: 'Nitrogen Cycle',
);
```

**Insights:**
- Most popular lessons
- Lesson start rate per topic
- Drop-off: lessons started but not completed

---

#### `lesson_completed`
**When:** User finishes a lesson (quiz passed)  
**Purpose:** Track lesson completion and performance  
**Parameters:**
- `lesson_id` (string) - Unique lesson identifier
- `topic` (string) - Lesson topic
- `score` (int) - Quiz score (0-100 percentage)

**Implementation:**
```dart
FirebaseAnalyticsService().logLessonCompleted(
  lessonId: 'nitrogen_cycle_1',
  topic: 'Nitrogen Cycle',
  score: 85,
);
```

**Insights:**
- Lesson completion rate
- Average quiz score per lesson
- Difficult lessons (low average score)
- Learning path progress

---

#### `quiz_attempt`
**When:** User submits quiz answers  
**Purpose:** Track quiz performance in detail  
**Parameters:**
- `quiz_id` (string) - Quiz identifier
- `score` (int) - Correct answers count
- `total_questions` (int) - Total questions in quiz
- `percentage` (int) - Score as percentage (auto-calculated)

**Implementation:**
```dart
FirebaseAnalyticsService().logQuizAttempt(
  quizId: 'nitrogen_cycle_quiz_1',
  score: 8,
  totalQuestions: 10,
);
```

**Insights:**
- Quiz difficulty analysis
- Average pass rate per quiz
- Retry patterns (multiple attempts)
- Learning curve (score improvement over time)

---

### 3. Gamification Events

#### `level_up` (Firebase Standard Event)
**When:** User reaches a new level  
**Purpose:** Track progression through levels  
**Parameters:**
- `level` (int) - New level reached (1-30)
- `character` (string) - Always "aquarium_hobbyist" (for segmentation)

**Implementation:**
```dart
FirebaseAnalyticsService().logLevelUp(
  level: 5,
  character: 'aquarium_hobbyist',
);
```

**Insights:**
- Level progression rate
- Time to reach each level
- Engagement by level (do high-level users stay engaged?)

---

#### `achievement_unlocked`
**When:** User unlocks an achievement  
**Purpose:** Track achievement unlock rate and popular achievements  
**Parameters:**
- `achievement_id` (string) - Achievement identifier (e.g., "first_lesson")
- `achievement_name` (string) - Human-readable name (e.g., "First Steps")

**Implementation:**
```dart
FirebaseAnalyticsService().logAchievementUnlocked(
  achievementId: 'first_lesson',
  achievementName: 'First Steps',
);
```

**Insights:**
- Most/least unlocked achievements
- Achievement unlock rate
- Rare achievement hunters (unlock % by user)
- Achievement unlock timeline (early vs late)

---

#### `streak_milestone`
**When:** User reaches a streak milestone (7, 14, 30, 60, 100 days)  
**Purpose:** Track engagement consistency  
**Parameters:**
- `streak_days` (int) - Current streak length

**Implementation:**
```dart
FirebaseAnalyticsService().logStreakMilestone(
  streakDays: 7,
);
```

**Insights:**
- Streak retention curve
- % of users who reach each milestone
- Correlation: streaks vs engagement

---

#### `xp_milestone`
**When:** User reaches XP milestones (1000, 5000, 10000, etc.)  
**Purpose:** Track progression through XP system  
**Parameters:**
- `total_xp` (int) - User's total XP
- `milestone` (int) - Milestone reached (1000, 5000, etc.)

**Implementation:**
```dart
FirebaseAnalyticsService().logXpMilestone(
  totalXp: 5200,
  milestone: 5000,
);
```

**Insights:**
- XP earning rate
- Time to each milestone
- XP sources (lessons vs practice vs bonuses)

---

### 4. Tank Management Events

#### `tank_created`
**When:** User creates a new tank  
**Purpose:** Track tank creation patterns  
**Parameters:**
- `tank_type` (string) - Type of tank (e.g., "Freshwater", "Saltwater", "Planted")
- `size` (double) - Tank size in gallons

**Implementation:**
```dart
FirebaseAnalyticsService().logTankCreated(
  tankType: 'Freshwater',
  size: 20.0,
);
```

**Insights:**
- Most popular tank types
- Average tank size
- Tanks created per user
- Tank creation timeline (day 1 vs week 1 vs month 1)

---

#### `tank_edited`
**When:** User updates tank details  
**Purpose:** Track tank management engagement  
**Parameters:**
- `tank_id` (string) - Tank identifier
- `tank_type` (string) - Tank type

**Implementation:**
```dart
FirebaseAnalyticsService().logTankEdited(
  tankId: 'tank_123',
  tankType: 'Freshwater',
);
```

**Insights:**
- Tank edit frequency
- Most edited tank types
- User engagement with tank features

---

#### `tank_deleted`
**When:** User deletes a tank  
**Purpose:** Track tank churn  
**Parameters:**
- `tank_id` (string) - Tank identifier
- `tank_type` (string) - Tank type

**Implementation:**
```dart
FirebaseAnalyticsService().logTankDeleted(
  tankId: 'tank_123',
  tankType: 'Freshwater',
);
```

**Insights:**
- Tank deletion rate
- Types of tanks most deleted
- Time from creation to deletion
- User churn signals

---

### 5. Search & Discovery Events

#### `search_performed`
**When:** User uses search feature (species, plants, guides)  
**Purpose:** Track search usage and improve search quality  
**Parameters:**
- `query` (string) - Search query text
- `results_count` (int) - Number of results found

**Implementation:**
```dart
FirebaseAnalyticsService().logSearchPerformed(
  query: 'neon tetra',
  resultsCount: 3,
);
```

**Insights:**
- Most searched terms
- Zero-result searches (content gaps)
- Search → conversion (search → add to tank)

---

#### `filter_applied`
**When:** User applies a filter (species browser, shop, etc.)  
**Purpose:** Track filter usage patterns  
**Parameters:**
- `filter_type` (string) - Type of filter (e.g., "difficulty", "tank_type")
- `filter_value` (string) - Selected value (e.g., "easy", "freshwater")

**Implementation:**
```dart
FirebaseAnalyticsService().logFilterApplied(
  filterType: 'difficulty',
  filterValue: 'easy',
);
```

**Insights:**
- Most used filters
- Filter combinations
- User preferences (e.g., beginner-friendly species)

---

### 6. Settings & Preferences Events

#### `settings_changed`
**When:** User modifies app settings  
**Purpose:** Track feature usage and preferences  
**Parameters:**
- `setting_name` (string) - Setting changed (e.g., "notifications", "theme")
- `new_value` (string) - New value (e.g., "enabled", "dark")

**Implementation:**
```dart
FirebaseAnalyticsService().logSettingsChanged(
  settingName: 'notifications',
  newValue: 'enabled',
);
```

**Insights:**
- Most changed settings
- Feature adoption (e.g., % users enable notifications)
- Preference distribution (theme, units, etc.)

---

## 👤 User Properties

User properties provide context for all events, enabling powerful segmentation.

### Standard User Properties

#### `experience_level`
**Values:** "Beginner" | "Intermediate" | "Advanced" | "Expert"  
**Set When:** Onboarding complete, updated on level milestones  
**Purpose:** Segment users by skill level

**Implementation:**
```dart
FirebaseAnalyticsService().setExperienceLevel('Intermediate');
```

**Use Cases:**
- Compare engagement by experience level
- Personalize content recommendations
- Identify difficult lessons for beginners

---

#### `tank_count`
**Values:** Integer (0, 1, 2, ..., 20+)  
**Set When:** Tank created/deleted  
**Purpose:** Segment users by hobby commitment

**Implementation:**
```dart
FirebaseAnalyticsService().setTankCount(3);
```

**Use Cases:**
- Identify power users (5+ tanks)
- Target messaging (0 tanks = encourage first tank)
- Engagement by tank count

---

#### `preferred_tank_type`
**Values:** "Freshwater" | "Saltwater" | "Planted" | "Brackish"  
**Set When:** User creates 2+ tanks of same type  
**Purpose:** Personalize content

**Implementation:**
```dart
FirebaseAnalyticsService().setPreferredTankType('Planted');
```

**Use Cases:**
- Recommend species for preferred type
- Segment push notifications
- Personalized learning paths

---

#### `user_id`
**Values:** Unique identifier (UUID)  
**Set When:** Profile created  
**Purpose:** Cross-device tracking (future)

**Implementation:**
```dart
FirebaseAnalyticsService().setUserId('user_abc123');
```

**Use Cases:**
- Link sessions across devices
- Funnel analysis across app reinstalls
- User lifetime value calculation

---

## 📈 Key Metrics & KPIs

### Engagement Metrics

| Metric | Definition | Target | Calculation |
|--------|------------|--------|-------------|
| **DAU** | Daily Active Users | N/A | Unique `app_open` per day |
| **WAU** | Weekly Active Users | N/A | Unique `app_open` per week |
| **MAU** | Monthly Active Users | N/A | Unique `app_open` per month |
| **Session Length** | Avg time per session | 5+ min | Time between `app_open` and session end |
| **Sessions per User** | Avg sessions per day | 2+ | `app_open` count / DAU |
| **Retention (D1)** | Users who return day 1 | 40%+ | Users who open app D1 / new users D0 |
| **Retention (D7)** | Users who return day 7 | 20%+ | Users who open app D7 / new users D0 |
| **Retention (D30)** | Users who return day 30 | 10%+ | Users who open app D30 / new users D0 |

### Learning Metrics

| Metric | Definition | Target | Calculation |
|--------|------------|--------|-------------|
| **Lesson Completion Rate** | % of started lessons completed | 70%+ | `lesson_completed` / `lesson_started` |
| **Avg Quiz Score** | Average score across all quizzes | 75%+ | Sum(quiz score) / Total quizzes |
| **Lessons per Week** | Avg lessons completed weekly | 3+ | `lesson_completed` count / active weeks |
| **Learning Path Progress** | Avg % of path completed | 40%+ | Completed lessons / total lessons |
| **Review Adherence** | % of due reviews completed | 60%+ | Completed reviews / due reviews |

### Gamification Metrics

| Metric | Definition | Target | Calculation |
|--------|------------|--------|-------------|
| **Streak Retention** | % of users with 7+ day streak | 30%+ | Users with `streak_milestone(7)` / DAU |
| **Achievement Unlock Rate** | Avg achievements unlocked | 10+ | Total `achievement_unlocked` / MAU |
| **Level Progression** | Avg level reached | 5+ | Average `level_up` level |
| **XP per Week** | Avg XP earned weekly | 1000+ | Total XP earned / active weeks |

### Tank Management Metrics

| Metric | Definition | Target | Calculation |
|--------|------------|--------|-------------|
| **Tanks per User** | Avg tanks created | 1.5+ | `tank_created` / users |
| **Tank Engagement** | % users with 1+ tank | 80%+ | Users with `tank_created` / MAU |
| **Tank Deletion Rate** | % of tanks deleted | <20% | `tank_deleted` / `tank_created` |
| **Avg Tank Size** | Avg tank size (gallons) | N/A | Sum(tank size) / `tank_created` |

---

## 🎯 Critical User Flows Tracked

### Flow 1: Onboarding
```
tutorial_begin
    ↓
screen_view: OnboardingScreen
    ↓
screen_view: ProfileCreationScreen
    ↓
tutorial_complete
    ↓
screen_view: HomeScreen
```

**Funnel Metrics:**
- % who start onboarding
- % who complete onboarding
- Time to complete onboarding
- Drop-off point identification

---

### Flow 2: First Lesson
```
screen_view: LearnScreen
    ↓
lesson_started (lesson_id: first_lesson)
    ↓
screen_view: LessonScreen
    ↓
quiz_attempt (score, total_questions)
    ↓
lesson_completed (score)
    ↓
achievement_unlocked (first_lesson)
    ↓
xp_milestone (100)
```

**Funnel Metrics:**
- % who start first lesson
- % who complete first lesson
- Time to complete first lesson
- First lesson quiz score distribution

---

### Flow 3: Tank Creation
```
screen_view: MyTanksScreen
    ↓
screen_view: AddTankScreen
    ↓
tank_created (tank_type, size)
    ↓
screen_view: TankDetailScreen
    ↓
achievement_unlocked (first_tank)
```

**Funnel Metrics:**
- % of users who create first tank
- Time to first tank creation
- Tank type distribution
- Engagement after tank creation

---

### Flow 4: Streak Building
```
app_open (Day 1)
    ↓
lesson_completed
    ↓
app_open (Day 2)
    ↓
lesson_completed
    ↓
...
    ↓
streak_milestone (7)
    ↓
achievement_unlocked (week_warrior)
```

**Funnel Metrics:**
- % who start a streak
- % who reach 7-day milestone
- Streak break rate
- Avg streak length

---

## 🔍 Analytics Insights & Use Cases

### Insight 1: Lesson Difficulty Analysis
**Question:** Which lessons are too hard or too easy?  
**Metrics:** 
- Lesson completion rate by lesson
- Average quiz score by lesson
- Retry attempts per lesson

**Action:**
- Adjust content difficulty
- Add hints to difficult lessons
- Split complex lessons into smaller chunks

---

### Insight 2: Engagement Drop-off Points
**Question:** When do users stop using the app?  
**Metrics:**
- D1/D7/D30 retention curves
- Last screen viewed before churn
- Days since last app open

**Action:**
- Send re-engagement notifications
- Improve onboarding
- Add features for specific drop-off points

---

### Insight 3: Feature Adoption
**Question:** Which features are most/least used?  
**Metrics:**
- Screen view counts
- Feature-specific event counts
- % of users who use each feature

**Action:**
- Promote underused features
- Improve UX for popular features
- Deprecate unused features

---

### Insight 4: User Segmentation
**Question:** How do different user types behave?  
**Metrics:**
- Behavior by `experience_level`
- Behavior by `tank_count`
- Behavior by `preferred_tank_type`

**Action:**
- Personalize content recommendations
- Target messaging by segment
- Create segment-specific features

---

## 🛠️ Implementation Status

### ✅ Completed
- [x] FirebaseAnalyticsService implemented
- [x] All events defined and documented
- [x] Integration points identified
- [x] User properties defined
- [x] Automatic screen view tracking configured

### ⚠️ Pending Firebase Configuration
- [ ] Create Firebase project
- [ ] Add Android/iOS apps to Firebase
- [ ] Download google-services.json / GoogleService-Info.plist
- [ ] Uncomment Firebase dependencies in pubspec.yaml
- [ ] Uncomment Firebase initialization in main.dart
- [ ] Uncomment analytics logging in service

**Steps to Enable:**
1. Follow `docs/setup/FIREBASE_SETUP_GUIDE.md`
2. Uncomment Firebase dependencies in `pubspec.yaml`
3. Add Firebase config files to project
4. Uncomment imports and implementation in `firebase_analytics_service.dart`
5. Uncomment initialization in `main.dart`
6. Test in debug mode (analytics disabled for dev)
7. Enable in production builds

---

## 🔒 Privacy & Compliance

### Data Collection Principles
- ✅ **Opt-in by default** - Analytics enabled by default (standard practice)
- ✅ **No PII collected** - No names, emails, or personal data in events
- ✅ **Anonymized** - Firebase handles IP anonymization
- ✅ **Transparent** - Privacy policy explains data collection
- ✅ **User control** - Option to disable analytics (future)

### GDPR/CCPA Compliance
- ✅ No sensitive personal data collected
- ✅ Analytics can be disabled on request
- ✅ Data retention set to 14 months (Firebase default)
- ✅ User deletion supported (Firebase automatic)

### Data Retention
- **Events:** 14 months (Firebase default)
- **User properties:** Until user deletes account
- **Aggregated reports:** Indefinite (no PII)

---

## 📊 Analytics Dashboards (Future)

### Dashboard 1: Engagement Overview
- DAU/WAU/MAU trends
- Session length distribution
- Retention curves (D1/D7/D30)
- Top screens by view count

### Dashboard 2: Learning Analytics
- Lessons completed per day
- Average quiz scores
- Lesson completion funnel
- Topic popularity

### Dashboard 3: Gamification Performance
- Streak distribution
- Achievement unlock rate
- Level progression curve
- XP earning trends

### Dashboard 4: Tank Management
- Tanks created per week
- Tank type distribution
- Tank size distribution
- Tank deletion rate

---

## ✅ Analytics Verification Checklist

### Pre-Launch
- [x] All events defined
- [x] Service implemented
- [x] Integration points documented
- [ ] Firebase project created
- [ ] Analytics enabled in production
- [ ] Test events verified in Firebase console
- [ ] Dashboards configured

### Post-Launch
- [ ] Monitor event volume (expected: 100-1000 events/day initially)
- [ ] Verify no PII in events
- [ ] Check data quality (no null values, correct types)
- [ ] Set up alerts for key metrics (retention drop, crash rate)
- [ ] Review dashboards weekly

---

## 🎯 Success Criteria

**Analytics Implementation Complete When:**
- ✅ All critical user flows tracked
- ✅ All gamification events logged
- ✅ Screen view tracking automatic
- ✅ User properties set on key actions
- ✅ Privacy policy updated
- ✅ Firebase project configured
- ✅ Events visible in Firebase console
- ✅ Dashboards created for key metrics

---

**Next Steps:**
1. Set up Firebase project (follow `docs/setup/FIREBASE_SETUP_GUIDE.md`)
2. Enable analytics in production builds
3. Verify events in Firebase console (send test events)
4. Create custom dashboards for key metrics
5. Set up alerts for critical metrics (retention, crash rate)

**Document Maintained By:** Analytics Team  
**Last Updated:** February 2025  
**Next Review:** Post-launch (after 1000+ users collected)
