# Living Tank Water Change Age Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the tank water look stale when a logged water change is overdue, even if the latest test does not show high nitrate.

**Architecture:** Extend `TankVisualStateService` with a log-aware entry point that keeps unsafe readings highest priority, then temperature/high-nitrate, then old water-change age. Pass the resolved `TankVisualState` through `HomeScreen -> LivingRoomScene -> ThemedAquarium` while keeping the existing `latestWaterTest` fallback for direct widget use.

**Tech Stack:** Flutter, Riverpod, existing `LogEntry` model, widget tests.

---

### Task 1: Add Log-Aware Visual Rules

**Files:**
- Modify: `apps/aquarium_app/lib/services/tank_visual_state_service.dart`
- Modify: `apps/aquarium_app/test/services/tank_visual_state_service_test.dart`

- [x] **Step 1: Write failing service tests**

Add tests that verify:
- a water change older than 14 days maps to `staleWater`
- a recent water change with safe readings maps to `clear`
- unsafe nitrogen stays `unsafeWater` even when the water change is old

- [x] **Step 2: Run service tests for RED**

Run:

```powershell
flutter test test/services/tank_visual_state_service_test.dart
```

Expected: FAIL because `TankVisualStateService.fromLogs` does not exist.

- [x] **Step 3: Implement `fromLogs`**

Add:
- `static const int staleWaterChangeDays = 14`
- `static TankVisualState fromLogs(List<LogEntry> logs, {DateTime? now})`
- private latest water-test and latest water-change helpers

`fromLogs` should return `fromWaterTest(latestWaterTest)` when that result has an overlay, otherwise return stale water when the latest water change is older than 14 days, otherwise return clear.

- [x] **Step 4: Run service tests for GREEN**

Run:

```powershell
flutter test test/services/tank_visual_state_service_test.dart
```

Expected: PASS.

### Task 2: Pass Resolved Visual State Through The Room

**Files:**
- Modify: `apps/aquarium_app/lib/widgets/room/themed_aquarium.dart`
- Modify: `apps/aquarium_app/lib/widgets/room/living_room_scene.dart`
- Modify: `apps/aquarium_app/lib/screens/home/home_screen.dart`
- Modify: `apps/aquarium_app/test/widget_tests/home_screen_test.dart`

- [x] **Step 1: Write failing HomeScreen test**

Add a test that saves an old water-change log plus safe readings, pumps `HomeScreen`, and expects `Key('tank-visual-overlay-staleWater')`.

- [x] **Step 2: Run HomeScreen test for RED**

Run:

```powershell
flutter test test/widget_tests/home_screen_test.dart --plain-name "Tank aquarium reflects overdue water changes visually"
```

Expected: FAIL because HomeScreen currently passes only latest water-test readings.

- [x] **Step 3: Implement state wiring**

Add optional `TankVisualState? visualState` to `LivingRoomScene` and `ThemedAquarium`. In `ThemedAquarium`, render `visualState ?? TankVisualStateService.fromWaterTest(latestWaterTest)`. In `HomeScreen`, replace `_latestWaterTest(currentLogs)` with `TankVisualStateService.fromLogs(currentLogs)` and pass the result as `visualState`.

- [x] **Step 4: Run focused tests**

Run:

```powershell
flutter test test/services/tank_visual_state_service_test.dart test/widgets/room/themed_aquarium_visual_state_test.dart test/widget_tests/home_screen_test.dart
```

Expected: PASS.

### Task 3: Docs, Verification, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [x] **Step 1: Record CL-P1-001B progress**

Document that old water-change logs now affect living tank water visuals.

- [x] **Step 2: Format and normalize line endings**

Run:

```powershell
dart format lib/services/tank_visual_state_service.dart lib/widgets/room/themed_aquarium.dart lib/widgets/room/living_room_scene.dart lib/screens/home/home_screen.dart test/services/tank_visual_state_service_test.dart test/widget_tests/home_screen_test.dart
```

- [x] **Step 3: Verify**

Run:

```powershell
flutter analyze
flutter test
flutter build apk --debug
git diff --check
```

Expected: analyzer clean, all tests pass, APK builds, whitespace clean.

- [x] **Step 4: Commit**

Run:

```powershell
git add apps/aquarium_app/lib/services/tank_visual_state_service.dart apps/aquarium_app/lib/widgets/room/themed_aquarium.dart apps/aquarium_app/lib/widgets/room/living_room_scene.dart apps/aquarium_app/lib/screens/home/home_screen.dart apps/aquarium_app/test/services/tank_visual_state_service_test.dart apps/aquarium_app/test/widget_tests/home_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-living-tank-water-change-age.md
git commit -m "feat: show overdue water changes in tank"
```
