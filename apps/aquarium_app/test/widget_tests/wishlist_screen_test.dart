// Widget tests for WishlistScreen.
//
// Run: flutter test test/widget_tests/wishlist_screen_test.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/wishlist_screen.dart';
import 'package:danio/models/wishlist.dart';
import 'package:danio/providers/wishlist_provider.dart';
import 'package:danio/widgets/core/app_button.dart';

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

class _FailingPurchaseCompensationWishlistNotifier extends WishlistNotifier {
  _FailingPurchaseCompensationWishlistNotifier(super.ref);

  @override
  Future<void> updateItem(WishlistItem item) async {
    throw StateError('purchase compensation failed');
  }
}

class _FailingAddPurchaseBudgetNotifier extends BudgetNotifier {
  _FailingAddPurchaseBudgetNotifier(super.ref);

  @override
  Future<void> addPurchase(double amount) async {
    throw StateError('budget save failed');
  }
}

class _FailingRemoveWishlistNotifier extends WishlistNotifier {
  _FailingRemoveWishlistNotifier(super.ref);

  @override
  Future<void> removeItem(String id) async {
    throw StateError('remove save failed');
  }
}

class _DeleteBeforeRemoveWishlistNotifier extends WishlistNotifier {
  _DeleteBeforeRemoveWishlistNotifier(super.ref);

  @override
  Future<void> removeItem(String id) async {
    await super.removeItem(id);
    await super.removeItem(id);
  }
}

class _FailingUndoWishlistNotifier extends WishlistNotifier {
  _FailingUndoWishlistNotifier(super.ref);

  @override
  Future<void> addItem(WishlistItem item) async {
    throw StateError('restore save failed');
  }
}

class _DeleteBeforeUpdateWishlistNotifier extends WishlistNotifier {
  _DeleteBeforeUpdateWishlistNotifier(super.ref);

  @override
  Future<void> updateItem(WishlistItem item) async {
    await super.removeItem(item.id);
    await super.updateItem(item);
  }
}

class _ReplayProbeWishlistNotifier extends WishlistNotifier {
  _ReplayProbeWishlistNotifier(super.ref);

  final firstAddGate = Completer<void>();
  int addAttempts = 0;

  @override
  Future<void> addItem(WishlistItem item) async {
    addAttempts += 1;
    if (addAttempts == 1) {
      await firstAddGate.future;
    }
    await super.addItem(item);
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

    testWidgets(
      'captured stale add callback cannot replay across failure and retry',
      (tester) async {
        late _ReplayProbeWishlistNotifier notifier;
        await tester.pumpWidget(
          _wrap(
            overrides: [
              wishlistProvider.overrideWith(
                (ref) => notifier = _ReplayProbeWishlistNotifier(ref),
              ),
            ],
          ),
        );
        await _advance(tester);

        await tester.tap(find.text('Add Item').first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.enterText(
          find.widgetWithText(TextField, 'Fish name'),
          'Cardinal Tetra',
        );
        await tester.pump();

        final addButton = find.widgetWithText(AppButton, 'Add to Wishlist');
        final capturedAdd = tester.widget<AppButton>(addButton).onPressed!;
        capturedAdd();
        await tester.pump();
        capturedAdd();
        await tester.pump();

        expect(notifier.addAttempts, 1);
        expect(tester.widget<AppButton>(addButton).isLoading, isTrue);

        notifier.firstAddGate.completeError(
          StateError('wishlist persistence failed'),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(
          find.text(
            'Could not save that wishlist item. Try again in a moment.',
          ),
          findsOneWidget,
        );
        expect(notifier.addAttempts, 1);
        expect(tester.widget<AppButton>(addButton).isLoading, isFalse);

        await tester.tap(addButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(notifier.addAttempts, 2);
        expect(find.text('Cardinal Tetra'), findsOneWidget);

        final prefs = await SharedPreferences.getInstance();
        final savedItems =
            jsonDecode(prefs.getString('wishlist_items')!) as List<dynamic>;
        expect(savedItems, hasLength(1));
      },
    );
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

    testWidgets(
      'editing a stale wishlist item shows error instead of false success',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'wishlist_items':
              '[{"id":"wishlist-stale-edit","name":"Neon Tetra",'
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
                (ref) => _DeleteBeforeUpdateWishlistNotifier(ref),
              ),
            ],
          ),
        );
        await _advance(tester);

        await tester.tap(find.text('Neon Tetra'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextField, 'Fish name'),
          'Cardinal Tetra',
        );
        await tester.tap(find.text('Save Changes'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(tester.takeException(), isNull);
        expect(
          find.text(
            'Could not save that wishlist item. Try again in a moment.',
          ),
          findsOneWidget,
        );
        expect(find.text('Cardinal Tetra saved.'), findsNothing);
        expect(find.text('Edit Item'), findsOneWidget);

        final prefs = await SharedPreferences.getInstance();
        final savedItems =
            jsonDecode(prefs.getString('wishlist_items')!) as List<dynamic>;
        expect(savedItems, isEmpty);
      },
    );

    testWidgets('tablet keeps wishlist item cards readable', (tester) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({
        'wishlist_items':
            '[{"id":"wishlist-tablet","name":"Neon Tetra",'
            '"category":"fish","species":"Paracheirodon innesi",'
            '"notes":null,"estimatedPrice":2.5,"imageUrl":null,'
            '"quantity":6,"purchased":false,'
            '"createdAt":"${DateTime.now().toIso8601String()}",'
            '"purchasedAt":null}]',
      });

      await tester.pumpWidget(_wrap());
      await _advance(tester);

      final itemCard = find.ancestor(
        of: find.text('Neon Tetra'),
        matching: find.byType(Card),
      );

      expect(itemCard, findsOneWidget);
      expect(tester.getSize(itemCard).width, lessThanOrEqualTo(720));
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

    testWidgets(
      'deleting a stale wishlist item shows error instead of false success',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'wishlist_items':
              '[{"id":"wishlist-stale-remove","name":"Neon Tetra",'
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
                (ref) => _DeleteBeforeRemoveWishlistNotifier(ref),
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
        expect(
          find.text('Could not remove Neon Tetra. Try again in a moment.'),
          findsOneWidget,
        );
        expect(find.text('Neon Tetra removed'), findsNothing);
        expect(find.text('Undo'), findsNothing);

        final prefs = await SharedPreferences.getInstance();
        final savedItems =
            jsonDecode(prefs.getString('wishlist_items')!) as List<dynamic>;
        expect(savedItems, isEmpty);
      },
    );

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

    testWidgets(
      'failed purchase compensation reports persisted purchase and missing budget update',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'wishlist_items':
              '[{"id":"wishlist-purchase-partial","name":"Neon Tetra",'
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
                (ref) => _FailingPurchaseCompensationWishlistNotifier(ref),
              ),
              budgetProvider.overrideWith(
                (ref) => _FailingAddPurchaseBudgetNotifier(ref),
              ),
            ],
          ),
        );
        await _advance(tester);

        await tester.tap(find.byIcon(Icons.check_circle_outline));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(tester.takeException(), isNull);
        expect(find.text('Neon Tetra'), findsNothing);
        expect(
          find.text(
            'Neon Tetra was marked as purchased, but the budget could not be updated.',
          ),
          findsOneWidget,
        );
        expect(
          find.text(
            'Could not mark Neon Tetra as purchased. Try again in a moment.',
          ),
          findsNothing,
        );
        expect(find.text('Neon Tetra marked as purchased!'), findsNothing);

        final prefs = await SharedPreferences.getInstance();
        final savedItems =
            jsonDecode(prefs.getString('wishlist_items')!) as List<dynamic>;
        final savedItem = savedItems.single as Map<String, dynamic>;
        expect(savedItem['purchased'], isTrue);
        expect(savedItem['purchasedAt'], isNotNull);
        expect(prefs.getString('shop_budget'), isNull);
      },
    );

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
