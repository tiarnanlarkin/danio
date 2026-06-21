// Persistence tests for SpeciesUnlockNotifier.
//
// Run: flutter test test/providers/species_unlock_persistence_test.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/data/species_unlock_map.dart';
import 'package:danio/providers/species_unlock_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';

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

Future<void> _waitForSpeciesUnlockLoad(ProviderContainer container) async {
  for (var i = 0; i < 20; i += 1) {
    container.read(speciesUnlockProvider);
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SpeciesUnlockNotifier persistence', () {
    test(
      'unlockSpecies waits for save before exposing earned species',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final saveGate = Completer<bool>();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _DelayedSetStringPrefs(
                delegate: prefs,
                delayedKey: 'unlocked_species_v1',
                gate: saveGate,
              );
            }),
          ],
        );
        addTearDown(container.dispose);
        final subscription = container.listen(
          speciesUnlockProvider,
          (_, __) {},
        );
        addTearDown(subscription.close);
        await _waitForSpeciesUnlockLoad(container);

        expect(container.read(speciesUnlockProvider), contains('neon_tetra'));
        expect(container.read(speciesUnlockProvider), isNot(contains('betta')));

        final unlock = container
            .read(speciesUnlockProvider.notifier)
            .unlockSpecies('betta');
        await Future<void>.delayed(Duration.zero);

        expect(container.read(speciesUnlockProvider), isNot(contains('betta')));

        saveGate.complete(true);
        expect(await unlock, isTrue);

        expect(container.read(speciesUnlockProvider), contains('betta'));
        final savedSpecies =
            jsonDecode(prefs.getString('unlocked_species_v1')!) as List;
        expect(savedSpecies, contains('betta'));
      },
    );

    test(
      'unlockSpecies keeps species locked when save returns false',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final saveGate = Completer<bool>();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _DelayedSetStringPrefs(
                delegate: prefs,
                delayedKey: 'unlocked_species_v1',
                gate: saveGate,
              );
            }),
          ],
        );
        addTearDown(container.dispose);
        final subscription = container.listen(
          speciesUnlockProvider,
          (_, __) {},
        );
        addTearDown(subscription.close);
        await _waitForSpeciesUnlockLoad(container);

        final unlock = container
            .read(speciesUnlockProvider.notifier)
            .unlockSpecies('betta');
        await Future<void>.delayed(Duration.zero);

        saveGate.complete(false);

        expect(await unlock, isFalse);
        expect(container.read(speciesUnlockProvider), defaultUnlockedSpecies);
        expect(prefs.getString('unlocked_species_v1'), isNull);
      },
    );
  });
}
