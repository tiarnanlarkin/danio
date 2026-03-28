// Widget tests for HardscapeGuideScreen.
//
// Run: flutter test test/widget_tests/hardscape_guide_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/hardscape_guide_screen.dart';

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

  group('HardscapeGuideScreen — rendering', () {
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
  });
}
