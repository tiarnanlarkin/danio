// Widget tests for AlgaeGuideScreen.
//
// Run: flutter test test/widget_tests/algae_guide_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/algae_guide_screen.dart';
import 'package:danio/widgets/core/app_card.dart';

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

    testWidgets('tablet keeps algae guide surfaces readable', (tester) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await tester.pump();

      final introCard = find
          .ancestor(
            of: find.text('Algae Basics'),
            matching: find.byType(AppCard),
          )
          .first;
      final algaeCard = find
          .ancestor(
            of: find.text('Green Spot Algae (GSA)'),
            matching: find.byType(Card),
          )
          .first;
      final introWidth = tester.getSize(introCard).width;
      final algaeCardWidth = tester.getSize(algaeCard).width;

      await tester.scrollUntilVisible(
        find.text('Amano Shrimp'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final crewCard = find
          .ancestor(
            of: find.text('Amano Shrimp'),
            matching: find.byType(AppCard),
          )
          .first;
      final crewCardWidth = tester.getSize(crewCard).width;

      await tester.scrollUntilVisible(
        find.text('Light: 6-8 hours max, no direct sunlight'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final checklistCard = find
          .ancestor(
            of: find.text('Light: 6-8 hours max, no direct sunlight'),
            matching: find.byType(AppCard),
          )
          .first;

      expect(introWidth, lessThanOrEqualTo(720));
      expect(algaeCardWidth, lessThanOrEqualTo(720));
      expect(crewCardWidth, lessThanOrEqualTo(720));
      expect(tester.getSize(checklistCard).width, lessThanOrEqualTo(720));
    });
  });

  group('AlgaeGuideScreen — expandable algae cards', () {
    testWidgets('algae cards are collapsed by default (causes not visible)', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // "Causes" heading only appears in expanded cards
      expect(find.text('Causes'), findsNothing);
    });

    testWidgets('tapping algae card reveals causes and solutions', (
      tester,
    ) async {
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
