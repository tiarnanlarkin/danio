# Wave 2C — Durability Fixes

**Agent:** Hephaestus  
**Date:** 2026-03-29  
**Status:** ✅ Complete

---

## FB-T4: Gems Debounce Lifecycle Flush

### Problem
`GemsNotifier._save()` used a 500 ms debounce timer. The lifecycle handler in `main.dart` (`didChangeAppLifecycleState`) only handled `resumed` — never `paused`/`inactive`. If the OS killed the app during the 500 ms window after a gem transaction, the balance update was lost.

### Fix
**`lib/providers/gems_provider.dart`**

1. Added `_pendingGemsState` field — tracks the most-recently-queued state awaiting the debounce timer.
2. Extracted `_writeToDisk(GemsState)` — the actual SharedPreferences write, now shared by both the debounce timer and the flush path.
3. `_save()` now stores `_pendingGemsState` before arming the timer. `_writeToDisk` clears it on success.
4. Added `flushPendingWrite()` — cancels the timer and calls `_writeToDisk` immediately. No-op if nothing is pending.

**`lib/main.dart`**

- Added import for `gems_provider.dart`.
- Extended `didChangeAppLifecycleState` to call `unawaited(ref.read(gemsProvider.notifier).flushPendingWrite())` on both `AppLifecycleState.paused` and `AppLifecycleState.inactive`.

### Result
Any pending gem balance write is now flushed synchronously to SharedPreferences before the OS may terminate the process. Zero gem loss window.

---

## FB-T3: SchemaMigration — LocalJsonStorageService

### Problem
`SchemaMigration` (SharedPreferences) was already implemented. However, `LocalJsonStorageService` (the JSON file store for tanks/livestock/equipment/logs/tasks) wrote a `version` key but never read it back or applied any migration logic on load.

### Fix
**`lib/services/local_json_storage_service.dart`**

1. Bumped `_schemaVersion` constant: `1 → 2`.
2. Added `_migrateJson(Map<String, dynamic> json) → Map<String, dynamic>` method:
   - Reads `json['version']` (defaults to 0 if absent).
   - Fast-paths if `storedVersion >= _schemaVersion`.
   - Logs migration event: `📦 Storage migration: vX → vY`.
   - **v0 → v1:** Version stamp only (data was written in v1 format before the key was introduced).
   - **v1 → v2:** Stamps version; `sortOrder` and `isDemoTank` Tank fields already have safe defaults in `_tankFromJson` (`?? 0` / `?? false`) — no structural transform needed.
   - Commented template for future migration blocks.
   - Returns migrated map (never mutates original).
3. Called `_migrateJson(json)` in `_loadFromDisk` immediately after JSON parse success, before `_parseAndLoadEntities`. The corrected version is used for entity loading.
4. On next `_persistUnlocked()` call (triggered by any write), `'version': _schemaVersion` is written to disk, stamping the migration permanently.

### Design Decisions
- **No migration DSL, no rollback, no framework** — as scoped.
- Migration is purely additive (safe defaults only).
- Existing data is never deleted.
- Future migrations follow the pattern of the v1→v2 block with a commented template.

---

## Flutter Analyze (post-fix)

```
4 issues found.
```

All 4 issues are pre-existing `info`/`warning` items in `test/widget_tests/tab_navigator_test.dart` — unrelated to this wave. Zero issues introduced by these fixes.

---

## Files Changed

| File | Change |
|------|--------|
| `lib/providers/gems_provider.dart` | Debounce refactor + `flushPendingWrite()` |
| `lib/main.dart` | Lifecycle flush on `paused`/`inactive` |
| `lib/services/local_json_storage_service.dart` | `_migrateJson()` + version bump |
