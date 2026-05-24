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
  return const MaterialApp(home: StockingCalculatorScreen());
}

Widget _wrapWithBottomInset() {
  return MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData(
        size: Size(390, 844),
        padding: EdgeInsets.only(bottom: 34),
        viewPadding: EdgeInsets.only(bottom: 34),
      ),
      child: const StockingCalculatorScreen(),
    ),
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

  group('StockingCalculatorScreen - validation and calculation', () {
    testWidgets('valid setup and species search can add a fish', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.enterText(find.byType(TextField).last, 'Neon');
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.textContaining('Neon'), findsWidgets);

      final addTarget = find.textContaining('Neon').last;
      await tester.tap(addTarget);
      await tester.pump();

      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    });

    testWidgets('stocking advice uses an icon instead of raw emoji text', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.enterText(find.byType(TextField).last, 'Neon');
      await tester.pump(const Duration(milliseconds: 350));

      await tester.tap(find.textContaining('Neon').last);
      await tester.pump();

      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

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

    testWidgets('zero tank volume shows validation guidance', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.enterText(find.widgetWithText(TextField, '100'), '0');
      await tester.pump();

      expect(find.text('Enter a tank volume greater than 0'), findsOneWidget);
    });

    testWidgets('stocking advice stays above gesture navigation', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrapWithBottomInset());
      await tester.pump();

      await tester.enterText(find.byType(TextField).last, 'Neon');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.tap(find.textContaining('Neon').last);
      await tester.pump();

      final adviceBox = tester.getRect(
        find.text('Good stocking level with room to grow.'),
      );

      expect(adviceBox.bottom, lessThanOrEqualTo(810));
    });
  });
}
