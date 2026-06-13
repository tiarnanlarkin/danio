# CO2 Guided Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the CO2 Calculator into a guided workflow that can save a calculated CO2 reading and safety status into the tank journal.

**Architecture:** Reuse the existing `AddLogScreen(initialNotes: ...)` observation handoff created for Dosing. Add optional `tankId` to `Co2CalculatorScreen`, show a guided journal action when there is a valid reading and tank context, and wire Workshop to pass tank context using the existing chooser pattern.

**Tech Stack:** Flutter, Dart, existing `NavigationThrottle`, existing `AddLogScreen`, widget tests with `InMemoryStorageService`.

---

### Task 1: CO2 Calculator Journal Handoff

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/co2_calculator_test.dart`
- Modify: `apps/aquarium_app/lib/screens/co2_calculator_screen.dart`

- [x] **Step 1: Write failing CO2 test**

Add a test that opens `Co2CalculatorScreen(tankId: 'tank-1')`, taps `Log this CO2 note`, and verifies `AddLogScreen` opens with observation selected and a note containing `12.0 ppm`.

- [x] **Step 2: Run CO2 test red**

Run:

```powershell
flutter test test/widget_tests/co2_calculator_test.dart
```

Expected: fail because the screen has no `tankId` or log handoff action.

- [x] **Step 3: Implement CO2 handoff**

Add optional `tankId` to `Co2CalculatorScreen`.

When `tankId` and `_co2Level` are available, show a guided card with:

- title: `Guided next step`
- body: `Save this CO2 estimate as a tank journal note so later plant and fish observations have context.`
- button: `Log this CO2 note`

Button navigates to:

```dart
AddLogScreen(
  tankId: tankId,
  initialType: LogType.observation,
  initialNotes: _co2Summary,
)
```

where `_co2Summary` includes CO2 ppm, status, pH, KH, and a reminder that this is an estimate.

Clean mojibake in this touched file and use ASCII-safe hint text/comments.

- [x] **Step 4: Run CO2 test green**

Run:

```powershell
flutter test test/widget_tests/co2_calculator_test.dart
```

Expected: pass.

### Task 2: Workshop Context

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/workshop_screen_test.dart`
- Modify: `apps/aquarium_app/lib/screens/workshop_screen.dart`

- [x] **Step 1: Write failing Workshop test**

Add a test that seeds one tank, taps `CO2 Calculator`, verifies `Co2CalculatorScreen` opens, and sees `Log this CO2 note`.

- [x] **Step 2: Run Workshop test red**

Run:

```powershell
flutter test test/widget_tests/workshop_screen_test.dart
```

Expected: fail because Workshop opens `const Co2CalculatorScreen()` without tank context.

- [x] **Step 3: Implement Workshop CO2 handoff**

Add `_openCo2Calculator()` beside the other guided tool launchers:

- no tanks: standalone `const Co2CalculatorScreen()`
- one tank: `Co2CalculatorScreen(tankId: tank.id)`
- multiple tanks: picker, then pass selected tank ID

Update the CO2 card `onTap`.

- [x] **Step 4: Run focused tests**

Run:

```powershell
flutter test test/widget_tests/co2_calculator_test.dart test/widget_tests/workshop_screen_test.dart
```

Expected: pass.

### Task 3: Docs, Verification, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`

- [x] **Step 1: Update CL-P1-006 docs**

Record CL-P1-006D as CO2 guided workflow: tank context, calculated estimate explanation, and journal handoff.

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
git add apps/aquarium_app/lib/screens/co2_calculator_screen.dart apps/aquarium_app/lib/screens/workshop_screen.dart apps/aquarium_app/test/widget_tests/co2_calculator_test.dart apps/aquarium_app/test/widget_tests/workshop_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md docs/superpowers/plans/2026-06-13-co2-guided-workflow.md
git diff --cached --check
git commit -m "feat: add guided co2 workflow"
```

Expected: one scoped commit for CL-P1-006D.
