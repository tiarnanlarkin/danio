# Stocking Guided Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the Stocking Calculator into a guided workflow that can prefill tank volume and save a stocking check summary into the selected tank journal.

**Architecture:** Add optional `tankId` and `initialTankVolumeLitres` to `StockingCalculatorScreen`. Reuse the existing `AddLogScreen(initialNotes: ...)` observation handoff for stock-check summaries, and wire Workshop to pass the selected tank context using the existing chooser pattern.

**Tech Stack:** Flutter, Dart, Riverpod test overrides, existing `NavigationThrottle`, existing `AddLogScreen`, widget tests with `InMemoryStorageService`.

---

### Task 1: Stocking Journal Handoff

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/stocking_calculator_screen_test.dart`
- Modify: `apps/aquarium_app/lib/screens/stocking_calculator_screen.dart`

- [x] **Step 1: Write the failing Stocking test**

Add a test that opens `StockingCalculatorScreen(tankId: 'tank-1', initialTankVolumeLitres: 72, initialSpecies: Neon Tetra)`, verifies the tank-volume field is prefilled with `72`, taps `Log stocking check`, and verifies `AddLogScreen` opens with observation selected and a note containing `Stocking check`, `Tank volume: 72 L`, and `Neon Tetra x 6`.

- [x] **Step 2: Run Stocking test red**

Run:

```powershell
flutter test test/widget_tests/stocking_calculator_screen_test.dart
```

Expected: fail because the screen has no `tankId`, no volume prefill argument, and no journal handoff action.

- [x] **Step 3: Implement Stocking handoff**

Add optional `tankId` and `initialTankVolumeLitres` to `StockingCalculatorScreen`.

In `initState`, when `initialTankVolumeLitres` is present and greater than 0, set `_tankVolumeController.text` to a compact value such as `72` or `72.5`.

When `tankId` is present, `_stock` is not empty, and setup validation is clear, show a guided action below the stocking advice:

- title: `Guided next step`
- body: `Save this stocking check to the tank journal before you buy or move fish.`
- button: `Log stocking check`

Button navigates to:

```dart
AddLogScreen(
  tankId: tankId,
  initialType: LogType.observation,
  initialNotes: _stockingSummary,
)
```

where `_stockingSummary` includes tank volume, filter rating, plant state, stocking percent, stocking level, species counts, and a reminder that this is a planning estimate.

Clean mojibake in the touched Stocking file and tests using ASCII-safe labels/comments.

- [x] **Step 4: Run Stocking test green**

Run:

```powershell
flutter test test/widget_tests/stocking_calculator_screen_test.dart
```

Expected: pass.

### Task 2: Workshop Context

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/workshop_screen_test.dart`
- Modify: `apps/aquarium_app/lib/screens/workshop_screen.dart`

- [x] **Step 1: Write failing Workshop test**

Add a test that seeds one tank with volume `72`, taps `Stocking`, verifies `StockingCalculatorScreen` opens with the `72` tank-volume field, adds Neon Tetra, and sees `Log stocking check`.

- [x] **Step 2: Run Workshop test red**

Run:

```powershell
flutter test test/widget_tests/workshop_screen_test.dart
```

Expected: fail because Workshop opens `const StockingCalculatorScreen()` without tank context or volume prefill.

- [x] **Step 3: Implement Workshop Stocking handoff**

Add `_openStockingCalculator()` beside the other guided tool launchers:

- no tanks: standalone `const StockingCalculatorScreen()`
- one tank: `StockingCalculatorScreen(tankId: tank.id, initialTankVolumeLitres: tank.volumeLitres)`
- multiple tanks: picker, then pass selected tank ID and volume

Update the Stocking card `onTap`.

- [x] **Step 4: Run focused tests**

Run:

```powershell
flutter test test/widget_tests/stocking_calculator_screen_test.dart test/widget_tests/workshop_screen_test.dart
```

Expected: pass.

### Task 3: Docs, Verification, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`

- [x] **Step 1: Update CL-P1-006 docs**

Record CL-P1-006F as Stocking guided workflow: tank-volume prefill, stock-check summary, planning caveat, and journal handoff.

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
git add apps/aquarium_app/lib/screens/stocking_calculator_screen.dart apps/aquarium_app/lib/screens/workshop_screen.dart apps/aquarium_app/test/widget_tests/stocking_calculator_screen_test.dart apps/aquarium_app/test/widget_tests/workshop_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md docs/superpowers/plans/2026-06-13-stocking-guided-workflow.md
git diff --cached --check
git commit -m "feat: add guided stocking workflow"
```

Expected: one scoped commit for CL-P1-006F.
