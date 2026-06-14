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

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(seconds: 1));
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
  });
}
