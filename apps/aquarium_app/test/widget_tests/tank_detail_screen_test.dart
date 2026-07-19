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
import 'package:danio/providers/tank_visual_event_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/models/models.dart';
import 'package:danio/widgets/tank_delete_failure_feedback_listener.dart';

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

Widget _wrapWithHost(String tankId, {required StorageService storage}) {
  final messengerKey = GlobalKey<ScaffoldMessengerState>();
  return ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
    child: MaterialApp(
      scaffoldMessengerKey: messengerKey,
      builder: (context, child) => TankDeleteFailureFeedbackListener(
        scaffoldMessengerKey: messengerKey,
        child: child ?? const SizedBox.shrink(),
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => TankDetailScreen(tankId: tankId),
                ),
              );
            },
            child: const Text('Open tank'),
          ),
        ),
      ),
    ),
  );
}

Widget _wrapWithPulseProbe(String tankId, {required StorageService storage}) {
  return ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
    child: MaterialApp(
      home: Stack(
        children: [
          TankDetailScreen(tankId: tankId),
          Positioned(
            left: 0,
            top: 0,
            child: Consumer(
              builder: (context, ref, _) => Text(
                'pulse ${ref.watch(tankFeedingPulseProvider(tankId))}',
                textDirection: TextDirection.ltr,
              ),
            ),
          ),
        ],
      ),
    ),
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

class _MissingTankAfterLoadStorage extends _DelegatingStorageService {
  _MissingTankAfterLoadStorage(super.delegate, {required this.missingTankId});

  final String missingTankId;
  bool tankMissing = false;

  @override
  Future<Tank?> getTank(String id) async {
    if (tankMissing && id == missingTankId) {
      return null;
    }
    return super.getTank(id);
  }
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

class _CompletionLogAndTaskRollbackFailStorage
    extends _DelegatingStorageService {
  _CompletionLogAndTaskRollbackFailStorage(super.delegate);

  final completionLogError = StateError('task completion log failed');
  final taskRollbackError = StateError('task rollback failed');
  var _taskRollbackPending = false;
  int successfulTaskWrites = 0;
  int maximumCompletionCount = 0;
  int getTasksForTankCalls = 0;
  int getEquipmentForTankCalls = 0;
  int getLogsForTankCalls = 0;

  @override
  Future<List<Task>> getTasksForTank(String? tankId) async {
    getTasksForTankCalls++;
    return super.getTasksForTank(tankId);
  }

  @override
  Future<List<Equipment>> getEquipmentForTank(String tankId) async {
    getEquipmentForTankCalls++;
    return super.getEquipmentForTank(tankId);
  }

  @override
  Future<List<LogEntry>> getLogsForTank(
    String tankId, {
    int? limit,
    DateTime? after,
  }) async {
    getLogsForTankCalls++;
    return super.getLogsForTank(tankId, limit: limit, after: after);
  }

  @override
  Future<void> saveTask(Task task) async {
    if (_taskRollbackPending) {
      _taskRollbackPending = false;
      throw taskRollbackError;
    }
    successfulTaskWrites++;
    maximumCompletionCount = task.completionCount > maximumCompletionCount
        ? task.completionCount
        : maximumCompletionCount;
    await super.saveTask(task);
  }

  @override
  Future<void> saveLog(LogEntry log) async {
    if (log.type == LogType.taskCompleted) {
      _taskRollbackPending = true;
      throw completionLogError;
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

class _TankDeleteFailsStorage extends _DelegatingStorageService {
  _TankDeleteFailsStorage(super.delegate);

  @override
  Future<void> deleteTank(String id) async {
    throw StateError('tank delete failed');
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
    testWidgets(
      'tank-detail task completion rejects a missing parent before writing',
      (tester) async {
        const tankId = 'tank-detail-task-complete-missing-parent';
        final svc = InMemoryStorageService();
        final missingTankStorage = _MissingTankAfterLoadStorage(
          svc,
          missingTankId: tankId,
        );
        await svc.saveTank(_makeTank(id: tankId));
        final task = Task(
          id: 'task-detail-complete-missing-parent',
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
          _wrapWithStorage(tankId, storage: missingTankStorage),
        );
        await _advance(tester);
        await tester.scrollUntilVisible(
          find.text('Rinse prefilter'),
          500,
          scrollable: find.byType(Scrollable).first,
        );
        final taskTile = find.ancestor(
          of: find.text('Rinse prefilter'),
          matching: find.byType(ListTile),
        );
        final completeTaskButton = find.descendant(
          of: taskTile,
          matching: find.byTooltip('Complete task'),
        );
        await tester.ensureVisible(completeTaskButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        missingTankStorage.tankMissing = true;
        expect(await missingTankStorage.getTank(tankId), isNull);
        expect(await svc.getTasksForTank(tankId), hasLength(1));

        await tester.tap(completeTaskButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(tester.takeException(), isNull);
        final storedTask = (await svc.getTasksForTank(tankId)).single;
        expect(storedTask.completionCount, 0);
        expect(storedTask.lastCompletedAt, isNull);
        expect(await svc.getLogsForTank(tankId), isEmpty);
        expect(
          find.text('Couldn\'t complete that task. Try again.'),
          findsOneWidget,
        );
        expect(find.text('Rinse prefilter completed!'), findsNothing);
      },
    );

    testWidgets(
      'stale tank-detail equipment-task completion does not recreate task or service equipment',
      (tester) async {
        const tankId = 'tank-detail-task-complete-stale-id';
        final svc = InMemoryStorageService();
        final lastServiced = _now.subtract(const Duration(days: 30));
        await svc.saveTank(_makeTank(id: tankId));
        final equipment = Equipment(
          id: 'equipment-detail-task-complete-stale-id',
          tankId: tankId,
          type: EquipmentType.filter,
          name: 'Canister filter',
          maintenanceIntervalDays: 30,
          lastServiced: lastServiced,
          createdAt: _now,
          updatedAt: _now,
        );
        await svc.saveEquipment(equipment);
        final task = Task(
          id: 'task-detail-complete-stale-id',
          tankId: tankId,
          title: 'Rinse prefilter',
          recurrence: RecurrenceType.weekly,
          dueDate: _now.add(const Duration(days: 1)),
          priority: TaskPriority.normal,
          relatedEquipmentId: equipment.id,
          isEnabled: true,
          createdAt: _now,
          updatedAt: _now,
        );
        await svc.saveTask(task);

        await tester.pumpWidget(_wrap(tankId, storage: svc));
        await _advance(tester);
        await tester.scrollUntilVisible(
          find.text('Rinse prefilter'),
          500,
          scrollable: find.byType(Scrollable).first,
        );
        final taskTile = find.ancestor(
          of: find.text('Rinse prefilter'),
          matching: find.byType(ListTile),
        );
        final completeTaskButton = find.descendant(
          of: taskTile,
          matching: find.byTooltip('Complete task'),
        );
        await tester.ensureVisible(completeTaskButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await svc.deleteTask(task.id);
        expect(await svc.getTasksForTank(tankId), isEmpty);

        await tester.tap(completeTaskButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(tester.takeException(), isNull);
        expect(await svc.getTasksForTank(tankId), isEmpty);
        final storedEquipment = (await svc.getEquipmentForTank(tankId)).single;
        expect(storedEquipment.lastServiced, lastServiced);
        expect(await svc.getLogsForTank(tankId), isEmpty);
        expect(
          find.text('Couldn\'t complete that task. Try again.'),
          findsOneWidget,
        );
        expect(find.text('Rinse prefilter completed!'), findsNothing);
      },
    );

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
      final taskTile = find.ancestor(
        of: find.text('Rinse prefilter'),
        matching: find.byType(ListTile),
      );
      final completeTaskButton = find.descendant(
        of: taskTile,
        matching: find.byTooltip('Complete task'),
      );
      await tester.ensureVisible(completeTaskButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(completeTaskButton);
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

    testWidgets(
      'failed tank-detail task rollback reports uncertain completion without unsafe retry',
      (tester) async {
        const tankId = 'tank-detail-task-complete-rollback-uncertain';
        const taskId = 'task-detail-complete-rollback-uncertain';
        final svc = InMemoryStorageService();
        final failingStorage = _CompletionLogAndTaskRollbackFailStorage(svc);
        await svc.saveTank(_makeTank(id: tankId));
        final task = Task(
          id: taskId,
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
        final debugMessages = <String>[];
        final previousDebugPrint = debugPrint;
        debugPrint = (String? message, {int? wrapWidth}) {
          if (message != null) debugMessages.add(message);
        };
        addTearDown(() => debugPrint = previousDebugPrint);

        await tester.pumpWidget(
          _wrapWithStorage(tankId, storage: failingStorage),
        );
        await _advance(tester);
        await tester.scrollUntilVisible(
          find.text('Rinse prefilter'),
          500,
          scrollable: find.byType(Scrollable).first,
        );
        final taskTile = find.ancestor(
          of: find.text('Rinse prefilter'),
          matching: find.byType(ListTile),
        );
        final completeTaskButton = find.descendant(
          of: taskTile,
          matching: find.byTooltip('Complete task'),
        );
        final completeTaskIconButton = find.descendant(
          of: taskTile,
          matching: find.byType(IconButton),
        );
        await tester.ensureVisible(completeTaskButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        final staleComplete = tester
            .widget<IconButton>(completeTaskIconButton)
            .onPressed;
        expect(staleComplete, isNotNull);
        final taskReadsBefore = failingStorage.getTasksForTankCalls;
        final equipmentReadsBefore = failingStorage.getEquipmentForTankCalls;
        final logReadsBefore = failingStorage.getLogsForTankCalls;

        await tester.tap(completeTaskButton);
        await _advance(tester);

        expect(
          find.text(
            'Rinse prefilter may already have been completed. Its activity '
            'log wasn\'t saved, and task restoration is uncertain. Check this '
            'tank\'s tasks and recent activity.',
          ),
          findsOneWidget,
        );
        expect(
          find.text('Couldn\'t complete that task. Try again.'),
          findsNothing,
        );
        expect(
          find.textContaining(RegExp('try again', caseSensitive: false)),
          findsNothing,
        );
        expect(find.text('Retry'), findsNothing);
        expect(find.text('Rinse prefilter completed!'), findsNothing);

        staleComplete!();
        await _advance(tester);
        final visibleTaskTile = find.ancestor(
          of: find.text('Rinse prefilter'),
          matching: find.byType(ListTile),
        );
        final visibleCompleteTaskButton = find.descendant(
          of: visibleTaskTile,
          matching: find.byTooltip('Complete task'),
        );
        final visibleCompleteTaskIconButton = find.descendant(
          of: visibleTaskTile,
          matching: find.byType(IconButton),
        );
        await tester.tap(visibleCompleteTaskButton);
        await _advance(tester);

        debugPrint = previousDebugPrint;
        expect(tester.takeException(), isNull);
        final storedTask = (await svc.getTasksForTank(tankId)).single;
        expect(storedTask.completionCount, 1);
        expect(storedTask.lastCompletedAt, isNotNull);
        expect(failingStorage.successfulTaskWrites, 1);
        expect(failingStorage.maximumCompletionCount, 1);
        expect(await svc.getLogsForTank(tankId), isEmpty);
        expect(
          tester.widget<IconButton>(visibleCompleteTaskIconButton).onPressed,
          isNull,
        );
        expect(
          failingStorage.getTasksForTankCalls,
          greaterThan(taskReadsBefore),
        );
        expect(
          failingStorage.getEquipmentForTankCalls,
          greaterThan(equipmentReadsBefore),
        );
        expect(
          failingStorage.getLogsForTankCalls,
          greaterThan(logReadsBefore),
        );

        final combinedLog = debugMessages.join('\n');
        expect(combinedLog, contains('task completion log failed'));
        expect(combinedLog, contains('task rollback failed'));
        expect(combinedLog, contains(taskId));
        expect(combinedLog, contains(tankId));
      },
    );
  });

  group('TankDetailScreen - quick feeding', () {
    testWidgets('successful feeding log emits a tank feeding pulse', (
      tester,
    ) async {
      const tankId = 'tank-detail-feed-pulse';
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank(id: tankId));

      await tester.pumpWidget(_wrapWithPulseProbe(tankId, storage: svc));
      await _advance(tester);

      expect(find.text('pulse 0'), findsOneWidget);

      await tester.tap(find.byTooltip('Quick actions menu'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byTooltip('Log Feeding'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final logs = await svc.getLogsForTank(tankId);
      expect(logs.where((log) => log.type == LogType.feeding), hasLength(1));
      expect(find.text('pulse 1'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 300));
    });

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

    testWidgets('missing tank ids do not create orphan quick feeding logs', (
      tester,
    ) async {
      const tankId = 'tank-detail-feed-missing-parent';
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank(id: tankId));

      await tester.pumpWidget(_wrapWithStorage(tankId, storage: svc));
      await _advance(tester);

      await svc.deleteTank(tankId);
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

  group('TankDetailScreen - tank deletion', () {
    testWidgets('failed delete expiry restores tank with retry feedback', (
      tester,
    ) async {
      const tankId = 'tank-detail-delete-expiry-failure';
      final svc = InMemoryStorageService();
      final failingStorage = _TankDeleteFailsStorage(svc);
      await svc.saveTank(_makeTank(id: tankId, name: 'Retry Reef'));

      await tester.pumpWidget(_wrapWithHost(tankId, storage: failingStorage));
      await tester.tap(find.text('Open tank'));
      await _advance(tester);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Delete Tank').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Delete Tank').last);
      await tester.pump();

      expect(find.text('Retry Reef deleted'), findsWidgets);
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(await svc.getTank(tankId), isNotNull);
      expect(
        find.text("Couldn't delete Retry Reef. Try again."),
        findsOneWidget,
      );
    });
  });
}
