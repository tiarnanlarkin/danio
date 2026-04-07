# Fish Motion Rewrite Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the linear ping-pong fish animation with a goal-seeking motion engine shared by both `AnimatedSwimmingFish` and `SpeciesFish`, preserving all 6 documented safety constraints and zero call-site changes.

**Architecture:** Pure-Dart `FishMotion` class with internal state (position, target, speed, hover timer, bob phase) driven by a per-widget `Ticker` via `SingleTickerProviderStateMixin`. 2D goal-seek with sine bob layered at read-time. See `docs/plans/2026-04-07-fish-motion-rewrite-design.md` for full design.

**Tech Stack:** Flutter, Dart, `dart:math`, `dart:ui` (`Offset`), `flutter_test`, `dart:async` (`Ticker`).

**Branch:** `feature/danio-fix-brief-phase-5` (already created, design doc at `ed6fa5a1`).

**Working directory for all commands:** `repo/apps/aquarium_app`

---

## Pre-Implementation Survey (5 min, no code yet)

Before Task 1, the implementing agent must:

1. Read the design doc end-to-end:
   ```
   repo/docs/plans/2026-04-07-fish-motion-rewrite-design.md
   ```

2. Read both target widgets in full:
   ```
   repo/apps/aquarium_app/lib/widgets/room/animated_swimming_fish.dart
   repo/apps/aquarium_app/lib/widgets/room/species_fish.dart
   ```

3. Grep for existing positional fish assertions:
   ```bash
   cd repo/apps/aquarium_app
   grep -rn "AnimatedSwimmingFish\|SpeciesFish" test/
   grep -rn "_facingRight\|_swimAnimation" test/
   ```
   Note any test that asserts an exact `Positioned.left` value or similar — these need migration in Tasks 12 and 13.

4. Verify current state:
   ```bash
   git status                    # expect: clean, on feature/danio-fix-brief-phase-5
   git log --oneline -3          # expect: ed6fa5a1 design doc, then 22e8789b Phase 3
   flutter analyze               # expect: clean (baseline)
   flutter test test/widgets/room/  # expect: pass (baseline)
   ```

If `flutter analyze` or the baseline tests fail, stop and report — the rewrite must start from a green state.

---

## Task 1: FishMotion class skeleton with constructor

**Files:**
- Create: `repo/apps/aquarium_app/lib/widgets/room/fish_motion.dart`
- Create: `repo/apps/aquarium_app/test/widgets/room/fish_motion_test.dart`

**Step 1: Write the failing test**

```dart
// test/widgets/room/fish_motion_test.dart
import 'dart:math';
import 'dart:ui';

import 'package:danio/widgets/room/fish_motion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FishMotion construction', () {
    test('constructs with required + default params', () {
      final motion = FishMotion(
        tankWidth: 300,
        tankHeight: 200,
        fishSize: 20,
      );

      expect(motion.tankWidth, 300);
      expect(motion.tankHeight, 200);
      expect(motion.fishSize, 20);
      expect(motion.maxSpeed, 35.0);
      expect(motion.minSpeed, 8.0);
      expect(motion.bobAmplitude, 6.0);
      expect(motion.bobPeriodSeconds, 3.5);
      expect(motion.glassMargin, 4.0);
      expect(motion.sandFraction, 0.78);
      expect(motion.isHovering, isFalse);
      expect(motion.facingRight, isTrue);
    });

    test('accepts injected Random for deterministic tests', () {
      final motion = FishMotion(
        tankWidth: 300,
        tankHeight: 200,
        fishSize: 20,
        rng: Random(42),
      );
      expect(motion, isNotNull);
    });
  });
}
```

**Step 2: Run test, verify it fails**

```bash
cd repo/apps/aquarium_app
flutter test test/widgets/room/fish_motion_test.dart
```

Expected: FAIL with "Target of URI doesn't exist: 'package:danio/widgets/room/fish_motion.dart'"

**Step 3: Write minimal implementation**

```dart
// lib/widgets/room/fish_motion.dart
import 'dart:math';
import 'dart:ui';

/// Pure-Dart goal-seeking motion engine for fish widgets.
///
/// See `docs/plans/2026-04-07-fish-motion-rewrite-design.md` for the full
/// algorithm specification.
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
    Random? rng,
  }) : _rng = rng ?? Random();

  final double tankWidth;
  final double tankHeight;
  final double fishSize;
  final double baseTopFraction;
  final double layerHalfHeightFraction;
  final double maxSpeed;
  final double minSpeed;
  final double bobAmplitude;
  final double bobPeriodSeconds;
  final double glassMargin;
  final double sandFraction;

  final Random _rng;

  // Mutable state — populated by seedInitialPosition / tick
  Offset _position = Offset.zero;
  Offset _target = Offset.zero;
  double _speed = 0;
  double _pauseRemaining = 0;
  double _bobPhase = 0;
  bool _lastFacingRight = true;

  Offset get position => _position;
  bool get facingRight => _lastFacingRight;
  bool get isHovering => _pauseRemaining > 0;
}
```

**Step 4: Run test, verify it passes**

```bash
flutter test test/widgets/room/fish_motion_test.dart
```

Expected: PASS (2 tests).

**Step 5: Commit**

```bash
git add lib/widgets/room/fish_motion.dart test/widgets/room/fish_motion_test.dart
git commit -m "feat(fish-motion): Task 1 — FishMotion class skeleton + constructor"
```

---

## Task 2: seedInitialPosition + position within bounds

**Files:**
- Modify: `lib/widgets/room/fish_motion.dart`
- Modify: `test/widgets/room/fish_motion_test.dart`

**Step 1: Write the failing test**

Add to the test file:

```dart
group('FishMotion seedInitialPosition', () {
  late FishMotion motion;

  setUp(() {
    motion = FishMotion(
      tankWidth: 300,
      tankHeight: 200,
      fishSize: 20,
      rng: Random(42),
    );
  });

  test('phaseOffset 0 places fish at left edge', () {
    motion.seedInitialPosition(phaseOffset: 0);
    expect(motion.position.dx, lessThan(50));
    expect(motion.position.dx, greaterThanOrEqualTo(motion.glassMargin + motion.fishSize / 2));
  });

  test('phaseOffset 1 places fish at right edge', () {
    motion.seedInitialPosition(phaseOffset: 1.0);
    expect(motion.position.dx, greaterThan(250));
    expect(motion.position.dx, lessThanOrEqualTo(300 - motion.glassMargin - motion.fishSize / 2));
  });

  test('initial position is within tank glass bounds', () {
    motion.seedInitialPosition(phaseOffset: 0.5);
    expect(motion.position.dx, inInclusiveRange(motion.glassMargin + motion.fishSize / 2, 300 - motion.glassMargin - motion.fishSize / 2));
    expect(motion.position.dy, inInclusiveRange(motion.glassMargin + motion.fishSize / 2, 200 * 0.78 - motion.fishSize / 2));
  });
});
```

**Step 2: Run test, verify it fails**

```bash
flutter test test/widgets/room/fish_motion_test.dart
```

Expected: FAIL — "The method 'seedInitialPosition' isn't defined".

**Step 3: Implement**

Add to `FishMotion`:

```dart
void seedInitialPosition({double phaseOffset = 0}) {
  final clampedPhase = phaseOffset.clamp(0.0, 1.0);
  final minX = glassMargin + fishSize / 2;
  final maxX = tankWidth - glassMargin - fishSize / 2;
  _position = Offset(
    minX + (maxX - minX) * clampedPhase,
    baseTopFraction * tankHeight,
  );
  _target = _position;
  _pauseRemaining = clampedPhase * 0.5;  // staggered start so fish don't sync
}
```

**Step 4: Run test, verify it passes**

```bash
flutter test test/widgets/room/fish_motion_test.dart
```

Expected: PASS (5 tests total).

**Step 5: Commit**

```bash
git add lib/widgets/room/fish_motion.dart test/widgets/room/fish_motion_test.dart
git commit -m "feat(fish-motion): Task 2 — seedInitialPosition + bounds"
```

---

## Task 3: tick() with dt clamp (no movement yet)

**Files:**
- Modify: `lib/widgets/room/fish_motion.dart`
- Modify: `test/widgets/room/fish_motion_test.dart`

**Step 1: Write the failing test**

Add to the test file:

```dart
group('FishMotion tick — dt clamp', () {
  late FishMotion motion;

  setUp(() {
    motion = FishMotion(
      tankWidth: 300,
      tankHeight: 200,
      fishSize: 20,
      rng: Random(42),
    );
    motion.seedInitialPosition(phaseOffset: 0.5);
  });

  test('tick(0) does not throw and does not move', () {
    final before = motion.position;
    motion.tick(0);
    expect(motion.position, equals(before));
  });

  test('tick(huge dt) does not throw', () {
    motion.tick(1000.0);
    expect(motion.position.dx.isFinite, isTrue);
    expect(motion.position.dy.isFinite, isTrue);
  });

  test('tick advances bob phase but bob amplitude is 0 here so position unchanged', () {
    final before = motion.position;
    motion.tick(0.016);
    // No target movement yet; only bob phase advanced. With default bobAmplitude=6,
    // position.dy WILL drift slightly because the position getter applies bob.
    // For this task we only assert finiteness, full movement comes in later tasks.
    expect(motion.position.dx.isFinite, isTrue);
    expect(motion.position.dy.isFinite, isTrue);
    // Allow position.dx to be unchanged because no movement logic yet
    expect(motion.position.dx, equals(before.dx));
  });
});
```

**Step 2: Run test, verify it fails**

```bash
flutter test test/widgets/room/fish_motion_test.dart
```

Expected: FAIL — "The method 'tick' isn't defined".

**Step 3: Implement**

Add to `FishMotion`:

```dart
void tick(double dt) {
  if (dt <= 0) return;
  final clampedDt = dt > 0.1 ? 0.1 : dt;
  _bobPhase += clampedDt * 2 * pi / bobPeriodSeconds;
  // Movement logic comes in later tasks.
}
```

**Step 4: Run test, verify it passes**

```bash
flutter test test/widgets/room/fish_motion_test.dart
```

Expected: PASS (8 tests total).

**Step 5: Commit**

```bash
git add lib/widgets/room/fish_motion.dart test/widgets/room/fish_motion_test.dart
git commit -m "feat(fish-motion): Task 3 — tick with dt clamp"
```

---

## Task 4: _pickNewTarget within layer band (no edge bias yet)

**Files:**
- Modify: `lib/widgets/room/fish_motion.dart`
- Modify: `test/widgets/room/fish_motion_test.dart`

**Step 1: Write the failing test**

```dart
group('FishMotion target selection', () {
  late FishMotion motion;

  setUp(() {
    motion = FishMotion(
      tankWidth: 300,
      tankHeight: 200,
      fishSize: 20,
      baseTopFraction: 0.4,
      layerHalfHeightFraction: 0.15,
      rng: Random(42),
    );
    motion.seedInitialPosition(phaseOffset: 0.5);
  });

  test('after seeding and tick(1), target is set within layer band', () {
    // Advance time long enough for the staggered initial pause to expire and
    // a target to be picked.
    for (int i = 0; i < 60; i++) {
      motion.tick(0.016);
    }
    // Internal target — verified indirectly via position bounds after movement
    expect(motion.position.dx, inInclusiveRange(motion.glassMargin + motion.fishSize / 2, 300 - motion.glassMargin - motion.fishSize / 2));
  });
});
```

**Step 2: Run test, verify it fails**

```bash
flutter test test/widgets/room/fish_motion_test.dart
```

Expected: FAIL — fish never moves because there's no target picking yet, but the test passes accidentally on bounds. Actually, this test will PASS without target picking too. We need a sharper assertion.

Replace the test body with:

```dart
test('first target is picked after initial pause expires', () {
  // Initial pause is phaseOffset * 0.5 = 0.25s. Tick 0.5s to clear it.
  for (int i = 0; i < 35; i++) {
    motion.tick(0.016);
  }
  // After pause clears + a few movement ticks, position should differ from initial
  // ONLY if target picking + movement work. For Task 4 we just verify _target was set
  // by checking position has begun moving (position-target distance > 0).
  // We expose internal target via a debug getter for tests OR we infer from movement.
  // Since we want to keep _target private, assert via movement: tick more,
  // verify position changed.
  final beforeX = motion.position.dx;
  for (int i = 0; i < 30; i++) {
    motion.tick(0.016);
  }
  // Without movement logic in tick, position.dx stays the same. With target picked
  // but no movement logic, also stays the same. Task 4 only adds _pickNewTarget;
  // Task 5 adds movement. So this test SHOULD still pass without change in dx —
  // we need a different signal that target was picked.
});
```

Better: expose `_target` via a `@visibleForTesting` getter.

Add to FishMotion (in Task 4 step 3 below):
```dart
@visibleForTesting
Offset get debugTarget => _target;
```

And update the test:

```dart
test('first target is picked after initial pause expires', () {
  // Tick past the initial 0.25s pause so _pickNewTarget runs
  for (int i = 0; i < 30; i++) {
    motion.tick(0.016);
  }
  // After picking, target should differ from initial position (which was the seed)
  expect(motion.debugTarget, isNot(equals(Offset(150, 80))));  // initial seeded position
  // And target must be within layer band
  final layerCenter = 0.4 * 200;  // 80
  final layerHalf = 0.15 * 200;   // 30
  expect(motion.debugTarget.dy, inInclusiveRange(layerCenter - layerHalf, layerCenter + layerHalf));
  // And within glass bounds
  expect(motion.debugTarget.dx, inInclusiveRange(motion.glassMargin + motion.fishSize, 300 - motion.glassMargin - motion.fishSize));
});
```

Add `import 'package:flutter/foundation.dart';` to fish_motion.dart for `@visibleForTesting`.

**Step 2 (re-run): Run test, verify it fails**

```bash
flutter test test/widgets/room/fish_motion_test.dart
```

Expected: FAIL — `debugTarget` not defined OR `_pickNewTarget` not implemented so target equals initial position.

**Step 3: Implement**

Add to `FishMotion`:

```dart
import 'package:flutter/foundation.dart';
// ... existing imports

@visibleForTesting
Offset get debugTarget => _target;

void _pickNewTarget() {
  final minX = glassMargin + fishSize;
  final maxX = tankWidth - glassMargin - fishSize;

  final layerCenter = baseTopFraction * tankHeight;
  final layerHalf = layerHalfHeightFraction * tankHeight;
  final minY = (glassMargin + fishSize).clamp(0.0, double.infinity).toDouble();
  final maxY = (tankHeight * sandFraction - fishSize).clamp(0.0, tankHeight);
  final boundedMinY = (layerCenter - layerHalf < minY) ? minY : layerCenter - layerHalf;
  final boundedMaxY = (layerCenter + layerHalf > maxY) ? maxY : layerCenter + layerHalf;

  // Uniform random within bounds (edge bias added in Task 8)
  final tx = minX + (maxX - minX) * _rng.nextDouble();
  final ty = boundedMinY + (boundedMaxY - boundedMinY) * _rng.nextDouble();
  _target = Offset(tx, ty);
}
```

Update `tick`:

```dart
void tick(double dt) {
  if (dt <= 0) return;
  final clampedDt = dt > 0.1 ? 0.1 : dt;
  _bobPhase += clampedDt * 2 * pi / bobPeriodSeconds;

  if (_pauseRemaining > 0) {
    _pauseRemaining -= clampedDt;
    if (_pauseRemaining <= 0) {
      _pickNewTarget();
    }
    return;
  }
}
```

**Step 4: Run test, verify it passes**

```bash
flutter test test/widgets/room/fish_motion_test.dart
```

Expected: PASS (9 tests total).

**Step 5: Commit**

```bash
git add lib/widgets/room/fish_motion.dart test/widgets/room/fish_motion_test.dart
git commit -m "feat(fish-motion): Task 4 — pick random target within layer band"
```

---

## Task 5: Movement toward target (constant speed, no easing)

**Files:**
- Modify: `lib/widgets/room/fish_motion.dart`
- Modify: `test/widgets/room/fish_motion_test.dart`

**Step 1: Write the failing test**

```dart
test('position moves toward target after pause clears', () {
  // Clear initial pause + pick first target
  for (int i = 0; i < 30; i++) {
    motion.tick(0.016);
  }
  final positionAfterTargetPicked = motion.position;
  final target = motion.debugTarget;

  // Tick more — position should move toward target
  for (int i = 0; i < 30; i++) {
    motion.tick(0.016);
  }
  final positionAfterMovement = motion.position;

  // Distance to target should have decreased
  final distBefore = (target - positionAfterTargetPicked).distance;
  final distAfter = (target - positionAfterMovement).distance;
  expect(distAfter, lessThan(distBefore));
});
```

**Step 2: Run, verify fail**

Expected: FAIL — distance unchanged because no movement code yet.

**Step 3: Implement**

Update `tick`:

```dart
void tick(double dt) {
  if (dt <= 0) return;
  final clampedDt = dt > 0.1 ? 0.1 : dt;
  _bobPhase += clampedDt * 2 * pi / bobPeriodSeconds;

  if (_pauseRemaining > 0) {
    _pauseRemaining -= clampedDt;
    if (_pauseRemaining <= 0) {
      _pickNewTarget();
    }
    return;
  }

  final toTarget = _target - _position;
  final distance = toTarget.distance;

  if (distance < fishSize * 0.25) {
    // Arrived — handled in Task 6 (hover phase)
    return;
  }

  // Constant speed for now (Task 7 adds the speed model)
  final direction = Offset(toTarget.dx / distance, toTarget.dy / distance);
  _position = Offset(
    _position.dx + direction.dx * maxSpeed * clampedDt,
    _position.dy + direction.dy * maxSpeed * clampedDt,
  );
}
```

**Step 4: Run, verify pass**

```bash
flutter test test/widgets/room/fish_motion_test.dart
```

Expected: PASS (10 tests).

**Step 5: Commit**

```bash
git add lib/widgets/room/fish_motion.dart test/widgets/room/fish_motion_test.dart
git commit -m "feat(fish-motion): Task 5 — move toward target at constant speed"
```

---

## Task 6: Arrival detection + hover phase

**Files:**
- Modify: `lib/widgets/room/fish_motion.dart`
- Modify: `test/widgets/room/fish_motion_test.dart`

**Step 1: Write the failing test**

```dart
test('isHovering becomes true after fish reaches a target', () {
  bool everHovered = false;
  for (int i = 0; i < 600; i++) {  // 10 seconds
    motion.tick(0.016);
    if (motion.isHovering) {
      everHovered = true;
      break;
    }
  }
  expect(everHovered, isTrue);
});

test('after hover, a new target is picked', () {
  // Run until first hover
  for (int i = 0; i < 600; i++) {
    motion.tick(0.016);
    if (motion.isHovering) break;
  }
  expect(motion.isHovering, isTrue);
  final firstHoverTarget = motion.debugTarget;

  // Run until hover ends + new target picked
  for (int i = 0; i < 100; i++) {
    motion.tick(0.016);
    if (!motion.isHovering) break;
  }
  expect(motion.isHovering, isFalse);
  // Tick a few more to let _pickNewTarget run on the next cycle
  for (int i = 0; i < 5; i++) {
    motion.tick(0.016);
  }
  expect(motion.debugTarget, isNot(equals(firstHoverTarget)));
});
```

**Step 2: Run, verify fail**

Expected: FAIL — isHovering is never set to true because the arrival branch returns silently.

**Step 3: Implement**

Update the arrival branch in `tick`:

```dart
if (distance < fishSize * 0.25) {
  // Arrived — enter hover phase with random pause 0.3-0.8s
  _pauseRemaining = 0.3 + _rng.nextDouble() * 0.5;
  _speed = 0;
  return;
}
```

**Step 4: Run, verify pass**

```bash
flutter test test/widgets/room/fish_motion_test.dart
```

Expected: PASS (12 tests).

**Step 5: Commit**

```bash
git add lib/widgets/room/fish_motion.dart test/widgets/room/fish_motion_test.dart
git commit -m "feat(fish-motion): Task 6 — arrival hover phase + retarget"
```

---

## Task 7: Speed model (ease-out + wall slowdown)

**Files:**
- Modify: `lib/widgets/room/fish_motion.dart`
- Modify: `test/widgets/room/fish_motion_test.dart`

**Step 1: Write the failing test**

```dart
test('speed varies — slower near target, faster at midpoint', () {
  // Force a known target position so we can sample speed at known distances
  // Run for a bit to clear pause
  for (int i = 0; i < 30; i++) {
    motion.tick(0.016);
  }

  // Sample distances: keep ticking and record (distance, speed-equivalent)
  final samples = <double>[];
  for (int i = 0; i < 200; i++) {
    final beforePos = motion.position;
    motion.tick(0.016);
    final delta = (motion.position - beforePos).distance / 0.016;
    samples.add(delta);
  }

  // Filter out zero-speed (hover) frames
  final nonZeroSamples = samples.where((s) => s > 0.1).toList();
  expect(nonZeroSamples, isNotEmpty);

  // Speed should vary (not constant at maxSpeed)
  final maxObserved = nonZeroSamples.reduce((a, b) => a > b ? a : b);
  final minObserved = nonZeroSamples.reduce((a, b) => a < b ? a : b);
  expect(maxObserved - minObserved, greaterThan(2.0),
    reason: 'expected speed to vary by at least 2 px/sec');
});
```

**Step 2: Run, verify fail**

Expected: FAIL — current implementation uses constant `maxSpeed`, samples are nearly identical.

**Step 3: Implement**

Add speed model to `tick` (replaces the constant-speed movement section):

```dart
// Wall proximity factor — 0 at any wall, 1 mid-tank
final comfortDistance = fishSize * 2;
final xMargin = (_position.dx - glassMargin) < (tankWidth - glassMargin - _position.dx)
    ? (_position.dx - glassMargin)
    : (tankWidth - glassMargin - _position.dx);
final yMargin = (_position.dy - glassMargin) < (tankHeight * sandFraction - _position.dy)
    ? (_position.dy - glassMargin)
    : (tankHeight * sandFraction - _position.dy);
final xFactor = (xMargin / comfortDistance).clamp(0.0, 1.0);
final yFactor = (yMargin / comfortDistance).clamp(0.0, 1.0);
final edgeFactor = xFactor < yFactor ? xFactor : yFactor;

// Approach factor — 0 right at target, 1 outside deceleration radius
final decelDistance = tankWidth * 0.18;
final approachFactor = (distance / decelDistance).clamp(0.0, 1.0);

// Target speed and smooth easing
final targetSpeed = minSpeed + (maxSpeed - minSpeed) * approachFactor * edgeFactor;
_speed += (targetSpeed - _speed) * (clampedDt * 4 < 1 ? clampedDt * 4 : 1);

final direction = Offset(toTarget.dx / distance, toTarget.dy / distance);
_position = Offset(
  _position.dx + direction.dx * _speed * clampedDt,
  _position.dy + direction.dy * _speed * clampedDt,
);
```

**Step 4: Run, verify pass**

```bash
flutter test test/widgets/room/fish_motion_test.dart
```

Expected: PASS (13 tests).

**Step 5: Commit**

```bash
git add lib/widgets/room/fish_motion.dart test/widgets/room/fish_motion_test.dart
git commit -m "feat(fish-motion): Task 7 — speed model (ease-out + wall slowdown)"
```

---

## Task 8: Wander (perpendicular noise)

**Files:**
- Modify: `lib/widgets/room/fish_motion.dart`
- Modify: `test/widgets/room/fish_motion_test.dart`

**Step 1: Write the failing test**

```dart
test('position wanders perpendicular to direction of travel', () {
  // Reseed with a far target for a long straight journey
  for (int i = 0; i < 30; i++) {
    motion.tick(0.016);  // get past initial pause + pick target
  }

  final samples = <Offset>[];
  for (int i = 0; i < 60; i++) {
    motion.tick(0.016);
    samples.add(motion.position);
  }

  // Compute the average straight-line slope vs. actual zigzag
  // A pure straight-line motion has zero variance perpendicular to direction.
  // With wander, samples should NOT all lie on the line from samples[0] to samples[-1].
  final start = samples.first;
  final end = samples.last;
  final lineDir = (end - start);
  final lineLength = lineDir.distance;
  if (lineLength < 1) {
    // Not enough movement to test
    return;
  }
  final unit = Offset(lineDir.dx / lineLength, lineDir.dy / lineLength);

  double maxPerpDeviation = 0;
  for (final s in samples) {
    final v = s - start;
    // perpendicular component magnitude
    final perp = (v.dx * -unit.dy + v.dy * unit.dx).abs();
    if (perp > maxPerpDeviation) maxPerpDeviation = perp;
  }
  expect(maxPerpDeviation, greaterThan(0.5),
    reason: 'expected wander to produce >0.5 px lateral deviation');
});
```

**Step 2: Run, verify fail**

Expected: FAIL — current motion is straight-line, perp deviation is ~0.

**Step 3: Implement**

Add wander after the position update in `tick`:

```dart
// Wander: small perpendicular noise
final perpendicular = Offset(-direction.dy, direction.dx);
final wanderAmount = (_rng.nextDouble() - 0.5) * 0.5 * clampedDt * _speed;
_position = Offset(
  _position.dx + perpendicular.dx * wanderAmount,
  _position.dy + perpendicular.dy * wanderAmount,
);
```

**Step 4: Run, verify pass**

```bash
flutter test test/widgets/room/fish_motion_test.dart
```

Expected: PASS (14 tests).

**Step 5: Commit**

```bash
git add lib/widgets/room/fish_motion.dart test/widgets/room/fish_motion_test.dart
git commit -m "feat(fish-motion): Task 8 — perpendicular wander noise"
```

---

## Task 9: Edge bias in target selection

**Files:**
- Modify: `lib/widgets/room/fish_motion.dart`
- Modify: `test/widgets/room/fish_motion_test.dart`

**Step 1: Write the failing test**

```dart
test('fish near left wall picks targets in right portion', () {
  // Force fish to the left wall by manually placing it there
  motion.seedInitialPosition(phaseOffset: 0);  // far left
  // Tick past initial pause
  for (int i = 0; i < 30; i++) {
    motion.tick(0.016);
  }
  // First target should be biased right
  expect(motion.debugTarget.dx, greaterThan(300 * 0.40),
    reason: 'fish near left wall should pick target in right 60%');
});

test('fish near right wall picks targets in left portion', () {
  motion.seedInitialPosition(phaseOffset: 1.0);  // far right
  for (int i = 0; i < 30; i++) {
    motion.tick(0.016);
  }
  expect(motion.debugTarget.dx, lessThan(300 * 0.60),
    reason: 'fish near right wall should pick target in left 60%');
});
```

**Step 2: Run, verify fail**

Expected: FAIL — uniform random doesn't bias.

**Step 3: Implement**

Add helper to `FishMotion`:

```dart
({double start, double end}) _biasAwayFromCurrentEdge(
  double current,
  double min,
  double max,
) {
  final total = max - min;
  if (total <= 0) return (start: min, end: max);
  final fraction = (current - min) / total;
  if (fraction < 0.33) {
    return (start: min + total * 0.40, end: max);
  }
  if (fraction > 0.67) {
    return (start: min, end: min + total * 0.60);
  }
  return (start: min, end: max);
}
```

Update `_pickNewTarget`:

```dart
void _pickNewTarget() {
  final minX = glassMargin + fishSize;
  final maxX = tankWidth - glassMargin - fishSize;

  final layerCenter = baseTopFraction * tankHeight;
  final layerHalf = layerHalfHeightFraction * tankHeight;
  final minYBound = (glassMargin + fishSize).toDouble();
  final maxYBound = (tankHeight * sandFraction - fishSize).clamp(0.0, tankHeight);
  final minY = layerCenter - layerHalf < minYBound ? minYBound : layerCenter - layerHalf;
  final maxY = layerCenter + layerHalf > maxYBound ? maxYBound : layerCenter + layerHalf;

  final xRange = _biasAwayFromCurrentEdge(_position.dx, minX, maxX);
  final yRange = _biasAwayFromCurrentEdge(_position.dy, minY, maxY);

  // Try up to 5 samples for minTravelDistance
  final minTravel = tankWidth * 0.25;
  Offset candidate = _position;
  for (int i = 0; i < 5; i++) {
    candidate = Offset(
      xRange.start + (xRange.end - xRange.start) * _rng.nextDouble(),
      yRange.start + (yRange.end - yRange.start) * _rng.nextDouble(),
    );
    if ((candidate - _position).distance >= minTravel) break;
  }
  _target = candidate;
}
```

**Step 4: Run, verify pass**

```bash
flutter test test/widgets/room/fish_motion_test.dart
```

Expected: PASS (16 tests).

**Step 5: Commit**

```bash
git add lib/widgets/room/fish_motion.dart test/widgets/room/fish_motion_test.dart
git commit -m "feat(fish-motion): Task 9 — edge-aware target bias"
```

---

## Task 10: facingRight derivation + sine bob in position getter

**Files:**
- Modify: `lib/widgets/room/fish_motion.dart`
- Modify: `test/widgets/room/fish_motion_test.dart`

**Step 1: Write the failing test**

```dart
test('facingRight reflects horizontal velocity sign', () {
  // Force fish at left, target should be to the right → facingRight = true
  motion.seedInitialPosition(phaseOffset: 0);
  for (int i = 0; i < 30; i++) {
    motion.tick(0.016);
  }
  // Now moving — facingRight should match sign of (target - position).dx
  final dx = motion.debugTarget.dx - motion.position.dx;
  if (dx.abs() > 0.5) {
    expect(motion.facingRight, equals(dx > 0));
  }
});

test('position has sine bob layered on Y', () {
  motion.seedInitialPosition(phaseOffset: 0.5);
  // Sample Y over time without horizontal movement (force pause)
  // Approximate by sampling rapidly while pauseRemaining > 0
  final samples = <double>[];
  for (int i = 0; i < 30; i++) {
    motion.tick(0.016);
    samples.add(motion.position.dy);
  }
  // With bob amplitude 6.0 default, Y should oscillate by at least 1.0 px
  final maxY = samples.reduce((a, b) => a > b ? a : b);
  final minY = samples.reduce((a, b) => a < b ? a : b);
  expect(maxY - minY, greaterThan(1.0),
    reason: 'sine bob should produce Y oscillation');
});
```

**Step 2: Run, verify fail**

Expected: FAIL — `facingRight` is hardcoded to `_lastFacingRight = true`; position getter returns `_position` without bob.

**Step 3: Implement**

Replace the `position` getter:

```dart
Offset get position {
  final bobOffset = sin(_bobPhase) * bobAmplitude;
  return Offset(_position.dx, _position.dy + bobOffset);
}
```

Replace the `facingRight` getter:

```dart
bool get facingRight {
  final dx = _target.dx - _position.dx;
  if (dx.abs() < 0.01) return _lastFacingRight;
  _lastFacingRight = dx > 0;
  return _lastFacingRight;
}
```

Note: `facingRight` mutates `_lastFacingRight`. The getter is impure but the mutation is idempotent (same `dx` always produces same result). If you prefer pure: extract the mutation into a `_updateFacing()` call inside `tick()`.

**Step 4: Run, verify pass**

```bash
flutter test test/widgets/room/fish_motion_test.dart
```

Expected: PASS (18 tests).

**Step 5: Commit**

```bash
git add lib/widgets/room/fish_motion.dart test/widgets/room/fish_motion_test.dart
git commit -m "feat(fish-motion): Task 10 — facingRight + sine bob layered"
```

---

## Task 11: BUG-08 hard clamp + R-088 finite invariant

**Files:**
- Modify: `lib/widgets/room/fish_motion.dart`
- Modify: `test/widgets/room/fish_motion_test.dart`

**Step 1: Write the failing test**

```dart
test('position stays within glass bounds across 100 simulated seconds', () {
  motion.seedInitialPosition(phaseOffset: 0.5);
  for (int i = 0; i < 6000; i++) {  // ~100 sec at 60fps
    motion.tick(0.016);
    expect(motion.position.dx.isFinite, isTrue);
    expect(motion.position.dy.isFinite, isTrue);
    // Underlying _position must be within glass; position getter adds bob (small)
    expect(motion.position.dx, inInclusiveRange(motion.glassMargin, 300 - motion.glassMargin));
    // Y has bob added, so allow bob amplitude on top of sand boundary
    expect(motion.position.dy, lessThan(200 * 0.78 + motion.bobAmplitude + 1));
  }
});

test('extreme dt does not produce out-of-bounds position', () {
  motion.seedInitialPosition(phaseOffset: 0);
  for (int i = 0; i < 30; i++) {
    motion.tick(0.016);  // get past pause
  }
  motion.tick(100.0);  // huge dt — should be clamped to 0.1
  expect(motion.position.dx, inInclusiveRange(motion.glassMargin, 300 - motion.glassMargin));
});

test('zero tank dimensions do not produce NaN', () {
  final degenerate = FishMotion(
    tankWidth: 0,
    tankHeight: 0,
    fishSize: 20,
    rng: Random(42),
  );
  degenerate.seedInitialPosition(phaseOffset: 0.5);
  // tick should not crash and getters should not throw
  expect(() => degenerate.tick(0.016), returnsNormally);
  // Position may not be finite — that's the widget's R-088 check problem
});
```

**Step 2: Run, verify fail**

Expected: bounds test may FAIL because we don't have the explicit clamp at the end of `tick`.

**Step 3: Implement**

Add explicit clamp at the end of `tick` (after wander):

```dart
// BUG-08 hard clamp — last line of defense
final minXC = glassMargin + fishSize / 2;
final maxXC = tankWidth - glassMargin - fishSize / 2;
final minYC = glassMargin + fishSize / 2;
final maxYC = tankHeight * sandFraction - fishSize / 2;
final clampedX = _position.dx.clamp(
  minXC < maxXC ? minXC : maxXC,
  minXC < maxXC ? maxXC : minXC,
);
final clampedY = _position.dy.clamp(
  minYC < maxYC ? minYC : maxYC,
  minYC < maxYC ? maxYC : minYC,
);
_position = Offset(clampedX, clampedY);
```

(The min/max swap handles the degenerate case where tankWidth ≤ 2 * glassMargin + fishSize.)

**Step 4: Run, verify pass**

```bash
flutter test test/widgets/room/fish_motion_test.dart
```

Expected: PASS (21 tests).

**Step 5: Commit**

```bash
git add lib/widgets/room/fish_motion.dart test/widgets/room/fish_motion_test.dart
git commit -m "feat(fish-motion): Task 11 — BUG-08 hard clamp + bounds invariant"
```

---

## Task 12: Migrate AnimatedSwimmingFish to use FishMotion

**Files:**
- Modify: `repo/apps/aquarium_app/lib/widgets/room/animated_swimming_fish.dart`
- Modify (if exists): `repo/apps/aquarium_app/test/widgets/room/animated_swimming_fish_test.dart`

**Pre-step: Identify existing tests**

```bash
cd repo/apps/aquarium_app
find test -name "*animated_swimming*" -o -name "*animated_fish*"
grep -rn "AnimatedSwimmingFish" test/ | head -20
```

If a test file exists, read it. Note any test asserting exact `Positioned.left`, `Positioned.top`, or fish facing direction at a specific frame — these need migration to bounds assertions in this commit.

**Step 1: Write the (new or updated) widget test**

Create or update `test/widgets/room/animated_swimming_fish_test.dart`:

```dart
import 'package:danio/widgets/room/animated_swimming_fish.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimatedSwimmingFish', () {
    Widget wrap(Widget child, {bool reduceMotion = false}) {
      return MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 200,
              child: Stack(children: [child]),
            ),
          ),
        ),
      );
    }

    testWidgets('renders without exceptions', (tester) async {
      await tester.pumpWidget(wrap(const AnimatedSwimmingFish(
        size: 20,
        color: Colors.red,
        tankWidth: 300,
        tankHeight: 200,
      )));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('fish stays within tank bounds over 5 seconds', (tester) async {
      await tester.pumpWidget(wrap(const AnimatedSwimmingFish(
        size: 20,
        color: Colors.red,
        tankWidth: 300,
        tankHeight: 200,
      )));
      for (int i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        final positioned = tester.widget<Positioned>(find.byType(Positioned));
        expect(positioned.left!, inInclusiveRange(-1, 301));
        expect(positioned.top!, inInclusiveRange(-1, 201));
      }
    });

    testWidgets('reduced motion freezes fish', (tester) async {
      await tester.pumpWidget(wrap(
        const AnimatedSwimmingFish(
          size: 20,
          color: Colors.red,
          tankWidth: 300,
          tankHeight: 200,
        ),
        reduceMotion: true,
      ));
      await tester.pump(const Duration(milliseconds: 100));
      final pos1 = tester.widget<Positioned>(find.byType(Positioned)).left!;
      await tester.pump(const Duration(seconds: 5));
      final pos2 = tester.widget<Positioned>(find.byType(Positioned)).left!;
      expect(pos1, equals(pos2));
    });

    testWidgets('disposes cleanly without late-callback exception', (tester) async {
      await tester.pumpWidget(wrap(const AnimatedSwimmingFish(
        size: 20,
        color: Colors.red,
        tankWidth: 300,
        tankHeight: 200,
      )));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });
  });
}
```

**Step 2: Run test, verify it fails (or passes against old impl)**

```bash
flutter test test/widgets/room/animated_swimming_fish_test.dart
```

Some tests may already pass against the old implementation (the bounds tests are loose enough to pass either way). The "reduced motion freezes" test will likely PASS too because the existing 5-min duration acts the same. That's fine — these tests are bounds invariants, not behavior change detectors. The behavior change is verified by the engine unit tests + manual emulator check.

**Step 3: Rewrite `animated_swimming_fish.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'fish_motion.dart';
import 'fish_painter.dart';

/// Animated fish that swims with goal-seeking motion across the tank.
///
/// Wraps [SoftFish] in a RepaintBoundary to prevent full-tree repaints on
/// every animation tick.
class AnimatedSwimmingFish extends StatefulWidget {
  final double size;
  final Color color;
  final double swimSpeed;       // seconds to traverse the tank at top speed
  final double verticalBob;     // bob amplitude in px
  final double startOffset;     // 0-1, phase offset for de-syncing fish
  final double tankWidth;
  final double tankHeight;
  final double baseTop;         // base Y fraction of tank height (0-1)

  const AnimatedSwimmingFish({
    super.key,
    required this.size,
    required this.color,
    required this.tankWidth,
    required this.tankHeight,
    this.swimSpeed = 8.0,
    this.verticalBob = 15.0,
    this.startOffset = 0.0,
    this.baseTop = 0.3,
  });

  @override
  State<AnimatedSwimmingFish> createState() => _AnimatedSwimmingFishState();
}

class _AnimatedSwimmingFishState extends State<AnimatedSwimmingFish>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late FishMotion _motion;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _motion = _buildMotion();
    _motion.seedInitialPosition(phaseOffset: widget.startOffset);
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ticker.muted = MediaQuery.of(context).disableAnimations;
  }

  @override
  void didUpdateWidget(covariant AnimatedSwimmingFish oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tankWidth != widget.tankWidth ||
        oldWidget.tankHeight != widget.tankHeight ||
        oldWidget.size != widget.size ||
        oldWidget.swimSpeed != widget.swimSpeed) {
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
    final dtMicros = (elapsed - _lastElapsed).inMicroseconds;
    _lastElapsed = elapsed;
    final dt = dtMicros / 1e6;
    if (dt <= 0) return;
    _motion.tick(dt);
    if (mounted) setState(() {});
  }

  FishMotion _buildMotion() {
    final tw = widget.tankWidth > 0 ? widget.tankWidth : 1;
    final speed = widget.swimSpeed > 0 ? widget.swimSpeed : 8;
    return FishMotion(
      tankWidth: widget.tankWidth,
      tankHeight: widget.tankHeight,
      fishSize: widget.size,
      baseTopFraction: widget.baseTop,
      layerHalfHeightFraction: 0.18,
      maxSpeed: tw / speed,
      minSpeed: (tw / speed) * 0.25,
      bobAmplitude: widget.verticalBob,
      bobPeriodSeconds: speed * 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pos = _motion.position;
    // R-088 finite guard at the render boundary
    if (!pos.dx.isFinite || !pos.dy.isFinite) {
      return const SizedBox.shrink();
    }
    return Positioned(
      left: pos.dx - widget.size / 2,
      top: pos.dy - widget.size / 2,
      child: RepaintBoundary(
        child: Transform.scale(
          scaleX: _motion.facingRight ? 1 : -1,
          child: SoftFish(size: widget.size, color: widget.color),
        ),
      ),
    );
  }
}
```

**Step 4: Run tests**

```bash
flutter test test/widgets/room/animated_swimming_fish_test.dart
flutter test test/widgets/room/fish_motion_test.dart
flutter analyze
```

Expected: all PASS, analyze clean. If any pre-existing test asserts exact positions, migrate it to bounds-assertion form per the design doc §"Existing Test Migration".

**Step 5: Commit**

```bash
git add lib/widgets/room/animated_swimming_fish.dart test/widgets/room/animated_swimming_fish_test.dart
git commit -m "feat(fish-motion): Task 12 — migrate AnimatedSwimmingFish to FishMotion engine"
```

---

## Task 13: Migrate SpeciesFish to use FishMotion

**Files:**
- Modify: `repo/apps/aquarium_app/lib/widgets/room/species_fish.dart`
- Modify (if exists): `repo/apps/aquarium_app/test/widgets/room/species_fish_test.dart`

**Pre-step: Read the full species_fish.dart**

```bash
cd repo/apps/aquarium_app
wc -l lib/widgets/room/species_fish.dart
```

Read the entire file. Note:
- Existing `_x`, `_speedX`, `_paused`, `_lastElapsed` fields and their usage
- Depth scaling logic (size, opacity, speed multipliers)
- Sprite loading from `assets/images/fish/<speciesId>.png`
- `FishTapInteraction` wrapper if present
- Any custom `_baseSize` constant

The migration replaces the motion state but preserves rendering, depth scaling, sprite loading, and tap interaction wiring. Do not delete any of these.

**Pre-step: Grep existing tests**

```bash
grep -rn "SpeciesFish" test/ | head -20
```

Note any positional assertions for migration.

**Step 1: Write the widget test**

Create or update `test/widgets/room/species_fish_test.dart` with the same shape as `animated_swimming_fish_test.dart`:

```dart
import 'package:danio/widgets/room/species_fish.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpeciesFish', () {
    Widget wrap(Widget child, {bool reduceMotion = false}) {
      return MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 200,
              child: Stack(children: [child]),
            ),
          ),
        ),
      );
    }

    testWidgets('renders without exceptions', (tester) async {
      await tester.pumpWidget(wrap(const SpeciesFish(
        speciesId: 'neon_tetra',
        tankWidth: 300,
        tankHeight: 200,
      )));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('fish stays within tank bounds over 5 seconds', (tester) async {
      await tester.pumpWidget(wrap(const SpeciesFish(
        speciesId: 'neon_tetra',
        tankWidth: 300,
        tankHeight: 200,
      )));
      for (int i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        final positioned = tester.widget<Positioned>(find.byType(Positioned));
        expect(positioned.left!, inInclusiveRange(-5, 305));
        expect(positioned.top!, inInclusiveRange(-5, 205));
      }
    });

    testWidgets('reduced motion freezes fish', (tester) async {
      await tester.pumpWidget(wrap(
        const SpeciesFish(
          speciesId: 'neon_tetra',
          tankWidth: 300,
          tankHeight: 200,
        ),
        reduceMotion: true,
      ));
      await tester.pump(const Duration(milliseconds: 100));
      final pos1 = tester.widget<Positioned>(find.byType(Positioned)).left!;
      await tester.pump(const Duration(seconds: 5));
      final pos2 = tester.widget<Positioned>(find.byType(Positioned)).left!;
      expect(pos1, equals(pos2));
    });
  });
}
```

**Step 2: Run, verify failure mode**

```bash
flutter test test/widgets/room/species_fish_test.dart
```

If tests pass against the old implementation, that's fine — they're bounds invariants. If they fail because the old implementation doesn't honor `MediaQueryData(disableAnimations: true)`, even better — that proves the migration adds value.

**Step 3: Rewrite species_fish.dart**

This is the larger of the two migrations. Preserve everything the original file does EXCEPT the `_x`/`_speedX`/`_paused`/`_lastElapsed` motion state. Replace with `FishMotion` + the same Ticker pattern as Task 12.

Key migration steps:
1. Add `import 'fish_motion.dart';`
2. Replace `late AnimationController _ticker;` with `late Ticker _ticker;` (or keep the AnimationController name if the existing code uses it as a frame source — verify by reading the file)
3. Delete `_x`, `_speedX`, `_paused`, `_lastElapsed` fields
4. Add `late FishMotion _motion;` and `Duration _lastElapsed = Duration.zero;`
5. In `initState`: create motion via `_buildMotion()`, seed with `phaseOffset`, start ticker
6. Add `didChangeDependencies` for `_ticker.muted`
7. Add `didUpdateWidget` for tank-size reseed
8. Replace the existing tick callback with the `_onTick` from Task 12 pattern
9. Replace position calculation in `build()` with `_motion.position` + finite check
10. Use `_motion.facingRight` for the flip transform
11. Preserve depth scaling, sprite loading, opacity, and tap interaction wrapper

Parameter mapping:
```dart
FishMotion _buildMotion() {
  final depthScale = 1.0 - widget.depth * 0.4;
  final effectiveSize = _baseSize * depthScale;  // _baseSize from species data
  return FishMotion(
    tankWidth: widget.tankWidth,
    tankHeight: widget.tankHeight,
    fishSize: effectiveSize,
    baseTopFraction: widget.baseTop,
    layerHalfHeightFraction: 0.20,
    maxSpeed: widget.baseSpeed * depthScale,
    minSpeed: widget.baseSpeed * depthScale * 0.25,
    bobAmplitude: widget.bobAmplitude,
    bobPeriodSeconds: widget.bobPeriod,
  );
}
```

**Step 4: Run tests**

```bash
flutter test test/widgets/room/species_fish_test.dart
flutter test test/widgets/room/
flutter analyze
```

Expected: all PASS, analyze clean. Migrate any positional tests that broke.

**Step 5: Commit**

```bash
git add lib/widgets/room/species_fish.dart test/widgets/room/species_fish_test.dart
git commit -m "feat(fish-motion): Task 13 — migrate SpeciesFish to FishMotion engine"
```

---

## Task 14: Full suite verification + manual emulator check

**Files:** None modified in this task — this is verification only.

**Step 1: Run full test suite**

```bash
cd repo/apps/aquarium_app
flutter analyze
```
Expected: clean.

```bash
flutter test
```
Expected: all 826+ tests pass. If any pre-existing test failed because it asserted exact fish positions, migrate it to bounds-assertion form in a separate "test: migrate fish position assertions to bounds" commit.

**Step 2: Manual emulator verification**

Start an Android emulator and:

```bash
flutter run --profile
```

Then:
1. Open the app, enter the tank screen
2. If you have a fresh install (no unlocked species), verify the 3 fallback fish move with the new goal-seek motion (look for: variable speed, direction changes mid-tank, brief pauses)
3. Open Settings → Accessibility → enable Reduce Motion (or use device-level reduce motion)
4. Verify fish freeze in place
5. Disable reduce motion → verify fish resume smoothly without jumping
6. Tap the FPS overlay (or use DevTools): verify FPS stays ≥ 55 over 30 seconds

Take a screenshot of the FPS overlay during normal motion. Save it to:
```
repo/docs/testing/danio-fix-brief-2026-04/phase-5/fish-motion-fps.png
```

**Step 3: Commit verification artifacts (if any)**

```bash
git add docs/testing/danio-fix-brief-2026-04/phase-5/
git commit -m "test(fish-motion): Task 14 — emulator verification artifacts"
```

(Skip if no artifacts produced.)

**Step 4: Push the branch**

⚠️ **Confirm with the user before pushing.** Do not push without explicit user approval.

```bash
git push -u origin feature/danio-fix-brief-phase-5
```

---

## Done

The fish motion rewrite portion of Phase 5 is complete. The remaining Phase 5 work (banner unification + side panel redesign) is out of scope for this plan and will be brainstormed separately in a future session.

**Important constraints honored:**
- ✅ No `AnimationStatus` listeners that recurse (Ticker has no status events)
- ✅ Reduced motion handled via `Ticker.muted` (no `Duration.zero` assertion possible)
- ✅ R-088 non-finite guards (engine clamp + widget render boundary check)
- ✅ BUG-08 boundary clamps (engine `tick()` end-of-tick clamp)
- ✅ `RepaintBoundary` optimization preserved
- ✅ Public widget APIs preserved on both `AnimatedSwimmingFish` and `SpeciesFish` — zero call-site changes

**Files touched:**
- `lib/widgets/room/fish_motion.dart` (new)
- `lib/widgets/room/animated_swimming_fish.dart` (rewritten internals, public API unchanged)
- `lib/widgets/room/species_fish.dart` (rewritten internals, public API unchanged)
- `test/widgets/room/fish_motion_test.dart` (new)
- `test/widgets/room/animated_swimming_fish_test.dart` (new or updated)
- `test/widgets/room/species_fish_test.dart` (new or updated)

**Files explicitly NOT touched:**
- `lib/widgets/room/fish_painter.dart`
- `lib/widgets/room/themed_aquarium.dart`
- `lib/widgets/room/tank_fish_manager.dart`

**Total commits:** 14 (Tasks 1–11 = engine TDD, Task 12 = AnimatedSwimmingFish migration, Task 13 = SpeciesFish migration, Task 14 = verification).
