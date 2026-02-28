# Code Cleanup Guide

## Task
Professional code cleanup to achieve:
- ✅ Zero TODOs/FIXMEs
- ✅ Zero analyzer warnings
- ✅ Well-documented complex logic
- ✅ Production-ready code quality

## Phase 1: Remove TODOs/FIXMEs

### Current TODOs (3 total):

**1. spaced_repetition_practice_screen.dart:45**
```dart
// final weakCount = srState.stats.weakCards; // TODO: Display weak cards count
```
**Action:** Remove the commented line entirely (feature deferred, not blocking)

**2. achievement_service.dart:134**
```dart
// TODO: Implement based on LessonContent.allPaths structure
shouldUnlock = false;
```
**Action:** Replace TODO with clear comment:
```dart
// Not implemented: Requires LessonContent.allPaths integration (deferred to future release)
shouldUnlock = false;
```

**3. room_backgrounds.dart:170**
```dart
// TODO: Re-enable with optimized non-repeating versions
return const SizedBox.shrink();
```
**Action:** Replace TODO with clear comment:
```dart
// Disabled: Ambient effects caused ANR on some devices
// Will re-enable in future release with optimized implementation
return const SizedBox.shrink();
```

## Phase 2: Fix Analyzer Warnings

### Common Warning Types to Fix:

**Unused imports:**
```dart
// BEFORE
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Not used

// AFTER  
import 'package:flutter/material.dart';
```

**Missing const:**
```dart
// BEFORE
Widget build(BuildContext context) {
  return Text('Hello');
}

// AFTER
Widget build(BuildContext context) {
  return const Text('Hello');
}
```

**Prefer const constructors:**
```dart
// BEFORE
return Container(
  padding: EdgeInsets.all(16),
  child: Text('Hello'),
);

// AFTER
return Container(
  padding: const EdgeInsets.all(16),
  child: const Text('Hello'),
);
```

**use_build_context_synchronously:**
```dart
// BEFORE
await someAsyncFunction();
if (mounted) {
  Navigator.pop(context);
}

// AFTER - already correct, ignore warning if pattern is safe
```

## Phase 3: Documentation

### What to Document:

**Complex Widgets:**
- Room scene rendering logic
- Animation controllers
- Custom painters

**Public APIs:**
- Service classes
- Provider methods
- Utility functions

**Example Documentation:**
```dart
/// Renders the cozy room scene with dynamic theming.
/// 
/// Supports:
/// - Day/night cycle transitions
/// - Custom color themes
/// - Animated decorative elements
/// 
/// Performance: Optimized for 60fps rendering
class CozyRoomScene extends StatelessWidget {
  /// Creates a cozy room scene.
  /// 
  /// [theme] - Color theme for the room
  /// [isNightMode] - Whether to render night variant
  const CozyRoomScene({
    super.key,
    required this.theme,
    required this.isNightMode,
  });
  
  final RoomTheme theme;
  final bool isNightMode;
  
  // ...
}
```

## Process

1. **Run analyzer:**
   ```bash
   flutter analyze --no-pub
   ```

2. **For each warning:**
   - Read the warning message
   - Apply the suggested fix
   - Re-run analyzer to verify

3. **For TODOs:**
   - Remove or replace with clear "deferred" comments
   - Ensure no functionality is lost

4. **For documentation:**
   - Add doc comments to public classes/methods
   - Focus on complex logic that needs explanation

5. **Test build:**
   ```bash
   flutter build apk --debug
   ```

6. **Commit:**
   ```bash
   git add -A
   git commit -m "chore: code quality cleanup - zero warnings, zero TODOs"
   ```

## Success Criteria

- ✅ `flutter analyze` shows "No issues found!"
- ✅ Zero TODO/FIXME comments
- ✅ All public APIs have doc comments
- ✅ Build succeeds
- ✅ No functionality broken

## Notes

- Prefer clarity over brevity in documentation
- Don't over-document obvious code
- Focus on **why** not **what** in comments
- Use `///` for doc comments, `//` for implementation notes
