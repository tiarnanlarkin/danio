# Cycling Assistant Guided Actions Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn Cycling Assistant recommendations into direct user actions: log a water test and create a phase-aware cycling reminder task.

**Architecture:** Keep Cycling Assistant tank-scoped. Add a small guided-action widget below the existing action list, using `AddLogScreen` for water-test logging and the existing `StorageService.saveTask` path for reminder creation.

**Tech Stack:** Flutter, Riverpod, widget tests, existing Danio models/providers/widgets.

---

### Task 1: Add Failing Widget Tests

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/cycling_assistant_screen_test.dart`

- [ ] **Step 1: Add test imports**

Add:

```dart
import 'package:danio/screens/add_log_screen.dart';
import 'package:danio/services/storage_service.dart';
```

- [ ] **Step 2: Let the wrapper accept shared storage**

Change `_wrap` to accept `InMemoryStorageService? storage` and use it in `storageServiceProvider.overrideWithValue`.

- [ ] **Step 3: Write failing test for water-test handoff**

Add a widget test that opens `CyclingAssistantScreen`, scrolls to `Log water test`, taps it, and expects `AddLogScreen` plus the water-test form validation copy.

- [ ] **Step 4: Write failing test for cycling task creation**

Add a widget test that uses a phase-2 water test, taps `Create cycling reminder`, then asserts one task was saved for the tank with title `Test ammonia and nitrite` and `RecurrenceType.custom` every 2 days.

- [ ] **Step 5: Run focused tests and confirm RED**

Run:

```powershell
flutter test test/widget_tests/cycling_assistant_screen_test.dart
```

Expected: the new tests fail because the guided actions do not exist.

### Task 2: Implement Guided Actions

**Files:**
- Modify: `apps/aquarium_app/lib/screens/cycling_assistant_screen.dart`

- [ ] **Step 1: Add required imports**

Add imports for:

```dart
import 'package:uuid/uuid.dart';
import '../providers/storage_provider.dart';
import '../widgets/danio_snack_bar.dart';
import 'add_log_screen.dart';
```

- [ ] **Step 2: Render guided action widget**

Insert `_CycleGuidedActions(phase: phase, tankId: tank.id)` after `_ActionItems`.

- [ ] **Step 3: Implement water-test navigation**

`Log water test` should push `AddLogScreen(tankId: tankId, initialType: LogType.waterTest)`.

- [ ] **Step 4: Implement phase-aware task creation**

`Create cycling reminder` should save a task using current phase guidance:

```dart
phase2 -> title "Test ammonia and nitrite", recurrence custom, intervalDays 2
phase3 -> title "Confirm cycle is stable", recurrence custom, intervalDays 2
cycled -> title "Weekly water test", recurrence weekly
notStarted/phase1 -> title "Test cycling water", recurrence custom, intervalDays 3
```

- [ ] **Step 5: Invalidate task providers and show success feedback**

Invalidate `tasksProvider(tankId)` and show a concise success snackbar.

- [ ] **Step 6: Run focused tests and confirm GREEN**

Run:

```powershell
flutter test test/widget_tests/cycling_assistant_screen_test.dart
```

Expected: all Cycling Assistant tests pass.

### Task 3: Verify and Document

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`

- [ ] **Step 1: Update audit docs**

Record the guided Cycling Assistant handoff under CL-P1-006.

- [ ] **Step 2: Run verification**

Run:

```powershell
flutter analyze
flutter test
flutter test test/copy/current_docs_local_truth_test.dart
flutter build apk --debug --target lib/main.dart
git diff --check
```

Expected: analyzer clean, full tests pass, docs truth passes, debug APK builds, diff check clean.

- [ ] **Step 3: Run touched-file encoding scan**

Run:

```powershell
rg -n '[^\x00-\x7F]' apps/aquarium_app/lib/screens/cycling_assistant_screen.dart apps/aquarium_app/test/widget_tests/cycling_assistant_screen_test.dart docs/superpowers/plans/2026-06-13-cycling-assistant-guided-actions.md
```

Expected: only intentional existing Unicode if any; no mojibake.

- [ ] **Step 4: Commit**

```powershell
git add apps/aquarium_app/lib/screens/cycling_assistant_screen.dart apps/aquarium_app/test/widget_tests/cycling_assistant_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md docs/superpowers/plans/2026-06-13-cycling-assistant-guided-actions.md
git commit -m "feat: add guided cycling actions"
```
