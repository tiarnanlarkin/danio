// Widget tests for GlossaryScreen.
//
// Run: flutter test test/widget_tests/glossary_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/glossary_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const MaterialApp(
    home: GlossaryScreen(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('GlossaryScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(GlossaryScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Glossary'), findsOneWidget);
    });

    testWidgets('shows search field', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.widgetWithText(TextField, 'Search terms...'), findsOneWidget);
    });

    testWidgets('shows All filter chip', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.widgetWithText(FilterChip, 'All'), findsOneWidget);
    });

    testWidgets('shows glossary entries in the list', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // GlossaryScreen uses Card widgets for each term
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('tablet keeps glossary cards in a readable rail', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(
        tester.getSize(find.byType(Card).first).width,
        lessThanOrEqualTo(720),
      );
    });
  });
}
