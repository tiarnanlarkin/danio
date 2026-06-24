// Widget tests for HardscapeGuideScreen.
//
// Run: flutter test test/widget_tests/hardscape_guide_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/hardscape_guide_screen.dart';
import 'package:danio/widgets/core/app_card.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const MaterialApp(
    home: HardscapeGuideScreen(),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HardscapeGuideScreen rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(HardscapeGuideScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Hardscape Guide'), findsOneWidget);
    });

    testWidgets('shows intro section about hardscape', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('What is Hardscape?'), findsOneWidget);
    });

    testWidgets('shows Rocks section header', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Rocks'), findsOneWidget);
    });

    testWidgets('shows at least one hardscape type card', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      // Seiryu Stone is the first rock card listed in the screen
      expect(find.text('Seiryu Stone'), findsOneWidget);
    });

    testWidgets('shows source-safe safety notes', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.scrollUntilVisible(
        find.text('Safety Notes'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(
        find.textContaining(
          '- Never use rocks from parking lots or roadsides (contaminated)',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('\u2022'), findsNothing);
    });

    testWidgets('tablet keeps hardscape guide surfaces readable', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await _advance(tester);

      final introCard = find
          .ancestor(
            of: find.text('What is Hardscape?'),
            matching: find.byType(AppCard),
          )
          .first;
      final rockCard = find
          .ancestor(of: find.text('Seiryu Stone'), matching: find.byType(Card))
          .first;
      final introWidth = tester.getSize(introCard).width;
      final rockWidth = tester.getSize(rockCard).width;

      await tester.scrollUntilVisible(
        find.text('Mopani Wood'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final woodCard = find
          .ancestor(of: find.text('Mopani Wood'), matching: find.byType(Card))
          .first;
      final woodWidth = tester.getSize(woodCard).width;

      await tester.scrollUntilVisible(
        find.text('Preparing Rocks'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final prepCard = find
          .ancestor(
            of: find.text('Preparing Rocks'),
            matching: find.byType(AppCard),
          )
          .first;
      final prepWidth = tester.getSize(prepCard).width;

      await tester.scrollUntilVisible(
        find.text('Rule of Thirds'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final designCard = find
          .ancestor(
            of: find.text('Rule of Thirds'),
            matching: find.byType(Card),
          )
          .first;
      final designWidth = tester.getSize(designCard).width;

      await tester.scrollUntilVisible(
        find.text('Safety Notes'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final safetyCard = find
          .ancestor(
            of: find.text('Safety Notes'),
            matching: find.byType(AppCard),
          )
          .first;

      expect(introWidth, lessThanOrEqualTo(720));
      expect(rockWidth, lessThanOrEqualTo(720));
      expect(woodWidth, lessThanOrEqualTo(720));
      expect(prepWidth, lessThanOrEqualTo(720));
      expect(designWidth, lessThanOrEqualTo(720));
      expect(tester.getSize(safetyCard).width, lessThanOrEqualTo(720));
    });
  });
}
