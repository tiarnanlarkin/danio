// Widget tests for UnitConverterScreen.
//
// Run: flutter test test/widget_tests/unit_converter_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/unit_converter_screen.dart';

Widget _wrap() {
  return const MaterialApp(home: UnitConverterScreen());
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

    testWidgets('temperature conversion from C to F is readable', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.text('Temp'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '0');
      await tester.pump();

      expect(find.text('32.00'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
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
