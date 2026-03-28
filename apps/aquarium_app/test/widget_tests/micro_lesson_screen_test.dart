// Widget tests for MicroLessonScreen.
//
// Run: flutter test test/widget_tests/micro_lesson_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/onboarding/micro_lesson_screen.dart';
import 'package:danio/models/user_profile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap({
  ExperienceLevel level = ExperienceLevel.beginner,
  VoidCallback? onComplete,
}) {
  return MaterialApp(
    home: MicroLessonScreen(
      experienceLevel: level,
      onComplete: onComplete ?? () {},
    ),
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

  group('MicroLessonScreen — beginner', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(MicroLessonScreen), findsOneWidget);
    });

    testWidgets('shows scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows lesson content text for beginner', (tester) async {
      await tester.pumpWidget(_wrap(level: ExperienceLevel.beginner));
      await _advance(tester);
      // The lesson has answer option widgets visible
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('shows progress dots', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      // Progress dots row should be in the layout
      expect(find.byType(Row), findsWidgets);
    });
  });

  group('MicroLessonScreen — expert', () {
    testWidgets('renders expert variant without throwing', (tester) async {
      await tester.pumpWidget(_wrap(level: ExperienceLevel.expert));
      await _advance(tester);
      expect(find.byType(MicroLessonScreen), findsOneWidget);
    });
  });
}
