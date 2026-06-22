// Widget tests for TankComparisonScreen.
//
// Run: flutter test test/widget_tests/tank_comparison_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/tank_comparison_screen.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/models/models.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Tank _tank(String id, String name) => Tank(
  id: id,
  name: name,
  type: TankType.freshwater,
  volumeLitres: 100,
  startDate: DateTime.now().subtract(const Duration(days: 120)),
  targets: const WaterTargets(),
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

LogEntry _waterTest(String id, String tankId, {double nitrate = 10}) {
  final now = DateTime.now();
  return LogEntry(
    id: id,
    tankId: tankId,
    type: LogType.waterTest,
    timestamp: now.subtract(const Duration(days: 1)),
    waterTest: WaterTestResults(
      ammonia: 0,
      nitrite: 0,
      nitrate: nitrate,
      ph: 7,
    ),
    createdAt: now.subtract(const Duration(days: 1)),
  );
}

LogEntry _waterChange(String id, String tankId, {int daysAgo = 3}) {
  final timestamp = DateTime.now().subtract(Duration(days: daysAgo));
  return LogEntry(
    id: id,
    tankId: tankId,
    type: LogType.waterChange,
    timestamp: timestamp,
    waterChangePercent: 30,
    createdAt: timestamp,
  );
}

LogEntry _observation(
  String id,
  String tankId,
  String note, {
  int daysAgo = 0,
}) {
  final timestamp = DateTime.now().subtract(Duration(days: daysAgo));
  return LogEntry(
    id: id,
    tankId: tankId,
    type: LogType.observation,
    timestamp: timestamp,
    notes: note,
    createdAt: timestamp,
  );
}

Task _task(String id, String tankId, String title, DateTime dueDate) => Task(
  id: id,
  tankId: tankId,
  title: title,
  recurrence: RecurrenceType.weekly,
  dueDate: dueDate,
  createdAt: dueDate.subtract(const Duration(days: 7)),
  updatedAt: dueDate.subtract(const Duration(days: 7)),
);

Livestock _livestock(String id, String tankId, int count) => Livestock(
  id: id,
  tankId: tankId,
  commonName: 'Neon Tetra',
  count: count,
  dateAdded: DateTime(2024),
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

Equipment _equipment(String id, String tankId) => Equipment(
  id: id,
  tankId: tankId,
  type: EquipmentType.filter,
  name: 'Filter',
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

Widget _wrap({
  List<Tank>? tanks,
  Map<String, List<LogEntry>> logs = const {},
  Map<String, List<Task>> tasks = const {},
  Map<String, List<Livestock>> livestock = const {},
  Map<String, List<Equipment>> equipment = const {},
}) {
  final memStorage = InMemoryStorageService();
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(memStorage),
      tanksProvider.overrideWith((ref) async => tanks ?? []),
      allLogsProvider.overrideWith(
        (ref, tankId) async => logs[tankId] ?? const [],
      ),
      tasksProvider.overrideWith(
        (ref, tankId) async => tasks[tankId] ?? const [],
      ),
      livestockProvider.overrideWith(
        (ref, tankId) async => livestock[tankId] ?? const [],
      ),
      equipmentProvider.overrideWith(
        (ref, tankId) async => equipment[tankId] ?? const [],
      ),
    ],
    child: const MaterialApp(home: TankComparisonScreen()),
  );
}

void suppressErrors() {
  final original = FlutterError.onError!;
  FlutterError.onError = (FlutterErrorDetails details) {
    final msg = details.exceptionAsString();
    if (msg.contains('overflowed') || msg.contains('backgroundImage != null')) {
      return;
    }
    original(details);
  };
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TankComparisonScreen', () {
    testWidgets('renders without throwing', (tester) async {
      suppressErrors();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(TankComparisonScreen), findsOneWidget);
    });

    testWidgets('shows Compare Tanks title in AppBar', (tester) async {
      suppressErrors();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Compare Tanks'), findsOneWidget);
    });

    testWidgets('shows "Need at Least 2 Tanks" when fewer than 2 tanks exist', (
      tester,
    ) async {
      suppressErrors();
      await tester.pumpWidget(_wrap(tanks: [_tank('t1', 'Tank A')]));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Need at Least 2 Tanks'), findsOneWidget);
    });

    testWidgets('shows insight-led comparison layout with 2+ tanks', (
      tester,
    ) async {
      suppressErrors();
      final tankA = _tank('t1', 'Tank A');
      final tankB = _tank('t2', 'Tank B');
      final now = DateTime.now();
      await tester.pumpWidget(
        _wrap(
          tanks: [tankA, tankB],
          logs: {
            tankA.id: [
              _waterChange('wc-a', tankA.id),
              _waterTest('wt-a', tankA.id, nitrate: 10),
            ],
            tankB.id: [
              _waterChange('wc-b', tankB.id, daysAgo: 18),
              _waterTest('wt-b', tankB.id, nitrate: 80),
            ],
          },
          tasks: {
            tankB.id: [
              _task(
                'task-b',
                tankB.id,
                'Water change',
                now.subtract(const Duration(days: 2)),
              ),
            ],
          },
          livestock: {
            tankA.id: [_livestock('fish-a', tankA.id, 6)],
            tankB.id: [_livestock('fish-b', tankB.id, 1)],
          },
          equipment: {
            tankA.id: [_equipment('filter-a', tankA.id)],
            tankB.id: [_equipment('filter-b', tankB.id)],
          },
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Needs attention first'), findsOneWidget);
      expect(find.text('Tank B'), findsWidgets);
      expect(find.byType(DropdownButtonFormField<String>), findsWidgets);
      await tester.scrollUntilVisible(
        find.text('Water'),
        250,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Water'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Care rhythm'),
        250,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Care rhythm'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Livestock & stocking'),
        250,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Livestock & stocking'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Equipment'),
        250,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Equipment'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Activity'),
        250,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Activity'), findsOneWidget);
    });

    testWidgets('swaps compared tanks with one accessible action', (
      tester,
    ) async {
      suppressErrors();
      final tankA = _tank('t1', 'Tank A');
      final tankB = _tank('t2', 'Tank B');

      await tester.pumpWidget(_wrap(tanks: [tankA, tankB]));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      List<DropdownButtonFormField<String>> selectors() => tester
          .widgetList<DropdownButtonFormField<String>>(
            find.byType(DropdownButtonFormField<String>),
          )
          .toList();

      expect(selectors()[0].initialValue, tankA.id);
      expect(selectors()[1].initialValue, tankB.id);

      await tester.tap(find.byTooltip('Swap compared tanks'));
      await tester.pumpAndSettle();

      expect(selectors()[0].initialValue, tankB.id);
      expect(selectors()[1].initialValue, tankA.id);
    });

    testWidgets('surfaces urgent unselected tanks in all-tanks overview', (
      tester,
    ) async {
      suppressErrors();
      final tankA = _tank('t1', 'Tank A');
      final tankB = _tank('t2', 'Tank B');
      final tankC = _tank('t3', 'Tank C');
      final now = DateTime.now();

      await tester.pumpWidget(
        _wrap(
          tanks: [tankA, tankB, tankC],
          logs: {
            tankA.id: [
              _waterChange('wc-a', tankA.id),
              _waterTest('wt-a', tankA.id, nitrate: 10),
            ],
            tankB.id: [
              _waterChange('wc-b', tankB.id),
              _waterTest('wt-b', tankB.id, nitrate: 10),
            ],
            tankC.id: [
              _waterChange('wc-c', tankC.id, daysAgo: 21),
              _waterTest('wt-c', tankC.id, nitrate: 80),
            ],
          },
          tasks: {
            tankC.id: [
              _task(
                'task-c',
                tankC.id,
                'Water change',
                now.subtract(const Duration(days: 2)),
              ),
            ],
          },
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('All tanks at a glance'), findsOneWidget);
      expect(find.text('Highest priority: Tank C'), findsOneWidget);
      expect(
        find.textContaining('Water parameters need attention'),
        findsWidgets,
      );
    });

    testWidgets('shows recent activity across all tanks', (tester) async {
      suppressErrors();
      final tankA = _tank('t1', 'Tank A');
      final tankB = _tank('t2', 'Tank B');
      final tankC = _tank('t3', 'Tank C');

      await tester.pumpWidget(
        _wrap(
          tanks: [tankA, tankB, tankC],
          logs: {
            tankA.id: [_waterChange('wc-a', tankA.id, daysAgo: 4)],
            tankB.id: [_observation('obs-b', tankB.id, 'New plant growth')],
            tankC.id: [_waterTest('wt-c', tankC.id, nitrate: 80)],
          },
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.scrollUntilVisible(
        find.text('Recent activity across tanks'),
        250,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Recent activity across tanks'), findsOneWidget);
      expect(find.textContaining('Tank C'), findsWidgets);
      expect(find.textContaining('Water Test'), findsWidgets);
      expect(find.textContaining('Tank B'), findsWidgets);
      expect(find.textContaining('New plant growth'), findsWidgets);
    });

    testWidgets('shows honest sparse-data states without inventing metrics', (
      tester,
    ) async {
      suppressErrors();
      await tester.pumpWidget(
        _wrap(tanks: [_tank('t1', 'Tank A'), _tank('t2', 'Tank B')]),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('No water tests'), findsWidgets);
      await tester.scrollUntilVisible(
        find.text('Livestock & stocking'),
        250,
        scrollable: find.byType(Scrollable),
      );
      expect(find.textContaining('No livestock yet'), findsWidgets);
    });

    testWidgets('shows empty state message with no tanks', (tester) async {
      suppressErrors();
      await tester.pumpWidget(_wrap(tanks: []));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Need at Least 2 Tanks'), findsOneWidget);
    });
  });
}
