import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wishlist.dart';
import 'package:danio/utils/logger.dart';

/// Keys for SharedPreferences storage
const _wishlistKey = 'wishlist_items';
const _budgetKey = 'shop_budget';
const _shopsKey = 'local_shops';

/// Provider for all wishlist items
final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, List<WishlistItem>>((ref) {
      return WishlistNotifier();
    });

/// Provider for items filtered by category
final fishWishlistProvider = Provider<List<WishlistItem>>((ref) {
  return ref
      .watch(wishlistProvider)
      .where(
        (item) => item.category == WishlistCategory.fish && !item.purchased,
      )
      .toList();
});

final plantWishlistProvider = Provider<List<WishlistItem>>((ref) {
  return ref
      .watch(wishlistProvider)
      .where(
        (item) => item.category == WishlistCategory.plant && !item.purchased,
      )
      .toList();
});

final equipmentWishlistProvider = Provider<List<WishlistItem>>((ref) {
  return ref
      .watch(wishlistProvider)
      .where(
        (item) =>
            item.category == WishlistCategory.equipment && !item.purchased,
      )
      .toList();
});

/// Provider for shop budget
final budgetProvider = StateNotifierProvider<BudgetNotifier, ShopBudget>((ref) {
  return BudgetNotifier();
});

/// Provider for local shops
final localShopsProvider =
    StateNotifierProvider<LocalShopsNotifier, List<LocalShop>>((ref) {
      return LocalShopsNotifier();
    });

/// Wishlist state management
class WishlistNotifier extends StateNotifier<List<WishlistItem>> {
  WishlistNotifier() : super([]) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_wishlistKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        state = jsonList.map((j) => WishlistItem.fromJson(j)).toList();
      }
    } catch (e) {
      // If loading fails (corrupt data, etc.), start with empty wishlist
      // Don't crash the app - user can rebuild their wishlist
      state = [];
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(state.map((e) => e.toJson()).toList());
      await prefs.setString(_wishlistKey, jsonString);
    } catch (e) {
      // Save failed - throw so callers can handle/notify user
      throw Exception('Failed to save wishlist. Please try again.');
    }
  }

  Future<void> addItem(WishlistItem item) async {
    state = [...state, item];
    try {
      await _saveToStorage();
    } catch (e) {
      // Revert state change on save failure
      state = state.where((i) => i.id != item.id).toList();
      rethrow;
    }
  }

  Future<void> updateItem(WishlistItem item) async {
    final oldState = state;
    state = state.map((e) => e.id == item.id ? item : e).toList();
    try {
      await _saveToStorage();
    } catch (e) {
      // Revert on failure
      state = oldState;
      rethrow;
    }
  }

  Future<void> removeItem(String id) async {
    final oldState = state;
    state = state.where((e) => e.id != id).toList();
    try {
      await _saveToStorage();
    } catch (e) {
      // Revert on failure
      state = oldState;
      rethrow;
    }
  }

  Future<void> markPurchased(String id) async {
    final oldState = state;
    state = state.map((e) {
      if (e.id == id) {
        return e.copyWith(purchased: true, purchasedAt: DateTime.now());
      }
      return e;
    }).toList();
    try {
      await _saveToStorage();
    } catch (e) {
      // Revert on failure
      state = oldState;
      rethrow;
    }
  }

  List<WishlistItem> getByCategory(
    WishlistCategory category, {
    bool includePurchased = false,
  }) {
    return state.where((item) {
      if (item.category != category) return false;
      if (!includePurchased && item.purchased) return false;
      return true;
    }).toList();
  }
}

/// Budget state management
class BudgetNotifier extends StateNotifier<ShopBudget> {
  BudgetNotifier() : super(ShopBudget()) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_budgetKey);
      if (jsonString != null) {
        state = ShopBudget.fromJson(json.decode(jsonString));
        // Check if we need to reset for new month
        _checkMonthReset();
      }
    } catch (e) {
      // If loading fails, start with default budget
      // Don't crash the app - user can set up budget again
      state = ShopBudget();
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_budgetKey, json.encode(state.toJson()));
    } catch (e) {
      throw Exception('Failed to save budget. Please try again.');
    }
  }

  void _checkMonthReset() {
    final now = DateTime.now();
    if (now.month != state.lastReset.month ||
        now.year != state.lastReset.year) {
      // New month - reset spending
      state = state.copyWith(spentThisMonth: 0, lastReset: now);
      _saveToStorage().catchError((e) {
        logError(e, tag: 'WishlistProvider');
      });
    }
  }

  Future<void> setMonthlyBudget(double amount) async {
    final oldState = state;
    state = state.copyWith(monthlyBudget: amount);
    try {
      await _saveToStorage();
    } catch (e) {
      state = oldState;
      rethrow;
    }
  }

  Future<void> addPurchase(double amount) async {
    final oldState = state;
    state = state.copyWith(spentThisMonth: state.spentThisMonth + amount);
    try {
      await _saveToStorage();
    } catch (e) {
      state = oldState;
      rethrow;
    }
  }

  Future<void> resetSpending() async {
    final oldState = state;
    state = state.copyWith(spentThisMonth: 0, lastReset: DateTime.now());
    try {
      await _saveToStorage();
    } catch (e) {
      state = oldState;
      rethrow;
    }
  }
}

/// Local shops state management
class LocalShopsNotifier extends StateNotifier<List<LocalShop>> {
  LocalShopsNotifier() : super([]) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_shopsKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        state = jsonList.map((j) => LocalShop.fromJson(j)).toList();
      }
    } catch (e) {
      // If loading fails, start with empty shops list
      // Don't crash the app - user can add shops again
      state = [];
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(state.map((e) => e.toJson()).toList());
      await prefs.setString(_shopsKey, jsonString);
    } catch (e) {
      throw Exception('Failed to save local shops. Please try again.');
    }
  }

  Future<void> addShop(LocalShop shop) async {
    state = [...state, shop];
    try {
      await _saveToStorage();
    } catch (e) {
      // Revert on failure
      state = state.where((s) => s.id != shop.id).toList();
      rethrow;
    }
  }

  Future<void> updateShop(LocalShop shop) async {
    final oldState = state;
    state = state.map((e) => e.id == shop.id ? shop : e).toList();
    try {
      await _saveToStorage();
    } catch (e) {
      state = oldState;
      rethrow;
    }
  }

  Future<void> removeShop(String id) async {
    final oldState = state;
    state = state.where((e) => e.id != id).toList();
    try {
      await _saveToStorage();
    } catch (e) {
      state = oldState;
      rethrow;
    }
  }
}
