# Troubleshooting Lesson Guides Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add structured learning guide metadata to every Troubleshooting & Emergencies lesson so emergency learning is practical, source-backed, and safe for normal users.

**Architecture:** Reuse existing shared water-quality, fish-health, environment, and disease-management source constants from `lesson_sources.dart`. Attach `LessonLearningGuide` metadata directly to `troubleshooting.dart` without changing lesson order, prerequisites, or quiz answers.

**Tech Stack:** Flutter, Dart, `flutter_test`.

---

### Task 1: Troubleshooting Guide Coverage Test

**Files:**
- Modify: `apps/aquarium_app/test/data/lesson_data_test.dart`

- [x] **Step 1: Write the failing test**

Add this test after the Breeding Basics guide coverage test:

```dart
test('every troubleshooting lesson has a structured guide', () {
  _expectStructuredGuides('Troubleshooting', troubleshootingPath.lessons);
});
```

- [x] **Step 2: Run the focused test**

Run:

```powershell
$env:JAVA_HOME = Join-Path $env:USERPROFILE 'development\jdk-21'
$env:ANDROID_SDK_ROOT = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$env:ANDROID_HOME = $env:ANDROID_SDK_ROOT
$env:Path = "$env:LOCALAPPDATA\Programs\Git\cmd;$env:USERPROFILE\development\flutter\bin;$env:JAVA_HOME\bin;$env:ANDROID_SDK_ROOT\platform-tools;$env:Path"
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/data/lesson_data_test.dart --plain-name "every troubleshooting lesson has a structured guide"
```

Expected: FAIL because `tr_emergency` has no structured guide.

### Task 2: Troubleshooting Guide Metadata

**Files:**
- Modify: `apps/aquarium_app/lib/data/lessons/troubleshooting.dart`

- [x] **Step 1: Import shared lesson sources**

Add:

```dart
import '../lesson_sources.dart';
```

- [x] **Step 2: Add guide metadata**

Add `LessonLearningGuide` blocks to:
- `tr_emergency`
- `tr_disease_diagnosis`
- `tr_cloudy_water`
- `tr_power_outage`
- `tr_temperature_crash`
- `tr_ph_crash`

Each guide must include at least two outcomes, a realistic scenario, at least two care drill steps, and one or more HTTPS source references.

- [x] **Step 3: Run the focused test**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/data/lesson_data_test.dart --plain-name "every troubleshooting lesson has a structured guide"
```

Expected: PASS.

### Task 3: Format, Verify, Docs, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`

- [x] **Step 1: Format edited Dart files**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\dart.bat" format apps/aquarium_app/lib/data/lessons/troubleshooting.dart apps/aquarium_app/test/data/lesson_data_test.dart
```

- [x] **Step 2: Normalize edited Dart files to LF**

Normalize `troubleshooting.dart` and `lesson_data_test.dart` to LF.

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

Expected: all commands exit 0. Full test count should increase by one from 1470 to 1471.

- [x] **Step 4: Update docs**

Record CL-P1-004L, update the verification count to 1471 tests, and note that every current learning path now has structured guide coverage.

- [x] **Step 5: Commit**

Run:

```powershell
git add docs/superpowers/plans/2026-06-13-troubleshooting-lesson-guides.md apps/aquarium_app/lib/data/lessons/troubleshooting.dart apps/aquarium_app/test/data/lesson_data_test.dart apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md
git commit -m "feat: expand troubleshooting lesson guides"
```
