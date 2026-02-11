import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wishlist.dart';

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
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_wishlistKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      state = jsonList.map((j) => WishlistItem.fromJson(j)).toList();
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_wishlistKey, jsonString);
  }

  Future<void> addItem(WishlistItem item) async {
    state = [...state, item];
    await _saveToStorage();
  }

  Future<void> updateItem(WishlistItem item) async {
    state = state.map((e) => e.id == item.id ? item : e).toList();
    await _saveToStorage();
  }

  Future<void> removeItem(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _saveToStorage();
  }

  Future<void> markPurchased(String id) async {
    state = state.map((e) {
      if (e.id == id) {
        return e.copyWith(purchased: true, purchasedAt: DateTime.now());
      }
      return e;
    }).toList();
    await _saveToStorage();
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
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_budgetKey);
    if (jsonString != null) {
      state = ShopBudget.fromJson(json.decode(jsonString));
      // Check if we need to reset for new month
      _checkMonthReset();
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_budgetKey, json.encode(state.toJson()));
  }

  void _checkMonthReset() {
    final now = DateTime.now();
    if (now.month != state.lastReset.month ||
        now.year != state.lastReset.year) {
      // New month - reset spending
      state = state.copyWith(spentThisMonth: 0, lastReset: now);
      _saveToStorage();
    }
  }

  Future<void> setMonthlyBudget(double amount) async {
    state = state.copyWith(monthlyBudget: amount);
    await _saveToStorage();
  }

  Future<void> addPurchase(double amount) async {
    state = state.copyWith(spentThisMonth: state.spentThisMonth + amount);
    await _saveToStorage();
  }

  Future<void> resetSpending() async {
    state = state.copyWith(spentThisMonth: 0, lastReset: DateTime.now());
    await _saveToStorage();
  }
}

/// Local shops state management
class LocalShopsNotifier extends StateNotifier<List<LocalShop>> {
  LocalShopsNotifier() : super([]) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_shopsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      state = jsonList.map((j) => LocalShop.fromJson(j)).toList();
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_shopsKey, jsonString);
  }

  Future<void> addShop(LocalShop shop) async {
    state = [...state, shop];
    await _saveToStorage();
  }

  Future<void> updateShop(LocalShop shop) async {
    state = state.map((e) => e.id == shop.id ? shop : e).toList();
    await _saveToStorage();
  }

  Future<void> removeShop(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _saveToStorage();
  }
}
