// Widget tests for MaintenanceChecklistScreen.
//
// Run: flutter test test/widget_tests/maintenance_checklist_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/screens/maintenance_checklist_screen.dart';
import 'package:danio/widgets/core/app_card.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap({
  String tankId = 'tank-1',
  String tankName = 'Test Tank',
  SharedPreferences? prefs,
}) {
  return ProviderScope(
    overrides: [
      if (prefs != null)
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
    ],
    child: MaterialApp(
      home: MaintenanceChecklistScreen(tankId: tankId, tankName: tankName),
    ),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 500));
}

class _FalseSetStringPrefs implements SharedPreferences {
  _FalseSetStringPrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key, String value) _shouldFail;

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  int? getInt(String key) => _delegate.getInt(key);

  @override
  Future<bool> setBool(String key, bool value) => _delegate.setBool(key, value);

  @override
  Future<bool> setInt(String key, int value) => _delegate.setInt(key, value);

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

  group('MaintenanceChecklistScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(MaintenanceChecklistScreen), findsOneWidget);
    });

    testWidgets('shows tank name in app bar title', (tester) async {
      await tester.pumpWidget(_wrap(tankName: 'My Tropical Tank'));
      await _advance(tester);
      // Title is "${tankName} Checklist"
      expect(find.text('My Tropical Tank Checklist'), findsOneWidget);
    });

    testWidgets('shows weekly checklist section', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Weekly'), findsWidgets);
    });

    testWidgets('shows monthly checklist section', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Monthly'), findsWidgets);
    });

    testWidgets('shows checklist items', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      // Known weekly checklist items
      expect(find.text('Test water parameters'), findsOneWidget);
    });

    testWidgets('tablet keeps progress and checklist cards readable', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await _advance(tester);

      final progressCard = find
          .ancestor(of: find.text('Weekly'), matching: find.byType(AppCard))
          .first;
      expect(tester.getSize(progressCard).width, lessThanOrEqualTo(720));

      final sectionHeader = find
          .ancestor(of: find.text('Weekly Tasks'), matching: find.byType(Row))
          .first;
      expect(tester.getSize(sectionHeader).width, lessThanOrEqualTo(720));

      final checklistCard = find
          .ancestor(
            of: find.text('Test water parameters'),
            matching: find.byType(Card),
          )
          .first;
      expect(tester.getSize(checklistCard).width, lessThanOrEqualTo(720));
    });

    testWidgets('completed section chip avoids raw check mark text', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      const weeklyItems = [
        'Test water parameters',
        'Water change (20-30%)',
        'Vacuum substrate',
        'Clean glass',
        'Count & observe fish',
        'Check temperature',
        'Trim dead plant matter',
        'Top off evaporated water',
      ];

      for (final label in weeklyItems) {
        final item = find.text(label);
        await tester.ensureVisible(item);
        await tester.tap(item);
        await tester.pump();
      }

      await tester.drag(find.byType(ListView), const Offset(0, 800));
      await tester.pump();

      expect(find.text('Complete!'), findsOneWidget);
      expect(find.text('\u2713 Complete!'), findsNothing);
    });

    testWidgets(
      'false checklist save result rolls back progress with feedback',
      (tester) async {
        final prefs = await SharedPreferences.getInstance();
        final falsePrefs = _FalseSetStringPrefs(
          prefs,
          (key, value) => key == 'checklist_tank-1_state_v2',
        );

        await tester.pumpWidget(_wrap(prefs: falsePrefs));
        await _advance(tester);

        await tester.tap(find.text('Test water parameters'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox).first);
        expect(checkbox.value, isFalse);
        expect(
          find.text("Couldn't save checklist progress. Try again."),
          findsOneWidget,
        );
      },
    );
  });
}
