// Widget tests for TankDetailScreen.
//
// Run: flutter test test/widget_tests/tank_detail_screen_test.dart
//
// Note: TankDetailScreen includes QuickAddFab (repeating animation) and
// flutter_animate widgets. pumpAndSettle never settles. We use timed pumps.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/tank_detail/tank_detail_screen.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/models/models.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _now = DateTime.now();

Tank _makeTank({String id = 'tank-1', String name = 'My Test Tank'}) => Tank(
      id: id,
      name: name,
      type: TankType.freshwater,
      volumeLitres: 100,
      startDate: _now,
      targets: WaterTargets.freshwaterTropical(),
      createdAt: _now,
      updatedAt: _now,
    );

Widget _wrap(String tankId, {InMemoryStorageService? storage}) {
  final svc = storage ?? InMemoryStorageService();
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(svc),
    ],
    child: MaterialApp(
      home: TankDetailScreen(tankId: tankId),
    ),
  );
}

/// Advance enough time for async providers + animations without hitting
/// repeating animation loops that prevent pumpAndSettle from settling.
Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 1000));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TankDetailScreen — smoke tests', () {
    testWidgets('widget type is constructable', (tester) async {
      expect(TankDetailScreen(tankId: 'tank-1'), isA<TankDetailScreen>());
    });

    testWidgets('renders without throwing with valid tank', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrap('tank-1', storage: svc));
      await _advance(tester);
      expect(find.byType(TankDetailScreen), findsOneWidget);
    });

    testWidgets('renders scaffold', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank());
      await tester.pumpWidget(_wrap('tank-1', storage: svc));
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows tank name after data loads', (tester) async {
      final svc = InMemoryStorageService();
      await svc.saveTank(_makeTank(name: 'Crystal Palace'));
      await tester.pumpWidget(_wrap('tank-1', storage: svc));
      await _advance(tester);
      expect(find.textContaining('Crystal Palace'), findsWidgets);
    });
  });
}
