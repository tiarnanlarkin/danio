import 'package:danio/models/user_profile.dart';
import 'package:danio/services/tank_achievement_visual_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('profile with no achievements returns clear', () {
    final state = TankAchievementVisualService.fromProfile(_profile());

    expect(state.condition, TankAchievementVisualCondition.clear);
    expect(state.hasOverlay, isFalse);
  });

  test('one achievement returns badge shelf cue', () {
    final state = TankAchievementVisualService.fromProfile(
      _profile(achievements: ['first_lesson']),
    );

    expect(state.condition, TankAchievementVisualCondition.badgeShelf);
    expect(
      state.semanticsLabel,
      'Tank achievement cosmetic state: badge shelf visible',
    );
  });

  test('five achievements returns trophy shelf cue', () {
    final state = TankAchievementVisualService.fromProfile(
      _profile(
        achievements: [
          'first_lesson',
          'lessons_10',
          'streak_3',
          'streak_7',
          'xp_1000',
        ],
      ),
    );

    expect(state.condition, TankAchievementVisualCondition.trophyShelf);
    expect(
      state.semanticsLabel,
      'Tank achievement cosmetic state: trophy shelf visible',
    );
  });

  test('null profile returns clear', () {
    final state = TankAchievementVisualService.fromProfile(null);

    expect(state.condition, TankAchievementVisualCondition.clear);
    expect(state.hasOverlay, isFalse);
  });
}

UserProfile _profile({List<String> achievements = const []}) {
  final now = DateTime(2026, 6, 13);
  return UserProfile(
    id: 'profile-1',
    achievements: achievements,
    createdAt: now,
    updatedAt: now,
  );
}
