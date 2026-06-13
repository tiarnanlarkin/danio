# Care Profile Cards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make fish and plant detail pages feel richer by adding compact, data-derived care profile cards.

**Architecture:** Render a fish `Care Profile` card and plant `Planting Profile` card directly in the existing detail sheets. Each card uses only existing structured database fields, avoiding unsupported new facts while making the detail pages easier to scan and act on.

**Tech Stack:** Flutter widget composition, existing `AppCard`, existing static species/plant data, widget tests.

---

### Task 1: Add Failing Tests

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/species_browser_screen_test.dart`
- Modify: `apps/aquarium_app/test/widget_tests/plant_browser_screen_test.dart`

- [ ] **Step 1: Add fish care-profile test**

Add:

```dart
testWidgets('species detail shows care profile', (tester) async {
  await tester.pumpWidget(_wrap());
  await _advance(tester);

  await tester.tap(find.text('Neon Tetra'));
  await tester.pumpAndSettle();

  expect(find.text('Care Profile'), findsOneWidget);
  expect(
    find.text('Tank fit: 40 L+, middle swimmer, peaceful temperament.'),
    findsOneWidget,
  );
  expect(find.text('Group plan: keep 6 or more together.'), findsOneWidget);
  expect(find.text('Water window: 20-26 C, pH 6.0-7.0, GH 1-10.'), findsOneWidget);
  expect(
    find.text('Feeding style: Omnivore - flakes, micro pellets, frozen/live foods'),
    findsOneWidget,
  );
});
```

- [ ] **Step 2: Add plant profile test**

Add:

```dart
testWidgets('plant detail shows planting profile', (tester) async {
  await tester.pumpWidget(_wrap());
  await _advance(tester);

  await tester.tap(find.text('Anubias Barteri'));
  await tester.pumpAndSettle();

  expect(find.text('Planting Profile'), findsOneWidget);
  expect(find.text('Layout role: midground, 15-30 cm mature height.'), findsOneWidget);
  expect(find.text('Growth pace: slow growth, easy difficulty.'), findsOneWidget);
  expect(find.text('Light and CO2: low light, no CO2 setup needed.'), findsOneWidget);
  expect(find.text('Propagation: rhizome division.'), findsOneWidget);
});
```

- [ ] **Step 3: Run focused tests to verify failure**

Run both by name. Expected: fail because the cards are not rendered yet.

### Task 2: Implement Cards

**Files:**
- Modify: `apps/aquarium_app/lib/screens/species_browser_screen.dart`
- Modify: `apps/aquarium_app/lib/screens/plant_browser_screen.dart`

- [ ] **Step 1: Render fish profile**

Add `_SpeciesCareProfileCard` after species description and before `_CareActionsCard`.

- [ ] **Step 2: Render plant profile**

Add `_PlantingProfileCard` after plant description and before `_PlantCareActionsCard`.

- [ ] **Step 3: Use existing styling**

Use `AppCard`, a heading row with a suitable icon, and compact icon/text rows. Keep copy factual and derived from the model fields.

- [ ] **Step 4: Run focused tests**

Expected: PASS.

### Task 3: Verify And Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [ ] **Step 1: Format and normalize Dart files**

- [ ] **Step 2: Run `flutter analyze`, full `flutter test`, doc-truth test, debug APK build, and `git diff --check`**

- [ ] **Step 3: Update docs**

Record CL-P1-003K as care/planting profile cards, update the test count, and mark CL-P1-003 done.

- [ ] **Step 4: Commit**

```powershell
git add apps/aquarium_app/lib/screens/species_browser_screen.dart apps/aquarium_app/lib/screens/plant_browser_screen.dart apps/aquarium_app/test/widget_tests/species_browser_screen_test.dart apps/aquarium_app/test/widget_tests/plant_browser_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-care-profile-cards.md
git commit -m "feat: add care profile cards"
```
