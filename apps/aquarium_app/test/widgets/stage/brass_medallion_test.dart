import 'package:danio/widgets/stage/water_quality/brass_medallion.dart';
import 'package:danio/widgets/stage/water_quality/water_param_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BrassMedallion', () {
    testWidgets('renders label, value, and unit', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
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
      );
      expect(find.text('pH'), findsOneWidget);
      expect(find.text('7.2'), findsOneWidget);
    });

    testWidgets('shows "--" when value is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 120,
              height: 120,
              child: BrassMedallion(
                label: 'NH₃',
                value: null,
                unit: 'ppm',
                status: WqParamStatus.unknown,
              ),
            ),
          ),
        ),
      );
      expect(find.text('NH₃'), findsOneWidget);
      expect(find.text('--'), findsOneWidget);
    });

    testWidgets('exposes status via semantics label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 120,
              height: 120,
              child: BrassMedallion(
                label: 'NO₂',
                value: '0',
                unit: 'ppm',
                status: WqParamStatus.danger,
              ),
            ),
          ),
        ),
      );
      expect(
        find.bySemanticsLabel(RegExp(r'NO₂.*Danger')),
        findsOneWidget,
      );
    });
  });
}
