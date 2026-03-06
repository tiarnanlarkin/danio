# 🐠 Aquarium App — Comprehensive UX Review

**Reviewer:** Apollo (Design Agent)
**Date:** 2026-02-23
**Commit state:** Current mirror HEAD
**Overall UX Score: 6.5 / 10**

> **Justification:** The app has a solid design system foundation (AppColors, AppOverlays, AppSpacing, etc.), strong skeleton loading patterns, and good error/empty state coverage on core screens. However, it suffers from a major navigation identity crisis (old HouseNavigator vs new TabNavigator), ~8 orphaned screens, 78 remaining `.withOpacity()` calls, 123 hardcoded `Colors.white` usages, an unwired Smart Hub, and common widgets (CozyCard, RoomHeader, PrimaryActionTile, DrawerListItem) that are defined but never imported in any screen. The onboarding flow has stale navigation pointers. With focused cleanup, this could easily reach 8+/10.

---

## 1. Navigation & Information Architecture

### Current Navigation Structure

**Primary shell:** `TabNavigator` (4-tab bottom nav — the *active* router from `main.dart`)

| Tab | Index | Screen | Icon |
|-----|-------|--------|------|
| Learn | 0 | `LearnScreen` | auto_stories |
| Quiz | 1 | `PracticeHubScreen` | quiz (badge: due cards) |
| Tank | 2 | `HomeScreen` | water |
| Settings | 3 | `SettingsHubScreen` | settings |

**Settings Hub sub-navigation** (push routes from Tab 3):
- Friends → `FriendsScreen`
- Leaderboard → `LeaderboardScreen`
- Shop Street → `ShopStreetScreen`
- Achievements → `AchievementsScreen`
- Workshop → `WorkshopScreen` (→ 9 calculator/tool screens)
- Analytics → `AnalyticsScreen`
- Preferences → `SettingsScreen` (→ Account, Notifications, Quick Start Guide, Theme Gallery, Difficulty, About)
- Backup & Restore → `BackupRestoreScreen`
- About → `AboutScreen` (→ Terms of Service, Privacy Policy)

**Tank drill-down** (push from HomeScreen):
- `TankDetailScreen` → Logs, Livestock, Equipment, Tasks, Charts, Cost Tracker, Journal, Maintenance Checklist, Photo Gallery, Tank Settings, Tank Comparison, Livestock Value

**Learn drill-down** (push from LearnScreen):
- `LessonScreen` → `PracticeScreen`
- `ParameterGuideScreen`
- `SpacedRepetitionPracticeScreen`

### 🔴 Critical Issue: Dual Navigation System

The **old** `HouseNavigator` (6-room horizontal swipe) still exists and is actively referenced by **5 onboarding screens**:
- `profile_creation_screen.dart` → `HouseNavigator` (skip-to-home)
- `first_tank_wizard_screen.dart` → `HouseNavigator`
- `tutorial_walkthrough_screen.dart` → `HouseNavigator`
- `enhanced_tutorial_walkthrough_screen.dart` → `HouseNavigator`
- `onboarding_screen.dart` → `HouseNavigator` (Quick Start)

**Impact:** Users completing onboarding land in the old 6-room swipe interface, NOT the new 4-tab interface. The `_AppRouter` in `main.dart` correctly routes to `TabNavigator`, but onboarding bypasses it.

**Fix needed:** Replace all `HouseNavigator` references in onboarding with `TabNavigator` (or route through `_AppRouter`).

### Dead Ends
- **No dead ends found.** All pushed screens have AppBar with back button (Flutter default).

### Orphaned Screens (built but unreachable)

| Screen | Status |
|--------|--------|
| `EnhancedOnboardingScreen` | **Orphaned** — never navigated to |
| `EnhancedQuizScreen` | **Orphaned** — never navigated to |
| `PlacementTestScreen` | **Orphaned** — superseded by `EnhancedPlacementTestScreen` |
| `GemShopScreen` | **Orphaned** — defined but no route to it |
| `SearchScreen` | **Orphaned** — defined but no route to it |
| `SmartScreen` | **Not wired** into bottom nav (see §5) |
| `StudyScreen` (rooms/) | Only used by old `HouseNavigator` |

### Information Hierarchy Assessment
The 4-tab structure is logical: Learn → Practice → Tank → Settings. The Quiz tab badge showing due cards is excellent. However, burying Community (Friends, Leaderboard) and Tools (Workshop, Analytics) under Settings creates discoverability issues. The Smart Hub (AI features) is entirely missing from navigation.

---

## 2. Design System Consistency Check

### Token Usage in Screens

| Token Class | Used in Screens? | Notes |
|-------------|-----------------|-------|
| `AppColors.*` | ✅ Widely used | Core palette well-adopted |
| `AppOverlays.*` | ✅ ~60+ usages | Good adoption of pre-computed alpha colors |
| `AppSpacing.*` | ✅ Used everywhere | Consistent spacing |
| `AppTypography.*` | ✅ Used in most screens | Good adoption |
| `AppRadius.*` | ✅ Used in most screens | Good adoption |
| `AppElevation` | ❌ **Never used in screens** | Defined but zero screen references |
| `AppDurations` | ❌ **Never used in screens** | Screens use raw Duration values |
| `AppCurves` | ❌ **Never used in screens** | Screens use raw Curves values |
| `AppIconSizes` | ❌ **Never used in screens** | Screens use hardcoded icon sizes |
| `AppTouchTargets` | ❌ **Never used in screens** | Zero adoption |
| `AppTouchPadding` | ❌ **Never used in screens** | Zero adoption |

### Common Widget Usage

| Widget | Defined In | Used in Screens? |
|--------|-----------|-----------------|
| `CozyCard` | `widgets/common/cozy_card.dart` | ❌ **Not imported by any screen** |
| `RoomHeader` | `widgets/common/room_header.dart` | ❌ **Not imported by any screen** |
| `PrimaryActionTile` | `widgets/common/primary_action_tile.dart` | ❌ **Not imported by any screen** |
| `DrawerListItem` | `widgets/common/drawer_list_item.dart` | ❌ **Not imported by any screen** |

**Verdict:** All 4 common widgets are dead code. They were designed but never adopted.

### Raw Colors vs AppColors Tokens

**Screens with local color palettes (bypassing AppColors entirely):**
- `InventoryScreen` → `_InventoryColors` class (7 raw `Color(0x...)` values)
- `ShopStreetScreen` → `ShopStreetColors` class (7 raw colors)
- `WorkshopScreen` → `WorkshopColors` class (10 raw colors)

These "themed room" screens define completely separate color systems. While intentional for the room aesthetic, they break dark mode and don't participate in the theme system.

### `.withOpacity()` Calls Remaining

**78 instances across screens**, including:
- `logs_screen.dart` (2)
- `reminders_screen.dart` (2)
- `learn_screen.dart` (1)
- `settings_hub_screen.dart` (2)
- `charts_screen.dart` (2)
- `enhanced_quiz_screen.dart` (2)
- `onboarding_screen.dart` (1)
- `leaderboard_screen.dart` (1)
- `rooms/study_screen.dart` (5) — paint operations
- Many more in guide screens and calculators

Most are dynamic-color contexts where `.withOpacity()` is harder to avoid, but at least ~30 could be replaced with pre-computed `AppOverlays` constants.

---

## 3. Screen-by-Screen UX Review

### Core Screens

| Screen | Loading | Empty | Error | Accessibility |
|--------|---------|-------|-------|---------------|
| **LearnScreen** | ✅ Skeletonizer | ⚠️ No explicit empty state for zero paths | N/A (static data) | ❌ No Semantics |
| **PracticeHubScreen** | ❌ No loading state | ✅ "All Caught Up!" card | ❌ No error handling | ❌ No Semantics |
| **HomeScreen** | ✅ Skeleton room + Skeletonizer | ✅ EmptyRoomScene widget | ✅ ErrorState widget | ❌ Minimal Semantics |
| **SettingsHubScreen** | ❌ No loading state | N/A | ❌ No error handling | ❌ No Semantics |
| **TankDetailScreen** | ✅ Excellent — skeleton loaders for every section | ⚠️ Partial | ⚠️ Generic fallback | ❌ No Semantics |

### Secondary Screens

| Screen | Loading | Empty | Error | Accessibility |
|--------|---------|-------|-------|---------------|
| **LogsScreen** | ✅ Skeletonizer with SkeletonPlaceholders | ✅ EmptyState.withMascot | ✅ ErrorState | ❌ No Semantics |
| **EquipmentScreen** | ✅ Skeletonizer with SkeletonPlaceholders | ✅ EmptyState.withMascot | ✅ ErrorState | ❌ No Semantics |
| **TasksScreen** | ✅ (implied via provider) | ✅ EmptyState | ✅ ErrorState | ❌ No Semantics |
| **FriendsScreen** | ⚠️ Basic CircularProgressIndicator | ✅ EmptyState.withMascot | ✅ ErrorState | ❌ No Semantics |
| **LivestockScreen** | ⚠️ Basic loading | ⚠️ Unclear | ⚠️ Unclear | ❌ No Semantics |
| **InventoryScreen** | ⚠️ Basic loading | ✅ EmptyState.withMascot | ✅ ErrorState | ⚠️ Some semanticLabels on icons |
| **LeaderboardScreen** | ❌ No loading (uses mock data) | N/A | N/A | ❌ No Semantics |
| **SmartScreen** | N/A | ✅ History empty check | ❌ No explicit error state | ❌ No Semantics |
| **LessonScreen** | ⚠️ Skeleton available but basic | N/A | ⚠️ Partial | ❌ No Semantics |

### Accessibility Summary
- **68 total Semantics/semanticLabel references** across all screens
- Only `ProfileCreationScreen` has thorough Semantics wrapping (~20 references)
- All other screens have zero or minimal accessibility annotations
- No `ExcludeSemantics` or `MergeSemantics` patterns outside onboarding
- **No screen reader testing evidence**

---

## 4. Onboarding Flow Review

### Current Flow
```
OnboardingScreen (3-page carousel)
  ├── Quick Start → creates default profile → HouseNavigator ⚠️
  ├── Skip Intro → ExperienceAssessmentScreen
  └── Get Started → ExperienceAssessmentScreen
                      └── FirstTankWizardScreen
                            └── HouseNavigator ⚠️
```

### Alternative Path (from _AppRouter)
```
_AppRouter (no onboarding, no profile)
  └── ProfileCreationScreen
        ├── Skip to Home → HouseNavigator ⚠️
        └── Complete → EnhancedPlacementTestScreen
                         └── PlacementResultScreen
                               └── (unclear final route)
```

### Issues Found

1. **🔴 Navigation mismatch:** All onboarding exits route to `HouseNavigator` (old 6-room swipe), not `TabNavigator` (current 4-tab). Users who complete onboarding see a completely different app than users who already had a profile.

2. **⚠️ Quick Start creates "Dev User" profile** — `_skipToHome()` in `ProfileCreationScreen` creates a profile named "Dev User" which should be renamed or made more user-friendly.

3. **⚠️ Redundant onboarding screens:** Both `OnboardingScreen` and `EnhancedOnboardingScreen` exist. The enhanced version is orphaned.

4. **✅ Good:** Experience assessment personalizes difficulty level. First Tank Wizard collects essential data. Quick Start option respects user agency.

5. **⚠️ No skip-back:** Once in ExperienceAssessmentScreen, there's no way to return to the onboarding carousel.

---

## 5. Smart Hub Integration Gap

### Current State
`SmartScreen` is fully built with 4 AI features (Fish ID, Symptom Triage, Weekly Plan, Anomaly History) but has **zero navigation routes** to it. It's not in TabNavigator, not in SettingsHubScreen, and not accessible from any screen.

### Exact Steps to Wire Into Bottom Nav

**File:** `lib/screens/tab_navigator.dart`

**Step 1:** Add import
```dart
import 'smart_screen.dart';
```

**Step 2:** Add 5th navigator key
```dart
final List<GlobalKey<NavigatorState>> _navigatorKeys = [
  GlobalKey<NavigatorState>(), // Learn
  GlobalKey<NavigatorState>(), // Quiz
  GlobalKey<NavigatorState>(), // Tank
  GlobalKey<NavigatorState>(), // Smart  ← ADD
  GlobalKey<NavigatorState>(), // Settings
];
```

**Step 3:** Add tab in `IndexedStack.children` (between Tank and Settings):
```dart
// Tab 3: Smart
Navigator(
  key: _navigatorKeys[3],
  onGenerateRoute: (settings) {
    return MaterialPageRoute(
      builder: (context) => const SmartScreen(),
      settings: settings,
    );
  },
),
```

**Step 4:** Update Settings tab index from 3 to 4.

**Step 5:** Add NavigationDestination (between Tank and Settings):
```dart
const NavigationDestination(
  icon: Icon(Icons.psychology_outlined),
  selectedIcon: Icon(Icons.psychology),
  label: 'Smart',
),
```

**Consideration:** 5 bottom nav tabs is the Material Design maximum. This fills the last slot. If more tabs are needed later, consider moving Smart into Settings Hub instead.

---

## 6. Missing Polish Items

### Unfinished / Stub Screens

| Screen | Issue |
|--------|-------|
| `EnhancedOnboardingScreen` | Complete but orphaned — superseded by `OnboardingScreen` |
| `EnhancedQuizScreen` | Complete but orphaned — no route leads to it |
| `GemShopScreen` | Fully built gem shop with categories, but no navigation route |
| `SearchScreen` | Built with search UI, but unreachable |
| `PlacementTestScreen` | Superseded by `EnhancedPlacementTestScreen`, orphaned |

### Hardcoded Test Data

| Location | Data |
|----------|------|
| `LeaderboardScreen` | Uses `MockLeaderboard.generate()` — entirely fake data |
| `ProfileCreationScreen._skipToHome()` | Creates profile with name "Dev User" |
| `data/mock_friends.dart` | Mock friend data (used by FriendsScreen) |
| `data/mock_leaderboard.dart` | Mock leaderboard entries |
| `data/stories.dart` | Story content (may be intentional static content) |

### Placeholder UI

- `LessonScreen` line 432: `// Placeholder for future image support`
- `AddLogScreen` line 601: `// Placeholder for alignment`
- `HomeScreen.EmptyRoomScene`: Has "Tank goes here" placeholder text

### Missing Features Referenced in Code

- Firebase Analytics: Commented out everywhere (`// FirebaseAnalyticsService()...`)
- Firebase Crashlytics: Commented out in `main.dart`
- Supabase sync: Configured but with placeholder credentials

---

## 7. Dark Mode Coverage

### Hardcoded Colors That Break Dark Mode

**`Colors.white` — 123 instances across screens:**
Most are used on colored/gradient backgrounds where white text is intentional (e.g., on primary-colored cards, story player overlay). However, several are problematic:

| File | Issue |
|------|-------|
| `friends_screen.dart:346` | `Border.all(color: Colors.white)` — avatar border, invisible in dark mode on light surfaces |
| `friends_screen.dart:425` | `color: Colors.white` — text on dynamic background |
| `learn_screen.dart:679` | `Colors.white` for card background — should use `AppColors.surface` |
| `add_log_screen.dart:1013,1019` | `Colors.white` for selected chip text — OK on colored bg |
| `maintenance_checklist_screen.dart:255` | `color: Colors.white` — on gradient, acceptable |

**`Colors.black` — 3 instances:**
| File | Issue |
|------|-------|
| `photo_gallery_screen.dart:283,285,316` | `Colors.black` as gallery background — **acceptable** (full-screen image viewer) |

**Splash screen in `main.dart`:**
```dart
color: isDark ? Colors.black : Colors.white,
```
Uses `Colors.black` / `Colors.white` with explicit dark mode checks — acceptable.

**Themed room screens with no dark mode:**
- `InventoryScreen` (dark purple gradient) — no light/dark variants
- `ShopStreetScreen` (forest green gradient) — no light/dark variants
- `WorkshopScreen` (brown gradient) — no light/dark variants

These rooms use their own fixed color schemes, so they look the same in both modes, which is a deliberate design choice but means dark mode users see light text on dark backgrounds regardless.

---

## Prioritised UX Improvements

### 🔴 P0 — Critical (Ship-blocking)

1. **Fix onboarding navigation target** — Replace all `HouseNavigator` references with `TabNavigator` in onboarding screens (5 locations). Users currently land in wrong app shell after onboarding.

2. **Wire Smart Hub into TabNavigator** — Add as 5th tab or as top-level entry in Settings Hub. AI features are built but invisible.

### 🟠 P1 — High (Quality bar)

3. **Delete or archive orphaned screens** — `EnhancedOnboardingScreen`, `EnhancedQuizScreen`, `PlacementTestScreen`, `GemShopScreen`, `SearchScreen`. Dead code adds confusion and bundle size.

4. **Replace mock data in LeaderboardScreen** — Currently uses `MockLeaderboard.generate()`. Either connect to real data or show explicit "demo" label.

5. **Rename "Dev User" quick-start profile** — Change to "Aquarist" or prompt for name.

6. **Add loading/error states to PracticeHubScreen and SettingsHubScreen** — These core tab screens have no loading or error handling.

### 🟡 P2 — Medium (Polish)

7. **Adopt `AppElevation`, `AppDurations`, `AppCurves`, `AppIconSizes`** — These tokens exist but are unused. Either adopt them across screens or remove them to reduce API surface.

8. **Adopt or remove common widgets** — `CozyCard`, `RoomHeader`, `PrimaryActionTile`, `DrawerListItem` are defined but never used. Either integrate them into screens or delete.

9. **Migrate remaining `.withOpacity()` calls** — 78 remaining instances. At least 30 are straightforward replacements with `AppOverlays` constants.

10. **Replace `Colors.white` with `AppColors.onPrimary`** where used as text-on-primary-bg. ~40 instances in `learn_screen.dart`, `lesson_screen.dart`, `inventory_screen.dart` could safely use the semantic token.

11. **Add accessibility labels** — Only `ProfileCreationScreen` has proper Semantics. All other screens need `Semantics` wrappers on interactive elements, especially cards and custom buttons.

12. **Consolidate room color palettes** — `InventoryColors`, `ShopStreetColors`, `WorkshopColors` should be part of the theme system (e.g., `RoomThemes`) rather than standalone classes.

### 🟢 P3 — Low (Nice-to-have)

13. **Consider deleting HouseNavigator** — The old 6-room swipe navigator is now superseded by TabNavigator. Clean removal would eliminate the navigation confusion entirely.

14. **Add empty state to PracticeHubScreen when no cards exist at all** — Currently shows "All Caught Up" which is misleading when user has never created any cards.

15. **Dark mode variant for themed rooms** — Inventory, Workshop, Shop Street use fixed gradient backgrounds. Consider subtle dark-mode adjustments.

16. **Add semantic `Tooltip` to bottom nav badges** — The due-cards badge on Quiz tab lacks accessibility description.

17. **Connect Firebase Analytics** — Currently commented out everywhere. Either implement or remove the dead imports.

---

## Architecture Notes

- **State management:** Riverpod — well-structured with clear provider patterns
- **Error boundary:** Global `ErrorBoundary` widget wraps the entire app ✅
- **Offline handling:** `OfflineIndicator` and `SyncIndicator` present at tab level ✅
- **Performance:** Pre-computed alpha colors (`AppOverlays`) is excellent engineering
- **Haptic feedback:** Consistently used on navigation and interactions ✅
- **Celebration system:** Level-up, confetti, XP animations all wired up ✅
- **Double-back-to-exit:** Implemented in TabNavigator ✅

---

*Review complete. The foundation is strong — the critical fixes are mostly wiring/navigation issues rather than fundamental design problems.*
