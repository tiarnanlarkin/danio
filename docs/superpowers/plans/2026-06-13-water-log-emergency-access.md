# Water Log Emergency Access Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** When users save unsafe ammonia or nitrite readings, route them directly to emergency steps instead of treating the log like a normal successful save.

**Architecture:** Detect unsafe water-test values in `AddLogScreen` after the log is saved. Show a bottom action sheet with `Unsafe water logged`, explanation text, earned XP, and an `Emergency Guide` action routed through `NavigationThrottle` to the existing `EmergencyGuideScreen`.

**Tech Stack:** Flutter, Riverpod, existing `AddLogScreen`, `EmergencyGuideScreen`, `NavigationThrottle`, app bottom sheets, and widget tests.

---

## File Structure

- Modify `apps/aquarium_app/test/widget_tests/add_log_screen_test.dart`: add a widget test for unsafe water-test save behavior.
- Modify `apps/aquarium_app/lib/screens/add_log/add_log_screen.dart`: add unsafe water detection and emergency action sheet.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`: record CL-P0-006H progress and mark CL-P0-006 done.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`: mark CL-P0-006 done.

---

### Task 1: Unsafe Water Save Test

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/add_log_screen_test.dart`

- [x] **Step 1: Write failing widget test**

Add imports for `EmergencyGuideScreen` and `NavigationThrottle`, reset throttle in `setUp`, save a water test with ammonia `0.5`, expect `Unsafe water logged`, tap `Emergency Guide`, and verify `EmergencyGuideScreen` opens.

- [x] **Step 2: Run test to verify failure**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/add_log_screen_test.dart
```

Expected initial result: FAIL because unsafe water-test saves only use the generic save flow.

- [x] **Step 3: Write saved-state regression test**

Add a widget test that dismisses the unsafe-water sheet and verifies the saved form can close without showing the dirty-form discard prompt.

- [x] **Step 4: Run regression test to verify failure**

Run the new test by `--plain-name` and confirm it fails because the form still shows `Discard changes?`.

---

### Task 2: Unsafe Water Action Sheet

**Files:**
- Modify: `apps/aquarium_app/lib/screens/add_log/add_log_screen.dart`

- [x] **Step 1: Add imports**

Import `app_bottom_sheet.dart`, `navigation_throttle.dart`, and `emergency_guide_screen.dart`.

- [x] **Step 2: Detect unsafe water tests**

Add `_isUnsafeWaterTest` for ammonia or nitrite above `0.25 ppm`.

- [x] **Step 3: Add bottom sheet**

Add `_showUnsafeWaterEmergencySheet` with title `Unsafe water logged`, explanation text, earned XP, an `Emergency Guide` button, and a `Done` button.

- [x] **Step 4: Branch save flow**

After a successful unsafe water-test save, clear the loading state and show the emergency sheet. Normal logs continue to show the existing success message and pop.

- [x] **Step 5: Mark saved logs clean before sheet display**

Set `_discardConfirmed` once the unsafe water-test save succeeds so dismissing the emergency sheet does not leave the saved form in a dirty state.

---

### Task 3: Docs

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [x] **Step 1: Update product tracking**

Record `CL-P0-006H` and mark `CL-P0-006` done because all listed emergency-entry surfaces now route to Emergency Guide.

---

### Task 4: Verification And Commit

**Files:**
- All files touched in Tasks 1-3

- [x] **Step 1: Format changed Dart files**

Run:

```powershell
cd apps/aquarium_app
dart format lib/screens/add_log/add_log_screen.dart test/widget_tests/add_log_screen_test.dart
```

- [x] **Step 2: Run focused test**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/add_log_screen_test.dart
```

- [x] **Step 3: Run analyzer**

Run:

```powershell
cd apps/aquarium_app
flutter analyze
```

- [x] **Step 4: Check diff**

Run:

```powershell
git diff --check
git diff -- apps/aquarium_app/lib/screens/add_log/add_log_screen.dart apps/aquarium_app/test/widget_tests/add_log_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-water-log-emergency-access.md
```

- [x] **Step 5: Commit**

Run:

```powershell
git add apps/aquarium_app/lib/screens/add_log/add_log_screen.dart apps/aquarium_app/test/widget_tests/add_log_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-water-log-emergency-access.md
git commit -m "feat: route unsafe water logs to emergencies"
```
