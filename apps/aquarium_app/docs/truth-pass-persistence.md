# Truth Pass: Persistence & Test Quality Verification

**Date:** 2026-03-29  
**Repo:** `apps/aquarium_app`  
**Analyst:** Orpheus (subagent)  
**Purpose:** Verify that data actually persists, assess real test quality, and confirm/refute surface audit must-fixes.

---

## Section 1: Persistence Truth Test

### Storage Architecture

All app data uses **two separate persistence layers**:
1. **`LocalJsonStorageService`** — single JSON file (`aquarium_data.json`) for tanks, livestock, equipment, logs, tasks
2. **`SharedPreferences`** — for user profile, gems, achievements, SRS cards, settings

Both use in-memory maps/objects that are flushed to disk on every write operation.

---

### 1.1 Tanks (create, update, delete)

**Write path:**  
`TankActions.createTank()` → `_storage.saveTank(tank)` → `LocalJsonStorageService.saveTank()` → `_persistLock.synchronized()` → `_tanks[tank.id] = tank` → `_persistUnlocked()` → `jsonEncode(payload)` → atomic write (`.tmp` → rename).

**Verdict: WRITES CORRECTLY.**

- `saveTank` acquires a `Lock` (from `synchronized` package) before modifying the in-memory map and flushing.
- `_persistUnlocked` does `jsonEncode(payload)` and writes to a `.tmp` file, then renames — this is an atomic write pattern.
- `deleteTank` also cascades: removes related livestock, equipment, logs, and tasks in the same lock block.
- `bulkDeleteTanks` uses `deleteAllTanks` which does a single atomic flush.

**JSON encode risk:** `_tankToJson` serialises all fields manually. There is **no silent failure** — any exception during `jsonEncode` propagates out of `_persistUnlocked` and up through `saveTank`, which does **not** catch it, so the caller (`TankActions.createTank/updateTank`) will `rethrow`. This is visible to the UI. ✅

---

### 1.2 Water Logs (add, edit)

**Write path:**  
`_storage.saveLog(log)` → `LocalJsonStorageService.saveLog()` → `_persistLock.synchronized()` → `_logs[log.id] = log` → `_persistUnlocked()`.

**Verdict: WRITES CORRECTLY.**

- `_logToJson` serialises all log fields including `waterTest`, `waterChangePercent`, `photoUrls` etc.
- No silent failure path — exceptions propagate.
- No "edit log" helper exists in `tank_provider.dart` at the provider level, but `saveLog` is idempotent (overwrite by ID), so editing means calling `saveLog` with the updated entry again. This is standard.

**Note:** There is no `updateLog` helper in `TankActions`; callers must use `_storage.saveLog` directly or via a screen-level service. This is a minor API gap, not a persistence bug.

---

### 1.3 User Profile (XP, level, streak, gems, inventory)

**Write path (user profile):**  
`UserProfileNotifier._saveImmediate(profile)` → `prefs.setString('user_profile', jsonEncode(profile.toJson()))`.

**Verdict: WRITES CORRECTLY — with one design caveat.**

- XP and streak use `_saveImmediate` (bypasses debounce) for critical state changes.
- A 200ms debounce (`_saveDebouncer`) is used for less critical updates like `updateProfile`.
- A lifecycle observer (`_ProfileLifecycleListener`) flushes any pending saves when the app is paused/detached — **important safety net** to prevent data loss on app kill.
- `recordActivity` reads state fresh inside the async closure (comment explicitly flags the stale-snapshot risk). ✅

**Potential silent failure risk:**  
In `_save()`, the debouncer captures `_pendingSave` at callback time. If `_pendingSave` is null when the debounce fires (because `_saveImmediate` cleared it), the save is **silently skipped**. This is intentional by design (immediate save wins), but could theoretically lose data if `_save` and `_saveImmediate` race. Risk is low due to Dart's single-threaded concurrency, but worth noting.

**Gems write path:**  
`GemsNotifier._save(gemsState)` → 500ms `Timer` debounce → `prefs.setString('gems_state', jsonEncode(gemsState.toJson()))`.

**Verdict: WRITES CORRECTLY — with debounce caveat.**

- Gems use a `Timer` debounce (not a `Debouncer`). If the app is killed within 500ms of a gem award, the debounce timer is cancelled and gems are **lost**.
- Unlike user profile, there is **no lifecycle flush** for gems — `GemsNotifier.dispose()` cancels the timer without flushing.
- **This is a real data loss risk for gems.** A rapid gem award followed by app kill within 500ms will lose the award.

---

### 1.4 Achievements (unlock)

**Write path:**  
`AchievementProgressNotifier.updateProgress()` → `state = {...state, achievementId: progress}` → `_saveDebouncer.run()` (500ms) → `prefs.setString('achievement_progress', jsonEncode(toSave))`.

**Verdict: WRITES CORRECTLY — with debounce caveat.**

- 500ms debounce. `dispose()` calls `_saveDebouncer.flush()` which starts the async save but doesn't await it. If the app process is killed immediately, the flush may not complete.
- The unlock is also recorded in `UserProfile.achievements` via `unlockAchievement()`, which uses `_saveImmediate`. **The profile copy is safely persisted; only the `achievementProgressProvider` copy has the debounce risk.** Practical impact: progress UI may be slightly off on restart, but the achievement itself (tracked in profile) survives.

---

### 1.5 SRS Review Cards (schedule update)

**Write path:**  
`SpacedRepetitionNotifier.reviewCard()` → `_saveData()` → `prefs.setString('spaced_repetition_cards', jsonEncode(...))` + `prefs.setString('spaced_repetition_stats', jsonEncode(...))`.

**Verdict: WRITES CORRECTLY — errors are caught and may silently fail.**

- `_saveData()` throws `Exception('Failed to save review data: $e')` on failure.
- In `reviewCard()`, that exception is caught: state is rolled back, `errorMessage` is set, and the error is **not rethrown**. Comment says: "Don't rethrow - let review flow continue."
- **The `errorMessage` field on `SpacedRepetitionState` is never consumed by any screen in `spaced_repetition_practice/`** (confirmed by grep). The error is stored in state but never displayed to the user or propagated to UI.
- This matches MF-S2 — see Section 3 for full analysis.

---

### 1.6 JSON Encode Silent Failure Summary

| Data type | JSON encode step | Silent on failure? |
|---|---|---|
| Tanks | `jsonEncode` in `_persistUnlocked` | **No** — propagates up, logged, rethrown |
| Logs | Same as tanks | **No** |
| User profile | `jsonEncode(profile.toJson())` | **No** — `_saveImmediate` awaits and propagates |
| Gems | `jsonEncode(gemsState.toJson())` in 500ms timer | **Partially** — timer runs fire-and-forget, app kill = data loss |
| Achievements (progress) | `jsonEncode` in 500ms debounce | **Partially** — same debounce risk |
| SRS cards | `jsonEncode` in `_saveData` | **Yes (by design)** — errors caught and swallowed in `reviewCard` |

---

## Section 2: Test Quality Sample

### 2.1 Files Audited

Note: Two of the five requested test files do not exist:
- `test/screens/home_screen_test.dart` — **DOES NOT EXIST**
- `test/screens/settings_screen_test.dart` — **DOES NOT EXIST** (replaced by `test/screens/data_deletion_test.dart`)

Files actually found and analysed:
1. `test/screens/learn_screen_test.dart` ✅
2. `test/services/tank_health_service_test.dart` ✅
3. `test/screens/data_deletion_test.dart` ✅ (settings screen coverage)
4. `test/services/stocking_calculator_test.dart` ✅

---

### 2.2 Classification

#### `test/screens/learn_screen_test.dart` (6 tests)

| Test | Classification |
|---|---|
| `all 12 paths are present in allPathMetadata` | **behaviour** — asserts count matches expected value |
| `advanced_topics path is present (not hidden)` | **behaviour** — asserts specific ID in set |
| `advanced_topics has non-empty lessonIds` | **behaviour** — asserts content not empty |
| `all expected path IDs are present` | **behaviour** — asserts exact set equality |
| `no path has empty lessonIds` | **behaviour** — asserts invariant holds for all paths |
| `equipment path has content` | **behaviour** — asserts minimum content |

**All 6 tests are genuine behaviour tests.** They call no widgets; they test pure data structure integrity of `LessonProvider.allPathMetadata`. These are high-value regression tests.

---

#### `test/services/tank_health_service_test.dart` (12 tests)

| Test | Classification |
|---|---|
| `recent water change + good params → excellent or good` | **behaviour** — asserts score ≥ 60 + level enum |
| `score is in range 0-100` | **behaviour** — range assertion |
| `excellent label when score >= 80` | **behaviour** — conditional label assertion |
| `high ammonia → score reduced and warning in factors` | **behaviour** — penalty + factor presence |
| `ammonia = 0 gives full ammonia points` | **behaviour** — no warning expected |
| `no logs → score <= 40 (poor or fair)` | **behaviour** — penalised score range |
| `no logs → factors mention missing water changes` | **behaviour** — factor text content |
| `no water test → neutral param score, factors note this` | **behaviour** — factor text content |
| `water change 15 days ago → poor/fair and factor mentions overdue` | **behaviour** — overdue scoring |
| `water test 20 days ago → reduced param score` | **behaviour** — stale test penalty (comparative) |
| `no logs → streak is 0` | **behaviour** — edge case |
| `water change this week → streak is at least 1` | **behaviour** — basic streak logic |
| `consecutive weekly changes → streak counts correctly` | **behaviour** — streak accumulation |

**All 13 tests are genuine behaviour tests.** They test specific scoring logic with input variations and verify output correctness.

---

#### `test/screens/data_deletion_test.dart` (9 tests)

| Test | Classification |
|---|---|
| `Delete My Data tile is present in settings` | **presence** — `find.text()` only |
| `Delete My Data tile subtitle is visible` | **presence** — `find.text()` only |
| `tapping Delete My Data shows confirmation dialog` | **interaction** — tap + verify dialog appeared |
| `confirmation dialog contains warning text` | **interaction** — tap + verify text in dialog |
| `confirmation dialog has Delete Everything and Cancel buttons` | **interaction** — tap + verify button presence |
| `tapping Cancel dismisses dialog without deleting` | **interaction** — tap + verify dialog gone, screen still present |
| `dialog mentions email address for GDPR compliance` | **interaction** — tap + verify text |
| `tapping Delete Everything triggers deletion (prefs cleared)` | **persistence** — tap + verify SharedPreferences cleared |
| `Clear All Data tile is also present` | **presence** — scroll + `find.text()` |
| `Clear All Data subtitle is visible` | **presence** — scroll + `find.text()` |

**Breakdown:** 3 presence, 5 interaction, 1 persistence. Quality is good — the deletion test actually verifies SharedPreferences was cleared. No pure smoke tests here.

---

#### `test/services/stocking_calculator_test.dart` (12 tests)

| Test | Classification |
|---|---|
| `no livestock → understocked with 0% full` | **behaviour** — level + percent assertion |
| `empty tank summary mentions no livestock` | **presence** — `summary.isNotEmpty` (weak) |
| `empty tank → suggestions provided` | **presence** — `suggestions.isNotEmpty` (weak) |
| `small number of fish in large tank → good or understocked` | **behaviour** — level range + percent > 0 |
| `percent full increases with more fish` | **behaviour** — comparative assertion |
| `percentFull is clamped to 150 max` | **behaviour** — boundary/clamp |
| `too many fish in small tank → overstocked` | **behaviour** — overstocked enum |
| `overstocked → warning in result` | **behaviour** — level assertion |
| `overstocked summary is not empty` | **presence** — weak |
| `multiple species counted together` | **behaviour** — percent > 0 with two species |
| `result level is one of the defined enum values` | **smoke** — trivially true, enum must match |
| `moderate stocking range returns moderate level` | **smoke** — "just verify it's a valid level" (comment in code) |

**Breakdown:** 7 behaviour, 3 presence, 1 smoke, 1 trivial-smoke. Better quality than the name suggests.

---

### 2.3 Summary Counts

| File | Smoke | Presence | Interaction | Behaviour | Persistence | Total |
|---|---|---|---|---|---|---|
| learn_screen_test | 0 | 0 | 0 | 6 | 0 | 6 |
| tank_health_service_test | 0 | 0 | 0 | 13 | 0 | 13 |
| data_deletion_test | 0 | 3 | 5 | 0 | 1 | 9 |
| stocking_calculator_test | 2 | 3 | 0 | 7 | 0 | 12 |
| **TOTAL** | **2** | **6** | **5** | **26** | **1** | **40** |

**Real ratio: 31/40 (78%) are genuine behaviour/interaction/persistence tests.**  
Only 2/40 (5%) are smoke tests (trivially-true assertions in stocking_calculator).  
The learn screen and tank health tests are entirely behaviour-level — no fluff.

**Notable gap:** No `home_screen_test.dart` or `settings_screen_test.dart` exist. The settings coverage that exists (`data_deletion_test.dart`) is reasonable but tests one narrow flow. Home screen has zero coverage.

---

## Section 3: Surface Audit Must-Fix Verification

### MF-S1: Placement Test Routes Wrong

**Claim:** Placement test routes to the wrong screen.

**Evidence:**

`PlacementChallengeCard.dart` (line 97–100):
```dart
onPressed: () {
  NavigationThrottle.push(
    context,
    const SpacedRepetitionPracticeScreen(),
  );
},
```

The "Take the test" button on the placement challenge card navigates to `SpacedRepetitionPracticeScreen` — the **spaced repetition review hub** — not a dedicated placement test flow.

There is no `PlacementTestScreen`, no placement-specific route, and no screen that calls `completePlacementTest()` in the codebase (grep confirms zero matches for any screen calling that method outside the notifier itself).

The `UserProfileNotifier.completePlacementTest()` method exists and is wired up, but there is no screen that actually calls it. The card routes to SR practice, which has no awareness of placement testing and will never mark the user's `hasCompletedPlacementTest = true` via this flow.

**Verdict: CONFIRMED BROKEN.**  
The placement test CTA routes to the wrong screen, and there is no dedicated placement test screen at all. The `completePlacementTest()` method is dead code from a UI perspective.

---

### MF-S10: care/water_change Notifications Unhandled

**Claim:** Tapping a `care` or `water_change` notification does nothing useful.

**Evidence:**

In `notification_service.dart` (line 326–328):
```dart
case 'care':
case 'water_change':
  return 0; // Home tab
```

`payloadToTabIndex` maps both payloads to tab 0. However, this utility function is **never called** in `main.dart`.

In `main.dart`, the `_onNotificationPayload` handler (line 280–294) explicitly handles:
- `'learn'` → tab 0
- `'review'` → tab 1 + pushes `SpacedRepetitionPracticeScreen`
- `'home'` → tab 2
- `'achievements'` → tab 4 + pushes `AchievementsScreen`

There is **no `case` for `'care'` or `'water_change'`** in `_onNotificationPayload`. Both fall through to `if (targetTab < 0) return;` — the handler exits with no action.

The comment in `_handleNotificationFallback` says "Intentionally empty — onNotificationTap in main.dart handles this." But `main.dart` doesn't handle these payloads.

**Verdict: CONFIRMED BROKEN.**  
Tapping a care or water_change notification does nothing — the handler silently exits. The tab index mapping in `payloadToTabIndex` is never used.

---

### MF-S14: Difficulty Settings Don't Persist

**Claim:** Changes to difficulty settings are lost on restart.

**Evidence:**

In `settings_screen.dart` (line 764–788), the `_DifficultySettingsWrapper` widget:
```dart
late UserSkillProfile _profile;

@override
void initState() {
  super.initState();
  _profile = const UserSkillProfile(
    skillLevels: {},
    performanceHistory: {},
    manualOverrides: {},
  );
}

void _onProfileUpdated(UserSkillProfile updatedProfile) {
  setState(() {
    _profile = updatedProfile;
  });
}
```

The `UserSkillProfile` is initialised as an **empty in-memory const** with no load from SharedPreferences. `_onProfileUpdated` only calls `setState` — it does not persist to any storage.

In `difficulty_settings_screen.dart`, the `onProfileUpdated` callback is called when the user sets a manual override:
```dart
final Function(UserSkillProfile) onProfileUpdated;
```

But the callback only updates local widget state, not a provider or SharedPreferences.

Searching for `UserSkillProfile` persistence: no `prefs.setString` or `_save` call with `UserSkillProfile` exists anywhere in the codebase outside `DifficultySettingsScreen`'s parent widget.

**Verdict: CONFIRMED BROKEN.**  
`UserSkillProfile` (containing manual overrides and skill levels) is never persisted. Every app restart starts with empty difficulty data.

---

### MF-S17: Lighting Schedule Midnight Crash

**Claim:** The lighting schedule crashes when lights-on time is set to midnight (hour = 0).

**Evidence:**

In `lighting_schedule_screen.dart` (lines 296, 300):
```dart
'• CO2 ON: ${_formatTime(TimeOfDay(hour: _lightsOn.hour - 1, ...))}'
'• CO2 OFF: ${_formatTime(TimeOfDay(hour: _lightsOff.hour - 1, ...))}'
```

`TimeOfDay` requires `hour` to be in range 0–23. When `_lightsOn.hour == 0` (midnight), `hour - 1 == -1`.

The Flutter `TimeOfDay` constructor has the assertion:
```
assert(hour >= 0 && hour < 24)
```

In debug builds, this throws an `AssertionError`. In release builds, the assertion is skipped, but the `TimeOfDay` object is constructed with `hour: -1`. The `_formatTime` method then calls `time.hourOfPeriod` which returns `time.hour % 12`, resulting in `-1 % 12 = -1` in Dart (Dart modulo preserves sign for negative numbers), giving `hourOfPeriod == -1`, which then hits the `== 0 ? 12 : hourOfPeriod` check and returns `-1`. The display string would show `-1:00 AM` — wrong but not necessarily a crash in release.

However, in debug mode (which is most of development), this **will throw an AssertionError** whenever `_lightsOn.hour == 0` (midnight) or `_lightsOff.hour == 0`.

Default values are `TimeOfDay(hour: 10, ...)` and `TimeOfDay(hour: 20, ...)`, so this only triggers when the user sets midnight. The user can select midnight via the time picker.

**Verdict: CONFIRMED BROKEN (debug crash, release display corruption).**  
Setting lights-on or lights-off to midnight (00:00) crashes in debug mode via `AssertionError`. In release, it produces corrupt display text (`-1:00 AM`). Fix: clamp/wrap hour: `(hour - 1 + 24) % 24`.

---

### MF-S2: SR Error State Swallowed

**Claim:** Errors during spaced repetition reviews are silently swallowed.

**Evidence:**

`SpacedRepetitionNotifier.reviewCard()` (line ~395–459):
```dart
} catch (e, stackTrace) {
  // Rollback on save failure, but don't break review flow
  state = state.copyWith(
    cards: originalCards,
    stats: originalStats,
    errorMessage: 'Couldn\'t save that review — it\'ll retry automatically.',
  );
  logError('Failed to save review result: $e\n$stackTrace', ...);
  // Don't rethrow - let review flow continue
}
```

The error is stored in `state.errorMessage`. However, in `spaced_repetition_practice_screen.dart`, `srState.errorMessage` is **never read or displayed** (confirmed by grep: zero matches for `.errorMessage` in the practice screen file).

The `review_session_screen.dart` has its own local `_errorMessage` string (line 33) that it shows (line 269–278), but this is populated only from the try/catch within the screen itself, not from `srState.errorMessage`.

The result: if `_saveData` fails (e.g. SharedPreferences write error), the review silently rolls back, the save is logged, and the user sees nothing — not even the "Couldn't save that review" message that was carefully written.

There is a design comment: "Don't rethrow - let review flow continue" — which is reasonable UX, but the error message stored in state is then unused.

Additionally, `_saveData()` **throws** on failure rather than returning a result type, meaning any caller of `_saveData` that doesn't catch (e.g. `createCard`) will propagate the exception. But `reviewCard` catches it. So the error handling is inconsistent across the provider.

**Verdict: CONFIRMED BROKEN.**  
`state.errorMessage` is set but never consumed by the SR practice UI. Users receive no feedback when review saves fail; the rollback is also silent. The fix is to read `srState.errorMessage` in the practice screen and show a snackbar/toast.

---

## Summary

### Persistence

| Data type | Persists? | Risk |
|---|---|---|
| Tanks (CRUD) | ✅ Yes | None — atomic write, lock guarded |
| Water logs | ✅ Yes | None |
| User profile (XP, streak, level) | ✅ Yes | Minor — debounce on less critical saves |
| Gems | ⚠️ Mostly | 500ms debounce, no lifecycle flush — app kill = gem loss |
| Achievements | ⚠️ Mostly | Debounce, but profile copy saves immediately |
| SRS cards | ✅ Yes (normally) | Save errors silently swallowed |

### Test Quality

- **78% genuine tests** (behaviour / interaction / persistence)
- **5% smoke tests** (2 trivially-true assertions in stocking_calculator)
- **17% presence tests** (widget/text exists)
- `home_screen_test.dart` and `settings_screen_test.dart` are **missing** — zero coverage for those screens

### Must-Fix Verdicts

| ID | Description | Verdict |
|---|---|---|
| MF-S1 | Placement test routes wrong | ✅ CONFIRMED BROKEN — routes to SR, no dedicated screen exists |
| MF-S10 | care/water_change notifications unhandled | ✅ CONFIRMED BROKEN — handler exits silently |
| MF-S14 | Difficulty settings don't persist | ✅ CONFIRMED BROKEN — in-memory only, never saved |
| MF-S17 | Lighting schedule midnight crash | ✅ CONFIRMED BROKEN — `hour - 1` when hour=0 → crash/corrupt |
| MF-S2 | SR error state swallowed | ✅ CONFIRMED BROKEN — `errorMessage` set but never displayed |

**All 5 must-fixes are genuine bugs. None are false positives.**
