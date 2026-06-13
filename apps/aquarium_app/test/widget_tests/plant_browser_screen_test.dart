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
  return const ProviderScope(child: MaterialApp(home: PlantBrowserScreen()));
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

    testWidgets('plant detail shows actionable care plan', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.tap(find.text('Anubias Barteri'));
      await tester.pumpAndSettle();

      expect(find.text('Care Actions'), findsOneWidget);
      expect(find.text('Use as a midground plant.'), findsOneWidget);
      expect(find.text('Give low light.'), findsOneWidget);
      expect(find.text('No CO2 setup needed for this plant.'), findsOneWidget);
      expect(find.text('Propagate by rhizome division.'), findsOneWidget);
    });

    testWidgets('plant detail saves plant to wishlist', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.tap(find.text('Anubias Barteri'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Save to wishlist'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save to wishlist'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final prefs = await SharedPreferences.getInstance();
      final savedItems = prefs.getString('wishlist_items') ?? '';

      expect(savedItems, contains('Anubias Barteri'));
      expect(savedItems, contains('Anubias barteri var. barteri'));
      expect(find.text('Saved to wishlist'), findsOneWidget);
    });

    testWidgets('empty search state explains no matches', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.enterText(find.byType(TextField), 'no_such_plant_zz');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      expect(find.text('No matches'), findsOneWidget);
      expect(
        find.text('Try a different plant name or clear filters'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });
  });
}
