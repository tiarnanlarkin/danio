// Widget tests for ExperienceLevelScreen.
//
// Run: flutter test test/widget_tests/experience_level_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/onboarding/experience_level_screen.dart';
import 'package:danio/models/user_profile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap({ValueChanged<ExperienceLevel>? onSelected}) {
  return MaterialApp(
    home: ExperienceLevelScreen(onSelected: onSelected ?? (_) {}),
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

  group('ExperienceLevelScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(ExperienceLevelScreen), findsOneWidget);
    });

    testWidgets('shows headline question', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('How long have you kept fish?'), findsOneWidget);
    });

    testWidgets('shows all three experience options', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Just starting out'), findsOneWidget);
      expect(find.text('A few years in'), findsOneWidget);
      expect(find.text('Pretty experienced'), findsOneWidget);
    });

    testWidgets('shows Continue button (disabled initially)', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('calls onSelected when card tapped and Continue pressed',
        (tester) async {
      ExperienceLevel? chosen;
      await tester.pumpWidget(_wrap(onSelected: (l) => chosen = l));
      await _advance(tester);

      await tester.tap(find.text('Just starting out'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(chosen, ExperienceLevel.beginner);
    });
  });
}
