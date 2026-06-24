// Widget tests for CostTrackerScreen.
//
// Run: flutter test test/widget_tests/cost_tracker_test.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/screens/cost_tracker_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const ProviderScope(child: MaterialApp(home: CostTrackerScreen()));
}

Widget _wrapWithFailingPrefs({
  required Map<String, Object> initialValues,
  required bool Function(String key, Object value) shouldFail,
}) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        SharedPreferences.setMockInitialValues(initialValues);
        final prefs = await SharedPreferences.getInstance();
        return _ThrowingSetStringPrefs(prefs, shouldFail);
      }),
    ],
    child: const MaterialApp(home: CostTrackerScreen()),
  );
}

Widget _wrapWithFalseSetStringPrefs({
  required Map<String, Object> initialValues,
  required bool Function(String key, Object value) shouldFail,
}) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        SharedPreferences.setMockInitialValues(initialValues);
        final prefs = await SharedPreferences.getInstance();
        return _FalseSetStringPrefs(prefs, shouldFail);
      }),
    ],
    child: const MaterialApp(home: CostTrackerScreen()),
  );
}

class _ThrowingSetStringPrefs implements SharedPreferences {
  _ThrowingSetStringPrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key, Object value) _shouldFail;

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  int? getInt(String key) => _delegate.getInt(key);

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  Future<bool> setString(String key, String value) {
    if (_shouldFail(key, value)) {
      throw StateError('Simulated SharedPreferences write failure for $key');
    }
    return _delegate.setString(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FalseSetStringPrefs implements SharedPreferences {
  _FalseSetStringPrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key, Object value) _shouldFail;

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  int? getInt(String key) => _delegate.getInt(key);

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  Future<bool> setString(String key, String value) {
    if (_shouldFail(key, value)) {
      return Future.value(false);
    }
    return _delegate.setString(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CostTrackerScreen - empty state', () {
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

  group('CostTrackerScreen - add expense', () {
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

      // Fill description - target the TextField with "Description" labelText
      // (the labelText appears as a child Text widget when the field is empty)
      final descField = find.widgetWithText(TextField, 'Description');
      await tester.enterText(descField, 'Neon Tetras x6');

      // Fill amount - target the TextField with "Amount" labelText
      final amountField = find.widgetWithText(TextField, 'Amount');
      await tester.enterText(amountField, '24.99');

      // Save
      await tester.tap(find.text('Save Expense'));
      await tester.pumpAndSettle();

      // Expense should now appear in the list
      expect(find.text('Neon Tetras x6'), findsOneWidget);
    });

    testWidgets('saving expense confirms local add and persists it', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Add First Expense'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Description'),
        'Frozen food',
      );
      await tester.enterText(find.widgetWithText(TextField, 'Amount'), '7.50');

      await tester.tap(find.text('Save Expense'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Frozen food'), findsOneWidget);
      expect(find.text('Frozen food added.'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      final savedExpenses =
          jsonDecode(prefs.getString('cost_tracker_expenses')!)
              as List<dynamic>;
      expect(savedExpenses.single['description'], 'Frozen food');
      expect(savedExpenses.single['amount'], 7.5);
    });

    testWidgets('false save result shows feedback and keeps expense unsaved', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithFalseSetStringPrefs(
          initialValues: {},
          shouldFail: (key, value) => key == 'cost_tracker_expenses',
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Add First Expense'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Description'),
        'Frozen food',
      );
      await tester.enterText(find.widgetWithText(TextField, 'Amount'), '7.50');

      await tester.tap(find.text('Save Expense'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.widgetWithText(ListTile, 'Frozen food'), findsNothing);
      expect(
        find.text("Couldn't save that expense. Try again in a moment."),
        findsOneWidget,
      );
    });

    testWidgets('empty expense form shows validation guidance', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Add First Expense'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Expense'));
      await tester.pumpAndSettle();

      expect(find.text('Please fill in all fields'), findsWidgets);
    });

    testWidgets('zero amount is rejected', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Add First Expense'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Description'),
        'Free sample',
      );
      await tester.enterText(find.widgetWithText(TextField, 'Amount'), '0');
      await tester.tap(find.text('Save Expense'));
      await tester.pumpAndSettle();

      expect(find.text('Enter an amount greater than 0'), findsWidgets);
      expect(find.text('Save Expense'), findsOneWidget);
    });
  });

  group('CostTrackerScreen - with saved data', () {
    testWidgets('shows expense list when data exists', (tester) async {
      SharedPreferences.setMockInitialValues({
        'cost_tracker_expenses':
            '[{"id":"1","description":"Filter","amount":35.0,"category":"Equipment","date":"2025-01-15T12:00:00.000"}]',
        'cost_tracker_currency': '\u00A3',
      });

      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Filter'), findsOneWidget);
      // GBP35.00 appears in summary card, category bar, and expense tile.
      expect(find.text('\u00A335.00'), findsWidgets);
    });

    testWidgets('shows summary cards', (tester) async {
      SharedPreferences.setMockInitialValues({
        'cost_tracker_expenses':
            '[{"id":"1","description":"Fish Food","amount":12.0,"category":"Food","date":"${DateTime.now().toIso8601String()}"}]',
        'cost_tracker_currency': '\u00A3',
      });

      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('This Year'), findsOneWidget);
      expect(find.text('All Time Total'), findsOneWidget);
    });

    testWidgets('tablet keeps summary and expense surfaces readable', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      SharedPreferences.setMockInitialValues({
        'cost_tracker_expenses':
            '[{"id":"1","description":"Filter","amount":35.0,"category":"Equipment","date":"2025-01-15T12:00:00.000"}]',
        'cost_tracker_currency': '\u00A3',
      });

      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final totalCard = find
          .ancestor(
            of: find.text('All Time Total'),
            matching: find.byType(Card),
          )
          .first;
      final expenseCard = find
          .ancestor(of: find.text('Filter'), matching: find.byType(Card))
          .first;

      expect(tester.getSize(totalCard).width, lessThanOrEqualTo(720));
      expect(tester.getSize(expenseCard).width, lessThanOrEqualTo(720));
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

    testWidgets('settings keeps custom saved currency selectable', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'cost_tracker_expenses': '[]',
        'cost_tracker_currency': 'CHF',
      });

      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
      expect(find.text('CHF'), findsOneWidget);
    });

    testWidgets(
      'clearing all expenses shows undo and restores saved expenses',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'cost_tracker_expenses':
              '[{"id":"1","description":"Filter","amount":35.0,'
              '"category":"Equipment","date":"2025-01-15T12:00:00.000"},'
              '{"id":"2","description":"Plant food","amount":8.5,'
              '"category":"Food","date":"2025-01-16T12:00:00.000"}]',
          'cost_tracker_currency': '\u00A3',
        });

        await tester.pumpWidget(_wrap());
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Filter'), findsOneWidget);
        expect(find.text('Plant food'), findsOneWidget);

        await tester.tap(find.byTooltip('Cost tracker settings'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Delete expense'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Clear All'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Filter'), findsNothing);
        expect(find.text('Plant food'), findsNothing);
        expect(find.text('Expenses cleared'), findsOneWidget);
        expect(find.text('Undo'), findsOneWidget);

        await tester.tap(find.widgetWithText(SnackBarAction, 'Undo'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Filter'), findsOneWidget);
        expect(find.text('Plant food'), findsOneWidget);

        final prefs = await SharedPreferences.getInstance();
        final restoredExpenses =
            jsonDecode(prefs.getString('cost_tracker_expenses')!)
                as List<dynamic>;
        expect(restoredExpenses.map((e) => e['id']), ['1', '2']);
      },
    );

    testWidgets('undo restore failure shows local feedback without throwing', (
      tester,
    ) async {
      const savedExpenses =
          '[{"id":"1","description":"Filter","amount":35.0,'
          '"category":"Equipment","date":"2025-01-15T12:00:00.000"},'
          '{"id":"2","description":"Plant food","amount":8.5,'
          '"category":"Food","date":"2025-01-16T12:00:00.000"}]';

      await tester.pumpWidget(
        _wrapWithFailingPrefs(
          initialValues: {
            'cost_tracker_expenses': savedExpenses,
            'cost_tracker_currency': '\u00A3',
          },
          shouldFail: (key, value) =>
              key == 'cost_tracker_expenses' && value != '[]',
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byTooltip('Cost tracker settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Delete expense'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear All'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.widgetWithText(SnackBarAction, 'Undo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(
        find.text("Couldn't restore those expenses. Try again in a moment."),
        findsOneWidget,
      );
    });

    testWidgets(
      'clear false save result shows feedback and keeps expenses active',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        const savedExpenses =
            '[{"id":"1","description":"Filter","amount":35.0,'
            '"category":"Equipment","date":"2025-01-15T12:00:00.000"},'
            '{"id":"2","description":"Plant food","amount":8.5,'
            '"category":"Food","date":"2025-01-16T12:00:00.000"}]';

        await tester.pumpWidget(
          _wrapWithFalseSetStringPrefs(
            initialValues: {
              'cost_tracker_expenses': savedExpenses,
              'cost_tracker_currency': '\u00A3',
            },
            shouldFail: (key, value) =>
                key == 'cost_tracker_expenses' && value == '[]',
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.byTooltip('Cost tracker settings'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Delete expense'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Clear All'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(tester.takeException(), isNull);
        expect(find.text('Filter'), findsOneWidget);
        expect(find.text('Plant food'), findsOneWidget);
        expect(
          find.text("Couldn't clear expenses. Try again in a moment."),
          findsOneWidget,
        );
      },
    );
  });
}
