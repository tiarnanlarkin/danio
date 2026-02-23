/// Tests for AnomalyDetectorService — rules-based anomaly detection
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/features/smart/anomaly_detector/anomaly_detector_service.dart';
import 'package:aquarium_app/features/smart/models/smart_models.dart';
import 'package:aquarium_app/models/models.dart';
import 'package:aquarium_app/services/openai_service.dart';

void main() {
  late AnomalyDetectorService detector;

  setUp(() {
    // OpenAI not configured in tests — rules-based detection only
    detector = AnomalyDetectorService(OpenAIService());
  });

  /// Helper to create a water test log entry
  LogEntry _waterTestLog({
    required DateTime timestamp,
    double? ph,
    double? temperature,
    double? ammonia,
    double? nitrite,
    double? nitrate,
  }) {
    return LogEntry(
      id: 'log-${timestamp.millisecondsSinceEpoch}',
      tankId: 'tank-1',
      type: LogType.waterTest,
      timestamp: timestamp,
      waterTest: WaterTestResults(
        ph: ph,
        temperature: temperature,
        ammonia: ammonia,
        nitrite: nitrite,
        nitrate: nitrate,
      ),
      createdAt: timestamp,
    );
  }

  group('pH drift detection', () {
    test('pH drift >0.5 in 24h triggers warning', () async {
      final now = DateTime.now();
      final logs = [
        _waterTestLog(timestamp: now, ph: 7.8),
        _waterTestLog(
          timestamp: now.subtract(const Duration(hours: 12)),
          ph: 7.0,
        ),
      ];

      final anomalies = await detector.analyse(tankId: 'tank-1', logs: logs);

      expect(anomalies.any((a) => a.parameter == 'pH'), true);
      final phAnomaly = anomalies.firstWhere((a) => a.parameter == 'pH');
      expect(phAnomaly.severity, AnomalySeverity.warning);
      expect(phAnomaly.description, contains('0.8'));
    });

    test('pH drift exactly 0.5 does NOT trigger warning', () async {
      final now = DateTime.now();
      final logs = [
        _waterTestLog(timestamp: now, ph: 7.5),
        _waterTestLog(
          timestamp: now.subtract(const Duration(hours: 12)),
          ph: 7.0,
        ),
      ];

      final anomalies = await detector.analyse(tankId: 'tank-1', logs: logs);
      expect(anomalies.any((a) => a.parameter == 'pH'), false);
    });

    test('pH drift <0.5 does NOT trigger warning', () async {
      final now = DateTime.now();
      final logs = [
        _waterTestLog(timestamp: now, ph: 7.3),
        _waterTestLog(
          timestamp: now.subtract(const Duration(hours: 12)),
          ph: 7.0,
        ),
      ];

      final anomalies = await detector.analyse(tankId: 'tank-1', logs: logs);
      expect(anomalies.any((a) => a.parameter == 'pH'), false);
    });

    test('pH drop (decrease) >0.5 also triggers warning', () async {
      final now = DateTime.now();
      final logs = [
        _waterTestLog(timestamp: now, ph: 6.2),
        _waterTestLog(
          timestamp: now.subtract(const Duration(hours: 10)),
          ph: 7.0,
        ),
      ];

      final anomalies = await detector.analyse(tankId: 'tank-1', logs: logs);
      expect(anomalies.any((a) => a.parameter == 'pH'), true);
    });
  });

  group('Temperature spike detection', () {
    test('temp spike >3°C in 24h triggers alert', () async {
      final now = DateTime.now();
      final logs = [
        _waterTestLog(timestamp: now, temperature: 29.0),
        _waterTestLog(
          timestamp: now.subtract(const Duration(hours: 8)),
          temperature: 25.0,
        ),
      ];

      final anomalies = await detector.analyse(tankId: 'tank-1', logs: logs);
      final tempAnomaly =
          anomalies.where((a) => a.parameter == 'Temperature').toList();

      expect(tempAnomaly.length, 1);
      expect(tempAnomaly.first.severity, AnomalySeverity.alert);
      expect(tempAnomaly.first.description, contains('4.0'));
    });

    test('temp change exactly 3.0°C does NOT trigger alert', () async {
      final now = DateTime.now();
      final logs = [
        _waterTestLog(timestamp: now, temperature: 28.0),
        _waterTestLog(
          timestamp: now.subtract(const Duration(hours: 8)),
          temperature: 25.0,
        ),
      ];

      final anomalies = await detector.analyse(tankId: 'tank-1', logs: logs);
      expect(anomalies.any((a) => a.parameter == 'Temperature'), false);
    });

    test('temp drop >3°C also triggers alert', () async {
      final now = DateTime.now();
      final logs = [
        _waterTestLog(timestamp: now, temperature: 21.0),
        _waterTestLog(
          timestamp: now.subtract(const Duration(hours: 6)),
          temperature: 25.0,
        ),
      ];

      final anomalies = await detector.analyse(tankId: 'tank-1', logs: logs);
      expect(anomalies.any((a) => a.parameter == 'Temperature'), true);
    });
  });

  group('Ammonia detection', () {
    test('any non-zero ammonia triggers critical', () async {
      final now = DateTime.now();
      final logs = [
        _waterTestLog(timestamp: now, ammonia: 0.25),
      ];

      final anomalies = await detector.analyse(tankId: 'tank-1', logs: logs);
      final ammoniaAnomaly =
          anomalies.where((a) => a.parameter == 'Ammonia').toList();

      expect(ammoniaAnomaly.length, 1);
      expect(ammoniaAnomaly.first.severity, AnomalySeverity.critical);
      expect(ammoniaAnomaly.first.description, contains('0.25'));
    });

    test('zero ammonia does NOT trigger anomaly', () async {
      final now = DateTime.now();
      final logs = [
        _waterTestLog(timestamp: now, ammonia: 0.0),
      ];

      final anomalies = await detector.analyse(tankId: 'tank-1', logs: logs);
      expect(anomalies.any((a) => a.parameter == 'Ammonia'), false);
    });

    test('null ammonia does NOT trigger anomaly', () async {
      final now = DateTime.now();
      final logs = [
        _waterTestLog(timestamp: now, ammonia: null),
      ];

      final anomalies = await detector.analyse(tankId: 'tank-1', logs: logs);
      expect(anomalies.any((a) => a.parameter == 'Ammonia'), false);
    });
  });

  group('Nitrite detection', () {
    test('any non-zero nitrite triggers critical', () async {
      final now = DateTime.now();
      final logs = [
        _waterTestLog(timestamp: now, nitrite: 0.5),
      ];

      final anomalies = await detector.analyse(tankId: 'tank-1', logs: logs);
      final nitriteAnomaly =
          anomalies.where((a) => a.parameter == 'Nitrite').toList();

      expect(nitriteAnomaly.length, 1);
      expect(nitriteAnomaly.first.severity, AnomalySeverity.critical);
    });

    test('zero nitrite does NOT trigger anomaly', () async {
      final now = DateTime.now();
      final logs = [
        _waterTestLog(timestamp: now, nitrite: 0.0),
      ];

      final anomalies = await detector.analyse(tankId: 'tank-1', logs: logs);
      expect(anomalies.any((a) => a.parameter == 'Nitrite'), false);
    });
  });

  group('Nitrate detection', () {
    test('nitrate >40ppm triggers warning', () async {
      final now = DateTime.now();
      final logs = [
        _waterTestLog(timestamp: now, nitrate: 60.0),
      ];

      final anomalies = await detector.analyse(tankId: 'tank-1', logs: logs);
      final nitrateAnomaly =
          anomalies.where((a) => a.parameter == 'Nitrate').toList();

      expect(nitrateAnomaly.length, 1);
      expect(nitrateAnomaly.first.severity, AnomalySeverity.warning);
      expect(nitrateAnomaly.first.description, contains('60'));
    });

    test('nitrate exactly 40ppm does NOT trigger warning', () async {
      final now = DateTime.now();
      final logs = [
        _waterTestLog(timestamp: now, nitrate: 40.0),
      ];

      final anomalies = await detector.analyse(tankId: 'tank-1', logs: logs);
      expect(anomalies.any((a) => a.parameter == 'Nitrate'), false);
    });

    test('nitrate <40ppm does NOT trigger warning', () async {
      final now = DateTime.now();
      final logs = [
        _waterTestLog(timestamp: now, nitrate: 20.0),
      ];

      final anomalies = await detector.analyse(tankId: 'tank-1', logs: logs);
      expect(anomalies.any((a) => a.parameter == 'Nitrate'), false);
    });
  });

  group('Normal readings — no anomalies', () {
    test('all normal parameters produce zero anomalies', () async {
      final now = DateTime.now();
      final logs = [
        _waterTestLog(
          timestamp: now,
          ph: 7.0,
          temperature: 25.0,
          ammonia: 0.0,
          nitrite: 0.0,
          nitrate: 20.0,
        ),
        _waterTestLog(
          timestamp: now.subtract(const Duration(hours: 12)),
          ph: 7.1,
          temperature: 25.5,
          ammonia: 0.0,
          nitrite: 0.0,
          nitrate: 18.0,
        ),
      ];

      final anomalies = await detector.analyse(tankId: 'tank-1', logs: logs);
      expect(anomalies, isEmpty);
    });

    test('empty log list returns no anomalies', () async {
      final anomalies =
          await detector.analyse(tankId: 'tank-1', logs: <LogEntry>[]);
      expect(anomalies, isEmpty);
    });

    test('non-water-test logs are ignored', () async {
      final now = DateTime.now();
      final logs = [
        LogEntry(
          id: 'log-feeding',
          tankId: 'tank-1',
          type: LogType.feeding,
          timestamp: now,
          createdAt: now,
        ),
        LogEntry(
          id: 'log-observation',
          tankId: 'tank-1',
          type: LogType.observation,
          timestamp: now,
          notes: 'Fish look happy',
          createdAt: now,
        ),
      ];

      final anomalies = await detector.analyse(tankId: 'tank-1', logs: logs);
      expect(anomalies, isEmpty);
    });
  });

  group('Multiple anomalies', () {
    test('multiple issues in one reading produce multiple anomalies', () async {
      final now = DateTime.now();
      final logs = [
        _waterTestLog(
          timestamp: now,
          ph: 8.0,
          temperature: 30.0,
          ammonia: 1.0,
          nitrite: 0.5,
          nitrate: 80.0,
        ),
        _waterTestLog(
          timestamp: now.subtract(const Duration(hours: 6)),
          ph: 7.0,
          temperature: 25.0,
          ammonia: 0.0,
          nitrite: 0.0,
          nitrate: 20.0,
        ),
      ];

      final anomalies = await detector.analyse(tankId: 'tank-1', logs: logs);

      // Should detect: pH drift, temp spike, ammonia, nitrite, nitrate
      expect(anomalies.length, greaterThanOrEqualTo(4));

      final parameters = anomalies.map((a) => a.parameter).toSet();
      expect(parameters, contains('pH'));
      expect(parameters, contains('Temperature'));
      expect(parameters, contains('Ammonia'));
      expect(parameters, contains('Nitrite'));
      expect(parameters, contains('Nitrate'));
    });
  });

  group('Edge cases', () {
    test('readings >24h apart are skipped for drift detection', () async {
      final now = DateTime.now();
      final logs = [
        _waterTestLog(timestamp: now, ph: 8.5),
        _waterTestLog(
          timestamp: now.subtract(const Duration(hours: 48)),
          ph: 6.0,
        ),
      ];

      final anomalies = await detector.analyse(tankId: 'tank-1', logs: logs);
      // pH drift check should be skipped because readings are >24h apart
      expect(anomalies.any((a) => a.parameter == 'pH'), false);
    });

    test('single reading checks absolute thresholds only', () async {
      final now = DateTime.now();
      final logs = [
        _waterTestLog(
          timestamp: now,
          ammonia: 2.0,
          nitrate: 50.0,
        ),
      ];

      final anomalies = await detector.analyse(tankId: 'tank-1', logs: logs);
      expect(anomalies.any((a) => a.parameter == 'Ammonia'), true);
      expect(anomalies.any((a) => a.parameter == 'Nitrate'), true);
    });

    test('anomaly has correct tankId', () async {
      final now = DateTime.now();
      final logs = [
        _waterTestLog(timestamp: now, ammonia: 1.0),
      ];

      final anomalies =
          await detector.analyse(tankId: 'my-special-tank', logs: logs);
      expect(anomalies.first.tankId, 'my-special-tank');
    });
  });
}
