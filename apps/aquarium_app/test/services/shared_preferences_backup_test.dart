import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import 'package:danio/services/shared_preferences_backup.dart';

class _FailingSharedPreferencesStore extends InMemorySharedPreferencesStore {
  _FailingSharedPreferencesStore.withData(
    super.data, {
    required this.failOnceOnKey,
  }) : super.withData();

  final String failOnceOnKey;
  var _hasFailed = false;

  @override
  Future<bool> setValue(String valueType, String key, Object value) {
    if (!_hasFailed && key == failOnceOnKey) {
      _hasFailed = true;
      throw StateError('simulated preference write failure for $key');
    }
    return super.setValue(valueType, key, value);
  }
}

class _FailingRestoreAndRollbackStore extends InMemorySharedPreferencesStore {
  _FailingRestoreAndRollbackStore.withData(
    super.data, {
    required this.failOnKey,
  }) : super.withData();

  final String failOnKey;
  var _failedWrites = 0;

  @override
  Future<bool> setValue(String valueType, String key, Object value) {
    if (key == failOnKey && _failedWrites < 2) {
      _failedWrites += 1;
      if (_failedWrites == 1) {
        _throwRestoreFailure(key);
      }
      _throwRollbackFailure(key);
    }
    return super.setValue(valueType, key, value);
  }

  Never _throwRestoreFailure(String key) {
    throw StateError('simulated restore preference write failure for $key');
  }

  Never _throwRollbackFailure(String key) {
    throw StateError('simulated rollback preference write failure for $key');
  }
}

void main() {
  group('SharedPreferencesBackup', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'exports app preferences and progress keys used in production',
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('theme_mode', 2);
        await prefs.setBool('use_metric', false);
        await prefs.setBool('notifications_enabled', true);
        await prefs.setBool('ambient_lighting_enabled', false);
        await prefs.setBool('haptic_feedback_enabled', false);
        await prefs.setInt('room_theme', 1);
        await prefs.setString(
          'unlocked_tank_decorations_v1',
          '["riverStones"]',
        );
        await prefs.setString('equipped_tank_decoration_v1', 'riverStones');
        await prefs.setString('achievement_progress', '{"first":true}');
        await prefs.setString('unlocked_species_v1', '["betta"]');
        await prefs.setString('wishlist_items', '[]');
        await prefs.setString('shop_budget', '{"monthlyBudget":100}');
        await prefs.setString('local_shops', '[]');
        await prefs.setString(
          'checklist_tank-1_state_v2',
          '{"week":"2026-W1","month":"2026-1","weekly":{},"monthly":{}}',
        );
        await prefs.setString('user_openai_api_key', 'secret');

        final backup =
            jsonDecode(await SharedPreferencesBackup.exportAsJson())
                as Map<String, dynamic>;
        final entries = backup['entries'] as Map<String, dynamic>;

        expect(entries['theme_mode'], 2);
        expect(entries['use_metric'], false);
        expect(entries['notifications_enabled'], true);
        expect(entries['ambient_lighting_enabled'], false);
        expect(entries['haptic_feedback_enabled'], false);
        expect(entries['room_theme'], 1);
        expect(entries['unlocked_tank_decorations_v1'], '["riverStones"]');
        expect(entries['equipped_tank_decoration_v1'], 'riverStones');
        expect(entries['achievement_progress'], '{"first":true}');
        expect(entries['unlocked_species_v1'], '["betta"]');
        expect(entries['wishlist_items'], '[]');
        expect(entries['shop_budget'], '{"monthlyBudget":100}');
        expect(entries['local_shops'], '[]');
        expect(
          entries['checklist_tank-1_state_v2'],
          '{"week":"2026-W1","month":"2026-1","weekly":{},"monthly":{}}',
        );
        expect(entries.containsKey('user_openai_api_key'), isFalse);
      },
    );

    test(
      'restore clears all current exportable keys before writing backup',
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('spaced_repetition_streak', '{"streak":9}');
        await prefs.setInt('room_theme', 3);
        await prefs.setString(
          'unlocked_tank_decorations_v1',
          '["riverStones"]',
        );
        await prefs.setString('equipped_tank_decoration_v1', 'riverStones');
        await prefs.setInt('theme_mode', 2);
        await prefs.setString('user_openai_api_key', 'secret');

        final restored = await SharedPreferencesBackup.restoreFromJson({
          'entries': {'theme_mode': 1},
        });

        expect(restored, 1);
        expect(prefs.getInt('theme_mode'), 1);
        expect(prefs.getString('spaced_repetition_streak'), isNull);
        expect(prefs.getInt('room_theme'), isNull);
        expect(prefs.getString('unlocked_tank_decorations_v1'), isNull);
        expect(prefs.getString('equipped_tank_decoration_v1'), isNull);
        expect(prefs.getString('user_openai_api_key'), 'secret');
      },
    );

    test(
      'restore rolls back previous preferences when a write fails mid-restore',
      () async {
        SharedPreferences.resetStatic();
        SharedPreferencesStorePlatform.instance =
            _FailingSharedPreferencesStore.withData({
              'flutter.theme_mode': 2,
              'flutter.use_metric': true,
              'flutter.room_theme': 3,
              'flutter.user_openai_api_key': 'secret',
            }, failOnceOnKey: 'flutter.use_metric');

        final prefs = await SharedPreferences.getInstance();

        await expectLater(
          SharedPreferencesBackup.restoreFromJson({
            'entries': {
              'theme_mode': 1,
              'use_metric': false,
            },
          }),
          throwsA(isA<StateError>()),
        );

        expect(prefs.getInt('theme_mode'), 2);
        expect(prefs.getBool('use_metric'), true);
        expect(prefs.getInt('room_theme'), 3);
        expect(prefs.getString('user_openai_api_key'), 'secret');
      },
    );

    test(
      'restore preserves the initiating error when snapshot rollback also fails',
      () async {
        SharedPreferences.resetStatic();
        SharedPreferencesStorePlatform.instance =
            _FailingRestoreAndRollbackStore.withData({
              'flutter.theme_mode': 2,
              'flutter.use_metric': true,
            }, failOnKey: 'flutter.use_metric');

        Object? thrown;
        StackTrace? thrownStackTrace;
        try {
          await SharedPreferencesBackup.restoreFromJson({
            'entries': {
              'theme_mode': 1,
              'use_metric': false,
            },
          });
        } catch (error, stackTrace) {
          thrown = error;
          thrownStackTrace = stackTrace;
        }

        expect(thrown, isA<SharedPreferencesRestoreException>());
        final restoreError = thrown as SharedPreferencesRestoreException;
        expect(
          restoreError.toString(),
          allOf(
            contains('simulated restore preference write failure'),
            contains('simulated rollback preference write failure'),
          ),
        );
        expect(
          restoreError.originalError,
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('simulated restore preference write failure'),
          ),
        );
        expect(
          restoreError.rollbackError,
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('simulated rollback preference write failure'),
          ),
        );
        expect(
          restoreError.originalStackTrace.toString(),
          allOf(
            contains('_throwRestoreFailure'),
            isNot(contains('_throwRollbackFailure')),
          ),
        );
        expect(
          restoreError.rollbackStackTrace.toString(),
          allOf(
            contains('_throwRollbackFailure'),
            isNot(contains('_throwRestoreFailure')),
          ),
        );
        expect(
          thrownStackTrace.toString(),
          allOf(
            contains('_throwRestoreFailure'),
            isNot(contains('_throwRollbackFailure')),
          ),
        );
      },
    );

    test('restore ignores non-exportable entries from backup files', () async {
      final prefs = await SharedPreferences.getInstance();

      final restored = await SharedPreferencesBackup.restoreFromJson({
        'entries': {
          'theme_mode': 1,
          'user_openai_api_key': 'secret',
          'flutter.internal': 'internal',
        },
      });

      expect(restored, 1);
      expect(prefs.getInt('theme_mode'), 1);
      expect(prefs.getString('user_openai_api_key'), isNull);
      expect(prefs.getString('flutter.internal'), isNull);
    });

    for (final scenario in [
      (
        label: 'object value',
        entries: {
          'theme_mode': {'mode': 1},
        },
        message: 'Invalid backup: unsupported preference value for theme_mode',
      ),
      (
        label: 'mixed string list',
        entries: {
          'aquarium_reminders': ['morning', 9],
        },
        message:
            'Invalid backup: string list preference aquarium_reminders contains non-string values',
      ),
    ]) {
      test(
        'restore rejects ${scenario.label} before clearing existing preferences',
        () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('theme_mode', 2);

          await expectLater(
            SharedPreferencesBackup.restoreFromJson({
              'entries': scenario.entries,
            }),
            throwsA(
              isA<FormatException>().having(
                (error) => error.message,
                'message',
                contains(scenario.message),
              ),
            ),
          );

          expect(prefs.getInt('theme_mode'), 2);
        },
      );
    }

    for (final scenario in [
      (
        label: 'integer preference with decimal value',
        existingKey: 'theme_mode',
        seed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('theme_mode', 2);
        },
        entries: {'theme_mode': 1.5},
        message: 'Invalid backup: preference theme_mode must be an integer',
        assertUnchanged: () async {
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getInt('theme_mode'), 2);
        },
      ),
      (
        label: 'boolean preference with string value',
        existingKey: 'use_metric',
        seed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('use_metric', true);
        },
        entries: {'use_metric': 'false'},
        message: 'Invalid backup: preference use_metric must be a boolean',
        assertUnchanged: () async {
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getBool('use_metric'), isTrue);
        },
      ),
      (
        label: 'string preference with string-list value',
        existingKey: 'aquarium_reminders',
        seed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('aquarium_reminders', '[]');
        },
        entries: {
          'aquarium_reminders': ['morning'],
        },
        message:
            'Invalid backup: preference aquarium_reminders must be a string',
        assertUnchanged: () async {
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getString('aquarium_reminders'), '[]');
        },
      ),
    ]) {
      test(
        'restore rejects ${scenario.label} before clearing ${scenario.existingKey}',
        () async {
          await scenario.seed();

          await expectLater(
            SharedPreferencesBackup.restoreFromJson({
              'entries': scenario.entries,
            }),
            throwsA(
              isA<FormatException>().having(
                (error) => error.message,
                'message',
                contains(scenario.message),
              ),
            ),
          );

          await scenario.assertUnchanged();
        },
      );
    }
  });
}
