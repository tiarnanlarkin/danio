// Widget tests for UnitConverterScreen.
//
// Run: flutter test test/widget_tests/unit_converter_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/unit_converter_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const MaterialApp(home: UnitConverterScreen());
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('UnitConverterScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(UnitConverterScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Unit Converter'), findsOneWidget);
    });

    testWidgets('shows conversion category tabs', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Volume'), findsOneWidget);
      expect(find.text('Temp'), findsOneWidget);
      expect(find.text('Length'), findsOneWidget);
      expect(find.text('Hardness'), findsOneWidget);
    });

    testWidgets('shows input field on Volume tab', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('can tap Temperature tab', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.tap(find.text('Temp'));
      await tester.pumpAndSettle();
      // Temperature converter shows °C and °F
      expect(find.text('°C'), findsWidgets);
    });
  });

  group('UnitConverterScreen - validation and calculation', () {
    testWidgets('valid volume input shows conversions', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.enterText(find.byType(TextField), '10');
      await tester.pump();

      expect(find.text('Conversions'), findsOneWidget);
      expect(find.text('US gal'), findsOneWidget);
    });

    testWidgets('empty volume input hides conversions', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.enterText(find.byType(TextField), '10');
      await tester.pump();
      expect(find.text('Conversions'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      expect(find.text('Conversions'), findsNothing);
    });
  });
}
