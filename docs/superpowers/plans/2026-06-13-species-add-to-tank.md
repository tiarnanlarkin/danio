# Species Add To Tank Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let a user open a fish species detail sheet and add that species to an existing tank through the app's existing livestock creation workflow.

**Architecture:** Reuse the established Fish ID add-to-tank pattern: read `tanksProvider`, show a warning if no tank exists, auto-select a single tank or show the existing app dialog for multiple tanks, then open `LivestockAddDialog` prefilled with species names. Keep persistence inside `LivestockAddDialog` so logs, XP, provider invalidation, and validation stay consistent.

**Tech Stack:** Flutter, Riverpod, app custom `showAppDialog`/`showAppDragSheet`, existing `LivestockAddDialog`, widget tests with `flutter_test` and `InMemoryStorageService`.

---

### Task 1: Add Widget Coverage

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/species_browser_screen_test.dart`
- Read: `apps/aquarium_app/lib/providers/storage_provider.dart`
- Read: `apps/aquarium_app/lib/providers/tank_provider.dart`
- Read: `apps/aquarium_app/lib/services/storage_service.dart`

- [ ] **Step 1: Add imports**

Add these imports near the existing package imports:

```dart
import 'package:danio/models/models.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/services/storage_service.dart';
```

- [ ] **Step 2: Add a wrapper that seeds one tank**

Add this helper below `_wrap()`:

```dart
Widget _wrapWithTank({required InMemoryStorageService storage}) {
  final now = DateTime(2026, 6, 13);
  final tank = Tank(
    id: 'species-test-tank',
    name: 'Species Test Tank',
    type: TankType.freshwater,
    volumeLitres: 120,
    startDate: now,
    targets: WaterTargets.freshwaterTropical(),
    createdAt: now,
    updatedAt: now,
  );

  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(storage),
      tanksProvider.overrideWith((ref) async => [tank]),
    ],
    child: const MaterialApp(home: SpeciesBrowserScreen()),
  );
}
```

- [ ] **Step 3: Write the failing test**

Add this test inside `group('SpeciesBrowserScreen - rendering', () { ... })` near the existing species detail action tests:

```dart
testWidgets('species detail opens prefilled add-to-tank dialog', (
  tester,
) async {
  final storage = InMemoryStorageService();

  await tester.pumpWidget(_wrapWithTank(storage: storage));
  await _advance(tester);

  await tester.tap(find.text('Neon Tetra'));
  await tester.pumpAndSettle();

  await tester.ensureVisible(find.text('Add to tank'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Add to tank'));
  await tester.pumpAndSettle();

  expect(find.text('Add Livestock'), findsOneWidget);
  expect(find.widgetWithText(TextField, 'Neon Tetra'), findsOneWidget);
  expect(find.widgetWithText(TextField, 'Paracheirodon innesi'), findsOneWidget);
  expect(find.widgetWithText(TextField, '6'), findsOneWidget);
});
```

- [ ] **Step 4: Run test to verify it fails**

Run:

```powershell
$env:JAVA_HOME = Join-Path $env:USERPROFILE 'development\jdk-21'
$env:ANDROID_SDK_ROOT = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$env:ANDROID_HOME = $env:ANDROID_SDK_ROOT
$env:Path = "$env:LOCALAPPDATA\Programs\Git\cmd;$env:USERPROFILE\development\flutter\bin;$env:JAVA_HOME\bin;$env:ANDROID_SDK_ROOT\platform-tools;$env:Path"
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/widget_tests/species_browser_screen_test.dart --name "species detail opens prefilled add-to-tank dialog"
```

Expected: FAIL because the species detail `Care Actions` card does not yet render an `Add to tank` button.

### Task 2: Reuse Existing Livestock Add Flow

**Files:**
- Modify: `apps/aquarium_app/lib/screens/species_browser_screen.dart`
- Read: `apps/aquarium_app/lib/features/smart/fish_id/fish_id_screen.dart:278`
- Read: `apps/aquarium_app/lib/screens/livestock/livestock_add_dialog.dart`

- [ ] **Step 1: Add imports**

Add these imports:

```dart
import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../widgets/app_bottom_sheet.dart';
import 'livestock/livestock_add_dialog.dart';
```

If an imported symbol already exists through another import, keep the import list minimal and let `flutter analyze` confirm.

- [ ] **Step 2: Add the button**

In `_CareActionsCard` button `Wrap`, add this button after `Plan stocking fit`:

```dart
AppButton(
  label: 'Add to tank',
  leadingIcon: Icons.add_circle_outline,
  variant: AppButtonVariant.primary,
  size: AppButtonSize.small,
  onPressed: () => _addToTank(context, ref),
),
```

- [ ] **Step 3: Add the helper**

Add this method inside `_CareActionsCard`:

```dart
Future<void> _addToTank(BuildContext context, WidgetRef ref) async {
  final tanks = await ref.read(tanksProvider.future);
  if (!context.mounted) return;

  if (tanks.isEmpty) {
    DanioSnackBar.warning(context, 'Add a tank first before adding livestock.');
    return;
  }

  Tank? selectedTank;
  if (tanks.length == 1) {
    selectedTank = tanks.first;
  } else {
    selectedTank = await showAppDialog<Tank>(
      context: context,
      title: 'Choose a Tank',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: tanks
            .map(
              (tank) => ListTile(
                leading: const Icon(Icons.water),
                title: Text(tank.name),
                subtitle: Text('${tank.volumeLitres.toStringAsFixed(0)} L'),
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context, tank);
                  }
                },
              ),
            )
            .toList(),
      ),
    );
  }

  if (selectedTank == null || !context.mounted) return;

  await showAppDragSheet(
    context: context,
    builder: (_) => LivestockAddDialog(
      tankId: selectedTank!.id,
      prefillCommonName: species.commonName,
      prefillScientificName: species.scientificName,
    ),
  );
}
```

- [ ] **Step 4: Run focused test to verify it passes**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/widget_tests/species_browser_screen_test.dart --name "species detail opens prefilled add-to-tank dialog"
```

Expected: PASS.

### Task 3: Verify And Document

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [ ] **Step 1: Format changed Dart files**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\dart.bat" format lib/screens/species_browser_screen.dart test/widget_tests/species_browser_screen_test.dart
```

- [ ] **Step 2: Normalize line endings**

Run from repo root:

```powershell
$paths = @(
  'apps/aquarium_app/lib/screens/species_browser_screen.dart',
  'apps/aquarium_app/test/widget_tests/species_browser_screen_test.dart'
)
foreach ($path in $paths) {
  $text = [System.IO.File]::ReadAllText($path)
  $text = $text -replace "`r`n", "`n"
  [System.IO.File]::WriteAllText($path, $text, [System.Text.UTF8Encoding]::new($false))
}
```

- [ ] **Step 3: Run verification**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" analyze
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/product/current_audit_doc_truth_test.dart
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" build apk --debug
git diff --check
```

Expected: analyze clean, all tests pass with one additional test, doc truth passes, debug APK builds, diff check clean.

- [ ] **Step 4: Update docs**

Record this slice under CL-P1-003 in both audit docs as completed: species detail pages now offer direct add-to-tank through the existing prefilled livestock flow. Update the total `flutter test` count to the latest verified number.

- [ ] **Step 5: Commit**

Run:

```powershell
git add apps/aquarium_app/lib/screens/species_browser_screen.dart apps/aquarium_app/test/widget_tests/species_browser_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-species-add-to-tank.md
git commit -m "feat: add species tank handoff"
```
