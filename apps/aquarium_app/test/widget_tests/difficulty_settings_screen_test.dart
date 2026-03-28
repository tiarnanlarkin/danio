// Widget tests for DifficultySettingsScreen.
//
// Run: flutter test test/widget_tests/difficulty_settings_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/difficulty_settings_screen.dart';
import 'package:danio/models/adaptive_difficulty.dart';

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

    testWidgets('shows mastery percentage when skills populated', (tester) async {
      await tester.pumpWidget(_wrap(profile: _profileWithSkills()));
      await tester.pump(const Duration(seconds: 1));
      // overallSkillLevel = (0.8 + 0.5 + 0.3) / 3 ≈ 0.53 → 53%
      expect(find.textContaining('% Mastery'), findsOneWidget);
    });
  });

  group('DifficultySettingsScreen — empty state', () {
    testWidgets('shows no-lessons message when profile is empty', (tester) async {
      await tester.pumpWidget(_wrap(profile: _emptyProfile()));
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.text('No lessons completed yet — start learning to see stats here!'),
        findsOneWidget,
      );
    });
  });

  group('DifficultySettingsScreen — with skills', () {
    testWidgets('shows topic name cards when skill data exists', (tester) async {
      await tester.pumpWidget(_wrap(profile: _profileWithSkills()));
      await tester.pump(const Duration(seconds: 1));
      // At least one known topic name should appear
      expect(find.text('Nitrogen Cycle'), findsWidgets);
    });
  });
}
