// Widget tests for NitrogenCycleGuideScreen.
//
// Run: flutter test test/widget_tests/nitrogen_cycle_guide_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/nitrogen_cycle_guide_screen.dart';

Widget _wrap() => const MaterialApp(home: NitrogenCycleGuideScreen());

void main() {
  group('NitrogenCycleGuideScreen — rendering', () {
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
  });
}
