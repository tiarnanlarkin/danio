import 'dart:io';

import 'package:danio/models/daily_goal.dart';
import 'package:danio/models/log_entry.dart';
import 'package:danio/models/spaced_repetition.dart';
import 'package:danio/models/task.dart';
import 'package:danio/providers/spaced_repetition_provider.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/screens/emergency_guide_screen.dart';
import 'package:danio/screens/home/widgets/today_board.dart';
import 'package:danio/screens/tasks_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap({
  required DailyGoal dailyGoal,
  required List<Task> tasks,
  List<LogEntry>? logs,
}) {
  final resolvedLogs = logs ?? [_waterTest(), _feeding()];
  return ProviderScope(
    overrides: [
      todaysDailyGoalProvider.overrideWithValue(dailyGoal),
      tasksProvider('tank-1').overrideWith((ref) async => tasks),
      logsProvider('tank-1').overrideWith((ref) async => resolvedLogs),
      spacedRepetitionProvider.overrideWith(
        (ref) => _FakeSrNotifier(_reviewStats()),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(body: TodayBoardCard(tankId: 'tank-1')),
    ),
  );
}

Widget _wrapEmptyBoard({required ReviewStats stats, List<LogEntry>? logs}) {
  final resolvedLogs = logs ?? [_waterTest(), _feeding()];
  return ProviderScope(
    overrides: [
      todaysDailyGoalProvider.overrideWithValue(_completedGoal()),
      tasksProvider('tank-1').overrideWith((ref) async => const []),
      logsProvider('tank-1').overrideWith((ref) async => resolvedLogs),
      spacedRepetitionProvider.overrideWith((ref) => _FakeSrNotifier(stats)),
    ],
    child: const MaterialApp(
      home: Scaffold(body: TodayBoardCard(tankId: 'tank-1')),
    ),
  );
}

ReviewStats _reviewStats({int totalCards = 0, int dueCards = 0}) {
  return ReviewStats(
    totalCards: totalCards,
    dueCards: dueCards,
    weakCards: 0,
    masteredCards: 0,
    averageStrength: 0,
    cardsByMastery: const {},
    reviewsToday: 0,
    currentStreak: 0,
  );
}

class _FakeSrNotifier extends StateNotifier<SpacedRepetitionState>
    implements SpacedRepetitionNotifier {
  _FakeSrNotifier(ReviewStats stats)
    : super(SpacedRepetitionState(cards: const [], stats: stats));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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

LogEntry _waterTest({double? ammonia = 0, double? nitrite = 0}) {
  final now = DateTime.now();
  return LogEntry(
    id: 'water-test',
    tankId: 'tank-1',
    type: LogType.waterTest,
    timestamp: now,
    createdAt: now,
    waterTest: WaterTestResults(ammonia: ammonia, nitrite: nitrite),
  );
}

LogEntry _feeding() {
  final now = DateTime.now();
  return LogEntry(
    id: 'feeding',
    tankId: 'tank-1',
    type: LogType.feeding,
    timestamp: now,
    createdAt: now,
  );
}

void main() {
  test('Today board source keeps visible separators ASCII-safe', () {
    final source = File(
      'lib/screens/home/widgets/today_board.dart',
    ).readAsStringSync();

    expect(source, isNot(contains(String.fromCharCode(0x00b7))));
    expect(source, isNot(contains(String.fromCharCode(0x2014))));
  });

  testWidgets('daily goal bar uses quiet completion copy', (tester) async {
    await tester.pumpWidget(
      _wrap(dailyGoal: _completedGoal(), tasks: [_task()]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Water Change'), findsOneWidget);
    expect(find.text('Daily goal complete!'), findsOneWidget);
    expect(find.textContaining(String.fromCharCode(0x1F389)), findsNothing);
  });

  testWidgets('tank task rows open the task list instead of no-op navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(dailyGoal: _completedGoal(), tasks: [_task()]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Water Change'));
    await tester.pumpAndSettle();

    expect(find.byType(TasksScreen), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
  });

  testWidgets('shows unsafe water priority above tasks', (tester) async {
    await tester.pumpWidget(
      _wrap(
        dailyGoal: _completedGoal(),
        tasks: [_task()],
        logs: [_waterTest(ammonia: 0.5), _feeding()],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unsafe water detected'), findsOneWidget);
    expect(find.text('Water Change'), findsOneWidget);
  });

  testWidgets('unsafe water priority opens Emergency Guide', (tester) async {
    await tester.pumpWidget(
      _wrap(
        dailyGoal: _completedGoal(),
        tasks: [_task()],
        logs: [_waterTest(ammonia: 0.5), _feeding()],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Unsafe water detected'));
    await tester.pumpAndSettle();

    expect(find.byType(EmergencyGuideScreen), findsOneWidget);
  });

  testWidgets('shows water-test priority when no water tests are logged', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapEmptyBoard(stats: _reviewStats(), logs: [_feeding()]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Log a water test'), findsOneWidget);
  });

  testWidgets('empty board due-review state uses quiet action copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapEmptyBoard(stats: _reviewStats(totalCards: 3, dueCards: 2)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reviews are ready'), findsOneWidget);
    expect(find.textContaining(String.fromCharCode(0x1F9E0)), findsNothing);
  });

  testWidgets('empty board lesson state uses quiet action copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapEmptyBoard(stats: _reviewStats(totalCards: 3)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('No tank tasks today - Browse new lessons'),
      findsOneWidget,
    );
    expect(find.textContaining(String.fromCharCode(0x1F4D6)), findsNothing);
  });

  testWidgets('empty board encyclopedia state uses quiet action copy', (
    tester,
  ) async {
    await tester.pumpWidget(_wrapEmptyBoard(stats: _reviewStats()));
    await tester.pumpAndSettle();

    expect(
      find.text('No tank tasks today - Explore the fish encyclopedia'),
      findsOneWidget,
    );
    expect(find.textContaining(String.fromCharCode(0x1F420)), findsNothing);
  });
}
