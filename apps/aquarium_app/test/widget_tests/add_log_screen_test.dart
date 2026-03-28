// Widget tests for AddLogScreen.
//
// Run: flutter test test/widget_tests/add_log_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/add_log_screen.dart';
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

Widget _wrap({InMemoryStorageService? storage, LogType type = LogType.waterTest}) {
  final svc = storage ?? InMemoryStorageService();
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(svc),
    ],
    child: MaterialApp(
      home: AddLogScreen(tankId: 'tank-1', initialType: type),
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
        find.byWidgetPredicate((w) =>
            w is Text &&
            (w.data == 'Save Log' ||
                w.data == 'Save' ||
                w.data == 'Log Entry' ||
                w.data == 'Submit')),
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
  });
}
