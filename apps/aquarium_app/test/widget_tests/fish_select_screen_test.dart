// Widget tests for FishSelectScreen.
//
// Run: flutter test test/widget_tests/fish_select_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/onboarding/fish_select_screen.dart';
import 'package:danio/data/species_database.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap({
  String tankStatus = 'active',
  ValueChanged<SpeciesInfo>? onFishSelected,
}) {
  return MaterialApp(
    home: FishSelectScreen(
      tankStatus: tankStatus,
      onFishSelected: onFishSelected ?? (_) {},
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('FishSelectScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(FishSelectScreen), findsOneWidget);
    });

    testWidgets('shows header text for active tank', (tester) async {
      await tester.pumpWidget(_wrap(tankStatus: 'active'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('What fish do you have right now?'), findsOneWidget);
    });

    testWidgets('shows header text for planning tank', (tester) async {
      await tester.pumpWidget(_wrap(tankStatus: 'planning'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('What fish are you thinking of getting?'), findsOneWidget);
    });

    testWidgets('shows search field', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(TextField), findsAtLeastNWidgets(1));
    });

    testWidgets('shows popular fish list', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump(const Duration(seconds: 1));
      // Neon Tetra is always in popular fish list
      expect(find.text('Neon Tetra'), findsWidgets);
    });
  });

  group('FishSelectScreen — search', () {
    testWidgets('search returns results when query matches', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump(const Duration(seconds: 1));

      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'Betta');
      await tester.pump(const Duration(milliseconds: 300));

      // Should show at least one result containing 'Betta'
      expect(find.textContaining('Betta'), findsWidgets);
    });

    testWidgets('shows search placeholder hint', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('Search'), findsWidgets);
    });
  });

  group('FishSelectScreen — selection', () {
    testWidgets('tapping a fish shows confirm tray with species name', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump(const Duration(seconds: 1));

      // Tap the first popular fish
      await tester.tap(find.text('Neon Tetra').first);
      await tester.pump(const Duration(seconds: 1));

      // Confirm tray shows selected fish name and CTA button
      expect(find.text('Neon Tetra'), findsWidgets);
      expect(find.text('This is my fish →'), findsOneWidget);
    });

    testWidgets('confirm button calls onFishSelected', (tester) async {
      SpeciesInfo? selected;
      await tester.pumpWidget(_wrap(onFishSelected: (fish) => selected = fish));
      await tester.pump(const Duration(seconds: 1));

      // Tap Neon Tetra
      await tester.tap(find.text('Neon Tetra').first);
      // Let the tray slide animation complete
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // Tap the confirm CTA (hit-test ignoring since button may be behind overlay)
      await tester.tap(find.text('This is my fish →'), warnIfMissed: false);
      await tester.pump(const Duration(seconds: 1));

      // Either selected is set OR confirm tray is visible (animation still running)
      if (selected == null) {
        // Try again after longer settle
        await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.text('This is my fish →'), warnIfMissed: false);
        await tester.pump(const Duration(seconds: 1));
      }
      expect(selected, isNotNull);
      expect(selected!.commonName, 'Neon Tetra');
    });
  });
}
