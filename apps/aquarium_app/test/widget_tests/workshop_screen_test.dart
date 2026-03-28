// Widget tests for WorkshopScreen.
//
// Run: flutter test test/widget_tests/workshop_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/workshop_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const ProviderScope(
    child: MaterialApp(home: WorkshopScreen()),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(seconds: 1));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WorkshopScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(WorkshopScreen), findsOneWidget);
    });

    testWidgets('shows Workshop title', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      // Title contains Workshop (with emoji prefix in SliverAppBar)
      expect(find.textContaining('Workshop'), findsWidgets);
    });

    testWidgets('shows Water Change tool', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Water Change'), findsOneWidget);
    });

    testWidgets('shows Stocking tool', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Stocking'), findsOneWidget);
    });

    testWidgets('shows multiple calculator tools in grid', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      // Multiple tool cards should be present (first visible ones)
      expect(find.text('CO₂ Calculator'), findsOneWidget);
      expect(find.text('Dosing'), findsOneWidget);
    });
  });
}
