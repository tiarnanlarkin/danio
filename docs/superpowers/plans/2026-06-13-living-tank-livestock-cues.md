# Living Tank Livestock Cues Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show subtle visual stress/compatibility cues in the central aquarium when local livestock data says a tank needs review.

**Architecture:** Add a focused service that converts livestock health and existing `CompatibilityService` results into a small visual-state object. HomeScreen watches current tank livestock, computes the state, passes it through `LivingRoomScene` to `ThemedAquarium`, and the aquarium renders a non-interactive text-free cue overlay.

**Tech Stack:** Flutter, Riverpod providers already used by Tank, existing `CompatibilityService`, existing `Livestock` health model.

---

### Task 1: Add Livestock Visual State Service

**Files:**
- Create: `apps/aquarium_app/lib/services/tank_livestock_visual_service.dart`
- Test: `apps/aquarium_app/test/services/tank_livestock_visual_service_test.dart`

- [ ] **Step 1: Write failing service tests**

Create tests for three cases:

```dart
test('healthy compatible livestock returns clear', () {
  final state = TankLivestockVisualService.fromTank(
    tank: _tank(),
    livestock: [_livestock('neon', 'Neon Tetra', count: 6)],
  );

  expect(state.condition, TankLivestockVisualCondition.clear);
  expect(state.hasOverlay, isFalse);
});

test('sick livestock returns health concern before compatibility', () {
  final state = TankLivestockVisualService.fromTank(
    tank: _tank(),
    livestock: [
      _livestock('betta', 'Betta', healthStatus: HealthStatus.sick),
      _livestock('guppy', 'Guppy', count: 3),
    ],
  );

  expect(state.condition, TankLivestockVisualCondition.healthConcern);
  expect(state.semanticsLabel, 'Tank livestock visual state: livestock health needs review');
});

test('compatibility issues return compatibility concern', () {
  final state = TankLivestockVisualService.fromTank(
    tank: _tank(),
    livestock: [
      _livestock('betta', 'Betta'),
      _livestock('guppy', 'Guppy', count: 3),
    ],
  );

  expect(state.condition, TankLivestockVisualCondition.compatibilityConcern);
  expect(state.semanticsLabel, 'Tank livestock visual state: compatibility needs review');
});
```

- [ ] **Step 2: Run tests for RED**

Run:

```powershell
flutter test test/services/tank_livestock_visual_service_test.dart
```

Expected: compile failure because the service does not exist.

- [ ] **Step 3: Implement service**

Create:

```dart
enum TankLivestockVisualCondition { clear, healthConcern, compatibilityConcern }

class TankLivestockVisualState {
  final TankLivestockVisualCondition condition;
  final String semanticsLabel;

  const TankLivestockVisualState({
    required this.condition,
    required this.semanticsLabel,
  });

  bool get hasOverlay => condition != TankLivestockVisualCondition.clear;
}
```

Implement `TankLivestockVisualService.fromTank({required Tank tank, required List<Livestock> livestock})`:

- Return clear when the list is empty.
- Return `healthConcern` first if any entry has `healthStatus != HealthStatus.healthy`.
- Otherwise run `CompatibilityService.checkLivestockCompatibility` for each livestock entry against the same tank/list.
- Return `compatibilityConcern` if any compatibility warning or incompatible issue exists.
- Otherwise return clear.

- [ ] **Step 4: Run service tests for GREEN**

Run:

```powershell
flutter test test/services/tank_livestock_visual_service_test.dart
```

### Task 2: Render Livestock Cue In Aquarium

**Files:**
- Modify: `apps/aquarium_app/lib/widgets/room/themed_aquarium.dart`
- Modify: `apps/aquarium_app/lib/widgets/room/living_room_scene.dart`
- Modify: `apps/aquarium_app/test/widgets/room/themed_aquarium_visual_state_test.dart`

- [ ] **Step 1: Write failing aquarium widget test**

Add:

```dart
testWidgets('shows livestock compatibility cue when provided', (tester) async {
  final semantics = tester.ensureSemantics();
  try {
    await tester.pumpWidget(
      _wrap(
        null,
        livestockVisualState: const TankLivestockVisualState(
          condition: TankLivestockVisualCondition.compatibilityConcern,
          semanticsLabel: 'Tank livestock visual state: compatibility needs review',
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('tank-livestock-overlay-compatibilityConcern')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Tank livestock visual state: compatibility needs review'),
      findsOneWidget,
    );
  } finally {
    semantics.dispose();
  }
});
```

- [ ] **Step 2: Run widget test for RED**

Run:

```powershell
flutter test test/widgets/room/themed_aquarium_visual_state_test.dart --plain-name "shows livestock compatibility cue when provided"
```

- [ ] **Step 3: Implement overlay propagation**

Add `TankLivestockVisualState? livestockVisualState` to `ThemedAquarium` and `LivingRoomScene`.

In `ThemedAquarium`, render after the water-state overlay:

```dart
if (livestockVisualState != null && livestockVisualState!.hasOverlay)
  Positioned.fill(child: _TankLivestockVisualOverlay(livestockVisualState!)),
```

Create `_TankLivestockVisualOverlay`:

- Wrap with `Semantics(label: state.semanticsLabel, excludeSemantics: true)`.
- Wrap with `IgnorePointer`.
- Key the paint layer as `tank-livestock-overlay-${state.condition.name}`.
- Use `CustomPaint` to draw subtle warning/stress arcs in amber for compatibility and red/coral for health.
- Do not add visible text.

- [ ] **Step 4: Run widget test for GREEN**

Run:

```powershell
flutter test test/widgets/room/themed_aquarium_visual_state_test.dart
```

### Task 3: Wire HomeScreen Livestock Cue

**Files:**
- Modify: `apps/aquarium_app/lib/screens/home/home_screen.dart`
- Modify: `apps/aquarium_app/test/widget_tests/home_screen_test.dart`

- [ ] **Step 1: Write failing HomeScreen integration test**

Add a test that creates a current tank, saves `Betta` and `Guppy` livestock into the fake storage, pumps HomeScreen, and expects:

```dart
expect(
  find.byKey(const Key('tank-livestock-overlay-compatibilityConcern')),
  findsOneWidget,
);
```

- [ ] **Step 2: Run test for RED**

Run:

```powershell
flutter test test/widget_tests/home_screen_test.dart --plain-name "Tank aquarium reflects livestock compatibility visually"
```

- [ ] **Step 3: Implement HomeScreen wiring**

Import `tank_livestock_visual_service.dart`.

In `_buildLivingRoomScreen`, after current logs:

```dart
final currentLivestock =
    ref.watch(livestockProvider(currentTank.id)).valueOrNull ?? [];
final livestockVisualState = TankLivestockVisualService.fromTank(
  tank: currentTank,
  livestock: currentLivestock,
);
```

Pass `livestockVisualState: livestockVisualState` to `LivingRoomScene`.

- [ ] **Step 4: Run focused tests for GREEN**

Run:

```powershell
flutter test test/services/tank_livestock_visual_service_test.dart test/widgets/room/themed_aquarium_visual_state_test.dart test/widget_tests/home_screen_test.dart
```

### Task 4: Docs, Verification, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [ ] **Step 1: Record CL-P1-001D progress**

Document that living tank visuals now show livestock health and compatibility review cues.

- [ ] **Step 2: Format and verify**

Run:

```powershell
dart format lib/services/tank_livestock_visual_service.dart lib/widgets/room/themed_aquarium.dart lib/widgets/room/living_room_scene.dart lib/screens/home/home_screen.dart test/services/tank_livestock_visual_service_test.dart test/widgets/room/themed_aquarium_visual_state_test.dart test/widget_tests/home_screen_test.dart
flutter analyze
flutter test
flutter build apk --debug
git diff --check
```

- [ ] **Step 3: Commit**

Run:

```powershell
git add apps/aquarium_app/lib/services/tank_livestock_visual_service.dart apps/aquarium_app/lib/widgets/room/themed_aquarium.dart apps/aquarium_app/lib/widgets/room/living_room_scene.dart apps/aquarium_app/lib/screens/home/home_screen.dart apps/aquarium_app/test/services/tank_livestock_visual_service_test.dart apps/aquarium_app/test/widgets/room/themed_aquarium_visual_state_test.dart apps/aquarium_app/test/widget_tests/home_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-living-tank-livestock-cues.md
git commit -m "feat: show livestock care cues in tank"
```
