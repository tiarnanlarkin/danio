// Widget tests for LessonScreen.
//
// Run: flutter test test/widget_tests/lesson_screen_test.dart
//
// LessonScreen depends on spacedRepetitionProvider (which triggers
// NotificationService), so we override it with a fake notifier.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/lesson_screen.dart';
import 'package:danio/models/learning.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/providers/spaced_repetition_provider.dart';
import 'package:danio/models/spaced_repetition.dart';

// ---------------------------------------------------------------------------
// Fake SpacedRepetitionNotifier (avoids NotificationService init)
// ---------------------------------------------------------------------------

class _FakeSrNotifier extends StateNotifier<SpacedRepetitionState>
    implements SpacedRepetitionNotifier {
  _FakeSrNotifier()
      : super(SpacedRepetitionState(
          cards: const [],
          stats: ReviewStats(
            totalCards: 0,
            dueCards: 0,
            weakCards: 0,
            masteredCards: 0,
            averageStrength: 0.0,
            cardsByMastery: const {},
            reviewsToday: 0,
            currentStreak: 0,
          ),
        ));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

final _testLesson = Lesson(
  id: 'lesson-1',
  pathId: 'path-1',
  title: 'The Nitrogen Cycle',
  description: 'Learn about the nitrogen cycle in your aquarium.',
  orderIndex: 1,
  xpReward: 50,
  sections: const [
    LessonSection(
      type: LessonSectionType.text,
      content: 'The nitrogen cycle is the most important concept in fishkeeping.',
    ),
    LessonSection(
      type: LessonSectionType.text,
      content: 'Ammonia is produced by fish waste and uneaten food.',
    ),
  ],
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  SharedPreferences.setMockInitialValues({});
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        return SharedPreferences.getInstance();
      }),
      spacedRepetitionProvider.overrideWith((ref) => _FakeSrNotifier()),
    ],
    child: MaterialApp(
      home: LessonScreen(
        lesson: _testLesson,
        pathTitle: 'Getting Started',
      ),
    ),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(seconds: 1));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LessonScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(LessonScreen), findsOneWidget);
    });

    testWidgets('shows lesson title', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('The Nitrogen Cycle'), findsOneWidget);
    });

    testWidgets('shows scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows lesson content section', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(
        find.textContaining('nitrogen cycle is the most important'),
        findsOneWidget,
      );
    });
  });
}
