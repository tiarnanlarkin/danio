// Widget tests for TankSettingsScreen.
//
// Run: flutter test test/widget_tests/tank_settings_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/tank_settings_screen.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/models/tank.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _fakeTankId = 'tank-settings-001';

Tank _fakeTank() => Tank(
      id: _fakeTankId,
      name: 'My Test Tank',
      type: TankType.freshwater,
      volumeLitres: 100,
      startDate: DateTime(2024),
      targets: const WaterTargets(),
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

Widget _wrap() {
  final memStorage = InMemoryStorageService();
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(memStorage),
      tankProvider.overrideWith((ref, tankId) async => _fakeTank()),
    ],
    child: MaterialApp(
      home: TankSettingsScreen(tankId: _fakeTankId),
    ),
  );
}

Widget _wrapNotFound() {
  final memStorage = InMemoryStorageService();
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(memStorage),
      tankProvider.overrideWith((ref, tankId) async => null),
    ],
    child: MaterialApp(
      home: TankSettingsScreen(tankId: _fakeTankId),
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

  group('TankSettingsScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(TankSettingsScreen), findsOneWidget);
    });

    testWidgets('shows scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows Tank Settings in app bar when loaded', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Tank Settings'), findsOneWidget);
    });

    testWidgets('shows tank name field pre-populated', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('My Test Tank'), findsOneWidget);
    });

    testWidgets('shows not found message when tank is null', (tester) async {
      await tester.pumpWidget(_wrapNotFound());
      await _advance(tester);
      expect(find.text('Tank not found'), findsOneWidget);
    });
  });
}
