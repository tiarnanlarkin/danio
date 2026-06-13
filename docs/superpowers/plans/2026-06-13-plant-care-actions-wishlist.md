# Plant Care Actions Wishlist Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bring plant detail sheets closer to fish species page parity with actionable care guidance and local wishlist saving.

**Architecture:** Add a Riverpod-aware plant Care Actions card to the plant detail sheet. Derive actions from existing `PlantInfo` fields only, and write saved plants into the existing SharedPreferences-backed wishlist as `WishlistCategory.plant`.

**Tech Stack:** Flutter, Riverpod, SharedPreferences-backed wishlist provider, existing `DanioSnackBar`, existing plant browser widget tests.

---

### Task 1: Plant Care Actions

**Files:**
- Modify: `apps/aquarium_app/lib/screens/plant_browser_screen.dart`
- Test: `apps/aquarium_app/test/widget_tests/plant_browser_screen_test.dart`

- [ ] **Step 1: Write the failing test**

Add a widget test that opens `Anubias Barteri` and expects:
- `Care Actions`
- `Use as a midground plant.`
- `Give low light.`
- `No CO2 setup needed for this plant.`
- `Propagate by rhizome division.`

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
flutter test test/widget_tests/plant_browser_screen_test.dart
```

Expected: the new test fails because plant detail sheets do not have `Care Actions`.

- [ ] **Step 3: Implement care actions**

Create `_PlantCareActionsCard` and insert it after the description. Use existing fields only:
- placement
- lightLevel
- needsCO2
- propagation
- growthRate/difficulty if useful

- [ ] **Step 4: Run focused test to verify pass**

Run:

```powershell
flutter test test/widget_tests/plant_browser_screen_test.dart
```

Expected: all plant browser widget tests pass.

### Task 2: Plant Wishlist Save

**Files:**
- Modify: `apps/aquarium_app/lib/screens/plant_browser_screen.dart`
- Test: `apps/aquarium_app/test/widget_tests/plant_browser_screen_test.dart`

- [ ] **Step 1: Write the failing test**

Add a widget test that opens `Anubias Barteri`, taps `Save to wishlist`, and expects:
- SharedPreferences key `wishlist_items` contains `Anubias Barteri`.
- SharedPreferences key `wishlist_items` contains `Anubias barteri var. barteri`.
- The visible button state changes to `Saved to wishlist`.

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
flutter test test/widget_tests/plant_browser_screen_test.dart
```

Expected: the new test fails because `Save to wishlist` is not implemented on plant detail sheets.

- [ ] **Step 3: Implement wishlist save**

Make `_PlantCareActionsCard` a `ConsumerWidget`, read `plantWishlistProvider`, and save:

```dart
WishlistItem(
  category: WishlistCategory.plant,
  name: plant.commonName,
  species: plant.scientificName,
  notes:
      'Saved from Plant Guide. Placement: ${plant.placement}. Light: ${plant.lightLevel}. CO2: ${plant.needsCO2 ? 'needed' : 'not needed'}.',
)
```

- [ ] **Step 4: Run focused test to verify pass**

Run:

```powershell
flutter test test/widget_tests/plant_browser_screen_test.dart
```

Expected: all plant browser widget tests pass.

### Task 3: Verify, Document, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Add: `docs/superpowers/plans/2026-06-13-plant-care-actions-wishlist.md`

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

Record `CL-P1-003E Plant care actions and wishlist save`, the new passing test count, clean analyzer, doc-truth pass, and debug APK result.

- [ ] **Step 4: Commit**

```powershell
git add apps/aquarium_app/lib/screens/plant_browser_screen.dart apps/aquarium_app/test/widget_tests/plant_browser_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-plant-care-actions-wishlist.md
git commit -m "feat: add plant care actions"
```
