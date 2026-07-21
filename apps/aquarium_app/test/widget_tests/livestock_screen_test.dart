// Widget tests for LivestockScreen.
//
// Run: flutter test test/widget_tests/livestock_screen_test.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/livestock/livestock_screen.dart';
import 'package:danio/screens/livestock/livestock_bulk_add_dialog.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/providers/tank_visual_event_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/models/models.dart';
import 'package:danio/widgets/core/app_button.dart';
import 'package:danio/widgets/core/app_card.dart';
import 'package:danio/widgets/xp_award_animation.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _fakeTankId = 'tank-001';
final _now = DateTime(2026, 6, 14, 12);

Tank _makeTank({required String id, required String name}) => Tank(
  id: id,
  name: name,
  type: TankType.freshwater,
  volumeLitres: 100,
  startDate: _now,
  targets: WaterTargets.freshwaterTropical(),
  createdAt: _now,
  updatedAt: _now,
);

Livestock _makeLivestock({
  required String id,
  required String tankId,
  required String name,
  int count = 1,
}) => Livestock(
  id: id,
  tankId: tankId,
  commonName: name,
  count: count,
  dateAdded: _now,
  createdAt: _now,
  updatedAt: _now,
);

UserProfile _makeProfile() => UserProfile(
  id: 'livestock-profile',
  experienceLevel: ExperienceLevel.beginner,
  primaryTankType: TankType.freshwater,
  goals: const [UserGoal.keepFishAlive],
  hasStreakFreeze: false,
  createdAt: _now,
  updatedAt: _now,
);

class _ThrowingSetStringPrefs implements SharedPreferences {
  _ThrowingSetStringPrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key, Object value) _shouldFail;

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  int? getInt(String key) => _delegate.getInt(key);

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  double? getDouble(String key) => _delegate.getDouble(key);

  @override
  List<String>? getStringList(String key) => _delegate.getStringList(key);

  @override
  Object? get(String key) => _delegate.get(key);

  @override
  bool containsKey(String key) => _delegate.containsKey(key);

  @override
  Set<String> getKeys() => _delegate.getKeys();

  @override
  Future<bool> setString(String key, String value) {
    if (_shouldFail(key, value)) {
      throw StateError('Simulated SharedPreferences write failure for $key');
    }
    return _delegate.setString(key, value);
  }

  @override
  Future<bool> setBool(String key, bool value) => _delegate.setBool(key, value);

  @override
  Future<bool> setDouble(String key, double value) =>
      _delegate.setDouble(key, value);

  @override
  Future<bool> setInt(String key, int value) => _delegate.setInt(key, value);

  @override
  Future<bool> setStringList(String key, List<String> value) =>
      _delegate.setStringList(key, value);

  @override
  Future<bool> remove(String key) => _delegate.remove(key);

  @override
  Future<bool> clear() => _delegate.clear();

  @override
  Future<void> reload() => _delegate.reload();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _wrap({AsyncValue<List<Livestock>>? livestockOverride}) {
  // Use in-memory storage so no real SQLite I/O occurs in tests.
  final memStorage = InMemoryStorageService();
  final overrides = <Override>[
    storageServiceProvider.overrideWithValue(memStorage),
    livestockProvider.overrideWith(
      (ref, tankId) async => livestockOverride?.valueOrNull ?? [],
    ),
    tankProvider.overrideWith(
      (ref, tankId) async => Tank(
        id: tankId,
        name: 'My Tank',
        type: TankType.freshwater,
        volumeLitres: 100,
        startDate: DateTime(2024),
        targets: const WaterTargets(),
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      ),
    ),
  ];

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: LivestockScreen(tankId: _fakeTankId)),
  );
}

Widget _wrapWithLoadingLivestock() {
  final loadingLivestock = Completer<List<Livestock>>();
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(InMemoryStorageService()),
      tankProvider.overrideWith(
        (ref, tankId) async => _makeTank(id: tankId, name: 'My Tank'),
      ),
      livestockProvider.overrideWith((ref, tankId) => loadingLivestock.future),
    ],
    child: MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const LivestockScreen(tankId: _fakeTankId),
              ),
            );
          },
          child: const Text('Open livestock'),
        ),
      ),
    ),
  );
}

Widget _wrapWithStorage({
  required StorageService storage,
  required String tankId,
  bool disableAnimations = false,
  SharedPreferences? prefs,
  bool showProfileProbe = false,
}) {
  final screen = LivestockScreen(tankId: tankId);
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(storage),
      if (prefs != null)
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
    ],
    child: MaterialApp(
      home: Stack(
        children: [
          disableAnimations
              ? Builder(
                  builder: (context) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(disableAnimations: true),
                    child: screen,
                  ),
                )
              : screen,
          if (showProfileProbe)
            Positioned(
              left: 0,
              top: 0,
              child: Consumer(
                builder: (context, ref, _) {
                  final profile = ref.watch(userProfileProvider).valueOrNull;
                  return Text(
                    profile == null ? 'profile loading' : 'profile ready',
                  );
                },
              ),
            ),
        ],
      ),
    ),
  );
}

Widget _wrapWithPulseProbe({
  required StorageService storage,
  required String tankId,
  bool showProfileProbe = false,
}) {
  return ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
    child: MaterialApp(
      home: Stack(
        children: [
          LivestockScreen(tankId: tankId),
          Positioned(
            left: 0,
            top: 0,
            child: Consumer(
              builder: (context, ref, _) =>
                  Text('pulse ${ref.watch(tankFeedingPulseProvider(tankId))}'),
            ),
          ),
          if (showProfileProbe)
            Positioned(
              left: 0,
              top: 24,
              child: Consumer(
                builder: (context, ref, _) {
                  final profile = ref.watch(userProfileProvider).valueOrNull;
                  return Text(
                    profile == null ? 'profile loading' : 'profile ready',
                  );
                },
              ),
            ),
        ],
      ),
    ),
  );
}

Widget _wrapWithTimelineProbe({
  required StorageService storage,
  required String tankId,
}) {
  return ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
    child: MaterialApp(
      home: Stack(
        children: [
          LivestockScreen(tankId: tankId),
          Positioned(
            left: 0,
            top: 0,
            child: Consumer(
              builder: (context, ref, _) {
                final feedingCount = ref
                    .watch(allLogsProvider(tankId))
                    .maybeWhen(
                      data: (logs) => logs
                          .where((log) => log.type == LogType.feeding)
                          .length,
                      orElse: () => -1,
                    );
                return Text('timeline feedings $feedingCount');
              },
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _wrapBulkAddDialog({
  required StorageService storage,
  required String tankId,
}) {
  return ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
    child: MaterialApp(
      home: Scaffold(body: LivestockBulkAddDialog(tankId: tankId)),
    ),
  );
}

class _FailingLivestockDeleteStorage implements StorageService {
  _FailingLivestockDeleteStorage({required this.failingLivestockId});

  final InMemoryStorageService _delegate = InMemoryStorageService();
  final String failingLivestockId;

  @override
  Future<List<Tank>> getAllTanks() => _delegate.getAllTanks();

  @override
  Future<Tank?> getTank(String id) => _delegate.getTank(id);

  @override
  Future<void> saveTank(Tank tank) => _delegate.saveTank(tank);

  @override
  Future<void> saveTanks(List<Tank> tanks) => _delegate.saveTanks(tanks);

  @override
  Future<void> deleteTank(String id) => _delegate.deleteTank(id);

  @override
  Future<void> deleteAllTanks(List<String> ids) =>
      _delegate.deleteAllTanks(ids);

  @override
  Future<List<Livestock>> getLivestockForTank(String tankId) =>
      _delegate.getLivestockForTank(tankId);

  @override
  Future<void> saveLivestock(Livestock livestock) =>
      _delegate.saveLivestock(livestock);

  @override
  Future<void> deleteLivestock(String id) async {
    if (id == failingLivestockId) {
      throw StateError('livestock delete failed');
    }
    await _delegate.deleteLivestock(id);
  }

  @override
  Future<List<Equipment>> getEquipmentForTank(String tankId) =>
      _delegate.getEquipmentForTank(tankId);

  @override
  Future<void> saveEquipment(Equipment equipment) =>
      _delegate.saveEquipment(equipment);

  @override
  Future<void> deleteEquipment(String id) => _delegate.deleteEquipment(id);

  @override
  Future<List<LogEntry>> getLogsForTank(
    String tankId, {
    int? limit,
    DateTime? after,
  }) => _delegate.getLogsForTank(tankId, limit: limit, after: after);

  @override
  Future<LogEntry?> getLatestWaterTest(String tankId) =>
      _delegate.getLatestWaterTest(tankId);

  @override
  Future<void> saveLog(LogEntry log) => _delegate.saveLog(log);

  @override
  Future<void> deleteLog(String id) => _delegate.deleteLog(id);

  @override
  Future<List<Task>> getTasksForTank(String? tankId) =>
      _delegate.getTasksForTank(tankId);

  @override
  Future<void> saveTask(Task task) => _delegate.saveTask(task);

  @override
  Future<void> deleteTask(String id) => _delegate.deleteTask(id);
}

class _SaveLogFailsStorage extends _FailingLivestockDeleteStorage {
  _SaveLogFailsStorage() : super(failingLivestockId: '');

  @override
  Future<void> deleteLivestock(String id) => _delegate.deleteLivestock(id);

  @override
  Future<void> saveLog(LogEntry log) async {
    throw StateError('log save failed');
  }
}

class _CountingCleanSingleAddFailureStorage extends _SaveLogFailsStorage {
  int saveLivestockCalls = 0;
  int saveLogCalls = 0;
  int deleteLivestockCalls = 0;

  @override
  Future<void> saveLivestock(Livestock livestock) async {
    saveLivestockCalls++;
    await super.saveLivestock(livestock);
  }

  @override
  Future<void> saveLog(LogEntry log) async {
    saveLogCalls++;
    await super.saveLog(log);
  }

  @override
  Future<void> deleteLivestock(String id) async {
    deleteLivestockCalls++;
    await super.deleteLivestock(id);
  }
}

class _SingleAddLogAndDeleteRollbackFailStorage
    extends _FailingLivestockDeleteStorage {
  _SingleAddLogAndDeleteRollbackFailStorage() : super(failingLivestockId: '');

  final Object logSaveError = StateError('single livestock add log failed');
  final Object livestockDeleteError = StateError(
    'single livestock delete rollback failed',
  );
  final List<String> savedLivestockIds = <String>[];
  final List<LogEntry> attemptedLogs = <LogEntry>[];
  final List<String> deletedLogIds = <String>[];
  final List<String> deletedLivestockIds = <String>[];
  int getTankCalls = 0;
  int getLivestockForTankCalls = 0;
  int recentLogReads = 0;
  int fullLogReads = 0;
  int deleteLogCalls = 0;
  int deleteLivestockCalls = 0;

  @override
  Future<Tank?> getTank(String id) {
    getTankCalls++;
    return super.getTank(id);
  }

  @override
  Future<List<Livestock>> getLivestockForTank(String tankId) {
    getLivestockForTankCalls++;
    return super.getLivestockForTank(tankId);
  }

  @override
  Future<List<LogEntry>> getLogsForTank(
    String tankId, {
    int? limit,
    DateTime? after,
  }) {
    if (limit == null) {
      fullLogReads++;
    } else {
      recentLogReads++;
    }
    return super.getLogsForTank(tankId, limit: limit, after: after);
  }

  @override
  Future<void> saveLivestock(Livestock livestock) async {
    savedLivestockIds.add(livestock.id);
    await _delegate.saveLivestock(livestock);
  }

  @override
  Future<void> saveLog(LogEntry log) async {
    attemptedLogs.add(log);
    await _delegate.saveLog(log);
    throw logSaveError;
  }

  @override
  Future<void> deleteLog(String id) async {
    deleteLogCalls++;
    deletedLogIds.add(id);
    await _delegate.deleteLog(id);
  }

  @override
  Future<void> deleteLivestock(String id) async {
    deleteLivestockCalls++;
    deletedLivestockIds.add(id);
    throw livestockDeleteError;
  }
}

class _BlockingSingleAddLogStorage extends _FailingLivestockDeleteStorage {
  _BlockingSingleAddLogStorage() : super(failingLivestockId: '');

  final Completer<void> logSaveStarted = Completer<void>();
  final Completer<void> releaseLogSave = Completer<void>();
  int saveLivestockCalls = 0;
  int saveLogCalls = 0;

  @override
  Future<void> saveLivestock(Livestock livestock) async {
    saveLivestockCalls++;
    await _delegate.saveLivestock(livestock);
  }

  @override
  Future<void> saveLog(LogEntry log) async {
    saveLogCalls++;
    if (!logSaveStarted.isCompleted) {
      logSaveStarted.complete();
    }
    await releaseLogSave.future;
    await _delegate.saveLog(log);
  }
}

class _SaveLogAndRollbackFailOnceStorage
    extends _FailingLivestockDeleteStorage {
  _SaveLogAndRollbackFailOnceStorage() : super(failingLivestockId: '');

  int saveLivestockCalls = 0;
  int saveLogCalls = 0;
  int deleteLivestockCalls = 0;

  @override
  Future<void> saveLivestock(Livestock livestock) async {
    saveLivestockCalls++;
    await _delegate.saveLivestock(livestock);
  }

  @override
  Future<void> saveLog(LogEntry log) async {
    saveLogCalls++;
    if (saveLogCalls == 1) {
      throw StateError('initial log save failed');
    }
    await _delegate.saveLog(log);
  }

  @override
  Future<void> deleteLivestock(String id) async {
    deleteLivestockCalls++;
    if (deleteLivestockCalls == 1) {
      throw StateError('livestock rollback failed');
    }
    await _delegate.deleteLivestock(id);
  }
}

class _CleanThenUncertainBulkAddStorage extends _FailingLivestockDeleteStorage {
  _CleanThenUncertainBulkAddStorage() : super(failingLivestockId: '');

  int saveLivestockCalls = 0;
  int saveLogCalls = 0;
  int deleteLivestockCalls = 0;

  @override
  Future<void> saveLivestock(Livestock livestock) async {
    saveLivestockCalls++;
    await _delegate.saveLivestock(livestock);
  }

  @override
  Future<void> saveLog(LogEntry log) async {
    saveLogCalls++;
    if (saveLogCalls <= 2) {
      throw StateError('log save failed on attempt $saveLogCalls');
    }
    await _delegate.saveLog(log);
  }

  @override
  Future<void> deleteLivestock(String id) async {
    deleteLivestockCalls++;
    if (deleteLivestockCalls == 2) {
      throw StateError('second livestock rollback failed');
    }
    await _delegate.deleteLivestock(id);
  }
}

class _BulkMoveSaveAndRollbackFailStorage
    extends _FailingLivestockDeleteStorage {
  _BulkMoveSaveAndRollbackFailStorage({
    required this.movedLivestockId,
    required this.moveFailingLivestockId,
    required this.sourceTankId,
    required this.targetTankId,
  }) : super(failingLivestockId: '');

  final String movedLivestockId;
  final String moveFailingLivestockId;
  final String sourceTankId;
  final String targetTankId;
  var _firstMovePersisted = false;

  @override
  Future<void> saveLivestock(Livestock livestock) async {
    if (livestock.id == movedLivestockId && livestock.tankId == targetTankId) {
      await _delegate.saveLivestock(livestock);
      _firstMovePersisted = true;
      return;
    }
    if (livestock.id == moveFailingLivestockId &&
        livestock.tankId == targetTankId) {
      throw StateError('livestock save failed');
    }
    if (_firstMovePersisted &&
        livestock.id == movedLivestockId &&
        livestock.tankId == sourceTankId) {
      throw StateError('livestock rollback failed');
    }
    await _delegate.saveLivestock(livestock);
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // The skeleton loader renders placeholder LivestockCard widgets that have
  // a CircleAvatar assertion issue at test canvas size.  We suppress it below.
  void suppressAvatarError() {
    final original = FlutterError.onError!;
    FlutterError.onError = (FlutterErrorDetails details) {
      final msg = details.exceptionAsString();
      if (msg.contains('overflowed') ||
          msg.contains('backgroundImage != null')) {
        return;
      }
      original(details);
    };
  }

  group('LivestockScreen — empty state', () {
    testWidgets('loading skeleton does not register duplicate hero tags', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapWithLoadingLivestock());
      await tester.tap(find.text('Open livestock'));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without throwing', (tester) async {
      suppressAvatarError();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(LivestockScreen), findsOneWidget);
    });

    testWidgets('shows Livestock app bar title', (tester) async {
      suppressAvatarError();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Livestock'), findsOneWidget);
    });

    testWidgets('shows Add Livestock button when empty', (tester) async {
      suppressAvatarError();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Add Livestock'), findsOneWidget);
    });

    testWidgets('empty state does not duplicate the add action with a FAB', (
      tester,
    ) async {
      suppressAvatarError();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Add Livestock'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets(
      'empty state title uses iconography instead of raw emoji text',
      (tester) async {
        suppressAvatarError();
        await tester.pumpWidget(_wrap());
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.byIcon(Icons.set_meal), findsWidgets);
        expect(
          find.text('Your tank awaits its first residents!'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Your tank awaits its first residents! 🐠'),
          findsNothing,
        );
      },
    );

    testWidgets('has overflow menu button in actions', (tester) async {
      suppressAvatarError();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('tablet keeps livestock summary and list cards readable', (
      tester,
    ) async {
      suppressAvatarError();
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _wrap(
          livestockOverride: AsyncData([
            _makeLivestock(
              id: 'tablet-neons',
              tankId: _fakeTankId,
              name: 'Neon Tetra',
              count: 8,
            ),
          ]),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final summaryCard = find
          .ancestor(of: find.text('8 total'), matching: find.byType(AppCard))
          .first;
      expect(tester.getSize(summaryCard).width, lessThanOrEqualTo(720));

      final livestockCard = find
          .ancestor(of: find.text('Neon Tetra'), matching: find.byType(Card))
          .first;
      expect(tester.getSize(livestockCard).width, lessThanOrEqualTo(720));
    });

    testWidgets(
      'adding livestock shows success feedback and readable timeline log',
      (tester) async {
        suppressAvatarError();
        const tankId = 'livestock-add-feedback-tank';
        final storage = InMemoryStorageService();
        await storage.saveTank(_makeTank(id: tankId, name: 'Shrimp Tank'));

        await tester.pumpWidget(
          _wrapWithStorage(storage: storage, tankId: tankId),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.text('Add Livestock'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.enterText(
          find.byType(TextFormField).first,
          'Amano Shrimp',
        );
        await tester.tap(find.text('Add').last);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(seconds: 1));

        final livestock = await storage.getLivestockForTank(tankId);
        expect(livestock.single.commonName, 'Amano Shrimp');
        expect(livestock.single.count, 1);

        final logs = await storage.getLogsForTank(tankId);
        expect(logs.single.title, 'Added 1x Amano Shrimp');
        expect(find.text('1x Amano Shrimp added.'), findsOneWidget);
      },
    );

    testWidgets('failed add-log save rolls back new livestock', (
      tester,
    ) async {
      suppressAvatarError();
      const tankId = 'livestock-add-log-failure-tank';
      final storage = _SaveLogFailsStorage();
      await storage.saveTank(_makeTank(id: tankId, name: 'Rollback Tank'));

      await tester.pumpWidget(
        _wrapWithStorage(storage: storage, tankId: tankId),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Add Livestock'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(
        find.byType(TextFormField).first,
        'Otocinclus',
      );
      await tester.tap(find.text('Add').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 1));

      expect(await storage.getLivestockForTank(tankId), isEmpty);
      expect(await storage.getLogsForTank(tankId), isEmpty);
      expect(
        find.text('Couldn\'t save that. Check your connection and try again.'),
        findsOneWidget,
      );
      expect(find.text('1x Otocinclus added.'), findsNothing);
    });

    testWidgets('stale single-add Retry is ignored after sheet dismissal', (
      tester,
    ) async {
      suppressAvatarError();
      const tankId = 'livestock-single-add-dismissed-retry-tank';
      final storage = _CountingCleanSingleAddFailureStorage();
      await storage.saveTank(_makeTank(id: tankId, name: 'Dismissed Tank'));

      await tester.pumpWidget(
        _wrapWithStorage(storage: storage, tankId: tankId),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Add Livestock'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(
        find.byType(TextFormField).first,
        'Harlequin Rasbora',
      );
      final addFinder = find.widgetWithText(AppButton, 'Add').last;

      await tester.tap(addFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 1));

      expect(storage.saveLivestockCalls, 1);
      expect(storage.saveLogCalls, 1);
      expect(storage.deleteLivestockCalls, 1);
      expect(find.text('Retry'), findsOneWidget);
      final staleRetry = tester.widget<SnackBarAction>(
        find.byType(SnackBarAction),
      );

      Navigator.of(tester.element(addFinder)).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.widgetWithText(AppButton, 'Add'), findsNothing);

      staleRetry.onPressed();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
      expect(storage.saveLivestockCalls, 1);
      expect(storage.saveLogCalls, 1);
      expect(storage.deleteLivestockCalls, 1);
      expect(await storage.getLivestockForTank(tankId), isEmpty);
      expect(await storage.getLogsForTank(tankId), isEmpty);
    });

    testWidgets(
      'failed single-add log and deletion rollback preserves uncertain id and blocks repeated submit',
      (tester) async {
        suppressAvatarError();
        const tankId = 'livestock-single-add-rollback-uncertain-tank';
        final storage = _SingleAddLogAndDeleteRollbackFailStorage();
        await storage.saveTank(_makeTank(id: tankId, name: 'Uncertain Tank'));
        final debugMessages = <String>[];
        final previousDebugPrint = debugPrint;
        debugPrint = (String? message, {int? wrapWidth}) {
          if (message != null) debugMessages.add(message);
        };
        addTearDown(() => debugPrint = previousDebugPrint);

        await tester.pumpWidget(
          _wrapWithStorage(storage: storage, tankId: tankId),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.text('Add Livestock'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.enterText(
          find.byType(TextFormField).first,
          'Peppered Cory',
        );
        final addFinder = find.widgetWithText(AppButton, 'Add').last;
        final staleAdd = tester.widget<AppButton>(addFinder).onPressed!;
        final tankReadsBefore = storage.getTankCalls;
        final livestockReadsBefore = storage.getLivestockForTankCalls;
        final recentLogReadsBefore = storage.recentLogReads;
        final fullLogReadsBefore = storage.fullLogReads;

        await tester.tap(addFinder);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(seconds: 1));

        expect(storage.getTankCalls, greaterThanOrEqualTo(tankReadsBefore + 2));
        expect(
          storage.getLivestockForTankCalls,
          greaterThan(livestockReadsBefore),
        );
        expect(storage.recentLogReads, greaterThan(recentLogReadsBefore));
        expect(storage.fullLogReads, greaterThan(fullLogReadsBefore));
        final livestock = await storage.getLivestockForTank(tankId);
        expect(livestock, hasLength(1));
        final uncertainLivestockId = livestock.single.id;
        expect(storage.savedLivestockIds, <String>[uncertainLivestockId]);
        expect(storage.attemptedLogs, hasLength(1));
        final attemptedLog = storage.attemptedLogs.single;
        expect(attemptedLog.relatedLivestockId, uncertainLivestockId);
        expect(await storage.getLogsForTank(tankId), isEmpty);
        expect(storage.deleteLogCalls, 1);
        expect(storage.deleteLivestockCalls, 1);
        expect(storage.deletedLogIds, <String>[attemptedLog.id]);
        expect(storage.deletedLivestockIds, <String>[uncertainLivestockId]);
        expect(tester.widget<AppButton>(addFinder).onPressed, isNull);
        expect(
          find.text(
            '1x Peppered Cory may already be saved, and its activity history '
            'may be incomplete. Close this form and check your livestock '
            'before trying again.',
          ),
          findsOneWidget,
        );
        expect(
          find.text(
            'Couldn\'t save that. Check your connection and try again.',
          ),
          findsNothing,
        );
        expect(find.text('1x Peppered Cory added.'), findsNothing);
        expect(find.byType(SnackBarAction), findsNothing);
        expect(find.text('Retry'), findsNothing);

        staleAdd();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        debugPrint = previousDebugPrint;
        expect(storage.savedLivestockIds, <String>[uncertainLivestockId]);
        expect(storage.attemptedLogs, hasLength(1));
        expect(storage.deleteLogCalls, 1);
        expect(storage.deleteLivestockCalls, 1);
        final combinedLog = debugMessages.join('\n');
        expect(combinedLog, contains('LivestockAddCompensationException'));
        expect(combinedLog, contains(storage.logSaveError.toString()));
        expect(combinedLog, contains(storage.livestockDeleteError.toString()));
        expect(combinedLog, contains(tankId));
        expect(combinedLog, contains(uncertainLivestockId));
        expect(combinedLog, contains(attemptedLog.id));
      },
    );

    testWidgets('in-flight single-add ignores a repeated stale callback', (
      tester,
    ) async {
      suppressAvatarError();
      const tankId = 'livestock-single-add-in-flight-tank';
      final storage = _BlockingSingleAddLogStorage();
      await storage.saveTank(_makeTank(id: tankId, name: 'In-flight Tank'));

      await tester.pumpWidget(
        _wrapWithStorage(storage: storage, tankId: tankId),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Add Livestock'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(find.byType(TextFormField).first, 'Kuhli Loach');
      final addFinder = find.widgetWithText(AppButton, 'Add').last;
      final capturedAdd = tester.widget<AppButton>(addFinder).onPressed!;

      capturedAdd();
      await storage.logSaveStarted.future;
      capturedAdd();
      await tester.pump();

      storage.releaseLogSave.complete();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 1));

      expect(storage.saveLivestockCalls, 1);
      expect(storage.saveLogCalls, 1);
      expect(await storage.getLivestockForTank(tankId), hasLength(1));
      expect(await storage.getLogsForTank(tankId), hasLength(1));
      expect(find.text('1x Kuhli Loach added.'), findsOneWidget);
    });

    testWidgets(
      'profile activity failure after livestock add does not report add failure',
      (tester) async {
        suppressAvatarError();
        SharedPreferences.setMockInitialValues({
          'user_profile': jsonEncode(_makeProfile().toJson()),
        });
        final prefs = await SharedPreferences.getInstance();
        final throwingPrefs = _ThrowingSetStringPrefs(
          prefs,
          (key, _) => key == 'user_profile',
        );
        const tankId = 'livestock-add-profile-failure-tank';
        final storage = InMemoryStorageService();
        await storage.saveTank(_makeTank(id: tankId, name: 'Progress Tank'));

        await tester.pumpWidget(
          _wrapWithStorage(
            storage: storage,
            tankId: tankId,
            prefs: throwingPrefs,
            showProfileProbe: true,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('profile ready'), findsOneWidget);

        await tester.tap(find.text('Add Livestock'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.enterText(
          find.byType(TextFormField).first,
          'Cherry Shrimp',
        );
        await tester.tap(find.text('Add').last);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(seconds: 1));

        final livestock = await storage.getLivestockForTank(tankId);
        expect(livestock, hasLength(1));
        expect(livestock.single.commonName, 'Cherry Shrimp');

        final logs = await storage.getLogsForTank(tankId);
        expect(logs, hasLength(1));
        expect(logs.single.title, 'Added 1x Cherry Shrimp');
        expect(
          find.widgetWithText(TextFormField, 'Cherry Shrimp'),
          findsNothing,
        );
        expect(
          find.text('1x Cherry Shrimp added, but progress couldn\'t update.'),
          findsOneWidget,
        );
        expect(
          find.text(
            'Couldn\'t save that. Check your connection and try again.',
          ),
          findsNothing,
        );
        expect(find.text('Retry'), findsNothing);
      },
    );

    testWidgets('stale livestock edit ids are not recreated by save', (
      tester,
    ) async {
      suppressAvatarError();
      const tankId = 'livestock-stale-edit-tank';
      const livestockId = 'livestock-stale-edit-neons';
      final storage = InMemoryStorageService();
      await storage.saveTank(_makeTank(id: tankId, name: 'Stale Edit Tank'));
      await storage.saveLivestock(
        _makeLivestock(
          id: livestockId,
          tankId: tankId,
          name: 'Neon Tetra',
          count: 8,
        ),
      );

      await tester.pumpWidget(
        _wrapWithStorage(storage: storage, tankId: tankId),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final livestockTile = find.ancestor(
        of: find.text('Neon Tetra'),
        matching: find.byType(ListTile),
      );
      await tester.tap(
        find.descendant(
          of: livestockTile,
          matching: find.byTooltip('Livestock actions'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Edit Livestock'), findsOneWidget);

      await storage.deleteLivestock(livestockId);

      await tester.ensureVisible(find.text('Save').last);
      await tester.pump();
      await tester.tap(find.text('Save').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 1));

      expect(await storage.getLivestockForTank(tankId), isEmpty);
      expect(
        find.text('Couldn\'t save that. Check your connection and try again.'),
        findsOneWidget,
      );
      expect(find.text('8x Neon Tetra saved.'), findsNothing);
    });

    testWidgets('missing tank ids do not create orphan livestock', (
      tester,
    ) async {
      suppressAvatarError();
      const tankId = 'livestock-missing-parent-tank';
      final storage = InMemoryStorageService();
      await storage.saveTank(
        _makeTank(id: tankId, name: 'Missing Parent Tank'),
      );

      await tester.pumpWidget(
        _wrapWithStorage(storage: storage, tankId: tankId),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Add Livestock'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(find.byType(TextFormField).first, 'Cherry Shrimp');

      await storage.deleteTank(tankId);
      expect(await storage.getTank(tankId), isNull);

      await tester.tap(find.text('Add').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 1));

      expect(await storage.getLivestockForTank(tankId), isEmpty);
      expect(await storage.getLogsForTank(tankId), isEmpty);
      expect(
        find.text('Couldn\'t save that. Check your connection and try again.'),
        findsOneWidget,
      );
      expect(find.text('1x Cherry Shrimp added.'), findsNothing);
    });

    testWidgets('failed bulk-add log save rolls back new livestock', (
      tester,
    ) async {
      suppressAvatarError();
      const tankId = 'livestock-bulk-log-failure-tank';
      final storage = _SaveLogFailsStorage();
      await storage.saveTank(_makeTank(id: tankId, name: 'Rollback Tank'));

      await tester.pumpWidget(
        _wrapBulkAddDialog(storage: storage, tankId: tankId),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(
        find.byType(TextField).last,
        'Neon Tetra, 10\nCorydoras x6',
      );
      await tester.pump();
      await tester.tap(find.text('Add (2) livestock'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 1));

      expect(await storage.getLivestockForTank(tankId), isEmpty);
      expect(await storage.getLogsForTank(tankId), isEmpty);
      expect(
        find.text('Couldn\'t add that right now. Try again!'),
        findsOneWidget,
      );
      expect(find.text('Added 2 livestock entries.'), findsNothing);
    });

    testWidgets(
      'failed bulk-add rollback reports uncertainty and blocks duplicate retry',
      (tester) async {
        suppressAvatarError();
        const tankId = 'livestock-bulk-rollback-failure-tank';
        final storage = _SaveLogAndRollbackFailOnceStorage();
        await storage.saveTank(_makeTank(id: tankId, name: 'Uncertain Tank'));

        await tester.pumpWidget(
          _wrapBulkAddDialog(storage: storage, tankId: tankId),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        await tester.enterText(
          find.byType(TextField).last,
          'Neon Tetra, 10',
        );
        await tester.pump();
        await tester.tap(find.text('Add (1) livestock'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(seconds: 1));

        expect(await storage.getLivestockForTank(tankId), hasLength(1));
        expect(await storage.getLogsForTank(tankId), isEmpty);
        expect(storage.saveLivestockCalls, 1);
        expect(storage.saveLogCalls, 1);
        expect(storage.deleteLivestockCalls, 1);
        expect(
          find.text(
            'Bulk add didn\'t finish, and some livestock may already be saved. '
            'Close this form and check your livestock before trying again.',
          ),
          findsOneWidget,
        );
        expect(find.text('Retry'), findsNothing);

        await tester.tap(find.text('Add (1) livestock'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(storage.saveLivestockCalls, 1);
        expect(storage.saveLogCalls, 1);
        expect(await storage.getLivestockForTank(tankId), hasLength(1));
        expect(await storage.getLogsForTank(tankId), isEmpty);
        expect(find.text('Added 1 livestock entries.'), findsNothing);
      },
    );

    testWidgets(
      'stale bulk-add retry cannot bypass uncertain persistence lock',
      (tester) async {
        suppressAvatarError();
        const tankId = 'livestock-bulk-stale-retry-tank';
        final storage = _CleanThenUncertainBulkAddStorage();
        await storage.saveTank(_makeTank(id: tankId, name: 'Retry Tank'));

        await tester.pumpWidget(
          _wrapBulkAddDialog(storage: storage, tankId: tankId),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        await tester.enterText(find.byType(TextField).last, 'Neon Tetra, 10');
        await tester.pump();
        await tester.tap(find.text('Add (1) livestock'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(await storage.getLivestockForTank(tankId), isEmpty);
        expect(storage.saveLivestockCalls, 1);
        expect(storage.saveLogCalls, 1);
        expect(storage.deleteLivestockCalls, 1);
        expect(find.text('Retry'), findsOneWidget);
        final staleRetry = tester.widget<SnackBarAction>(
          find.byType(SnackBarAction),
        );

        await tester.tap(find.text('Add (1) livestock'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(seconds: 1));

        expect(await storage.getLivestockForTank(tankId), hasLength(1));
        expect(await storage.getLogsForTank(tankId), isEmpty);
        expect(storage.saveLivestockCalls, 2);
        expect(storage.saveLogCalls, 2);
        expect(storage.deleteLivestockCalls, 2);

        staleRetry.onPressed();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(storage.saveLivestockCalls, 2);
        expect(storage.saveLogCalls, 2);
        expect(storage.deleteLivestockCalls, 2);
        expect(await storage.getLivestockForTank(tankId), hasLength(1));
        expect(await storage.getLogsForTank(tankId), isEmpty);
        expect(find.text('Retry'), findsNothing);
        expect(
          find.text(
            'Bulk add didn\'t finish, and some livestock may already be saved. '
            'Close this form and check your livestock before trying again.',
          ),
          findsOneWidget,
        );
        expect(find.text('Added 1 livestock entries.'), findsNothing);
      },
    );

    testWidgets('bulk add rejects missing parent tanks before saving', (
      tester,
    ) async {
      suppressAvatarError();
      const tankId = 'livestock-bulk-missing-parent-tank';
      final storage = InMemoryStorageService();
      await storage.saveTank(_makeTank(id: tankId, name: 'Missing Parent'));

      await tester.pumpWidget(
        _wrapBulkAddDialog(storage: storage, tankId: tankId),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(
        find.byType(TextField).last,
        'Neon Tetra, 10\nCorydoras x6',
      );
      await tester.pump();

      await storage.deleteTank(tankId);
      expect(await storage.getTank(tankId), isNull);

      await tester.tap(find.text('Add (2) livestock'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 1));

      expect(await storage.getLivestockForTank(tankId), isEmpty);
      expect(await storage.getLogsForTank(tankId), isEmpty);
      expect(
        find.text('Couldn\'t add that right now. Try again!'),
        findsOneWidget,
      );
      expect(find.text('Added 2 livestock entries.'), findsNothing);
    });
  });

  group('LivestockScreen - quick feeding', () {
    testWidgets('successful feeding log emits a tank feeding pulse', (
      tester,
    ) async {
      suppressAvatarError();
      const tankId = 'livestock-feed-pulse-tank';
      final storage = InMemoryStorageService();
      await storage.saveTank(_makeTank(id: tankId, name: 'Community Tank'));
      await storage.saveLivestock(
        _makeLivestock(
          id: 'livestock-feed-pulse-neons',
          tankId: tankId,
          name: 'Neon Tetra',
          count: 8,
        ),
      );

      await tester.pumpWidget(
        _wrapWithPulseProbe(storage: storage, tankId: tankId),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('pulse 0'), findsOneWidget);

      await tester.tap(find.text('Feed'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final logs = await storage.getLogsForTank(tankId);
      expect(logs.where((log) => log.type == LogType.feeding), hasLength(1));
      expect(find.text('pulse 1'), findsOneWidget);
    });

    testWidgets(
      'quick feeding rejects a missing parent before saving or rewarding',
      (tester) async {
        suppressAvatarError();
        const tankId = 'livestock-feed-missing-parent';
        final initialProfile = _makeProfile().copyWith(totalXp: 40);
        SharedPreferences.setMockInitialValues({
          'user_profile': jsonEncode(initialProfile.toJson()),
        });
        final prefs = await SharedPreferences.getInstance();
        final storage = InMemoryStorageService();
        await storage.saveTank(_makeTank(id: tankId, name: 'Stale Tank'));
        await storage.saveLivestock(
          _makeLivestock(
            id: 'livestock-feed-missing-parent-neons',
            tankId: tankId,
            name: 'Neon Tetra',
            count: 8,
          ),
        );

        await tester.pumpWidget(
          _wrapWithPulseProbe(
            storage: storage,
            tankId: tankId,
            showProfileProbe: true,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('pulse 0'), findsOneWidget);
        expect(find.text('profile ready'), findsOneWidget);

        await storage.deleteTank(tankId);
        expect(await storage.getTank(tankId), isNull);

        await tester.tap(find.text('Feed'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(await storage.getLogsForTank(tankId), isEmpty);
        expect(find.text('pulse 0'), findsOneWidget);
        expect(find.byType(XpAwardAnimation), findsNothing);
        final persistedProfile = UserProfile.fromJson(
          jsonDecode(prefs.getString('user_profile')!) as Map<String, dynamic>,
        );
        expect(persistedProfile.totalXp, initialProfile.totalXp);
        expect(
          find.text("Couldn't log that feeding. Give it another go!"),
          findsOneWidget,
        );
        expect(find.text('Feeding logged.'), findsNothing);
      },
    );

    testWidgets('successful feeding log refreshes all-log timeline data', (
      tester,
    ) async {
      suppressAvatarError();
      const tankId = 'livestock-feed-timeline-tank';
      final storage = InMemoryStorageService();
      await storage.saveTank(_makeTank(id: tankId, name: 'Timeline Tank'));
      await storage.saveLivestock(
        _makeLivestock(
          id: 'livestock-feed-timeline-corys',
          tankId: tankId,
          name: 'Corydoras',
          count: 6,
        ),
      );

      await tester.pumpWidget(
        _wrapWithTimelineProbe(storage: storage, tankId: tankId),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('timeline feedings 0'), findsOneWidget);

      await tester.tap(find.text('Feed'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final logs = await storage.getLogsForTank(tankId);
      expect(logs.where((log) => log.type == LogType.feeding), hasLength(1));
      expect(find.text('timeline feedings 1'), findsOneWidget);
    });
  });

  group('LivestockScreen - bulk move', () {
    testWidgets('success feedback reports selected livestock count', (
      tester,
    ) async {
      suppressAvatarError();
      const sourceTankId = 'bulk-move-source';
      const targetTankId = 'bulk-move-target';
      final storage = InMemoryStorageService();
      await storage.saveTank(
        _makeTank(id: sourceTankId, name: 'Living Room Tank'),
      );
      await storage.saveTank(_makeTank(id: targetTankId, name: 'Bedroom Tank'));
      await storage.saveLivestock(
        _makeLivestock(
          id: 'bulk-move-neons',
          tankId: sourceTankId,
          name: 'Neon Tetra',
          count: 8,
        ),
      );
      await storage.saveLivestock(
        _makeLivestock(
          id: 'bulk-move-corys',
          tankId: sourceTankId,
          name: 'Corydoras',
          count: 5,
        ),
      );

      await tester.pumpWidget(
        _wrapWithStorage(storage: storage, tankId: sourceTankId),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.more_vert),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select multiple'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select All'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Move to Tank'));
      await tester.pumpAndSettle();
      final bedroomTankTile = tester.widget<ListTile>(
        find
            .ancestor(
              of: find.text('Bedroom Tank'),
              matching: find.byType(ListTile),
            )
            .last,
      );
      expect(bedroomTankTile.onTap, isNotNull);
      bedroomTankTile.onTap!.call();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Moved 2 livestock to Bedroom Tank'), findsOneWidget);
      expect(find.text('Moved 0 livestock to Bedroom Tank'), findsNothing);
    });

    testWidgets(
      'bulk move reports actual count when a selected livestock id is missing',
      (tester) async {
        suppressAvatarError();
        const sourceTankId = 'bulk-move-stale-source';
        const targetTankId = 'bulk-move-stale-target';
        const durableLivestockId = 'bulk-move-stale-neons';
        const missingLivestockId = 'bulk-move-stale-corys';
        final storage = InMemoryStorageService();
        await storage.saveTank(
          _makeTank(id: sourceTankId, name: 'Living Room Tank'),
        );
        await storage.saveTank(
          _makeTank(id: targetTankId, name: 'Bedroom Tank'),
        );
        await storage.saveLivestock(
          _makeLivestock(
            id: durableLivestockId,
            tankId: sourceTankId,
            name: 'Neon Tetra',
            count: 8,
          ),
        );
        await storage.saveLivestock(
          _makeLivestock(
            id: missingLivestockId,
            tankId: sourceTankId,
            name: 'Corydoras',
            count: 5,
          ),
        );

        await tester.pumpWidget(
          _wrapWithStorage(storage: storage, tankId: sourceTankId),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        await tester.tap(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.byIcon(Icons.more_vert),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Select multiple'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Select All'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Move to Tank'));
        await tester.pumpAndSettle();

        await storage.deleteLivestock(missingLivestockId);
        final bedroomTankTile = tester.widget<ListTile>(
          find
              .ancestor(
                of: find.text('Bedroom Tank'),
                matching: find.byType(ListTile),
              )
              .last,
        );
        expect(bedroomTankTile.onTap, isNotNull);
        bedroomTankTile.onTap!.call();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(await storage.getLivestockForTank(sourceTankId), isEmpty);
        expect(
          (await storage.getLivestockForTank(
            targetTankId,
          )).map((livestock) => livestock.id),
          [durableLivestockId],
        );
        expect(find.text('Moved 1 livestock to Bedroom Tank'), findsOneWidget);
        expect(find.text('Moved 2 livestock to Bedroom Tank'), findsNothing);
      },
    );

    testWidgets(
      'failed bulk-move rollback reports partial-move uncertainty without unsafe retry',
      (tester) async {
        suppressAvatarError();
        const sourceTankId = 'bulk-move-uncertain-source';
        const targetTankId = 'bulk-move-uncertain-target';
        const movedLivestockId = 'bulk-move-uncertain-neons';
        const failingLivestockId = 'bulk-move-uncertain-corys';
        final storage = _BulkMoveSaveAndRollbackFailStorage(
          movedLivestockId: movedLivestockId,
          moveFailingLivestockId: failingLivestockId,
          sourceTankId: sourceTankId,
          targetTankId: targetTankId,
        );
        await storage.saveTank(
          _makeTank(id: sourceTankId, name: 'Living Room Tank'),
        );
        await storage.saveTank(
          _makeTank(id: targetTankId, name: 'Bedroom Tank'),
        );
        await storage.saveLivestock(
          _makeLivestock(
            id: movedLivestockId,
            tankId: sourceTankId,
            name: 'Neon Tetra',
            count: 8,
          ),
        );
        await storage.saveLivestock(
          _makeLivestock(
            id: failingLivestockId,
            tankId: sourceTankId,
            name: 'Corydoras',
            count: 5,
          ),
        );

        await tester.pumpWidget(
          _wrapWithStorage(storage: storage, tankId: sourceTankId),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        await tester.tap(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.byIcon(Icons.more_vert),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Select multiple'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Select All'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Move to Tank'));
        await tester.pumpAndSettle();

        final bedroomTankTile = tester.widget<ListTile>(
          find
              .ancestor(
                of: find.text('Bedroom Tank'),
                matching: find.byType(ListTile),
              )
              .last,
        );
        expect(bedroomTankTile.onTap, isNotNull);
        bedroomTankTile.onTap!.call();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(
          (await storage.getLivestockForTank(
            sourceTankId,
          )).map((livestock) => livestock.id),
          [failingLivestockId],
        );
        expect(
          (await storage.getLivestockForTank(
            targetTankId,
          )).map((livestock) => livestock.id),
          [movedLivestockId],
        );
        expect(find.textContaining('Try again'), findsNothing);
        expect(find.text('Retry'), findsNothing);
        expect(find.text('Move to Tank'), findsNothing);
        expect(find.textContaining('Moved 2 livestock'), findsNothing);
        expect(
          find.text(
            'Bulk move didn\'t finish. 2 selected livestock may now be split '
            'between this tank and Bedroom Tank. Refresh both tanks before '
            'moving livestock again.',
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('LivestockScreen - bulk delete', () {
    testWidgets('failed single removal expiry restores item with feedback', (
      tester,
    ) async {
      suppressAvatarError();
      const tankId = 'single-delete-failure-tank';
      const livestockId = 'single-delete-failure-neons';
      final storage = _FailingLivestockDeleteStorage(
        failingLivestockId: livestockId,
      );
      await storage.saveTank(_makeTank(id: tankId, name: 'Community Tank'));
      await storage.saveLivestock(
        _makeLivestock(
          id: livestockId,
          tankId: tankId,
          name: 'Neon Tetra',
          count: 8,
        ),
      );

      await tester.pumpWidget(
        _wrapWithStorage(
          storage: storage,
          tankId: tankId,
          disableAnimations: true,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Neon Tetra'), findsOneWidget);

      final livestockTile = find.ancestor(
        of: find.text('Neon Tetra'),
        matching: find.byType(ListTile),
      );
      await tester.tap(
        find.descendant(
          of: livestockTile,
          matching: find.byTooltip('Livestock actions'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pump();

      expect(find.text('8x Neon Tetra removed'), findsOneWidget);

      await tester.pump(const Duration(seconds: 6));
      await tester.pump();

      expect(find.text('Neon Tetra'), findsOneWidget);
      expect(
        find.text('Couldn\'t remove Neon Tetra. Try again.'),
        findsOneWidget,
      );

      final logs = await storage.getLogsForTank(tankId);
      expect(
        logs.where((log) => log.type == LogType.livestockRemoved),
        isEmpty,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    testWidgets('failed bulk removal expiry restores item with feedback', (
      tester,
    ) async {
      suppressAvatarError();
      const tankId = 'bulk-delete-failure-tank';
      const deletedLivestockId = 'bulk-delete-failure-neons';
      const restoredLivestockId = 'bulk-delete-failure-corys';
      final storage = _FailingLivestockDeleteStorage(
        failingLivestockId: restoredLivestockId,
      );
      await storage.saveTank(_makeTank(id: tankId, name: 'Community Tank'));
      await storage.saveLivestock(
        _makeLivestock(
          id: deletedLivestockId,
          tankId: tankId,
          name: 'Neon Tetra',
          count: 8,
        ),
      );
      await storage.saveLivestock(
        _makeLivestock(
          id: restoredLivestockId,
          tankId: tankId,
          name: 'Corydoras',
          count: 5,
        ),
      );

      await tester.pumpWidget(
        _wrapWithStorage(
          storage: storage,
          tankId: tankId,
          disableAnimations: true,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.more_vert),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select multiple'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select All'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove Livestock'));
      await tester.pump();

      expect(find.text('2 livestock removed'), findsOneWidget);

      await tester.pump(const Duration(seconds: 6));
      await tester.pump();

      expect(find.text('Neon Tetra'), findsNothing);
      expect(find.text('Corydoras'), findsOneWidget);
      expect(
        find.text('Couldn\'t remove one or more livestock. Try again.'),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    testWidgets(
      'expired livestock removal does not log after parent tank deletion',
      (tester) async {
        suppressAvatarError();
        const tankId = 'single-delete-missing-parent-tank';
        const livestockId = 'single-delete-missing-parent-neons';
        final storage = InMemoryStorageService();
        await storage.saveTank(_makeTank(id: tankId, name: 'Community Tank'));
        await storage.saveLivestock(
          _makeLivestock(
            id: livestockId,
            tankId: tankId,
            name: 'Neon Tetra',
            count: 8,
          ),
        );

        await tester.pumpWidget(
          _wrapWithStorage(
            storage: storage,
            tankId: tankId,
            disableAnimations: true,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        final livestockTile = find.ancestor(
          of: find.text('Neon Tetra'),
          matching: find.byType(ListTile),
        );
        await tester.tap(
          find.descendant(
            of: livestockTile,
            matching: find.byTooltip('Livestock actions'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Remove'));
        await tester.pump();

        expect(find.text('8x Neon Tetra removed'), findsOneWidget);

        await storage.deleteTank(tankId);
        expect(await storage.getTank(tankId), isNull);

        await tester.pump(const Duration(seconds: 6));
        await tester.pump();

        final logs = await storage.getLogsForTank(tankId);
        expect(
          logs.where((log) => log.type == LogType.livestockRemoved),
          isEmpty,
        );
      },
    );

    testWidgets('expired bulk removal writes timeline logs', (tester) async {
      suppressAvatarError();
      const tankId = 'bulk-delete-log-tank';
      final storage = InMemoryStorageService();
      await storage.saveTank(_makeTank(id: tankId, name: 'Timeline Tank'));
      await storage.saveLivestock(
        _makeLivestock(
          id: 'bulk-delete-neons',
          tankId: tankId,
          name: 'Neon Tetra',
          count: 8,
        ),
      );
      await storage.saveLivestock(
        _makeLivestock(
          id: 'bulk-delete-corys',
          tankId: tankId,
          name: 'Corydoras',
          count: 5,
        ),
      );

      await tester.pumpWidget(
        _wrapWithStorage(storage: storage, tankId: tankId),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.more_vert),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select multiple'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select All'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove Livestock'));
      await tester.pump();

      expect(find.text('2 livestock removed'), findsOneWidget);

      await tester.pump(const Duration(seconds: 6));
      await tester.pump();

      final logs = await storage.getLogsForTank(tankId);
      final removalLogs = logs
          .where((log) => log.type == LogType.livestockRemoved)
          .toList();

      expect(removalLogs, hasLength(2));
      expect(
        removalLogs.map((log) => log.title),
        containsAll(<String>['Removed 8x Neon Tetra', 'Removed 5x Corydoras']),
      );
    });
  });
}
