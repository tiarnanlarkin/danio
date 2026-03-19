# Performance & Memory Audit — Danio Aquarium App

**Auditor:** Argus  
**Branch:** `openclaw/stage-system`  
**Date:** 2026-03-19  
**Files scanned:** 330 Dart files across `lib/`

---

## 1. Widget Rebuild Analysis

### [PF-001] CurvedAnimation objects never disposed across onboarding screens
- **Severity:** P1
- **File:** `lib/screens/onboarding/welcome_screen.dart:47,54,64,74`, `lib/screens/onboarding/warm_entry_screen.dart:73,80,90,101`, `lib/screens/onboarding/aha_moment_screen.dart:76,98,111,125,137`, `lib/screens/onboarding/paywall_stub_screen.dart:55,63`, `lib/screens/onboarding/push_permission_screen.dart:47,58`, `lib/screens/onboarding/micro_lesson_screen.dart:56,63,73`, `lib/screens/onboarding/returning_user_flows.dart:57,229`
- **Impact:** 30+ `CurvedAnimation` instances created across onboarding screens are NEVER disposed. While their parent `AnimationController` is disposed (which does remove the listener), the `CurvedAnimation` object itself holds references to both the parent controller and curve object. On lower-end devices, failing to dispose these keeps listener registrations alive longer than needed and can trigger the `AnimationController` debug warning about being disposed with active listeners. This is a minor memory leak pattern that compounds across the onboarding flow.
- **Suggested Fix:** Store each `CurvedAnimation` as a `late final` field and call `.dispose()` in the `dispose()` method of each State. Pattern:
  ```dart
  late final CurvedAnimation _headlineOpacity;
  // in dispose():
  _headlineOpacity.dispose();
  ```
  Impact: ~30 instances fixed, eliminates potential listener leak warnings.

### [PF-002] Non-builder `ListView` used for potentially large result lists
- **Severity:** P2
- **File:** `lib/screens/compatibility_checker_screen.dart:264`
- **Impact:** `ListView(children: [...])` renders all children at once. In this case it shows selected species results which is typically small (<20 items), so actual jank is unlikely. However, if a user adds many species, every species card is built simultaneously.
- **Suggested Fix:** Convert to `ListView.builder(itemBuilder: ...)`. Low effort, defensive improvement.

### [PF-003] Non-builder `ListView` in skeleton loader
- **Severity:** P3
- **File:** `lib/widgets/lesson_skeleton.dart:121`
- **Impact:** Skeleton loader typically shows ~5-8 placeholder items. Rendering all at once is acceptable for this use case.
- **Suggested Fix:** No action needed — item count is bounded and small.

### [PF-004] Non-builder `ListView` in performance overlay
- **Severity:** P3
- **File:** `lib/widgets/performance_overlay.dart:209`
- **Impact:** Performance overlay shows debug metrics — typically <10 items. Acceptable.
- **Suggested Fix:** No action needed — debug-only widget.

### [PF-005] ~1,500 non-const `TextStyle`, `EdgeInsets`, `BoxDecoration`, `Color` instantiations in `build()` methods
- **Severity:** P2
- **Impact:** Creating new `TextStyle(...)`, `EdgeInsets.all(...)`, `BoxDecoration(...)` objects in `build()` forces Flutter to create new `RenderObject` properties every rebuild, even when the values haven't changed. With ~1,500 instances found, this is a systemic issue across the codebase. However, Flutter's widget reconciliation mitigates most of this — new objects with identical properties don't necessarily trigger repaints. This is more about wasted GC pressure on hot paths.
- **Suggested Fix:** Extract commonly repeated styles into `const` variables at the top of the file or in a theme constants class. Prioritise widgets that rebuild frequently (e.g., timers, animations). Estimated: ~200-300 `const` extractions would cover 80% of the impact.

### [PF-006] `CompactHeartsDisplay` uses 1-second `Timer.periodic` to force full rebuild for countdown display
- **Severity:** P2
- **File:** `lib/widgets/hearts_widgets.dart:94,100-101` and `lib/widgets/hearts_widgets.dart:297,303-304`
- **Impact:** Two separate widgets (`DetailedHeartsDisplay` and `OutOfHeartsModal`) create `Timer.periodic(Duration(seconds: 1))` that calls `setState(() {})` every second to refresh a countdown timer. This rebuilds the entire widget tree (including all children) every second, even though only a single text label changes. If multiple instances are shown, this compounds.
- **Suggested Fix:** Use a `ValueNotifier<int>` or `StreamBuilder` that only rebuilds the countdown text, not the entire widget. Alternatively, use a `Ticker`-based approach for smoother updates aligned with vsync.

### [PF-007] `room_scene.dart` — 1,816 lines, complex widget tree with background image
- **Severity:** P2
- **File:** `lib/widgets/room_scene.dart:89,374`
- **Impact:** The room scene is a large widget (1,816 lines) that loads a full-screen background `Image.asset()` on every build. The background image at line 89 does NOT set `cacheWidth`/`cacheHeight`, meaning the full-resolution asset is decoded into GPU memory. A second image at line 374 correctly sets `cacheWidth: 256, cacheHeight: 256` (a repeating texture). The main background is the concern.
- **Suggested Fix:** Add `cacheWidth` and `cacheHeight` to the background image at line 89, capped at the device screen resolution. For a Z Fold 5, this would be `cacheWidth: 1768, cacheHeight: 2208` (or use `MediaQuery`). This alone could save 50-75% of GPU memory for the background image.

---

## 2. Image Loading

### [PF-008] `Image.asset()` in `main.dart` splash screen without `cacheWidth`/`cacheHeight`
- **Severity:** P2
- **File:** `lib/main.dart:410`
- **Impact:** Splash screen logo decoded at full asset resolution into memory.
- **Suggested Fix:** Add `cacheWidth`/`cacheHeight` matching the display size.

### [PF-009] `Image.asset()` in `about_screen.dart` without `cacheWidth`/`cacheHeight`
- **Severity:** P3
- **File:** `lib/screens/about_screen.dart:37`
- **Impact:** About screen image loaded at full resolution. Low impact since screen is rarely visited.
- **Suggested Fix:** Add `cacheWidth`/`cacheHeight`.

### [PF-010] `Image.asset()` in `fish_select_screen.dart` (onboarding) without `cacheWidth`/`cacheHeight`
- **Severity:** P2
- **File:** `lib/screens/onboarding/fish_select_screen.dart:418`
- **Impact:** Fish sprite images in the selection tray are loaded without size constraints. If many species are shown, this wastes memory.
- **Suggested Fix:** Add `cacheWidth`/`cacheHeight` appropriate for the sprite display size.

### [PF-011] `Image.asset()` in `welcome_screen.dart` without `cacheWidth`/`cacheHeight`
- **Severity:** P3
- **File:** `lib/screens/onboarding/welcome_screen.dart:129`
- **Impact:** One-time onboarding screen image. Low concern but should still be constrained.
- **Suggested Fix:** Add `cacheWidth`/`cacheHeight`.

### [PF-012] `Image.asset()` in `livestock_preview.dart` without `cacheWidth`/`cacheHeight`
- **Severity:** P2
- **File:** `lib/screens/tank_detail/widgets/livestock_preview.dart:81`
- **Impact:** Livestock thumbnail loaded at full resolution. Could be shown multiple times on home screen.
- **Suggested Fix:** Add `cacheWidth`/`cacheHeight` matching the thumbnail display size.

### [PF-013] `Image.file()` in `add_log_screen.dart` — correctly uses `cacheWidth`/`cacheHeight`
- **Severity:** N/A (positive finding)
- **File:** `lib/screens/add_log_screen.dart:1321-1323`
- **Impact:** Good pattern — photo thumbnails use `cacheWidth: 96 * devicePixelRatio`. ✅

### [PF-014] `OptimizedAssetImage` / `OptimizedFileImage` and `CachedImage` exist but not used everywhere
- **Severity:** P2
- **File:** `lib/services/image_cache_service.dart:24-200`, `lib/widgets/optimized_image.dart:26-178`
- **Impact:** The codebase has well-implemented `OptimizedNetworkImage`, `OptimizedAssetImage`, `OptimizedFileImage`, and `CachedImage` utilities with `cacheWidth`/`cacheHeight`, `ResizeImage`, and placeholder support. However, at least 6 `Image.asset()` and `Image.file()` calls across the codebase bypass these utilities and use raw `Image` constructors. This is inconsistent — some images get optimisation, others don't.
- **Suggested Fix:** Audit all raw `Image.*()` calls and migrate to the existing `OptimizedAssetImage`/`OptimizedFileImage`/`CachedImage` wrappers. Estimated: 6-8 migration points.

---

## 3. Animation & Controller Leaks

### [PF-015] `CurvedAnimation` dispose — systemic pattern (30+ instances)
- **Severity:** P1
- **File:** See [PF-001] for full file/line list
- **Impact:** 30+ `CurvedAnimation` instances across onboarding screens are created but never individually disposed. While Dart's GC will eventually collect them after the parent `AnimationController` is disposed, this violates Flutter best practices and can trigger debug assertions about active listeners on disposed controllers.
- **Suggested Fix:** Add `CurvedAnimation` disposal to all `dispose()` methods. Estimated 30 lines of code across 10 files.

### [PF-016] `Timer` in `tank_provider.dart` — not cancelled in any lifecycle method
- **Severity:** P1
- **File:** `lib/providers/tank_provider.dart:22`
- **Impact:** `Timer(const Duration(seconds: 5), ...)` is created for tank debounce operations. If the provider is disposed before the 5-second timer fires, the timer callback will execute against a disposed provider. The `ref.onDispose` is used for other state but not for cancelling this timer.
- **Suggested Fix:** Store the timer in a variable and cancel it in `ref.onDispose`.

### [PF-017] `Timer` in `celebration_service.dart` — properly cancelled ✅
- **Severity:** N/A (positive finding)
- **File:** `lib/services/celebration_service.dart:78,106,119,141,152,166,195,209,218,230`
- **Impact:** Multiple `Timer` instances all have corresponding `_cancelDismissTimer()` calls. Well-managed. ✅

### [PF-018] `Timer` in `cloud_sync_service.dart` debounce — properly cancelled ✅
- **Severity:** N/A (positive finding)
- **File:** `lib/services/cloud_sync_service.dart:607-608`
- **Impact:** `_debounceTimer?.cancel()` called before creating new timer and in `dispose()`. ✅

### [PF-019] `Timer` in `ambient_time_service.dart` — not disposed in StateNotifier
- **Severity:** P2
- **File:** `lib/services/ambient_time_service.dart:151`
- **Impact:** `Timer.periodic(Duration(minutes: 1))` is created in a `StateNotifier`. When the notifier is disposed, the timer continues running. At 1-minute intervals this is low impact, but it's a resource leak.
- **Suggested Fix:** Cancel the timer in the StateNotifier's `dispose()` method.

### [PF-020] `Timer` in `fun_loading_messages.dart` — not disposed
- **Severity:** P3
- **File:** `lib/widgets/fun_loading_messages.dart:48,66`
- **Impact:** `Timer.periodic(Duration(seconds: 3))` is created and disposed when the widget is removed from the tree. The `dispose()` does cancel it. ✅ Actually well-managed.

### [PF-021] All `TextEditingController` and `FocusNode` instances — properly disposed ✅
- **Severity:** N/A (positive finding)
- **Files:** `symptom_triage_screen.dart:55-62`, `account_screen.dart:30-32`, `co2_calculator_screen.dart:27-29`, `cost_tracker_screen.dart:596-598`, `create_tank_screen.dart:670`, `dosing_calculator_screen.dart:30-32`, `equipment_screen.dart:641-644`, `home_sheets_tank.dart:194-196`, `journal_screen.dart:221-223`, `fish_select_screen.dart:91-92`, `livestock_screen.dart:963-968,1245-1247`
- **Impact:** All 20+ `TextEditingController` and `FocusNode` instances have corresponding `.dispose()` calls. ✅

### [PF-022] All `ScrollController` and `TabController`/`PageController` — properly disposed ✅
- **Severity:** N/A (positive finding)
- **Files:** `learn_screen.dart:54-55`, `create_tank_screen.dart:50`, `gem_shop_screen.dart:64`, `inventory_screen.dart:62-63`, `onboarding_screen.dart:65`
- **Impact:** All controllers are properly disposed. ✅

---

## 4. Memory & Data Loading

### [PF-023] ~500KB of static data loaded eagerly via top-level `const` lists
- **Severity:** P1
- **File:** `lib/data/species_database.dart` (99KB), `lib/data/plant_database.dart` (39KB), `lib/data/stories.dart` (59KB), `lib/data/achievements.dart` (21KB), `lib/data/shop_catalog.dart` (9KB), `lib/data/lessons/*.dart` (260KB total), `lib/data/daily_tips.dart` (10KB), `lib/data/mock_friends.dart`, `lib/data/mock_leaderboard.dart`
- **Impact:** Total ~500KB of static Dart objects are compiled into the binary and loaded into the Dart VM heap at app startup. The `const List<SpeciesInfo> _allSpecies` at `species_database.dart:116` contains ~80+ species with full `SpeciesInfo` objects including `List<String> compatibleWith` and `List<String> avoidWith`. Similarly, 260KB of lesson content across 9 lesson files is always in memory even when the user is on the home screen. This is the single largest memory footprint issue.
- **Suggested Fix:** **Big win.** Move lesson content to lazy-loaded JSON files that are parsed on first access (the `LessonProvider` infrastructure already exists at `lib/data/lesson_content_lazy.dart` but the actual lesson data is still in Dart). Consider moving `species_database.dart` to a JSON file loaded on first `SpeciesDatabase.species` access. For stories (59KB), load per-chapter on demand. Estimated savings: 300-400KB of RAM when not in learn/species screens.

### [PF-024] `_allSpecies` const list — species database not lazily initialised
- **Severity:** P2
- **File:** `lib/data/species_database.dart:116`
- **Impact:** The `_allSpecies` list is a top-level `const`, meaning all 80+ species with their string properties and compatibility lists are in memory from app launch. The `_ensureInitialized()` method at line 51 only builds the lookup maps — the data is already loaded.
- **Suggested Fix:** Move species data to a JSON asset file and parse on first access. The `SpeciesDatabase` class already has the `_ensureInitialized()` pattern — just change what it does.

### [PF-025] `LocalJsonStorageService` — single monolithic JSON file with full serialization on every write
- **Severity:** P1
- **File:** `lib/services/local_json_storage_service.dart` (entire file, ~600 lines)
- **Impact:** Every single mutation (save tank, save log, save livestock) triggers a complete serialization of ALL tanks, livestock, equipment, logs, and tasks into JSON and writes the entire payload to disk. As users accumulate logs (a log entry per water test), this JSON file grows unboundedly. Each save involves: (1) `_persistLock.synchronized()` lock acquisition, (2) `jsonEncode()` of all entities, (3) write `.tmp` file, (4) copy current to `.bak`, (5) rename `.tmp` → main file. With 100+ log entries and multiple tanks, each save serializes 1000+ objects. The `.bak` copy doubles disk I/O.
- **Suggested Fix:** **Big win.** Replace with SQLite (via `sqflite` or `drift`) or at minimum, separate the entity stores into individual JSON files (one per tank, one for global settings) so a single log save doesn't re-serialize everything. Debounce bulk operations where possible. Estimated: 5-10x reduction in save latency as data grows.

### [PF-026] Logs grow unboundedly in `LocalJsonStorageService`
- **Severity:** P2
- **File:** `lib/services/local_json_storage_service.dart:271` (`_logs` map)
- **Impact:** Log entries are added but never trimmed. A user testing water daily for a year accumulates 365+ entries per tank, each containing `WaterTestResults` with 9 parameters, timestamps, and optional notes. No pagination or archiving mechanism exists. This directly impacts the monolithic save issue in [PF-025].
- **Suggested Fix:** Implement log archiving: keep last 90 days of logs in the active store, archive older logs to a separate file. Show "load more" in the UI for archived logs.

### [PF-027] No `compute()` / `Isolate` usage for JSON parsing
- **Severity:** P2
- **File:** All providers and storage services
- **Impact:** All JSON `encode`/`decode` operations run on the main isolate. For the storage service's full-serialization saves (PF-025), this blocks the UI thread during disk writes. The `spaced_repetition_provider.dart` has multiple `jsonDecode`/`jsonEncode` calls for card data. `achievement_provider.dart` does streak computation on the main thread.
- **Suggested Fix:** Use `compute()` for JSON encode/decode operations on payloads > 10KB. Specifically target `_persistUnlocked()` in `local_json_storage_service.dart`.

### [PF-028] 203 `SharedPreferences` reads/writes found across providers and screens
- **Severity:** P2
- **File:** Multiple providers and screens (see grep results)
- **Impact:** `SharedPreferences` reads are async but cached after first load. Writes are async and debounced in some places (achievement_provider, user_profile_provider) but not in others. Each `prefs.setString()` call triggers a file write. Without debouncing, rapid state changes can queue many writes.
- **Suggested Fix:** Audit all `prefs.setString()` calls for debouncing. The `_saveDebouncer` pattern used in `achievement_provider.dart` and `user_profile_provider.dart` should be applied to `gems_provider.dart`, `spaced_repetition_provider.dart`, `inventory_provider.dart`, and `wishlist_provider.dart`.

---

## 5. Navigation & Routing

### [PF-029] `Navigator.push` used via `NavigationThrottle` — not using GoRouter
- **Severity:** P3
- **File:** `lib/utils/navigation_throttle.dart:47,68`
- **Impact:** The app uses `Navigator.push()` and `Navigator.pushNamed()` wrapped in a throttle utility rather than GoRouter's `context.push()`. This is a deliberate architectural choice (the throttle adds debounce/safety-timer logic) and works correctly. However, it means the app doesn't benefit from GoRouter's declarative routing, deep linking, or URL state restoration.
- **Suggested Fix:** No immediate action — this is an architectural decision, not a performance bug.

---

## 6. Database / Storage

### [PF-030] `LocalJsonStorageService` — full monolithic serialization on every write (duplicate of PF-025)
- **Severity:** P1
- **File:** `lib/services/local_json_storage_service.dart:240-260` (`_persistUnlocked`)
- **Impact:** See [PF-025] for full details. Every entity save (tank, log, livestock, equipment, task) triggers `_persistUnlocked()` which serializes ALL entities and writes the entire JSON file.
- **Suggested Fix:** See [PF-025].

### [PF-031] Backup file created on every save
- **Severity:** P2
- **File:** `lib/services/local_json_storage_service.dart:249-255`
- **Impact:** Every save copies the current file to a `.bak` file before writing the new one. This means every save involves 3x disk I/O: (1) copy main → .bak, (2) write .tmp, (3) rename .tmp → main. For a service that's called on every log entry, tank edit, or parameter change, this is excessive.
- **Suggested Fix:** Only create `.bak` on first save after app launch (detect stale `.bak` via timestamp) or use journal-based durability (write-ahead log) instead of full backup copies.

---

## Summary

### Findings by Severity

| Severity | Count | Description |
|----------|-------|-------------|
| **P0** | 0 | No OOM/crash/freezes found |
| **P1** | 4 | CurvedAnimation leaks (30+), Timer leak in tank_provider, monolithic JSON serialization, ~500KB static data |
| **P2** | 12 | Unbounded log growth, no Isolate usage, inconsistent image caching, 1s timer rebuilds, background image without cache, SharedPreferences not debounced everywhere, etc. |
| **P3** | 4 | Small ListViews, about screen image, welcome screen image, NavigationThrottle pattern |
| **✅ Positive** | 6 | TextEditingControllers disposed, ScrollControllers disposed, celebration service timers managed, existing image cache utilities, debouncer patterns, .bak backup logic |

### Quick Wins (High Impact, Low Effort)

1. **[PF-001/PF-015] Dispose all 30 `CurvedAnimation` instances** — 30 lines of code across 10 files, eliminates listener leak warnings
2. **[PF-006] Replace 1s Timer.periodic + setState with ValueNotifier for hearts countdown** — 2 widgets, significant rebuild reduction
3. **[PF-008, PF-010, PF-012] Add cacheWidth/cacheHeight to 6 raw Image.asset() calls** — 6 lines, immediate GPU memory savings
4. **[PF-016] Cancel Timer in tank_provider onDispose** — 2 lines, prevents post-dispose callback
5. **[PF-028] Add SharedPreferences write debouncing to 4 providers** — ~20 lines, reduces disk I/O

### Big Wins (High Impact, High Effort)

1. **[PF-023/PF-024] Migrate 500KB of static data to lazy-loaded JSON assets** — Biggest memory footprint reduction. Move species (99KB), lessons (260KB), stories (59KB) to JSON files loaded on demand. Use existing `LessonProvider` infrastructure. Estimated savings: 300-400KB RAM on home screen.
2. **[PF-025/PF-030] Replace monolithic JSON storage with SQLite** — Eliminates O(n) serialization on every write. As data grows, the current approach becomes the primary bottleneck for save performance. Would also enable efficient queries (e.g., "latest log for tank X" without scanning all logs).
3. **[PF-027] Offload JSON encode/decode to `compute()`** — Target `_persistUnlocked()` and provider initialization. Prevents UI jank during saves and app startup.
4. **[PF-014] Standardise all image loading through existing OptimizedImage wrappers** — Migrate 6-8 raw Image calls to use `OptimizedAssetImage`/`OptimizedFileImage`/`CachedImage`.

### Overall Assessment

The Danio codebase is **generally well-written** with good disposal patterns for controllers and inputs. The main performance concerns are:

1. **Storage architecture** — the monolithic single-file JSON approach will become a bottleneck as users accumulate data. This is the highest-impact item to address before scaling.
2. **Static data memory** — ~500KB of always-in-memory data is a significant portion of the app's memory budget on low-end devices.
3. **Animation hygiene** — the 30 undispersed `CurvedAnimation` instances are a pattern issue that should be addressed to prevent future regressions as the animation system grows.

No P0 (crash/OOM) issues were found. The app should perform well for typical users with 1-2 tanks and <100 log entries. The concerns become more relevant as data accumulates over months of use.
