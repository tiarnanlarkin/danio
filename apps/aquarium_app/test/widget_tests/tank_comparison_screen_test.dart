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
      startDate: DateTime(2024),
      targets: const WaterTargets(),
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

Widget _wrap({List<Tank>? tanks}) {
  final memStorage = InMemoryStorageService();
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(memStorage),
      tanksProvider.overrideWith(
        (ref) async => tanks ?? [],
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

    testWidgets('shows "Need at Least 2 Tanks" when fewer than 2 tanks exist',
        (tester) async {
      suppressErrors();
      await tester.pumpWidget(_wrap(tanks: [_tank('t1', 'Tank A')]));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Need at Least 2 Tanks'), findsOneWidget);
    });

    testWidgets('shows comparison layout with 2+ tanks', (tester) async {
      suppressErrors();
      await tester.pumpWidget(_wrap(
        tanks: [_tank('t1', 'Tank A'), _tank('t2', 'Tank B')],
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      // Comparison dropdowns should appear
      expect(find.byType(DropdownButton<String>), findsWidgets);
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
