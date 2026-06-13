# Water Parameters Lesson Guides Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extend structured lesson guide coverage from Nitrogen Cycle into the Water Parameters path.

**Architecture:** Add a focused data contract for `waterParametersPath.lessons`, create shared lesson source references for reusable citation data, and add outcomes, scenarios, care drills, and references to each Water Parameters lesson.

**Tech Stack:** Flutter, Dart, static lesson data, Flutter tests.

---

### Task 1: Add Failing Data Test

**Files:**
- Modify: `apps/aquarium_app/test/data/lesson_data_test.dart`

- [ ] **Step 1: Add Water Parameters guide contract**

Add a test named `every water parameters lesson has a structured guide`.
For each `waterParametersPath.lessons` item, assert:

- `lesson.guide` is not null.
- `guide.outcomes.length >= 2`.
- `guide.scenario.trim().isNotEmpty`.
- `guide.careDrill.length >= 2`.
- `guide.sources.isNotEmpty`.
- Each source has non-empty title, publisher, note, and an `https://` URL.

- [ ] **Step 2: Run focused test and verify red**

Run:

```powershell
$env:JAVA_HOME = Join-Path $env:USERPROFILE 'development\jdk-21'
$env:ANDROID_SDK_ROOT = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$env:ANDROID_HOME = $env:ANDROID_SDK_ROOT
$env:Path = "$env:LOCALAPPDATA\Programs\Git\cmd;$env:USERPROFILE\development\flutter\bin;$env:JAVA_HOME\bin;$env:ANDROID_SDK_ROOT\platform-tools;$env:Path"
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/data/lesson_data_test.dart --name "every water parameters lesson has a structured guide"
```

Expected: fails because Water Parameters lessons do not yet have guides.

### Task 2: Add Shared Sources And Water Guides

**Files:**
- Create: `apps/aquarium_app/lib/data/lesson_sources.dart`
- Modify: `apps/aquarium_app/lib/data/lessons/nitrogen_cycle.dart`
- Modify: `apps/aquarium_app/lib/data/lessons/water_parameters.dart`

- [ ] **Step 1: Create shared source constants**

Move reusable lesson references into `lesson_sources.dart`:

- INJAF Nitrogen Cycle and Fishless Cycle.
- Merck Veterinary Manual environmental water quality.
- Merck Veterinary Manual normal water quality ranges.
- RSPCA aquarium setup water quality.
- RSPCA UK fish environment advice.

- [ ] **Step 2: Update Nitrogen Cycle imports**

Import `../lesson_sources.dart` from `nitrogen_cycle.dart` and remove the private duplicated source constants.

- [ ] **Step 3: Add Water Parameters guides**

Add `LessonLearningGuide` metadata to all six Water Parameters lessons:

- pH.
- Temperature.
- GH/KH.
- Chlorine/chloramine.
- TDS.
- Seasonal water challenges.

- [ ] **Step 4: Run focused test and verify green**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/data/lesson_data_test.dart --name "every water parameters lesson has a structured guide"
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

Record CL-P1-004B and update the test count.

- [ ] **Step 4: Review diff and commit**

Run `git diff --check`, review status, and commit:

```powershell
git commit -m "feat: expand lesson guide coverage"
```
