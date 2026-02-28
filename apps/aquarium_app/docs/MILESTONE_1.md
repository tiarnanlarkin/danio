# Milestone 1: Build Stability + Critical Fixes
Version: 1.0 | Date: 2026-02-28

## Acceptance Criteria
- [ ] `flutter analyze`: 0 errors (currently 55 — all in test files)
- [ ] `flutter test`: all tests pass (no red)
- [ ] 0 S0 issues open
- [ ] Clean install on physical device works
- [ ] No visible overflow on any onboarding screen
- [ ] Social/Smart features clearly labeled as demo/coming-soon

---

## Tasks

### T1: Fix test file — common_widgets_test.dart (52 errors)
**File:** `test/widgets/common/common_widgets_test.dart`
**Problem:** Widget APIs were refactored but tests not updated. Missing `emoji` parameter, removed `EmptyState`/`StandardInput`/`PrimaryButton` classes, renamed parameters (`label` → `title`, `badge` removed, `onBack` removed).
**Fix:** Rewrite all test cases to match current widget APIs in `lib/widgets/common/`. Read each widget's constructor and update tests accordingly.
**Acceptance:** `flutter analyze` reports 0 errors in this file.
**Est:** 2h

### T2: Fix test file — home_screen_test.dart (3 errors)
**File:** `test/screens/home_screen_test.dart`
**Problem:** Test mocks return `AsyncValue<List<Tank>>` but closure expects `FutureOr<List<Tank>>`. Riverpod provider override API mismatch.
**Fix:** Update mock overrides to return correct types. Likely needs `AsyncValue.data(tanks)` unwrapped or provider override pattern changed.
**Acceptance:** `flutter analyze` reports 0 errors in this file.
**Est:** 30min

### T3: Fix onboarding layout overflow
**File:** `lib/screens/onboarding/profile_creation_screen.dart`
**Problem:** Tank type cards (Freshwater/Marine) overflow bottom by 34–62 pixels on standard phone screens.
**Fix:** Either increase card height to 180+, reduce icon/text sizing, or wrap content in `Flexible`/`FittedBox`. Test on 360dp and 430dp widths.
**Acceptance:** No yellow/black overflow stripes visible on any onboarding screen.
**Est:** 30min

### T4: Fix Hearts refill edge cases
**File:** `lib/services/hearts_service.dart`
**Problem:** 2 tests fail on refill timing edge cases. Normal use works fine.
**Fix:** Review timer-based refill calculation. Check boundary conditions (midnight rollover, app backgrounded > refill period, max hearts cap).
**Acceptance:** `flutter test test/hearts_system_test.dart` — all pass.
**Est:** 1–2h

### T5: Add "Preview" labels to social screens
**Files:** `lib/screens/friends_screen.dart`, `lib/screens/leaderboard_screen.dart`, `lib/screens/activity_feed_screen.dart`, `lib/screens/friend_comparison_screen.dart`
**Problem:** These screens use mock data but present as if they're live features.
**Fix:** Add a banner/chip near the top: "🔮 Preview — social features coming soon". Use `AppColors.info` background.
**Acceptance:** Each social screen clearly communicates it's a preview.
**Est:** 1h

### T6: Add "Coming Soon" states to Smart features
**Files:** `lib/features/smart/fish_id/fish_id_screen.dart`, `lib/features/smart/symptom_triage/symptom_triage_screen.dart`, `lib/features/smart/weekly_plan/weekly_plan_screen.dart`
**Problem:** These require OpenAI API which isn't configured. May show error or empty state without context.
**Fix:** Add a polished "Coming Soon" state with illustration/icon, description of what the feature will do, and a "Notify me" button (or just informational).
**Acceptance:** Each Smart screen shows a clear, branded coming-soon state. No error messages or empty confusion.
**Est:** 1h

### T7: Remove development artifacts
**Files:** `lib/screens/count_withopacity.sh`, `lib/services/wave3_migration_service.dart.disabled`
**Problem:** Non-Dart files in lib/ that shouldn't be there.
**Fix:** Delete both files.
**Acceptance:** `find lib/ -not -name "*.dart" -type f` returns only expected non-Dart files (if any).
**Est:** 5min

### T8: Verify clean build
**Command:** `flutter clean && flutter pub get && flutter build apk --debug`
**Problem:** Need to confirm app builds cleanly after all fixes.
**Acceptance:** Build completes with 0 errors. APK generated.
**Est:** 10min (build time)

---

## Total Estimated Effort: 6–8 hours

## Dependencies
- T1 and T2 can be done in parallel
- T3, T4, T5, T6, T7 are all independent
- T8 must be last (verification)

## Out of Scope for M1
- Firebase integration (M2)
- On-device polish audit (M2)
- Test coverage improvements (M2)
- Store listing assets (M2)
- Dependency updates (M2)
- E2E integration tests (M3)
