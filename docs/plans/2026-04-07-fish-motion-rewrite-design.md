# Fish Motion Rewrite — Design Doc

**Date:** 2026-04-07
**Phase:** Danio Fix Brief Phase 5 (motion, banners, side panels — this doc covers motion only)
**Branch:** `feature/danio-fix-brief-phase-5` (branched from `main`, independent of phase-4)
**Spec source:** `repo/docs/planning/2026-04-danio-fix-brief-concept-lock.md` §"Fish Animation Behavior Spec"
**Plan source:** `C:\Users\larki\.claude\plans\playful-cooking-glade.md` §"Phase 5"

## Context

The current `AnimatedSwimmingFish` widget uses a linear `Tween<double>(begin: -0.1, end: 1.1)` driven by `AnimationController.repeat(reverse: true)`. The fish slides back and forth in a perfect ping-pong, looking mechanical. The fix brief asks for goal-seeking motion that "feels deliberate."

A scope discovery during exploration: `AnimatedSwimmingFish` is only used in `tank_fish_manager.dart:_buildFallback()` (3 hardcoded fish for users with no unlocked species). Real users with unlocked livestock see `SpeciesFish`, which has its own separate procedural animation (constant-speed bounce + 200ms wall pause + sine bob + speed jitter). The literal Phase 5 plan only names `animated_swimming_fish.dart`, but limiting the rewrite to that file would mean almost no real users see the new motion.

**Decision: extract a shared `FishMotion` engine and apply it to both widgets.** This widens the diff but matches the spec's actual intent.

## Locked Decisions (from brainstorming Q&A)

| # | Decision | Choice |
|---|----------|--------|
| 1 | Rewrite scope | Both widgets via shared `FishMotion` engine |
| 2 | Goal-seek dimensionality | 2D (X+Y target) with sine bob layered on top |
| 3 | Arrival behavior | Decelerate → 300–800ms random pause → new target |
| 4 | Determinism | Fully random in prod; widget tests use bounds assertions; engine has optional `Random? rng` for state-machine unit tests |
| 5 | Engine architecture | Per-widget `Ticker` + pure-Dart `FishMotion` class |

## Component Layout

**New file (1):**
- `lib/widgets/room/fish_motion.dart` — pure-Dart `FishMotion` class. Imports only `dart:math` and `dart:ui`. No Flutter widget dependencies.

**Modified files (2):**
- `lib/widgets/room/animated_swimming_fish.dart` — swaps `AnimationController.repeat()` for `Ticker` + `FishMotion`. Public API unchanged.
- `lib/widgets/room/species_fish.dart` — swaps existing `_x`/`_speedX`/`_paused` state for `FishMotion`. Public API unchanged.

**Untouched (per concept lock §5 + plan):**
- `lib/widgets/room/fish_painter.dart` — fish appearance (sacred)
- `lib/widgets/room/themed_aquarium.dart` — Layer 4, Apollo's "DO NOT TOUCH"
- `lib/widgets/room/tank_fish_manager.dart` — only orchestrates, doesn't animate

**New tests (1):**
- `test/widgets/room/fish_motion_test.dart` — pure-Dart unit tests for the engine

## FishMotion — Public API

```dart
class FishMotion {
  FishMotion({
    required this.tankWidth,
    required this.tankHeight,
    required this.fishSize,
    this.baseTopFraction = 0.5,
    this.layerHalfHeightFraction = 0.18,
    this.maxSpeed = 35.0,
    this.minSpeed = 8.0,
    this.bobAmplitude = 6.0,
    this.bobPeriodSeconds = 3.5,
    this.glassMargin = 4.0,
    this.sandFraction = 0.78,
    Random? rng,                 // null in prod; seeded in unit tests
  });

  final double tankWidth, tankHeight, fishSize;
  final double baseTopFraction, layerHalfHeightFraction;
  final double maxSpeed, minSpeed;
  final double bobAmplitude, bobPeriodSeconds;
  final double glassMargin, sandFraction;

  Offset get position;          // current center, with bob layered on Y
  bool get facingRight;         // derived from horizontal velocity sign
  bool get isHovering;          // true during the 300-800ms post-arrival pause

  void tick(double dt);         // dt clamped internally to ≤ 0.1
  void seedInitialPosition({double phaseOffset = 0});
}
```

## Internal State

```dart
Offset _position;          // current center, before bob is added
Offset _target;            // current goal-seek target
double _speed;             // current scalar speed (px/sec), eased
double _pauseRemaining;    // seconds left in hover; 0 == traveling
double _bobPhase;          // accumulated radians for sine bob
bool _lastFacingRight;     // cached so flip is stable while hovering
late final Random _rng;
```

## Tick Algorithm

```
tick(dt):
  dt = min(dt, 0.1)              // backgrounded-app guard
  _bobPhase += dt * 2π / bobPeriodSeconds

  if _pauseRemaining > 0:
    _pauseRemaining -= dt
    if _pauseRemaining <= 0:
      _pickNewTarget()
    return

  toTarget = _target - _position
  distance = toTarget.distance

  if distance < arrivalRadius:    // arrivalRadius ≈ fishSize * 0.25
    _pauseRemaining = randomBetween(0.3, 0.8)
    _speed = 0
    return

  // Speed model: ease-out near target, slower near walls
  approachFactor = clamp(distance / decelDistance, 0, 1)  // decelDistance ≈ tankWidth * 0.18
  edgeFactor = _proximityToWalls()
  targetSpeed = lerp(minSpeed, maxSpeed, approachFactor * edgeFactor)
  _speed += (targetSpeed - _speed) * min(1, dt * 4)       // smooth acceleration

  // Move toward target
  direction = toTarget / distance
  _position += direction * _speed * dt

  // Wander: small lateral perturbation perpendicular to direction
  perpendicular = Offset(-direction.dy, direction.dx)
  wanderAmount = (_rng.nextDouble() - 0.5) * 0.5 * dt * _speed
  _position += perpendicular * wanderAmount

  // BUG-08 hard clamp (last line of defense)
  _position = Offset(
    _position.dx.clamp(glassMargin + fishSize/2, tankWidth - glassMargin - fishSize/2),
    _position.dy.clamp(glassMargin + fishSize/2, tankHeight * sandFraction - fishSize/2),
  )
```

The position getter adds the sine bob at read-time:
```dart
Offset get position => Offset(_position.dx, _position.dy + sin(_bobPhase) * bobAmplitude);
```

## Target Selection

```
_pickNewTarget():
  // Glass + fish margin
  minX = glassMargin + fishSize
  maxX = tankWidth - glassMargin - fishSize

  // Layer band (preserves the 3-layer depth structure from tank_fish_manager.dart)
  layerCenter = baseTopFraction * tankHeight
  layerHalf = layerHalfHeightFraction * tankHeight
  minY = max(glassMargin + fishSize, layerCenter - layerHalf)
  maxY = min(tankHeight * sandFraction - fishSize, layerCenter + layerHalf)

  // Edge response: bias toward the opposite side of any current edge proximity
  preferredXRange = _biasAwayFromCurrentEdge(_position.dx, minX, maxX)
  preferredYRange = _biasAwayFromCurrentEdge(_position.dy, minY, maxY)

  // Try up to 5 random samples; pick the first that exceeds minTravelDistance
  minTravelDistance = tankWidth * 0.25
  for attempt in 0..5:
    candidate = randomPointIn(preferredXRange, preferredYRange)
    if (candidate - _position).distance >= minTravelDistance:
      _target = candidate
      return
  _target = candidate                     // fallback for extreme aspect ratios
```

`_biasAwayFromCurrentEdge` returns a sub-range that excludes the third closest to the current wall:
- Fish in left third → target in right 60%
- Fish in right third → target in left 60%
- Fish in middle → full range

Same for vertical. This produces "soft turn" behavior — fish near the left glass picks a target in the right two-thirds and naturally arcs away.

## Wall Proximity (Speed Model Input)

```
_proximityToWalls():
  comfortDistance = fishSize * 2
  xMargin = min(_position.dx - glassMargin, tankWidth - glassMargin - _position.dx)
  yMargin = min(_position.dy - glassMargin, tankHeight * sandFraction - _position.dy)
  return min(xMargin / comfortDistance, yMargin / comfortDistance).clamp(0, 1)
```

Returns 0 at any wall, 1 when comfortably mid-tank. Multiplied into the speed calculation so fish slow to `minSpeed` near walls.

## Widget Integration Pattern

Both `AnimatedSwimmingFish` and `SpeciesFish` follow the same pattern:

```dart
class _State extends State<X> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late FishMotion _motion;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _motion = _buildMotion();
    _motion.seedInitialPosition(phaseOffset: widget.startOffset);
    _ticker.start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ticker.muted = MediaQuery.of(context).disableAnimations;
  }

  @override
  void didUpdateWidget(covariant X oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tankWidth != widget.tankWidth ||
        oldWidget.tankHeight != widget.tankHeight) {
      _motion = _buildMotion();
      _motion.seedInitialPosition(phaseOffset: widget.startOffset);
      _lastElapsed = Duration.zero;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (dt <= 0) return;
    _motion.tick(dt);
    if (mounted) setState(() {});
  }

  FishMotion _buildMotion();   // overridden per widget
}
```

**No mixin extraction.** With only two consumers, duplicating ~25 lines is clearer than introducing a third file. Mixin can be extracted later if a third consumer appears.

### Parameter Mapping

**`AnimatedSwimmingFish`:**
```dart
FishMotion _buildMotion() => FishMotion(
  tankWidth: widget.tankWidth,
  tankHeight: widget.tankHeight,
  fishSize: widget.size,
  baseTopFraction: widget.baseTop,
  layerHalfHeightFraction: 0.18,
  maxSpeed: widget.tankWidth / widget.swimSpeed,
  minSpeed: (widget.tankWidth / widget.swimSpeed) * 0.25,
  bobAmplitude: widget.verticalBob,
  bobPeriodSeconds: widget.swimSpeed * 0.5,
);
```
`swimSpeed` (seconds-per-cycle) repurposed as "seconds to traverse the tank at top speed" — visual feel is preserved for existing callers passing `swimSpeed: 8.0`.

**`SpeciesFish`:**
```dart
FishMotion _buildMotion() {
  final depthScale = 1.0 - widget.depth * 0.4;
  return FishMotion(
    tankWidth: widget.tankWidth,
    tankHeight: widget.tankHeight,
    fishSize: _baseSize * depthScale,
    baseTopFraction: widget.baseTop,
    layerHalfHeightFraction: 0.20,
    maxSpeed: widget.baseSpeed * depthScale,
    minSpeed: widget.baseSpeed * depthScale * 0.25,
    bobAmplitude: widget.bobAmplitude,
    bobPeriodSeconds: widget.bobPeriod,
  );
}
```

## Safety Constraint Preservation

| # | Constraint | Mechanism |
|---|------------|-----------|
| 1 | No `AnimationStatus` listeners that recurse | `Ticker` has no completion or status events. The bug class is structurally impossible. |
| 2 | Reduced motion: long-duration freeze, NOT zero | Replaced with `_ticker.muted = MediaQuery.disableAnimations`. Same intent (no movement); no `Duration.zero` assertion possible because there is no `Duration` field. |
| 3 | R-088 non-finite guards | Engine clamps internally; widget `build()` checks `pos.dx.isFinite && pos.dy.isFinite` and returns `SizedBox.shrink()` on NaN. |
| 4 | BUG-08 boundary clamps | `FishMotion.tick()` ends with explicit clamp to `[glassMargin + fishSize/2, tankWidth - glassMargin - fishSize/2]` × `[glassMargin + fishSize/2, tankHeight * sandFraction - fishSize/2]`. Target selection also biases toward valid positions. |
| 5 | `RepaintBoundary` optimization | Both widgets keep `RepaintBoundary` wrapping the rendered fish in `build()`, unchanged. |
| 6 | Public widget API preserved | Both widgets keep their full public param surface. Zero call-site changes anywhere in the codebase. |

### New Safety: `dt` Clamp

`tick(dt)` clamps `dt = min(dt, 0.1)` (100ms). Handles backgrounded-app resume gracefully — fish gets one frame of motion regardless of how long the app slept. Without this, a 30-second background gap would integrate motion across 30 simulated seconds in one frame and fly the fish across the tank.

### Reduced-Motion Toggle Mid-Session

- Toggle ON → `didChangeDependencies` → `_ticker.muted = true` → fish freezes mid-stride
- Toggle OFF → `_ticker.muted = false` → next frame has large `elapsed - _lastElapsed` gap → `dt` clamp neutralizes → fish resumes smoothly

No state desync, no jump.

## Testing Strategy

### A. Pure-Dart Engine Tests — `test/widgets/room/fish_motion_test.dart` (NEW, ~12 tests)

Run without `WidgetTester`. Millisecond-fast. Cover:
- Initial position is within glass bounds
- Position changes after `tick()`
- Position stays within bounds after 100s of simulated ticks
- `dt` clamp prevents large jump after backgrounded-app
- Hover phase entered on arrival (wait for `isHovering`)
- `facingRight` reflects horizontal velocity sign
- Engine has no `muted` concept (skip test, document why)

Use `Random(42)` for deterministic state-machine assertions; production never seeds.

### B. Widget Tests — `test/widgets/room/animated_swimming_fish_test.dart` & `species_fish_test.dart` (NEW or UPDATED)

- Renders without exceptions
- Fish stays within tank bounds over 5 seconds of pumping (bounds assertion only, no exact positions)
- Reduced motion freezes fish (compare `Positioned.left` before/after pump under `MediaQueryData(disableAnimations: true)`)
- Disposes cleanly without late-callback exception (unmount, pump, expect no thrown exception)

### C. Existing Test Migration

Before implementation, grep `test/` for assertions on fish positions. Migrate any positional checks to bounds-only assertions in the same commit as the rewrite. Expected scope: < 10 tests.

### D. Performance Sanity Check (Manual)

Part of Phase 5 verification, not automated:
- `flutter run --profile` on Android emulator
- FPS overlay enabled
- Empty tank (3 fallback fish): FPS ≥ 55 over 30 seconds
- Populated tank (8 species fish): FPS ≥ 55 over 30 seconds
- Toggle reduced motion in settings, verify fish freeze

### E. Not Tested

- No golden tests for motion (random per-launch, would fail)
- No determinism in widget tests (per Q4 decision)
- No multi-fish coordination tests (fish are independent)

## Out of Scope

- `tank_fish_manager.dart` orchestration (untouched)
- `fish_painter.dart` appearance (untouched per concept lock §5)
- `themed_aquarium.dart` Layer 4 (untouched per Apollo's audit)
- The other Phase 5 work — banner unification, side panel redesign — is in the same phase but not in this design doc; will be handled in separate design docs or directly per the plan

## Open Items

None. All decisions are locked from the brainstorming Q&A.

## Next Step

Invoke `superpowers:writing-plans` to convert this design into a step-by-step implementation plan.
