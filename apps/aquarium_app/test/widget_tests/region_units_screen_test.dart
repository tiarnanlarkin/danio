// Widget tests for RegionUnitsScreen.
//
// Run: flutter test test/widget_tests/region_units_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/onboarding/region_units_screen.dart';

Widget _wrap({
  ValueChanged<RegionUnitsChoice>? onContinue,
  VoidCallback? onSkip,
}) {
  return MaterialApp(
    home: RegionUnitsScreen(onContinue: onContinue ?? (_) {}, onSkip: onSkip),
  );
}

void main() {
  group('RegionUnitsScreen', () {
    testWidgets('shows region heading and universal choices', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(find.byType(RegionUnitsScreen), findsOneWidget);
      expect(find.text('Where are you based?'), findsOneWidget);
      expect(find.text('UK & Ireland'), findsOneWidget);
      expect(find.text('Europe'), findsOneWidget);
      expect(find.text('United States'), findsOneWidget);
      expect(find.text('Canada'), findsOneWidget);
      expect(find.text('Australia & New Zealand'), findsOneWidget);
      expect(find.text('Somewhere else'), findsOneWidget);
    });

    testWidgets('selecting United States defaults to US units', (tester) async {
      RegionUnitsChoice? choice;
      await tester.pumpWidget(_wrap(onContinue: (value) => choice = value));
      await tester.pump();

      await tester.tap(find.text('United States'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(choice?.regionCode, 'us');
      expect(choice?.useMetric, isFalse);
    });

    testWidgets('selecting Europe defaults to metric units', (tester) async {
      RegionUnitsChoice? choice;
      await tester.pumpWidget(_wrap(onContinue: (value) => choice = value));
      await tester.pump();

      await tester.tap(find.text('Europe'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(choice?.regionCode, 'europe');
      expect(choice?.useMetric, isTrue);
    });

    testWidgets('unit choice can override the region default', (tester) async {
      RegionUnitsChoice? choice;
      await tester.pumpWidget(_wrap(onContinue: (value) => choice = value));
      await tester.pump();

      await tester.tap(find.text('United States'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Metric'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(choice?.regionCode, 'us');
      expect(choice?.useMetric, isTrue);
    });

    testWidgets('skip action remains available when supplied', (tester) async {
      var skipped = false;
      await tester.pumpWidget(_wrap(onSkip: () => skipped = true));
      await tester.pump();

      final skipButton = find.bySemanticsLabel('Skip setup for now');
      expect(skipButton, findsOneWidget);

      await tester.tap(skipButton);
      await tester.pump();

      expect(skipped, isTrue);
    });
  });
}
