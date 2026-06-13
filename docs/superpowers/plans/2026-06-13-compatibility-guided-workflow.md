# Compatibility Guided Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the Compatibility Checker into a guided workflow that uses selected tank context and can save a compatibility verdict into the tank journal.

**Architecture:** Add optional `tankId` to `CompatibilityCheckerScreen`, use that selected tank as the tank-size reference when present, and reuse the existing `AddLogScreen(initialNotes: ...)` observation handoff for compatibility summaries. Wire Workshop to pass tank context using the existing chooser pattern.

**Tech Stack:** Flutter, Dart, Riverpod provider overrides, existing `NavigationThrottle`, existing `AddLogScreen`, widget tests with `InMemoryStorageService`.

---

### Task 1: Compatibility Journal Handoff

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/compatibility_checker_test.dart`
- Modify: `apps/aquarium_app/lib/screens/compatibility_checker_screen.dart`

- [x] **Step 1: Write the failing Compatibility test**

Add a test that opens `CompatibilityCheckerScreen(tankId: 'tank-1')` with a stored 72 L tank, adds Neon Tetra and Guppy, taps `Log compatibility check`, and verifies `AddLogScreen` opens with observation selected and a note containing `Compatibility check`, `Verdict:`, `Neon Tetra`, and `Guppy`.

- [x] **Step 2: Run Compatibility test red**

Run:

```powershell
flutter test test/widget_tests/compatibility_checker_test.dart
```

Expected: fail because the screen has no `tankId` constructor argument or journal handoff action.

- [x] **Step 3: Implement Compatibility handoff**

Add optional `tankId` to `CompatibilityCheckerScreen`.

Refactor issue calculation so:

- build uses `ref.watch(tanksProvider).valueOrNull`
- selected tank ID, when present, is the tank-size reference
- standalone mode keeps the current largest-owned-tank fallback

When `tankId` is present and at least two species are selected, show a guided card after the recommended setup card:

- title: `Guided next step`
- body: `Save this compatibility check to the tank journal before you buy or move fish.`
- button: `Log compatibility check`

Button navigates to:

```dart
AddLogScreen(
  tankId: tankId,
  initialType: LogType.observation,
  initialNotes: _compatibilitySummary,
)
```

where `_compatibilitySummary` includes selected species, verdict, issue count/details, recommended tank/temperature/pH, selected tank reference, and an educational caveat.

Clean mojibake in the touched Compatibility file and tests using ASCII-safe comments and temperature text.

- [x] **Step 4: Run Compatibility test green**

Run:

```powershell
flutter test test/widget_tests/compatibility_checker_test.dart
```

Expected: pass.

### Task 2: Workshop Context

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/workshop_screen_test.dart`
- Modify: `apps/aquarium_app/lib/screens/workshop_screen.dart`

- [x] **Step 1: Write failing Workshop test**

Add a test that seeds one tank, taps `Compatibility`, verifies `CompatibilityCheckerScreen` opens, adds Neon Tetra and Guppy, and sees `Log compatibility check`.

- [x] **Step 2: Run Workshop test red**

Run:

```powershell
flutter test test/widget_tests/workshop_screen_test.dart
```

Expected: fail because Workshop opens `const CompatibilityCheckerScreen()` without tank context.

- [x] **Step 3: Implement Workshop Compatibility handoff**

Add `_openCompatibilityChecker()` beside the other guided tool launchers:

- no tanks: standalone `const CompatibilityCheckerScreen()`
- one tank: `CompatibilityCheckerScreen(tankId: tank.id)`
- multiple tanks: picker, then pass selected tank ID

Update the Compatibility card `onTap`.

- [x] **Step 4: Run focused tests**

Run:

```powershell
flutter test test/widget_tests/compatibility_checker_test.dart test/widget_tests/workshop_screen_test.dart
```

Expected: pass.

### Task 3: Docs, Verification, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`

- [x] **Step 1: Update CL-P1-006 docs**

Record CL-P1-006G as Compatibility guided workflow: selected tank context, tank-size reference, compatibility verdict summary, caveat, and journal handoff.

- [x] **Step 2: Run verification**

Run:

```powershell
flutter analyze
flutter test
flutter test test/copy/current_docs_local_truth_test.dart
flutter build apk --debug --target lib/main.dart
git diff --check
```

Expected: analyzer clean, full suite passes with updated count, docs truth passes, debug APK builds with only the existing Kotlin Gradle Plugin warning, and diff check is clean.

- [x] **Step 3: Commit**

Stage only expected files and commit:

```powershell
git add apps/aquarium_app/lib/screens/compatibility_checker_screen.dart apps/aquarium_app/lib/screens/workshop_screen.dart apps/aquarium_app/test/widget_tests/compatibility_checker_test.dart apps/aquarium_app/test/widget_tests/workshop_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md docs/superpowers/plans/2026-06-13-compatibility-guided-workflow.md
git diff --cached --check
git commit -m "feat: add guided compatibility workflow"
```

Expected: one scoped commit for CL-P1-006G.
