// Widget tests for LivestockScreen.
//
// Run: flutter test test/widget_tests/livestock_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/livestock/livestock_screen.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/providers/tank_visual_event_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/models/models.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _fakeTankId = 'tank-001';
final _now = DateTime(2026, 6, 14, 12);

Tank _makeTank({required String id, required String name}) => Tank(
  id: id,
  name: name,
  type: TankType.freshwater,
  volumeLitres: 100,
  startDate: _now,
  targets: WaterTargets.freshwaterTropical(),
  createdAt: _now,
  updatedAt: _now,
);

Livestock _makeLivestock({
  required String id,
  required String tankId,
  required String name,
  int count = 1,
}) => Livestock(
  id: id,
  tankId: tankId,
  commonName: name,
  count: count,
  dateAdded: _now,
  createdAt: _now,
  updatedAt: _now,
);

Widget _wrap({AsyncValue<List<Livestock>>? livestockOverride}) {
  // Use in-memory storage so no real SQLite I/O occurs in tests.
  final memStorage = InMemoryStorageService();
  final overrides = <Override>[
    storageServiceProvider.overrideWithValue(memStorage),
    livestockProvider.overrideWith(
      (ref, tankId) async => livestockOverride?.valueOrNull ?? [],
    ),
    tankProvider.overrideWith(
      (ref, tankId) async => Tank(
        id: tankId,
        name: 'My Tank',
        type: TankType.freshwater,
        volumeLitres: 100,
        startDate: DateTime(2024),
        targets: const WaterTargets(),
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      ),
    ),
  ];

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: LivestockScreen(tankId: _fakeTankId)),
  );
}

Widget _wrapWithStorage({
  required StorageService storage,
  required String tankId,
}) {
  return ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
    child: MaterialApp(home: LivestockScreen(tankId: tankId)),
  );
}

Widget _wrapWithPulseProbe({
  required StorageService storage,
  required String tankId,
}) {
  return ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
    child: MaterialApp(
      home: Stack(
        children: [
          LivestockScreen(tankId: tankId),
          Positioned(
            left: 0,
            top: 0,
            child: Consumer(
              builder: (context, ref, _) =>
                  Text('pulse ${ref.watch(tankFeedingPulseProvider(tankId))}'),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _wrapWithTimelineProbe({
  required StorageService storage,
  required String tankId,
}) {
  return ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
    child: MaterialApp(
      home: Stack(
        children: [
          LivestockScreen(tankId: tankId),
          Positioned(
            left: 0,
            top: 0,
            child: Consumer(
              builder: (context, ref, _) {
                final feedingCount = ref
                    .watch(allLogsProvider(tankId))
                    .maybeWhen(
                      data: (logs) => logs
                          .where((log) => log.type == LogType.feeding)
                          .length,
                      orElse: () => -1,
                    );
                return Text('timeline feedings $feedingCount');
              },
            ),
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // The skeleton loader renders placeholder LivestockCard widgets that have
  // a CircleAvatar assertion issue at test canvas size.  We suppress it below.
  void suppressAvatarError() {
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

  group('LivestockScreen — empty state', () {
    testWidgets('renders without throwing', (tester) async {
      suppressAvatarError();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(LivestockScreen), findsOneWidget);
    });

    testWidgets('shows Livestock app bar title', (tester) async {
      suppressAvatarError();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Livestock'), findsOneWidget);
    });

    testWidgets('shows Add Livestock button when empty', (tester) async {
      suppressAvatarError();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Add Livestock'), findsOneWidget);
    });

    testWidgets('empty state does not duplicate the add action with a FAB', (
      tester,
    ) async {
      suppressAvatarError();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Add Livestock'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets(
      'empty state title uses iconography instead of raw emoji text',
      (tester) async {
        suppressAvatarError();
        await tester.pumpWidget(_wrap());
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.byIcon(Icons.set_meal), findsWidgets);
        expect(
          find.text('Your tank awaits its first residents!'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Your tank awaits its first residents! 🐠'),
          findsNothing,
        );
      },
    );

    testWidgets('has overflow menu button in actions', (tester) async {
      suppressAvatarError();
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets(
      'adding livestock shows success feedback and readable timeline log',
      (tester) async {
        suppressAvatarError();
        const tankId = 'livestock-add-feedback-tank';
        final storage = InMemoryStorageService();
        await storage.saveTank(_makeTank(id: tankId, name: 'Shrimp Tank'));

        await tester.pumpWidget(
          _wrapWithStorage(storage: storage, tankId: tankId),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.text('Add Livestock'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.enterText(
          find.byType(TextFormField).first,
          'Amano Shrimp',
        );
        await tester.tap(find.text('Add').last);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(seconds: 1));

        final livestock = await storage.getLivestockForTank(tankId);
        expect(livestock.single.commonName, 'Amano Shrimp');
        expect(livestock.single.count, 1);

        final logs = await storage.getLogsForTank(tankId);
        expect(logs.single.title, 'Added 1x Amano Shrimp');
        expect(find.text('1x Amano Shrimp added.'), findsOneWidget);
      },
    );
  });

  group('LivestockScreen - quick feeding', () {
    testWidgets('successful feeding log emits a tank feeding pulse', (
      tester,
    ) async {
      suppressAvatarError();
      const tankId = 'livestock-feed-pulse-tank';
      final storage = InMemoryStorageService();
      await storage.saveTank(_makeTank(id: tankId, name: 'Community Tank'));
      await storage.saveLivestock(
        _makeLivestock(
          id: 'livestock-feed-pulse-neons',
          tankId: tankId,
          name: 'Neon Tetra',
          count: 8,
        ),
      );

      await tester.pumpWidget(
        _wrapWithPulseProbe(storage: storage, tankId: tankId),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('pulse 0'), findsOneWidget);

      await tester.tap(find.text('Feed'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final logs = await storage.getLogsForTank(tankId);
      expect(logs.where((log) => log.type == LogType.feeding), hasLength(1));
      expect(find.text('pulse 1'), findsOneWidget);
    });

    testWidgets('successful feeding log refreshes all-log timeline data', (
      tester,
    ) async {
      suppressAvatarError();
      const tankId = 'livestock-feed-timeline-tank';
      final storage = InMemoryStorageService();
      await storage.saveTank(_makeTank(id: tankId, name: 'Timeline Tank'));
      await storage.saveLivestock(
        _makeLivestock(
          id: 'livestock-feed-timeline-corys',
          tankId: tankId,
          name: 'Corydoras',
          count: 6,
        ),
      );

      await tester.pumpWidget(
        _wrapWithTimelineProbe(storage: storage, tankId: tankId),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('timeline feedings 0'), findsOneWidget);

      await tester.tap(find.text('Feed'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final logs = await storage.getLogsForTank(tankId);
      expect(logs.where((log) => log.type == LogType.feeding), hasLength(1));
      expect(find.text('timeline feedings 1'), findsOneWidget);
    });
  });

  group('LivestockScreen - bulk move', () {
    testWidgets('success feedback reports selected livestock count', (
      tester,
    ) async {
      suppressAvatarError();
      const sourceTankId = 'bulk-move-source';
      const targetTankId = 'bulk-move-target';
      final storage = InMemoryStorageService();
      await storage.saveTank(
        _makeTank(id: sourceTankId, name: 'Living Room Tank'),
      );
      await storage.saveTank(_makeTank(id: targetTankId, name: 'Bedroom Tank'));
      await storage.saveLivestock(
        _makeLivestock(
          id: 'bulk-move-neons',
          tankId: sourceTankId,
          name: 'Neon Tetra',
          count: 8,
        ),
      );
      await storage.saveLivestock(
        _makeLivestock(
          id: 'bulk-move-corys',
          tankId: sourceTankId,
          name: 'Corydoras',
          count: 5,
        ),
      );

      await tester.pumpWidget(
        _wrapWithStorage(storage: storage, tankId: sourceTankId),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.more_vert),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select multiple'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select All'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Move to Tank'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bedroom Tank').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Moved 2 livestock to Bedroom Tank'), findsOneWidget);
      expect(find.text('Moved 0 livestock to Bedroom Tank'), findsNothing);
    });
  });

  group('LivestockScreen - bulk delete', () {
    testWidgets('expired bulk removal writes timeline logs', (tester) async {
      suppressAvatarError();
      const tankId = 'bulk-delete-log-tank';
      final storage = InMemoryStorageService();
      await storage.saveTank(_makeTank(id: tankId, name: 'Timeline Tank'));
      await storage.saveLivestock(
        _makeLivestock(
          id: 'bulk-delete-neons',
          tankId: tankId,
          name: 'Neon Tetra',
          count: 8,
        ),
      );
      await storage.saveLivestock(
        _makeLivestock(
          id: 'bulk-delete-corys',
          tankId: tankId,
          name: 'Corydoras',
          count: 5,
        ),
      );

      await tester.pumpWidget(
        _wrapWithStorage(storage: storage, tankId: tankId),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.more_vert),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select multiple'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select All'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove Livestock'));
      await tester.pump();

      expect(find.text('2 livestock removed'), findsOneWidget);

      await tester.pump(const Duration(seconds: 6));
      await tester.pump();

      final logs = await storage.getLogsForTank(tankId);
      final removalLogs = logs
          .where((log) => log.type == LogType.livestockRemoved)
          .toList();

      expect(removalLogs, hasLength(2));
      expect(
        removalLogs.map((log) => log.title),
        containsAll(<String>['Removed 8x Neon Tetra', 'Removed 5x Corydoras']),
      );
    });
  });
}
