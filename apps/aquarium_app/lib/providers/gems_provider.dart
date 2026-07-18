import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/gem_transaction.dart';
import 'user_profile_provider.dart';
import '../utils/app_constants.dart';
import '../utils/logger.dart';

const _uuid = Uuid();

String achievementRewardIdempotencyKey(String achievementId) {
  return 'achievement_reward:$achievementId';
}

/// Provider for gem economy management
final gemsProvider = StateNotifierProvider<GemsNotifier, AsyncValue<GemsState>>(
  (ref) {
    return GemsNotifier(ref);
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

class _GemsSaveException implements Exception {
  const _GemsSaveException(this.cause, {required this.gemsStateWritten});

  final Object cause;
  final bool gemsStateWritten;

  @override
  String toString() => 'Failed to save gems data: $cause';
}

class GemsPersistenceCompensationException implements Exception {
  const GemsPersistenceCompensationException({
    required this.saveError,
    required this.rollbackError,
  });

  final Object saveError;
  final Object rollbackError;

  @override
  String toString() {
    return 'Gem save failed ($saveError) and gems_state rollback also failed '
        '($rollbackError); gem persistence is uncertain.';
  }
}

class GemsNotifier extends StateNotifier<AsyncValue<GemsState>> {
  final Ref ref;
  GemsNotifier(this.ref) : super(const AsyncValue.loading()) {
    _load();
  }

  static const _key = 'gems_state';
  static const _cumulativeKey = 'gems_cumulative';
  static const _maxTransactions = 200;
  bool _spending = false;
  bool _adding = false;
  int _cumulativeEarned = 0;
  int _cumulativeSpent = 0;
  Set<String> _appliedIdempotencyKeys = {};
  Timer? _saveDebounce;
  Timer? _cumulativeSaveDebounce;

  /// The last state queued for debounced persistence.
  /// Set by [_save] and consumed by [flushPendingWrite].
  GemsState? _pendingGemsState;

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _cumulativeSaveDebounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
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
        _appliedIdempotencyKeys = {
          for (final key
              in cumulative['appliedIdempotencyKeys'] as List<dynamic>? ??
                  const <dynamic>[])
            if (key is String) key,
        };
      } else {
        // Backfill from existing transaction history on first load
        _cumulativeEarned = gemsState.transactions
            .where((t) => t.type == GemTransactionType.earn)
            .fold(0, (sum, t) => sum + t.amount);
        _cumulativeSpent = gemsState.transactions
            .where((t) => t.type == GemTransactionType.spend)
            .fold(0, (sum, t) => sum + t.amount.abs());
        _appliedIdempotencyKeys = {
          for (final transaction in gemsState.transactions)
            if (transaction.idempotencyKey != null) transaction.idempotencyKey!,
        };
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
      logError(
        'GemsProvider: _load failed: $e',
        stackTrace: st,
        tag: 'GemsProvider',
      );
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _saveCumulative(SharedPreferences prefs) async {
    await _setStringOrThrow(
      prefs,
      _cumulativeKey,
      jsonEncode({
        'earned': _cumulativeEarned,
        'spent': _cumulativeSpent,
        'appliedIdempotencyKeys': _appliedIdempotencyKeys.toList()..sort(),
      }),
    );
  }

  Future<void> _setStringOrThrow(
    SharedPreferences prefs,
    String key,
    String value,
  ) async {
    final saved = await prefs.setString(key, value);
    if (!saved) {
      throw StateError('SharedPreferences.setString returned false for $key.');
    }
  }

  Future<void> _removeOrThrow(SharedPreferences prefs, String key) async {
    final removed = await prefs.remove(key);
    if (!removed) {
      throw StateError('SharedPreferences.remove returned false for $key.');
    }
  }

  Future<void> _save(GemsState gemsState) async {
    _pendingGemsState = gemsState;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(kProviderSaveDebounce, () async {
      await _writeToDisk(gemsState);
    });
  }

  Future<void> _saveImmediate(GemsState gemsState) async {
    _saveDebounce?.cancel();
    _saveDebounce = null;
    _pendingGemsState = null;
    await _writeToDisk(gemsState);
  }

  /// Write gems state immediately to disk, bypassing the debounce timer.
  ///
  /// Call this from lifecycle handlers (paused/inactive) to guarantee the
  /// latest balance is persisted before the OS may kill the process.
  Future<void> flushPendingWrite() async {
    final pending = _pendingGemsState;
    if (pending == null) return; // Nothing queued — already clean.
    await _saveImmediate(pending);
    appLog(
      'GemsProvider: lifecycle flush — balance=${pending.balance}',
      tag: 'GemsProvider',
    );
  }

  Future<void> _writeToDisk(GemsState gemsState) async {
    var gemsStateWritten = false;
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      List<GemTransaction> transactions = gemsState.transactions;
      if (transactions.length > _maxTransactions) {
        transactions = transactions.take(_maxTransactions).toList();
        gemsState = gemsState.copyWith(transactions: transactions);
      }
      await _setStringOrThrow(prefs, _key, jsonEncode(gemsState.toJson()));
      gemsStateWritten = true;
      await _saveCumulative(prefs);
      _pendingGemsState = null; // Mark as clean after successful write.
    } catch (e, st) {
      logError(
        'GemsProvider: save failed: $e',
        stackTrace: st,
        tag: 'GemsProvider',
      );
      throw _GemsSaveException(e, gemsStateWritten: gemsStateWritten);
    }
  }

  Future<void> _restorePersistedGemsStateIfNeeded(
    Object error,
    GemsState gemsState,
  ) async {
    if (error is! _GemsSaveException || !error.gemsStateWritten) return;
    await _restorePersistedGemsState(gemsState);
  }

  Future<void> _restorePersistedGemsState(GemsState gemsState) async {
    try {
      await _restorePersistedGemsStateOrThrow(gemsState);
    } catch (e, st) {
      logError(
        'GemsProvider: rollback save failed: $e',
        stackTrace: st,
        tag: 'GemsProvider',
      );
    }
  }

  Future<void> _restorePersistedGemsStateOrThrow(GemsState gemsState) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    List<GemTransaction> transactions = gemsState.transactions;
    if (transactions.length > _maxTransactions) {
      transactions = transactions.take(_maxTransactions).toList();
      gemsState = gemsState.copyWith(transactions: transactions);
    }
    final rollbackJson = jsonEncode(gemsState.toJson());
    if (prefs.getString(_key) == rollbackJson) return;
    await _setStringOrThrow(prefs, _key, rollbackJson);
  }

  /// Get current gem balance
  int get balance => state.value?.balance ?? 0;

  bool isIdempotencyKeyApplied(String idempotencyKey) {
    return _appliedIdempotencyKeys.contains(idempotencyKey);
  }

  /// Add gems (earn)
  /// Returns true if successful, false if a concurrent add is in progress.
  Future<bool> addGems({
    required int amount,
    required GemEarnReason reason,
    String? customReason,
    String? idempotencyKey,
  }) async {
    if (amount <= 0) return false;

    // Re-entrancy guard. This is NOT atomic in a multi-threaded sense, but is
    // safe here because: (1) Dart executes on a single isolate, and (2) Riverpod
    // notifier methods are called from the UI thread (no concurrent awaits
    // between the check and set). The `finally` block always resets `_adding`.
    if (_adding) return false;
    _adding = true;
    final originalCumulativeEarned = _cumulativeEarned;
    final originalAppliedIdempotencyKeys = Set<String>.of(
      _appliedIdempotencyKeys,
    );
    GemsState? originalState;

    try {
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
      originalState = current;
      if (idempotencyKey != null &&
          current.transactions.any(
            (transaction) => transaction.idempotencyKey == idempotencyKey,
          )) {
        final existingTransaction = current.transactions.firstWhere(
          (transaction) => transaction.idempotencyKey == idempotencyKey,
        );
        if (existingTransaction.type != GemTransactionType.earn ||
            existingTransaction.amount != amount) {
          throw StateError(
            'Gem idempotency key collision for $idempotencyKey.',
          );
        }
        if (!_appliedIdempotencyKeys.contains(idempotencyKey)) {
          _cumulativeEarned += existingTransaction.amount;
          _appliedIdempotencyKeys.add(idempotencyKey);
          final prefs = await ref.read(sharedPreferencesProvider.future);
          await _saveCumulative(prefs);
        }
        return true;
      }

      final now = DateTime.now();
      final newBalance = current.balance + amount;

      final transaction = GemTransaction(
        id: _uuid.v4(),
        type: GemTransactionType.earn,
        amount: amount,
        reason: customReason ?? reason.name,
        idempotencyKey: idempotencyKey,
        timestamp: now,
        balanceAfter: newBalance,
      );

      final updatedTransactions = [transaction, ...current.transactions];
      // Cap transaction list to prevent unbounded SharedPreferences growth
      final cappedTransactions = updatedTransactions.length > _maxTransactions
          ? updatedTransactions.take(_maxTransactions).toList()
          : updatedTransactions;

      _cumulativeEarned += amount;
      if (idempotencyKey != null) {
        _appliedIdempotencyKeys.add(idempotencyKey);
      }
      final updatedState = current.copyWith(
        balance: newBalance,
        transactions: cappedTransactions,
        lastUpdated: now,
      );

      await _saveImmediate(updatedState);
      state = AsyncValue.data(updatedState);
      return true;
    } catch (e, st) {
      _cumulativeEarned = originalCumulativeEarned;
      _appliedIdempotencyKeys = originalAppliedIdempotencyKeys;
      final rollbackState = originalState;
      if (rollbackState != null) {
        try {
          if (e is _GemsSaveException && e.gemsStateWritten) {
            await _restorePersistedGemsStateOrThrow(rollbackState);
          }
        } catch (rollbackError, rollbackStack) {
          final uncertainError = GemsPersistenceCompensationException(
            saveError: e,
            rollbackError: rollbackError,
          );
          logError(
            'GemsProvider: rollback save failed: $rollbackError',
            stackTrace: rollbackStack,
            tag: 'GemsProvider',
          );
          state = AsyncValue.error(uncertainError, rollbackStack);
          Error.throwWithStackTrace(uncertainError, st);
        }
      }
      state = AsyncValue.error(e, st);
      rethrow;
    } finally {
      _adding = false;
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

    // Re-entrancy guard — same Dart single-threaded safety rationale as _adding.
    // See [addGems] for full explanation.
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
      final originalCumulativeSpent = _cumulativeSpent;

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
        await _saveImmediate(updatedState);
        state = AsyncValue.data(updatedState);
        return true;
      } catch (e, st) {
        logError(
          'GemsProvider: spend failed, rolling back: $e',
          stackTrace: st,
          tag: 'GemsProvider',
        );
        // Rollback: restore original state
        _cumulativeSpent = originalCumulativeSpent;
        await _restorePersistedGemsStateIfNeeded(e, originalState);
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
    final originalState = current;

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

      await _saveImmediate(updatedState);
      state = AsyncValue.data(updatedState);
    } catch (e, st) {
      await _restorePersistedGemsStateIfNeeded(e, originalState);
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
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await _removeOrThrow(prefs, _key);
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
    final originalState = current;

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

      await _saveImmediate(updatedState);
      state = AsyncValue.data(updatedState);
    } catch (e, st) {
      await _restorePersistedGemsStateIfNeeded(e, originalState);
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
