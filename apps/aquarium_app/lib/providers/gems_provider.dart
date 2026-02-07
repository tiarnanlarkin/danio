import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/gem_transaction.dart';
import '../models/gem_economy.dart';

const _uuid = Uuid();

/// Provider for gem economy management
final gemsProvider = StateNotifierProvider<GemsNotifier, AsyncValue<GemsState>>((ref) {
  return GemsNotifier();
});

/// Gems state combining balance and transaction history
class GemsState {
  final int balance;
  final List<GemTransaction> transactions;
  final DateTime lastUpdated;

  const GemsState({
    required this.balance,
    required this.transactions,
    required this.lastUpdated,
  });

  GemsState copyWith({
    int? balance,
    List<GemTransaction>? transactions,
    DateTime? lastUpdated,
  }) {
    return GemsState(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() => {
        'balance': balance,
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory GemsState.fromJson(Map<String, dynamic> json) {
    return GemsState(
      balance: json['balance'] as int,
      transactions: (json['transactions'] as List<dynamic>)
          .map((e) => GemTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}

class GemsNotifier extends StateNotifier<AsyncValue<GemsState>> {
  GemsNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  static const _key = 'gems_state';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_key);

      GemsState gemsState;
      if (json != null) {
        gemsState = GemsState.fromJson(jsonDecode(json));
      } else {
        // Initialize with 0 gems and empty history
        gemsState = GemsState(
          balance: 0,
          transactions: [],
          lastUpdated: DateTime.now(),
        );
        await _save(gemsState);
      }

      state = AsyncValue.data(gemsState);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _save(GemsState gemsState) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(gemsState.toJson()));
  }

  /// Get current gem balance
  int get balance => state.value?.balance ?? 0;

  /// Add gems (earn)
  Future<void> addGems({
    required int amount,
    required GemEarnReason reason,
    String? customReason,
  }) async {
    if (amount <= 0) return;

    final current = state.value;
    if (current == null) return;

    final now = DateTime.now();
    final newBalance = current.balance + amount;

    final transaction = GemTransaction(
      id: _uuid.v4(),
      type: GemTransactionType.earn,
      amount: amount,
      reason: customReason ?? reason.name,
      timestamp: now,
      balanceAfter: newBalance,
    );

    final updatedTransactions = [transaction, ...current.transactions];
    // Keep only last 100 transactions
    final trimmedTransactions = updatedTransactions.take(100).toList();

    final updatedState = current.copyWith(
      balance: newBalance,
      transactions: trimmedTransactions,
      lastUpdated: now,
    );

    await _save(updatedState);
    state = AsyncValue.data(updatedState);
  }

  /// Spend gems (shop purchase)
  Future<bool> spendGems({
    required int amount,
    required String itemId,
    String? itemName,
  }) async {
    if (amount <= 0) return false;

    final current = state.value;
    if (current == null) return false;

    // Check if user has enough gems
    if (current.balance < amount) {
      return false;
    }

    final now = DateTime.now();
    final newBalance = current.balance - amount;

    final transaction = GemTransaction(
      id: _uuid.v4(),
      type: GemTransactionType.spend,
      amount: -amount, // Negative for spending
      reason: itemName ?? 'Shop purchase',
      itemId: itemId,
      timestamp: now,
      balanceAfter: newBalance,
    );

    final updatedTransactions = [transaction, ...current.transactions];
    final trimmedTransactions = updatedTransactions.take(100).toList();

    final updatedState = current.copyWith(
      balance: newBalance,
      transactions: trimmedTransactions,
      lastUpdated: now,
    );

    await _save(updatedState);
    state = AsyncValue.data(updatedState);
    return true;
  }

  /// Refund a purchase
  Future<void> refund({
    required int amount,
    required String itemId,
    String? itemName,
  }) async {
    if (amount <= 0) return;

    final current = state.value;
    if (current == null) return;

    final now = DateTime.now();
    final newBalance = current.balance + amount;

    final transaction = GemTransaction(
      id: _uuid.v4(),
      type: GemTransactionType.refund,
      amount: amount,
      reason: 'Refund: ${itemName ?? itemId}',
      itemId: itemId,
      timestamp: now,
      balanceAfter: newBalance,
    );

    final updatedTransactions = [transaction, ...current.transactions];
    final trimmedTransactions = updatedTransactions.take(100).toList();

    final updatedState = current.copyWith(
      balance: newBalance,
      transactions: trimmedTransactions,
      lastUpdated: now,
    );

    await _save(updatedState);
    state = AsyncValue.data(updatedState);
  }

  /// Get recent transactions
  List<GemTransaction> getRecentTransactions({int count = 20}) {
    final current = state.value;
    if (current == null) return [];
    return current.transactions.take(count).toList();
  }

  /// Get total gems earned (all time)
  int get totalEarned {
    final current = state.value;
    if (current == null) return 0;
    return current.transactions
        .where((t) => t.type == GemTransactionType.earn)
        .fold(0, (sum, t) => sum + t.amount);
  }

  /// Get total gems spent (all time)
  int get totalSpent {
    final current = state.value;
    if (current == null) return 0;
    return current.transactions
        .where((t) => t.type == GemTransactionType.spend)
        .fold(0, (sum, t) => sum + t.amount.abs());
  }

  /// Reset gems (for testing/debugging)
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await _load();
  }

  /// Grant promotional gems (admin function)
  Future<void> grantGems({
    required int amount,
    String reason = 'Promotional bonus',
  }) async {
    if (amount <= 0) return;

    final current = state.value;
    if (current == null) return;

    final now = DateTime.now();
    final newBalance = current.balance + amount;

    final transaction = GemTransaction(
      id: _uuid.v4(),
      type: GemTransactionType.grant,
      amount: amount,
      reason: reason,
      timestamp: now,
      balanceAfter: newBalance,
    );

    final updatedTransactions = [transaction, ...current.transactions];
    final trimmedTransactions = updatedTransactions.take(100).toList();

    final updatedState = current.copyWith(
      balance: newBalance,
      transactions: trimmedTransactions,
      lastUpdated: now,
    );

    await _save(updatedState);
    state = AsyncValue.data(updatedState);
  }
}

/// Convenience provider for just the balance
final gemBalanceProvider = Provider<int>((ref) {
  final gemsState = ref.watch(gemsProvider);
  return gemsState.when(
    loading: () => 0,
    error: (_, __) => 0,
    data: (state) => state.balance,
  );
});

/// Provider for recent transaction history
final recentGemTransactionsProvider = Provider<List<GemTransaction>>((ref) {
  final gemsState = ref.watch(gemsProvider);
  return gemsState.when(
    loading: () => [],
    error: (_, __) => [],
    data: (state) => state.transactions.take(20).toList(),
  );
});
