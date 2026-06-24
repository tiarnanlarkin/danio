import 'dart:convert';

import 'package:danio/models/achievements.dart';
import 'package:danio/providers/achievement_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
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
}
