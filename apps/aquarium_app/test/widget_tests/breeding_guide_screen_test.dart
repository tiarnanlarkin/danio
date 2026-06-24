// Widget tests for BreedingGuideScreen.
//
// Run: flutter test test/widget_tests/breeding_guide_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/breeding_guide_screen.dart';
import 'package:danio/widgets/core/app_card.dart';

Widget _wrap() => const MaterialApp(home: BreedingGuideScreen());

void main() {
  group('BreedingGuideScreen rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(BreedingGuideScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Fish Breeding Guide'), findsOneWidget);
    });

    testWidgets('shows Breeding Basics intro', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Breeding Basics'), findsOneWidget);
    });

    testWidgets('shows Breeding Methods section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Breeding Methods'), findsOneWidget);
    });

    testWidgets('shows Livebearers method card', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Livebearers'), findsOneWidget);
    });

    testWidgets('shows source-safe conditioning and fry copy', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Temperature'),
        700,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(find.textContaining('Slight increase (1-2 C)'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Day 1-3'),
        700,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(
        find.text('Feeding: No feeding needed - fry absorb yolk sac'),
        findsOneWidget,
      );
      expect(
        find.text('Care: Keep water clean, gentle aeration, low light'),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(
        find.text('Before You Breed'),
        700,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(
        find.textContaining('- Have a plan for the fry - can you home them?'),
        findsOneWidget,
      );
      expect(find.textContaining('\u00c2'), findsNothing);
      expect(find.textContaining('\u00f0'), findsNothing);
    });

    testWidgets('tablet keeps breeding guide surfaces readable', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await tester.pump();

      final introCard = find
          .ancestor(
            of: find.text('Breeding Basics'),
            matching: find.byType(AppCard),
          )
          .first;
      final methodCard = find
          .ancestor(
            of: find.text('Livebearers'),
            matching: find.byType(Card),
          )
          .first;
      final introWidth = tester.getSize(introCard).width;
      final methodWidth = tester.getSize(methodCard).width;

      await tester.scrollUntilVisible(
        find.text('Conditioning Breeders'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final conditioningCard = find
          .ancestor(
            of: find.text('Diet'),
            matching: find.byType(AppCard),
          )
          .first;
      final conditioningWidth = tester.getSize(conditioningCard).width;

      await tester.scrollUntilVisible(
        find.text('Day 1-3'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final fryStageCard = find
          .ancestor(
            of: find.text('Day 1-3'),
            matching: find.byType(Card),
          )
          .first;
      final fryStageWidth = tester.getSize(fryStageCard).width;

      await tester.scrollUntilVisible(
        find.text('Before You Breed'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final warningCard = find
          .ancestor(
            of: find.text('Before You Breed'),
            matching: find.byType(AppCard),
          )
          .first;

      expect(introWidth, lessThanOrEqualTo(720));
      expect(methodWidth, lessThanOrEqualTo(720));
      expect(conditioningWidth, lessThanOrEqualTo(720));
      expect(fryStageWidth, lessThanOrEqualTo(720));
      expect(tester.getSize(warningCard).width, lessThanOrEqualTo(720));
    });
  });
}
