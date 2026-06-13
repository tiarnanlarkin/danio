// Widget tests for CompatibilityCheckerScreen.
//
// Run: flutter test test/widget_tests/compatibility_checker_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/models/models.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/screens/add_log_screen.dart';
import 'package:danio/screens/compatibility_checker_screen.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/theme/app_theme.dart';
import 'package:danio/utils/navigation_throttle.dart';

Widget _wrap({
  List<Override> overrides = const [],
  String? tankId,
  InMemoryStorageService? storage,
}) {
  return ProviderScope(
    overrides: [
      if (storage != null) storageServiceProvider.overrideWithValue(storage),
      ...overrides,
    ],
    child: MaterialApp(home: CompatibilityCheckerScreen(tankId: tankId)),
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

Tank _makeTank({String id = 'tank-1', double volumeLitres = 72}) => Tank(
  id: id,
  name: 'Test Tank',
  type: TankType.freshwater,
  volumeLitres: volumeLitres,
  startDate: DateTime(2026, 1, 1),
  targets: WaterTargets.freshwaterTropical(),
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

Future<void> _addSpecies(WidgetTester tester, String query) async {
  await tester.enterText(find.byType(TextField), query);
  await tester.pump(const Duration(milliseconds: 350));
  final addBtn = find.byIcon(Icons.add_circle_outline);
  expect(addBtn, findsWidgets);
  await tester.tap(addBtn.first);
  await tester.pump();
}

Future<void> _clearStorage() async {
  final storage = InMemoryStorageService();
  final tanks = await storage.getAllTanks();
  await storage.deleteAllTanks(tanks.map((tank) => tank.id).toList());
}

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

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    NavigationThrottle.reset();
    await _clearStorage();
  });

  group('CompatibilityCheckerScreen - smoke', () {
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

  group('CompatibilityCheckerScreen - search', () {
    testWidgets('typing in search field updates state', (tester) async {
      await tester.pumpWidget(_wrap(overrides: [_emptyTanksProvider]));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Neon');
      await tester.pump(const Duration(milliseconds: 350));

      final listTiles = find.byType(ListTile);
      expect(listTiles.evaluate().length, greaterThan(0));
    });

    testWidgets('tapping a search result adds species as chip', (tester) async {
      await tester.pumpWidget(_wrap(overrides: [_emptyTanksProvider]));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Neon');
      await tester.pump(const Duration(milliseconds: 350));

      final addButtons = find.byIcon(Icons.add_circle_outline);
      if (addButtons.evaluate().isNotEmpty) {
        await tester.tap(addButtons.first);
        await tester.pump();

        expect(find.byType(Chip), findsWidgets);
        final chip = tester.widget<Chip>(find.byType(Chip).first);
        expect((chip.label as Text).style?.color, AppColors.textPrimary);
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller?.text,
          isEmpty,
        );
      }
    });
  });

  group('CompatibilityCheckerScreen - species management', () {
    testWidgets('removing a species chip updates the list', (tester) async {
      await tester.pumpWidget(_wrap(overrides: [_emptyTanksProvider]));
      await tester.pump();

      await _addSpecies(tester, 'Neon');

      final chipsBefore = find.byType(Chip).evaluate().length;
      expect(chipsBefore, greaterThan(0));

      final deleteIcons = find.byIcon(Icons.close);
      if (deleteIcons.evaluate().isNotEmpty) {
        await tester.tap(deleteIcons.first);
        await tester.pump();

        final chipsAfter = find.byType(Chip).evaluate().length;
        expect(chipsAfter, lessThan(chipsBefore));
      }
    });
  });

  group('CompatibilityCheckerScreen - verdict display', () {
    testWidgets('verdict card appears with 2+ species', (tester) async {
      await tester.pumpWidget(_wrap(overrides: [_emptyTanksProvider]));
      await tester.pump();

      await _addSpecies(tester, 'Neon');
      await _addSpecies(tester, 'Guppy');

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

      await _addSpecies(tester, 'Neon');
      await _addSpecies(tester, 'Guppy');

      await tester.drag(find.byType(ListView).last, const Offset(0, -300));
      await tester.pump();
      expect(find.text('Recommended Setup'), findsOneWidget);
    });

    testWidgets('guided action opens an observation log with verdict summary', (
      tester,
    ) async {
      final storage = InMemoryStorageService();
      await storage.saveTank(_makeTank());

      await tester.pumpWidget(_wrap(tankId: 'tank-1', storage: storage));
      await tester.pump();

      await _addSpecies(tester, 'Neon');
      await _addSpecies(tester, 'Guppy');

      await tester.scrollUntilVisible(
        find.text('Log compatibility check'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.ensureVisible(find.text('Log compatibility check'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Log compatibility check'));
      await tester.pumpAndSettle();

      expect(find.byType(AddLogScreen), findsOneWidget);
      expect(find.text('Observation'), findsWidgets);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is TextFormField &&
              (widget.initialValue ?? '').contains('Compatibility check') &&
              (widget.initialValue ?? '').contains('Verdict:') &&
              (widget.initialValue ?? '').contains('Neon Tetra') &&
              (widget.initialValue ?? '').contains('Guppy'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Betta and Neon Tetra are shown as a cautious match', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(overrides: [_emptyTanksProvider]));
      await tester.pump();

      await _addSpecies(tester, 'Betta');
      await _addSpecies(tester, 'Neon Tetra');

      expect(find.text('Proceed with Caution'), findsOneWidget);
      expect(find.textContaining('Betta temperament varies'), findsOneWidget);
    });

    testWidgets('single-species tank warnings do not render dangling plus', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(overrides: [_smallTankProvider]));
      await tester.pump();

      await _addSpecies(tester, 'Common Goldfish');
      await _addSpecies(tester, 'Neon Tetra');

      expect(find.text('Common Goldfish +'), findsNothing);
      expect(find.text('Common Goldfish'), findsWidgets);
    });

    testWidgets('tank-size warnings use plain ASCII separator copy', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(overrides: [_smallTankProvider]));
      await tester.pump();

      await _addSpecies(tester, 'Common Goldfish');
      await _addSpecies(tester, 'Neon Tetra');

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

      await _addSpecies(tester, 'Neon');
      await _addSpecies(tester, 'Guppy');

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
