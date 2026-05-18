# Whole App Map Remediation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Work through the whole-app QA map findings in small verified phases, with phone review and checkpoint commits after each phase.

**Architecture:** Keep product changes narrow and evidence-led. Fix the QA harness first, then user-facing copy/layout defects, then navigation consolidation, then calculator-level validation coverage.

**Tech Stack:** Flutter, Riverpod, Flutter widget tests, Flutter integration tests, ADB phone review on `SM F966B` / `RFCY8022D5R`.

---

## File Structure

- `apps/aquarium_app/docs/qa/whole-app-map-2026-05-18.md`: source QA dossier and running remediation notes.
- `apps/aquarium_app/integration_test/smoke_test_v2.dart`: phone smoke test gate to repair.
- `apps/aquarium_app/test/integration_smoke_contract_test.dart`: planned host-side contract test for smoke-test selectors and setup assumptions.
- `apps/aquarium_app/lib/screens/practice_hub_screen.dart`: Practice copy and state rules.
- `apps/aquarium_app/test/widget_tests/practice_hub_screen_test.dart`: Practice state regression tests.
- `apps/aquarium_app/lib/screens/settings/widgets/tools_section.dart`: duplicated Preferences tool hub.
- `apps/aquarium_app/lib/screens/settings/settings_screen.dart`: Preferences structure and section labels.
- `apps/aquarium_app/lib/screens/settings_hub_screen.dart`: More hub structure.
- `apps/aquarium_app/lib/screens/workshop_screen.dart`: primary calculators hub.
- `apps/aquarium_app/test/widget_tests/settings_hub_screen_test.dart`, `apps/aquarium_app/test/widget_tests/workshop_screen_test.dart`, `apps/aquarium_app/test/widget_tests/notification_settings_screen_test.dart`: navigation and structure checks.
- Calculator widget tests under `apps/aquarium_app/test/widget_tests/*calculator*_test.dart`: input validation coverage.

---

### Task 0: Commit Completed Post-Map P1 Fixes

**Files:**
- Modify: `apps/aquarium_app/lib/widgets/room/themed_aquarium.dart`
- Modify: `apps/aquarium_app/lib/screens/workshop_screen.dart`
- Modify: `apps/aquarium_app/test/widget_tests/workshop_screen_test.dart`
- Create: `apps/aquarium_app/test/widgets/room/living_room_scene_tap_test.dart`
- Create/update: `apps/aquarium_app/docs/qa/whole-app-map-2026-05-18.md`
- Create/update: `apps/aquarium_app/docs/qa/screenshots/whole-app-map-2026-05-18/`

- [x] **Step 1: Verify automated checks**

Run:

```powershell
cd "C:\Users\larki\Documents\Danio Aquarium App Project\repo\apps\aquarium_app"
flutter analyze --no-pub
flutter test
flutter build apk --debug --target lib/main.dart
```

Expected: analyze reports no issues, test reports 1073 passing tests, debug APK builds.

- [x] **Step 2: Verify phone behavior**

Run:

```powershell
$adb = "C:\Users\larki\AppData\Local\Android\sdk\platform-tools\adb.exe"
& $adb -s RFCY8022D5R install -r build\app\outputs\flutter-apk\app-debug.apk
& $adb -s RFCY8022D5R shell am start -W -n com.tiarnanlarkin.danio/.MainActivity
```

Expected: app launches; aquarium tap opens Tank detail; Workshop top and lower views show no overflow stripes; logcat has no app crash signatures.

- [x] **Step 3: Commit checkpoint**

Run:

```powershell
cd "C:\Users\larki\Documents\Danio Aquarium App Project\repo"
git add apps/aquarium_app/lib/widgets/room/themed_aquarium.dart apps/aquarium_app/lib/screens/workshop_screen.dart apps/aquarium_app/test/widget_tests/workshop_screen_test.dart apps/aquarium_app/test/widgets/room/living_room_scene_tap_test.dart apps/aquarium_app/docs/qa/whole-app-map-2026-05-18.md apps/aquarium_app/docs/qa/screenshots/whole-app-map-2026-05-18
git commit -m "fix: resolve whole-app map P1 UI blockers"
```

---

### Task 1: Repair Phone Smoke Test Gate

**Files:**
- Modify: `apps/aquarium_app/integration_test/smoke_test_v2.dart`
- Create: `apps/aquarium_app/test/integration_smoke_contract_test.dart`
- Update: `apps/aquarium_app/docs/qa/whole-app-map-2026-05-18.md`

- [x] **Step 1: Write a host-side contract test for smoke selectors**

Create `apps/aquarium_app/test/integration_smoke_contract_test.dart` with checks that the bottom dock key and tab keys used by `smoke_test_v2.dart` match the production keys in `TabNavigator`.

- [x] **Step 2: Run the new test and confirm it fails if selectors are stale**

Run:

```powershell
cd "C:\Users\larki\Documents\Danio Aquarium App Project\repo\apps\aquarium_app"
flutter test test/integration_smoke_contract_test.dart
```

Expected before fixing if selectors/setup are stale: failure identifying the mismatch or missing contract.

- [x] **Step 3: Update the integration smoke launch flow**

Keep `app.main()` but replace fixed sleeps with a condition wait that accepts either onboarding or main shell. The smoke test should not hang waiting for `pumpAndSettle` on ongoing animations.

- [x] **Step 4: Run focused and phone verification**

Run:

```powershell
flutter test test/integration_smoke_contract_test.dart
flutter test integration_test/smoke_test_v2.dart -d RFCY8022D5R
```

Expected: both commands complete without hanging.

- [x] **Step 5: Commit checkpoint**

Run:

```powershell
git add lib/main.dart integration_test/smoke_test_v2.dart integration_test/smoke_test_harness.dart test/integration_smoke_contract_test.dart docs/qa/whole-app-map-2026-05-18.md ..\..\docs\superpowers\plans\2026-05-18-whole-app-map-remediation.md
git commit -m "test: repair phone smoke qa gate"
```

---

### Task 2: Clarify Practice Empty/Due/Weak States

**Files:**
- Modify: `apps/aquarium_app/lib/screens/practice_hub_screen.dart`
- Modify: `apps/aquarium_app/test/widget_tests/practice_hub_screen_test.dart`
- Update: `apps/aquarium_app/docs/qa/whole-app-map-2026-05-18.md`

- [x] **Step 1: Add failing Practice state tests**

Add tests for:
- `dueCards == 0`, `totalCards > 0`, `weakCards > 0`: text says weak spots are available, not only `All caught up`.
- `dueCards == 0`, `totalCards > 0`, `weakCards == 0`: all-caught-up copy remains valid.
- `totalCards == 0`: Learn-to-Practice empty deck copy remains valid.

- [x] **Step 2: Run the focused Practice test**

Run:

```powershell
flutter test test/widget_tests/practice_hub_screen_test.dart
```

Expected before implementation: the weak-spots copy test fails.

- [x] **Step 3: Implement the copy rule**

In `practice_hub_screen.dart`, branch the no-due card copy by weak-card availability.

- [x] **Step 4: Verify and phone review**

Run:

```powershell
flutter test test/widget_tests/practice_hub_screen_test.dart
flutter analyze --no-pub
```

Phone review: open Practice with seeded QA review cards and capture screenshots for no-due/weak-available state.

- [x] **Step 5: Commit checkpoint**

Run:

```powershell
git add lib/screens/practice_hub_screen.dart test/widget_tests/practice_hub_screen_test.dart docs/qa/whole-app-map-2026-05-18.md docs/qa/screenshots/whole-app-map-2026-05-18
git commit -m "fix: clarify practice review states"
```

---

### Task 3: Consolidate Tool Hub Responsibilities

**Files:**
- Modify: `apps/aquarium_app/lib/screens/settings/widgets/tools_section.dart`
- Modify: `apps/aquarium_app/lib/screens/settings/settings_screen.dart`
- Modify: `apps/aquarium_app/lib/screens/settings_hub_screen.dart`
- Modify: `apps/aquarium_app/test/widget_tests/settings_hub_screen_test.dart`
- Modify: `apps/aquarium_app/test/widget_tests/workshop_screen_test.dart`
- Update: `apps/aquarium_app/docs/qa/whole-app-map-2026-05-18.md`

- [x] **Step 1: Add structure tests for primary destinations**

Tests should assert:
- Workshop remains the primary calculators hub.
- More exposes Workshop, Analytics, Shop Street, Gem Shop, Achievements, Preferences.
- Preferences no longer presents a second full calculator hub; it may show settings, notifications, backup/data, legal, and account.

- [x] **Step 2: Run structure tests and confirm current duplication fails**

Run:

```powershell
flutter test test/widget_tests/settings_hub_screen_test.dart test/widget_tests/workshop_screen_test.dart
```

Expected before implementation: Preferences duplication assertion fails.

- [x] **Step 3: Demote Preferences tools to settings-context shortcuts**

Remove or relabel calculator duplicates in `ToolsSection`. Keep notification/reminder settings in Preferences. Keep Workshop and contextual Tank shortcuts as entry points to tools.

- [x] **Step 4: Verify and phone review**

Run:

```powershell
flutter test test/widget_tests/settings_hub_screen_test.dart test/widget_tests/workshop_screen_test.dart
flutter analyze --no-pub
flutter test
```

Phone review: More -> Workshop, More -> Preferences, and Preferences lower sections.

- [x] **Step 5: Commit checkpoint**

Run:

```powershell
git add lib/screens/settings/widgets/tools_section.dart lib/screens/settings/settings_screen.dart lib/screens/settings_hub_screen.dart test/widget_tests/settings_hub_screen_test.dart test/widget_tests/workshop_screen_test.dart docs/qa/whole-app-map-2026-05-18.md docs/qa/screenshots/whole-app-map-2026-05-18
git commit -m "refactor: consolidate tool hub navigation"
```

---

### Task 4: Calculator Input Validation Pass

**Files:**
- Modify calculator screens under `apps/aquarium_app/lib/screens/*calculator*_screen.dart`
- Modify calculator tests under `apps/aquarium_app/test/widget_tests/*calculator*_test.dart`
- Update: `apps/aquarium_app/docs/qa/whole-app-map-2026-05-18.md`

- [ ] **Step 1: Add one valid and one invalid/empty input test per calculator**

Cover Water Change, Stocking, CO2, Dosing, Unit Converter, Tank Volume, Lighting, Compatibility, Cycling Assistant, and Cost Tracker where each screen has inputs.

- [ ] **Step 2: Run focused calculator tests**

Run:

```powershell
flutter test test/widget_tests/water_change_calculator_screen_test.dart test/widget_tests/stocking_calculator_screen_test.dart test/widget_tests/co2_calculator_test.dart test/widget_tests/dosing_calculator_screen_test.dart test/widget_tests/unit_converter_screen_test.dart test/widget_tests/tank_volume_calculator_screen_test.dart test/widget_tests/lighting_schedule_screen_test.dart test/widget_tests/compatibility_checker_test.dart test/widget_tests/cycling_assistant_screen_test.dart test/widget_tests/cost_tracker_test.dart
```

Expected before implementation: missing validation tests fail where behavior is unclear or absent.

- [ ] **Step 3: Implement minimal validation and feedback fixes**

Use existing app snackbar/dialog/input-error patterns. Do not redesign calculator screens in this pass.

- [ ] **Step 4: Verify and phone review**

Run:

```powershell
flutter analyze --no-pub
flutter test
flutter build apk --debug --target lib/main.dart
```

Phone review: one valid and one invalid input on each calculator.

- [ ] **Step 5: Commit checkpoint**

Run:

```powershell
git add lib/screens test/widget_tests docs/qa/whole-app-map-2026-05-18.md docs/qa/screenshots/whole-app-map-2026-05-18
git commit -m "test: cover calculator validation flows"
```

---

## Final Release Gate

- [ ] Run:

```powershell
cd "C:\Users\larki\Documents\Danio Aquarium App Project\repo\apps\aquarium_app"
flutter analyze --no-pub
flutter test
flutter test integration_test/smoke_test_v2.dart -d RFCY8022D5R
flutter build apk --debug --target-platform android-arm64
```

- [ ] Install final APK on `RFCY8022D5R`.
- [ ] Run a 20-30 minute phone pass across Learn, Practice, Tank, Smart, More, Workshop, and Preferences.
- [ ] Update the QA dossier with final screenshots, pass/fail notes, and remaining triage.
- [ ] Commit final QA update.

---

## Self-Review

- Spec coverage: covers current map findings and the user-requested autonomous phase gates.
- Placeholder scan: no `TBD`, `TODO`, or intentionally vague test commands.
- Type consistency: file paths and command paths match the current repository layout.
