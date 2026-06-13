// Widget tests for SpeciesBrowserScreen.
//
// Run: flutter test test/widget_tests/species_browser_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/emergency_guide_screen.dart';
import 'package:danio/screens/species_browser_screen.dart';
import 'package:danio/screens/stocking_calculator_screen.dart';
import 'package:danio/utils/navigation_throttle.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const ProviderScope(child: MaterialApp(home: SpeciesBrowserScreen()));
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
    NavigationThrottle.reset();
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

    testWidgets('species detail opens Emergency Guide', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.tap(find.text('Neon Tetra'));
      await tester.pumpAndSettle();

      expect(find.text('Emergency Guide'), findsOneWidget);
      expect(
        find.text('Urgent steps for illness, injury, gasping, or unsafe water'),
        findsOneWidget,
      );

      await tester.tap(find.text('Emergency Guide'));
      await tester.pumpAndSettle();

      expect(find.byType(EmergencyGuideScreen), findsOneWidget);
    });

    testWidgets('species detail shows actionable care plan', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.tap(find.text('Neon Tetra'));
      await tester.pumpAndSettle();

      expect(find.text('Care Actions'), findsOneWidget);
      expect(find.text('Use a tank of at least 40 L.'), findsOneWidget);
      expect(find.text('Plan a group of 6 or more.'), findsOneWidget);
      expect(
        find.text('Keep water around 20-26 C and pH 6.0-7.0.'),
        findsOneWidget,
      );
      expect(
        find.text('Check the avoid list before adding tankmates.'),
        findsOneWidget,
      );
    });

    testWidgets('species detail shows watch-for guidance', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.tap(find.text('Neon Tetra'));
      await tester.pumpAndSettle();

      expect(find.text('Watch For'), findsOneWidget);
      expect(
        find.text('Small groups: plan 6 or more, not a lone fish.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Tankmates: review Angelfish, Bettas, Large Cichlids before mixing.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Adult fit: plan around 3.5 cm adult size and 40 L minimum tank.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('species detail opens prefilled stocking calculator', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.tap(find.text('Neon Tetra'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Plan stocking fit'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Plan stocking fit'));
      await tester.pumpAndSettle();

      expect(find.byType(StockingCalculatorScreen), findsOneWidget);
      expect(find.text('Stocking Calculator'), findsOneWidget);
      expect(find.text('Neon Tetra'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
    });

    testWidgets('species detail saves fish to wishlist', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.tap(find.text('Neon Tetra'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Save to wishlist'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save to wishlist'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final prefs = await SharedPreferences.getInstance();
      final savedItems = prefs.getString('wishlist_items') ?? '';

      expect(savedItems, contains('Neon Tetra'));
      expect(savedItems, contains('Paracheirodon innesi'));
      expect(find.text('Saved to wishlist'), findsOneWidget);
    });

    testWidgets(
      'empty search state uses iconography instead of raw emoji text',
      (tester) async {
        await tester.pumpWidget(_wrap());
        await _advance(tester);

        await tester.enterText(find.byType(TextField), 'no_such_fish_zz');
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();

        expect(find.text('No matches'), findsOneWidget);
        expect(find.byIcon(Icons.search_off), findsOneWidget);
        expect(find.textContaining(String.fromCharCode(0x1F50D)), findsNothing);
      },
    );

    testWidgets('empty search opens species request guidance', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.enterText(find.byType(TextField), 'blue dragon tetra');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      expect(find.text('Request species'), findsOneWidget);

      await tester.tap(find.text('Request species'));
      await tester.pumpAndSettle();

      expect(find.text('Request Species'), findsOneWidget);
      expect(
        find.text(
          'We could not find "blue dragon tetra" in the local fish database.',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('larkintiarnanbizz@gmail.com'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Danio does not send this automatically'),
        findsOneWidget,
      );
    });
  });
}
