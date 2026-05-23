import 'package:danio/models/daily_goal.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/widgets/daily_goal_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(DailyGoal? dailyGoal) {
  return ProviderScope(
    overrides: [todaysDailyGoalProvider.overrideWithValue(dailyGoal)],
    child: const MaterialApp(home: Scaffold(body: DailyGoalProgress())),
  );
}

DailyGoal _goal({
  required int targetXp,
  required int earnedXp,
  required bool isCompleted,
}) {
  return DailyGoal(
    date: DateTime(2026, 5, 23),
    targetXp: targetXp,
    earnedXp: earnedXp,
    isCompleted: isCompleted,
    isToday: true,
  );
}

void main() {
  testWidgets('shows quiet completion copy when the daily goal is complete', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(_goal(targetXp: 20, earnedXp: 20, isCompleted: true)),
    );

    expect(find.text('Goal complete!'), findsOneWidget);
    expect(find.textContaining(String.fromCharCode(0x1F389)), findsNothing);
  });

  testWidgets('shows remaining XP while the daily goal is in progress', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(_goal(targetXp: 20, earnedXp: 5, isCompleted: false)),
    );

    expect(find.text('Daily goal: 20'), findsOneWidget);
    expect(find.text('15 XP to go'), findsOneWidget);
  });
}
