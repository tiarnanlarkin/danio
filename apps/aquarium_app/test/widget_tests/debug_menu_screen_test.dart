// Widget tests for DebugMenuScreen.
//
// Run: flutter test test/widget_tests/debug_menu_screen_test.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/debug_menu_screen.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/providers/spaced_repetition_provider.dart';
import 'package:danio/providers/tank_decoration_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/models/equipment.dart';
import 'package:danio/models/log_entry.dart';
import 'package:danio/models/spaced_repetition.dart';
import 'package:danio/models/task.dart';
import 'package:danio/models/tank_decoration.dart';
import 'package:danio/models/user_profile.dart';
import 'package:danio/services/tank_livestock_visual_service.dart';
import 'package:danio/services/room_theme_unlock_service.dart';
import 'package:danio/services/tank_decoration_unlock_service.dart';
import 'package:danio/services/tank_progress_visual_service.dart';
import 'package:danio/services/onboarding_service.dart';
import 'package:danio/services/notification_scheduler.dart';
import 'package:danio/theme/room_themes.dart';
import 'package:danio/features/smart/ai_disclosure_preferences.dart';

Widget _wrap({
  InMemoryStorageService? storage,
  SharedPreferences? sharedPreferences,
  List<Override> overrides = const [],
}) {
  if (sharedPreferences == null) {
    SharedPreferences.setMockInitialValues({});
  }
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        return sharedPreferences ?? SharedPreferences.getInstance();
      }),
      if (storage != null) storageServiceProvider.overrideWithValue(storage),
      ...overrides,
    ],
    child: const MaterialApp(home: DebugMenuScreen()),
  );
}

class _FailingPrefs implements SharedPreferences {
  _FailingPrefs(
    this._delegate, {
    this.shouldFailRemove = _neverFailRemove,
    this.shouldFailSetString = _neverFailSetString,
    this.failClear = false,
  });

  final SharedPreferences _delegate;
  final bool Function(String key) shouldFailRemove;
  final bool Function(String key, String value) shouldFailSetString;
  final bool failClear;

  static bool _neverFailRemove(String key) => false;

  static bool _neverFailSetString(String key, String value) => false;

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  int? getInt(String key) => _delegate.getInt(key);

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  bool containsKey(String key) => _delegate.containsKey(key);

  @override
  Future<bool> setString(String key, String value) {
    if (shouldFailSetString(key, value)) {
      return Future<bool>.value(false);
    }
    return _delegate.setString(key, value);
  }

  @override
  Future<bool> setInt(String key, int value) => _delegate.setInt(key, value);

  @override
  Future<bool> setBool(String key, bool value) => _delegate.setBool(key, value);

  @override
  Future<bool> remove(String key) {
    if (shouldFailRemove(key)) {
      return Future<bool>.value(false);
    }
    return _delegate.remove(key);
  }

  @override
  Future<bool> clear() {
    if (failClear) {
      return Future<bool>.value(false);
    }
    return _delegate.clear();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DebugProfileWriteCase {
  const _DebugProfileWriteCase({
    required this.actionLabel,
    required this.errorPrefix,
  });

  final String actionLabel;
  final String errorPrefix;
}

class _NoopReminderNotificationService implements ReminderNotificationService {
  @override
  Future<void> cancelReviewReminder() async {}

  @override
  Future<void> cancelStreakNotifications() async {}

  @override
  Future<void> scheduleAllStreakNotifications({
    required int currentStreak,
    required int dailyXpGoal,
    required int todayXp,
    TimeOfDay? morningTime,
    TimeOfDay? eveningTime,
    TimeOfDay? nightTime,
  }) async {}

  @override
  Future<void> scheduleReviewReminder({
    required int dueCardsCount,
    TimeOfDay? time,
  }) async {}
}

class _FrozenSpacedRepetitionNotifier extends SpacedRepetitionNotifier {
  _FrozenSpacedRepetitionNotifier(
    super.ref, {
    required List<ReviewCard> cards,
  }) {
    state = SpacedRepetitionState(
      cards: cards,
      stats: ReviewStats.fromCards(cards),
    );
  }
}

List<ReviewCard> _futureReviewCards(int count) {
  final now = DateTime(2026, 6, 26, 12);
  return List.generate(
    count,
    (index) => ReviewCard(
      id: 'future-card-$index',
      conceptId: 'concept-$index',
      conceptType: ConceptType.lesson,
      strength: 0.6,
      lastReviewed: now,
      nextReview: now.add(const Duration(days: 7)),
    ),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    OnboardingService.resetForTesting();
  });

  tearDown(OnboardingService.resetForTesting);

  Future<void> clearStorage(InMemoryStorageService storage) async {
    final tanks = await storage.getAllTanks();
    await storage.deleteAllTanks(tanks.map((tank) => tank.id).toList());
  }

  group('DebugMenuScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(DebugMenuScreen), findsOneWidget);
    });

    testWidgets('shows Debug Menu app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('🐛 Debug Menu'), findsOneWidget);
    });

    testWidgets('shows Onboarding section header', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Onboarding'), findsOneWidget);
    });

    testWidgets('shows ListView', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows Complete Onboarding tile', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Complete Onboarding'), findsOneWidget);
    });

    testWidgets('seeds emergency unsafe-water QA tank and log', (
      tester,
    ) async {
      final storage = InMemoryStorageService();
      await clearStorage(storage);

      await tester.pumpWidget(_wrap(storage: storage));
      await _advance(tester);

      await tester.scrollUntilVisible(
        find.text('Seed Emergency Water Spike'),
        500,
      );
      await tester.tap(find.text('Seed Emergency Water Spike'));
      await tester.pumpAndSettle();

      final tank = await storage.getTank('debug-emergency-water-tank');
      expect(tank, isNotNull);
      expect(tank!.name, 'QA Emergency Water Spike');

      final livestock = await storage.getLivestockForTank(tank.id);
      expect(livestock.single.healthStatus.name, 'sick');

      final logs = await storage.getLogsForTank(tank.id);
      final waterTest = logs.singleWhere(
        (log) => log.type == LogType.waterTest,
      );
      expect(waterTest.waterTest?.ammonia, greaterThan(0));
      expect(waterTest.waterTest?.nitrite, greaterThan(0));
      expect(waterTest.title, contains('Emergency'));
    });

    testWidgets('seeds incompatible fish QA tank for visual checks', (
      tester,
    ) async {
      final storage = InMemoryStorageService();
      await clearStorage(storage);

      await tester.pumpWidget(_wrap(storage: storage));
      await _advance(tester);

      await tester.scrollUntilVisible(
        find.text('Seed Incompatible Fish Tank'),
        500,
      );
      await tester.tap(find.text('Seed Incompatible Fish Tank'));
      await tester.pumpAndSettle();

      final tank = await storage.getTank('debug-incompatible-fish-tank');
      expect(tank, isNotNull);
      expect(tank!.name, 'QA Incompatible Fish Tank');

      final livestock = await storage.getLivestockForTank(tank.id);
      expect(
        livestock.map((fish) => fish.commonName),
        containsAll(['Betta', 'Guppy']),
      );

      final visualState = TankLivestockVisualService.fromTank(
        tank: tank,
        livestock: livestock,
      );
      expect(
        visualState.condition,
        TankLivestockVisualCondition.compatibilityConcern,
      );
    });

    testWidgets('seeds skipped onboarding quick-start state', (tester) async {
      final storage = InMemoryStorageService();
      await clearStorage(storage);

      await tester.pumpWidget(_wrap(storage: storage));
      await _advance(tester);

      await tester.scrollUntilVisible(
        find.text('Seed Skipped Onboarding'),
        500,
      );
      await tester.tap(find.text('Seed Skipped Onboarding'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('onboarding_completed'), isTrue);

      final profileJson =
          jsonDecode(prefs.getString('user_profile')!) as Map<String, dynamic>;
      expect(profileJson['experienceLevel'], 'beginner');
      expect(profileJson['primaryTankType'], 'freshwater');
      expect(profileJson['goals'], contains('keepFishAlive'));

      final demoTank = (await storage.getAllTanks()).singleWhere(
        (tank) => tank.isDemoTank && tank.name == 'Sample Tank',
      );
      expect(await storage.getLivestockForTank(demoTank.id), isNotEmpty);
      expect(await storage.getLogsForTank(demoTank.id), isNotEmpty);
    });

    testWidgets('seeds no-AI Smart Hub QA state without fake keys', (
      tester,
    ) async {
      final storage = InMemoryStorageService();
      await clearStorage(storage);

      await tester.pumpWidget(_wrap(storage: storage));
      await _advance(tester);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_openai_api_key', 'debug-fake-key');
      await prefs.setBool(AiDisclosurePreferences.acceptedKey, true);

      await tester.scrollUntilVisible(
        find.text('Seed No-AI Smart Hub State'),
        500,
      );
      await tester.tap(find.text('Seed No-AI Smart Hub State'));
      await tester.pumpAndSettle();

      expect(prefs.containsKey('user_openai_api_key'), isFalse);
      expect(prefs.containsKey(AiDisclosurePreferences.acceptedKey), isFalse);

      final tank = await storage.getTank('debug-no-ai-smart-tank');
      expect(tank, isNotNull);
      expect(tank!.name, 'QA No-AI Smart Hub');

      final logs = await storage.getLogsForTank(tank.id);
      final waterTest = logs.singleWhere(
        (log) => log.type == LogType.waterTest,
      );
      expect(waterTest.waterTest?.nitrate, greaterThanOrEqualTo(40));
    });

    testWidgets('seeds partial unlock edge QA state', (tester) async {
      final storage = InMemoryStorageService();
      await clearStorage(storage);

      await tester.pumpWidget(_wrap(storage: storage));
      await _advance(tester);

      await tester.scrollUntilVisible(find.text('Seed Unlock Edge State'), 500);
      await tester.tap(find.text('Seed Unlock Edge State'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      final rawProfile = prefs.getString('user_profile');
      expect(rawProfile, isNotNull);

      final profile = UserProfile.fromJson(
        jsonDecode(rawProfile!) as Map<String, dynamic>,
      );
      expect(profile.totalXp, 900);
      expect(profile.currentStreak, 6);
      expect(profile.completedLessons, hasLength(9));
      expect(profile.completedLessons.last, 'debug_unlock_edge_lesson_9');

      final rawSpecies = prefs.getString('unlocked_species_v1');
      expect(rawSpecies, isNotNull);
      final unlockedSpecies = (jsonDecode(rawSpecies!) as List<dynamic>)
          .whereType<String>()
          .toSet();
      expect(unlockedSpecies, contains('betta'));
      expect(unlockedSpecies, isNot(contains('discus')));

      final progressVisual = TankProgressVisualService.fromUnlockedSpecies(
        unlockedSpecies,
      );
      expect(
        progressVisual.condition,
        TankProgressVisualCondition.speciesUnlocked,
      );

      final rawDecorations = prefs.getString(kUnlockedTankDecorationsKey);
      expect(rawDecorations, isNotNull);
      final unlockedDecorations = (jsonDecode(rawDecorations!) as List<dynamic>)
          .whereType<String>()
          .map(
            (name) => TankDecorationType.values.firstWhere(
              (type) => type.name == name,
            ),
          )
          .toSet();
      expect(unlockedDecorations, contains(TankDecorationType.driftwoodArch));
      expect(
        unlockedDecorations,
        isNot(contains(TankDecorationType.mossyHide)),
      );
      expect(
        prefs.getString(kEquippedTankDecorationKey),
        TankDecorationType.driftwoodArch.name,
      );

      final decorationStates = TankDecorationUnlockService.statesFor(
        profile: profile,
        unlockedSpecies: unlockedSpecies,
        unlockedDecorations: unlockedDecorations,
      );
      expect(
        decorationStates[TankDecorationType.driftwoodArch]?.isUnlocked,
        isTrue,
      );
      expect(
        decorationStates[TankDecorationType.mossyHide]?.isUnlocked,
        isFalse,
      );
      expect(
        decorationStates[TankDecorationType.ceramicShelter]?.isUnlocked,
        isFalse,
      );

      final roomStates = RoomThemeUnlockService.statesFor(
        profile: profile,
        unlockedSpecies: unlockedSpecies,
      );
      expect(roomStates[RoomThemeType.pastel]?.isUnlocked, isTrue);
      expect(roomStates[RoomThemeType.eveningGlow]?.isUnlocked, isTrue);
      expect(roomStates[RoomThemeType.midnight]?.isUnlocked, isFalse);
      expect(roomStates[RoomThemeType.watercolor]?.isUnlocked, isFalse);
      expect(prefs.getInt('room_theme'), RoomThemeType.eveningGlow.index);
    });

    testWidgets('seeds tablet visual QA state', (tester) async {
      final storage = InMemoryStorageService();
      await clearStorage(storage);

      await tester.pumpWidget(_wrap(storage: storage));
      await _advance(tester);

      await tester.scrollUntilVisible(find.text('Seed Tablet QA State'), 500);
      await tester.tap(find.text('Seed Tablet QA State'));
      await tester.pumpAndSettle();

      final tank = await storage.getTank('debug-tablet-qa-tank');
      expect(tank, isNotNull);
      expect(tank!.name, 'QA Tablet Long Layout Community Tank');
      expect(tank.notes, contains('tablet'));

      final livestock = await storage.getLivestockForTank(tank.id);
      expect(livestock, hasLength(greaterThanOrEqualTo(4)));
      expect(
        livestock.map((fish) => fish.commonName),
        contains('Longfin Pearl Gourami Layout Stress Group'),
      );
      expect(
        livestock.fold<int>(0, (total, fish) => total + fish.count),
        greaterThanOrEqualTo(30),
      );

      final equipment = await storage.getEquipmentForTank(tank.id);
      expect(equipment, hasLength(greaterThanOrEqualTo(3)));
      expect(equipment.map((item) => item.type), contains(EquipmentType.light));
      expect(
        equipment.map((item) => item.type),
        contains(EquipmentType.filter),
      );

      final tasks = await storage.getTasksForTank(tank.id);
      expect(tasks, hasLength(greaterThanOrEqualTo(4)));
      expect(tasks.map((task) => task.priority), contains(TaskPriority.high));
      expect(
        tasks.map((task) => task.title),
        contains('Trim background stems and replant healthy tops'),
      );

      final logs = await storage.getLogsForTank(tank.id);
      expect(logs, hasLength(greaterThanOrEqualTo(4)));
      expect(logs.map((log) => log.type), contains(LogType.waterTest));
      expect(logs.map((log) => log.type), contains(LogType.feeding));
      expect(logs.map((log) => log.type), contains(LogType.waterChange));
      expect(logs.map((log) => log.title), contains('Tablet QA water test'));
    });

    testWidgets(
      'reset achievements reports failed local removal without clearing profile',
      (tester) async {
        final originalProfile = UserProfile(
          id: 'debug-profile',
          achievements: const ['first_tank'],
          createdAt: DateTime(2026, 6, 26),
          updatedAt: DateTime(2026, 6, 26),
        );
        const progressJson = '{"first_tank":{"current":1}}';
        SharedPreferences.setMockInitialValues({
          'achievement_progress': progressJson,
          'user_profile': jsonEncode(originalProfile.toJson()),
        });
        final prefs = await SharedPreferences.getInstance();

        await tester.pumpWidget(
          _wrap(
            sharedPreferences: _FailingPrefs(
              prefs,
              shouldFailRemove: (key) => key == 'achievement_progress',
            ),
          ),
        );
        await _advance(tester);

        await tester.scrollUntilVisible(
          find.text('Reset Achievements Only'),
          500,
        );
        await tester.tap(find.text('Reset Achievements Only'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Reset achievements failed'),
          findsOneWidget,
        );
        expect(find.text('Achievements cleared'), findsNothing);
        expect(prefs.getString('achievement_progress'), progressJson);

        final savedProfile = UserProfile.fromJson(
          jsonDecode(prefs.getString('user_profile')!) as Map<String, dynamic>,
        );
        expect(savedProfile.achievements, originalProfile.achievements);
      },
    );

    testWidgets(
      'reset achievements restores progress when profile write fails',
      (tester) async {
        final originalProfile = UserProfile(
          id: 'debug-profile',
          achievements: const ['first_tank'],
          createdAt: DateTime(2026, 6, 26),
          updatedAt: DateTime(2026, 6, 26),
        );
        const progressJson = '{"first_tank":{"current":1}}';
        SharedPreferences.setMockInitialValues({
          'achievement_progress': progressJson,
          'user_profile': jsonEncode(originalProfile.toJson()),
        });
        final prefs = await SharedPreferences.getInstance();

        await tester.pumpWidget(
          _wrap(
            sharedPreferences: _FailingPrefs(
              prefs,
              shouldFailSetString: (key, _) => key == 'user_profile',
            ),
          ),
        );
        await _advance(tester);

        await tester.scrollUntilVisible(
          find.text('Reset Achievements Only'),
          500,
        );
        await tester.tap(find.text('Reset Achievements Only'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Reset achievements failed'),
          findsOneWidget,
        );
        expect(find.text('Achievements cleared'), findsNothing);
        expect(prefs.getString('achievement_progress'), progressJson);

        final savedProfile = UserProfile.fromJson(
          jsonDecode(prefs.getString('user_profile')!) as Map<String, dynamic>,
        );
        expect(savedProfile.achievements, originalProfile.achievements);
      },
    );

    for (final debugCase in const [
      _DebugProfileWriteCase(
        actionLabel: 'Set XP: 500',
        errorPrefix: 'Set XP failed',
      ),
      _DebugProfileWriteCase(
        actionLabel: 'Set Streak: 7',
        errorPrefix: 'Set streak failed',
      ),
      _DebugProfileWriteCase(
        actionLabel: 'Reset Learning Only',
        errorPrefix: 'Reset learning failed',
      ),
      _DebugProfileWriteCase(
        actionLabel: 'Reset Gamification Only',
        errorPrefix: 'Reset gamification failed',
      ),
      _DebugProfileWriteCase(
        actionLabel: 'Complete All Lessons',
        errorPrefix: 'Complete all lessons failed',
      ),
    ]) {
      testWidgets(
        '${debugCase.actionLabel} reports failed profile writes',
        (tester) async {
          final originalProfile = UserProfile(
            id: 'debug-profile',
            totalXp: 123,
            weeklyXP: 77,
            currentStreak: 5,
            longestStreak: 8,
            hearts: 3,
            completedLessons: const ['existing_lesson'],
            achievements: const ['first_tank'],
            createdAt: DateTime(2026, 6, 26),
            updatedAt: DateTime(2026, 6, 26),
          );
          final originalJson = jsonEncode(originalProfile.toJson());
          SharedPreferences.setMockInitialValues({
            'user_profile': originalJson,
          });
          final prefs = await SharedPreferences.getInstance();

          await tester.pumpWidget(
            _wrap(
              sharedPreferences: _FailingPrefs(
                prefs,
                shouldFailSetString: (key, _) => key == 'user_profile',
              ),
            ),
          );
          await _advance(tester);

          await tester.scrollUntilVisible(
            find.text(debugCase.actionLabel),
            500,
          );
          await tester.tap(find.text(debugCase.actionLabel));
          await tester.pumpAndSettle();

          expect(
            find.textContaining(debugCase.errorPrefix),
            findsOneWidget,
          );
          expect(prefs.getString('user_profile'), originalJson);
        },
      );
    }

    testWidgets('reset species reports failed local unlock writes', (
      tester,
    ) async {
      const originalSpeciesJson = '["betta"]';
      SharedPreferences.setMockInitialValues({
        'unlocked_species_v1': originalSpeciesJson,
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        _wrap(
          sharedPreferences: _FailingPrefs(
            prefs,
            shouldFailSetString: (key, _) => key == 'unlocked_species_v1',
          ),
        ),
      );
      await _advance(tester);

      await tester.scrollUntilVisible(
        find.text('Reset Species to Defaults'),
        500,
      );
      await tester.ensureVisible(find.text('Reset Species to Defaults'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset Species to Defaults'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Reset species failed'), findsOneWidget);
      expect(prefs.getString('unlocked_species_v1'), originalSpeciesJson);
    });

    testWidgets('clear all data reports failed local preference clear', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'user_profile': '{"id":"debug-profile"}',
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        _wrap(sharedPreferences: _FailingPrefs(prefs, failClear: true)),
      );
      await _advance(tester);

      await tester.scrollUntilVisible(find.text('Clear All Data'), 500);
      await tester.ensureVisible(find.text('Clear All Data'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear All Data'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Clear all data failed'), findsOneWidget);
      expect(find.text('All data cleared. Restart the app.'), findsNothing);
      expect(prefs.getString('user_profile'), '{"id":"debug-profile"}');
    });

    testWidgets('force SR cards due reports failed local card writes', (
      tester,
    ) async {
      final originalCards = _futureReviewCards(1);
      final originalJson = jsonEncode(
        originalCards.map((card) => card.toJson()).toList(),
      );
      SharedPreferences.setMockInitialValues({
        'spaced_repetition_cards': originalJson,
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        _wrap(
          sharedPreferences: _FailingPrefs(
            prefs,
            shouldFailSetString: (key, _) => key == 'spaced_repetition_cards',
          ),
          overrides: [
            notificationServiceProvider.overrideWithValue(
              _NoopReminderNotificationService(),
            ),
            spacedRepetitionProvider.overrideWith(
              (ref) => _FrozenSpacedRepetitionNotifier(
                ref,
                cards: originalCards,
              ),
            ),
          ],
        ),
      );
      await _advance(tester);

      await tester.scrollUntilVisible(find.text('Force 10 SR Cards Due'), 500);
      await tester.ensureVisible(find.text('Force 10 SR Cards Due'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Force 10 SR Cards Due'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Force SR cards due failed'), findsOneWidget);
      expect(find.text('1 SR cards set to due-now'), findsNothing);
      expect(prefs.getString('spaced_repetition_cards'), originalJson);
    });
  });
}
