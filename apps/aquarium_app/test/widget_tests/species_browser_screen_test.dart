// Widget tests for SpeciesBrowserScreen.
//
// Run: flutter test test/widget_tests/species_browser_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/species_browser_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const ProviderScope(
    child: MaterialApp(
      home: SpeciesBrowserScreen(),
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

  group('SpeciesBrowserScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(SpeciesBrowserScreen), findsOneWidget);
    });

    testWidgets('shows app bar title Fish Database', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Fish Database'), findsOneWidget);
    });

    testWidgets('shows search field', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      // The search hint text should be visible
      expect(find.text('Search fish by name...'), findsOneWidget);
    });

    testWidgets('shows care level filter chips', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Beginner'), findsWidgets);
      expect(find.text('Intermediate'), findsWidgets);
    });

    testWidgets('shows species list items', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      // Species database is static — at least one card should be present
      expect(find.byType(ListView), findsWidgets);
    });
  });
}
