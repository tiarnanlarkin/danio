# Wave 2 — Argus Verification: Trust + Durability
**Date:** 2026-03-29  
**Reviewer:** Argus (Quality Director)  
**Scope:** 5 silent trust + durability fixes (FB-T1 through FB-T5)

---

## FB-T1: Inventory Silent Fallbacks
**File:** `lib/providers/inventory_provider.dart`

### Verdict: ✅ PASS

**Evidence — `purchaseItem` guard (lines ~91–99):**
```dart
if (!state.hasValue) {
  logError(
    'InventoryProvider: purchaseItem called while state is not loaded (${state.runtimeType}) — aborting to prevent data loss',
    tag: 'InventoryProvider',
  );
  return false;
}
```
Early-return guard present. Correctly checks `!state.hasValue`, logs the error with context, returns `false` instead of proceeding.

**Evidence — `useItem` guard (lines ~162–168):**
```dart
if (!state.hasValue) {
  logError(
    'InventoryProvider: useItem called while state is not loaded — aborting',
    tag: 'InventoryProvider',
  );
  return false;
}
```
Guard present and correct. Aborts before touching `currentInventory`.

**Storage error / empty-list write:** The `_save()` method is only reached after `state.hasValue` is confirmed true and a valid `updated` list is constructed. There is no code path where an empty list is silently written on storage error. On `purchaseItem` failure the catch block fires a compensating refund and rethrows — it does not persist an empty list.

---

## FB-T2: Silent Catch Blocks
**File:** `lib/providers/spaced_repetition_provider.dart`

### Verdict: ✅ PASS

**Evidence — streak parse catch (~line 133):**
```dart
} catch (e) {
  // Ignore parse errors — keep value loaded from statsKey
  logError('SpacedRepetitionProvider: failed to parse streak JSON: $e', tag: 'SpacedRepetitionProvider');
}
```
The previously-silent `catch(_) {}` now logs via `logError` with tag and error value. Every other catch in the file was also audited — all log their errors. No bare silent swallows found.

---

## FB-T3: Schema Migration
**File:** `lib/services/local_json_storage_service.dart`

### Verdict: ✅ PASS

**Evidence — method exists and is called:**
```dart
// FB-T3: Run forward-only schema migrations before loading entities.
json = _migrateJson(json);
```
Called inside `_loadFromDisk()` immediately after successful JSON parse.

**`_migrateJson()` implementation checks:**
- ✅ **Reads schema version:** `final int storedVersion = (json['version'] as int?) ?? 0;`
- ✅ **Fast-path if already current:** `if (storedVersion >= _schemaVersion) { return json; }`
- ✅ **Logs migration:** `appLog('📦 Storage migration: v$storedVersion → v$_schemaVersion', tag: '...');`
- ✅ **Forward-only, safe defaults:** v0→v1 stamps version key; v1→v2 stamps version, notes new fields applied on read
- ✅ **Updates stored version:** `migrated['version'] = 2;` (and `= 1;` for sub-step)
- ✅ **Works on mutable copy:** `final migrated = Map<String, dynamic>.from(json);`

Schema version constant: `static const int _schemaVersion = 2;`

All four required characteristics present.

---

## FB-T4: Gems Lifecycle Flush
**Files:** `lib/providers/gems_provider.dart`, `lib/main.dart`

### Verdict: ✅ PASS

**Evidence — `flushPendingWrite()` method in `GemsNotifier`:**
```dart
Future<void> flushPendingWrite() async {
  final pending = _pendingGemsState;
  if (pending == null) return; // Nothing queued — already clean.
  _saveDebounce?.cancel();
  _saveDebounce = null;
  _pendingGemsState = null;
  await _writeToDisk(pending);
  appLog('GemsProvider: lifecycle flush — balance=${pending.balance}', tag: 'GemsProvider');
}
```
Method exists, cancels the debounce timer, clears pending state, writes immediately, and logs the flush.

**Evidence — called from `didChangeAppLifecycleState` in `main.dart` (~line 330–337):**
```dart
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused ||
      state == AppLifecycleState.inactive) {
    // FB-T4: Flush any pending debounced gem writes synchronously so the
    // OS cannot kill the process before the 500 ms timer fires.
    unawaited(ref.read(gemsProvider.notifier).flushPendingWrite());
  }
  ...
}
```
Both `paused` and `inactive` lifecycle states covered. The `WidgetsBindingObserver` mixin is confirmed on the containing widget (line 247). `unawaited` usage is intentional and correctly explained in comment.

---

## FB-T5: SR Error State UI
**File:** `lib/screens/spaced_repetition_practice/spaced_repetition_practice_screen.dart`

### Verdict: ✅ PASS

**Evidence — error state branch (~lines 44–69):**
```dart
// Show error banner if provider reported an error
if (srState.errorMessage != null) {
  return Scaffold(
    appBar: AppBar(title: const Text('Practice')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              srState.errorMessage!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(spacedRepetitionProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    ),
  );
}
```

- ✅ Error icon rendered (`Icons.error_outline`, 48px, red)
- ✅ Error message text rendered from `srState.errorMessage`
- ✅ Retry button present (`ElevatedButton.icon` with `Icons.refresh` and label `'Try again'`)
- ✅ Retry action calls `ref.invalidate(spacedRepetitionProvider)` — forces provider reload
- ✅ Not a blank screen — full Scaffold with AppBar returned

---

## Summary

| ID | Title | Verdict | Notes |
|----|-------|---------|-------|
| FB-T1 | Inventory silent fallbacks | ✅ PASS | Both `purchaseItem` and `useItem` guarded; no empty-list silent write path |
| FB-T2 | Silent catch blocks | ✅ PASS | Streak parse catch now logs; all other catches also log |
| FB-T3 | Schema migration | ✅ PASS | `_migrateJson()` exists, versioned, logged, safe defaults, stamps version |
| FB-T4 | Gems lifecycle flush | ✅ PASS | `flushPendingWrite()` exists; called on paused+inactive in main.dart |
| FB-T5 | SR error state UI | ✅ PASS | Error icon + message + retry button rendered; not blank |

**Overall: 5/5 PASS. All trust + durability fixes verified present and correctly implemented.**

---

*Argus — "Did you test it? I mean REALLY test it?"*
