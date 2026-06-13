# First-Run Quick Start Handoff Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make skipped onboarding land in a polished, honest local sample experience instead of creating an empty guessed starter tank.

**Architecture:** Reuse the existing `TankActions.addDemoTank()` sample-data path, because it already creates a freshwater demo tank with livestock, equipment, logs, tasks, and demo-mode labeling. Keep quick start from setting inferred region or tank-status context. Route the user to the central Tank tab after completion so first launch opens on the aquarium experience.

**Tech Stack:** Flutter, Riverpod, Dart tests, source-level onboarding copy contracts.

---

## File Structure

- Modify `apps/aquarium_app/lib/screens/onboarding_screen.dart`: replace quick-start empty tank creation with sample tank creation, set current tab to the tank tab, and update disclosure copy.
- Create `apps/aquarium_app/test/copy/onboarding_quick_start_handoff_test.dart`: source contracts for quick-start behavior and copy.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`: record CL-P0-004B completion and next onboarding slice.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`: move quick-start sample handoff from open backlog to completed evidence.

---

### Task 1: Quick-Start Source Contract

**Files:**
- Create: `apps/aquarium_app/test/copy/onboarding_quick_start_handoff_test.dart`
- Modify: `apps/aquarium_app/lib/screens/onboarding_screen.dart`

- [x] **Step 1: Write the failing source contract**

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('quick start uses a sample tank instead of guessing a real starter tank', () {
    final source = File('lib/screens/onboarding_screen.dart').readAsStringSync();

    final quickStartStart = source.indexOf('Future<void> _quickStart() async');
    final quickStartEnd = source.indexOf('@override', quickStartStart);
    final quickStart = source.substring(quickStartStart, quickStartEnd);

    expect(quickStart, contains('addDemoTank()'));
    expect(quickStart, isNot(contains("name: 'My Tank'")));
    expect(quickStart, isNot(contains('volumeLitres: 60')));
    expect(quickStart, contains('currentTabNotifier.state = 2'));
    expect(quickStart, contains('Sample tank added'));
    expect(quickStart, isNot(contains('starter tank')));
    expect(quickStart, isNot(contains('regionCode:')));
    expect(quickStart, isNot(contains('tankStatus:')));
  });
}
```

- [x] **Step 2: Run the focused test and verify it fails**

Run:

```powershell
cd apps/aquarium_app
flutter test test/copy/onboarding_quick_start_handoff_test.dart
```

Expected: FAIL because `_quickStart` still calls `createTank(name: 'My Tank', volumeLitres: 60)` and lacks `addDemoTank()` / tank-tab routing.

- [x] **Step 3: Implement minimal quick-start behavior**

Change `_quickStart` in `apps/aquarium_app/lib/screens/onboarding_screen.dart` so it:

```dart
final tankNotifier = ref.read(tankActionsProvider);
await tankNotifier.addDemoTank();
final currentTabNotifier = ref.read(currentTabProvider.notifier);
currentTabNotifier.state = 2;
```

Keep `createProfile(...)` without `regionCode` and without `tankStatus`, and update the snackbar to:

```dart
'Sample tank added so you can explore. Replace it with your own setup when ready.'
```

- [x] **Step 4: Run the focused test and verify it passes**

Run:

```powershell
cd apps/aquarium_app
flutter test test/copy/onboarding_quick_start_handoff_test.dart
```

Expected: PASS.

---

### Task 2: Existing Flow Regression

**Files:**
- Test: `apps/aquarium_app/test/copy/onboarding_region_units_flow_test.dart`
- Test: `apps/aquarium_app/test/providers/tank_provider_test.dart`

- [x] **Step 1: Run focused regression tests**

Run:

```powershell
cd apps/aquarium_app
flutter test test/copy/onboarding_region_units_flow_test.dart test/providers/tank_provider_test.dart
```

Expected: PASS.

- [x] **Step 2: Fix only behavior directly broken by this slice**

If tests fail because the quick-start source changed, adjust the test contract to match the new honest sample-handoff behavior. Do not change unrelated provider behavior.

---

### Task 3: Product Audit Update

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [x] **Step 1: Update current audit**

Record CL-P0-004B as complete with evidence:

```markdown
- CL-P0-004B complete: Quick-start/skipped onboarding now creates the existing populated sample tank, keeps inferred region/tank status unset, routes to the center Tank tab, and uses disclosure copy that says it is sample data.
```

- [x] **Step 2: Update backlog**

Move or annotate the quick-start sample handoff item as completed. Leave remaining onboarding work open:

```markdown
- Next: capture tank stage/goals more robustly, then add contextual missing-context prompts where tools genuinely need setup data.
```

---

### Task 4: Verification and Commit

**Files:**
- All files touched in Tasks 1-3

- [x] **Step 1: Format changed Dart files**

Run:

```powershell
cd apps/aquarium_app
dart format lib/screens/onboarding_screen.dart test/copy/onboarding_quick_start_handoff_test.dart
```

Expected: Files formatted with no Dart syntax errors.

- [x] **Step 2: Run focused verification**

Run:

```powershell
cd apps/aquarium_app
flutter test test/copy/onboarding_quick_start_handoff_test.dart test/copy/onboarding_region_units_flow_test.dart test/providers/tank_provider_test.dart
```

Expected: PASS.

- [x] **Step 3: Run analyzer**

Run:

```powershell
cd apps/aquarium_app
flutter analyze
```

Expected: No issues found.

- [x] **Step 4: Check diff**

Run:

```powershell
git diff --check
git diff -- apps/aquarium_app/lib/screens/onboarding_screen.dart apps/aquarium_app/test/copy/onboarding_quick_start_handoff_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-first-run-quick-start-handoff.md
```

Expected: no whitespace errors, diff limited to this slice.

- [x] **Step 5: Commit**

Run:

```powershell
git add apps/aquarium_app/lib/screens/onboarding_screen.dart apps/aquarium_app/test/copy/onboarding_quick_start_handoff_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-first-run-quick-start-handoff.md
git commit -m "feat: improve quick-start sample handoff"
```

Expected: commit succeeds.
