# Fish Health Lesson Guides Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add structured learning guide metadata to every Fish Health lesson so illness, treatment, and hospital-tank topics become safer, more actionable, and source-backed.

**Architecture:** Add official fish-health source constants to `lesson_sources.dart`, then attach `LessonLearningGuide` metadata directly to `fish_health.dart`. Do not alter emergency accessibility, lesson ordering, quiz answers, or treatment copy outside guide metadata.

**Tech Stack:** Flutter, Dart, `flutter_test`.

---

### Task 1: Fish Health Guide Coverage Test

**Files:**
- Modify: `apps/aquarium_app/test/data/lesson_data_test.dart`

- [ ] **Step 1: Write the failing test**

Add this test after the Equipment guide coverage test:

```dart
test('every fish health lesson has a structured guide', () {
  _expectStructuredGuides('Fish Health', fishHealthPath.lessons);
});
```

- [ ] **Step 2: Run the focused test**

Run:

```powershell
$env:JAVA_HOME = Join-Path $env:USERPROFILE 'development\jdk-21'
$env:ANDROID_SDK_ROOT = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$env:ANDROID_HOME = $env:ANDROID_SDK_ROOT
$env:Path = "$env:LOCALAPPDATA\Programs\Git\cmd;$env:USERPROFILE\development\flutter\bin;$env:JAVA_HOME\bin;$env:ANDROID_SDK_ROOT\platform-tools;$env:Path"
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/data/lesson_data_test.dart --plain-name "every fish health lesson has a structured guide"
```

Expected: FAIL because `fh_prevention` has no structured guide.

### Task 2: Fish Health Source References

**Files:**
- Modify: `apps/aquarium_app/lib/data/lesson_sources.dart`

- [ ] **Step 1: Add official health sources**

Add reusable `LessonSource` constants for Merck fish diseases, Merck aquarium fish management, RSPCA fish health, and CDC fish health guidance.

### Task 3: Fish Health Guide Metadata

**Files:**
- Modify: `apps/aquarium_app/lib/data/lessons/fish_health.dart`

- [ ] **Step 1: Import shared lesson sources**

Add:

```dart
import '../lesson_sources.dart';
```

- [ ] **Step 2: Add guide metadata**

Add `LessonLearningGuide` blocks to:
- `fh_prevention`
- `fh_ich`
- `fh_fin_rot`
- `fh_fungal`
- `fh_parasites`
- `fh_medication_dosing`
- `fh_hospital_tank`

Each guide must include at least two outcomes, one realistic scenario, at least two care-drill steps, and source references.

- [ ] **Step 3: Run the focused test**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/data/lesson_data_test.dart --plain-name "every fish health lesson has a structured guide"
```

Expected: PASS.

### Task 4: Format, Verify, Docs, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`

- [ ] **Step 1: Format edited Dart files**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\dart.bat" format apps/aquarium_app/lib/data/lesson_sources.dart apps/aquarium_app/lib/data/lessons/fish_health.dart apps/aquarium_app/test/data/lesson_data_test.dart
```

- [ ] **Step 2: Normalize edited Dart files to LF**

Normalize `lesson_sources.dart`, `fish_health.dart`, and `lesson_data_test.dart` to LF.

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

Expected: all commands exit 0. Full test count should increase by one from 1465 to 1466.

- [ ] **Step 4: Update docs**

Record CL-P1-004G and update the verification count to 1466 tests.

- [ ] **Step 5: Commit**

Run:

```powershell
git add docs/superpowers/plans/2026-06-13-fish-health-lesson-guides.md apps/aquarium_app/lib/data/lesson_sources.dart apps/aquarium_app/lib/data/lessons/fish_health.dart apps/aquarium_app/test/data/lesson_data_test.dart apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md
git commit -m "feat: expand fish health lesson guides"
```
