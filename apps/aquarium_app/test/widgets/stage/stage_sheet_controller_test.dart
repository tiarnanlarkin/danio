import 'package:danio/widgets/stage/stage_provider.dart';
import 'package:danio/widgets/stage/stage_sheet_controller.dart';
import 'package:danio/widgets/stage/swiss_army_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Stage sheet coordination', () {
    testWidgets('opening a side handle requests the bottom sheet to close', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  StageHandleStrip(
                    panel: StagePanel.temp,
                    isLeft: true,
                    icon: Icons.thermostat_outlined,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(StageHandleStrip));
      await tester.pump();

      expect(
        container.read(stageProvider).openPanels,
        contains(StagePanel.temp),
      );
      expect(
        container.read(stageSheetControllerProvider).snap,
        StageSheetSnap.closed,
      );
    });

    testWidgets(
      'drag-opening a side handle requests the bottom sheet to close',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: Stack(
                  children: [
                    StageHandleStrip(
                      panel: StagePanel.waterQuality,
                      isLeft: false,
                      icon: Icons.water_drop_outlined,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.fling(
          find.byType(StageHandleStrip),
          const Offset(-140, 0),
          600,
        );
        await tester.pump();

        expect(
          container.read(stageProvider).openPanels,
          contains(StagePanel.waterQuality),
        );
        expect(
          container.read(stageSheetControllerProvider).snap,
          StageSheetSnap.closed,
        );
      },
    );
  });
}
