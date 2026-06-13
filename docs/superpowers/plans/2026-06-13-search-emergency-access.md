# Search Emergency Access Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make urgent global searches route users directly to Emergency Guide.

**Architecture:** Extend `SearchScreen` with a guide result type and emergency-term matcher. The result appears under a `Guides` section, uses emergency styling, and opens the existing `EmergencyGuideScreen` through `NavigationThrottle`.

**Tech Stack:** Flutter, Riverpod, existing `SearchScreen`, `EmergencyGuideScreen`, `NavigationThrottle`, and widget tests.

---

## File Structure

- Modify `apps/aquarium_app/test/widget_tests/search_screen_test.dart`: add a widget test for urgent search terms opening Emergency Guide.
- Modify `apps/aquarium_app/lib/screens/search_screen.dart`: add guide result support and emergency matching.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`: record CL-P0-006D progress.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`: update CL-P0-006 status.

---

### Task 1: Emergency Search Test

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/search_screen_test.dart`

- [x] **Step 1: Write failing widget test**

Add imports for `EmergencyGuideScreen` and `NavigationThrottle`, reset navigation throttle in `setUp`, then add a test that enters `ammonia emergency`, expects a `Guides` result for `Emergency Guide`, taps it, and verifies the guide opens.

- [x] **Step 2: Run test to verify failure**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/search_screen_test.dart
```

Expected initial result: FAIL because Search has no emergency guide result.

---

### Task 2: Search Result Implementation

**Files:**
- Modify: `apps/aquarium_app/lib/screens/search_screen.dart`

- [x] **Step 1: Add guide result type**

Add `_ResultType.guide`, a result color field, and a `Guides` result group before tank/livestock/equipment/species groups.

- [x] **Step 2: Add emergency matcher**

Match urgent terms including `emergency`, `urgent`, `ammonia`, `nitrite`, `toxic`, `spike`, `gasping`, `heater`, `filter`, `ich`, `injury`, `poisoning`, `sick`, `disease`, and `dying`.

- [x] **Step 3: Route to Emergency Guide**

Add an `Emergency Guide` result that opens `const EmergencyGuideScreen()` through `NavigationThrottle.push(... rootNavigator: true)`.

- [x] **Step 4: Update search copy**

Update the search hint and empty state so guides are discoverable search targets.

---

### Task 3: Docs

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [x] **Step 1: Update product tracking**

Record `CL-P0-006D` as Search emergency access progress and remove Search from the remaining emergency-entry list.

---

### Task 4: Verification And Commit

**Files:**
- All files touched in Tasks 1-3

- [x] **Step 1: Format changed Dart files**

Run:

```powershell
cd apps/aquarium_app
dart format lib/screens/search_screen.dart test/widget_tests/search_screen_test.dart
```

- [x] **Step 2: Run focused test**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/search_screen_test.dart
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
git diff -- apps/aquarium_app/lib/screens/search_screen.dart apps/aquarium_app/test/widget_tests/search_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-search-emergency-access.md
```

- [x] **Step 5: Commit**

Run:

```powershell
git add apps/aquarium_app/lib/screens/search_screen.dart apps/aquarium_app/test/widget_tests/search_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-search-emergency-access.md
git commit -m "feat: route emergency searches to guide"
```
