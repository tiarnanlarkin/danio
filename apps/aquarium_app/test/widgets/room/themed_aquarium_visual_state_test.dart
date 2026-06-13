import 'package:danio/models/log_entry.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/services/tank_aquascape_visual_service.dart';
import 'package:danio/services/tank_livestock_visual_service.dart';
import 'package:danio/theme/room_themes.dart';
import 'package:danio/widgets/room/themed_aquarium.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(
  WaterTestResults? latestWaterTest, {
  int feedingPulse = 0,
  TankAquascapeVisualState? aquascapeVisualState,
  TankLivestockVisualState? livestockVisualState,
}) {
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(InMemoryStorageService()),
    ],
    child: MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Scaffold(
          body: Center(
            child: ThemedAquarium(
              width: 320,
              height: 220,
              theme: RoomTheme.ocean,
              reduceMotion: true,
              latestWaterTest: latestWaterTest,
              feedingPulse: feedingPulse,
              aquascapeVisualState: aquascapeVisualState,
              livestockVisualState: livestockVisualState,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('safe readings do not render a water-state overlay', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        WaterTestResults(temperature: 25, ammonia: 0, nitrite: 0, nitrate: 15),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('tank-visual-overlay-clear')), findsNothing);
  });

  testWidgets('unsafe nitrogen renders an unsafe water overlay', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        _wrap(WaterTestResults(ammonia: 0.5, nitrite: 0, nitrate: 10)),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('tank-visual-overlay-unsafeWater')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Tank visual state: unsafe water'),
        findsOneWidget,
      );
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('warm water renders a warm overlay', (tester) async {
    await tester.pumpWidget(
      _wrap(
        WaterTestResults(temperature: 31, ammonia: 0, nitrite: 0, nitrate: 10),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('tank-visual-overlay-tooWarm')),
      findsOneWidget,
    );
  });

  testWidgets('high nitrate renders a stale water overlay', (tester) async {
    await tester.pumpWidget(
      _wrap(WaterTestResults(ammonia: 0, nitrite: 0, nitrate: 50)),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('tank-visual-overlay-staleWater')),
      findsOneWidget,
    );
  });

  testWidgets('shows feeding pulse when feedingPulse is positive', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(_wrap(null, feedingPulse: 1));
      await tester.pump();

      expect(find.byKey(const Key('tank-feeding-pulse-1')), findsOneWidget);
      expect(find.bySemanticsLabel('Tank feeding animation'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('shows livestock compatibility cue when provided', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        _wrap(
          null,
          livestockVisualState: const TankLivestockVisualState(
            condition: TankLivestockVisualCondition.compatibilityConcern,
            semanticsLabel:
                'Tank livestock visual state: compatibility needs review',
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('tank-livestock-overlay-compatibilityConcern')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          'Tank livestock visual state: compatibility needs review',
        ),
        findsOneWidget,
      );
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('shows aquascape cue when provided', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        _wrap(
          null,
          aquascapeVisualState: const TankAquascapeVisualState(
            condition: TankAquascapeVisualCondition.plantedDecorated,
            semanticsLabel:
                'Tank aquascape visual state: planted and decorated',
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('tank-aquascape-overlay-plantedDecorated')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          'Tank aquascape visual state: planted and decorated',
        ),
        findsOneWidget,
      );
    } finally {
      semantics.dispose();
    }
  });
}
