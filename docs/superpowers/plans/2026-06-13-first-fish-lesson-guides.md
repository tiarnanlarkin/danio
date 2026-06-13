# First Fish Lesson Guides Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extend structured lesson guide coverage to the beginner `First Fish` path.

**Architecture:** Add a path-level data contract, extend shared lesson source references, and add guide metadata to all First Fish lessons using the existing `LessonLearningGuide` schema.

**Tech Stack:** Flutter, Dart, static lesson data, Flutter tests.

---

### Task 1: Add Failing Data Test

**Files:**
- Modify: `apps/aquarium_app/test/data/lesson_data_test.dart`

- [ ] **Step 1: Add First Fish guide contract**

Add a test named `every first fish lesson has a structured guide` that calls:

```dart
_expectStructuredGuides('First Fish', firstFishPath.lessons);
```

- [ ] **Step 2: Run focused test and verify red**

Run:

```powershell
$env:JAVA_HOME = Join-Path $env:USERPROFILE 'development\jdk-21'
$env:ANDROID_SDK_ROOT = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$env:ANDROID_HOME = $env:ANDROID_SDK_ROOT
$env:Path = "$env:LOCALAPPDATA\Programs\Git\cmd;$env:USERPROFILE\development\flutter\bin;$env:JAVA_HOME\bin;$env:ANDROID_SDK_ROOT\platform-tools;$env:Path"
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/data/lesson_data_test.dart --name "every first fish lesson has a structured guide"
```

Expected: fails because First Fish lessons do not yet have guides.

### Task 2: Add Sources And First Fish Guides

**Files:**
- Modify: `apps/aquarium_app/lib/data/lesson_sources.dart`
- Modify: `apps/aquarium_app/lib/data/lessons/first_fish.dart`

- [ ] **Step 1: Add reusable source constants**

Add source constants for:

- Merck Veterinary Manual, `Providing a Home for Fish`.
- Merck Veterinary Manual, `Routine Health Care of Fish`.
- RSPCA, fish diet/feeding advice.
- RSPCA Knowledgebase, tropical fish care.

- [ ] **Step 2: Import shared sources in First Fish**

Add:

```dart
import '../lesson_sources.dart';
```

- [ ] **Step 3: Add guide metadata to all six First Fish lessons**

Each lesson gets:

- Two or more outcomes.
- One realistic tank scenario.
- Two or more care drill steps.
- One or more source references.

- [ ] **Step 4: Run focused test and verify green**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/data/lesson_data_test.dart --name "every first fish lesson has a structured guide"
```

Expected: pass.

### Task 3: Verify, Document, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [ ] **Step 1: Format and normalize**

Run `dart format` on edited Dart files and normalize LF line endings.

- [ ] **Step 2: Run verification**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/data/lesson_data_test.dart
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" analyze
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/copy/current_docs_local_truth_test.dart
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" build apk --debug --target lib/main.dart
```

- [ ] **Step 3: Update docs**

Record CL-P1-004C and update the test count.

- [ ] **Step 4: Review diff and commit**

Run `git diff --check`, review status, and commit:

```powershell
git commit -m "feat: expand beginner lesson guides"
```
