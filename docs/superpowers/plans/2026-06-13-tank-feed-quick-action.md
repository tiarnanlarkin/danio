# Tank Feed Quick Action Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the main Tank screen Feed action log a feeding directly while still giving normal users safe overfeeding-aware feedback.

**Architecture:** Reuse the existing `StorageService` and tank log providers. Keep the feeding guidance sheet available through the room food object, but make the floating Feed quick action behave like a true quick action. Use a widget test to verify the main Tank action menu saves a `LogType.feeding` entry without opening `AddLogScreen`.

**Tech Stack:** Flutter, Riverpod, existing `HomeScreen`, `SpeedDialFAB`, `StorageService`, and widget tests.

---

## File Structure

- Modify `apps/aquarium_app/test/widget_tests/home_screen_test.dart`: add a behavior test that opens the main Tank action menu, taps Feed, and verifies a feeding log is saved.
- Modify `apps/aquarium_app/lib/screens/home/home_screen.dart`: add `_quickLogFeeding`, use it from `RoomControlFAB.onFeed`, and invalidate tank log providers after save.
- Modify `apps/aquarium_app/test/screens/tank_daily_care_contract_test.dart`: add a light source contract for direct feed logging and safe feedback copy.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`: record CL-P0-005B progress.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`: update CL-P0-005 remaining work.

---

### Task 1: Main Tank Feed Action Test

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/home_screen_test.dart`

- [x] **Step 1: Write failing widget test**

Add a test helper that can receive a shared in-memory storage and a tank:

```dart
Widget _wrapWithTank({Tank? tank, InMemoryStorageService? storage}) {
  final memStorage = storage ?? InMemoryStorageService();
  final now = DateTime(2026, 1, 1);
  final resolvedTank =
      tank ??
      Tank(
        id: 'tank-1',
        name: 'Test Tank',
        type: TankType.freshwater,
        volumeLitres: 100,
        startDate: now,
        targets: WaterTargets.freshwaterTropical(),
        createdAt: now,
        updatedAt: now,
      );

  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(memStorage),
      tanksProvider.overrideWith((ref) async => [resolvedTank]),
      currentRoomThemeProvider.overrideWith((ref) => RoomTheme.ocean),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}
```

Add the test:

```dart
testWidgets('main Tank Feed quick action saves a feeding log', (tester) async {
  suppressLayoutErrors();
  final storage = InMemoryStorageService();
  final now = DateTime(2026, 1, 1);
  final tank = Tank(
    id: 'quick-feed-${DateTime.now().microsecondsSinceEpoch}',
    name: 'Quick Feed Tank',
    type: TankType.freshwater,
    volumeLitres: 100,
    startDate: now,
    targets: WaterTargets.freshwaterTropical(),
    createdAt: now,
    updatedAt: now,
  );

  await tester.pumpWidget(_wrapWithTank(tank: tank, storage: storage));
  await tester.pump();
  await tester.pump(const Duration(seconds: 5));

  await tester.tap(find.bySemanticsLabel('Open action menu'));
  await tester.pump(const Duration(milliseconds: 800));
  final feedTapTarget = tester.widget<GestureDetector>(
    find
        .ancestor(of: find.text('Feed'), matching: find.byType(GestureDetector))
        .first,
  );
  feedTapTarget.onTap!();
  await tester.pump(const Duration(milliseconds: 500));

  final logs = await storage.getLogsForTank(tank.id);
  expect(logs.where((log) => log.type == LogType.feeding), hasLength(1));
  expect(find.textContaining('Feeding logged'), findsOneWidget);
  expect(find.byType(AddLogScreen), findsNothing);
});
```

Also import:

```dart
import 'package:danio/screens/add_log_screen.dart';
```

- [x] **Step 2: Run test to verify failure**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/home_screen_test.dart --plain-name "main Tank Feed quick action saves a feeding log"
```

Expected: FAIL because the current Feed action opens the feeding info sheet and does not save a log.

---

### Task 2: Direct Feeding Log Implementation

**Files:**
- Modify: `apps/aquarium_app/lib/screens/home/home_screen.dart`

- [x] **Step 1: Implement `_quickLogFeeding`**

Add the import:

```dart
import '../../providers/storage_provider.dart';
```

Add a helper inside `_HomeScreenState`:

```dart
  Future<void> _quickLogFeeding(
    BuildContext context,
    WidgetRef ref,
    Tank tank,
    List<LogEntry> currentLogs,
  ) async {
    try {
      final now = DateTime.now();
      final storage = ref.read(storageServiceProvider);
      await storage.saveLog(
        LogEntry(
          id: now.microsecondsSinceEpoch.toString(),
          tankId: tank.id,
          type: LogType.feeding,
          timestamp: now,
          title: 'Fed fish',
          createdAt: now,
        ),
      );

      ref.invalidate(logsProvider(tank.id));
      ref.invalidate(allLogsProvider(tank.id));

      if (!context.mounted) return;
      final feedingsToday = _feedingsToday(currentLogs, now) + 1;
      final message = feedingsToday >= 3
          ? 'Feeding logged. $feedingsToday feedings today - keep portions tiny.'
          : 'Feeding logged. Keep portions tiny.';
      DanioSnackBar.success(context, message);
    } catch (e, st) {
      logError(
        'HomeScreen: quick feeding save failed: $e',
        stackTrace: st,
        tag: 'HomeScreen',
      );
      if (context.mounted) {
        DanioSnackBar.error(context, 'Couldn\\'t save that feeding. Try again.');
      }
    }
  }

  int _feedingsToday(List<LogEntry> logs, DateTime now) {
    return logs
        .where(
          (log) =>
              log.type == LogType.feeding &&
              log.timestamp.year == now.year &&
              log.timestamp.month == now.month &&
              log.timestamp.day == now.day,
        )
        .length;
  }
```

Change the main `RoomControlFAB` feed callback:

```dart
              onFeed: () =>
                  _quickLogFeeding(context, ref, currentTank, currentLogs),
```

- [x] **Step 2: Run widget test and verify pass**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/home_screen_test.dart --plain-name "main Tank Feed quick action saves a feeding log"
```

Expected: PASS.

---

### Task 3: Contract And Docs

**Files:**
- Modify: `apps/aquarium_app/test/screens/tank_daily_care_contract_test.dart`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [x] **Step 1: Add source contract**

Add a test to `tank_daily_care_contract_test.dart`:

```dart
  test('main Tank Feed action is a direct care log with safety copy', () {
    final source = File('lib/screens/home/home_screen.dart').readAsStringSync();

    expect(source, contains('Future<void> _quickLogFeeding'));
    expect(source, contains('type: LogType.feeding'));
    expect(source, contains("title: 'Fed fish'"));
    expect(source, contains('Feeding logged. Keep portions tiny.'));
    expect(source, contains('feedings today - keep portions tiny.'));
    expect(
      source,
      contains('_quickLogFeeding(context, ref, currentTank, currentLogs)'),
    );
  });
```

- [x] **Step 2: Update product docs**

Current audit:

```markdown
CL-P0-005B Tank quick-feed progress:

- Main Tank Feed quick action now saves a feeding log directly and gives safety-aware portion feedback, while the room food object still opens the deeper feeding guidance sheet.
```

Backlog CL-P0-005 acceptance:

```markdown
In progress; CL-P0-005A adds care priority and next-best action. CL-P0-005B makes the main Tank Feed action a direct log with safety feedback. Remaining: richer quick action polish, visual QA, and tighter integration with emergency workflows.
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
flutter test test/widget_tests/home_screen_test.dart --plain-name "main Tank Feed quick action saves a feeding log"
flutter test test/screens/tank_daily_care_contract_test.dart
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
git diff -- apps/aquarium_app/lib/screens/home/home_screen.dart apps/aquarium_app/test/widget_tests/home_screen_test.dart apps/aquarium_app/test/screens/tank_daily_care_contract_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-tank-feed-quick-action.md
```

- [x] **Step 5: Commit**

Run:

```powershell
git add apps/aquarium_app/lib/screens/home/home_screen.dart apps/aquarium_app/test/widget_tests/home_screen_test.dart apps/aquarium_app/test/screens/tank_daily_care_contract_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-tank-feed-quick-action.md
git commit -m "feat: quick log feeding from tank"
```
