# Tank Emergency Access Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make emergency help directly reachable from the Tank screen without requiring users to dig through Settings or guides.

**Architecture:** Add a top-bar emergency action to `HomeScreen` beside the existing Tank Toolbox and Tank Settings actions. It routes to the existing `EmergencyGuideScreen`; no new emergency content model is introduced in this slice. Add a widget navigation test plus a source contract so this entry point does not regress.

**Tech Stack:** Flutter, Riverpod, existing `HomeScreen`, `EmergencyGuideScreen`, `NavigationThrottle`, and widget/source tests.

---

## File Structure

- Modify `apps/aquarium_app/test/widget_tests/home_screen_test.dart`: add a widget test that opens Emergency Guide from a Tank with data.
- Modify `apps/aquarium_app/lib/screens/home/home_screen.dart`: import `EmergencyGuideScreen` and add a top-bar `IconButton`.
- Modify `apps/aquarium_app/test/screens/tank_daily_care_contract_test.dart`: add a source contract for the Tank emergency entry point.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`: record CL-P0-006A progress.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`: update CL-P0-006 status.

---

### Task 1: Tank Emergency Entry Test

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/home_screen_test.dart`

- [x] **Step 1: Write failing widget test**

Add imports:

```dart
import 'package:danio/screens/emergency_guide_screen.dart';
import 'package:danio/utils/navigation_throttle.dart';
```

Update `setUp` so navigation throttle cannot leak between tests:

```dart
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    NavigationThrottle.reset();
  });
```

Add the test:

```dart
testWidgets('Tank top bar opens Emergency Guide', (tester) async {
  suppressLayoutErrors();

  await tester.pumpWidget(_wrapWithTank());
  await tester.pump();
  await tester.pump(const Duration(seconds: 5));

  expect(find.byTooltip('Emergency Guide'), findsOneWidget);

  final emergencyButton = tester.widget<IconButton>(
    find.widgetWithIcon(IconButton, Icons.emergency_outlined),
  );
  emergencyButton.onPressed!();
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));

  expect(find.byType(EmergencyGuideScreen), findsOneWidget);
  expect(find.text('Emergency Guide'), findsWidgets);
});
```

- [x] **Step 2: Run test to verify failure**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/home_screen_test.dart --plain-name "Tank top bar opens Emergency Guide"
```

Expected: FAIL because `HomeScreen` does not yet expose an `Emergency Guide` top-bar action.

---

### Task 2: Tank Top-Bar Emergency Action

**Files:**
- Modify: `apps/aquarium_app/lib/screens/home/home_screen.dart`

- [x] **Step 1: Implement navigation action**

Add import:

```dart
import '../emergency_guide_screen.dart';
```

Add an `IconButton` in the top-bar row before Tank Toolbox:

```dart
                    IconButton(
                      icon: const Icon(
                        Icons.emergency_outlined,
                        color: AppColors.error,
                      ),
                      tooltip: 'Emergency Guide',
                      onPressed: () => NavigationThrottle.push(
                        context,
                        const EmergencyGuideScreen(),
                        rootNavigator: true,
                      ),
                    ),
```

- [x] **Step 2: Run widget test and verify pass**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/home_screen_test.dart --plain-name "Tank top bar opens Emergency Guide"
```

Expected: PASS.

---

### Task 3: Contract And Docs

**Files:**
- Modify: `apps/aquarium_app/test/screens/tank_daily_care_contract_test.dart`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [x] **Step 1: Add source contract**

Add:

```dart
  test('Tank top bar keeps Emergency Guide directly reachable', () {
    final source = File('lib/screens/home/home_screen.dart').readAsStringSync();

    expect(source, contains("tooltip: 'Emergency Guide'"));
    expect(source, contains('const EmergencyGuideScreen()'));
    expect(source, contains('Icons.emergency_outlined'));
  });
```

- [x] **Step 2: Update product docs**

Current audit:

```markdown
CL-P0-006A Tank emergency access progress:

- Tank top bar now exposes Emergency Guide directly beside core tank actions, so urgent help is reachable from the centre screen without going through Settings.
```

Backlog CL-P0-006 acceptance:

```markdown
In progress; CL-P0-006A makes Emergency Guide directly reachable from the Tank top bar. Remaining: emergency entry from Tank alerts, Smart, Search/More, lessons, species pages, and water logs.
```

---

### Task 4: Verification And Commit

**Files:**
- All files touched in Tasks 1-3

- [x] **Step 1: Format changed Dart files**

Run:

```powershell
cd apps/aquarium_app
dart format lib/screens/home/home_screen.dart test/widget_tests/home_screen_test.dart test/screens/tank_daily_care_contract_test.dart
```

- [x] **Step 2: Run focused tests**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/home_screen_test.dart --plain-name "Tank top bar opens Emergency Guide"
flutter test test/screens/tank_daily_care_contract_test.dart test/widget_tests/emergency_guide_screen_test.dart
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
git diff -- apps/aquarium_app/lib/screens/home/home_screen.dart apps/aquarium_app/test/widget_tests/home_screen_test.dart apps/aquarium_app/test/screens/tank_daily_care_contract_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-tank-emergency-access.md
```

- [x] **Step 5: Commit**

Run:

```powershell
git add apps/aquarium_app/lib/screens/home/home_screen.dart apps/aquarium_app/test/widget_tests/home_screen_test.dart apps/aquarium_app/test/screens/tank_daily_care_contract_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-tank-emergency-access.md
git commit -m "feat: add tank emergency access"
```
