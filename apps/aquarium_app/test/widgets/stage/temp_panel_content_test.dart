// test/widgets/stage/temp_panel_content_test.dart
import 'dart:io';

import 'package:danio/models/log_entry.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/theme/room_themes.dart';
import 'package:danio/widgets/stage/temp_panel_content.dart';
import 'package:danio/widgets/stage/temperature/brass_gauge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TempHeroSection (concept lock 2026-04-07)', () {
    testWidgets('renders a BrassGauge', (tester) async {
      final anim = AnimationController(
        vsync: const TestVSync(),
        duration: Duration.zero,
      )..value = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                height: 500,
                child: TempHeroSection(
                  temp: 24.5,
                  fillAnim: anim,
                  gaugeMin: 18,
                  gaugeMax: 30,
                  optimalMin: 24,
                  optimalMax: 26,
                  status: TempStatus.perfect,
                  lastEntry: null,
                  formatTimestamp: (t) => 'now',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BrassGauge), findsOneWidget);
      // Legacy ThermometerPainter was removed in Task 14.

      anim.dispose();
    });

    testWidgets('HeaterStatusPill renders ON state and last-test string', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HeaterStatusPill(heaterOn: true, lastTestLabel: '2h ago'),
          ),
        ),
      );
      expect(find.text('Heater ON'), findsOneWidget);
      expect(find.textContaining('2h ago'), findsOneWidget);
    });

    testWidgets('HeaterStatusPill renders OFF state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HeaterStatusPill(heaterOn: false, lastTestLabel: null),
          ),
        ),
      );
      expect(find.text('Heater OFF'), findsOneWidget);
    });

    test('HeaterStatusPill uses shared alpha tokens', () {
      final source = File(
        'lib/widgets/stage/temperature/heater_status.dart',
      ).readAsStringSync();

      expect(source, contains('AppColors.whiteAlpha50'));
      expect(source, isNot(contains('Colors.white.withValues(alpha: 0.5)')));
    });

    testWidgets('TempTrendSection has no card wrapper decoration', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              child: TempTrendSection(
                sparkData: const [24, 24.5, 25, 24.5, 24, 24, 24.5],
                minTemp: 24,
                maxTemp: 25,
                avgTemp: 24.4,
              ),
            ),
          ),
        ),
      );

      final decorated = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(TempTrendSection),
              matching: find.byType(Container),
            ),
          )
          .where(
            (c) =>
                c.decoration is BoxDecoration &&
                ((c.decoration as BoxDecoration).color != null ||
                    (c.decoration as BoxDecoration).boxShadow != null),
          )
          .toList();
      expect(decorated, isEmpty);
    });

    testWidgets('TempTrendSection chart is slim (<= 40px tall)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              child: TempTrendSection(
                sparkData: const [24, 24.5, 25, 24.5, 24, 24, 24.5],
                minTemp: 24,
                maxTemp: 25,
                avgTemp: 24.4,
              ),
            ),
          ),
        ),
      );

      final sizedBox = tester
          .widgetList<SizedBox>(
            find.descendant(
              of: find.byType(TempTrendSection),
              matching: find.byType(SizedBox),
            ),
          )
          .where(
            (sb) => sb.height != null && sb.height! > 20 && sb.height! <= 40,
          )
          .toList();
      expect(sizedBox, isNotEmpty);
    });

    testWidgets(
      'TempTrendSection uses single-reading copy when one point exists',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 360,
                child: TempTrendSection(
                  sparkData: const [25.5],
                  minTemp: 25.5,
                  maxTemp: 25.5,
                  avgTemp: 25.5,
                ),
              ),
            ),
          ),
        );

        expect(find.text('No data yet'), findsNothing);
        expect(find.text('Add another reading to see a trend'), findsOneWidget);
      },
    );

    testWidgets(
      'TempPanelContent has no outer gradient + outlined log button',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              latestWaterTestProvider(
                't1',
              ).overrideWith((_) => Future.value(null)),
              latestWaterTestEntryProvider(
                't1',
              ).overrideWith((_) => Future.value(null)),
              testStreakProvider('t1').overrideWith((_) => Future.value(0)),
              logsProvider(
                't1',
              ).overrideWith((_) => Future.value(<LogEntry>[])),
              tankHeaterProvider('t1').overrideWith((_) => Future.value(null)),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: TempPanelContent(tankId: 't1', theme: RoomTheme.ocean),
              ),
            ),
          ),
        );
        // Pump past the 200ms Future.delayed in initState
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pumpAndSettle();

        final gradientContainers = tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(TempPanelContent),
                matching: find.byType(Container),
              ),
            )
            .where(
              (c) =>
                  c.decoration is BoxDecoration &&
                  (c.decoration as BoxDecoration).gradient != null,
            )
            .toList();
        expect(gradientContainers, isEmpty);

        // Log button is outlined pill
        expect(
          find.descendant(
            of: find.byType(TempPanelContent),
            matching: find.byType(ElevatedButton),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: find.byType(TempPanelContent),
            matching: find.byType(OutlinedButton),
          ),
          findsOneWidget,
        );
        expect(find.text('Log Temperature'), findsOneWidget);
      },
    );

    testWidgets(
      'TempPanelContent hides temperature metadata when test has no temperature',
      (tester) async {
        final timestamp = DateTime.utc(2026, 5, 25, 10);
        final entry = LogEntry(
          id: 'water-test-no-temp',
          tankId: 't1',
          type: LogType.waterTest,
          timestamp: timestamp,
          createdAt: timestamp,
          waterTest: WaterTestResults(ph: 7.2, ammonia: 0),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              latestWaterTestProvider(
                't1',
              ).overrideWith((_) => Future.value(entry.waterTest)),
              latestWaterTestEntryProvider(
                't1',
              ).overrideWith((_) => Future.value(entry)),
              testStreakProvider('t1').overrideWith((_) => Future.value(1)),
              logsProvider(
                't1',
              ).overrideWith((_) => Future.value(<LogEntry>[])),
              tankHeaterProvider('t1').overrideWith((_) => Future.value(null)),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: TempPanelContent(tankId: 't1', theme: RoomTheme.ocean),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pumpAndSettle();

        expect(find.text('--°C'), findsOneWidget);
        expect(find.textContaining('Last logged:'), findsNothing);
        expect(find.textContaining('Last test:'), findsNothing);
        expect(find.textContaining('1-day streak'), findsNothing);
      },
    );
  });
}
