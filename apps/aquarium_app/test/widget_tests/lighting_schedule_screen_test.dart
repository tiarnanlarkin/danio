// Widget tests for LightingScheduleScreen.
//
// Run: flutter test test/widget_tests/lighting_schedule_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/lighting_schedule_screen.dart';

Widget _wrap() => const MaterialApp(home: LightingScheduleScreen());

void main() {
  group('LightingScheduleScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(LightingScheduleScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Lighting Schedule'), findsOneWidget);
    });

    testWidgets('shows Tank Setup section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Tank Setup'), findsOneWidget);
    });

    testWidgets('shows Live Plants toggle', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Live Plants'), findsOneWidget);
    });

    testWidgets('shows Schedule section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Schedule'), findsOneWidget);
    });
  });
}
