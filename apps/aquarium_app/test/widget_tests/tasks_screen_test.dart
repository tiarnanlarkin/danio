// Widget tests for TasksScreen.
//
// Run: flutter test test/widget_tests/tasks_screen_test.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/tasks_screen.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/models/models.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _now = DateTime.now();

Tank _makeTank({String id = 'tank-1'}) => Tank(
  id: id,
  name: 'Test Tank',
  type: TankType.freshwater,
  volumeLitres: 100,
  startDate: _now,
  targets: WaterTargets.freshwaterTropical(),
  createdAt: _now,
  updatedAt: _now,
);

Widget _wrap({InMemoryStorageService? storage, String tankId = 'tank-1'}) {
  final svc = storage ?? InMemoryStorageService();
  return ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(svc)],
    child: MaterialApp(home: TasksScreen(tankId: tankId)),
  );
}

Widget _wrapWithStorage({
  required StorageService storage,
  String tankId = 'tank-1',
}) {
  return ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
    child: MaterialApp(home: TasksScreen(tankId: tankId)),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(seconds: 1));
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

class _MissingTankStorage extends _DelegatingStorageService {
  _MissingTankStorage(super.delegate, {required this.missingTankId});

  final String missingTankId;

  @override
  Future<Tank?> getTank(String id) async {
    if (id == missingTankId) {
      return null;
    }
    return super.getTank(id);
  }
}

class _TaskSaveFailsStorage extends _DelegatingStorageService {
  _TaskSaveFailsStorage(super.delegate, {required this.failingTaskId});

  final String failingTaskId;

  @override
  Future<void> saveTask(Task task) async {
    if (task.id == failingTaskId) {
      throw StateError('task save failed');
    }
    await super.saveTask(task);
  }
}

class _TaskDeleteFailsStorage extends _DelegatingStorageService {
  _TaskDeleteFailsStorage(super.delegate, {required this.failingTaskId});

  final String failingTaskId;

  @override
  Future<void> deleteTask(String id) async {
    if (id == failingTaskId) {
      throw StateError('task delete failed');
    }
    await super.deleteTask(id);
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TasksScreen — empty state', () {
    test('source keeps task actions clear of the persistent bottom dock', () {
      final source = File('lib/screens/tasks_screen.dart').readAsStringSync();

      expect(source, contains('DanioBottomDock.contentClearance'));
    });

    testWidgets('renders without throwing', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrap(storage: svc));
      await _advance(tester);
      expect(find.byType(TasksScreen), findsOneWidget);
    });

    testWidgets('shows app bar with Tasks title', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrap(storage: svc));
      await _advance(tester);
      expect(find.text('Tasks'), findsOneWidget);
    });

    testWidgets('shows empty state when no tasks', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrap(storage: svc));
      await _advance(tester);
      // Should show empty state or Add Task button
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              (w.data?.contains('Add Task') == true ||
                  w.data?.contains('success') == true ||
                  w.data?.contains('task') == true),
        ),
        findsWidgets,
      );
    });

    testWidgets(
      'empty state title uses iconography instead of raw emoji text',
      (tester) async {
        final svc = InMemoryStorageService();
        await svc.saveTank(_makeTank());
        await tester.pumpWidget(_wrap(storage: svc));
        await _advance(tester);

        expect(find.byIcon(Icons.task_alt), findsWidgets);
        expect(find.text('Set yourself up for success!'), findsOneWidget);
        expect(
          find.textContaining('Set yourself up for success! ✅'),
          findsNothing,
        );
      },
    );

    testWidgets('shows scaffold', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrap(storage: svc));
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('TasksScreen — with tasks', () {
    testWidgets('renders task list when tasks exist', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      final task = Task(
        id: 'task-1',
        tankId: 'tank-1',
        title: 'Water Change',
        recurrence: RecurrenceType.weekly,
        dueDate: _now.add(const Duration(days: 1)),
        priority: TaskPriority.normal,
        isEnabled: true,
        createdAt: _now,
        updatedAt: _now,
      );
      await svc.saveTask(task);
      await tester.pumpWidget(_wrap(storage: svc));
      await _advance(tester);
      expect(find.text('Water Change'), findsOneWidget);
    });

    testWidgets('tablet keeps task section headers and cards readable', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      final task = Task(
        id: 'tablet-task',
        tankId: 'tank-1',
        title: 'Water Change',
        recurrence: RecurrenceType.weekly,
        dueDate: _now.add(const Duration(days: 1)),
        priority: TaskPriority.normal,
        isEnabled: true,
        createdAt: _now,
        updatedAt: _now,
      );
      await svc.saveTask(task);

      await tester.pumpWidget(_wrap(storage: svc));
      await _advance(tester);

      final header = find
          .ancestor(of: find.text('Upcoming'), matching: find.byType(Row))
          .first;
      expect(tester.getSize(header).width, lessThanOrEqualTo(720));

      final taskCard = find
          .ancestor(of: find.text('Water Change'), matching: find.byType(Card))
          .first;
      expect(tester.getSize(taskCard).width, lessThanOrEqualTo(720));
    });

    testWidgets('adding a task shows success feedback', (tester) async {
      const tankId = 'tank-task-add-feedback';
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank(id: tankId));

      await tester.pumpWidget(_wrap(storage: svc, tankId: tankId));
      await _advance(tester);

      await tester.tap(find.byTooltip('Add a new task'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(
        find.byType(TextFormField).first,
        'Rinse prefilter',
      );
      await tester.tap(find.text('Add').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final tasks = await svc.getTasksForTank(tankId);
      expect(tasks.single.title, 'Rinse prefilter');
      expect(find.text('Rinse prefilter added.'), findsOneWidget);
    });

    testWidgets('stale task edit ids are not recreated by save', (
      tester,
    ) async {
      const tankId = 'tank-task-stale-edit';
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank(id: tankId));
      final task = Task(
        id: 'task-stale-edit',
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

      await tester.pumpWidget(_wrap(storage: svc, tankId: tankId));
      await _advance(tester);

      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit').last);
      await tester.pumpAndSettle();

      await svc.deleteTask(task.id);
      expect(await svc.getTasksForTank(tankId), isEmpty);

      await tester.tap(find.text('Save').last);
      await _advance(tester);

      expect(await svc.getTasksForTank(tankId), isEmpty);
      expect(find.text('Edit Task'), findsOneWidget);
      expect(
        find.text('Couldn\'t complete that action. Try again!'),
        findsOneWidget,
      );
    });

    testWidgets('missing tank ids do not create orphan tasks', (
      tester,
    ) async {
      const tankId = 'tank-task-missing-parent';
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank(id: tankId));

      await tester.pumpWidget(_wrap(storage: svc, tankId: tankId));
      await _advance(tester);

      await tester.tap(find.byTooltip('Add a new task'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(
        find.byType(TextFormField).first,
        'Rinse prefilter',
      );

      await svc.deleteTank(tankId);
      expect(await svc.getTank(tankId), isNull);

      await tester.tap(find.text('Add').last);
      await _advance(tester);

      expect(await svc.getTasksForTank(tankId), isEmpty);
      expect(find.text('Add Task'), findsWidgets);
      expect(
        find.text('Couldn\'t complete that action. Try again!'),
        findsOneWidget,
      );
    });

    testWidgets(
      'failed primary delete keeps task visible with error feedback',
      (
        tester,
      ) async {
        const tankId = 'tank-task-delete-failure';
        const taskId = 'task-delete-failure';
        final svc = InMemoryStorageService();
        final failingStorage = _TaskDeleteFailsStorage(
          svc,
          failingTaskId: taskId,
        );
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

        await tester.pumpWidget(
          _wrapWithStorage(storage: failingStorage, tankId: tankId),
        );
        await _advance(tester);

        await tester.tap(find.byType(PopupMenuButton<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete').last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete Task'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(tester.takeException(), isNull);
        final remainingTasks = await svc.getTasksForTank(tankId);
        expect(remainingTasks, hasLength(1));
        expect(remainingTasks.single.id, task.id);
        expect(find.text('Rinse prefilter'), findsOneWidget);
        expect(
          find.text("Couldn't delete that task. Give it another go!"),
          findsOneWidget,
        );
        expect(find.text('Task deleted'), findsNothing);
        expect(find.text('Undo'), findsNothing);
      },
    );

    testWidgets('deleting a task shows undo and restores the task', (
      tester,
    ) async {
      const tankId = 'tank-task-undo';
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank(id: tankId));
      final task = Task(
        id: 'task-undo',
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

      await tester.pumpWidget(_wrap(storage: svc, tankId: tankId));
      await _advance(tester);

      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete Task'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(await svc.getTasksForTank(tankId), isEmpty);
      expect(find.text('Rinse prefilter'), findsNothing);
      expect(find.text('Task deleted'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final restoredTasks = await svc.getTasksForTank(tankId);
      expect(restoredTasks, hasLength(1));
      expect(restoredTasks.single.id, task.id);
      expect(find.text('Rinse prefilter'), findsOneWidget);
    });

    testWidgets(
      'undo does not restore a task after its parent tank was deleted',
      (
        tester,
      ) async {
        const tankId = 'tank-task-undo-missing-parent';
        final svc = InMemoryStorageService();
        await svc.saveTank(_makeTank(id: tankId));
        final task = Task(
          id: 'task-undo-missing-parent',
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

        await tester.pumpWidget(_wrap(storage: svc, tankId: tankId));
        await _advance(tester);

        await tester.tap(find.byType(PopupMenuButton<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete').last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete Task'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(await svc.getTasksForTank(tankId), isEmpty);
        expect(find.text('Undo'), findsOneWidget);

        await svc.deleteTank(tankId);
        expect(await svc.getTank(tankId), isNull);

        await tester.tap(find.text('Undo'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(tester.takeException(), isNull);
        expect(await svc.getTasksForTank(tankId), isEmpty);
        expect(
          find.text('Couldn\'t restore that task. Try again.'),
          findsOneWidget,
        );
      },
    );

    testWidgets('failed delete undo keeps task deleted with error feedback', (
      tester,
    ) async {
      const tankId = 'tank-task-undo-failure';
      final svc = InMemoryStorageService();
      final failingStorage = _TaskSaveFailsStorage(
        svc,
        failingTaskId: 'task-undo-failure',
      );
      await svc.saveTank(_makeTank(id: tankId));
      final task = Task(
        id: 'task-undo-failure',
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
        _wrapWithStorage(storage: failingStorage, tankId: tankId),
      );
      await _advance(tester);

      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete Task'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(await svc.getTasksForTank(tankId), isEmpty);
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(await svc.getTasksForTank(tankId), isEmpty);
      expect(
        find.text('Couldn\'t restore that task. Try again.'),
        findsOneWidget,
      );
    });

    testWidgets('completing a task shows success feedback', (tester) async {
      const tankId = 'tank-task-complete-feedback';
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank(id: tankId));
      final task = Task(
        id: 'task-complete-feedback',
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

      await tester.pumpWidget(_wrap(storage: svc, tankId: tankId));
      await _advance(tester);

      await tester.tap(find.byTooltip('Toggle task'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final completedTasks = await svc.getTasksForTank(tankId);
      expect(completedTasks.single.completionCount, 1);
      expect(find.text('Rinse prefilter completed!'), findsOneWidget);
    });

    testWidgets('stale task completion does not recreate a deleted task', (
      tester,
    ) async {
      const tankId = 'tank-task-complete-stale-id';
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank(id: tankId));
      final task = Task(
        id: 'task-complete-stale-id',
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

      await tester.pumpWidget(_wrap(storage: svc, tankId: tankId));
      await _advance(tester);

      await svc.deleteTask(task.id);
      expect(await svc.getTasksForTank(tankId), isEmpty);

      await tester.tap(find.byTooltip('Toggle task'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(await svc.getTasksForTank(tankId), isEmpty);
      expect(await svc.getLogsForTank(tankId), isEmpty);
      expect(
        find.text('Couldn\'t complete that task. Try again.'),
        findsOneWidget,
      );
      expect(find.text('Rinse prefilter completed!'), findsNothing);
    });

    testWidgets('task completion rejects a missing parent before writing', (
      tester,
    ) async {
      const tankId = 'tank-task-complete-missing-parent';
      final svc = InMemoryStorageService();
      final missingTankStorage = _MissingTankStorage(
        svc,
        missingTankId: tankId,
      );
      await svc.saveTank(_makeTank(id: tankId));
      final task = Task(
        id: 'task-complete-missing-parent',
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
        _wrapWithStorage(storage: missingTankStorage, tankId: tankId),
      );
      await _advance(tester);

      expect(await missingTankStorage.getTank(tankId), isNull);
      expect(await svc.getTasksForTank(tankId), hasLength(1));

      await tester.tap(find.byTooltip('Toggle task'));
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
    });

    testWidgets('failed completion log write rolls back task completion', (
      tester,
    ) async {
      const tankId = 'tank-task-complete-rollback';
      final svc = InMemoryStorageService();
      final failingStorage = _CompletionLogFailsStorage(svc);
      await svc.saveTank(_makeTank(id: tankId));
      final task = Task(
        id: 'task-complete-rollback',
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
        _wrapWithStorage(storage: failingStorage, tankId: tankId),
      );
      await _advance(tester);

      await tester.tap(find.byTooltip('Toggle task'));
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

    testWidgets('snoozing a task shows success feedback', (tester) async {
      const tankId = 'tank-task-snooze-feedback';
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank(id: tankId));
      final task = Task(
        id: 'task-snooze-feedback',
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

      await tester.pumpWidget(_wrap(storage: svc, tankId: tankId));
      await _advance(tester);

      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Snooze').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('1 day'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final storedTask = (await svc.getTasksForTank(tankId)).single;
      expect(storedTask.dueDate, isNot(task.dueDate));
      expect(storedTask.dueDate!.isAfter(task.dueDate!), isTrue);
      expect(find.text('Rinse prefilter snoozed for 1 day.'), findsOneWidget);
    });

    testWidgets('stale task snooze does not recreate a deleted task', (
      tester,
    ) async {
      const tankId = 'tank-task-stale-snooze';
      const taskId = 'task-stale-snooze';
      final svc = InMemoryStorageService();
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

      await tester.pumpWidget(_wrap(storage: svc, tankId: tankId));
      await _advance(tester);

      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Snooze').last);
      await tester.pumpAndSettle();
      await svc.deleteTask(taskId);
      expect(await svc.getTasksForTank(tankId), isEmpty);

      await tester.tap(find.text('1 day'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(await svc.getTasksForTank(tankId), isEmpty);
      expect(
        find.text('Couldn\'t snooze that task. Try again.'),
        findsOneWidget,
      );
      expect(find.text('Rinse prefilter snoozed for 1 day.'), findsNothing);
    });

    testWidgets('failed snooze keeps task unchanged with error feedback', (
      tester,
    ) async {
      const tankId = 'tank-task-snooze-failure';
      final svc = InMemoryStorageService();
      final failingStorage = _TaskSaveFailsStorage(
        svc,
        failingTaskId: 'task-snooze-failure',
      );
      await svc.saveTank(_makeTank(id: tankId));
      final task = Task(
        id: 'task-snooze-failure',
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
        _wrapWithStorage(storage: failingStorage, tankId: tankId),
      );
      await _advance(tester);

      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Snooze').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('1 day'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      final storedTask = (await svc.getTasksForTank(tankId)).single;
      expect(storedTask.dueDate, task.dueDate);
      expect(
        find.text('Couldn\'t snooze that task. Try again.'),
        findsOneWidget,
      );
    });
  });
}
