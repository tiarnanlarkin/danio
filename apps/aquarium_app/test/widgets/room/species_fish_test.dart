import 'package:danio/widgets/room/species_fish.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpeciesFish', () {
    Widget wrap(Widget child, {bool reduceMotion = false}) {
      return MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 200,
              child: Stack(children: [child]),
            ),
          ),
        ),
      );
    }

    testWidgets('renders without exceptions', (tester) async {
      await tester.pumpWidget(wrap(const SpeciesFish(
        speciesId: 'neon_tetra',
        tankWidth: 300,
        tankHeight: 200,
      )));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('fish stays within tank bounds over 5 seconds', (tester) async {
      await tester.pumpWidget(wrap(const SpeciesFish(
        speciesId: 'neon_tetra',
        tankWidth: 300,
        tankHeight: 200,
      )));
      for (int i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        final positioned = tester.widget<Positioned>(find.byType(Positioned));
        // Bounds include margin for bob amplitude (default 10px) + glass margin
        // + sprite size overhang — clamp is generous because the engine centers
        // _position on the fish and the Positioned.left is dx - spriteSize/2.
        expect(positioned.left!, inInclusiveRange(-40, 340));
        expect(positioned.top!, inInclusiveRange(-40, 240));
      }
    });

    testWidgets('reduced motion freezes fish', (tester) async {
      await tester.pumpWidget(wrap(
        const SpeciesFish(
          speciesId: 'neon_tetra',
          tankWidth: 300,
          tankHeight: 200,
        ),
        reduceMotion: true,
      ));
      await tester.pump(const Duration(milliseconds: 100));
      final pos1 = tester.widget<Positioned>(find.byType(Positioned)).left!;
      await tester.pump(const Duration(seconds: 5));
      final pos2 = tester.widget<Positioned>(find.byType(Positioned)).left!;
      expect(pos1, equals(pos2));
    });

    testWidgets('disposes cleanly without late-callback exception', (tester) async {
      await tester.pumpWidget(wrap(const SpeciesFish(
        speciesId: 'neon_tetra',
        tankWidth: 300,
        tankHeight: 200,
      )));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });
  });
}
