// Widget tests for TankStatusScreen.
//
// Run: flutter test test/widget_tests/tank_status_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/onboarding/tank_status_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap({ValueChanged<String>? onSelected}) {
  return MaterialApp(
    home: TankStatusScreen(onSelected: onSelected ?? (_) {}),
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

  group('TankStatusScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(TankStatusScreen), findsOneWidget);
    });

    testWidgets('shows scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows all three status option labels', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Thinking about getting one'), findsOneWidget);
      expect(find.text('Setting it up'), findsOneWidget);
      expect(find.text('Already up and running'), findsOneWidget);
    });

    testWidgets('shows three status card emojis', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('🏠'), findsOneWidget);
      expect(find.text('🔧'), findsOneWidget);
      expect(find.text('🐟'), findsOneWidget);
    });

    testWidgets('shows GestureDetectors for tap targets', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('selecting a status and tapping Continue calls onSelected', (
      tester,
    ) async {
      String? selected;
      await tester.pumpWidget(_wrap(onSelected: (value) => selected = value));
      await _advance(tester);

      await tester.tap(find.text('Already up and running'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(selected, 'active');
    });
  });
}
