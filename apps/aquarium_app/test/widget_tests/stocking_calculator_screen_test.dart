// Widget tests for StockingCalculatorScreen.
//
// Run: flutter test test/widget_tests/stocking_calculator_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/stocking_calculator_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const MaterialApp(
    home: StockingCalculatorScreen(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('StockingCalculatorScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(StockingCalculatorScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Stocking Calculator'), findsOneWidget);
    });

    testWidgets('shows tank volume input with default value', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.widgetWithText(TextField, '100'), findsOneWidget);
    });

    testWidgets('shows live plants toggle', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('shows search field for species', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Search field for adding species
      expect(find.byType(TextField), findsWidgets);
    });
  });
}
