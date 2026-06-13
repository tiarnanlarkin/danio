# Living Tank Water State Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the central aquarium visually react to water-test care state without changing navigation or requiring AI.

**Architecture:** Add a small pure Dart service that maps latest water readings to a visual condition. Pass latest readings from `HomeScreen` through `LivingRoomScene` into `ThemedAquarium`, where a non-interactive overlay changes water mood while keeping the existing watercolor/illustrated tank style.

**Tech Stack:** Flutter, Riverpod providers already used by the Tank screen, existing `WaterTestResults`/`LogEntry` models, widget tests.

---

### Task 1: Add Water Visual State Rules

**Files:**
- Create: `apps/aquarium_app/lib/services/tank_visual_state_service.dart`
- Test: `apps/aquarium_app/test/services/tank_visual_state_service_test.dart`

- [x] **Step 1: Write the failing service tests**

Create `apps/aquarium_app/test/services/tank_visual_state_service_test.dart` with tests for:
- ammonia or nitrite above `0.25` maps to `unsafeWater`
- temperature `>= 30` maps to `tooWarm`
- temperature below `20` maps to `tooCold`
- nitrate `>= 40` maps to `staleWater`
- safe readings map to `clear`

- [x] **Step 2: Run the service test to verify RED**

Run:

```powershell
flutter test test/services/tank_visual_state_service_test.dart
```

Expected: FAIL because `tank_visual_state_service.dart` does not exist.

- [x] **Step 3: Implement the service**

Create:

```dart
import '../models/log_entry.dart';
import 'tank_care_priority_service.dart';

enum TankVisualCondition { clear, unsafeWater, tooWarm, tooCold, staleWater }

class TankVisualState {
  final TankVisualCondition condition;
  final String semanticsLabel;

  const TankVisualState({
    required this.condition,
    required this.semanticsLabel,
  });

  bool get hasOverlay => condition != TankVisualCondition.clear;
}

class TankVisualStateService {
  static const double warmWaterCelsius = 30;
  static const double coldWaterCelsius = 20;
  static const double staleNitratePpm = 40;

  const TankVisualStateService._();

  static TankVisualState fromWaterTest(WaterTestResults? results) {
    if (results == null || !results.hasValues) {
      return const TankVisualState(
        condition: TankVisualCondition.clear,
        semanticsLabel: 'Tank visual state: clear water',
      );
    }

    if ((results.ammonia ?? 0) >
            TankCarePriorityService.unsafeNitrogenThreshold ||
        (results.nitrite ?? 0) >
            TankCarePriorityService.unsafeNitrogenThreshold) {
      return const TankVisualState(
        condition: TankVisualCondition.unsafeWater,
        semanticsLabel: 'Tank visual state: unsafe water',
      );
    }

    final temperature = results.temperature;
    if (temperature != null && temperature >= warmWaterCelsius) {
      return const TankVisualState(
        condition: TankVisualCondition.tooWarm,
        semanticsLabel: 'Tank visual state: water too warm',
      );
    }
    if (temperature != null && temperature < coldWaterCelsius) {
      return const TankVisualState(
        condition: TankVisualCondition.tooCold,
        semanticsLabel: 'Tank visual state: water too cold',
      );
    }

    if ((results.nitrate ?? 0) >= staleNitratePpm) {
      return const TankVisualState(
        condition: TankVisualCondition.staleWater,
        semanticsLabel: 'Tank visual state: stale water',
      );
    }

    return const TankVisualState(
      condition: TankVisualCondition.clear,
      semanticsLabel: 'Tank visual state: clear water',
    );
  }
}
```

- [x] **Step 4: Run the service test to verify GREEN**

Run:

```powershell
flutter test test/services/tank_visual_state_service_test.dart
```

Expected: PASS.

### Task 2: Render Themed Aquarium Overlays

**Files:**
- Modify: `apps/aquarium_app/lib/widgets/room/themed_aquarium.dart`
- Test: `apps/aquarium_app/test/widgets/room/themed_aquarium_visual_state_test.dart`

- [x] **Step 1: Write the failing widget tests**

Create tests that pump `ThemedAquarium` with:
- safe readings and expect no `Key('tank-visual-overlay-clear')`
- ammonia `0.5` and expect `Key('tank-visual-overlay-unsafeWater')` plus semantics label `Tank visual state: unsafe water`
- temperature `31` and expect `Key('tank-visual-overlay-tooWarm')`
- nitrate `50` and expect `Key('tank-visual-overlay-staleWater')`

- [x] **Step 2: Run the widget test to verify RED**

Run:

```powershell
flutter test test/widgets/room/themed_aquarium_visual_state_test.dart
```

Expected: FAIL because `ThemedAquarium` does not expose visual-state inputs or overlays.

- [x] **Step 3: Implement the overlay**

Add optional `WaterTestResults? latestWaterTest` to `ThemedAquarium`, call `TankVisualStateService.fromWaterTest(latestWaterTest)`, and render `_TankVisualStateOverlay` above the base water/plants/fish but below the tank hood when `hasOverlay` is true.

The overlay must:
- use `IgnorePointer`
- expose a single semantics label from `TankVisualState.semanticsLabel`
- use `Key('tank-visual-overlay-${state.condition.name}')`
- use subtle translucent gradients, not visible text

- [x] **Step 4: Run the widget test to verify GREEN**

Run:

```powershell
flutter test test/widgets/room/themed_aquarium_visual_state_test.dart
```

Expected: PASS.

### Task 3: Wire Latest Tank Logs Into The Room Scene

**Files:**
- Modify: `apps/aquarium_app/lib/widgets/room/living_room_scene.dart`
- Modify: `apps/aquarium_app/lib/screens/home/home_screen.dart`
- Test: `apps/aquarium_app/test/widget_tests/home_screen_test.dart`

- [x] **Step 1: Write the failing HomeScreen widget test**

Add a test that saves an unsafe water-test log for a unique tank, pumps `HomeScreen`, and expects `Tank visual state: unsafe water` in the semantics tree.

- [x] **Step 2: Run the HomeScreen test to verify RED**

Run:

```powershell
flutter test test/widget_tests/home_screen_test.dart --plain-name "Tank aquarium reflects unsafe water logs visually"
```

Expected: FAIL because `HomeScreen` does not pass latest water readings into `LivingRoomScene`.

- [x] **Step 3: Implement log wiring**

In `HomeScreen`, derive the latest water-test log from `currentLogs` and pass its `waterTest` to `LivingRoomScene`.

In `LivingRoomScene`, add `WaterTestResults? latestWaterTest` and pass it to `ThemedAquarium`.

- [x] **Step 4: Run focused tests**

Run:

```powershell
flutter test test/services/tank_visual_state_service_test.dart test/widgets/room/themed_aquarium_visual_state_test.dart test/widget_tests/home_screen_test.dart --plain-name "Tank aquarium reflects unsafe water logs visually"
```

Expected: PASS.

### Task 4: Docs, Formatting, And Verification

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [x] **Step 1: Record CL-P1-001A progress**

Document that the central aquarium now shows local water-state visual cues for unsafe nitrogen, high nitrate/stale water, and temperature extremes.

- [x] **Step 2: Format and normalize line endings**

Run:

```powershell
dart format lib/services/tank_visual_state_service.dart lib/widgets/room/themed_aquarium.dart lib/widgets/room/living_room_scene.dart lib/screens/home/home_screen.dart test/services/tank_visual_state_service_test.dart test/widgets/room/themed_aquarium_visual_state_test.dart test/widget_tests/home_screen_test.dart
```

Normalize touched Dart files to LF.

- [x] **Step 3: Run final verification**

Run:

```powershell
flutter analyze
flutter test
flutter build apk --debug
git diff --check
```

Expected: analyzer clean, all tests pass, debug APK builds, whitespace check clean. The existing Kotlin Gradle Plugin future warning may remain.

- [x] **Step 4: Commit**

Run:

```powershell
git add apps/aquarium_app/lib/services/tank_visual_state_service.dart apps/aquarium_app/lib/widgets/room/themed_aquarium.dart apps/aquarium_app/lib/widgets/room/living_room_scene.dart apps/aquarium_app/lib/screens/home/home_screen.dart apps/aquarium_app/test/services/tank_visual_state_service_test.dart apps/aquarium_app/test/widgets/room/themed_aquarium_visual_state_test.dart apps/aquarium_app/test/widget_tests/home_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-living-tank-water-state.md
git commit -m "feat: show tank water state visually"
```

Expected: commit succeeds with only intended files.
