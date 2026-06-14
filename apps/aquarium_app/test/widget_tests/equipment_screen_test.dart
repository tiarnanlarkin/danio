// Widget tests for EquipmentScreen.
//
// Run: flutter test test/widget_tests/equipment_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/equipment_screen.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/models/models.dart';
import 'package:danio/theme/app_theme.dart';

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

Widget _wrap({InMemoryStorageService? storage, String tankId = 'tank-1'}) {
  final svc = storage ?? InMemoryStorageService();
  return ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(svc)],
    child: MaterialApp(home: EquipmentScreen(tankId: tankId)),
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

        final historyIcon = tester.widget<Icon>(find.byIcon(Icons.history));
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
  });
}
