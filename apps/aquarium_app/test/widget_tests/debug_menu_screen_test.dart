// Widget tests for DebugMenuScreen.
//
// Run: flutter test test/widget_tests/debug_menu_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/debug_menu_screen.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/models/log_entry.dart';

Widget _wrap({InMemoryStorageService? storage}) {
  SharedPreferences.setMockInitialValues({});
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        return SharedPreferences.getInstance();
      }),
      if (storage != null) storageServiceProvider.overrideWithValue(storage),
    ],
    child: const MaterialApp(home: DebugMenuScreen()),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> clearStorage(InMemoryStorageService storage) async {
    final tanks = await storage.getAllTanks();
    await storage.deleteAllTanks(tanks.map((tank) => tank.id).toList());
  }

  group('DebugMenuScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(DebugMenuScreen), findsOneWidget);
    });

    testWidgets('shows Debug Menu app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('🐛 Debug Menu'), findsOneWidget);
    });

    testWidgets('shows Onboarding section header', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Onboarding'), findsOneWidget);
    });

    testWidgets('shows ListView', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows Complete Onboarding tile', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Complete Onboarding'), findsOneWidget);
    });

    testWidgets('seeds emergency unsafe-water QA tank and log', (
      tester,
    ) async {
      final storage = InMemoryStorageService();
      await clearStorage(storage);

      await tester.pumpWidget(_wrap(storage: storage));
      await _advance(tester);

      await tester.scrollUntilVisible(
        find.text('Seed Emergency Water Spike'),
        500,
      );
      await tester.tap(find.text('Seed Emergency Water Spike'));
      await tester.pumpAndSettle();

      final tank = await storage.getTank('debug-emergency-water-tank');
      expect(tank, isNotNull);
      expect(tank!.name, 'QA Emergency Water Spike');

      final livestock = await storage.getLivestockForTank(tank.id);
      expect(livestock.single.healthStatus.name, 'sick');

      final logs = await storage.getLogsForTank(tank.id);
      final waterTest = logs.singleWhere(
        (log) => log.type == LogType.waterTest,
      );
      expect(waterTest.waterTest?.ammonia, greaterThan(0));
      expect(waterTest.waterTest?.nitrite, greaterThan(0));
      expect(waterTest.title, contains('Emergency'));
    });
  });
}
