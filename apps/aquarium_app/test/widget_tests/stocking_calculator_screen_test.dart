// Widget tests for StockingCalculatorScreen.
//
// Run: flutter test test/widget_tests/stocking_calculator_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/data/species_database.dart';
import 'package:danio/models/models.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/screens/add_log_screen.dart';
import 'package:danio/screens/stocking_calculator_screen.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/utils/navigation_throttle.dart';

final _now = DateTime.now();

Tank _makeTank({String id = 'tank-1', double volumeLitres = 72}) => Tank(
  id: id,
  name: 'Test Tank',
  type: TankType.freshwater,
  volumeLitres: volumeLitres,
  startDate: _now,
  targets: WaterTargets.freshwaterTropical(),
  createdAt: _now,
  updatedAt: _now,
);

Widget _wrap({
  String? tankId,
  double? initialTankVolumeLitres,
  SpeciesInfo? initialSpecies,
  InMemoryStorageService? storage,
}) {
  return ProviderScope(
    overrides: [
      if (storage != null) storageServiceProvider.overrideWithValue(storage),
    ],
    child: MaterialApp(
      home: StockingCalculatorScreen(
        tankId: tankId,
        initialTankVolumeLitres: initialTankVolumeLitres,
        initialSpecies: initialSpecies,
      ),
    ),
  );
}

Widget _wrapWithInitialSpecies() {
  final species = SpeciesDatabase.lookup('Neon Tetra')!;
  return _wrap(initialSpecies: species);
}

Widget _wrapWithBottomInset() {
  return ProviderScope(
    child: MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(390, 844),
          padding: EdgeInsets.only(bottom: 34),
          viewPadding: EdgeInsets.only(bottom: 34),
        ),
        child: const StockingCalculatorScreen(),
      ),
    ),
  );
}

Future<void> _clearStorage() async {
  final storage = InMemoryStorageService();
  final tanks = await storage.getAllTanks();
  await storage.deleteAllTanks(tanks.map((tank) => tank.id).toList());
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    NavigationThrottle.reset();
    await _clearStorage();
  });

  group('StockingCalculatorScreen - rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(StockingCalculatorScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Stocking Calculator'), findsOneWidget);
    });

    testWidgets('shows tank volume input with default value', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.widgetWithText(TextField, '100'), findsOneWidget);
    });

    testWidgets('shows live plants toggle', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('shows search field for species', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('can open with an initial species group', (tester) async {
      await tester.pumpWidget(_wrapWithInitialSpecies());
      await tester.pump();

      expect(find.text('Neon Tetra'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('Search and add fish above'), findsNothing);
    });

    testWidgets('tablet keeps setup, meter, and search readable', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(
        tester.getSize(find.widgetWithText(TextField, '100')).width,
        lessThanOrEqualTo(720),
      );

      final meterCard = find
          .ancestor(
            of: find.text('Lightly Stocked'),
            matching: find.byType(Card),
          )
          .first;
      expect(tester.getSize(meterCard).width, lessThanOrEqualTo(720));

      expect(
        tester.getSize(find.byType(TextField).last).width,
        lessThanOrEqualTo(720),
      );
    });
  });

  group('StockingCalculatorScreen - validation and calculation', () {
    testWidgets('valid setup and species search can add a fish', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.enterText(find.byType(TextField).last, 'Neon');
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.textContaining('Neon'), findsWidgets);

      final addTarget = find.textContaining('Neon').last;
      await tester.tap(addTarget);
      await tester.pump();

      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).last).controller?.text,
        isEmpty,
      );
    });

    testWidgets(
      'guided action opens an observation log with stocking summary',
      (tester) async {
        final storage = InMemoryStorageService();
        await storage.saveTank(_makeTank());
        final neon = SpeciesDatabase.lookup('Neon Tetra')!;

        await tester.pumpWidget(
          _wrap(
            tankId: 'tank-1',
            initialTankVolumeLitres: 72,
            initialSpecies: neon,
            storage: storage,
          ),
        );
        await tester.pump();

        expect(find.widgetWithText(TextField, '72'), findsOneWidget);
        await tester.tap(find.text('Log stocking check'));
        await tester.pumpAndSettle();

        expect(find.byType(AddLogScreen), findsOneWidget);
        expect(find.text('Observation'), findsWidgets);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is TextFormField &&
                (widget.initialValue ?? '').contains('Stocking check') &&
                (widget.initialValue ?? '').contains('Tank volume: 72 L') &&
                (widget.initialValue ?? '').contains('Neon Tetra x 6'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('stocking advice uses an icon instead of raw emoji text', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.enterText(find.byType(TextField).last, 'Neon');
      await tester.pump(const Duration(milliseconds: 350));

      await tester.tap(find.textContaining('Neon').last);
      await tester.pump();

      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

      final emoji = RegExp(
        r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}]',
        unicode: true,
      );
      final renderedText = tester
          .widgetList<Text>(find.byType(Text))
          .map((widget) {
            return widget.data ?? widget.textSpan?.toPlainText() ?? '';
          })
          .where(emoji.hasMatch)
          .toList();

      expect(renderedText, isEmpty);
    });

    testWidgets('zero tank volume shows validation guidance', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.enterText(find.widgetWithText(TextField, '100'), '0');
      await tester.pump();

      expect(find.text('Enter a tank volume greater than 0'), findsOneWidget);
    });

    testWidgets('stocking advice stays above gesture navigation', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrapWithBottomInset());
      await tester.pump();

      await tester.enterText(find.byType(TextField).last, 'Neon');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.tap(find.textContaining('Neon').last);
      await tester.pump();

      final adviceBox = tester.getRect(
        find.text('Good stocking level with room to grow.'),
      );

      expect(adviceBox.bottom, lessThanOrEqualTo(810));
    });
  });
}
