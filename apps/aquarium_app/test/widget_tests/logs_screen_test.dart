// Widget tests for LogsScreen.
//
// Run: flutter test test/widget_tests/logs_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/logs_screen.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/models/models.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _fakeTankId = 'tank-logs-001';

Widget _wrap({List<LogEntry>? logs}) {
  final memStorage = InMemoryStorageService();
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(memStorage),
      allLogsProvider.overrideWith((ref, tankId) async => logs ?? []),
      tankProvider.overrideWith(
        (ref, tankId) async => Tank(
          id: tankId,
          name: 'Test Tank',
          type: TankType.freshwater,
          volumeLitres: 100,
          startDate: DateTime(2024),
          targets: const WaterTargets(),
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      ),
    ],
    child: MaterialApp(
      home: LogsScreen(tankId: _fakeTankId),
    ),
  );
}

LogEntry _activityEntry() => LogEntry(
  id: 'log-activity-001',
  tankId: _fakeTankId,
  type: LogType.observation,
  timestamp: DateTime(2024, 7, 3, 18),
  title: 'Filter floss changed',
  notes: 'Replaced old floss after maintenance.',
  createdAt: DateTime(2024, 7, 3, 18),
);

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

  group('LogsScreen — empty state', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(LogsScreen), findsOneWidget);
    });

    testWidgets('shows app bar title Activity Log', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Activity Log'), findsOneWidget);
    });

    testWidgets('shows filter icon button in app bar', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('shows empty state message when no logs', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Add Log Entry'), findsOneWidget);
    });

    testWidgets(
      'empty state title uses iconography instead of raw emoji text',
      (
        tester,
      ) async {
        await tester.pumpWidget(_wrap());
        await _advance(tester);

        expect(find.byIcon(Icons.list_alt), findsWidgets);
        expect(find.text('Start your tank\'s story!'), findsOneWidget);
        expect(
          find.textContaining('Start your tank\'s story! 📖'),
          findsNothing,
        );
      },
    );

    testWidgets('shows scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('tablet keeps activity log cards readable', (tester) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap(logs: [_activityEntry()]));
      await _advance(tester);

      final logCard = find
          .ancestor(
            of: find.text('Filter floss changed'),
            matching: find.byType(Card),
          )
          .first;
      expect(tester.getSize(logCard).width, lessThanOrEqualTo(720));
    });
  });
}
