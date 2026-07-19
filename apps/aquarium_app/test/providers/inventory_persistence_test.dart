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
import 'package:danio/providers/gems_provider.dart';
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

class _FalseSetStringPrefs implements SharedPreferences {
  _FalseSetStringPrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key, Object value) _shouldFail;

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  Future<bool> setString(String key, String value) {
    if (_shouldFail(key, value)) {
      return Future<bool>.value(false);
    }
    return _delegate.setString(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FalseRemovePrefs implements SharedPreferences {
  _FalseRemovePrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key) _shouldFail;

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  Future<bool> setString(String key, String value) =>
      _delegate.setString(key, value);

  @override
  Future<bool> remove(String key) {
    if (_shouldFail(key)) {
      return Future<bool>.value(false);
    }
    return _delegate.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UncertainInventoryUsePrefs implements SharedPreferences {
  _UncertainInventoryUsePrefs(
    this._delegate, {
    required this.effectError,
    required this.effectStackTrace,
    required this.restoreError,
    required this.restoreStackTrace,
  });

  final SharedPreferences _delegate;
  final Object effectError;
  final StackTrace effectStackTrace;
  final Object restoreError;
  final StackTrace restoreStackTrace;

  int inventoryReads = 0;
  int profileReads = 0;
  int inventoryWrites = 0;

  @override
  String? getString(String key) {
    if (key == 'shop_inventory') inventoryReads += 1;
    if (key == 'user_profile') profileReads += 1;
    return _delegate.getString(key);
  }

  @override
  Future<bool> setString(String key, String value) {
    if (key == 'shop_inventory') {
      inventoryWrites += 1;
      if (inventoryWrites > 1) {
        return Error.throwWithStackTrace(restoreError, restoreStackTrace);
      }
    }
    if (key == 'user_profile') {
      return Error.throwWithStackTrace(effectError, effectStackTrace);
    }
    return _delegate.setString(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _waitForLoad(ProviderContainer container) async {
  for (var i = 0; i < 20; i++) {
    final gemsState = container.read(gemsProvider);
    final profileState = container.read(userProfileProvider);
    final inventoryState = container.read(inventoryProvider);
    if (!gemsState.isLoading &&
        !profileState.isLoading &&
        !inventoryState.isLoading) {
      return;
    }
    await Future<void>.delayed(Duration.zero);
  }
}

Future<void> _waitForProfileLoad(ProviderContainer container) async {
  for (var i = 0; i < 20; i++) {
    final profileState = container.read(userProfileProvider);
    if (!profileState.isLoading) return;
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

GemsState _gemsState({int balance = 100}) {
  return GemsState(
    balance: balance,
    transactions: const [],
    lastUpdated: DateTime(2026, 6, 19, 12),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InventoryNotifier persistence', () {
    test(
      'legacy inventory migration keeps profile inventory when shop save returns false',
      () async {
        final legacyItem = InventoryItem(
          itemId: 'streak_freeze',
          quantity: 1,
          purchasedAt: DateTime(2026, 6, 19, 12),
        );
        final legacyProfile = _profile().copyWith(inventory: [legacyItem]);
        final legacyProfileJson = jsonEncode(legacyProfile.toJson());
        SharedPreferences.setMockInitialValues({
          'user_profile': legacyProfileJson,
        });
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _FalseSetStringPrefs(
                prefs,
                (key, _) => key == 'shop_inventory',
              );
            }),
          ],
        );
        addTearDown(container.dispose);
        final profileSub = container.listen(userProfileProvider, (_, __) {});
        addTearDown(profileSub.close);
        await _waitForProfileLoad(container);
        final inventorySub = container.listen(inventoryProvider, (_, __) {});
        addTearDown(inventorySub.close);
        await _waitForLoad(container);

        final migratedItems = container.read(inventoryProvider).valueOrNull;
        expect(migratedItems, hasLength(1));
        expect(migratedItems?.single.itemId, legacyItem.itemId);
        expect(migratedItems?.single.quantity, legacyItem.quantity);
        expect(prefs.getString('shop_inventory'), isNull);
        expect(prefs.getString('user_profile'), legacyProfileJson);
      },
    );

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

    test(
      'useItem treats false inventory saves as failures before applying profile effect',
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
              return _FalseSetStringPrefs(
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

    test(
      'useItem preserves effect and rollback failures when inventory restore is uncertain',
      () async {
        final originalProfile = _profile();
        final ownedItem = InventoryItem(
          itemId: 'streak_freeze',
          quantity: 1,
          purchasedAt: DateTime(2026, 6, 19, 12),
        );
        final originalInventoryJson = jsonEncode([ownedItem.toJson()]);
        final effectError = StateError('profile effect failed');
        final effectStackTrace = StackTrace.fromString('profile effect stack');
        final restoreError = StateError('inventory restore failed');
        final restoreStackTrace = StackTrace.fromString(
          'inventory restore stack',
        );
        SharedPreferences.setMockInitialValues({
          'user_profile': jsonEncode(originalProfile.toJson()),
          'shop_inventory': originalInventoryJson,
        });
        final prefs = await SharedPreferences.getInstance();
        final uncertainPrefs = _UncertainInventoryUsePrefs(
          prefs,
          effectError: effectError,
          effectStackTrace: effectStackTrace,
          restoreError: restoreError,
          restoreStackTrace: restoreStackTrace,
        );
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith(
              (ref) async => uncertainPrefs,
            ),
          ],
        );
        addTearDown(container.dispose);
        final inventorySub = container.listen(inventoryProvider, (_, __) {});
        addTearDown(inventorySub.close);
        final profileSub = container.listen(userProfileProvider, (_, __) {});
        addTearDown(profileSub.close);
        await _waitForLoad(container);

        Object? useFailure;
        StackTrace? useFailureStackTrace;
        try {
          await container
              .read(inventoryProvider.notifier)
              .useItem('streak_freeze');
        } catch (error, stackTrace) {
          useFailure = error;
          useFailureStackTrace = stackTrace;
        }

        expect(useFailure, isNotNull);
        expect(
          useFailure.runtimeType.toString(),
          'InventoryUseCompensationException',
          reason: '$useFailure\n$useFailureStackTrace',
        );
        expect(useFailure, isA<InventoryUseCompensationException>());
        final uncertainty = useFailure! as InventoryUseCompensationException;
        expect(uncertainty.effectError, same(effectError));
        expect(
          uncertainty.effectStackTrace.toString(),
          effectStackTrace.toString(),
        );
        expect(uncertainty.restoreFailures, hasLength(1));
        expect(uncertainty.restoreFailures.single.error, same(restoreError));
        expect(
          uncertainty.restoreFailures.single.stackTrace.toString(),
          restoreStackTrace.toString(),
        );
        expect(uncertainty.itemId, 'streak_freeze');
        expect(uncertainty.itemName, 'Streak Freeze');
        expect(uncertainty.itemType, ShopItemType.streakFreeze);
        expect(
          useFailureStackTrace.toString(),
          effectStackTrace.toString(),
        );

        await _waitForLoad(container);
        expect(uncertainPrefs.inventoryReads, greaterThanOrEqualTo(2));
        expect(uncertainPrefs.profileReads, greaterThanOrEqualTo(2));
        expect(container.read(inventoryProvider).valueOrNull, isEmpty);
        expect(
          container.read(userProfileProvider).valueOrNull?.hasStreakFreeze,
          isFalse,
        );
        expect(
          jsonDecode(prefs.getString('shop_inventory')!) as List<dynamic>,
          isEmpty,
        );
        expect(
          jsonDecode(prefs.getString('user_profile')!)['hasStreakFreeze'],
          isFalse,
        );
        expect(
          await container
              .read(inventoryProvider.notifier)
              .useItem('streak_freeze'),
          isFalse,
        );
      },
    );

    test(
      'useItem restores inventory after profile effect failure when compensation succeeds',
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
        final throwingPrefs = _ThrowingSetStringPrefs(
          prefs,
          (key, _) => key == 'user_profile',
        );
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith(
              (ref) async => throwingPrefs,
            ),
          ],
        );
        addTearDown(container.dispose);
        final inventorySub = container.listen(inventoryProvider, (_, __) {});
        addTearDown(inventorySub.close);
        final profileSub = container.listen(userProfileProvider, (_, __) {});
        addTearDown(profileSub.close);
        await _waitForLoad(container);

        await expectLater(
          container.read(inventoryProvider.notifier).useItem('streak_freeze'),
          throwsA(isA<StateError>()),
        );

        final restoredInventory = container.read(inventoryProvider).valueOrNull;
        expect(restoredInventory, hasLength(1));
        expect(restoredInventory?.single.itemId, ownedItem.itemId);
        expect(restoredInventory?.single.quantity, ownedItem.quantity);
        expect(restoredInventory?.single.purchasedAt, ownedItem.purchasedAt);
        expect(prefs.getString('shop_inventory'), originalInventoryJson);
        expect(
          container.read(userProfileProvider).valueOrNull?.hasStreakFreeze,
          isFalse,
        );
      },
    );

    test(
      'purchaseItem refunds gems when inventory save returns false',
      () async {
        final originalGems = _gemsState();
        const badge = ShopItem(
          id: 'badge_early_bird',
          name: 'Early Bird Badge',
          description: 'Permanent badge',
          emoji: 'AM',
          category: ShopItemCategory.cosmetics,
          type: ShopItemType.profileBadge,
          gemCost: 10,
          isConsumable: false,
          orderIndex: 20,
        );
        SharedPreferences.setMockInitialValues({
          'gems_state': jsonEncode(originalGems.toJson()),
          'gems_cumulative': jsonEncode({'earned': 100, 'spent': 0}),
        });
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _FalseSetStringPrefs(
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
          notifier.purchaseItem(badge),
          throwsA(isA<StateError>()),
        );

        expect(container.read(inventoryProvider).valueOrNull, isEmpty);
        expect(prefs.getString('shop_inventory'), isNull);
        final gemsState = container.read(gemsProvider).asData?.value;
        expect(gemsState?.balance, originalGems.balance);
        final persistedGems = GemsState.fromJson(
          jsonDecode(prefs.getString('gems_state')!) as Map<String, dynamic>,
        );
        expect(persistedGems.balance, originalGems.balance);
      },
    );

    test(
      'purchaseItem preserves inventory and refund failures for diagnosis',
      () async {
        final originalGems = _gemsState();
        const badge = ShopItem(
          id: 'badge_early_bird',
          name: 'Early Bird Badge',
          description: 'Permanent badge',
          emoji: 'AM',
          category: ShopItemCategory.cosmetics,
          type: ShopItemType.profileBadge,
          gemCost: 10,
          isConsumable: false,
          orderIndex: 20,
        );
        SharedPreferences.setMockInitialValues({
          'gems_state': jsonEncode(originalGems.toJson()),
          'gems_cumulative': jsonEncode({'earned': 0, 'spent': 0}),
        });
        final prefs = await SharedPreferences.getInstance();
        var gemsStateWrites = 0;
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _FalseSetStringPrefs(prefs, (key, _) {
                if (key == 'shop_inventory') return true;
                if (key == 'gems_state') {
                  gemsStateWrites += 1;
                  return gemsStateWrites == 2;
                }
                return false;
              });
            }),
          ],
        );
        addTearDown(container.dispose);
        final sub = container.listen(inventoryProvider, (_, __) {});
        addTearDown(sub.close);
        await _waitForLoad(container);

        Object? purchaseFailure;
        try {
          await container.read(inventoryProvider.notifier).purchaseItem(badge);
        } catch (error) {
          purchaseFailure = error;
        }

        expect(purchaseFailure, isNotNull);
        expect(purchaseFailure.toString(), contains('shop_inventory'));
        expect(purchaseFailure.toString(), contains('gems_state'));
        expect(container.read(inventoryProvider).valueOrNull, isEmpty);
        expect(prefs.getString('shop_inventory'), isNull);
        final persistedGems = GemsState.fromJson(
          jsonDecode(prefs.getString('gems_state')!) as Map<String, dynamic>,
        );
        expect(persistedGems.balance, 90);
      },
    );

    test(
      'purchaseItem rejects owned permanent items before spending gems',
      () async {
        final ownedBadge = InventoryItem(
          itemId: 'badge_early_bird',
          quantity: 1,
          purchasedAt: DateTime(2026, 6, 19, 12),
        );
        const duplicateBadge = ShopItem(
          id: 'badge_early_bird',
          name: 'Early Bird Badge',
          description: 'Permanent badge',
          emoji: 'AM',
          category: ShopItemCategory.cosmetics,
          type: ShopItemType.profileBadge,
          gemCost: 10,
          isConsumable: false,
          orderIndex: 20,
        );
        final originalGems = _gemsState();
        final originalInventoryJson = jsonEncode([ownedBadge.toJson()]);
        SharedPreferences.setMockInitialValues({
          'gems_state': jsonEncode(originalGems.toJson()),
          'gems_cumulative': jsonEncode({'earned': 100, 'spent': 0}),
          'shop_inventory': originalInventoryJson,
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
        final sub = container.listen(inventoryProvider, (_, __) {});
        addTearDown(sub.close);
        await _waitForLoad(container);

        final notifier = container.read(inventoryProvider.notifier);

        final purchased = await notifier.purchaseItem(duplicateBadge);

        expect(purchased, isFalse);
        final gemsState = container.read(gemsProvider).asData?.value;
        expect(gemsState?.balance, originalGems.balance);
        expect(
          prefs.getString('gems_state'),
          jsonEncode(originalGems.toJson()),
        );
        expect(prefs.getString('shop_inventory'), originalInventoryJson);
      },
    );

    test(
      'reset surfaces failed local removals before reporting reset success',
      () async {
        final ownedBadge = InventoryItem(
          itemId: 'badge_early_bird',
          quantity: 1,
          purchasedAt: DateTime(2026, 6, 19, 12),
        );
        final originalInventoryJson = jsonEncode([ownedBadge.toJson()]);
        SharedPreferences.setMockInitialValues({
          'shop_inventory': originalInventoryJson,
        });
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _FalseRemovePrefs(
                prefs,
                (key) => key == 'shop_inventory',
              );
            }),
          ],
        );
        addTearDown(container.dispose);
        final sub = container.listen(inventoryProvider, (_, __) {});
        addTearDown(sub.close);
        await _waitForLoad(container);

        final notifier = container.read(inventoryProvider.notifier);

        await expectLater(notifier.reset(), throwsA(isA<StateError>()));

        final inventory = container.read(inventoryProvider).valueOrNull;
        expect(inventory, hasLength(1));
        expect(inventory?.single.itemId, ownedBadge.itemId);
        expect(prefs.getString('shop_inventory'), originalInventoryJson);
      },
    );
  });
}
