// Widget tests for home water parameter bottom sheet.
//
// Run: flutter test test/widget_tests/home_sheets_water_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/home/home_sheets_water.dart';

Widget _wrap() {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () => showWaterParams(context, const [], 'tank-1'),
          child: const Text('Open water sheet'),
        ),
      ),
    ),
  );
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.pumpWidget(_wrap());
  await tester.tap(find.text('Open water sheet'));
  await tester.pumpAndSettle();
}

void main() {
  group('Home water parameter sheet', () {
    testWidgets('empty test result copy avoids raw emoji text', (tester) async {
      await _openSheet(tester);

      expect(find.text('Water Parameters'), findsOneWidget);
      expect(find.text('No test results yet'), findsOneWidget);
      expect(find.textContaining('No test results yet 🧪'), findsNothing);
    });

    testWidgets('support headings use plain text without emoji prefixes', (
      tester,
    ) async {
      await _openSheet(tester);

      expect(find.text('Ideal Ranges (Freshwater)'), findsOneWidget);
      expect(find.text('What this means for your fish'), findsOneWidget);
      expect(find.textContaining('✅'), findsNothing);
      expect(find.textContaining('🐟'), findsNothing);
    });
  });
}
