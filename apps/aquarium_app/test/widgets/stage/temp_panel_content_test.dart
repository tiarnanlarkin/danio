// test/widgets/stage/temp_panel_content_test.dart
import 'package:danio/widgets/stage/temperature/brass_gauge.dart';
import 'package:danio/widgets/stage/temperature/heater_status.dart';
import 'package:danio/widgets/stage/temperature/temperature_gauge.dart';
import 'package:danio/widgets/stage/temperature/temperature_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TempHeroSection (concept lock 2026-04-07)', () {
    testWidgets('renders a BrassGauge, not a ThermometerPainter',
        (tester) async {
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
      // Old thermometer painter should no longer be in the tree
      final thermometers = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .where((cp) => cp.painter is ThermometerPainter)
          .toList();
      expect(thermometers, isEmpty,
          reason: 'ThermometerPainter replaced by BrassGaugePainter');

      anim.dispose();
    });

    testWidgets('HeaterStatusPill renders ON state and last-test string',
        (tester) async {
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

    testWidgets('TempTrendSection has no card wrapper decoration',
        (tester) async {
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

    testWidgets('TempTrendSection chart is slim (<= 40px tall)', (tester) async {
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
          .where((sb) => sb.height != null && sb.height! > 20 && sb.height! <= 40)
          .toList();
      expect(sizedBox, isNotEmpty);
    });
  });
}
