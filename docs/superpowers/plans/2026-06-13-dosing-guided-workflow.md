# Dosing Guided Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the Dosing Calculator into a guided workflow that can carry a calculated liquid-product dose into the existing tank journal.

**Architecture:** Reuse `AddLogScreen` rather than writing logs directly from the calculator. Add a small `initialNotes` constructor hook to AddLog for observation/medication-style notes, then let `DosingCalculatorScreen` open AddLog as an observation with a dose summary. Workshop passes current tank volume and tank ID into Dosing when available.

**Tech Stack:** Flutter, Dart, Riverpod storage overrides in widget tests, existing `AddLogScreen`, existing `NavigationThrottle`.

---

### Task 1: AddLog Initial Notes

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/add_log_screen_test.dart`
- Modify: `apps/aquarium_app/lib/screens/add_log/add_log_screen.dart`

- [x] **Step 1: Write failing AddLog test**

Add a test that opens `AddLogScreen(tankId: tankId, initialType: LogType.observation, initialNotes: 'Dose note')`, verifies the notes field is prefilled, saves, and verifies the stored log is an observation with `notes == 'Dose note'`.

- [x] **Step 2: Run AddLog test red**

Run:

```powershell
flutter test test/widget_tests/add_log_screen_test.dart
```

Expected: fail because `AddLogScreen` has no `initialNotes` parameter.

- [x] **Step 3: Implement AddLog initial notes**

Add `final String? initialNotes;` to `AddLogScreen`.

When there is no `existingLog`, set `_notes = widget.initialNotes?.trim() ?? ''` before `_loadLastValues()`.

- [x] **Step 4: Run AddLog test green**

Run:

```powershell
flutter test test/widget_tests/add_log_screen_test.dart
```

Expected: pass.

### Task 2: Dosing Calculator Journal Handoff

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/dosing_calculator_screen_test.dart`
- Modify: `apps/aquarium_app/lib/screens/dosing_calculator_screen.dart`

- [x] **Step 1: Write failing Dosing test**

Add a test that opens `DosingCalculatorScreen(tankId: 'tank-1', tankVolumeLitres: 100)`, enters dose amount `2`, taps `Log this dosing note`, and verifies `AddLogScreen` opens with observation selected and a note containing `20.00 ml`.

- [x] **Step 2: Run Dosing test red**

Run:

```powershell
flutter test test/widget_tests/dosing_calculator_screen_test.dart
```

Expected: fail because the screen has no `tankId` or log handoff action.

- [x] **Step 3: Implement Dosing handoff**

Add optional `tankId` to `DosingCalculatorScreen`.

When `tankId` and `_totalDose` are available, show a guided card with:

- title: `Guided next step`
- body: `Save this dose as a tank journal note so you can see what was added later.`
- button: `Log this dosing note`

Button navigates to:

```dart
AddLogScreen(
  tankId: tankId,
  initialType: LogType.observation,
  initialNotes: _doseSummary,
)
```

where `_doseSummary` includes total dose, tank volume, and dose rate.

- [x] **Step 4: Run Dosing test green**

Run:

```powershell
flutter test test/widget_tests/dosing_calculator_screen_test.dart
```

Expected: pass.

### Task 3: Workshop Context

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/workshop_screen_test.dart`
- Modify: `apps/aquarium_app/lib/screens/workshop_screen.dart`

- [x] **Step 1: Write failing Workshop test**

Add a test that seeds one tank, taps `Dosing`, verifies the dosing volume field is prefilled with that tank volume, calculates a dose, and sees `Log this dosing note`.

- [x] **Step 2: Run Workshop test red**

Run:

```powershell
flutter test test/widget_tests/workshop_screen_test.dart
```

Expected: fail because Workshop opens `const DosingCalculatorScreen()` without tank context.

- [x] **Step 3: Implement Workshop Dosing handoff**

Add `_openDosingCalculator()` beside the other guided tool launchers:

- no tanks: standalone `const DosingCalculatorScreen()`
- one tank: `DosingCalculatorScreen(tankId: tank.id, tankVolumeLitres: tank.volumeLitres)`
- multiple tanks: picker, then pass selected tank ID and volume

Update the Dosing card `onTap`.

- [x] **Step 4: Run focused tests**

Run:

```powershell
flutter test test/widget_tests/add_log_screen_test.dart test/widget_tests/dosing_calculator_screen_test.dart test/widget_tests/workshop_screen_test.dart
```

Expected: pass.

### Task 4: Docs, Verification, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`

- [x] **Step 1: Update CL-P1-006 docs**

Record CL-P1-006C as Dosing guided workflow: tank-volume prefill, calculated dose explanation, and journal handoff.

- [x] **Step 2: Run verification**

Run:

```powershell
flutter analyze
flutter test
flutter test test/copy/current_docs_local_truth_test.dart
flutter build apk --debug --target lib/main.dart
git diff --check
```

Expected: analyzer clean, full suite passes with updated count, docs truth passes, debug APK builds with only the existing Kotlin Gradle Plugin warning, and diff check is clean.

- [x] **Step 3: Commit**

Stage only expected files and commit:

```powershell
git add apps/aquarium_app/lib/screens/add_log/add_log_screen.dart apps/aquarium_app/lib/screens/dosing_calculator_screen.dart apps/aquarium_app/lib/screens/workshop_screen.dart apps/aquarium_app/test/widget_tests/add_log_screen_test.dart apps/aquarium_app/test/widget_tests/dosing_calculator_screen_test.dart apps/aquarium_app/test/widget_tests/workshop_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md docs/superpowers/plans/2026-06-13-dosing-guided-workflow.md
git diff --cached --check
git commit -m "feat: add guided dosing workflow"
```

Expected: one scoped commit for CL-P1-006C.
