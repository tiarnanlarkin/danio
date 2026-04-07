import 'package:danio/theme/room_themes.dart';
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
  });
}
