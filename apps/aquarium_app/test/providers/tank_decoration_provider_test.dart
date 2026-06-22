import 'dart:async';

import 'package:danio/models/tank_decoration.dart';
import 'package:danio/providers/tank_decoration_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _DelayedSetStringPrefs implements SharedPreferences {
  _DelayedSetStringPrefs({
    required SharedPreferences delegate,
    required this.delayedKey,
    required this.gate,
  }) : _delegate = delegate;

  final SharedPreferences _delegate;
  final String delayedKey;
  final Completer<bool> gate;

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  Future<bool> setString(String key, String value) {
    if (key == delayedKey) {
      return gate.future.then((saved) async {
        if (!saved) return false;
        return _delegate.setString(key, value);
      });
    }
    return _delegate.setString(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _waitForDecorationProviders(ProviderContainer container) async {
  for (var i = 0; i < 20; i += 1) {
    container.read(unlockedTankDecorationsProvider);
    container.read(equippedTankDecorationProvider);
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Tank decoration providers', () {
    test('starter decoration is seeded into local earned inventory', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await _waitForDecorationProviders(container);

      expect(
        container.read(unlockedTankDecorationsProvider),
        contains(TankDecorationType.riverStones),
      );
    });

    test('equipDecoration waits for save before exposing state', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final saveGate = Completer<bool>();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async {
            return _DelayedSetStringPrefs(
              delegate: prefs,
              delayedKey: kEquippedTankDecorationKey,
              gate: saveGate,
            );
          }),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        equippedTankDecorationProvider,
        (_, __) {},
      );
      addTearDown(subscription.close);
      await _waitForDecorationProviders(container);

      final equip = container
          .read(equippedTankDecorationProvider.notifier)
          .equipDecoration(TankDecorationType.riverStones);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(equippedTankDecorationProvider), isNull);

      saveGate.complete(true);
      expect(await equip, isTrue);

      expect(
        container.read(equippedTankDecorationProvider),
        TankDecorationType.riverStones,
      );
      expect(
        prefs.getString(kEquippedTankDecorationKey),
        TankDecorationType.riverStones.name,
      );
    });

    test('equipDecoration keeps state unchanged when save fails', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final saveGate = Completer<bool>();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async {
            return _DelayedSetStringPrefs(
              delegate: prefs,
              delayedKey: kEquippedTankDecorationKey,
              gate: saveGate,
            );
          }),
        ],
      );
      addTearDown(container.dispose);
      await _waitForDecorationProviders(container);

      final equip = container
          .read(equippedTankDecorationProvider.notifier)
          .equipDecoration(TankDecorationType.riverStones);
      await Future<void>.delayed(Duration.zero);

      saveGate.complete(false);

      expect(await equip, isFalse);
      expect(container.read(equippedTankDecorationProvider), isNull);
      expect(prefs.getString(kEquippedTankDecorationKey), isNull);
    });

    test('locked decorations cannot be equipped', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await _waitForDecorationProviders(container);

      final equipped = await container
          .read(equippedTankDecorationProvider.notifier)
          .equipDecoration(TankDecorationType.mossyHide);

      expect(equipped, isFalse);
      expect(container.read(equippedTankDecorationProvider), isNull);
    });
  });
}
