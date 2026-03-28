// Widget tests for WarmEntryScreen.
//
// Run: flutter test test/widget_tests/warm_entry_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/onboarding/warm_entry_screen.dart';
import 'package:danio/data/species_database.dart';
import 'package:danio/models/user_profile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _testFish = SpeciesInfo(
  commonName: 'Betta',
  scientificName: 'Betta splendens',
  family: 'Osphronemidae',
  careLevel: 'Intermediate',
  minTankLitres: 20,
  minTempC: 24,
  maxTempC: 30,
  minPh: 6.0,
  maxPh: 7.5,
  minSchoolSize: 1,
  temperament: 'Aggressive',
  diet: 'Carnivore',
  adultSizeCm: 7,
  swimLevel: 'Top',
  description: 'Colourful labyrinth fish.',
);

Widget _wrap({
  String? userName,
  VoidCallback? onReady,
  String tankStatus = 'active',
}) {
  return MaterialApp(
    home: WarmEntryScreen(
      selectedFish: _testFish,
      experienceLevel: ExperienceLevel.beginner,
      tankStatus: tankStatus,
      userName: userName,
      onReady: onReady ?? () {},
    ),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WarmEntryScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(WarmEntryScreen), findsOneWidget);
    });

    testWidgets('shows Almost there heading before name is entered', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Almost there! 🐟'), findsOneWidget);
    });

    testWidgets('shows name input field', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows Next and Skip buttons', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Next →'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('tapping Skip advances to warm entry cards', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.tap(find.text('Skip'));
      await tester.pump(const Duration(milliseconds: 500));

      // After skip, name input disappears and warm entry cards appear
      expect(find.byType(TextField), findsNothing);
    });
  });
}
