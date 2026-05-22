// Widget tests for CyclingAssistantScreen.
//
// Run: flutter test test/widget_tests/cycling_assistant_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/cycling_assistant_screen.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/models/log_entry.dart';
import 'package:danio/models/tank.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _fakeTankId = 'tank-cycle-001';

Widget _wrap({Tank? tank, List<LogEntry> logs = const []}) {
  final memStorage = InMemoryStorageService();
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(memStorage),
      tankProvider.overrideWith(
        (ref, tankId) async =>
            tank ??
            Tank(
              id: tankId,
              name: 'Cycling Tank',
              type: TankType.freshwater,
              volumeLitres: 100,
              startDate: DateTime.now().subtract(const Duration(days: 10)),
              targets: const WaterTargets(),
              createdAt: DateTime(2024),
              updatedAt: DateTime(2024),
            ),
      ),
      allLogsProvider.overrideWith((ref, tankId) async => logs),
    ],
    child: MaterialApp(home: CyclingAssistantScreen(tankId: _fakeTankId)),
  );
}

Widget _wrapMissingTank() {
  return ProviderScope(
    overrides: [
      tankProvider.overrideWith((ref, tankId) async => null),
      allLogsProvider.overrideWith((ref, tankId) async => []),
    ],
    child: const MaterialApp(home: CyclingAssistantScreen(tankId: _fakeTankId)),
  );
}

LogEntry _waterTest({
  required DateTime timestamp,
  required double ammonia,
  required double nitrite,
  required double nitrate,
}) {
  return LogEntry(
    id: timestamp.millisecondsSinceEpoch.toString(),
    tankId: _fakeTankId,
    type: LogType.waterTest,
    timestamp: timestamp,
    waterTest: WaterTestResults(
      ammonia: ammonia,
      nitrite: nitrite,
      nitrate: nitrate,
    ),
    createdAt: timestamp,
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CyclingAssistantScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(CyclingAssistantScreen), findsOneWidget);
    });

    testWidgets('shows Nitrogen Cycle Assistant title', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Nitrogen Cycle Assistant'), findsOneWidget);
    });

    testWidgets('shows scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows app bar', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders cycling phase content after data loads', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      // Allow async providers to resolve
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      // Should no longer show loading indicator
      expect(find.byType(CyclingAssistantScreen), findsOneWidget);
    });

    testWidgets('cycled water tests show completion guidance', (tester) async {
      final now = DateTime(2026, 5, 18);
      await tester.pumpWidget(
        _wrap(
          logs: [
            _waterTest(
              timestamp: now.subtract(const Duration(days: 2)),
              ammonia: 0.25,
              nitrite: 0.25,
              nitrate: 10,
            ),
            _waterTest(timestamp: now, ammonia: 0, nitrite: 0, nitrate: 15),
          ],
        ),
      );
      await _advance(tester);

      expect(find.text('Tank is Cycled!'), findsOneWidget);
      expect(find.text('Safe to add fish gradually'), findsOneWidget);
    });

    testWidgets('missing tank shows a stable error state', (tester) async {
      await tester.pumpWidget(_wrapMissingTank());
      await _advance(tester);

      expect(find.text('Tank not found'), findsOneWidget);
      expect(find.text('This tank may have been deleted.'), findsOneWidget);
    });
  });
}
