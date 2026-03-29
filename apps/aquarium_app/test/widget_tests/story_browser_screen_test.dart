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
  });
}
