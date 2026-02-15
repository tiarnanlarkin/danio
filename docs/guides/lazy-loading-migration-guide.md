# Lazy Loading Migration Guide

## Overview
This guide shows how to migrate screens from the old `LessonContent.allPaths` approach to the new lazy-loaded system.

---

## Quick Reference

### Old Way (Eager Loading)
```dart
import '../data/lesson_content.dart';

// Loads all 347KB immediately
final paths = LessonContent.allPaths;
```

### New Way (Lazy Loading)
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/lesson_provider.dart';
import '../widgets/lesson_skeleton.dart';

class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonState = ref.watch(lessonProvider);
    
    // Load path on demand
    if (!lessonState.isPathLoaded('nitrogen_cycle')) {
      Future.microtask(() {
        ref.read(lessonProvider.notifier).loadPath('nitrogen_cycle');
      });
      return PathCardSkeleton(); // Show skeleton while loading
    }
    
    final path = lessonState.getPath('nitrogen_cycle')!;
    return PathContent(path: path);
  }
}
```

---

## Migration Examples

### Example 1: Learn Screen (Path List)

**Before:**
```dart
Widget build(BuildContext context, WidgetRef ref) {
  return ListView.builder(
    itemCount: LessonContent.allPaths.length,
    itemBuilder: (context, index) {
      final path = LessonContent.allPaths[index];
      return PathCard(path: path);
    },
  );
}
```

**After:**
```dart
Widget build(BuildContext context, WidgetRef ref) {
  final pathMetadata = ref.watch(pathMetadataProvider);
  final lessonState = ref.watch(lessonProvider);
  
  // Preload first 2 paths on mount
  useEffect(() {
    Future.microtask(() {
      ref.read(lessonProvider.notifier).preloadEssentials();
    });
    return null;
  }, []);
  
  return ListView.builder(
    itemCount: pathMetadata.length,
    itemBuilder: (context, index) {
      final metadata = pathMetadata[index];
      
      // Show skeleton if not loaded
      if (!lessonState.isPathLoaded(metadata.id)) {
        // Lazy load when scrolled into view
        Future.microtask(() {
          ref.read(lessonProvider.notifier).loadPath(metadata.id);
        });
        return PathCardSkeleton();
      }
      
      // Path loaded - show real content
      final path = lessonState.getPath(metadata.id)!;
      return PathCard(path: path);
    },
  );
}
```

---

### Example 2: Lesson Screen (Single Lesson)

**Before:**
```dart
class LessonScreen extends StatelessWidget {
  final String lessonId;
  
  @override
  Widget build(BuildContext context) {
    // Find lesson in all paths
    Lesson? lesson;
    for (final path in LessonContent.allPaths) {
      try {
        lesson = path.lessons.firstWhere((l) => l.id == lessonId);
        break;
      } catch (_) {}
    }
    
    if (lesson == null) return ErrorScreen();
    return LessonContent(lesson: lesson);
  }
}
```

**After:**
```dart
class LessonScreen extends ConsumerWidget {
  final String lessonId;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lesson = ref.watch(lessonByIdProvider(lessonId));
    
    // Lesson not loaded yet
    if (lesson == null) {
      // Trigger lazy load
      Future.microtask(() async {
        // Find which path contains this lesson
        for (final metadata in LessonProvider.allPathMetadata) {
          if (metadata.lessonIds.contains(lessonId)) {
            await ref.read(lessonProvider.notifier).loadPath(metadata.id);
            break;
          }
        }
      });
      
      // Show skeleton while loading
      return Scaffold(
        appBar: AppBar(title: Text('Loading...')),
        body: LessonContentSkeleton(),
      );
    }
    
    return LessonContent(lesson: lesson);
  }
}
```

---

### Example 3: Analytics Screen (Stats Calculation)

**Before:**
```dart
Widget build(BuildContext context) {
  final allPaths = LessonContent.allPaths;
  final totalLessons = allPaths.fold<int>(
    0,
    (sum, path) => sum + path.lessons.length,
  );
  
  return Text('Total: $totalLessons lessons');
}
```

**After (Option 1: Use Metadata - Lightweight):**
```dart
Widget build(BuildContext context, WidgetRef ref) {
  final metadata = ref.watch(pathMetadataProvider);
  final totalLessons = metadata.fold<int>(
    0,
    (sum, meta) => sum + meta.lessonIds.length,
  );
  
  return Text('Total: $totalLessons lessons');
}
```

**After (Option 2: Load All - If You Really Need Full Data):**
```dart
Widget build(BuildContext context, WidgetRef ref) {
  final lessonState = ref.watch(lessonProvider);
  
  // Load all paths if not loaded
  useEffect(() {
    Future.microtask(() async {
      for (final meta in LessonProvider.allPathMetadata) {
        await ref.read(lessonProvider.notifier).loadPath(meta.id);
      }
    });
    return null;
  }, []);
  
  // Show loading until all loaded
  if (lessonState.loadedPaths.length < LessonProvider.allPathMetadata.length) {
    return CircularProgressIndicator();
  }
  
  final totalLessons = lessonState.loadedPaths.values.fold<int>(
    0,
    (sum, path) => sum + path.lessons.length,
  );
  
  return Text('Total: $totalLessons lessons');
}
```

---

## Best Practices

### 1. **Prefer Metadata Over Full Paths**
Metadata is always loaded and lightweight (just IDs, titles, descriptions).

```dart
// ✅ Good - uses metadata
final pathCount = ref.watch(pathMetadataProvider).length;

// ❌ Bad - forces loading all paths
final pathCount = LessonContent.allPaths.length;
```

### 2. **Preload Essential Paths**
Load nitrogen cycle and water parameters early (most accessed).

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(lessonProvider.notifier).preloadEssentials();
  });
}
```

### 3. **Show Skeletons During Load**
Never show blank screens - always provide loading feedback.

```dart
if (!lessonState.isPathLoaded(pathId)) {
  return PathCardSkeleton(); // ✅ Good
  // return Container(); // ❌ Bad - blank screen
}
```

### 4. **Handle Errors Gracefully**
Provide retry mechanisms for failed loads.

```dart
if (lessonState.pathLoadStates[pathId] == LessonLoadState.error) {
  return LessonErrorWidget(
    message: lessonState.errorMessage ?? 'Failed to load',
    onRetry: () {
      ref.read(lessonProvider.notifier).loadPath(pathId);
    },
  );
}
```

### 5. **Clear Paths When Done**
If a user navigates away from a path, consider clearing it to free memory.

```dart
@override
void dispose() {
  // Clear rarely-used paths
  ref.read(lessonProvider.notifier).clearPath('advanced_topics');
  super.dispose();
}
```

---

## Migration Checklist

For each screen that uses lessons:

- [ ] Replace `LessonContent.allPaths` with `ref.watch(pathMetadataProvider)` (if only need metadata)
- [ ] Replace `LessonContent.allPaths` with lazy loading (if need full content)
- [ ] Add loading state checks (`isPathLoaded`)
- [ ] Show skeleton loaders during load
- [ ] Handle error states with retry buttons
- [ ] Preload essential paths if needed
- [ ] Test loading behavior (slow network simulation)
- [ ] Verify memory usage improvements

---

## Performance Tips

### Measuring Impact
```dart
// Before loading
final beforeMem = ProcessInfo.currentRss;
final beforeTime = DateTime.now();

await ref.read(lessonProvider.notifier).loadPath('nitrogen_cycle');

final afterMem = ProcessInfo.currentRss;
final afterTime = DateTime.now();

print('Memory: ${(afterMem - beforeMem) / 1024 / 1024} MB');
print('Time: ${afterTime.difference(beforeTime).inMilliseconds} ms');
```

### Expected Results
- **Metadata load:** <5ms, <1MB
- **Single path load:** 10-50ms, 5-10MB
- **All paths load:** 100-200ms, 40-60MB (vs 200ms, 350MB before)

---

## Troubleshooting

### "Lesson not found"
**Cause:** Lesson ID doesn't exist in any path metadata.
**Solution:** Check `LessonProvider.allPathMetadata` for correct IDs.

### "Path loads every rebuild"
**Cause:** Calling `loadPath()` in build method without checks.
**Solution:** Wrap in `Future.microtask()` and check `isPathLoaded()` first.

### "Memory usage still high"
**Cause:** All paths loaded and never cleared.
**Solution:** Call `clearPath()` for unused paths or use a LRU cache.

---

## Next Steps

1. Start with low-risk screens (analytics, placement test)
2. Migrate high-traffic screens (learn_screen, lesson_screen)
3. Monitor performance metrics
4. Gradually migrate all `LessonContent.allPaths` usages
5. Remove legacy file once complete

---

**Questions?** Check `/docs/completed/phase-1-3-lazy-loading-completion.md` for implementation details.
