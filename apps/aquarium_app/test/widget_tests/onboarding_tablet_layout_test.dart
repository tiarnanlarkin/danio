import 'package:danio/data/species_database.dart';
import 'package:danio/models/user_profile.dart';
import 'package:danio/screens/onboarding/aha_moment_screen.dart';
import 'package:danio/screens/onboarding/experience_level_screen.dart';
import 'package:danio/screens/onboarding/feature_summary_screen.dart';
import 'package:danio/screens/onboarding/goals_screen.dart';
import 'package:danio/screens/onboarding/micro_lesson_screen.dart';
import 'package:danio/screens/onboarding/push_permission_screen.dart';
import 'package:danio/screens/onboarding/region_units_screen.dart';
import 'package:danio/screens/onboarding/tank_status_screen.dart';
import 'package:danio/screens/onboarding/warm_entry_screen.dart';
import 'package:danio/screens/onboarding/welcome_screen.dart';
import 'package:danio/screens/onboarding/xp_celebration_screen.dart';
import 'package:danio/widgets/core/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _tabletSurface = Size(2000, 1200);
const _maxReadableWidth = 720.0;

const _testFish = SpeciesInfo(
  commonName: 'Neon Tetra',
  scientificName: 'Paracheirodon innesi',
  family: 'Characidae',
  careLevel: 'Beginner',
  minTankLitres: 40,
  minTempC: 20,
  maxTempC: 26,
  minPh: 6.0,
  maxPh: 7.5,
  minSchoolSize: 6,
  temperament: 'Peaceful',
  diet: 'Omnivore',
  adultSizeCm: 4,
  swimLevel: 'Middle',
  description: 'Small, colourful tetra.',
);

Future<void> _pumpTablet(WidgetTester tester, Widget child) async {
  await tester.binding.setSurfaceSize(_tabletSurface);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(MaterialApp(home: child));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void _expectReadableWidth(WidgetTester tester, String semanticsLabel) {
  final control = find.bySemanticsLabel(semanticsLabel);
  expect(control, findsOneWidget);
  _expectFinderWidth(tester, control);
}

void _expectFinderWidth(WidgetTester tester, Finder control) {
  expect(
    tester.getSize(control).width,
    lessThanOrEqualTo(_maxReadableWidth),
  );
}

Future<void> _finishAhaReveal(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 1800));
  await tester.pump(const Duration(milliseconds: 450));
  await tester.pump(const Duration(milliseconds: 1200));
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('first-run tablet layout', () {
    testWidgets('Welcome keeps primary action readable on tablet', (
      tester,
    ) async {
      await _pumpTablet(
        tester,
        WelcomeScreen(onNext: () {}, onLogin: () {}),
      );

      _expectFinderWidth(tester, find.byType(AppButton).first);
    });

    testWidgets('Region and units keeps primary action readable on tablet', (
      tester,
    ) async {
      await _pumpTablet(
        tester,
        RegionUnitsScreen(onContinue: (_) {}, onSkip: () {}),
      );

      _expectReadableWidth(tester, 'Continue');
    });

    testWidgets('Experience level keeps primary action readable on tablet', (
      tester,
    ) async {
      await _pumpTablet(
        tester,
        ExperienceLevelScreen(onSelected: (_) {}, onSkip: () {}),
      );

      _expectReadableWidth(tester, 'Continue');
    });

    testWidgets('Tank status keeps primary action readable on tablet', (
      tester,
    ) async {
      await _pumpTablet(tester, TankStatusScreen(onSelected: (_) {}));

      _expectReadableWidth(tester, 'Continue');
    });

    testWidgets('Goals keeps primary action readable on tablet', (
      tester,
    ) async {
      await _pumpTablet(
        tester,
        GoalsScreen(
          recommendedGoal: UserGoal.keepFishAlive,
          onContinue: (_) {},
        ),
      );

      _expectReadableWidth(tester, 'Continue');
    });

    testWidgets('Feature summary keeps primary action readable on tablet', (
      tester,
    ) async {
      await _pumpTablet(
        tester,
        FeatureSummaryScreen(
          selectedFish: _testFish,
          onComplete: () {},
          onSkip: () {},
        ),
      );

      _expectReadableWidth(tester, 'Continue to setup');
    });

    testWidgets('Reminder setup keeps primary action readable on tablet', (
      tester,
    ) async {
      await _pumpTablet(
        tester,
        PushPermissionScreen(onAllow: () {}, onSkip: () {}),
      );

      _expectReadableWidth(tester, 'Continue without enabling reminders');
    });

    testWidgets('Micro lesson keeps lesson content readable on tablet', (
      tester,
    ) async {
      await _pumpTablet(
        tester,
        MicroLessonScreen(
          experienceLevel: ExperienceLevel.beginner,
          onComplete: () {},
        ),
      );

      _expectFinderWidth(tester, find.byType(AppButton).last);
    });

    testWidgets('XP celebration keeps primary action readable on tablet', (
      tester,
    ) async {
      await _pumpTablet(tester, XpCelebrationScreen(onNext: () {}));

      _expectFinderWidth(tester, find.byType(AppButton).last);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('Aha moment keeps final action readable on tablet', (
      tester,
    ) async {
      await _pumpTablet(
        tester,
        AhaMomentScreen(
          selectedFish: _testFish,
          experienceLevel: ExperienceLevel.beginner,
          tankStatus: 'active',
          onComplete: () {},
        ),
      );
      await _finishAhaReveal(tester);

      _expectReadableWidth(tester, 'Start your journey');
    });

    testWidgets('Warm entry keeps name entry readable on tablet', (
      tester,
    ) async {
      await _pumpTablet(
        tester,
        WarmEntryScreen(
          selectedFish: _testFish,
          experienceLevel: ExperienceLevel.beginner,
          tankStatus: 'active',
          onReady: () {},
        ),
      );

      final nameField = find.byType(TextField);
      expect(nameField, findsOneWidget);
      _expectFinderWidth(tester, nameField);
    });
  });
}
