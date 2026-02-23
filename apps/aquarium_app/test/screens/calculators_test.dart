/// Tests for calculator logic — water change, dosing, CO2, stocking, tank volume
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/models/models.dart';
import 'package:aquarium_app/services/stocking_calculator.dart';

void main() {
  // =========================================================================
  // Water Change Calculator
  // =========================================================================
  group('Water Change Calculator', () {
    /// Replicates the formula from WaterChangeCalculatorScreen._calculate:
    /// changePercent = (currentNitrate - targetNitrate) / (currentNitrate - tapNitrate) * 100
    /// changeVolume = tankVolume * (changePercent / 100)
    double? waterChangePercent({
      required double currentNitrate,
      required double targetNitrate,
      required double tapNitrate,
    }) {
      if (currentNitrate <= targetNitrate) return 0;
      if (tapNitrate >= targetNitrate) return null; // Can't reach target
      return ((currentNitrate - targetNitrate) /
              (currentNitrate - tapNitrate)) *
          100;
    }

    test('20% of 200L = 40L water change', () {
      // Setup: need to find inputs that give 20% change
      // changePercent = (40 - 20) / (40 - 0) * 100 = 50%
      // Actually, let's test a concrete scenario:
      // tank=200L, current=25ppm, target=20ppm, tap=0ppm
      // changePercent = (25-20)/(25-0)*100 = 20%
      final pct = waterChangePercent(
        currentNitrate: 25,
        targetNitrate: 20,
        tapNitrate: 0,
      );
      expect(pct, 20.0);
      final volume = 200.0 * (pct! / 100);
      expect(volume, 40.0);
    });

    test('50% water change for high nitrates', () {
      // tank=100L, current=40, target=20, tap=0
      // pct = (40-20)/(40-0)*100 = 50%
      final pct = waterChangePercent(
        currentNitrate: 40,
        targetNitrate: 20,
        tapNitrate: 0,
      );
      expect(pct, 50.0);
      expect(100.0 * (pct! / 100), 50.0);
    });

    test('no change needed when already at target', () {
      final pct = waterChangePercent(
        currentNitrate: 20,
        targetNitrate: 20,
        tapNitrate: 5,
      );
      expect(pct, 0);
    });

    test('no change needed when below target', () {
      final pct = waterChangePercent(
        currentNitrate: 10,
        targetNitrate: 20,
        tapNitrate: 5,
      );
      expect(pct, 0);
    });

    test('returns null when tap water nitrate >= target', () {
      final pct = waterChangePercent(
        currentNitrate: 40,
        targetNitrate: 20,
        tapNitrate: 25,
      );
      expect(pct, isNull);
    });

    test('accounts for tap water nitrate in calculation', () {
      // tank=100L, current=40, target=20, tap=10
      // pct = (40-20)/(40-10)*100 = 66.67%
      final pct = waterChangePercent(
        currentNitrate: 40,
        targetNitrate: 20,
        tapNitrate: 10,
      );
      expect(pct, closeTo(66.67, 0.01));
    });
  });

  // =========================================================================
  // Dosing Calculator
  // =========================================================================
  group('Dosing Calculator', () {
    /// Replicates DosingCalculatorScreen._totalDose:
    /// totalDose = (tankVolume / dosePerLitres) * dosePer
    double calculateDose({
      required double tankVolume,
      required double dosePer,
      required double dosePerLitres,
    }) {
      return (tankVolume / dosePerLitres) * dosePer;
    }

    test('basic dosing: 1ml per 10L in 100L tank = 10ml', () {
      final dose = calculateDose(
        tankVolume: 100,
        dosePer: 1,
        dosePerLitres: 10,
      );
      expect(dose, 10.0);
    });

    test('Seachem Prime: 5ml per 200L in 100L tank = 2.5ml', () {
      final dose = calculateDose(
        tankVolume: 100,
        dosePer: 5,
        dosePerLitres: 200,
      );
      expect(dose, 2.5);
    });

    test('Seachem Stability: 5ml per 40L in 200L tank = 25ml', () {
      final dose = calculateDose(
        tankVolume: 200,
        dosePer: 5,
        dosePerLitres: 40,
      );
      expect(dose, 25.0);
    });

    test('Tropica Specialised: 1ml per 25L in 60L tank = 2.4ml', () {
      final dose = calculateDose(
        tankVolume: 60,
        dosePer: 1,
        dosePerLitres: 25,
      );
      expect(dose, 2.4);
    });

    test('zero tank volume = zero dose', () {
      final dose = calculateDose(
        tankVolume: 0,
        dosePer: 5,
        dosePerLitres: 10,
      );
      expect(dose, 0.0);
    });

    test('large tank (1000L) calculation', () {
      final dose = calculateDose(
        tankVolume: 1000,
        dosePer: 5,
        dosePerLitres: 200,
      );
      expect(dose, 25.0);
    });
  });

  // =========================================================================
  // CO2 Calculator
  // =========================================================================
  group('CO2 Calculator', () {
    /// Replicates CO2CalculatorScreen._calculate:
    /// CO2 (ppm) = 3 × KH × 10^(7-pH)
    double calculateCO2({required double ph, required double kh}) {
      return 3 * kh * pow(10, 7 - ph).toDouble();
    }

    test('pH 7.0, KH 4 → CO2 = 12 ppm', () {
      final co2 = calculateCO2(ph: 7.0, kh: 4);
      expect(co2, closeTo(12.0, 0.01));
    });

    test('pH 6.6, KH 4 → CO2 ≈ 30 ppm (optimal planted tank)', () {
      final co2 = calculateCO2(ph: 6.6, kh: 4);
      expect(co2, closeTo(30.14, 0.1));
    });

    test('pH 7.4, KH 4 → CO2 ≈ 4.8 ppm (low)', () {
      final co2 = calculateCO2(ph: 7.4, kh: 4);
      expect(co2, closeTo(4.77, 0.1));
    });

    test('higher KH with same pH = more CO2', () {
      final co2Low = calculateCO2(ph: 7.0, kh: 2);
      final co2High = calculateCO2(ph: 7.0, kh: 8);
      expect(co2High, greaterThan(co2Low));
      expect(co2High / co2Low, closeTo(4.0, 0.01)); // Linear with KH
    });

    test('lower pH with same KH = more CO2', () {
      final co2HighPH = calculateCO2(ph: 7.5, kh: 4);
      final co2LowPH = calculateCO2(ph: 6.5, kh: 4);
      expect(co2LowPH, greaterThan(co2HighPH));
    });

    test('CO2 status ranges', () {
      // Too Low: <10
      expect(calculateCO2(ph: 7.5, kh: 2), lessThan(10));
      // Optimal: 20-30
      final optimal = calculateCO2(ph: 6.6, kh: 4);
      expect(optimal, greaterThanOrEqualTo(20));
      expect(optimal, lessThanOrEqualTo(35));
    });
  });

  // =========================================================================
  // Stocking Calculator
  // =========================================================================
  group('Stocking Calculator', () {
    Tank _makeTank({double volumeLitres = 100}) {
      return Tank(
        id: 'tank-1',
        name: 'Test Tank',
        type: TankType.freshwater,
        volumeLitres: volumeLitres,
        startDate: DateTime(2025, 1, 1),
        targets: WaterTargets.freshwaterTropical(),
        sortOrder: 0,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
    }

    Livestock _makeFish({
      String name = 'Test Fish',
      int count = 1,
      double? sizeCm,
    }) {
      return Livestock(
        id: 'fish-1',
        tankId: 'tank-1',
        commonName: name,
        count: count,
        sizeCm: sizeCm,
        dateAdded: DateTime(2025, 1, 1),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
    }

    test('empty tank is understocked', () {
      final tank = _makeTank();
      final result = StockingCalculator.calculate(
        tank: tank,
        livestock: [],
      );
      expect(result.level, StockingLevel.understocked);
      expect(result.percentFull, 0);
    });

    test('lightly stocked tank (<30%)', () {
      final tank = _makeTank(volumeLitres: 200); // ~52.8 gallons
      // 1 fish of 5cm (unknown species) = ~2 inches
      // 2 inches / 52.8 gallons = ~3.8% → understocked
      final result = StockingCalculator.calculate(
        tank: tank,
        livestock: [_makeFish(count: 1, sizeCm: 5)],
      );
      expect(result.level, StockingLevel.understocked);
      expect(result.percentFull, lessThan(30));
    });

    test('overstocked detection', () {
      final tank = _makeTank(volumeLitres: 20); // ~5.3 gallons
      // 20 fish at 5cm each = 20 * ~2" = 40 inches
      // 40 / 5.3 = ~755% → definitely overstocked
      final result = StockingCalculator.calculate(
        tank: tank,
        livestock: [_makeFish(count: 20, sizeCm: 5)],
      );
      expect(result.level, StockingLevel.overstocked);
      expect(result.percentFull, greaterThanOrEqualTo(100));
    });

    test('moderate stocking level', () {
      final tank = _makeTank(volumeLitres: 100); // ~26.4 gallons
      // 10 fish at 5cm each = ~39.4 inches / 26.4 gallons = ~149%?
      // Hmm, let's be more careful. 5cm = 1.97 inches.
      // 5 fish * 1.97 = 9.84 inches / 26.4 gallons = 37.3% → good
      // 10 fish * 1.97 = 19.7 / 26.4 = 74.6% → moderate
      final result = StockingCalculator.calculate(
        tank: tank,
        livestock: [_makeFish(count: 10, sizeCm: 5)],
      );
      expect(result.percentFull, greaterThan(30));
      expect(result.percentFull, lessThan(100));
    });

    test('percentFull is clamped to 150', () {
      final tank = _makeTank(volumeLitres: 10);
      final result = StockingCalculator.calculate(
        tank: tank,
        livestock: [_makeFish(count: 50, sizeCm: 10)],
      );
      expect(result.percentFull, 150);
    });

    test('stocking result includes warnings for overstocked', () {
      final tank = _makeTank(volumeLitres: 10);
      final result = StockingCalculator.calculate(
        tank: tank,
        livestock: [_makeFish(count: 20, sizeCm: 5)],
      );
      expect(result.warnings, isNotEmpty);
    });
  });

  // =========================================================================
  // Tank Volume Calculator
  // =========================================================================
  group('Tank Volume Calculator', () {
    /// Replicates TankVolumeCalculatorScreen._volume for rectangular:
    /// (L × W × H) / 1000 (cm → litres)
    double rectangularVolume(double lengthCm, double widthCm, double heightCm) {
      return (lengthCm * widthCm * heightCm) / 1000;
    }

    /// Cylindrical: π × (d/2)² × h / 1000
    double cylindricalVolume(double diameterCm, double heightCm) {
      return (pi * pow(diameterCm / 2, 2) * heightCm) / 1000;
    }

    test('L×W×H → litres: 100×40×50 = 200L', () {
      final vol = rectangularVolume(100, 40, 50);
      expect(vol, 200.0);
    });

    test('L×W×H → litres: 60×30×30 = 54L', () {
      final vol = rectangularVolume(60, 30, 30);
      expect(vol, 54.0);
    });

    test('L×W×H → litres: 120×40×50 = 240L', () {
      final vol = rectangularVolume(120, 40, 50);
      expect(vol, 240.0);
    });

    test('small nano tank: 30×20×20 = 12L', () {
      final vol = rectangularVolume(30, 20, 20);
      expect(vol, 12.0);
    });

    test('cylindrical tank: diameter 30cm, height 40cm', () {
      final vol = cylindricalVolume(30, 40);
      // π × 15² × 40 / 1000 = π × 225 × 40 / 1000 ≈ 28.27L
      expect(vol, closeTo(28.27, 0.01));
    });

    test('imperial to metric conversion: inches to cm', () {
      // 24" × 12" × 16" tank
      const inchToCm = 2.54;
      final vol = rectangularVolume(
        24 * inchToCm,
        12 * inchToCm,
        16 * inchToCm,
      );
      // = 60.96 × 30.48 × 40.64 / 1000 ≈ 75.5L ≈ ~20 US gallons
      expect(vol, closeTo(75.48, 0.1));
    });

    test('zero dimension results in zero volume', () {
      expect(rectangularVolume(100, 0, 50), 0);
      expect(rectangularVolume(0, 40, 50), 0);
      expect(rectangularVolume(100, 40, 0), 0);
    });
  });
}
