// Widget tests for WaterChangeCalculatorScreen.
//
// Run: flutter test test/widget_tests/water_change_calculator_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/models/models.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/screens/add_log_screen.dart';
import 'package:danio/screens/water_change_calculator_screen.dart';
import 'package:danio/services/storage_service.dart';

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
  final child = MaterialApp(home: WaterChangeCalculatorScreen(tankId: tankId));
  if (storage == null) return child;

  return ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
    child: child,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WaterChangeCalculatorScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(WaterChangeCalculatorScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Water Change Calculator'), findsOneWidget);
    });

    testWidgets('shows tank volume input', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Default value '100' for tank volume
      expect(find.widgetWithText(TextField, '100'), findsOneWidget);
    });

    testWidgets('shows nitrate input fields', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Nitrate inputs exist
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('shows nitrate levels section heading', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Nitrate Levels section is always visible above the fold
      expect(find.text('Nitrate Levels'), findsOneWidget);
    });
  });

  group('WaterChangeCalculatorScreen - validation and calculation', () {
    testWidgets('valid nitrate inputs show a water change result', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Water Change Needed'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(find.text('Water Change Needed'), findsOneWidget);
      expect(find.text('57%'), findsOneWidget);
      expect(find.text('57L'), findsOneWidget);
    });

    testWidgets('empty required input shows validation guidance', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.enterText(find.widgetWithText(TextField, '100'), '');
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Please fill in all fields'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(find.text('Water Change Needed'), findsNothing);
      expect(find.text('Please fill in all fields'), findsOneWidget);
    });

    testWidgets('guided action opens a prefilled water-change log', (
      tester,
    ) async {
      final storage = InMemoryStorageService();
      await storage.saveTank(_makeTank());

      await tester.pumpWidget(_wrap(tankId: 'tank-1', storage: storage));
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Guided next step'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(find.text('Log this water change'), findsOneWidget);

      await tester.tap(find.text('Log this water change'));
      await tester.pumpAndSettle();

      expect(find.byType(AddLogScreen), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '57'), findsOneWidget);
    });
  });
}
