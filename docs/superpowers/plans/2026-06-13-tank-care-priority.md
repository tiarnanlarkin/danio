# Tank Care Priority Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give the Tank screen a clear next-best care action based on urgent water readings, overdue tasks, and missing/stale care logs.

**Architecture:** Add a pure `TankCarePriorityService` that ranks care needs from existing tasks and logs. Surface its result in `TodayBoardCard` as a compact actionable strip above task rows / empty-state actions. Quick actions route to existing `AddLogScreen` and `TasksScreen` instead of creating new flows.

**Tech Stack:** Flutter, Riverpod, existing `tasksProvider`/`logsProvider`, existing models `Task` and `LogEntry`.

---

## File Structure

- Create `apps/aquarium_app/lib/services/tank_care_priority_service.dart`: pure care-priority evaluator.
- Create `apps/aquarium_app/test/services/tank_care_priority_service_test.dart`: unit tests for priority ordering.
- Modify `apps/aquarium_app/lib/screens/home/widgets/today_board.dart`: watch logs, render priority strip, and route quick actions.
- Modify `apps/aquarium_app/test/widget_tests/today_board_test.dart`: override logs provider and add UI tests for urgent/stale-priority copy.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`: record CL-P0-005A progress.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`: update CL-P0-005 remaining work.

---

### Task 1: Care Priority Service

**Files:**
- Create: `apps/aquarium_app/test/services/tank_care_priority_service_test.dart`
- Create: `apps/aquarium_app/lib/services/tank_care_priority_service.dart`

- [x] **Step 1: Write failing service tests**

Test:

- ammonia or nitrite above `0.25` returns emergency water-change priority
- overdue enabled task returns task priority when no emergency exists
- no water test returns water-test priority
- safe recent test and no tasks returns clear state

- [x] **Step 2: Run service tests and verify failure**

Run:

```powershell
cd apps/aquarium_app
flutter test test/services/tank_care_priority_service_test.dart
```

Expected: FAIL because service does not exist.

- [x] **Step 3: Implement service**

Create:

```dart
enum TankCarePriorityLevel { emergency, due, suggested, clear }
enum TankCarePriorityAction { waterChange, waterTest, feeding, tasks, none }

class TankCarePriority {
  final TankCarePriorityLevel level;
  final TankCarePriorityAction action;
  final String title;
  final String subtitle;
  final String semanticsLabel;
}
```

Rules in order:

1. Latest water test ammonia or nitrite `> 0.25`: `Unsafe water detected`, action `waterChange`.
2. Any enabled overdue task: `Overdue care task`, action `tasks`.
3. No water test, or latest water test older than 7 days: `Log a water test`, action `waterTest`.
4. No feeding log today: `Log feeding when you feed`, action `feeding`.
5. Otherwise: `Care on track`, action `none`.

- [x] **Step 4: Run service tests and verify pass**

Run:

```powershell
cd apps/aquarium_app
flutter test test/services/tank_care_priority_service_test.dart
```

Expected: PASS.

---

### Task 2: Today Board Integration

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/today_board_test.dart`
- Modify: `apps/aquarium_app/lib/screens/home/widgets/today_board.dart`

- [x] **Step 1: Write failing Today Board tests**

Update `_wrap` and `_wrapEmptyBoard` to override `logsProvider('tank-1')`.

Add tests:

```dart
testWidgets('shows unsafe water priority above tasks', ...)
testWidgets('shows water-test priority when no water tests are logged', ...)
```

Expect text `Unsafe water detected` and `Log a water test`.

- [x] **Step 2: Run Today Board tests and verify failure**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/today_board_test.dart
```

Expected: FAIL because Today Board does not render care priority.

- [x] **Step 3: Render care priority strip**

In `TodayBoardCard`:

- watch `logsProvider(tankId)`
- evaluate `TankCarePriorityService.evaluate(tasks: tasks, logs: logs)`
- render `_CarePriorityStrip` before task content and before empty-state content
- tap actions:
  - `waterChange` -> `AddLogScreen(tankId: tankId, initialType: LogType.waterChange)`
  - `waterTest` -> `AddLogScreen(tankId: tankId, initialType: LogType.waterTest)`
  - `feeding` -> `AddLogScreen(tankId: tankId, initialType: LogType.feeding)`
  - `tasks` -> `TasksScreen(tankId: tankId)`

- [x] **Step 4: Run Today Board tests and verify pass**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/today_board_test.dart
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
- CL-P0-005A complete: Tank Today Board now computes a care priority from water logs and tasks, surfaces the next-best action, and routes quick actions to existing log/task flows.
```

- [x] **Step 2: Update backlog**

Update CL-P0-005:

```markdown
In progress; CL-P0-005A adds care priority and next-best action. Remaining: richer quick action polish, visual QA, and tighter integration with emergency workflows.
```

---

### Task 4: Verification and Commit

**Files:**
- All files touched in Tasks 1-3

- [x] **Step 1: Format changed Dart files**

Run:

```powershell
cd apps/aquarium_app
dart format lib/services/tank_care_priority_service.dart lib/screens/home/widgets/today_board.dart test/services/tank_care_priority_service_test.dart test/widget_tests/today_board_test.dart
```

- [x] **Step 2: Run focused verification**

Run:

```powershell
cd apps/aquarium_app
flutter test test/services/tank_care_priority_service_test.dart test/widget_tests/today_board_test.dart test/screens/tank_daily_care_contract_test.dart
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
git diff -- apps/aquarium_app/lib/services/tank_care_priority_service.dart apps/aquarium_app/lib/screens/home/widgets/today_board.dart apps/aquarium_app/test/services/tank_care_priority_service_test.dart apps/aquarium_app/test/widget_tests/today_board_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-tank-care-priority.md
```

- [x] **Step 5: Commit**

Run:

```powershell
git add apps/aquarium_app/lib/services/tank_care_priority_service.dart apps/aquarium_app/lib/screens/home/widgets/today_board.dart apps/aquarium_app/test/services/tank_care_priority_service_test.dart apps/aquarium_app/test/widget_tests/today_board_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-tank-care-priority.md
git commit -m "feat: add tank care priority"
```
