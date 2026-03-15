# Danio — Functional Logic Audit
**Date:** 2026-03-15  
**Auditor:** Subagent (read-only)  
**Scope:** lib/providers/, lib/services/, lib/models/, lib/data/  

---

## Summary

| Severity | Count |
|----------|-------|
| P0 (crash / data loss) | 4 |
| P1 (wrong behaviour, visible bug) | 14 |
| P2 (edge case / minor issue) | 12 |
| **Total** | **30** |

---

## 1. XP / Level System

### LOGIC-XP-01 · P1 · Double XP write on `addXp()` + `completeLesson()`
**File:** `lib/providers/user_profile_provider.dart`  
**Issue:** `completeLesson()` writes `totalXp += xpReward` directly, *then* calls `recordActivity(xp: 0)`. Similarly, `addXp()` writes totalXp *then* calls `recordActivity(xp: 0)`. The inline comment documents this correctly, but it is a structural trap: any future developer who calls `recordActivity(xp: someValue)` after these methods will double-count. The `recordActivity` method also writes `totalXp += effectiveXp + bonusXp` — if `effectiveXp=0` this is safe, but the dependency is fragile.  
**Suggested fix:** Consolidate into a single internal `_applyXp(amount, {bool recordStreak})` helper to remove the dual-path complexity and comment.

---

### LOGIC-XP-02 · P1 · Level calculation relies on Map iteration order
**File:** `lib/models/user_profile.dart` — `UserProfile.levels`, `currentLevel`, `levelTitle`, `xpToNextLevel`, `levelProgress`  
**Issue:** `levels` is a `const Map<int, String>` with keys `{0, 100, 300, 600, 1000, 1500, 2500}`. All four computed getters iterate this map with a `for (final entry in levels.entries)` and break when the threshold is exceeded. In Dart, `Map` literals maintain insertion order, so this works *today*. However, there is no compile-time guarantee and the pattern is fragile. Additionally:
- `levelProgress` has an off-by-one: the first level (index 0) returns `progress / range` where `prevThreshold = 0` — correct. But when `totalXp == 0`, the loop enters the first branch (`totalXp < 100`) and returns `0 / 100 = 0.0`. ✅ OK.
- `xpToNextLevel` returns `0` for max level (Guru, ≥2500 XP). The UI should explicitly handle `xpToNextLevel == 0` to avoid showing "0 XP to next level."  
**Suggested fix:** Use a `List<MapEntry>` or a sorted list of thresholds for level calculations. Add a `bool get isMaxLevel => totalXp >= 2500` property.

---

### LOGIC-XP-03 · P2 · XP boost multiplier applied in two places
**File:** `lib/providers/user_profile_provider.dart`  
**Issue:** Both `addXp()` and `recordActivity()` accept `xpBoostActive` and independently double the XP. If both are ever called with `xpBoostActive: true` on the same user action, XP would be quadrupled. Current call sites use `recordActivity(xp: 0)` after `addXp()` which sidesteps this — but it's a booby trap.  
**Suggested fix:** Apply boost multiplier only once at the outermost call site before passing to any internal methods.

---

### LOGIC-XP-04 · P2 · Streak bonus XP not shown in daily XP history correctly
**File:** `lib/providers/user_profile_provider.dart` → `recordActivity()`  
**Issue:** In `recordActivity()`, `bonusXp` (from `XpRewards.dailyStreak`) is added to `totalXp` and to `dailyXpHistory[todayKey]`, but this happens *inside* the `offlineService.awardXp(localUpdate: ...)` closure. The base `amount` passed to `awardXp` is `effectiveXp` — so the streak bonus XP is counted in history. However, the call from `addXp()` passes `xp: 0` to `recordActivity`, so `effectiveXp = 0` there. If `addXp()` is called with `xpBoostActive: true`, the boost was already applied before `recordActivity` — the history entry will be correct, but the in-memory `effectiveXp` inside the closure will be 0 (the boost isn't threaded into the closure). This is a non-obvious data flow.

---

## 2. Hearts System

### LOGIC-HRT-01 · P1 · Refill timer not started on first heart loss
**File:** `lib/services/hearts_service.dart` → `loseHeart()`  
**Issue:** The refill timer only starts when `lastHeartRefill == null || hearts >= maxHearts`. On first heart loss from 5→4: `shouldStartTimer = (4 < 5) && (lastHeartRefill == null || 5 >= 5)` = `true && true` = ✅ timer starts. Correct.  
On second loss from 4→3: `shouldStartTimer = (3 < 5) && (lastHeartRefill != null && 4 < 5)` → `(3 < 5)` AND `(lastHeartRefill != null)` → second condition is `false`. Timer is NOT restarted. This is intentional — the timer keeps counting from the original loss. However, `getTimeUntilNextRefill()` computes based on `lastHeartRefill`, so `timeSinceRefill` correctly advances for multiple pending hearts.  
**Real issue:** After `refillToMax()` is called (gem purchase), `updateRefillTime: false` means `lastHeartRefill` is NOT cleared. The next `loseHeart()` will find a stale `lastHeartRefill` and may immediately calculate that 60+ minutes have passed, auto-refilling before the user even finishes the lesson.  
**Suggested fix:** Set `lastHeartRefill = null` inside `refillToMax()` to reset the timer state cleanly.

---

### LOGIC-HRT-02 · P1 · Auto-refill can grant hearts beyond max
**File:** `lib/services/hearts_service.dart` → `calculateAutoRefill()`  
**Issue:** The clamp logic `intervalsPassed.clamp(0, HeartsConfig.maxHearts - profile.hearts)` correctly caps at remaining capacity. However, `checkAndApplyAutoRefill()` passes `profile.hearts + heartsToRefill` without validating the final value before `_updateHearts()`. If `calculateAutoRefill` returns e.g. 3 and hearts=4, it would try to set hearts=7. The `.clamp(0, HeartsConfig.maxHearts)` in `_updateHearts` saves this, but only by accident.  
**Severity reduced:** The clamp in `_updateHearts` means no actual over-max state is saved. P1 for the logic gap, not an actual data corruption.

---

### LOGIC-HRT-03 · P2 · 0-heart state blocks lesson but no UI prompt to wait or purchase
**File:** `lib/services/hearts_service.dart` → `canStartLesson()`  
**Issue:** When `profile.hearts == 0` and `isPracticeMode == false`, `canStartLesson()` returns `false`. The caller is responsible for showing an appropriate UX (wait or purchase). The service provides `timeUntilNextRefill()` but there is no enforcement that callers check and display this. No error is thrown, so a silent `false` could be ignored.  
**Suggested fix:** Acceptable as-is if all lesson entry points check the return value (audit of screens is outside scope). Low risk.

---

### LOGIC-HRT-04 · P2 · `getHeartsDisplay()` reads from service, not provider state
**File:** `lib/providers/hearts_provider.dart` → `HeartsState.fromProfile()`  
**Issue:** `heartsDisplay` is built by calling `service.getHeartsDisplay()` which reads `currentHearts` from `ref.read(userProfileProvider)`. This is the same profile passed in, so it's consistent — but it introduces an indirect read when the value is already available from `profile.hearts` directly. Minor coupling issue.

---

## 3. Gems System

### LOGIC-GEM-01 · P0 · State set to error after rollback in `spendGems()`
**File:** `lib/providers/gems_provider.dart` → `spendGems()` catch block  
**Issue:**
```dart
state = AsyncValue.data(originalState); // rollback ✅
state = AsyncValue.error(e, st);        // immediately overwrites rollback ❌
rethrow;
```
The two lines in the catch block first restore `originalState` (correct), then immediately overwrite it with an error state. The UI will see an error, not the rolled-back data. On the next interaction, the state is `AsyncValue.error` which makes `current = state.value` return `null` — causing `Cannot spend gems: Gems state not loaded` on the next purchase attempt, even though the save failure was transient.  
**Suggested fix:** Remove the second `state = AsyncValue.error(e, st)` line. Only set error if you want to block further operations.

---

### LOGIC-GEM-02 · P1 · Gems balance can theoretically go negative via concurrent calls
**File:** `lib/providers/gems_provider.dart`  
**Issue:** `spendGems()` checks `current.balance < amount` before proceeding. If two simultaneous spend calls race (e.g. a double-tap), both could pass the balance check before either updates the state. Riverpod's StateNotifier is not inherently async-safe here.  
**Suggested fix:** Add a `_spending` lock flag, or debounce the spend button in the UI.

---

### LOGIC-GEM-03 · P2 · Transaction history capped at 100 but `totalEarned`/`totalSpent` computed from truncated history
**File:** `lib/providers/gems_provider.dart` → `totalEarned`, `totalSpent`  
**Issue:** Transactions are trimmed to the last 100. `totalEarned` and `totalSpent` iterate only those 100 transactions. A user with >100 transactions will see incorrect totals in the UI.  
**Suggested fix:** Track cumulative `totalEarned` and `totalSpent` as separate persisted counters, updated atomically with each transaction.

---

### LOGIC-GEM-04 · P2 · `GemRewards.getStreakMilestoneReward` uses same reward for day-14 as day-7
**File:** `lib/models/gem_economy.dart`  
**Issue:**
```dart
if (streakDays == 14) return streak7Days; // 10 gems — same as 7 days
if (streakDays == 50) return streak30Days; // 25 gems — same as 30 days
```
Day 14 and day 50 streaks give the same reward as the smaller milestone. Probably unintentional.  
**Suggested fix:** Define `streak14Days` and `streak50Days` constants with distinct values.

---

## 4. Streak System

### LOGIC-STK-01 · P1 · `lastActivityDate` stored as local time — timezone change resets streak
**File:** `lib/providers/user_profile_provider.dart` → `recordActivity()` and `_normalizeDate()`  
**Issue:** `lastActivityDate` is set to `DateTime.now()` (local time) and `_normalizeDate()` strips hours/minutes. This is correct for single-timezone use. However, `dayDifference = today.difference(lastDate).inDays` — if a user travels across timezones, `DateTime.now()` will shift, and a difference of 1 "local day" may not be 1 actual calendar day. For example, a user who completes a lesson at 11 PM EST, then flies to Los Angeles and opens the app at 10 PM PST the same evening, will see `dayDifference = 0` (same local date after normalization) — streak not incremented, but the user did it two separate "local days." Low frequency but a known Duolingo-class edge case.  
**Suggested fix:** Store `lastActivityDate` as UTC and normalise to UTC midnight for comparisons.

---

### LOGIC-STK-02 · P1 · Streak freeze granted date not initialised on new profile
**File:** `lib/models/user_profile.dart`  
**Issue:** New profiles are created with `hasStreakFreeze: true` but `streakFreezeGrantedDate: null`. `shouldResetStreakFreeze` checks `if (streakFreezeGrantedDate == null) return true` — so it always returns `true` for new users. On the first call to `recordActivity()`, if `shouldResetStreakFreeze` is true, the code does:
```dart
c = c.copyWith(hasStreakFreeze: true, streakFreezeGrantedDate: DateTime.now(), ...);
```
This is benign — it simply assigns the date on first use. But it adds an unnecessary write on every first activity if the freeze was never explicitly granted.  
**Suggested fix:** Initialise `streakFreezeGrantedDate` to profile creation date in `createProfile()`.

---

### LOGIC-STK-03 · P2 · Streak freeze consumed even if streak was already reset
**File:** `lib/providers/user_profile_provider.dart` → `recordActivity()`  
**Issue:** The freeze is used when `dayDifference == 2 && hasStreakFreeze && !streakFreezeUsedThisWeek`. If the streak was already 0 (user had been inactive for weeks), this branch still consumes the freeze to increment a streak from 0 to 1, which is logically wrong — the freeze should only preserve an *existing* streak.  
**Suggested fix:** Add condition `&& c.currentStreak > 0` before using freeze.

---

### LOGIC-STK-04 · P2 · `isStreakActive` in UserProfile inconsistent with `recordActivity` logic
**File:** `lib/models/user_profile.dart` → `isStreakActive`  
**Issue:** `isStreakActive` returns true if `lastActivityDate` is today OR yesterday (using local time comparison). But `recordActivity()` resets streak on `dayDifference >= 2`. These are consistent. However, `isStreakActive` uses `DateTime(...)` (midnight local) comparison, while `recordActivity` uses `_normalizeDate()` which does the same. They agree for normal use, but both should be moved to a single shared utility.

---

## 5. Achievement System

### LOGIC-ACH-01 · P1 · `completionist` achievement counts incorrectly
**File:** `lib/services/achievement_service.dart`  
**Issue:**
```dart
final otherAchievements = AchievementDefinitions.all
    .where((a) => a.id != 'completionist')
    .length; // = 54
final unlockedCount = userProfile.achievements.length; // includes completionist if unlocked
```
`userProfile.achievements.length` includes ALL unlocked IDs, including `completionist` itself once awarded. But `completionist` can never unlock itself because `progress.isUnlocked` is checked before the switch — so it's fine on first eval. However, `unlockedCount >= 54` will be false if `AchievementDefinitions.all.length` grows. The count is hardcoded implicitly and not self-updating.  
**Suggested fix:** Compare `unlockedCount` against `AchievementDefinitions.all.length - 1` explicitly.

---

### LOGIC-ACH-02 · P1 · 6 master/topic achievements permanently disabled
**File:** `lib/services/achievement_service.dart`  
**Issue:** `beginner_master`, `intermediate_master`, `advanced_master`, `water_chemistry_master`, `plants_master`, `livestock_master` all have `shouldUnlock = false` with comment "Not implemented." These achievements are listed in the Trophy Case UI, are visible to users, but can never be earned. Users will be confused.  
**Suggested fix:** Either implement the logic using `LessonProvider.allPathMetadata.expand(m => m.lessonIds)` filtered by path, or mark them `isHidden: true` until implemented.

---

### LOGIC-ACH-03 · P1 · `midnight_scholar` condition too strict — only fires at exactly 00:00
**File:** `lib/services/achievement_service.dart`  
**Issue:**
```dart
shouldUnlock = time.hour == 0 && time.minute == 0;
```
This requires a lesson to be completed in the *exact minute* of midnight — `00:00` to `00:00:59`. Practically impossible in normal use.  
**Suggested fix:** Widen to `time.hour == 0` (any time between midnight and 1 AM).

---

### LOGIC-ACH-04 · P1 · `weekend_warrior` achievement has no tracking mechanism
**File:** `lib/services/achievement_service.dart`, `lib/models/achievements.dart`  
**Issue:** `weekend_warrior` requires 10 weekends in a row with learning activity. `AchievementStats.weekendStreaks` defaults to 0 and nothing in the codebase ever increments it — no call site passes a non-zero value. The achievement can never be earned.  
**Suggested fix:** Track weekend activity in `recordActivity()` — check if `DateTime.now().weekday >= 6` and increment/track a separate weekend streak counter.

---

### LOGIC-ACH-05 · P1 · `heart_collector` and `daily_goal_streak` have no tracking mechanism
**File:** `lib/services/achievement_service.dart`  
**Issue:** Both rely on `stats.fullHeartsStreak` and `stats.dailyGoalStreaks` respectively. Neither is ever incremented — callers pass 0 for both fields. Both achievements are permanently inaccessible.  
**Suggested fix:** `fullHeartsStreak` should be tracked at session end; `dailyGoalStreaks` should be computed from `dailyXpHistory`.

---

### LOGIC-ACH-06 · P2 · `early_bird` / `night_owl` use local time, not user's home timezone
**File:** `lib/services/achievement_service.dart`  
**Issue:** `lastLessonCompletedAt.hour` uses device local time. Travellers or users who change timezone will have inconsistent results. Low severity for a casual app.

---

### LOGIC-ACH-07 · P2 · Dual achievement system (legacy `Achievements` + new `AchievementDefinitions`) creates confusion
**File:** `lib/models/learning.dart`, `lib/data/achievements.dart`  
**Issue:** The legacy `Achievements` class in `models/learning.dart` has 22 achievements. The new `AchievementDefinitions` in `data/achievements.dart` has 55. The `unlockAchievement()` method falls back to the legacy class. Some IDs exist in both (e.g. `first_lesson`). The `@deprecated` annotation is present but no migration path is documented.  
**Suggested fix:** Remove the legacy class entirely and update all references. The `_rarityToTier` mapping in `user_profile_provider.dart` is a smell that the migration is incomplete.

---

## 6. Learning System

### LOGIC-LRN-01 · P1 · Lesson prerequisites enforced in model but not in UI navigation
**File:** `lib/models/learning.dart` → `Lesson.isUnlocked()`  
**Issue:** `isUnlocked()` correctly checks `prerequisites`. However, audit of the lesson screen flow is needed to confirm that locked lessons are non-tappable in the UI. If the screen simply loads the lesson regardless, users can complete lessons out of order and bypass prerequisites. (Cannot fully verify without reading all screen files, but the model logic itself is correct.)

---

### LOGIC-LRN-02 · P1 · Quiz pass threshold is 70% but no heart is deducted for failing a quiz
**File:** `lib/models/learning.dart`, `lib/services/hearts_service.dart`  
**Issue:** `Quiz.passingScore = 70`. There is no code path visible that calls `heartsActions.loseHeart()` on a quiz failure. A user can retry quizzes indefinitely without any heart penalty, making the hearts system irrelevant to the quiz flow.  
**Suggested fix:** Decide whether quiz failures should deduct a heart. If yes, call `loseHeart()` on quiz fail in the quiz screen.

---

### LOGIC-LRN-03 · P2 · `_extractReviewableConceptsFromLesson` seeded from already-loaded lesson, but `autoSeedFromLesson` is separate path
**File:** `lib/providers/user_profile_provider.dart`, `lib/providers/spaced_repetition_provider.dart`  
**Issue:** Two methods exist for seeding review cards: `_createReviewCardsForLesson()` (via `user_profile_provider`) and `autoSeedFromLesson()` (via `spaced_repetition_provider`). Both create cards for the same lesson. If both are called (e.g. `completeLesson()` calls the first, and a screen also calls the second), duplicate cards are created — though the `conceptId` duplicate check prevents exact duplicates from the same method. However, `_createReviewCardsForLesson` uses IDs like `${lessonId}_section_$i` while `autoSeedFromLesson` uses `${lessonId}_section_$sectionIndex` — these are identical. The duplicate guard in `createCard()` (`if (state.cards.any((c) => c.conceptId == conceptId)) return;`) prevents true duplication.  
**Verdict:** Logic is safe, but the two code paths are confusing. Consolidate.

---

### LOGIC-LRN-04 · P2 · Spaced repetition only has 4 intervals (1, 7, 14, 30 days); missing 3-day step
**File:** `lib/models/spaced_repetition.dart`  
**Issue:** `ReviewInterval` has `day1, day3, day7, day14, day30`. The `_calculateNextInterval()` method skips `day3` entirely — it goes `day1 → day7` when strength crosses 0.6. Standard SM-2 algorithm uses a 3-day interval. The `day3` enum value is defined but never returned.  
**Suggested fix:** Add `if (strength >= 0.4) return ReviewInterval.day3;` before the day1 fallback.

---

### LOGIC-LRN-05 · P2 · Review streak uses `_isSameDay()` which doesn't handle DST
**File:** `lib/providers/spaced_repetition_provider.dart`  
**Issue:** `_isSameDay(a, b)` compares year/month/day. Consistent with the rest of the codebase. Same timezone issue as streak (LOGIC-STK-01) applies.

---

## 7. Tank Management

### LOGIC-TNK-01 · P1 · Tank volume validation is absent — 0 litre tank allowed
**File:** `lib/providers/tank_provider.dart` → `TankActions.createTank()`  
**Issue:** `volumeLitres` is passed directly with no validation. A user could create a tank with `volumeLitres: 0` or even negative (if the UI allows it). The `Tank.fromJson` defaults to `0` if null. Downstream code (compatibility checker, stocking advisors) divides or compares against volume without null/zero checks.  
**Suggested fix:** Add `assert(volumeLitres > 0)` or throw `ArgumentError` for zero/negative volume.

---

### LOGIC-TNK-02 · P1 · `deleteTank()` and `softDeleteTank()` both exist — double-delete path
**File:** `lib/providers/tank_provider.dart`  
**Issue:** `deleteTank()` calls `_storage.deleteTank(id)` immediately. `softDeleteTank()` starts a 5-second timer then calls `permanentlyDeleteTank(id)`. If UI calls both (race or UI bug), `deleteTank` fires immediately and the storage entry is gone, but `softDeleteTank`'s timer will still fire calling `permanentlyDeleteTank` on a non-existent ID. `_storage.deleteTank(id)` on a non-existent ID is a silent no-op (HashMap.remove returns null), so no crash, but `onUndoExpired` callback may still fire causing UI confusion.  
**Suggested fix:** Prefer using only `softDeleteTank()` from UI, and make `deleteTank()` private or internal.

---

### LOGIC-TNK-03 · P0 · Race condition in `bulkMoveLivestock()` — loads from source tank, may be stale
**File:** `lib/providers/tank_provider.dart` → `bulkMoveLivestock()`  
**Issue:**
```dart
final allLivestock = await storage.getLivestockForTank(fromTankId);
for (final id in livestockIds) {
  final livestock = allLivestock.firstWhere((l) => l.id == id, ...);
  ...
}
```
If another coroutine adds/removes livestock between the `getLivestockForTank` call and the loop (e.g. user adds a fish on another screen), `firstWhere` will throw `StateError('Livestock not found: $id')` which propagates as an unhandled error. The `_persistLock` in `LocalJsonStorageService` protects against storage race conditions, but `bulkMoveLivestock` fetches data outside the lock.  
**Suggested fix:** Wrap in a try-catch per item, or reload from storage per item to avoid stale snapshot.

---

### LOGIC-TNK-04 · P2 · `importTanks()` silently drops livestock/equipment/logs
**File:** `lib/providers/tank_provider.dart` → `importTanks()`  
**Issue:** The method imports tanks but explicitly comments: "livestock, equipment, logs would need separate handling." An imported tank appears in the UI with no data. This is documented in comments but not surfaced to the user.  
**Suggested fix:** Show a warning after import: "Tank imported with no livestock, logs, or equipment."

---

### LOGIC-TNK-05 · P2 · Soft-delete 5-second timer not stopped when app goes to background
**File:** `lib/providers/tank_provider.dart` → `SoftDeleteState`  
**Issue:** `SoftDeleteState.dispose()` cancels timers when the ProviderScope is torn down. But if the user swipes away the app during the 5-second undo window, the timer may fire and attempt to call `permanentlyDeleteTank()` via a `Timer.run()` without a valid context. On Android, background Dart isolate timers can fire after the UI is gone.  
**Suggested fix:** Check if the provider is still alive before executing the permanent delete, or use a persisted flag instead of an in-memory timer.

---

## 8. Water Parameters

### LOGIC-WTR-01 · P1 · No validation on water test input values — negative pH allowed
**File:** `lib/models/log_entry.dart` → `WaterTestResults`  
**Issue:** All water test fields are nullable `double?` with no range validation. Users can log `ph: -1`, `temperature: 500`, `ammonia: -0.5` etc. These would then appear in trend charts and trigger false alerts.  
**Suggested fix:** Add factory/constructor validation or a `validate()` method that enforces: `ph ∈ [0, 14]`, `temperature ∈ [0, 50]°C`, `ammonia ≥ 0`, `nitrite ≥ 0`, `nitrate ≥ 0`, `gh ≥ 0`, `kh ≥ 0`.

---

### LOGIC-WTR-02 · P1 · `latestWaterTestProvider` uses `logsProvider` (50-log limit) — oldest tests may be missed
**File:** `lib/providers/tank_provider.dart`  
**Issue:** `latestWaterTestProvider` watches `logsProvider(tankId)` which has `limit: 50`. For active tanks with many water change/feeding/observation logs, the most recent water test may be beyond position 50. The query fetches latest 50 logs (sorted by `timestamp DESC`) so this is actually fine — `limit: 50` is applied after sorting, so the 50 most recent logs are returned. **Verdict: Safe.** The most recent test will be in the first 50 entries.

---

### LOGIC-WTR-03 · P2 · `testStreakProvider` and `waterChangeStreakProvider` use separate 365-day window providers
**File:** `lib/providers/tank_provider.dart`  
**Issue:** Both streak providers use `recentLogsProvider` which cuts off at 365 days. A user with a 366-day test streak will see their streak reset to 0. Acceptable for MVP but should be documented as a known limitation.

---

### LOGIC-WTR-04 · P2 · WaterTargets has no validation — `phMin > phMax` allowed
**File:** `lib/models/tank.dart` → `WaterTargets`  
**Issue:** All target range fields are independently nullable doubles. Nothing prevents `phMin: 8.0, phMax: 6.0` (inverted range). Alert logic downstream that checks `value < target.phMin || value > target.phMax` would fire for every test result.  
**Suggested fix:** Add assertion `assert(phMin == null || phMax == null || phMin! <= phMax!)` etc.

---

## 9. Compatibility Checker

### LOGIC-CPT-01 · P1 · `avoidWith` matching is too broad — partial name match can cause false positives
**File:** `lib/screens/compatibility_checker_screen.dart`  
**Issue:**
```dart
a.avoidWith.any((name) =>
    b.commonName.toLowerCase().contains(name.toLowerCase()) ||
    b.family.toLowerCase().contains(name.toLowerCase())
)
```
If species A's `avoidWith` contains `"Cichlid"`, it will flag any species whose name *contains* "Cichlid" (including "Apistogramma" — which is technically a dwarf cichlid in the `Cichlidae` family, but `b.family` would be `Cichlidae`, which contains "cichlid"). More dangerously: if `avoidWith` contains `"Large"`, it would match any species name containing "Large." Currently no species has "Large" in avoidWith, but the logic is fragile.  
**Suggested fix:** Match against exact common names or scientific names only (no partial substring match on family).

---

### LOGIC-CPT-02 · P1 · No tank size check in compatibility checker
**File:** `lib/screens/compatibility_checker_screen.dart`  
**Issue:** The checker validates temperature, pH, size ratio, and temperament — but does NOT check minimum tank size. You can add 10 species each requiring 200L and the checker will show "Compatible" even for a 20L nano tank.  
**Suggested fix:** Add tank size parameter to the checker, or at minimum show the maximum `minTankLitres` across all selected species as a requirement.

---

### LOGIC-CPT-03 · P2 · School size requirement not checked
**File:** `lib/screens/compatibility_checker_screen.dart`, `lib/data/species_database.dart`  
**Issue:** `SpeciesInfo.minSchoolSize` is defined (e.g. Neon Tetra = 6) but the compatibility checker never warns if the user adds only 1 or 2 of a schooling species. A user could plan a tank with 2 neon tetras and get a "compatible" result.  
**Suggested fix:** Add an issue if the user is adding a schooling species (minSchoolSize > 1) and only 1 instance is selected.

---

### LOGIC-CPT-04 · P2 · Species database has data inconsistency — Guppy temperament listed as "Peaceful" but `avoidWith` includes `"Bettas (male)"`
**File:** `lib/data/species_database.dart`  
**Issue:** The `avoidWith` string `"Bettas (male)"` will only match if a species in the checker has common name containing `"Bettas (male)"`. The Betta entry would have common name `"Betta"` or `"Siamese Fighting Fish"` — so the matcher `b.commonName.toLowerCase().contains("bettas (male)")` would fail (name is "Betta", not "Bettas (male)"). This avoidWith entry is effectively dead.  
**Suggested fix:** Normalise `avoidWith` to use canonical common names matching the database entries exactly, or use scientific names.

---

## 10. Data Persistence

### LOGIC-PRS-01 · P0 · `SharedPreferences` and `LocalJsonStorageService` are separate stores — XP/profile data lives in SharedPreferences, tank data in JSON file
**File:** `lib/providers/user_profile_provider.dart`, `lib/providers/gems_provider.dart`, `lib/providers/achievement_provider.dart`, `lib/providers/spaced_repetition_provider.dart` vs. `lib/services/local_json_storage_service.dart`  
**Issue:** User gamification state (XP, streak, gems, achievements, spaced repetition cards) is all stored in **SharedPreferences** as JSON strings. Tank, livestock, equipment, and logs are stored in a **single JSON file** (`aquarium_data.json`) via `LocalJsonStorageService`. These are two completely separate persistence layers with no cross-backup or unified restore path. The `backup_restore_screen.dart` presumably only handles one layer.  
**Risk:** A user's XP/achievements can be wiped by clearing app data in Android Settings while tank data survives (or vice versa on a restore). There is no atomic backup covering both.  
**Suggested fix:** Unify all persistence under one layer (preferably the JSON file), or ensure the backup/restore screens handle both SharedPreferences keys and the JSON file atomically.

---

### LOGIC-PRS-02 · P0 · Debounced save can lose XP on force-kill
**File:** `lib/providers/user_profile_provider.dart`  
**Issue:** `_save()` uses a 200ms debouncer. `_saveImmediate()` bypasses the debouncer and is used for XP, streaks, lesson completions, and achievements. However, `_save()` (non-immediate) is used for `updateProfile()`, `updateHearts()`, `updateStoryProgress()`, and `reviewLesson()` — the last of which awards XP and gems. If the app is force-killed within 200ms of a lesson review, the XP from that review is lost (even though gems were already saved to their own SharedPreferences key).  
**Suggested fix:** Change `reviewLesson()` to use `_saveImmediate()` since it also adds XP.

---

### LOGIC-PRS-03 · P1 · `_loadFuture` caching in `LocalJsonStorageService` — corrupted state not retried
**File:** `lib/services/local_json_storage_service.dart` → `_ensureLoaded()`  
**Issue:** `_loadFuture` is assigned once and cached. On `StorageState.corrupted`, `_ensureLoaded()` throws immediately. The only way to retry is via `retryLoad()` or `recoverFromCorruption()`. These require explicit UI action. If the storage fails on first load and the UI doesn't surface the error clearly, the app will appear to work (empty state) but all saves will fail silently because `_state == StorageState.corrupted` short-circuits.  
**Severity:** Actually checked: on `corrupted`, `_ensureLoaded()` throws `StorageCorruptionException`. All save methods call `_ensureLoaded()`, so saves will throw too. However, `TankActions.createTank()` catches and rethrows — the UI must handle this. If it doesn't, tank creation silently fails.

---

### LOGIC-PRS-04 · P2 · `aquarium_data.json.bak` backup is overwritten on every save
**File:** `lib/services/local_json_storage_service.dart` → `_persistUnlocked()`  
**Issue:** Every save copies the current file to `.bak` before writing. Frequent saves (equipment maintenance logs, task updates) will rapidly cycle the backup. If an issue occurs mid-session, the `.bak` is only 1 write behind. This is acceptable but users should know the backup is a rolling single-version backup, not a timestamped history.

---

## 11. Offline Behaviour

### LOGIC-OFF-01 · P1 · Connectivity check uses optimistic default — app shows "online" while checking
**File:** `lib/widgets/offline_indicator.dart` → `isOnlineProvider`  
**Issue:**
```dart
loading: () => true, // Assume online while loading
error: (_, __) => true, // Assume online on error
```
On app start, before the connectivity stream emits, the app assumes it is online. Any XP or gem operations that queue sync actions will execute locally (correct) but won't be queued for later sync if they complete before the connectivity state is known. The `OfflineAwareService.executeOrQueue()` reads `isOnlineProvider` — if this returns `true` during the initial loading phase, actions won't be queued even if the device is actually offline.  
**Suggested fix:** Default to `false` (assume offline) on loading, or delay user-facing gamification actions until connectivity state is confirmed.

---

### LOGIC-OFF-02 · P1 · Sync queue (`SyncService`) has no backend — queued actions are never actually replayed
**File:** `lib/services/sync_service.dart`, `lib/services/offline_aware_service.dart`  
**Issue:** `OfflineAwareService.executeOrQueue()` queues actions to `syncServiceProvider` when offline. The sync queue stores these in `SharedPreferences`. However, looking at `SyncService` — there is no backend API. All data is local-only. The sync queue is architectural scaffolding for a future backend. When connectivity returns, the queue items sit there but are never sent to any server. The app works correctly *locally* (actions execute immediately via `executeNow: localUpdate`) but the "queued for sync" pathway is dead code.  
**Severity:** P1 because users and developers may believe sync is happening when it isn't, creating false expectations. If a future backend is added, stale queued items may cause incorrect replays.  
**Suggested fix:** Either implement the backend sync flush, or remove the queuing mechanism and document that the app is fully local-only.

---

### LOGIC-OFF-03 · P2 · AI features (FishID, symptom triage, weekly plan) fail without internet — no graceful degradation
**File:** `lib/features/smart/` (multiple screens)  
**Issue:** Smart features that call external AI APIs will return errors when offline. Review of UI is out of scope for this logic audit, but the service layer should surface a user-friendly "offline" state rather than a raw error.

---

## Quick-Reference Priority Table

| ID | System | Severity | Title |
|----|--------|----------|-------|
| LOGIC-GEM-01 | Gems | P0 | State overwritten with error after rollback in spendGems() |
| LOGIC-TNK-03 | Tanks | P0 | Race condition in bulkMoveLivestock() |
| LOGIC-PRS-01 | Persistence | P0 | Two separate stores — no unified backup/restore |
| LOGIC-PRS-02 | Persistence | P0 | Debounced save can lose XP on force-kill in reviewLesson() |
| LOGIC-HRT-01 | Hearts | P1 | Refill timer not reset after refillToMax() |
| LOGIC-HRT-02 | Hearts | P1 | Auto-refill logic gap (saved by downstream clamp) |
| LOGIC-XP-01 | XP | P1 | Double XP write structural trap |
| LOGIC-XP-02 | XP | P1 | Level calculation relies on Map iteration order |
| LOGIC-STK-01 | Streak | P1 | lastActivityDate stored as local time — timezone shift resets streak |
| LOGIC-STK-02 | Streak | P1 | Streak freeze grant date not initialised on new profile |
| LOGIC-ACH-02 | Achievements | P1 | 6 master achievements permanently disabled (always shouldUnlock=false) |
| LOGIC-ACH-03 | Achievements | P1 | midnight_scholar fires only at exactly 00:00 — effectively impossible |
| LOGIC-ACH-04 | Achievements | P1 | weekend_warrior has no tracking — never earnable |
| LOGIC-ACH-05 | Achievements | P1 | heart_collector and daily_goal_streak have no tracking |
| LOGIC-ACH-01 | Achievements | P1 | completionist count implicit, breaks if achievement list grows |
| LOGIC-LRN-02 | Learning | P1 | Quiz failures don't deduct hearts — hearts system irrelevant to quizzes |
| LOGIC-TNK-01 | Tanks | P1 | No tank volume validation — 0L tank allowed |
| LOGIC-TNK-02 | Tanks | P1 | deleteTank() and softDeleteTank() double-delete path |
| LOGIC-WTR-01 | Water | P1 | No validation on water test values — negative pH/ammonia allowed |
| LOGIC-CPT-01 | Compatibility | P1 | avoidWith partial match causes false positives |
| LOGIC-CPT-02 | Compatibility | P1 | No tank size check in compatibility checker |
| LOGIC-OFF-01 | Offline | P1 | Optimistic connectivity default may miss queuing on cold start |
| LOGIC-OFF-02 | Offline | P1 | Sync queue is dead code — no backend to send to |
| LOGIC-GEM-02 | Gems | P2 | Concurrent spendGems() calls can race on balance check |
| LOGIC-GEM-03 | Gems | P2 | totalEarned/totalSpent computed from truncated 100-transaction history |
| LOGIC-GEM-04 | Gems | P2 | Day-14 streak reward same as day-7 (probably unintentional) |
| LOGIC-STK-03 | Streak | P2 | Freeze consumed even when streak is already 0 |
| LOGIC-STK-04 | Streak | P2 | isStreakActive inconsistency risk with recordActivity |
| LOGIC-LRN-04 | Learning | P2 | day3 ReviewInterval defined but never used in scheduling |
| LOGIC-CPT-03 | Compatibility | P2 | School size not checked in compatibility checker |
| LOGIC-CPT-04 | Compatibility | P2 | Guppy avoidWith "Bettas (male)" never matches Betta entry |
| LOGIC-TNK-04 | Tanks | P2 | importTanks() drops livestock/equipment/logs silently |
| LOGIC-TNK-05 | Tanks | P2 | Soft-delete timer may fire after app goes to background |
| LOGIC-WTR-03 | Water | P2 | testStreak/waterChangeStreak capped at 365 days |
| LOGIC-WTR-04 | Water | P2 | WaterTargets allows inverted ranges (phMin > phMax) |
| LOGIC-PRS-03 | Persistence | P1 | Corrupted storage silently fails saves after first error |
| LOGIC-ACH-06 | Achievements | P2 | early_bird/night_owl use device local time |
| LOGIC-ACH-07 | Achievements | P2 | Dual achievement system creates maintenance complexity |
| LOGIC-XP-03 | XP | P2 | XP boost multiplier applied at two call sites — quadruple risk |
| LOGIC-LRN-03 | Learning | P2 | Two separate card seeding paths — confusing but safe |

---

*End of audit. 30 findings total (4 × P0, 18 × P1, 12 × P2).*
