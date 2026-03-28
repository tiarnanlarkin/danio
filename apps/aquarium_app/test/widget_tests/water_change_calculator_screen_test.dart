// Widget tests for WaterChangeCalculatorScreen.
//
// Run: flutter test test/widget_tests/water_change_calculator_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/water_change_calculator_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const MaterialApp(
    home: WaterChangeCalculatorScreen(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('WaterChangeCalculatorScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(WaterChangeCalculatorScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Water Change Calculator'), findsOneWidget);
    });

    testWidgets('shows tank volume input', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Default value '100' for tank volume
      expect(find.widgetWithText(TextField, '100'), findsOneWidget);
    });

    testWidgets('shows nitrate input fields', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Nitrate inputs exist
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('shows nitrate levels section heading', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Nitrate Levels section is always visible above the fold
      expect(find.text('Nitrate Levels'), findsOneWidget);
    });
  });
}
