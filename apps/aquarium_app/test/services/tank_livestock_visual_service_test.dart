import 'package:danio/models/models.dart';
import 'package:danio/services/tank_livestock_visual_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('healthy compatible livestock returns clear', () {
    final state = TankLivestockVisualService.fromTank(
      tank: _tank(),
      livestock: [_livestock('betta', 'Betta')],
    );

    expect(state.condition, TankLivestockVisualCondition.clear);
    expect(state.hasOverlay, isFalse);
  });

  test('sick livestock returns health concern before compatibility', () {
    final state = TankLivestockVisualService.fromTank(
      tank: _tank(),
      livestock: [
        _livestock('betta', 'Betta', healthStatus: HealthStatus.sick),
        _livestock('guppy', 'Guppy', count: 3),
      ],
    );

    expect(state.condition, TankLivestockVisualCondition.healthConcern);
    expect(
      state.semanticsLabel,
      'Tank livestock visual state: livestock health needs review',
    );
  });

  test('compatibility issues return compatibility concern', () {
    final state = TankLivestockVisualService.fromTank(
      tank: _tank(),
      livestock: [
        _livestock('betta', 'Betta'),
        _livestock('guppy', 'Guppy', count: 3),
      ],
    );

    expect(state.condition, TankLivestockVisualCondition.compatibilityConcern);
    expect(
      state.semanticsLabel,
      'Tank livestock visual state: compatibility needs review',
    );
  });
}

Tank _tank() {
  final now = DateTime(2026, 6, 13);
  return Tank(
    id: 'tank-1',
    name: 'Community Tank',
    type: TankType.freshwater,
    volumeLitres: 100,
    startDate: now,
    targets: WaterTargets.freshwaterTropical(),
    createdAt: now,
    updatedAt: now,
  );
}

Livestock _livestock(
  String id,
  String commonName, {
  int count = 1,
  HealthStatus healthStatus = HealthStatus.healthy,
}) {
  final now = DateTime(2026, 6, 13);
  return Livestock(
    id: id,
    tankId: 'tank-1',
    commonName: commonName,
    count: count,
    dateAdded: now,
    healthStatus: healthStatus,
    createdAt: now,
    updatedAt: now,
  );
}
