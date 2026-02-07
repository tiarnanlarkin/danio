/// Tests for Story models

import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/models/story.dart';
import 'package:aquarium_app/models/user_profile.dart';
import 'package:aquarium_app/data/stories.dart';

void main() {
  group('StoryProgress', () {
    test('starts with initial scene', () {
      final progress = StoryProgress.start('test_story', 'scene_1');
      
      expect(progress.storyId, 'test_story');
      expect(progress.currentSceneId, 'scene_1');
      expect(progress.visitedSceneIds, ['scene_1']);
      expect(progress.completed, false);
      expect(progress.score, 0);
    });

    test('tracks choices correctly', () {
      final progress = StoryProgress.start('test_story', 'scene_1');
      
      final choice1 = StoryChoice(
        id: 'choice_1',
        text: 'Correct answer',
        nextSceneId: 'scene_2',
        isCorrect: true,
      );
      
      final newProgress = progress.makeChoice(
        choice: choice1,
        nextSceneId: 'scene_2',
        isFinalScene: false,
      );
      
      expect(newProgress.currentSceneId, 'scene_2');
      expect(newProgress.correctChoices, 1);
      expect(newProgress.totalChoices, 1);
      expect(newProgress.score, 100);
      expect(newProgress.visitedSceneIds, ['scene_1', 'scene_2']);
    });

    test('calculates score correctly with mixed choices', () {
      var progress = StoryProgress.start('test_story', 'scene_1');
      
      // Correct choice
      progress = progress.makeChoice(
        choice: StoryChoice(
          id: 'c1',
          text: 'Correct',
          nextSceneId: 's2',
          isCorrect: true,
        ),
        nextSceneId: 's2',
        isFinalScene: false,
      );
      
      // Incorrect choice
      progress = progress.makeChoice(
        choice: StoryChoice(
          id: 'c2',
          text: 'Wrong',
          nextSceneId: 's3',
          isCorrect: false,
        ),
        nextSceneId: 's3',
        isFinalScene: false,
      );
      
      // Correct choice
      progress = progress.makeChoice(
        choice: StoryChoice(
          id: 'c3',
          text: 'Correct',
          nextSceneId: 's4',
          isCorrect: true,
        ),
        nextSceneId: 's4',
        isFinalScene: true,
      );
      
      expect(progress.correctChoices, 2);
      expect(progress.totalChoices, 3);
      expect(progress.score, 67); // 2/3 = 66.67% -> 67
      expect(progress.completed, true);
    });

    test('calculates XP based on score', () {
      final baseXp = 100;
      
      // 100% score -> 1.5x multiplier
      var progress = StoryProgress(
        storyId: 'test',
        currentSceneId: 'end',
        correctChoices: 5,
        totalChoices: 5,
        completed: true,
        score: 100,
      );
      expect(progress.calculateXp(baseXp), 150);
      
      // 80% score -> 1.25x multiplier
      progress = progress.copyWith(
        correctChoices: 4,
        score: 80,
      );
      expect(progress.calculateXp(baseXp), 125);
      
      // 60% score -> 1.0x multiplier
      progress = progress.copyWith(
        correctChoices: 3,
        score: 60,
      );
      expect(progress.calculateXp(baseXp), 100);
      
      // 40% score -> 0.75x multiplier
      progress = progress.copyWith(
        correctChoices: 2,
        score: 40,
      );
      expect(progress.calculateXp(baseXp), 75);
    });

    test('serializes to and from JSON', () {
      final original = StoryProgress(
        storyId: 'test_story',
        currentSceneId: 'scene_3',
        visitedSceneIds: ['scene_1', 'scene_2', 'scene_3'],
        choicesMade: ['choice_1', 'choice_2'],
        correctChoices: 2,
        totalChoices: 2,
        completed: false,
        score: 100,
        startedAt: DateTime(2024, 1, 1),
      );
      
      final json = original.toJson();
      final restored = StoryProgress.fromJson(json);
      
      expect(restored.storyId, original.storyId);
      expect(restored.currentSceneId, original.currentSceneId);
      expect(restored.visitedSceneIds, original.visitedSceneIds);
      expect(restored.correctChoices, original.correctChoices);
      expect(restored.score, original.score);
    });
  });

  group('Story', () {
    test('finds scenes by ID', () {
      final story = Story(
        id: 'test',
        title: 'Test Story',
        description: 'A test',
        difficulty: StoryDifficulty.beginner,
        estimatedMinutes: 5,
        xpReward: 50,
        scenes: [
          StoryScene(
            id: 'scene_1',
            text: 'Scene 1',
            choices: [],
          ),
          StoryScene(
            id: 'scene_2',
            text: 'Scene 2',
            choices: [],
          ),
        ],
      );
      
      expect(story.getSceneById('scene_1')?.text, 'Scene 1');
      expect(story.getSceneById('scene_2')?.text, 'Scene 2');
      expect(story.getSceneById('nonexistent'), null);
    });

    test('checks unlock requirements', () {
      final story = Story(
        id: 'advanced_story',
        title: 'Advanced Story',
        description: 'Requires level 5',
        difficulty: StoryDifficulty.advanced,
        estimatedMinutes: 10,
        xpReward: 100,
        scenes: [],
        minLevel: 5,
        prerequisites: ['basic_story'],
      );
      
      // User below level
      var profile = UserProfile(
        id: 'user1',
        totalXp: 50, // Level 0
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(story.isUnlocked(profile, []), false);
      
      // User at level but missing prerequisites
      profile = profile.copyWith(totalXp: 1000); // Level 5+
      expect(story.isUnlocked(profile, []), false);
      
      // User meets all requirements
      expect(story.isUnlocked(profile, ['basic_story']), true);
    });
  });

  group('Stories Data', () {
    test('all stories have unique IDs', () {
      final ids = Stories.allStories.map((s) => s.id).toSet();
      expect(ids.length, Stories.allStories.length);
    });

    test('all stories have valid scenes', () {
      for (final story in Stories.allStories) {
        expect(story.scenes.isNotEmpty, true, 
            reason: '${story.id} has no scenes');
        
        // Check that all nextSceneIds reference valid scenes
        for (final scene in story.scenes) {
          for (final choice in scene.choices) {
            if (choice.nextSceneId.isNotEmpty) {
              final nextScene = story.getSceneById(choice.nextSceneId);
              expect(nextScene, isNotNull, 
                  reason: '${story.id}: Invalid nextSceneId ${choice.nextSceneId}');
            }
          }
        }
      }
    });

    test('stories have final scenes marked correctly', () {
      for (final story in Stories.allStories) {
        final finalScenes = story.scenes.where((s) => s.isFinalScene).toList();
        expect(finalScenes.isNotEmpty, true,
            reason: '${story.id} has no final scene');
      }
    });

    test('can retrieve stories by difficulty', () {
      final beginnerStories = Stories.getByDifficulty(StoryDifficulty.beginner);
      expect(beginnerStories.every((s) => s.difficulty == StoryDifficulty.beginner), true);
      
      final intermediateStories = Stories.getByDifficulty(StoryDifficulty.intermediate);
      expect(intermediateStories.every((s) => s.difficulty == StoryDifficulty.intermediate), true);
    });

    test('can filter locked/unlocked stories', () {
      final profile = UserProfile(
        id: 'test',
        totalXp: 500, // Level 3
        completedStories: ['new_tank_setup'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final unlocked = Stories.getUnlockedStories(
        profile.completedStories,
        profile.currentLevel,
      );
      
      final locked = Stories.getLockedStories(
        profile.completedStories,
        profile.currentLevel,
      );
      
      expect(unlocked.length + locked.length, Stories.allStories.length);
      
      // Verify no overlap
      final unlockedIds = unlocked.map((s) => s.id).toSet();
      final lockedIds = locked.map((s) => s.id).toSet();
      expect(unlockedIds.intersection(lockedIds).isEmpty, true);
    });
  });

  group('Story Navigation', () {
    test('complete story flow works', () {
      final story = Stories.newTankSetup;
      var progress = StoryProgress.start(story.id, story.startScene.id);
      
      // Navigate through a few scenes
      final scene1 = story.getSceneById(progress.currentSceneId);
      expect(scene1, isNotNull);
      
      if (scene1!.choices.isNotEmpty) {
        final choice = scene1.choices.first;
        progress = progress.makeChoice(
          choice: choice,
          nextSceneId: choice.nextSceneId,
          isFinalScene: false,
        );
        
        expect(progress.totalChoices, 1);
        expect(progress.visitedSceneIds.length, 2);
      }
    });
  });
}
