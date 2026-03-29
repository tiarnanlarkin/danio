# Data Resilience & Offline Behaviour Audit
**Branch:** `openclaw/stage-system`  
**Date:** 2026-03-29  
**Auditor:** Hephaestus (T-D-293)

---

## Executive Summary

Danio has a solid offline-first foundation. The core tank management data lives in a local JSON file with atomic writes and a mutex lock — that's more than most apps bother with at MVP stage. The gamification layer (XP, gems, achievements) uses `SharedPreferences` with its own backup coverage. Cloud sync via Supabase is additive and gracefully disabled when credentials are absent.

The main risks are: no version migration strategy for the local JSON schema, crash-during-form means unsaved data is lost, no deduplication in the restore-backup path for logs, and the SharedPreferences backup has a whitelist that could miss keys added in future.

---

## 1. Offline Capability Matrix

| Feature | Works Offline | Notes |
|---|---|---|
| View tanks, livestock, equipment | ✅ Yes | All data local |
| Add / edit tanks | ✅ Yes | Saved to local JSON immediately |
| Add / edit livestock | ✅ Yes | Local JSON |
| Log water tests & water changes | ✅ Yes | Local JSON |
| Tasks / maintenance checklist | ✅ Yes | Local JSON |
| Analytics / charts | ✅ Yes | Computed from local data |
| Learning lessons | ✅ Yes | All lesson content is bundled in-app |
| Spaced-repetition practice | ✅ Yes | Local |
| XP, gems, achievements | ✅ Yes | `SharedPreferences`; queued for eventual sync |
| Streak tracking | ✅ Yes | UTC-based local calc |
| Cost tracker | ✅ Yes | `SharedPreferences` |
| Wishlist | ✅ Yes | `SharedPreferences` |
| Backup/restore (ZIP) | ✅ Yes | File-based, no network needed |
| Stocking calculator / unit converters | ✅ Yes | Pure computation |
| Species/plant/compatibility browser | ✅ Yes | Static bundled data |
| AI Fish ID | ❌ No | Requires OpenAI API |
| AI Symptom Triage | ❌ No | Requires OpenAI API |
| AI Weekly Plan | ❌ No | Requires OpenAI API |
| AI Stocking Suggestions | ❌ No | Requires OpenAI API |
| AI Compatibility Checker | ❌ No | Requires OpenAI API |
| Cloud account sign-in / sign-out | ❌ No | Requires Supabase |
| Cloud backup (encrypted upload) | ❌ No | Requires Supabase Storage |
| Realtime cross-device sync | ❌ No | Requires Supabase Realtime |
| Friends / social | N/A | Debug-only stub; not yet shipped |

**Offline UX handling:**
- `OfflineIndicator` banner shown app-wide via `connectivityProvider` (stream from `connectivity_plus`).
- All AI features check `isOnlineProvider` before calling OpenAI and display a clear offline error message.
- `isOnlineProvider` defaults to `true` while loading and on error — i.e. it optimistically assumes online until confirmed otherwise. This means there is a brief window on startup where the app may attempt an AI call and fail.
- `SyncService` queues XP/gem/achievement/lesson actions locally and re-syncs when online. **CAVEAT: The comment in `sync_service.dart` says "Backend sync not yet implemented — queued actions execute locally only."** The queue exists but the flush-to-backend path is scaffolding.

---

## 2. Data Persistence Coverage

### What Is Saved & How

| Data | Storage | Mechanism | Backed Up (ZIP) | Backed Up (Cloud) |
|---|---|---|---|---|
| Tanks | `aquarium_data.json` | `LocalJsonStorageService` | ✅ Yes | ✅ Yes (user_tanks) |
| Livestock | `aquarium_data.json` | `LocalJsonStorageService` | ✅ Yes | ✅ Yes (user_fish) |
| Equipment | `aquarium_data.json` | `LocalJsonStorageService` | ✅ Yes | ✅ Yes (inventory_items) |
| Log entries | `aquarium_data.json` | `LocalJsonStorageService` | ✅ Yes | ✅ Yes (water_parameters) |
| Tasks | `aquarium_data.json` | `LocalJsonStorageService` | ✅ Yes | ✅ Yes (tasks) |
| Photos | App documents/photos/ | Local files | ✅ Bundled in ZIP | ❌ No |
| User profile (XP, streak, etc.) | `SharedPreferences` | JSON blobs | ✅ Yes (v3 backup) | Via `user_profiles` (sync queue only) |
| Gems state | `SharedPreferences` | JSON blob | ✅ Yes | Via sync queue (scaffolding) |
| Achievements | `SharedPreferences` | JSON blob | ✅ Yes | Via sync queue (scaffolding) |
| Shop inventory | `SharedPreferences` | JSON blob | ✅ Yes | N/A |
| Wishlist | `SharedPreferences` | JSON blob | ✅ Yes | N/A |
| Cost tracker expenses | `SharedPreferences` | JSON array | ✅ Yes | ❌ No |
| AI interaction history | `SharedPreferences` | String list | ✅ Yes | ❌ No |
| Weekly plan cache | `SharedPreferences` | JSON string | ✅ Yes | ❌ No |
| Settings (theme, units, etc.) | `SharedPreferences` | Primitives | ✅ Yes | ❌ No |
| GDPR analytics consent | `SharedPreferences` | Bool | ✅ Yes | ❌ No |
| Lesson progress / completed lessons | `SharedPreferences` | String lists | ✅ Yes | Via sync queue (scaffolding) |
| Spaced-repetition state | `SharedPreferences` | JSON | ✅ Yes | N/A |

### Storage Corruption Handling (`LocalJsonStorageService`)

This is genuinely well-built:
- Atomic write: data written to `.tmp` first, then renamed to live file.
- On first save of a session, the previous file is copied to `.bak`.
- JSON parse failure: corrupted file is copied to `.corrupted.<timestamp>` before any attempt to proceed.
- Entity-level recovery: individual malformed records are skipped (up to 10 errors tolerated; >10 throws).
- States tracked: `idle`, `loading`, `loaded`, `corrupted`, `ioError`.
- UI can inspect `storageService.isHealthy` / `storageService.lastError`.
- `recoverFromCorruption()`, `retryLoad()`, and `clearAllData()` exposed for UI-driven recovery.

**Gap:** The `.bak` backup is only kept from the *first save of the session*. If the app is opened, a tank is added (first save creates `.bak`), and a second operation corrupts the file, the `.bak` is already stale from earlier that session. There's no rolling backup across sessions.

### `SharedPreferences` Backup Coverage

`SharedPreferencesBackup` uses a whitelist of key prefixes to decide what's exportable. Current whitelist:
```
user_profile, gems_state, gems_cumulative, shop_inventory,
settings_, onboarding_, daily_goal_, ai_interaction_history,
anomaly_history, weekly_plan_cache, spaced_repetition_,
reduced_motion, haptic_feedback, analytics_consent,
streak_freeze, daily_xp, lesson_progress, completed_lessons
```

**Gap:** The `cost_tracker_expenses` and `cost_tracker_currency` keys (used by `CostTrackerScreen`) are **NOT** in the prefix whitelist. A user's full spending history would be lost in a ZIP backup/restore. The `wishlist_*` key would also miss if it doesn't start with a whitelisted prefix — needs verification. 

**Gap:** No schema versioning on the `SharedPreferences` JSON blob. If a key is renamed or a field is removed in a future release, old backup files restore silently with stale/missing data.

---

## 3. Crash Recovery Assessment

### Form Data Loss

There is no `RestorationMixin` or `RestorableProperty` usage anywhere in the codebase. Flutter's state restoration API is unused.

| Form | Data Lost on Crash | Severity |
|---|---|---|
| Add Log (water test with many fields) | All unsaved inputs | **High** — water tests can have 9+ numeric fields |
| Add Log (observation / medication notes) | All unsaved text | Medium |
| Create Tank (multi-step wizard) | All wizard progress | Medium |
| Symptom Triage (free text + 5 parameters) | All inputs | Medium |
| Cost Tracker entry modal | Description + amount | Low |
| Account screen (email/password) | Email/password typed | Low |

The `Add Log` screen and the Create Tank wizard are the highest-risk forms: users often fill in multiple readings and would be frustrated to lose them. No auto-save or draft mechanism is present.

### Multi-Step Operation Consistency

| Operation | Risk | Notes |
|---|---|---|
| Delete Tank | **Potential inconsistency** | `deleteTank()` removes tank + cascades livestock/equipment/logs/tasks in a single `_persistLock.synchronized` block — this is safe. |
| Backup ZIP export | Low | Creates a temp file then zips; if interrupted, temp files are left in system temp dir. |
| Cloud backup upload | Low | Upload failure throws; local data is untouched. |
| Restore from ZIP | **Medium** | Restoration is not transactional — if import fails halfway through tanks/livestock/logs, the DB is left partially populated. No rollback. |
| Restore from cloud backup | **Medium** | Same: `_importData` iterates entities one by one without a transaction. |

---

## 4. Data Migration Strategy

### Local JSON Schema
- Schema version is hardcoded as `_schemaVersion = 1` in `LocalJsonStorageService`.
- The version is written to disk in the JSON envelope (`'version': _schemaVersion`), but **it is never read back** — there is no migration logic that checks the on-disk version against the current version.
- Adding or renaming a field in a model (e.g. adding `Tank.co2InjectType`) would silently produce `null` when loading old data. The `_tankFromJson` / `_livestockFromJson` etc. helpers use `?? defaultValue` for most fields which provides graceful forward-compat, but there's no `onUpgrade` equivalent.

### `SharedPreferences` Keys
- Same issue: no version checking on load. Legacy key names from older app versions would just be ignored.
- `InventoryProvider` does have one ad-hoc migration: it copies items from the legacy user profile field into the new `SharedPreferences` key, then clears the old field. This is an example of the kind of migration needed systematically.

### Supabase SQL Migrations
- Only one migration file: `lib/supabase/migrations/001_initial.sql`. No upgrade path defined yet (appropriate for current early stage).

---

## 5. Concurrent Access

### In-App Concurrency
All write operations in `LocalJsonStorageService` are wrapped in `_persistLock.synchronized(...)` using the `synchronized` package. This is correct and prevents race conditions when multiple providers simultaneously trigger saves.

**Verified safe paths:**
- `saveTank`, `saveLivestock`, `saveEquipment`, `saveLog`, `saveTask`
- `deleteTank` (cascade), `deleteLivestock`, `deleteEquipment`, `deleteLog`, `deleteTask`
- `saveTanks` (bulk)
- `clearAllData`

**Potential race on read-then-write:** The `_ensureLoaded()` guard uses a `_loadFuture` to coalesce concurrent loads. However, if a write is triggered before the initial load completes (unlikely but possible on very fast first-launch), the `await _ensureLoaded()` at the top of each write method will handle it correctly since it awaits `_loadFuture`.

### Cross-Service Concurrency
- `CloudSyncService._handleRemoteChange` → calls `storage.saveLog()` / `storage.saveTank()` etc. from a Realtime callback. These go through the same `_persistLock`, so they're safe.
- `SyncService` queues to `SharedPreferences` but the queue itself has no lock — multiple simultaneous `queueAction()` calls could race if triggered rapidly. In practice, the Riverpod `StateNotifier` serializes its mutations on the event loop, so this is low risk.

### `SharedPreferences` Writes
- No lock on `SharedPreferences` writes (e.g. `GemsProvider`, `AchievementProvider`). These are async but `SharedPreferences` on mobile is backed by a single file with platform-level serialization, so corruption is unlikely. However, simultaneous writes to different keys from unrelated providers could produce unexpected read-back order.

---

## 6. Edge Cases Assessment

### First Launch (No Data)
- `LocalJsonStorageService._loadFromDisk()` handles missing file gracefully: if the file doesn't exist, it sets `_state = StorageState.loaded` and continues with empty maps. ✅
- Onboarding service (`OnboardingService`) checks `onboarding_completed` key; if absent, user is shown onboarding flow. ✅
- `isOnlineProvider` returns `true` during loading — on very slow devices a brief network call attempt could occur before connectivity is confirmed. Low risk.

### After Clearing App Data
- All `SharedPreferences` keys gone → user sees onboarding, fresh state. ✅
- `aquarium_data.json` gone → `LocalJsonStorageService` starts fresh. ✅
- Photos directory gone → logs with `photoUrls` will have broken paths. The app stores absolute paths in `LogEntry.photoUrls` locally, so photos will be missing silently (no error handling for broken image paths in `LogDetailScreen`).

### Very Large Data Sets (Hundreds of Logs/Fish)
- `LocalJsonStorageService` loads the **entire** `aquarium_data.json` into memory at startup and keeps it all in memory. For users with hundreds of tanks and thousands of logs, this could cause:
  - Slow initial load (JSON parse of large file)
  - High memory usage (all entities in memory at once)
- `getLogsForTank()` supports a `limit` parameter and `after` date filter — `tankLogsProvider` uses `limit: 50` for the default view. ✅
- However, the ZIP backup export iterates all logs for all tanks with no pagination, and the JSON serialisation of a large dataset is done in-memory. Could hit memory pressure.
- Gems transaction list is explicitly capped (`_maxTransactions`). ✅
- XP history is trimmed to 365 days before save. ✅

### Timezone Changes
- Streak calculation uses `DateTime.utc()` for day boundaries. ✅ Comment in `user_profile_notifier.dart` explicitly documents this.
- Task `dueDate` is stored as ISO-8601 with no timezone offset — parsed as local time. If a user travels between timezones, task due times will shift by the offset delta.
- Log `timestamp` is stored as local ISO-8601. Cross-timezone log history could appear out of order.
- Notification scheduling uses `timezone` package (`tz.TZDateTime`). ✅

### System Date Manipulation
- A user setting their clock backwards could extend their streak (daily XP credit would re-trigger). The streak logic checks `_todayUtc()` which uses `DateTime.now().toUtc()` — manipulable by the user.
- No server-side timestamp validation (sync queue is local-only scaffold).
- Offline-only mode means there is no authoritative time source.

---

## Top 10 Resilience Improvements (Ranked by User Impact)

### #1 — Add JSON Schema Migration on Load ⭐⭐⭐⭐⭐
**Impact:** Critical. Without this, any model field addition or rename in future app updates will silently break existing user data. The on-disk `version` field is already written; add a migration runner in `_loadFromDisk()` that inspects it and applies transformations before parsing.

**What to do:** Add a `_migrateJson(Map<String, dynamic> raw, int fromVersion)` function called in `_loadFromDisk()` when `raw['version'] < _schemaVersion`. Bump `_schemaVersion` on each breaking schema change.

---

### #2 — Draft Auto-Save for "Add Log" Form ⭐⭐⭐⭐⭐
**Impact:** High user frustration when app is backgrounded or killed mid water-test entry. Water tests involve up to 9 numeric fields.

**What to do:** On each field change, auto-save form state to `SharedPreferences` under a `log_draft_<tankId>` key. On screen open, check for a saved draft and offer to restore. Clear on successful submit.

---

### #3 — Add `cost_tracker_expenses` to SharedPreferences Backup Whitelist ⭐⭐⭐⭐
**Impact:** Users who diligently track aquarium costs (potentially months of entries) would lose all data on a device transfer or fresh install + backup restore. This is a silent data loss bug.

**What to do:** Add `'cost_tracker'` to `SharedPreferencesBackup._exportablePrefixes`. Verify wishlist key prefix is also covered.

---

### #4 — Transactional Restore / Rollback ⭐⭐⭐⭐
**Impact:** A corrupt or partial backup ZIP imported mid-way leaves the app in a mixed state (some new tanks + old ones, some missing livestock). Recovery requires manual deletion or another restore.

**What to do:** Load the complete backup into memory first, validate it, then snapshot the existing `LocalJsonStorageService` state and do a full replace atomically. On failure, restore the snapshot.

---

### #5 — Rolling `.bak` Files Across Sessions ⭐⭐⭐
**Impact:** The current `.bak` is only created on the first write of each session. If the app restarts and saves again, the `.bak` is overwritten with the same-session copy. A corruption that persists across sessions leaves users with no good recovery point.

**What to do:** Keep a timestamped rolling backup (e.g. `aquarium_data.bak.YYYYMMDD`) retained for 7 days. At startup, create today's backup from the previous clean state before loading.

---

### #6 — Handle Broken Photo Paths After App Data Clear ⭐⭐⭐
**Impact:** After clearing app data or restoring to a new device, `LogEntry.photoUrls` contains absolute paths from the old device that don't exist. Log detail screen will show broken images silently.

**What to do:** In `LogDetailScreen` (and anywhere else photos are displayed), check if the file path exists before rendering; show a "photo unavailable" placeholder with an option to remove the broken reference.

---

### #7 — Paginated Log Loading for Large Datasets ⭐⭐⭐
**Impact:** Users with 2+ years of weekly water tests (100+ log entries per tank) will experience noticeable app startup lag as the entire JSON blob is parsed and kept in memory.

**What to do:** Keep the in-memory approach but add a lazy-load threshold: only parse/cache the last N log entries at startup, loading older entries on demand. Alternatively, migrate to SQLite (sqflite) when log count exceeds a threshold.

---

### #8 — Implement Sync Queue Flush (Backend Sync Scaffold) ⭐⭐⭐
**Impact:** The `SyncService` and `OfflineAwareService` queue XP/gem/lesson/achievement actions for backend sync, but the flush-to-Supabase path is marked as scaffolding and doesn't execute. If Supabase credentials are ever provided, these queued actions will never actually sync, leaving cloud profiles permanently stale.

**What to do:** Implement `SyncService._flushQueue()` to actually `upsert` queued records to Supabase when online and authenticated. Add a `startListening()` call in `main.dart` that connects the connectivity stream to the flush trigger.

---

### #9 — UTC Timestamps for Task Due Dates and Log Entries ⭐⭐
**Impact:** Tasks and logs use local time ISO-8601. For users who travel internationally or in edge-case DST transitions, logs may appear out of chronological order and task due times may shift by the timezone offset.

**What to do:** Store all timestamps in UTC (append `Z` suffix to ISO strings). Display in local time using `DateTime.toLocal()`. This matches how streaks are already handled.

---

### #10 — SharedPreferences Versioning ⭐⭐
**Impact:** `SharedPreferencesBackup` doesn't version individual blobs (only the outer backup container). If a key's JSON schema changes between app versions, restoring an old backup silently produces corrupt state.

**What to do:** Store a `__sp_schema_version` key. On restore, compare backup's `__backup_version` (currently 1) against the running app's expected version and run a migration if needed — mirroring the same approach recommended for `LocalJsonStorageService`.

---

## Summary Risk Table

| Area | Risk Level | Primary Concern |
|---|---|---|
| Offline core (tanks/fish/logs/tasks) | 🟢 Low | Well-implemented local-first |
| Crash recovery (forms) | 🔴 High | No draft save; log entry data lost on crash |
| Schema migration | 🔴 High | No migration runner; future field changes break old data |
| Backup coverage (SharedPreferences) | 🟠 Medium | `cost_tracker_*` keys missing from whitelist |
| Restore atomicity | 🟠 Medium | No transactional rollback on import failure |
| Large data performance | 🟠 Medium | Full in-memory load; no lazy paging for logs |
| Sync queue | 🟠 Medium | Backend flush is scaffolding only |
| Photo path integrity | 🟡 Low-Medium | Broken paths after app reset; silent failures |
| Concurrent writes | 🟢 Low | `Lock` mutex properly applied throughout |
| Timezone handling | 🟢 Low | Streaks use UTC; tasks/logs are local time (minor) |
| Corruption detection | 🟢 Low | Robust; atomic writes, `.bak`, `.corrupted` copies |
