# Living Tank Feeding Pulse Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show a short visual feeding pulse in the central aquarium when the user logs feeding from Tank quick actions.

**Architecture:** Add a per-tank Riverpod pulse counter. Feeding save flows increment it after storage succeeds, HomeScreen watches it and passes the counter into `LivingRoomScene`/`ThemedAquarium`, and the aquarium renders a non-interactive particle pulse keyed by the counter.

**Tech Stack:** Flutter, Riverpod `StateProvider.family`, existing Tank/Home widgets.

---

### Task 1: Add Feeding Pulse Provider

**Files:**
- Create: `apps/aquarium_app/lib/providers/tank_visual_event_provider.dart`
- Test through widget flows in Tasks 2-3.

- [ ] **Step 1: Create provider**

Create the file with:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tankFeedingPulseProvider = StateProvider.family<int, String>(
  (ref, tankId) => 0,
);
```

### Task 2: Render Feeding Pulse In The Aquarium

**Files:**
- Modify: `apps/aquarium_app/lib/widgets/room/themed_aquarium.dart`
- Modify: `apps/aquarium_app/lib/widgets/room/living_room_scene.dart`
- Modify: `apps/aquarium_app/test/widgets/room/themed_aquarium_visual_state_test.dart`

- [ ] **Step 1: Write failing aquarium widget test**

In `apps/aquarium_app/test/widgets/room/themed_aquarium_visual_state_test.dart`, add:

```dart
testWidgets('shows feeding pulse when feedingPulse is positive', (tester) async {
  final semantics = tester.ensureSemantics();
  addTearDown(semantics.dispose);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ThemedAquarium(
          width: 300,
          height: 180,
          theme: defaultRoomTheme,
          feedingPulse: 1,
        ),
      ),
    ),
  );

  expect(find.byKey(const Key('tank-feeding-pulse-1')), findsOneWidget);
  expect(find.bySemanticsLabel('Tank feeding animation'), findsOneWidget);
});
```

- [ ] **Step 2: Run widget test for RED**

Run `flutter test test/widgets/room/themed_aquarium_visual_state_test.dart`.

- [ ] **Step 3: Implement overlay**

In `ThemedAquarium`, add:

```dart
final int feedingPulse;
```

Default it to `0` in the constructor. After the fish layer and before the water-state overlay, render:

```dart
if (feedingPulse > 0)
  Positioned.fill(child: _FeedingPulseOverlay(pulse: feedingPulse)),
```

Create `_FeedingPulseOverlay` as a private stateless widget. It must use:

```dart
Semantics(
  label: 'Tank feeding animation',
  excludeSemantics: true,
  child: IgnorePointer(
    child: Stack(
      key: Key('tank-feeding-pulse-$pulse'),
      children: const [
        _FoodParticle(leftFactor: 0.44, topFactor: 0.18, size: 7, opacity: 0.95),
        _FoodParticle(leftFactor: 0.51, topFactor: 0.23, size: 5, opacity: 0.82),
        _FoodParticle(leftFactor: 0.58, topFactor: 0.16, size: 6, opacity: 0.75),
        _FoodParticle(leftFactor: 0.47, topFactor: 0.31, size: 4, opacity: 0.58),
        _FoodParticle(leftFactor: 0.55, topFactor: 0.34, size: 4, opacity: 0.48),
      ],
    ),
  ),
)
```

`_FoodParticle` should use `LayoutBuilder` and `Positioned` so particle positions scale with the aquarium size. Use `AnimatedOpacity` with a short duration unless `MediaQuery.disableAnimations` is true, in which case use zero duration.

In `LivingRoomScene`, add `final int feedingPulse;`, default to `0`, and pass it into `ThemedAquarium`.

- [ ] **Step 4: Run widget test for GREEN**

Run `flutter test test/widgets/room/themed_aquarium_visual_state_test.dart`.

### Task 3: Trigger Pulse From Tank Feeding Actions

**Files:**
- Modify: `apps/aquarium_app/lib/screens/home/home_screen.dart`
- Modify: `apps/aquarium_app/lib/screens/home/widgets/today_board.dart`
- Modify: `apps/aquarium_app/test/widget_tests/home_screen_test.dart`
- Modify: `apps/aquarium_app/test/widget_tests/today_board_test.dart`

- [ ] **Step 1: Write failing HomeScreen test**

In `apps/aquarium_app/test/widget_tests/home_screen_test.dart`, extend `main Tank Feed quick action saves a feeding log`:

```dart
await tester.tap(find.byTooltip('Feed fish'));
await tester.pumpAndSettle();

expect(find.byKey(const Key('tank-feeding-pulse-1')), findsOneWidget);
```

Keep the existing log-save assertions.

- [ ] **Step 2: Write failing TodayBoard test**

In `apps/aquarium_app/test/widget_tests/today_board_test.dart`, import `tank_visual_event_provider.dart` and add:

```dart
testWidgets('Feed quick care action emits a tank feeding pulse', (tester) async {
  final storage = FakeStorageService();
  await storage.saveTank(_tank());

  await tester.pumpWidget(
    ProviderScope(
      overrides: _todayBoardOverrides(storage),
      child: MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const TodayBoardCard(tankId: 'tank-1'),
              Consumer(
                builder: (context, ref, _) => Text(
                  'pulse ${ref.watch(tankFeedingPulseProvider('tank-1'))}',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
  expect(find.text('pulse 0'), findsOneWidget);

  await tester.tap(find.bySemanticsLabel('Quick care action: Feed'));
  await tester.pumpAndSettle();

  expect(find.text('pulse 1'), findsOneWidget);
});
```

Adapt helper names to the existing test file if needed; keep the behavior exactly the same.

- [ ] **Step 3: Run tests for RED**

Run:

```powershell
flutter test test/widget_tests/home_screen_test.dart --plain-name "main Tank Feed quick action saves a feeding log"
flutter test test/widget_tests/today_board_test.dart --plain-name "Feed quick care action emits a tank feeding pulse"
```

- [ ] **Step 4: Implement event wiring**

Import `tank_visual_event_provider.dart` in `home_screen.dart` and `today_board.dart`.

In `HomeScreen._buildLivingRoomScreen`, add:

```dart
final feedingPulse = ref.watch(tankFeedingPulseProvider(currentTank.id));
```

Pass `feedingPulse: feedingPulse` into `LivingRoomScene`.

In `_quickLogFeeding`, after both log providers are invalidated, add:

```dart
ref.read(tankFeedingPulseProvider(tank.id).notifier).state++;
```

In `_QuickCareRail._logFeeding`, after both log providers are invalidated, add:

```dart
ref.read(tankFeedingPulseProvider(tankId).notifier).state++;
```

- [ ] **Step 5: Run focused tests for GREEN**

Run:

```powershell
flutter test test/widgets/room/themed_aquarium_visual_state_test.dart test/widget_tests/home_screen_test.dart test/widget_tests/today_board_test.dart
```

### Task 4: Docs, Verification, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [ ] **Step 1: Record CL-P1-001C progress**

Document feeding pulse animation from Tank quick actions.

- [ ] **Step 2: Format and verify**

Run:

```powershell
dart format lib/providers/tank_visual_event_provider.dart lib/widgets/room/themed_aquarium.dart lib/widgets/room/living_room_scene.dart lib/screens/home/home_screen.dart lib/screens/home/widgets/today_board.dart test/widgets/room/themed_aquarium_visual_state_test.dart test/widget_tests/home_screen_test.dart test/widget_tests/today_board_test.dart
flutter analyze
flutter test
flutter build apk --debug
git diff --check
```

- [ ] **Step 3: Commit**

Run:

```powershell
git add apps/aquarium_app/lib/providers/tank_visual_event_provider.dart apps/aquarium_app/lib/widgets/room/themed_aquarium.dart apps/aquarium_app/lib/widgets/room/living_room_scene.dart apps/aquarium_app/lib/screens/home/home_screen.dart apps/aquarium_app/lib/screens/home/widgets/today_board.dart apps/aquarium_app/test/widgets/room/themed_aquarium_visual_state_test.dart apps/aquarium_app/test/widget_tests/home_screen_test.dart apps/aquarium_app/test/widget_tests/today_board_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-living-tank-feeding-pulse.md
git commit -m "feat: animate tank feeding feedback"
```
