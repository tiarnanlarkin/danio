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
}
