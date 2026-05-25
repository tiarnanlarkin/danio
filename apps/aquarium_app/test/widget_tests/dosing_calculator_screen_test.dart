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

Finder _productPreset(String name) {
  return find.byWidgetPredicate((widget) {
    if (widget is! ListTile || widget.title is! Text) return false;
    final title = widget.title! as Text;
    return title.data == name;
  });
}

Future<void> _tapProductPreset(WidgetTester tester, String name) async {
  final element = tester.elementList(_productPreset(name)).last;
  await Scrollable.ensureVisible(element, alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(
    find.byElementPredicate((candidate) => candidate == element),
  );
  await tester.pumpAndSettle();
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

    testWidgets('shows Tank Volume and Recommended Dose sections', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.text('Tank Volume'), findsOneWidget);
      expect(find.text('Recommended Dose'), findsOneWidget);
    });

    testWidgets('shows placeholder prompt when no volume entered', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(
        find.text('Enter your tank volume above to calculate dose'),
        findsOneWidget,
      );
    });

    testWidgets('safety warning uses an icon instead of raw emoji text', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

      final emoji = RegExp(
        r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}]',
        unicode: true,
      );
      final renderedText = tester
          .widgetList<Text>(find.byType(Text))
          .map((widget) {
            return widget.data ?? widget.textSpan?.toPlainText() ?? '';
          })
          .where(emoji.hasMatch)
          .toList();

      expect(renderedText, isEmpty);
    });

    testWidgets('safety copy matches liquid product presets', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.textContaining('liquid aquarium products'), findsOneWidget);
      expect(find.textContaining('Do not use for medications'), findsOneWidget);
      expect(find.textContaining('fertiliser dosing only'), findsNothing);
    });
  });

  group('DosingCalculatorScreen — calculation', () {
    testWidgets('entering volume shows result card', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      final volumeField = find.widgetWithText(
        TextFormField,
        'e.g., 120 litres',
      );
      await tester.enterText(volumeField, '50');
      await tester.pump();

      expect(find.text('Total dose for your tank'), findsOneWidget);
    });

    testWidgets('shows Tank volume and Dose rate in result', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      final volumeField = find.widgetWithText(
        TextFormField,
        'e.g., 120 litres',
      );
      await tester.enterText(volumeField, '100');
      await tester.pump();

      expect(find.text('Tank volume'), findsOneWidget);
      expect(find.text('Dose rate'), findsOneWidget);
    });

    testWidgets('shows common liquid products after volume entered', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      final volumeField = find.widgetWithText(
        TextFormField,
        'e.g., 120 litres',
      );
      await tester.enterText(volumeField, '100');
      await tester.pump();

      expect(find.text('Common Liquid Products'), findsOneWidget);
      expect(find.text('Seachem Prime'), findsOneWidget);
      expect(find.text('Easy Green (Aquarium Co-Op)'), findsOneWidget);
    });

    testWidgets('result shows ml suffix in dose display', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      final volumeField = find.widgetWithText(
        TextFormField,
        'e.g., 120 litres',
      );
      await tester.enterText(volumeField, '100');
      await tester.pump();

      // Both the result headline and 'Dose rate' row show ml
      expect(find.textContaining('ml'), findsWidgets);
    });

    testWidgets('valid volume and dose show the calculated dose amount', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g., 120 litres'),
        '100',
      );
      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '2');
      await tester.pump();

      expect(find.text('20.00 ml'), findsOneWidget);
      expect(find.text('Total dose for your tank'), findsOneWidget);
    });

    testWidgets('zero volume shows validation guidance instead of a dose', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g., 120 litres'),
        '0',
      );
      await tester.pump();

      expect(find.text('20.00 ml'), findsNothing);
      expect(find.text('Enter a tank volume greater than 0'), findsOneWidget);
    });

    testWidgets('Tropica Specialised preset uses manufacturer weekly dose', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g., 120 litres'),
        '100',
      );
      await tester.pump();

      await _tapProductPreset(tester, 'Tropica Specialised');

      expect(find.text('12.00 ml'), findsOneWidget);
      expect(find.text('6.0 ml per 50 L'), findsOneWidget);
    });

    testWidgets('Easy Green preset uses 10 US gallon product dose', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g., 120 litres'),
        '100',
      );
      await tester.pump();

      await _tapProductPreset(tester, 'Easy Green (Aquarium Co-Op)');

      expect(find.text('2.63 ml'), findsOneWidget);
      expect(find.text('1.0 ml per 38 L'), findsOneWidget);
    });
  });
}
