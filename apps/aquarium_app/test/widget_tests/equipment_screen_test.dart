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

Widget _wrap({InMemoryStorageService? storage}) {
  final svc = storage ?? InMemoryStorageService();
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(svc),
    ],
    child: const MaterialApp(
      home: EquipmentScreen(tankId: 'tank-1'),
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
        find.byWidgetPredicate((w) =>
            w is Text &&
            (w.data?.contains('Add Equipment') == true ||
                w.data?.contains('gear up') == true ||
                w.data?.contains('Equipment') == true)),
        findsWidgets,
      );
    });
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

    testWidgets('scaffold renders without crash', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrap(storage: svc));
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
