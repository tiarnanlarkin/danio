# Wave 2B — Silent Fallbacks + Catch Blocks
**Agent:** Hephaestus  
**Date:** 2026-03-29  
**Commit:** d1401ae

---

## Pre-existing Status (before this wave)

Most of the issues listed in the brief had already been fixed by previous wave agents:

- `spaced_repetition_provider.dart` already had comprehensive `logError()` in all catch blocks except one (line 133)
- `inventory_provider.dart` already used `AsyncValue.error` on load failure, not silent empty state
- `home_screen.dart` already showed `AppErrorState` for tank load errors (not "No tanks")
- All provider catches in `achievement_provider`, `gems_provider`, `room_theme_provider`, `reduced_motion_provider`, `smart_providers` already logged via `logError`

---

## Fixes Applied

### FB-T1: inventory_provider.dart — purchaseItem/useItem guards
**File:** `lib/providers/inventory_provider.dart`

Added early-return guard in `purchaseItem` and `useItem` when `state.hasValue` is false.

**Why it matters:** If inventory is in loading or error state, `state.valueOrNull ?? []` returns empty list. Any purchase write would then persist an empty inventory, wiping existing items. The guard returns `false` (no-op) and logs an error instead.

```dart
// Before: silent data loss risk
final currentInventory = state.valueOrNull ?? [];

// After: explicit guard
if (!state.hasValue) {
  logError('purchaseItem called while state is not loaded — aborting to prevent data loss', ...);
  return false;
}
final currentInventory = state.valueOrNull ?? [];
```

### FB-T2: spaced_repetition_provider.dart — silent catch(_) at line 133
**File:** `lib/providers/spaced_repetition_provider.dart`

Changed `catch (_)` (zero logging) to `catch (e)` with `logError()`.

```dart
// Before
} catch (_) {
  // Ignore parse errors — keep value loaded from statsKey
}

// After
} catch (e) {
  // Ignore parse errors — keep value loaded from statsKey
  logError('SpacedRepetitionProvider: failed to parse streak JSON: $e', tag: 'SpacedRepetitionProvider');
}
```

### FB-T5: SR practice screen — error state swallowed
**File:** `lib/screens/spaced_repetition_practice/spaced_repetition_practice_screen.dart`

Added a full error UI block that renders when `srState.errorMessage != null`. Previously the `errorMessage` field existed in `SpacedRepetitionState` but was never read by the screen — user would see a blank or stale screen with no feedback.

```dart
// After: shows error + retry button
if (srState.errorMessage != null) {
  return Scaffold(
    appBar: AppBar(title: const Text('Practice')),
    body: Center(
      child: Column(
        children: [
          Icon(Icons.error_outline, ...),
          Text(srState.errorMessage!),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(spacedRepetitionProvider),
            label: const Text('Try again'),
          ),
        ],
      ),
    ),
  );
}
```

---

## Analyzer Results

```
flutter analyze --no-pub
Analyzing aquarium_app...

4 issues found (all in test/widget_tests/tab_navigator_test.dart)
  - 2 info: test dep warnings (pre-existing, not production code)  
  - 1 warning: override_on_non_overriding_member (pre-existing test file)
  - 1 info: use_super_parameters (pre-existing test file)

No errors or warnings in production lib/ code.
```

**Zero production code issues.** All 4 issues are in test files and pre-existed this wave.

---

## Scope Notes

- Did NOT touch the other ~100+ catch blocks (not in scope — they were already logging)  
- Did NOT refactor `activePowerUpsProvider`/`ownsItemProvider` error arms — returning `[]`/`false` on error is acceptable for read-only query providers
- The `_pendingMigrationJson` error seen in first analyzer run was a stale `.dart_tool` analysis cache, not a real bug — cleared and reran cleanly
