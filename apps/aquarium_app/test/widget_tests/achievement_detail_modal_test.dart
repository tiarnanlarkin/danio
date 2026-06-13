import 'package:danio/data/achievements.dart';
import 'package:danio/models/achievements.dart';
import 'package:danio/widgets/achievement_card.dart';
import 'package:danio/widgets/achievement_detail_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Achievement achievement, AchievementProgress progress) {
  return MaterialApp(
    home: Scaffold(
      body: AchievementDetailModal(
        achievement: achievement,
        progress: progress,
      ),
    ),
  );
}

void main() {
  testWidgets('renders badge visuals without raw stored icon text', (
    tester,
  ) async {
    const achievement = AchievementDefinitions.firstLesson;
    const progress = AchievementProgress(
      achievementId: 'first_lesson',
      currentCount: 1,
      isUnlocked: true,
    );

    await tester.pumpWidget(_wrap(achievement, progress));
    await tester.pump();

    expect(find.text(achievement.icon), findsNothing);
    expect(
      find.text(
        '${achievement.category.icon} ${achievement.category.displayName}',
      ),
      findsNothing,
    );
    expect(find.text(achievement.category.displayName), findsOneWidget);
    expect(
      find.byIcon(AchievementCard.iconFor(achievement.category)),
      findsWidgets,
    );
  });
}
