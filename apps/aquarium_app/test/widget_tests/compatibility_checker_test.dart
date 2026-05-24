// Widget tests for CompatibilityCheckerScreen.
//
// Run: flutter test test/widget_tests/compatibility_checker_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/compatibility_checker_screen.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/models/models.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap({List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(home: CompatibilityCheckerScreen()),
  );
}

Widget _wrapWithGestureInset({List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(
          padding: EdgeInsets.only(bottom: 34),
          viewPadding: EdgeInsets.only(bottom: 34),
        ),
        child: const CompatibilityCheckerScreen(),
      ),
    ),
  );
}

/// Mock tanks provider that returns no tanks (empty list).
final _emptyTanksProvider = tanksProvider.overrideWith((ref) async => []);

final _smallTankProvider = tanksProvider.overrideWith(
  (ref) async => [
    Tank(
      id: 'small-tank',
      name: 'Small Tank',
      type: TankType.freshwater,
      volumeLitres: 40,
      startDate: DateTime(2026, 1, 1),
      targets: WaterTargets.freshwaterTropical(),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  ],
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CompatibilityCheckerScreen — smoke', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap(overrides: [_emptyTanksProvider]));
      await tester.pump();
      expect(find.byType(CompatibilityCheckerScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap(overrides: [_emptyTanksProvider]));
      await tester.pump();
      expect(find.text('Compatibility Checker'), findsOneWidget);
    });

    testWidgets('shows search field', (tester) async {
      await tester.pumpWidget(_wrap(overrides: [_emptyTanksProvider]));
      await tester.pump();
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search fish to add...'), findsOneWidget);
    });

    testWidgets('shows empty state prompt', (tester) async {
      await tester.pumpWidget(_wrap(overrides: [_emptyTanksProvider]));
      await tester.pump();
      expect(find.text('Add Fish to Check'), findsOneWidget);
      expect(
        find.text('Search and add fish above to check if they\'re compatible'),
        findsOneWidget,
      );
    });
  });

  group('CompatibilityCheckerScreen — search', () {
    testWidgets('typing in search field updates state', (tester) async {
      await tester.pumpWidget(_wrap(overrides: [_emptyTanksProvider]));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Neon');
      // Wait for the 300ms debounce to fire before checking results.
      await tester.pump(const Duration(milliseconds: 350));

      // Search results should appear if species match
      // The database has Neon Tetra — results should show
      final listTiles = find.byType(ListTile);
      // At minimum, the list should contain search results
      expect(listTiles.evaluate().length, greaterThan(0));
    });

    testWidgets('tapping a search result adds species as chip', (tester) async {
      await tester.pumpWidget(_wrap(overrides: [_emptyTanksProvider]));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Neon');
      await tester.pump(const Duration(milliseconds: 350));

      // Find and tap the first search result (add button)
      final addButtons = find.byIcon(Icons.add_circle_outline);
      if (addButtons.evaluate().isNotEmpty) {
        await tester.tap(addButtons.first);
        await tester.pump();

        // A chip with species name should appear
        expect(find.byType(Chip), findsWidgets);
      }
    });
  });

  group('CompatibilityCheckerScreen — species management', () {
    testWidgets('removing a species chip updates the list', (tester) async {
      await tester.pumpWidget(_wrap(overrides: [_emptyTanksProvider]));
      await tester.pump();

      // Add a species
      await tester.enterText(find.byType(TextField), 'Neon');
      await tester.pump(const Duration(milliseconds: 350));

      final addButtons = find.byIcon(Icons.add_circle_outline);
      if (addButtons.evaluate().isNotEmpty) {
        await tester.tap(addButtons.first);
        await tester.pump();

        final chipsBefore = find.byType(Chip).evaluate().length;
        expect(chipsBefore, greaterThan(0));

        // Remove via the delete icon on the chip
        final deleteIcons = find.byIcon(Icons.close);
        if (deleteIcons.evaluate().isNotEmpty) {
          await tester.tap(deleteIcons.first);
          await tester.pump();

          final chipsAfter = find.byType(Chip).evaluate().length;
          expect(chipsAfter, lessThan(chipsBefore));
        }
      }
    });
  });

  group('CompatibilityCheckerScreen — verdict display', () {
    testWidgets('verdict card appears with 2+ species', (tester) async {
      await tester.pumpWidget(_wrap(overrides: [_emptyTanksProvider]));
      await tester.pump();

      // Add first species
      await tester.enterText(find.byType(TextField), 'Neon');
      await tester.pump(const Duration(milliseconds: 350));
      final addButtons1 = find.byIcon(Icons.add_circle_outline);
      if (addButtons1.evaluate().isEmpty) return;
      await tester.tap(addButtons1.first);
      await tester.pump();

      // Add second species
      await tester.enterText(find.byType(TextField), 'Guppy');
      await tester.pump(const Duration(milliseconds: 350));
      final addButtons2 = find.byIcon(Icons.add_circle_outline);
      if (addButtons2.evaluate().isEmpty) return;
      await tester.tap(addButtons2.first);
      await tester.pump();

      // Should show verdict: Good Match, Proceed with Caution, or Not Recommended
      final verdicts = [
        'Good Match!',
        'Proceed with Caution',
        'Not Recommended',
      ];
      expect(
        find.byWidgetPredicate((widget) {
          if (widget is! Text) return false;
          return verdicts.contains(widget.data);
        }),
        findsOneWidget,
        reason: 'Expected a verdict card after adding 2 species',
      );
    });

    testWidgets('recommended setup section shows with 2+ species', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(overrides: [_emptyTanksProvider]));
      await tester.pump();

      // Add two species
      for (final query in ['Neon', 'Guppy']) {
        await tester.enterText(find.byType(TextField), query);
        await tester.pump(const Duration(milliseconds: 350));
        final addBtn = find.byIcon(Icons.add_circle_outline);
        if (addBtn.evaluate().isEmpty) return;
        await tester.tap(addBtn.first);
        await tester.pump();
      }

      // Should show "Recommended Setup" header
      await tester.drag(find.byType(ListView).last, const Offset(0, -300));
      await tester.pump();
      expect(find.text('Recommended Setup'), findsOneWidget);
    });

    testWidgets('Betta and Neon Tetra are shown as a cautious match', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(overrides: [_emptyTanksProvider]));
      await tester.pump();

      for (final query in ['Betta', 'Neon Tetra']) {
        await tester.enterText(find.byType(TextField), query);
        await tester.pump(const Duration(milliseconds: 350));
        final addBtn = find.byIcon(Icons.add_circle_outline);
        expect(addBtn, findsWidgets);
        await tester.tap(addBtn.first);
        await tester.pump();
      }

      expect(find.text('Proceed with Caution'), findsOneWidget);
      expect(find.textContaining('Betta temperament varies'), findsOneWidget);
    });

    testWidgets('single-species tank warnings do not render dangling plus', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(overrides: [_smallTankProvider]));
      await tester.pump();

      for (final query in ['Common Goldfish', 'Neon Tetra']) {
        await tester.enterText(find.byType(TextField), query);
        await tester.pump(const Duration(milliseconds: 350));
        final addBtn = find.byIcon(Icons.add_circle_outline);
        expect(addBtn, findsWidgets);
        await tester.tap(addBtn.first);
        await tester.pump();
      }

      expect(find.text('Common Goldfish +'), findsNothing);
      expect(find.text('Common Goldfish'), findsWidgets);
    });

    testWidgets('tank-size warnings use plain ASCII separator copy', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(overrides: [_smallTankProvider]));
      await tester.pump();

      for (final query in ['Common Goldfish', 'Neon Tetra']) {
        await tester.enterText(find.byType(TextField), query);
        await tester.pump(const Duration(milliseconds: 350));
        final addBtn = find.byIcon(Icons.add_circle_outline);
        expect(addBtn, findsWidgets);
        await tester.tap(addBtn.first);
        await tester.pump();
      }

      await tester.drag(find.byType(ListView).last, const Offset(0, -300));
      await tester.pump();

      final warningTexts = tester
          .widgetList<Text>(find.byType(Text))
          .map((widget) => widget.data ?? '')
          .where((text) => text.contains('requires at least'))
          .toList();

      expect(warningTexts, isNotEmpty);
      for (final text in warningTexts) {
        expect(text, isNot(contains(String.fromCharCode(0x2014))));
        expect(text, isNot(contains(String.fromCharCode(0x2113))));
      }
    });

    testWidgets('results list stays above gesture navigation', (tester) async {
      const viewport = Size(390, 844);
      await tester.binding.setSurfaceSize(viewport);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _wrapWithGestureInset(overrides: [_emptyTanksProvider]),
      );
      await tester.pump();

      for (final query in ['Neon', 'Guppy']) {
        await tester.enterText(find.byType(TextField), query);
        await tester.pump(const Duration(milliseconds: 350));
        final addBtn = find.byIcon(Icons.add_circle_outline);
        expect(addBtn, findsWidgets);
        await tester.tap(addBtn.first);
        await tester.pump();
      }

      final listViewRect = tester.getRect(find.byType(ListView).last);
      expect(listViewRect.bottom, lessThanOrEqualTo(viewport.height - 34));
    });
  });

  group('CompatibilityCheckerScreen - validation coverage', () {
    testWidgets('empty selection keeps guidance and no verdict', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(overrides: [_emptyTanksProvider]));
      await tester.pump();

      expect(find.text('Add Fish to Check'), findsOneWidget);
      expect(find.text('Good Match!'), findsNothing);
      expect(find.text('Proceed with Caution'), findsNothing);
      expect(find.text('Not Recommended'), findsNothing);
    });
  });
}
