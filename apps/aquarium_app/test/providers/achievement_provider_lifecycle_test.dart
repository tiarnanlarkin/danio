import 'dart:convert';

import 'package:danio/models/achievements.dart';
import 'package:danio/providers/achievement_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/utils/app_constants.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

class _FalseOnceSetStringPrefs implements SharedPreferences {
  _FalseOnceSetStringPrefs(this._delegate, this._failedKey);

  final SharedPreferences _delegate;
  final String _failedKey;
  var _hasFailed = false;

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  Future<bool> setString(String key, String value) {
    if (key == _failedKey && !_hasFailed) {
      _hasFailed = true;
      return Future<bool>.value(false);
    }
    return _delegate.setString(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'achievement progress flushes pending debounced save on app pause',
    () async {
      final binding = TestWidgetsFlutterBinding.instance;
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(achievementProgressProvider);
      await _settle();

      await container
          .read(achievementProgressProvider.notifier)
          .updateProgress(
            'first_steps',
            const AchievementProgress(
              achievementId: 'first_steps',
              currentCount: 1,
            ),
          );

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString('achievement_progress'),
        isNull,
        reason: 'The debounce timer has not fired yet.',
      );

      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await _settle();

      final savedJson = prefs.getString('achievement_progress');
      expect(savedJson, isNotNull);

      final decoded = jsonDecode(savedJson!) as Map<String, dynamic>;
      expect(decoded['first_steps'], isA<Map<String, dynamic>>());
      expect(
        (decoded['first_steps'] as Map<String, dynamic>)['currentCount'],
        1,
      );
    },
  );

  test(
    'restore cancellation clears pending achievement progress before pause',
    () async {
      final binding = TestWidgetsFlutterBinding.instance;
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(achievementProgressProvider);
      await _settle();

      await container
          .read(achievementProgressProvider.notifier)
          .updateProgress(
            'first_steps',
            const AchievementProgress(
              achievementId: 'first_steps',
              currentCount: 1,
            ),
          );

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString('achievement_progress'),
        isNull,
        reason: 'The debounce timer has not fired yet.',
      );

      container
          .read(achievementProgressProvider.notifier)
          .cancelPendingSaveForRestore();
      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await _settle();

      expect(
        prefs.getString('achievement_progress'),
        isNull,
        reason: 'Restore cancellation must prevent stale progress flushes.',
      );
    },
  );

  test(
    'false debounced achievement progress save stays pending for lifecycle retry',
    () async {
      final binding = TestWidgetsFlutterBinding.instance;
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async {
            return _FalseOnceSetStringPrefs(prefs, 'achievement_progress');
          }),
        ],
      );
      addTearDown(container.dispose);

      container.read(achievementProgressProvider);
      await _settle();

      await container
          .read(achievementProgressProvider.notifier)
          .updateProgress(
            'first_steps',
            const AchievementProgress(
              achievementId: 'first_steps',
              currentCount: 1,
            ),
          );

      await Future<void>.delayed(
        kProviderSaveDebounce + const Duration(milliseconds: 50),
      );
      await _settle();
      expect(
        prefs.getString('achievement_progress'),
        isNull,
        reason: 'The first debounced write returned false.',
      );

      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await _settle();

      final savedJson = prefs.getString('achievement_progress');
      expect(savedJson, isNotNull);
      final decoded = jsonDecode(savedJson!) as Map<String, dynamic>;
      expect(
        (decoded['first_steps'] as Map<String, dynamic>)['currentCount'],
        1,
      );
    },
  );
}
