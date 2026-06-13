# Species Watch For Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a concise `Watch For` card to fish species detail sheets so users see the main planning risks before buying or mixing livestock.

**Architecture:** Derive all copy from existing `SpeciesInfo` fields: minimum group size, avoid list, adult size, minimum tank size, care level, and medication warnings. Do not add new species facts or external-source claims in this slice.

**Tech Stack:** Flutter, existing species database, existing `AppCard` components, species browser widget tests.

---

### Task 1: Species Watch For Card

**Files:**
- Modify: `apps/aquarium_app/lib/screens/species_browser_screen.dart`
- Test: `apps/aquarium_app/test/widget_tests/species_browser_screen_test.dart`

- [ ] **Step 1: Write the failing test**

Add a widget test that opens `Neon Tetra` and expects:
- `Watch For`
- `Small groups: plan 6 or more, not a lone fish.`
- `Tankmates: review Angelfish, Bettas, Large Cichlids before mixing.`
- `Adult fit: plan around 3.5 cm adult size and 40 L minimum tank.`

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
flutter test test/widget_tests/species_browser_screen_test.dart
```

Expected: the new test fails because `Watch For` does not exist yet.

- [ ] **Step 3: Implement data-derived card**

Insert `_SpeciesWatchForCard(species: species)` after `_CareActionsCard`. Build rows from:
- `minSchoolSize`
- `avoidWith`
- `adultSizeCm`
- `minTankLitres`
- `careLevel` when not beginner/easy
- `medicationWarnings` when present

- [ ] **Step 4: Run focused test to verify pass**

Run:

```powershell
flutter test test/widget_tests/species_browser_screen_test.dart
```

Expected: all species browser widget tests pass.

### Task 2: Verify, Document, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Add: `docs/superpowers/plans/2026-06-13-species-watch-for.md`

- [ ] **Step 1: Format and normalize touched Dart files**

Run:

```powershell
dart format lib/screens/species_browser_screen.dart test/widget_tests/species_browser_screen_test.dart
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

Record `CL-P1-003F Species Watch For guidance`, the new passing test count, clean analyzer, doc-truth pass, and debug APK result.

- [ ] **Step 4: Commit**

```powershell
git add apps/aquarium_app/lib/screens/species_browser_screen.dart apps/aquarium_app/test/widget_tests/species_browser_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-species-watch-for.md
git commit -m "feat: add species watch guidance"
```
