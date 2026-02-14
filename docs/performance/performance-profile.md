# Aquarium App - Performance Profile Report

**Date:** 2025-02-14
**Agent:** Performance Profiling Subagent
**Flutter Version:** (from /home/tiarnanlarkin/flutter/bin/flutter)

---

## Executive Summary

This report analyzes the Aquarium App for performance issues that could impact 60fps rendering. Key findings include:

- **321 withOpacity calls** throughout the codebase - potential jank sources
- **Many non-builder ListViews** - inefficient rendering for dynamic lists
- **Several large widget files** (>1000 lines) - complex widget trees
- **Build issues** on WSL (file locks) - unable to complete full profile build

---

## 1. Build Profile

**Status:** ⚠️ Unable to complete full build on WSL

### Build Attempts
1. **First attempt:** Failed due to missing `_triggerTestCrash()` method in settings_screen.dart
2. **Second attempt:** Failed due to deprecated `semanticLabel` parameter in IconButton
3. **Third attempt:** Failed due to WSL file lock issues (`FileSystemException: Deletion failed, path = 'build'`)

### Build Time Information
- **Last successful build:** Not available (no APKs in build output)
- **Build time estimate:** 46+ seconds based on Gradle task execution

### Warnings During Build
- **32 packages** have newer versions incompatible with dependency constraints
- Multiple dependency updates available (see output below)
  - archive 3.6.1 → 4.0.7
  - characters 1.4.0 → 1.4.1
  - confetti 0.7.0 → 0.8.0
  - connectivity_plus 6.1.5 → 7.0.0
  - fl_chart 0.69.2 → 1.1.1
  - flutter_riverpod 2.6.1 → 3.2.1
  - go_router 14.8.1 → 17.1.0
  - And 24 more packages

### Recommendation
Run the build from Windows PowerShell instead of WSL to avoid file lock issues:
```powershell
cd "C:\Users\larki\Documents\Aquarium App Dev\repo\apps\aquarium_app"
flutter build apk --debug
```

---

## 2. Performance Issues Found

### 2.1 Non-Builder ListViews (20+ instances found)

**Issue:** ListViews without `.builder` pattern render all children at once, causing jank for lists with many items.

#### Critical ListViews (High Traffic Screens)
1. `lib/screens/home_screen.dart` - Uses ListView (main app screen, critical)
2. `lib/screens/tank_detail_screen.dart` - Uses ListView (2440 lines - very complex)
3. `lib/screens/livestock_screen.dart` - Uses ListView (1345 lines - large)
4. `lib/screens/add_log_screen.dart` - Uses ListView (1204 lines - large)
5. `lib/screens/analytics_screen.dart` - Uses ListView (1156 lines - large)

#### Other ListScreens with Non-Builder ListViews
- `lib/screens/activity_feed_screen.dart`
- `lib/screens/algae_guide_screen.dart`
- `lib/screens/backup_restore_screen.dart`
- `lib/screens/breeding_guide_screen.dart`
- `lib/screens/co2_calculator_screen.dart`
- `lib/screens/compatibility_checker_screen.dart`
- `lib/screens/cost_tracker_screen.dart`
- `lib/screens/difficulty_settings_screen.dart`
- `lib/screens/emergency_guide_screen.dart`
- `lib/screens/enhanced_onboarding_screen.dart` (3 instances)
- `lib/screens/enhanced_quiz_screen.dart`
- `lib/screens/equipment_guide_screen.dart`
- `lib/screens/equipment_screen.dart` (2 instances)
- `lib/screens/faq_screen.dart`
- `lib/screens/feeding_guide_screen.dart`

**Impact:**
- All list items rendered at once → memory overhead
- Scrolling performance degradation with many items
- Potential jank on 60fps target

---

### 2.2 Large Widget Trees (>500 lines)

**Issue:** Large widget files are difficult to maintain and may cause unnecessary rebuilds.

#### Files Requiring Splitting
1. **tank_detail_screen.dart** - 2,440 lines ⚠️ **P0**
   - Extremely large, complex widget tree
   - Likely multiple screens/widgets in one file
   - High risk of unnecessary rebuilds

2. **home_screen.dart** - 1,715 lines ⚠️ **P0**
   - Main app screen - critical for performance
   - Complex state management
   - Multiple features in one widget

3. **settings_screen.dart** - 1,415 lines ⚠️ **P1**
   - Large settings tree
   - Multiple setting groups

4. **livestock_screen.dart** - 1,345 lines ⚠️ **P1**
   - Complex livestock management
   - Multiple widgets in one file

5. **spaced_repetition_practice_screen.dart** - 1,230 lines ⚠️ **P1**
   - Quiz/practice functionality
   - Complex animations

6. **add_log_screen.dart** - 1,204 lines ⚠️ **P1**
   - Log entry functionality
   - Multiple form widgets

7. **analytics_screen.dart** - 1,156 lines ⚠️ **P1**
   - Charts and analytics
   - Heavy computation

8. **charts_screen.dart** - 1,065 lines ⚠️ **P2**
   - Chart rendering
   - Could benefit from splitting

9. **lesson_screen.dart** - 1,021 lines ⚠️ **P2**
   - Educational content
   - Multiple lesson types

10. **enhanced_tutorial_walkthrough_screen.dart** - 1,001 lines ⚠️ **P2**
    - Tutorial walkthrough
    - Multiple steps

**Impact:**
- Complex widget trees → more rebuilds
- Difficult to optimize individual components
- Harder to test and maintain

---

### 2.3 Image Assets

**Status:** ✅ **No oversized images found**

**Findings:**
- All image folders (`assets/images/`) contain only `.gitkeep` files
- No actual image files present in the repository
- App may be using external images or programmatic graphics

**Impact:**
- None - no oversized images to optimize
- Consider adding image optimization when images are added

---

### 2.4 withOpacity Calls (321 total)

**Issue:** `withOpacity()` calls during rebuilds can cause jank because they trigger paint operations.

#### Total Count
- **321 withOpacity calls** across the codebase
- Located primarily in `/lib/screens/` and `/lib/widgets/`

#### High-Traffic Screens with withOpacity
**analytics_screen.dart** - Multiple calls
- Line 295: `color.withOpacity(0.1)` - likely in a list or chart
- Line 297: `color.withOpacity(0.3)` - border color
- Line 785: `color.withOpacity(0.1)` - repeated pattern
- Line 787: `color.withOpacity(0.3)` - border color

**charts_screen.dart** - Multiple calls
- Line 359: `color.withOpacity(0.1)` - chart area background
- Line 365: `AppColors.textHint.withOpacity(0.8)` - text color
- Line 800: `_getParamColor(param).withOpacity(0.3)` - parameter selector

**enhanced_quiz_screen.dart** - Multiple calls
- Line 479: `color.withOpacity(0.1)` - quiz option background
- Line 481: `color.withOpacity(0.3)` - border color
- Line 634: `AppColors.warning.withOpacity(0.7)` - warning indicator
- Line 644: `withOpacity(0.3)` - overlay

**difficulty_settings_screen.dart** - Multiple calls
- Line 93: `withOpacity(0.2)` - skill indicator
- Line 220: `Colors.amber.withOpacity(0.2)` - warning indicator
- Line 281: `color.withOpacity(0.1)` - background
- Line 378: `withOpacity(0.2)` - score indicator
- Line 407: `withOpacity(0.2)` - score color

**Other screens with withOpacity:**
- `algae_guide_screen.dart` - 1 call
- `co2_calculator_screen.dart` - 2 calls
- `cost_tracker_screen.dart` - 1 call
- `disease_guide_screen.dart` - 1 call
- `equipment_screen.dart` - 2 calls
- `friend_comparison_screen.dart` - 1 call
- And many more...

**Impact:**
- Paint operations during rebuilds → jank
- Especially problematic in animated widgets
- High frequency in charts, quizzes, and analytics

---

## 3. Prioritized Fixes

### P0 - Critical (Must Fix)

#### 1. tank_detail_screen.dart - Split into smaller widgets (2440 lines)
- **Issue:** Extremely large file with complex widget tree
- **Impact:** Unnecessary rebuilds, difficult to optimize
- **Fix:** Split into separate widgets:
  - TankHeaderWidget
  - ParametersWidget
  - LogsWidget
  - LivestockWidget
  - etc.
- **Estimated Time:** 2-3 hours

#### 2. home_screen.dart - Split into smaller widgets (1715 lines)
- **Issue:** Main app screen with multiple features
- **Impact:** Critical - affects entire app performance
- **Fix:** Extract components:
  - TankSwitcherWidget
  - DashboardWidget
  - FloatingActionButtonsWidget
  - SearchBarWidget
- **Estimated Time:** 2-3 hours

#### 3. Non-builder ListViews in high-traffic screens
- **Issue:** ListViews without `.builder` pattern
- **Impact:** Jank when scrolling lists with many items
- **Fix:** Convert to ListView.builder for:
  - home_screen.dart
  - tank_detail_screen.dart
  - livestock_screen.dart
  - add_log_screen.dart
  - analytics_screen.dart
- **Estimated Time:** 30-45 minutes per file

#### 4. High-frequency withOpacity in animated widgets
- **Issue:** withOpacity calls in charts_screen.dart (animations)
- **Issue:** withOpacity calls in enhanced_quiz_screen.dart (animations)
- **Impact:** Paint operations during animations cause jank
- **Fix:** Use AnimatedOpacity or pre-computed colors with const
- **Estimated Time:** 1-2 hours

---

### P1 - High Priority (Should Fix)

#### 1. Large widget trees (>1000 lines)
- **settings_screen.dart** (1415 lines) - Split into settings widgets
- **livestock_screen.dart** (1345 lines) - Split livestock components
- **spaced_repetition_practice_screen.dart** (1230 lines) - Split quiz components
- **add_log_screen.dart** (1204 lines) - Split form components
- **analytics_screen.dart** (1156 lines) - Split chart components

- **Estimated Time:** 1-2 hours per file

#### 2. Non-builder ListViews in medium-traffic screens
- **Issue:** Remaining ListViews in guides and settings
- **Impact:** Potential jank in specific use cases
- **Fix:** Convert to ListView.builder:
  - activity_feed_screen.dart
  - equipment_screen.dart
  - cost_tracker_screen.dart
  - difficulty_settings_screen.dart
- **Estimated Time:** 15-20 minutes per file

#### 3. Static withOpacity calls
- **Issue:** withOpacity in non-animated widgets
- **Impact:** Minor paint overhead
- **Fix:** Pre-compute as const colors or use Color.lerp()
- **Estimated Time:** 2-3 hours total (321 calls to review)

---

### P2 - Medium Priority (Nice to Have)

#### 1. Remaining large widget trees (500-1000 lines)
- charts_screen.dart (1065 lines)
- lesson_screen.dart (1021 lines)
- enhanced_tutorial_walkthrough_screen.dart (1001 lines)

- **Estimated Time:** 1 hour per file

#### 2. Non-builder ListViews in low-traffic screens
- **Issue:** ListViews in guides and infrequent screens
- **Impact:** Minimal performance impact
- **Fix:** Convert to ListView.builder if needed
- **Estimated Time:** 10-15 minutes per file

---

## 4. Quick Wins Applied

### ✅ Build Fixes Applied
1. **Added missing _triggerTestCrash() method** in settings_screen.dart
   - Fixed build error: "The method '_triggerTestCrash' isn't defined"
   - Method throws test exception for error boundary testing

2. **Removed deprecated semanticLabel parameters** in home_screen.dart
   - Fixed build error: "No named parameter with the name 'semanticLabel'"
   - Replaced with tooltip (already present)

### ⚠️ Build Still Failing
- **Issue:** WSL file lock issue preventing clean build
- **Error:** `FileSystemException: Deletion failed, path = 'build'`
- **Recommendation:** Run from Windows PowerShell

---

## 5. Fix Plan

### Phase 1: Critical Performance (1-2 days)
1. **Split tank_detail_screen.dart** (2-3 hours)
2. **Split home_screen.dart** (2-3 hours)
3. **Convert high-traffic ListViews to ListView.builder** (2 hours)
4. **Fix animated withOpacity in charts_screen.dart** (1 hour)
5. **Fix animated withOpacity in enhanced_quiz_screen.dart** (1 hour)

### Phase 2: High Priority (2-3 days)
1. **Split remaining large widget trees** (8-10 hours total)
2. **Convert medium-traffic ListViews** (2 hours total)
3. **Optimize static withOpacity calls** (2-3 hours)

### Phase 3: Polish (1-2 days)
1. **Split remaining widget trees** (3 hours)
2. **Convert low-traffic ListViews** (2 hours)
3. **Profile and validate improvements** (1 hour)

---

## 6. Recommendations

### Immediate Actions
1. ✅ **Run build from Windows PowerShell** to get accurate build metrics
2. ✅ **Profile with DevTools** to identify actual jank sources
3. ✅ **Use Performance Overlay** during testing to see frame metrics

### Code Quality
1. **Establish widget size limits** (<500 lines per file)
2. **Use ListView.builder** by default for all lists
3. **Pre-compute colors** or use AnimatedOpacity for animations
4. **Extract widgets** to reduce rebuild scope

### Monitoring
1. **Add performance logging** for critical screens
2. **Track frame rates** in production
3. **Monitor build times** for regression detection

---

## 7. Next Steps

1. **Run build from Windows** to get accurate metrics
2. **Profile with Flutter DevTools**:
   ```bash
   flutter pub global activate devtools
   flutter pub global run devtools
   ```
3. **Apply Phase 1 fixes** for critical performance issues
4. **Measure improvement** with before/after profiling
5. **Commit changes** with detailed commit messages

---

## Appendix A: Build Output (Last Attempt)

```
Running Gradle task 'assembleDebug'...
FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:copyFlutterAssetsDebug'.
> Cannot access a file in the destination directory. Copying to a directory which contains unreadable content is not supported. Declare the task as untracked by using Task.doNotTrackState(). For more information, please refer to https://docs.gradle.org/8.14/userguide/incremental_build.html#sec:disable-state-tracking in the Gradle documentation.
   > java.nio.file.NoSuchFileException: /mnt/c/Users/larki/Documents/Aquarium App Dev/repo/apps/aquarium_app/build/app/intermediates/assets/debug/mergeDebugAssets/flutter_assets/NativeAssetsManifest.json

* Try:
Run with --stacktrace option to get the full trace.
Run with --info or --debug to get more log output.
Run with --scan for more comprehensive insights.

BUILD FAILED in 46s
```

---

## Appendix B: Dependency Updates Available

32 packages have newer versions incompatible with dependency constraints. Consider updating to get performance improvements:

- **Major updates with potential performance gains:**
  - fl_chart 0.69.2 → 1.1.1 (chart library - likely performance improvements)
  - flutter_riverpod 2.6.1 → 3.2.1 (state management - performance improvements)
  - riverpod 2.6.1 → 3.2.1
  - go_router 14.8.1 → 17.1.0 (navigation - performance improvements)

- **Run for details:** `flutter pub outdated`

---

**Report Generated:** 2025-02-14
**Agent:** Performance Profiling Subagent (task: #91c99a61-f23f-49bb-813d-d78f35e26e57)
