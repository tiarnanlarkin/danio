# Species Wishlist Save Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let users save a fish from its species detail sheet into the existing local fish wishlist.

**Architecture:** Convert the species Care Actions card into a Riverpod-aware widget so it can read active fish wishlist items and write a new `WishlistItem`. Keep the action local-first and explicit: the button saves to the existing wishlist, changes to a saved state, and does not pretend to add livestock to an active tank.

**Tech Stack:** Flutter, Riverpod, SharedPreferences-backed wishlist provider, existing `DanioSnackBar`, existing species browser widget tests.

---

### Task 1: Species Detail Wishlist Save

**Files:**
- Modify: `apps/aquarium_app/lib/screens/species_browser_screen.dart`
- Test: `apps/aquarium_app/test/widget_tests/species_browser_screen_test.dart`

- [ ] **Step 1: Write the failing test**

Add a widget test that opens `Neon Tetra`, taps `Save to wishlist`, and expects:
- SharedPreferences key `wishlist_items` contains `Neon Tetra`.
- SharedPreferences key `wishlist_items` contains `Paracheirodon innesi`.
- The visible button state changes to `Saved to wishlist`.

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
flutter test test/widget_tests/species_browser_screen_test.dart
```

Expected: the new test fails because `Save to wishlist` does not exist yet.

- [ ] **Step 3: Implement minimal wishlist action**

Add imports:

```dart
import '../models/wishlist.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/danio_snack_bar.dart';
```

Make `_CareActionsCard` extend `ConsumerWidget`, read `fishWishlistProvider`, and add an `AppButton`:

```dart
final isSaved = ref.watch(fishWishlistProvider).any(
  (item) =>
      item.name.toLowerCase() == species.commonName.toLowerCase() ||
      item.species?.toLowerCase() == species.scientificName.toLowerCase(),
);
```

Save item:

```dart
await ref.read(wishlistProvider.notifier).addItem(
  WishlistItem(
    category: WishlistCategory.fish,
    name: species.commonName,
    species: species.scientificName,
    notes:
        'Saved from Species Guide. Minimum group: ${species.minSchoolSize}. Minimum tank: ${species.minTankLitres.toStringAsFixed(0)} L.',
    quantity: species.minSchoolSize > 0 ? species.minSchoolSize : 1,
  ),
);
```

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
- Add: `docs/superpowers/plans/2026-06-13-species-wishlist-save.md`

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

Record `CL-P1-003D Species wishlist save`, the new passing test count, clean analyzer, doc-truth pass, and debug APK result.

- [ ] **Step 4: Commit**

```powershell
git add apps/aquarium_app/lib/screens/species_browser_screen.dart apps/aquarium_app/test/widget_tests/species_browser_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-species-wishlist-save.md
git commit -m "feat: save species to wishlist"
```
