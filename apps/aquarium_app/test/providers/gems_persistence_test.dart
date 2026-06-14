// Persistence tests for GemsNotifier.
//
// Run: flutter test test/providers/gems_persistence_test.dart

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/providers/gems_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';

class _ThrowingSetStringPrefs implements SharedPreferences {
  _ThrowingSetStringPrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key, Object value) _shouldFail;

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  Future<bool> setString(String key, String value) {
    if (_shouldFail(key, value)) {
      throw StateError('Simulated SharedPreferences write failure for $key');
    }
    return _delegate.setString(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _waitForGemsLoad(ProviderContainer container) async {
  for (var i = 0; i < 20; i++) {
    final gemsState = container.read(gemsProvider);
    if (!gemsState.isLoading) return;
    await Future<void>.delayed(Duration.zero);
  }
}

GemsState _gemsState({int balance = 10}) {
  return GemsState(
    balance: balance,
    transactions: const [],
    lastUpdated: DateTime(2026, 6, 14, 12),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GemsNotifier persistence', () {
    test(
      'refund surfaces local save failures before exposing restored gems',
      () async {
        final originalState = _gemsState();
        SharedPreferences.setMockInitialValues({
          'gems_state': jsonEncode(originalState.toJson()),
          'gems_cumulative': jsonEncode({'earned': 10, 'spent': 5}),
        });
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _ThrowingSetStringPrefs(
                prefs,
                (key, _) => key == 'gems_state',
              );
            }),
          ],
        );
        addTearDown(container.dispose);
        await _waitForGemsLoad(container);

        final notifier = container.read(gemsProvider.notifier);

        await expectLater(
          notifier.refund(
            amount: 5,
            itemId: 'xp_boost_1h',
            itemName: 'XP Boost',
          ),
          throwsA(isA<Exception>()),
        );

        final gemsState = container.read(gemsProvider);
        expect(gemsState.asData?.value.balance, isNot(15));
        expect(
          prefs.getString('gems_state'),
          jsonEncode(originalState.toJson()),
        );
      },
    );
  });
}
