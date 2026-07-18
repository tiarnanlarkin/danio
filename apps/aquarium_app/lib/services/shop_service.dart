import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shop_item.dart';
import '../models/purchase_result.dart';
import '../data/shop_catalog.dart';
import '../providers/gems_provider.dart';
import '../providers/inventory_provider.dart';

/// Provider for the shop service
final shopServiceProvider = Provider<ShopService>((ref) {
  return ShopService(
    getInventory: () => ref.read(inventoryProvider).valueOrNull ?? [],
    getGemBalance: () => ref.read(gemBalanceProvider),
    getInventoryNotifier: () => ref.read(inventoryProvider.notifier),
  );
});

/// Service for handling shop purchases and inventory management.
///
/// All inventory operations delegate to [InventoryNotifier], which owns the
/// single source of truth stored in SharedPreferences under key `shop_inventory`.
/// This class is now a thin facade over the provider layer.
///
/// Dependencies are injected via constructor callbacks rather than storing a
/// [Ref] field — this keeps the service decoupled from the provider system
/// and easier to test.
class ShopService {
  final List<InventoryItem> Function() getInventory;
  final int Function() getGemBalance;
  final InventoryNotifier Function() getInventoryNotifier;

  const ShopService({
    required this.getInventory,
    required this.getGemBalance,
    required this.getInventoryNotifier,
  });

  /// Check if user owns a specific item.
  bool ownsItem(String itemId) {
    final inventory = getInventory();
    return inventory.any((item) {
      if (item.itemId != itemId) return false;
      if (item.isActive || item.expiresAt != null) return !item.isExpired;
      if (item.quantity > 0) return true;

      try {
        final catalogItem = ShopCatalog.allItems.firstWhere(
          (catalogItem) => catalogItem.id == item.itemId,
        );
        return !catalogItem.isConsumable;
      } on StateError {
        return false;
      }
    });
  }

  /// Get quantity of a consumable item.
  int getItemQuantity(String itemId) {
    return getInventoryNotifier().getQuantity(itemId);
  }

  /// Check if user can purchase an item.
  PurchaseResult canPurchase(ShopItem item) {
    final gemBalance = getGemBalance();

    if (gemBalance < item.gemCost) {
      return PurchaseResult.insufficientGems(
        required: item.gemCost,
        available: gemBalance,
      );
    }

    if (!item.isConsumable && ownsItem(item.id)) {
      return PurchaseResult.error('You already own this item');
    }

    return PurchaseResult.success(item);
  }

  /// Purchase an item from the shop.
  ///
  /// Delegates to [InventoryNotifier.purchaseItem], which attempts a compensating
  /// refund if the inventory save fails and surfaces both failures when refund
  /// durability cannot be confirmed.
  Future<PurchaseResult> purchaseItem(ShopItem item) async {
    final canPurchaseResult = canPurchase(item);
    if (!canPurchaseResult.success) {
      return canPurchaseResult;
    }

    final success = await getInventoryNotifier().purchaseItem(item);

    if (!success) {
      return PurchaseResult.error('Failed to purchase item');
    }

    return PurchaseResult.success(item);
  }

  /// Use/activate a consumable item.
  ///
  /// Delegates to [InventoryNotifier.useItem] which handles effect application
  /// and quantity tracking in a single consistent flow.
  Future<bool> useItem(String itemId) async {
    return getInventoryNotifier().useItem(itemId);
  }

  /// Check if a specific item is currently active.
  bool isItemActive(String itemId) {
    return getInventoryNotifier().isItemActive(itemId);
  }

  /// Clean up expired items from inventory.
  ///
  /// Delegates to [InventoryNotifier.cleanupExpiredItems].
  Future<void> cleanupExpiredItems() async {
    await getInventoryNotifier().cleanupExpiredItems();
  }

  /// Get all items from catalog filtered by category.
  List<ShopItem> getItemsByCategory(ShopItemCategory category) {
    return ShopCatalog.getByCategory(category);
  }

  /// Get all available shop items.
  List<ShopItem> getAllItems() {
    return ShopCatalog.availableItems;
  }
}

/// Provider for item quantity — derives from [inventoryProvider].
final itemQuantityProvider = Provider.family<int, String>((ref, itemId) {
  final inventoryAsync = ref.watch(inventoryProvider);
  return inventoryAsync.when(
    loading: () => 0,
    error: (_, __) => 0,
    data: (items) => items
        .where((i) => i.itemId == itemId && !i.isActive && !i.isExpired)
        .fold<int>(0, (sum, i) => sum + i.quantity),
  );
});

/// Provider to check if item is active — derives from [inventoryProvider].
final isItemActiveProvider = Provider.family<bool, String>((ref, itemId) {
  final inventoryAsync = ref.watch(inventoryProvider);
  return inventoryAsync.when(
    loading: () => false,
    error: (_, __) => false,
    data: (items) => items.any(
      (item) => item.itemId == itemId && item.isActive && !item.isExpired,
    ),
  );
});
