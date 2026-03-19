import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/gem_transaction.dart';
import '../models/gem_economy.dart';

const _uuid = Uuid();

/// Provider for gem economy management
final gemsProvider = StateNotifierProvider<GemsNotifier, AsyncValue<GemsState>>(
  (ref) {
    return GemsNotifier();
  },
);

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
  static const _cumulativeKey = 'gems_cumulative';
  static const _maxTransactions = 200;
  bool _spending = false;
  int _cumulativeEarned = 0;
  int _cumulativeSpent = 0;

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

      // Restore cumulative counters
      final cumulativeJson = prefs.getString(_cumulativeKey);
      if (cumulativeJson != null) {
        final cumulative = jsonDecode(cumulativeJson) as Map<String, dynamic>;
        _cumulativeEarned = cumulative['earned'] as int? ?? 0;
        _cumulativeSpent = cumulative['spent'] as int? ?? 0;
      } else {
        // Backfill from existing transaction history on first load
        _cumulativeEarned = gemsState.transactions
            .where((t) => t.type == GemTransactionType.earn)
            .fold(0, (sum, t) => sum + t.amount);
        _cumulativeSpent = gemsState.transactions
            .where((t) => t.type == GemTransactionType.spend)
            .fold(0, (sum, t) => sum + t.amount.abs());
        await _saveCumulative(prefs);
      }

      // Trim oldest transactions if list exceeds cap
      if (gemsState.transactions.length > _maxTransactions) {
        gemsState = gemsState.copyWith(
          transactions: gemsState.transactions.take(_maxTransactions).toList(),
        );
      }

      state = AsyncValue.data(gemsState);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _saveCumulative(SharedPreferences prefs) async {
    await prefs.setString(
      _cumulativeKey,
      jsonEncode({'earned': _cumulativeEarned, 'spent': _cumulativeSpent}),
    );
  }

  Future<void> _save(GemsState gemsState) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Trim oldest transactions before persisting
      List<GemTransaction> transactions = gemsState.transactions;
      if (transactions.length > _maxTransactions) {
        transactions = transactions.take(_maxTransactions).toList();
        gemsState = gemsState.copyWith(transactions: transactions);
      }
      await prefs.setString(_key, jsonEncode(gemsState.toJson()));
      await _saveCumulative(prefs);
    } catch (e) {
      // Rethrow to let callers handle the error
      throw Exception('Failed to save gems data: $e');
    }
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

    // Auto-initialize if state not loaded yet
    var current = state.value;
    if (current == null) {
      current = GemsState(
        balance: 0,
        transactions: [],
        lastUpdated: DateTime.now(),
      );
      state = AsyncValue.data(current);
    }

    try {
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
      // Cap transaction list to prevent unbounded SharedPreferences growth
      final cappedTransactions = updatedTransactions.length > _maxTransactions
          ? updatedTransactions.take(_maxTransactions).toList()
          : updatedTransactions;

      _cumulativeEarned += amount;
      final updatedState = current.copyWith(
        balance: newBalance,
        transactions: cappedTransactions,
        lastUpdated: now,
      );

      await _save(updatedState);
      state = AsyncValue.data(updatedState);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Spend gems (shop purchase)
  /// Returns true if successful, false if insufficient funds
  /// Throws exception if save fails (atomic transaction - will rollback)
  Future<bool> spendGems({
    required int amount,
    required String itemId,
    String? itemName,
  }) async {
    if (amount <= 0) return false;
    if (_spending) return false;
    _spending = true;

    try {
      final current = state.value;
      if (current == null) {
        throw Exception('Cannot spend gems: Gems state not loaded');
      }

      // Check if user has enough gems
      if (current.balance < amount) {
        return false;
      }

      // Store original state for rollback
      final originalState = current;

      try {
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
        final cappedTransactions = updatedTransactions.length > _maxTransactions
            ? updatedTransactions.take(_maxTransactions).toList()
            : updatedTransactions;

        _cumulativeSpent += amount;

        final updatedState = current.copyWith(
          balance: newBalance,
          transactions: cappedTransactions,
          lastUpdated: now,
        );

        // Atomic: save first, then update state
        // If save fails, state won't be updated (rollback)
        await _save(updatedState);
        state = AsyncValue.data(updatedState);
        return true;
      } catch (e) {
        // Rollback: restore original state
        state = AsyncValue.data(originalState);
        rethrow;
      }
    } finally {
      _spending = false;
    }
  }

  /// Refund a purchase
  Future<void> refund({
    required int amount,
    required String itemId,
    String? itemName,
  }) async {
    if (amount <= 0) return;

    final current = state.value;
    if (current == null) {
      throw Exception('Cannot refund gems: Gems state not loaded');
    }

    try {
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
      final cappedTransactions = updatedTransactions.length > _maxTransactions
          ? updatedTransactions.take(_maxTransactions).toList()
          : updatedTransactions;

      final updatedState = current.copyWith(
        balance: newBalance,
        transactions: cappedTransactions,
        lastUpdated: now,
      );

      await _save(updatedState);
      state = AsyncValue.data(updatedState);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Get recent transactions
  List<GemTransaction> getRecentTransactions({int count = 20}) {
    final current = state.value;
    if (current == null) return [];
    return current.transactions.take(count).toList();
  }

  /// Get total gems earned (all time) — uses running counter for O(1) lookup
  int get totalEarned => _cumulativeEarned;

  /// Get total gems spent (all time) — uses running counter for O(1) lookup
  int get totalSpent => _cumulativeSpent;

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
    if (current == null) {
      throw Exception('Cannot grant gems: Gems state not loaded');
    }

    try {
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
      final cappedTransactions = updatedTransactions.length > _maxTransactions
          ? updatedTransactions.take(_maxTransactions).toList()
          : updatedTransactions;

      final updatedState = current.copyWith(
        balance: newBalance,
        transactions: cappedTransactions,
        lastUpdated: now,
      );

      await _save(updatedState);
      state = AsyncValue.data(updatedState);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
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
