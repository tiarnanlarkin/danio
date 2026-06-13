import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('onboarding includes region and units before experience level', () {
    final source = File(
      'lib/screens/onboarding_screen.dart',
    ).readAsStringSync();

    expect(source, contains("import 'onboarding/region_units_screen.dart';"));
    expect(source, contains('static const _totalPages = 12;'));
    expect(
      source.indexOf('RegionUnitsScreen('),
      lessThan(source.indexOf('ExperienceLevelScreen(')),
    );
    expect(source, contains('setUseMetric(_useMetricUnits)'));
    expect(source, contains('regionCode: _regionCode'));
    expect(source, contains('onSkip: _quickStart'));
  });
}
