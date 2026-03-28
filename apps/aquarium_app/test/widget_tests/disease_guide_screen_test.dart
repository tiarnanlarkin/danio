// Widget tests for DiseaseGuideScreen.
//
// Run: flutter test test/widget_tests/disease_guide_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/disease_guide_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const MaterialApp(
    home: DiseaseGuideScreen(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('DiseaseGuideScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(DiseaseGuideScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Fish Disease Guide'), findsOneWidget);
    });

    testWidgets('shows search field', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Search by disease or symptom...'), findsOneWidget);
    });

    testWidgets('shows disclaimer card', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.textContaining('This guide is for reference only'),
        findsOneWidget,
      );
    });

    testWidgets('shows disease list entries', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Ich (White Spot Disease)'), findsOneWidget);
      expect(find.text('Fin Rot'), findsOneWidget);
    });

    testWidgets('shows disease cause as subtitle', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.text('Parasite (Ichthyophthirius multifiliis)'),
        findsOneWidget,
      );
    });
  });

  group('DiseaseGuideScreen — expandable disease cards', () {
    testWidgets('disease cards are collapsed by default', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // "Symptoms" heading only appears inside expanded cards
      expect(find.text('Symptoms'), findsNothing);
    });

    testWidgets('tapping disease card reveals symptoms section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.text('Ich (White Spot Disease)'));
      await tester.pumpAndSettle();

      expect(find.text('Symptoms'), findsOneWidget);
      expect(find.text('White spots like salt grains'), findsOneWidget);
    });

    testWidgets('expanded card shows treatment section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.text('Ich (White Spot Disease)'));
      await tester.pumpAndSettle();

      expect(find.text('Treatment'), findsOneWidget);
      expect(find.textContaining('Raise temperature'), findsOneWidget);
    });

    testWidgets('expanded card shows prevention section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.text('Ich (White Spot Disease)'));
      await tester.pumpAndSettle();

      expect(find.text('Prevention'), findsOneWidget);
      expect(find.textContaining('Quarantine new fish'), findsOneWidget);
    });

    testWidgets('expanded card shows contagious status', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.text('Ich (White Spot Disease)'));
      await tester.pumpAndSettle();

      expect(find.text('⚠️ Contagious'), findsOneWidget);
    });
  });

  group('DiseaseGuideScreen — search', () {
    testWidgets('search filters disease list by name', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.enterText(
        find.byType(TextField),
        'Ich',
      );
      // Wait for debounce
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Ich (White Spot Disease)'), findsOneWidget);
      // Fin Rot should be filtered out
      expect(find.text('Fin Rot'), findsNothing);
    });

    testWidgets('search filters by symptom text', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.enterText(
        find.byType(TextField),
        'Swollen belly',
      );
      await tester.pump(const Duration(milliseconds: 500));

      // Dropsy has "Swollen belly" as a symptom
      expect(find.text('Dropsy'), findsOneWidget);
      expect(find.text('Fin Rot'), findsNothing);
    });

    testWidgets('empty search shows all diseases', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'xyz_no_match');
      await tester.pump(const Duration(milliseconds: 500));

      // No results
      expect(find.text('Ich (White Spot Disease)'), findsNothing);

      // Clear search
      await tester.enterText(find.byType(TextField), '');
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Ich (White Spot Disease)'), findsOneWidget);
    });
  });
}
