/// Lazy-loaded lesson content wrapper
/// Maintains backward compatibility with LessonContent.allPaths
/// while using the new lazy-loading system under the hood
library;

import '../models/learning.dart';
import '../providers/lesson_provider.dart';

/// Singleton wrapper for lazy-loaded lesson content
class LessonContentLazy {
  static final LessonContentLazy _instance = LessonContentLazy._internal();
  factory LessonContentLazy() => _instance;
  LessonContentLazy._internal();

  final LessonProvider _provider = LessonProvider();
  bool _initialized = false;

  /// Get all paths metadata (lightweight - no full lessons)
  List<PathMetadata> get allPathsMetadata {
    return LessonProvider.allPathMetadata;
  }

  /// Load a specific path
  Future<LearningPath> loadPath(String pathId) async {
    await _provider.loadPath(pathId);
    final path = _provider.getPath(pathId);
    if (path == null) {
      throw Exception('Failed to load path: $pathId');
    }
    return path;
  }

  /// Get all paths (loads them if not already loaded)
  /// Use this sparingly - prefer loadPath() for specific needs
  Future<List<LearningPath>> getAllPaths() async {
    if (!_initialized) {
      await _initializeAll();
    }
    return _provider.loadedPaths.values.toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  /// Initialize all paths (for compatibility with old code)
  Future<void> _initializeAll() async {
    for (final metadata in LessonProvider.allPathMetadata) {
      await _provider.loadPath(metadata.id);
    }
    _initialized = true;
  }

  /// Get a specific lesson by ID
  Future<Lesson?> getLesson(String lessonId) async {
    // Try loaded paths first
    var lesson = _provider.getLesson(lessonId);
    if (lesson != null) return lesson;

    // Search in metadata and load the required path
    for (final metadata in LessonProvider.allPathMetadata) {
      if (metadata.lessonIds.contains(lessonId)) {
        await loadPath(metadata.id);
        return _provider.getLesson(lessonId);
      }
    }
    return null;
  }

  /// Check if a path is loaded
  bool isPathLoaded(String pathId) {
    return _provider.isPathLoaded(pathId);
  }

  /// Preload essential paths (nitrogen cycle, water parameters)
  Future<void> preloadEssentials() async {
    await _provider.preloadEssentials();
  }

  /// Clear all loaded content (memory management)
  void clearAll() {
    _provider.clearAll();
    _initialized = false;
  }
}

/// Global instance for easy access
final lessonContentLazy = LessonContentLazy();
