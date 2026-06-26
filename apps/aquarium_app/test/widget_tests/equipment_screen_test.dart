// Widget tests for EquipmentScreen.
//
// Run: flutter test test/widget_tests/equipment_screen_test.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/equipment_screen.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/models/models.dart';
import 'package:danio/theme/app_theme.dart';
import 'package:danio/widgets/core/app_card.dart';

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

UserProfile _makeProfile() => UserProfile(
  id: 'equipment-profile',
  experienceLevel: ExperienceLevel.beginner,
  primaryTankType: TankType.freshwater,
  goals: const [UserGoal.keepFishAlive],
  hasStreakFreeze: false,
  createdAt: _now,
  updatedAt: _now,
);

class _ThrowingSetStringPrefs implements SharedPreferences {
  _ThrowingSetStringPrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key, Object value) _shouldFail;

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  int? getInt(String key) => _delegate.getInt(key);

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  double? getDouble(String key) => _delegate.getDouble(key);

  @override
  List<String>? getStringList(String key) => _delegate.getStringList(key);

  @override
  Object? get(String key) => _delegate.get(key);

  @override
  bool containsKey(String key) => _delegate.containsKey(key);

  @override
  Set<String> getKeys() => _delegate.getKeys();

  @override
  Future<bool> setString(String key, String value) {
    if (_shouldFail(key, value)) {
      throw StateError('Simulated SharedPreferences write failure for $key');
    }
    return _delegate.setString(key, value);
  }

  @override
  Future<bool> setBool(String key, bool value) => _delegate.setBool(key, value);

  @override
  Future<bool> setDouble(String key, double value) =>
      _delegate.setDouble(key, value);

  @override
  Future<bool> setInt(String key, int value) => _delegate.setInt(key, value);

  @override
  Future<bool> setStringList(String key, List<String> value) =>
      _delegate.setStringList(key, value);

  @override
  Future<bool> remove(String key) => _delegate.remove(key);

  @override
  Future<bool> clear() => _delegate.clear();

  @override
  Future<void> reload() => _delegate.reload();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _wrap({InMemoryStorageService? storage, String tankId = 'tank-1'}) {
  final svc = storage ?? InMemoryStorageService();
  return ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(svc)],
    child: MaterialApp(home: EquipmentScreen(tankId: tankId)),
  );
}

Widget _wrapWithStorage({
  required StorageService storage,
  String tankId = 'tank-1',
}) {
  return ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
    child: MaterialApp(home: EquipmentScreen(tankId: tankId)),
  );
}

Widget _wrapWithLauncher({
  required InMemoryStorageService storage,
  String tankId = 'tank-1',
  SharedPreferences? prefs,
  bool showProfileProbe = false,
}) {
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(storage),
      if (prefs != null)
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
    ],
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showProfileProbe)
                  Consumer(
                    builder: (context, ref, _) {
                      final profile = ref
                          .watch(userProfileProvider)
                          .valueOrNull;
                      return Text(
                        profile == null ? 'profile loading' : 'profile ready',
                      );
                    },
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EquipmentScreen(tankId: tankId),
                      ),
                    );
                  },
                  child: const Text('Open equipment'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _wrapLoading({String tankId = 'tank-1'}) {
  final loading = Completer<List<Equipment>>();
  return ProviderScope(
    overrides: [
      equipmentProvider(tankId).overrideWith((ref) => loading.future),
    ],
    child: MaterialApp(home: EquipmentScreen(tankId: tankId)),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(seconds: 1));
}

class _DeleteTaskFailsStorage implements StorageService {
  _DeleteTaskFailsStorage(this._delegate, {required this.failingTaskId});

  final InMemoryStorageService _delegate;
  final String failingTaskId;

  @override
  Future<void> deleteAllTanks(List<String> ids) =>
      _delegate.deleteAllTanks(ids);

  @override
  Future<void> deleteEquipment(String id) => _delegate.deleteEquipment(id);

  @override
  Future<void> deleteLivestock(String id) => _delegate.deleteLivestock(id);

  @override
  Future<void> deleteLog(String id) => _delegate.deleteLog(id);

  @override
  Future<void> deleteTank(String id) => _delegate.deleteTank(id);

  @override
  Future<void> deleteTask(String id) async {
    if (id == failingTaskId) {
      throw StateError('task delete failed');
    }
    await _delegate.deleteTask(id);
  }

  @override
  Future<List<Tank>> getAllTanks() => _delegate.getAllTanks();

  @override
  Future<List<Equipment>> getEquipmentForTank(String tankId) =>
      _delegate.getEquipmentForTank(tankId);

  @override
  Future<LogEntry?> getLatestWaterTest(String tankId) =>
      _delegate.getLatestWaterTest(tankId);

  @override
  Future<List<Livestock>> getLivestockForTank(String tankId) =>
      _delegate.getLivestockForTank(tankId);

  @override
  Future<List<LogEntry>> getLogsForTank(
    String tankId, {
    int? limit,
    DateTime? after,
  }) => _delegate.getLogsForTank(tankId, limit: limit, after: after);

  @override
  Future<Tank?> getTank(String id) => _delegate.getTank(id);

  @override
  Future<List<Task>> getTasksForTank(String? tankId) =>
      _delegate.getTasksForTank(tankId);

  @override
  Future<void> saveEquipment(Equipment equipment) =>
      _delegate.saveEquipment(equipment);

  @override
  Future<void> saveLivestock(Livestock livestock) =>
      _delegate.saveLivestock(livestock);

  @override
  Future<void> saveLog(LogEntry log) => _delegate.saveLog(log);

  @override
  Future<void> saveTank(Tank tank) => _delegate.saveTank(tank);

  @override
  Future<void> saveTanks(List<Tank> tanks) => _delegate.saveTanks(tanks);

  @override
  Future<void> saveTask(Task task) => _delegate.saveTask(task);
}

class _SaveTaskFailsStorage extends _DeleteTaskFailsStorage {
  _SaveTaskFailsStorage(super._delegate) : super(failingTaskId: '');

  @override
  Future<void> deleteTask(String id) => _delegate.deleteTask(id);

  @override
  Future<void> saveTask(Task task) async {
    throw StateError('task save failed');
  }
}

class _SaveEquipmentFailsStorage implements StorageService {
  _SaveEquipmentFailsStorage(
    this._delegate, {
    required this.failingEquipmentId,
  });

  final InMemoryStorageService _delegate;
  final String failingEquipmentId;

  @override
  Future<void> deleteAllTanks(List<String> ids) =>
      _delegate.deleteAllTanks(ids);

  @override
  Future<void> deleteEquipment(String id) => _delegate.deleteEquipment(id);

  @override
  Future<void> deleteLivestock(String id) => _delegate.deleteLivestock(id);

  @override
  Future<void> deleteLog(String id) => _delegate.deleteLog(id);

  @override
  Future<void> deleteTank(String id) => _delegate.deleteTank(id);

  @override
  Future<void> deleteTask(String id) => _delegate.deleteTask(id);

  @override
  Future<List<Tank>> getAllTanks() => _delegate.getAllTanks();

  @override
  Future<List<Equipment>> getEquipmentForTank(String tankId) =>
      _delegate.getEquipmentForTank(tankId);

  @override
  Future<LogEntry?> getLatestWaterTest(String tankId) =>
      _delegate.getLatestWaterTest(tankId);

  @override
  Future<List<Livestock>> getLivestockForTank(String tankId) =>
      _delegate.getLivestockForTank(tankId);

  @override
  Future<List<LogEntry>> getLogsForTank(
    String tankId, {
    int? limit,
    DateTime? after,
  }) => _delegate.getLogsForTank(tankId, limit: limit, after: after);

  @override
  Future<Tank?> getTank(String id) => _delegate.getTank(id);

  @override
  Future<List<Task>> getTasksForTank(String? tankId) =>
      _delegate.getTasksForTank(tankId);

  @override
  Future<void> saveEquipment(Equipment equipment) async {
    if (equipment.id == failingEquipmentId) {
      throw StateError('equipment restore failed');
    }
    await _delegate.saveEquipment(equipment);
  }

  @override
  Future<void> saveLivestock(Livestock livestock) =>
      _delegate.saveLivestock(livestock);

  @override
  Future<void> saveLog(LogEntry log) => _delegate.saveLog(log);

  @override
  Future<void> saveTank(Tank tank) => _delegate.saveTank(tank);

  @override
  Future<void> saveTanks(List<Tank> tanks) => _delegate.saveTanks(tanks);

  @override
  Future<void> saveTask(Task task) => _delegate.saveTask(task);
}

class _SaveLogFailsStorage implements StorageService {
  _SaveLogFailsStorage(this._delegate, {required this.failingLogType});

  final InMemoryStorageService _delegate;
  final LogType failingLogType;

  @override
  Future<void> deleteAllTanks(List<String> ids) =>
      _delegate.deleteAllTanks(ids);

  @override
  Future<void> deleteEquipment(String id) => _delegate.deleteEquipment(id);

  @override
  Future<void> deleteLivestock(String id) => _delegate.deleteLivestock(id);

  @override
  Future<void> deleteLog(String id) => _delegate.deleteLog(id);

  @override
  Future<void> deleteTank(String id) => _delegate.deleteTank(id);

  @override
  Future<void> deleteTask(String id) => _delegate.deleteTask(id);

  @override
  Future<List<Tank>> getAllTanks() => _delegate.getAllTanks();

  @override
  Future<List<Equipment>> getEquipmentForTank(String tankId) =>
      _delegate.getEquipmentForTank(tankId);

  @override
  Future<LogEntry?> getLatestWaterTest(String tankId) =>
      _delegate.getLatestWaterTest(tankId);

  @override
  Future<List<Livestock>> getLivestockForTank(String tankId) =>
      _delegate.getLivestockForTank(tankId);

  @override
  Future<List<LogEntry>> getLogsForTank(
    String tankId, {
    int? limit,
    DateTime? after,
  }) => _delegate.getLogsForTank(tankId, limit: limit, after: after);

  @override
  Future<Tank?> getTank(String id) => _delegate.getTank(id);

  @override
  Future<List<Task>> getTasksForTank(String? tankId) =>
      _delegate.getTasksForTank(tankId);

  @override
  Future<void> saveEquipment(Equipment equipment) =>
      _delegate.saveEquipment(equipment);

  @override
  Future<void> saveLivestock(Livestock livestock) =>
      _delegate.saveLivestock(livestock);

  @override
  Future<void> saveLog(LogEntry log) async {
    if (log.type == failingLogType) {
      throw StateError('log save failed');
    }
    await _delegate.saveLog(log);
  }

  @override
  Future<void> saveTank(Tank tank) => _delegate.saveTank(tank);

  @override
  Future<void> saveTanks(List<Tank> tanks) => _delegate.saveTanks(tanks);

  @override
  Future<void> saveTask(Task task) => _delegate.saveTask(task);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('EquipmentScreen — renders', () {
    testWidgets('renders without throwing', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrap(storage: svc));
      await _advance(tester);
      expect(find.byType(EquipmentScreen), findsOneWidget);
    });

    testWidgets('shows Equipment app bar title', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrap(storage: svc));
      await _advance(tester);
      expect(find.text('Equipment'), findsOneWidget);
    });

    testWidgets('shows empty state when no equipment', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrap(storage: svc));
      await _advance(tester);
      // Empty state shows gear up message or Add Equipment button
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              (w.data?.contains('Add Equipment') == true ||
                  w.data?.contains('gear up') == true ||
                  w.data?.contains('Equipment') == true),
        ),
        findsWidgets,
      );
    });

    testWidgets('empty state does not duplicate the add action with a FAB', (
      tester,
    ) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrap(storage: svc));
      await _advance(tester);

      expect(find.text('Add Equipment'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('tablet keeps loading skeleton cards readable', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrapLoading());
      await tester.pump();

      final skeletonCard = find.byType(Card).first;
      expect(tester.getSize(skeletonCard).width, lessThanOrEqualTo(720));
    });

    testWidgets(
      'empty state title uses iconography instead of raw emoji text',
      (tester) async {
        final svc = InMemoryStorageService();
        await svc.saveTank(_makeTank());
        await tester.pumpWidget(_wrap(storage: svc));
        await _advance(tester);

        expect(find.byIcon(Icons.settings), findsWidgets);
        expect(find.text('Time to gear up!'), findsOneWidget);
        expect(find.textContaining('Time to gear up! ⚙️'), findsNothing);
      },
    );

    testWidgets('adding equipment shows success feedback', (tester) async {
      const tankId = 'tank-equipment-add-feedback';
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank(id: tankId));

      await tester.pumpWidget(_wrap(storage: svc, tankId: tankId));
      await _advance(tester);

      await tester.tap(find.text('Add Equipment'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(find.byType(TextFormField).first, 'Sponge filter');
      await tester.tap(find.text('Add').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 1));

      final equipment = await svc.getEquipmentForTank(tankId);
      expect(equipment.single.name, 'Sponge filter');
      expect(find.text('Sponge filter added.'), findsOneWidget);
    });

    testWidgets('failed maintenance-task sync rolls back new equipment', (
      tester,
    ) async {
      const tankId = 'tank-equipment-add-task-failure';
      final delegate = InMemoryStorageService();
      final storage = _SaveTaskFailsStorage(delegate);
      await delegate.saveTank(_makeTank(id: tankId));

      await tester.pumpWidget(
        _wrapWithStorage(storage: storage, tankId: tankId),
      );
      await _advance(tester);

      await tester.tap(find.text('Add Equipment'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(find.byType(TextFormField).first, 'Sponge filter');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Maintenance interval (days)'),
        '30',
      );
      await tester.tap(find.text('Add').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(await delegate.getEquipmentForTank(tankId), isEmpty);
      expect(await delegate.getTasksForTank(tankId), isEmpty);
      expect(
        find.text('Couldn\'t do that. Give it another go!'),
        findsOneWidget,
      );
      expect(find.text('Sponge filter added.'), findsNothing);
    });

    testWidgets(
      'profile activity failure after equipment add does not report add failure',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'user_profile': jsonEncode(_makeProfile().toJson()),
        });
        final prefs = await SharedPreferences.getInstance();
        final throwingPrefs = _ThrowingSetStringPrefs(
          prefs,
          (key, _) => key == 'user_profile',
        );
        const tankId = 'tank-equipment-add-profile-failure';
        final storage = InMemoryStorageService();
        await storage.saveTank(_makeTank(id: tankId));

        await tester.pumpWidget(
          _wrapWithLauncher(
            storage: storage,
            tankId: tankId,
            prefs: throwingPrefs,
            showProfileProbe: true,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('profile ready'), findsOneWidget);

        await tester.tap(find.text('Open equipment'));
        await tester.pump();
        await _advance(tester);

        await tester.tap(find.text('Add Equipment'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.enterText(
          find.byType(TextFormField).first,
          'Profile boundary filter',
        );
        await tester.tap(find.text('Add').last);
        await tester.pump();
        await _advance(tester);

        final equipment = await storage.getEquipmentForTank(tankId);
        expect(equipment, hasLength(1));
        expect(equipment.single.name, 'Profile boundary filter');
        expect(find.byType(EquipmentScreen), findsOneWidget);
        expect(
          find.widgetWithText(TextFormField, 'Profile boundary filter'),
          findsNothing,
        );
        expect(
          find.text(
            'Profile boundary filter added, but progress couldn\'t update.',
          ),
          findsOneWidget,
        );
        expect(
          find.text('Couldn\'t do that. Give it another go!'),
          findsNothing,
        );
        expect(find.text('Retry'), findsNothing);
      },
    );
  });

  group('EquipmentScreen — with equipment', () {
    testWidgets('renders equipment name when item exists', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      final equip = Equipment(
        id: 'equip-1',
        tankId: 'tank-1',
        type: EquipmentType.filter,
        name: 'Fluval 307',
        createdAt: _now,
        updatedAt: _now,
      );
      await svc.saveEquipment(equip);
      await tester.pumpWidget(_wrap(storage: svc));
      await _advance(tester);
      expect(find.text('Fluval 307'), findsOneWidget);
    });

    testWidgets('tablet keeps equipment warning and cards readable', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      final equip = Equipment(
        id: 'tablet-equip',
        tankId: 'tank-1',
        type: EquipmentType.filter,
        name: 'Canister filter',
        maintenanceIntervalDays: 14,
        lastServiced: _now.subtract(const Duration(days: 30)),
        createdAt: _now,
        updatedAt: _now,
      );
      await svc.saveEquipment(equip);

      await tester.pumpWidget(_wrap(storage: svc));
      await _advance(tester);

      final warningCard = find
          .ancestor(
            of: find.text('1 maintenance overdue'),
            matching: find.byType(AppCard),
          )
          .first;
      expect(tester.getSize(warningCard).width, lessThanOrEqualTo(720));

      final equipmentCard = find
          .ancestor(
            of: find.text('Canister filter'),
            matching: find.byType(Card),
          )
          .first;
      expect(tester.getSize(equipmentCard).width, lessThanOrEqualTo(720));
    });

    testWidgets(
      'last-serviced history icon uses the minimum legible app size',
      (tester) async {
        final svc = InMemoryStorageService();
        await svc.saveTank(_makeTank());
        final equip = Equipment(
          id: 'equip-1',
          tankId: 'tank-1',
          type: EquipmentType.filter,
          name: 'Fluval 307',
          lastServiced: _now,
          createdAt: _now,
          updatedAt: _now,
        );
        await svc.saveEquipment(equip);
        await tester.pumpWidget(_wrap(storage: svc));
        await _advance(tester);

        final serviceRow = find
            .ancestor(
              of: find.textContaining('Last serviced'),
              matching: find.byType(Row),
            )
            .first;
        final historyIcon = tester.widget<Icon>(
          find.descendant(of: serviceRow, matching: find.byIcon(Icons.history)),
        );
        expect(historyIcon.size, greaterThanOrEqualTo(AppIconSizes.xs));
      },
    );

    testWidgets('scaffold renders without crash', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrap(storage: svc));
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('undoing equipment removal restores its maintenance task', (
      tester,
    ) async {
      const tankId = 'tank-equipment-undo';
      const equipmentId = 'equip-undo';
      const taskId = 'equip_equip-undo_maintenance';
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank(id: tankId));
      final equipment = Equipment(
        id: equipmentId,
        tankId: tankId,
        type: EquipmentType.filter,
        name: 'Canister filter',
        maintenanceIntervalDays: 14,
        createdAt: _now,
        updatedAt: _now,
      );
      final task = Task(
        id: taskId,
        tankId: tankId,
        title: 'Service Canister filter',
        description: 'Maintenance for Filter',
        recurrence: RecurrenceType.custom,
        intervalDays: 14,
        dueDate: _now.add(const Duration(days: 14)),
        priority: TaskPriority.normal,
        isEnabled: true,
        isAutoGenerated: true,
        relatedEquipmentId: equipmentId,
        createdAt: _now,
        updatedAt: _now,
      );
      await svc.saveEquipment(equipment);
      await svc.saveTask(task);

      await tester.pumpWidget(_wrap(storage: svc, tankId: tankId));
      await _advance(tester);

      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove Equipment'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(await svc.getEquipmentForTank(tankId), isEmpty);
      expect(await svc.getTasksForTank(tankId), isEmpty);
      expect(find.text('Canister filter removed'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 1));

      final restoredEquipment = await svc.getEquipmentForTank(tankId);
      final restoredTasks = await svc.getTasksForTank(tankId);
      expect(restoredEquipment.map((item) => item.id), contains(equipmentId));
      expect(restoredTasks.map((item) => item.id), contains(taskId));
      expect(restoredTasks.single.relatedEquipmentId, equipmentId);
    });

    testWidgets('failed maintenance-task deletion keeps equipment saved', (
      tester,
    ) async {
      const tankId = 'tank-equipment-delete-failure';
      const equipmentId = 'equip-delete-failure';
      const taskId = 'equip_equip-delete-failure_maintenance';
      final delegate = InMemoryStorageService();
      final storage = _DeleteTaskFailsStorage(delegate, failingTaskId: taskId);
      await delegate.saveTank(_makeTank(id: tankId));
      final equipment = Equipment(
        id: equipmentId,
        tankId: tankId,
        type: EquipmentType.filter,
        name: 'Canister filter',
        maintenanceIntervalDays: 14,
        createdAt: _now,
        updatedAt: _now,
      );
      final task = Task(
        id: taskId,
        tankId: tankId,
        title: 'Service Canister filter',
        description: 'Maintenance for Filter',
        recurrence: RecurrenceType.custom,
        intervalDays: 14,
        dueDate: _now.add(const Duration(days: 14)),
        priority: TaskPriority.normal,
        isEnabled: true,
        isAutoGenerated: true,
        relatedEquipmentId: equipmentId,
        createdAt: _now,
        updatedAt: _now,
      );
      await delegate.saveEquipment(equipment);
      await delegate.saveTask(task);

      await tester.pumpWidget(
        _wrapWithStorage(storage: storage, tankId: tankId),
      );
      await _advance(tester);

      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove Equipment'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final equipmentAfterFailure = await delegate.getEquipmentForTank(tankId);
      expect(
        equipmentAfterFailure.map((item) => item.id),
        contains(equipmentId),
      );
      expect(
        find.text('Couldn\'t remove that equipment. Give it another go!'),
        findsOneWidget,
      );
    });

    testWidgets('failed service log keeps equipment unchanged', (tester) async {
      const tankId = 'tank-equipment-service-failure';
      const equipmentId = 'equip-service-failure';
      final lastServiced = _now.subtract(const Duration(days: 30));
      final delegate = InMemoryStorageService();
      final storage = _SaveLogFailsStorage(
        delegate,
        failingLogType: LogType.equipmentMaintenance,
      );
      await delegate.saveTank(_makeTank(id: tankId));
      final equipment = Equipment(
        id: equipmentId,
        tankId: tankId,
        type: EquipmentType.filter,
        name: 'Canister filter',
        maintenanceIntervalDays: 14,
        lastServiced: lastServiced,
        createdAt: _now.subtract(const Duration(days: 60)),
        updatedAt: _now.subtract(const Duration(days: 30)),
      );
      await delegate.saveEquipment(equipment);

      await tester.pumpWidget(
        _wrapWithStorage(storage: storage, tankId: tankId),
      );
      await _advance(tester);

      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark Serviced'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      final savedEquipment = (await delegate.getEquipmentForTank(
        tankId,
      )).single;
      expect(savedEquipment.lastServiced, lastServiced);
      expect(
        find.text(
          'Could not mark Canister filter as serviced. Try again in a moment.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('failed service task log restores equipment and task', (
      tester,
    ) async {
      const tankId = 'tank-equipment-task-log-failure';
      const equipmentId = 'equip-task-log-failure';
      const taskId = 'equip_equip-task-log-failure_maintenance';
      final lastServiced = _now.subtract(const Duration(days: 30));
      final originalDueDate = _now.subtract(const Duration(days: 1));
      final delegate = InMemoryStorageService();
      final storage = _SaveLogFailsStorage(
        delegate,
        failingLogType: LogType.taskCompleted,
      );
      await delegate.saveTank(_makeTank(id: tankId));
      final equipment = Equipment(
        id: equipmentId,
        tankId: tankId,
        type: EquipmentType.filter,
        name: 'Canister filter',
        maintenanceIntervalDays: 14,
        lastServiced: lastServiced,
        createdAt: _now.subtract(const Duration(days: 60)),
        updatedAt: _now.subtract(const Duration(days: 30)),
      );
      final task = Task(
        id: taskId,
        tankId: tankId,
        title: 'Service Canister filter',
        description: 'Maintenance for Filter',
        recurrence: RecurrenceType.custom,
        intervalDays: 14,
        dueDate: originalDueDate,
        priority: TaskPriority.normal,
        isEnabled: true,
        isAutoGenerated: true,
        relatedEquipmentId: equipmentId,
        createdAt: _now.subtract(const Duration(days: 60)),
        updatedAt: _now.subtract(const Duration(days: 30)),
      );
      await delegate.saveEquipment(equipment);
      await delegate.saveTask(task);

      await tester.pumpWidget(
        _wrapWithStorage(storage: storage, tankId: tankId),
      );
      await _advance(tester);

      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark Serviced'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      final savedEquipment = (await delegate.getEquipmentForTank(
        tankId,
      )).single;
      final savedTask = (await delegate.getTasksForTank(tankId)).single;
      final savedLogs = await delegate.getLogsForTank(tankId);

      expect(savedEquipment.lastServiced, lastServiced);
      expect(savedTask.completionCount, 0);
      expect(savedTask.lastCompletedAt, isNull);
      expect(savedTask.dueDate, originalDueDate);
      expect(savedLogs, isEmpty);
      expect(
        find.text(
          'Could not mark Canister filter as serviced. Try again in a moment.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('failed equipment delete undo keeps equipment deleted', (
      tester,
    ) async {
      const tankId = 'tank-equipment-undo-failure';
      const equipmentId = 'equip-undo-failure';
      const taskId = 'equip_equip-undo-failure_maintenance';
      final delegate = InMemoryStorageService();
      final storage = _SaveEquipmentFailsStorage(
        delegate,
        failingEquipmentId: equipmentId,
      );
      await delegate.saveTank(_makeTank(id: tankId));
      final equipment = Equipment(
        id: equipmentId,
        tankId: tankId,
        type: EquipmentType.filter,
        name: 'Canister filter',
        maintenanceIntervalDays: 14,
        createdAt: _now,
        updatedAt: _now,
      );
      final task = Task(
        id: taskId,
        tankId: tankId,
        title: 'Service Canister filter',
        description: 'Maintenance for Filter',
        recurrence: RecurrenceType.custom,
        intervalDays: 14,
        dueDate: _now.add(const Duration(days: 14)),
        priority: TaskPriority.normal,
        isEnabled: true,
        isAutoGenerated: true,
        relatedEquipmentId: equipmentId,
        createdAt: _now,
        updatedAt: _now,
      );
      await delegate.saveEquipment(equipment);
      await delegate.saveTask(task);

      await tester.pumpWidget(
        _wrapWithStorage(storage: storage, tankId: tankId),
      );
      await _advance(tester);

      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove Equipment'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(await delegate.getEquipmentForTank(tankId), isEmpty);
      expect(await delegate.getTasksForTank(tankId), isEmpty);
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(await delegate.getEquipmentForTank(tankId), isEmpty);
      expect(await delegate.getTasksForTank(tankId), isEmpty);
      expect(
        find.text('Could not restore Canister filter. Try again in a moment.'),
        findsOneWidget,
      );
    });

    testWidgets('equipment without a maintenance task removes cleanly', (
      tester,
    ) async {
      const tankId = 'tank-equipment-no-task';
      const equipmentId = 'equip-no-task';
      const taskId = 'equip_equip-no-task_maintenance';
      final delegate = InMemoryStorageService();
      final storage = _DeleteTaskFailsStorage(delegate, failingTaskId: taskId);
      await delegate.saveTank(_makeTank(id: tankId));
      final equipment = Equipment(
        id: equipmentId,
        tankId: tankId,
        type: EquipmentType.light,
        name: 'Plant light',
        createdAt: _now,
        updatedAt: _now,
      );
      await delegate.saveEquipment(equipment);

      await tester.pumpWidget(
        _wrapWithStorage(storage: storage, tankId: tankId),
      );
      await _advance(tester);

      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove Equipment'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(await delegate.getEquipmentForTank(tankId), isEmpty);
      expect(find.text('Plant light removed'), findsOneWidget);
      expect(
        find.text('Couldn\'t remove that equipment. Give it another go!'),
        findsNothing,
      );
    });
  });
}
