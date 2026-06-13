# Unit Converter Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Polish the Unit Converter so visible temperature and hardness units are readable, ASCII-safe, and trustworthy for normal users.

**Architecture:** Keep the existing tabbed converter structure. Replace mojibake unit labels with plain unit labels (`C`, `F`, `K`, `ppm CaCO3`, `mg/L CaCO3`) and add widget coverage that verifies temperature labels/conversion output and touched-file encoding hygiene.

**Tech Stack:** Flutter, Dart, existing widget tests.

---

### Task 1: Unit Label Tests

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/unit_converter_screen_test.dart`
- Modify: `apps/aquarium_app/lib/screens/unit_converter_screen.dart`

- [x] **Step 1: Write failing tests**

Add tests that:

- open the Temperature tab and verify `C`, `F`, and `K` are visible while mojibake Celsius/Fahrenheit labels are not visible
- enter `0` on the Temperature tab and verify Fahrenheit conversion displays `32.00` or `32.0`
- open the Hardness tab and verify `ppm CaCO3` is visible while mojibake CaCO3 labels are not visible

- [x] **Step 2: Run Unit Converter test red**

Run:

```powershell
flutter test test/widget_tests/unit_converter_screen_test.dart
```

Expected: fail because the current screen still renders mojibake temperature and hardness labels.

- [x] **Step 3: Implement label cleanup**

Update `UnitConverterScreen` so:

- temperature source unit defaults to `C`
- temperature dropdown items are `C`, `F`, and `K`
- conversion outputs use `C`, `F`, and `K`
- conversion methods switch on `F`, not the mojibake Fahrenheit label
- hardness units use `ppm CaCO3` and `mg/L CaCO3`
- touched comments/tests are ASCII-clean

- [x] **Step 4: Run Unit Converter test green**

Run:

```powershell
flutter test test/widget_tests/unit_converter_screen_test.dart
```

Expected: pass.

### Task 2: Docs, Verification, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [x] **Step 1: Update docs**

Record CL-P1-006H as Unit Converter polish: ASCII-safe unit labels and focused coverage.

- [x] **Step 2: Run verification**

Run:

```powershell
flutter analyze
flutter test
flutter test test/copy/current_docs_local_truth_test.dart
flutter build apk --debug --target lib/main.dart
git diff --check
```

Expected: analyzer clean, full suite passes with updated count, docs truth passes, debug APK builds with only the existing Kotlin Gradle Plugin warning, and diff check is clean.

- [x] **Step 3: Commit**

Stage only expected files and commit:

```powershell
git add apps/aquarium_app/lib/screens/unit_converter_screen.dart apps/aquarium_app/test/widget_tests/unit_converter_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md docs/superpowers/plans/2026-06-13-unit-converter-polish.md
git diff --cached --check
git commit -m "fix: polish unit converter labels"
```

Expected: one scoped commit for CL-P1-006H.
