// Widget tests for TasksScreen.
//
// Run: flutter test test/widget_tests/tasks_screen_test.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/tasks_screen.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
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

UserProfile _makeProfile() => UserProfile(
  id: 'tasks-profile',
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

Widget _wrapWithRouteHost({
  required StorageService storage,
  required String tankId,
  required GlobalKey<_TasksRouteHostState> hostKey,
}) {
  return ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
    child: _TasksRouteHost(key: hostKey, tankId: tankId),
  );
}

class _TasksRouteHost extends StatefulWidget {
  const _TasksRouteHost({super.key, required this.tankId});

  final String tankId;

  @override
  State<_TasksRouteHost> createState() => _TasksRouteHostState();
}

class _TasksRouteHostState extends State<_TasksRouteHost> {
  var _showTasks = true;

  void leaveTasks() => setState(() => _showTasks = false);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _showTasks
          ? TasksScreen(tankId: widget.tankId)
          : const Scaffold(body: SizedBox.shrink()),
    );
  }
}

Widget _wrapWithProfile({
  required InMemoryStorageService storage,
  required SharedPreferences prefs,
  required String tankId,
}) {
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(storage),
      sharedPreferencesProvider.overrideWith((ref) async => prefs),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Consumer(
              builder: (context, ref, _) {
                final profile = ref.watch(userProfileProvider).valueOrNull;
                return Text(
                  profile == null ? 'profile loading' : 'profile ready',
                );
              },
            ),
            Consumer(
              builder: (context, ref, _) {
                final tasks = ref.watch(tasksProvider(tankId)).valueOrNull;
                return Text(
                  tasks == null
                      ? 'tasks loading'
                      : 'task completions: ${tasks.isEmpty ? 0 : tasks.first.completionCount}',
                );
              },
            ),
            Expanded(child: TasksScreen(tankId: tankId)),
          ],
        ),
      ),
    ),
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

class _CompletionLogAndTaskRollbackFailStorage
    extends _DelegatingStorageService {
  _CompletionLogAndTaskRollbackFailStorage(
    super.delegate, {
    this.blockCompletionLog = false,
  });

  final bool blockCompletionLog;
  final completionLogError = StateError('task completion log failed');
  final taskRollbackError = StateError('task rollback failed');
  final completionLogStarted = Completer<void>();
  final releaseCompletionLog = Completer<void>();
  var _taskRollbackPending = false;
  int successfulTaskWrites = 0;
  int maximumCompletionCount = 0;
  int getTankCalls = 0;
  int getTasksForTankCalls = 0;
  int getEquipmentForTankCalls = 0;
  int getLogsForTankCalls = 0;
  int recentLogReads = 0;
  int fullLogReads = 0;

  @override
  Future<Tank?> getTank(String id) async {
    getTankCalls++;
    return super.getTank(id);
  }

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
    if (limit == 50 && after == null) recentLogReads++;
    if (limit == null && after == null) fullLogReads++;
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
      if (!completionLogStarted.isCompleted) completionLogStarted.complete();
      if (blockCompletionLog) await releaseCompletionLog.future;
      throw completionLogError;
    }
    await super.saveLog(log);
  }
}

class _BlockingCompletionLogStorage extends _DelegatingStorageService {
  _BlockingCompletionLogStorage(super.delegate);

  final completionLogStarted = Completer<void>();
  final releaseCompletionLog = Completer<void>();
  int completionTaskWrites = 0;
  int completionLogAttempts = 0;

  @override
  Future<void> saveTask(Task task) async {
    if (task.completionCount > 0) completionTaskWrites++;
    await super.saveTask(task);
  }

  @override
  Future<void> saveLog(LogEntry log) async {
    if (log.type == LogType.taskCompleted) {
      completionLogAttempts++;
      if (!completionLogStarted.isCompleted) completionLogStarted.complete();
      await releaseCompletionLog.future;
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

    testWidgets(
      'profile activity failure does not report durable task completion as failed',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'user_profile': jsonEncode(_makeProfile().toJson()),
        });
        final prefs = await SharedPreferences.getInstance();
        final throwingPrefs = _ThrowingSetStringPrefs(
          prefs,
          (key, _) => key == 'user_profile',
        );
        const tankId = 'tank-task-complete-profile-failure';
        final storage = InMemoryStorageService();
        await storage.saveTank(_makeTank(id: tankId));
        final task = Task(
          id: 'task-complete-profile-failure',
          tankId: tankId,
          title: 'Rinse prefilter',
          recurrence: RecurrenceType.weekly,
          dueDate: _now.add(const Duration(days: 1)),
          priority: TaskPriority.normal,
          isEnabled: true,
          createdAt: _now,
          updatedAt: _now,
        );
        await storage.saveTask(task);

        await tester.pumpWidget(
          _wrapWithProfile(
            storage: storage,
            prefs: throwingPrefs,
            tankId: tankId,
          ),
        );
        await _advance(tester);
        expect(find.text('profile ready'), findsOneWidget);
        expect(find.text('task completions: 0'), findsOneWidget);

        await tester.tap(find.byTooltip('Toggle task'));
        await _advance(tester);

        expect(tester.takeException(), isNull);
        final storedTask = (await storage.getTasksForTank(tankId)).single;
        expect(storedTask.completionCount, 1);
        final completionLogs = (await storage.getLogsForTank(
          tankId,
        )).where((log) => log.type == LogType.taskCompleted).toList();
        expect(completionLogs, hasLength(1));
        final persistedProfile = UserProfile.fromJson(
          jsonDecode(prefs.getString('user_profile')!) as Map<String, dynamic>,
        );
        expect(persistedProfile.totalXp, 0);
        expect(
          find.text(
            'Rinse prefilter completed, but progress couldn\'t update.',
          ),
          findsOneWidget,
        );
        expect(
          find.text('Couldn\'t complete that task. Try again.'),
          findsNothing,
        );
        expect(find.text('Rinse prefilter completed!'), findsNothing);
        expect(find.text('Retry'), findsNothing);
        expect(find.text('task completions: 1'), findsOneWidget);
      },
    );

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

    testWidgets(
      'failed Tasks task rollback reports uncertain completion without unsafe retry',
      (tester) async {
        const tankId = 'tank-tasks-complete-rollback-uncertain';
        const taskId = 'task-tasks-complete-rollback-uncertain';
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
          _wrapWithStorage(storage: failingStorage, tankId: tankId),
        );
        await _advance(tester);
        final taskTile = find.ancestor(
          of: find.text('Rinse prefilter'),
          matching: find.byType(ListTile),
        );
        final completeTaskButton = find.descendant(
          of: taskTile,
          matching: find.byTooltip('Toggle task'),
        );
        final completeTaskIconButton = find.ancestor(
          of: find.descendant(
            of: taskTile,
            matching: find.byIcon(Icons.check_circle_outline),
          ),
          matching: find.byType(IconButton),
        );
        final staleComplete = tester
            .widget<IconButton>(completeTaskIconButton)
            .onPressed;
        expect(staleComplete, isNotNull);
        final tankReadsBefore = failingStorage.getTankCalls;
        final taskReadsBefore = failingStorage.getTasksForTankCalls;
        final equipmentReadsBefore = failingStorage.getEquipmentForTankCalls;
        final recentLogReadsBefore = failingStorage.recentLogReads;
        final fullLogReadsBefore = failingStorage.fullLogReads;

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

        debugPrint = previousDebugPrint;
        expect(tester.takeException(), isNull);
        final storedTask = (await svc.getTasksForTank(tankId)).single;
        expect(storedTask.completionCount, 1);
        expect(storedTask.lastCompletedAt, isNotNull);
        expect(failingStorage.successfulTaskWrites, 1);
        expect(failingStorage.maximumCompletionCount, 1);
        expect(await svc.getLogsForTank(tankId), isEmpty);
        final visibleTaskTile = find.ancestor(
          of: find.text('Rinse prefilter'),
          matching: find.byType(ListTile),
        );
        final visibleCompleteTaskIconButton = find.ancestor(
          of: find.descendant(
            of: visibleTaskTile,
            matching: find.byIcon(Icons.check_circle_outline),
          ),
          matching: find.byType(IconButton),
        );
        expect(
          tester.widget<IconButton>(visibleCompleteTaskIconButton).onPressed,
          isNull,
        );
        expect(
          failingStorage.getTankCalls,
          greaterThanOrEqualTo(tankReadsBefore + 2),
        );
        expect(
          failingStorage.getTasksForTankCalls,
          greaterThanOrEqualTo(taskReadsBefore + 2),
        );
        expect(
          failingStorage.getEquipmentForTankCalls,
          greaterThan(equipmentReadsBefore),
        );
        expect(failingStorage.recentLogReads, recentLogReadsBefore + 1);
        expect(failingStorage.fullLogReads, fullLogReadsBefore + 1);

        final combinedLog = debugMessages.join('\n');
        expect(
          combinedLog,
          contains('TasksScreenTaskCompletionCompensationException'),
        );
        expect(combinedLog, contains('task completion log failed'));
        expect(combinedLog, contains('task rollback failed'));
        expect(combinedLog, contains(taskId));
        expect(combinedLog, contains(tankId));
      },
    );

    testWidgets('in-flight task completion ignores a repeated stale callback', (
      tester,
    ) async {
      const tankId = 'tank-task-complete-in-flight';
      final svc = InMemoryStorageService();
      final blockingStorage = _BlockingCompletionLogStorage(svc);
      await svc.saveTank(_makeTank(id: tankId));
      final task = Task(
        id: 'task-complete-in-flight',
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
        _wrapWithStorage(storage: blockingStorage, tankId: tankId),
      );
      await _advance(tester);
      final completeTaskButton = find.ancestor(
        of: find.byIcon(Icons.check_circle_outline),
        matching: find.byType(IconButton),
      );
      final capturedComplete = tester
          .widget<IconButton>(completeTaskButton)
          .onPressed;
      expect(capturedComplete, isNotNull);

      capturedComplete!();
      await blockingStorage.completionLogStarted.future;
      capturedComplete();
      await tester.pump();

      expect(blockingStorage.completionTaskWrites, 1);
      expect(blockingStorage.completionLogAttempts, 1);

      blockingStorage.releaseCompletionLog.complete();
      await _advance(tester);

      final storedTask = (await svc.getTasksForTank(tankId)).single;
      expect(storedTask.completionCount, 1);
      expect(
        (await svc.getLogsForTank(
          tankId,
        )).where((log) => log.type == LogType.taskCompleted),
        hasLength(1),
      );
      expect(blockingStorage.completionTaskWrites, 1);
      expect(blockingStorage.completionLogAttempts, 1);
      expect(find.text('Rinse prefilter completed!'), findsOneWidget);
    });

    testWidgets(
      'uncertain completion reloads authority after leaving Tasks',
      (tester) async {
        const tankId = 'tank-task-complete-unmounted';
        final svc = InMemoryStorageService();
        final failingStorage = _CompletionLogAndTaskRollbackFailStorage(
          svc,
          blockCompletionLog: true,
        );
        final hostKey = GlobalKey<_TasksRouteHostState>();
        await svc.saveTank(_makeTank(id: tankId));
        final task = Task(
          id: 'task-complete-unmounted',
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
          _wrapWithRouteHost(
            storage: failingStorage,
            tankId: tankId,
            hostKey: hostKey,
          ),
        );
        await _advance(tester);
        final completeTaskButton = find.ancestor(
          of: find.byIcon(Icons.check_circle_outline),
          matching: find.byType(IconButton),
        );
        final capturedComplete = tester
            .widget<IconButton>(completeTaskButton)
            .onPressed;
        expect(capturedComplete, isNotNull);

        capturedComplete!();
        await failingStorage.completionLogStarted.future;
        hostKey.currentState!.leaveTasks();
        await tester.pump();
        failingStorage.releaseCompletionLog.complete();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(tester.takeException(), isNull);
        final storedTask = (await svc.getTasksForTank(tankId)).single;
        expect(storedTask.completionCount, 1);
        expect(await svc.getLogsForTank(tankId), isEmpty);
        expect(failingStorage.getTankCalls, greaterThanOrEqualTo(2));
        expect(failingStorage.getTasksForTankCalls, greaterThanOrEqualTo(3));
        expect(failingStorage.getEquipmentForTankCalls, 1);
        expect(failingStorage.recentLogReads, 1);
        expect(failingStorage.fullLogReads, 1);
      },
    );

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
