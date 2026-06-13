import 'package:danio/data/achievements.dart';
import 'package:danio/widgets/achievement_unlocked_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: child,
    ),
  );
}

void main() {
  testWidgets('shows room vibe reward for achievement-linked cosmetics', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const AchievementUnlockedDialog(
          achievement: AchievementDefinitions.streak7,
          xpAwarded: 50,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Room vibe unlocked'), findsOneWidget);
    expect(find.text('Midnight'), findsOneWidget);
  });

  testWidgets('does not show cosmetic reward copy for unmapped achievements', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const AchievementUnlockedDialog(
          achievement: AchievementDefinitions.firstLesson,
          xpAwarded: 50,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Room vibe unlocked'), findsNothing);
  });
}
