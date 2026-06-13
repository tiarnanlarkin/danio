import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _source(String path) => File(path).readAsStringSync();

void main() {
  test('returning-user milestone copy avoids hidden upgrade promises', () {
    final files = [
      'lib/screens/home/home_screen.dart',
      'lib/screens/onboarding/returning_user_flows.dart',
    ];
    final staleUpgradeCopy = RegExp(
      r'onUpgrade|paywall|upgrade destination|upgrade screen|upgrade CTA|'
      r"See what's waiting for you, upgrade",
      caseSensitive: false,
    );

    for (final path in files) {
      expect(_source(path), isNot(contains(staleUpgradeCopy)), reason: path);
    }

    expect(
      _source('lib/screens/onboarding/returning_user_flows.dart'),
      contains('onExplore'),
    );
    expect(
      _source('lib/screens/home/home_screen.dart'),
      contains('celebration-only card'),
    );
  });
}
