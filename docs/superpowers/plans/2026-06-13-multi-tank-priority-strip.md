# Multi-Tank Priority Strip Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Compare Tanks show all-tank priorities so urgent tanks are visible even when they are not part of the selected two-tank comparison.

**Architecture:** Keep the existing pair selector and detailed comparison sections. Expand `_ComparisonDataView` to load summaries for every tank, derive selected-pair summaries from that map, and render a compact all-tanks priority card before the detailed pair comparison.

**Tech Stack:** Flutter, Riverpod provider overrides, existing `TankComparisonService`.

---

### Task 1: Add Failing Widget Test

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/tank_comparison_screen_test.dart`

- [ ] **Step 1: Add a three-tank priority test**

Create three tanks where the default selected pair is Tank A/Tank B, but Tank C has stale water, unsafe nitrate, and an overdue task.

- [ ] **Step 2: Assert all-tanks overview**

Expect visible text:

```dart
expect(find.text('All tanks at a glance'), findsOneWidget);
expect(find.text('Highest priority: Tank C'), findsOneWidget);
expect(find.textContaining('Water parameters need attention'), findsWidgets);
```

- [ ] **Step 3: Run focused RED**

Run:

```powershell
flutter test test/widget_tests/tank_comparison_screen_test.dart
```

Expected: the new test fails because the all-tanks priority card does not exist.

### Task 2: Implement All-Tanks Priority Card

**Files:**
- Modify: `apps/aquarium_app/lib/screens/tank_comparison_screen.dart`

- [ ] **Step 1: Pass all tanks into data view**

Change `_ComparisonDataView` construction to pass `allTanks: tanks` alongside `selectedTanks`.

- [ ] **Step 2: Build summaries for all tanks**

In `_ComparisonDataView`, watch logs/tasks/livestock/equipment for every tank, build all summaries, then derive selected summaries by ID.

- [ ] **Step 3: Render all-tanks card**

Add `_AllTanksPriorityCard` above the selected-pair insight. Sort summaries by descending `attentionScore`, show highest priority and each tank's compact reason.

- [ ] **Step 4: Run focused GREEN**

Run:

```powershell
flutter test test/widget_tests/tank_comparison_screen_test.dart
```

Expected: all TankComparisonScreen tests pass.

### Task 3: Verify, Document, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`

- [ ] **Step 1: Update audit docs**

Record this as CL-P1-007A multi-tank priority strip.

- [ ] **Step 2: Run verification**

Run:

```powershell
flutter analyze
flutter test
flutter test test/copy/current_docs_local_truth_test.dart
flutter build apk --debug --target lib/main.dart
git diff --check
rg -n '[^\x00-\x7F]' apps/aquarium_app/lib/screens/tank_comparison_screen.dart apps/aquarium_app/test/widget_tests/tank_comparison_screen_test.dart docs/superpowers/plans/2026-06-13-multi-tank-priority-strip.md
```

Expected: analyzer clean, full tests pass, docs truth passes, APK builds, diff check clean, and touched source/test/plan files are ASCII-safe.

- [ ] **Step 3: Commit**

```powershell
git add apps/aquarium_app/lib/screens/tank_comparison_screen.dart apps/aquarium_app/test/widget_tests/tank_comparison_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md docs/superpowers/plans/2026-06-13-multi-tank-priority-strip.md
git commit -m "feat: add multi-tank priority strip"
```
