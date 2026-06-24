// Widget tests for SubstrateGuideScreen.
//
// Run: flutter test test/widget_tests/substrate_guide_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/substrate_guide_screen.dart';
import 'package:danio/widgets/core/app_card.dart';

Widget _wrap() => const MaterialApp(home: SubstrateGuideScreen());

void main() {
  group('SubstrateGuideScreen rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(SubstrateGuideScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Substrate Guide'), findsOneWidget);
    });

    testWidgets('shows Why Substrate Matters intro card', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Why Substrate Matters'), findsOneWidget);
    });

    testWidgets('shows Substrate Types section heading', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Substrate Types'), findsOneWidget);
    });

    testWidgets('shows Gravel substrate card', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Gravel'), findsOneWidget);
    });

    testWidgets('shows source-safe substrate details and tips', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.text('Gravel'));
      await tester.pumpAndSettle();

      expect(find.text('- Cheap'), findsOneWidget);
      expect(find.text('- No nutrients for plants'), findsOneWidget);
      expect(find.textContaining('\u2022'), findsNothing);

      await tester.scrollUntilVisible(
        find.text('Pro Tips'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(
        find.text(
          'Calculate amount: L x W x depth (cm) / 1000 = litres needed',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('\u00d7'), findsNothing);
      expect(find.textContaining('\u00f7'), findsNothing);
    });

    testWidgets('tablet keeps substrate guide surfaces readable', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await tester.pump();

      final introCard = find
          .ancestor(
            of: find.text('Why Substrate Matters'),
            matching: find.byType(AppCard),
          )
          .first;
      final gravelCard = find
          .ancestor(of: find.text('Gravel'), matching: find.byType(Card))
          .first;
      final introWidth = tester.getSize(introCard).width;
      final gravelWidth = tester.getSize(gravelCard).width;

      await tester.scrollUntilVisible(
        find.text('High-Tech Planted'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final tankTypeCard = find
          .ancestor(
            of: find.text('High-Tech Planted'),
            matching: find.byType(Card),
          )
          .first;
      final tankTypeWidth = tester.getSize(tankTypeCard).width;

      await tester.scrollUntilVisible(
        find.text('Dirted Tank (Walstad Method)'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final layerCard = find
          .ancestor(
            of: find.text('Dirted Tank (Walstad Method)'),
            matching: find.byType(AppCard),
          )
          .first;
      final layerWidth = tester.getSize(layerCard).width;

      await tester.scrollUntilVisible(
        find.text('Pro Tips'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final tipsCard = find
          .ancestor(
            of: find.text('Pro Tips'),
            matching: find.byType(AppCard),
          )
          .first;

      expect(introWidth, lessThanOrEqualTo(720));
      expect(gravelWidth, lessThanOrEqualTo(720));
      expect(tankTypeWidth, lessThanOrEqualTo(720));
      expect(layerWidth, lessThanOrEqualTo(720));
      expect(tester.getSize(tipsCard).width, lessThanOrEqualTo(720));
    });
  });
}
