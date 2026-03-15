# Navigation & User Flow Audit — Danio Aquarium App
**Audit Date:** 2026-03-15  
**Auditor:** Athena (subagent)  
**Scope:** `lib/screens/`, `lib/widgets/`, `lib/utils/`, `lib/main.dart`  
**Status:** READ-ONLY — no files modified

---

## Executive Summary

The app uses a 5-tab `IndexedStack`-based `TabNavigator` with per-tab `Navigator` keys for state preservation. The architecture is largely sound. The main concerns are:

1. **NavigationThrottle is a global static lock** — a single timeout in a crash can permanently block all navigation.
2. **Notification navigation bypasses the tab navigator** (root navigator), producing orphaned screens with no bottom nav.
3. **WorkshopScreen has no back button** (no Scaffold/AppBar).
4. **Settings → "Reset Onboarding" and "Clear Data" use `rootNavigator: true` + `popUntil(isFirst)`** — this pops the tab navigator's own nav stacks as well, potentially leaving the UI in an inconsistent state.
5. **TankSettingsScreen "Delete Tank" also calls `popUntil(route.isFirst)`** — this blows the whole navigation stack (including across tabs) when deleting a tank from a nested screen.
6. **LearnScreen auto-scroll hardcodes 320px offset** — breaks if the study room scene header changes height.
7. **Several deep flows lack mid-flow state persistence** — killed app mid-quiz loses all progress.

---

## 1. Navigation Route Map

### App Entry & Routing (`main.dart`, `tab_navigator.dart`)

```
App Start
  └─ _AppRouter (reactive provider-driven)
       ├─ onboardingCompleted = false  → OnboardingScreen (3-page PageView)
       │    └─ "Get Started" → PersonalisationScreen → ProfileCreationScreen
       │         └─ ProfileCreationScreen → EnhancedPlacementTestScreen (optional)
       │              └─ PlacementResultScreen → JourneyRevealScreen → TabNavigator (via popUntil)
       ├─ profile = null               → PersonalisationScreen
       └─ all clear                   → TabNavigator (5 tabs)
```

### TabNavigator — 5 tabs, each with its own Navigator
```
Tab 0: Learn      → LearnScreen
Tab 1: Practice   → PracticeHubScreen
Tab 2: Tank       → HomeScreen
Tab 3: Smart      → SmartScreen
Tab 4: Toolbox    → SettingsHubScreen
```

### Tab 0 — Learn (`learn_screen.dart`)
```
LearnScreen
  ├─ StudyRoomScene → microscope tap → ParameterGuideScreen
  ├─ StudyRoomScene → globe tap → AlertDialog (fish fact, "Another!" loops)
  ├─ _ReviewCardsBanner → SpacedRepetitionPracticeScreen
  ├─ _PracticeCard → PracticeScreen
  ├─ PlacementChallengeCard → (not traced here, P2)
  ├─ profile == null → ProfileCreationScreen (via NavigationThrottle.push)
  └─ _LazyLearningPathCard (ExpansionTile)
       └─ LessonScreen (each lesson item)
            ├─ lesson content → "Take Quiz" → inline quiz (_buildQuiz)
            │    ├─ wrong answer → HeartAnimation → (out of hearts) → showOutOfHeartsModal
            │    │    ├─ "Practice Mode" → Navigator.pushReplacement(LessonScreen isPracticeMode=true)
            │    │    └─ "Wait" → Navigator.of(context).pop() [back to lesson list]
            │    └─ quiz complete → _buildQuizResults → "Complete Lesson" button
            │         └─ _completeLesson() → XpAwardOverlay → LevelUpDialog? → _showNextLessonOrPop()
            │              ├─ has next lesson → showModalBottomSheet
            │              │    ├─ "Start Next Lesson" → pushReplacement(LessonScreen next)
            │              │    └─ "Back to Path" → Navigator.pop()
            │              └─ no next lesson → Navigator.pop()
            └─ no quiz → "Complete Lesson" → _completeLesson() (same flow as above)
```

### Tab 1 — Practice (`practice_hub_screen.dart`)
```
PracticeHubScreen
  ├─ SpacedRepetitionPracticeScreen (due cards)
  ├─ PracticeScreen (weak lessons review)
  │    └─ LessonScreen(isPracticeMode: true) for each weak lesson
  └─ AchievementsScreen
```

### Tab 2 — Tank (`home_screen.dart`)
```
HomeScreen
  ├─ TankSwitcher → switches _currentTankIndex (local state)
  ├─ TankSettingsScreen (appBar settings icon)
  │    └─ "Delete Tank" → popUntil(route.isFirst) ⚠️ ISSUE
  ├─ SpeedDialFAB
  │    ├─ "Stats"         → showModalBottomSheet → inline stats sheet
  │    ├─ "Water Change"  → AddLogScreen (ModalScaleRoute)
  │    ├─ "Feed"          → showModalBottomSheet (feeding info)
  │    ├─ "Quick Test"    → showModalBottomSheet (quick log sheet)
  │    └─ "Add Tank"      → CreateTankScreen (MaterialPageRoute)
  │         └─ 3-page wizard (name → size → water type) → navigator.pop() + snackbar
  ├─ Tank toolbox (IconButton) → showModalBottomSheet
  │    ├─ Reminders      → RemindersScreen (RoomSlideRoute)
  │    ├─ Tank Journal   → JournalScreen (RoomSlideRoute)
  │    ├─ Analytics      → AnalyticsScreen (MaterialPageRoute)
  │    └─ Species Search → SearchScreen (RoomSlideRoute)
  ├─ Room scene interactive objects → various bottom sheets (water params, feeding, plants)
  ├─ LivingRoomScene tank tap → TankDetailScreen (TankDetailRoute)
  │    └─ (see TankDetailScreen below)
  ├─ BottomPlate "Your Tanks" → list of tanks (tap changes current tank)
  ├─ BottomPlate "Your Progress" → GamificationDashboard
  │    └─ onTap → showModalBottomSheet (stats details)
  │         ├─ "Daily Goal" → showModalBottomSheet (daily goal details)
  │         └─ "Calendar"   → StreakCalendarScreen (RoomSlideRoute)
  ├─ SwissArmyPanel left (temp panel)
  ├─ SwissArmyPanel right (water quality panel)
  └─ Empty state → EmptyRoomScene → CreateTankScreen OR load demo tank
```

### TankDetailScreen (nested under Tab 2)
```
TankDetailScreen
  ├─ AppBar actions: TankSettingsScreen, TankComparisonScreen
  ├─ FAB (QuickAddFab)
  │    ├─ AddLogScreen (water test / water change / feeding / general)
  │    ├─ LivestockScreen → LivestockDetailScreen
  │    └─ EquipmentScreen
  ├─ Task section → TasksScreen
  ├─ Logs section → LogsScreen → LogDetailScreen
  ├─ Charts section → ChartsScreen
  ├─ Livestock preview → LivestockScreen
  ├─ Equipment preview → EquipmentScreen
  ├─ Cycling status → CyclingAssistantScreen
  ├─ Journal → JournalScreen
  ├─ Photo gallery → PhotoGalleryScreen
  ├─ Maintenance checklist → MaintenanceChecklistScreen
  ├─ Cost tracker → CostTrackerScreen
  └─ Livestock value → LivestockValueScreen
```

### Tab 3 — Smart (`smart_screen.dart`)
```
SmartScreen
  ├─ FishIdScreen (camera, requires API key)
  ├─ SymptomTriageScreen (requires API key)
  ├─ WeeklyPlanScreen (requires API key)
  ├─ CompatibilityCheckerScreen (offline, always available)
  ├─ "Ask Danio" inline text field (no navigation)
  └─ Anomaly History → showModalBottomSheet (DraggableScrollableSheet)
```

### Tab 4 — Toolbox/Settings (`settings_hub_screen.dart`)
```
SettingsHubScreen
  ├─ ShopStreetScreen
  ├─ AchievementsScreen
  │    └─ AchievementDetailModal (showModalBottomSheet for each achievement)
  ├─ WorkshopScreen  ⚠️ NO BACK BUTTON
  │    └─ grid of tool screens (all via NavigationThrottle.push)
  ├─ AnalyticsScreen
  └─ SettingsScreen (Preferences)
       ├─ AccountScreen
       ├─ NotificationSettingsScreen
       ├─ ThemeGalleryScreen
       ├─ DifficultySettingsScreen
       ├─ RemindersScreen
       ├─ WishlistScreen
       ├─ TankComparisonScreen
       ├─ WaterChangeCalculatorScreen
       ├─ Co2CalculatorScreen
       ├─ DosingCalculatorScreen
       ├─ UnitConverterScreen
       ├─ TankVolumeCalculatorScreen
       ├─ StockingCalculatorScreen
       ├─ LightingScheduleScreen
       ├─ CompatibilityCheckerScreen
       ├─ CostTrackerScreen
       ├─ EmergencyGuideScreen
       ├─ FaqScreen
       ├─ VacationGuideScreen
       ├─ PlantBrowserScreen
       ├─ SpeciesBrowserScreen
       ├─ GlossaryScreen
       ├─ QuickStartGuideScreen
       ├─ TroubleshootingScreen
       ├─ QuarantineGuideScreen
       ├─ SubstrateGuideScreen
       ├─ EquipmentGuideScreen
       ├─ NitrogenCycleGuideScreen
       ├─ DiseaseGuideScreen
       ├─ FeedingGuideScreen
       ├─ ParameterGuideScreen
       ├─ AlgaeGuideScreen
       ├─ BreedingGuideScreen
       ├─ HardscapeGuideScreen
       ├─ AclimatisationGuideScreen
       ├─ BackupRestoreScreen
       ├─ AboutScreen → TermsOfServiceScreen, PrivacyPolicyScreen
       ├─ "Reset Onboarding" → popUntil(isFirst) via rootNavigator  ⚠️ ISSUE
       └─ "Clear All Data" → popUntil(isFirst) via rootNavigator  ⚠️ ISSUE
```

### Notification-triggered Navigation (via `navigatorKey` — root navigator)
```
Push notification tap (payload='learn')       → LearnScreen  ⚠️ no bottom nav
Push notification tap (payload='review')      → SpacedRepetitionPracticeScreen  ⚠️ no bottom nav
Push notification tap (payload='achievements') → AchievementsScreen  ⚠️ no bottom nav
```

---

## 2. Back Button Behaviour

### ✅ Correctly Handled

| Screen | Mechanism | Notes |
|--------|-----------|-------|
| `TabNavigator` | `PopScope(canPop: false)` | Double-back-to-exit, delegates to inner navigators first |
| `LessonScreen` | `PopScope(canPop: false)` | Prompts "Leave quiz?" dialog if mid-quiz |
| `AddLogScreen` | `PopScope(canPop: !_hasUnsavedData)` | Confirms discard if unsaved |
| `CreateTankScreen` | `PopScope(canPop: !_hasUnsavedData)` | Confirms discard if data entered |
| `SpacedRepetitionPracticeScreen` | `PopScope(canPop: false)` | Exit dialog with progress loss warning |
| Most screens with AppBar | Standard back arrow | Flutter default, works correctly |

### ⚠️ Issues Found

**[NAV-BACK-01] `WorkshopScreen` — No back button, no AppBar — P1**
- File: `lib/screens/workshop_screen.dart`
- `WorkshopScreen.build()` returns a bare `Container` → `SafeArea` → `CustomScrollView`. There is no `Scaffold`, no `AppBar`, and no back button.
- The screen is pushed via `NavigationThrottle.push` from `SettingsHubScreen`, so the system back gesture works on Android. However on iOS there's no visual affordance, and the header (`_WorkshopHeader`) has no back navigation element.
- **Suggested fix:** Wrap in `Scaffold` with `AppBar(title: Text('🔧 Workshop'))` or add a manual back button to `_WorkshopHeader`.

**[NAV-BACK-02] `TankSettingsScreen` "Delete Tank" uses `popUntil(isFirst)` — P1**
- File: `lib/screens/tank_settings_screen.dart` line 437
- `Navigator.of(context).popUntil((route) => route.isFirst)` is called on the tab's inner navigator after deleting a tank.
- This pops ALL screens in the current tab's stack back to the tab root. If the user navigated: Tank tab → TankDetailScreen → TankSettingsScreen → delete, they land back at HomeScreen (expected). BUT if they arrived at TankSettingsScreen from a deeply nested flow (e.g. a modal that pushed TankSettings), all stacked screens get popped.
- **Suggested fix:** Use `Navigator.of(context).pop()` twice (to close TankSettings and TankDetail) after confirming deletion, which is deterministic.

**[NAV-BACK-03] `SettingsScreen` "Reset Onboarding" and "Clear Data" use `rootNavigator: true` — P2**
- File: `lib/screens/settings_screen.dart` lines 792, 870
- `Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst)` escapes ALL nested navigators and pops everything to the root. This is intentional (to exit to onboarding), but has an edge case: if there are dialogs or bottom sheets open on top of the settings screen, they'll be caught by `popUntil` and dismissed as part of the cascade, potentially causing "cannot pop a route that is not in the navigator" warnings.
- **Suggested fix:** Close any open dialogs before navigating. Consider `Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(...)` instead for a clean replace.

---

## 3. Deep Navigation — Stack Depth Analysis

### 3-Screen Deep Flows (confirmed working)

- `SettingsHubScreen → WorkshopScreen → WaterChangeCalculatorScreen` (3 levels; back works via system gesture only due to NAV-BACK-01)
- `LearnScreen → LessonScreen (lesson content) → LessonScreen (next lesson via pushReplacement)` (2 levels; pushReplacement keeps stack shallow)
- `HomeScreen → TankDetailScreen → LogsScreen → LogDetailScreen` (4 levels; all use standard `Navigator.push`, back works)
- `HomeScreen → TankDetailScreen → LivestockScreen → LivestockDetailScreen` (4 levels; works)
- `SettingsHubScreen → SettingsScreen → NotificationSettingsScreen` (3 levels; works)
- `PracticeHubScreen → PracticeScreen → LessonScreen` (3 levels; works)

### Issues at Depth

**[NAV-DEEP-01] `_showNextLessonOrPop` uses `pushReplacement` not `push` — P2**
- File: `lib/screens/lesson_screen.dart` line 1116
- When "Start Next Lesson" is chosen from the completion bottom sheet, the current `LessonScreen` is replaced with the next one via `Navigator.of(context).pushReplacement(...)`. This means the user **cannot back-navigate to the previous lesson**. A series of 5 lessons creates a single non-undoable chain — back from lesson 5 goes directly to the learn path list, skipping lessons 4, 3, 2.
- This may be intentional (prevent re-doing completed lessons), but is inconsistent — the back button on lesson 1 takes you back to the learn path.
- **Suggested fix:** Either document as intentional or use `push` and filter completed lessons from back-navigation.

**[NAV-DEEP-02] Out-of-hearts flow does `Navigator.of(context).pop()` but `LessonScreen` has `PopScope(canPop: false)` — P1**
- File: `lib/screens/lesson_screen.dart` lines 757–769
- When a user runs out of hearts mid-quiz and chooses "Wait" or dismisses the `showOutOfHeartsModal`, `Navigator.of(context).pop()` is called directly. But `LessonScreen` wraps itself in `PopScope(canPop: false)`.
- This `Navigator.of(context).pop()` is called from within the `showOutOfHeartsModal` result handler — i.e. it navigates from inside the modal's callback after the modal dismisses. At that point, it's attempting to pop `LessonScreen` itself, but `PopScope(canPop: false)` should technically intercept this via the framework's standard route pop mechanism.
- However, `Navigator.of(context).pop()` called programmatically bypasses `PopScope.canPop` — `PopScope` only intercepts user-gesture-based pops. So this DOES work as intended but the `PopScope(canPop: false)` is misleading — it won't prevent this programmatic exit.
- **Risk:** If the `_confirmExitQuiz()` logic is ever triggered (e.g. by a system back while modal is open), there could be a double-pop.
- **Suggested fix:** Add a `_isExitingDueToHearts` flag to suppress the `_confirmExitQuiz()` dialog.

---

## 4. Tab Bar — Transitions & State

### ✅ State Preservation
- Each tab has its own `GlobalKey<NavigatorState>` within an `IndexedStack`. All 5 tabs preserve their navigation stack when switching tabs. This is correct.
- `currentTabProvider = StateProvider<int>((ref) => 0)` — starts on Learn (tab 0), not Tank tab. This is the intended default.

### ✅ Tab Transition Animation
- `FadeTransition` with `_fadeController` (200ms, `easeOut` curve) on `IndexedStack`. Clean, no jank observed in code.

### ✅ Double-tap to scroll to root
- `navigator.popUntil((route) => route.isFirst)` on same-tab tap. Correctly implemented.

### Issues

**[NAV-TAB-01] `currentTabProvider` initial value is 0 (Learn), but comment says "Start at Learn tab" — potential confusion — P3**
- Tabs are ordered: 0=Learn, 1=Practice, 2=Tank, 3=Smart, 4=Toolbox.
- Starting on Learn is intentional per comments. No bug, but the tab ordering should be verified against UX intent (most users may expect to land on Tank tab on return visits).

**[NAV-TAB-02] `_onTabChanged` only fires fade animation — does not handle haptic/tab-switch edge case — P3**
- `HapticFeedback.selectionClick()` fires on every tab tap including same-tab taps. On same-tab tap, haptic fires but animation does not. Minor inconsistency.

**[NAV-TAB-03] `HomeScreen._navigateToCreateFirstTank` references `ref.read(currentTabProvider)` to guard auto-launch — P2**
- File: `lib/screens/home/home_screen.dart` line 835
- The guard checks `if (currentTab != 2) return;` (only auto-launch create when Tank tab is visible). This is deliberately disabled (`return;` is dead code after the guard), but the disabled auto-launch code reads `currentTabProvider` to check if Tab 2 is active. If re-enabled, this would be correct.
- **Note:** The `_maybeShowFirstTankPrompt` auto-launch is **commented out / disabled** — code has `return;` before the logic fires. Users must manually tap "Add Your Tank". This is a deliberate safety choice after lifecycle crashes.

---

## 5. Bottom Sheets & Dialogs

### ✅ Properly Handled
- Most bottom sheets use `showModalBottomSheet` with standard dismissal (swipe down or tap scrim). No `isDismissible: false` blocking unless intentional.
- Quick log sheet (`_showQuickLogSheet`) disposes controllers in `whenComplete`. Correct.
- Tank toolbox bottom sheet uses `Navigator.pop(ctx)` before any navigation from within the sheet. Correct.

### Issues

**[NAV-SHEET-01] `StoryPlayerScreen` completion dialog is `barrierDismissible: false` — no escape if buttons don't work — P2**
- File: `lib/screens/story_player_screen.dart` line 186
- The story completion dialog (`barrierDismissible: false`) has two buttons: one closes the dialog + returns to stories list, the other exits the story. If either button's callback throws an exception, the user is trapped — cannot dismiss by tapping outside.
- **Suggested fix:** Use `barrierDismissible: true` and handle the `null` result in `.then()`.

**[NAV-SHEET-02] `EnhancedTutorialWalkthroughScreen` has a `barrierDismissible: false` dialog — P2**
- File: `lib/screens/onboarding/enhanced_tutorial_walkthrough_screen.dart` line 181
- Same concern. Non-dismissible onboarding dialogs that could trap users.

**[NAV-SHEET-03] `SpacedRepetitionPracticeScreen` uses `barrierDismissible: false` — P2**
- File: `lib/screens/spaced_repetition_practice_screen.dart` line 1064
- This appears to be an important confirmation dialog (e.g. for session exit), so intentional. Lower risk, but worth confirming there are always functioning buttons.

**[NAV-SHEET-04] Multiple layers of bottom sheets can stack — P2**
- From `HomeScreen`, a user can: open Progress BottomPlate → tap stats → `_showStatsDetails` bottom sheet → tap "Daily Goal" → `_showDailyGoalDetails` bottom sheet. Two modal bottom sheets are open simultaneously. Closing the outer one while the inner is still animating can cause visual glitches in some Flutter versions.
- **Suggested fix:** Pop the first sheet before pushing the second (`Navigator.pop(ctx)` before `showModalBottomSheet`).

**[NAV-SHEET-05] `HomeScreen._showStatsDetails` bottom sheet nested call doesn't close parent — P2**
- File: `lib/screens/home/home_screen.dart`
- `_showStatsDetails` opens a sheet. Inside that sheet, "Daily Goal" button calls `Navigator.pop(ctx)` first, THEN `_showDailyGoalDetails(context)`. This is correct. But "Calendar" button calls `Navigator.pop(ctx)` then `NavigationThrottle.push(context, StreakCalendarScreen())`. `NavigationThrottle.push` uses `Navigator.push` on the tab navigator — but `context` here is the sheet's context, not the screen's context. After `Navigator.pop(ctx)` the sheet's context may be deactivated. The `NavigationThrottle.push(context, ...)` could throw "Looking up a deactivated widget's ancestor is unsafe."
- **Suggested fix:** Capture the screen-level `BuildContext` before opening the sheet and use it in the callback.

---

## 6. Tank Creation Flow

**Complete flow: "+" → Saved Tank**

```
1. User taps SpeedDial "Add Tank" or "+" in TankSwitcher
2. HomeScreen._navigateToCreateTank() → Navigator.of(context).push(MaterialPageRoute → CreateTankScreen)
3. CreateTankScreen opens
   ├─ PopScope: canPop = !_hasUnsavedData (allows back if empty; confirms otherwise)
   ├─ AppBar: close icon → Navigator.maybePop → triggers PopScope confirmation
   ├─ Page 1: Name + Type (freshwater/marine)
   │    - "Marine" is disabled — shows snackbar "coming soon"
   │    - "Next" enabled only when _name.isNotEmpty
   ├─ Page 2: Volume + Dimensions (optional) + presets
   │    - "Next" enabled only when _volumeLitres > 0
   ├─ Page 3: Water type (Tropical/Coldwater) + start date
   │    - PageView has NeverScrollableScrollPhysics (swipe-to-advance disabled intentionally)
   └─ "Create Tank" button → _createTank() → nav.pop() → snackbar + XP + confetti
4. After pop: HomeScreen.whenComplete() → ref.invalidate(tanksProvider) → re-fetches tanks
5. New tank becomes visible in TankSwitcher
6. If first ever tank: celebration milestone overlay shown
```

### Issues

**[NAV-TANK-01] No step to add livestock/equipment immediately after tank creation — P2**
- After `CreateTankScreen` closes, the user lands back on `HomeScreen` with the new tank selected but no guidance to add fish or equipment. The "first tank" celebration overlay mentions the hobby has begun but doesn't offer a CTA to add fish.
- **Suggested fix:** After first tank creation, show a "Add your first fish?" prompt or navigate to `TankDetailScreen` with an onboarding overlay.

**[NAV-TANK-02] `_navigateToCreateFirstTank` uses `rootNavigator: true` — P1**
- File: `lib/screens/home/home_screen.dart` line 865
- `Navigator.of(context, rootNavigator: true).push(MaterialPageRoute → CreateTankScreen)` means `CreateTankScreen` is pushed onto the **root** navigator, not the tab's inner navigator. When `navigator.pop()` is called (line 892: `TankDetailRoute` push), it uses `navigator` which is the root navigator. The subsequent `navigator.push(TankDetailRoute(...))` also pushes onto root, giving `TankDetailScreen` no tab bar.
- This is a known pattern in the codebase and may be intentional (full-screen creation wizard), but it means any navigation from `TankDetailScreen` (logs, livestock, etc.) also happens outside the tab navigator.
- **Suggested fix:** If this is the intended UX (creation wizard as full-screen), document it clearly. If not, remove `rootNavigator: true` and use `Navigator.of(context)` (tab navigator).

**[NAV-TANK-03] Marine tank type is disabled but still tappable — P3**
- File: `lib/screens/create_tank_screen.dart` `_TypeCard`
- `isDisabled: true` types still have `onTap` wired up (to show snackbar). `Semantics` marks them as `enabled: false`, but the `InkWell.onTap` fires. Users with assistive tech hear "disabled" but it still responds to taps. Visual `Opacity(0.6)` is applied.
- **Suggested fix:** Conditionally set `InkWell.onTap = null` when disabled, or use `AbsorbPointer`.

---

## 7. Lesson Flow

**Complete flow: Start lesson → Quiz → Completion → Back to list**

```
1. User expands LearningPath card in LearnScreen
   └─ onExpansionChanged: loads path lazily via ref.read(lessonProvider.notifier).loadPath()
2. User taps lesson tile (only if isUnlocked)
   └─ NavigationThrottle.push(context, LessonScreen(lesson, pathTitle))
3. LessonScreen opens
   ├─ PopScope(canPop: false): always intercepts back
   ├─ Shows lesson content (sections: text, key points, tips, warnings, etc.)
   └─ "Take Quiz" button → setState(_showQuiz = true)
4. Quiz phase (inline in LessonScreen._buildQuiz)
   ├─ Select answer → "Check Answer" → reveals correct/wrong + explanation
   ├─ Wrong answer → loses heart (non-practice mode) → HeartAnimation
   │    └─ 0 hearts → showOutOfHeartsModal (barrierDismissible implicit true)
   │         ├─ "Practice Mode" → pushReplacement(LessonScreen isPracticeMode=true)
   │         └─ "Wait" → Navigator.of(context).pop() [exits to learn screen]
   └─ "Next Question" loops until quiz complete → "See Results"
5. Quiz results screen (_buildQuizResults)
   └─ "Complete Lesson" → _completeLesson(bonusXp) →
        ├─ recordActivity, completeLesson, autoSeedFromLesson, scheduleNotifications
        ├─ achievement check (fire-and-forget)
        ├─ in-app review trigger (fire-and-forget)
        └─ XpAwardOverlay.show → onComplete → LevelUpDialog? → _showNextLessonOrPop()
             ├─ next lesson available → bottom sheet → "Start Next Lesson" → pushReplacement
             └─ no next lesson / practice mode → Navigator.pop()
6. User returns to LearnScreen, path card shows updated progress
```

### Issues

**[NAV-LESSON-01] `_findNextLesson` only searches `loadedPaths` — P1**
- File: `lib/screens/lesson_screen.dart` 
- `_findNextLesson()` iterates `lessonState.loadedPaths.values`. If the user completed a lesson in path A, then opened path B (loaded it), and path A was not re-loaded (lazy loading only on expansion), `_findNextLesson()` may miss the next lesson in path A.
- More critically: if the app was killed and relaunched, no paths are loaded until expanded. Completing a lesson in a freshly-expanded path would find the next lesson correctly, but if the user navigated directly to a lesson via a deep link or notification, `loadedPaths` may be empty and `_findNextLesson()` returns `null`.
- **Suggested fix:** Ensure the current lesson's path is always in `loadedPaths` when `LessonScreen` opens, or load it explicitly in `initState`.

**[NAV-LESSON-02] `_completeLesson` has no mid-flight save — P1**
- File: `lib/screens/lesson_screen.dart`
- The entire lesson completion (XP award, lesson record, spaced-repetition seeding, achievement check, notification schedule) happens in a single `try/catch`. If the app is killed after `completeLesson` succeeds but before `autoSeedFromLesson` completes, the lesson IS marked complete but SR cards may be incomplete. This is logged but not retried.
- The lesson progress (quiz state: `_currentQuizQuestion`, `_correctAnswers`) is held only in widget state. If the app is killed mid-quiz, all progress is lost on restart.
- **Suggested fix (P1):** Persist quiz progress to `SharedPreferences` periodically so restart can resume. 
- **Suggested fix (P2):** Wrap SR seeding and notifications in separate try/catch blocks with individual fallbacks (already partially done).

**[NAV-LESSON-03] Quiz "Check Answer" button has no debouncing — P2**
- File: `lib/screens/lesson_screen.dart`
- The "Check Answer" button calls `setState(() => _answered = true)` and then a heart-loss async chain. If the user taps rapidly, `_answered` protects against double-answer, but the button remains enabled briefly before setState fires. `NavigationThrottle` does not wrap this (it's within the same screen, not a navigation push).
- Low risk given `_answered` guard, but worth confirming with rapid-tap testing.

**[NAV-LESSON-04] `LevelUpDialog.show` is awaited inside `XpAwardOverlay.onComplete` callback — P2**
- File: `lib/screens/lesson_screen.dart` `_showXpAnimation`
- `XpAwardOverlay.show` takes an `onComplete` callback which itself is async (awaits `_showLevelUpCelebration`). If the widget is unmounted during the XP animation, `_showLevelUpCelebration` still calls `LevelUpDialog.show(context, ...)` which would throw. There is `if (!mounted) return;` guard — this is correct.

---

## 8. Settings Screen

**Flow: Toolbox → Preferences**

Settings screen is a `ListView.builder` with lazy `WidgetBuilder` items — each section is built on demand. This was explicitly added to fix an ANR caused by building 60+ widgets synchronously. Architecture is sound.

### Navigation within Settings

All sub-screens use `NavigationThrottle.push`. All have AppBars with standard back buttons (system + visual). Back navigation is correct for all sub-screens audited.

### Issues

**[NAV-SETTINGS-01] `_replayOnboarding` and `_confirmClearData` use `rootNavigator: true` + `popUntil(isFirst)` — P2**
- File: `lib/screens/settings_screen.dart` lines 792, 870
- After resetting onboarding/clearing data, `Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst)` is called. This navigates to the root route (typically the splash / `_AppRouter`), which should re-evaluate to show `OnboardingScreen`.
- **Risk:** If the user had any dialogs or sheets open above the settings screen at the time "Clear Data" is confirmed (unlikely but possible with rapid interaction), those routes are also popped, which could cause issues if they were holding references.
- **Suggested fix:** Use `SchedulerBinding.instance.addPostFrameCallback` to ensure the navigation happens after the current build frame completes.

**[NAV-SETTINGS-02] Settings → "Daily Goal" picker is an inline dialog, not a screen — P3**
- File: `lib/screens/settings_screen.dart` `_showDailyGoalPicker`
- This opens a `showDialog` with goal options. No back-navigation issue, but it means there's no way to reach the daily goal setting via a deep-link or notification payload.

**[NAV-SETTINGS-03] `RoomNavigation` widget in settings launches room screens — P3**
- File: `lib/widgets/room_navigation.dart` (referenced from settings_screen.dart)
- Settings contains a "Rooms" section showing navigation items. These presumably push additional screens but were not fully traced. If they include `WorkshopScreen` (no AppBar), the same NAV-BACK-01 issue applies.

---

## 9. Profile & Achievements Navigation

### Access Points to AchievementsScreen
1. `SettingsHubScreen → Achievements` (Tab 4 primary path)
2. `PracticeHubScreen → Achievements` (Tab 1 secondary path)
3. Push notification (payload = 'achievements') via root navigator — **no bottom nav bar** ⚠️

### AchievementsScreen UX
- FilterMode (All/Unlocked/Locked), Category, Rarity filters — all in-screen state, no navigation.
- Sort by Rarity/Date/Progress — PopupMenuButton — no navigation issues.
- Tap achievement → `showModalBottomSheet` → `AchievementDetailModal` — dismissable by swipe/barrier tap. ✅

### GamificationDashboard
- Inline widget on HomeScreen, shown in BottomPlate and in `_showStatsDetails` sheet.
- `onTap` opens `_showStatsDetails` bottom sheet. ✅

### Issues

**[NAV-PROFILE-01] Push notification to `AchievementsScreen` uses root navigator — P2**
- File: `lib/main.dart` line 115
- `navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => const AchievementsScreen()))` pushes directly onto the root MaterialApp navigator.
- The `AchievementsScreen` has an AppBar with a standard back button, so the user can return. BUT: they're taken outside the tab-based navigation — the bottom navigation bar is absent, and navigating back takes them back to the tab they were on, but the tab state may not reflect that they've returned (e.g. AchievementsScreen changes could trigger achievement provider updates that don't cause tab-based screens to refresh).
- **Suggested fix:** Navigate to the Toolbox tab first (`ref.read(currentTabProvider.notifier).state = 4`) and then push within that tab's navigator, or at minimum wrap notification-pushed screens with a `Scaffold` that includes a `BottomNavigationBar` reference.

**[NAV-PROFILE-02] No profile screen accessible from main navigation — P2**
- There is no dedicated "Profile" screen accessible from the tab bar. Profile info is shown in the SettingsHub header card and editable via the edit button → `SettingsScreen`. However, there is a `ProfileCreationScreen` and potentially an `AccountScreen` — these are in the deep settings hierarchy.
- Users who want to edit their profile must navigate: Toolbox → Preferences → Account & Sync.
- **Suggested fix:** Add a profile tap action to the SettingsHub header card that navigates directly to `AccountScreen`.

**[NAV-PROFILE-03] Leaderboard and Friends screens exist in code but are hidden — P3**
- File: `lib/screens/settings_hub_screen.dart` comments: `// friends_screen.dart — hidden until feature ships (CA-002)` and `// leaderboard_screen.dart — hidden until feature ships (CA-003)`
- `FriendsScreen` and `LeaderboardScreen` dart files exist but are not linked from any navigation point. This is intentional (pre-launch gating) but should be formally tracked.

---

## 10. Edge Case Flows

### Device Rotation
**[NAV-EDGE-01] Orientation is locked to portrait — P3 (by design)**
- File: `lib/main.dart` lines 44–47
- `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])` — landscape is locked out. No rotation issues possible. This is correct for an app with a room-based visual design.

### App Kill Mid-Flow

**[NAV-EDGE-02] Quiz state is fully in-memory — P1**
- As noted in NAV-LESSON-02. Killing the app mid-quiz loses all progress. The lesson must be restarted.
- **Suggested fix:** Persist `_currentQuizQuestion`, `_correctAnswers`, `_selectedAnswer`, lesson ID to `SharedPreferences` on each question transition. Restore on `initState` if a matching save exists.

**[NAV-EDGE-03] Tank creation state is fully in-memory — P2**
- `CreateTankScreen` uses local widget state. Killing the app mid-wizard loses entered data (name, volume, etc.). Low friction since the form is short (3 pages), but worth noting.
- **Suggested fix:** Low priority given form brevity. Consider `SharedPreferences` persistence for the name field only.

**[NAV-EDGE-04] `NavigationThrottle._isNavigating` is a static bool — P1**
- File: `lib/utils/navigation_throttle.dart`
- `_isNavigating` is a class-level static variable. If any navigation call throws an unhandled exception BEFORE the `finally { _isNavigating = false; }` block runs (e.g. the pushed screen's constructor throws), the lock never resets and ALL future `NavigationThrottle.push` calls silently return `null`. The entire app's navigation becomes non-functional.
- The `try/finally` block is present and should reset the flag even on exception, BUT if the Dart VM itself crashes (Killed by OS, OOM), the flag would be lost anyway (process restarts).
- **More realistic risk:** If `Navigator.push` itself throws a sync exception (e.g. `context` is already deactivated), the `finally` block runs correctly. If the error is async (e.g. from within the pushed widget's build), the `push` future resolves normally and `_isNavigating = false` runs. This is likely safe.
- **Residual risk:** There's no timeout on the lock. If `Navigator.push` hangs indefinitely (hypothetical), no navigation is ever possible again.
- **Suggested fix:** Add a 5-second timeout: `Future.delayed(Duration(seconds: 5), () => _isNavigating = false)` as a safety net.

**[NAV-EDGE-05] Low memory — `IndexedStack` holds all 5 tab trees alive simultaneously — P2**
- File: `lib/screens/tab_navigator.dart`
- `IndexedStack` keeps all 5 tab widgets instantiated and in the tree, even when not visible. This is intentional for state preservation, but means all 5 tabs consume memory simultaneously:
  - Tab 0 (`LearnScreen`): loads species database, path metadata
  - Tab 1 (`PracticeHubScreen`): loads SR state
  - Tab 2 (`HomeScreen`): loads tank data, room scene, stage providers
  - Tab 3 (`SmartScreen`): loads AI history, anomaly data
  - Tab 4 (`SettingsHubScreen`): loads profile
- Under low memory pressure (e.g. old Android phones), the OS may kill the app process, which clears all state. On resume, Flutter recreates the widget tree but providers must re-initialize from `SharedPreferences`/file storage. The `_AppRouter`'s onboarding check handles the initial routing correctly on resume.
- **Risk:** `_currentTankIndex` in `HomeScreen` is local widget state — if the OS restores the widget tree but the `State` is recreated (as happens on some Android process death scenarios), the selected tank index resets to 0.
- **Suggested fix:** Persist `_currentTankIndex` to `SharedPreferences` or a Riverpod `StateProvider` so it survives process death.

**[NAV-EDGE-06] `HomeScreen._navigateToCreateFirstTank` has a double-deferred `addPostFrameCallback` — P2**
- File: `lib/screens/home/home_screen.dart` — the auto-prompt function is disabled with `return;` (dead code), so this is not active. If re-enabled, the double-deferred callback could still fire after the widget is unmounted in edge cases (rapid tab switching during initial load). The `if (!mounted) return;` guards are present but the double-defer pattern adds complexity.

---

## 11. Additional Issues Found

**[NAV-MISC-01] `LearnScreen` auto-scroll hardcodes 320px — P2**
- File: `lib/screens/learn_screen.dart` line (in `_maybeScrollToFirstLesson`)
- `_scrollController.animateTo(320.0, ...)` assumes the `StudyRoomScene` header is exactly 320px tall. It is `SizedBox(height: 320)` — currently correct. But if the header height changes (e.g. for a promotional banner, or OS status bar changes), the auto-scroll will be off.
- **Suggested fix:** Use a `GlobalKey` on the first learning path section and scroll to its `RenderBox` position instead.

**[NAV-MISC-02] Notification-pushed `LearnScreen` is a full `LearnScreen`, not just the lesson list — P2**
- File: `lib/main.dart` line 105
- `navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => const LearnScreen()))` pushes the entire `LearnScreen` via root navigator. This gives users a full Learn experience outside the tab navigator, but without the bottom nav bar. Users who finish a lesson then hit back and are returned to whatever was under the root navigator (likely the tab navigator, which shows the last active tab). This may be confusing — the back button from a lesson completed via notification takes the user back to `LearnScreen` (outside tabs), then one more back to their previous tab.
- **Suggested fix:** Instead of pushing `LearnScreen`, switch to Tab 0 (`currentTabProvider.notifier.state = 0`) using the root navigator context, then navigate within Tab 0's navigator.

**[NAV-MISC-03] `TankDetailScreen` navigation uses `Navigator.of(context)` from a `ConsumerWidget` — P2**
- File: `lib/screens/tank_detail/tank_detail_screen.dart`
- `TankDetailScreen` is a `ConsumerWidget` (not a `StatefulWidget`). All navigation calls use `Navigator.of(context)` from within the `build` method's context. This is safe for callbacks (`onPressed: () => Navigator.of(context).push(...)`), but for async callbacks (e.g. after awaiting `_completeTask`), the context could be stale.
- The code has `if (context.mounted)` guards in several places. Verify all async navigation chains have these guards.

**[NAV-MISC-04] `WorkshopScreen` "Charts" and "Equipment" tiles show info snackbars, not navigation — P3**
- File: `lib/screens/workshop_screen.dart` lines 177, 181
- Two tiles call `AppFeedback.showInfo(context, 'Select a tank first...')` rather than navigating anywhere. These features are accessible from `TankDetailScreen` but not from the Workshop without a tank context. This is a discoverability gap.
- **Suggested fix:** Either disable/hide these tiles when no tank exists, or make them navigate to the Tank tab with a prompt.

**[NAV-MISC-05] `EnhancedQuizScreen._buildResults` shows XP animation on first build frame via `addPostFrameCallback` — P2**
- File: `lib/screens/enhanced_quiz_screen.dart`
- XP animation starts after results build. If the user immediately presses "Complete" (tapping as results appear), `widget.onComplete` is called while `XpAwardOverlay` is still running. There is no guard preventing this. The overlay is an overlay entry — it should not crash, but the animation will be cut short.
- **Suggested fix:** Disable the "Complete" button until the XP animation has finished (`_xpAnimationComplete` flag).

---

## Severity Summary

| ID | Issue | Severity | File |
|----|-------|----------|------|
| NAV-BACK-01 | WorkshopScreen has no back button/AppBar | P1 | workshop_screen.dart |
| NAV-BACK-02 | TankSettings "Delete Tank" uses popUntil(isFirst) | P1 | tank_settings_screen.dart |
| NAV-DEEP-02 | Out-of-hearts pop + PopScope(canPop:false) edge case | P1 | lesson_screen.dart |
| NAV-TANK-02 | CreateTank uses rootNavigator — TankDetail has no tab bar | P1 | home_screen.dart |
| NAV-LESSON-01 | _findNextLesson only searches loadedPaths | P1 | lesson_screen.dart |
| NAV-LESSON-02 | Quiz progress lost on app kill | P1 | lesson_screen.dart |
| NAV-EDGE-04 | NavigationThrottle static bool can permanently block nav | P1 | navigation_throttle.dart |
| NAV-BACK-03 | Settings reset/clear uses rootNavigator popUntil | P2 | settings_screen.dart |
| NAV-SHEET-01 | StoryPlayer completion dialog barrierDismissible:false | P2 | story_player_screen.dart |
| NAV-SHEET-02 | OnboardingTutorial dialog barrierDismissible:false | P2 | enhanced_tutorial_walkthrough_screen.dart |
| NAV-SHEET-03 | SpacedRepetition dialog barrierDismissible:false | P2 | spaced_repetition_practice_screen.dart |
| NAV-SHEET-04 | Stacked bottom sheets (Progress → Stats → Daily Goal) | P2 | home_screen.dart |
| NAV-SHEET-05 | _showStatsDetails "Calendar" uses deactivated sheet context | P2 | home_screen.dart |
| NAV-TANK-01 | No CTA after first tank creation | P2 | home_screen.dart |
| NAV-LESSON-03 | Quiz "Check Answer" lacks debounce | P2 | lesson_screen.dart |
| NAV-LESSON-04 | LevelUpDialog in XpAwardOverlay callback (guarded) | P2 | lesson_screen.dart |
| NAV-EDGE-02 | Quiz state fully in-memory (lost on kill) | P1 | lesson_screen.dart |
| NAV-EDGE-03 | Tank creation state lost on kill | P2 | create_tank_screen.dart |
| NAV-EDGE-05 | IndexedStack holds all 5 tabs in memory | P2 | tab_navigator.dart |
| NAV-EDGE-05b | _currentTankIndex not persisted across process death | P2 | home_screen.dart |
| NAV-PROFILE-01 | Achievement notification uses root navigator (no tab bar) | P2 | main.dart |
| NAV-PROFILE-02 | No direct profile screen from main navigation | P2 | settings_hub_screen.dart |
| NAV-MISC-02 | Notification-pushed LearnScreen outside tab navigator | P2 | main.dart |
| NAV-MISC-03 | TankDetailScreen async navigation context guards | P2 | tank_detail_screen.dart |
| NAV-MISC-05 | EnhancedQuizScreen Complete button active during XP anim | P2 | enhanced_quiz_screen.dart |
| NAV-DEEP-01 | pushReplacement chains prevent back to previous lessons | P2 | lesson_screen.dart |
| NAV-TAB-03 | _maybeShowFirstTankPrompt auto-launch disabled (dead code) | P2 | home_screen.dart |
| NAV-MISC-01 | LearnScreen auto-scroll hardcodes 320px | P2 | learn_screen.dart |
| NAV-TANK-03 | Marine type disabled but tappable | P3 | create_tank_screen.dart |
| NAV-TAB-01 | Initial tab is Learn (0) not Tank (2) | P3 | tab_navigator.dart |
| NAV-TAB-02 | Haptic fires on same-tab tap but no animation | P3 | tab_navigator.dart |
| NAV-SETTINGS-02 | Daily Goal not reachable via deep link | P3 | settings_screen.dart |
| NAV-SETTINGS-03 | RoomNavigation in settings may link to WorkshopScreen | P3 | settings_screen.dart |
| NAV-PROFILE-03 | Friends/Leaderboard screens hidden (CA-002, CA-003) | P3 | settings_hub_screen.dart |
| NAV-EDGE-01 | Rotation locked (by design) | P3 | main.dart |
| NAV-MISC-04 | Workshop Charts/Equipment show snackbar not navigation | P3 | workshop_screen.dart |

---

## Priority Fixes Recommended (P0/P1 immediately)

1. **NAV-BACK-01** — Add `Scaffold`/`AppBar` to `WorkshopScreen`. Trivial 1-line fix.
2. **NAV-EDGE-04** — Add a safety-reset timeout to `NavigationThrottle` (5s `Future.delayed` fallback).
3. **NAV-LESSON-01** — In `LessonScreen.initState`, ensure the lesson's parent path is loaded in `lessonProvider` before displaying the screen.
4. **NAV-BACK-02** — Replace `popUntil(isFirst)` in `TankSettingsScreen` with deterministic `pop()` × 2.
5. **NAV-TANK-02** — Remove `rootNavigator: true` from `_navigateToCreateFirstTank` or document as intentional full-screen flow.
6. **NAV-LESSON-02** — Persist quiz progress to `SharedPreferences` on each question answer.
7. **NAV-SHEET-05** — Fix `_showStatsDetails` "Calendar" button context to use screen-level context, not sheet-level context.

---

*End of audit. 37 issues total: 7× P1, 23× P2, 7× P3.*
