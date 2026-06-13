// Unit tests for ShopService.
//
// Run: flutter test test/services/shop_service_test.dart

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/data/shop_catalog.dart';
import 'package:danio/services/shop_service.dart';
import 'package:danio/models/shop_item.dart';
import 'package:danio/providers/inventory_provider.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ShopItem _makeItem({
  String id = 'test_item',
  int gemCost = 10,
  bool isConsumable = true,
}) {
  return ShopItem(
    id: id,
    name: 'Test Item',
    description: 'A test item',
    emoji: '🧪',
    category: ShopItemCategory.extras,
    type: ShopItemType.streakFreeze,
    gemCost: gemCost,
    isConsumable: isConsumable,
  );
}

/// Build a real [ShopService] backed by a real Riverpod [ProviderContainer].
///
/// The [getInventoryNotifier] callback delegates to the container so that
/// [purchaseItem] / [useItem] calls hit the real (mocked-prefs) notifier.
ShopService _makeService({
  List<InventoryItem>? inventory,
  int gemBalance = 100,
}) {
  final container = ProviderContainer();

  return ShopService(
    getInventory: () => inventory ?? [],
    getGemBalance: () => gemBalance,
    getInventoryNotifier: () => container.read(inventoryProvider.notifier),
  );
}

Future<void> _settle() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ShopService.ownsItem', () {
    test('returns false when inventory is empty', () {
      final service = _makeService(inventory: []);
      expect(service.ownsItem('any_item'), isFalse);
    });

    test('returns true for owned consumable with quantity > 0', () {
      final item = InventoryItem(
        itemId: 'streak_freeze',
        quantity: 1,
        purchasedAt: DateTime.now(),
      );
      final service = _makeService(inventory: [item]);
      expect(service.ownsItem('streak_freeze'), isTrue);
    });

    test('returns false for unknown zero-quantity items', () {
      final item = InventoryItem(
        itemId: 'permanent_badge',
        quantity: 0,
        purchasedAt: DateTime.now(),
      );
      final service = _makeService(inventory: [item]);
      expect(service.ownsItem('permanent_badge'), isFalse);
    });

    test('returns false for item not in inventory at all', () {
      final item = InventoryItem(
        itemId: 'streak_freeze',
        quantity: 1,
        purchasedAt: DateTime.now(),
      );
      final service = _makeService(inventory: [item]);
      // Different ID — not found → StateError caught → false
      expect(service.ownsItem('not_in_inventory'), isFalse);
    });

    test('returns false for expired time-based item', () {
      final item = InventoryItem(
        itemId: 'xp_boost',
        quantity: 0,
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        purchasedAt: DateTime.now().subtract(const Duration(hours: 2)),
      );
      final service = _makeService(inventory: [item]);
      expect(service.ownsItem('xp_boost'), isFalse);
    });

    test('returns true for active non-expired time-based item', () {
      final item = InventoryItem(
        itemId: 'xp_boost',
        quantity: 0,
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        purchasedAt: DateTime.now(),
      );
      final service = _makeService(inventory: [item]);
      expect(service.ownsItem('xp_boost'), isTrue);
    });
  });

  group('ShopService.canPurchase', () {
    test('returns success when gems are sufficient and item not owned', () {
      final service = _makeService(inventory: [], gemBalance: 50);
      final item = _makeItem(gemCost: 10);
      final result = service.canPurchase(item);
      expect(result.success, isTrue);
    });

    test('returns insufficientGems when balance is too low', () {
      final service = _makeService(inventory: [], gemBalance: 5);
      final item = _makeItem(gemCost: 10);
      final result = service.canPurchase(item);
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('gems'));
      expect(result.requiredGems, 10);
      expect(result.availableGems, 5);
    });

    test('returns error when non-consumable already owned', () {
      final existing = InventoryItem(
        itemId: 'permanent_badge',
        quantity: 1,
        purchasedAt: DateTime.now(),
      );
      final service = _makeService(inventory: [existing], gemBalance: 100);
      final item = _makeItem(
        id: 'permanent_badge',
        gemCost: 20,
        isConsumable: false,
      );
      final result = service.canPurchase(item);
      expect(result.success, isFalse);
      expect(result.errorMessage, isNotEmpty);
    });

    test('allows re-purchasing consumable already owned', () {
      final existing = InventoryItem(
        itemId: 'streak_freeze',
        quantity: 1,
        purchasedAt: DateTime.now(),
      );
      final service = _makeService(inventory: [existing], gemBalance: 100);
      final item = _makeItem(
        id: 'streak_freeze',
        gemCost: 10,
        isConsumable: true,
      );
      final result = service.canPurchase(item);
      expect(result.success, isTrue);
    });

    test('canPurchase fails when gem balance exactly zero', () {
      final service = _makeService(inventory: [], gemBalance: 0);
      final item = _makeItem(gemCost: 1);
      final result = service.canPurchase(item);
      expect(result.success, isFalse);
    });

    test('canPurchase succeeds when gem balance exactly equals cost', () {
      final service = _makeService(inventory: [], gemBalance: 10);
      final item = _makeItem(gemCost: 10);
      final result = service.canPurchase(item);
      expect(result.success, isTrue);
    });
  });

  group('ShopService.getItemsByCategory / getAllItems', () {
    test('getItemsByCategory returns items for powerUps category', () {
      final service = _makeService();
      final items = service.getItemsByCategory(ShopItemCategory.powerUps);
      expect(items, isA<List<ShopItem>>());
    });

    test('getItemsByCategory returns items for extras category', () {
      final service = _makeService();
      final items = service.getItemsByCategory(ShopItemCategory.extras);
      expect(items, isA<List<ShopItem>>());
    });

    test('getAllItems returns non-empty list from catalog', () {
      final service = _makeService();
      expect(service.getAllItems(), isNotEmpty);
    });

    test('getAllItems items have valid ids and positive gem costs', () {
      final service = _makeService();
      for (final item in service.getAllItems()) {
        expect(item.id, isNotEmpty);
        expect(item.gemCost, greaterThan(0));
      }
    });
  });

  group('ShopCatalog availability', () {
    test('hides legacy no-op rewards from the available shop', () {
      final availableIds = ShopCatalog.availableItems.map((i) => i.id).toSet();

      expect(availableIds, isNot(contains('progress_protector')));
      expect(ShopCatalog.getById('daily_goal_shield')?.durationHours, 24);
    });
  });

  group('InventoryNotifier timed consumables', () {
    test('using an XP boost keeps an active timed record visible', () async {
      final purchasedAt = DateTime(2026, 6, 13, 10);
      final owned = InventoryItem(
        itemId: 'xp_boost_1h',
        quantity: 2,
        purchasedAt: purchasedAt,
      );

      SharedPreferences.setMockInitialValues({
        'shop_inventory': jsonEncode([owned.toJson()]),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);
      final sub = container.listen(inventoryProvider, (_, __) {});
      addTearDown(sub.close);
      await _settle();

      final notifier = container.read(inventoryProvider.notifier);
      expect(notifier.getQuantity('xp_boost_1h'), 2);

      final success = await notifier.useItem('xp_boost_1h');
      await _settle();

      expect(success, isTrue);
      expect(container.read(xpBoostActiveProvider), isTrue);
      expect(notifier.getQuantity('xp_boost_1h'), 1);

      final inventory = container.read(inventoryProvider).valueOrNull ?? [];
      expect(
        inventory.any(
          (item) =>
              item.itemId == 'xp_boost_1h' &&
              item.isActive &&
              !item.isExpired &&
              item.expiresAt != null,
        ),
        isTrue,
      );
    });
  });
}
