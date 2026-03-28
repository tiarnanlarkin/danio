// Widget tests for LivestockDetailScreen.
//
// Run: flutter test test/widget_tests/livestock_detail_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/livestock_detail_screen.dart';
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

Livestock _makeLivestock({
  String id = 'ls-1',
  String tankId = 'tank-1',
  String name = 'Neon Tetra',
}) =>
    Livestock(
      id: id,
      tankId: tankId,
      commonName: name,
      scientificName: 'Paracheirodon innesi',
      count: 6,
      dateAdded: _now,
      createdAt: _now,
      updatedAt: _now,
    );

Widget _wrap({InMemoryStorageService? storage, Livestock? livestock}) {
  final svc = storage ?? InMemoryStorageService();
  final ls = livestock ?? _makeLivestock();
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(svc),
    ],
    child: MaterialApp(
      home: LivestockDetailScreen(tankId: 'tank-1', livestock: ls),
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

  group('LivestockDetailScreen — renders', () {
    testWidgets('renders without throwing', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrap(storage: svc));
      await _advance(tester);
      expect(find.byType(LivestockDetailScreen), findsOneWidget);
    });

    testWidgets('shows fish common name in app bar', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrap(storage: svc));
      await _advance(tester);
      expect(find.text('Neon Tetra'), findsWidgets);
    });

    testWidgets('shows scaffold', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrap(storage: svc));
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows fish count info', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      final ls = _makeLivestock(name: 'Betta');
      await tester.pumpWidget(_wrap(storage: svc, livestock: ls));
      await _advance(tester);
      expect(find.text('Betta'), findsWidgets);
    });

    testWidgets('shows scrollable content', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrap(storage: svc));
      await _advance(tester);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
