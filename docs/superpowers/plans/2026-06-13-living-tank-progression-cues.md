# Living Tank Progression Cues Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let the central aquarium show subtle collectible/progression cues when the user has earned species beyond the default starter unlocks.

**Architecture:** Add a focused service that classifies the existing `speciesUnlockProvider` state against `defaultUnlockedSpecies`. HomeScreen watches the unlocked species set, passes a visual state through `LivingRoomScene` to `ThemedAquarium`, and the aquarium renders a non-interactive sparkle/ripple layer. This uses real lesson/species progression only; it does not invent tank cosmetics that the app cannot yet persist.

**Tech Stack:** Flutter, Riverpod, existing `speciesUnlockProvider`, existing `species_unlock_map.dart`.

---

### Task 1: Add Progression Visual State Service

**Files:**
- Create: `apps/aquarium_app/lib/services/tank_progress_visual_service.dart`
- Test: `apps/aquarium_app/test/services/tank_progress_visual_service_test.dart`

- [ ] **Step 1: Write failing service tests**

Create tests for:

```dart
test('default starter species return clear', () {
  final state = TankProgressVisualService.fromUnlockedSpecies(
    defaultUnlockedSpecies.toSet(),
  );

  expect(state.condition, TankProgressVisualCondition.clear);
  expect(state.hasOverlay, isFalse);
});

test('one earned species returns species unlocked cue', () {
  final state = TankProgressVisualService.fromUnlockedSpecies({
    ...defaultUnlockedSpecies,
    'betta',
  });

  expect(state.condition, TankProgressVisualCondition.speciesUnlocked);
  expect(
    state.semanticsLabel,
    'Tank progression visual state: species unlocks visible',
  );
});

test('three earned species returns growing collection cue', () {
  final state = TankProgressVisualService.fromUnlockedSpecies({
    ...defaultUnlockedSpecies,
    'betta',
    'molly',
    'platy',
  });

  expect(state.condition, TankProgressVisualCondition.collectionGrowing);
  expect(
    state.semanticsLabel,
    'Tank progression visual state: growing species collection',
  );
});
```

- [ ] **Step 2: Run service test for RED**

Run:

```powershell
flutter test test/services/tank_progress_visual_service_test.dart
```

Expected: compile failure because the service does not exist.

- [ ] **Step 3: Implement service**

Create:

```dart
enum TankProgressVisualCondition { clear, speciesUnlocked, collectionGrowing }

class TankProgressVisualState {
  final TankProgressVisualCondition condition;
  final String semanticsLabel;

  const TankProgressVisualState({
    required this.condition,
    required this.semanticsLabel,
  });

  bool get hasOverlay => condition != TankProgressVisualCondition.clear;
}
```

`TankProgressVisualService.fromUnlockedSpecies(Set<String> unlockedSpecies)` should:

- Count species unlocked beyond `defaultUnlockedSpecies`.
- Return clear when the earned count is zero.
- Return `speciesUnlocked` when the earned count is one or two.
- Return `collectionGrowing` when the earned count is three or more.

- [ ] **Step 4: Run service tests for GREEN**

Run:

```powershell
flutter test test/services/tank_progress_visual_service_test.dart
```

### Task 2: Render Progression Accent Layer

**Files:**
- Modify: `apps/aquarium_app/lib/widgets/room/themed_aquarium.dart`
- Modify: `apps/aquarium_app/lib/widgets/room/living_room_scene.dart`
- Modify: `apps/aquarium_app/test/widgets/room/themed_aquarium_visual_state_test.dart`

- [ ] **Step 1: Write failing aquarium widget test**

Add a test that pumps:

```dart
progressVisualState: const TankProgressVisualState(
  condition: TankProgressVisualCondition.collectionGrowing,
  semanticsLabel: 'Tank progression visual state: growing species collection',
)
```

Expect:

```dart
find.byKey(const Key('tank-progress-overlay-collectionGrowing'))
find.bySemanticsLabel('Tank progression visual state: growing species collection')
```

- [ ] **Step 2: Run widget test for RED**

Run:

```powershell
flutter test test/widgets/room/themed_aquarium_visual_state_test.dart --plain-name "shows progression cue when provided"
```

- [ ] **Step 3: Implement overlay propagation**

Add `TankProgressVisualState? progressVisualState` to `ThemedAquarium` and `LivingRoomScene`.

In `ThemedAquarium`, render after the fish layer and before care-warning overlays:

```dart
if (progressVisualState != null && progressVisualState!.hasOverlay)
  Positioned.fill(child: _TankProgressVisualOverlay(progressVisualState!)),
```

Create `_TankProgressVisualOverlay`:

- Wrap with `Semantics(label: state.semanticsLabel, excludeSemantics: true)`.
- Wrap with `IgnorePointer`.
- Key the paint layer as `tank-progress-overlay-${state.condition.name}`.
- Use `CustomPaint` to draw subtle sparkle/ripple accents.
- Use a stronger cue for `collectionGrowing` than for `speciesUnlocked`.
- Do not add visible text.

- [ ] **Step 4: Run widget test for GREEN**

Run:

```powershell
flutter test test/widgets/room/themed_aquarium_visual_state_test.dart
```

### Task 3: Wire HomeScreen Unlock Cue

**Files:**
- Modify: `apps/aquarium_app/lib/screens/home/home_screen.dart`
- Modify: `apps/aquarium_app/test/widget_tests/home_screen_test.dart`

- [ ] **Step 1: Write failing HomeScreen test**

Seed SharedPreferences with:

```dart
SharedPreferences.setMockInitialValues({
  'unlocked_species_v1': jsonEncode([
    ...defaultUnlockedSpecies,
    'betta',
    'molly',
    'platy',
  ]),
});
```

Pump HomeScreen with a tank and expect:

```dart
expect(
  find.byKey(const Key('tank-progress-overlay-collectionGrowing')),
  findsOneWidget,
);
```

- [ ] **Step 2: Run test for RED**

Run:

```powershell
flutter test test/widget_tests/home_screen_test.dart --plain-name "Tank aquarium reflects earned species progression visually"
```

- [ ] **Step 3: Implement HomeScreen wiring**

Import `species_unlock_provider.dart` and `tank_progress_visual_service.dart`.

In `_buildLivingRoomScreen`, after current tank data is resolved:

```dart
final unlockedSpecies = ref.watch(speciesUnlockProvider);
final progressVisualState =
    TankProgressVisualService.fromUnlockedSpecies(unlockedSpecies);
```

Pass `progressVisualState: progressVisualState` to `LivingRoomScene`.

- [ ] **Step 4: Run focused tests for GREEN**

Run:

```powershell
flutter test test/services/tank_progress_visual_service_test.dart test/widgets/room/themed_aquarium_visual_state_test.dart test/widget_tests/home_screen_test.dart
```

### Task 4: Docs, Verification, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [ ] **Step 1: Record CL-P1-001F progress**

Document that the living tank now reflects real species unlock progression. Keep the caveat that full room/decor/tank-cosmetic reward loops remain separate CL-P1-002 depth.

- [ ] **Step 2: Format and verify**

Run:

```powershell
dart format lib/services/tank_progress_visual_service.dart lib/widgets/room/themed_aquarium.dart lib/widgets/room/living_room_scene.dart lib/screens/home/home_screen.dart test/services/tank_progress_visual_service_test.dart test/widgets/room/themed_aquarium_visual_state_test.dart test/widget_tests/home_screen_test.dart
flutter analyze
flutter test
flutter build apk --debug
git diff --check
```

- [ ] **Step 3: Commit**

Run:

```powershell
git add apps/aquarium_app/lib/services/tank_progress_visual_service.dart apps/aquarium_app/lib/widgets/room/themed_aquarium.dart apps/aquarium_app/lib/widgets/room/living_room_scene.dart apps/aquarium_app/lib/screens/home/home_screen.dart apps/aquarium_app/test/services/tank_progress_visual_service_test.dart apps/aquarium_app/test/widgets/room/themed_aquarium_visual_state_test.dart apps/aquarium_app/test/widget_tests/home_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-living-tank-progression-cues.md
git commit -m "feat: show progression cues in tank"
```
