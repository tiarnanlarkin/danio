import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/services/shared_preferences_backup.dart';

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
        await prefs.setString('achievement_progress', '{"first":true}');
        await prefs.setString('unlocked_species_v1', '["betta"]');
        await prefs.setString('wishlist_items', '[]');
        await prefs.setString('shop_budget', '{"monthlyBudget":100}');
        await prefs.setString('local_shops', '[]');
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
        expect(entries['achievement_progress'], '{"first":true}');
        expect(entries['unlocked_species_v1'], '["betta"]');
        expect(entries['wishlist_items'], '[]');
        expect(entries['shop_budget'], '{"monthlyBudget":100}');
        expect(entries['local_shops'], '[]');
        expect(entries.containsKey('user_openai_api_key'), isFalse);
      },
    );

    test(
      'restore clears all current exportable keys before writing backup',
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('spaced_repetition_streak', '{"streak":9}');
        await prefs.setInt('room_theme', 3);
        await prefs.setInt('theme_mode', 2);
        await prefs.setString('user_openai_api_key', 'secret');

        final restored = await SharedPreferencesBackup.restoreFromJson({
          'entries': {'theme_mode': 1},
        });

        expect(restored, 1);
        expect(prefs.getInt('theme_mode'), 1);
        expect(prefs.getString('spaced_repetition_streak'), isNull);
        expect(prefs.getInt('room_theme'), isNull);
        expect(prefs.getString('user_openai_api_key'), 'secret');
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
  });
}
