// Widget tests for water parameter field status labels.
//
// Run: flutter test test/widget_tests/water_param_fields_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/add_log/water_param_fields.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

void main() {
  group('Water parameter fields', () {
    testWidgets('standard field danger label avoids raw symbol text', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ParameterField(
            label: 'Ammonia',
            value: 1.0,
            onChanged: (_) {},
            warningThreshold: 0.25,
            dangerThreshold: 0.5,
          ),
        ),
      );

      expect(find.text('Danger'), findsOneWidget);
      expect(find.textContaining('✕ Danger'), findsNothing);
    });

    testWidgets('compact field safe label avoids raw symbol text', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          CompactParamField(
            label: 'Ammonia',
            value: 0.0,
            onChanged: (_) {},
            warningThreshold: 0.25,
            dangerThreshold: 0.5,
          ),
        ),
      );

      expect(find.text('Safe'), findsOneWidget);
      expect(find.textContaining('✓ Safe'), findsNothing);
    });
  });
}
