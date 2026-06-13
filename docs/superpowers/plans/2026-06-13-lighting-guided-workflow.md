# Lighting Guided Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the Lighting Schedule tool into a guided workflow that can save the chosen schedule and recommendation into the selected tank journal.

**Architecture:** Reuse the existing `AddLogScreen(initialNotes: ...)` observation handoff used by Dosing and CO2. Add optional `tankId` to `LightingScheduleScreen`, show a guided journal action when tank context exists, and wire Workshop to pass tank context using the existing chooser pattern.

**Tech Stack:** Flutter, Dart, Riverpod test overrides, existing `NavigationThrottle`, existing `AddLogScreen`, widget tests with `InMemoryStorageService`.

---

### Task 1: Lighting Journal Handoff

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/lighting_schedule_screen_test.dart`
- Modify: `apps/aquarium_app/lib/screens/lighting_schedule_screen.dart`

- [x] **Step 1: Write the failing Lighting test**

Add a test that opens `LightingScheduleScreen(tankId: 'tank-1')`, scrolls to `Log this lighting schedule`, taps it, and verifies `AddLogScreen` opens with observation selected and a note containing `Lighting schedule`, `Lights on: 10:00 AM`, `Lights off: 8:00 PM`, and `Total light: 10 hours`.

- [x] **Step 2: Run Lighting test red**

Run:

```powershell
flutter test test/widget_tests/lighting_schedule_screen_test.dart
```

Expected: fail because the screen has no `tankId` constructor argument or journal handoff action.

- [x] **Step 3: Implement Lighting handoff**

Add optional `tankId` to `LightingScheduleScreen`.

When `tankId` is present, show a guided card after the Recommendation card with:

- title: `Guided next step`
- body: `Save this lighting plan to the tank journal so future algae, plant, and CO2 changes have context.`
- button: `Log this lighting schedule`

Button navigates to:

```dart
AddLogScreen(
  tankId: tankId,
  initialType: LogType.observation,
  initialNotes: _lightingSummary,
)
```

where `_lightingSummary` includes lights-on time, lights-off time, total light hours, whether siesta is enabled, plant/CO2/algae setup flags, and the current recommendation.

Clean mojibake in the touched Lighting file and tests using ASCII-safe comments and bullet markers.

- [x] **Step 4: Run Lighting test green**

Run:

```powershell
flutter test test/widget_tests/lighting_schedule_screen_test.dart
```

Expected: pass.

### Task 2: Workshop Context

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/workshop_screen_test.dart`
- Modify: `apps/aquarium_app/lib/screens/workshop_screen.dart`

- [x] **Step 1: Write failing Workshop test**

Add a test that seeds one tank, taps `Lighting`, verifies `LightingScheduleScreen` opens, and sees `Log this lighting schedule`.

- [x] **Step 2: Run Workshop test red**

Run:

```powershell
flutter test test/widget_tests/workshop_screen_test.dart
```

Expected: fail because Workshop opens `const LightingScheduleScreen()` without tank context.

- [x] **Step 3: Implement Workshop Lighting handoff**

Add `_openLightingSchedule()` beside the other guided tool launchers:

- no tanks: standalone `const LightingScheduleScreen()`
- one tank: `LightingScheduleScreen(tankId: tank.id)`
- multiple tanks: picker, then pass selected tank ID

Update the Lighting card `onTap`.

- [x] **Step 4: Run focused tests**

Run:

```powershell
flutter test test/widget_tests/lighting_schedule_screen_test.dart test/widget_tests/workshop_screen_test.dart
```

Expected: pass.

### Task 3: Docs, Verification, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`

- [x] **Step 1: Update CL-P1-006 docs**

Record CL-P1-006E as Lighting guided workflow: tank context, schedule summary, recommendation context, and journal handoff.

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
git add apps/aquarium_app/lib/screens/lighting_schedule_screen.dart apps/aquarium_app/lib/screens/workshop_screen.dart apps/aquarium_app/test/widget_tests/lighting_schedule_screen_test.dart apps/aquarium_app/test/widget_tests/workshop_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md docs/superpowers/plans/2026-06-13-lighting-guided-workflow.md
git diff --cached --check
git commit -m "feat: add guided lighting workflow"
```

Expected: one scoped commit for CL-P1-006E.
