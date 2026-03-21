import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wishlist.dart';
import 'user_profile_provider.dart';
import 'package:danio/utils/logger.dart';

/// Keys for SharedPreferences storage
const _wishlistKey = 'wishlist_items';
const _budgetKey = 'shop_budget';
const _shopsKey = 'local_shops';

/// Provider for all wishlist items
final wishlistProvider =
    StateNotifierProvider.autoDispose<WishlistNotifier, List<WishlistItem>>((ref) {
      return WishlistNotifier(ref);
    });

/// Provider for items filtered by category
final fishWishlistProvider = Provider.autoDispose<List<WishlistItem>>((ref) {
  return ref
      .watch(wishlistProvider)
      .where(
        (item) => item.category == WishlistCategory.fish && !item.purchased,
      )
      .toList();
});

final plantWishlistProvider = Provider.autoDispose<List<WishlistItem>>((ref) {
  return ref
      .watch(wishlistProvider)
      .where(
        (item) => item.category == WishlistCategory.plant && !item.purchased,
      )
      .toList();
});

final equipmentWishlistProvider = Provider.autoDispose<List<WishlistItem>>((ref) {
  return ref
      .watch(wishlistProvider)
      .where(
        (item) =>
            item.category == WishlistCategory.equipment && !item.purchased,
      )
      .toList();
});

/// Provider for shop budget
final budgetProvider = StateNotifierProvider.autoDispose<BudgetNotifier, ShopBudget>((ref) {
  return BudgetNotifier(ref);
});

/// Provider for local shops
final localShopsProvider =
    StateNotifierProvider.autoDispose<LocalShopsNotifier, List<LocalShop>>((ref) {
      return LocalShopsNotifier(ref);
    });

/// Wishlist state management
class WishlistNotifier extends StateNotifier<List<WishlistItem>> {
  WishlistNotifier(this._ref) : super([]) {
    _loadFromStorage();
  }

  final Ref _ref;

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await _ref.read(sharedPreferencesProvider.future);
      final jsonString = prefs.getString(_wishlistKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        state = jsonList.map((j) => WishlistItem.fromJson(j)).toList();
      }
    } catch (e, stackTrace) {
      logError('Failed to load wishlist: $e\n$stackTrace', tag: 'WishlistProvider');
      state = [];
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await _ref.read(sharedPreferencesProvider.future);
      final jsonString = json.encode(state.map((e) => e.toJson()).toList());
      await prefs.setString(_wishlistKey, jsonString);
    } catch (e, stackTrace) {
      logError('Failed to save wishlist: $e\n$stackTrace', tag: 'WishlistProvider');
      throw Exception('Failed to save wishlist. Please try again.');
    }
  }

  Future<void> addItem(WishlistItem item) async {
    state = [...state, item];
    try {
      await _saveToStorage();
    } catch (e, stackTrace) {
      logError('Failed to save after adding item: $e\n$stackTrace', tag: 'WishlistProvider');
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
    } catch (e, stackTrace) {
      logError('Failed to save after updating item: $e\n$stackTrace', tag: 'WishlistProvider');
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
    } catch (e, stackTrace) {
      logError('Failed to save after removing item: $e\n$stackTrace', tag: 'WishlistProvider');
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
    } catch (e, stackTrace) {
      logError('Failed to save after marking purchased: $e\n$stackTrace', tag: 'WishlistProvider');
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
  BudgetNotifier(this._ref) : super(ShopBudget()) {
    _loadFromStorage();
  }

  final Ref _ref;

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await _ref.read(sharedPreferencesProvider.future);
      final jsonString = prefs.getString(_budgetKey);
      if (jsonString != null) {
        state = ShopBudget.fromJson(json.decode(jsonString));
        // Check if we need to reset for new month
        _checkMonthReset();
      }
    } catch (e, stackTrace) {
      logError('Failed to load budget: $e\n$stackTrace', tag: 'WishlistProvider');
      state = ShopBudget();
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await _ref.read(sharedPreferencesProvider.future);
      await prefs.setString(_budgetKey, json.encode(state.toJson()));
    } catch (e, stackTrace) {
      logError('Failed to save budget: $e\n$stackTrace', tag: 'WishlistProvider');
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
    } catch (e, stackTrace) {
      logError('Failed to save monthly budget: $e\n$stackTrace', tag: 'WishlistProvider');
      state = oldState;
      rethrow;
    }
  }

  Future<void> addPurchase(double amount) async {
    final oldState = state;
    state = state.copyWith(spentThisMonth: state.spentThisMonth + amount);
    try {
      await _saveToStorage();
    } catch (e, stackTrace) {
      logError('Failed to save after adding purchase: $e\n$stackTrace', tag: 'WishlistProvider');
      state = oldState;
      rethrow;
    }
  }

  Future<void> resetSpending() async {
    final oldState = state;
    state = state.copyWith(spentThisMonth: 0, lastReset: DateTime.now());
    try {
      await _saveToStorage();
    } catch (e, stackTrace) {
      logError('Failed to save after resetting spending: $e\n$stackTrace', tag: 'WishlistProvider');
      state = oldState;
      rethrow;
    }
  }
}

/// Local shops state management
class LocalShopsNotifier extends StateNotifier<List<LocalShop>> {
  LocalShopsNotifier(this._ref) : super([]) {
    _loadFromStorage();
  }

  final Ref _ref;

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await _ref.read(sharedPreferencesProvider.future);
      final jsonString = prefs.getString(_shopsKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        state = jsonList.map((j) => LocalShop.fromJson(j)).toList();
      }
    } catch (e, stackTrace) {
      logError('Failed to load local shops: $e\n$stackTrace', tag: 'WishlistProvider');
      state = [];
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await _ref.read(sharedPreferencesProvider.future);
      final jsonString = json.encode(state.map((e) => e.toJson()).toList());
      await prefs.setString(_shopsKey, jsonString);
    } catch (e, stackTrace) {
      logError('Failed to save local shops: $e\n$stackTrace', tag: 'WishlistProvider');
      throw Exception('Failed to save local shops. Please try again.');
    }
  }

  Future<void> addShop(LocalShop shop) async {
    state = [...state, shop];
    try {
      await _saveToStorage();
    } catch (e, stackTrace) {
      logError('Failed to save after adding shop: $e\n$stackTrace', tag: 'WishlistProvider');
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
    } catch (e, stackTrace) {
      logError('Failed to save after updating shop: $e\n$stackTrace', tag: 'WishlistProvider');
      state = oldState;
      rethrow;
    }
  }

  Future<void> removeShop(String id) async {
    final oldState = state;
    state = state.where((e) => e.id != id).toList();
    try {
      await _saveToStorage();
    } catch (e, stackTrace) {
      logError('Failed to save after removing shop: $e\n$stackTrace', tag: 'WishlistProvider');
      state = oldState;
      rethrow;
    }
  }
}
