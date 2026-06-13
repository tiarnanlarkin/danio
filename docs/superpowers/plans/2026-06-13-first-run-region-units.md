# First Run Region And Units Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a guided, skippable first-run region and units choice that persists to the user profile/settings and remains changeable from Preferences.

**Architecture:** Region is profile context because it describes the keeper, while metric/US units reuse the existing `settingsProvider.useMetric` app preference. A new onboarding screen is inserted after Welcome, before experience level, so the app can adapt early without blocking quick start users who skip personalisation.

**Tech Stack:** Flutter, Dart, Riverpod, SharedPreferences, flutter_test.

---

## File Structure

- Modify: `apps/aquarium_app/lib/models/user_profile.dart`
  - Add `regionCode` to `UserProfile`, `copyWith`, `toJson`, and `fromJson`.
- Modify: `apps/aquarium_app/lib/providers/user_profile_notifier.dart`
  - Accept `regionCode` in `createProfile` and `updateProfile`.
- Create: `apps/aquarium_app/lib/screens/onboarding/region_units_screen.dart`
  - Self-contained onboarding screen with region cards, unit chips, and `RegionUnitsChoice`.
- Modify: `apps/aquarium_app/lib/screens/onboarding_screen.dart`
  - Insert `RegionUnitsScreen` after Welcome, persist its values on completion, and keep quick start unguessed.
- Modify: `apps/aquarium_app/lib/screens/settings/settings_screen.dart`
  - Add Units tile and picker under App Settings.
- Modify: `apps/aquarium_app/test/model_tests/serialization_test.dart`
  - Verify `regionCode` round-trips and missing data defaults to null.
- Modify: `apps/aquarium_app/test/providers/user_profile_notifier_test.dart`
  - Verify `createProfile` and `updateProfile` persist region context.
- Create: `apps/aquarium_app/test/widget_tests/region_units_screen_test.dart`
  - Verify onboarding region/unit behavior.
- Modify: `apps/aquarium_app/test/widget/settings_screen_test.dart`
  - Verify Units tile, picker, persistence, and subtitle.
- Create: `apps/aquarium_app/test/copy/onboarding_region_units_flow_test.dart`
  - Source-level contract that the onboarding flow contains the region/units screen and persists settings.
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
  - Record CL-P0-004A evidence.
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
  - Mark CL-P0-004A done and leave broader first-run polishing open.

## Preflight

- [x] **Step 1: Confirm clean starting point**

Run:

```powershell
& "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe" status --short
```

Expected: no output.

- [x] **Step 2: Set Flutter environment for this shell**

Run:

```powershell
$env:JAVA_HOME = Join-Path $env:USERPROFILE 'development\jdk-21'
$env:ANDROID_SDK_ROOT = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$env:ANDROID_HOME = $env:ANDROID_SDK_ROOT
$env:Path = "$env:LOCALAPPDATA\Programs\Git\cmd;$env:USERPROFILE\development\flutter\bin;$env:JAVA_HOME\bin;$env:ANDROID_SDK_ROOT\platform-tools;$env:Path"
```

Expected: command exits without output.

### Task 1: Persist Profile Region Context

**Files:**
- Modify: `apps/aquarium_app/test/model_tests/serialization_test.dart`
- Modify: `apps/aquarium_app/lib/models/user_profile.dart`

- [x] **Step 1: Write the failing serialization assertions**

In `test/model_tests/serialization_test.dart`, add `regionCode: 'gb_ie'` to `_testProfile()`.

Add this assertion inside `UserProfile > round-trip serialization > toJson -> fromJson preserves all fields` near the primary tank type assertion:

```dart
expect(restored.regionCode, original.regionCode);
```

Add this assertion inside `UserProfile > fromJson defaults > provides sensible defaults for scalar-only JSON` near the primary tank type assertion:

```dart
expect(profile.regionCode, isNull);
```

- [x] **Step 2: Run test to verify it fails**

Run:

```powershell
flutter test test\model_tests\serialization_test.dart --plain-name "toJson -> fromJson preserves all fields"
```

Expected: FAIL because `UserProfile` has no `regionCode` getter/constructor argument.

- [x] **Step 3: Add the minimal model implementation**

In `lib/models/user_profile.dart`, add a field after `primaryTankType`:

```dart
final String? regionCode;
```

Add constructor parameter after `primaryTankType`:

```dart
this.regionCode,
```

Add `copyWith` parameter after `primaryTankType`:

```dart
String? regionCode,
```

Pass it into the returned `UserProfile`:

```dart
regionCode: regionCode ?? this.regionCode,
```

Add to `toJson()` after `primaryTankType`:

```dart
'regionCode': regionCode,
```

Add to `fromJson()` after `primaryTankType`:

```dart
regionCode: json['regionCode'] as String?,
```

- [x] **Step 4: Run model tests to verify green**

Run:

```powershell
flutter test test\model_tests\serialization_test.dart
```

Expected: PASS.

### Task 2: Persist Region Through UserProfileNotifier

**Files:**
- Modify: `apps/aquarium_app/test/providers/user_profile_notifier_test.dart`
- Modify: `apps/aquarium_app/lib/providers/user_profile_notifier.dart`

- [x] **Step 1: Write failing provider tests**

In `test/providers/user_profile_notifier_test.dart`, inside `UserProfileNotifier - createProfile`, add:

```dart
    test('stores region code during profile creation', () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(userProfileProvider);
      await _settle();

      await container.read(userProfileProvider.notifier).createProfile(
        experienceLevel: ExperienceLevel.beginner,
        primaryTankType: TankType.freshwater,
        goals: [UserGoal.keepFishAlive],
        regionCode: 'us',
      );
      await _settle();

      final profile = container.read(userProfileProvider).value!;
      expect(profile.regionCode, 'us');
    });
```

Inside `UserProfileNotifier - updateProfile`, add:

```dart
    test('updates region code while preserving progress', () async {
      final json = _profileJson(totalXp: 200);
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(json),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(userProfileProvider);
      await _settle();

      await container.read(userProfileProvider.notifier).updateProfile(
        regionCode: 'europe',
      );
      await _settle();

      final profile = container.read(userProfileProvider).value!;
      expect(profile.regionCode, 'europe');
      expect(profile.totalXp, 200);
    });
```

- [x] **Step 2: Run test to verify it fails**

Run:

```powershell
flutter test test\providers\user_profile_notifier_test.dart --plain-name "stores region code during profile creation"
```

Expected: FAIL because `createProfile` does not accept `regionCode`.

- [x] **Step 3: Add notifier parameters**

In `lib/providers/user_profile_notifier.dart`, add `String? regionCode` to both `createProfile` and `updateProfile`.

For `createProfile`, pass it into `UserProfile`:

```dart
regionCode: regionCode,
```

For `updateProfile`, pass it into `copyWith`:

```dart
regionCode: regionCode ?? current.regionCode,
```

- [x] **Step 4: Run provider tests to verify green**

Run:

```powershell
flutter test test\providers\user_profile_notifier_test.dart
```

Expected: PASS.

### Task 3: Build RegionUnitsScreen

**Files:**
- Create: `apps/aquarium_app/test/widget_tests/region_units_screen_test.dart`
- Create: `apps/aquarium_app/lib/screens/onboarding/region_units_screen.dart`

- [x] **Step 1: Write failing widget tests**

Create `test/widget_tests/region_units_screen_test.dart` with:

```dart
// Widget tests for RegionUnitsScreen.
//
// Run: flutter test test/widget_tests/region_units_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/onboarding/region_units_screen.dart';

Widget _wrap({
  ValueChanged<RegionUnitsChoice>? onContinue,
  VoidCallback? onSkip,
}) {
  return MaterialApp(
    home: RegionUnitsScreen(
      onContinue: onContinue ?? (_) {},
      onSkip: onSkip,
    ),
  );
}

void main() {
  group('RegionUnitsScreen', () {
    testWidgets('shows region heading and universal choices', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(find.byType(RegionUnitsScreen), findsOneWidget);
      expect(find.text('Where are you based?'), findsOneWidget);
      expect(find.text('UK & Ireland'), findsOneWidget);
      expect(find.text('Europe'), findsOneWidget);
      expect(find.text('United States'), findsOneWidget);
      expect(find.text('Canada'), findsOneWidget);
      expect(find.text('Australia & New Zealand'), findsOneWidget);
      expect(find.text('Somewhere else'), findsOneWidget);
    });

    testWidgets('selecting United States defaults to US units', (tester) async {
      RegionUnitsChoice? choice;
      await tester.pumpWidget(_wrap(onContinue: (value) => choice = value));
      await tester.pump();

      await tester.tap(find.text('United States'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(choice?.regionCode, 'us');
      expect(choice?.useMetric, isFalse);
    });

    testWidgets('selecting Europe defaults to metric units', (tester) async {
      RegionUnitsChoice? choice;
      await tester.pumpWidget(_wrap(onContinue: (value) => choice = value));
      await tester.pump();

      await tester.tap(find.text('Europe'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(choice?.regionCode, 'europe');
      expect(choice?.useMetric, isTrue);
    });

    testWidgets('unit choice can override the region default', (tester) async {
      RegionUnitsChoice? choice;
      await tester.pumpWidget(_wrap(onContinue: (value) => choice = value));
      await tester.pump();

      await tester.tap(find.text('United States'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Metric'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(choice?.regionCode, 'us');
      expect(choice?.useMetric, isTrue);
    });

    testWidgets('skip action remains available when supplied', (tester) async {
      var skipped = false;
      await tester.pumpWidget(_wrap(onSkip: () => skipped = true));
      await tester.pump();

      final skipButton = find.bySemanticsLabel('Skip setup for now');
      expect(skipButton, findsOneWidget);

      await tester.tap(skipButton);
      await tester.pump();

      expect(skipped, isTrue);
    });
  });
}
```

- [x] **Step 2: Run test to verify it fails**

Run:

```powershell
flutter test test\widget_tests\region_units_screen_test.dart
```

Expected: FAIL because `region_units_screen.dart` does not exist.

- [x] **Step 3: Create RegionUnitsScreen**

Create `lib/screens/onboarding/region_units_screen.dart` with a `RegionUnitsChoice` value class, six region cards, Metric/US unit filter chips, a disabled-until-selected Continue button, and an optional text skip button. Use `AppColors.onboardingWarmCream`, `AppSpacing`, `AppTypography`, and `AppButton` to match existing onboarding screens.

The screen must emit:

```dart
const RegionUnitsChoice(regionCode: 'us', useMetric: false)
```

after selecting United States and pressing Continue, unless the user manually changes the unit chips.

- [x] **Step 4: Run widget tests to verify green**

Run:

```powershell
flutter test test\widget_tests\region_units_screen_test.dart
```

Expected: PASS.

### Task 4: Wire RegionUnitsScreen Into Onboarding

**Files:**
- Create: `apps/aquarium_app/test/copy/onboarding_region_units_flow_test.dart`
- Modify: `apps/aquarium_app/lib/screens/onboarding_screen.dart`

- [x] **Step 1: Write failing onboarding source contract**

Create `test/copy/onboarding_region_units_flow_test.dart` with:

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('onboarding includes region and units before experience level', () {
    final source = File(
      'lib/screens/onboarding_screen.dart',
    ).readAsStringSync();

    expect(source, contains("import 'onboarding/region_units_screen.dart';"));
    expect(source, contains('static const _totalPages = 11;'));
    expect(source.indexOf('RegionUnitsScreen('), lessThan(source.indexOf('ExperienceLevelScreen(')));
    expect(source, contains('ref.read(settingsProvider.notifier).setUseMetric'));
    expect(source, contains('regionCode: _regionCode'));
    expect(source, contains('onSkip: _quickStart'));
  });
}
```

- [x] **Step 2: Run test to verify it fails**

Run:

```powershell
flutter test test\copy\onboarding_region_units_flow_test.dart
```

Expected: FAIL because the onboarding screen does not import or use `RegionUnitsScreen`.

- [x] **Step 3: Update onboarding flow**

In `lib/screens/onboarding_screen.dart`:

- Import `settings_provider.dart`.
- Import `onboarding/region_units_screen.dart`.
- Add fields:

```dart
String? _regionCode;
bool _useMetricUnits = true;
```

- Change `_totalPages` from `10` to `11`.
- Insert `RegionUnitsScreen` after `WelcomeScreen`.
- Move the existing page comments and fallback step numbers forward by one.
- In the `RegionUnitsScreen.onContinue` callback:

```dart
setState(() {
  _regionCode = choice.regionCode;
  _useMetricUnits = choice.useMetric;
});
_nextPage();
```

- In `_completeOnboarding`, before creating/updating the profile:

```dart
await ref.read(settingsProvider.notifier).setUseMetric(_useMetricUnits);
```

- Pass `regionCode: _regionCode` to both `createProfile` and `updateProfile`.
- Keep `_quickStart` free of a guessed `regionCode`; let skipped areas ask later.

- [x] **Step 4: Run onboarding source contract**

Run:

```powershell
flutter test test\copy\onboarding_region_units_flow_test.dart
```

Expected: PASS.

### Task 5: Add Preferences Units Picker

**Files:**
- Modify: `apps/aquarium_app/test/widget/settings_screen_test.dart`
- Modify: `apps/aquarium_app/lib/screens/settings/settings_screen.dart`

- [x] **Step 1: Write failing settings tests**

In `test/widget/settings_screen_test.dart`, after the Theme Mode group, add:

```dart
  group('_UnitsTile', () {
    testWidgets('shows Units tile with metric subtitle by default', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Units'), 500.0);
      expect(find.text('Units'), findsOneWidget);
      expect(find.text('Metric (litres, cm, C)'), findsOneWidget);
    });

    testWidgets('opens units picker on tap', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Units'), 500.0);
      await tester.tap(find.text('Units'));
      await tester.pumpAndSettle();

      expect(find.text('Choose Units'), findsOneWidget);
      expect(find.text('US units'), findsOneWidget);
    });

    testWidgets('selecting US units updates the visible subtitle', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Units'), 500.0);
      await tester.tap(find.text('Units'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('US units'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Units'), 500.0);
      expect(find.text('US units (gallons, inches, F)'), findsOneWidget);
    });
  });
```

- [x] **Step 2: Run test to verify it fails**

Run:

```powershell
flutter test test\widget\settings_screen_test.dart --plain-name "shows Units tile with metric subtitle by default"
```

Expected: FAIL because there is no Units tile.

- [x] **Step 3: Add Units tile and picker**

In `lib/screens/settings/settings_screen.dart`, add `(_) => const _UnitsTile(),` after `_RoomThemeTile()`.

Add helpers near `_ThemeModeTile`:

```dart
String _unitsLabel(bool useMetric) {
  return useMetric
      ? 'Metric (litres, cm, C)'
      : 'US units (gallons, inches, F)';
}

void _showUnitsPicker(BuildContext context, WidgetRef ref, bool useMetric) {
  showAppDragSheet(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Choose Units',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          AppListTile(
            leading: const Icon(Icons.straighten),
            title: 'Metric',
            subtitle: 'Litres, centimetres, Celsius',
            isSelected: useMetric,
            trailing: useMetric
                ? const Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () {
              ref.read(settingsProvider.notifier).setUseMetric(true);
              Navigator.maybePop(ctx);
            },
          ),
          AppListTile(
            leading: const Icon(Icons.speed),
            title: 'US units',
            subtitle: 'Gallons, inches, Fahrenheit',
            isSelected: !useMetric,
            trailing: !useMetric
                ? const Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () {
              ref.read(settingsProvider.notifier).setUseMetric(false);
              Navigator.maybePop(ctx);
            },
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    ),
  );
}

class _UnitsTile extends ConsumerWidget {
  const _UnitsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useMetric = ref.watch(settingsProvider.select((s) => s.useMetric));
    return NavListTile(
      icon: Icons.straighten,
      title: 'Units',
      subtitle: _unitsLabel(useMetric),
      onTap: () => _showUnitsPicker(context, ref, useMetric),
    );
  }
}
```

- [x] **Step 4: Run settings tests to verify green**

Run:

```powershell
flutter test test\widget\settings_screen_test.dart
```

Expected: PASS.

### Task 6: Audit Docs, Full Verification, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [x] **Step 1: Update audit docs**

Record CL-P0-004A as complete with these evidence items:

```text
Profile region context persists through UserProfile JSON and notifier create/update paths.
Onboarding now asks broad region/units before experience level and persists unit preference.
Preferences now exposes a Units picker so users can change units after onboarding.
Quick start remains skippable and does not guess a region.
```

- [x] **Step 2: Run focused verification**

Run:

```powershell
flutter test test\model_tests\serialization_test.dart test\providers\user_profile_notifier_test.dart test\widget_tests\region_units_screen_test.dart test\copy\onboarding_region_units_flow_test.dart test\widget\settings_screen_test.dart
```

Expected: PASS.

- [x] **Step 3: Run analyzer**

Run:

```powershell
flutter analyze
```

Expected: no issues found.

- [x] **Step 4: Run full test suite**

Run:

```powershell
flutter test
```

Expected: PASS.

- [x] **Step 5: Build debug APK**

Run:

```powershell
flutter build apk --debug
```

Expected: debug APK builds. Existing Kotlin Gradle Plugin warning is allowed as a known future maintenance item.

- [x] **Step 6: Inspect diff and commit**

Run:

```powershell
& "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe" diff --check
& "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe" status --short
```

Expected: `diff --check` exits 0 and status lists only this slice.

Commit:

```powershell
& "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe" add apps\aquarium_app\docs\product\danio-complete-local-current-audit-2026-06-13.md apps\aquarium_app\docs\product\danio-complete-local-audit-backlog-2026-06-13.md docs\superpowers\plans\2026-06-13-first-run-region-units.md apps\aquarium_app\lib\models\user_profile.dart apps\aquarium_app\lib\providers\user_profile_notifier.dart apps\aquarium_app\lib\screens\onboarding\region_units_screen.dart apps\aquarium_app\lib\screens\onboarding_screen.dart apps\aquarium_app\lib\screens\settings\settings_screen.dart apps\aquarium_app\test\model_tests\serialization_test.dart apps\aquarium_app\test\providers\user_profile_notifier_test.dart apps\aquarium_app\test\widget_tests\region_units_screen_test.dart apps\aquarium_app\test\copy\onboarding_region_units_flow_test.dart apps\aquarium_app\test\widget\settings_screen_test.dart
& "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe" commit -m "feat: add first-run region and units setup"
```

Expected: commit succeeds.

## Self-Review

- Spec coverage: The plan covers guided first-run region capture, unit preference capture, skippable quick start, settings reset/change path, and documentation evidence.
- Placeholder scan: No placeholder implementation steps remain; each task names exact files, tests, commands, and expected outcomes.
- Type consistency: `regionCode` is a nullable `String` on `UserProfile`, `createProfile`, and `updateProfile`; units remain the existing `bool useMetric` in `AppSettings`.
