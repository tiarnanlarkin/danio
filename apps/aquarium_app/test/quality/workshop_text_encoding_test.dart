import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Workshop screen copy does not contain mojibake sequences', () {
    final files = [
      'lib/screens/water_change_calculator_screen.dart',
      'lib/screens/stocking_calculator_screen.dart',
      'lib/screens/co2_calculator_screen.dart',
      'lib/screens/dosing_calculator_screen.dart',
      'lib/screens/unit_converter_screen.dart',
      'lib/screens/tank_volume_calculator_screen.dart',
      'lib/screens/lighting_schedule_screen.dart',
      'lib/screens/compatibility_checker_screen.dart',
      'lib/screens/cycling_assistant_screen.dart',
      'lib/screens/cost_tracker_screen.dart',
    ];

    final mojibakePattern = RegExp('[ÂÃâÏ]');
    final offenders = <String>[];

    for (final path in files) {
      final contents = File(path).readAsStringSync();
      if (mojibakePattern.hasMatch(contents)) {
        offenders.add(path);
      }
    }

    expect(offenders, isEmpty);
  });
}
