# First-Run Context Prompts Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let users who skipped setup add missing region/tank-stage context later, and prompt for it only on Smart where that context improves care intelligence.

**Architecture:** Add editable `Setup Details` tiles in Preferences using existing `UserProfile.regionCode` and `UserProfile.tankStatus`. Add a Smart Hub nudge that appears only when a loaded profile is missing either field and routes to Preferences. This avoids global nagging while giving intelligence-heavy tools a clear path to better context.

**Tech Stack:** Flutter, Riverpod, SharedPreferences-backed profile tests, SmartScreen widget tests, source-level docs audit.

---

## File Structure

- Modify `apps/aquarium_app/lib/screens/settings/settings_screen.dart`: add `Setup Details` section with Region and Tank Stage pickers.
- Modify `apps/aquarium_app/test/widget/settings_screen_test.dart`: add widget tests for missing setup details and picker behavior.
- Modify `apps/aquarium_app/lib/screens/smart_screen.dart`: add conditional `_SetupContextBanner`.
- Modify `apps/aquarium_app/test/widget_tests/smart_screen_test.dart`: add saved-profile fixture and banner tests.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`: record CL-P0-004D completion.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`: mark CL-P0-004 remaining local work as final screen QA.

---

### Task 1: Preferences Setup Details

**Files:**
- Modify: `apps/aquarium_app/test/widget/settings_screen_test.dart`
- Modify: `apps/aquarium_app/lib/screens/settings/settings_screen.dart`

- [x] **Step 1: Write failing Settings tests**

Add tests that seed `user_profile` without `regionCode` or `tankStatus` and verify:

```dart
expect(find.text('Setup Details'), findsOneWidget);
expect(find.text('Region'), findsOneWidget);
expect(find.text('Not set - helps localise guidance'), findsOneWidget);
expect(find.text('Tank stage'), findsOneWidget);
expect(find.text('Not set - helps tune care prompts'), findsOneWidget);
```

Add a picker test that taps `Region`, selects `UK & Ireland`, and expects `UK & Ireland` as the subtitle.

- [x] **Step 2: Run Settings tests and verify failure**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget/settings_screen_test.dart
```

Expected: FAIL because the new section and pickers do not exist.

- [x] **Step 3: Implement Settings setup details**

Add:

- `_SetupDetailsSection`
- `_RegionProfileTile`
- `_TankStageProfileTile`
- `_showRegionPicker`
- `_showTankStagePicker`

Use these region labels:

```dart
gb_ie: UK & Ireland
europe: Europe
us: United States
canada: Canada
aus_nz: Australia & New Zealand
other: Other / not listed
```

Use these tank stage labels:

```dart
planning: Planning a tank
cycling: Cycling / setting up
active: Tank running with livestock
```

Persist via `ref.read(userProfileProvider.notifier).updateProfile(regionCode: code)` and `updateProfile(tankStatus: status)`.

- [x] **Step 4: Run Settings tests and verify pass**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget/settings_screen_test.dart
```

Expected: PASS.

---

### Task 2: Smart Context Nudge

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/smart_screen_test.dart`
- Modify: `apps/aquarium_app/lib/screens/smart_screen.dart`

- [x] **Step 1: Write failing Smart tests**

Add one test with a saved profile missing `regionCode` and `tankStatus`:

```dart
expect(find.text('Complete setup details'), findsOneWidget);
expect(
  find.text('Add your region and tank stage so Smart can tune risks, reminders, and care plans.'),
  findsOneWidget,
);
```

Add one test with `regionCode: 'gb_ie'` and `tankStatus: 'active'` that expects no setup-context banner.

- [x] **Step 2: Run Smart tests and verify failure**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/smart_screen_test.dart
```

Expected: FAIL because the setup-context banner does not exist.

- [x] **Step 3: Implement Smart setup-context banner**

In `SmartScreen.build`, watch:

```dart
final profile = ref.watch(userProfileProvider).valueOrNull;
final needsSetupContext =
    profile != null && (profile.regionCode == null || profile.tankStatus == null);
```

Add `_SetupContextBanner` near the top of `items` after the AI status/banner. Button label `Open Preferences`, action `NavigationThrottle.push(context, const SettingsScreen(), rootNavigator: true)`.

- [x] **Step 4: Run Smart tests and verify pass**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/smart_screen_test.dart
```

Expected: PASS.

---

### Task 3: Product Audit Update

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [x] **Step 1: Update current audit**

Record:

```markdown
- CL-P0-004D complete: Preferences now lets skipped users fill region and tank stage later, and Smart shows a setup-context nudge only when those fields are missing.
```

- [x] **Step 2: Update backlog**

Update CL-P0-004 remaining work:

```markdown
Remaining: final first-run screen QA on Android phone/tablet when transport is usable.
```

---

### Task 4: Verification and Commit

**Files:**
- All files touched in Tasks 1-3

- [x] **Step 1: Format changed Dart files**

Run:

```powershell
cd apps/aquarium_app
dart format lib/screens/settings/settings_screen.dart lib/screens/smart_screen.dart test/widget/settings_screen_test.dart test/widget_tests/smart_screen_test.dart
```

Expected: formatting succeeds.

- [x] **Step 2: Run focused verification**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget/settings_screen_test.dart test/widget_tests/smart_screen_test.dart test/providers/user_profile_notifier_test.dart
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
git diff -- apps/aquarium_app/lib/screens/settings/settings_screen.dart apps/aquarium_app/lib/screens/smart_screen.dart apps/aquarium_app/test/widget/settings_screen_test.dart apps/aquarium_app/test/widget_tests/smart_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-first-run-context-prompts.md
```

Expected: no whitespace errors, diff limited to this slice.

- [x] **Step 5: Commit**

Run:

```powershell
git add apps/aquarium_app/lib/screens/settings/settings_screen.dart apps/aquarium_app/lib/screens/smart_screen.dart apps/aquarium_app/test/widget/settings_screen_test.dart apps/aquarium_app/test/widget_tests/smart_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-first-run-context-prompts.md
git commit -m "feat: add setup context prompts"
```

Expected: commit succeeds.
