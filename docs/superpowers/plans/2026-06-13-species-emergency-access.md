# Species Emergency Access Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Emergency Guide directly reachable from species detail pages where users may be checking illness, injury, compatibility, or treatment warnings.

**Architecture:** Add a Species Safety callout near the top of `_SpeciesDetailSheet` in `SpeciesBrowserScreen`. Route the callout button to the existing `EmergencyGuideScreen` through `NavigationThrottle`.

**Tech Stack:** Flutter, Riverpod, existing `SpeciesBrowserScreen`, `EmergencyGuideScreen`, `NavigationThrottle`, and widget tests.

---

## File Structure

- Modify `apps/aquarium_app/test/widget_tests/species_browser_screen_test.dart`: add a widget test that opens a species detail sheet and routes to Emergency Guide.
- Modify `apps/aquarium_app/lib/screens/species_browser_screen.dart`: add the species safety callout.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`: record CL-P0-006G progress.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`: update CL-P0-006 status.

---

### Task 1: Species Detail Emergency Test

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/species_browser_screen_test.dart`

- [x] **Step 1: Write failing widget test**

Add imports for `EmergencyGuideScreen` and `NavigationThrottle`, reset throttle in `setUp`, open `Neon Tetra`, expect `Emergency Guide`, tap it, and verify `EmergencyGuideScreen` opens.

- [x] **Step 2: Run test to verify failure**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/species_browser_screen_test.dart
```

Expected initial result: FAIL because species detail sheets do not yet expose Emergency Guide.

---

### Task 2: Species Safety Callout

**Files:**
- Modify: `apps/aquarium_app/lib/screens/species_browser_screen.dart`

- [x] **Step 1: Add imports**

Import `navigation_throttle.dart` and `emergency_guide_screen.dart`.

- [x] **Step 2: Add callout**

Add an `AppCard` near the top of `_SpeciesDetailSheet` with the text `Urgent steps for illness, injury, gasping, or unsafe water` and an `Emergency Guide` button.

- [x] **Step 3: Route to Emergency Guide**

Use `NavigationThrottle.push(context, const EmergencyGuideScreen(), rootNavigator: true)`.

---

### Task 3: Docs

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [x] **Step 1: Update product tracking**

Record `CL-P0-006G` as Species emergency access progress and remove species pages from the remaining emergency-entry list.

---

### Task 4: Verification And Commit

**Files:**
- All files touched in Tasks 1-3

- [x] **Step 1: Format changed Dart files**

Run:

```powershell
cd apps/aquarium_app
dart format lib/screens/species_browser_screen.dart test/widget_tests/species_browser_screen_test.dart
```

- [x] **Step 2: Run focused test**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/species_browser_screen_test.dart
```

- [x] **Step 3: Run analyzer**

Run:

```powershell
cd apps/aquarium_app
flutter analyze
```

- [x] **Step 4: Check diff**

Run:

```powershell
git diff --check
git diff -- apps/aquarium_app/lib/screens/species_browser_screen.dart apps/aquarium_app/test/widget_tests/species_browser_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-species-emergency-access.md
```

- [x] **Step 5: Commit**

Run:

```powershell
git add apps/aquarium_app/lib/screens/species_browser_screen.dart apps/aquarium_app/test/widget_tests/species_browser_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-species-emergency-access.md
git commit -m "feat: add species emergency access"
```
