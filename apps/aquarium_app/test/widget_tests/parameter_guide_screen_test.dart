// Widget tests for ParameterGuideScreen.
//
// Run: flutter test test/widget_tests/parameter_guide_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/parameter_guide_screen.dart';
import 'package:danio/widgets/core/app_card.dart';

Widget _wrap() => const MaterialApp(home: ParameterGuideScreen());

void main() {
  group('ParameterGuideScreen rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(ParameterGuideScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Water Parameters Guide'), findsOneWidget);
    });

    testWidgets('shows Ammonia parameter section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.textContaining('Ammonia'), findsWidgets);
    });

    testWidgets('shows Nitrite parameter section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.textContaining('Nitrite'), findsWidgets);
    });

    testWidgets('shows pH section by scrolling', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.scrollUntilVisible(
        find.text('pH'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      expect(find.text('pH'), findsOneWidget);
    });

    testWidgets('shows readable source-safe parameter labels', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(find.text('Ammonia (NH3)'), findsOneWidget);
      expect(find.text('Nitrite (NO2)'), findsOneWidget);
      expect(find.text('Nitrate (NO3)'), findsOneWidget);
      expect(find.textContaining('\u00c3\u00a2'), findsNothing);

      await tester.scrollUntilVisible(
        find.text('Temperature'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(find.text('24-26 C (tropical)'), findsOneWidget);
      expect(find.textContaining('\u00c3\u00a2'), findsNothing);
    });

    testWidgets('shows correct pH raising tip copy', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('pH'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      await tester.tap(find.text('pH'));
      await tester.pumpAndSettle();

      expect(find.text('Crushed coral and limestone raise pH'), findsOneWidget);
      expect(find.textContaining('Crusite'), findsNothing);
    });

    testWidgets('tablet keeps intro, parameter, and quick reference readable', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await tester.pump();

      final introCard = find
          .ancestor(
            of: find.textContaining('Understanding your water parameters'),
            matching: find.byType(AppCard),
          )
          .first;
      final parameterCard = find
          .ancestor(
            of: find.text('Ammonia (NH3)'),
            matching: find.byType(Card),
          )
          .first;
      final introWidth = tester.getSize(introCard).width;
      final parameterWidth = tester.getSize(parameterCard).width;

      await tester.scrollUntilVisible(
        find.text('Quick Reference by Fish Type'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final quickReferenceCard = find
          .ancestor(
            of: find.text('Community (tetras, rasboras)'),
            matching: find.byType(AppCard),
          )
          .first;

      expect(introWidth, lessThanOrEqualTo(720));
      expect(parameterWidth, lessThanOrEqualTo(720));
      expect(
        tester.getSize(quickReferenceCard).width,
        lessThanOrEqualTo(720),
      );
    });
  });
}
