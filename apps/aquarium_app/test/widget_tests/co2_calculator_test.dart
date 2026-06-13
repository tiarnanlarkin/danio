// Widget tests for Co2CalculatorScreen.
//
// Run: flutter test test/widget_tests/co2_calculator_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/models/models.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/screens/add_log_screen.dart';
import 'package:danio/screens/co2_calculator_screen.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/utils/navigation_throttle.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _now = DateTime.now();

Tank _makeTank({String id = 'tank-1'}) => Tank(
  id: id,
  name: 'Test Tank',
  type: TankType.freshwater,
  volumeLitres: 100,
  startDate: _now,
  targets: WaterTargets.freshwaterTropical(),
  createdAt: _now,
  updatedAt: _now,
);

Widget _wrap({String? tankId, InMemoryStorageService? storage}) {
  return ProviderScope(
    overrides: [
      if (storage != null) storageServiceProvider.overrideWithValue(storage),
    ],
    child: MaterialApp(home: Co2CalculatorScreen(tankId: tankId)),
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
    NavigationThrottle.reset();
    await _clearStorage();
  });

  group('Co2CalculatorScreen - rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(Co2CalculatorScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('CO2 Calculator'), findsOneWidget);
    });

    testWidgets('shows pH and KH input fields', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('pH'), findsOneWidget);
      expect(find.text('KH (dKH)'), findsOneWidget);
    });

    testWidgets('shows CO2 result card', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Estimated CO2 Level'), findsOneWidget);
    });

    testWidgets('shows reference chart', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      // The reference chart contains these range labels
      expect(find.text('10-20 ppm'), findsOneWidget);
      expect(find.text('20-30 ppm'), findsOneWidget);
      expect(find.text('30-40 ppm'), findsOneWidget);
    });
  });

  group('Co2CalculatorScreen - calculation', () {
    testWidgets('default values produce a CO2 reading', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      // Default: pH=7.0, KH=4 -> CO2 = 3 * 4 * 10^(7-7) = 12 ppm -> Low
      expect(find.textContaining('ppm'), findsWidgets);
      // "Low" appears in both the result card and reference chart
      expect(find.text('Low'), findsWidgets);
    });

    testWidgets('optimal range shows "Optimal" status', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      // pH 6.6, KH 4 -> CO2 = 3 * 4 * 10^(0.4) about 30.2 ppm -> Optimal
      final phField = find.widgetWithText(TextField, '7.0');
      await tester.enterText(phField, '6.6');
      await tester.pump();

      // "Optimal" appears once (only in result, not reference chart labels)
      expect(find.text('Optimal'), findsWidgets);
    });

    testWidgets('dangerous level shows "Dangerous" status', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      // pH 6.0, KH 8 -> CO2 = 3 * 8 * 10^1 = 240 ppm -> Dangerous
      final phField = find.widgetWithText(TextField, '7.0');
      await tester.enterText(phField, '6.0');
      await tester.pump();

      final khField = find.widgetWithText(TextField, '4');
      await tester.enterText(khField, '8');
      await tester.pump();

      // "Dangerous" appears in result card and reference chart row
      expect(find.text('Dangerous'), findsWidgets);
    });

    testWidgets('changing pH updates result in real time', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      // Default pH 7.0 -> Low (12 ppm)
      expect(find.text('Low'), findsWidgets);

      // Change to pH 7.2 with same KH 4
      // CO2 = 3 * 4 * 10^(-0.2) about 7.6 ppm -> Too Low
      final phField = find.widgetWithText(TextField, '7.0');
      await tester.enterText(phField, '7.2');
      await tester.pump();

      expect(find.text('Too Low'), findsWidgets);
    });

    testWidgets('guided action opens an observation log with CO2 summary', (
      tester,
    ) async {
      final storage = InMemoryStorageService();
      await storage.saveTank(_makeTank());

      await tester.pumpWidget(_wrap(tankId: 'tank-1', storage: storage));
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Log this CO2 note'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Log this CO2 note'));
      await tester.pumpAndSettle();

      expect(find.byType(AddLogScreen), findsOneWidget);
      expect(find.text('Observation'), findsWidgets);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is TextFormField &&
              (widget.initialValue ?? '').contains('12.0 ppm'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('empty pH input clears result without crashing', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.enterText(find.widgetWithText(TextField, '7.0'), '');
      await tester.pump();

      expect(find.text('-'), findsOneWidget);
      expect(find.text('Enter values'), findsOneWidget);
    });
  });

  group('Co2CalculatorScreen - edge cases', () {
    testWidgets('very large KH still calculates', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      final khField = find.widgetWithText(TextField, '4');
      await tester.enterText(khField, '50');
      await tester.pump();

      // Should still show a value, not an error
      expect(find.textContaining('ppm'), findsWidgets);
      expect(find.text('Dangerous'), findsWidgets);
    });

    testWidgets('out of range pH shows validation guidance', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.enterText(find.widgetWithText(TextField, '7.0'), '15');
      await tester.pump();

      expect(find.text('pH must be between 0.1 and 14.0'), findsOneWidget);
      expect(find.text('Enter values'), findsOneWidget);
    });

    testWidgets('shows info card about the calculator', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(
        find.textContaining(
          'Calculate dissolved CO2 from your pH and KH readings',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows drop checker colours section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      // Scroll down - the screen uses ListView.builder
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pump();

      // Should find drop checker labels
      expect(find.text('Blue'), findsOneWidget);
      expect(find.text('Green'), findsOneWidget);
      expect(find.text('Yellow'), findsOneWidget);
    });

    testWidgets('shows tips section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.drag(find.byType(ListView), const Offset(0, -1200));
      await tester.pump();

      // Tips contain bullet points with advice
      expect(
        find.textContaining('Measure pH at the same time each day'),
        findsOneWidget,
      );
    });
  });
}
