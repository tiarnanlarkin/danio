# Species Care Lesson Guides Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add structured learning guide metadata to every merged Species Care lesson so species-specific advice includes outcomes, real-tank scenarios, care drills, and source trails.

**Architecture:** Reuse `_mergedSpeciesCarePath` in the lesson data test and add broad species/welfare source constants for FishBase and RSPCA fish welfare. Attach `LessonLearningGuide` metadata directly to base and expanded Species Care lesson files without changing lesson order or quiz content.

**Tech Stack:** Flutter, Dart, `flutter_test`.

---

### Task 1: Species Care Guide Coverage Test

**Files:**
- Modify: `apps/aquarium_app/test/data/lesson_data_test.dart`

- [x] **Step 1: Write the failing test**

Add this test after the Fish Health guide coverage test:

```dart
test('every species care lesson has a structured guide', () {
  _expectStructuredGuides('Species Care', _mergedSpeciesCarePath.lessons);
});
```

- [x] **Step 2: Run the focused test**

Run:

```powershell
$env:JAVA_HOME = Join-Path $env:USERPROFILE 'development\jdk-21'
$env:ANDROID_SDK_ROOT = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$env:ANDROID_HOME = $env:ANDROID_SDK_ROOT
$env:Path = "$env:LOCALAPPDATA\Programs\Git\cmd;$env:USERPROFILE\development\flutter\bin;$env:JAVA_HOME\bin;$env:ANDROID_SDK_ROOT\platform-tools;$env:Path"
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/data/lesson_data_test.dart --plain-name "every species care lesson has a structured guide"
```

Expected: FAIL because `sc_betta` has no structured guide.

### Task 2: Shared Species Sources

**Files:**
- Modify: `apps/aquarium_app/lib/data/lesson_sources.dart`

- [x] **Step 1: Add broad species/welfare sources**

Add `LessonSource` constants for FishBase and RSPCA freshwater fish welfare.

### Task 3: Base Species Care Guides

**Files:**
- Modify: `apps/aquarium_app/lib/data/lessons/species_care.dart`

- [x] **Step 1: Import shared lesson sources**

Add:

```dart
import '../lesson_sources.dart';
```

- [x] **Step 2: Add guide metadata**

Add `LessonLearningGuide` blocks to:
- `sc_betta`
- `sc_goldfish`
- `sc_tetras`
- `sc_cichlids`
- `sc_shrimp`
- `sc_snails`

### Task 4: Expanded Species Care Guides

**Files:**
- Modify: `apps/aquarium_app/lib/data/lessons/species_care_expanded.dart`

- [x] **Step 1: Import shared lesson sources**

Add:

```dart
import '../lesson_sources.dart';
```

- [x] **Step 2: Add guide metadata**

Add `LessonLearningGuide` blocks to:
- `sc_corydoras`
- `sc_livebearers`
- `sc_rasboras`
- `sc_angelfish`
- `sc_plecos`
- `sc_gouramis`
- `sc_loaches`

- [x] **Step 3: Run the focused test**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/data/lesson_data_test.dart --plain-name "every species care lesson has a structured guide"
```

Expected: PASS.

### Task 5: Format, Verify, Docs, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`

- [x] **Step 1: Format edited Dart files**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\dart.bat" format apps/aquarium_app/lib/data/lesson_sources.dart apps/aquarium_app/lib/data/lessons/species_care.dart apps/aquarium_app/lib/data/lessons/species_care_expanded.dart apps/aquarium_app/test/data/lesson_data_test.dart
```

- [x] **Step 2: Normalize edited Dart files to LF**

Normalize `lesson_sources.dart`, `species_care.dart`, `species_care_expanded.dart`, and `lesson_data_test.dart` to LF.

- [x] **Step 3: Run verification**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/data/lesson_data_test.dart
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" analyze
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/copy/current_docs_local_truth_test.dart
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" build apk --debug --target lib/main.dart
git diff --check
```

Expected: all commands exit 0. Full test count should increase by one from 1466 to 1467.

- [x] **Step 4: Update docs**

Record CL-P1-004H and update the verification count to 1467 tests.

- [x] **Step 5: Commit**

Run:

```powershell
git add docs/superpowers/plans/2026-06-13-species-care-lesson-guides.md apps/aquarium_app/lib/data/lesson_sources.dart apps/aquarium_app/lib/data/lessons/species_care.dart apps/aquarium_app/lib/data/lessons/species_care_expanded.dart apps/aquarium_app/test/data/lesson_data_test.dart apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md
git commit -m "feat: expand species care lesson guides"
```
