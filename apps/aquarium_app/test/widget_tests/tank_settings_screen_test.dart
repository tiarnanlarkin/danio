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
import 'package:danio/widgets/danio_bottom_dock.dart';

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
    child: MaterialApp(home: TankSettingsScreen(tankId: _fakeTankId)),
  );
}

Widget _wrapNotFound() {
  final memStorage = InMemoryStorageService();
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(memStorage),
      tankProvider.overrideWith((ref, tankId) async => null),
    ],
    child: MaterialApp(home: TankSettingsScreen(tankId: _fakeTankId)),
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

    testWidgets('does not overflow the tank type selector on a phone width', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2520);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap());
      await _advance(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Freshwater'), findsOneWidget);
    });

    testWidgets('shows tank type as fixed supported freshwater scope', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      expect(find.text('Freshwater'), findsOneWidget);
      expect(find.textContaining('Marine'), findsNothing);
      expect(find.textContaining('not available'), findsNothing);
      expect(find.byType(DropdownButtonFormField<TankType>), findsNothing);
    });

    testWidgets('adds enough bottom padding for the persistent dock', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      final listView = tester.widget<ListView>(find.byType(ListView));
      final padding = listView.padding as EdgeInsets;

      expect(
        padding.bottom,
        greaterThanOrEqualTo(DanioBottomDock.contentClearance),
      );
    });

    testWidgets('shows not found message when tank is null', (tester) async {
      await tester.pumpWidget(_wrapNotFound());
      await _advance(tester);
      expect(find.text('Tank not found'), findsOneWidget);
    });
  });
}
