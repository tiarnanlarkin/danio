// Widget tests for CyclingStatusCard.
//
// Run: flutter test test/widget_tests/cycling_status_card_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/models/models.dart';
import 'package:danio/widgets/cycling_status_card.dart';

const _tankId = 'tank-cycle-card';

Tank _tank() {
  final now = DateTime.now();
  return Tank(
    id: _tankId,
    name: 'Cycle Test',
    type: TankType.freshwater,
    volumeLitres: 100,
    startDate: now.subtract(const Duration(days: 10)),
    targets: WaterTargets.freshwaterTropical(),
    createdAt: now,
    updatedAt: now,
  );
}

LogEntry _cycledWaterTest() {
  final now = DateTime.now();
  return LogEntry(
    id: 'cycled-test',
    tankId: _tankId,
    type: LogType.waterTest,
    timestamp: now,
    waterTest: WaterTestResults(ammonia: 0, nitrite: 0, nitrate: 15),
    createdAt: now,
  );
}

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

void main() {
  group('CyclingStatusCard', () {
    testWidgets('cycled title avoids duplicate raw check mark text', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(CyclingStatusCard(tank: _tank(), logs: [_cycledWaterTest()])),
      );

      expect(find.text('Tank is Cycled'), findsOneWidget);
      expect(find.text('Tank is Cycled \u2713'), findsNothing);
    });
  });
}
