# Aquascaping Lesson Guides Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add structured learning guide metadata to every Aquascaping & Design lesson so layout, plant placement, fertilisation, and algae management become actionable care guidance.

**Architecture:** Reuse existing shared plant, care, water-quality, and source references from `lesson_sources.dart`. Attach `LessonLearningGuide` metadata directly to `aquascaping.dart` without changing quiz content, lesson order, or prerequisites.

**Tech Stack:** Flutter, Dart, `flutter_test`.

---

### Task 1: Aquascaping Guide Coverage Test

**Files:**
- Modify: `apps/aquarium_app/test/data/lesson_data_test.dart`

- [x] **Step 1: Write the failing test**

Add this test after the Advanced Topics guide coverage test:

```dart
test('every aquascaping lesson has a structured guide', () {
  _expectStructuredGuides('Aquascaping', aquascapingPath.lessons);
});
```

- [x] **Step 2: Run the focused test**

Run:

```powershell
$env:JAVA_HOME = Join-Path $env:USERPROFILE 'development\jdk-21'
$env:ANDROID_SDK_ROOT = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$env:ANDROID_HOME = $env:ANDROID_SDK_ROOT
$env:Path = "$env:LOCALAPPDATA\Programs\Git\cmd;$env:USERPROFILE\development\flutter\bin;$env:JAVA_HOME\bin;$env:ANDROID_SDK_ROOT\platform-tools;$env:Path"
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/data/lesson_data_test.dart --plain-name "every aquascaping lesson has a structured guide"
```

Expected: FAIL because `aq_layout_styles` has no structured guide.

### Task 2: Aquascaping Guide Metadata

**Files:**
- Modify: `apps/aquarium_app/lib/data/lessons/aquascaping.dart`

- [x] **Step 1: Import shared lesson sources**

Add:

```dart
import '../lesson_sources.dart';
```

- [x] **Step 2: Add guide metadata**

Add `LessonLearningGuide` blocks to:
- `aq_layout_styles`
- `aq_plant_zones`
- `aq_fertilisation`
- `aq_algae_management`

Each guide must include at least two outcomes, a realistic scenario, at least two care drill steps, and one or more HTTPS source references.

- [x] **Step 3: Run the focused test**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/data/lesson_data_test.dart --plain-name "every aquascaping lesson has a structured guide"
```

Expected: PASS.

### Task 3: Format, Verify, Docs, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`

- [x] **Step 1: Format edited Dart files**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\dart.bat" format apps/aquarium_app/lib/data/lessons/aquascaping.dart apps/aquarium_app/test/data/lesson_data_test.dart
```

- [x] **Step 2: Normalize edited Dart files to LF**

Normalize `aquascaping.dart` and `lesson_data_test.dart` to LF.

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

Expected: all commands exit 0. Full test count should increase by one from 1468 to 1469.

- [x] **Step 4: Update docs**

Record CL-P1-004J and update the verification count to 1469 tests.

- [x] **Step 5: Commit**

Run:

```powershell
git add docs/superpowers/plans/2026-06-13-aquascaping-lesson-guides.md apps/aquarium_app/lib/data/lessons/aquascaping.dart apps/aquarium_app/test/data/lesson_data_test.dart apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md
git commit -m "feat: expand aquascaping lesson guides"
```
