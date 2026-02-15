/// Test script for lazy loading implementation
/// Run: flutter test test/lazy_loading_test.dart
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/providers/lesson_provider.dart';
import 'package:aquarium_app/models/learning.dart';

void main() {
  group('Lazy Loading Provider Tests', () {
    late LessonProvider provider;

    setUp(() {
      provider = LessonProvider();
    });

    test('Initial state should be empty', () {
      expect(provider.loadedPaths.length, 0);
      expect(provider.pathLoadStates.length, 0);
    });

    test('Path metadata should be available immediately', () {
      final metadata = LessonProvider.allPathMetadata;
      expect(metadata.length, 9);
      expect(metadata[0].id, 'nitrogen_cycle');
      expect(metadata[0].lessonIds.length, greaterThan(0));
    });

    test('Load nitrogen cycle path', () async {
      await provider.loadPath('nitrogen_cycle');
      
      expect(provider.isPathLoaded('nitrogen_cycle'), true);
      expect(provider.getPath('nitrogen_cycle'), isNotNull);
      
      final path = provider.getPath('nitrogen_cycle')!;
      expect(path.id, 'nitrogen_cycle');
      expect(path.lessons.length, greaterThan(0));
    });

    test('Load multiple paths', () async {
      await provider.loadPaths(['nitrogen_cycle', 'water_parameters']);
      
      expect(provider.isPathLoaded('nitrogen_cycle'), true);
      expect(provider.isPathLoaded('water_parameters'), true);
      expect(provider.loadedPaths.length, 2);
    });

    test('Preload essentials loads nitrogen cycle and water parameters', () async {
      await provider.preloadEssentials();
      
      expect(provider.isPathLoaded('nitrogen_cycle'), true);
      expect(provider.isPathLoaded('water_parameters'), true);
      expect(provider.loadedPaths.length, 2);
    });

    test('Get lesson by ID', () async {
      await provider.loadPath('nitrogen_cycle');
      
      final lesson = provider.getLesson('nc_intro');
      expect(lesson, isNotNull);
      expect(lesson!.id, 'nc_intro');
      expect(lesson.pathId, 'nitrogen_cycle');
    });

    test('Get lesson from unloaded path returns null', () {
      final lesson = provider.getLesson('nc_intro');
      expect(lesson, isNull);
    });

    test('Clear path removes it from loaded paths', () async {
      await provider.loadPath('nitrogen_cycle');
      expect(provider.isPathLoaded('nitrogen_cycle'), true);
      
      provider.clearPath('nitrogen_cycle');
      expect(provider.isPathLoaded('nitrogen_cycle'), false);
      expect(provider.loadedPaths.length, 0);
    });

    test('Clear all removes all loaded paths', () async {
      await provider.loadPaths(['nitrogen_cycle', 'water_parameters', 'first_fish']);
      expect(provider.loadedPaths.length, 3);
      
      provider.clearAll();
      expect(provider.loadedPaths.length, 0);
      expect(provider.pathLoadStates.length, 0);
    });

    test('Loading same path twice does not duplicate', () async {
      await provider.loadPath('nitrogen_cycle');
      await provider.loadPath('nitrogen_cycle');
      
      expect(provider.loadedPaths.length, 1);
    });

    test('Invalid path ID throws error', () async {
      await expectLater(
        provider.loadPath('invalid_path_id'),
        throwsException,
      );
    });

    test('All paths can be loaded', () async {
      for (final metadata in LessonProvider.allPathMetadata) {
        await provider.loadPath(metadata.id);
      }
      
      expect(provider.loadedPaths.length, 9);
      
      // Verify each path
      expect(provider.getPath('nitrogen_cycle'), isNotNull);
      expect(provider.getPath('water_parameters'), isNotNull);
      expect(provider.getPath('first_fish'), isNotNull);
      expect(provider.getPath('maintenance'), isNotNull);
      expect(provider.getPath('planted_tank'), isNotNull);
      expect(provider.getPath('equipment'), isNotNull);
      expect(provider.getPath('fish_health'), isNotNull);
      expect(provider.getPath('species_care'), isNotNull);
      expect(provider.getPath('advanced_topics'), isNotNull);
    });

    test('Lessons have correct structure', () async {
      await provider.loadPath('nitrogen_cycle');
      final path = provider.getPath('nitrogen_cycle')!;
      
      expect(path.lessons, isNotEmpty);
      
      final firstLesson = path.lessons.first;
      expect(firstLesson.id, isNotEmpty);
      expect(firstLesson.title, isNotEmpty);
      expect(firstLesson.sections, isNotEmpty);
      expect(firstLesson.xpReward, greaterThan(0));
      expect(firstLesson.estimatedMinutes, greaterThan(0));
    });

    test('Quiz data loads correctly', () async {
      await provider.loadPath('nitrogen_cycle');
      final lesson = provider.getLesson('nc_intro')!;
      
      expect(lesson.quiz, isNotNull);
      expect(lesson.quiz!.questions, isNotEmpty);
      
      final question = lesson.quiz!.questions.first;
      expect(question.question, isNotEmpty);
      expect(question.options.length, greaterThan(1));
      expect(question.correctIndex, greaterThanOrEqualTo(0));
      expect(question.correctIndex, lessThan(question.options.length));
    });
  });

  group('Performance Tests', () {
    test('Loading path should be fast', () async {
      final provider = LessonProvider();
      final stopwatch = Stopwatch()..start();
      
      await provider.loadPath('nitrogen_cycle');
      
      stopwatch.stop();
      print('Path load time: ${stopwatch.elapsedMilliseconds}ms');
      
      // Should load in under 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('Metadata access should be instant', () {
      final stopwatch = Stopwatch()..start();
      
      final metadata = LessonProvider.allPathMetadata;
      
      stopwatch.stop();
      print('Metadata access time: ${stopwatch.elapsedMicroseconds}μs');
      
      // Should be under 1ms
      expect(stopwatch.elapsedMilliseconds, lessThan(1));
      expect(metadata.length, 9);
    });

    test('Memory usage check', () async {
      final provider = LessonProvider();
      
      // Load single path
      await provider.loadPath('nitrogen_cycle');
      final path = provider.getPath('nitrogen_cycle')!;
      
      // Basic sanity check - path should have data
      expect(path.lessons.isNotEmpty, true);
      
      // Clear and verify
      provider.clearPath('nitrogen_cycle');
      expect(provider.loadedPaths.isEmpty, true);
    });
  });
}
