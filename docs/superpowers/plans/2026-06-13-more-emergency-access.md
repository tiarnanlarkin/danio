# More Emergency Access Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Emergency Guide directly reachable from the More tab landing surface.

**Architecture:** Add a `Care Safety` section near the top of `SettingsHubScreen` with a primary `Emergency Guide` tile. Route through `NavigationThrottle` to the existing `EmergencyGuideScreen`. Update SettingsHub widget tests for navigation and viewport-stable lower-tile assertions.

**Tech Stack:** Flutter, Riverpod, existing `SettingsHubScreen`, `EmergencyGuideScreen`, `NavigationThrottle`, and widget tests.

---

## File Structure

- Modify `apps/aquarium_app/test/widget_tests/settings_hub_screen_test.dart`: add a More emergency navigation test and reset `NavigationThrottle`.
- Modify `apps/aquarium_app/lib/screens/settings_hub_screen.dart`: add the direct Care Safety tile.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`: record CL-P0-006E progress.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`: update CL-P0-006 status.

---

### Task 1: More Emergency Entry Test

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/settings_hub_screen_test.dart`

- [x] **Step 1: Write failing widget test**

Add imports for `EmergencyGuideScreen` and `NavigationThrottle`, reset the throttle in `setUp`, include `Emergency Guide` in the primary destination set, and add a test that taps the More hub tile and verifies `EmergencyGuideScreen` opens.

- [x] **Step 2: Run test to verify failure**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/settings_hub_screen_test.dart
```

Expected initial result: FAIL because More does not yet expose a direct emergency tile.

---

### Task 2: More Hub Tile

**Files:**
- Modify: `apps/aquarium_app/lib/screens/settings_hub_screen.dart`

- [x] **Step 1: Add Care Safety section**

Import `emergency_guide_screen.dart` and add a top-level `Care Safety` section after the profile card with an `Emergency Guide` `PrimaryActionTile`.

- [x] **Step 2: Route to Emergency Guide**

Use:

```dart
NavigationThrottle.push(
  context,
  const EmergencyGuideScreen(),
  rootNavigator: true,
)
```

- [x] **Step 3: Stabilize affected tests**

Scroll to Achievements before asserting it, because the new top tile legitimately shifts lower More content below the initial viewport.

---

### Task 3: Docs

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [x] **Step 1: Update product tracking**

Record `CL-P0-006E` as More emergency access progress and remove More from the remaining emergency-entry list.

---

### Task 4: Verification And Commit

**Files:**
- All files touched in Tasks 1-3

- [x] **Step 1: Format changed Dart files**

Run:

```powershell
cd apps/aquarium_app
dart format lib/screens/settings_hub_screen.dart test/widget_tests/settings_hub_screen_test.dart
```

- [x] **Step 2: Run focused test**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/settings_hub_screen_test.dart
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
git diff -- apps/aquarium_app/lib/screens/settings_hub_screen.dart apps/aquarium_app/test/widget_tests/settings_hub_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-more-emergency-access.md
```

- [x] **Step 5: Commit**

Run:

```powershell
git add apps/aquarium_app/lib/screens/settings_hub_screen.dart apps/aquarium_app/test/widget_tests/settings_hub_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-more-emergency-access.md
git commit -m "feat: add more emergency access"
```
