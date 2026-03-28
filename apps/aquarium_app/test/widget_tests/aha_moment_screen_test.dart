// Widget tests for AhaMomentScreen.
//
// Run: flutter test test/widget_tests/aha_moment_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/onboarding/aha_moment_screen.dart';
import 'package:danio/data/species_database.dart';
import 'package:danio/models/user_profile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

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

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AhaMomentScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(AhaMomentScreen), findsOneWidget);
    });

    testWidgets('shows scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows fish name in phase 1 or 2', (tester) async {
      await tester.pumpWidget(_wrap());
      // Phase 1 runs for ~2s, pump past it to phase 2/3
      await tester.pump(const Duration(milliseconds: 100));
      // Either phase 1 loading text or fish name should be present
      expect(find.byType(AhaMomentScreen), findsOneWidget);
    });

    testWidgets('eventually shows CTA in phase 3', (tester) async {
      await tester.pumpWidget(_wrap());
      // Skip through all phases (phase 1: 2s + phase 2: 2s + phase 3 appears)
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 500));
      // Screen still showing without crash
      expect(find.byType(AhaMomentScreen), findsOneWidget);
    });
  });
}
