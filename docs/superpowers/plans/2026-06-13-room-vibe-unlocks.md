# Room Vibe Unlocks Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make room themes feel like meaningful local progression rewards by showing which tank vibes are unlocked and why.

**Architecture:** Add a derived unlock service/provider that maps existing profile progress and species unlocks to `RoomThemeType` availability. The theme picker keeps every room vibe visible as an aspirational gallery, but locked premium vibes cannot be applied until the requirement is met. Starter/cozy themes stay available so users never lose a polished local experience.

**Tech Stack:** Flutter, Riverpod, existing `UserProfile`, existing `speciesUnlockProvider`, existing `RoomThemeType`.

---

### Task 1: Add Room Theme Unlock Service

**Files:**
- Create: `apps/aquarium_app/lib/services/room_theme_unlock_service.dart`
- Test: `apps/aquarium_app/test/services/room_theme_unlock_service_test.dart`

- [ ] **Step 1: Write failing service tests**

Create tests for:

```dart
test('starter room vibes are always unlocked', () {
  final states = RoomThemeUnlockService.statesFor(
    profile: null,
    unlockedSpecies: defaultUnlockedSpecies.toSet(),
  );

  expect(states[RoomThemeType.ocean]!.isUnlocked, isTrue);
  expect(states[RoomThemeType.cozyLiving]!.isUnlocked, isTrue);
  expect(states[RoomThemeType.golden]!.isUnlocked, isTrue);
});

test('first earned species unlocks pastel', () {
  final states = RoomThemeUnlockService.statesFor(
    profile: null,
    unlockedSpecies: {...defaultUnlockedSpecies, 'betta'},
  );

  expect(states[RoomThemeType.pastel]!.isUnlocked, isTrue);
});

test('seven day streak unlocks midnight and evening glow', () {
  final profile = _profile(currentStreak: 7);
  final states = RoomThemeUnlockService.statesFor(
    profile: profile,
    unlockedSpecies: defaultUnlockedSpecies.toSet(),
  );

  expect(states[RoomThemeType.eveningGlow]!.isUnlocked, isTrue);
  expect(states[RoomThemeType.midnight]!.isUnlocked, isTrue);
});

test('locked themes expose plain requirement copy', () {
  final states = RoomThemeUnlockService.statesFor(
    profile: _profile(),
    unlockedSpecies: defaultUnlockedSpecies.toSet(),
  );

  expect(states[RoomThemeType.aurora]!.isUnlocked, isFalse);
  expect(states[RoomThemeType.aurora]!.requirementLabel, isNotEmpty);
});
```

- [ ] **Step 2: Run service test for RED**

Run:

```powershell
flutter test test/services/room_theme_unlock_service_test.dart
```

Expected: compile failure because the service does not exist.

- [ ] **Step 3: Implement service**

Create:

```dart
class RoomThemeUnlockState {
  final RoomThemeType type;
  final bool isUnlocked;
  final String requirementLabel;

  const RoomThemeUnlockState({
    required this.type,
    required this.isUnlocked,
    required this.requirementLabel,
  });
}
```

`RoomThemeUnlockService.statesFor({required UserProfile? profile, required Set<String> unlockedSpecies})` should:

- Always unlock `ocean`, `cozyLiving`, and `golden`.
- Unlock `pastel` after the first earned species beyond defaults.
- Unlock `eveningGlow` at a 3-day streak.
- Unlock `midnight` at a 7-day streak or `night_owl` achievement.
- Unlock `dreamy` after 10 completed lessons or `lessons_10` achievement.
- Unlock `sunset` at 300 XP.
- Unlock `forest` after five unlocked species or `five_species` achievement.
- Unlock `watercolor` at 1000 XP.
- Unlock `cotton` after `perfectionist` achievement or 3 perfect scores.
- Unlock `aurora` at 2500 XP.

- [ ] **Step 4: Run service tests for GREEN**

Run:

```powershell
flutter test test/services/room_theme_unlock_service_test.dart
```

### Task 2: Add Riverpod Unlock Provider

**Files:**
- Create: `apps/aquarium_app/lib/providers/room_theme_unlock_provider.dart`
- Test: `apps/aquarium_app/test/providers/room_theme_unlock_provider_test.dart`

- [ ] **Step 1: Write failing provider test**

Use `ProviderContainer` with mocked SharedPreferences and seeded unlocked species, then expect:

```dart
final states = container.read(roomThemeUnlockStatesProvider);
expect(states[RoomThemeType.pastel]!.isUnlocked, isTrue);
```

- [ ] **Step 2: Run provider test for RED**

Run:

```powershell
flutter test test/providers/room_theme_unlock_provider_test.dart
```

- [ ] **Step 3: Implement provider**

Create:

```dart
final roomThemeUnlockStatesProvider =
    Provider<Map<RoomThemeType, RoomThemeUnlockState>>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  final unlockedSpecies = ref.watch(speciesUnlockProvider);
  return RoomThemeUnlockService.statesFor(
    profile: profile,
    unlockedSpecies: unlockedSpecies,
  );
});
```

- [ ] **Step 4: Run provider test for GREEN**

Run:

```powershell
flutter test test/providers/room_theme_unlock_provider_test.dart
```

### Task 3: Lock Premium Vibes In Theme Picker

**Files:**
- Modify: `apps/aquarium_app/lib/screens/home/theme_picker_sheet.dart`
- Test: `apps/aquarium_app/test/widget_tests/theme_picker_sheet_test.dart`

- [ ] **Step 1: Write failing widget tests**

Add tests that pump `ThemePickerSheet` with the current theme set to `aurora` and no progress:

```dart
expect(find.text('Locked'), findsOneWidget);
expect(find.textContaining('Reach 2500 XP'), findsOneWidget);
```

Add a second test with enough XP:

```dart
expect(find.text('Apply'), findsOneWidget);
expect(find.text('Locked'), findsNothing);
```

- [ ] **Step 2: Run widget test for RED**

Run:

```powershell
flutter test test/widget_tests/theme_picker_sheet_test.dart
```

- [ ] **Step 3: Implement picker UI**

In `ThemePickerSheet`:

- Watch `roomThemeUnlockStatesProvider`.
- Pass each card its `RoomThemeUnlockState`.
- If the top card is locked, tapping it should show `DanioSnackBar.info(context, state.requirementLabel)` and must not call `roomThemeProvider.notifier.setTheme`.
- `_ThemeCard` should show a small icon-only lock badge over locked previews.
- `_ThemeInfoBar` should show the unlock requirement plus a disabled `Locked` button for locked themes, and normal description plus `Apply` for unlocked themes.

- [ ] **Step 4: Run widget test for GREEN**

Run:

```powershell
flutter test test/widget_tests/theme_picker_sheet_test.dart
```

### Task 4: Docs, Verification, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [ ] **Step 1: Record CL-P1-002A progress**

Document that room theme/vibe unlocks now use local progress state and stay visible as aspirational locked cosmetics.

- [ ] **Step 2: Format and verify**

Run:

```powershell
dart format lib/services/room_theme_unlock_service.dart lib/providers/room_theme_unlock_provider.dart lib/screens/home/theme_picker_sheet.dart test/services/room_theme_unlock_service_test.dart test/providers/room_theme_unlock_provider_test.dart test/widget_tests/theme_picker_sheet_test.dart
flutter analyze
flutter test
flutter build apk --debug --target lib/main.dart
git diff --check
```

- [ ] **Step 3: Commit**

Run:

```powershell
git add apps/aquarium_app/lib/services/room_theme_unlock_service.dart apps/aquarium_app/lib/providers/room_theme_unlock_provider.dart apps/aquarium_app/lib/screens/home/theme_picker_sheet.dart apps/aquarium_app/test/services/room_theme_unlock_service_test.dart apps/aquarium_app/test/providers/room_theme_unlock_provider_test.dart apps/aquarium_app/test/widget_tests/theme_picker_sheet_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-room-vibe-unlocks.md
git commit -m "feat: unlock room vibes through progress"
```
