// Widget tests for LivestockLastFedInfo.
//
// Run: flutter test test/widget_tests/livestock_last_fed_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/providers/tank_provider.dart';
import 'package:danio/screens/livestock/livestock_last_fed.dart';

Widget _wrap() {
  return ProviderScope(
    overrides: [
      logsProvider.overrideWith((ref, tankId) async => []),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: LivestockLastFedInfo(tankId: 'tank-1'),
      ),
    ),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pumpWidget(_wrap());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  group('LivestockLastFedInfo', () {
    testWidgets('empty feeding state stays neutral and avoids raw emoji text', (
      tester,
    ) async {
      await _advance(tester);

      expect(find.text('No feedings logged yet'), findsOneWidget);
      expect(
        find.textContaining('No feedings logged yet — time to feed your fish! 🐟'),
        findsNothing,
      );
    });
  });
}
