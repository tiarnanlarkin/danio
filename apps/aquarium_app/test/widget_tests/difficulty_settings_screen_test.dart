// Widget tests for DifficultySettingsScreen.
//
// Run: flutter test test/widget_tests/difficulty_settings_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/difficulty_settings_screen.dart';
import 'package:danio/models/adaptive_difficulty.dart';
import 'package:danio/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

UserSkillProfile _emptyProfile() {
  return const UserSkillProfile(
    skillLevels: {},
    performanceHistory: {},
    manualOverrides: {},
  );
}

UserSkillProfile _profileWithSkills() {
  return const UserSkillProfile(
    skillLevels: {
      'nitrogen_cycle': 0.8,
      'water_parameters': 0.5,
      'maintenance': 0.3,
    },
    performanceHistory: {},
    manualOverrides: {},
  );
}

UserSkillProfile _profileWithSkillHistory() {
  final record = PerformanceRecord(
    timestamp: DateTime(2026, 5, 18),
    topicId: 'nitrogen_cycle',
    difficulty: DifficultyLevel.medium,
    score: 8,
    maxScore: 10,
    mistakeCount: 1,
    timeSpent: const Duration(minutes: 4),
    completed: true,
  );

  return UserSkillProfile(
    skillLevels: const {'nitrogen_cycle': 0.8},
    performanceHistory: {
      'nitrogen_cycle': PerformanceHistory(
        topicId: 'nitrogen_cycle',
        recentAttempts: [record],
      ),
    },
    manualOverrides: const {},
  );
}

UserSkillProfile _profileWithMastery() {
  final attempts = List.generate(
    5,
    (index) => PerformanceRecord(
      timestamp: DateTime(2026, 5, 18).add(Duration(minutes: index)),
      topicId: 'nitrogen_cycle',
      difficulty: DifficultyLevel.hard,
      score: 9,
      maxScore: 10,
      mistakeCount: 1,
      timeSpent: const Duration(minutes: 4),
      completed: true,
    ),
  );

  return UserSkillProfile(
    skillLevels: const {'nitrogen_cycle': 0.9},
    performanceHistory: {
      'nitrogen_cycle': PerformanceHistory(
        topicId: 'nitrogen_cycle',
        recentAttempts: attempts,
      ),
    },
    manualOverrides: const {},
  );
}

Widget _wrap({
  required UserSkillProfile profile,
  Function(UserSkillProfile)? onUpdated,
}) {
  return MaterialApp(
    home: DifficultySettingsScreen(
      skillProfile: profile,
      onProfileUpdated: onUpdated ?? (_) {},
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('DifficultySettingsScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap(profile: _emptyProfile()));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(DifficultySettingsScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap(profile: _emptyProfile()));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Difficulty Settings'), findsOneWidget);
    });

    testWidgets('shows Overall Skill Level card', (tester) async {
      await tester.pumpWidget(_wrap(profile: _emptyProfile()));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Overall Skill Level'), findsOneWidget);
    });

    testWidgets('shows Skills by Topic section', (tester) async {
      await tester.pumpWidget(_wrap(profile: _emptyProfile()));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Skills by Topic'), findsOneWidget);
    });

    testWidgets('shows mastery percentage when skills populated', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(profile: _profileWithSkills()));
      await tester.pump(const Duration(seconds: 1));
      // overallSkillLevel = (0.8 + 0.5 + 0.3) / 3 ≈ 0.53 → 53%
      expect(find.textContaining('% Mastery'), findsOneWidget);
    });
  });

  group('DifficultySettingsScreen — empty state', () {
    testWidgets('shows no-lessons message when profile is empty', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(profile: _emptyProfile()));
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.text(
          'No lessons completed yet — start learning to see stats here!',
        ),
        findsOneWidget,
      );
    });
  });

  group('DifficultySettingsScreen — with skills', () {
    testWidgets('shows topic name cards when skill data exists', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(profile: _profileWithSkills()));
      await tester.pump(const Duration(seconds: 1));
      // At least one known topic name should appear
      expect(find.text('Nitrogen Cycle'), findsWidgets);
    });

    testWidgets('stat chip icons use the minimum legible app size', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(profile: _profileWithSkillHistory()));
      await tester.pump(const Duration(seconds: 1));

      final historyIcon = tester.widget<Icon>(find.byIcon(Icons.history).first);
      expect(historyIcon.size, greaterThanOrEqualTo(AppIconSizes.xs));
    });

    testWidgets('difficulty controls use icons instead of emoji text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_wrap(profile: _emptyProfile()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byIcon(Icons.eco_outlined), findsWidgets);
      for (final level in DifficultyLevel.values) {
        expect(find.text(level.emoji), findsNothing);
      }

      await tester.ensureVisible(
        find.byType(DropdownButton<DifficultyLevel?>).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButton<DifficultyLevel?>).first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.auto_awesome_outlined), findsWidgets);
      for (final level in DifficultyLevel.values) {
        expect(find.text(level.emoji), findsNothing);
      }
    });

    testWidgets('mastery badge uses an icon instead of trophy emoji', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(profile: _profileWithMastery()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Mastered'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events_outlined), findsOneWidget);
      expect(find.text(String.fromCharCode(0x1f3c6)), findsNothing);
    });
  });
}
