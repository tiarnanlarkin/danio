// Widget tests for AddLogScreen.
//
// Run: flutter test test/widget_tests/add_log_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/add_log_screen.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/models/models.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _now = DateTime.now();

Tank _makeTank({String id = 'tank-1'}) => Tank(
  id: id,
  name: 'Test Tank',
  type: TankType.freshwater,
  volumeLitres: 100,
  startDate: _now,
  targets: WaterTargets.freshwaterTropical(),
  createdAt: _now,
  updatedAt: _now,
);

Widget _wrap({
  InMemoryStorageService? storage,
  LogType type = LogType.waterTest,
  String tankId = 'tank-1',
}) {
  final svc = storage ?? InMemoryStorageService();
  return ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(svc)],
    child: MaterialApp(
      home: AddLogScreen(tankId: tankId, initialType: type),
    ),
  );
}

Widget _wrapWithLauncher({
  required InMemoryStorageService storage,
  LogType type = LogType.waterTest,
  String tankId = 'tank-1',
}) {
  return ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        AddLogScreen(tankId: tankId, initialType: type),
                  ),
                );
              },
              child: const Text('Open log form'),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _wrapWithLatestTemperatureHarness({
  required InMemoryStorageService storage,
  String tankId = 'tank-1',
}) {
  return ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
    child: MaterialApp(
      home: Consumer(
        builder: (context, ref, _) {
          final latest = ref.watch(latestWaterTestProvider(tankId));
          final label = latest.when(
            data: (test) =>
                'Latest temp: ${test?.temperature?.toStringAsFixed(1) ?? '--'}',
            loading: () => 'Latest temp: loading',
            error: (_, __) => 'Latest temp: error',
          );

          return Scaffold(
            body: Column(
              children: [
                Text(label),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddLogScreen(
                          tankId: tankId,
                          initialType: LogType.waterTest,
                        ),
                      ),
                    );
                  },
                  child: const Text('Open log form'),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(seconds: 1));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AddLogScreen — renders', () {
    testWidgets('renders without throwing', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrap(storage: svc));
      await _advance(tester);
      expect(find.byType(AddLogScreen), findsOneWidget);
    });

    testWidgets('shows scaffold with app bar', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrap(storage: svc));
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows log type selector chips', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrap(storage: svc));
      await _advance(tester);
      // Type selector has Water Test, Water Change, Observation, Medication
      expect(find.text('Water Test'), findsOneWidget);
      expect(find.text('Water Change'), findsOneWidget);
    });

    testWidgets('shows save/submit button', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrap(storage: svc));
      await _advance(tester);
      // The save button should be somewhere in the widget tree
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              (w.data == 'Save Log' ||
                  w.data == 'Save' ||
                  w.data == 'Log Entry' ||
                  w.data == 'Submit'),
        ),
        findsWidgets,
      );
    });

    testWidgets('tapping Water Change chip changes selection', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrap(storage: svc));
      await _advance(tester);
      await tester.tap(find.text('Water Change'));
      await tester.pump(const Duration(milliseconds: 300));
      // No crash — chip tapped successfully
      expect(find.text('Water Change'), findsWidgets);
    });

    testWidgets('feeding entry opens with Feeding selected', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());

      await tester.pumpWidget(_wrap(storage: svc, type: LogType.feeding));
      await _advance(tester);

      expect(find.text('Log Feeding'), findsOneWidget);
      expect(find.text('Feeding'), findsOneWidget);
    });
  });

  group('AddLogScreen validation', () {
    testWidgets('blocks blank water tests before saving', (tester) async {
      final svc = InMemoryStorageService();
      const tankId = 'blank-water-test-tank';
      await svc.saveTank(_makeTank(id: tankId));

      await tester.pumpWidget(_wrap(storage: svc, tankId: tankId));
      await _advance(tester);

      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('Add at least one tested water value before saving.'),
        findsOneWidget,
      );
      expect(await svc.getLogsForTank(tankId), isEmpty);
      expect(find.byType(AddLogScreen), findsOneWidget);
    });

    testWidgets('saves a water test once a parameter is entered', (
      tester,
    ) async {
      final svc = InMemoryStorageService();
      const tankId = 'valid-water-test-tank';
      await svc.saveTank(_makeTank(id: tankId));

      await tester.pumpWidget(_wrap(storage: svc, tankId: tankId));
      await _advance(tester);

      await tester.enterText(find.widgetWithText(TextFormField, 'pH'), '7.2');
      await tester.tap(find.text('Save'));
      await _advance(tester);

      final logs = await svc.getLogsForTank(tankId);
      expect(logs, hasLength(1));
      expect(logs.single.waterTest?.ph, 7.2);
    });

    testWidgets('saving a water test refreshes latest water test readers', (
      tester,
    ) async {
      final svc = InMemoryStorageService();
      const tankId = 'latest-temp-refresh-tank';
      await svc.saveTank(_makeTank(id: tankId));

      await tester.pumpWidget(
        _wrapWithLatestTemperatureHarness(storage: svc, tankId: tankId),
      );
      await _advance(tester);

      expect(find.text('Latest temp: --'), findsOneWidget);

      await tester.tap(find.text('Open log form'));
      await tester.pumpAndSettle();
      await _advance(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Temperature'),
        '25.5',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      await _advance(tester);

      expect(find.text('Latest temp: 25.5'), findsOneWidget);
    });
  });

  group('AddLogScreen dirty close behavior', () {
    testWidgets('cancel keeps a dirty log form open', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrapWithLauncher(storage: svc));

      await tester.tap(find.text('Open log form'));
      await tester.pumpAndSettle();
      await _advance(tester);

      await tester.enterText(find.byType(TextFormField).last, 'Some notes');
      await tester.pump();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AddLogScreen), findsOneWidget);
      expect(find.text('Some notes'), findsOneWidget);
    });

    testWidgets('discard closes a dirty log form without looping', (
      tester,
    ) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrapWithLauncher(storage: svc));

      await tester.tap(find.text('Open log form'));
      await tester.pumpAndSettle();
      await _advance(tester);

      await tester.enterText(find.byType(TextFormField).last, 'Some notes');
      await tester.pump();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsOneWidget);

      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(find.byType(AddLogScreen), findsNothing);
      expect(find.text('Open log form'), findsOneWidget);
      expect(find.text('Discard changes?'), findsNothing);
    });
  });
}
