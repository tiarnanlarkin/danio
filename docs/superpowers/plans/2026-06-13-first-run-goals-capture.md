# First-Run Goals Capture Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a guided onboarding goals step so Danio captures more than one care intent and can recommend the next best thing without forcing a rigid track.

**Architecture:** Insert a `GoalsScreen` after `TankStatusScreen`. `OnboardingScreen` will compute one recommended goal from the selected tank stage and experience level, let users select multiple goals, then persist selected goals through the existing `UserProfile.goals` field. If the user reaches completion without explicit goals, fallback to the recommendation derived from information they already gave.

**Tech Stack:** Flutter, Riverpod, Dart widget tests, source-level onboarding flow contracts.

---

## File Structure

- Create `apps/aquarium_app/lib/screens/onboarding/goals_screen.dart`: multi-select goals UI with one recommended goal chip.
- Create `apps/aquarium_app/test/widget_tests/goals_screen_test.dart`: widget tests for rendering, multi-select, and recommended fallback.
- Modify `apps/aquarium_app/lib/screens/onboarding_screen.dart`: add goals state, route page, total page count, fallback indexes, and profile persistence.
- Modify `apps/aquarium_app/test/copy/onboarding_region_units_flow_test.dart`: update source contract for 12 onboarding pages and goals step placement.
- Create `apps/aquarium_app/test/copy/onboarding_goals_flow_test.dart`: source contract for persistence and fallback behavior.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`: record CL-P0-004C progress and next step.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`: update CL-P0-004 remaining work.

---

### Task 1: Goals Screen Widget Contract

**Files:**
- Create: `apps/aquarium_app/test/widget_tests/goals_screen_test.dart`
- Create: `apps/aquarium_app/lib/screens/onboarding/goals_screen.dart`

- [x] **Step 1: Write failing widget tests**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/models/user_profile.dart';
import 'package:danio/screens/onboarding/goals_screen.dart';

Widget _wrap({
  ValueChanged<List<UserGoal>>? onContinue,
  UserGoal recommendedGoal = UserGoal.keepFishAlive,
}) {
  return MaterialApp(
    home: GoalsScreen(
      recommendedGoal: recommendedGoal,
      onContinue: onContinue ?? (_) {},
    ),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('shows normal-user goal choices with one recommendation', (tester) async {
    await tester.pumpWidget(_wrap(recommendedGoal: UserGoal.learnTheScience));
    await _advance(tester);

    expect(find.text('What should Danio help with first?'), findsOneWidget);
    expect(find.text('Keep fish healthy'), findsOneWidget);
    expect(find.text('Plan with confidence'), findsOneWidget);
    expect(find.text('Recommended'), findsOneWidget);
  });

  testWidgets('can select multiple goals and continue', (tester) async {
    List<UserGoal>? chosen;
    await tester.pumpWidget(_wrap(onContinue: (goals) => chosen = goals));
    await _advance(tester);

    await tester.tap(find.text('Keep fish healthy'));
    await tester.pump();
    await tester.tap(find.text('Create a beautiful tank'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(chosen, containsAll([UserGoal.keepFishAlive, UserGoal.beautifulDisplay]));
  });

  testWidgets('skip uses the recommended goal without extra guessing', (tester) async {
    List<UserGoal>? chosen;
    await tester.pumpWidget(
      _wrap(
        recommendedGoal: UserGoal.masterTheHobby,
        onContinue: (goals) => chosen = goals,
      ),
    );
    await _advance(tester);

    await tester.tap(find.text('Use recommendation'));
    await tester.pump();

    expect(chosen, [UserGoal.masterTheHobby]);
  });
}
```

- [x] **Step 2: Run the widget test and verify it fails**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/goals_screen_test.dart
```

Expected: FAIL because `GoalsScreen` does not exist.

- [x] **Step 3: Implement minimal `GoalsScreen`**

Build a warm onboarding screen with:

- title `What should Danio help with first?`
- helper text that explains users can pick more than one
- selectable cards mapped to existing `UserGoal` values
- a `Recommended` chip on the recommended goal
- `Continue` disabled until a goal is selected
- `Use recommendation` text button that returns `[recommendedGoal]`

- [x] **Step 4: Run the widget test and verify it passes**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/goals_screen_test.dart
```

Expected: PASS.

---

### Task 2: Onboarding Flow Integration

**Files:**
- Modify: `apps/aquarium_app/lib/screens/onboarding_screen.dart`
- Modify: `apps/aquarium_app/test/copy/onboarding_region_units_flow_test.dart`
- Create: `apps/aquarium_app/test/copy/onboarding_goals_flow_test.dart`

- [x] **Step 1: Write failing source contracts**

`onboarding_region_units_flow_test.dart` should expect `static const _totalPages = 12;`.

`onboarding_goals_flow_test.dart` should assert:

```dart
expect(source, contains("import 'onboarding/goals_screen.dart';"));
expect(source.indexOf('GoalsScreen('), greaterThan(source.indexOf('TankStatusScreen(')));
expect(source.indexOf('GoalsScreen('), lessThan(source.indexOf('MicroLessonScreen(')));
expect(source, contains('List<UserGoal> _selectedGoals = const [];'));
expect(source, contains('List<UserGoal> _effectiveGoals()'));
expect(source, contains('goals: _effectiveGoals()'));
expect(source, isNot(contains('goals: [_deriveGoal()]')));
```

- [x] **Step 2: Run source contracts and verify failure**

Run:

```powershell
cd apps/aquarium_app
flutter test test/copy/onboarding_region_units_flow_test.dart test/copy/onboarding_goals_flow_test.dart
```

Expected: FAIL because goals flow is not wired and `_totalPages` is still 11.

- [x] **Step 3: Wire goals into onboarding**

Change `OnboardingScreen`:

- import `goals_screen.dart`
- add `List<UserGoal> _selectedGoals = const [];`
- set `_totalPages = 12`
- replace `_deriveGoal()` with `_recommendedGoal()` and `_effectiveGoals()`
- pass `goals: _effectiveGoals()` to create/update profile
- insert `GoalsScreen` after `TankStatusScreen`
- shift later page comments and `goToStep` indexes by one

- [x] **Step 4: Run source contracts and verify pass**

Run:

```powershell
cd apps/aquarium_app
flutter test test/copy/onboarding_region_units_flow_test.dart test/copy/onboarding_goals_flow_test.dart
```

Expected: PASS.

---

### Task 3: Product Audit Update

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [x] **Step 1: Update current audit**

Record CL-P0-004C as complete:

```markdown
- CL-P0-004C complete: Onboarding now captures multiple user goals after tank stage, marks one recommendation based on known context, persists selected goals, and falls back only to the derived recommendation when no explicit goals were selected.
```

- [x] **Step 2: Update backlog**

Update CL-P0-004 remaining work:

```markdown
Remaining: contextual missing-context prompts and final first-run screen QA.
```

---

### Task 4: Verification and Commit

**Files:**
- All files touched in Tasks 1-3

- [x] **Step 1: Format changed Dart files**

Run:

```powershell
cd apps/aquarium_app
dart format lib/screens/onboarding_screen.dart lib/screens/onboarding/goals_screen.dart test/widget_tests/goals_screen_test.dart test/copy/onboarding_region_units_flow_test.dart test/copy/onboarding_goals_flow_test.dart
```

Expected: formatting succeeds.

- [x] **Step 2: Run focused verification**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/goals_screen_test.dart test/copy/onboarding_region_units_flow_test.dart test/copy/onboarding_goals_flow_test.dart test/model_tests/serialization_test.dart test/providers/user_profile_notifier_test.dart
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
git diff -- apps/aquarium_app/lib/screens/onboarding_screen.dart apps/aquarium_app/lib/screens/onboarding/goals_screen.dart apps/aquarium_app/test/widget_tests/goals_screen_test.dart apps/aquarium_app/test/copy/onboarding_region_units_flow_test.dart apps/aquarium_app/test/copy/onboarding_goals_flow_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-first-run-goals-capture.md
```

Expected: no whitespace errors, diff limited to this slice.

- [x] **Step 5: Commit**

Run:

```powershell
git add apps/aquarium_app/lib/screens/onboarding_screen.dart apps/aquarium_app/lib/screens/onboarding/goals_screen.dart apps/aquarium_app/test/widget_tests/goals_screen_test.dart apps/aquarium_app/test/copy/onboarding_region_units_flow_test.dart apps/aquarium_app/test/copy/onboarding_goals_flow_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-first-run-goals-capture.md
git commit -m "feat: capture onboarding goals"
```

Expected: commit succeeds.
