// Persistence tests for InventoryNotifier.
//
// Run: flutter test test/providers/inventory_persistence_test.dart

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/models/shop_item.dart';
import 'package:danio/models/tank.dart';
import 'package:danio/models/user_profile.dart';
import 'package:danio/providers/inventory_provider.dart';
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

Future<void> _waitForLoad(ProviderContainer container) async {
  for (var i = 0; i < 20; i++) {
    final profileState = container.read(userProfileProvider);
    final inventoryState = container.read(inventoryProvider);
    if (!profileState.isLoading && !inventoryState.isLoading) return;
    await Future<void>.delayed(Duration.zero);
  }
}

UserProfile _profile({bool hasStreakFreeze = false}) {
  final now = DateTime(2026, 6, 19, 12);
  return UserProfile(
    id: 'profile-1',
    experienceLevel: ExperienceLevel.beginner,
    primaryTankType: TankType.freshwater,
    goals: [UserGoal.keepFishAlive],
    hasStreakFreeze: hasStreakFreeze,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InventoryNotifier persistence', () {
    test(
      'useItem surfaces inventory save failures before applying profile effect',
      () async {
        final originalProfile = _profile();
        final ownedItem = InventoryItem(
          itemId: 'streak_freeze',
          quantity: 1,
          purchasedAt: DateTime(2026, 6, 19, 12),
        );
        final originalInventoryJson = jsonEncode([ownedItem.toJson()]);
        SharedPreferences.setMockInitialValues({
          'user_profile': jsonEncode(originalProfile.toJson()),
          'shop_inventory': originalInventoryJson,
        });
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _ThrowingSetStringPrefs(
                prefs,
                (key, _) => key == 'shop_inventory',
              );
            }),
          ],
        );
        addTearDown(container.dispose);
        final sub = container.listen(inventoryProvider, (_, __) {});
        addTearDown(sub.close);
        await _waitForLoad(container);

        final notifier = container.read(inventoryProvider.notifier);

        await expectLater(
          notifier.useItem('streak_freeze'),
          throwsA(isA<StateError>()),
        );

        final profileState = container.read(userProfileProvider);
        expect(profileState.value?.hasStreakFreeze, isFalse);
        expect(
          prefs.getString('user_profile'),
          jsonEncode(originalProfile.toJson()),
        );
        expect(prefs.getString('shop_inventory'), originalInventoryJson);
      },
    );
  });
}
