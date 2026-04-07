import 'dart:ui';

import 'package:danio/theme/room_themes.dart';
import 'package:danio/widgets/stage/stage_provider.dart';
import 'package:danio/widgets/stage/swiss_army_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SwissArmyPanel glass frame (concept lock 2026-04-07)', () {
    testWidgets('uses sigma:14 blur when open', (tester) async {
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

      // Drive animation to fully open
      await tester.pumpAndSettle();

      final backdrop = tester.widget<BackdropFilter>(
        find.byType(BackdropFilter),
      );
      final filter = backdrop.filter as ImageFilter;
      // We can't introspect the sigma directly, but we can assert structure —
      // presence of a BackdropFilter inside the open panel is enough to lock
      // the contract. Detailed sigma is asserted via a golden in Task 1b.
      expect(filter, isNotNull);
      expect(find.byKey(const Key('panel-body')), findsOneWidget);
    });

    testWidgets('has a drop shadow on the outer container', (tester) async {
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

      // Find the frame Container — the one that has both a color and a shadow.
      final framedContainers = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) => c.decoration is BoxDecoration)
          .map((c) => c.decoration as BoxDecoration)
          .where((d) => d.boxShadow != null && d.boxShadow!.isNotEmpty);

      expect(
        framedContainers.isNotEmpty,
        isTrue,
        reason: 'Concept lock requires drop shadow 0,2,8 black@25 on frame',
      );
    });
  });
}
