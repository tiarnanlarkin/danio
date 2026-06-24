// Widget tests for VacationGuideScreen.
//
// Run: flutter test test/widget_tests/vacation_guide_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/vacation_guide_screen.dart';
import 'package:danio/widgets/core/app_card.dart';

Widget _wrap() => const MaterialApp(home: VacationGuideScreen());

void main() {
  group('VacationGuideScreen rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(VacationGuideScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Vacation Planning'), findsOneWidget);
    });

    testWidgets('shows Before You Leave section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.scrollUntilVisible(
        find.text('Before You Leave'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      expect(find.text('Before You Leave'), findsOneWidget);
    });

    testWidgets('shows Feeding Options section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.scrollUntilVisible(
        find.text('Feeding Options'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      expect(find.text('Feeding Options'), findsOneWidget);
    });

    testWidgets('shows 1 Week Before prep tip', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.scrollUntilVisible(
        find.text('1 Week Before'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      expect(find.text('1 Week Before'), findsOneWidget);
    });

    testWidgets('shows source-safe option and sitter bullet copy', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('No Feeding (Short Trips)'),
        700,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(find.text('- Safest option'), findsOneWidget);
      expect(find.text('- Fish may be hungry when you return'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('If Using a Fish Sitter'),
        700,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(
        find.text('Pre-portion ALL food in labeled daily containers'),
        findsOneWidget,
      );
      expect(find.textContaining('\u00c2'), findsNothing);
      expect(find.textContaining('\u2022'), findsNothing);
    });

    testWidgets('tablet keeps vacation guide surfaces readable', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await tester.pump();

      final introCard = find
          .ancestor(
            of: find.textContaining('Planning ahead ensures'),
            matching: find.byType(AppCard),
          )
          .first;
      final durationCard = find
          .ancestor(
            of: find.text('Adult tropical fish'),
            matching: find.byType(AppCard),
          )
          .first;
      final introWidth = tester.getSize(introCard).width;
      final durationWidth = tester.getSize(durationCard).width;

      await tester.scrollUntilVisible(
        find.text('1 Week Before'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final checklistCard = find
          .ancestor(
            of: find.text('1 Week Before'),
            matching: find.byType(Card),
          )
          .first;
      final checklistWidth = tester.getSize(checklistCard).width;

      await tester.scrollUntilVisible(
        find.text('No Feeding (Short Trips)'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final optionCard = find
          .ancestor(
            of: find.text('No Feeding (Short Trips)'),
            matching: find.byType(Card),
          )
          .first;
      final optionWidth = tester.getSize(optionCard).width;

      await tester.scrollUntilVisible(
        find.text('When You Return'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final returnCard = find
          .ancestor(
            of: find.text('Check all fish are present and healthy'),
            matching: find.byType(AppCard),
          )
          .first;

      expect(introWidth, lessThanOrEqualTo(720));
      expect(durationWidth, lessThanOrEqualTo(720));
      expect(checklistWidth, lessThanOrEqualTo(720));
      expect(optionWidth, lessThanOrEqualTo(720));
      expect(tester.getSize(returnCard).width, lessThanOrEqualTo(720));
    });
  });
}
