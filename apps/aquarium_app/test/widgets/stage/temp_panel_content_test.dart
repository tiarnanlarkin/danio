// test/widgets/stage/temp_panel_content_test.dart
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show Tristate;

import 'package:danio/models/equipment.dart';
import 'package:danio/models/log_entry.dart';
import 'package:danio/models/tank.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/screens/add_log_screen.dart';
import 'package:danio/screens/charts_screen.dart';
import 'package:danio/screens/equipment_screen.dart';
import 'package:danio/screens/tank_detail/tank_detail_screen.dart';
import 'package:danio/screens/tank_settings_screen.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/theme/room_themes.dart';
import 'package:danio/utils/navigation_throttle.dart';
import 'package:danio/widgets/danio_bottom_dock.dart';
import 'package:danio/widgets/stage/stage_provider.dart';
import 'package:danio/widgets/stage/swiss_army_panel.dart';
import 'package:danio/widgets/stage/temp_panel_content.dart';
import 'package:danio/widgets/stage/temperature/brass_gauge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'haptic_feedback_enabled': false,
    });
    NavigationThrottle.reset();
  });

  tearDown(() {
    NavigationThrottle.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

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

    testWidgets('HeaterStatusPill reflows its honest label at 2.0x', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(225, 180));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final capturedErrors = <FlutterErrorDetails>[];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = capturedErrors.add;

      try {
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child ?? const SizedBox.shrink(),
            ),
            home: const Scaffold(
              body: Center(
                child: HeaterStatusPill(
                  heaterOn: true,
                  lastTestLabel: '9999d ago',
                ),
              ),
            ),
          ),
        );
        await tester.pump();
      } finally {
        FlutterError.onError = originalOnError;
      }

      expect(
        capturedErrors.map((details) => details.toString()),
        isEmpty,
      );
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
      'TempPanelContent keeps the flat instrument surface for an honest empty state',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tankProvider(
                't1',
              ).overrideWith((_) => Future.value(_testTank('t1'))),
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

        final panel = find.byType(TempPanelContent);
        expect(
          find.descendant(
            of: panel,
            matching: find.text('Log Temperature'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(of: panel, matching: find.text('--°C')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: panel, matching: find.text('No data yet')),
          findsOneWidget,
        );
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
              tankProvider(
                't1',
              ).overrideWith((_) => Future.value(_testTank('t1'))),
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

  group('Phase 3 temperature instrument contract', () {
    testWidgets(
      'an unmatched saved range selects Custom across provider rebuilds',
      (tester) async {
        final harness = await _pumpPhase3Panel(
          tester,
          targets: const WaterTargets(
            tempMin: 24,
            tempMax: 26,
            phMin: 6.8,
            phMax: 7.4,
            ghMin: 5,
            ghMax: 11,
            khMin: 3,
            khMax: 7,
          ),
        );
        _expectSelectedTarget(tester, 'Custom');
        expect(find.textContaining('24–26°C'), findsWidgets);
        expect(
          tester
              .getSemantics(_targetFinder('Custom'))
              .getSemanticsData()
              .attributedLabel
              .string,
          contains('24–26°C'),
        );

        harness.container.invalidate(tankProvider(_phase3TankId));
        await tester.pump();
        await tester.pumpAndSettle();

        _expectSelectedTarget(tester, 'Custom');
        expect(find.textContaining('24–26°C'), findsWidgets);
      },
    );

    testWidgets('decimal Custom targets stay exact in the instrument copy', (
      tester,
    ) async {
      await _pumpPhase3Panel(
        tester,
        targets: const WaterTargets(tempMin: 24.5, tempMax: 26.5),
      );

      _expectSelectedTarget(tester, 'Custom');
      expect(find.text('Optimal 24.5–26.5°C'), findsOneWidget);
      expect(find.text('Optimal 24–26°C'), findsNothing);
    });

    testWidgets('a one-sided saved target stays honest and crash-free', (
      tester,
    ) async {
      await _pumpPhase3Panel(
        tester,
        targets: const WaterTargets(tempMin: 24.5),
      );

      _expectSelectedTarget(tester, 'Custom');
      expect(find.text('Saved range unavailable'), findsOneWidget);
      expect(find.textContaining('Optimal '), findsNothing);
    });

    for (final preset in const [
      ('Tropical', 24.0, 28.0),
      ('Coldwater', 15.0, 22.0),
    ]) {
      testWidgets(
        'selecting ${preset.$1} changes only the saved temperature range',
        (tester) async {
          final harness = await _pumpPhase3Panel(
            tester,
            targets: const WaterTargets(
              tempMin: 23,
              tempMax: 27,
              phMin: 6.8,
              phMax: 7.4,
              ghMin: 5,
              ghMax: 11,
              khMin: 3,
              khMax: 7,
            ),
          );
          await tester.tap(_targetFinder(preset.$1));
          await tester.pump();
          await tester.pumpAndSettle();

          final saved = await harness.storage.getTank(_phase3TankId);
          expect(saved, isNotNull);
          expect(saved!.targets.tempMin, preset.$2);
          expect(saved.targets.tempMax, preset.$3);
          expect(saved.targets.phMin, 6.8);
          expect(saved.targets.phMax, 7.4);
          expect(saved.targets.ghMin, 5);
          expect(saved.targets.ghMax, 11);
          expect(saved.targets.khMin, 3);
          expect(saved.targets.khMax, 7);
          _expectSelectedTarget(tester, preset.$1);
        },
      );
    }

    testWidgets(
      'a rejected target save stays Custom and reports the failure',
      (tester) async {
        final harness = await _pumpPhase3Panel(
          tester,
          failPresetSave: true,
          targets: const WaterTargets(
            tempMin: 23,
            tempMax: 27,
            phMin: 6.8,
            phMax: 7.4,
            ghMin: 5,
            ghMax: 11,
            khMin: 3,
            khMax: 7,
          ),
        );

        await tester.tap(_targetFinder('Coldwater'));
        await tester.pump();
        await tester.pumpAndSettle();

        final saved = await harness.storage.getTank(_phase3TankId);
        expect(saved, isNotNull);
        expect(saved!.targets.tempMin, 23);
        expect(saved.targets.tempMax, 27);
        _expectSelectedTarget(tester, 'Custom');
        expect(
          find.text("Couldn't update temperature target. Try again."),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'an in-flight save cannot leak target state into another tank',
      (
        tester,
      ) async {
        const secondaryTankId = 'phase3-secondary-temperature-tank';
        late _DelayedTankSaveStorage delayedStorage;
        final harness = await _pumpPhase3Panel(
          tester,
          targets: const WaterTargets(tempMin: 23, tempMax: 27),
          secondaryTank: _testTank(
            secondaryTankId,
            targets: const WaterTargets(tempMin: 24, tempMax: 28),
          ),
          decorateStorage: (baseStorage) {
            delayedStorage = _DelayedTankSaveStorage(
              baseStorage,
              delayedTankId: _phase3TankId,
            );
            return delayedStorage;
          },
        );
        addTearDown(() {
          if (!delayedStorage.releaseSave.isCompleted) {
            delayedStorage.releaseSave.complete();
          }
        });

        await tester.tap(_targetFinder('Coldwater'));
        await tester.pump();
        await delayedStorage.saveStarted.future;
        _expectSelectedTarget(tester, 'Coldwater');

        await tester.pumpWidget(
          harness.buildApp(tankId: secondaryTankId),
        );
        await tester.pump();
        await tester.pumpAndSettle();

        _expectSelectedTarget(tester, 'Tropical');
        expect(
          tester
              .getSemantics(_targetFinder('Coldwater'))
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isTrue,
          reason: 'Tank B controls must not remain disabled by Tank A save',
        );

        delayedStorage.releaseSave.complete();
        await tester.pump();
        await tester.pumpAndSettle();

        _expectSelectedTarget(tester, 'Tropical');
        final savedA = await harness.storage.getTank(_phase3TankId);
        final savedB = await harness.storage.getTank(secondaryTankId);
        expect(savedA!.targets.tempMin, 15);
        expect(savedA.targets.tempMax, 22);
        expect(savedB!.targets.tempMin, 24);
        expect(savedB.targets.tempMax, 28);
      },
    );

    testWidgets('a target failure never falls back to a named preset', (
      tester,
    ) async {
      await _pumpPhase3Panel(
        tester,
        failTarget: true,
        temperature: 25.5,
      );

      expect(find.text('Target unavailable'), findsOneWidget);
      expect(find.text('Temperature unavailable'), findsNothing);
      expect(find.text('History unavailable'), findsNothing);
      expect(find.text('25.5°C'), findsOneWidget);
      expect(find.text('No data yet'), findsNothing);
      _expectNoSelectedTargetIfRendered(tester);
    });

    testWidgets(
      'a temperature failure stays distinct from a missing reading',
      (tester) async {
        await _pumpPhase3Panel(tester, failTemperature: true);

        expect(find.text('Target unavailable'), findsNothing);
        expect(find.text('Temperature unavailable'), findsOneWidget);
        expect(find.text('History unavailable'), findsNothing);
        expect(find.text('--°C'), findsNothing);
        expect(find.text('No data yet'), findsOneWidget);
        _expectSelectedTarget(tester, 'Tropical');
      },
    );

    testWidgets('a history failure never renders successful empty copy', (
      tester,
    ) async {
      await _pumpPhase3Panel(
        tester,
        failHistory: true,
        temperature: 25.5,
      );

      expect(find.text('Target unavailable'), findsNothing);
      expect(find.text('Temperature unavailable'), findsNothing);
      expect(find.text('History unavailable'), findsOneWidget);
      expect(find.text('25.5°C'), findsOneWidget);
      expect(find.text('No data yet'), findsNothing);
      _expectSelectedTarget(tester, 'Tropical');
    });

    testWidgets(
      'a manual temperature reading without heater data never reports Heater OFF',
      (tester) async {
        await _pumpPhase3Panel(tester, temperature: 25.5);

        expect(find.text('25.5°C'), findsOneWidget);
        expect(find.text('Heater OFF'), findsNothing);
        expect(find.text('Heater ON'), findsNothing);
      },
    );

    testWidgets(
      'malformed heater metadata stays hidden instead of fabricating a state',
      (tester) async {
        await _pumpPhase3Panel(
          tester,
          temperature: 25.5,
          heaterSettings: const {'on': 'off'},
        );

        expect(find.text('25.5°C'), findsOneWidget);
        expect(find.text('Heater OFF'), findsNothing);
        expect(find.text('Heater ON'), findsNothing);
      },
    );

    testWidgets(
      'boolean heater metadata stays hidden without an authoritative state contract',
      (tester) async {
        await _pumpPhase3Panel(
          tester,
          temperature: 25.5,
          heaterSettings: const {'on': true},
        );

        expect(find.text('25.5°C'), findsOneWidget);
        expect(find.text('Heater OFF'), findsNothing);
        expect(find.text('Heater ON'), findsNothing);
      },
    );

    testWidgets(
      'named targets and route actions expose executable accessibility taps',
      (tester) async {
        await _pumpPhase3Panel(tester);

        for (final label in const ['Tropical', 'Coldwater']) {
          expect(
            tester
                .getSemantics(_targetFinder(label))
                .getSemanticsData()
                .hasAction(SemanticsAction.tap),
            isTrue,
            reason: '$label must be operable through accessibility services',
          );
        }
        expect(
          tester
              .getSemantics(_targetFinder('Custom'))
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isFalse,
          reason: 'Custom is a derived state, not a fake editing action',
        );
        for (final label in const [
          'Log Temperature',
          'Charts/History',
          'Equipment',
          'Alerts',
          'Tank Settings',
        ]) {
          expect(
            tester
                .getSemantics(find.bySemanticsLabel(label))
                .getSemanticsData()
                .hasAction(SemanticsAction.tap),
            isTrue,
            reason: '$label must be operable through accessibility services',
          );
        }
      },
    );

    testWidgets(
      'actions keep the approved order and Tank Settings is visually secondary',
      (tester) async {
        await _pumpPhase3Panel(tester);

        final primaryGroup = find.byKey(
          const ValueKey('temperature-primary-actions'),
        );
        final secondaryGroup = find.byKey(
          const ValueKey('temperature-secondary-actions'),
        );
        expect(primaryGroup, findsOneWidget);
        expect(secondaryGroup, findsOneWidget);

        const primaryLabels = [
          'Log Temperature',
          'Charts/History',
          'Equipment',
          'Alerts',
        ];
        final primaryOrders = <double>[];
        for (final label in primaryLabels) {
          final action = find.bySemanticsLabel(label);
          expect(
            find.descendant(
              of: primaryGroup,
              matching: action,
            ),
            findsOneWidget,
          );
          expect(
            tester
                .getSemantics(action)
                .getSemanticsData()
                .flagsCollection
                .isButton,
            isTrue,
          );
          primaryOrders.add(_semanticOrder(tester, action));
        }
        expect(primaryOrders, orderedEquals([0, 1, 2, 3]));
        expect(
          find.descendant(
            of: primaryGroup,
            matching: find.bySemanticsLabel('Tank Settings'),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: secondaryGroup,
            matching: find.bySemanticsLabel('Tank Settings'),
          ),
          findsOneWidget,
        );
        final settings = find.bySemanticsLabel('Tank Settings');
        expect(
          _semanticOrder(tester, settings),
          greaterThan(primaryOrders.last),
        );
        expect(
          tester.getRect(settings).top,
          greaterThanOrEqualTo(
            tester.getRect(find.bySemanticsLabel('Alerts')).bottom,
          ),
        );
      },
    );

    testWidgets(
      'instrument chrome keeps readable contrast on every room panel surface',
      (tester) async {
        final harness = await _pumpPhase3Panel(
          tester,
          disableAnimations: true,
        );

        for (final roomTheme in RoomTheme.allThemes) {
          await tester.pumpWidget(
            harness.buildApp(roomThemeOverride: roomTheme),
          );
          await tester.pump();
          final panelSurface = Color.alphaBlend(
            roomTheme.glassCard.withValues(alpha: 0.92),
            Colors.white,
          );
          for (final label in const [
            'Temperature',
            'Target range',
            'Saved to this tank',
            'Log Temperature',
            'Tank Settings',
          ]) {
            final text = tester.widget<Text>(find.text(label).first);
            final foreground = text.style?.color;
            expect(
              foreground,
              isNotNull,
              reason: '$label needs an exact color',
            );
            expect(
              _contrastRatio(foreground!, panelSurface),
              greaterThanOrEqualTo(4.5),
              reason:
                  '$label must remain readable on the ${roomTheme.name} panel',
            );
          }
        }
      },
    );

    final actionRoutes = [
      _ActionRouteExpectation(
        label: 'Log Temperature',
        destinationType: AddLogScreen,
        verify: (widget) {
          final screen = widget as AddLogScreen;
          expect(screen.tankId, _phase3TankId);
          expect(screen.initialType, LogType.waterTest);
        },
      ),
      _ActionRouteExpectation(
        label: 'Charts/History',
        destinationType: ChartsScreen,
        verify: (widget) {
          final screen = widget as ChartsScreen;
          expect(screen.tankId, _phase3TankId);
          expect(screen.initialParam, 'temp');
        },
      ),
      _ActionRouteExpectation(
        label: 'Equipment',
        destinationType: EquipmentScreen,
        verify: (widget) {
          expect((widget as EquipmentScreen).tankId, _phase3TankId);
        },
      ),
      _ActionRouteExpectation(
        label: 'Alerts',
        destinationType: TankDetailScreen,
        verify: (widget) {
          expect((widget as TankDetailScreen).tankId, _phase3TankId);
        },
      ),
      _ActionRouteExpectation(
        label: 'Tank Settings',
        destinationType: TankSettingsScreen,
        verify: (widget) {
          expect((widget as TankSettingsScreen).tankId, _phase3TankId);
        },
      ),
    ];

    for (final route in actionRoutes) {
      testWidgets(
        '${route.label} closes the temperature panel and preserves tank context',
        (tester) async {
          final harness = await _pumpPhase3Panel(tester);

          expect(
            harness.container
                .read(stageProvider)
                .openPanels
                .contains(StagePanel.temp),
            isTrue,
          );
          harness.navigationObserver.arm();
          await tester.ensureVisible(find.text(route.label));
          await tester.tap(find.text(route.label));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 700));

          expect(
            harness.container
                .read(stageProvider)
                .openPanels
                .contains(StagePanel.temp),
            isFalse,
          );
          expect(
            harness.navigationObserver.tempWasOpenAtPush,
            isFalse,
            reason: 'StagePanel.temp must close before ${route.label} pushes',
          );
          final destination = find.byType(route.destinationType);
          expect(destination, findsOneWidget);
          route.verify(tester.widget<Widget>(destination));
          // Drain finite destination-screen entrance animations before the
          // widget-test binding checks for leaked timers.
          await tester.pump(const Duration(seconds: 2));
        },
      );
    }

    testWidgets(
      'the real 66 percent panel reflows at 2.0x and keeps actions above the dock',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final capturedErrors = <FlutterErrorDetails>[];
        final originalOnError = FlutterError.onError;
        FlutterError.onError = capturedErrors.add;

        try {
          await _pumpPhase3Panel(
            tester,
            textScaler: const TextScaler.linear(2),
            disableAnimations: true,
          );
          final panelScroll = find.byKey(
            const ValueKey('temperature-panel-scroll'),
          );
          expect(panelScroll, findsOneWidget);

          for (final target in const ['Tropical', 'Coldwater', 'Custom']) {
            final control = _targetFinder(target);
            await _bringControlIntoSafeView(tester, panelScroll, control);
            _expectDockSafeControl(
              tester,
              control,
              mustBeHitTestable: target != 'Custom',
            );
          }
          for (final label in const [
            'Log Temperature',
            'Charts/History',
            'Equipment',
            'Alerts',
            'Tank Settings',
          ]) {
            final control = find.bySemanticsLabel(label);
            await _bringControlIntoSafeView(tester, panelScroll, control);
            _expectDockSafeControl(tester, control);
          }
        } finally {
          FlutterError.onError = originalOnError;
        }

        expect(
          capturedErrors.map((details) => details.toString()),
          isEmpty,
        );
      },
    );

    testWidgets(
      '2.0x panel layout stays overflow-free in both brightness modes and every room theme',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final capturedErrors = <FlutterErrorDetails>[];
        final originalOnError = FlutterError.onError;
        FlutterError.onError = capturedErrors.add;

        try {
          final harness = await _pumpPhase3Panel(
            tester,
            textScaler: const TextScaler.linear(2),
            disableAnimations: true,
          );
          for (final brightness in Brightness.values) {
            for (final roomTheme in RoomTheme.allThemes) {
              await tester.pumpWidget(
                harness.buildApp(
                  brightnessOverride: brightness,
                  roomThemeOverride: roomTheme,
                ),
              );
              await tester.pump();
              expect(find.text('Temperature'), findsOneWidget);
              expect(
                find.byKey(const ValueKey('temperature-primary-actions')),
                findsOneWidget,
              );
            }
          }
        } finally {
          FlutterError.onError = originalOnError;
        }

        expect(
          capturedErrors.map((details) => details.toString()),
          isEmpty,
        );
      },
    );

    testWidgets(
      'target state settles without transient frames when animations are disabled',
      (tester) async {
        final harness = await _pumpPhase3Panel(
          tester,
          disableAnimations: true,
          targets: const WaterTargets(tempMin: 23, tempMax: 27),
        );

        final coldwater = _targetFinder('Coldwater');
        await tester.tap(coldwater);
        await tester.pump();

        _expectSelectedTarget(tester, 'Coldwater');
        final immediateRect = tester.getRect(coldwater);
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        _expectSelectedTarget(tester, 'Coldwater');
        expect(tester.getRect(coldwater), immediateRect);
        expect(
          (await harness.storage.getTank(_phase3TankId))!.targets.tempMin,
          15,
        );
      },
    );

    testWidgets(
      'disabled haptic preference suppresses target-selector platform feedback',
      (tester) async {
        final hapticCalls = _captureHapticCalls();
        await _pumpPhase3Panel(tester);

        await tester.tap(_targetFinder('Coldwater'));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(hapticCalls, isEmpty);
      },
    );

    testWidgets(
      'enabled haptic preference emits one selection click for a target change',
      (tester) async {
        final hapticCalls = _captureHapticCalls();
        await _pumpPhase3Panel(tester, hapticsEnabled: true);
        hapticCalls.clear();

        await tester.tap(_targetFinder('Coldwater'));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(
          hapticCalls.map((call) => call.arguments),
          ['HapticFeedbackType.selectionClick'],
        );
      },
    );
  });
}

const _phase3TankId = 'phase3-temperature-panel-tank';

class _ActionRouteExpectation {
  final String label;
  final Type destinationType;
  final void Function(Widget widget) verify;

  const _ActionRouteExpectation({
    required this.label,
    required this.destinationType,
    required this.verify,
  });
}

class _Phase3Harness {
  final ProviderContainer container;
  final StorageService storage;
  final TextScaler textScaler;
  final bool disableAnimations;
  final Brightness brightness;
  final RoomTheme roomTheme;
  final _StageOrderObserver navigationObserver;

  const _Phase3Harness({
    required this.container,
    required this.storage,
    required this.textScaler,
    required this.disableAnimations,
    required this.brightness,
    required this.roomTheme,
    required this.navigationObserver,
  });

  Widget buildApp({
    Brightness? brightnessOverride,
    RoomTheme? roomThemeOverride,
    String tankId = _phase3TankId,
  }) {
    final effectiveBrightness = brightnessOverride ?? brightness;
    final effectiveRoomTheme = roomThemeOverride ?? roomTheme;
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorObservers: [navigationObserver],
        theme: effectiveBrightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: textScaler,
            disableAnimations: disableAnimations,
          ),
          child: child ?? const SizedBox.shrink(),
        ),
        home: Scaffold(
          body: Stack(
            children: [
              SwissArmyPanel.left(
                theme: effectiveRoomTheme,
                child: TempPanelContent(
                  tankId: tankId,
                  theme: effectiveRoomTheme,
                ),
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: DanioBottomDock.contentClearance,
                child: AbsorbPointer(
                  child: ColoredBox(color: Color(0x01000000)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageOrderObserver extends NavigatorObserver {
  final ProviderContainer container;
  bool _armed = false;
  bool? tempWasOpenAtPush;

  _StageOrderObserver(this.container);

  void arm() {
    _armed = true;
    tempWasOpenAtPush = null;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (!_armed || tempWasOpenAtPush != null) return;
    tempWasOpenAtPush = container
        .read(stageProvider)
        .openPanels
        .contains(StagePanel.temp);
  }
}

class _FailingTankSaveStorage implements StorageService {
  final InMemoryStorageService delegate;

  _FailingTankSaveStorage(this.delegate);

  @override
  Future<Tank?> getTank(String id) => delegate.getTank(id);

  @override
  Future<void> saveTank(Tank tank) {
    return Future<void>.error(StateError('target save failed'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DelayedTankSaveStorage implements StorageService {
  final InMemoryStorageService delegate;
  final String delayedTankId;
  final saveStarted = Completer<void>();
  final releaseSave = Completer<void>();
  bool _hasDelayed = false;

  _DelayedTankSaveStorage(this.delegate, {required this.delayedTankId});

  @override
  Future<Tank?> getTank(String id) => delegate.getTank(id);

  @override
  Future<void> saveTank(Tank tank) async {
    if (!_hasDelayed && tank.id == delayedTankId) {
      _hasDelayed = true;
      saveStarted.complete();
      await releaseSave.future;
    }
    await delegate.saveTank(tank);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<_Phase3Harness> _pumpPhase3Panel(
  WidgetTester tester, {
  WaterTargets targets = const WaterTargets(
    tempMin: 24,
    tempMax: 28,
    phMin: 6.5,
    phMax: 7.5,
    ghMin: 4,
    ghMax: 12,
    khMin: 3,
    khMax: 8,
  ),
  double? temperature,
  bool failTarget = false,
  bool failTemperature = false,
  bool failHistory = false,
  bool failPresetSave = false,
  Map<String, dynamic>? heaterSettings,
  Tank? secondaryTank,
  StorageService Function(InMemoryStorageService)? decorateStorage,
  bool hapticsEnabled = false,
  TextScaler textScaler = TextScaler.noScaling,
  bool disableAnimations = false,
  Brightness brightness = Brightness.light,
  RoomTheme? roomTheme,
}) async {
  final baseStorage = InMemoryStorageService();
  await baseStorage.deleteTank(_phase3TankId);
  final timestamp = DateTime.utc(2026, 7, 30, 12);
  await baseStorage.saveTank(
    _testTank(
      _phase3TankId,
      targets: targets,
      timestamp: timestamp,
    ),
  );
  if (secondaryTank != null) {
    await baseStorage.saveTank(secondaryTank);
  }
  final StorageService storage = failPresetSave
      ? _FailingTankSaveStorage(baseStorage)
      : (decorateStorage?.call(baseStorage) ?? baseStorage);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('haptic_feedback_enabled', hapticsEnabled);
  final waterTest = temperature == null
      ? null
      : WaterTestResults(temperature: temperature);
  final latestEntry = waterTest == null
      ? null
      : LogEntry(
          id: 'phase3-temperature-reading',
          tankId: _phase3TankId,
          type: LogType.waterTest,
          timestamp: timestamp,
          createdAt: timestamp,
          waterTest: waterTest,
        );
  final heater = heaterSettings == null
      ? null
      : Equipment(
          id: 'phase3-heater',
          tankId: _phase3TankId,
          type: EquipmentType.heater,
          name: 'Test heater',
          settings: heaterSettings,
          createdAt: timestamp,
          updatedAt: timestamp,
        );

  final container = ProviderContainer(
    overrides: [
      storageServiceProvider.overrideWithValue(storage),
      sharedPreferencesProvider.overrideWith((_) async => prefs),
      if (failTarget)
        tankProvider(_phase3TankId).overrideWith(
          (_) => Future<Tank?>.error(StateError('target failed')),
        ),
      latestWaterTestProvider(_phase3TankId).overrideWith(
        (_) => failTemperature
            ? Future<WaterTestResults?>.error(
                StateError('temperature failed'),
              )
            : Future<WaterTestResults?>.value(waterTest),
      ),
      latestWaterTestEntryProvider(_phase3TankId).overrideWith(
        (_) => Future<LogEntry?>.value(latestEntry),
      ),
      testStreakProvider(
        _phase3TankId,
      ).overrideWith((_) => Future<int>.value(temperature == null ? 0 : 1)),
      logsProvider(_phase3TankId).overrideWith(
        (_) => failHistory
            ? Future<List<LogEntry>>.error(StateError('history failed'))
            : Future<List<LogEntry>>.value(
                latestEntry == null ? <LogEntry>[] : <LogEntry>[latestEntry],
              ),
      ),
      tankHeaterProvider(
        _phase3TankId,
      ).overrideWith((_) => Future.value(heater)),
      if (secondaryTank != null)
        latestWaterTestProvider(
          secondaryTank.id,
        ).overrideWith((_) => Future<WaterTestResults?>.value(null)),
      if (secondaryTank != null)
        latestWaterTestEntryProvider(
          secondaryTank.id,
        ).overrideWith((_) => Future<LogEntry?>.value(null)),
      if (secondaryTank != null)
        testStreakProvider(
          secondaryTank.id,
        ).overrideWith((_) => Future<int>.value(0)),
      if (secondaryTank != null)
        logsProvider(
          secondaryTank.id,
        ).overrideWith((_) => Future<List<LogEntry>>.value(<LogEntry>[])),
      if (secondaryTank != null)
        tankHeaterProvider(
          secondaryTank.id,
        ).overrideWith((_) => Future.value(null)),
    ],
  );
  container.read(stageProvider.notifier).open(StagePanel.temp);
  final navigationObserver = _StageOrderObserver(container);
  final harness = _Phase3Harness(
    container: container,
    storage: storage,
    textScaler: textScaler,
    disableAnimations: disableAnimations,
    brightness: brightness,
    roomTheme: roomTheme ?? RoomTheme.ocean,
    navigationObserver: navigationObserver,
  );
  addTearDown(() async {
    container.dispose();
    await baseStorage.deleteTank(_phase3TankId);
    if (secondaryTank != null) {
      await baseStorage.deleteTank(secondaryTank.id);
    }
  });

  await tester.pumpWidget(harness.buildApp());
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pumpAndSettle();
  return harness;
}

Tank _testTank(
  String id, {
  WaterTargets? targets,
  DateTime? timestamp,
}) {
  final now = timestamp ?? DateTime.utc(2026, 7, 30, 12);
  return Tank(
    id: id,
    name: 'Temperature Test Tank',
    type: TankType.freshwater,
    volumeLitres: 90,
    startDate: DateTime.utc(2026, 1, 1),
    targets: targets ?? WaterTargets.freshwaterTropical(),
    createdAt: now,
    updatedAt: now,
  );
}

Finder _targetFinder(String label) {
  return find.bySemanticsLabel(
    RegExp(
      '^${RegExp.escape(label)} temperature target(?:, .+)?\$',
    ),
  );
}

void _expectSelectedTarget(WidgetTester tester, String label) {
  for (final candidate in const ['Tropical', 'Coldwater', 'Custom']) {
    final semantics = tester.getSemantics(_targetFinder(candidate));
    expect(
      semantics.getSemanticsData().flagsCollection.isSelected,
      candidate == label ? Tristate.isTrue : Tristate.isFalse,
      reason: '$candidate selection must reflect the saved range',
    );
  }
}

void _expectNoSelectedTargetIfRendered(WidgetTester tester) {
  for (final candidate in const ['Tropical', 'Coldwater', 'Custom']) {
    final finder = _targetFinder(candidate);
    if (finder.evaluate().isEmpty) continue;
    final semantics = tester.getSemantics(finder);
    expect(
      semantics.getSemanticsData().flagsCollection.isSelected,
      Tristate.isFalse,
      reason:
          '$candidate must not be selected while target data is unavailable',
    );
  }
}

double _semanticOrder(WidgetTester tester, Finder finder) {
  final semantics = tester.widget<Semantics>(finder);
  final sortKey = semantics.properties.sortKey;
  expect(sortKey, isA<OrdinalSortKey>());
  return (sortKey! as OrdinalSortKey).order;
}

Future<void> _bringControlIntoSafeView(
  WidgetTester tester,
  Finder panelScroll,
  Finder control,
) async {
  expect(control, findsOneWidget);
  await Scrollable.ensureVisible(
    tester.element(control),
    alignment: 0.5,
    duration: Duration.zero,
  );
  await tester.pump();
  expect(panelScroll, findsOneWidget);
}

void _expectDockSafeControl(
  WidgetTester tester,
  Finder control, {
  bool mustBeHitTestable = true,
}) {
  if (mustBeHitTestable) {
    expect(control.hitTestable(), findsOneWidget);
  }
  final rect = tester.getRect(control);
  expect(rect.width, greaterThanOrEqualTo(48));
  expect(rect.height, greaterThanOrEqualTo(48));
  expect(rect.top, greaterThanOrEqualTo(0));
  expect(
    rect.bottom,
    lessThanOrEqualTo(844 - DanioBottomDock.contentClearance),
  );
}

List<MethodCall> _captureHapticCalls() {
  final calls = <MethodCall>[];
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          calls.add(call);
        }
        return null;
      });
  return calls;
}

double _contrastRatio(Color foreground, Color background) {
  final paintedForeground = Color.alphaBlend(foreground, background);
  final lighter = math.max(
    paintedForeground.computeLuminance(),
    background.computeLuminance(),
  );
  final darker = math.min(
    paintedForeground.computeLuminance(),
    background.computeLuminance(),
  );
  return (lighter + 0.05) / (darker + 0.05);
}
