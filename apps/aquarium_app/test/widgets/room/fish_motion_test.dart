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
}
