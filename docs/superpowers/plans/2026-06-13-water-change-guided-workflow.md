# Water Change Guided Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the Water Change Calculator from a static calculation page into the first guided tool flow with explanation, safety guidance, and a prefilled log handoff.

**Architecture:** Reuse the existing AddLog water-change save path instead of creating a second log writer. Add optional constructor inputs to `AddLogScreen`, then let `WaterChangeCalculatorScreen` pass its calculated percentage into the log form when a tank ID is available.

**Tech Stack:** Flutter, Dart, Riverpod tests where storage is needed, existing `AddLogScreen`, existing local storage providers.

---

### Task 1: Prefilled Water-Change Log Handoff

**Files:**
- Modify: `apps/aquarium_app/lib/screens/add_log/add_log_screen.dart`
- Modify: `apps/aquarium_app/test/widget_tests/add_log_screen_test.dart`

- [x] **Step 1: Write failing AddLog tests**

Add a test that opens `AddLogScreen` with `initialType: LogType.waterChange` and `suggestedWaterChangePercent: 57`, then saves and verifies the saved log has `waterChangePercent == 57`.

- [x] **Step 2: Implement AddLog constructor support**

Add `final int? suggestedWaterChangePercent;` to `AddLogScreen`.

When there is no `existingLog`, `initialType == LogType.waterChange`, and the suggested percent is between 1 and 100, set `_waterChangePercent` before `_loadLastValues()`.

Update `_loadLastValues()` so a previous water-change log does not overwrite the suggested calculator value.

- [x] **Step 3: Run focused AddLog tests**

Run:

```powershell
flutter test test/widget_tests/add_log_screen_test.dart
```

Expected: AddLog tests pass.

### Task 2: Guided Calculator Action

**Files:**
- Modify: `apps/aquarium_app/lib/screens/water_change_calculator_screen.dart`
- Modify: `apps/aquarium_app/lib/screens/workshop_screen.dart`
- Modify: `apps/aquarium_app/test/widget_tests/water_change_calculator_screen_test.dart`

- [x] **Step 1: Write failing calculator tests**

Add tests that:
- Render `WaterChangeCalculatorScreen(tankId: 'tank-1')`.
- Verify a result includes a guided next-step section.
- Tap `Log this water change`.
- Confirm `AddLogScreen` opens with the calculated `57` percent prefilled.

- [x] **Step 2: Implement calculator handoff**

Add optional `tankId` and `initialTankVolumeLitres` constructor params.

Use `initialTankVolumeLitres` to prefill volume when supplied.

When `_changePercent` and `tankId` are available, show a guided action card with:
- a short confirmation explanation
- `Log this water change` button
- navigation to `AddLogScreen(tankId: tankId!, initialType: LogType.waterChange, suggestedWaterChangePercent: roundedPercent)`

Clean up existing mojibake in this touched file while preserving copy intent.

- [x] **Step 3: Wire Workshop**

In `WorkshopScreen`, open Water Change with current tank context:
- no tanks: open standalone calculator
- one tank: pass that tank ID and volume
- multiple tanks: ask user to choose a tank, then pass selected ID and volume

- [x] **Step 4: Run focused tests**

Run:

```powershell
flutter test test/widget_tests/water_change_calculator_screen_test.dart test/widget_tests/workshop_screen_test.dart test/widget_tests/add_log_screen_test.dart
```

Expected: focused guided-tool tests pass.

### Task 3: Docs, Verification, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`

- [x] **Step 1: Update CL-P1-006 docs**

Record CL-P1-006A as Water Change guided workflow: result explanation, safety guidance, and prefilled log confirmation handoff.

- [x] **Step 2: Full verification**

Run:

```powershell
flutter analyze
flutter test
flutter test test/copy/current_docs_local_truth_test.dart
flutter build apk --debug --target lib/main.dart
git diff --check
```

Expected: analyzer clean, full suite passes with the new count, docs truth passes, debug APK builds with only the existing Kotlin Gradle Plugin warning, and diff check is clean.

- [x] **Step 3: Commit**

Stage only expected files and commit:

```powershell
git add apps/aquarium_app/lib/screens/add_log/add_log_screen.dart apps/aquarium_app/lib/screens/water_change_calculator_screen.dart apps/aquarium_app/lib/screens/workshop_screen.dart apps/aquarium_app/test/widget_tests/add_log_screen_test.dart apps/aquarium_app/test/widget_tests/water_change_calculator_screen_test.dart apps/aquarium_app/test/widget_tests/workshop_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md docs/superpowers/plans/2026-06-13-water-change-guided-workflow.md
git diff --cached --check
git commit -m "feat: add guided water change workflow"
```

Expected: one scoped commit for CL-P1-006A.
