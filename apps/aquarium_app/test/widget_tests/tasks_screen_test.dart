// Widget tests for TasksScreen.
//
// Run: flutter test test/widget_tests/tasks_screen_test.dart

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

Widget _wrap({InMemoryStorageService? storage}) {
  final svc = storage ?? InMemoryStorageService();
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(svc),
    ],
    child: const MaterialApp(
      home: TasksScreen(tankId: 'tank-1'),
    ),
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
        find.byWidgetPredicate((w) =>
            w is Text &&
            (w.data?.contains('Add Task') == true ||
                w.data?.contains('success') == true ||
                w.data?.contains('task') == true)),
        findsWidgets,
      );
    });

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
  });
}
