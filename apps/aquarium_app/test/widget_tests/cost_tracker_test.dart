// Widget tests for CostTrackerScreen.
//
// Run: flutter test test/widget_tests/cost_tracker_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/cost_tracker_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const ProviderScope(
    child: MaterialApp(
      home: CostTrackerScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CostTrackerScreen — empty state', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(CostTrackerScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Cost Tracker'), findsOneWidget);
    });

    testWidgets('shows empty state with prompt', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Track Your Fishkeeping Expenses'), findsOneWidget);
      expect(find.text('Add First Expense'), findsOneWidget);
    });

    testWidgets('has FAB for adding expenses', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Add Expense'), findsOneWidget);
    });

    testWidgets('tapping Add First Expense opens bottom sheet', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Add First Expense'));
      await tester.pumpAndSettle();

      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
    });
  });

  group('CostTrackerScreen — add expense', () {
    testWidgets('bottom sheet has required fields', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Add First Expense'));
      await tester.pumpAndSettle();

      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Save Expense'), findsOneWidget);
    });

    testWidgets('category dropdown shows all categories', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Add First Expense'));
      await tester.pumpAndSettle();

      // Tap the category dropdown (shows "Fish" as current value)
      await tester.tap(find.text('Fish'));
      await tester.pumpAndSettle();

      expect(find.text('Plants'), findsOneWidget);
      expect(find.text('Equipment'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Medication'), findsOneWidget);
      expect(find.text('Decor'), findsOneWidget);
      expect(find.text('Tank'), findsOneWidget);
      expect(find.text('Test Kits'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
    });

    testWidgets('can fill in and save expense', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Add First Expense'));
      await tester.pumpAndSettle();

      // Fill description — target the TextField with "Description" labelText
      // (the labelText appears as a child Text widget when the field is empty)
      final descField = find.widgetWithText(TextField, 'Description');
      await tester.enterText(descField, 'Neon Tetras x6');

      // Fill amount — target the TextField with "Amount" labelText
      final amountField = find.widgetWithText(TextField, 'Amount');
      await tester.enterText(amountField, '24.99');

      // Save
      await tester.tap(find.text('Save Expense'));
      await tester.pumpAndSettle();

      // Expense should now appear in the list
      expect(find.text('Neon Tetras x6'), findsOneWidget);
    });
  });

  group('CostTrackerScreen — with saved data', () {
    testWidgets('shows expense list when data exists', (tester) async {
      SharedPreferences.setMockInitialValues({
        'cost_tracker_expenses': '[{"id":"1","description":"Filter","amount":35.0,"category":"Equipment","date":"2025-01-15T12:00:00.000"}]',
        'cost_tracker_currency': '£',
      });

      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Filter'), findsOneWidget);
      // £35.00 appears in summary card, category bar, and expense tile
      expect(find.text('£35.00'), findsWidgets);
    });

    testWidgets('shows summary cards', (tester) async {
      SharedPreferences.setMockInitialValues({
        'cost_tracker_expenses': '[{"id":"1","description":"Fish Food","amount":12.0,"category":"Food","date":"${DateTime.now().toIso8601String()}"}]',
        'cost_tracker_currency': '£',
      });

      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('This Year'), findsOneWidget);
      expect(find.text('All Time Total'), findsOneWidget);
    });

    testWidgets('settings button opens dialog', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
    });
  });
}
