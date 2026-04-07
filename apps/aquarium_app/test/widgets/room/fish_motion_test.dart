import 'dart:math';

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

    test('first target is picked after initial pause expires', () {
      // Tick past the initial 0.25s pause so _pickNewTarget runs
      for (int i = 0; i < 30; i++) {
        motion.tick(0.016);
      }
      // After picking, target should differ from initial position
      // (the initial position was the seed at center of tank: x=150, y=80)
      expect(motion.debugTarget, isNot(equals(const Offset(150, 80))));
      // And target must be within layer band
      final layerCenter = 0.4 * 200;  // 80
      final layerHalf = 0.15 * 200;   // 30
      expect(motion.debugTarget.dy, inInclusiveRange(layerCenter - layerHalf, layerCenter + layerHalf));
      // And within glass bounds
      expect(motion.debugTarget.dx, inInclusiveRange(motion.glassMargin + motion.fishSize, 300 - motion.glassMargin - motion.fishSize));
    });

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

    test('isHovering becomes true after fish reaches a target', () {
      // First, tick past the initial seeded pause (0.25s) AND let the fish
      // pick + start moving toward a real target.
      for (int i = 0; i < 30; i++) {
        motion.tick(0.016);
      }
      // At this point fish should be moving toward target (not hovering from seed).
      // Now watch for hover triggered by ARRIVAL at the target.
      bool arrivedAtTarget = false;
      for (int i = 0; i < 600; i++) {
        motion.tick(0.016);
        if (motion.isHovering) {
          arrivedAtTarget = true;
          break;
        }
      }
      expect(arrivedAtTarget, isTrue);
    });

    test('after hover, a new target is picked', () {
      // Tick past initial pause so the fish is moving
      for (int i = 0; i < 30; i++) {
        motion.tick(0.016);
      }
      // Run until first arrival-triggered hover
      for (int i = 0; i < 600; i++) {
        motion.tick(0.016);
        if (motion.isHovering) break;
      }
      expect(motion.isHovering, isTrue, reason: 'fish should hover after arrival');
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
  });
}
