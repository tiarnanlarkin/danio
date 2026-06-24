// Widget tests for NitrogenCycleGuideScreen.
//
// Run: flutter test test/widget_tests/nitrogen_cycle_guide_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/nitrogen_cycle_guide_screen.dart';
import 'package:danio/widgets/core/app_card.dart';

Widget _wrap() => const MaterialApp(home: NitrogenCycleGuideScreen());

void main() {
  group('NitrogenCycleGuideScreen rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(NitrogenCycleGuideScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Nitrogen Cycle Guide'), findsOneWidget);
    });

    testWidgets('shows intro card explaining the cycle', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('What is the Nitrogen Cycle?'), findsOneWidget);
    });

    testWidgets('shows The Cycle heading', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('The Cycle'), findsOneWidget);
    });

    testWidgets('shows ammonia cycle stage', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.textContaining('Ammonia'), findsWidgets);
    });

    testWidgets('shows source-safe chemistry and method copy', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(find.text('Ammonia (NH3)'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Fishless Cycling (Recommended)'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(find.text('- No fish harmed'), findsOneWidget);
      expect(find.text('- Need ammonia source'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Tips for Success'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(
        find.text(
          'Keep temperature at 26-28 degrees C - bacteria grow faster in warmth.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('\u2022'), findsNothing);
      expect(find.textContaining('\u00b0'), findsNothing);
      expect(find.textContaining('\u2082'), findsNothing);
      expect(find.textContaining('\u2083'), findsNothing);
    });

    testWidgets('tablet keeps nitrogen cycle surfaces readable', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await tester.pump();

      final introCard = find
          .ancestor(
            of: find.text('What is the Nitrogen Cycle?'),
            matching: find.byType(AppCard),
          )
          .first;
      final stageCard = find
          .ancestor(
            of: find.textContaining('Ammonia').first,
            matching: find.byType(Card),
          )
          .first;
      final introWidth = tester.getSize(introCard).width;
      final stageWidth = tester.getSize(stageCard).width;

      await tester.scrollUntilVisible(
        find.text('Fishless Cycling (Recommended)'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final methodCard = find
          .ancestor(
            of: find.text('Fishless Cycling (Recommended)'),
            matching: find.byType(Card),
          )
          .first;
      final methodWidth = tester.getSize(methodCard).width;

      await tester.scrollUntilVisible(
        find.text('Ammonia reads 0 ppm'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final completionCard = find
          .ancestor(
            of: find.text('Ammonia reads 0 ppm'),
            matching: find.byType(AppCard),
          )
          .first;
      final completionWidth = tester.getSize(completionCard).width;

      final temperatureTip = find.textContaining('Keep temperature').first;
      await tester.scrollUntilVisible(
        temperatureTip,
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final tipCard = find
          .ancestor(
            of: temperatureTip,
            matching: find.byType(Card),
          )
          .first;

      expect(introWidth, lessThanOrEqualTo(720));
      expect(stageWidth, lessThanOrEqualTo(720));
      expect(methodWidth, lessThanOrEqualTo(720));
      expect(completionWidth, lessThanOrEqualTo(720));
      expect(tester.getSize(tipCard).width, lessThanOrEqualTo(720));
    });
  });
}
