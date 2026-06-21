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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WishlistNotifier persistence', () {
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
  });
}
