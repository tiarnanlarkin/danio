// Widget tests for ShopStreetScreen.
//
// Run: flutter test test/widget_tests/shop_street_screen_test.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/shop_street_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const ProviderScope(child: MaterialApp(home: ShopStreetScreen()));
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

  group('ShopStreetScreen — renders', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(ShopStreetScreen), findsOneWidget);
    });

    testWidgets('shows Shop Street app bar', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.textContaining('Shop Street'), findsWidgets);
    });

    testWidgets('shows fish wishlist section', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.textContaining('Fish Wishlist'), findsWidgets);
    });

    testWidgets('shows plant wishlist section', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.textContaining('Plant Wishlist'), findsWidgets);
    });

    testWidgets('shows equipment wishlist section', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.textContaining('Equipment Wishlist'), findsWidgets);
    });

    testWidgets('uses honest local planning copy, not planned-feature copy', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      expect(find.text('Gear to compare before buying'), findsOneWidget);
      expect(find.text('Useful boosts and collectible badges'), findsOneWidget);
      expect(find.text('Wishlists, budget, and shops'), findsOneWidget);
      expect(find.textContaining('planned'), findsNothing);
      expect(find.textContaining('coming soon'), findsNothing);
    });

    testWidgets('deleting a local shop shows undo and restores it', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'local_shops':
            '[{"id":"shop-undo","name":"Aquatic World",'
            '"address":"12 River Road","phone":null,"website":null,'
            '"distanceMiles":3.5,"rating":4.5,'
            '"notes":"Good plant section",'
            '"createdAt":"${DateTime.now().toIso8601String()}"}]',
      });

      await tester.pumpWidget(_wrap());
      await _advance(tester);
      await tester.scrollUntilVisible(
        find.text('Local Fish Shops'),
        500,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aquatic World'), findsOneWidget);

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove Shop'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Aquatic World'), findsNothing);
      expect(find.text('Aquatic World removed'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Aquatic World'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      final restoredShops =
          jsonDecode(prefs.getString('local_shops')!) as List<dynamic>;
      final restoredShop = restoredShops.single as Map<String, dynamic>;
      expect(restoredShop['id'], 'shop-undo');
      expect(restoredShop['distanceMiles'], 3.5);
      expect(restoredShop['notes'], 'Good plant section');
    });
  });
}
