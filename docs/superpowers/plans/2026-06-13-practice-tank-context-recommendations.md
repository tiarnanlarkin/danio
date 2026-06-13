# Practice Tank Context Recommendations Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Skill Drills react to local tank context so Danio can quietly recommend the most relevant practice track from water tests, care tasks, livestock health, and equipment records.

**Architecture:** Extend `PracticeDrillSummary` with optional context fields and add a small `PracticeDrillContext` model derived from existing local tank data. Keep `PracticeDrillService` pure and testable: context changes summary ordering/hints but does not mutate review cards or tank data.

**Tech Stack:** Flutter, Dart, Riverpod, existing tank/log/task/livestock/equipment models, `flutter_test`.

---

### Task 1: Context-Aware Drill Summaries

**Files:**
- Modify: `apps/aquarium_app/lib/models/practice_drill.dart`
- Modify: `apps/aquarium_app/lib/services/practice_drill_service.dart`
- Modify: `apps/aquarium_app/test/services/practice_drill_service_test.dart`

- [ ] **Step 1: Write failing service tests**

Add tests that build summaries with `PracticeDrillContext.fromTankData`:

```dart
test('unsafe water context recommends emergency decisions first', () {
  final now = DateTime(2026, 6, 13, 12);
  final summaries = PracticeDrillService.buildSummaries(
    cards: [
      _card(id: 'water', conceptId: 'wp_ph_section_0'),
      _card(id: 'emergency', conceptId: 'tr_emergency_section_0'),
    ],
    context: PracticeDrillContext.fromTankData(
      logs: [
        _waterTestLog(
          now,
          WaterTestResults(ammonia: 0.25, nitrite: 0.1),
        ),
      ],
      tasks: const [],
      livestock: const [],
      equipment: const [],
      now: now,
    ),
  );

  expect(summaries.first.drill.id, PracticeDrillId.emergencyDecision);
  final emergency = summaries.byId(PracticeDrillId.emergencyDecision);
  expect(emergency.contextHint, contains('Unsafe water'));
  expect(emergency.contextPriority, greaterThan(0));
});

test('missing water-test context recommends parameter reading', () {
  final now = DateTime(2026, 6, 13, 12);
  final summaries = PracticeDrillService.buildSummaries(
    cards: [_card(id: 'water', conceptId: 'wp_ph_section_0')],
    context: PracticeDrillContext.fromTankData(
      logs: const [],
      tasks: const [],
      livestock: const [],
      equipment: [
        _equipment(now, type: EquipmentType.filter),
      ],
      now: now,
    ),
  );

  final parameter = summaries.byId(PracticeDrillId.parameterInterpretation);
  expect(parameter.contextHint, contains('No recent water test'));
  expect(summaries.first.drill.id, PracticeDrillId.parameterInterpretation);
});

test('health alerts recommend diagnosis practice', () {
  final now = DateTime(2026, 6, 13, 12);
  final summaries = PracticeDrillService.buildSummaries(
    cards: [_card(id: 'health', conceptId: 'fh_ich_section_0')],
    context: PracticeDrillContext.fromTankData(
      logs: [_waterTestLog(now, WaterTestResults(ammonia: 0, nitrite: 0))],
      tasks: const [],
      livestock: [
        _livestock(now, healthStatus: HealthStatus.quarantine),
      ],
      equipment: [_equipment(now, type: EquipmentType.filter)],
      now: now,
    ),
  );

  final diagnosis = summaries.byId(PracticeDrillId.diagnosis);
  expect(diagnosis.contextHint, contains('health'));
  expect(summaries.first.drill.id, PracticeDrillId.diagnosis);
});
```

- [ ] **Step 2: Verify red**

Run:

```powershell
flutter test test/services/practice_drill_service_test.dart
```

Expected: compile/test failure because `PracticeDrillContext`, `contextHint`, `contextPriority`, and the `context` argument do not exist yet.

- [ ] **Step 3: Implement model and service support**

In `practice_drill.dart`, add:
- `PracticeDrillSummary.contextHint`
- `PracticeDrillSummary.contextPriority`
- `PracticeDrillContext.fromTankData(...)`

In `practice_drill_service.dart`, add:
- optional `context` parameter to `buildSummaries`
- context signal calculation per drill
- stable sorting by `contextPriority` descending, then catalog order

Signals:
- unsafe ammonia/nitrite -> Emergency Decisions
- missing/stale/latest high nitrate water data -> Parameter Reading
- sick/quarantine livestock -> Diagnosis Practice
- no equipment or overdue care task -> Setup Planning
- 2+ livestock entries -> Compatibility Checks

- [ ] **Step 4: Run focused service tests**

Run:

```powershell
dart format apps/aquarium_app/lib/models/practice_drill.dart apps/aquarium_app/lib/services/practice_drill_service.dart apps/aquarium_app/test/services/practice_drill_service_test.dart
flutter test test/services/practice_drill_service_test.dart
```

Expected: all PracticeDrillService tests pass.

### Task 2: Practice Hub Context Display

**Files:**
- Modify: `apps/aquarium_app/lib/screens/practice_hub_screen.dart`
- Test: `apps/aquarium_app/test/widget_tests/practice_hub_screen_test.dart`

- [ ] **Step 1: Add a widget test for visible context copy**

Add or adjust a Practice Hub test so a provided contextual summary displays the context hint in a drill card. Keep provider setup local to the test and avoid emulator/ADB.

- [ ] **Step 2: Wire Practice Hub to existing providers**

Read the first visible tank from `tanksProvider`, then use existing `logsProvider`, `tasksProvider`, `livestockProvider`, and `equipmentProvider` for that tank. Pass `PracticeDrillContext.fromTankData(...)` into `PracticeDrillService.buildSummaries`.

In `_buildSkillDrillChoice`, show `summary.contextHint` instead of the static drill subtitle when the drill is enabled and a hint is present.

- [ ] **Step 3: Run focused widget/service tests**

Run:

```powershell
flutter test test/services/practice_drill_service_test.dart test/widget_tests/practice_hub_screen_test.dart
```

Expected: service tests and Practice Hub widget tests pass.

### Task 3: Docs, Verification, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`

- [ ] **Step 1: Update CL-P1-005 docs**

Record CL-P1-005G as tank-context recommendations. Keep richer stored tool-result integration as remaining guided-tool work unless this slice adds it directly.

- [ ] **Step 2: Full verification**

Run:

```powershell
flutter analyze
flutter test
flutter test test/copy/current_docs_local_truth_test.dart
flutter build apk --debug --target lib/main.dart
git diff --check
```

Expected: analyzer clean, full suite passes with the new test count, docs truth passes, debug APK builds with only the existing Kotlin Gradle Plugin warning, and diff check is clean.

- [ ] **Step 3: Commit**

Stage only the expected files and commit:

```powershell
git add apps/aquarium_app/lib/models/practice_drill.dart apps/aquarium_app/lib/services/practice_drill_service.dart apps/aquarium_app/lib/screens/practice_hub_screen.dart apps/aquarium_app/test/services/practice_drill_service_test.dart apps/aquarium_app/test/widget_tests/practice_hub_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md docs/superpowers/plans/2026-06-13-practice-tank-context-recommendations.md
git diff --cached --check
git commit -m "feat: add tank-context practice recommendations"
```

Expected: one scoped commit for CL-P1-005G.
