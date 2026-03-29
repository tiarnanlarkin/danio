# TRUTH PASS — Silent Failures & Error Swallowing Audit
**Auditor:** Argus (Quality Director)  
**Date:** 2026-03-29  
**Repo:** `apps/aquarium_app/lib/`  
**Status:** ✅ COMPLETE

---

> *"The most dangerous bugs aren't the ones that crash. They're the ones that silently lie to you."*

This audit covers: silent fallbacks (`valueOrNull ??`), swallowed catch blocks, data loss scenarios, and the top trust-destroying items in the codebase.

---

## SECTION 1 — SILENT FALLBACKS (`valueOrNull ??`)

### Raw counts
| Pattern | Count |
|---|---|
| `valueOrNull ?? []` | **13** |
| `valueOrNull ?? <other>` (total) | **14** |

### All 14 occurrences

| # | File | Line | Pattern | Category |
|---|---|---|---|---|
| 1 | `lib/providers/inventory_provider.dart` | 96 | `state.valueOrNull ?? []` | CRITICAL |
| 2 | `lib/providers/inventory_provider.dart` | 183 | `state.valueOrNull ?? []` | CRITICAL |
| 3 | `lib/providers/inventory_provider.dart` | 281 | `state.valueOrNull ?? []` | CRITICAL |
| 4 | `lib/providers/inventory_provider.dart` | 297 | `state.valueOrNull ?? []` | CRITICAL |
| 5 | `lib/providers/inventory_provider.dart` | 327 | `state.valueOrNull ?? []` | CRITICAL |
| 6 | `lib/providers/inventory_provider.dart` | 333 | `state.valueOrNull ?? []` | CRITICAL |
| 7 | `lib/providers/inventory_provider.dart` | 344 | `state.valueOrNull ?? []` | CRITICAL |
| 8 | `lib/providers/inventory_provider.dart` | 354 | `state.valueOrNull ?? []` | CRITICAL |
| 9 | `lib/providers/inventory_provider.dart` | 362 | `state.valueOrNull ?? []` | CRITICAL |
| 10 | `lib/screens/home/home_screen.dart` | 250 | `tanksProvider.valueOrNull ?? []` | CRITICAL |
| 11 | `lib/screens/home/home_screen.dart` | 328 | `tanksAsync.valueOrNull ?? []` | CRITICAL |
| 12 | `lib/screens/home/home_screen.dart` | 353 | `logsProvider(...).valueOrNull ?? []` | CRITICAL |
| 13 | `lib/services/shop_service.dart` | 11 | `inventoryProvider.valueOrNull ?? []` | CRITICAL |
| 14 | `lib/widgets/xp_progress_bar.dart` | 97 | `next.valueOrNull ?? 0.0` | DECORATIVE |

**DECORATIVE (1):** `xp_progress_bar.dart:97` — XP bar shows 0% progress if provider errors. Mildly misleading but no data loss.

**CRITICAL PATH (13):** Everything else. Breakdown below.

---

### Critical path analysis

#### 1. `inventory_provider.dart` — 9 occurrences (lines 96, 183, 281, 297, 327, 333, 344, 354, 362)

Every single write-path in `InventoryNotifier` reads the current inventory via `state.valueOrNull ?? []`. This means:

**Scenario: provider is in error state (e.g. SharedPreferences corrupted)** 
→ `state.valueOrNull` returns `null`  
→ `?? []` substitutes an **empty list**  
→ Every subsequent operation (`purchaseItem`, `useItem`, `activateItem`, `cleanupExpiredItems`, etc.) treats the user as having **zero inventory**  
→ `purchaseItem` calls `hasItem()` → `false` → user can **re-purchase already-owned items**, paying gems twice  
→ `useItem()` finds no existing item → returns `false` silently  
→ The compensating-refund logic at line 281 attempts to refund on a save failure, but if the state was already broken, the refund itself may fail

**What the user sees:** Items disappear from inventory. Gems are lost with no product received. Re-purchasing the same item again works (and charges again). On reload, inventory may or may not restore depending on whether the underlying SharedPreferences key is readable.

**Severity: P0** — Real money/gem loss path.

---

#### 2. `home_screen.dart:250` — `tanksBefore = ref.read(tanksProvider).valueOrNull ?? []`

This is inside a callback that fires when creating a new tank (to detect what tanks existed *before* the creation). Used to determine if this is the user's first tank (for achievement/XP purposes).

**Scenario: `tanksProvider` is still loading or in error state**  
→ `valueOrNull` returns `null` → `tanksBefore = []`  
→ Every tank creation is treated as "first tank ever"  
→ First-tank achievements and XP bonuses fire repeatedly  
→ User gets phantom XP/gems every time they create any tank

**Severity: P1** — Achievement integrity compromised.

---

#### 3. `home_screen.dart:328` — `tanksAsync.valueOrNull ?? []`

Used to render the tank list on the home screen.

**Scenario: `tanksProvider` is loading or errored**  
→ Shows empty state ("No tanks yet") to a user who has tanks  
→ User panics. Thinks their data is gone.  
→ May tap "Create Tank", creating a duplicate  
→ The duplicate may overwrite the real tank if cloud sync merges on `name` not `id`

**Severity: P1** — False empty state; potential phantom duplicate creation.

---

#### 4. `home_screen.dart:353` — `logsProvider(currentTank.id).valueOrNull ?? []`

Used to render the recent activity/log preview on the home screen card.

**Scenario: logs provider errors on load**  
→ Shows "No logs yet" on the tank card  
→ The tank card activity history appears blank  
→ User may log the same thing twice (water test, etc.) to "fix" it  
→ Duplicate logs corrupt streak calculations

**Severity: P1** — False state, potential duplicate data.

---

#### 5. `shop_service.dart:11` — `inventoryProvider.valueOrNull ?? []`

`ShopService` uses this as the `getInventory` getter. This is the canonical truth about what the user owns for the entire shop system.

**Scenario: inventory provider not yet loaded**  
→ `getInventory()` returns `[]`  
→ Shop thinks user owns nothing  
→ `hasItem(id)` returns `false` for everything  
→ All "already owned" guards fail  
→ User can repurchase permanent items (cosmetics, badges)  
→ Gems deducted, duplicate inventory entries created

**Severity: P0** — Direct gem loss path.

---

## SECTION 2 — SILENT CATCH BLOCKS

### Raw counts
| Pattern | Count |
|---|---|
| `catch (e)` | **113** |
| `catch (_)` | **4** |
| **Total** | **117** |

### Classification methodology
For each catch block I checked: **Does it (a) log? (b) show UI? (c) rethrow? (d) set error state?**  
A block that only logs but takes **no user-visible action** and **doesn't rethrow** is classified as a **silent swallow** — the error disappears into the logs and the user gets broken behaviour with no explanation.

### Silently swallowing count: **~24 confirmed swallows** out of 117

(Blocks that log but neither surface to UI nor rethrow on a critical path.)

---

### Worst 10 swallowed catch blocks

---

#### #1 — `lib/providers/inventory_provider.dart:67` (SAVE DEBOUNCE)
```dart
// Inside _save() debounce timer
} catch (e) {
  logError('InventoryProvider: migration best-effort failed: $e', ...);
}
```
**Classification:** LOGS ONLY — no rethrow, no UI  
**Impact:** If the debounced inventory save fails (storage full, permissions revoked, etc.), this catch block swallows it. The in-memory state says the user has inventory. Disk does not. On next cold start, inventory is **gone**. The user spent gems on items that vanished.

**Severity: P0**

---

#### #2 — `lib/screens/home/home_screen.dart` — Multiple `valueOrNull ??` paths  
The home screen itself does not throw — it silently renders empty state. No error is surfaced to the user. Combined with the `valueOrNull ?? []` fallbacks described in Section 1, the home screen silently lies about the user's data state.

**Classification:** NO ERROR SURFACED AT ALL  
**Severity: P0** (silent lie to user)

---

#### #3 — `lib/services/cloud_sync_service.dart:348` — `_mergeIntoLocalStorage`
```dart
} catch (e) {
  logError('[CloudSync] Failed to merge $table/$recordId: $e', ...);
}
```
**Classification:** LOGS ONLY — no rethrow, no UI  
**Impact:** If a cloud sync record fails to merge into local storage (e.g. schema mismatch, parse error), this catch silently discards the remote data. The user's cloud data never arrives locally. They think sync worked (status shows "Synced") but data is silently missing.  
This is inside `_mergeIntoLocalStorage`, which handles tanks, livestock, equipment, tasks, and logs.

**Severity: P1**

---

#### #4 — `lib/services/cloud_sync_service.dart:535` — `_pullTable`
```dart
} catch (e) {
  logError('[CloudSync] Failed to pull $table: $e', ...);
}
```
**Classification:** LOGS ONLY — no rethrow, no UI  
**Impact:** An entire table (e.g. all tanks, all logs) can silently fail to sync. `syncNow()` will then report `CloudSyncStatus.synced` because the outer try/catch at line ~460 only fails if `_flushOfflineQueue` or the loop itself throws — individual table failures are swallowed here. **The user sees a green tick. Their data wasn't synced.**

**Severity: P1**

---

#### #5 — `lib/screens/add_log/add_log_screen.dart:958` — Water change notification scheduling
```dart
} catch (e) {
  logError('Failed to schedule water change reminder: $e', ...);
}
```
**Classification:** LOGS ONLY — no rethrow, no UI  
This one is genuinely low severity on its own (notification failure). But it's emblematic of a pattern: any failure after `storage.saveLog(log)` is caught and swallowed. The log is saved, but the post-save side-effects (XP, achievements, notifications) may not all complete. The user gets partial credit.

**Severity: P2**

---

#### #6 — `lib/screens/add_log/add_log_screen.dart:1011` — Achievement check post-log
```dart
} catch (e) {
  logError('Achievement check failed: $e', ...);
}
```
**Classification:** LOGS ONLY — no rethrow, no UI  
**Impact:** If achievement checking fails after a log is saved, the catch block swallows it. The user may miss achievement unlocks silently. They logged water test data, earned the XP, but the achievement never fires and is never retried.

**Severity: P1** — Achievement progress silently lost.

---

#### #7 — `lib/services/local_json_storage_service.dart:276,288,300,312,324` — Entity parse errors
```dart
} catch (e) {
  errors.add('Tank ${entry.key}: $e');
  logError('⚠️  Skipping corrupted tank: ...', ...);
}
```
**Classification:** LOGS AND SKIPS — no UI  
**Impact:** This is intentional partial recovery, but the user is **never told** that data was silently dropped. Up to 10 entities can be lost before the threshold triggers a `FormatException`. The user's tanks, logs, livestock can vanish silently. The threshold of 10 is arbitrary — losing 9 tanks is not "acceptable", it's catastrophic.

**Severity: P0** — Data silently gone, no user notification.

---

#### #8 — `lib/providers/user_profile_notifier.dart:664` — Review card creation post-lesson
```dart
} catch (e) {
  logError('Warning: Failed to create review cards for lesson $lessonId: $e', ...);
}
```
**Classification:** LOGS ONLY — no rethrow, no UI  
**Impact:** SRS (Spaced Repetition System) cards silently fail to be created after lesson completion. The lesson is marked as completed, XP is awarded, but no review cards are created. The user's SRS deck is corrupted — they think they'll be quizzed, they won't be. Review streaks break.

**Severity: P1**

---

#### #9 — `lib/services/cloud_sync_service.dart:566` — Offline queue flush failure
```dart
} catch (e) {
  logError('[CloudSync] Failed to flush entry: $e', ...);
  failed.add(entryJson);
}
```
**Classification:** LOGS AND RE-QUEUES  
This is better — failed entries are re-queued. But there is no maximum retry count. If an entry is permanently corrupt (e.g. malformed JSON in the queue from a previous serialization bug), it will re-queue forever, growing the queue until `_maxOfflineQueueSize` drops it. Dropped offline changes are **silently lost** when the queue exceeds 100 entries.

**Severity: P1**

---

#### #10 — `lib/providers/spaced_repetition_provider.dart:133` — `catch (_)` parse swallow
```dart
} catch (_) {
  // Ignore parse errors — keep value loaded from statsKey
}
```
**Classification:** COMPLETELY SILENT — no log, no UI, no rethrow  
**Impact:** SRS streak date parse failures are silently discarded. If the stored date string is malformed, the streak calculation proceeds with a wrong value. Review streak counts may be wrong. This cannot be diagnosed from logs because there is no log entry.

**Severity: P1** — Undiagnosable data corruption.

---

## SECTION 3 — DATA LOSS SCENARIOS

### Scenario A: App killed mid-write to SharedPreferences

**Code path:**  
`_saveImmediate()` in `user_profile_notifier.dart:113–118`:
```dart
final prefs = await ref.read(sharedPreferencesProvider.future);
await prefs.setString(_key, jsonEncode(profile.toJson()));
```

SharedPreferences on Android calls `apply()` (async) under the hood by default via the Flutter plugin. The write is dispatched to a background thread. If the OS kills the app process *after* `setString` returns to Dart but *before* the Android `apply()` completes its disk write, **the data is lost**.

For `_save()` (debounced path), this is worse: the `Debouncer` has a 200ms delay. Any activity in the last 200ms before an OS kill will not be persisted. The lifecycle observer (`_ProfileLifecycleListener`) fires on `AppLifecycleState.paused` to flush — but `paused` is not guaranteed to fire before a force-kill or OOM kill.

**What happens:**  
- XP from the last lesson may be lost  
- Streak increments may revert  
- Lesson completions recorded in in-memory state are not on disk  
- On next cold start, the user sees yesterday's profile  
- Achievements unlocked in that session are gone

**Mitigation present:** `_saveImmediate` bypasses debounce for critical writes. Lifecycle flush fires on `paused`. But there is no verification that writes completed, and no retry if they didn't.

**Rating: P1** — Most users won't hit this, but competitive XP/streak users will notice reversion.

---

### Scenario B: Storage full (device out of space)

**Code path:**  
`LocalJsonStorageService._persistUnlocked()`:
```dart
final tmp = File('${file.path}.tmp');
await tmp.writeAsString(jsonEncode(payload));  // ← throws FileSystemException
await tmp.rename(file.path);
```

If the device is out of space, `tmp.writeAsString()` throws a `FileSystemException`. This exception propagates up through the `_persistLock.synchronized()` block and is NOT caught inside `saveTank/saveLog/etc`. The callers (`storage.saveLog(log)` in `add_log_screen.dart`) catch with:
```dart
} catch (e, st) {
  AppFeedback.showError(context, 'Hmm, couldn\'t save that...');
}
```

**What happens:**  
- The user sees the generic error toast "Hmm, couldn't save that"  
- The in-memory state (`_logs`, `_tanks`, etc.) has already been updated  
- The `.tmp` file write failed, so the main data file is unchanged  
- The in-memory state is now **ahead of disk**  
- If the user continues using the app (perhaps deleting something else to free space), subsequent saves will overwrite the main file with the full in-memory state — which may include unconfirmed partial data

No specific "out of storage" error message is shown. The error message is generic. The user cannot tell whether their data is safe.

**Rating: P1**

---

### Scenario C: Corrupt JSON in storage (main data file)

**Code path:**  
`LocalJsonStorageService._loadFromDisk()`:

1. Attempts `jsonDecode(raw)` — if this throws, it's a `FormatException`
2. The corrupted file is **backed up** to `aquarium_data.json.corrupted.<timestamp>`
3. `StorageState` is set to `StorageState.corrupted`
4. `_ensureLoaded()` throws `StorageCorruptionException`
5. All subsequent calls to `saveTank/getLogs/etc` throw
6. The UI must handle `StorageCorruptionException` in `storageServiceProvider`

**What actually happens in the UI:**  
`tanksProvider` is a `FutureProvider` that calls `storage.getAllTanks()`. If `getAllTanks()` throws, the provider enters an error state. The home screen uses:
```dart
final tanksData = tanksAsync.valueOrNull ?? [];  // line 328
```
This silently swallows the error and shows empty state. **The user is not told their data is corrupted.** They think they have no tanks.

The `storageErrorProvider` exists but must be explicitly watched. It is unclear from the audit how many screens actually watch it.

**Rating: P0** — Corruption → silent empty state → user may think data is lost and start recreating tanks, permanently abandoning the corrupted (but potentially recoverable) backup.

---

### Scenario D: Schema mismatch after app update

**Code path:**  
`SchemaMigration.runIfNeeded()` in `schema_migration.dart`:

```dart
static const int _targetVersion = 1;
// Only migration: v0 → v1 is a no-op stamp
if (currentVersion < 1) {
  await prefs.setInt(_key, 1);
}
```

**Critical finding: The schema migration system exists but is a stub.** Version 1 is the only version, and it does nothing. All migration logic is commented-out placeholder.

Meanwhile, `LocalJsonStorageService` has `_schemaVersion = 1` hardcoded in the JSON file header, but there is **no version check on load**. The `_parseAndLoadEntities` method receives the JSON map and begins parsing without checking the `version` field.

**What happens on schema mismatch after app update:**  
If the app adds a new required field to `Tank`, `Livestock`, `LogEntry`, etc. and ships an update:
- Old data files have no `version` bump
- `_loadFromDisk` will attempt to parse old JSON into new model classes
- If the new field is required and has no default, `DateTime.parse(m['newField']!)` will throw `Null check operator used on a null value`
- This is caught per-entity in `_parseAndLoadEntities` — the entity is **silently skipped** with a log warning
- Up to 10 entities lost before the threshold fires a `FormatException`
- The `.bak` backup is only created once (`_firstSaveDone` flag)

**There is no forward migration for the JSON file schema.** `SchemaMigration` only handles SharedPreferences keys. The JSON file has no migration path at all.

**Rating: P0** — Any new required field in any model causes silent data loss on update.

---

## SECTION 4 — TOP 10 "IF THIS STAYS, THE APP CANNOT BE TRUSTED"

Ranked by severity and likelihood of user impact.

---

### #1 — `home_screen.dart:328` — Tanks display as empty when provider errors  
**File:** `lib/screens/home/home_screen.dart:328`  
```dart
final tanksData = tanksAsync.valueOrNull ?? [];
```
A user with 5 tanks who experiences a provider error (storage corruption, plugin failure, race condition at startup) sees **zero tanks**. No error. No explanation. Just empty state. They may start creating new tanks, duplicating their data, or panic-factory-reset their device.

**Fix:** Replace with proper `.when()` error handling that distinguishes loading/error/empty states.  
**Severity: P0**

---

### #2 — `local_json_storage_service.dart` — No schema migration for JSON file  
**File:** `lib/services/local_json_storage_service.dart` (entire file)  
`SchemaMigration` only handles SharedPreferences. The JSON data file (`aquarium_data.json`) has no migration path. The first time a model class adds a required field in production, every existing user's data silently loses entities on update. This will happen. It is not a "maybe".

**Fix:** Add a `version` check on load and implement proper schema migration for the JSON file.  
**Severity: P0**

---

### #3 — `inventory_provider.dart` — `valueOrNull ?? []` on every write path  
**Files:** `lib/providers/inventory_provider.dart:96,183,281,297,327,333,344,354,362`  
If `inventoryProvider` is in error state, all write operations treat inventory as empty. Users can re-purchase permanent items, depleting gems. The compensating-refund logic is sound but only activates on save failure — not on state error.

**Fix:** Guard every write with an explicit error state check and surface a user-facing error rather than proceeding on a known-broken state.  
**Severity: P0**

---

### #4 — Silent entity skip threshold of 10 in `_parseAndLoadEntities`  
**File:** `lib/services/local_json_storage_service.dart:~260`  
Up to 10 corrupted entities are silently skipped. The user is never notified. 9 tanks gone = silent. 10 tanks gone = silent. 11 tanks gone = error thrown. This threshold is arbitrary and dangerous.

**Fix:** Notify the user immediately when any entity is skipped (even 1). Show a recovery dialog. Do not silently discard data.  
**Severity: P0**

---

### #5 — Cloud sync reports "Synced" when individual tables silently fail  
**File:** `lib/services/cloud_sync_service.dart:535` (`_pullTable`)  
```dart
} catch (e) {
  logError('[CloudSync] Failed to pull $table: $e', ...);
}
// ↑ Outer syncNow() catches will not see this. Status → CloudSyncStatus.synced
```
Every table failure is swallowed. `syncNow()` may complete without error while no data was actually synced. The sync status indicator lies.

**Fix:** Track per-table sync failures. If any table fails, report `CloudSyncStatus.partialError` or similar, not `synced`.  
**Severity: P1**

---

### #6 — `spaced_repetition_provider.dart:133` — `catch (_)` with zero logging  
**File:** `lib/providers/spaced_repetition_provider.dart:133`  
```dart
} catch (_) {
  // Ignore parse errors — keep value loaded from statsKey
}
```
No log. No rethrow. No error state. Parse failures in SRS streak data produce wrong streak counts with **zero diagnostic trail**. This is the worst kind of silent failure: undetectable, undiagnosable, and directly affects user-facing metrics.

**Fix:** At minimum, `logError(...)`. Ideally, reset to a safe default and note the reset in state.  
**Severity: P1**

---

### #7 — Debounced profile save has a 200ms loss window  
**File:** `lib/providers/user_profile_notifier.dart:57,98–110`  
Non-critical profile updates (`updateProfile`, `skipPlacementTest`) use the 200ms debounced `_save()`. The lifecycle observer fires on `paused`, not on force-kill. Users who have their app force-killed (low-memory, battery optimisation, crash) in the 200ms window after a profile update **lose that update**.

The `_onLifecyclePause` fire-and-forget pattern also has a race: `ref.read(sharedPreferencesProvider.future).then(...)` is not awaited. The OS may kill the process before the `then` executes.

**Fix:** For any write path that may affect displayed user data, use `_saveImmediate` or ensure the debouncer's pending save is completed synchronously on pause.  
**Severity: P1**

---

### #8 — Achievement progress silently lost if check fails post-log  
**File:** `lib/screens/add_log/add_log_screen.dart:1011`  
```dart
} catch (e) {
  logError('Achievement check failed: $e', ...);
}
```
After saving a log, achievement checking is done in a fire-and-forget try/catch. If `checkAllAchievements` throws (e.g. user profile null, provider error), the achievement is silently not awarded. There is no retry. The user's log activity is recorded but the achievement milestone is permanently missed.

**Fix:** If achievement check fails, queue it for retry on next app launch, or at minimum surface a non-blocking "Achievement check delayed" toast.  
**Severity: P1**

---

### #9 — No user notification when storage corruption is detected  
**File:** `lib/services/local_json_storage_service.dart` + `lib/screens/home/home_screen.dart:328`  

When `LocalJsonStorageService` detects corruption, it sets `StorageState.corrupted` and `_lastError`. But the home screen uses `tanksAsync.valueOrNull ?? []` (line 328), which silently shows empty state instead of surfacing the corruption error. Unless the user navigates to a screen that explicitly reads `storageErrorProvider`, they never know their data file is corrupted and a backup exists.

**Fix:** Add a top-level error listener for `storageErrorProvider` (or `tanksProvider` error state) that immediately displays a recovery dialog when storage is corrupted.  
**Severity: P0**

---

### #10 — Schema migration is a no-op stub  
**File:** `lib/utils/schema_migration.dart`  

The entire schema migration framework (which runs at startup) does exactly one thing: stamps version 1 if it hasn't been stamped. All future migrations are commented-out placeholder code. The moment anyone adds a new non-nullable field to `UserProfile`, `Tank`, `LogEntry`, etc. and ships it to production, all existing users' data is at risk. This is a time bomb.

**Fix:** Implement real migration logic before any model field changes reach production. Add a CI check that fails if `_targetVersion` hasn't been bumped when model files change.  
**Severity: P0** (time bomb — not exploited yet)

---

## SUMMARY SCORECARD

| Severity | Count |
|---|---|
| **P0 — BLOCKERS** | 6 |
| **P1 — CRITICAL** | 6 |
| **P2 — IMPORTANT** | 2+ |

| Category | Finding |
|---|---|
| Silent `valueOrNull ??` fallbacks | 14 total, **13 on critical paths** |
| Total catch blocks | **117** |
| Silent swallows (no UI, no rethrow) | **~24** |
| Data loss scenarios confirmed | **4** |
| Schema migration coverage | **Stub only — 0 real migrations** |
| Storage corruption user notification | **None in default flow** |

---

## VERDICT

**REJECTED FOR RELEASE.**

The silent failures in this codebase are not edge cases — they are the default behaviour when things go wrong. Users will lose data, lose gems, miss achievements, and see phantom empty states with zero explanation. The schema migration system is a stub that will cause a production incident the first time any model class adds a required field.

The storage layer itself (`LocalJsonStorageService`) is competently written with proper atomic writes, locking, and backup creation. The problem is the layers above it: they don't surface its errors to users. Fix the error propagation chain first.

*— Argus*

---

*Generated: 2026-03-29 | Pass: TRUTH PASS Silent Failures*
