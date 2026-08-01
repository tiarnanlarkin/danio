import 'package:danio/models/log_entry.dart';
import 'package:danio/models/tank.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/screens/add_log_screen.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/theme/room_themes.dart';
import 'package:danio/utils/navigation_throttle.dart';
import 'package:danio/widgets/stage/stage_provider.dart';
import 'package:danio/widgets/stage/swiss_army_panel.dart';
import 'package:danio/widgets/stage/water_panel_content.dart';
import 'package:danio/widgets/stage/water_quality/brass_medallion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(NavigationThrottle.reset);
  tearDown(NavigationThrottle.reset);

  group('WaterPanelContent (concept lock 2026-04-07)', () {
    testWidgets('has no outer gradient container wrapping the scroll view', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            latestWaterTestProvider('t1').overrideWith(
              (_) => Future.value(null),
            ),
            latestWaterTestEntryProvider('t1').overrideWith(
              (_) => Future.value(null),
            ),
            logsProvider('t1').overrideWith((_) => Future.value(<LogEntry>[])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: WaterPanelContent(tankId: 't1', theme: RoomTheme.ocean),
            ),
          ),
        ),
      );
      // Advance past the 150 ms post-frame delay that schedules the
      // health-ring animation, then settle the animation itself.
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // The first descendant of WaterPanelContent should be a SingleChildScrollView,
      // not a Container-with-gradient.
      final scroll = find.byType(SingleChildScrollView);
      expect(scroll, findsOneWidget);

      // Walk the tree and assert no descendant Container
      // inside WaterPanelContent has a BoxDecoration with a gradient.
      final containersWithGradient = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(WaterPanelContent),
              matching: find.byType(Container),
            ),
          )
          .where(
            (c) =>
                c.decoration is BoxDecoration &&
                (c.decoration as BoxDecoration).gradient != null,
          )
          .toList();

      expect(
        containersWithGradient,
        isEmpty,
        reason: 'Concept lock: no outer card container on water panel content',
      );
    });

    testWidgets('WqHealthScoreCard has no card wrapper decoration', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: Builder(
                  builder: (context) {
                    final anim = AnimationController(
                      vsync: const TestVSync(),
                      duration: Duration.zero,
                    )..value = 1.0;
                    return WqHealthScoreCard(
                      health: WqHealthStatus.excellent,
                      ringAnim: anim,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final decorated = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(WqHealthScoreCard),
              matching: find.byType(Container),
            ),
          )
          .where(
            (c) =>
                c.decoration is BoxDecoration &&
                ((c.decoration as BoxDecoration).color != null ||
                    (c.decoration as BoxDecoration).boxShadow != null ||
                    (c.decoration as BoxDecoration).border != null),
          )
          .toList();

      expect(
        decorated,
        isEmpty,
        reason:
            'Concept lock: health score ring keeps its widget but loses the card wrapper',
      );
    });

    testWidgets(
      'WqHealthScoreCard uses plain status copy for excellent water',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Builder(
                    builder: (context) {
                      final anim = AnimationController(
                        vsync: const TestVSync(),
                        duration: Duration.zero,
                      )..value = 1.0;
                      return WqHealthScoreCard(
                        health: WqHealthStatus.excellent,
                        ringAnim: anim,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('All parameters in range'), findsOneWidget);
        expect(find.textContaining('🎉'), findsNothing);
      },
    );

    testWidgets(
      'WqParamGrid lays out priority/secondary as 2×3 brass medallions',
      (tester) async {
        final params = [
          const WqParamSpec(
            key: 'pH',
            label: 'pH',
            unit: '',
            idealRange: '6.5 – 7.8',
            value: 7.2,
            status: WqParamStatus.perfect,
          ),
          const WqParamSpec(
            key: 'NH₃',
            label: 'Ammonia',
            unit: 'ppm',
            idealRange: '< 0.25',
            value: 0,
            status: WqParamStatus.perfect,
          ),
          const WqParamSpec(
            key: 'NO₂',
            label: 'Nitrite',
            unit: 'ppm',
            idealRange: '0',
            value: 0,
            status: WqParamStatus.perfect,
          ),
          const WqParamSpec(
            key: 'NO₃',
            label: 'Nitrate',
            unit: 'ppm',
            idealRange: '< 20',
            value: 10,
            status: WqParamStatus.perfect,
          ),
          const WqParamSpec(
            key: 'GH',
            label: 'GH',
            unit: 'dGH',
            idealRange: '4–12',
            value: 8,
            status: WqParamStatus.perfect,
          ),
          const WqParamSpec(
            key: 'KH',
            label: 'KH',
            unit: 'dKH',
            idealRange: '3–8',
            value: 5,
            status: WqParamStatus.perfect,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 360,
                child: WqParamGrid(params: params),
              ),
            ),
          ),
        );

        // 6 medallions in the grid
        expect(find.byType(BrassMedallion), findsNWidgets(6));

        // Priority row contains the top 3 param keys
        expect(find.text('pH'), findsOneWidget);
        expect(find.text('NH₃'), findsOneWidget);
        expect(find.text('NO₂'), findsOneWidget);
        // Secondary row
        expect(find.text('NO₃'), findsOneWidget);
        expect(find.text('GH'), findsOneWidget);
        expect(find.text('KH'), findsOneWidget);
        // Legacy WqParamCard was removed in Task 14.
      },
    );

    testWidgets('WqSparklineSection has no card wrapper', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WqSparklineSection(
              phData: const [7.0, 7.1, 7.0, 7.2, 7.1, 7.0, 7.1],
              nitData: const [10, 12, 10, 14, 12, 11, 10],
            ),
          ),
        ),
      );

      final decorated = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(WqSparklineSection),
              matching: find.byType(Container),
            ),
          )
          .where(
            (c) =>
                c.decoration is BoxDecoration &&
                ((c.decoration as BoxDecoration).color != null ||
                    (c.decoration as BoxDecoration).border != null),
          )
          .toList();

      expect(
        decorated,
        isEmpty,
        reason: 'Concept lock: sparkline section has no card wrapper',
      );
    });

    testWidgets('Water Log button is an OutlinedButton pill, not filled', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            latestWaterTestProvider(
              't1',
            ).overrideWith((_) => Future.value(null)),
            latestWaterTestEntryProvider(
              't1',
            ).overrideWith((_) => Future.value(null)),
            logsProvider('t1').overrideWith((_) => Future.value(<LogEntry>[])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: WaterPanelContent(tankId: 't1', theme: RoomTheme.ocean),
            ),
          ),
        ),
      );
      // Pump past the 150ms Future.delayed in initState (see Task 2 test)
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // No filled ElevatedButton in the water panel
      expect(
        find.descendant(
          of: find.byType(WaterPanelContent),
          matching: find.byType(ElevatedButton),
        ),
        findsNothing,
      );

      // A single OutlinedButton (the log button)
      expect(
        find.descendant(
          of: find.byType(WaterPanelContent),
          matching: find.byType(OutlinedButton),
        ),
        findsOneWidget,
      );
      expect(find.text('Log Water Test'), findsOneWidget);
    });
  });

  group('WaterPanelContent Phase 4 hybrid instrument', () {
    testWidgets(
      'renders one parameter-first decorative chassis with native read-only values',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 844);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        await _pumpWaterPhase4Panel(tester);

        final skin = find.byKey(const ValueKey('water-hybrid-skin'));
        expect(skin, findsOneWidget);
        expect(
          find.descendant(of: skin, matching: find.byType(Image)),
          findsOneWidget,
        );
        expect(find.text('Water Quality'), findsOneWidget);
        expect(find.textContaining('Last manual test'), findsOneWidget);
        expect(find.textContaining('6.5'), findsOneWidget);
        expect(find.textContaining('< 0.25 ppm'), findsOneWidget);
        expect(find.textContaining('4'), findsWidgets);
        expect(find.textContaining('3'), findsWidgets);
        expect(
          find.bySemanticsLabel(
            'Expected manual water-test ranges: '
            'pH 6.5 – 7.8, Ammonia < 0.25 ppm, Nitrite 0 ppm, '
            'Nitrate < 20 ppm, GH 4 – 12 dGH, KH 3 – 8 dKH',
          ),
          findsOneWidget,
        );

        for (final key in const [
          'ph',
          'ammonia',
          'nitrite',
          'nitrate',
          'gh',
          'kh',
        ]) {
          final parameter = find.byKey(ValueKey('water-param-$key'));
          expect(parameter, findsOneWidget);
          expect(
            tester
                .getSemantics(parameter)
                .getSemanticsData()
                .hasAction(SemanticsAction.tap),
            isFalse,
            reason: '$key is a local reading, not an apparent control.',
          );
        }

        final logWaterTest = find.bySemanticsLabel('Log Water Test');
        expect(logWaterTest, findsOneWidget);
        expect(
          tester.getRect(logWaterTest).shortestSide,
          greaterThanOrEqualTo(48),
        );
      },
    );

    testWidgets('a failed current test stays distinct from no logged test', (
      tester,
    ) async {
      await _pumpWaterPhase4Panel(tester, failLatestTest: true);

      expect(find.text('Water test data unavailable'), findsOneWidget);
      expect(find.text('All parameters in range'), findsNothing);
      expect(find.text('No Data'), findsNothing);
    });

    testWidgets(
      'Log Water Test closes the panel and keeps the existing tank context',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 844);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final harness = await _pumpWaterPhase4Panel(tester);

        expect(
          harness.container
              .read(stageProvider)
              .openPanels
              .contains(StagePanel.waterQuality),
          isTrue,
        );
        await tester.tap(find.bySemanticsLabel('Log Water Test'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));

        expect(
          harness.container
              .read(stageProvider)
              .openPanels
              .contains(StagePanel.waterQuality),
          isFalse,
        );
        final destination = find.byType(AddLogScreen);
        expect(destination, findsOneWidget);
        final addLog = tester.widget<AddLogScreen>(destination);
        expect(addLog.tankId, _waterPhase4TankId);
        expect(addLog.initialType, LogType.waterTest);
        await tester.pump(const Duration(seconds: 2));
      },
    );

    testWidgets('large text uses the responsive panel before overlays shrink', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await _pumpWaterPhase4Panel(
        tester,
        textScaler: const TextScaler.linear(2),
      );

      expect(find.byKey(const ValueKey('water-hybrid-skin')), findsNothing);
      expect(find.bySemanticsLabel('Log Water Test'), findsOneWidget);
    });
  });
}

const _waterPhase4TankId = 'phase4-water-panel-tank';

class _WaterPhase4Harness {
  final ProviderContainer container;

  const _WaterPhase4Harness(this.container);
}

Future<_WaterPhase4Harness> _pumpWaterPhase4Panel(
  WidgetTester tester, {
  bool failLatestTest = false,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  final storage = InMemoryStorageService.ephemeral();
  final timestamp = DateTime.utc(2026, 8, 1, 12);
  await storage.saveTank(
    Tank(
      id: _waterPhase4TankId,
      name: 'Water panel test tank',
      type: TankType.freshwater,
      volumeLitres: 90,
      startDate: timestamp.subtract(const Duration(days: 120)),
      targets: WaterTargets.freshwaterTropical(),
      createdAt: timestamp.subtract(const Duration(days: 120)),
      updatedAt: timestamp,
    ),
  );
  final latest = LogEntry(
    id: 'phase4-water-latest',
    tankId: _waterPhase4TankId,
    type: LogType.waterTest,
    timestamp: timestamp,
    createdAt: timestamp,
    waterTest: WaterTestResults(
      ph: 7.2,
      ammonia: 0,
      nitrite: 0,
      nitrate: 12,
      gh: 8,
      kh: 5,
    ),
  );
  final previous = LogEntry(
    id: 'phase4-water-previous',
    tankId: _waterPhase4TankId,
    type: LogType.waterTest,
    timestamp: timestamp.subtract(const Duration(days: 1)),
    createdAt: timestamp.subtract(const Duration(days: 1)),
    waterTest: WaterTestResults(ph: 7.1, nitrate: 10),
  );
  final container = ProviderContainer(
    overrides: [
      storageServiceProvider.overrideWithValue(storage),
      latestWaterTestProvider(_waterPhase4TankId).overrideWith(
        (_) => failLatestTest
            ? Future<WaterTestResults?>.error(StateError('water test failed'))
            : Future<WaterTestResults?>.value(latest.waterTest),
      ),
      latestWaterTestEntryProvider(_waterPhase4TankId).overrideWith(
        (_) => Future<LogEntry?>.value(latest),
      ),
      logsProvider(_waterPhase4TankId).overrideWith(
        (_) => Future<List<LogEntry>>.value([latest, previous]),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: true,
            textScaler: textScaler,
          ),
          child: child ?? const SizedBox.shrink(),
        ),
        home: Scaffold(
          body: Stack(
            children: [
              SwissArmyPanel.right(
                theme: RoomTheme.ocean,
                child: WaterPanelContent(
                  tankId: _waterPhase4TankId,
                  theme: RoomTheme.ocean,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  container.read(stageProvider.notifier).open(StagePanel.waterQuality);
  await tester.pump();
  await tester.pumpAndSettle();
  return _WaterPhase4Harness(container);
}
