import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('guide comparison headers use plain labels instead of raw symbols', () {
    final guideFiles = [
      'lib/screens/equipment_guide_screen.dart',
      'lib/screens/feeding_guide_screen.dart',
      'lib/screens/nitrogen_cycle_guide_screen.dart',
      'lib/screens/substrate_guide_screen.dart',
      'lib/screens/vacation_guide_screen.dart',
    ];

    for (final path in guideFiles) {
      final source = File(path).readAsStringSync();

      expect(source, isNot(contains('✓ Pros')), reason: path);
      expect(source, isNot(contains('✗ Cons')), reason: path);
      expect(source, contains("'Pros'"), reason: path);
      expect(source, contains("'Cons'"), reason: path);
    }
  });
}
