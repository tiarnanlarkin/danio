// Serialization round-trip tests for UserProfile, Tank, and LogEntry.
//
// Verifies that toJson() -> fromJson() preserves every field, that copyWith()
// modifies only the target field, and that fromJson() supplies sensible
// defaults when only required fields are present.
//
// Run: flutter test test/model_tests/serialization_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:danio/models/user_profile.dart';
import 'package:danio/models/tank.dart';
import 'package:danio/models/log_entry.dart';
import 'package:danio/models/leaderboard.dart';
import 'package:danio/models/lesson_progress.dart';
import 'package:danio/models/shop_item.dart';

// ---------------------------------------------------------------------------
// Helper factories — fully-populated instances for round-trip tests.
// ---------------------------------------------------------------------------

UserProfile _testProfile() {
  final now = DateTime.utc(2025, 6, 15, 10, 30);
  final yesterday = now.subtract(const Duration(days: 1));
  return UserProfile(
    id: 'user-42',
    name: 'Ada',
    experienceLevel: ExperienceLevel.intermediate,
    primaryTankType: TankType.freshwater,
    goals: [UserGoal.breeding, UserGoal.learnTheScience],
    totalXp: 750,
    currentStreak: 5,
    longestStreak: 12,
    lastActivityDate: yesterday,
    achievements: ['first_test', 'streak_7'],
    completedLessons: ['lesson_1', 'lesson_2'],
    lessonProgress: {
      'lesson_1': LessonProgress(
        lessonId: 'lesson_1',
        completedDate: now.subtract(const Duration(days: 10)),
        lastReviewDate: now.subtract(const Duration(days: 2)),
        reviewCount: 3,
        strength: 85.0,
      ),
    },
    completedStories: ['story_intro'],
    storyProgress: {
      'story_intro': {'chapter': 2, 'completed': true},
    },
    hasCompletedPlacementTest: true,
    hasSkippedPlacementTest: false,
    placementResultId: 'placement-abc',
    placementTestDate: now.subtract(const Duration(days: 30)),
    dailyXpGoal: 75,
    dailyXpHistory: {'2025-06-14': 80, '2025-06-13': 50},
    hasStreakFreeze: false,
    streakFreezeUsedDate: yesterday,
    streakFreezeGrantedDate: now.subtract(const Duration(days: 6)),
    hearts: 3,
    lastHeartRefill: yesterday,
    league: League.gold,
    weeklyXP: 420,
    weekStartDate: now.subtract(const Duration(days: 2)),
    inventory: [
      InventoryItem(
        itemId: 'xp_boost_1',
        quantity: 2,
        expiresAt: now.add(const Duration(hours: 12)),
        purchasedAt: now.subtract(const Duration(hours: 1)),
        isActive: true,
      ),
    ],
    tankStatus: 'active',
    firstFishSpeciesId: 'betta_splendens',
    dailyTipsEnabled: false,
    streakRemindersEnabled: false,
    hasSeenTutorial: true,
    morningReminderTime: '08:00',
    eveningReminderTime: '20:00',
    nightReminderTime: '22:00',
    learningStylePreference: 'deep',
    weekendActivityDates: ['2025-06-14', '2025-06-07'],
    fullHeartDates: ['2025-06-14'],
    perfectScoreCount: 4,
    createdAt: now.subtract(const Duration(days: 60)),
    updatedAt: now,
  );
}

Tank _testTank() {
  final now = DateTime.utc(2025, 6, 15, 10, 30);
  return Tank(
    id: 'tank-1',
    name: 'Community Tank',
    type: TankType.freshwater,
    volumeLitres: 200,
    lengthCm: 100,
    widthCm: 40,
    heightCm: 50,
    startDate: now.subtract(const Duration(days: 90)),
    targets: const WaterTargets(
      tempMin: 24,
      tempMax: 28,
      phMin: 6.5,
      phMax: 7.5,
      ghMin: 4,
      ghMax: 12,
      khMin: 3,
      khMax: 8,
    ),
    notes: 'Planted tank with CO2',
    imageUrl: '/photos/tank1.jpg',
    sortOrder: 2,
    isDemoTank: false,
    createdAt: now.subtract(const Duration(days: 90)),
    updatedAt: now,
  );
}

LogEntry _testLogEntry() {
  final now = DateTime.utc(2025, 6, 15, 10, 30);
  return LogEntry(
    id: 'log-1',
    tankId: 'tank-1',
    type: LogType.waterTest,
    timestamp: now,
    waterTest: WaterTestResults(
      temperature: 25.5,
      ph: 7.0,
      ammonia: 0.0,
      nitrite: 0.0,
      nitrate: 10.0,
      gh: 8.0,
      kh: 5.0,
      phosphate: 0.5,
      co2: 15.0,
    ),
    waterChangePercent: null,
    title: 'Weekly water test',
    notes: 'All parameters stable',
    photoUrls: ['/photos/test1.jpg', '/photos/test2.jpg'],
    relatedEquipmentId: 'equip-heater',
    relatedLivestockId: 'fish-betta',
    relatedTaskId: 'task-weekly-test',
    createdAt: now,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // UserProfile
  // =========================================================================
  group('UserProfile', () {
    group('round-trip serialization', () {
      test('toJson -> fromJson preserves all fields', () {
        final original = _testProfile();
        final json = original.toJson();
        final restored = UserProfile.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.experienceLevel, original.experienceLevel);
        expect(restored.primaryTankType, original.primaryTankType);
        expect(restored.goals, original.goals);
        expect(restored.totalXp, original.totalXp);
        expect(restored.currentStreak, original.currentStreak);
        expect(restored.longestStreak, original.longestStreak);
        expect(
          restored.lastActivityDate?.toIso8601String(),
          original.lastActivityDate?.toIso8601String(),
        );
        expect(restored.achievements, original.achievements);
        expect(restored.completedLessons, original.completedLessons);

        // LessonProgress map
        expect(restored.lessonProgress.keys, original.lessonProgress.keys);
        final lp = restored.lessonProgress['lesson_1']!;
        final origLp = original.lessonProgress['lesson_1']!;
        expect(lp.lessonId, origLp.lessonId);
        expect(
          lp.completedDate.toIso8601String(),
          origLp.completedDate.toIso8601String(),
        );
        expect(
          lp.lastReviewDate?.toIso8601String(),
          origLp.lastReviewDate?.toIso8601String(),
        );
        expect(lp.reviewCount, origLp.reviewCount);
        expect(lp.strength, origLp.strength);

        expect(restored.completedStories, original.completedStories);
        expect(restored.storyProgress, original.storyProgress);
        expect(
          restored.hasCompletedPlacementTest,
          original.hasCompletedPlacementTest,
        );
        expect(
          restored.hasSkippedPlacementTest,
          original.hasSkippedPlacementTest,
        );
        expect(restored.placementResultId, original.placementResultId);
        expect(
          restored.placementTestDate?.toIso8601String(),
          original.placementTestDate?.toIso8601String(),
        );
        expect(restored.dailyXpGoal, original.dailyXpGoal);
        expect(restored.dailyXpHistory, original.dailyXpHistory);
        expect(restored.hasStreakFreeze, original.hasStreakFreeze);
        expect(
          restored.streakFreezeUsedDate?.toIso8601String(),
          original.streakFreezeUsedDate?.toIso8601String(),
        );
        expect(
          restored.streakFreezeGrantedDate?.toIso8601String(),
          original.streakFreezeGrantedDate?.toIso8601String(),
        );
        expect(restored.hearts, original.hearts);
        expect(
          restored.lastHeartRefill?.toIso8601String(),
          original.lastHeartRefill?.toIso8601String(),
        );
        expect(restored.league, original.league);
        expect(restored.weeklyXP, original.weeklyXP);
        expect(
          restored.weekStartDate?.toIso8601String(),
          original.weekStartDate?.toIso8601String(),
        );

        // Inventory
        expect(restored.inventory.length, original.inventory.length);
        final inv = restored.inventory.first;
        final origInv = original.inventory.first;
        expect(inv.itemId, origInv.itemId);
        expect(inv.quantity, origInv.quantity);
        expect(
          inv.expiresAt?.toIso8601String(),
          origInv.expiresAt?.toIso8601String(),
        );
        expect(
          inv.purchasedAt.toIso8601String(),
          origInv.purchasedAt.toIso8601String(),
        );
        expect(inv.isActive, origInv.isActive);

        expect(restored.tankStatus, original.tankStatus);
        expect(restored.firstFishSpeciesId, original.firstFishSpeciesId);
        expect(restored.dailyTipsEnabled, original.dailyTipsEnabled);
        expect(restored.streakRemindersEnabled, original.streakRemindersEnabled);
        expect(restored.hasSeenTutorial, original.hasSeenTutorial);
        expect(restored.morningReminderTime, original.morningReminderTime);
        expect(restored.eveningReminderTime, original.eveningReminderTime);
        expect(restored.nightReminderTime, original.nightReminderTime);
        expect(
          restored.learningStylePreference,
          original.learningStylePreference,
        );
        expect(restored.weekendActivityDates, original.weekendActivityDates);
        expect(restored.fullHeartDates, original.fullHeartDates);
        expect(restored.perfectScoreCount, original.perfectScoreCount);
        expect(
          restored.createdAt.toIso8601String(),
          original.createdAt.toIso8601String(),
        );
        expect(
          restored.updatedAt.toIso8601String(),
          original.updatedAt.toIso8601String(),
        );
      });

      test('handles empty lists and maps', () {
        final now = DateTime.utc(2025, 1, 1);
        final profile = UserProfile(
          id: 'empty-user',
          goals: const [],
          achievements: const [],
          completedLessons: const [],
          lessonProgress: const {},
          completedStories: const [],
          storyProgress: const {},
          dailyXpHistory: const {},
          inventory: const [],
          weekendActivityDates: const [],
          fullHeartDates: const [],
          createdAt: now,
          updatedAt: now,
        );

        final restored = UserProfile.fromJson(profile.toJson());

        expect(restored.goals, isEmpty);
        expect(restored.achievements, isEmpty);
        expect(restored.completedLessons, isEmpty);
        expect(restored.lessonProgress, isEmpty);
        expect(restored.completedStories, isEmpty);
        expect(restored.storyProgress, isEmpty);
        expect(restored.dailyXpHistory, isEmpty);
        expect(restored.inventory, isEmpty);
        expect(restored.weekendActivityDates, isEmpty);
        expect(restored.fullHeartDates, isEmpty);
      });

      test('handles null optional DateTime fields', () {
        final now = DateTime.utc(2025, 1, 1);
        final profile = UserProfile(
          id: 'null-dates',
          createdAt: now,
          updatedAt: now,
        );

        final restored = UserProfile.fromJson(profile.toJson());

        expect(restored.lastActivityDate, isNull);
        expect(restored.placementTestDate, isNull);
        expect(restored.streakFreezeUsedDate, isNull);
        expect(restored.streakFreezeGrantedDate, isNull);
        expect(restored.lastHeartRefill, isNull);
        expect(restored.weekStartDate, isNull);
      });
    });

    group('copyWith', () {
      test('modifies target field, preserves others', () {
        final original = _testProfile();
        final modified = original.copyWith(totalXp: 9999, name: 'Bob');

        expect(modified.totalXp, 9999);
        expect(modified.name, 'Bob');
        // Everything else unchanged
        expect(modified.id, original.id);
        expect(modified.experienceLevel, original.experienceLevel);
        expect(modified.currentStreak, original.currentStreak);
        expect(modified.league, original.league);
        expect(modified.hearts, original.hearts);
        expect(modified.dailyTipsEnabled, original.dailyTipsEnabled);
        expect(modified.hasSeenTutorial, original.hasSeenTutorial);
        expect(modified.perfectScoreCount, original.perfectScoreCount);
        expect(modified.inventory.length, original.inventory.length);
      });

      test('can change enum fields', () {
        final original = _testProfile();
        final modified = original.copyWith(
          experienceLevel: ExperienceLevel.expert,
          primaryTankType: TankType.marine,
          league: League.diamond,
        );

        expect(modified.experienceLevel, ExperienceLevel.expert);
        expect(modified.primaryTankType, TankType.marine);
        expect(modified.league, League.diamond);
        expect(modified.id, original.id);
      });

      test('can replace list and map fields', () {
        final original = _testProfile();
        final modified = original.copyWith(
          goals: [UserGoal.relaxation],
          achievements: ['new_achievement'],
          dailyXpHistory: {'2025-07-01': 100},
        );

        expect(modified.goals, [UserGoal.relaxation]);
        expect(modified.achievements, ['new_achievement']);
        expect(modified.dailyXpHistory, {'2025-07-01': 100});
      });
    });

    group('fromJson defaults', () {
      test('provides sensible defaults for scalar-only JSON', () {
        final now = DateTime.utc(2025, 1, 1);
        // Provide empty lists/maps explicitly because fromJson uses
        // `is List?` guards that match null and then cast, causing a
        // crash when the key is truly absent. A realistic minimal JSON
        // always includes these keys (they come from toJson output).
        final minimalJson = <String, dynamic>{
          'id': 'min-user',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
          // Empty collections to avoid the `null as List` cast issue
          'goals': <String>[],
          'achievements': <String>[],
          'completedLessons': <String>[],
          'lessonProgress': <String, dynamic>{},
          'completedStories': <String>[],
          'storyProgress': <String, dynamic>{},
          'dailyXpHistory': <String, dynamic>{},
          'inventory': <Map<String, dynamic>>[],
          'weekendActivityDates': <String>[],
          'fullHeartDates': <String>[],
        };

        final profile = UserProfile.fromJson(minimalJson);

        expect(profile.id, 'min-user');
        expect(profile.name, isNull);
        expect(profile.experienceLevel, ExperienceLevel.beginner);
        expect(profile.primaryTankType, TankType.freshwater);
        expect(profile.goals, isEmpty);
        expect(profile.totalXp, 0);
        expect(profile.currentStreak, 0);
        expect(profile.longestStreak, 0);
        expect(profile.lastActivityDate, isNull);
        expect(profile.achievements, isEmpty);
        expect(profile.completedLessons, isEmpty);
        expect(profile.lessonProgress, isEmpty);
        expect(profile.completedStories, isEmpty);
        expect(profile.storyProgress, isEmpty);
        expect(profile.hasCompletedPlacementTest, false);
        expect(profile.hasSkippedPlacementTest, false);
        expect(profile.placementResultId, isNull);
        expect(profile.placementTestDate, isNull);
        expect(profile.dailyXpGoal, 50);
        expect(profile.dailyXpHistory, isEmpty);
        expect(profile.hasStreakFreeze, true);
        expect(profile.hearts, 5);
        expect(profile.league, League.bronze);
        expect(profile.weeklyXP, 0);
        expect(profile.inventory, isEmpty);
        expect(profile.tankStatus, isNull);
        expect(profile.firstFishSpeciesId, isNull);
        expect(profile.dailyTipsEnabled, true);
        expect(profile.streakRemindersEnabled, true);
        expect(profile.hasSeenTutorial, false);
        expect(profile.morningReminderTime, '09:00');
        expect(profile.eveningReminderTime, '19:00');
        expect(profile.nightReminderTime, '23:00');
        expect(profile.learningStylePreference, isNull);
        expect(profile.weekendActivityDates, isEmpty);
        expect(profile.fullHeartDates, isEmpty);
        expect(profile.perfectScoreCount, 0);
      });

      test('fromJson crashes on truly missing list keys (known limitation)', () {
        // Documents that fromJson uses `is List?` which matches null,
        // then casts with `as List` -- so absent keys throw a TypeError.
        // This is a known defect; if fixed, flip this to expect no throw.
        expect(
          () => UserProfile.fromJson(<String, dynamic>{'id': 'x'}),
          throwsA(isA<TypeError>()),
        );
      });
    });
  });

  // =========================================================================
  // Tank
  // =========================================================================
  group('Tank', () {
    group('round-trip serialization', () {
      test('toJson -> fromJson preserves all fields', () {
        final original = _testTank();
        final json = original.toJson();
        final restored = Tank.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.type, original.type);
        expect(restored.volumeLitres, original.volumeLitres);
        expect(restored.lengthCm, original.lengthCm);
        expect(restored.widthCm, original.widthCm);
        expect(restored.heightCm, original.heightCm);
        expect(
          restored.startDate.toIso8601String(),
          original.startDate.toIso8601String(),
        );
        // WaterTargets
        expect(restored.targets.tempMin, original.targets.tempMin);
        expect(restored.targets.tempMax, original.targets.tempMax);
        expect(restored.targets.phMin, original.targets.phMin);
        expect(restored.targets.phMax, original.targets.phMax);
        expect(restored.targets.ghMin, original.targets.ghMin);
        expect(restored.targets.ghMax, original.targets.ghMax);
        expect(restored.targets.khMin, original.targets.khMin);
        expect(restored.targets.khMax, original.targets.khMax);

        expect(restored.notes, original.notes);
        expect(restored.imageUrl, original.imageUrl);
        expect(restored.sortOrder, original.sortOrder);
        expect(restored.isDemoTank, original.isDemoTank);
        expect(
          restored.createdAt.toIso8601String(),
          original.createdAt.toIso8601String(),
        );
        expect(
          restored.updatedAt.toIso8601String(),
          original.updatedAt.toIso8601String(),
        );
      });

      test('handles null optional dimension fields', () {
        final now = DateTime.utc(2025, 1, 1);
        final tank = Tank(
          id: 'tank-no-dims',
          name: 'Nano',
          type: TankType.freshwater,
          volumeLitres: 30,
          startDate: now,
          targets: const WaterTargets(),
          createdAt: now,
          updatedAt: now,
        );

        final restored = Tank.fromJson(tank.toJson());

        expect(restored.lengthCm, isNull);
        expect(restored.widthCm, isNull);
        expect(restored.heightCm, isNull);
        expect(restored.notes, isNull);
        expect(restored.imageUrl, isNull);
      });

      test('handles null WaterTargets fields', () {
        final now = DateTime.utc(2025, 1, 1);
        final tank = Tank(
          id: 'tank-empty-targets',
          name: 'Bare Tank',
          type: TankType.freshwater,
          volumeLitres: 50,
          startDate: now,
          targets: const WaterTargets(),
          createdAt: now,
          updatedAt: now,
        );

        final json = tank.toJson();
        final restored = Tank.fromJson(json);

        expect(restored.targets.tempMin, isNull);
        expect(restored.targets.tempMax, isNull);
        expect(restored.targets.phMin, isNull);
        expect(restored.targets.phMax, isNull);
        expect(restored.targets.ghMin, isNull);
        expect(restored.targets.ghMax, isNull);
        expect(restored.targets.khMin, isNull);
        expect(restored.targets.khMax, isNull);
      });
    });

    group('copyWith', () {
      test('modifies target field, preserves others', () {
        final original = _testTank();
        final modified = original.copyWith(
          name: 'Shrimp Tank',
          volumeLitres: 60,
        );

        expect(modified.name, 'Shrimp Tank');
        expect(modified.volumeLitres, 60);
        expect(modified.id, original.id);
        expect(modified.type, original.type);
        expect(modified.lengthCm, original.lengthCm);
        expect(modified.targets.tempMin, original.targets.tempMin);
        expect(modified.sortOrder, original.sortOrder);
        expect(modified.isDemoTank, original.isDemoTank);
        expect(modified.notes, original.notes);
      });

      test('can replace WaterTargets', () {
        final original = _testTank();
        const newTargets = WaterTargets(
          tempMin: 20,
          tempMax: 24,
          phMin: 7.0,
          phMax: 8.0,
        );
        final modified = original.copyWith(targets: newTargets);

        expect(modified.targets.tempMin, 20);
        expect(modified.targets.tempMax, 24);
        expect(modified.targets.phMin, 7.0);
        expect(modified.targets.phMax, 8.0);
        expect(modified.targets.ghMin, isNull);
        expect(modified.name, original.name);
      });

      test('can toggle isDemoTank', () {
        final original = _testTank();
        final modified = original.copyWith(isDemoTank: true);

        expect(modified.isDemoTank, true);
        expect(modified.id, original.id);
      });
    });

    group('fromJson defaults', () {
      test('provides sensible defaults for minimal JSON', () {
        final minimalJson = <String, dynamic>{
          'id': 'tank-min',
        };

        final tank = Tank.fromJson(minimalJson);

        expect(tank.id, 'tank-min');
        expect(tank.name, 'Unnamed Tank');
        expect(tank.type, TankType.freshwater);
        expect(tank.volumeLitres, 0);
        expect(tank.lengthCm, isNull);
        expect(tank.widthCm, isNull);
        expect(tank.heightCm, isNull);
        expect(tank.notes, isNull);
        expect(tank.imageUrl, isNull);
        expect(tank.sortOrder, 0);
        expect(tank.isDemoTank, false);
      });

      test('uses freshwaterTropical targets when targets key is missing', () {
        final tank = Tank.fromJson(<String, dynamic>{
          'id': 'tank-no-targets',
          'startDate': '2025-01-01T00:00:00.000Z',
        });

        // Should match WaterTargets.freshwaterTropical() defaults
        expect(tank.targets.tempMin, 24);
        expect(tank.targets.tempMax, 28);
        expect(tank.targets.phMin, 6.5);
        expect(tank.targets.phMax, 7.5);
      });

      test('falls back to default id when id is missing', () {
        final tank = Tank.fromJson(<String, dynamic>{});

        expect(tank.id, '');
      });
    });
  });

  // =========================================================================
  // LogEntry
  // =========================================================================
  group('LogEntry', () {
    group('round-trip serialization', () {
      test('toJson -> fromJson preserves all fields', () {
        final original = _testLogEntry();
        final json = original.toJson();
        final restored = LogEntry.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.tankId, original.tankId);
        expect(restored.type, original.type);
        expect(
          restored.timestamp.toIso8601String(),
          original.timestamp.toIso8601String(),
        );

        // WaterTestResults
        expect(restored.waterTest, isNotNull);
        expect(restored.waterTest!.temperature, original.waterTest!.temperature);
        expect(restored.waterTest!.ph, original.waterTest!.ph);
        expect(restored.waterTest!.ammonia, original.waterTest!.ammonia);
        expect(restored.waterTest!.nitrite, original.waterTest!.nitrite);
        expect(restored.waterTest!.nitrate, original.waterTest!.nitrate);
        expect(restored.waterTest!.gh, original.waterTest!.gh);
        expect(restored.waterTest!.kh, original.waterTest!.kh);
        expect(restored.waterTest!.phosphate, original.waterTest!.phosphate);
        expect(restored.waterTest!.co2, original.waterTest!.co2);

        expect(restored.waterChangePercent, original.waterChangePercent);
        expect(restored.title, original.title);
        expect(restored.notes, original.notes);
        expect(restored.photoUrls, original.photoUrls);
        expect(restored.relatedEquipmentId, original.relatedEquipmentId);
        expect(restored.relatedLivestockId, original.relatedLivestockId);
        expect(restored.relatedTaskId, original.relatedTaskId);
        expect(
          restored.createdAt.toIso8601String(),
          original.createdAt.toIso8601String(),
        );
      });

      test('handles null waterTest', () {
        final now = DateTime.utc(2025, 6, 15);
        final entry = LogEntry(
          id: 'log-wc',
          tankId: 'tank-1',
          type: LogType.waterChange,
          timestamp: now,
          waterChangePercent: 25,
          createdAt: now,
        );

        final restored = LogEntry.fromJson(entry.toJson());

        expect(restored.waterTest, isNull);
        expect(restored.waterChangePercent, 25);
        expect(restored.type, LogType.waterChange);
      });

      test('handles null optional string fields', () {
        final now = DateTime.utc(2025, 6, 15);
        final entry = LogEntry(
          id: 'log-bare',
          tankId: 'tank-1',
          type: LogType.observation,
          timestamp: now,
          createdAt: now,
        );

        final restored = LogEntry.fromJson(entry.toJson());

        expect(restored.title, isNull);
        expect(restored.notes, isNull);
        expect(restored.photoUrls, isNull);
        expect(restored.relatedEquipmentId, isNull);
        expect(restored.relatedLivestockId, isNull);
        expect(restored.relatedTaskId, isNull);
        expect(restored.waterChangePercent, isNull);
      });

      test('handles empty photoUrls list', () {
        final now = DateTime.utc(2025, 6, 15);
        final entry = LogEntry(
          id: 'log-empty-photos',
          tankId: 'tank-1',
          type: LogType.feeding,
          timestamp: now,
          photoUrls: const [],
          createdAt: now,
        );

        final restored = LogEntry.fromJson(entry.toJson());

        expect(restored.photoUrls, isEmpty);
      });

      test('round-trips every LogType', () {
        final now = DateTime.utc(2025, 6, 15);
        for (final logType in LogType.values) {
          final entry = LogEntry(
            id: 'log-${logType.name}',
            tankId: 'tank-1',
            type: logType,
            timestamp: now,
            createdAt: now,
          );

          final restored = LogEntry.fromJson(entry.toJson());
          expect(restored.type, logType, reason: '${logType.name} not preserved');
        }
      });
    });

    group('copyWith', () {
      test('modifies target field, preserves others', () {
        final original = _testLogEntry();
        final modified = original.copyWith(
          title: 'Updated title',
          notes: 'Updated notes',
        );

        expect(modified.title, 'Updated title');
        expect(modified.notes, 'Updated notes');
        expect(modified.id, original.id);
        expect(modified.tankId, original.tankId);
        expect(modified.type, original.type);
        expect(modified.waterTest!.ph, original.waterTest!.ph);
        expect(modified.photoUrls, original.photoUrls);
        expect(modified.relatedTaskId, original.relatedTaskId);
      });

      test('can change type and associated data', () {
        final original = _testLogEntry();
        final modified = original.copyWith(
          type: LogType.waterChange,
          waterChangePercent: 30,
        );

        expect(modified.type, LogType.waterChange);
        expect(modified.waterChangePercent, 30);
        expect(modified.id, original.id);
      });

      test('can replace waterTest', () {
        final original = _testLogEntry();
        final newTest = WaterTestResults(ph: 6.5, ammonia: 0.25);
        final modified = original.copyWith(waterTest: newTest);

        expect(modified.waterTest!.ph, 6.5);
        expect(modified.waterTest!.ammonia, 0.25);
        expect(modified.waterTest!.temperature, isNull);
        expect(modified.id, original.id);
      });
    });

    group('fromJson defaults', () {
      test('falls back to observation when type is unrecognized', () {
        final json = <String, dynamic>{
          'id': 'log-unknown',
          'tankId': 'tank-1',
          'type': 'nonExistentType',
          'timestamp': '2025-06-15T10:30:00.000Z',
          'createdAt': '2025-06-15T10:30:00.000Z',
        };

        final entry = LogEntry.fromJson(json);

        expect(entry.type, LogType.observation);
      });
    });
  });

  // =========================================================================
  // WaterTestResults (standalone)
  // =========================================================================
  group('WaterTestResults', () {
    group('round-trip serialization', () {
      test('toJson -> fromJson preserves all fields', () {
        final original = WaterTestResults(
          temperature: 26.0,
          ph: 7.2,
          ammonia: 0.0,
          nitrite: 0.0,
          nitrate: 15.0,
          gh: 6.0,
          kh: 4.0,
          phosphate: 1.0,
          co2: 20.0,
        );

        final restored = WaterTestResults.fromJson(original.toJson());

        expect(restored.temperature, original.temperature);
        expect(restored.ph, original.ph);
        expect(restored.ammonia, original.ammonia);
        expect(restored.nitrite, original.nitrite);
        expect(restored.nitrate, original.nitrate);
        expect(restored.gh, original.gh);
        expect(restored.kh, original.kh);
        expect(restored.phosphate, original.phosphate);
        expect(restored.co2, original.co2);
      });

      test('handles all-null values', () {
        final results = WaterTestResults();
        final restored = WaterTestResults.fromJson(results.toJson());

        expect(restored.temperature, isNull);
        expect(restored.ph, isNull);
        expect(restored.ammonia, isNull);
        expect(restored.nitrite, isNull);
        expect(restored.nitrate, isNull);
        expect(restored.gh, isNull);
        expect(restored.kh, isNull);
        expect(restored.phosphate, isNull);
        expect(restored.co2, isNull);
        expect(restored.hasValues, false);
      });
    });

    group('copyWith', () {
      test('modifies target field, preserves others', () {
        final original = WaterTestResults(
          temperature: 25.0,
          ph: 7.0,
          ammonia: 0.0,
        );
        final modified = original.copyWith(ph: 6.8);

        expect(modified.ph, 6.8);
        expect(modified.temperature, 25.0);
        expect(modified.ammonia, 0.0);
      });
    });
  });

  // =========================================================================
  // WaterTargets (standalone)
  // =========================================================================
  group('WaterTargets', () {
    group('copyWith', () {
      test('modifies target field, preserves others', () {
        const original = WaterTargets(
          tempMin: 24,
          tempMax: 28,
          phMin: 6.5,
          phMax: 7.5,
        );
        final modified = original.copyWith(tempMin: 22);

        expect(modified.tempMin, 22);
        expect(modified.tempMax, 28);
        expect(modified.phMin, 6.5);
        expect(modified.phMax, 7.5);
      });
    });
  });
}
