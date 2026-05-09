import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:danio/data/achievements.dart';
import 'package:danio/screens/onboarding/returning_user_flows.dart';

void main() {
  test('streak achievement copy avoids fishing-hook imagery', () {
    expect(
      AchievementDefinitions.streak14.description.toLowerCase(),
      isNot(contains('hooked')),
    );
  });

  testWidgets('day 30 card avoids fishing-pole imagery', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Day30CommittedCard(lessonsCompleted: 12, xpEarned: 340),
        ),
      ),
    );

    expect(find.textContaining(String.fromCharCode(0x1F3A3)), findsNothing);
  });
}
