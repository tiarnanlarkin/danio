// Widget tests for StoryBrowserScreen and StoryPlayScreen.
//
// Run: flutter test test/widget_tests/story_browser_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/story/story_browser_screen.dart';
import 'package:danio/screens/story/story_play_screen.dart';
import 'package:danio/models/story.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/widgets/core/app_button.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrapBrowser() {
  SharedPreferences.setMockInitialValues({});
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        return SharedPreferences.getInstance();
      }),
    ],
    child: const MaterialApp(home: StoryBrowserScreen()),
  );
}

Widget _wrapPlayScreen(Story story) {
  SharedPreferences.setMockInitialValues({});
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        return SharedPreferences.getInstance();
      }),
    ],
    child: MaterialApp(home: StoryPlayScreen(story: story)),
  );
}

Widget _wrapStoryNavigator(GlobalKey<NavigatorState> navigatorKey) {
  SharedPreferences.setMockInitialValues({});
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        return SharedPreferences.getInstance();
      }),
    ],
    child: MaterialApp(
      navigatorKey: navigatorKey,
      home: const Scaffold(body: Center(child: Text('Story hub'))),
    ),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(seconds: 1));
}

// A minimal story for testing StoryPlayScreen directly.
// nextSceneId: '' means endsStory == true (getter: nextSceneId.isEmpty).
const _testStory = Story(
  id: 'test_story',
  title: 'Test Story',
  description: 'A story for testing',
  difficulty: StoryDifficulty.beginner,
  estimatedMinutes: 5,
  xpReward: 50,
  scenes: [
    StoryScene(
      id: 'scene_1',
      text: 'Welcome to the test story. What do you choose?',
      choices: [
        StoryChoice(
          id: 'choice_a',
          text: 'Choice A',
          nextSceneId: '', // empty = endsStory
          isCorrect: true,
        ),
        StoryChoice(
          id: 'choice_b',
          text: 'Choice B',
          nextSceneId: '', // empty = endsStory
          isCorrect: false,
        ),
      ],
    ),
  ],
);

const _multiSceneStory = Story(
  id: 'multi_scene_story',
  title: 'Multi Scene Story',
  description: 'A story with progress to lose',
  difficulty: StoryDifficulty.beginner,
  estimatedMinutes: 5,
  xpReward: 50,
  scenes: [
    StoryScene(
      id: 'scene_1',
      text: 'You are starting a longer story.',
      choices: [
        StoryChoice(
          id: 'continue_story',
          text: 'Keep exploring',
          nextSceneId: 'scene_2',
          isCorrect: true,
        ),
      ],
    ),
    StoryScene(
      id: 'scene_2',
      text: 'You have made progress that should not be lost silently.',
      choices: [
        StoryChoice(
          id: 'continue_again',
          text: 'Continue safely',
          nextSceneId: 'scene_3',
          isCorrect: true,
        ),
      ],
    ),
    StoryScene(
      id: 'scene_3',
      text: 'This is the final scene.',
      choices: [
        StoryChoice(
          id: 'finish_story',
          text: 'Finish safely',
          nextSceneId: '',
          isCorrect: true,
        ),
      ],
    ),
  ],
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('StoryBrowserScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrapBrowser());
      await _advance(tester);
      expect(find.byType(StoryBrowserScreen), findsOneWidget);
    });

    testWidgets('shows Interactive Stories app bar title', (tester) async {
      await tester.pumpWidget(_wrapBrowser());
      await _advance(tester);
      expect(find.text('Interactive Stories'), findsOneWidget);
    });

    testWidgets('shows story cards from Stories.allStories', (tester) async {
      await tester.pumpWidget(_wrapBrowser());
      await _advance(tester);
      // At least one story card should be rendered
      expect(find.text('Choose your adventure'), findsOneWidget);
    });

    testWidgets('locked story tap explains how to unlock it', (tester) async {
      await tester.pumpWidget(_wrapBrowser());
      await _advance(tester);

      await tester.dragUntilVisible(
        find.text('Algae Outbreak'),
        find.byType(CustomScrollView),
        const Offset(0, -300),
      );
      await tester.pump();

      await tester.tap(find.text('Algae Outbreak'));
      await tester.pump();

      expect(
        find.text('Reach level 2 to unlock Algae Outbreak.'),
        findsOneWidget,
      );
    });
  });

  group('StoryPlayScreen', () {
    testWidgets('renders scene text', (tester) async {
      await tester.pumpWidget(_wrapPlayScreen(_testStory));
      await _advance(tester);
      expect(
        find.textContaining('Welcome to the test story'),
        findsOneWidget,
      );
    });

    testWidgets('renders choice buttons', (tester) async {
      await tester.pumpWidget(_wrapPlayScreen(_testStory));
      await _advance(tester);
      expect(find.text('Choice A'), findsOneWidget);
      expect(find.text('Choice B'), findsOneWidget);
    });

    testWidgets('back asks before leaving an unfinished story with progress', (
      tester,
    ) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(_wrapStoryNavigator(navigatorKey));
      await tester.pump();

      navigatorKey.currentState!.push<void>(
        MaterialPageRoute(
          builder: (_) => const StoryPlayScreen(story: _multiSceneStory),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Keep exploring'));
      await tester.pump();
      await tester.tap(find.widgetWithText(AppButton, 'Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('You have made progress that should not be lost silently.'),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Back'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Leave story?'), findsOneWidget);

      await tester.tap(find.text('Keep playing'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Leave story?'), findsNothing);
      expect(
        find.text('You have made progress that should not be lost silently.'),
        findsOneWidget,
      );
      expect(find.text('Story hub'), findsNothing);

      await tester.tap(find.byTooltip('Back'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Leave story?'), findsOneWidget);

      await tester.tap(find.text('Leave'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Story hub'), findsOneWidget);
      expect(
        find.text('You have made progress that should not be lost silently.'),
        findsNothing,
      );
    });
  });
}
