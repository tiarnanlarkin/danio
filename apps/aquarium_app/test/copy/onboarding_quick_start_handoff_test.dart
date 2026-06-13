import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'quick start uses a sample tank instead of guessing a real starter tank',
    () {
      final source = File(
        'lib/screens/onboarding_screen.dart',
      ).readAsStringSync();

      final quickStartStart = source.indexOf(
        'Future<void> _quickStart() async',
      );
      final quickStartEnd = source.indexOf('@override', quickStartStart);
      final quickStart = source.substring(quickStartStart, quickStartEnd);

      expect(quickStart, contains('addDemoTank()'));
      expect(quickStart, isNot(contains("name: 'My Tank'")));
      expect(quickStart, isNot(contains('volumeLitres: 60')));
      expect(quickStart, contains('currentTabNotifier.state = 2'));
      expect(quickStart, contains('Sample tank added'));
      expect(quickStart, isNot(contains('starter tank')));
      expect(quickStart, isNot(contains('regionCode:')));
      expect(quickStart, isNot(contains('tankStatus:')));
    },
  );
}
