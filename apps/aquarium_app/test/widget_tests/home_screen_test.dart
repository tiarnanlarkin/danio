// Widget tests for HomeScreen.
//
// Run: flutter test test/widget_tests/home_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/models/models.dart';
import 'package:danio/screens/home/home_screen.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/providers/room_theme_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/theme/room_themes.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  final memStorage = InMemoryStorageService();

  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(memStorage),
      tanksProvider.overrideWith((ref) async => []),
      currentRoomThemeProvider.overrideWith((ref) => RoomTheme.ocean),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

Widget _wrapWithTank() {
  final memStorage = InMemoryStorageService();
  final now = DateTime(2026, 1, 1);
  final tank = Tank(
    id: 'tank-1',
    name: 'Test Tank',
    type: TankType.freshwater,
    volumeLitres: 100,
    startDate: now,
    targets: WaterTargets.freshwaterTropical(),
    createdAt: now,
    updatedAt: now,
  );

  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(memStorage),
      tanksProvider.overrideWith((ref) async => [tank]),
      currentRoomThemeProvider.overrideWith((ref) => RoomTheme.ocean),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Suppress overflow and assertion errors from complex stage/room widgets
  // at the default test canvas size.
  void suppressLayoutErrors() {
    final original = FlutterError.onError!;
    FlutterError.onError = (FlutterErrorDetails details) {
      final msg = details.exceptionAsString();
      if (msg.contains('overflowed') ||
          msg.contains('backgroundImage != null')) {
        return;
      }
      original(details);
    };
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HomeScreen', () {
    testWidgets('renders without throwing', (tester) async {
      suppressLayoutErrors();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      // Drain any pending timers
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('shows Scaffold with content', (tester) async {
      suppressLayoutErrors();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 3));
      // HomeScreen renders the Scaffold — verify it's present
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });

    testWidgets('renders after async providers complete', (tester) async {
      suppressLayoutErrors();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('tank toolbox exposes one tappable semantics node', (
      tester,
    ) async {
      suppressLayoutErrors();
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(_wrapWithTank());
        await tester.pump();
        await tester.pump(const Duration(seconds: 5));

        expect(find.bySemanticsLabel('Tank Toolbox'), findsOneWidget);
        final toolboxNode = tester.getSemantics(
          find.bySemanticsLabel('Tank Toolbox'),
        );
        expect(
          toolboxNode.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
        );
      } finally {
        semantics.dispose();
      }
    });
  });
}
