import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void _expectRegisteredTests(String path, Iterable<String> names) {
  final file = File(path);
  expect(file.existsSync(), isTrue, reason: 'Missing evidence file: $path');

  final source = file.readAsStringSync();
  for (final name in names) {
    final declaration = RegExp(
      "^\\s*test(?:Widgets)?\\s*\\(\\s*'${RegExp.escape(name)}'",
      multiLine: true,
    );
    expect(
      declaration.hasMatch(source),
      isTrue,
      reason: '$path is missing a registered test for: $name',
    );
  }
}

void main() {
  test(
    'accepted Workshop, Journal, Learning, species, plant, and source paths retain executable evidence',
    () {
      const evidence = <String, List<String>>{
        'test/widget_tests/workshop_screen_test.dart': [
          'opens Tank Volume with current tank context',
          'opens Compatibility with current tank context',
        ],
        'test/widget_tests/journal_screen_test.dart': [
          'labels saved calculator notes as tool results',
          'failed new entry save keeps sheet open with feedback',
        ],
        'test/data/lesson_data_test.dart': [
          'total lesson count matches LessonProvider metadata (82)',
          'every nitrogen cycle lesson has a structured guide',
        ],
        'test/widget_tests/lazy_learning_path_card_test.dart': [
          'opens a full-screen path detail view after path loads',
          'shows a retryable error when path loading fails',
        ],
        'test/widget_tests/species_browser_screen_test.dart': [
          'species detail shows source trail',
          'species detail opens prefilled stocking calculator',
          'species detail creates a tank care task',
        ],
        'test/widget_tests/plant_browser_screen_test.dart': [
          'plant detail shows source trail',
          'plant detail saves plant to wishlist',
        ],
        'test/quality/content_validation_test.dart': [
          'lesson and care sources are traceable https references',
          'species database is broad, unique, and has sane care ranges',
        ],
      };

      for (final entry in evidence.entries) {
        _expectRegisteredTests(entry.key, entry.value);
      }
    },
  );

  test(
    'CompatibilityService retains the complete release-candidate matrix',
    () {
      _expectRegisteredTests(
        'test/services/compatibility_service_test.dart',
        const [
          'temperature mismatches distinguish incompatible from edge warnings',
          'pH mismatches distinguish incompatible from edge warnings',
          'GH outside the target is reported as a warning',
          'tank size and school size produce their expected severities',
          'avoid lists report livestock conflicts',
          'aggressive temperament against peaceful livestock is warned',
          'large size differences report predation risk',
          'incompatible severity takes precedence over warnings',
        ],
      );
    },
  );

  test('Tank Volume retains numeric proof for all five shapes', () {
    _expectRegisteredTests(
      'test/widget_tests/tank_volume_calculator_screen_test.dart',
      const [
        'rectangular dimensions produce 54.0 litres',
        'cylindrical dimensions produce 62.8 litres',
        'bow-front dimensions produce 108.6 litres',
        'hexagonal dimensions produce 65.0 litres',
        'corner dimensions produce 78.5 litres',
      ],
    );
  });

  test('Unit Converter retains complete numeric family assertions', () {
    _expectRegisteredTests(
      'test/widget_tests/unit_converter_screen_test.dart',
      const [
        'volume conversion asserts every numeric result',
        'temperature conversion asserts Fahrenheit and Kelvin results',
        'length conversion asserts every numeric result',
        'hardness conversion asserts every numeric result',
      ],
    );
  });
}
