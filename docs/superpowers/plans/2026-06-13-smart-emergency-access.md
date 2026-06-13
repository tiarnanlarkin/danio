# Smart Emergency Access Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make emergency help reachable from Smart Hub without requiring optional AI setup or a trip through Settings.

**Architecture:** Add an always-available `_FeatureCard` near the top of `SmartScreen`, route it to the existing `EmergencyGuideScreen` through `NavigationThrottle`, and harden the Smart widget suite around the new entry point.

**Tech Stack:** Flutter, Riverpod, existing `SmartScreen`, `EmergencyGuideScreen`, `NavigationThrottle`, and widget tests.

---

## File Structure

- Modify `apps/aquarium_app/test/widget_tests/smart_screen_test.dart`: add a widget test for opening Emergency Guide from Smart and reset `NavigationThrottle` in `setUp`.
- Modify `apps/aquarium_app/lib/screens/smart_screen.dart`: add the local Emergency Guide feature card.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`: record CL-P0-006C progress.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`: update CL-P0-006 status.

---

### Task 1: Smart Emergency Entry Test

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/smart_screen_test.dart`

- [x] **Step 1: Write failing widget test**

Add imports for `EmergencyGuideScreen` and `NavigationThrottle`, reset the throttle in `setUp`, then add a test that expects the Smart Hub `Emergency Guide` action, taps it, and verifies `EmergencyGuideScreen` is shown.

- [x] **Step 2: Run test to verify failure**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/smart_screen_test.dart
```

Expected initial result: FAIL because Smart Hub does not yet expose an `Emergency Guide` action.

---

### Task 2: Smart Hub Emergency Card

**Files:**
- Modify: `apps/aquarium_app/lib/screens/smart_screen.dart`

- [x] **Step 1: Implement the local action**

Import `emergency_guide_screen.dart` and add an always-available `_FeatureCard` near the top of the Smart item list:

```dart
_FeatureCard(
  icon: Icons.emergency_outlined,
  title: 'Emergency Guide',
  subtitle: 'Fast steps for urgent water and fish issues',
  color: AppColors.error,
  onTap: () => NavigationThrottle.push(
    context,
    const EmergencyGuideScreen(),
    rootNavigator: true,
  ),
)
```

- [x] **Step 2: Stabilize affected tests**

Update the existing optional-AI subtitle assertion to include offstage widgets, because the new top card pushes one locked AI card below the initial viewport. Use a bounded pump after scrolling to `Ask Danio` so delayed card animations do not leave pending timers.

---

### Task 3: Docs

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [x] **Step 1: Update product tracking**

Record `CL-P0-006C` as Smart emergency access progress and remove Smart from the remaining emergency-entry list.

---

### Task 4: Verification And Commit

**Files:**
- All files touched in Tasks 1-3

- [x] **Step 1: Format changed Dart files**

Run:

```powershell
cd apps/aquarium_app
dart format lib/screens/smart_screen.dart test/widget_tests/smart_screen_test.dart
```

- [x] **Step 2: Run focused test**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/smart_screen_test.dart
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
git diff -- apps/aquarium_app/lib/screens/smart_screen.dart apps/aquarium_app/test/widget_tests/smart_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-smart-emergency-access.md
```

- [x] **Step 5: Commit**

Run:

```powershell
git add apps/aquarium_app/lib/screens/smart_screen.dart apps/aquarium_app/test/widget_tests/smart_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-smart-emergency-access.md
git commit -m "feat: add smart emergency access"
```
