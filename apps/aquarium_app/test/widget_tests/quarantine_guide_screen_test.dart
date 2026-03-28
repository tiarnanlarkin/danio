// Widget tests for QuarantineGuideScreen.
//
// Run: flutter test test/widget_tests/quarantine_guide_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/quarantine_guide_screen.dart';

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
  });
}
