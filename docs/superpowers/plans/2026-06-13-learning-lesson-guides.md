# Learning Lesson Guides Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add structured, source-aware lesson guide metadata and render it on lesson pages so learning feels more practical, scenario-led, and review-ready.

**Architecture:** Extend the static lesson model with an optional `LessonLearningGuide` containing outcomes, a real-world scenario, care drill steps, and source references. Render the guide inside `LessonCardWidget` before the main lesson sections, and enrich the Nitrogen Cycle path first as the initial CL-P1-004 content slice.

**Tech Stack:** Flutter, Dart, Riverpod, Flutter widget tests, static lesson data.

---

### Task 1: Add Failing Tests

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/lesson_screen_test.dart`
- Modify: `apps/aquarium_app/test/data/lesson_data_test.dart`

- [ ] **Step 1: Add a widget test for lesson guide rendering**

Add a `Lesson` fixture with:

```dart
guide: const LessonLearningGuide(
  outcomes: [
    'Explain why ammonia is dangerous before fish show symptoms.',
    'Know the first safe action when a new tank tests unsafe.',
  ],
  scenario:
      'Your new tank looks clear, but fish are gasping near the surface.',
  careDrill: [
    'Test ammonia and nitrite before feeding again.',
    'Use a water change plan before adding more fish.',
  ],
  sources: [
    LessonSource(
      title: 'Water quality and fish health',
      publisher: 'Merck Veterinary Manual',
      url:
          'https://www.merckvetmanual.com/exotic-and-laboratory-animals/aquatic-systems/environmental-diseases-of-aquatic-animals-in-aquatic-systems',
      note: 'Water quality risks and emergency context.',
    ),
  ],
),
```

Assert the lesson page shows `You'll learn`, both outcome strings, `Real tank scenario`, the scenario text, `Care drill`, the drill steps, `References`, and `Merck Veterinary Manual`.

- [ ] **Step 2: Add a data contract for Nitrogen Cycle guides**

In `lesson_data_test.dart`, add a test that every `nitrogenCyclePath.lessons` item has a non-null guide with at least two outcomes, a non-empty scenario, at least two care drill steps, and at least one source with title, publisher, url, and note.

- [ ] **Step 3: Run focused tests and verify red**

Run:

```powershell
$env:JAVA_HOME = Join-Path $env:USERPROFILE 'development\jdk-21'
$env:ANDROID_SDK_ROOT = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$env:ANDROID_HOME = $env:ANDROID_SDK_ROOT
$env:Path = "$env:LOCALAPPDATA\Programs\Git\cmd;$env:USERPROFILE\development\flutter\bin;$env:JAVA_HOME\bin;$env:ANDROID_SDK_ROOT\platform-tools;$env:Path"
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/widget_tests/lesson_screen_test.dart test/data/lesson_data_test.dart
```

Expected: fails because `LessonLearningGuide`, `LessonSource`, and `Lesson.guide` do not exist yet.

### Task 2: Implement Model And Renderer

**Files:**
- Modify: `apps/aquarium_app/lib/models/learning.dart`
- Modify: `apps/aquarium_app/lib/screens/lesson/lesson_card_widget.dart`

- [ ] **Step 1: Add model types**

Add immutable `LessonLearningGuide` and `LessonSource` classes with const constructors and `toJson()`.

- [ ] **Step 2: Add optional guide to Lesson**

Add:

```dart
final LessonLearningGuide? guide;
```

to `Lesson`, add `this.guide,` to the constructor, and include `guide` in `toJson()` only when non-null.

- [ ] **Step 3: Render the guide card**

In `LessonCardWidget`, account for the optional guide in `itemCount`, insert it between the read-time row and the lesson sections, and render a compact guide card with:

- `You'll learn`
- outcome rows
- `Real tank scenario`
- scenario copy
- `Care drill`
- numbered drill rows
- `References`
- source title and publisher/note

- [ ] **Step 4: Run focused widget test and verify green for renderer**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/widget_tests/lesson_screen_test.dart --name "shows structured lesson guide"
```

Expected: pass.

### Task 3: Enrich Nitrogen Cycle Lessons

**Files:**
- Modify: `apps/aquarium_app/lib/data/lessons/nitrogen_cycle.dart`

- [ ] **Step 1: Add shared source constants**

Add lesson source constants for Merck Veterinary Manual, RSPCA fish advice, and ammonia/nitrogen-cycle education references already used by the local content where appropriate.

- [ ] **Step 2: Add guide metadata to all six Nitrogen Cycle lessons**

Each lesson gets:

- Two or more outcomes.
- One realistic tank scenario.
- Two or more care drill steps.
- One or more source references.

- [ ] **Step 3: Run focused data test and verify green**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/data/lesson_data_test.dart --name "every nitrogen cycle lesson has a structured guide"
```

Expected: pass.

### Task 4: Verify, Document, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [ ] **Step 1: Format edited Dart files**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\dart.bat" format lib/models/learning.dart lib/screens/lesson/lesson_card_widget.dart lib/data/lessons/nitrogen_cycle.dart test/widget_tests/lesson_screen_test.dart test/data/lesson_data_test.dart
```

- [ ] **Step 2: Normalize line endings on edited Dart files**

Use the repository LF normalization snippet from the active workstream notes.

- [ ] **Step 3: Run verification**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/widget_tests/lesson_screen_test.dart test/data/lesson_data_test.dart
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" analyze
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/copy/current_docs_local_truth_test.dart
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" build apk --debug --target lib/main.dart
```

- [ ] **Step 4: Update docs**

Record CL-P1-004A as the first learning-depth slice and update the total passing test count.

- [ ] **Step 5: Review diff and commit**

Run:

```powershell
git diff --check
git status --short
git add docs/superpowers/plans/2026-06-13-learning-lesson-guides.md apps/aquarium_app/lib/models/learning.dart apps/aquarium_app/lib/screens/lesson/lesson_card_widget.dart apps/aquarium_app/lib/data/lessons/nitrogen_cycle.dart apps/aquarium_app/test/widget_tests/lesson_screen_test.dart apps/aquarium_app/test/data/lesson_data_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md
git commit -m "feat: add structured lesson guides"
```
