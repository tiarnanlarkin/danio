import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/widgets/stage/temperature/brass_gauge.dart';
import 'package:danio/widgets/stage/water_quality/brass_medallion.dart';
import 'package:danio/widgets/stage/water_quality/water_param_card.dart';

void main() {
  group('Tank stage gauge typography', () {
    testWidgets('temperature value uses normal letter spacing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: SizedBox(
                width: 180,
                height: 180,
                child: BrassGauge(
                  temp: 25.5,
                  gaugeMin: 18,
                  gaugeMax: 32,
                  optimalMin: 24,
                  optimalMax: 27,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final valueText = tester.widget<Text>(find.text('25.5°C'));
      expect(valueText.style?.letterSpacing ?? 0, 0);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('water medallion value uses normal letter spacing', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: BrassMedallion(
                  label: 'pH',
                  value: '7.2',
                  unit: '',
                  status: WqParamStatus.perfect,
                ),
              ),
            ),
          ),
        ),
      );

      final valueText = tester.widget<Text>(find.text('7.2'));
      expect(valueText.style?.letterSpacing ?? 0, 0);
    });
  });
}
