// Widget tests for FeedingGuideScreen.
//
// Run: flutter test test/widget_tests/feeding_guide_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/feeding_guide_screen.dart';
import 'package:danio/widgets/core/app_card.dart';

Widget _wrap() => const MaterialApp(home: FeedingGuideScreen());

void main() {
  group('FeedingGuideScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(FeedingGuideScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Feeding Guide'), findsOneWidget);
    });

    testWidgets('shows The Golden Rule intro', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('The Golden Rule'), findsOneWidget);
    });

    testWidgets('shows How Often to Feed section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('How Often to Feed'), findsOneWidget);
    });

    testWidgets('shows Food Types section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.scrollUntilVisible(
        find.text('Food Types'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      expect(find.text('Food Types'), findsOneWidget);
    });

    testWidgets('tablet keeps intro and frequency cards readable', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await tester.pump();

      final introCard = find
          .ancestor(
            of: find.text('The Golden Rule'),
            matching: find.byType(AppCard),
          )
          .first;
      final frequencyCard = find
          .ancestor(
            of: find.text('Adult tropical fish'),
            matching: find.byType(Card),
          )
          .first;

      expect(tester.getSize(introCard).width, lessThanOrEqualTo(720));
      expect(tester.getSize(frequencyCard).width, lessThanOrEqualTo(720));
    });
  });
}
