// Persistence tests for WishlistNotifier.
//
// Run: flutter test test/providers/wishlist_persistence_test.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/models/wishlist.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/providers/wishlist_provider.dart';

class _DelayedSetStringPrefs implements SharedPreferences {
  _DelayedSetStringPrefs({
    required SharedPreferences delegate,
    required this.delayedKey,
    required this.gate,
  }) : _delegate = delegate;

  final SharedPreferences _delegate;
  final String delayedKey;
  final Completer<bool> gate;

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  Future<bool> setString(String key, String value) {
    if (key == delayedKey) {
      return gate.future.then((saved) async {
        if (!saved) return false;
        return _delegate.setString(key, value);
      });
    }
    return _delegate.setString(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _waitForWishlistLoad(
  ProviderContainer container, {
  int? expectedLength,
}) async {
  for (var i = 0; i < 20; i += 1) {
    final items = container.read(wishlistProvider);
    if (expectedLength == null || items.length == expectedLength) return;
    await Future<void>.delayed(Duration.zero);
  }
}

Future<void> _waitForLocalShopsLoad(
  ProviderContainer container, {
  int? expectedLength,
}) async {
  for (var i = 0; i < 20; i += 1) {
    final shops = container.read(localShopsProvider);
    if (expectedLength == null || shops.length == expectedLength) return;
    await Future<void>.delayed(Duration.zero);
  }
}

WishlistItem _wishlistItem({
  String id = 'wishlist-cardinal-tetra',
  String name = 'Cardinal tetra',
  bool purchased = false,
}) {
  return WishlistItem(
    id: id,
    category: WishlistCategory.fish,
    name: name,
    quantity: 6,
    purchased: purchased,
    createdAt: DateTime(2026, 6, 21, 12),
  );
}

LocalShop _localShop({
  String id = 'local-shop-cardiff-aquatics',
  String name = 'Cardiff Aquatics',
}) {
  return LocalShop(
    id: id,
    name: name,
    distanceMiles: 4.2,
    notes: 'Good planted tank section',
    createdAt: DateTime(2026, 6, 21, 14),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Shop planning persistence', () {
    test('addItem waits for wishlist save before exposing the item', () async {
      final existing = _wishlistItem(
        id: 'wishlist-existing-guppy',
        name: 'Guppy',
      );
      SharedPreferences.setMockInitialValues({
        'wishlist_items': jsonEncode([existing.toJson()]),
      });
      final prefs = await SharedPreferences.getInstance();
      final saveGate = Completer<bool>();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async {
            return _DelayedSetStringPrefs(
              delegate: prefs,
              delayedKey: 'wishlist_items',
              gate: saveGate,
            );
          }),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(wishlistProvider, (_, __) {});
      addTearDown(subscription.close);
      await _waitForWishlistLoad(container, expectedLength: 1);

      final item = _wishlistItem();
      final save = container.read(wishlistProvider.notifier).addItem(item);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(wishlistProvider).map((entry) => entry.id), [
        existing.id,
      ]);

      saveGate.complete(true);
      await save;

      expect(container.read(wishlistProvider).map((entry) => entry.id), [
        existing.id,
        item.id,
      ]);
      expect(
        jsonDecode(prefs.getString('wishlist_items')!) as List<dynamic>,
        hasLength(2),
      );
    });

    test(
      'removeItem keeps item visible until wishlist save completes',
      () async {
        final item = _wishlistItem();
        SharedPreferences.setMockInitialValues({
          'wishlist_items': jsonEncode([item.toJson()]),
        });
        final prefs = await SharedPreferences.getInstance();
        final saveGate = Completer<bool>();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _DelayedSetStringPrefs(
                delegate: prefs,
                delayedKey: 'wishlist_items',
                gate: saveGate,
              );
            }),
          ],
        );
        addTearDown(container.dispose);
        final subscription = container.listen(wishlistProvider, (_, __) {});
        addTearDown(subscription.close);
        await _waitForWishlistLoad(container, expectedLength: 1);

        final save = container
            .read(wishlistProvider.notifier)
            .removeItem(item.id);
        await Future<void>.delayed(Duration.zero);

        expect(container.read(wishlistProvider).map((entry) => entry.id), [
          item.id,
        ]);

        saveGate.complete(true);
        await save;

        expect(container.read(wishlistProvider), isEmpty);
        expect(
          jsonDecode(prefs.getString('wishlist_items')!) as List<dynamic>,
          isEmpty,
        );
      },
    );

    test('markPurchased rejects missing items before reporting success', () async {
      final item = _wishlistItem();
      SharedPreferences.setMockInitialValues({
        'wishlist_items': jsonEncode([item.toJson()]),
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final subscription = container.listen(wishlistProvider, (_, __) {});
      addTearDown(subscription.close);
      await _waitForWishlistLoad(container, expectedLength: 1);

      await expectLater(
        container.read(wishlistProvider.notifier).markPurchased('missing-item'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('Wishlist item missing-item was not found'),
          ),
        ),
      );

      expect(container.read(wishlistProvider).single.purchased, isFalse);
      final savedItems =
          jsonDecode(prefs.getString('wishlist_items')!) as List<dynamic>;
      expect((savedItems.single as Map<String, dynamic>)['purchased'], isFalse);
    });

    test(
      'setMonthlyBudget waits for budget save before exposing amount',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final saveGate = Completer<bool>();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _DelayedSetStringPrefs(
                delegate: prefs,
                delayedKey: 'shop_budget',
                gate: saveGate,
              );
            }),
          ],
        );
        addTearDown(container.dispose);
        final subscription = container.listen(budgetProvider, (_, __) {});
        addTearDown(subscription.close);
        final initialBudget = container.read(budgetProvider).monthlyBudget;

        final save = container
            .read(budgetProvider.notifier)
            .setMonthlyBudget(150);
        await Future<void>.delayed(Duration.zero);

        expect(container.read(budgetProvider).monthlyBudget, initialBudget);

        saveGate.complete(true);
        await save;

        expect(container.read(budgetProvider).monthlyBudget, 150);
        expect(
          jsonDecode(prefs.getString('shop_budget')!) as Map<String, dynamic>,
          containsPair('monthlyBudget', 150.0),
        );
      },
    );

    test('addShop waits for local shop save before exposing shop', () async {
      final existing = _localShop(
        id: 'local-shop-existing',
        name: 'Existing Aquatics',
      );
      SharedPreferences.setMockInitialValues({
        'local_shops': jsonEncode([existing.toJson()]),
      });
      final prefs = await SharedPreferences.getInstance();
      final saveGate = Completer<bool>();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async {
            return _DelayedSetStringPrefs(
              delegate: prefs,
              delayedKey: 'local_shops',
              gate: saveGate,
            );
          }),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(localShopsProvider, (_, __) {});
      addTearDown(subscription.close);
      await _waitForLocalShopsLoad(container, expectedLength: 1);

      final shop = _localShop();
      final save = container.read(localShopsProvider.notifier).addShop(shop);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(localShopsProvider).map((entry) => entry.id), [
        existing.id,
      ]);

      saveGate.complete(true);
      await save;

      expect(container.read(localShopsProvider).map((entry) => entry.id), [
        existing.id,
        shop.id,
      ]);
      expect(
        jsonDecode(prefs.getString('local_shops')!) as List<dynamic>,
        hasLength(2),
      );
    });
  });
}
