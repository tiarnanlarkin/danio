// Widget tests for QuickStartGuideScreen.
//
// Run: flutter test test/widget_tests/quick_start_guide_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/quick_start_guide_screen.dart';
import 'package:danio/widgets/core/app_card.dart';

Widget _wrap() => const MaterialApp(home: QuickStartGuideScreen());

void main() {
  group('QuickStartGuideScreen rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(QuickStartGuideScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Quick Start Guide'), findsOneWidget);
    });

    testWidgets('shows hero card with Your First Aquarium', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Your First Aquarium'), findsOneWidget);
    });

    testWidgets('shows step 1 Choose Your Tank', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Choose Your Tank'), findsOneWidget);
    });

    testWidgets('shows step 2 Get Your Equipment by scrolling', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.scrollUntilVisible(
        find.text('Get Your Equipment'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      expect(find.text('Get Your Equipment'), findsOneWidget);
    });

    testWidgets('shows source-safe bullet and mistake copy', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(find.textContaining('\u2022'), findsNothing);

      await tester.scrollUntilVisible(
        find.text('Common Beginner Mistakes'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              widget.text.toPlainText().contains(
                'Adding fish before cycling -> Fish die from ammonia poisoning',
              ),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              widget.text.toPlainText().contains('\u2192'),
        ),
        findsNothing,
      );
    });

    testWidgets('tablet keeps quick start surfaces readable', (tester) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await tester.pump();

      final introCard = find
          .ancestor(
            of: find.text('Your First Aquarium'),
            matching: find.byType(AppCard),
          )
          .first;
      final stepOneCard = find
          .ancestor(
            of: find.text('Choose Your Tank'),
            matching: find.byType(Card),
          )
          .first;
      final introWidth = tester.getSize(introCard).width;
      final stepOneWidth = tester.getSize(stepOneCard).width;

      await tester.scrollUntilVisible(
        find.text('Cycle Your Tank'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final cycleCard = find
          .ancestor(
            of: find.text('Cycle Your Tank'),
            matching: find.byType(Card),
          )
          .first;
      final cycleWidth = tester.getSize(cycleCard).width;

      await tester.scrollUntilVisible(
        find.text('Common Beginner Mistakes'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final mistakeCard = find
          .ancestor(
            of: find.text('Common Beginner Mistakes'),
            matching: find.byType(AppCard),
          )
          .first;
      final mistakeWidth = tester.getSize(mistakeCard).width;

      expect(introWidth, lessThanOrEqualTo(720));
      expect(stepOneWidth, lessThanOrEqualTo(720));
      expect(cycleWidth, lessThanOrEqualTo(720));
      expect(mistakeWidth, lessThanOrEqualTo(720));
    });
  });
}
