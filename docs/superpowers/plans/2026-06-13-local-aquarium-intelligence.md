# Local Aquarium Intelligence Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the first complete CL-P0-007 Smart Hub slice: a rule-based, no-AI Aquarium Intelligence section that summarizes risks, care actions, compatibility signals, anomaly history, and reasons from local tank data.

**Architecture:** Add a pure `AquariumIntelligenceService` under `features/smart/intelligence` with small model classes and deterministic rules. Expose it through a Riverpod provider that reads local storage, then render a Smart Hub section above optional-AI cards.

**Tech Stack:** Flutter, Riverpod, existing local storage providers, existing tank/log/task/livestock/equipment models, existing compatibility service, widget tests, service tests.

---

## File Structure

- Create `apps/aquarium_app/lib/features/smart/intelligence/aquarium_intelligence_service.dart`: local intelligence models plus pure evaluation rules.
- Modify `apps/aquarium_app/lib/features/smart/smart_providers.dart`: add `aquariumIntelligenceProvider`.
- Create `apps/aquarium_app/lib/features/smart/intelligence/aquarium_intelligence_section.dart`: Smart Hub UI section for the local report.
- Modify `apps/aquarium_app/lib/screens/smart_screen.dart`: insert `AquariumIntelligenceSection` before optional-AI cards.
- Create `apps/aquarium_app/test/services/aquarium_intelligence_service_test.dart`: service-level rule coverage.
- Modify `apps/aquarium_app/test/widget_tests/smart_screen_test.dart`: widget coverage for no-AI local intelligence.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`: record CL-P0-007A progress.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`: mark CL-P0-007 in progress.

---

### Task 1: Service Rules

**Files:**
- Create: `apps/aquarium_app/test/services/aquarium_intelligence_service_test.dart`
- Create: `apps/aquarium_app/lib/features/smart/intelligence/aquarium_intelligence_service.dart`

- [x] **Step 1: Write failing critical-risk service test**

Add a test that creates one tank, one latest water-test log with ammonia `0.5`, and expects the report to contain one critical risk item with title `Unsafe water detected`, action label `Emergency Guide`, and a reason mentioning `Ammonia 0.50 ppm`.

- [x] **Step 2: Run service test to verify failure**

Run:

```powershell
cd apps/aquarium_app
flutter test test/services/aquarium_intelligence_service_test.dart --plain-name "flags unsafe ammonia as a critical local risk"
```

Expected: FAIL because the service file does not exist yet.

- [x] **Step 3: Implement service models and critical nitrogen rule**

Create:

```dart
enum AquariumIntelligenceSeverity { clear, info, warning, critical }

enum AquariumIntelligenceCategory { risk, care, compatibility, anomaly, equipment }

enum AquariumIntelligenceAction {
  none,
  emergencyGuide,
  waterTest,
  tankDetail,
  workshop,
}

class AquariumIntelligenceTankInput {
  final Tank tank;
  final List<LogEntry> logs;
  final List<Task> tasks;
  final List<Livestock> livestock;
  final List<Equipment> equipment;
  final List<Anomaly> anomalies;
  const AquariumIntelligenceTankInput({
    required this.tank,
    required this.logs,
    required this.tasks,
    required this.livestock,
    required this.equipment,
    this.anomalies = const [],
  });
}

class AquariumIntelligenceItem {
  final String tankId;
  final String tankName;
  final AquariumIntelligenceSeverity severity;
  final AquariumIntelligenceCategory category;
  final AquariumIntelligenceAction action;
  final String title;
  final String reason;
  final String actionLabel;
  const AquariumIntelligenceItem({
    required this.tankId,
    required this.tankName,
    required this.severity,
    required this.category,
    required this.action,
    required this.title,
    required this.reason,
    required this.actionLabel,
  });
}

class AquariumIntelligenceReport {
  final List<AquariumIntelligenceItem> items;
  final int tankCount;
  const AquariumIntelligenceReport({required this.items, required this.tankCount});
  List<AquariumIntelligenceItem> get topItems => items.take(3).toList();
  int get criticalRiskCount => items
      .where((item) =>
          item.category == AquariumIntelligenceCategory.risk &&
          item.severity == AquariumIntelligenceSeverity.critical)
      .length;
  int get careActionCount => items
      .where((item) =>
          item.category == AquariumIntelligenceCategory.care ||
          item.category == AquariumIntelligenceCategory.equipment)
      .length;
  int get compatibilityIssueCount => items
      .where((item) =>
          item.category == AquariumIntelligenceCategory.compatibility)
      .length;
  int get activeAnomalyCount => items
      .where((item) => item.category == AquariumIntelligenceCategory.anomaly)
      .length;
}
```

Implement `AquariumIntelligenceService.evaluate({required List<AquariumIntelligenceTankInput> tanks, DateTime? now})` with:

```dart
static const unsafeNitrogenThreshold = 0.25;
if ((latest.ammonia ?? 0) > unsafeNitrogenThreshold ||
    (latest.nitrite ?? 0) > unsafeNitrogenThreshold) {
  add critical risk item titled 'Unsafe water detected';
}
```

- [x] **Step 4: Run service test to verify pass**

Run:

```powershell
cd apps/aquarium_app
flutter test test/services/aquarium_intelligence_service_test.dart --plain-name "flags unsafe ammonia as a critical local risk"
```

Expected: PASS.

- [x] **Step 5: Add failing care/compatibility/anomaly rule tests**

Add tests for:

- no recent water test creates `Water test due`;
- overdue task creates `Care task overdue`;
- a livestock compatibility issue creates `Compatibility needs review`;
- active anomalies create `Anomaly history needs review`.

- [x] **Step 6: Run service tests to verify failure**

Run:

```powershell
cd apps/aquarium_app
flutter test test/services/aquarium_intelligence_service_test.dart
```

Expected: FAIL on the newly added missing rules.

- [x] **Step 7: Implement remaining local rules**

Add deterministic rules:

- stale or missing latest water test after 7 days -> care item `Water test due`;
- enabled overdue tasks -> care item `Care task overdue`;
- sick/quarantine livestock -> risk item `Livestock health needs review`;
- compatibility service warnings/incompatibilities -> compatibility item `Compatibility needs review`;
- active anomalies -> anomaly item `Anomaly history needs review`;
- overdue equipment maintenance or missing filter registration -> equipment/care item.

- [x] **Step 8: Run full service test**

Run:

```powershell
cd apps/aquarium_app
flutter test test/services/aquarium_intelligence_service_test.dart
```

Expected: PASS.

- [x] **Step 9: Commit service slice**

Run:

```powershell
git add apps/aquarium_app/lib/features/smart/intelligence/aquarium_intelligence_service.dart apps/aquarium_app/test/services/aquarium_intelligence_service_test.dart docs/superpowers/plans/2026-06-13-local-aquarium-intelligence.md
git commit -m "feat: add local aquarium intelligence rules"
```

---

### Task 2: Provider And Smart UI

**Files:**
- Modify: `apps/aquarium_app/lib/features/smart/smart_providers.dart`
- Create: `apps/aquarium_app/lib/features/smart/intelligence/aquarium_intelligence_section.dart`
- Modify: `apps/aquarium_app/lib/screens/smart_screen.dart`
- Modify: `apps/aquarium_app/test/widget_tests/smart_screen_test.dart`

- [ ] **Step 1: Write failing Smart widget test**

Update the Smart test wrapper to accept an `InMemoryStorageService`, override `storageServiceProvider`, save a tank plus unsafe water-test log, render Smart without AI configured, and expect:

- `Aquarium Intelligence`;
- `Local checks, no AI key needed`;
- `Unsafe water detected`;
- `Ammonia 0.50 ppm`;
- `Emergency Guide` action from the intelligence item.

- [ ] **Step 2: Run Smart widget test to verify failure**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/smart_screen_test.dart --plain-name "shows local aquarium intelligence without optional AI"
```

Expected: FAIL because the UI section/provider does not exist yet.

- [ ] **Step 3: Add provider**

In `smart_providers.dart`, add:

```dart
final aquariumIntelligenceProvider =
    FutureProvider.autoDispose<AquariumIntelligenceReport>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  final tanks = await storage.getAllTanks();
  final anomalies = ref.watch(anomalyHistoryProvider);
  final inputs = <AquariumIntelligenceTankInput>[];
  for (final tank in tanks) {
    inputs.add(
      AquariumIntelligenceTankInput(
        tank: tank,
        logs: await storage.getLogsForTank(tank.id, limit: 50),
        tasks: await storage.getTasksForTank(tank.id),
        livestock: await storage.getLivestockForTank(tank.id),
        equipment: await storage.getEquipmentForTank(tank.id),
        anomalies: anomalies
            .where((anomaly) => anomaly.tankId == tank.id && !anomaly.dismissed)
            .toList(),
      ),
    );
  }
  return AquariumIntelligenceService.evaluate(tanks: inputs);
});
```

- [ ] **Step 4: Add UI section**

Create `AquariumIntelligenceSection` as a `ConsumerWidget` that watches `aquariumIntelligenceProvider`, renders a card titled `Aquarium Intelligence`, shows summary chips for risks/care/compatibility/anomalies, lists up to three report items with reasons, and routes item actions through existing `NavigationThrottle`/`AppRoutes`.

- [ ] **Step 5: Insert UI section in Smart**

Import `aquarium_intelligence_section.dart` in `smart_screen.dart` and insert `const AquariumIntelligenceSection()` after the setup-context banner and before `Emergency Guide`.

- [ ] **Step 6: Run Smart widget test to verify pass**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/smart_screen_test.dart --plain-name "shows local aquarium intelligence without optional AI"
```

Expected: PASS.

- [ ] **Step 7: Run full Smart widget test file**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/smart_screen_test.dart
```

Expected: PASS.

- [ ] **Step 8: Commit UI slice**

Run:

```powershell
git add apps/aquarium_app/lib/features/smart/smart_providers.dart apps/aquarium_app/lib/features/smart/intelligence/aquarium_intelligence_section.dart apps/aquarium_app/lib/screens/smart_screen.dart apps/aquarium_app/test/widget_tests/smart_screen_test.dart docs/superpowers/plans/2026-06-13-local-aquarium-intelligence.md
git commit -m "feat: show local aquarium intelligence in smart"
```

---

### Task 3: Docs And Verification

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Modify: `docs/superpowers/plans/2026-06-13-local-aquarium-intelligence.md`

- [ ] **Step 1: Update product tracking**

Record `CL-P0-007A Local Aquarium Intelligence foundation` and mark CL-P0-007 as in progress with local risk/care/compatibility/anomaly/reason coverage started.

- [ ] **Step 2: Format changed Dart files**

Run:

```powershell
cd apps/aquarium_app
dart format lib/features/smart/intelligence/aquarium_intelligence_service.dart lib/features/smart/intelligence/aquarium_intelligence_section.dart lib/features/smart/smart_providers.dart lib/screens/smart_screen.dart test/services/aquarium_intelligence_service_test.dart test/widget_tests/smart_screen_test.dart
```

- [ ] **Step 3: Run focused tests**

Run:

```powershell
cd apps/aquarium_app
flutter test test/services/aquarium_intelligence_service_test.dart test/widget_tests/smart_screen_test.dart
```

- [ ] **Step 4: Run analyzer**

Run:

```powershell
cd apps/aquarium_app
flutter analyze
```

- [ ] **Step 5: Check diff**

Run:

```powershell
git diff --check
git diff -- apps/aquarium_app/lib/features/smart/intelligence/aquarium_intelligence_service.dart apps/aquarium_app/lib/features/smart/intelligence/aquarium_intelligence_section.dart apps/aquarium_app/lib/features/smart/smart_providers.dart apps/aquarium_app/lib/screens/smart_screen.dart apps/aquarium_app/test/services/aquarium_intelligence_service_test.dart apps/aquarium_app/test/widget_tests/smart_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-local-aquarium-intelligence.md
```

- [ ] **Step 6: Commit docs/verification slice**

Run:

```powershell
git add apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-local-aquarium-intelligence.md
git commit -m "docs: record local aquarium intelligence progress"
```
