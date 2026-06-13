# Unsafe Water Emergency Routing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Route unsafe ammonia/nitrite Tank alerts to Emergency Guide so urgent help is available exactly where the risk appears.

**Architecture:** Extend `TankCarePriorityAction` with an `emergencyGuide` action. The care-priority service will classify unsafe nitrogen as emergency guidance rather than just a water-change log shortcut. `TodayBoardCard` will route that action to the existing `EmergencyGuideScreen`.

**Tech Stack:** Flutter, Riverpod, existing `TankCarePriorityService`, `TodayBoardCard`, and widget/unit tests.

---

## File Structure

- Modify `apps/aquarium_app/test/services/tank_care_priority_service_test.dart`: update unsafe ammonia/nitrite expectations.
- Modify `apps/aquarium_app/lib/services/tank_care_priority_service.dart`: add `emergencyGuide` action and unsafe-water copy.
- Modify `apps/aquarium_app/test/widget_tests/today_board_test.dart`: verify unsafe water priority opens Emergency Guide.
- Modify `apps/aquarium_app/lib/screens/home/widgets/today_board.dart`: import and route to `EmergencyGuideScreen`.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`: record CL-P0-006B progress.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`: update CL-P0-006 remaining work.

---

### Task 1: Priority Service Emergency Action

**Files:**
- Modify: `apps/aquarium_app/test/services/tank_care_priority_service_test.dart`
- Modify: `apps/aquarium_app/lib/services/tank_care_priority_service.dart`

- [x] **Step 1: Write failing service expectations**

Change unsafe-water tests to expect the new action:

```dart
expect(priority.action, TankCarePriorityAction.emergencyGuide);
expect(priority.subtitle, contains('emergency steps'));
```

- [x] **Step 2: Run service test to verify failure**

Run:

```powershell
cd apps/aquarium_app
flutter test test/services/tank_care_priority_service_test.dart --plain-name "ammonia above 0.25 returns emergency water-change priority"
```

Expected: FAIL because `TankCarePriorityAction.emergencyGuide` does not exist yet.

- [x] **Step 3: Implement service action**

Change enum:

```dart
enum TankCarePriorityAction {
  emergencyGuide,
  waterChange,
  waterTest,
  feeding,
  tasks,
  none,
}
```

Change unsafe-water return:

```dart
return const TankCarePriority(
  level: TankCarePriorityLevel.emergency,
  action: TankCarePriorityAction.emergencyGuide,
  title: 'Unsafe water detected',
  subtitle: 'Open emergency steps, then log the water change.',
  semanticsLabel: 'Unsafe water detected. Open emergency steps.',
);
```

- [x] **Step 4: Run service tests and verify pass**

Run:

```powershell
cd apps/aquarium_app
flutter test test/services/tank_care_priority_service_test.dart
```

Expected: PASS.

---

### Task 2: Today Board Emergency Routing

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/today_board_test.dart`
- Modify: `apps/aquarium_app/lib/screens/home/widgets/today_board.dart`

- [x] **Step 1: Write failing widget test**

Add import:

```dart
import 'package:danio/screens/emergency_guide_screen.dart';
```

Add test:

```dart
testWidgets('unsafe water priority opens Emergency Guide', (tester) async {
  await tester.pumpWidget(
    _wrap(
      dailyGoal: _completedGoal(),
      tasks: [_task()],
      logs: [_waterTest(ammonia: 0.5), _feeding()],
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('Unsafe water detected'));
  await tester.pumpAndSettle();

  expect(find.byType(EmergencyGuideScreen), findsOneWidget);
});
```

- [x] **Step 2: Run widget test to verify failure**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/today_board_test.dart --plain-name "unsafe water priority opens Emergency Guide"
```

Expected: FAIL because the Today Board does not yet route `emergencyGuide`.

- [x] **Step 3: Route emergency action**

Add import:

```dart
import '../../emergency_guide_screen.dart';
```

Update icon switch:

```dart
case TankCarePriorityAction.emergencyGuide:
  return Icons.emergency_rounded;
```

Update tap switch:

```dart
case TankCarePriorityAction.emergencyGuide:
  destination = const EmergencyGuideScreen();
```

- [x] **Step 4: Run widget tests and verify pass**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/today_board_test.dart
```

Expected: PASS.

---

### Task 3: Docs

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [x] **Step 1: Update product docs**

Current audit:

```markdown
CL-P0-006B unsafe-water emergency routing progress:

- Unsafe ammonia/nitrite priority on the Tank Today Board now opens Emergency Guide, keeping emergency steps one tap away from the alert.
```

Backlog CL-P0-006 acceptance:

```markdown
In progress; CL-P0-006A makes Emergency Guide directly reachable from the Tank top bar. CL-P0-006B routes unsafe-water Tank alerts to Emergency Guide. Remaining: emergency entry from Smart, Search/More, lessons, species pages, and water logs.
```

---

### Task 4: Verification And Commit

**Files:**
- All files touched in Tasks 1-3

- [x] **Step 1: Format changed Dart files**

Run:

```powershell
cd apps/aquarium_app
dart format lib/services/tank_care_priority_service.dart lib/screens/home/widgets/today_board.dart test/services/tank_care_priority_service_test.dart test/widget_tests/today_board_test.dart
```

- [x] **Step 2: Run focused tests**

Run:

```powershell
cd apps/aquarium_app
flutter test test/services/tank_care_priority_service_test.dart test/widget_tests/today_board_test.dart test/widget_tests/emergency_guide_screen_test.dart
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
git diff -- apps/aquarium_app/lib/services/tank_care_priority_service.dart apps/aquarium_app/lib/screens/home/widgets/today_board.dart apps/aquarium_app/test/services/tank_care_priority_service_test.dart apps/aquarium_app/test/widget_tests/today_board_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-unsafe-water-emergency-routing.md
```

- [x] **Step 5: Commit**

Run:

```powershell
git add apps/aquarium_app/lib/services/tank_care_priority_service.dart apps/aquarium_app/lib/screens/home/widgets/today_board.dart apps/aquarium_app/test/services/tank_care_priority_service_test.dart apps/aquarium_app/test/widget_tests/today_board_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-unsafe-water-emergency-routing.md
git commit -m "feat: route unsafe water alerts to emergencies"
```
