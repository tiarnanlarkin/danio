# Living Tank Aquascape Cues Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let the central aquarium show extra plant/decor accents when existing tank records imply a planted or hardscaped setup.

**Architecture:** Add a focused service that classifies existing per-tank `Equipment` records into planted/decorated aquascape visual states. HomeScreen watches the current tank equipment, passes the state through `LivingRoomScene` to `ThemedAquarium`, and the aquarium renders a non-interactive bottom accent layer. This is deliberately a cue, not a fake full plant inventory model.

**Tech Stack:** Flutter, Riverpod, existing `equipmentProvider`, existing `Equipment` model.

---

### Task 1: Add Aquascape Visual State Service

**Files:**
- Create: `apps/aquarium_app/lib/services/tank_aquascape_visual_service.dart`
- Test: `apps/aquarium_app/test/services/tank_aquascape_visual_service_test.dart`

- [ ] **Step 1: Write failing service tests**

Create tests for:

```dart
test('empty equipment returns clear', () {
  final state = TankAquascapeVisualService.fromEquipment(const []);
  expect(state.condition, TankAquascapeVisualCondition.clear);
  expect(state.hasOverlay, isFalse);
});

test('co2 system returns planted cue', () {
  final state = TankAquascapeVisualService.fromEquipment([
    _equipment(type: EquipmentType.co2System, name: 'CO2 Kit'),
  ]);
  expect(state.condition, TankAquascapeVisualCondition.planted);
});

test('hardscape named equipment returns decorated cue', () {
  final state = TankAquascapeVisualService.fromEquipment([
    _equipment(type: EquipmentType.other, name: 'Spiderwood hardscape'),
  ]);
  expect(state.condition, TankAquascapeVisualCondition.decorated);
});

test('plant and hardscape equipment returns planted decorated cue', () {
  final state = TankAquascapeVisualService.fromEquipment([
    _equipment(type: EquipmentType.co2System, name: 'CO2 Kit'),
    _equipment(type: EquipmentType.other, name: 'Seiryu stone decor'),
  ]);
  expect(state.condition, TankAquascapeVisualCondition.plantedDecorated);
});
```

- [ ] **Step 2: Run service test for RED**

Run:

```powershell
flutter test test/services/tank_aquascape_visual_service_test.dart
```

Expected: compile failure because the service does not exist.

- [ ] **Step 3: Implement service**

Create:

```dart
enum TankAquascapeVisualCondition { clear, planted, decorated, plantedDecorated }

class TankAquascapeVisualState {
  final TankAquascapeVisualCondition condition;
  final String semanticsLabel;

  const TankAquascapeVisualState({
    required this.condition,
    required this.semanticsLabel,
  });

  bool get hasOverlay => condition != TankAquascapeVisualCondition.clear;
}
```

`TankAquascapeVisualService.fromEquipment(List<Equipment> equipment)` should:

- Treat `EquipmentType.co2System` as a planted cue.
- Treat `EquipmentType.light` as planted only when its name/notes/settings text mentions plant, planted, aquascape, moss, fern, stem, carpet, or co2.
- Treat `EquipmentType.other` as planted when its name/notes/settings mention plant terms.
- Treat any equipment text as decorated when it mentions decor, decoration, hardscape, driftwood, wood, rock, stone, cave, ornament, or root.
- Return `plantedDecorated` when both groups are present.
- Return clear otherwise.

- [ ] **Step 4: Run service tests for GREEN**

Run:

```powershell
flutter test test/services/tank_aquascape_visual_service_test.dart
```

### Task 2: Render Aquascape Accent Layer

**Files:**
- Modify: `apps/aquarium_app/lib/widgets/room/themed_aquarium.dart`
- Modify: `apps/aquarium_app/lib/widgets/room/living_room_scene.dart`
- Modify: `apps/aquarium_app/test/widgets/room/themed_aquarium_visual_state_test.dart`

- [ ] **Step 1: Write failing aquarium widget test**

Add a test that pumps:

```dart
aquascapeVisualState: const TankAquascapeVisualState(
  condition: TankAquascapeVisualCondition.plantedDecorated,
  semanticsLabel: 'Tank aquascape visual state: planted and decorated',
)
```

Expect:

```dart
find.byKey(const Key('tank-aquascape-overlay-plantedDecorated'))
find.bySemanticsLabel('Tank aquascape visual state: planted and decorated')
```

- [ ] **Step 2: Run widget test for RED**

Run:

```powershell
flutter test test/widgets/room/themed_aquarium_visual_state_test.dart --plain-name "shows aquascape cue when provided"
```

- [ ] **Step 3: Implement overlay propagation**

Add `TankAquascapeVisualState? aquascapeVisualState` to `ThemedAquarium` and `LivingRoomScene`.

In `ThemedAquarium`, render after the base plant widgets and before the fish layer:

```dart
if (aquascapeVisualState != null && aquascapeVisualState!.hasOverlay)
  Positioned.fill(child: _TankAquascapeVisualOverlay(aquascapeVisualState!)),
```

Create `_TankAquascapeVisualOverlay`:

- Wrap with `Semantics(label: state.semanticsLabel, excludeSemantics: true)`.
- Wrap with `IgnorePointer`.
- Key the paint layer as `tank-aquascape-overlay-${state.condition.name}`.
- Use `CustomPaint` to draw extra bottom plant blades for planted/plantedDecorated and soft stones/wood shapes for decorated/plantedDecorated.
- Do not add visible text.

- [ ] **Step 4: Run widget test for GREEN**

Run:

```powershell
flutter test test/widgets/room/themed_aquarium_visual_state_test.dart
```

### Task 3: Wire HomeScreen Equipment Cue

**Files:**
- Modify: `apps/aquarium_app/lib/screens/home/home_screen.dart`
- Modify: `apps/aquarium_app/test/widget_tests/home_screen_test.dart`

- [ ] **Step 1: Write failing HomeScreen test**

Save a CO2 system and a hardscape/decor `EquipmentType.other` item for the current tank, pump HomeScreen, and expect:

```dart
expect(
  find.byKey(const Key('tank-aquascape-overlay-plantedDecorated')),
  findsOneWidget,
);
```

- [ ] **Step 2: Run test for RED**

Run:

```powershell
flutter test test/widget_tests/home_screen_test.dart --plain-name "Tank aquarium reflects aquascape equipment visually"
```

- [ ] **Step 3: Implement HomeScreen wiring**

Import `tank_aquascape_visual_service.dart`.

In `_buildLivingRoomScreen`, after current livestock:

```dart
final currentEquipment =
    ref.watch(equipmentProvider(currentTank.id)).valueOrNull ?? [];
final aquascapeVisualState =
    TankAquascapeVisualService.fromEquipment(currentEquipment);
```

Pass `aquascapeVisualState: aquascapeVisualState` to `LivingRoomScene`.

- [ ] **Step 4: Run focused tests for GREEN**

Run:

```powershell
flutter test test/services/tank_aquascape_visual_service_test.dart test/widgets/room/themed_aquarium_visual_state_test.dart test/widget_tests/home_screen_test.dart
```

### Task 4: Docs, Verification, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [ ] **Step 1: Record CL-P1-001E progress**

Document aquascape cues from existing tank equipment records and keep the caveat that a full plant/decor inventory model is still future depth if needed.

- [ ] **Step 2: Format and verify**

Run:

```powershell
dart format lib/services/tank_aquascape_visual_service.dart lib/widgets/room/themed_aquarium.dart lib/widgets/room/living_room_scene.dart lib/screens/home/home_screen.dart test/services/tank_aquascape_visual_service_test.dart test/widgets/room/themed_aquarium_visual_state_test.dart test/widget_tests/home_screen_test.dart
flutter analyze
flutter test
flutter build apk --debug
git diff --check
```

- [ ] **Step 3: Commit**

Run:

```powershell
git add apps/aquarium_app/lib/services/tank_aquascape_visual_service.dart apps/aquarium_app/lib/widgets/room/themed_aquarium.dart apps/aquarium_app/lib/widgets/room/living_room_scene.dart apps/aquarium_app/lib/screens/home/home_screen.dart apps/aquarium_app/test/services/tank_aquascape_visual_service_test.dart apps/aquarium_app/test/widgets/room/themed_aquarium_visual_state_test.dart apps/aquarium_app/test/widget_tests/home_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-living-tank-aquascape-cues.md
git commit -m "feat: show aquascape cues in tank"
```
