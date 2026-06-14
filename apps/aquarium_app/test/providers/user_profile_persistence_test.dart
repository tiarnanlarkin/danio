// Persistence tests for UserProfileNotifier.
//
// Run: flutter test test/providers/user_profile_persistence_test.dart

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/models/tank.dart';
import 'package:danio/models/user_profile.dart';
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

Future<void> _waitForProfileLoad(ProviderContainer container) async {
  for (var i = 0; i < 20; i++) {
    final profileState = container.read(userProfileProvider);
    if (!profileState.isLoading) return;
    await Future<void>.delayed(Duration.zero);
  }
}

UserProfile _profile({String? name, bool hasSkippedPlacementTest = false}) {
  final now = DateTime.now();
  return UserProfile(
    id: 'profile-1',
    name: name,
    experienceLevel: ExperienceLevel.beginner,
    primaryTankType: TankType.freshwater,
    goals: [UserGoal.keepFishAlive],
    hasSkippedPlacementTest: hasSkippedPlacementTest,
    hasStreakFreeze: false,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserProfileNotifier persistence', () {
    test(
      'createProfile surfaces local save failures before exposing profile',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _ThrowingSetStringPrefs(
                prefs,
                (key, _) => key == 'user_profile',
              );
            }),
          ],
        );
        addTearDown(container.dispose);
        await _waitForProfileLoad(container);

        final notifier = container.read(userProfileProvider.notifier);

        await expectLater(
          notifier.createProfile(
            experienceLevel: ExperienceLevel.beginner,
            primaryTankType: TankType.freshwater,
            goals: [UserGoal.keepFishAlive],
          ),
          throwsA(isA<StateError>()),
        );

        expect(container.read(userProfileProvider).hasError, isTrue);
        expect(prefs.getString('user_profile'), isNull);
      },
    );

    test(
      'updateProfile surfaces local save failures before exposing edits',
      () async {
        final originalProfile = _profile(name: 'Existing keeper');
        SharedPreferences.setMockInitialValues({
          'user_profile': jsonEncode(originalProfile.toJson()),
        });
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _ThrowingSetStringPrefs(
                prefs,
                (key, _) => key == 'user_profile',
              );
            }),
          ],
        );
        addTearDown(container.dispose);
        await _waitForProfileLoad(container);

        final notifier = container.read(userProfileProvider.notifier);

        await expectLater(
          notifier.updateProfile(name: 'Edited keeper'),
          throwsA(isA<StateError>()),
        );

        final profileState = container.read(userProfileProvider);
        expect(profileState.value?.name, 'Existing keeper');
        expect(
          prefs.getString('user_profile'),
          jsonEncode(originalProfile.toJson()),
        );
      },
    );

    test(
      'skipPlacementTest surfaces local save failures before exposing skip',
      () async {
        final originalProfile = _profile();
        SharedPreferences.setMockInitialValues({
          'user_profile': jsonEncode(originalProfile.toJson()),
        });
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _ThrowingSetStringPrefs(
                prefs,
                (key, _) => key == 'user_profile',
              );
            }),
          ],
        );
        addTearDown(container.dispose);
        await _waitForProfileLoad(container);

        final notifier = container.read(userProfileProvider.notifier);

        await expectLater(
          notifier.skipPlacementTest(),
          throwsA(isA<StateError>()),
        );

        final profileState = container.read(userProfileProvider);
        expect(profileState.value?.hasSkippedPlacementTest, isFalse);
        expect(
          prefs.getString('user_profile'),
          jsonEncode(originalProfile.toJson()),
        );
      },
    );

    test(
      'addStreakFreeze surfaces local save failures before exposing freeze',
      () async {
        final originalProfile = _profile();
        SharedPreferences.setMockInitialValues({
          'user_profile': jsonEncode(originalProfile.toJson()),
        });
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _ThrowingSetStringPrefs(
                prefs,
                (key, _) => key == 'user_profile',
              );
            }),
          ],
        );
        addTearDown(container.dispose);
        await _waitForProfileLoad(container);

        final notifier = container.read(userProfileProvider.notifier);

        await expectLater(
          notifier.addStreakFreeze(),
          throwsA(isA<StateError>()),
        );

        final profileState = container.read(userProfileProvider);
        expect(profileState.value?.hasStreakFreeze, isFalse);
        expect(
          prefs.getString('user_profile'),
          jsonEncode(originalProfile.toJson()),
        );
      },
    );

    test(
      'updateAchievements surfaces local save failures before exposing progress',
      () async {
        final originalProfile = _profile();
        SharedPreferences.setMockInitialValues({
          'user_profile': jsonEncode(originalProfile.toJson()),
        });
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _ThrowingSetStringPrefs(
                prefs,
                (key, _) => key == 'user_profile',
              );
            }),
          ],
        );
        addTearDown(container.dispose);
        await _waitForProfileLoad(container);

        final notifier = container.read(userProfileProvider.notifier);

        await expectLater(
          notifier.updateAchievements(
            achievements: ['first_water_test'],
            xpToAdd: 25,
          ),
          throwsA(isA<StateError>()),
        );

        final profileState = container.read(userProfileProvider);
        expect(profileState.value?.achievements, isEmpty);
        expect(profileState.value?.totalXp, 0);
        expect(
          prefs.getString('user_profile'),
          jsonEncode(originalProfile.toJson()),
        );
      },
    );

    test(
      'updateHearts surfaces local save failures before exposing energy',
      () async {
        final originalProfile = _profile();
        SharedPreferences.setMockInitialValues({
          'user_profile': jsonEncode(originalProfile.toJson()),
        });
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _ThrowingSetStringPrefs(
                prefs,
                (key, _) => key == 'user_profile',
              );
            }),
          ],
        );
        addTearDown(container.dispose);
        await _waitForProfileLoad(container);

        final notifier = container.read(userProfileProvider.notifier);

        await expectLater(
          notifier.updateHearts(
            hearts: 3,
            lastHeartRefill: DateTime(2026, 6, 14, 12),
          ),
          throwsA(isA<StateError>()),
        );

        final profileState = container.read(userProfileProvider);
        expect(profileState.asData?.value?.hearts, isNot(3));
        expect(
          prefs.getString('user_profile'),
          jsonEncode(originalProfile.toJson()),
        );
      },
    );
  });
}
