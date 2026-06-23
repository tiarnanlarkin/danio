// Widget tests for QuarantineGuideScreen.
//
// Run: flutter test test/widget_tests/quarantine_guide_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/quarantine_guide_screen.dart';
import 'package:danio/widgets/core/app_card.dart';

Widget _wrap() => const MaterialApp(home: QuarantineGuideScreen());

void main() {
  group('QuarantineGuideScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(QuarantineGuideScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Quarantine Guide'), findsOneWidget);
    });

    testWidgets('shows Why Quarantine intro card', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Why Quarantine?'), findsOneWidget);
    });

    testWidgets('shows Quarantine Tank Setup heading', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Quarantine Tank Setup'), findsOneWidget);
    });

    testWidgets('shows setup cards for filtration and heater', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Filtration'), findsOneWidget);
      expect(find.text('Heater'), findsOneWidget);
    });

    testWidgets('tablet keeps intro and setup cards readable', (tester) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await tester.pump();

      final introCard = find
          .ancestor(
            of: find.text('Why Quarantine?'),
            matching: find.byType(AppCard),
          )
          .first;
      final setupCard = find
          .ancestor(of: find.text('Filtration'), matching: find.byType(Card))
          .first;

      expect(tester.getSize(introCard).width, lessThanOrEqualTo(720));
      expect(tester.getSize(setupCard).width, lessThanOrEqualTo(720));
    });
  });
}
