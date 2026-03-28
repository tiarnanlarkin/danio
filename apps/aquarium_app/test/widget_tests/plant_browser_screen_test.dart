// Widget tests for PlantBrowserScreen.
//
// Run: flutter test test/widget_tests/plant_browser_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/plant_browser_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const ProviderScope(
    child: MaterialApp(
      home: PlantBrowserScreen(),
    ),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PlantBrowserScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(PlantBrowserScreen), findsOneWidget);
    });

    testWidgets('shows app bar title Plant Database', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Plant Database'), findsOneWidget);
    });

    testWidgets('shows search field', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Search plants...'), findsOneWidget);
    });

    testWidgets('shows plant list with entries', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      // Plant database should have entries — verify a ListView is present
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('shows difficulty filter chips', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      // Difficulty chips: Easy, Medium, Hard — 'Easy' appears in chips and plant cards
      expect(find.text('Easy'), findsWidgets);
      expect(find.text('Medium'), findsWidgets);
    });
  });
}
