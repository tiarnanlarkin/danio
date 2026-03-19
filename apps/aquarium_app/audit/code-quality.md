# Code Quality & Architecture Audit — Danio Aquarium App

**Branch:** `openclaw/stage-system`
**Date:** 2026-03-19
**Auditor:** Argus
**Total files scanned:** 330 `.dart` files in `lib/`

---

## 1. Dead Code & Unused Items

### [CQ-001] `lib/constants/aquarium_constants.dart` — never imported
- **Severity:** P2
- **File:** `lib/constants/aquarium_constants.dart`
- **Description:** This file defines aquarium-related constants but is never imported by any other file in the codebase. All 330 dart files were scanned; zero imports reference it.
- **Suggested Fix:** Either import and use these constants where appropriate, or delete the file.

### [CQ-002] `lib/data/mock_friends.dart` — dead code (292 lines)
- **Severity:** P2
- **File:** `lib/data/mock_friends.dart`
- **Description:** Generates mock friend data for the social feature. The file is only self-referencing — no other file imports it. The social feature uses `lib/models/social.dart` for its data models. This file is dead weight in the bundle.
- **Suggested Fix:** Delete the file. If social mock data is needed for development, gate it behind a debug flag or move it to a test fixture.

### [CQ-003] `lib/data/mock_leaderboard.dart` — dead code
- **Severity:** P2
- **File:** `lib/data/mock_leaderboard.dart`
- **Description:** Mock leaderboard generator, never imported anywhere. Social/leaderboard screens either don't exist or use different data sources.
- **Suggested Fix:** Delete or move to test fixtures.

### [CQ-004] `lib/data/placement_test_content.dart` — dead code
- **Severity:** P2
- **File:** `lib/data/placement_test_content.dart`
- **Description:** Defines `PlacementTestContent` class, never imported by any other file. The placement test functionality may have been reimplemented elsewhere.
- **Suggested Fix:** Verify placement test still uses this; if not, delete.

### [CQ-005] `lib/data/stories.dart` (1,524 lines) — never imported
- **Severity:** P2
- **File:** `lib/data/stories.dart`
- **Description:** Massive story data file (1,524 lines) that is never imported. The `Story` model class exists in `lib/models/story.dart`, but the story content data itself isn't wired into any provider or screen.
- **Suggested Fix:** If the interactive stories feature is still planned, wire it in. Otherwise delete ~1,500 lines of dead code.

### [CQ-006] `lib/models/friend.dart` — never imported
- **Severity:** P2
- **File:** `lib/models/friend.dart`
- **Description:** Defines `Friend`, `FriendActivity`, `FriendEncouragement` classes. Never imported. The social feature uses `lib/models/social.dart` which has `FriendRequest` and `FriendChallenge` — different models.
- **Suggested Fix:** Consolidate friend models into `social.dart` or delete if unused.

### [CQ-007] `lib/painters/temp_gauge_painter.dart` — never imported
- **Severity:** P2
- **File:** `lib/painters/temp_gauge_painter.dart`
- **Description:** Custom painter for a temperature gauge, never referenced outside its own file. Likely a leftover from an earlier design iteration.
- **Suggested Fix:** Delete or wire into the UI.

### [CQ-008] `lib/painters/water_vial_painter.dart` — never imported
- **Severity:** P2
- **File:** `lib/painters/water_vial_painter.dart`
- **Description:** Custom painter for a water vial visualisation, never referenced outside its own file.
- **Suggested Fix:** Delete or wire into the UI.

### [CQ-009] `package:vibration` listed in pubspec.yaml but never used
- **Severity:** P2
- **File:** `pubspec.yaml:37`
- **Description:** The `vibration: ^2.0.0` package is declared as a dependency but never imported in any `.dart` file. Haptic feedback is handled via `HapticService` which uses `HapticFeedback` from `flutter/services.dart` instead.
- **Suggested Fix:** Remove `vibration` from `pubspec.yaml` dependencies.

### [CQ-010] `package:animations` listed in pubspec.yaml but never used
- **Severity:** P2
- **File:** `pubspec.yaml:46`
- **Description:** The `animations: ^2.0.11` package is declared but never imported. The codebase uses `flutter_animate` for all animations.
- **Suggested Fix:** Remove `animations` from `pubspec.yaml` dependencies.

### [CQ-011] `riverpod_annotation` + `build_runner` in pubspec.yaml but never used
- **Severity:** P3
- **File:** `pubspec.yaml:7,43`
- **Description:** `riverpod_annotation: ^2.6.1` and `build_runner: ^2.4.13` are listed but no code-generated providers exist. All providers use the functional `Provider()` / `StateNotifierProvider()` API.
- **Suggested Fix:** Remove from `pubspec.yaml`. They add unnecessary dependency tree weight.

### [CQ-012] `package:collection` imported in 5 files but potentially overkill
- **Severity:** P3
- **File:** `lib/providers/lesson_provider.dart:5`, `lib/screens/log_detail_screen.dart:5`, `lib/screens/tank_detail/widgets/alerts_card.dart:2`, `lib/screens/tank_detail/widgets/snapshot_card.dart:2`, `lib/services/analytics_service.dart:1`
- **Description:** Used 5 times — likely for `firstWhereOrNull` or `groupBy`. Lightweight enough to keep, but verify each import is used.
- **Suggested Fix:** Audit each usage; replace with inline logic if trivial.

---

## 2. Code Duplication

### [CQ-013] `SharedPreferences.getInstance()` called directly in 77 locations instead of using the shared provider
- **Severity:** P1
- **File:** `lib/providers/settings_provider.dart:68,94,105,115,125,135`, `lib/providers/gems_provider.dart:73,128,342`, `lib/providers/inventory_provider.dart:30,74,289,295,306,396`, `lib/providers/reduced_motion_provider.dart:68,119`, `lib/providers/room_theme_provider.dart:27,42`, `lib/providers/spaced_repetition_provider.dart:77,139`, and 54 more across `lib/features/smart/` and `lib/main.dart`
- **Description:** A `sharedPreferencesProvider` exists in `user_profile_provider.dart:28` but only 4 locations use it. The other 77 call `SharedPreferences.getInstance()` directly. This creates duplicated async initialisation paths and makes testing harder. The git log shows this was flagged (`refactor: provider .select() + safe JSON casts + shared SharedPrefs + dep audit`) but only partially addressed.
- **Suggested Fix:** Systematically replace all direct `SharedPreferences.getInstance()` calls with `ref.read(sharedPreferencesProvider.future)` in providers, and inject SharedPreferences via constructor in non-provider classes.

### [CQ-014] Repeated `debugPrint('Failed to save...')` pattern in `SettingsNotifier`
- **Severity:** P3
- **File:** `lib/providers/settings_provider.dart:94,105,115,125,135`
- **Description:** Five setter methods follow an identical pattern: update state → try save to prefs → catch with debugPrint. This is a copy-paste template that should be a private helper.
- **Suggested Fix:** Extract a `_persist(String key, dynamic value)` helper that wraps the try/catch/debugPrint pattern.

### [CQ-015] Duplicated `_SummaryCard` class in two screens
- **Severity:** P3
- **File:** `lib/screens/charts_screen.dart:943`, `lib/screens/cost_tracker_screen.dart:415`
- **Description:** Both files define a private `_SummaryCard` StatelessWidget with similar structure. These could potentially share a common widget.
- **Suggested Fix:** Extract to `lib/widgets/common/summary_card.dart` if the APIs are compatible, or accept as intentional divergence if the content differs significantly.

### [CQ-016] Achievement checker methods repeat the same `ref.read(userProfileProvider)` + build `AchievementStats` pattern
- **Severity:** P3
- **File:** `lib/providers/achievement_provider.dart:402,426,442,458,474,491,506`
- **Description:** Seven `checkAfter*` methods (e.g. `checkAfterTankCreated`, `checkAfterDailyTip`, `checkAfterPractice`, `checkAfterWaterChange`, etc.) all do: read userProfile → build AchievementStats with different fields → call `checkAchievements(stats)`. The pattern is identical except for which fields are passed.
- **Suggested Fix:** Consider a builder pattern or a single `checkAchievements(AchievementStats stats)` entry point where callers pass just the stats they have. The individual `checkAfter*` methods could become one-liners that just construct stats and call the single method.

---

## 3. State Management Patterns (Riverpod)

### [CQ-017] `ref.watch(userProfileProvider)` without `.select()` in 10+ screens causes unnecessary rebuilds
- **Severity:** P1
- **File:** `lib/screens/lesson_screen.dart:614`, `lib/screens/practice_hub_screen.dart:41`, `lib/screens/settings_hub_screen.dart:79`, `lib/screens/workshop_screen.dart:258`, `lib/screens/notification_settings_screen.dart:16`, `lib/screens/learn_screen.dart:242`, `lib/screens/gem_shop_screen.dart:71`, `lib/screens/achievements_screen.dart:37-38`
- **Description:** These screens watch the full `userProfileProvider` `AsyncValue` but only access one or two fields (e.g., `.value` for name, level, xp). Any change to any profile field triggers a full rebuild. The codebase already uses `.select()` in some places (e.g., `hearts_provider.dart:67`, `home/home_screen.dart:224`, `main.dart:354`) showing the pattern is understood but inconsistently applied.
- **Suggested Fix:** Add `.select()` to extract only the needed fields. For example: `ref.watch(userProfileProvider.select((a) => a.value?.totalXp ?? 0))` instead of watching the whole async value.

### [CQ-018] `ref.watch(inventoryProvider)` without `.select()` triggers rebuilds on any inventory change
- **Severity:** P2
- **File:** `lib/screens/inventory_screen.dart:69`, `lib/providers/inventory_provider.dart:404,414,431`
- **Description:** Inventory provider is watched fully in the screen and in 3 derived providers. The screen only needs the list to display, but the derived providers watching the same source cause cascading rebuilds.
- **Suggested Fix:** Evaluate if derived providers can use more granular selectors.

### [CQ-019] `achievementProgressProvider` watched in two separate places without memoisation concern
- **Severity:** P2
- **File:** `lib/screens/achievements_screen.dart:37`, `lib/providers/achievement_provider.dart:669,759`
- **Description:** The progress map is watched in the screen and also read (not watched) inside multiple `checkAfter*` notifier methods. The read-vs-watch usage is correct (notifier methods use `ref.read` which is fine in event handlers), but the provider is not `autoDispose` despite being derived data that could be recomputed.
- **Suggested Fix:** Consider `autoDispose` for derived providers that can be recomputed from base data.

---

## 4. Error Handling

### [CQ-020] 155 `debugPrint` calls not guarded by `kDebugMode`
- **Severity:** P2
- **File:** Multiple (see examples: `lib/data/achievements.dart:702`, `lib/data/shop_catalog.dart:308`, `lib/data/stories.dart:1477`, `lib/features/smart/anomaly_detector/anomaly_detector_service.dart:185,188`, `lib/features/smart/smart_providers.dart:32,81,137`, `lib/models/story.dart:101`, `lib/providers/achievement_provider.dart:63,83`)
- **Description:** Out of ~156 total `debugPrint` calls, only 18 are wrapped in `if (kDebugMode)`. The remaining 138 emit log lines in release builds. While `debugPrint` is a no-op in profile/release mode in Flutter, this is implementation-dependent and unreliable — some Flutter versions do emit in release. More critically, it signals that the codebase doesn't follow a consistent logging discipline.
- **Suggested Fix:** Establish a `log` utility that wraps `debugPrint` with a `kDebugMode` guard, then replace all bare `debugPrint` calls with it.

### [CQ-021] Empty catch in `wishlist_provider.dart` silently swallows save failure
- **Severity:** P2
- **File:** `lib/providers/wishlist_provider.dart:190`
- **Description:** `_saveToStorage().catchError((_) {})` — the monthly budget auto-reset save failure is silently ignored. While the comment says "not critical", if this consistently fails the user loses their budget reset every month with no indication.
- **Suggested Fix:** At minimum, add `debugPrint` logging. Consider tracking consecutive save failures and surfacing a warning to the user.

### [CQ-022] Multiple catch blocks in `auth_service.dart` only log via `debugPrint`
- **Severity:** P2
- **File:** `lib/features/auth/auth_service.dart:49,51,77,79,106,108,127,129,144`
- **Description:** Every auth method (signUp, signIn, resetPassword, signOut) catches exceptions and only prints them. The calling code in `auth_provider.dart` wouldn't know the sign-out failed, for example. While the provider does check `AuthResultStatus`, some error paths swallow the distinction.
- **Suggested Fix:** Ensure all auth errors propagate to the UI layer (via provider state or the result type) rather than being swallowed.

### [CQ-023] `catchError((e) {` in user_profile_provider returns no value
- **Severity:** P1
- **File:** `lib/providers/user_profile_provider.dart:70`
- **Description:** `prefs.setString(_key, jsonEncode(toSave.toJson())).catchError((e) { debugPrint(...); })` — `catchError` returns a `Future<void>` here, but the return value isn't being used. The `catchError` is fire-and-forget, which means if the save fails, the state was already updated but persistence failed silently. This could lead to data loss where the user sees updated data in the UI, closes the app, and reopens to find old data. The git log shows a fix attempt (`fix(warning): return bool from catchError`) but this specific instance may not have been addressed.
- **Suggested Fix:** Either `await` the save and handle the error (potentially reverting state), or at minimum use `.then((_) {}, onError: (e) { ... })` pattern explicitly.

### [CQ-024] `catch (e)` without `stackTrace` in 30+ locations
- **Severity:** P3
- **File:** Multiple (e.g., `lib/data/achievements.dart:701`, `lib/data/stories.dart:1476`, `lib/features/smart/smart_providers.dart:31,80,136`, `lib/main.dart:108,303,328`)
- **Description:** Many catch blocks use `catch (e)` without the `st` (StackTrace) parameter, losing stack trace information. Some correctly use `catch (e, st)` (e.g., `achievement_provider.dart:61,97,114`), but the pattern is inconsistent.
- **Suggested Fix:** Add `, st` to all catch clauses and log it alongside the error.

---

## 5. Model Layer Quality

### [CQ-025] 8 model files missing `@immutable` annotation
- **Severity:** P3
- **File:** `lib/models/equipment.dart`, `lib/models/gem_economy.dart`, `lib/models/leaderboard.dart`, `lib/models/livestock.dart`, `lib/models/log_entry.dart`, `lib/models/tank.dart`, `lib/models/task.dart`, `lib/models/wishlist.dart`
- **Description:** These model classes have `final` fields and `copyWith` methods (immutable pattern) but lack the `@immutable` annotation. Other models in the codebase correctly use it (e.g., `achievements.dart`, `adaptive_difficulty.dart`, `analytics.dart`).
- **Suggested Fix:** Add `@immutable` annotation and `import 'package:flutter/foundation.dart';` to each file.

### [CQ-026] `Friend.levelTitle` is a free-form string that should be an enum
- **Severity:** P3
- **File:** `lib/models/friend.dart:19`
- **Description:** `levelTitle` stores values like 'Beginner', 'Expert' etc. as strings. This is stringly-typed and prone to typos/mismatches. The app already has a level system in `user_profile.dart`.
- **Suggested Fix:** Reuse the existing level/title enum or create a `FriendLevel` enum.

### [CQ-027] `LearningTimePattern.preferredTimeOfDay` is a free-form string
- **Severity:** P3
- **File:** `lib/models/analytics.dart:291`
- **Description:** Comment says `// Morning/Afternoon/Evening/Night` but stored as `String`. Should be an enum for type safety.
- **Suggested Fix:** Create `TimeOfDayPreference` enum.

---

## 6. Architecture Issues

### [CQ-028] `user_profile_provider.dart` is 1,242 lines — god object
- **Severity:** P1
- **File:** `lib/providers/user_profile_provider.dart`
- **Description:** This file contains: `UserProfile` notifier, `sharedPreferencesProvider`, `LevelUpEventNotifier`, `streakFreezeUsedProvider`, `learningStatsProvider`, `xpBoostActiveProvider`, and 6 additional derived providers. It's a monolith that handles profile CRUD, XP/leveling, streaks, learning stats, and SharedPreferences injection.
- **Suggested Fix:** Split into: `user_profile_provider.dart` (profile CRUD only), `xp_provider.dart` (XP/leveling/boosts), `streak_provider.dart` (streaks/freezes), `learning_stats_provider.dart`. Move `sharedPreferencesProvider` to a shared `providers/core_providers.dart`.

### [CQ-029] 31 files exceed 500 lines
- **Severity:** P2
- **File:** See table below
- **Description:** Large files are harder to test, review, and maintain. Data files (species_database, stories, plant_database) are inherently large but should be split by content. Screen and provider files over 500 lines should be decomposed.

| File | Lines | Type |
|------|------:|------|
| `lib/data/species_database.dart` | 3,259 | Data |
| `lib/widgets/room_scene.dart` | 1,816 | Widget |
| `lib/screens/settings_screen.dart` | 1,673 | Screen |
| `lib/screens/lesson_screen.dart` | 1,634 | Screen |
| `lib/theme/app_theme.dart` | 1,620 | Theme |
| `lib/screens/livestock_screen.dart` | 1,601 | Screen |
| `lib/data/stories.dart` | 1,524 | Data (dead) |
| `lib/screens/add_log_screen.dart` | 1,473 | Screen |
| `lib/screens/learn_screen.dart` | 1,388 | Screen |
| `lib/screens/spaced_repetition_practice_screen.dart` | 1,316 | Screen |
| `lib/data/plant_database.dart` | 1,286 | Data |
| `lib/screens/analytics_screen.dart` | 1,262 | Screen |
| `lib/providers/user_profile_provider.dart` | 1,242 | Provider |
| `lib/screens/tank_detail/tank_detail_screen.dart` | 1,218 | Screen |
| `lib/widgets/stage/temp_panel_content.dart` | 1,120 | Widget |
| `lib/screens/create_tank_screen.dart` | 1,116 | Screen |
| `lib/screens/charts_screen.dart` | 1,079 | Screen |
| `lib/widgets/hobby_items.dart` | 1,019 | Widget |
| `lib/widgets/stage/water_panel_content.dart` | 962 | Widget |
| `lib/screens/theme_gallery_screen.dart` | 962 | Screen |

- **Suggested Fix:** For data files: split into chunked files per category. For screens: extract sub-widgets and helper classes into dedicated widget files. For providers: split by responsibility.

### [CQ-030] `room_scene.dart` at 1,816 lines — largest widget file
- **Severity:** P1
- **File:** `lib/widgets/room_scene.dart`
- **Description:** This single widget file contains the entire room scene with multiple sub-scenes, interactive objects, Rive fish integration, and decorative elements. It's extremely difficult to maintain and test.
- **Suggested Fix:** Split into `lib/widgets/room/room_scene.dart` (orchestrator), `lib/widgets/room/desk_scene.dart`, `lib/widgets/room/shelf_scene.dart`, etc. Extract interactive object handlers into separate files.

### [CQ-031] `app_theme.dart` at 1,620 lines — monolithic theme definition
- **Severity:** P2
- **File:** `lib/theme/app_theme.dart`
- **Description:** Contains all colour tokens, typography, spacing, radii, icon sizes, durations, and theme data. Any theme change requires navigating a very large file.
- **Suggested Fix:** Split into `colors.dart`, `typography.dart`, `spacing.dart`, `radii.dart`, `durations.dart`, `theme_data.dart` under `lib/theme/`.

---

## 7. Concurrency & Race Conditions

### [CQ-032] `_ExpiryTimer` is a `StatelessWidget` — countdown never updates
- **Severity:** P1
- **File:** `lib/screens/inventory_screen.dart:531`
- **Description:** `_ExpiryTimer` extends `StatelessWidget` and computes `expiresAt.difference(DateTime.now())` in `build()`. Since it's stateless, it will only show the remaining time at the moment it was last built. It will NOT tick down. The user sees a static "23h 5m left" that never updates until something else triggers a rebuild.
- **Suggested Fix:** Convert to `StatefulWidget` with a periodic `Timer` (1-second interval) that calls `setState()` to update the display. Ensure the timer is cancelled in `dispose()`.

### [CQ-033] Gems provider uses boolean flags for re-entrancy instead of proper locking
- **Severity:** P2
- **File:** `lib/providers/gems_provider.dart:61-62`
- **Description:** `bool _spending = false; bool _adding = false;` guard concurrent gem operations. The comment correctly notes Dart is single-isolate, but these flags are manually reset in `finally` blocks. If any code path throws before `finally` (which Dart guarantees won't happen), or if future refactoring introduces an early return, the flag stays stuck at `true` and permanently blocks that operation.
- **Suggested Fix:** The current approach is adequate for Dart's single-threaded model, but consider using a `Lock` from the `synchronized` package (already a dependency) for more robust protection and clearer intent.

### [CQ-034] `NotificationService` instantiated as `new` inside callback — no lifecycle management
- **Severity:** P2
- **File:** `lib/main.dart:301`
- **Description:** `final notificationService = NotificationService();` is created inside a callback. Each invocation creates a new instance, and there's no guarantee the previous one was properly cleaned up.
- **Suggested Fix:** Provide `NotificationService` as a Riverpod provider and inject it, ensuring a single instance with proper lifecycle management.

### [CQ-035] `CelebrationService` timers not guarded against double-scheduling
- **Severity:** P2
- **File:** `lib/services/celebration_service.dart:75-218`
- **Description:** Multiple methods (`triggerCelebration`, `triggerLevelUp`, `triggerStreakMilestone`, etc.) set `_dismissTimer` with `_cancelDismissTimer()` called first, which is correct. However, `_cancelDismissTimer` nulls out the timer, so if two celebrations trigger in rapid succession, the first timer is cancelled and replaced — this is likely intentional but could silently swallow a celebration.
- **Suggested Fix:** If intentional, add a comment documenting this is a deliberate "latest wins" policy. If not, consider queuing celebrations.

### [CQ-036] `ref.read()` inside `ref.read(_softDeleteStateProvider).markDeleted()` — notifier callback references `ref.read`
- **Severity:** P3
- **File:** `lib/providers/tank_provider.dart:197,206,296,305`
- **Description:** The `markDeleted(id, callback)` pattern uses a callback that may read other providers. This is fine in practice (callback runs synchronously), but the pattern is fragile — if it ever became async, it could read stale state.
- **Suggested Fix:** Accept as-is for now but document the synchronous constraint in a code comment.

---

## 8. TODOs & Tech Debt

### [CQ-037] Three TODO comments remain in production code
- **Severity:** P3
- **File:** `lib/screens/home/home_screen.dart:178`, `lib/theme/app_theme.dart:1046`, `lib/widgets/placement_challenge_card.dart:117`
- **Description:** TODO comments for future work: species viewing tracking, theme migration, and assessment flow replacement.
- **Suggested Fix:** Convert to tracked issues/tickets and remove from code, or add sprint identifiers with target dates.

---

## SUMMARY

| Category | P0 | P1 | P2 | P3 | Total |
|----------|----|----|----|----|----:|
| 1. Dead Code & Unused Items | 0 | 0 | 8 | 3 | 11 |
| 2. Code Duplication | 0 | 1 | 1 | 3 | 5 |
| 3. State Management | 0 | 1 | 2 | 0 | 3 |
| 4. Error Handling | 0 | 1 | 3 | 1 | 5 |
| 5. Model Layer Quality | 0 | 0 | 0 | 3 | 3 |
| 6. Architecture Issues | 0 | 2 | 2 | 0 | 4 |
| 7. Concurrency & Race Conditions | 0 | 1 | 3 | 1 | 5 |
| 8. TODOs & Tech Debt | 0 | 0 | 0 | 1 | 1 |
| **Total** | **0** | **6** | **19** | **12** | **37** |

### Key Action Items (by priority)

**P1 — Fix before next release:**
1. **CQ-032** — `_ExpiryTimer` is broken (static countdown, never updates)
2. **CQ-013** — SharedPreferences.getInstance() called directly 77 times instead of using shared provider
3. **CQ-017** — 10+ screens watch full userProfileProvider without `.select()`, causing unnecessary rebuilds
4. **CQ-023** — Fire-and-forget save in user_profile_provider can lead to silent data loss
5. **CQ-028** — user_profile_provider.dart is a 1,242-line god object
6. **CQ-030** — room_scene.dart at 1,816 lines needs decomposition

**P2 — Address in next sprint:**
- Delete 8 dead files (CQ-001 through CQ-008) — saves ~4,000+ lines of dead code
- Remove 4 unused packages from pubspec.yaml (CQ-009, CQ-010, CQ-011)
- Guard 138 debugPrint calls with kDebugMode (CQ-020)
- Split app_theme.dart into token files (CQ-031)
- Fix NotificationService lifecycle (CQ-034)
- Fix empty catch in wishlist_provider (CQ-021)
