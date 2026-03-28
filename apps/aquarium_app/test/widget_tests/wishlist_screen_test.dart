// Widget tests for WishlistScreen.
//
// Run: flutter test test/widget_tests/wishlist_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/wishlist_screen.dart';
import 'package:danio/models/wishlist.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap({WishlistCategory category = WishlistCategory.fish}) {
  return ProviderScope(
    child: MaterialApp(
      home: WishlistScreen(category: category),
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

  group('WishlistScreen — empty state (fish)', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(WishlistScreen), findsOneWidget);
    });

    testWidgets('shows fish wishlist title', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('🐟 Fish Wishlist'), findsOneWidget);
    });

    testWidgets('shows empty state message', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Your wishlist is empty'), findsOneWidget);
    });

    testWidgets('shows Add Item action button in empty state', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Add Item'), findsWidgets);
    });
  });

  group('WishlistScreen — different categories', () {
    testWidgets('shows plant wishlist title for plant category', (tester) async {
      await tester.pumpWidget(_wrap(category: WishlistCategory.plant));
      await _advance(tester);
      expect(find.text('🌿 Plant Wishlist'), findsOneWidget);
    });

    testWidgets('shows equipment wishlist title for equipment category',
        (tester) async {
      await tester.pumpWidget(_wrap(category: WishlistCategory.equipment));
      await _advance(tester);
      expect(find.text('🛠️ Equipment Wishlist'), findsOneWidget);
    });
  });

  group('WishlistScreen — with saved items', () {
    testWidgets('shows wishlist item from prefs', (tester) async {
      SharedPreferences.setMockInitialValues({
        'wishlist_items':
            '[{"id":"1","name":"Neon Tetra","category":"fish","notes":null,'
            '"priority":"medium","purchased":false,"price":null,'
            '"createdAt":"${DateTime.now().toIso8601String()}"}]',
      });
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Neon Tetra'), findsOneWidget);
    });
  });
}
