// Widget tests for Co2CalculatorScreen.
//
// Run: flutter test test/widget_tests/co2_calculator_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/co2_calculator_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const MaterialApp(
    home: Co2CalculatorScreen(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Co2CalculatorScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(Co2CalculatorScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('CO2 Calculator'), findsOneWidget);
    });

    testWidgets('shows pH and KH input fields', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('pH'), findsOneWidget);
      expect(find.text('KH (dKH)'), findsOneWidget);
    });

    testWidgets('shows CO2 result card', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Estimated CO2 Level'), findsOneWidget);
    });

    testWidgets('shows reference chart', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      // The reference chart contains these range labels
      expect(find.text('10-20 ppm'), findsOneWidget);
      expect(find.text('20-30 ppm'), findsOneWidget);
      expect(find.text('30-40 ppm'), findsOneWidget);
    });
  });

  group('Co2CalculatorScreen — calculation', () {
    testWidgets('default values produce a CO2 reading', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      // Default: pH=7.0, KH=4 → CO2 = 3 * 4 * 10^(7-7) = 12 ppm → Low
      expect(find.textContaining('ppm'), findsWidgets);
      // "Low" appears in both the result card and reference chart
      expect(find.text('Low'), findsWidgets);
    });

    testWidgets('optimal range shows "Optimal" status', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      // pH 6.6, KH 4 → CO2 = 3 * 4 * 10^(0.4) ≈ 30.2 ppm → Optimal
      final phField = find.widgetWithText(TextField, '7.0');
      await tester.enterText(phField, '6.6');
      await tester.pump();

      // "Optimal" appears once (only in result, not reference chart labels)
      expect(find.text('Optimal'), findsWidgets);
    });

    testWidgets('dangerous level shows "Dangerous" status', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      // pH 6.0, KH 8 → CO2 = 3 * 8 * 10^1 = 240 ppm → Dangerous
      final phField = find.widgetWithText(TextField, '7.0');
      await tester.enterText(phField, '6.0');
      await tester.pump();

      final khField = find.widgetWithText(TextField, '4');
      await tester.enterText(khField, '8');
      await tester.pump();

      // "Dangerous" appears in result card and reference chart row
      expect(find.text('Dangerous'), findsWidgets);
    });

    testWidgets('changing pH updates result in real time', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      // Default pH 7.0 → Low (12 ppm)
      expect(find.text('Low'), findsWidgets);

      // Change to pH 7.2 with same KH 4
      // CO2 = 3 * 4 * 10^(-0.2) ≈ 7.6 ppm → Too Low
      final phField = find.widgetWithText(TextField, '7.0');
      await tester.enterText(phField, '7.2');
      await tester.pump();

      expect(find.text('Too Low'), findsWidgets);
    });
  });

  group('Co2CalculatorScreen — edge cases', () {
    testWidgets('very large KH still calculates', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      final khField = find.widgetWithText(TextField, '4');
      await tester.enterText(khField, '50');
      await tester.pump();

      // Should still show a value, not an error
      expect(find.textContaining('ppm'), findsWidgets);
      expect(find.text('Dangerous'), findsWidgets);
    });

    testWidgets('shows info card about the calculator', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(
        find.textContaining('Calculate dissolved CO2 from your pH and KH readings'),
        findsOneWidget,
      );
    });

    testWidgets('shows drop checker colours section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      // Scroll down — the screen uses ListView.builder
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pump();

      // Should find drop checker labels
      expect(find.text('Blue'), findsOneWidget);
      expect(find.text('Green'), findsOneWidget);
      expect(find.text('Yellow'), findsOneWidget);
    });

    testWidgets('shows tips section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.drag(find.byType(ListView), const Offset(0, -1200));
      await tester.pump();

      // Tips contain bullet points with advice
      expect(
        find.textContaining('Measure pH at the same time each day'),
        findsOneWidget,
      );
    });
  });
}
