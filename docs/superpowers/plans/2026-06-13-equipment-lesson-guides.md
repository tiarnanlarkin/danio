# Equipment Lesson Guides Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add structured learning guide metadata to every merged Equipment lesson so the path matches the current lesson-depth standard.

**Architecture:** Reuse the existing merged Equipment test path, `LessonLearningGuide`, and shared `LessonSource` constants. Attach guide metadata directly in the base and expanded Equipment lesson files without changing lesson order, quiz content, or provider metadata.

**Tech Stack:** Flutter, Dart, `flutter_test`.

---

### Task 1: Equipment Guide Coverage Test

**Files:**
- Modify: `apps/aquarium_app/test/data/lesson_data_test.dart`

- [ ] **Step 1: Write the failing test**

Add this test after the Planted Tanks guide coverage test:

```dart
test('every equipment lesson has a structured guide', () {
  _expectStructuredGuides('Equipment', _mergedEquipmentPath.lessons);
});
```

- [ ] **Step 2: Run the focused test**

Run:

```powershell
$env:JAVA_HOME = Join-Path $env:USERPROFILE 'development\jdk-21'
$env:ANDROID_SDK_ROOT = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$env:ANDROID_HOME = $env:ANDROID_SDK_ROOT
$env:Path = "$env:LOCALAPPDATA\Programs\Git\cmd;$env:USERPROFILE\development\flutter\bin;$env:JAVA_HOME\bin;$env:ANDROID_SDK_ROOT\platform-tools;$env:Path"
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/data/lesson_data_test.dart --plain-name "every equipment lesson has a structured guide"
```

Expected: FAIL because `eq_filters` has no structured guide.

### Task 2: Base Equipment Guides

**Files:**
- Modify: `apps/aquarium_app/lib/data/lessons/equipment.dart`

- [ ] **Step 1: Import shared lesson sources**

Add:

```dart
import '../lesson_sources.dart';
```

- [ ] **Step 2: Add guide metadata**

Add `LessonLearningGuide` blocks to:
- `eq_filters`
- `eq_heaters`
- `eq_lighting`

Use existing shared sources: INJAF nitrogen cycle, RSPCA environment/water quality, Merck water quality/ranges/home, and Tropica care where relevant.

### Task 3: Expanded Equipment Guides

**Files:**
- Modify: `apps/aquarium_app/lib/data/lessons/equipment_expanded.dart`

- [ ] **Step 1: Import shared lesson sources**

Add:

```dart
import '../lesson_sources.dart';
```

- [ ] **Step 2: Add guide metadata**

Add `LessonLearningGuide` blocks to:
- `eq_test_kits`
- `eq_setup_guide`
- `eq_filter_maintenance`
- `eq_water_change_gear`
- `eq_air_pumps`
- `eq_co2_systems`
- `eq_aquascape_tools`
- `eq_substrate`

Each guide must include at least two outcomes, one realistic scenario, at least two care-drill steps, and shared source references.

- [ ] **Step 3: Run the focused test**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/data/lesson_data_test.dart --plain-name "every equipment lesson has a structured guide"
```

Expected: PASS.

### Task 4: Format, Verify, Docs, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`

- [ ] **Step 1: Format edited Dart files**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\dart.bat" format apps/aquarium_app/lib/data/lessons/equipment.dart apps/aquarium_app/lib/data/lessons/equipment_expanded.dart apps/aquarium_app/test/data/lesson_data_test.dart
```

- [ ] **Step 2: Normalize edited Dart files to LF**

Normalize `equipment.dart`, `equipment_expanded.dart`, and `lesson_data_test.dart` to LF.

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

Expected: all commands exit 0. Full test count should increase by one from 1464 to 1465.

- [ ] **Step 4: Update docs**

Record CL-P1-004F and update the verification count to 1465 tests.

- [ ] **Step 5: Commit**

Run:

```powershell
git add docs/superpowers/plans/2026-06-13-equipment-lesson-guides.md apps/aquarium_app/lib/data/lessons/equipment.dart apps/aquarium_app/lib/data/lessons/equipment_expanded.dart apps/aquarium_app/test/data/lesson_data_test.dart apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md
git commit -m "feat: expand equipment lesson guides"
```
