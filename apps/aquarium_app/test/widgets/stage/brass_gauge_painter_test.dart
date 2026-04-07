import 'package:danio/widgets/stage/temperature/brass_gauge_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BrassGaugePainter', () {
    test('shouldRepaint returns true only on relevant changes', () {
      const a = BrassGaugePainter(
        tempFraction: 0.5,
        optFracMin: 0.5,
        optFracMax: 0.67,
      );
      const b = BrassGaugePainter(
        tempFraction: 0.5,
        optFracMin: 0.5,
        optFracMax: 0.67,
      );
      expect(a.shouldRepaint(b), isFalse);

      const c = BrassGaugePainter(
        tempFraction: 0.6,
        optFracMin: 0.5,
        optFracMax: 0.67,
      );
      expect(a.shouldRepaint(c), isTrue);
    });

    testWidgets('paints without throwing for all fraction extremes',
        (tester) async {
      for (final frac in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(
                    painter: BrassGaugePainter(
                      tempFraction: frac,
                      optFracMin: 0.5,
                      optFracMax: 0.67,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
      }
    });

    testWidgets('accepts null tempFraction (no needle drawn)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: BrassGaugePainter(
                    tempFraction: null,
                    optFracMin: 0.5,
                    optFracMax: 0.67,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    });
  });
}
