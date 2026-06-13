import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/models/user_profile.dart';
import 'package:danio/screens/onboarding/goals_screen.dart';

Widget _wrap({
  ValueChanged<List<UserGoal>>? onContinue,
  UserGoal recommendedGoal = UserGoal.keepFishAlive,
}) {
  return MaterialApp(
    home: GoalsScreen(
      recommendedGoal: recommendedGoal,
      onContinue: onContinue ?? (_) {},
    ),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('shows normal-user goal choices with one recommendation', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(recommendedGoal: UserGoal.learnTheScience));
    await _advance(tester);

    expect(find.text('What should Danio help with first?'), findsOneWidget);
    expect(find.text('Keep fish healthy'), findsOneWidget);
    expect(find.text('Plan with confidence'), findsOneWidget);
    expect(find.text('Recommended'), findsOneWidget);
  });

  testWidgets('can select multiple goals and continue', (tester) async {
    List<UserGoal>? chosen;
    await tester.pumpWidget(_wrap(onContinue: (goals) => chosen = goals));
    await _advance(tester);

    await tester.tap(find.text('Keep fish healthy'));
    await tester.pump();
    await tester.tap(find.text('Create a beautiful tank'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(
      chosen,
      containsAll([UserGoal.keepFishAlive, UserGoal.beautifulDisplay]),
    );
  });

  testWidgets('skip uses the recommended goal without extra guessing', (
    tester,
  ) async {
    List<UserGoal>? chosen;
    await tester.pumpWidget(
      _wrap(
        recommendedGoal: UserGoal.masterTheHobby,
        onContinue: (goals) => chosen = goals,
      ),
    );
    await _advance(tester);

    await tester.tap(find.text('Use recommendation'));
    await tester.pump();

    expect(chosen, [UserGoal.masterTheHobby]);
  });
}
