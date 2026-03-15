# Production Audit: Tank Creation Deep Dive

**Date:** 2026-03-15  
**Auditor:** Production Release Auditor (subagent)  
**Scope:** End-to-end tank creation journey  
**Codebase:** `apps/aquarium_app/`

---

## Executive Summary

The tank creation flow is **solid for production release**. The code demonstrates mature engineering with good accessibility, race condition guards, atomic storage writes, and thoughtful UX. However, there are **2 P1 issues** and several P2s that should be tracked.

**Totals:** 0 P0 | 2 P1 | 8 P2

---

## 1. CreateTankScreen (`lib/screens/create_tank_screen.dart`)

### 1.1 Page Flow: Name → Volume/Dimensions → Water Type ✅

Three-page `PageView` with `NeverScrollableScrollPhysics` (no swipe — buttons only). Progress indicator shows `(_currentPage + 1) / 3`. Clean, linear flow.

### 1.2 Form Validation

| Input | Validation | Verdict |
|-------|-----------|---------|
| Empty name | `v.trim().isEmpty` → "Please enter a tank name" | ✅ Works |
| Spaces-only name | `_name.trim().isNotEmpty` gates Next button + validator trims | ✅ Works |
| Very long name (200+ chars) | **No max length enforced** | ⚠️ P2-01 |
| Special characters | No restriction — allowed | ✅ Acceptable |
| Emoji in name | No restriction — allowed, Flutter handles Unicode | ✅ Works |
| 0 volume | Validator: `n <= 0` → "Please enter a volume greater than 0" | ✅ Works |
| Volume > 10,000L | Validator: `n > 10000` → "Maximum 10,000 litres" | ✅ Good cap |
| Empty volume | Validator: `v.isEmpty` → "Please enter a volume" | ✅ Works |

**Finding P2-01: No tank name length limit**
- **File:** `create_tank_screen.dart`, line ~230 (TextFormField validator)
- **Severity:** P2
- **Issue:** A user could enter a 500-character tank name. This won't crash but will overflow UI in TankSwitcher, AppBar titles, and TankDetailScreen's `FlexibleSpaceBar`.
- **Reproduction:** Enter 200+ character name → tap Next → create tank → observe name overflow in Home screen tank switcher and detail screen.
- **Suggested fix:** Add `maxLength: 50` to the TextFormField and/or a validator check: `if (v.length > 50) return 'Max 50 characters'`.

### 1.3 Marine Type Disabled ✅

- **Line ~270-285:** `_TypeCard` for Marine has `isDisabled: true` and subtitle "Arriving soon".
- **On tap:** Shows SnackBar "Marine tanks are on the way — stay tuned! 🐠🦀🐙" (3 seconds).
- **Opacity:** Reduced to 0.6 when disabled.
- **Semantics:** `enabled: false` and hint "Arriving soon".
- **Verdict:** Clear and well-handled. User gets feedback, not silence.

### 1.4 Volume Presets ✅

Presets: 20L, 60L, 120L, 200L, 300L.

These are sensible common tank sizes:
- 20L = nano/betta tank ✅
- 60L = standard starter ✅  
- 120L = standard community ✅
- 200L = large community ✅
- 300L = large display ✅

Missing but acceptable for MVP: 40L (common Fluval Flex size), 450L+ (large tanks). Fine for v1.

### 1.5 Dimension Inputs ✅

- Clearly labelled "Dimensions (optional)" with header.
- Subtitle: "Useful for stocking recommendations."
- All three fields (length, width, height) are independent — entering only width is fine, returns `double?` via `double.tryParse(v)`.
- No cross-validation (e.g., dimensions vs volume consistency) — acceptable for MVP.
- `inputFormatters` restrict to digits and decimal point.

### 1.6 Back Button Behaviour ✅

- Page > 0: "Back" button calls `_previousPage()` which animates to previous page.
- Page 0: No "Back" button shown (correct — `if (_currentPage > 0)`).
- AppBar close (X) button: triggers `Navigator.maybePop(context)` → `PopScope` handles unsaved data dialog.

### 1.7 "Create Tank" Button — Double-Tap Race Condition ✅

- **Line ~155:** `_canProceed() && !_isCreating ? _createTank : null`
- `_isCreating` is set `true` at the start of `_createTank()` and `false` in `finally`.
- Button shows `isLoading: _isCreating` spinner.
- **Verdict:** Double-tap protection is properly implemented.

### 1.8 PopScope — Unsaved Data Prompt ✅

- **Line ~53-68:** `canPop: !_hasUnsavedData || _isCreating`
- `_hasUnsavedData` = `_name.isNotEmpty || _volumeLitres > 0 || _currentPage > 0`
- When `canPop` is false, shows AlertDialog "Discard new tank?" with Cancel/Discard.
- Edge case: during creation (`_isCreating = true`), `canPop` becomes true — this prevents the dialog from blocking the pop after successful creation. Smart.

**Finding P2-02: PopScope allows pop during creation**
- **File:** `create_tank_screen.dart`, line ~53
- **Severity:** P2
- **Issue:** `canPop: !_hasUnsavedData || _isCreating` means when `_isCreating` is true, `canPop` is true. If the user hits the system back button during the async `_createTank()`, they can navigate away while the tank is being saved. The tank will still be created (the Future continues), but the success SnackBar/celebration won't fire because `mounted` will be false.
- **Impact:** Minor — tank is created but no feedback shown. User might create a duplicate thinking it failed.
- **Suggested fix:** Change to `canPop: !_hasUnsavedData && !_isCreating` (block pop during creation too), or keep current behaviour but add a note that it's intentional.

### 1.9 Post-Creation Flow ✅

After successful creation:
1. XP awarded (with 2x boost if active) ✅
2. XP animation shown ✅
3. Achievement check (non-blocking, caught errors) ✅
4. Navigator.pop() ✅
5. SnackBar: "{name} created! +{XP} XP" ✅
6. First tank celebration milestone ✅
7. Second tank "Multi-Tank Aquarist" Pro seed ✅

**Smart pattern:** Captures `Navigator.of(context)` and `ScaffoldMessenger.of(context)` BEFORE `pop()` to avoid deactivated context errors.

---

## 2. Tank Model (`lib/models/tank.dart`)

### 2.1 Fields & Defaults

| Field | Type | Default | Verdict |
|-------|------|---------|---------|
| id | String (required) | — | ✅ |
| name | String (required) | — | ✅ |
| type | TankType (required) | — | ✅ |
| volumeLitres | double (required) | — | ✅ |
| lengthCm | double? | null | ✅ Optional |
| widthCm | double? | null | ✅ Optional |
| heightCm | double? | null | ✅ Optional |
| startDate | DateTime (required) | — | ✅ |
| targets | WaterTargets (required) | — | ✅ |
| notes | String? | null | ✅ |
| imageUrl | String? | null | ✅ |
| sortOrder | int | 0 | ✅ |
| isDemoTank | bool | false | ✅ |
| createdAt | DateTime (required) | — | ✅ |
| updatedAt | DateTime (required) | — | ✅ |

All defaults are sensible. No nullable fields that should be required.

### 2.2 fromJson/toJson ✅

- `toJson()` serializes all fields including `isDemoTank`.
- `fromJson()` handles missing fields gracefully with defaults:
  - `type` defaults to `freshwater` if missing/invalid
  - `volumeLitres` defaults to 0 if null
  - `sortOrder` defaults to 0 if null
  - `isDemoTank` defaults to false if null
- `startDate`, `createdAt`, `updatedAt` use `DateTime.parse()` — will throw on malformed dates. Acceptable: these are always written by the app.

**Finding P1-01: Storage serialization drops `isDemoTank`**
- **File:** `local_json_storage_service.dart`, line ~618 (`_tankToJson`)
- **Severity:** P1
- **Issue:** The storage service's `_tankToJson()` does NOT include `isDemoTank`. The `_tankFromJson()` also does not read it. The model's own `toJson()`/`fromJson()` DO include it, but the storage service uses its own separate serialization methods.
- **Impact:** After app restart, a demo tank will have `isDemoTank = false` (the default). The "Demo Tank" banner in TankDetailScreen (`if (tank.isDemoTank)`) will never appear after first load. Demo tanks become indistinguishable from real tanks after restart.
- **Reproduction:** Create demo tank → kill app → reopen → navigate to demo tank → no "Demo Tank" banner.
- **Suggested fix:** Add `'isDemoTank': t.isDemoTank,` to `_tankToJson()` and `isDemoTank: (m['isDemoTank'] as bool?) ?? false,` to `_tankFromJson()`.

### 2.3 WaterTargets ✅

- Const assertions validate min ≤ max for all ranges.
- Factory constructors for tropical and coldwater with sensible defaults:
  - Tropical: 24-28°C, pH 6.5-7.5, GH 4-12, KH 3-8
  - Coldwater: 15-22°C, pH 7.0-8.0, GH 8-18, KH 4-10
- All fields nullable — supports partial data.
- `copyWith` available for updates.

### 2.4 TankType Enum

```dart
enum TankType { freshwater, marine }
```

Complete for current scope. Missing types that could come later: brackish, paludarium, terrarium. Fine for MVP.

---

## 3. Tank Provider (`lib/providers/tank_provider.dart`)

### 3.1 createTank() ✅

- Validates `volumeLitres > 0` with `ArgumentError`.
- Generates UUID v4 for ID.
- Creates default tasks for new tank.
- Invalidates `tanksProvider` after save.
- Wraps in try/catch, rethrows for UI handling.

**No name validation in provider** — relies on UI-level validation. Acceptable pattern but means programmatic callers (e.g., import) could create tanks with empty names.

### 3.2 Tank Ordering/Sorting ✅

`tanksProvider` sorts by `sortOrder` then `createdAt`. New tanks get `sortOrder = 0` (default), so they appear first among tanks with the same sort order, ordered by creation time.

### 3.3 Demo Tank vs Real Tank

- `seedDemoTankIfEmpty()` — only if user has no tanks. Calls `SampleData.seedFreshwaterDemo()`.
- `addDemoTank()` — adds demo regardless of existing tanks. Settings feature.
- Both invalidate all relevant providers.
- **See P1-01 above:** `isDemoTank` flag is lost on persist, so demo/real distinction doesn't survive restart.

### 3.4 updateTank() ✅

- Sets `updatedAt` to now.
- Invalidates both `tanksProvider` and `tankProvider(tank.id)`.

### 3.5 softDeleteTank() ✅

- Marks tank as soft-deleted in `SoftDeleteState`.
- 5-second timer before permanent deletion.
- `undoDeleteTank()` cancels timer and restores.
- Timer and deleted IDs stored in Riverpod-managed `SoftDeleteState` — survives provider refreshes.
- `ref.onDispose(state.dispose)` cleans up timers.

**Finding P2-03: Soft delete timer survives but undo UI doesn't**
- **File:** `tank_provider.dart`, lines ~20-40
- **Severity:** P2
- **Issue:** If a user soft-deletes a tank, the SnackBar with "Undo" appears for ~4 seconds (default SnackBar duration from `kSnackbarDuration`). But the actual timer is 5 seconds. If the SnackBar dismisses before the timer fires, the user can't undo. The SnackBar duration should match or exceed the 5-second timer.
- **Suggested fix:** Ensure `kSnackbarDuration >= Duration(seconds: 5)` or set SnackBar duration to `const Duration(seconds: 5)` explicitly.

### 3.6 permanentlyDeleteTank() ✅

- Calls `storage.deleteTank(id)` which also deletes all related livestock, equipment, logs, and tasks.
- Invalidates `tanksProvider`.

---

## 4. Storage Layer (`lib/services/local_json_storage_service.dart`)

### 4.1 Persistence Mechanism ✅

- Single JSON file: `aquarium_data.json` in app documents directory.
- All entities (tanks, livestock, equipment, logs, tasks) in one file.
- Schema version tracking (`_schemaVersion = 1`).

### 4.2 Atomic Writes ✅

- **Line ~268-282:** Write to `.tmp` file → backup existing as `.bak` → rename `.tmp` to main file.
- Rename is atomic on most filesystems.
- `.bak` preserved for crash recovery.
- Best-effort backup (caught errors don't block save).

### 4.3 Concurrency Protection ✅

- `Lock _persistLock` (from `synchronized` package) wraps all modify+persist operations.
- Every save/delete method uses `_persistLock.synchronized(() async { ... })`.

### 4.4 Corruption Protection ✅

- Parse errors backed up to `.corrupted.{timestamp}` files.
- Entity-level error recovery: individual corrupted entities are skipped (up to 10).
- > 10 corrupted entities throws `FormatException` (assumes severe corruption).
- Three recovery methods: `clearAllData()`, `retryLoad()`, `recoverFromCorruption()`.
- State tracking via `StorageState` enum: idle/loading/loaded/corrupted/ioError.
- I/O errors soft-fail: continues with empty data rather than crashing.

### 4.5 Storage Full / JSON Malformed

- **Storage full:** `writeAsString` will throw IOException → caught in `_persistUnlocked()` (no, actually it will throw and propagate to the caller). The save methods do `rethrow` in catch blocks.

**Finding P2-04: No disk space check before write**
- **File:** `local_json_storage_service.dart`, line ~268 (`_persistUnlocked`)
- **Severity:** P2
- **Issue:** If the device has no disk space, `tmp.writeAsString()` will throw. The `.bak` copy may also fail. In the worst case, the `.tmp` write partially completes and then the rename fails, potentially leaving the data in the `.bak` only.
- **Impact:** Very unlikely on modern devices but could cause data loss in extreme storage-constrained situations.
- **Suggested fix:** Consider catching the write exception in `_persistUnlocked` and logging it, or checking available space before write.

- **Malformed JSON:** Handled — caught in `_loadFromDisk()`, backed up, error state set.

---

## 5. Tank Detail Screen (`lib/screens/tank_detail/tank_detail_screen.dart`)

### 5.1 Immediately After Creation

After tank creation, `Navigator.pop()` returns to HomeScreen. The HomeScreen then:
1. Invalidates `tanksProvider` (via `whenComplete` callback)
2. For first-tank flow (`_navigateToCreateFirstTank`): automatically navigates to `TankDetailScreen` for the new tank.
3. For subsequent tanks: returns to HomeScreen, new tank appears in switcher.

**What the user sees on TankDetailScreen:**
- Tank name in SliverAppBar with gradient background ✅
- QuickStats (volume, age, etc.) ✅
- Tank Health card (will show "No data" equivalent — no logs yet) ✅
- Action buttons: Log Test, Water Change, Add Note ✅
- Latest Water Snapshot: empty state ✅
- Trends: empty state ✅
- Cycling status card (for tanks < 90 days old) ✅
- Tasks: default tasks from `DefaultTasks.forNewTank()` ✅
- Recent Activity: empty ✅
- Livestock: empty with add prompt ✅
- Equipment: empty with add prompt ✅

**Verdict:** Immediately useful — has default tasks and clear actions to take.

### 5.2 Navigation Back to Home ✅

- `Navigator.pop()` returns to HomeScreen.
- HomeScreen uses `ref.watch(tanksProvider)` — state preserved.
- `_currentTankIndex` maintained in `_HomeScreenState`.

### 5.3 Tank Settings ✅

- `TankSettingsScreen` loads tank by ID, allows editing name, type, volume, dimensions, start date, water type, notes.
- Uses lazy initialization (`_initialized` flag) to populate fields from tank data once.

---

## 6. Home Screen Tank Integration

### 6.1 TankSwitcher ✅

- Shows current tank name and volume.
- Multi-tank: shows index "1/3" and picker chevron.
- Single tank: no picker indicator.
- On tap (multi-tank): opens `TankPickerSheet` bottom sheet.
- On long press: enters selection mode (bulk operations).
- Name overflow: `TextOverflow.ellipsis` ✅

### 6.2 _currentTankIndex After Adding Tank

**Finding P1-02: _currentTankIndex can point to wrong tank after creation**
- **File:** `home_screen.dart`, `_HomeScreenState` class
- **Severity:** P1
- **Issue:** After creating a new tank via `_navigateToCreateTank()`, the `tanksProvider` is invalidated but `_currentTankIndex` is NOT updated. The new tank's position depends on `sortOrder` (default 0) and `createdAt`. If the new tank sorts before the currently-viewed tank, `_currentTankIndex` now points to a different tank than before — the user sees a different tank's room scene without having switched.
- **Reproduction:** Have 3 tanks → viewing tank at index 2 → create new tank → new tank gets sortOrder 0 → it inserts at position 0 or 1 → `_currentTankIndex` is still 2 → now pointing to a different tank.
- **Mitigating factor:** `_navigateToCreateFirstTank()` handles first tank correctly and navigates to the new tank. The `_navigateToCreateTank()` path (non-first) doesn't adjust the index but uses `% tanks.length` to prevent out-of-bounds. The user sees the wrong tank but the app doesn't crash.
- **Suggested fix:** After `ref.invalidate(tanksProvider)` in `_navigateToCreateTank().whenComplete()`, resolve the new tank list and set `_currentTankIndex` to the new tank's index, or to 0.

### 6.3 Empty State → First Tank → Room Scene ✅

- Empty: `EmptyRoomScene` with "Create Your Tank" and "Load Demo" buttons.
- After first tank creation: `_navigateToCreateFirstTank` auto-navigates to `TankDetailScreen`.
- Room scene renders with the tank's data immediately after returning.
- P0-001 and P0-002 fixes in place for lifecycle/loading edge cases.

---

## 7. Edge Cases

### 7.1 Create Tank → Kill App → Reopen

- **Analysis:** `_createTank()` calls `_storage.saveTank(tank)` which does atomic write (`.tmp` → rename). If the app is killed:
  - After rename completes: tank is persisted ✅
  - During `.tmp` write: no data loss (original file untouched) ✅
  - Between `.tmp` write and rename: `.tmp` file exists, original is stale. On reload, `.tmp` is ignored — **tank is lost**. But this is an extremely small window.
- **Default tasks:** Created in a loop AFTER `saveTank`. If killed between tank save and task saves, tank exists without tasks. Minor — tasks can be recreated.
- **Verdict:** Safe for production. Atomic write pattern handles this well.

### 7.2 Create 50 Tanks

**Finding P2-05: Performance concern with many tanks**
- **File:** `local_json_storage_service.dart`, `_persistUnlocked()`
- **Severity:** P2
- **Issue:** Every save serializes ALL entities to JSON and writes the entire file. With 50 tanks, each with livestock/equipment/logs/tasks, the JSON file could grow to several MB. Every tank creation triggers a full rewrite.
- **Impact:** Increased save time and potential UI jank on lower-end devices. The `Lock` prevents concurrent writes but queues them, so rapid operations could back up.
- **Suggested fix:** Acceptable for MVP. For scale, consider per-entity files or SQLite migration.

**Finding P2-06: TankSwitcher/BottomPlate with 50 tanks**
- **File:** `home_screen.dart`, `_buildTankTile` loop
- **Severity:** P2
- **Issue:** All tank tiles are rendered in a `Column` inside `BottomPlate`, not a `ListView.builder`. 50 tanks means 50 `ListTile` widgets built eagerly.
- **Impact:** Minor performance concern. Acceptable for realistic tank counts (most users have 1-5 tanks).
- **Suggested fix:** Replace with `ListView.builder` for lazy rendering if tank count becomes a concern.

### 7.3 Unicode Names (Chinese, Arabic, Emoji) ✅

- Flutter's `Text` widget handles Unicode natively.
- `TextFormField` with `TextCapitalization.words` may behave oddly with CJK (no word boundaries), but input still works.
- JSON serialization handles UTF-8 correctly.
- **Verdict:** Works fine.

### 7.4 Very Long Name (200+ Characters)

See P2-01 above. No length limit enforced. Will cause UI overflow in:
- `TankSwitcher`: `TextOverflow.ellipsis` handles it ✅
- `TankDetailScreen` `FlexibleSpaceBar` title: `maxLines: 1, overflow: TextOverflow.ellipsis` ✅
- HomeScreen top bar: `Flexible` + `TextOverflow.ellipsis` ✅
- **Verdict:** UI handles it gracefully with ellipsis, but storage and JSON bloat are unnecessary. Add a limit.

### 7.5 Create Tank While Offline ✅

- All storage is local (JSON file on device). No network calls in the creation flow.
- Achievement checking could fail (if it needs network), but it's wrapped in try/catch.
- **Verdict:** Works perfectly offline.

### 7.6 Two Rapid "Create" Taps ✅

- `_isCreating` flag disables the button immediately.
- Button receives `null` onPressed when `_isCreating` is true.
- `AppButton` with `isLoading: _isCreating` shows spinner.
- **Verdict:** Properly guarded.

**Finding P2-07: Home screen create button has separate double-nav guard**
- **File:** `home_screen.dart`, `_navigateToCreateTank()`
- **Severity:** P2 (informational — already fixed)
- **Issue:** `_isNavigatingToCreate` flag prevents double navigation. The FAB also has this path. Both use the flag correctly. However, the FAB's `setState(() => _isNavigatingToCreate = true)` renders the FAB invisible during navigation — good UX.

---

## 8. Additional Findings

**Finding P2-08: Volume preset doesn't update text controller immediately**
- **File:** `create_tank_screen.dart`, `_SizePageState.didUpdateWidget()`
- **Severity:** P2
- **Issue:** When a preset chip is tapped, `onVolumeChanged` is called which sets `_volumeLitres` in the parent via `setState`. The `_SizePage` rebuilds and `didUpdateWidget` syncs the text controller. However, the sync has a guard: `double.tryParse(currentText) != widget.volumeLitres` — this works but is indirect. If the text field is currently focused and has partial input (e.g., "12"), tapping "120L" preset may produce "120.0" in the field (from `toString()`), which is slightly unexpected.
- **Impact:** Minor cosmetic — "120.0" vs "120". Not blocking.
- **Suggested fix:** Use `volumeLitres.toStringAsFixed(0)` when displaying whole numbers.

**Finding P2-09: `_createTank` doesn't trim dimension values**
- **File:** `create_tank_screen.dart`, `_createTank()` line ~177
- **Severity:** P2 (very minor)
- **Issue:** `_name.trim()` is called but dimension values (`_lengthCm`, `_widthCm`, `_heightCm`) are passed as-is. These come from `double.tryParse()` so they can't have whitespace, but a value of `0.0` is valid and passed through. A tank with `lengthCm: 0.0` is different from `null` semantically.
- **Impact:** Negligible — `0.0` dimensions are unlikely and don't break anything.

---

## Summary Table

| ID | Severity | Component | Issue |
|----|----------|-----------|-------|
| P1-01 | **P1** | Storage `_tankToJson` | `isDemoTank` not serialized — demo flag lost on restart |
| P1-02 | **P1** | HomeScreen | `_currentTankIndex` not updated after tank creation — may show wrong tank |
| P2-01 | P2 | CreateTankScreen | No max length on tank name input |
| P2-02 | P2 | CreateTankScreen | PopScope allows back navigation during async creation |
| P2-03 | P2 | TankProvider | Soft delete timer (5s) may outlast SnackBar undo window |
| P2-04 | P2 | Storage | No disk space check before atomic write |
| P2-05 | P2 | Storage | Full-file rewrite on every save — scales poorly with many tanks |
| P2-06 | P2 | HomeScreen | Tank tiles in Column, not lazy ListView.builder |
| P2-07 | P2 | HomeScreen | Double-nav guard works correctly (informational) |
| P2-08 | P2 | CreateTankScreen | Volume preset shows "120.0" instead of "120" |
| P2-09 | P2 | CreateTankScreen | Zero dimensions (0.0) not filtered to null |

---

## Recommendation

**Ship-ready:** Yes, with the caveat that **P1-01** (`isDemoTank` serialization) should be fixed before or shortly after release — it's a one-line fix in `_tankToJson` and `_tankFromJson`. **P1-02** (tank index) is a UX annoyance, not a crash, and can be addressed in a fast-follow.

All P2 items are acceptable technical debt for MVP launch.
