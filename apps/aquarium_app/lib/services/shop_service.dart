import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shop_item.dart';
import '../models/purchase_result.dart';
import '../models/user_profile.dart';
import '../providers/gems_provider.dart';
import '../providers/user_profile_provider.dart';
import '../data/shop_catalog.dart';

/// Provider for the shop service
final shopServiceProvider = Provider<ShopService>((ref) {
  return ShopService(ref);
});

/// Service for handling shop purchases and inventory management
class ShopService {
  final Ref ref;

  ShopService(this.ref);

  /// Get user's current inventory
  List<InventoryItem> getInventory() {
    final profile = ref.read(userProfileProvider).value;
    return profile?.inventory ?? [];
  }

  /// Check if user owns a specific item
  bool ownsItem(String itemId) {
    final inventory = getInventory();
    InventoryItem? item;
    try {
      item = inventory.firstWhere((inv) => inv.itemId == itemId);
    } catch (_) {
      return false;
    }

    // Check if it's a consumable with quantity
    if (item.quantity > 0) return true;

    // Check if it's a time-based item that hasn't expired
    if (item.expiresAt != null) {
      return !item.isExpired;
    }

    // Non-consumable permanent item
    return true;
  }

  /// Get quantity of a consumable item
  int getItemQuantity(String itemId) {
    final inventory = getInventory();
    try {
      final item = inventory.firstWhere((inv) => inv.itemId == itemId);
      return item.quantity;
    } catch (_) {
      return 0;
    }
  }

  /// Check if user can purchase an item
  PurchaseResult canPurchase(ShopItem item) {
    final gemBalance = ref.read(gemBalanceProvider);

    // Check if user has enough gems
    if (gemBalance < item.gemCost) {
      return PurchaseResult.insufficientGems(
        required: item.gemCost,
        available: gemBalance,
      );
    }

    // For non-consumables, check if already owned
    if (!item.isConsumable && ownsItem(item.id)) {
      return PurchaseResult.error('You already own this item');
    }

    return PurchaseResult.success(item);
  }

  /// Purchase an item from the shop
  Future<PurchaseResult> purchaseItem(ShopItem item) async {
    // Check if purchase is valid
    final canPurchaseResult = canPurchase(item);
    if (!canPurchaseResult.success) {
      return canPurchaseResult;
    }

    // Attempt to spend gems
    final gemsNotifier = ref.read(gemsProvider.notifier);
    final success = await gemsNotifier.spendGems(
      amount: item.gemCost,
      itemId: item.id,
      itemName: item.name,
    );

    if (!success) {
      return PurchaseResult.error('Failed to deduct gems');
    }

    // Add item to inventory
    await _addToInventory(item);

    return PurchaseResult.success(item);
  }

  /// Add an item to user's inventory
  Future<void> _addToInventory(ShopItem item) async {
    final profile = ref.read(userProfileProvider).value;
    if (profile == null) return;

    final now = DateTime.now();
    final inventory = List<InventoryItem>.from(profile.inventory);

    // Check if item already exists in inventory
    final existingIndex = inventory.indexWhere((inv) => inv.itemId == item.id);

    if (existingIndex != -1 && item.isConsumable) {
      // For consumables, increment quantity
      final existing = inventory[existingIndex];
      inventory[existingIndex] = existing.copyWith(
        quantity: existing.quantity + (item.quantity ?? 1),
      );
    } else {
      // Add new item to inventory
      final expiresAt = item.durationHours != null
          ? now.add(Duration(hours: item.durationHours!))
          : null;

      inventory.add(
        InventoryItem(
          itemId: item.id,
          quantity: item.quantity ?? 1,
          expiresAt: expiresAt,
          purchasedAt: now,
          isActive: false,
        ),
      );
    }

    // Update profile with new inventory
    await ref
        .read(userProfileProvider.notifier)
        .updateProfile(inventory: inventory);
  }

  /// Use/activate a consumable item
  Future<bool> useItem(String itemId) async {
    final profile = ref.read(userProfileProvider).value;
    if (profile == null) return false;

    final inventory = List<InventoryItem>.from(profile.inventory);
    final itemIndex = inventory.indexWhere((inv) => inv.itemId == itemId);

    if (itemIndex == -1) return false;

    final item = inventory[itemIndex];
    final shopItem = ShopCatalog.getById(itemId);

    if (shopItem == null) return false;

    // Handle consumable items
    if (shopItem.isConsumable) {
      if (item.quantity <= 0) return false;

      // Decrement quantity
      if (item.quantity == 1) {
        // Remove item if quantity reaches 0
        inventory.removeAt(itemIndex);
      } else {
        inventory[itemIndex] = item.copyWith(quantity: item.quantity - 1);
      }
    } else {
      // For time-based items, activate them
      if (shopItem.durationHours != null) {
        final expiresAt = DateTime.now().add(
          Duration(hours: shopItem.durationHours!),
        );
        inventory[itemIndex] = item.copyWith(
          isActive: true,
          expiresAt: expiresAt,
        );
      }
    }

    // Update profile
    await ref
        .read(userProfileProvider.notifier)
        .updateProfile(inventory: inventory);

    return true;
  }

  /// Check if a specific item is currently active
  bool isItemActive(String itemId) {
    final inventory = getInventory();
    InventoryItem? item;
    try {
      item = inventory.firstWhere((inv) => inv.itemId == itemId);
    } catch (_) {
      return false;
    }
    if (!item.isActive) return false;
    if (item.isExpired) return false;

    return true;
  }

  /// Clean up expired items from inventory
  Future<void> cleanupExpiredItems() async {
    final profile = ref.read(userProfileProvider).value;
    if (profile == null) return;

    final inventory = profile.inventory
        .where((item) => !item.isExpired)
        .toList();

    if (inventory.length != profile.inventory.length) {
      await ref
          .read(userProfileProvider.notifier)
          .updateProfile(inventory: inventory);
    }
  }

  /// Get all items from catalog filtered by category
  List<ShopItem> getItemsByCategory(ShopItemCategory category) {
    return ShopCatalog.getByCategory(category);
  }

  /// Get all available shop items
  List<ShopItem> getAllItems() {
    return ShopCatalog.availableItems;
  }
}

/// Provider to check if user owns a specific item
final ownsItemProvider = Provider.family<bool, String>((ref, itemId) {
  final shopService = ref.watch(shopServiceProvider);
  return shopService.ownsItem(itemId);
});

/// Provider for item quantity
final itemQuantityProvider = Provider.family<int, String>((ref, itemId) {
  final shopService = ref.watch(shopServiceProvider);
  return shopService.getItemQuantity(itemId);
});

/// Provider to check if item is active
final isItemActiveProvider = Provider.family<bool, String>((ref, itemId) {
  final shopService = ref.watch(shopServiceProvider);
  return shopService.isItemActive(itemId);
});
