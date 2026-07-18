import 'dart:convert';

import 'package:danio/models/achievements.dart';
import 'package:danio/models/gem_transaction.dart';
import 'package:danio/models/tank.dart';
import 'package:danio/models/user_profile.dart';
import 'package:danio/providers/achievement_provider.dart';
import 'package:danio/providers/gems_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/services/achievement_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FailOnceSetStringPrefs implements SharedPreferences {
  _FailOnceSetStringPrefs(this._delegate, this.failedKey);

  final SharedPreferences _delegate;
  final String failedKey;
  bool _hasFailed = false;

  @override
  bool containsKey(String key) => _delegate.containsKey(key);

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  int? getInt(String key) => _delegate.getInt(key);

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  Future<bool> setString(String key, String value) {
    if (key == failedKey && !_hasFailed) {
      _hasFailed = true;
      throw StateError('Simulated SharedPreferences write failure for $key');
    }
    return _delegate.setString(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FailRewardAndProfileCompensationPrefs implements SharedPreferences {
  _FailRewardAndProfileCompensationPrefs(this._delegate);

  final SharedPreferences _delegate;
  var _profileWrites = 0;
  var _hasFailedReward = false;

  @override
  bool containsKey(String key) => _delegate.containsKey(key);

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  int? getInt(String key) => _delegate.getInt(key);

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  Future<bool> setString(String key, String value) {
    if (key == 'user_profile') {
      _profileWrites++;
      if (_profileWrites == 2) {
        throw StateError(
          'Simulated profile compensation failure for user_profile',
        );
      }
    }
    if (key == 'gems_cumulative' && !_hasFailedReward) {
      _hasFailedReward = true;
      throw StateError(
        'Simulated achievement reward failure for gems_cumulative',
      );
    }
    return _delegate.setString(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FailGemCumulativeAndRollbackPrefs implements SharedPreferences {
  _FailGemCumulativeAndRollbackPrefs(this._delegate);

  final SharedPreferences _delegate;
  var _gemsStateWrites = 0;
  var _hasFailedCumulative = false;

  @override
  bool containsKey(String key) => _delegate.containsKey(key);

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  int? getInt(String key) => _delegate.getInt(key);

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  Future<bool> setString(String key, String value) {
    if (key == 'gems_state') {
      _gemsStateWrites++;
      if (_gemsStateWrites == 2) {
        throw StateError(
          'Simulated gem state rollback failure for gems_state',
        );
      }
    }
    if (key == 'gems_cumulative' && !_hasFailedCumulative) {
      _hasFailedCumulative = true;
      throw StateError(
        'Simulated achievement reward failure for gems_cumulative',
      );
    }
    return _delegate.setString(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

UserProfile _profile() {
  final now = DateTime(2026, 7, 18, 12);
  return UserProfile(
    id: 'profile-1',
    experienceLevel: ExperienceLevel.beginner,
    primaryTankType: TankType.freshwater,
    goals: const [UserGoal.keepFishAlive],
    createdAt: now,
    updatedAt: now,
  );
}

GemsState _emptyGems() {
  return GemsState(
    balance: 0,
    transactions: const [],
    lastUpdated: DateTime(2026, 7, 18, 12),
  );
}

Future<void> _waitForLoad(ProviderContainer container) async {
  container.read(achievementProgressProvider);
  for (var i = 0; i < 20; i++) {
    final profile = container.read(userProfileProvider);
    final gems = container.read(gemsProvider);
    if (!profile.isLoading && !gems.isLoading) {
      for (var settle = 0; settle < 5; settle++) {
        await Future<void>.delayed(Duration.zero);
      }
      return;
    }
    await Future<void>.delayed(Duration.zero);
  }
  fail('Achievement test providers did not finish loading.');
}

ProviderContainer _container(SharedPreferences prefs) {
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async => prefs),
    ],
  );
}

void _disposeContainer(ProviderContainer container) {
  container
      .read(achievementProgressProvider.notifier)
      .cancelPendingSaveForRestore();
  container.dispose();
}

Future<List<AchievementUnlockResult>> _checkFirstLesson(
  ProviderContainer container,
) {
  return container
      .read(achievementCheckerProvider)
      .checkAchievements(
        const AchievementStats(lessonsCompleted: 1),
        showCelebrations: false,
      );
}

void _expectFirstLessonSettledExactlyOnce(ProviderContainer container) {
  final profile = container.read(userProfileProvider).requireValue!;
  expect(profile.achievements, ['first_lesson']);
  expect(profile.totalXp, 50);

  final progress = container.read(achievementProgressProvider)['first_lesson'];
  expect(progress?.achievementId, 'first_lesson');
  expect(progress?.currentCount, 1);
  expect(progress?.isUnlocked, isTrue);

  final gems = container.read(gemsProvider).requireValue;
  expect(gems.balance, 5);
  expect(gems.transactions, hasLength(1));
  expect(gems.transactions.single.type, GemTransactionType.earn);
  expect(gems.transactions.single.amount, 5);
  expect(gems.transactions.single.reason, 'Achievement: First Steps');
  expect(
    gems.transactions.single.idempotencyKey,
    achievementRewardIdempotencyKey('first_lesson'),
  );
  expect(container.read(gemsProvider.notifier).totalEarned, 5);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'failed profile write leaves first lesson reward recoverable on retry',
    () async {
      final profile = _profile();
      final emptyGems = _emptyGems();
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(profile.toJson()),
        'gems_state': jsonEncode(emptyGems.toJson()),
        'gems_cumulative': jsonEncode({'earned': 0, 'spent': 0}),
      });
      final backingPrefs = await SharedPreferences.getInstance();
      final prefs = _FailOnceSetStringPrefs(backingPrefs, 'user_profile');
      final container = _container(prefs);
      addTearDown(() => _disposeContainer(container));
      await _waitForLoad(container);

      await expectLater(
        _checkFirstLesson(container),
        throwsA(
          isA<StateError>().having(
            (error) => error.toString(),
            'message',
            contains('user_profile'),
          ),
        ),
      );

      final retryResults = await _checkFirstLesson(container);
      final unlockedResults = retryResults
          .where((result) => result.wasJustUnlocked)
          .toList();
      expect(unlockedResults, hasLength(1));
      expect(unlockedResults.single.achievement.id, 'first_lesson');
      expect(unlockedResults.single.xpAwarded, 50);
      _expectFirstLessonSettledExactlyOnce(container);

      expect(await _checkFirstLesson(container), isEmpty);
      _expectFirstLessonSettledExactlyOnce(container);
    },
  );

  test(
    'failed gem cumulative write leaves first lesson reward recoverable after reload',
    () async {
      final profile = _profile();
      final emptyGems = _emptyGems();
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(profile.toJson()),
        'gems_state': jsonEncode(emptyGems.toJson()),
        'gems_cumulative': jsonEncode({'earned': 0, 'spent': 0}),
      });
      final backingPrefs = await SharedPreferences.getInstance();
      final prefs = _FailOnceSetStringPrefs(backingPrefs, 'gems_cumulative');
      final failingContainer = _container(prefs);
      await _waitForLoad(failingContainer);

      await expectLater(
        _checkFirstLesson(failingContainer),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('gems_cumulative'),
          ),
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 700));
      _disposeContainer(failingContainer);

      final reloadedContainer = _container(prefs);
      addTearDown(() => _disposeContainer(reloadedContainer));
      await _waitForLoad(reloadedContainer);

      final retryResults = await _checkFirstLesson(reloadedContainer);
      final unlockedResults = retryResults
          .where((result) => result.wasJustUnlocked)
          .toList();
      expect(unlockedResults, hasLength(1));
      expect(unlockedResults.single.achievement.id, 'first_lesson');
      expect(unlockedResults.single.xpAwarded, 50);
      _expectFirstLessonSettledExactlyOnce(reloadedContainer);

      expect(await _checkFirstLesson(reloadedContainer), isEmpty);
      _expectFirstLessonSettledExactlyOnce(reloadedContainer);
    },
  );

  test(
    'failed profile compensation surfaces both achievement reward errors',
    () async {
      final profile = _profile();
      final emptyGems = _emptyGems();
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(profile.toJson()),
        'gems_state': jsonEncode(emptyGems.toJson()),
        'gems_cumulative': jsonEncode({'earned': 0, 'spent': 0}),
      });
      final backingPrefs = await SharedPreferences.getInstance();
      final prefs = _FailRewardAndProfileCompensationPrefs(backingPrefs);
      final container = _container(prefs);
      await _waitForLoad(container);

      await expectLater(
        _checkFirstLesson(container),
        throwsA(
          isA<AchievementRewardCompensationException>()
              .having(
                (error) => error.rewardError.toString(),
                'reward error',
                contains('gems_cumulative'),
              )
              .having(
                (error) => error.profileCompensationError.toString(),
                'profile compensation error',
                contains('user_profile'),
              )
              .having(
                (error) => error.toString(),
                'uncertainty message',
                contains('uncertain'),
              ),
        ),
      );

      expect(container.read(userProfileProvider).hasError, isTrue);
      expect(
        container.read(achievementProgressProvider)['first_lesson'],
        isNull,
      );
      final persistedGems = GemsState.fromJson(
        jsonDecode(backingPrefs.getString('gems_state')!)
            as Map<String, dynamic>,
      );
      expect(persistedGems.balance, 0);
      _disposeContainer(container);

      final reloadedContainer = _container(prefs);
      addTearDown(() => _disposeContainer(reloadedContainer));
      await _waitForLoad(reloadedContainer);

      final recoveryResults = await _checkFirstLesson(reloadedContainer);
      final recoveredUnlock = recoveryResults.singleWhere(
        (result) => result.achievement.id == 'first_lesson',
      );
      expect(recoveredUnlock.wasJustUnlocked, isTrue);
      expect(recoveredUnlock.xpAwarded, 50);
      _expectFirstLessonSettledExactlyOnce(reloadedContainer);

      expect(await _checkFirstLesson(reloadedContainer), isEmpty);
      _expectFirstLessonSettledExactlyOnce(reloadedContainer);
    },
  );

  test(
    'failed gem rollback surfaces uncertainty without duplicate retry',
    () async {
      final profile = _profile();
      final emptyGems = _emptyGems();
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(profile.toJson()),
        'gems_state': jsonEncode(emptyGems.toJson()),
        'gems_cumulative': jsonEncode({'earned': 0, 'spent': 0}),
      });
      final backingPrefs = await SharedPreferences.getInstance();
      final prefs = _FailGemCumulativeAndRollbackPrefs(backingPrefs);
      final failingContainer = _container(prefs);
      await _waitForLoad(failingContainer);

      await expectLater(
        _checkFirstLesson(failingContainer),
        throwsA(
          isA<Exception>()
              .having(
                (error) => error.toString(),
                'reward error',
                contains('gems_cumulative'),
              )
              .having(
                (error) => error.toString(),
                'rollback error',
                contains('gems_state'),
              )
              .having(
                (error) => error.toString(),
                'uncertainty message',
                contains('uncertain'),
              ),
        ),
      );

      final persistedProfile = UserProfile.fromJson(
        jsonDecode(backingPrefs.getString('user_profile')!)
            as Map<String, dynamic>,
      );
      expect(persistedProfile.achievements, ['first_lesson']);
      expect(persistedProfile.totalXp, 50);
      final persistedGems = GemsState.fromJson(
        jsonDecode(backingPrefs.getString('gems_state')!)
            as Map<String, dynamic>,
      );
      expect(persistedGems.balance, 5);
      expect(persistedGems.transactions, hasLength(1));
      expect(
        failingContainer.read(achievementProgressProvider)['first_lesson'],
        isNull,
      );
      _disposeContainer(failingContainer);

      final reloadedContainer = _container(prefs);
      addTearDown(() => _disposeContainer(reloadedContainer));
      await _waitForLoad(reloadedContainer);

      final recoveryResults = await _checkFirstLesson(reloadedContainer);
      final firstLesson = recoveryResults.singleWhere(
        (result) => result.achievement.id == 'first_lesson',
      );
      expect(firstLesson.wasJustUnlocked, isTrue);
      expect(firstLesson.xpAwarded, 50);
      _expectFirstLessonSettledExactlyOnce(reloadedContainer);

      expect(await _checkFirstLesson(reloadedContainer), isEmpty);
      _expectFirstLessonSettledExactlyOnce(reloadedContainer);
    },
  );

  test(
    'settled profile reward catches progress up silently after reload',
    () async {
      final profile = _profile();
      final emptyGems = _emptyGems();
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(profile.toJson()),
        'gems_state': jsonEncode(emptyGems.toJson()),
        'gems_cumulative': jsonEncode({'earned': 0, 'spent': 0}),
      });
      final prefs = await SharedPreferences.getInstance();
      final initialContainer = _container(prefs);
      await _waitForLoad(initialContainer);

      final initialResults = await _checkFirstLesson(initialContainer);
      final initialUnlocks = initialResults
          .where((result) => result.wasJustUnlocked)
          .toList();
      expect(initialUnlocks, hasLength(1));
      expect(initialUnlocks.single.achievement.id, 'first_lesson');
      _expectFirstLessonSettledExactlyOnce(initialContainer);
      _disposeContainer(initialContainer);

      final reloadedContainer = _container(prefs);
      addTearDown(() => _disposeContainer(reloadedContainer));
      await _waitForLoad(reloadedContainer);

      final catchUpResults = await _checkFirstLesson(reloadedContainer);
      final firstLesson = catchUpResults.singleWhere(
        (result) => result.achievement.id == 'first_lesson',
      );
      expect(firstLesson.wasJustUnlocked, isFalse);
      expect(firstLesson.xpAwarded, 0);
      _expectFirstLessonSettledExactlyOnce(reloadedContainer);

      expect(await _checkFirstLesson(reloadedContainer), isEmpty);
      _expectFirstLessonSettledExactlyOnce(reloadedContainer);
    },
  );
}
