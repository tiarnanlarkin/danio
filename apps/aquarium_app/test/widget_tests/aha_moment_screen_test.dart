// Widget tests for AhaMomentScreen.
//
// Run: flutter test test/widget_tests/aha_moment_screen_test.dart
//
// AhaMomentScreen runs multi-phase animations (1.8s + card cascade + 0.3s).
// Tests pump past all timers to avoid pending-timer assertion failures.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/onboarding/aha_moment_screen.dart';
import 'package:danio/data/species_database.dart';
import 'package:danio/models/user_profile.dart';

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

Widget _wrap({VoidCallback? onComplete}) {
  return MaterialApp(
    home: AhaMomentScreen(
      selectedFish: _testFish,
      experienceLevel: ExperienceLevel.beginner,
      tankStatus: 'active',
      onComplete: onComplete ?? () {},
    ),
  );
}

Future<void> _finishReveal(WidgetTester tester) async {
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

  group('AhaMomentScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(AhaMomentScreen), findsOneWidget);
      // Drain all internal timers
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('shows scaffold initially', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(Scaffold), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('shows fish name after phase 2', (tester) async {
      await tester.pumpWidget(_wrap());
      // Pump past phase 1 (1.8s) and phase 2 animations
      await tester.pump(const Duration(seconds: 5));
      // Fish name should be visible in phase 2 or 3
      expect(find.text('Neon Tetra'), findsOneWidget);
    });

    testWidgets('brings final CTA into view after reveal', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap());
      await _finishReveal(tester);

      final cta = find.textContaining('Start your journey');
      expect(cta, findsOneWidget);
      final ctaCenter = tester.getCenter(cta);
      expect(ctaCenter.dy, greaterThan(0));
      expect(ctaCenter.dy, lessThan(844));
    });
  });
}
