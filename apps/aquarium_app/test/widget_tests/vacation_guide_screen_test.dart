// Widget tests for VacationGuideScreen.
//
// Run: flutter test test/widget_tests/vacation_guide_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/vacation_guide_screen.dart';

Widget _wrap() => const MaterialApp(home: VacationGuideScreen());

void main() {
  group('VacationGuideScreen — rendering', () {
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
  });
}
