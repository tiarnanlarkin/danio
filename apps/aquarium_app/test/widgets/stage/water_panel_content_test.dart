import 'package:danio/models/log_entry.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/theme/room_themes.dart';
import 'package:danio/widgets/stage/water_panel_content.dart';
import 'package:danio/widgets/stage/water_quality/brass_medallion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WaterPanelContent (concept lock 2026-04-07)', () {
    testWidgets('has no outer gradient container wrapping the scroll view',
        (tester) async {
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
        reason:
            'Concept lock: no outer card container on water panel content',
      );
    });

    testWidgets('WqHealthScoreCard has no card wrapper decoration',
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

    testWidgets('WqParamGrid lays out priority/secondary as 2×3 brass medallions',
        (tester) async {
      final params = [
        const WqParamSpec(
          key: 'pH', label: 'pH', unit: '', idealRange: '6.5 – 7.8',
          value: 7.2, status: WqParamStatus.perfect,
        ),
        const WqParamSpec(
          key: 'NH₃', label: 'Ammonia', unit: 'ppm', idealRange: '< 0.25',
          value: 0, status: WqParamStatus.perfect,
        ),
        const WqParamSpec(
          key: 'NO₂', label: 'Nitrite', unit: 'ppm', idealRange: '0',
          value: 0, status: WqParamStatus.perfect,
        ),
        const WqParamSpec(
          key: 'NO₃', label: 'Nitrate', unit: 'ppm', idealRange: '< 20',
          value: 10, status: WqParamStatus.perfect,
        ),
        const WqParamSpec(
          key: 'GH', label: 'GH', unit: 'dGH', idealRange: '4–12',
          value: 8, status: WqParamStatus.perfect,
        ),
        const WqParamSpec(
          key: 'KH', label: 'KH', unit: 'dKH', idealRange: '3–8',
          value: 5, status: WqParamStatus.perfect,
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

      // No legacy WqParamCard remaining
      expect(find.byType(WqParamCard), findsNothing);
    });
  });
}
