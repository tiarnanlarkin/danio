# Plant Watch For Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a concise `Watch For` card to plant detail sheets so plant pages match the practical risk guidance now present on fish species pages.

**Architecture:** Derive all copy from existing `PlantInfo` fields and tips: propagation, growth rate, height range, CO2 need, and difficulty. Avoid adding new plant facts or external-source claims in this slice.

**Tech Stack:** Flutter, existing plant database, existing `AppCard` components, plant browser widget tests.

---

### Task 1: Plant Watch For Card

**Files:**
- Modify: `apps/aquarium_app/lib/screens/plant_browser_screen.dart`
- Test: `apps/aquarium_app/test/widget_tests/plant_browser_screen_test.dart`

- [ ] **Step 1: Write the failing test**

Add a widget test that opens `Anubias Barteri` and expects:
- `Watch For`
- `Rhizome: keep it above the substrate.`
- `Slow growth: avoid judging progress too quickly.`
- `Size: leave room for 15-30 cm growth.`

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
flutter test test/widget_tests/plant_browser_screen_test.dart
```

Expected: the new test fails because plant detail sheets do not have `Watch For`.

- [ ] **Step 3: Implement data-derived card**

Insert `_PlantWatchForCard(plant: plant)` after `_PlantCareActionsCard`. Build rows from:
- `propagation`/tips containing rhizome
- `growthRate`
- `minHeightCm`/`maxHeightCm`
- `needsCO2`
- `difficulty` when not easy

- [ ] **Step 4: Run focused test to verify pass**

Run:

```powershell
flutter test test/widget_tests/plant_browser_screen_test.dart
```

Expected: all plant browser widget tests pass.

### Task 2: Verify, Document, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Add: `docs/superpowers/plans/2026-06-13-plant-watch-for.md`

- [ ] **Step 1: Format and normalize touched Dart files**

Run:

```powershell
dart format lib/screens/plant_browser_screen.dart test/widget_tests/plant_browser_screen_test.dart
```

- [ ] **Step 2: Run verification**

Run:

```powershell
flutter analyze
flutter test
flutter test test/copy/current_docs_local_truth_test.dart
flutter build apk --debug --target lib/main.dart
git diff --check
```

- [ ] **Step 3: Update docs**

Record `CL-P1-003G Plant Watch For guidance`, the new passing test count, clean analyzer, doc-truth pass, and debug APK result.

- [ ] **Step 4: Commit**

```powershell
git add apps/aquarium_app/lib/screens/plant_browser_screen.dart apps/aquarium_app/test/widget_tests/plant_browser_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-plant-watch-for.md
git commit -m "feat: add plant watch guidance"
```
