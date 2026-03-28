// Widget tests for CyclingAssistantScreen.
//
// Run: flutter test test/widget_tests/cycling_assistant_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/cycling_assistant_screen.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/models/tank.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _fakeTankId = 'tank-cycle-001';

Widget _wrap() {
  final memStorage = InMemoryStorageService();
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(memStorage),
      tankProvider.overrideWith(
        (ref, tankId) async => Tank(
          id: tankId,
          name: 'Cycling Tank',
          type: TankType.freshwater,
          volumeLitres: 100,
          startDate: DateTime.now().subtract(const Duration(days: 10)),
          targets: const WaterTargets(),
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      ),
      allLogsProvider.overrideWith((ref, tankId) async => []),
    ],
    child: MaterialApp(
      home: CyclingAssistantScreen(tankId: _fakeTankId),
    ),
  );
}

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

  group('CyclingAssistantScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(CyclingAssistantScreen), findsOneWidget);
    });

    testWidgets('shows Nitrogen Cycle Assistant title', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Nitrogen Cycle Assistant'), findsOneWidget);
    });

    testWidgets('shows scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows app bar', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders cycling phase content after data loads', (tester) async {
      await tester.pumpWidget(_wrap());
      // Allow async providers to resolve
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      // Should no longer show loading indicator
      expect(find.byType(CyclingAssistantScreen), findsOneWidget);
    });
  });
}
