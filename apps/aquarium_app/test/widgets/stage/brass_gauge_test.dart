import 'package:danio/widgets/stage/temperature/brass_gauge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BrassGauge', () {
    testWidgets('renders center temp label at rest', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 240,
                height: 240,
                child: BrassGauge(
                  temp: 24.0,
                  gaugeMin: 18,
                  gaugeMax: 30,
                  optimalMin: 24,
                  optimalMax: 26,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('24.0°C'), findsOneWidget);
    });

    testWidgets('renders "--°C" placeholder when temp is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 240,
                height: 240,
                child: BrassGauge(
                  temp: null,
                  gaugeMin: 18,
                  gaugeMax: 30,
                  optimalMin: 24,
                  optimalMax: 26,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('--°C'), findsOneWidget);
    });
  });
}
