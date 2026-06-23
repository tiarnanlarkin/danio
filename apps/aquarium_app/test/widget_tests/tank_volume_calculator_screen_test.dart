// Widget tests for TankVolumeCalculatorScreen.
//
// Run: flutter test test/widget_tests/tank_volume_calculator_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/models/models.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/screens/tank_volume_calculator_screen.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/theme/app_theme.dart';
import 'package:danio/widgets/core/app_card.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _now = DateTime.now();

Tank _makeTank({String id = 'tank-1', double volumeLitres = 40}) => Tank(
  id: id,
  name: 'Test Tank',
  type: TankType.freshwater,
  volumeLitres: volumeLitres,
  startDate: _now,
  targets: WaterTargets.freshwaterTropical(),
  createdAt: _now,
  updatedAt: _now,
);

Widget _wrap({String? tankId, InMemoryStorageService? storage}) {
  final child = MaterialApp(home: TankVolumeCalculatorScreen(tankId: tankId));

  return ProviderScope(
    overrides: [
      if (storage != null) storageServiceProvider.overrideWithValue(storage),
    ],
    child: child,
  );
}

Future<void> _clearStorage() async {
  final storage = InMemoryStorageService();
  final tanks = await storage.getAllTanks();
  await storage.deleteAllTanks(tanks.map((tank) => tank.id).toList());
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await _clearStorage();
  });

  group('TankVolumeCalculatorScreen - rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(TankVolumeCalculatorScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Tank Volume Calculator'), findsOneWidget);
    });

    testWidgets('shows shape selector options', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Shape selector chips/buttons
      expect(find.text('Rectangular'), findsOneWidget);
    });

    testWidgets('shows dimension input fields for rectangular', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Rectangular is the default - should show length/width/height
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('shows metric/imperial toggle', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Metric toggle text
      expect(find.text('cm'), findsWidgets);
    });

    testWidgets('unselected selector chips use readable label color', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      final imperialChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Imperial (in)'),
      );

      expect(imperialChip.labelStyle?.color, AppColors.textPrimary);
    });

    testWidgets('tablet keeps inputs and result cards readable', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await tester.pump();

      final fields = find.byType(TextField);
      expect(tester.getSize(fields.first).width, lessThanOrEqualTo(720));

      final promptCard = find
          .ancestor(
            of: find.text('Enter dimensions above to calculate'),
            matching: find.byType(AppCard),
          )
          .first;
      expect(tester.getSize(promptCard).width, lessThanOrEqualTo(720));

      await tester.enterText(fields.at(0), '60');
      await tester.enterText(fields.at(1), '30');
      await tester.enterText(fields.at(2), '30');
      await tester.pump();

      final resultCard = find
          .ancestor(
            of: find.text('Estimated Volume'),
            matching: find.byType(AppCard),
          )
          .first;
      expect(tester.getSize(resultCard).width, lessThanOrEqualTo(720));
    });
  });

  group('TankVolumeCalculatorScreen - validation and calculation', () {
    testWidgets('valid rectangular dimensions show calculated volume', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '60');
      await tester.enterText(fields.at(1), '30');
      await tester.enterText(fields.at(2), '30');
      await tester.pump();

      expect(find.text('Estimated Volume'), findsOneWidget);
      expect(find.text('54.0 L'), findsOneWidget);
    });

    testWidgets('guided action applies calculated volume to tank profile', (
      tester,
    ) async {
      final storage = InMemoryStorageService();
      await storage.saveTank(_makeTank());

      await tester.pumpWidget(_wrap(tankId: 'tank-1', storage: storage));
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '60');
      await tester.enterText(fields.at(1), '30');
      await tester.enterText(fields.at(2), '30');
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Apply to tank profile'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Apply to tank profile'));
      await tester.pumpAndSettle();

      final tank = await storage.getTank('tank-1');
      expect(tank?.volumeLitres, 54.0);
      expect(find.textContaining('Updated tank volume'), findsOneWidget);
    });

    testWidgets('zero dimension keeps the empty guidance state', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '0');
      await tester.enterText(fields.at(1), '30');
      await tester.enterText(fields.at(2), '30');
      await tester.pump();

      expect(find.text('Estimated Volume'), findsNothing);
      expect(find.text('Enter dimensions above to calculate'), findsOneWidget);
    });
  });
}
