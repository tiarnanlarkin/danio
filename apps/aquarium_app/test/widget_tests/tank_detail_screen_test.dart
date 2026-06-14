// Widget tests for TankDetailScreen.
//
// Run: flutter test test/widget_tests/tank_detail_screen_test.dart
//
// Note: TankDetailScreen includes QuickAddFab (repeating animation) and
// flutter_animate widgets. pumpAndSettle never settles. We use timed pumps.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/tank_detail/tank_detail_screen.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/models/models.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _now = DateTime.now();

Tank _makeTank({String id = 'tank-1', String name = 'My Test Tank'}) => Tank(
  id: id,
  name: name,
  type: TankType.freshwater,
  volumeLitres: 100,
  startDate: _now,
  targets: WaterTargets.freshwaterTropical(),
  createdAt: _now,
  updatedAt: _now,
);

Widget _wrap(String tankId, {InMemoryStorageService? storage}) {
  final svc = storage ?? InMemoryStorageService();
  return ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(svc)],
    child: MaterialApp(home: TankDetailScreen(tankId: tankId)),
  );
}

Widget _wrapWithStorage(String tankId, {required StorageService storage}) {
  return ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
    child: MaterialApp(home: TankDetailScreen(tankId: tankId)),
  );
}

/// Advance enough time for async providers + animations without hitting
/// repeating animation loops that prevent pumpAndSettle from settling.
Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 1000));
}

class _DelegatingStorageService implements StorageService {
  _DelegatingStorageService(this._delegate);

  final InMemoryStorageService _delegate;

  @override
  Future<void> deleteAllTanks(List<String> ids) =>
      _delegate.deleteAllTanks(ids);

  @override
  Future<void> deleteEquipment(String id) => _delegate.deleteEquipment(id);

  @override
  Future<void> deleteLivestock(String id) => _delegate.deleteLivestock(id);

  @override
  Future<void> deleteLog(String id) => _delegate.deleteLog(id);

  @override
  Future<void> deleteTank(String id) => _delegate.deleteTank(id);

  @override
  Future<void> deleteTask(String id) => _delegate.deleteTask(id);

  @override
  Future<List<Tank>> getAllTanks() => _delegate.getAllTanks();

  @override
  Future<List<Equipment>> getEquipmentForTank(String tankId) =>
      _delegate.getEquipmentForTank(tankId);

  @override
  Future<LogEntry?> getLatestWaterTest(String tankId) =>
      _delegate.getLatestWaterTest(tankId);

  @override
  Future<List<Livestock>> getLivestockForTank(String tankId) =>
      _delegate.getLivestockForTank(tankId);

  @override
  Future<List<LogEntry>> getLogsForTank(
    String tankId, {
    int? limit,
    DateTime? after,
  }) => _delegate.getLogsForTank(tankId, limit: limit, after: after);

  @override
  Future<Tank?> getTank(String id) => _delegate.getTank(id);

  @override
  Future<List<Task>> getTasksForTank(String? tankId) =>
      _delegate.getTasksForTank(tankId);

  @override
  Future<void> saveEquipment(Equipment equipment) =>
      _delegate.saveEquipment(equipment);

  @override
  Future<void> saveLivestock(Livestock livestock) =>
      _delegate.saveLivestock(livestock);

  @override
  Future<void> saveLog(LogEntry log) => _delegate.saveLog(log);

  @override
  Future<void> saveTank(Tank tank) => _delegate.saveTank(tank);

  @override
  Future<void> saveTanks(List<Tank> tanks) => _delegate.saveTanks(tanks);

  @override
  Future<void> saveTask(Task task) => _delegate.saveTask(task);
}

class _CompletionLogFailsStorage extends _DelegatingStorageService {
  _CompletionLogFailsStorage(super.delegate);

  @override
  Future<void> saveLog(LogEntry log) async {
    if (log.type == LogType.taskCompleted) {
      throw StateError('task completion log failed');
    }
    await super.saveLog(log);
  }
}

class _FeedingLogFailsStorage extends _DelegatingStorageService {
  _FeedingLogFailsStorage(super.delegate);

  @override
  Future<void> saveLog(LogEntry log) async {
    if (log.type == LogType.feeding) {
      throw StateError('feeding log failed');
    }
    await super.saveLog(log);
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TankDetailScreen — smoke tests', () {
    testWidgets('widget type is constructable', (tester) async {
      expect(TankDetailScreen(tankId: 'tank-1'), isA<TankDetailScreen>());
    });

    testWidgets('renders without throwing with valid tank', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrap('tank-1', storage: svc));
      await _advance(tester);
      expect(find.byType(TankDetailScreen), findsOneWidget);
    });

    testWidgets('renders scaffold', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrap('tank-1', storage: svc));
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows tank name after data loads', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank(name: 'Crystal Palace'));
      await tester.pumpWidget(_wrap('tank-1', storage: svc));
      await _advance(tester);
      expect(find.textContaining('Crystal Palace'), findsWidgets);
    });
  });

  group('TankDetailScreen - task completion', () {
    testWidgets('failed completion log write rolls back task completion', (
      tester,
    ) async {
      const tankId = 'tank-detail-task-complete-rollback';
      final svc = InMemoryStorageService();
      final failingStorage = _CompletionLogFailsStorage(svc);
      await svc.saveTank(_makeTank(id: tankId));
      final task = Task(
        id: 'task-detail-complete-rollback',
        tankId: tankId,
        title: 'Rinse prefilter',
        recurrence: RecurrenceType.weekly,
        dueDate: _now.add(const Duration(days: 1)),
        priority: TaskPriority.normal,
        isEnabled: true,
        createdAt: _now,
        updatedAt: _now,
      );
      await svc.saveTask(task);

      await tester.pumpWidget(
        _wrapWithStorage(tankId, storage: failingStorage),
      );
      await _advance(tester);
      await tester.scrollUntilVisible(
        find.text('Rinse prefilter'),
        500,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.tap(find.byTooltip('Complete task'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      final storedTasks = await svc.getTasksForTank(tankId);
      expect(storedTasks.single.completionCount, 0);
      expect(storedTasks.single.lastCompletedAt, isNull);
      expect(
        find.text('Couldn\'t complete that task. Try again.'),
        findsOneWidget,
      );
      expect(find.text('Rinse prefilter completed!'), findsNothing);
    });
  });

  group('TankDetailScreen - quick feeding', () {
    testWidgets('failed feeding log write shows normal error feedback', (
      tester,
    ) async {
      const tankId = 'tank-detail-feed-failure';
      final svc = InMemoryStorageService();
      final failingStorage = _FeedingLogFailsStorage(svc);
      await svc.saveTank(_makeTank(id: tankId));

      await tester.pumpWidget(
        _wrapWithStorage(tankId, storage: failingStorage),
      );
      await _advance(tester);

      await tester.tap(find.byTooltip('Quick actions menu'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byTooltip('Log Feeding'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(await svc.getLogsForTank(tankId), isEmpty);
      expect(
        find.text('Couldn\'t save that feeding. Try again.'),
        findsOneWidget,
      );
      expect(find.text('Feeding logged.'), findsNothing);
    });
  });
}
