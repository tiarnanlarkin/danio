import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shop_item.dart';
import '../data/shop_catalog.dart';
import 'gems_provider.dart';
import 'hearts_provider.dart';
import 'user_profile_provider.dart';
import '../utils/logger.dart';

/// Provider for user's shop inventory
final inventoryProvider =
    StateNotifierProvider.autoDispose<InventoryNotifier, AsyncValue<List<InventoryItem>>>((
      ref,
    ) {
      return InventoryNotifier(ref);
    });

class InventoryNotifier extends StateNotifier<AsyncValue<List<InventoryItem>>> {
  InventoryNotifier(this.ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref ref;
  static const _key = 'shop_inventory';
  Timer? _saveDebounce;

  @override
  void dispose() {
    _saveDebounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final json = prefs.getString(_key);

      List<InventoryItem> inventory;
      if (json != null) {
        final List<dynamic> decoded = jsonDecode(json);
        inventory = decoded
            .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        inventory = [];
      }

      // Migrate any inventory stored in UserProfile.inventory (legacy dual-store).
      // If SharedPreferences has no items but the user profile does, copy them over
      // and clear the profile field so we never read stale data again.
      if (inventory.isEmpty) {
        try {
          final profile = ref.read(userProfileProvider).valueOrNull;
          if (profile != null && profile.inventory.isNotEmpty) {
            inventory = List<InventoryItem>.from(profile.inventory);
            // Persist to SharedPreferences (our single source of truth).
            final migrateJson = jsonEncode(
              inventory.map((i) => i.toJson()).toList(),
            );
            await prefs.setString(_key, migrateJson);
            // Clear the legacy field so we don't re-migrate.
            await ref
                .read(userProfileProvider.notifier)
                .updateProfile(inventory: []);
          }
        } catch (e) {
          // Migration is best-effort — if profile isn't loaded yet, we'll
          // try again next time inventory loads.
          logError('InventoryProvider: migration best-effort failed: $e', tag: 'InventoryProvider');
        }
      }

      state = AsyncValue.data(inventory);
    } catch (e, st) {
      logError('InventoryProvider: _load failed: $e', stackTrace: st, tag: 'InventoryProvider');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _save(List<InventoryItem> inventory) async {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () async {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final json = jsonEncode(inventory.map((i) => i.toJson()).toList());
      await prefs.setString(_key, json);
    });
  }

  /// Purchase an item from the shop.
  ///
  /// Uses a compensating-refund pattern: if gems are deducted but the
  /// inventory save fails, the gems are automatically refunded so the user
  /// never loses currency without receiving the item.
  Future<bool> purchaseItem(ShopItem item) async {
    // Guard: if inventory hasn't loaded, purchasing would wipe existing items.
    if (!state.hasValue) {
      logError(
        'InventoryProvider: purchaseItem called while state is not loaded (${state.runtimeType}) — aborting to prevent data loss',
        tag: 'InventoryProvider',
      );
      return false;
    }
    final currentInventory = state.valueOrNull ?? [];
    final gemsNotifier = ref.read(gemsProvider.notifier);

    // Try to spend gems
    final success = await gemsNotifier.spendGems(
      amount: item.gemCost,
      itemId: item.id,
      itemName: item.name,
    );

    if (!success) {
      return false; // Not enough gems
    }

    // Add to inventory — wrap in try/catch for compensating refund
    try {
      final now = DateTime.now();
      InventoryItem inventoryItem;

      if (item.isConsumable) {
        // Check if item already exists (stack quantities)
        final existingIndex = currentInventory.indexWhere(
          (i) => i.itemId == item.id,
        );

        if (existingIndex >= 0) {
          // Increase quantity
          final existing = currentInventory[existingIndex];
          inventoryItem = existing.copyWith(
            quantity: existing.quantity + (item.quantity ?? 1),
          );

          final updated = List<InventoryItem>.from(currentInventory);
          updated[existingIndex] = inventoryItem;
          await _save(updated);
          state = AsyncValue.data(updated);
        } else {
          // New consumable item
          inventoryItem = InventoryItem(
            itemId: item.id,
            quantity: item.quantity ?? 1,
            purchasedAt: now,
          );

          final updated = [...currentInventory, inventoryItem];
          await _save(updated);
          state = AsyncValue.data(updated);
        }
      } else {
        // Permanent item (cosmetic, etc.)
        // Check if already owned
        if (hasItem(item.id)) {
          // Refund - already owned
          await gemsNotifier.refund(
            amount: item.gemCost,
            itemId: item.id,
            itemName: item.name,
          );
          return false;
        }

        inventoryItem = InventoryItem(
          itemId: item.id,
          quantity: 1,
          purchasedAt: now,
        );

        final updated = [...currentInventory, inventoryItem];
        await _save(updated);
        state = AsyncValue.data(updated);
      }

      return true;
    } catch (e, st) {
      logError('InventoryProvider: purchase failed, compensating refund: $e', stackTrace: st, tag: 'InventoryProvider');
      // Compensating refund: inventory save failed, give gems back
      await gemsNotifier.refund(
        amount: item.gemCost,
        itemId: item.id,
        itemName: item.name,
      );
      rethrow;
    }
  }

  /// Use/consume an item AND apply its effect
  Future<bool> useItem(String itemId) async {
    if (!state.hasValue) {
      logError(
        'InventoryProvider: useItem called while state is not loaded — aborting',
        tag: 'InventoryProvider',
      );
      return false;
    }
    final currentInventory = state.valueOrNull ?? [];
    final itemIndex = currentInventory.indexWhere((i) => i.itemId == itemId);

    if (itemIndex < 0) return false;

    final item = currentInventory[itemIndex];
    final shopItem = ShopCatalog.getById(itemId);
    if (shopItem == null) return false;

    // Apply the effect first
    final effectApplied = await _applyItemEffect(shopItem);
    if (!effectApplied) return false;

    if (shopItem.isConsumable) {
      // Decrease quantity
      if (item.quantity <= 1) {
        // Remove item entirely
        final updated = List<InventoryItem>.from(currentInventory)
          ..removeAt(itemIndex);
        await _save(updated);
        state = AsyncValue.data(updated);
      } else {
        // Decrease quantity by 1
        final updatedItem = item.copyWith(quantity: item.quantity - 1);
        final updated = List<InventoryItem>.from(currentInventory);
        updated[itemIndex] = updatedItem;
        await _save(updated);
        state = AsyncValue.data(updated);
      }
      return true;
    } else {
      // Permanent items can't be "used" in the traditional sense
      // But we can activate time-based effects
      if (shopItem.durationHours != null) {
        final expiresAt = DateTime.now().add(
          Duration(hours: shopItem.durationHours!),
        );
        final updatedItem = item.copyWith(isActive: true, expiresAt: expiresAt);
        final updated = List<InventoryItem>.from(currentInventory);
        updated[itemIndex] = updatedItem;
        await _save(updated);
        state = AsyncValue.data(updated);
        return true;
      }
      return false;
    }
  }

  /// Apply the actual effect of an item
  Future<bool> _applyItemEffect(ShopItem item) async {
    switch (item.type) {
      case ShopItemType.heartsRefill:
        // Refill all hearts to max
        final heartsActions = ref.read(heartsActionsProvider);
        await heartsActions.refillToMax();
        return true;

      case ShopItemType.streakFreeze:
        // Add a streak freeze to user profile
        final profileNotifier = ref.read(userProfileProvider.notifier);
        await profileNotifier.addStreakFreeze();
        return true;

      case ShopItemType.xpBoost:
        // XP boost is handled by activating the item with expiry time
        // The xpBoostActiveProvider checks if it's active
        await _activateTimedItem(item.id, item.durationHours ?? 1);
        return true;

      case ShopItemType.quizSecondChance:
      case ShopItemType.lessonHelper:
        // These items are no longer sold; legacy inventory items are no-ops.
        return true;

      case ShopItemType.tankTheme:
        // Themes are applied via the theme gallery, not directly
        // But we can auto-apply if it's the first purchase
        return true;

      case ShopItemType.profileBadge:
        // Badges are automatically shown once owned
        return true;

      case ShopItemType.celebrationEffect:
        // Celebration effects are automatically used once owned
        return true;

      case ShopItemType.goalAdjust:
        // Goal adjustments are time-based
        if (item.durationHours != null) {
          await _activateTimedItem(item.id, item.durationHours!);
        }
        return true;
    }
  }

  /// Activate a timed item (sets isActive=true with expiry)
  Future<void> _activateTimedItem(String itemId, int durationHours) async {
    final currentInventory = state.valueOrNull ?? [];
    final itemIndex = currentInventory.indexWhere((i) => i.itemId == itemId);
    if (itemIndex < 0) return;

    final item = currentInventory[itemIndex];
    final expiresAt = DateTime.now().add(Duration(hours: durationHours));
    final updatedItem = item.copyWith(isActive: true, expiresAt: expiresAt);

    final updated = List<InventoryItem>.from(currentInventory);
    updated[itemIndex] = updatedItem;
    await _save(updated);
    state = AsyncValue.data(updated);
  }

  /// Activate a time-based item (XP boost, etc.)
  Future<bool> activateItem(String itemId) async {
    final currentInventory = state.valueOrNull ?? [];
    final itemIndex = currentInventory.indexWhere((i) => i.itemId == itemId);

    if (itemIndex < 0) return false;

    final item = currentInventory[itemIndex];
    final shopItem = ShopCatalog.getById(itemId);
    if (shopItem == null || shopItem.durationHours == null) return false;

    // Set expiry time and mark as active
    final expiresAt = DateTime.now().add(
      Duration(hours: shopItem.durationHours!),
    );
    final updatedItem = item.copyWith(isActive: true, expiresAt: expiresAt);

    final updated = List<InventoryItem>.from(currentInventory);
    updated[itemIndex] = updatedItem;
    await _save(updated);
    state = AsyncValue.data(updated);

    // If consumable, decrease quantity
    if (shopItem.isConsumable) {
      await useItem(itemId);
    }

    return true;
  }

  /// Check if user owns an item
  bool hasItem(String itemId) {
    final currentInventory = state.valueOrNull ?? [];
    return currentInventory.any((i) => i.itemId == itemId);
  }

  /// Get quantity of an item
  int getQuantity(String itemId) {
    final currentInventory = state.valueOrNull ?? [];
    final item = currentInventory.firstWhere(
      (i) => i.itemId == itemId,
      orElse: () =>
          InventoryItem(itemId: '', quantity: 0, purchasedAt: DateTime.now()),
    );
    return item.quantity;
  }

  /// Check if an item is active
  bool isItemActive(String itemId) {
    final currentInventory = state.valueOrNull ?? [];
    final item = currentInventory.firstWhere(
      (i) => i.itemId == itemId,
      orElse: () => InventoryItem(itemId: '', purchasedAt: DateTime.now()),
    );
    return item.isActive && !item.isExpired;
  }

  /// Get all active power-ups
  List<InventoryItem> getActivePowerUps() {
    final currentInventory = state.valueOrNull ?? [];
    return currentInventory
        .where((item) => item.isActive && !item.isExpired)
        .toList();
  }

  /// Clean up expired items
  Future<void> cleanupExpiredItems() async {
    final currentInventory = state.valueOrNull ?? [];

    bool hasChanges = false;
    final updated = currentInventory.map((item) {
      if (item.isExpired && item.isActive) {
        hasChanges = true;
        return item.copyWith(isActive: false);
      }
      return item;
    }).toList();

    if (hasChanges) {
      await _save(updated);
      state = AsyncValue.data(updated);
    }
  }

  /// Reset inventory (for testing)
  Future<void> reset() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.remove(_key);
    await _load();
  }
}

/// Provider to check if user owns a specific item
final ownsItemProvider = Provider.autoDispose.family<bool, String>((ref, itemId) {
  final inventory = ref.watch(inventoryProvider);
  return inventory.when(
    loading: () => false,
    error: (_, __) => false,
    data: (items) => items.any((i) => i.itemId == itemId),
  );
});

/// Provider for active power-ups
final activePowerUpsProvider = Provider.autoDispose<List<InventoryItem>>((ref) {
  final inventory = ref.watch(inventoryProvider);
  return inventory.when(
    loading: () => [],
    error: (_, __) => [],
    data: (items) => items.where((i) => i.isActive && !i.isExpired).toList(),
  );
});

/// Known XP boost item IDs — matches items defined in [ShopCatalog].
const _xpBoostItemIds = {'xp_boost_1h'};

/// Provider to check if XP boost is active.
///
/// Uses exact ID matching against [_xpBoostItemIds] rather than a substring
/// check to avoid false positives from items that happen to contain 'xp_boost'
/// in their ID (e.g. 'xp_boost_1h_bundle', 'no_xp_boost_ads', etc.).
final xpBoostActiveProvider = Provider.autoDispose<bool>((ref) {
  final activePowerUps = ref.watch(activePowerUpsProvider);
  return activePowerUps.any((item) => _xpBoostItemIds.contains(item.itemId));
});
