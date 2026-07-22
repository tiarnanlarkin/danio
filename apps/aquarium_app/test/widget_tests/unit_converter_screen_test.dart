// Widget tests for UnitConverterScreen.
//
// Run: flutter test test/widget_tests/unit_converter_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/unit_converter_screen.dart';

Widget _wrap() {
  return const MaterialApp(home: UnitConverterScreen());
}

void _expectConversionResult({required String value, required String unit}) {
  final card = find.ancestor(
    of: find.text(unit),
    matching: find.byType(Card),
  );
  expect(card, findsOneWidget, reason: 'Missing conversion card for $unit');
  expect(
    find.descendant(of: card, matching: find.text(value)),
    findsOneWidget,
    reason: 'Expected $value in the $unit conversion card',
  );
}

void main() {
  group('UnitConverterScreen - rendering', () {
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

    testWidgets('shows aquarium-use guidance on every tab', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(
        find.text('Use for dosing, water changes, and tank capacity checks.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Temp'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Use for heater settings, livestock ranges, and acclimation notes.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Length'));
      await tester.pumpAndSettle();
      expect(
        find.text('Use for tank dimensions, fish size, and equipment fit.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Hardness'));
      await tester.pumpAndSettle();
      expect(
        find.text('Use for GH/KH targets and species water-parameter checks.'),
        findsOneWidget,
      );
    });

    testWidgets('Temperature tab uses plain unit labels', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.text('Temp'));
      await tester.pumpAndSettle();

      final mojibakeCelsius =
          '${String.fromCharCode(0x00C2)}${String.fromCharCode(0x00B0)}C';
      final mojibakeFahrenheit =
          '${String.fromCharCode(0x00C2)}${String.fromCharCode(0x00B0)}F';

      expect(find.text('C'), findsOneWidget);
      expect(find.text(mojibakeCelsius), findsNothing);
      expect(find.text(mojibakeFahrenheit), findsNothing);
    });

    testWidgets('tablet keeps converter inputs and results readable', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(
        tester.getSize(find.byType(TextField)).width,
        lessThanOrEqualTo(720),
      );

      await tester.enterText(find.byType(TextField), '10');
      await tester.pump();

      final resultCard = find
          .ancestor(of: find.text('US gal'), matching: find.byType(Card))
          .first;
      expect(tester.getSize(resultCard).width, lessThanOrEqualTo(720));
    });
  });

  group('UnitConverterScreen - validation and calculation', () {
    testWidgets('volume conversion asserts every numeric result', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.enterText(find.byType(TextField), '10');
      await tester.pump();

      expect(find.text('Conversions'), findsOneWidget);
      _expectConversionResult(value: '2.64', unit: 'US gal');
      _expectConversionResult(value: '2.20', unit: 'UK gal');
      _expectConversionResult(value: '10000.0', unit: 'mL');
      _expectConversionResult(value: '338.1', unit: 'fl oz (US)');
      _expectConversionResult(value: '42.27', unit: 'cups');
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

    testWidgets(
      'temperature conversion asserts Fahrenheit and Kelvin results',
      (
        tester,
      ) async {
        await tester.pumpWidget(_wrap());
        await tester.pump();

        await tester.tap(find.text('Temp'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), '0');
        await tester.pump();

        _expectConversionResult(value: '32.00', unit: 'F');
        _expectConversionResult(value: '273.1', unit: 'K');
      },
    );

    testWidgets('length conversion asserts every numeric result', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.text('Length'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '100');
      await tester.pump();

      _expectConversionResult(value: '1000.0', unit: 'mm');
      _expectConversionResult(value: '39.37', unit: 'in');
      _expectConversionResult(value: '3.28', unit: 'ft');
      _expectConversionResult(value: '1.00', unit: 'm');
    });

    testWidgets('hardness conversion asserts every numeric result', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.text('Hardness'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '10');
      await tester.pump();

      _expectConversionResult(value: '178.5', unit: 'ppm CaCO3');
      _expectConversionResult(value: '178.5', unit: 'mg/L CaCO3');
      _expectConversionResult(value: '1.78', unit: 'mmol/L');
      _expectConversionResult(value: '10.43', unit: 'gpg');
    });

    testWidgets('hardness conversion uses plain CaCO3 labels', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.text('Hardness'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '5');
      await tester.pump();

      final mojibakeCaCo3 = 'CaCO${String.fromCharCode(0x00E2)}';

      expect(find.text('ppm CaCO3'), findsOneWidget);
      expect(find.textContaining(mojibakeCaCo3), findsNothing);
    });
  });
}
