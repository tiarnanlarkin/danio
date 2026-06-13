import 'dart:io';

// Widget tests for FeatureSummaryScreen.
//
// Run: flutter test test/widget_tests/feature_summary_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/onboarding/feature_summary_screen.dart';
import 'package:danio/data/species_database.dart';

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

Widget _wrap({VoidCallback? onComplete, VoidCallback? onSkip}) {
  return MaterialApp(
    home: FeatureSummaryScreen(
      selectedFish: _testFish,
      onComplete: onComplete ?? () {},
      onSkip: onSkip ?? () {},
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  test('onboarding feature summary has no stale paywall naming', () {
    final files = [
      'lib/screens/onboarding_screen.dart',
      'lib/screens/debug_menu_screen.dart',
      'lib/screens/onboarding/feature_summary_screen.dart',
    ];
    final stalePaywallCopy = RegExp(
      r'Paywall Stub|free trial|subscribe now|pricing',
      caseSensitive: false,
    );

    for (final path in files) {
      expect(
        File(path).readAsStringSync(),
        isNot(contains(stalePaywallCopy)),
        reason: path,
      );
    }
  });

  group('FeatureSummaryScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(FeatureSummaryScreen), findsOneWidget);
    });

    testWidgets('shows main headline', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Everything you need, right here.'), findsOneWidget);
    });

    testWidgets('shows free-to-use subtitle', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.textContaining('free to use'), findsOneWidget);
    });

    testWidgets('shows fish care guide reference text', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.textContaining('Neon Tetra'), findsOneWidget);
    });

    testWidgets('shows species care guides feature highlight', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.textContaining('species care guides'), findsOneWidget);
    });

    testWidgets('shows water parameter tracking highlight', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.textContaining('Water parameter tracking'), findsOneWidget);
    });

    testWidgets('shows CTA button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.textContaining("Let's go"), findsOneWidget);
    });
  });

  group('FeatureSummaryScreen — interaction', () {
    testWidgets('tapping CTA fires onComplete callback', (tester) async {
      var completions = 0;
      await tester.pumpWidget(_wrap(onComplete: () => completions++));
      await tester.pump();

      await tester.tap(find.textContaining("Let's go"));
      await tester.pumpAndSettle();

      expect(completions, 1);
    });

    testWidgets('tapping summary body is a guarded fallback', (tester) async {
      var completions = 0;
      await tester.pumpWidget(_wrap(onComplete: () => completions++));
      await tester.pump();

      await tester.tap(find.text('Everything you need, right here.'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Everything you need, right here.'));
      await tester.pumpAndSettle();

      expect(completions, 1);
    });
  });
}
