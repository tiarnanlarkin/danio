import 'package:danio/models/daily_goal.dart';
import 'package:danio/models/task.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/screens/home/widgets/today_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap({required DailyGoal dailyGoal, required List<Task> tasks}) {
  return ProviderScope(
    overrides: [
      todaysDailyGoalProvider.overrideWithValue(dailyGoal),
      tasksProvider('tank-1').overrideWith((ref) async => tasks),
    ],
    child: const MaterialApp(
      home: Scaffold(body: TodayBoardCard(tankId: 'tank-1')),
    ),
  );
}

DailyGoal _completedGoal() {
  return DailyGoal(
    date: DateTime(2026, 5, 23),
    targetXp: 20,
    earnedXp: 20,
    isCompleted: true,
    isToday: true,
  );
}

Task _task() {
  final now = DateTime(2026, 5, 23, 12);
  return Task(
    id: 'task-1',
    tankId: 'tank-1',
    title: 'Water Change',
    recurrence: RecurrenceType.weekly,
    dueDate: now.add(const Duration(days: 1)),
    priority: TaskPriority.normal,
    isEnabled: true,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  testWidgets('daily goal bar uses quiet completion copy', (tester) async {
    await tester.pumpWidget(
      _wrap(dailyGoal: _completedGoal(), tasks: [_task()]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Water Change'), findsOneWidget);
    expect(find.text('Daily goal complete!'), findsOneWidget);
    expect(find.textContaining(String.fromCharCode(0x1F389)), findsNothing);
  });
}
