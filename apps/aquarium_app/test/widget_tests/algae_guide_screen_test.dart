// Widget tests for AlgaeGuideScreen.
//
// Run: flutter test test/widget_tests/algae_guide_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/algae_guide_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const MaterialApp(
    home: AlgaeGuideScreen(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AlgaeGuideScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(AlgaeGuideScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Algae Identification & Control'), findsOneWidget);
    });

    testWidgets('shows intro card with algae basics', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Algae Basics'), findsOneWidget);
      expect(find.textContaining('Some algae is normal'), findsOneWidget);
    });

    testWidgets('shows algae type cards in list', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Green Spot Algae (GSA)'), findsOneWidget);
      expect(find.text('Black Beard Algae (BBA)'), findsOneWidget);
    });

    testWidgets('algae cards show appearance description', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.textContaining('Hard green spots on glass'),
        findsOneWidget,
      );
    });
  });

  group('AlgaeGuideScreen — expandable algae cards', () {
    testWidgets('algae cards are collapsed by default (causes not visible)',
        (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // "Causes" heading only appears in expanded cards
      expect(find.text('Causes'), findsNothing);
    });

    testWidgets('tapping algae card reveals causes and solutions', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.text('Green Spot Algae (GSA)'));
      await tester.pumpAndSettle();

      expect(find.text('Causes'), findsOneWidget);
      expect(find.text('Solutions'), findsOneWidget);
    });

    testWidgets('expanded algae card shows prevention info', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.text('Green Spot Algae (GSA)'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Prevention:'), findsOneWidget);
    });

    testWidgets('GSA causes include low phosphate', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.text('Green Spot Algae (GSA)'));
      await tester.pumpAndSettle();

      expect(find.text('• Low phosphate'), findsOneWidget);
    });
  });

  group('AlgaeGuideScreen — algae eating crew section', () {
    testWidgets('shows Algae-Eating Crew section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Algae-Eating Crew'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(find.text('Algae-Eating Crew'), findsOneWidget);
    });

    testWidgets('crew section lists Amano Shrimp', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Amano Shrimp'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(find.text('Amano Shrimp'), findsOneWidget);
    });
  });

  group('AlgaeGuideScreen — prevention checklist', () {
    testWidgets('shows Prevention Checklist section at bottom', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Prevention Checklist'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(find.text('Prevention Checklist'), findsOneWidget);
    });
  });
}
