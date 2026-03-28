// Widget tests for TankVolumeCalculatorScreen.
//
// Run: flutter test test/widget_tests/tank_volume_calculator_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/tank_volume_calculator_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const MaterialApp(
    home: TankVolumeCalculatorScreen(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TankVolumeCalculatorScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(TankVolumeCalculatorScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Tank Volume Calculator'), findsOneWidget);
    });

    testWidgets('shows shape selector options', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Shape selector chips/buttons
      expect(find.text('Rectangular'), findsOneWidget);
    });

    testWidgets('shows dimension input fields for rectangular', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Rectangular is the default — should show length/width/height
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('shows metric/imperial toggle', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Metric toggle text
      expect(find.text('cm'), findsWidgets);
    });
  });
}
