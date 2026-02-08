# Performance Optimization Report - Wave 3 Features
**Date:** 2024-02-07  
**Analyzed:** 179 Dart files  
**Issues Found:** 356 (150 errors, 20 warnings, 186 info/lints)

## Wave 3 Features Identified
1. **Analytics Screen** - Charts, insights, progress visualization
2. **Achievements Screen** - Trophy case with filtering/sorting
3. **Story Player Screen** - Interactive narratives with animations
4. **Friends Screen** - Social features, activity feed
5. **Leaderboard** - Weekly competition with leagues

## Critical Issues (Blocks Compilation)

### 1. Leaderboard Model API Mismatch (120+ errors)
- **Problem**: Tests use old API (`weeklyXp`, `displayName`, `avatarEmoji`)
- **Actual API**: `weeklyXP`, `username`, `avatarUrl`
- **Missing properties**: League.emoji, League.colorHex, League.promotionXp
- **Impact**: All leaderboard tests fail compilation

### 2. Missing Type Definitions
- **TankType**: Referenced in daily_tips.dart, enhanced_onboarding_screen.dart
  - **Location**: Actually defined in models/tank.dart but not imported
- **ExperienceLevel**: Referenced in placement_result_screen.dart (undefined)
- **QuestionDifficulty.medium**: Enum value doesn't exist

### 3. Property Access Errors
- **Task.completed** → should use `lastCompletedAt != null` or `completionCount > 0`
- **Livestock.species** → should use `commonName` or `scientificName`
- **AppColors.onSurfaceVariant** → doesn't exist (use `surfaceVariant`)

## Performance Optimization Opportunities

### Analytics Screen (lib/screens/analytics_screen.dart)
```dart
// Issues found:
- Large FutureBuilder rebuilding entire screen
- Charts recreated on every build
- Heavy computations in build method
- No const constructors for chart widgets
```

**Optimizations:**
1. Cache chart data computations
2. Extract chart widgets with const constructors
3. Use provider pattern instead of FutureBuilder
4. Implement shouldRebuild for expensive charts
5. Add loading states to prevent full rebuilds

### Achievements Screen (lib/screens/achievements_screen.dart)
```dart
// Issues found:
- Filtering/sorting happens in build method
- Achievement cards rebuilt unnecessarily
- No const constructors for static elements
- Heavy gradient computations
```

**Optimizations:**
1. Move filtering to provider/state management
2. Make AchievementCard const where possible
3. Cache gradient objects
4. Use ListView.builder (already doing this - ✓)
5. Optimize badge rendering

### Story Player Screen (lib/screens/story_player_screen.dart)
```dart
// Issues found:
- Multiple AnimationControllers
- Scene widgets rebuilt on every animation frame
- No const for static UI elements
- Text animations triggering full rebuilds
```

**Optimizations:**
1. Use RepaintBoundary for animated sections
2. Extract static UI to const widgets
3. Optimize animation listeners to rebuild only animated parts
4. Cache scene content
5. Implement AnimatedBuilder for isolated rebuilds

### Friends Screen (lib/screens/friends_screen.dart)
```dart
// Issues found:
- TabController disposal warning
- Unused _ErrorView widget
- List rebuilds on every search
- No const for empty states
```

**Optimizations:**
1. Add const to EmptyState widget
2. Remove unused _ErrorView
3. Debounce search input
4. Cache filtered friend lists
5. Optimize avatar loading

## Memory Optimization Priorities

### Controllers & Subscriptions
- ✓ Story Player: Disposes animation controllers correctly
- ✓ Friends Screen: Disposes TabController and TextEditingController
- ⚠️ Check: Riverpod providers for memory leaks
- ⚠️ Check: Chart animation controllers in Analytics screen

### Image Loading
- Stories: Check if images are cached
- Achievements: Badge images likely need caching
- Friends: Avatar loading optimization needed

## Code Quality Issues (Wave 3)

### Dangling Library Doc Comments (All Wave 3 files)
```dart
// Fix: Add `library;` directive after doc comment
/// My file description
library;

import 'package:flutter/material.dart';
```

### Unused Variables (Wave 3)
- achievement_integration_example.dart:29 - `today`
- difficulty_integration_example.dart:37 - `_showSkillUpMessage`
- friends_screen.dart:570 - `_ErrorView` class
- hearts_widgets.dart:25 - `heartsService`
- exercise_widgets.dart:104 - `_scaleAnimation`

### BuildContext Across Async Gaps
- achievement_integration_example.dart:54, 324
- lesson_screen.dart:600

## Build Optimization Recommendations

### Current APK Size Analysis Needed
```bash
flutter build apk --analyze-size
```

### Asset Optimization
1. Compress images (stories, achievements, avatars)
2. Use WebP format for photos
3. Tree shaking verification
4. ProGuard/R8 optimization for release

### Bundle Size Reduction
- Remove unused imports (6 found)
- Tree shake unused code
- Optimize dependencies
- Split features into deferred imports

## Implementation Priority

### Phase 1: Fix Compilation (Critical) - 2-3 hours
1. ✅ Import TankType where needed (5 min)
2. Fix Leaderboard test API (1 hour)
3. Fix Task/Livestock property access (30 min)
4. Add missing enum values or remove references (30 min)
5. Fix ExperienceLevel references (15 min)

### Phase 2: Wave 3 Performance (High) - 3-4 hours
1. Analytics Screen optimization (1 hour)
2. Achievements Screen optimization (45 min)
3. Story Player optimization (1 hour)
4. Friends Screen optimization (45 min)
5. Leaderboard screen optimization (30 min)

### Phase 3: Code Quality (Medium) - 2 hours
1. Add `library;` directives (30 min)
2. Remove unused variables/fields (30 min)
3. Fix BuildContext issues (30 min)
4. Add const constructors (30 min)

### Phase 4: Memory & Build (Medium) - 2-3 hours
1. Dispose audits (1 hour)
2. Image caching (1 hour)
3. Build optimization (1 hour)

## Performance Testing Plan

### Metrics to Measure
1. **App Startup Time**: Target <2s cold start
2. **Frame Rate**: Target 60fps for animations (Story Player)
3. **Memory Usage**: Monitor during 5min usage session
4. **APK Size**: Target <20MB for debug, <10MB for release

### Critical Paths to Profile
1. Analytics screen load time (heavy charts)
2. Story player animation smoothness
3. Achievements screen with 50+ items
4. Friends activity feed scrolling

### Tools
```bash
# Performance profiling
flutter run --profile
# In DevTools: Performance, Memory, Network tabs

# Widget rebuild tracking
flutter run --trace-skia

# Memory profiling
flutter run --profile --trace-startup
```

## Next Steps

1. **Immediate**: Fix critical compilation errors
2. **Short-term**: Optimize Wave 3 screens
3. **Ongoing**: Monitor memory and performance
4. **Release**: Full performance audit before production

## Estimated Total Time
- **Critical fixes**: 2-3 hours
- **Performance optimization**: 8-10 hours
- **Testing & validation**: 2-3 hours
- **Total**: ~12-16 hours for production-grade optimization
