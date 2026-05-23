// Widget tests for ChartsScreen.
//
// Run: flutter test test/widget_tests/charts_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/charts_screen.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/models/models.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _fakeTankId = 'tank-charts-001';

Widget _wrap({
  String initialParam = 'nitrate',
  List<LogEntry> logs = const [],
  WaterTargets targets = const WaterTargets(),
}) {
  final memStorage = InMemoryStorageService();

  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(memStorage),
      allLogsProvider.overrideWith((ref, tankId) async => logs),
      tankProvider.overrideWith(
        (ref, tankId) async => Tank(
          id: tankId,
          name: 'Charts Tank',
          type: TankType.freshwater,
          volumeLitres: 100,
          startDate: DateTime(2024),
          targets: targets,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      ),
    ],
    child: MaterialApp(
      home: ChartsScreen(tankId: _fakeTankId, initialParam: initialParam),
    ),
  );
}

LogEntry _waterTestLog(WaterTestResults results) {
  return LogEntry(
    id: 'log-1',
    tankId: _fakeTankId,
    type: LogType.waterTest,
    timestamp: DateTime(2026, 5, 1),
    waterTest: results,
    createdAt: DateTime(2026, 5, 1),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ChartsScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ChartsScreen), findsOneWidget);
    });

    testWidgets('shows Water Charts app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Water Charts'), findsOneWidget);
    });

    testWidgets('shows empty state when no logs', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      // EmptyState shows this when no water tests exist
      expect(find.text('Log Your First Water Test'), findsOneWidget);
    });

    testWidgets('has export CSV button in app bar', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('high ammonia alert avoids raw warning emoji text', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(logs: [_waterTestLog(WaterTestResults(ammonia: 1.0))]),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Parameter Alerts'), findsOneWidget);
      expect(find.text('High ammonia (1.0ppm)'), findsOneWidget);
      expect(find.textContaining('⚠️ High ammonia'), findsNothing);
    });

    testWidgets('all-clear alert uses iconography instead of raw check text', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(logs: [_waterTestLog(WaterTestResults(ammonia: 0.0))]),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(find.text('All parameters within safe ranges'), findsOneWidget);
      expect(
        find.textContaining('All parameters within safe ranges ✓'),
        findsNothing,
      );
    });
  });
}
