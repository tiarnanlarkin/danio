# Tank Volume Guided Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the Tank Volume Calculator into a guided workflow that can apply a calculated volume back to the selected local tank profile.

**Architecture:** Keep the calculator as the calculation surface, but make it Riverpod-aware only when a `tankId` is provided. Workshop passes tank context into the calculator using the same no-tank, one-tank, multi-tank pattern established for Water Change. The calculator updates the existing `Tank` through `tankActionsProvider.updateTank(...)` and shows local feedback instead of writing around the existing storage layer.

**Tech Stack:** Flutter, Dart, Riverpod, existing `TankActions`, existing `AppFeedback`, widget tests with `InMemoryStorageService`.

---

### Task 1: Calculator Apply Action

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/tank_volume_calculator_screen_test.dart`
- Modify: `apps/aquarium_app/lib/screens/tank_volume_calculator_screen.dart`

- [x] **Step 1: Write the failing calculator test**

Add a test that seeds an in-memory tank with `volumeLitres: 40`, opens `TankVolumeCalculatorScreen(tankId: 'tank-1')`, enters rectangular dimensions `60`, `30`, `30`, taps `Apply to tank profile`, and verifies the stored tank now has `volumeLitres == 54.0`.

- [x] **Step 2: Run the focused test and confirm red**

Run:

```powershell
flutter test test/widget_tests/tank_volume_calculator_screen_test.dart
```

Expected: fail because `TankVolumeCalculatorScreen` does not accept `tankId` and does not show `Apply to tank profile`.

- [x] **Step 3: Implement the calculator apply action**

Convert `TankVolumeCalculatorScreen` to `ConsumerStatefulWidget`.

Add constructor fields:

```dart
final String? tankId;
const TankVolumeCalculatorScreen({super.key, this.tankId});
```

When `_volume` is present and `tankId` is non-null, show a guided card with:

- title: `Guided next step`
- body: `Apply this calculated volume to your tank profile so care tools use the same number.`
- button: `Apply to tank profile`

Button logic:

```dart
final tank = await ref.read(tankProvider(tankId).future);
await ref.read(tankActionsProvider).updateTank(tank.copyWith(volumeLitres: _volume!));
AppFeedback.showSuccess(context, 'Updated tank volume to ${_volume!.toStringAsFixed(1)} L.');
```

Guard null/missing tank and show `AppFeedback.showError(context, 'Could not update this tank volume.')`.

Clean mojibake in this touched file, replacing visible bullets with ASCII `-` and formula comments with ASCII-safe text.

- [x] **Step 4: Run focused calculator tests**

Run:

```powershell
flutter test test/widget_tests/tank_volume_calculator_screen_test.dart
```

Expected: pass.

### Task 2: Workshop Tank Context

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/workshop_screen_test.dart`
- Modify: `apps/aquarium_app/lib/screens/workshop_screen.dart`

- [x] **Step 1: Write the failing Workshop test**

Add a test that seeds one tank, taps `Tank Volume`, enters dimensions, taps `Apply to tank profile`, and verifies the tank volume updates.

- [x] **Step 2: Run the focused Workshop test and confirm red**

Run:

```powershell
flutter test test/widget_tests/workshop_screen_test.dart
```

Expected: fail because Workshop still opens `const TankVolumeCalculatorScreen()` without tank context.

- [x] **Step 3: Implement Workshop handoff**

Add `_openTankVolumeCalculator()` beside `_openWaterChangeCalculator()`:

- no tanks: open standalone `const TankVolumeCalculatorScreen()`
- one tank: open `TankVolumeCalculatorScreen(tankId: tank.id)`
- multiple tanks: show the existing simple tank picker and pass selected `tank.id`

Update the Tank Volume card `onTap` to call `_openTankVolumeCalculator`.

- [x] **Step 4: Run focused guided-tool tests**

Run:

```powershell
flutter test test/widget_tests/tank_volume_calculator_screen_test.dart test/widget_tests/workshop_screen_test.dart
```

Expected: pass.

### Task 3: Docs, Verification, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`

- [x] **Step 1: Update CL-P1-006 docs**

Record CL-P1-006B as Tank Volume guided workflow: calculate volume, apply to tank profile, local confirmation, and focused test coverage.

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
git add apps/aquarium_app/lib/screens/tank_volume_calculator_screen.dart apps/aquarium_app/lib/screens/workshop_screen.dart apps/aquarium_app/test/widget_tests/tank_volume_calculator_screen_test.dart apps/aquarium_app/test/widget_tests/workshop_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md docs/superpowers/plans/2026-06-13-tank-volume-guided-workflow.md
git diff --cached --check
git commit -m "feat: add guided tank volume workflow"
```

Expected: one scoped commit for CL-P1-006B.
