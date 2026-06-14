// Widget tests for WishlistScreen.
//
// Run: flutter test test/widget_tests/wishlist_screen_test.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/wishlist_screen.dart';
import 'package:danio/models/wishlist.dart';
import 'package:danio/providers/wishlist_provider.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap({
  WishlistCategory category = WishlistCategory.fish,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: WishlistScreen(category: category)),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

class _FailingMarkPurchasedWishlistNotifier extends WishlistNotifier {
  _FailingMarkPurchasedWishlistNotifier(super.ref);

  @override
  Future<void> markPurchased(String id) async {
    throw StateError('purchase save failed');
  }
}

class _FailingRemoveWishlistNotifier extends WishlistNotifier {
  _FailingRemoveWishlistNotifier(super.ref);

  @override
  Future<void> removeItem(String id) async {
    throw StateError('remove save failed');
  }
}

class _FailingUndoWishlistNotifier extends WishlistNotifier {
  _FailingUndoWishlistNotifier(super.ref);

  @override
  Future<void> addItem(WishlistItem item) async {
    throw StateError('restore save failed');
  }
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
      expect(find.text('Fish Wishlist'), findsOneWidget);
      expect(find.textContaining('🐟'), findsNothing);
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

    testWidgets('adding a wishlist item saves it and confirms the add', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.tap(find.text('Add Item').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.enterText(
        find.widgetWithText(TextField, 'Fish name'),
        'Neon Tetra',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Scientific name (optional)'),
        'Paracheirodon innesi',
      );
      await tester.enterText(find.byType(TextField).at(2), '2.50');

      await tester.tap(find.text('Add to Wishlist').last);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Neon Tetra'), findsOneWidget);
      expect(find.text('Neon Tetra added.'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      final savedItems =
          jsonDecode(prefs.getString('wishlist_items')!) as List<dynamic>;
      final savedItem = savedItems.single as Map<String, dynamic>;
      expect(savedItem['name'], 'Neon Tetra');
      expect(savedItem['species'], 'Paracheirodon innesi');
      expect(savedItem['estimatedPrice'], 2.5);
      expect(savedItem['category'], 'fish');
    });
  });

  group('WishlistScreen — different categories', () {
    testWidgets('shows plant wishlist title for plant category', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(category: WishlistCategory.plant));
      await _advance(tester);
      expect(find.text('Plant Wishlist'), findsOneWidget);
      expect(find.textContaining('🌿'), findsNothing);
    });

    testWidgets('shows equipment wishlist title for equipment category', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(category: WishlistCategory.equipment));
      await _advance(tester);
      expect(find.text('Equipment Wishlist'), findsOneWidget);
      expect(find.textContaining('🛠️'), findsNothing);
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

    testWidgets('deleting a wishlist item shows undo and restores it', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'wishlist_items':
            '[{"id":"wishlist-undo","name":"Neon Tetra","category":"fish",'
            '"species":"Paracheirodon innesi","notes":null,'
            '"estimatedPrice":2.5,"imageUrl":null,"quantity":6,'
            '"purchased":false,'
            '"createdAt":"${DateTime.now().toIso8601String()}",'
            '"purchasedAt":null}]',
      });

      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove Item'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Neon Tetra'), findsNothing);
      expect(find.text('Neon Tetra removed'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Neon Tetra'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      final restoredItems =
          jsonDecode(prefs.getString('wishlist_items')!) as List<dynamic>;
      final restoredItem = restoredItems.single as Map<String, dynamic>;
      expect(restoredItem['id'], 'wishlist-undo');
      expect(restoredItem['category'], 'fish');
      expect(restoredItem['quantity'], 6);
    });

    testWidgets('failed delete keeps item visible with error feedback', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'wishlist_items':
            '[{"id":"wishlist-delete-failure","name":"Neon Tetra",'
            '"category":"fish","species":"Paracheirodon innesi",'
            '"notes":null,"estimatedPrice":2.5,"imageUrl":null,'
            '"quantity":6,"purchased":false,'
            '"createdAt":"${DateTime.now().toIso8601String()}",'
            '"purchasedAt":null}]',
      });

      await tester.pumpWidget(
        _wrap(
          overrides: [
            wishlistProvider.overrideWith(
              (ref) => _FailingRemoveWishlistNotifier(ref),
            ),
          ],
        ),
      );
      await _advance(tester);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove Item'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Neon Tetra'), findsOneWidget);
      expect(
        find.text('Could not remove Neon Tetra. Try again in a moment.'),
        findsOneWidget,
      );
      expect(find.text('Neon Tetra removed'), findsNothing);

      final prefs = await SharedPreferences.getInstance();
      final savedItems =
          jsonDecode(prefs.getString('wishlist_items')!) as List<dynamic>;
      final savedItem = savedItems.single as Map<String, dynamic>;
      expect(savedItem['id'], 'wishlist-delete-failure');
      expect(savedItem['purchased'], isFalse);
    });

    testWidgets('failed delete undo keeps item deleted with error feedback', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'wishlist_items':
            '[{"id":"wishlist-undo-failure","name":"Neon Tetra",'
            '"category":"fish","species":"Paracheirodon innesi",'
            '"notes":null,"estimatedPrice":2.5,"imageUrl":null,'
            '"quantity":6,"purchased":false,'
            '"createdAt":"${DateTime.now().toIso8601String()}",'
            '"purchasedAt":null}]',
      });

      await tester.pumpWidget(
        _wrap(
          overrides: [
            wishlistProvider.overrideWith(
              (ref) => _FailingUndoWishlistNotifier(ref),
            ),
          ],
        ),
      );
      await _advance(tester);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove Item'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Neon Tetra'), findsNothing);
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Neon Tetra'), findsNothing);
      expect(
        find.text('Could not restore Neon Tetra. Try again in a moment.'),
        findsOneWidget,
      );

      final prefs = await SharedPreferences.getInstance();
      final savedItems =
          jsonDecode(prefs.getString('wishlist_items')!) as List<dynamic>;
      expect(savedItems, isEmpty);
    });

    testWidgets('marking an item purchased saves it and updates budget', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'wishlist_items':
            '[{"id":"wishlist-purchase","name":"Neon Tetra",'
            '"category":"fish","species":"Paracheirodon innesi",'
            '"notes":null,"estimatedPrice":2.5,"imageUrl":null,'
            '"quantity":6,"purchased":false,'
            '"createdAt":"${DateTime.now().toIso8601String()}",'
            '"purchasedAt":null}]',
      });

      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.tap(find.byIcon(Icons.check_circle_outline));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Neon Tetra'), findsNothing);
      expect(find.text('Neon Tetra marked as purchased!'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      final savedItems =
          jsonDecode(prefs.getString('wishlist_items')!) as List<dynamic>;
      final savedItem = savedItems.single as Map<String, dynamic>;
      expect(savedItem['purchased'], isTrue);
      expect(savedItem['purchasedAt'], isNotNull);

      final savedBudget =
          jsonDecode(prefs.getString('shop_budget')!) as Map<String, dynamic>;
      expect(savedBudget['spentThisMonth'], 15.0);
    });

    testWidgets('failed purchase keeps item unpurchased with error feedback', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'wishlist_items':
            '[{"id":"wishlist-purchase-failure","name":"Neon Tetra",'
            '"category":"fish","species":"Paracheirodon innesi",'
            '"notes":null,"estimatedPrice":2.5,"imageUrl":null,'
            '"quantity":6,"purchased":false,'
            '"createdAt":"${DateTime.now().toIso8601String()}",'
            '"purchasedAt":null}]',
      });

      await tester.pumpWidget(
        _wrap(
          overrides: [
            wishlistProvider.overrideWith(
              (ref) => _FailingMarkPurchasedWishlistNotifier(ref),
            ),
          ],
        ),
      );
      await _advance(tester);

      await tester.tap(find.byIcon(Icons.check_circle_outline));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Neon Tetra'), findsOneWidget);
      expect(
        find.text(
          'Could not mark Neon Tetra as purchased. Try again in a moment.',
        ),
        findsOneWidget,
      );
      expect(find.text('Neon Tetra marked as purchased!'), findsNothing);

      final prefs = await SharedPreferences.getInstance();
      final savedItems =
          jsonDecode(prefs.getString('wishlist_items')!) as List<dynamic>;
      final savedItem = savedItems.single as Map<String, dynamic>;
      expect(savedItem['purchased'], isFalse);
      expect(savedItem['purchasedAt'], isNull);
      expect(prefs.getString('shop_budget'), isNull);
    });
  });
}
