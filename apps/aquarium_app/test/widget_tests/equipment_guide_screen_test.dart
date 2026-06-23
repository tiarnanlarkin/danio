// Widget tests for EquipmentGuideScreen.
//
// Run: flutter test test/widget_tests/equipment_guide_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/equipment_guide_screen.dart';

Widget _wrap() => const MaterialApp(home: EquipmentGuideScreen());

void main() {
  group('EquipmentGuideScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(EquipmentGuideScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Equipment Guide'), findsOneWidget);
    });

    testWidgets('shows Filtration category', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Filtration'), findsOneWidget);
    });

    testWidgets('shows Heating category', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Heating'), findsOneWidget);
    });

    testWidgets('shows Lighting category', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.scrollUntilVisible(
        find.text('Lighting'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      expect(find.text('Lighting'), findsOneWidget);
    });

    testWidgets('tablet keeps equipment category cards readable', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await tester.pump();

      final hobCard = find
          .ancestor(
            of: find.text('Hang-On-Back (HOB) Filter'),
            matching: find.byType(Card),
          )
          .first;
      final hobWidth = tester.getSize(hobCard).width;

      await tester.scrollUntilVisible(
        find.text('Heating'),
        700,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final heaterCard = find
          .ancestor(
            of: find.text('Submersible Heater'),
            matching: find.byType(Card),
          )
          .first;

      expect(hobWidth, lessThanOrEqualTo(720));
      expect(tester.getSize(heaterCard).width, lessThanOrEqualTo(720));
    });
  });
}
