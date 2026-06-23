// Widget tests for LightingScheduleScreen.
//
// Run: flutter test test/widget_tests/lighting_schedule_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/models/models.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/screens/add_log_screen.dart';
import 'package:danio/screens/lighting_schedule_screen.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/utils/navigation_throttle.dart';
import 'package:danio/widgets/core/app_card.dart';

final _now = DateTime.now();

Tank _makeTank({String id = 'tank-1'}) => Tank(
  id: id,
  name: 'Test Tank',
  type: TankType.freshwater,
  volumeLitres: 100,
  startDate: _now,
  targets: WaterTargets.freshwaterTropical(),
  createdAt: _now,
  updatedAt: _now,
);

Widget _wrap({String? tankId, InMemoryStorageService? storage}) {
  return ProviderScope(
    overrides: [
      if (storage != null) storageServiceProvider.overrideWithValue(storage),
    ],
    child: MaterialApp(home: LightingScheduleScreen(tankId: tankId)),
  );
}

Widget _wrapWithSchedule({
  required TimeOfDay lightsOn,
  required TimeOfDay lightsOff,
  bool useSiesta = false,
  TimeOfDay siestaStart = const TimeOfDay(hour: 14, minute: 0),
  TimeOfDay siestaEnd = const TimeOfDay(hour: 16, minute: 0),
  String? tankId,
  InMemoryStorageService? storage,
}) {
  return ProviderScope(
    overrides: [
      if (storage != null) storageServiceProvider.overrideWithValue(storage),
    ],
    child: MaterialApp(
      home: LightingScheduleScreen(
        tankId: tankId,
        initialLightsOn: lightsOn,
        initialLightsOff: lightsOff,
        initialUseSiesta: useSiesta,
        initialSiestaStart: siestaStart,
        initialSiestaEnd: siestaEnd,
      ),
    ),
  );
}

Future<void> _clearStorage() async {
  final storage = InMemoryStorageService();
  final tanks = await storage.getAllTanks();
  await storage.deleteAllTanks(tanks.map((tank) => tank.id).toList());
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    NavigationThrottle.reset();
    await _clearStorage();
  });

  group('LightingScheduleScreen - rendering', () {
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

    testWidgets('tablet keeps primary cards readable', (tester) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await tester.pump();

      final introCard = find
          .ancestor(
            of: find.textContaining('Proper lighting duration'),
            matching: find.byType(AppCard),
          )
          .first;
      expect(tester.getSize(introCard).width, lessThanOrEqualTo(720));

      final setupCard = find
          .ancestor(
            of: find.text('Live Plants'),
            matching: find.byType(AppCard),
          )
          .first;
      expect(tester.getSize(setupCard).width, lessThanOrEqualTo(720));

      final timelineCard = find
          .ancestor(
            of: find.text('Total Light: '),
            matching: find.byType(AppCard),
          )
          .first;
      expect(tester.getSize(timelineCard).width, lessThanOrEqualTo(720));
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

    testWidgets(
      'guided action opens an observation log with schedule summary',
      (tester) async {
        final storage = InMemoryStorageService();
        await storage.saveTank(_makeTank());

        await tester.pumpWidget(_wrap(tankId: 'tank-1', storage: storage));
        await tester.pump();

        await tester.scrollUntilVisible(
          find.text('Log this lighting schedule'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Log this lighting schedule'));
        await tester.pumpAndSettle();

        expect(find.byType(AddLogScreen), findsOneWidget);
        expect(find.text('Observation'), findsWidgets);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is TextFormField &&
                (widget.initialValue ?? '').contains('Lighting schedule') &&
                (widget.initialValue ?? '').contains('Lights on: 10:00 AM') &&
                (widget.initialValue ?? '').contains('Lights off: 8:00 PM') &&
                (widget.initialValue ?? '').contains('Total light: 10 hours'),
          ),
          findsOneWidget,
        );
      },
    );
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
