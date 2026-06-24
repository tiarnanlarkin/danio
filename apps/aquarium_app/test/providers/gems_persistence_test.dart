// Persistence tests for GemsNotifier.
//
// Run: flutter test test/providers/gems_persistence_test.dart

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/models/gem_transaction.dart';
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

class _FalseSetStringPrefs implements SharedPreferences {
  _FalseSetStringPrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key, Object value) _shouldFail;

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  Future<bool> setString(String key, String value) {
    if (_shouldFail(key, value)) return Future.value(false);
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

    test(
      'grantGems surfaces local save failures before exposing granted gems',
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
          notifier.grantGems(amount: 5, reason: 'Debug grant'),
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

    test(
      'grantGems treats false gems_state writes as local save failures',
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
              return _FalseSetStringPrefs(
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
          notifier.grantGems(amount: 5, reason: 'Debug grant'),
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

    test('addGems rolls back total earned when the save fails', () async {
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
        notifier.addGems(amount: 5, reason: GemEarnReason.lessonComplete),
        throwsA(isA<Exception>()),
      );

      expect(notifier.totalEarned, 10);
      expect(
        prefs.getString('gems_cumulative'),
        jsonEncode({'earned': 10, 'spent': 5}),
      );
    });

    test(
      'addGems restores persisted gem state when cumulative save fails',
      () async {
        final originalState = _gemsState();
        final originalGemsJson = jsonEncode(originalState.toJson());
        SharedPreferences.setMockInitialValues({
          'gems_state': originalGemsJson,
          'gems_cumulative': jsonEncode({'earned': 10, 'spent': 5}),
        });
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _ThrowingSetStringPrefs(
                prefs,
                (key, _) => key == 'gems_cumulative',
              );
            }),
          ],
        );
        addTearDown(container.dispose);
        await _waitForGemsLoad(container);

        final notifier = container.read(gemsProvider.notifier);

        await expectLater(
          notifier.addGems(amount: 5, reason: GemEarnReason.lessonComplete),
          throwsA(isA<Exception>()),
        );

        expect(prefs.getString('gems_state'), originalGemsJson);
        expect(
          prefs.getString('gems_cumulative'),
          jsonEncode({'earned': 10, 'spent': 5}),
        );
      },
    );

    test(
      'addGems restores persisted gem state when cumulative save returns false',
      () async {
        final originalState = _gemsState();
        final originalGemsJson = jsonEncode(originalState.toJson());
        SharedPreferences.setMockInitialValues({
          'gems_state': originalGemsJson,
          'gems_cumulative': jsonEncode({'earned': 10, 'spent': 5}),
        });
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _FalseSetStringPrefs(
                prefs,
                (key, _) => key == 'gems_cumulative',
              );
            }),
          ],
        );
        addTearDown(container.dispose);
        await _waitForGemsLoad(container);

        final notifier = container.read(gemsProvider.notifier);

        await expectLater(
          notifier.addGems(amount: 5, reason: GemEarnReason.lessonComplete),
          throwsA(isA<Exception>()),
        );

        expect(prefs.getString('gems_state'), originalGemsJson);
        expect(
          prefs.getString('gems_cumulative'),
          jsonEncode({'earned': 10, 'spent': 5}),
        );
      },
    );

    test('spendGems rolls back total spent when the save fails', () async {
      final originalState = _gemsState(balance: 20);
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
        notifier.spendGems(
          amount: 5,
          itemId: 'xp_boost_1h',
          itemName: 'XP Boost',
        ),
        throwsA(isA<Exception>()),
      );

      expect(notifier.totalSpent, 5);
      expect(
        prefs.getString('gems_cumulative'),
        jsonEncode({'earned': 10, 'spent': 5}),
      );
    });

    test(
      'spendGems restores persisted gem state when cumulative save fails',
      () async {
        final originalState = _gemsState(balance: 20);
        final originalGemsJson = jsonEncode(originalState.toJson());
        SharedPreferences.setMockInitialValues({
          'gems_state': originalGemsJson,
          'gems_cumulative': jsonEncode({'earned': 10, 'spent': 5}),
        });
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _ThrowingSetStringPrefs(
                prefs,
                (key, _) => key == 'gems_cumulative',
              );
            }),
          ],
        );
        addTearDown(container.dispose);
        await _waitForGemsLoad(container);

        final notifier = container.read(gemsProvider.notifier);

        await expectLater(
          notifier.spendGems(
            amount: 5,
            itemId: 'xp_boost_1h',
            itemName: 'XP Boost',
          ),
          throwsA(isA<Exception>()),
        );

        expect(prefs.getString('gems_state'), originalGemsJson);
        expect(
          prefs.getString('gems_cumulative'),
          jsonEncode({'earned': 10, 'spent': 5}),
        );
      },
    );

    test(
      'refund restores persisted gem state when cumulative save fails',
      () async {
        final originalState = _gemsState();
        final originalGemsJson = jsonEncode(originalState.toJson());
        SharedPreferences.setMockInitialValues({
          'gems_state': originalGemsJson,
          'gems_cumulative': jsonEncode({'earned': 10, 'spent': 5}),
        });
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _ThrowingSetStringPrefs(
                prefs,
                (key, _) => key == 'gems_cumulative',
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

        expect(prefs.getString('gems_state'), originalGemsJson);
        expect(
          prefs.getString('gems_cumulative'),
          jsonEncode({'earned': 10, 'spent': 5}),
        );
      },
    );

    test(
      'grantGems restores persisted gem state when cumulative save fails',
      () async {
        final originalState = _gemsState();
        final originalGemsJson = jsonEncode(originalState.toJson());
        SharedPreferences.setMockInitialValues({
          'gems_state': originalGemsJson,
          'gems_cumulative': jsonEncode({'earned': 10, 'spent': 5}),
        });
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _ThrowingSetStringPrefs(
                prefs,
                (key, _) => key == 'gems_cumulative',
              );
            }),
          ],
        );
        addTearDown(container.dispose);
        await _waitForGemsLoad(container);

        final notifier = container.read(gemsProvider.notifier);

        await expectLater(
          notifier.grantGems(amount: 5, reason: 'Debug grant'),
          throwsA(isA<Exception>()),
        );

        expect(prefs.getString('gems_state'), originalGemsJson);
        expect(
          prefs.getString('gems_cumulative'),
          jsonEncode({'earned': 10, 'spent': 5}),
        );
      },
    );
  });
}
