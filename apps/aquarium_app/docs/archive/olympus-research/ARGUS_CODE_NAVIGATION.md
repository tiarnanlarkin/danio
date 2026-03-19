# ARGUS: Navigation Flow Audit
**Repo:** `/mnt/c/Users/larki/Documents/Danio Aquarium App Project/repo/apps/aquarium_app`  
**Date:** 2026-03-16  
**Auditor:** Argus subagent

---

## 1. Live Onboarding Flow (First Launch)

Triggered when `onboardingCompletedProvider` = `false`.

| # | Screen | File Path |
|---|--------|-----------|
| 1 | **Splash** (loading state) | `lib/main.dart` (`_buildSplash`) |
| 2 | **OnboardingScreen** (3 swipeable intro cards: "Why Danio?", "Manage Your Collection", "Watch Your Tanks Thrive") | `lib/screens/onboarding_screen.dart` |
| 3 | **PersonalisationScreen** (experience level + tank status + optional name) | `lib/screens/onboarding/personalisation_screen.dart` |
| 4 | **JourneyRevealScreen** (personalised journey summary + "Let's go →") | `lib/screens/onboarding/journey_reveal_screen.dart` |
| 5 | **TabNavigator** (main app — 5-tab nav) | `lib/screens/tab_navigator.dart` |

**Notes:**
- "Quick Start" button on OnboardingScreen skips directly to TabNavigator (creates a default beginner profile + completes onboarding in one tap, bypasses PersonalisationScreen and JourneyRevealScreen entirely).
- "Skip Intro" button skips the slide cards and goes directly to PersonalisationScreen.
- JourneyRevealScreen's "Let's go →" calls `completeOnboarding()` and pops to first route → `_AppRouter` rebuilds → TabNavigator shown.

**Live onboarding screen count: 4** (Splash + OnboardingScreen + PersonalisationScreen + JourneyRevealScreen → TabNavigator)

---

## 2. Second-Launch Flow

Triggered when `onboardingCompletedProvider` = `true` and `userProfileProvider.value != null`.

**Result: Goes directly to TabNavigator.** No onboarding screens shown.

**TabNavigator 5-tab layout:**

| Tab | Label | Root Screen | File |
|-----|-------|-------------|------|
| 0 | Learn | `LearnScreen` | `lib/screens/learn_screen.dart` |
| 1 | Practice | `PracticeHubScreen` | `lib/screens/practice_hub_screen.dart` |
| 2 | Tank | `HomeScreen` | `lib/screens/home/home_screen.dart` |
| 3 | Smart | `SmartScreen` | `lib/screens/smart_screen.dart` |
| 4 | More | `SettingsHubScreen` | `lib/screens/settings_hub_screen.dart` |

**Edge case:** If `onboardingCompleted=true` but `profile==null` (force-quit recovery), shows `PersonalisationScreen` directly.

---

## 3. Screens Accessible from Live Flow (Post-Login)

All screens reachable from the 5 tab roots (directly navigable):

### From LearnScreen (Tab 0)
- `LessonScreen` — lesson playback
- `ParameterGuideScreen` — water chemistry guide
- `SpacedRepetitionPracticeScreen` — via review banner
- `ProfileCreationScreen` — safety net if no profile (legacy)

### From PracticeHubScreen (Tab 1)
- `SpacedRepetitionPracticeScreen`
- `PracticeScreen` — quick quiz
- `AchievementsScreen`

### From HomeScreen / TankDetail (Tab 2)
- `CreateTankScreen`
- `TankDetailScreen`
- `TankSettingsScreen`
- `AddLogScreen`
- `LogsScreen` → `LogDetailScreen`
- `LivestockScreen` → `LivestockDetailScreen`
- `EquipmentScreen`
- `TasksScreen`
- `JournalScreen`
- `PhotoGalleryScreen`
- `MaintenanceChecklistScreen`
- `ChartsScreen`
- `CyclingAssistantScreen`
- `TankComparisonScreen`
- `CostTrackerScreen`
- `LivestockValueScreen`
- `SearchScreen`
- `AnalyticsScreen`
- `RemindersScreen`
- `StreakCalendarScreen`
- `BackupRestoreScreen`

### From SmartScreen (Tab 3)
- `FishIdScreen` (AI-gated)
- `SymptomTriageScreen` (AI-gated)
- `WeeklyPlanScreen` (AI-gated)
- `CompatibilityCheckerScreen` (shown offline)
- `SettingsScreen` (for API key config)

### From SettingsHubScreen (Tab 4)
- `ShopStreetScreen` → `GemShopScreen`, `WishlistScreen` (×3 categories)
- `AchievementsScreen`
- `WorkshopScreen` → `WaterChangeCalculatorScreen`, `StockingCalculatorScreen`, `Co2CalculatorScreen`, `DosingCalculatorScreen`, `UnitConverterScreen`, `TankVolumeCalculatorScreen`, `LightingScheduleScreen`, `CompatibilityCheckerScreen`, `CostTrackerScreen`
- `AnalyticsScreen`
- `SettingsScreen` → `AccountScreen`, `ThemeGalleryScreen`, `NotificationSettingsScreen`, `DifficultySettingsScreen` (wrapper), `WishlistScreen`, `QuickStartGuideScreen`, `EmergencyGuideScreen`, `EquipmentGuideScreen`, `SubstrateGuideScreen`, `HardscapeGuideScreen`, `VacationGuideScreen`, `TroubleshootingScreen`, `BackupRestoreScreen`
- `AboutScreen` → `TermsOfServiceScreen`, `PrivacyPolicyScreen`

### From SettingsScreen (help section)
- `NitrogenCycleGuideScreen`, `DiseaseGuideScreen`, `AcclimationGuideScreen`, `QuarantineGuideScreen`, `FeedingGuideScreen`, `BreedingGuideScreen`, `AlgaeGuideScreen`, `SpeciesBrowserScreen`, `PlantBrowserScreen`, `GlossaryScreen`, `FaqScreen`
- (via `StudyScreen` reference — `StudyScreen` itself is orphaned, but SettingsScreen pushes these guides directly)

### Notification Deep-Links (from `main.dart`)
- `LearnScreen`
- `SpacedRepetitionPracticeScreen`
- `AchievementsScreen`

### Legacy / Safety-Net Onboarding Path (accessible from LearnScreen if no profile)
- `ProfileCreationScreen` → `EnhancedPlacementTestScreen` → `PlacementResultScreen` → `LearningStyleScreen` → `EnhancedTutorialWalkthroughScreen` → pop to TabNavigator

---

## 4. Orphaned Screens (Exist but NEVER Navigated To from Live Flow)

These files exist on disk but have **zero navigation calls** pointing to them from the live app:

| # | Screen | File Path | Notes |
|---|--------|-----------|-------|
| 1 | `FriendsScreen` | `lib/screens/friends_screen.dart` | **Intentionally hidden** — tracked as CA-002, social backend not shipped |
| 2 | `LeaderboardScreen` | `lib/screens/leaderboard_screen.dart` | **Intentionally hidden** — tracked as CA-003, social backend not shipped |
| 3 | `StudyScreen` | `lib/screens/rooms/study_screen.dart` | No navigation anywhere in codebase points to it |
| 4 | `AquariumSupplyScreen` | `lib/screens/aquarium_supply_screen.dart` | No navigation or import found in any live screen |
| 5 | `EnhancedQuizScreen` | `lib/screens/enhanced_quiz_screen.dart` | No navigation found — appears to be replaced by `LessonScreen` + `PracticeScreen` |
| 6 | `PlacementTestScreen` | `lib/screens/placement_test_screen.dart` | **Old version** — replaced by `EnhancedPlacementTestScreen`. Only comment references remain |
| 7 | `StoriesScreen` | `lib/screens/stories_screen.dart` | Only accessible via `StoriesCard` widget which is **never instantiated** in any screen |
| 8 | `StoryPlayerScreen` | `lib/screens/story_player_screen.dart` | Only pushed from `StoriesScreen` (itself orphaned) |
| 9 | `ActivityFeedScreen` | `lib/screens/activity_feed_screen.dart` | Only accessible via `FriendActivityWidget` which is **never instantiated** in any screen |

**Intentionally hidden (CA-tracked, not true dead code):**
- `FriendsScreen` (CA-002)
- `LeaderboardScreen` (CA-003)

**True orphans (no CA ticket, no known intent):**
- `StudyScreen`
- `AquariumSupplyScreen`
- `EnhancedQuizScreen`
- `PlacementTestScreen` (superseded)
- `StoriesScreen` + `StoryPlayerScreen` (widget chain broken)
- `ActivityFeedScreen` (widget chain broken)

**Orphaned screen count: 9** (7 true dead code + 2 intentionally hidden)

---

## 5. TODO / FIXME / HACK / XXX

```
grep -r "TODO\|FIXME\|HACK\|XXX" lib/ --include="*.dart" -n
```

**Result: 0 matches.**

The codebase uses its own tracking conventions instead:
- `BUG-XX` — bug fix references (e.g. `// BUG-01 fix:`)
- `CA-XXX` — feature tracking (e.g. `// CA-002 — Friends feature hidden`)
- `P[0-9]-XXX` — priority tracking

**TODO/FIXME count: 0**

---

## Summary

| Metric | Count |
|--------|-------|
| Live onboarding screens (first launch) | **4** |
| Orphaned screens (never navigated to) | **9** |
| TODO / FIXME / HACK / XXX markers | **0** |

---

## Key Observations

1. **Dual onboarding paths exist:** The live path (OnboardingScreen → PersonalisationScreen → JourneyRevealScreen) is clean and 4 screens. But `ProfileCreationScreen` still exists and is accessible as a safety net from `LearnScreen` when no profile exists — this triggers the old 5-step onboarding chain (ProfileCreation → EnhancedPlacement → PlacementResult → LearningStyle → EnhancedTutorialWalkthrough).

2. **StoriesCard and FriendActivityWidget are dead widgets:** Both are defined but never instantiated in any screen — their target screens (`StoriesScreen`, `ActivityFeedScreen`) are therefore unreachable.

3. **StudyScreen and AquariumSupplyScreen are fully orphaned** with no navigation from anywhere.

4. **EnhancedQuizScreen is orphaned** — the quiz functionality appears to have been subsumed into `LessonScreen` (in-lesson quiz steps) and `PracticeScreen`.

5. **Zero code debt markers** — the team uses BUG-XX and CA-XXX conventions instead of standard TODO/FIXME.
