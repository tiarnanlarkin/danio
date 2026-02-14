import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/models/models.dart';

/// Pump widget with ProviderScope and MaterialApp wrapper
Future<void> pumpWithProviders(
  WidgetTester tester,
  Widget widget, {
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: widget,
      ),
    ),
  );
}

/// Mock data factories for testing
class MockData {
  /// Create a mock tank with customizable properties
  static Tank mockTank({
    String? id,
    String? name,
    TankType? type,
    double? volumeLitres,
    DateTime? startDate,
    WaterTargets? targets,
  }) {
    return Tank(
      id: id ?? 'test-tank-1',
      name: name ?? 'Test Tank',
      type: type ?? TankType.freshwater,
      volumeLitres: volumeLitres ?? 100.0,
      startDate: startDate ?? DateTime(2024, 1, 1),
      targets: targets ?? WaterTargets.freshwaterTropical(),
      sortOrder: 0,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );
  }

  /// Create a mock log entry with customizable properties
  static LogEntry mockLog({
    String? id,
    String? tankId,
    LogType? type,
    DateTime? timestamp,
    WaterTestResults? waterTest,
  }) {
    return LogEntry(
      id: id ?? 'test-log-1',
      tankId: tankId ?? 'test-tank-1',
      type: type ?? LogType.waterTest,
      timestamp: timestamp ?? DateTime.now(),
      waterTest: waterTest ??
          const WaterTestResults(
            ph: 7.0,
            ammonia: 0.0,
            nitrite: 0.0,
            nitrate: 10.0,
          ),
      createdAt: DateTime.now(),
    );
  }

  /// Create a list of mock tanks
  static List<Tank> mockTankList(int count) {
    return List.generate(
      count,
      (index) => mockTank(
        id: 'test-tank-$index',
        name: 'Tank ${index + 1}',
        volumeLitres: 50.0 + (index * 25),
      ),
    );
  }

  /// Create a mock water test result
  static WaterTestResults mockWaterTest({
    double? ph,
    double? ammonia,
    double? nitrite,
    double? nitrate,
    double? temperature,
  }) {
    return WaterTestResults(
      ph: ph ?? 7.0,
      ammonia: ammonia ?? 0.0,
      nitrite: nitrite ?? 0.0,
      nitrate: nitrate ?? 10.0,
      temperature: temperature ?? 25.0,
    );
  }
}
