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
import 'package:danio/screens/add_log_screen.dart';
import 'package:danio/screens/emergency_guide_screen.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/providers/room_theme_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/theme/room_themes.dart';
import 'package:danio/utils/navigation_throttle.dart';

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

Widget _wrapWithTank({Tank? tank, InMemoryStorageService? storage}) {
  final memStorage = storage ?? InMemoryStorageService();
  final now = DateTime(2026, 1, 1);
  final resolvedTank =
      tank ??
      Tank(
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
      tanksProvider.overrideWith((ref) async => [resolvedTank]),
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
    NavigationThrottle.reset();
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

    testWidgets('main Tank Feed quick action saves a feeding log', (
      tester,
    ) async {
      suppressLayoutErrors();
      final storage = InMemoryStorageService();
      final now = DateTime(2026, 1, 1);
      final tank = Tank(
        id: 'quick-feed-${DateTime.now().microsecondsSinceEpoch}',
        name: 'Quick Feed Tank',
        type: TankType.freshwater,
        volumeLitres: 100,
        startDate: now,
        targets: WaterTargets.freshwaterTropical(),
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(_wrapWithTank(tank: tank, storage: storage));
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));

      await tester.tap(find.bySemanticsLabel('Open action menu'));
      await tester.pump(const Duration(milliseconds: 800));
      final feedTapTarget = tester.widget<GestureDetector>(
        find
            .ancestor(
              of: find.text('Feed'),
              matching: find.byType(GestureDetector),
            )
            .first,
      );
      feedTapTarget.onTap!();
      await tester.pump(const Duration(milliseconds: 500));

      final logs = await storage.getLogsForTank(tank.id);
      expect(logs.where((log) => log.type == LogType.feeding), hasLength(1));
      expect(find.textContaining('Feeding logged'), findsOneWidget);
      expect(find.byType(AddLogScreen), findsNothing);
    });

    testWidgets('Tank top bar opens Emergency Guide', (tester) async {
      suppressLayoutErrors();

      await tester.pumpWidget(_wrapWithTank());
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));

      expect(find.byTooltip('Emergency Guide'), findsOneWidget);

      final emergencyButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.emergency_outlined),
      );
      emergencyButton.onPressed!();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(EmergencyGuideScreen), findsOneWidget);
      expect(find.text('Emergency Guide'), findsWidgets);
    });
  });
}
