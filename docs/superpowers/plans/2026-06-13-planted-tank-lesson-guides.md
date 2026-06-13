# Planted Tank Lesson Guides Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add structured learning guide metadata to every Planted Tanks lesson so the path matches the current content-rich lesson standard.

**Architecture:** Reuse the existing `LessonLearningGuide` model and `LessonSource` constants. Add plant-focused shared source constants once, then attach outcomes, real-tank scenarios, care drills, and sources directly to the five Planted Tanks lessons.

**Tech Stack:** Flutter, Dart, Riverpod-adjacent lesson data, `flutter_test`.

---

### Task 1: Planted Tanks Guide Coverage Test

**Files:**
- Modify: `apps/aquarium_app/test/data/lesson_data_test.dart`

- [ ] **Step 1: Write the failing test**

Add this test after the Maintenance guide coverage test:

```dart
test('every planted tank lesson has a structured guide', () {
  _expectStructuredGuides('Planted Tanks', plantedTankPath.lessons);
});
```

- [ ] **Step 2: Run the focused data test to verify it fails**

Run:

```powershell
$env:JAVA_HOME = Join-Path $env:USERPROFILE 'development\jdk-21'
$env:ANDROID_SDK_ROOT = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$env:ANDROID_HOME = $env:ANDROID_SDK_ROOT
$env:Path = "$env:LOCALAPPDATA\Programs\Git\cmd;$env:USERPROFILE\development\flutter\bin;$env:JAVA_HOME\bin;$env:ANDROID_SDK_ROOT\platform-tools;$env:Path"
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/data/lesson_data_test.dart --plain-name "every planted tank lesson has a structured guide"
```

Expected: FAIL because `planted_basics` has no structured guide.

### Task 2: Shared Plant Lesson Sources

**Files:**
- Modify: `apps/aquarium_app/lib/data/lesson_sources.dart`

- [ ] **Step 1: Add shared source constants**

Append:

```dart
const lessonSourceTropicaPlants = LessonSource(
  title: 'Aquarium Plants',
  publisher: 'Tropica',
  url: 'https://tropica.com/en/plants/',
  note: 'Plant requirements, difficulty, growth, and layout context.',
);

const lessonSourceTropicaCare = LessonSource(
  title: 'Care',
  publisher: 'Tropica',
  url: 'https://tropica.com/en/guide/care/',
  note: 'Planted aquarium care, water changes, waste removal, and balance.',
);

const lessonSourceInjafAquariumPlants = LessonSource(
  title: "Beginner's Guide to Aquarium Plants",
  publisher: 'INJAF',
  url:
      'https://injaf.org/articles-guides/beginners-guides/beginners-guide-to-aquarium-plants/',
  note: 'Beginner plant choices, planting, and care guidance.',
);
```

### Task 3: Planted Tanks Guide Metadata

**Files:**
- Modify: `apps/aquarium_app/lib/data/lessons/planted_tank.dart`

- [ ] **Step 1: Import shared lesson sources**

Add:

```dart
import '../lesson_sources.dart';
```

- [ ] **Step 2: Add guide metadata to all five Planted Tanks lessons**

Each lesson must have:
- At least two `outcomes`.
- A realistic `scenario`.
- At least two `careDrill` steps.
- At least one shared `LessonSource`.

Use source-backed guide content for:
- `planted_basics`
- `planted_light`
- `planted_substrate`
- `planted_co2`
- `planted_propagation`

- [ ] **Step 3: Run focused data test to verify it passes**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/data/lesson_data_test.dart --plain-name "every planted tank lesson has a structured guide"
```

Expected: PASS.

### Task 4: Format, Verify, Docs, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`

- [ ] **Step 1: Format edited Dart files**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\dart.bat" format apps/aquarium_app/lib/data/lesson_sources.dart apps/aquarium_app/lib/data/lessons/planted_tank.dart apps/aquarium_app/test/data/lesson_data_test.dart
```

- [ ] **Step 2: Normalize edited Dart files to LF**

Normalize line endings on the edited Dart files.

- [ ] **Step 3: Run verification**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/data/lesson_data_test.dart
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" analyze
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/copy/current_docs_local_truth_test.dart
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" build apk --debug --target lib/main.dart
git diff --check
```

Expected: all commands exit 0. Full test count should increase by one from 1463 to 1464.

- [ ] **Step 4: Update docs**

Record CL-P1-004E and update the verification count to 1464 tests.

- [ ] **Step 5: Commit**

Run:

```powershell
git add docs/superpowers/plans/2026-06-13-planted-tank-lesson-guides.md apps/aquarium_app/lib/data/lesson_sources.dart apps/aquarium_app/lib/data/lessons/planted_tank.dart apps/aquarium_app/test/data/lesson_data_test.dart apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md
git commit -m "feat: expand planted lesson guides"
```
