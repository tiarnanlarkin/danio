// Widget tests for MaintenanceChecklistScreen.
//
// Run: flutter test test/widget_tests/maintenance_checklist_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/maintenance_checklist_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap({String tankId = 'tank-1', String tankName = 'Test Tank'}) {
  return ProviderScope(
    child: MaterialApp(
      home: MaintenanceChecklistScreen(
        tankId: tankId,
        tankName: tankName,
      ),
    ),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 500));
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
  });
}
