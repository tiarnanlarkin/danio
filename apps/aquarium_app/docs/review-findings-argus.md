# Danio — Finish-Line QA Review
**Reviewer:** Argus (QA Director)  
**Date:** 2026-03-29  
**Branch:** `openclaw/stage-system` | HEAD: `d7e14ac`  
**Test run:** 750/750 ✅ | 0 failures  
**Verdict:** ⚠️ **APPROVED WITH CONDITIONS** — shippable if you're honest about what the test suite is actually guarding

---

## 1. Test Suite Reality Check

### The Headline Numbers Are Misleading

**750 tests, 100% pass rate.** Sounds great. Reality check: this is better than most Flutter apps, and I mean that — but the number is doing a lot of heavy lifting to hide structural gaps.

**Actual breakdown by test type:**

| Type | Count | % | Comment |
|------|-------|---|---------|
| Pure smoke ("renders without throwing") | ~88 | ~12% | These confirm the widget tree doesn't explode. That's all. |
| UI presence checks ("shows AppBar/Scaffold/text") | ~250 | ~33% | Verify content is rendered. Not that it's correct or functional. |
| Interaction tests (tap/enter/expect outcome) | ~280 | ~37% | Mixed quality — some meaningful, many just "no crash on tap" |
| Behaviour/outcome tests (assert real state change) | ~80 | ~11% | The good stuff. Concentrated in provider tests and a few screen tests. |
| Data integrity tests | ~52 | ~7% | Solid. These catch real regressions. |

**Bottom line:** ~20–25% of the 750 tests are genuinely guarding behaviour. The other 75–80% confirm "doesn't crash" and little else.

### What's Actually There Since Last Audit

The prior audit noted 3/17 providers tested, 0/32 services tested. Since that audit, **meaningful additions have been made:**

- ✅ `test/services/tank_health_service_test.dart` — 13 tests, genuinely deep. Tests scoring logic, ammonia penalties, overdue water changes. **This is good testing.**
- ✅ `test/services/stocking_calculator_test.dart` — 12 tests, covers empty tank, overstocked, warnings.
- ✅ `test/services/shop_service_test.dart` — 16 tests covering purchase, insufficient gems, consumable use.
- ✅ `test/providers/user_profile_xp_level_test.dart` — XP levels, streak logic, pure model calculations.
- ✅ `test/utils/schema_migration_test.dart` — tests idempotency, version stamping.
- ✅ `test/widget_tests/onboarding_test.dart` — actually tests `gdpr_analytics_consent` key persistence. **GDPR critical path is now covered.**
- ✅ `test/widget_tests/tab_navigator_test.dart` — tab switching without crash.
- ✅ `test/widget_tests/story_browser_screen_test.dart` — includes minimal `StoryPlayScreen` tests (renders scene text, renders choice buttons).
- ✅ `test/data/species_unlock_map_test.dart` — added since audit.

**This is progress. Real, meaningful progress. The worst gaps called out in the prior audit have been partially addressed.**

### Remaining Quality Gaps

**What the test suite CANNOT catch:**

1. **Tank creation → data persists across hot restart** — No test verifies the full create tank → save → reload cycle. `InMemoryStorageService` is used throughout widget tests — correct for isolation, but means no test has ever exercised a real disk write/read round trip.

2. **Add water log → verify it appears in logs screen** — `add_log_screen_test.dart` renders the screen, taps the chip selectors, and stops. It does NOT submit a form and verify data was saved to the `InMemoryStorageService`. A broken save path would pass all current tests.

3. **Lesson completion → XP update chain** — `user_profile_xp_level_test.dart` tests the XP model maths. But the full path (tap Complete in `LessonScreen` → `UserProfileNotifier.completeLesson()` → XP increments → persisted) is never exercised end-to-end.

4. **Settings persist after save** — No test for "toggle reduced motion → restart → still toggled."

5. **Hearts deduction on wrong quiz answer** — `HeartsService` indirectly tested through `ShopService`. Direct deduction path untested.

6. **Empty state: no tanks created yet** — `EmptyRoomScene` is not tested. The empty state path on HomeScreen is untested.

7. **Livestock CRUD dialogs** — `livestock_add_dialog`, `livestock_edit_dialog`, `livestock_bulk_add_dialog`, `livestock_compatibility_check` — all ZERO tests.

8. **Integration tests: not wired to CI** — `smoke_test_v2.dart` exists and has sensible structure. It requires a running emulator and manual invocation. No evidence of GitHub Actions or CI pipeline running these automatically. They are aspirational, not operational.

**Services still without tests (14 of 32):**  
`AchievementService`, `BackupService`, `CloudBackupService`, `CloudSyncService`, `ConflictResolver`, `DifficultyService`, `HeartsService`, `NotificationScheduler`, `NotificationService`, `OfflineAwareService`, `OnboardingService`, `ReviewQueueService`, `SyncService`, `XpAnimationService`.

**The 87 ref.watch-without-select figure:** The prior audit reported 87. Current count shows **180 `ref.watch()` calls, 32 using `.select()`** — meaning **~148 broad watches** (vs 87 reported). `userProfileProvider` specifically: only 2 non-select watches. Most broad watches are on `tanksProvider`, `logsProvider`, `livestockProvider` etc. — fine when you need the whole list, concerning when you only need one field.

---

## 2. Error Handling Assessment

### What's Solid

The error handling infrastructure is genuinely good for a Flutter app at this stage. Not box-ticking — someone thought about this:

- `FlutterError.onError` + `PlatformDispatcher.instance.onError` both hooked in `main.dart`. Global errors are caught.
- Pre-Firebase error buffer (`_preFirebaseErrors`) for the startup window before Crashlytics initialises. Smart.
- `ErrorBoundary` wraps the app at the top level.
- `AppErrorState` component exists and is used on ~23 screens with user-friendly messages ("Couldn't load your tanks. Check your connection and give it another go!").
- GDPR-safe Crashlytics activation — collection only enabled after consent. Correct.
- No bare empty `catch (e) {}` blocks detected. This is the single most important error handling hygiene metric and it passes.
- Auth errors return typed `AuthResult.error()` values — not exceptions. Clean pattern.

### What Isn't

**Silent failures on `valueOrNull ?? []`:**

```dart
// home_screen.dart:353
ref.watch(logsProvider(currentTank.id)).valueOrNull ?? []
```

This pattern appears in 7 locations. If the storage service throws, the user sees an empty list. No error indicator. No retry. The user concludes their data is gone. **This is a silent failure that will generate 1-star reviews with "lost all my data."**

The distinction matters: some screens correctly use `.when(error: (e, _) => AppErrorState(...))`. Others silently fall back to empty. The inconsistency means a user's experience depends on which specific screen they're on when a storage error occurs.

**`streak_hearts_overlay.dart`:**
```dart
return logsAsync.when(
  loading: () => const SizedBox.shrink(),
  error: (_, __) => const SizedBox.shrink(),  // ← silently disappears
  data: (logs) { ... }
```
Error makes the overlay vanish. Acceptable for an overlay component, but worth noting.

**Error message quality: B+**  
Home screen: *"Couldn't load your tanks. Check your connection and give it another go!"* — good.  
Charts screen: *"We hit a snag loading your tank data. Give it another try!"* — good.  
The few remaining generic messages are in error states that are hit less often. No P0 here.

**`unawaited()` prewarm without error handling:**
```dart
unawaited(SpeciesDatabase.prewarm());
unawaited(PlantDatabase.prewarm());
```
If these throw, the error is silently swallowed. Low severity (it's a cache warm, not a write), but it's an inconsistency in a codebase that otherwise logs carefully.

**Smart providers swallow parse errors with logging — correct pattern.** These are fine.

**250 try-catch blocks : 20 log statements (12:1 ratio).** The architecture audit flagged this. It's real but lower risk than it sounds: most catch blocks return typed error values rather than logging, which is a valid pattern. The ones that should definitely log — storage failures, sync failures — do log. This is acceptable at current scale.

---

## 3. State Management Health

### Providers: Mostly Clean

**AI providers are now autoDispose.** The prior architecture audit found `aiHistoryProvider`, `anomalyHistoryProvider`, `weeklyPlanProvider` as non-autoDispose memory holders. Confirmed fixed — all three are `StateNotifierProvider.autoDispose`. Memory leak risk eliminated for the Smart tab.

**`connectivityProvider` is non-autoDispose StreamProvider** — intentional and correct for a global resource.

**`UserProfileNotifier`: 1,084 lines, unchanged.** The God object. It's functional. It's tested indirectly through model tests. But it is the single highest-risk file in the codebase: one breaking change here cascades to XP, streaks, lessons, gems, onboarding, daily goals simultaneously. The `REFACTORING_PLAN.md` exists but is unexecuted. For v1 launch: tolerate it. For ongoing maintenance: this is where bugs will cluster.

**ref.read in non-async home sheet contexts:**
```dart
// home_sheets_care.dart:17
// home_sheets_stats.dart:19  
// home_sheets_water.dart:17
void showFeedingInfo(BuildContext context, List<LogEntry> logs, String? tankId)
```
The functions accept `logs` as a parameter (already-watched value from the caller). The architecture audit flagged these as `ref.read` issues, but inspecting the actual code: the functions take `logs` as a *parameter*, not reading via ref internally. This is actually the **correct pattern** — caller passes the watched value. The stale data risk is at the call site, not in the function. Lower risk than originally reported.

**ref.watch without `.select()` — 148 broad watches:**  
Most are watching list providers (`tanksProvider`, `logsProvider(id)`) where you need the full list anyway. The genuinely concerning ones are:
- `notification_settings_screen.dart:16` — `ref.watch(userProfileProvider)` without `.select()`. Rebuilds on any profile change.
- `debug_menu_screen.dart:951` — same. (Debug only — lower concern.)

The 87 figure from the prior audit is now 148, but the context matters: the prior audit was counting all `ref.watch` without `.select()` across the codebase. A watch on `tanksProvider` returning a list where you need all tanks is not a bug — you need the full list. The actual performance problem is watching `userProfileProvider` (a large, frequently-mutating object) without selecting the specific field you care about.

**State consistency risks:**  
- `ShopService` holds a `ref` internally and calls `ref.read(gemBalanceProvider)` — acknowledged issue. Service has a tighter coupling to providers than ideal. Functional for v1, architecturally awkward.
- No circular dependencies detected.
- `SyncService` scaffolding: queues actions locally, never flushes to Supabase. The comment at line 1 of the file says so explicitly: *"SCAFFOLDING: Backend sync not yet implemented. Queued actions execute locally only."* This is honest. Just needs flagging: if you ever enable Supabase auth for users, their XP/gems will never sync without implementing `_flushQueue()`.

---

## 4. Fragility & Edge Case Assessment

### Empty States

- **No tanks:** `EmptyRoomScene` renders with a "Create Your First Tank" prompt. ✅ Handled.
- **No logs for a tank:** `valueOrNull ?? []` — results in empty list. Charts show "Charts unlock with your first test!" ✅ Handled.
- **No lessons completed:** Spaced repetition shows empty state. ✅ Appears handled.
- **No fish in tank:** Livestock screen shows empty state. ✅
- **Empty `EmptyRoomScene` fixed positioning:** Doesn't respect safe area insets on notched phones. P2 issue from prior audit — still unresolved.

### Long Text / Many Items

- **Fish names in 3-column grid with 13sp:** Still truncates on most phones. `fish_select_screen_test.dart` tests rendering — doesn't catch truncation.
- **No test for >50 tanks or >500 logs:** The `InMemoryStorageService` loads everything into memory. For heavy users (2+ years, multiple tanks, weekly tests), the JSON blob parse could be 10–20MB. No stress test exists.
- **Gems transaction list is capped (`_maxTransactions`)**. ✅ Memory-safe.
- **XP history trimmed to 365 days before save.** ✅

### Race Conditions

**`unawaited()` blocks in lesson completion:**
```dart
unawaited(() async {
  try {
    await achievementChecker.checkAfterLesson(...);
  } catch (e) {
    logError('Achievement check failed: $e', tag: 'LessonScreen');
  }
}());
```
This is deliberate non-blocking. The achievement check fires and the lesson completes regardless. If the achievement check fails, it logs and continues. **Correct pattern** — achievements are non-critical to lesson completion. Error is logged. Not a problem.

**`onLoadDemo` in HomeScreen:**
```dart
onLoadDemo: () async {
  ...
  if (!mounted) return;  // ← mounted check present
  ...
  if (context.mounted) _navigateToTankDetail(context, demoTank);
```
Mounted checks are present. ✅

**Lesson screen async operations:** 377 `context.mounted` usages found across the codebase. The lesson screen in particular has mounted checks at every async boundary. This is well-handled.

**`_persistLock.synchronized(...)` throughout `LocalJsonStorageService`:** All writes are mutex-protected. Concurrent writes from multiple providers are safe. ✅

### Null Safety

161 force-unwrap (`!.`) usages in non-test code. Most are legitimate:
- Model `Equipment.dueDate` logic: guards on `lastServiced != null` before the `!` via logical flow, but Dart can't infer it. Conceptually safe, syntactically risky.
- `Task.dueDate!` in `isToday` and `isDue` — called from code that checks `dueDate != null` first. Safe in practice.
- `spaced_repetition_provider.dart:496`: `state.currentSession!.cards.firstWhere(...)` — if `currentSession` is null when an answer is submitted, this will throw. The UI prevents submitting without an active session, but if state gets out of sync this could crash. **Medium risk.**

### Photo Path Integrity After App Data Clear

`LogEntry.photoUrls` stores absolute device paths. After clearing app data or restoring to a new device, those paths are broken. `LogDetailScreen` will silently show broken images — no "photo unavailable" placeholder. This is a P2 — frustrating but not crashing.

### Form Data Loss

Zero `RestorationMixin` usage. If the app is killed while:
- User is halfway through a 9-field water test in `AddLogScreen`
- User is midway through the multi-page `CreateTankScreen` wizard

All data is lost. The data resilience audit flagged this as **High**. It remains unaddressed. For v1 it's tolerable (most mobile apps don't auto-save forms), but it will generate angry 1-star reviews after the first "my app crashed and I lost my data" incident.

---

## 5. Critical Paths WITHOUT Coverage

| Path | Test Coverage | Risk | Impact if Broken |
|------|--------------|------|-----------------|
| Create tank → save → verify stored | ❌ None | 🔴 Critical | Core feature. Every user does this first. |
| Add water log → submit → verify stored | ❌ None | 🔴 Critical | Primary daily action. |
| Complete lesson → verify XP incremented and persisted | ❌ None | 🟠 High | Core engagement loop. |
| Livestock add dialog → validate → save | ❌ None | 🟠 High | Primary inventory action. |
| `onboarding_screen.dart` orchestrator flow | ❌ None (only sub-screens tested) | 🟠 High | Every new user. Broken = nobody completes setup. |
| Hearts deduction on wrong quiz answer | ❌ None | 🟠 High | Core paywall mechanic. |
| Integration tests (full app E2E) | ❌ Not in CI | 🟠 High | Known smoke tests exist but require manual device. |
| Return user flow (`returning_user_flows.dart`) | ❌ None | 🟡 Medium | Mis-fires onboarding on re-open after update. |
| Backup export → import round-trip | ❌ None | 🟡 Medium | Silent data loss on device transfer. |
| Settings persist after hot restart | ❌ None | 🟡 Medium | Top 1-star review trigger. |

---

## 6. Things That Are Actually Solid

**Infrastructure-level quality is high:**
- `LocalJsonStorageService`: atomic writes, `.bak`, `.corrupted` copies, entity-level recovery, mutex locking. This is production-grade storage for a local-first mobile app.
- Crashlytics + global error handlers + pre-Firebase buffer. Error telemetry is well-designed.
- `InMemoryStorageService` as a test double: cleanly injected via Riverpod overrides. The test infrastructure is correct.
- Consent/GDPR persistence: now tested end-to-end. `gdpr_analytics_consent` key is verified in SharedPreferences after both Accept and Decline paths.
- `TankHealthService` and `StockingCalculator` now have proper unit tests. The "fish welfare advice" critical path is covered.
- Data integrity tests (`fish_facts_test`, `lesson_data_test`, `species_unlock_map_test`) catch content regressions. Good.
- `mounted` checks after async operations: done consistently throughout. No obvious "use context after async gap without mounted check" crashes.
- `NavigationThrottle` preventing double-tap duplicate routes: smart defensive pattern.
- Model layer: all `@immutable` with `copyWith()`. Clean.
- Offline-first core: tank/fish/logs/tasks/lessons all work offline. The offline matrix is thorough and well-maintained.

---

## 7. Things That Look Solid But Aren't

### The Test Count

750 tests sounds like a well-tested app. It's not. It's a well-scaffolded app with a render-pass test on nearly every screen and genuine tests on about 20% of the code that matters. The number creates a false sense of security. A developer could merge a bug that breaks the Add Log save path, breaks the tank creation flow, or breaks the lesson XP chain, and **all 750 tests would still pass**.

### The `connectivityProvider` Offline Detection

`isOnlineProvider` defaults to `true` while loading. On startup, there's a window where the app assumes it's online before connectivity is confirmed. AI feature screens check `isOnlineProvider` before calling OpenAI — so on a brief true-offline startup, they'd attempt the call, get a network error, and show an error message. This is graceful recovery, not a crash. But the offline indicator may not be showing for a few seconds on a genuinely offline device. It looks like offline is handled; the edge is slightly rougher than it appears.

### The SyncService Queue

The app has `OfflineAwareService`, `SyncService`, and a sync queue UI. This looks like offline sync is implemented. **It isn't.** The queue exists. The flush-to-backend path is scaffolding. If a user goes offline, makes progress, comes back online, and you've enabled Supabase auth — their data will never sync to the cloud. The UI may even show "sync pending" while nothing actually uploads. This is clearly documented in the code (`// SCAFFOLDING: Backend sync not yet implemented`) but users can't read source comments.

### Error Messages Are Better Than Average But Still Have Gaps

The home screen and charts screen have good error messages. But the `valueOrNull ?? []` pattern in 7 locations means users hitting storage errors will see empty lists with no message at all — not "check your connection", just nothing. It looks like the data is gone. It's actually just an error that's been silently swallowed.

### The God Object Is Fine Until It Isn't

`UserProfileNotifier` at 1,084 lines is functional today. But it's the one file where a merge conflict is most likely, where a subtle streak/XP bug is most likely to hide, and where adding any new gamification feature risks unintended side effects. It has been called out in two separate audits now. It will stay fine until the day it isn't.

---

## 8. Recommended QA Finish Line

These are ordered by risk-to-ship, not effort.

### 🔴 Must-Have Before Submission to Play Store

**1. Three golden-path tests with real persistence verification**

These are the tests most likely to catch bugs that hurt real users:

```dart
// Test A: Tank creation persists
test('create tank → appears in provider after save', () async {
  final storage = InMemoryStorageService();
  await storage.saveTank(testTank);
  final tanks = await storage.loadTanks();
  expect(tanks.length, 1);
  expect(tanks.first.name, testTank.name);
});

// Test B: Water log submission persists  
// Simulate _savelog() path in AddLogScreen by calling storage.saveLog()
// and verifying via storage.getLogsForTank()

// Test C: Lesson complete → XP increments
// Use ProviderContainer with real UserProfileNotifier
// Call notifier.completeLesson(lessonId) 
// Assert state.totalXp increased by lesson.xpReward
```

These don't need UI tests — service/provider-level tests are sufficient and faster.

**2. Fix the `valueOrNull ?? []` silent failures on critical screens**

Replace in `home_screen.dart:353` and any screen where this represents primary content (not decorative overlays):

```dart
// Before: silent empty
final logs = ref.watch(logsProvider(currentTank.id)).valueOrNull ?? [];

// After: explicit error state
final logsAsync = ref.watch(logsProvider(currentTank.id));
if (logsAsync.hasError) return const AppErrorState.network();
final logs = logsAsync.valueOrNull ?? [];
```

This is a safety/trust issue. Users who see empty data think their fish data is gone.

### 🟠 Should-Have (Within Sprint)

**3. Wire integration tests to CI**

Add a GitHub Actions step or Firebase Test Lab run for `smoke_test_v2.dart`. Even one E2E test on a real device running before every merge to `main` is worth more than 100 more smoke widget tests.

**4. Livestock add dialog: at minimum a smoke test**

It's the primary inventory action. Currently has zero test coverage. A widget test that renders it without crashing is the minimum — a form validation test is better.

**5. Add `cost_tracker_*` keys to SharedPreferences backup whitelist**

This is a silent data loss bug. Users who back up and restore lose all their spending history. Fix is one line:  
`SharedPreferencesBackup._exportablePrefixes` → add `'cost_tracker'`.

**6. Add the `SCHEDULE_EXACT_ALARM` Play Console declaration**

Already documented in `docs/PLAY_CONSOLE_DECLARATIONS.md`. This is a Play Store requirement, not a code fix, but it blocks submission.

### 🟡 Should-Do (Next Release)

**7. Unit test `UserProfileNotifier.completeLesson()` state transition**

The one test that would catch the most bugs per line of test code written. Pass a lesson, assert XP delta, assert completedLessons set, assert streak update. Use `ProviderContainer` directly.

**8. Auto-save draft in `AddLogScreen`**

On every field change, save to `SharedPreferences` under `log_draft_<tankId>`. Offer to restore on screen open. This prevents the highest-frustration data loss scenario.

**9. Schema migration runner**

The on-disk version is written but never read back. Add `_migrateJson()` in `_loadFromDisk()` or the first breaking model change will silently produce nulls for existing users.

**10. `SpacedRepetitionProvider` null-guard on `currentSession!`**

`state.currentSession!.cards.firstWhere(...)` at line 496 will throw if `currentSession` is somehow null when an answer is submitted. Add a null guard before the force-unwrap.

---

## Summary Scorecard

| Area | Score | Change from Audit | Key Finding |
|------|-------|-------------------|-------------|
| Test quality (not quantity) | **6/10** | ↑ from 5/10 | Service tests added; critical path still untested |
| Error handling | **7/10** | → unchanged | Infrastructure solid; silent valueOrNull gap remains |
| State management | **7.5/10** | ↑ from 7/10 | AI providers now autoDispose; God object unchanged |
| Data resilience | **7/10** | → unchanged | cost_tracker backup gap; schema migration unimplemented |
| Fragility/edge cases | **7/10** | → unchanged | Mounted checks good; form data loss unaddressed |
| Runtime stability | **8/10** | ↑ | No crash patterns found; deprecated API count: 2 (withOpacity) |
| **Overall** | **7.2/10** | ↑ from ~6.8 | Meaningful improvement; specific gaps remain |

**This app will not crash on launch. It will not corrupt data for 99% of users. The core flows work. The architecture is respectable. The test suite has genuine coverage where it matters most (data integrity, service logic).**

**What it won't do: tell you when a critical path breaks silently. The gap between "750 tests all pass" and "I just broke the save flow" is real and it's the honest answer to "is this ready to ship?"**

Add the three golden-path persistence tests and fix the silent `valueOrNull` failures. Then it's ready.

---

*Did you test it? I mean REALLY test it?*  
*— Argus*
