# Advanced Topics Lesson Guides Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add structured learning guide metadata to every Advanced Topics lesson so expert learning has outcomes, real-tank scenarios, care drills, and source trails.

**Architecture:** Reuse the existing `LessonLearningGuide` model and attach guide metadata directly to `advanced_topics.dart`. Add shared source constants for breeding, livebearer, reproduction, and rehome-not-release evidence so this path can cite the same canonical source records as later Breeding/Aquascaping slices.

**Tech Stack:** Flutter, Dart, `flutter_test`.

---

### Task 1: Advanced Topics Guide Coverage Test

**Files:**
- Modify: `apps/aquarium_app/test/data/lesson_data_test.dart`

- [x] **Step 1: Write the failing test**

Add this test after the Species Care guide coverage test:

```dart
test('every advanced topics lesson has a structured guide', () {
  _expectStructuredGuides('Advanced Topics', advancedTopicsPath.lessons);
});
```

- [x] **Step 2: Run the focused test**

Run:

```powershell
$env:JAVA_HOME = Join-Path $env:USERPROFILE 'development\jdk-21'
$env:ANDROID_SDK_ROOT = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$env:ANDROID_HOME = $env:ANDROID_SDK_ROOT
$env:Path = "$env:LOCALAPPDATA\Programs\Git\cmd;$env:USERPROFILE\development\flutter\bin;$env:JAVA_HOME\bin;$env:ANDROID_SDK_ROOT\platform-tools;$env:Path"
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/data/lesson_data_test.dart --plain-name "every advanced topics lesson has a structured guide"
```

Expected: FAIL because `at_breeding_livebearers` has no structured guide.

### Task 2: Shared Advanced Sources

**Files:**
- Modify: `apps/aquarium_app/lib/data/lesson_sources.dart`

- [x] **Step 1: Add source constants**

Add these shared constants:

```dart
const lessonSourceMerckFishBreeding = LessonSource(
  title: 'Breeding and Reproduction of Fish',
  publisher: 'Merck Veterinary Manual',
  url:
      'https://www.merckvetmanual.com/all-other-pets/fish/breeding-and-reproduction-of-fish',
  note: 'Fish breeding triggers, livebearers, egg layers, and fry care.',
);

const lessonSourceInjafLivebearers = LessonSource(
  title: 'Beginners Guide to Livebearers',
  publisher: 'INJAF',
  url: 'https://injaf.org/aquarium-fish/beginners-guide-to-livebearers/',
  note: 'Livebearer care, water needs, breeding risk, and welfare context.',
);

const lessonSourceFishBaseReproduction = LessonSource(
  title: 'The REPRODUCTION Table',
  publisher: 'FishBase',
  url:
      'https://fishbase.se/manual/english/fishbasethe_REPRODUCTION_Table.htm',
  note: 'Reproductive mode, spawning behaviour, and reproductive guild context.',
);

const lessonSourceGovUkRehomeNotRelease = LessonSource(
  title: 'Why it is important to rehome rather than release unwanted fish',
  publisher: 'Marine Science Blog, GOV.UK',
  url:
      'https://marinescience.blog.gov.uk/2019/05/14/why-it-is-important-to-rehome-rather-than-release-unwanted-fish/',
  note: 'Environmental risk and rehoming guidance for unwanted aquarium fish.',
);
```

### Task 3: Advanced Topics Guide Metadata

**Files:**
- Modify: `apps/aquarium_app/lib/data/lessons/advanced_topics.dart`

- [x] **Step 1: Import shared lesson sources**

Add:

```dart
import '../lesson_sources.dart';
```

- [x] **Step 2: Add guide metadata**

Add `LessonLearningGuide` blocks to:
- `at_breeding_livebearers`
- `at_breeding_egg_layers`
- `at_aquascaping`
- `at_biotope`
- `at_troubleshooting`
- `at_water_chem`

Each guide must include at least two outcomes, a realistic scenario, at least two care drill steps, and one or more HTTPS source references.

- [x] **Step 3: Run the focused test**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/data/lesson_data_test.dart --plain-name "every advanced topics lesson has a structured guide"
```

Expected: PASS.

### Task 4: Format, Verify, Docs, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`

- [x] **Step 1: Format edited Dart files**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\dart.bat" format apps/aquarium_app/lib/data/lesson_sources.dart apps/aquarium_app/lib/data/lessons/advanced_topics.dart apps/aquarium_app/test/data/lesson_data_test.dart
```

- [x] **Step 2: Normalize edited Dart files to LF**

Normalize `lesson_sources.dart`, `advanced_topics.dart`, and `lesson_data_test.dart` to LF.

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

Expected: all commands exit 0. Full test count should increase by one from 1467 to 1468.

- [x] **Step 4: Update docs**

Record CL-P1-004I and update the verification count to 1468 tests.

- [x] **Step 5: Commit**

Run:

```powershell
git add docs/superpowers/plans/2026-06-13-advanced-topics-lesson-guides.md apps/aquarium_app/lib/data/lesson_sources.dart apps/aquarium_app/lib/data/lessons/advanced_topics.dart apps/aquarium_app/test/data/lesson_data_test.dart apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md
git commit -m "feat: expand advanced lesson guides"
```
