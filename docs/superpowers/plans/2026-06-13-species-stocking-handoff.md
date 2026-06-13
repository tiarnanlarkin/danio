# Species Stocking Handoff Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let users open the Stocking Calculator directly from a species detail sheet with that species prefilled as a realistic starting group.

**Architecture:** Add an optional `initialSpecies` argument to `StockingCalculatorScreen`; when provided, seed the current stock list with the species minimum school size. Add a compact action button in the species detail Care Actions card that routes to the calculator with the selected species.

**Tech Stack:** Flutter, Riverpod widget tests, existing `NavigationThrottle`, existing `SpeciesInfo` database model.

---

### Task 1: Prefilled Stocking Calculator

**Files:**
- Modify: `apps/aquarium_app/lib/screens/stocking_calculator_screen.dart`
- Test: `apps/aquarium_app/test/widget_tests/stocking_calculator_screen_test.dart`

- [ ] **Step 1: Write the failing test**

Add a widget test that builds `StockingCalculatorScreen(initialSpecies: SpeciesDatabase.lookup('Neon Tetra')!)` and expects:
- `Neon Tetra` is visible in the current stock list.
- `6` is visible as the starting count.
- The empty state `Search and add fish above` is not visible.

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
flutter test test/widget_tests/stocking_calculator_screen_test.dart
```

Expected: the new test fails because `StockingCalculatorScreen` does not accept or seed `initialSpecies`.

- [ ] **Step 3: Implement minimal prefill**

Add:

```dart
final SpeciesInfo? initialSpecies;

const StockingCalculatorScreen({super.key, this.initialSpecies});

@override
void initState() {
  super.initState();
  final species = widget.initialSpecies;
  if (species != null) {
    _stock.add(
      _StockEntry(
        species: species,
        count: species.minSchoolSize > 0 ? species.minSchoolSize : 1,
      ),
    );
  }
}
```

- [ ] **Step 4: Run focused test to verify pass**

Run:

```powershell
flutter test test/widget_tests/stocking_calculator_screen_test.dart
```

Expected: all stocking calculator widget tests pass.

### Task 2: Species Detail Handoff Button

**Files:**
- Modify: `apps/aquarium_app/lib/screens/species_browser_screen.dart`
- Test: `apps/aquarium_app/test/widget_tests/species_browser_screen_test.dart`

- [ ] **Step 1: Write the failing test**

Add a widget test that opens `Neon Tetra`, taps `Plan stocking fit`, and expects:
- `Stocking Calculator` is visible.
- `Neon Tetra` is visible.
- `6` is visible as the seeded group count.

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
flutter test test/widget_tests/species_browser_screen_test.dart
```

Expected: the new test fails because the button does not exist yet.

- [ ] **Step 3: Implement minimal route**

Import `stocking_calculator_screen.dart` in `species_browser_screen.dart` and add an `AppButton` below the care action rows:

```dart
AppButton(
  label: 'Plan stocking fit',
  leadingIcon: Icons.calculate_outlined,
  variant: AppButtonVariant.secondary,
  size: AppButtonSize.small,
  onPressed: () => NavigationThrottle.push(
    context,
    StockingCalculatorScreen(initialSpecies: species),
    rootNavigator: true,
  ),
),
```

- [ ] **Step 4: Run focused test to verify pass**

Run:

```powershell
flutter test test/widget_tests/species_browser_screen_test.dart
```

Expected: all species browser widget tests pass.

### Task 3: Verify, Document, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Add: `docs/superpowers/plans/2026-06-13-species-stocking-handoff.md`

- [ ] **Step 1: Format and normalize touched Dart files**

Run:

```powershell
dart format lib/screens/species_browser_screen.dart lib/screens/stocking_calculator_screen.dart test/widget_tests/species_browser_screen_test.dart test/widget_tests/stocking_calculator_screen_test.dart
```

- [ ] **Step 2: Run full verification**

Run:

```powershell
flutter analyze
flutter test
flutter test test/copy/current_docs_local_truth_test.dart
flutter build apk --debug --target lib/main.dart
git diff --check
```

- [ ] **Step 3: Update docs**

Record `CL-P1-003C Species stocking handoff`, the new passing test count, clean analyzer, doc-truth pass, and debug APK result.

- [ ] **Step 4: Commit**

```powershell
git add apps/aquarium_app/lib/screens/species_browser_screen.dart apps/aquarium_app/lib/screens/stocking_calculator_screen.dart apps/aquarium_app/test/widget_tests/species_browser_screen_test.dart apps/aquarium_app/test/widget_tests/stocking_calculator_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-species-stocking-handoff.md
git commit -m "feat: add species stocking handoff"
```
