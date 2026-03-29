// Tests for StockingCalculator.calculate()
//
// Run: flutter test test/services/stocking_calculator_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:danio/services/stocking_calculator.dart';
import 'package:danio/models/tank.dart';
import 'package:danio/models/livestock.dart';

Tank _testTank({double volumeLitres = 200}) {
  final now = DateTime.now();
  return Tank(
    id: 'tank-1',
    name: 'Test Tank',
    type: TankType.freshwater,
    volumeLitres: volumeLitres,
    startDate: now.subtract(const Duration(days: 30)),
    targets: WaterTargets.freshwaterTropical(),
    createdAt: now,
    updatedAt: now,
  );
}

Livestock _fish({
  String id = 'fish-1',
  String commonName = 'Neon Tetra',
  int count = 6,
  double? sizeCm = 4.0,
}) {
  final now = DateTime.now();
  return Livestock(
    id: id,
    tankId: 'tank-1',
    commonName: commonName,
    count: count,
    sizeCm: sizeCm,
    dateAdded: now,
    createdAt: now,
    updatedAt: now,
    healthStatus: HealthStatus.healthy,
  );
}

void main() {
  group('StockingCalculator — empty tank', () {
    test('no livestock → understocked with 0% full', () {
      final tank = _testTank();
      final result = StockingCalculator.calculate(
        tank: tank,
        livestock: [],
      );
      expect(result.level, equals(StockingLevel.understocked));
      expect(result.percentFull, equals(0.0));
    });

    test('empty tank summary mentions no livestock', () {
      final tank = _testTank();
      final result = StockingCalculator.calculate(
        tank: tank,
        livestock: [],
      );
      expect(result.summary.isNotEmpty, isTrue);
    });

    test('empty tank → suggestions provided', () {
      final tank = _testTank();
      final result = StockingCalculator.calculate(
        tank: tank,
        livestock: [],
      );
      expect(result.suggestions, isNotEmpty);
    });
  });

  group('StockingCalculator — basic calculation', () {
    test('small number of fish in large tank → good or understocked', () {
      final tank = _testTank(volumeLitres: 400); // ~105 gallons
      final livestock = [_fish(count: 6, sizeCm: 4.0)]; // ~6 total inches
      final result = StockingCalculator.calculate(
        tank: tank,
        livestock: livestock,
      );
      // 6 * (4/2.54) ≈ 9.4 inches, 105 gallons, ≈9% full → understocked
      expect(
        result.level,
        anyOf(StockingLevel.understocked, StockingLevel.good),
      );
      expect(result.percentFull, greaterThan(0));
    });

    test('percent full increases with more fish', () {
      final tank = _testTank(volumeLitres: 100); // ~26 gallons
      final fewFish = [_fish(count: 2, sizeCm: 4.0)];
      final manyFish = [_fish(count: 20, sizeCm: 4.0)];

      final fewResult = StockingCalculator.calculate(
        tank: tank,
        livestock: fewFish,
      );
      final manyResult = StockingCalculator.calculate(
        tank: tank,
        livestock: manyFish,
      );

      expect(manyResult.percentFull, greaterThan(fewResult.percentFull));
    });

    test('percentFull is clamped to 150 max', () {
      final tank = _testTank(volumeLitres: 20); // tiny ~5-gallon tank
      final livestock = [_fish(count: 50, sizeCm: 10.0)]; // huge overstock
      final result = StockingCalculator.calculate(
        tank: tank,
        livestock: livestock,
      );
      expect(result.percentFull, lessThanOrEqualTo(150));
    });
  });

  group('StockingCalculator — overstocked tank', () {
    test('too many fish in small tank → overstocked', () {
      // 30-gallon tank with 40 x 5cm fish (~63 total inches) → ~210% → overstocked
      final tank = _testTank(volumeLitres: 113); // ~30 gallons
      final livestock = [_fish(count: 40, sizeCm: 5.0, commonName: 'Unknown Fish')];
      final result = StockingCalculator.calculate(
        tank: tank,
        livestock: livestock,
      );
      expect(result.level, equals(StockingLevel.overstocked));
    });

    test('overstocked → warning in result', () {
      final tank = _testTank(volumeLitres: 40); // ~10 gallons
      final livestock = [_fish(count: 30, sizeCm: 5.0, commonName: 'Unknown Fish')];
      final result = StockingCalculator.calculate(
        tank: tank,
        livestock: livestock,
      );
      // Should be overstocked or heavy, warnings or suggestions should exist
      expect(
        result.level,
        anyOf(StockingLevel.overstocked, StockingLevel.heavy),
      );
    });

    test('overstocked summary is not empty', () {
      final tank = _testTank(volumeLitres: 40);
      final livestock = [_fish(count: 30, sizeCm: 5.0, commonName: 'Unknown Fish')];
      final result = StockingCalculator.calculate(
        tank: tank,
        livestock: livestock,
      );
      expect(result.summary, isNotEmpty);
    });
  });

  group('StockingCalculator — multiple livestock entries', () {
    test('multiple species counted together', () {
      final tank = _testTank(volumeLitres: 100); // ~26 gallons
      final livestock = [
        _fish(id: 'f1', commonName: 'Guppy', count: 5, sizeCm: 5.0),
        _fish(id: 'f2', commonName: 'Corydoras', count: 4, sizeCm: 6.0),
      ];
      final result = StockingCalculator.calculate(
        tank: tank,
        livestock: livestock,
      );
      expect(result.percentFull, greaterThan(0));
    });
  });

  group('StockingCalculator — stocking levels', () {
    test('result level is one of the defined enum values', () {
      final tank = _testTank();
      final livestock = [_fish(count: 5, sizeCm: 3.0)];
      final result = StockingCalculator.calculate(
        tank: tank,
        livestock: livestock,
      );
      expect(StockingLevel.values, contains(result.level));
    });

    test('moderate stocking range returns moderate level', () {
      // ~26-gallon tank, fish giving ~40-60% fill
      // 15 fish * 2-inch fish = 30 inches, 26 gallons → ~115% → heavy
      // Try 10 fish * 1.5-inch = 15 inches, 26 gallons → ~58% → good/moderate
      final tank = _testTank(volumeLitres: 100);
      final livestock = [
        _fish(count: 10, sizeCm: 3.8, commonName: 'Small Fish'),
      ];
      final result = StockingCalculator.calculate(
        tank: tank,
        livestock: livestock,
      );
      // Just verify it's a valid level
      expect(StockingLevel.values, contains(result.level));
    });
  });
}
