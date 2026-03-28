// Widget tests for DosingCalculatorScreen.
//
// Run: flutter test test/widget_tests/dosing_calculator_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/dosing_calculator_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap({double? tankVolumeLitres}) {
  return MaterialApp(
    home: DosingCalculatorScreen(tankVolumeLitres: tankVolumeLitres),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('DosingCalculatorScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.byType(DosingCalculatorScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.text('Dosing Calculator'), findsOneWidget);
    });

    testWidgets('shows Tank Volume and Recommended Dose sections', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.text('Tank Volume'), findsOneWidget);
      expect(find.text('Recommended Dose'), findsOneWidget);
    });

    testWidgets('shows placeholder prompt when no volume entered', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(
        find.text('Enter your tank volume above to calculate dose'),
        findsOneWidget,
      );
    });
  });

  group('DosingCalculatorScreen — calculation', () {
    testWidgets('entering volume shows result card', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      final volumeField = find.widgetWithText(TextFormField, 'e.g., 120 litres');
      await tester.enterText(volumeField, '50');
      await tester.pump();

      expect(find.text('Total dose for your tank'), findsOneWidget);
    });

    testWidgets('shows Tank volume and Dose rate in result', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      final volumeField = find.widgetWithText(TextFormField, 'e.g., 120 litres');
      await tester.enterText(volumeField, '100');
      await tester.pump();

      expect(find.text('Tank volume'), findsOneWidget);
      expect(find.text('Dose rate'), findsOneWidget);
    });

    testWidgets('shows common products after volume entered', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      final volumeField = find.widgetWithText(TextFormField, 'e.g., 120 litres');
      await tester.enterText(volumeField, '100');
      await tester.pump();

      expect(find.text('Common Products'), findsOneWidget);
      expect(find.text('Seachem Prime'), findsOneWidget);
      expect(find.text('Easy Green (Aquarium Co-Op)'), findsOneWidget);
    });

    testWidgets('result shows ml suffix in dose display', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      final volumeField = find.widgetWithText(TextFormField, 'e.g., 120 litres');
      await tester.enterText(volumeField, '100');
      await tester.pump();

      // Both the result headline and 'Dose rate' row show ml
      expect(find.textContaining('ml'), findsWidgets);
    });
  });
}
