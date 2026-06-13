# Lesson Emergency Access Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep Emergency Guide directly reachable while users are reading lesson content.

**Architecture:** Add a compact `Emergency Guide` app-bar action to `LessonScreen` for normal lessons. Route through `NavigationThrottle` to the existing `EmergencyGuideScreen`. Update `lesson_screen_test.dart` with navigation coverage.

**Tech Stack:** Flutter, Riverpod, existing `LessonScreen`, `EmergencyGuideScreen`, `NavigationThrottle`, and widget tests.

---

## File Structure

- Modify `apps/aquarium_app/test/widget_tests/lesson_screen_test.dart`: add a widget test for opening Emergency Guide from LessonScreen.
- Modify `apps/aquarium_app/lib/screens/lesson/lesson_screen.dart`: add the app-bar action.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`: record CL-P0-006F progress.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`: update CL-P0-006 status.

---

### Task 1: Lesson Emergency Entry Test

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/lesson_screen_test.dart`

- [x] **Step 1: Write failing widget test**

Add imports for `EmergencyGuideScreen` and `NavigationThrottle`, reset throttle in `setUp`, then add a test that expects a lesson app-bar `Emergency Guide` action and verifies navigation.

- [x] **Step 2: Run test to verify failure**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/lesson_screen_test.dart
```

Expected initial result: FAIL because `LessonScreen` does not yet expose Emergency Guide.

---

### Task 2: Lesson App-Bar Action

**Files:**
- Modify: `apps/aquarium_app/lib/screens/lesson/lesson_screen.dart`

- [x] **Step 1: Add imports**

Import `navigation_throttle.dart` and `emergency_guide_screen.dart`.

- [x] **Step 2: Add normal-lesson action**

Add an app-bar `IconButton` with `Icons.emergency_outlined`, tooltip `Emergency Guide`, and route to `const EmergencyGuideScreen()` through `NavigationThrottle.push(... rootNavigator: true)`.

---

### Task 3: Docs

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [x] **Step 1: Update product tracking**

Record `CL-P0-006F` as Lesson emergency access progress and remove lessons from the remaining emergency-entry list.

---

### Task 4: Verification And Commit

**Files:**
- All files touched in Tasks 1-3

- [x] **Step 1: Format changed Dart files**

Run:

```powershell
cd apps/aquarium_app
dart format lib/screens/lesson/lesson_screen.dart test/widget_tests/lesson_screen_test.dart
```

- [x] **Step 2: Run focused test**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/lesson_screen_test.dart
```

- [x] **Step 3: Run analyzer**

Run:

```powershell
cd apps/aquarium_app
flutter analyze
```

- [x] **Step 4: Check diff**

Run:

```powershell
git diff --check
git diff -- apps/aquarium_app/lib/screens/lesson/lesson_screen.dart apps/aquarium_app/test/widget_tests/lesson_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-lesson-emergency-access.md
```

- [x] **Step 5: Commit**

Run:

```powershell
git add apps/aquarium_app/lib/screens/lesson/lesson_screen.dart apps/aquarium_app/test/widget_tests/lesson_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-lesson-emergency-access.md
git commit -m "feat: add lesson emergency access"
```
