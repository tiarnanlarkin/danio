// Widget tests for LightingScheduleScreen.
//
// Run: flutter test test/widget_tests/lighting_schedule_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/lighting_schedule_screen.dart';

Widget _wrap() => const MaterialApp(home: LightingScheduleScreen());

Widget _wrapWithSchedule({
  required TimeOfDay lightsOn,
  required TimeOfDay lightsOff,
  bool useSiesta = false,
  TimeOfDay siestaStart = const TimeOfDay(hour: 14, minute: 0),
  TimeOfDay siestaEnd = const TimeOfDay(hour: 16, minute: 0),
}) {
  return MaterialApp(
    home: LightingScheduleScreen(
      initialLightsOn: lightsOn,
      initialLightsOff: lightsOff,
      initialUseSiesta: useSiesta,
      initialSiestaStart: siestaStart,
      initialSiestaEnd: siestaEnd,
    ),
  );
}

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

  group('LightingScheduleScreen - interactive recommendations', () {
    testWidgets('default schedule shows valid total light duration', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.scrollUntilVisible(find.text('10 hours'), 300);
      await tester.pump();

      expect(find.text('10 hours'), findsOneWidget);
      expect(find.text('Recommendation'), findsOneWidget);
    });

    testWidgets('algae toggle changes recommendation guidance', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.widgetWithText(SwitchListTile, 'Algae Issues'));
      await tester.pump();

      await tester.scrollUntilVisible(
        find.textContaining('consider reducing to 6 hours'),
        300,
      );
      await tester.pump();

      expect(
        find.textContaining('consider reducing to 6 hours'),
        findsOneWidget,
      );
    });
  });

  group('LightingScheduleScreen - midnight schedules', () {
    testWidgets('lights crossing midnight render as a positive duration', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithSchedule(
          lightsOn: const TimeOfDay(hour: 22, minute: 0),
          lightsOff: const TimeOfDay(hour: 2, minute: 0),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);

      await tester.scrollUntilVisible(find.text('4 hours'), 300);
      await tester.pump();

      expect(find.text('4 hours'), findsOneWidget);
    });

    testWidgets('siesta crossing midnight only subtracts overlapping light', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithSchedule(
          lightsOn: const TimeOfDay(hour: 22, minute: 0),
          lightsOff: const TimeOfDay(hour: 2, minute: 0),
          useSiesta: true,
          siestaStart: const TimeOfDay(hour: 23, minute: 0),
          siestaEnd: const TimeOfDay(hour: 0, minute: 30),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);

      await tester.scrollUntilVisible(find.text('3 hours'), 300);
      await tester.pump();

      expect(find.text('3 hours'), findsOneWidget);
    });
  });
}
