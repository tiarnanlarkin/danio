// Widget tests for LessonScreen.
//
// Run: flutter test test/widget_tests/lesson_screen_test.dart
//
// LessonScreen depends on spacedRepetitionProvider (which triggers
// NotificationService), so we override it with a fake notifier.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/emergency_guide_screen.dart';
import 'package:danio/screens/lesson_screen.dart';
import 'package:danio/models/learning.dart';
import 'package:danio/models/user_profile.dart';
import 'package:danio/providers/inventory_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/providers/spaced_repetition_provider.dart';
import 'package:danio/models/spaced_repetition.dart';
import 'package:danio/utils/navigation_throttle.dart';

// ---------------------------------------------------------------------------
// Fake SpacedRepetitionNotifier (avoids NotificationService init)
// ---------------------------------------------------------------------------

class _FakeSrNotifier extends StateNotifier<SpacedRepetitionState>
    implements SpacedRepetitionNotifier {
  _FakeSrNotifier()
    : super(
        SpacedRepetitionState(
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
        ),
      );

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
      content:
          'The nitrogen cycle is the most important concept in fishkeeping.',
    ),
    LessonSection(
      type: LessonSectionType.text,
      content: 'Ammonia is produced by fish waste and uneaten food.',
    ),
  ],
);

final _quizLesson = Lesson(
  id: 'lesson-quiz',
  pathId: 'path-1',
  title: 'Quiz Lesson',
  description: 'A lesson with a quiz.',
  orderIndex: 1,
  xpReward: 50,
  sections: _testLesson.sections,
  quiz: Quiz(
    id: 'quiz-1',
    lessonId: 'lesson-quiz',
    passingScore: 70,
    bonusXp: 25,
    questions: const [
      QuizQuestion(
        id: 'q1',
        question: 'Which reading must stay at zero in a safe aquarium?',
        options: ['Ammonia', 'Nitrate', 'GH', 'KH'],
        correctIndex: 0,
        explanation:
            'Ammonia should read zero in a stable tank because even small amounts can burn gills and signal that the biofilter is not keeping up.',
      ),
    ],
  ),
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _profileJson({ExperienceLevel level = ExperienceLevel.beginner}) {
  final now = DateTime(2026, 1, 1);
  return jsonEncode(
    UserProfile(
      id: 'profile-1',
      experienceLevel: level,
      createdAt: now,
      updatedAt: now,
    ).toJson(),
  );
}

Widget _wrap({
  Lesson? lesson,
  bool isPracticeMode = false,
  List<Override> overrides = const [],
}) {
  SharedPreferences.setMockInitialValues({});
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        return SharedPreferences.getInstance();
      }),
      spacedRepetitionProvider.overrideWith((ref) => _FakeSrNotifier()),
      ...overrides,
    ],
    child: MaterialApp(
      home: LessonScreen(
        lesson: lesson ?? _testLesson,
        pathTitle: 'Getting Started',
        isPracticeMode: isPracticeMode,
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
    NavigationThrottle.reset();
  });

  group('LessonScreen', () {
    test('quiz feedback scroll targets the explanation only', () {
      final source = File(
        'lib/screens/lesson/lesson_quiz_widget.dart',
      ).readAsStringSync();

      expect(source, contains('Scrollable.ensureVisible'));
      expect(
        source,
        isNot(
          contains(
            'animateTo(\n          _scrollController.position.maxScrollExtent',
          ),
        ),
        reason:
            'Max-scroll can clip the question heading when feedback already fits.',
      );
    });

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

    testWidgets('shows structured lesson guide', (tester) async {
      final lesson = Lesson(
        id: 'lesson-guide',
        pathId: 'path-1',
        title: 'Guided Lesson',
        description: 'A lesson with structured guide content.',
        orderIndex: 1,
        sections: _testLesson.sections,
        guide: const LessonLearningGuide(
          outcomes: [
            'Explain why ammonia is dangerous before fish show symptoms.',
            'Know the first safe action when a new tank tests unsafe.',
          ],
          scenario:
              'Your new tank looks clear, but fish are gasping near the surface.',
          careDrill: [
            'Test ammonia and nitrite before feeding again.',
            'Use a water change plan before adding more fish.',
          ],
          sources: [
            LessonSource(
              title: 'Water quality and fish health',
              publisher: 'Merck Veterinary Manual',
              url:
                  'https://www.merckvetmanual.com/exotic-and-laboratory-animals/aquatic-systems/environmental-diseases-of-aquatic-animals-in-aquatic-systems',
              note: 'Water quality risks and emergency context.',
            ),
          ],
        ),
      );

      await tester.pumpWidget(_wrap(lesson: lesson));
      await _advance(tester);

      expect(find.text('You\'ll learn'), findsOneWidget);
      expect(
        find.text(
          'Explain why ammonia is dangerous before fish show symptoms.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Know the first safe action when a new tank tests unsafe.'),
        findsOneWidget,
      );
      expect(find.text('Real tank scenario'), findsOneWidget);
      expect(
        find.text(
          'Your new tank looks clear, but fish are gasping near the surface.',
        ),
        findsOneWidget,
      );
      expect(find.text('Care drill'), findsOneWidget);
      expect(
        find.text('Test ammonia and nitrite before feeding again.'),
        findsOneWidget,
      );
      expect(
        find.text('Use a water change plan before adding more fish.'),
        findsOneWidget,
      );
      expect(find.text('References'), findsOneWidget);
      expect(find.text('Water quality and fish health'), findsOneWidget);
      expect(find.textContaining('Merck Veterinary Manual'), findsOneWidget);
    });

    testWidgets('opens the first lesson without blocking energy explainer', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      expect(find.text('Energy'), findsNothing);
      expect(find.textContaining('Energy gives you bonus XP'), findsNothing);
      expect(
        find.textContaining('nitrogen cycle is the most important'),
        findsOneWidget,
      );
    });

    testWidgets('opens Emergency Guide from the lesson app bar', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      expect(find.byTooltip('Emergency Guide'), findsOneWidget);

      final emergencyButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.emergency_outlined),
      );
      emergencyButton.onPressed!();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(EmergencyGuideScreen), findsOneWidget);
    });

    testWidgets('XP badge reflects active boost for lesson rewards', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          lesson: _quizLesson,
          overrides: [xpBoostActiveProvider.overrideWithValue(true)],
        ),
      );
      await _advance(tester);

      expect(find.text('up to +150 XP (2x)'), findsOneWidget);
      expect(find.text('up to +75 XP'), findsNothing);
    });

    testWidgets('XP badge reflects active boost for practice rewards', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          isPracticeMode: true,
          overrides: [xpBoostActiveProvider.overrideWithValue(true)],
        ),
      );
      await _advance(tester);

      expect(find.text('+50 XP (2x)'), findsOneWidget);
      expect(find.text('+25 XP'), findsNothing);
    });

    testWidgets('renders image sections with asset and caption', (
      tester,
    ) async {
      final lesson = Lesson(
        id: 'lesson-image',
        pathId: 'path-1',
        title: 'Visual Lesson',
        description: 'A lesson with an image section.',
        orderIndex: 1,
        sections: const [
          LessonSection(
            type: LessonSectionType.image,
            content: 'Tank visual',
            imageUrl: 'assets/images/placeholder.webp',
            caption: 'A clear visual anchor for this concept.',
          ),
        ],
      );

      await tester.pumpWidget(_wrap(lesson: lesson));
      await _advance(tester);

      expect(find.byType(Image), findsOneWidget);
      expect(
        find.text('A clear visual anchor for this concept.'),
        findsOneWidget,
      );
      expect(find.text('Visual guide on the way!'), findsNothing);
    });

    testWidgets('completion flow fits a compact Android viewport', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final lesson = Lesson(
        id: 'lesson-complete',
        pathId: 'path-1',
        title: 'Completion Lesson',
        description: 'A lesson with a quiz.',
        orderIndex: 1,
        xpReward: 50,
        sections: _testLesson.sections,
        quiz: Quiz(
          id: 'quiz-complete',
          lessonId: 'lesson-complete',
          questions: const [
            QuizQuestion(
              id: 'q1',
              question: 'What matters most?',
              options: ['Speed', 'Testing', 'Guessing', 'Skipping'],
              correctIndex: 1,
              explanation: 'Testing keeps the tank safe.',
            ),
            QuizQuestion(
              id: 'q2',
              question: 'When is review due?',
              options: ['Never', 'Tomorrow', 'In a year', 'Only on Sundays'],
              correctIndex: 1,
              explanation: 'First review returns tomorrow.',
            ),
            QuizQuestion(
              id: 'q3',
              question: 'What does Practice build?',
              options: ['Pressure', 'Care confidence', 'Noise', 'Confusion'],
              correctIndex: 1,
              explanation: 'Practice builds care confidence.',
            ),
          ],
          passingScore: 70,
          bonusXp: 25,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LessonCompletionFlow(
              lesson: lesson,
              pathTitle: 'The Nitrogen Cycle',
              isPracticeMode: false,
              correctAnswers: 3,
              isCompletingLesson: false,
              onCompleteLesson: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Complete Lesson'), findsOneWidget);
      expect(find.textContaining('review deck'), findsOneWidget);
    });

    testWidgets('quiz scrolls answer explanation into view after checking', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 560));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      int? selected;
      var answered = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return LessonQuizWidget(
                    lesson: _quizLesson,
                    isPracticeMode: false,
                    currentQuizQuestion: 0,
                    correctAnswers: answered ? 1 : 0,
                    selectedAnswer: selected,
                    answered: answered,
                    showHint: false,
                    onSelectAnswer: (index) => setState(() {
                      selected = index;
                    }),
                    onShowHint: () {},
                    onCheckOrAdvance:
                        ({
                          required selectedAnswer,
                          required isCorrect,
                          required isLastQuestion,
                        }) async {
                          setState(() {
                            answered = true;
                          });
                        },
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ammonia'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check Answer'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Ammonia should read zero'), findsOneWidget);
    });

    testWidgets('quiz feedback does not clip the question when it nearly fits', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      int? selected;
      var answered = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return LessonQuizWidget(
                    lesson: _quizLesson,
                    isPracticeMode: false,
                    currentQuizQuestion: 0,
                    correctAnswers: answered ? 1 : 0,
                    selectedAnswer: selected,
                    answered: answered,
                    showHint: false,
                    onSelectAnswer: (index) => setState(() {
                      selected = index;
                    }),
                    onShowHint: () {},
                    onCheckOrAdvance:
                        ({
                          required selectedAnswer,
                          required isCorrect,
                          required isLastQuestion,
                        }) async {
                          setState(() {
                            answered = true;
                          });
                        },
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ammonia'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check Answer'));
      await tester.pumpAndSettle();

      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));

      expect(
        scrollable.position.pixels,
        lessThanOrEqualTo(20),
        reason:
            'Near-fit feedback should not auto-scroll far enough to clip the question heading.',
      );
    });

    testWidgets('quiz keeps selected correct answer marker after reveal', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: Scaffold(
                body: LessonQuizWidget(
                  lesson: _quizLesson,
                  isPracticeMode: false,
                  currentQuizQuestion: 0,
                  correctAnswers: 1,
                  selectedAnswer: 0,
                  answered: true,
                  showHint: false,
                  onSelectAnswer: (_) {},
                  onShowHint: () {},
                  onCheckOrAdvance:
                      ({
                        required selectedAnswer,
                        required isCorrect,
                        required isLastQuestion,
                      }) async {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel('Selected answer A, correct'),
        findsOneWidget,
      );
    });

    testWidgets('quiz empty state does not use coming soon copy', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LessonQuizWidget(
                lesson: _testLesson,
                isPracticeMode: false,
                currentQuizQuestion: 0,
                correctAnswers: 0,
                selectedAnswer: null,
                answered: false,
                showHint: false,
                onSelectAnswer: (_) {},
                onShowHint: () {},
                onCheckOrAdvance:
                    ({
                      required selectedAnswer,
                      required isCorrect,
                      required isLastQuestion,
                    }) async {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No quiz for this lesson'), findsOneWidget);
      expect(find.text('Quiz coming soon!'), findsNothing);
    });

    testWidgets('hint chip reveals visible hint panel and announces it', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'user_profile': _profileJson()});

      var showHint = false;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return LessonQuizWidget(
                    lesson: _quizLesson,
                    isPracticeMode: false,
                    currentQuizQuestion: 0,
                    correctAnswers: 0,
                    selectedAnswer: null,
                    answered: false,
                    showHint: showHint,
                    onSelectAnswer: (_) {},
                    onShowHint: () {
                      setState(() {
                        showHint = true;
                      });
                    },
                    onCheckOrAdvance:
                        ({
                          required selectedAnswer,
                          required isCorrect,
                          required isLastQuestion,
                        }) async {},
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Need a hint?'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Look for keywords'), findsOneWidget);
      final announcements = tester.takeAnnouncements();
      expect(
        announcements.any((announcement) {
          return announcement.message.contains('Hint shown');
        }),
        isTrue,
      );
    });
  });
}
