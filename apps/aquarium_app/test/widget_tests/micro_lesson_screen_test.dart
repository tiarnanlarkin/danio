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

    testWidgets('reveals Got it action after answering', (tester) async {
      tester.view.physicalSize = const Size(411, 960);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(level: ExperienceLevel.beginner));
      await _advance(tester);

      await tester.ensureVisible(find.text('Uncycled water'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Uncycled water'));
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();

      final gotIt = find.textContaining('Got it');
      expect(gotIt, findsOneWidget);
      final gotItCenter = tester.getCenter(gotIt);
      expect(gotItCenter.dy, greaterThan(0));
      expect(gotItCenter.dy, lessThan(960));
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
