// Widget tests for SmartScreen.
//
// Run: flutter test test/widget_tests/smart_screen_test.dart

import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/smart_screen.dart';
import 'package:danio/screens/emergency_guide_screen.dart';
import 'package:danio/screens/workshop_screen.dart';
import 'package:danio/features/smart/smart_providers.dart';
import 'package:danio/models/models.dart';
import 'package:danio/services/openai_service.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/utils/navigation_throttle.dart';
import 'package:danio/theme/app_theme.dart';
import 'package:danio/widgets/offline_indicator.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _tabletSurface = Size(2000, 1200);
const _maxReadableSmartWidth = 720.0;

Widget _wrap({
  bool isOnline = true,
  bool aiConfigured = false,
  StorageService? storage,
}) {
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(
        storage ?? _SmartTestStorageService(),
      ),
      openAIServiceProvider.overrideWithValue(
        OpenAIService(directApiKey: aiConfigured ? 'sk-test' : ''),
      ),
      openAIConfiguredProvider.overrideWith((ref) async => aiConfigured),
      isOnlineProvider.overrideWithValue(isOnline),
      aiHistoryProvider.overrideWith((ref) => AIHistoryNotifier(ref)),
      anomalyHistoryProvider.overrideWith((ref) => AnomalyHistoryNotifier(ref)),
      // apiRateLimiterProvider is built by the framework — not overridden here
    ],
    child: const MaterialApp(home: SmartScreen()),
  );
}

Map<String, dynamic> _profileJson({String? regionCode, String? tankStatus}) {
  final now = DateTime.now().toIso8601String();
  return {
    'id': 'smart-test-user',
    'experienceLevel': 'beginner',
    'primaryTankType': 'freshwater',
    'regionCode': regionCode,
    'goals': ['keepFishAlive'],
    'tankStatus': tankStatus,
    'totalXp': 0,
    'currentStreak': 0,
    'longestStreak': 0,
    'completedLessons': <String>[],
    'achievements': <String>[],
    'lessonProgress': <String, dynamic>{},
    'completedStories': <String>[],
    'storyProgress': <String, dynamic>{},
    'hasCompletedPlacementTest': false,
    'hasSkippedPlacementTest': false,
    'dailyXpGoal': 50,
    'dailyXpHistory': <String, int>{},
    'hasStreakFreeze': false,
    'hearts': 5,
    'league': 'bronze',
    'weeklyXP': 0,
    'inventory': <dynamic>[],
    'dailyTipsEnabled': true,
    'streakRemindersEnabled': true,
    'hasSeenTutorial': false,
    'weekendActivityDates': <String>[],
    'fullHeartDates': <String>[],
    'perfectScoreCount': 0,
    'createdAt': now,
    'updatedAt': now,
  };
}

class _SmartTestStorageService implements StorageService {
  final Map<String, Tank> _tanks = {};
  final Map<String, Livestock> _livestock = {};
  final Map<String, Equipment> _equipment = {};
  final Map<String, LogEntry> _logs = {};
  final Map<String, Task> _tasks = {};

  @override
  Future<List<Tank>> getAllTanks() async => _tanks.values.toList();

  @override
  Future<Tank?> getTank(String id) async => _tanks[id];

  @override
  Future<void> saveTank(Tank tank) async {
    _tanks[tank.id] = tank;
  }

  @override
  Future<void> saveTanks(List<Tank> tanks) async {
    for (final tank in tanks) {
      _tanks[tank.id] = tank;
    }
  }

  @override
  Future<void> deleteTank(String id) async {
    _tanks.remove(id);
    _livestock.removeWhere((_, value) => value.tankId == id);
    _equipment.removeWhere((_, value) => value.tankId == id);
    _logs.removeWhere((_, value) => value.tankId == id);
    _tasks.removeWhere((_, value) => value.tankId == id);
  }

  @override
  Future<void> deleteAllTanks(List<String> ids) async {
    final idSet = ids.toSet();
    _tanks.removeWhere((id, _) => idSet.contains(id));
    _livestock.removeWhere((_, value) => idSet.contains(value.tankId));
    _equipment.removeWhere((_, value) => idSet.contains(value.tankId));
    _logs.removeWhere((_, value) => idSet.contains(value.tankId));
    _tasks.removeWhere((_, value) => idSet.contains(value.tankId));
  }

  @override
  Future<List<Livestock>> getLivestockForTank(String tankId) async {
    return _livestock.values.where((entry) => entry.tankId == tankId).toList();
  }

  @override
  Future<void> saveLivestock(Livestock livestock) async {
    _livestock[livestock.id] = livestock;
  }

  @override
  Future<void> deleteLivestock(String id) async {
    _livestock.remove(id);
  }

  @override
  Future<List<Equipment>> getEquipmentForTank(String tankId) async {
    return _equipment.values.where((entry) => entry.tankId == tankId).toList();
  }

  @override
  Future<void> saveEquipment(Equipment equipment) async {
    _equipment[equipment.id] = equipment;
  }

  @override
  Future<void> deleteEquipment(String id) async {
    _equipment.remove(id);
  }

  @override
  Future<List<LogEntry>> getLogsForTank(
    String tankId, {
    int? limit,
    DateTime? after,
  }) async {
    final logs =
        _logs.values
            .where((log) => log.tankId == tankId)
            .where((log) => after == null || log.timestamp.isAfter(after))
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return limit == null ? logs : logs.take(limit).toList();
  }

  @override
  Future<LogEntry?> getLatestWaterTest(String tankId) async {
    final tests = await getLogsForTank(tankId);
    return tests
        .where((log) => log.type == LogType.waterTest && log.waterTest != null)
        .firstOrNull;
  }

  @override
  Future<void> saveLog(LogEntry log) async {
    _logs[log.id] = log;
  }

  @override
  Future<void> deleteLog(String id) async {
    _logs.remove(id);
  }

  @override
  Future<List<Task>> getTasksForTank(String? tankId) async {
    return _tasks.values
        .where((task) => tankId == null || task.tankId == tankId)
        .toList();
  }

  @override
  Future<void> saveTask(Task task) async {
    _tasks[task.id] = task;
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.remove(id);
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  test('SmartScreen source keeps user-facing punctuation ASCII-safe', () {
    final source = File('lib/screens/smart_screen.dart').readAsStringSync();

    final punctuation = {
      'em dash': String.fromCharCode(0x2014),
      'middle dot': String.fromCharCode(0x00b7),
    };

    for (final entry in punctuation.entries) {
      expect(source, isNot(contains(entry.value)), reason: entry.key);
    }
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    NavigationThrottle.reset();
  });

  group('SmartScreen — renders', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(SmartScreen), findsOneWidget);
    });

    testWidgets('shows Smart app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Smart'), findsOneWidget);
    });

    testWidgets('shows feature cards when API not configured', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.textContaining('coming soon'), findsNothing);
      expect(
        find.text('Optional AI setup in Preferences', skipOffstage: false),
        findsNWidgets(3),
      );

      // When not configured, feature cards are rendered but may be offstage
      // (below the viewport fold in the SliverList). Use skipOffstage: false.
      expect(find.text('Fish & Plant ID', skipOffstage: false), findsOneWidget);
      expect(find.text('Symptom Checker', skipOffstage: false), findsOneWidget);
      expect(
        find.text('Weekly Care Plan', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('shows AI feature section cards', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      // Weekly Care Plan card should be present (may be offstage in SliverList)
      expect(
        find.text('Weekly Care Plan', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('opens Emergency Guide from the local Smart actions', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Emergency Guide', skipOffstage: false), findsOneWidget);
      expect(
        find.text(
          'Fast steps for urgent water and fish issues',
          skipOffstage: false,
        ),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(
        find.text('Emergency Guide'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Emergency Guide'));
      await tester.pumpAndSettle();

      expect(find.byType(EmergencyGuideScreen), findsOneWidget);
    });

    testWidgets('shows local aquarium intelligence without optional AI', (
      tester,
    ) async {
      final storage = _SmartTestStorageService();
      final now = DateTime(2026, 6, 13, 12);
      const tankId = 'smart-local-intelligence-tank';
      await storage.saveTank(_makeTank(id: tankId, now: now));
      await storage.saveLog(
        _waterTestLog(
          tankId: tankId,
          timestamp: now.subtract(const Duration(hours: 1)),
          ammonia: 0.5,
          nitrite: 0,
        ),
      );

      await tester.pumpWidget(_wrap(storage: storage));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Aquarium Intelligence'), findsOneWidget);
      expect(find.text('Local checks, no AI key needed'), findsOneWidget);
      expect(find.text('Unsafe water detected'), findsOneWidget);
      expect(find.textContaining('Ammonia 0.50 ppm'), findsOneWidget);
      expect(find.text('Emergency Guide', skipOffstage: false), findsWidgets);
    });

    testWidgets('keeps primary Smart surfaces readable on tablet', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(_tabletSurface);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);

      final intelligenceCard = find
          .ancestor(
            of: find.text('Aquarium Intelligence'),
            matching: find.byType(Card),
          )
          .first;
      final emergencyCard = find
          .ancestor(
            of: find.text('Emergency Guide'),
            matching: find.byType(Card),
          )
          .first;

      expect(intelligenceCard, findsOneWidget);
      expect(emergencyCard, findsOneWidget);
      expect(
        tester.getSize(intelligenceCard).width,
        lessThanOrEqualTo(_maxReadableSmartWidth),
      );
      expect(
        tester.getSize(emergencyCard).width,
        lessThanOrEqualTo(_maxReadableSmartWidth),
      );
    });

    testWidgets('opens full local Aquarium Intelligence review', (
      tester,
    ) async {
      final storage = _SmartTestStorageService();
      final now = DateTime(2026, 6, 13, 12);
      const tankId = 'smart-local-intelligence-detail-tank';
      await storage.saveTank(_makeTank(id: tankId, now: now));
      await storage.saveLog(
        _waterTestLog(
          tankId: tankId,
          timestamp: now.subtract(const Duration(hours: 1)),
          ammonia: 0.5,
          nitrite: 0,
        ),
      );

      await tester.pumpWidget(_wrap(storage: storage));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Review Intelligence'), findsOneWidget);
      await tester.tap(find.text('Review Intelligence'));
      await tester.pumpAndSettle();

      expect(find.text('Aquarium Intelligence'), findsOneWidget);
      expect(find.text('Local care plan'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('What Danio checked'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('What Danio checked'), findsOneWidget);
      expect(find.text('Unsafe water detected'), findsOneWidget);
      expect(find.textContaining('Ammonia 0.50 ppm'), findsOneWidget);
    });

    testWidgets('shows AI-only controls when Smart features are configured', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(aiConfigured: true));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.scrollUntilVisible(
        find.text('Ask Danio'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Ask Danio', skipOffstage: false), findsOneWidget);
      expect(
        find.text('Snap a photo to identify species', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('shows setup-context nudge when profile context is missing', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(_profileJson()),
      });

      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Complete setup details'), findsOneWidget);
      expect(
        find.text(
          'Add your region and tank stage so Smart can tune risks, reminders, and care plans.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('setup-context nudge uses readable text on light card', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(_profileJson()),
      });

      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final title = tester.widget<Text>(
        find.text('Complete setup details'),
      );
      final body = tester.widget<Text>(
        find.text(
          'Add your region and tank stage so Smart can tune risks, reminders, and care plans.',
        ),
      );

      final titleColor = title.style?.color;
      final bodyColor = body.style?.color;
      expect(titleColor, AppColors.textPrimary);
      expect(bodyColor, AppColors.textSecondary);
      expect(_contrastRatio(titleColor!, AppColors.surface), greaterThan(4.5));
      expect(_contrastRatio(bodyColor!, AppColors.surface), greaterThan(4.5));
    });

    testWidgets('hides setup-context nudge when profile context is complete', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(
          _profileJson(regionCode: 'gb_ie', tankStatus: 'active'),
        ),
      });

      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Complete setup details'), findsNothing);
    });

    testWidgets('locked AI cards open Smart setup guidance', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.scrollUntilVisible(
        find.text('Fish & Plant ID'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Fish & Plant ID'));
      await tester.pumpAndSettle();

      expect(find.text('Optional AI tools'), findsWidgets);
      expect(
        find.text(
          'Local Smart Hub checks are ready now. Add optional AI for photo ID, symptom triage, and weekly care planning.',
        ),
        findsOneWidget,
      );
      expect(find.text('Open Preferences'), findsWidgets);
    });

    testWidgets('locked AI cards expose setup action to semantics', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(_wrap());
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        await tester.scrollUntilVisible(
          find.text('Fish & Plant ID'),
          500,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pump(const Duration(seconds: 1));

        final cardSemantics = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              (widget.properties.label?.contains('Fish & Plant ID') ?? false),
        );
        expect(cardSemantics, findsOneWidget);

        final widget = tester.widget<Semantics>(cardSemantics);
        expect(widget.properties.label, contains('Fish & Plant ID'));
        expect(widget.properties.label, contains('Optional AI setup required'));
        expect(widget.properties.label, contains('Open Preferences'));
        expect(widget.properties.button, isTrue);
        expect(widget.properties.enabled, isTrue);
        final node = tester.getSemantics(cardSemantics);
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('tap-to-dismiss background is hidden from semantics', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final backgroundTapLayer = find.ancestor(
        of: find.byType(Scaffold),
        matching: find.byType(GestureDetector),
      );
      expect(backgroundTapLayer, findsOneWidget);

      final detector = tester.widget<GestureDetector>(backgroundTapLayer);
      expect(detector.excludeFromSemantics, isTrue);
    });

    testWidgets(
      'offline compatibility entry points to Workshop instead of duplicating the checker',
      (tester) async {
        await tester.pumpWidget(_wrap());
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        await tester.scrollUntilVisible(
          find.text('Workshop Compatibility Checker'),
          500,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pump(const Duration(seconds: 1));

        expect(
          find.text('Workshop Compatibility Checker', skipOffstage: false),
          findsOneWidget,
        );
        expect(
          find.text(
            'Check fish matches with local species data',
            skipOffstage: false,
          ),
          findsOneWidget,
        );

        await tester.tap(find.text('Workshop Compatibility Checker'));
        await tester.pumpAndSettle();

        expect(find.byType(WorkshopScreen), findsOneWidget);
      },
    );

    testWidgets('configured Smart labels AI compatibility as advice', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(aiConfigured: true));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(
        find.text('Compatibility Checker', skipOffstage: false),
        findsNothing,
      );
      expect(
        find.text('AI Compatibility Advice', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('Ask Danio empty submit gives inline feedback', (tester) async {
      await tester.pumpWidget(_wrap(aiConfigured: true));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.scrollUntilVisible(
        find.text('Ask Danio'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.byTooltip('Send question'));
      await tester.pump();

      expect(find.text('Ask a fishkeeping question first.'), findsOneWidget);
    });
  });
}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

Tank _makeTank({required String id, required DateTime now}) {
  return Tank(
    id: id,
    name: 'River Room',
    type: TankType.freshwater,
    volumeLitres: 100,
    startDate: now.subtract(const Duration(days: 60)),
    targets: WaterTargets.freshwaterTropical(),
    createdAt: now,
    updatedAt: now,
  );
}

LogEntry _waterTestLog({
  required String tankId,
  required DateTime timestamp,
  double? ammonia,
  double? nitrite,
}) {
  return LogEntry(
    id: 'log-$tankId-${timestamp.millisecondsSinceEpoch}',
    tankId: tankId,
    type: LogType.waterTest,
    timestamp: timestamp,
    waterTest: WaterTestResults(ammonia: ammonia, nitrite: nitrite),
    createdAt: timestamp,
  );
}
