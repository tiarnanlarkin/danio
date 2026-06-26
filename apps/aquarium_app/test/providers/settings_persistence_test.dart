// Persistence tests for SettingsNotifier.
//
// Run: flutter test test/providers/settings_persistence_test.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/providers/settings_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';

class _ThrowingPrefs implements SharedPreferences {
  _ThrowingPrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key, Object value) _shouldFail;

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  int? getInt(String key) => _delegate.getInt(key);

  @override
  Future<bool> setBool(String key, bool value) {
    if (_shouldFail(key, value)) {
      throw StateError('Simulated SharedPreferences write failure for $key');
    }
    return _delegate.setBool(key, value);
  }

  @override
  Future<bool> setInt(String key, int value) {
    if (_shouldFail(key, value)) {
      throw StateError('Simulated SharedPreferences write failure for $key');
    }
    return _delegate.setInt(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FalsePrefs implements SharedPreferences {
  _FalsePrefs(this._delegate, this._failedKeys);

  final SharedPreferences _delegate;
  final Set<String> _failedKeys;

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  int? getInt(String key) => _delegate.getInt(key);

  @override
  Future<bool> setBool(String key, bool value) {
    if (_failedKeys.contains(key)) return Future<bool>.value(false);
    return _delegate.setBool(key, value);
  }

  @override
  Future<bool> setInt(String key, int value) {
    if (_failedKeys.contains(key)) return Future<bool>.value(false);
    return _delegate.setInt(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _waitForSettingsLoad(ProviderContainer container) async {
  for (var i = 0; i < 20; i += 1) {
    container.read(settingsProvider);
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsNotifier persistence', () {
    test(
      'setUseMetric keeps current state when the preference save fails',
      () async {
        SharedPreferences.setMockInitialValues({'use_metric': true});
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _ThrowingPrefs(prefs, (key, _) => key == 'use_metric');
            }),
          ],
        );
        addTearDown(container.dispose);
        await _waitForSettingsLoad(container);

        await container.read(settingsProvider.notifier).setUseMetric(false);

        expect(container.read(settingsProvider).useMetric, isTrue);
        expect(prefs.getBool('use_metric'), isTrue);
      },
    );

    test(
      'setThemeMode keeps current state when the preference save fails',
      () async {
        SharedPreferences.setMockInitialValues({'theme_mode': 0});
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _ThrowingPrefs(prefs, (key, _) => key == 'theme_mode');
            }),
          ],
        );
        addTearDown(container.dispose);
        await _waitForSettingsLoad(container);

        await container
            .read(settingsProvider.notifier)
            .setThemeMode(AppThemeMode.dark);

        expect(container.read(settingsProvider).themeMode, AppThemeMode.system);
        expect(prefs.getInt('theme_mode'), 0);
      },
    );

    test(
      'setting toggles report false and keep state when preference writes return false',
      () async {
        SharedPreferences.setMockInitialValues({
          'theme_mode': 0,
          'notifications_enabled': true,
          'ambient_lighting_enabled': true,
          'haptic_feedback_enabled': true,
        });
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _FalsePrefs(prefs, {
                'theme_mode',
                'notifications_enabled',
                'ambient_lighting_enabled',
                'haptic_feedback_enabled',
              });
            }),
          ],
        );
        addTearDown(container.dispose);
        await _waitForSettingsLoad(container);

        final notifier = container.read(settingsProvider.notifier);

        expect(
          await notifier.setThemeMode(AppThemeMode.dark),
          isFalse,
        );
        expect(await notifier.setNotificationsEnabled(false), isFalse);
        expect(await notifier.setAmbientLightingEnabled(false), isFalse);
        expect(await notifier.setHapticFeedbackEnabled(false), isFalse);

        final settings = container.read(settingsProvider);
        expect(settings.themeMode, AppThemeMode.system);
        expect(settings.notificationsEnabled, isTrue);
        expect(settings.ambientLightingEnabled, isTrue);
        expect(settings.hapticFeedbackEnabled, isTrue);
        expect(prefs.getInt('theme_mode'), 0);
        expect(prefs.getBool('notifications_enabled'), isTrue);
        expect(prefs.getBool('ambient_lighting_enabled'), isTrue);
        expect(prefs.getBool('haptic_feedback_enabled'), isTrue);
      },
    );
  });
}
