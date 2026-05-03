import 'package:danio/theme/room_themes.dart';
import 'package:danio/widgets/stage/bottom_sheet_panel.dart';
import 'package:danio/widgets/stage/stage_provider.dart';
import 'package:danio/widgets/stage/swiss_army_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SwissArmyPanel glass frame (concept lock 2026-04-07)', () {
    testWidgets('uses sigma:14 blur when open', (tester) async {
      // Compile-time lock for the sigma constant
      expect(SwissArmyPanel.kGlassBlurSigma, 14.0);

      final container = ProviderContainer();
      container.read(stageProvider.notifier).toggle(StagePanel.waterQuality);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Stack(
              children: [
                SwissArmyPanel.right(
                  theme: RoomTheme.ocean,
                  child: const SizedBox(key: Key('panel-body')),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // BackdropFilter is present (structural check)
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.byKey(const Key('panel-body')), findsOneWidget);
    });

    testWidgets('has a drop shadow on the outer frame', (tester) async {
      final container = ProviderContainer();
      container.read(stageProvider.notifier).toggle(StagePanel.waterQuality);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Stack(
              children: [
                SwissArmyPanel.right(
                  theme: RoomTheme.ocean,
                  child: const SizedBox(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final frame = tester.widget<DecoratedBox>(
        find.byKey(const Key('swiss-frame-shadow')),
      );
      final deco = frame.decoration as BoxDecoration;
      expect(deco.boxShadow, isNotNull);
      expect(deco.boxShadow!.length, 1);
      expect(deco.boxShadow!.first.color, const Color(0x40000000));
      expect(deco.boxShadow!.first.blurRadius, 8);
      expect(deco.boxShadow!.first.offset, const Offset(0, 2));
    });

    test('uses conservative viewport constants for side panels', () {
      expect(SwissArmyPanel.kPanelWidthFactor, lessThanOrEqualTo(0.68));
      expect(SwissArmyPanel.kBottomContentGutter, lessThanOrEqualTo(24));
    });

    testWidgets('hides edge handles while a side panel is open', (
      tester,
    ) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: StageHandleStrip(
              panel: StagePanel.waterQuality,
              isLeft: false,
              icon: Icons.science_rounded,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);

      container.read(stageProvider.notifier).toggle(StagePanel.waterQuality);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_left), findsNothing);
    });
  });

  group('BottomSheetPanel snap contract', () {
    test('supports closed, peek, half, and full snap states', () {
      expect(BottomSheetPanel.kSnapClosed, closeTo(0.055, 0.005));
      expect(
        BottomSheetPanel.kSnapPeek,
        greaterThan(BottomSheetPanel.kSnapClosed),
      );
      expect(
        BottomSheetPanel.kSnapHalf,
        greaterThan(BottomSheetPanel.kSnapPeek),
      );
      expect(
        BottomSheetPanel.kSnapFull,
        greaterThan(BottomSheetPanel.kSnapHalf),
      );
      expect(BottomSheetPanel.kSnapSizes, <double>[
        BottomSheetPanel.kSnapClosed,
        BottomSheetPanel.kSnapPeek,
        BottomSheetPanel.kSnapHalf,
        BottomSheetPanel.kSnapFull,
      ]);
    });

    testWidgets('starts closed with only the handle area exposed', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  BottomSheetPanel(
                    progressContent: SizedBox(),
                    tanksContent: SizedBox(),
                    todayContent: SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final sheet = tester.widget<DraggableScrollableSheet>(
        find.byType(DraggableScrollableSheet),
      );
      expect(sheet.initialChildSize, BottomSheetPanel.kSnapClosed);
      expect(sheet.minChildSize, BottomSheetPanel.kSnapClosed);
      expect(sheet.snapSizes, BottomSheetPanel.kSnapSizes);
    });
  });
}
