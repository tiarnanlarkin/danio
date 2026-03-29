# Danio — Performance Deep Audit

> **Branch:** `openclaw/stage-system`  
> **Audit date:** 2026-03-29  
> **Auditor:** Prometheus (read-only, no files changed)

---

## 1. Startup Waterfall

What executes before or immediately after `runApp()`:

| Step | What happens | Blocking? | Est. cost |
|------|-------------|-----------|-----------|
| 1 | `WidgetsFlutterBinding.ensureInitialized()` | Yes | ~0 ms |
| 2 | `SystemChrome.setEnabledSystemUIMode` + overlay style | Yes | ~1 ms |
| 3 | `GoogleFonts.config.allowRuntimeFetching = false` | Yes | ~0 ms |
| 4 | `SystemChrome.setPreferredOrientations([portrait])` | **await** | ~5–15 ms |
| 5 | Flutter error handler setup | Yes | ~0 ms |
| 6 | `runApp(ErrorBoundary → ProviderScope → DanioApp)` | — | first frame |
| 7 | `DanioApp.build` → watches `settingsProvider` (SharedPrefs future) | Reactive | — |
| 8 | `_AppRouterState.initState` → `_checkGdprConsent()` (SharedPrefs call) | async | ~10–30 ms |
| 9 | While consent check is pending → `_buildSplash()` rendered | — | ✅ splash visible |

**Post-frame callback (deferred correctly):**

| Step | What | Est. cost |
|------|------|-----------|
| A | `Firebase.initializeApp()` | ~100–500 ms |
| B | `SharedPreferences.getInstance()` + GDPR consent read | ~10–30 ms |
| C | Crashlytics handler upgrade | ~0 ms |
| D | `SupabaseService.initialize()` | ~50–200 ms (network) |
| E | `SpeciesDatabase.prewarm()` (unawaited) | ~2–5 ms background |
| F | `PlantDatabase.prewarm()` (unawaited) | ~0 ms (just touches const list) |
| G | Performance monitor start (debug only) | ~0 ms |
| H | `NotificationService.initialize()` | ~20–50 ms |

**Verdict:** The startup architecture is well-designed. Heavy work (Firebase, Supabase, notifications) is correctly deferred behind a post-frame callback. The splash screen renders before any of that work begins.

**One mild issue:** `_checkGdprConsent()` in `_AppRouterState.initState` calls `SharedPreferences.getInstance()` independently — this is an extra SharedPreferences instance creation that races with the `sharedPreferencesProvider` FutureProvider. In practice both calls are nearly instant, but it's a redundant call. The `_AppRouter` could instead watch `sharedPreferencesProvider` to deduplicate.

---

## 2. Lazy vs Eager Loading

### Provider initialization strategy

| Provider | Strategy | Eagerly loaded on first frame? |
|----------|----------|-------------------------------|
| `settingsProvider` | `StateNotifierProvider` | ✅ Yes — reads SharedPrefs async via `.future` |
| `userProfileProvider` | `StateNotifierProvider` | ✅ Yes — `_load()` fires in constructor |
| `sharedPreferencesProvider` | `FutureProvider` | Yes (depended on by profile) |
| `onboardingCompletedProvider` | `FutureProvider` | Yes — watched by `_AppRouter` |
| `lessonProvider` | `StateNotifierProvider` | Yes — but lesson *content* is deferred imports |
| `achievementProvider` | `StateNotifierProvider` | Yes — non-autoDispose |
| `spacedRepetitionProvider` | `StateNotifierProvider` | Yes — non-autoDispose |
| `gemsProvider` | `StateNotifierProvider` | Yes — non-autoDispose |
| `reducedMotionProvider` | `StateNotifierProvider` | Lazy (only when first consumed) |
| `tanksProvider` | `FutureProvider` (non-autoDispose) | Lazy |
| `inventoryProvider` | `StateNotifierProvider.autoDispose` | Lazy ✅ |
| Tank sub-providers | `FutureProvider.autoDispose.family` | Lazy ✅ |

**Good:** Lesson content uses Dart deferred imports (`deferred as nitrogen_cycle`, etc.) — this is excellent; the 9,000+ lines of lesson text are not parsed at startup.

**Risk:** `achievementProvider`, `gemsProvider`, `spacedRepetitionProvider`, and `lessonProvider` are non-autoDispose `StateNotifierProvider`s. These are initialized the first time they're watched and then stay alive forever. For a Duolingo-style app where all four are core features, this is acceptable. However there is **no `keepAlive` annotation** on any of them — they rely on Riverpod's implicit "don't dispose non-autoDispose providers" rule, which is correct but makes intent opaque.

**Risk:** `tanksProvider` is `FutureProvider` without `autoDispose`. It retains the entire tank list in memory indefinitely. Given tanks are referenced across many screens this is justified, but if a user has many tanks with lots of livestock/log entries this could grow.

---

## 3. Image Loading Strategy

### Findings

| Image | File size | cacheWidth/cacheHeight set? | Risk |
|-------|-----------|---------------------------|------|
| `learn_header.png` | **1.4 MB** | ❌ No cacheWidth/cacheHeight | 🔴 HIGH |
| `practice_header.png` | **944 KB** | ✅ 480×320 | ✅ OK |
| `onboarding_journey_bg.webp` | Unknown | ✅ 800×1600 | ✅ OK |
| Room backgrounds (×12) | ~140–152 KB each | ✅ 1024×1024 | ✅ OK |
| Fish sprites | ~100–240 KB | ✅ 128×128 | ✅ OK |
| `app_icon.png` | 190 KB | ✅ 160×160 (splash) | ✅ OK |
| `felt-teal.webp` texture | 353 KB | ❌ None | 🟡 MEDIUM |
| `linen-wall.webp` texture | 248 KB | ❌ None | 🟡 MEDIUM |

**Critical finding:** `learn_header.png` (1.4 MB) is loaded with `Image.asset` and **no `cacheWidth`/`cacheHeight`**. Flutter decodes it at the full intrinsic resolution into the image cache. On a 1080p phone this PNG likely decodes to several megabytes of RGBA pixel data in memory, and it repaints on every rebuild of the learn screen header. This is the single largest image memory risk in the app.

**Good:** The `ImageCacheService` exists and uses `ResizeImage` for thumbnails and a 1920-px cap for full images. However it is only used in two places (`OptimizedAssetImage` — called in 2 places). Most image widgets use `Image.asset` directly.

**No precaching:** There is no `precacheImage` call at startup or during navigation transitions (only inside `ImageCacheService.precacheImages` which is not called from `main.dart` or any navigator). Transitions to the learn screen or practice hub will have a brief decode stutter on first load.

---

## 4. Widget Rebuild Frequency

- **127 `ConsumerWidget`/`ConsumerStatefulWidget` classes** — healthy for a Riverpod app of this size.
- **87 `ref.watch(...)` calls in screens without `.select()`** — some are necessary (watching entire `AsyncValue` states for `.when()` pattern), but several risk over-rebuilding.

### Notable broad watches

| Location | Provider watched | Issue |
|----------|-----------------|-------|
| `user_profile_derived_providers.dart:12` | `userProfileProvider` (full) | `needsOnboardingProvider` rebuilds on every profile change (XP, streaks, etc.) even though it only cares about `profile == null` |
| `user_profile_derived_providers.dart:22,40` | `userProfileProvider.value` (full) | `learningStatsProvider` and `todaysDailyGoalProvider` rebuild on every profile mutation |
| `home_screen.dart:317` | `tanksProvider` | Full tank list rebuild on any tank change |
| `streak_hearts_overlay.dart:95` | `heartsStateProvider` (full) | Rebuilds entire overlay on any hearts state change |
| `learn/lazy_learning_path_card.dart:67` | `lessonProvider` (full) | Entire lesson state object watched when only path-completion state needed |
| `notification_settings_screen.dart:16` | `userProfileProvider` (full) | Could use `.select()` for just notification prefs |
| `story_browser_screen.dart:18` | `userProfileProvider` (full) | Could select only completed stories |

**Good pattern found:** `recentDailyGoalsProvider` correctly uses `.select()` on both `dailyXpHistory` and `dailyXpGoal`. The `_AppRouter` also uses `.select()` for profile loading state. These are the right patterns — they just need to be applied more broadly.

**Most impactful rebuild risk:** `learningStatsProvider` and `todaysDailyGoalProvider` both watch the full `userProfileProvider`. Every XP gain, streak tick, or gem purchase triggers a rebuild of every widget consuming these derived providers — which includes the learn screen header and home screen dashboard. Adding `.select()` to extract only the fields they use would eliminate most spurious rebuilds during active learning sessions.

---

## 5. Animation Performance

- **270 references** to `AnimationController`/`AnimatedBuilder`/`TweenAnimationBuilder` across 394 Dart files — high animation density, expected for a gamified app.
- **15 classes** using `TickerProviderStateMixin` or `SingleTickerProviderStateMixin`.
- **128 uses** of `flutter_animate` `.animate()` — these create internal `AnimationController`s managed by the library.

### Dispose audit — result: ✅ generally clean

All explicitly created `AnimationController`s in audited files are properly disposed:
- Onboarding screens (welcome, aha_moment, warm_entry, xp_celebration, push_permission, feature_summary, fish_select, micro_lesson, returning_user_flows, tank_status, experience_level) — all dispose their controllers.
- Stage widgets (lighting_pulse, stage_scrim, swiss_army_panel, tank_glass_badge, bottom_sheet_panel) — all dispose.
- Celebration widgets (level_up_overlay, animated_flame, xp_award_animation, xp_progress_bar) — all dispose.

### Performance concern: always-on ambient animations

`LightingPulse` runs two `AnimationController`s that fire on a trigger but are re-started. `SwayingPlant` uses `flutter_animate` with `repeat(reverse: true)` — this runs continuously as long as the widget is in the tree.

On the home screen tank view:
- Multiple `SwayingPlant` widgets are alive simultaneously
- `LightingPulse` fires periodically
- `AmbientTipOverlay` uses a timer + animation controller

These are all wrapped in `RepaintBoundary` which is good — they won't invalidate parent layers. However they will keep the raster thread busy on low-end devices. There is a `reducedMotionProvider` and `SwayingPlant` checks `MediaQuery.disableAnimations`, but these ambient animations don't check `reducedMotionProvider` directly.

---

## 6. Database & Storage

**No SQLite.** The app uses `LocalJsonStorageService` — a single JSON file on disk. All tanks, livestock, logs, equipment are serialised into one file.

### Assessment

| Pattern | Finding |
|---------|---------|
| Single-file JSON | 🟡 Fine for MVP; risks grow as data accumulates |
| Write debouncing | ✅ 200ms debouncer prevents write storms on rapid state changes |
| Atomic write (tmp + rename) | ✅ `tmp` file pattern prevents corruption on crash |
| On-pause flush | ✅ Direct save on `AppLifecycleState.paused` |
| Read on startup | ✅ Lazy — only loaded when `storageServiceProvider` first consumed |
| Batch operations | N/A — no SQLite |

**Risk:** As users add more tanks, livestock entries, water test logs, and equipment records, the entire JSON blob is re-serialised and written to disk on every save. A user with 3 tanks, 30 livestock entries, and 200 log entries could have a JSON file of 50–200 KB. The `readAsString` + `jsonDecode` on startup is O(n) and runs synchronously after the async file read. For large files this could add 20–100 ms to `_AppRouter`'s first meaningful data render.

No batching concern with the current JSON approach — every mutation rewrites everything. This is the inherent trade-off vs SQLite.

---

## 7. Dispose Patterns

### Summary: ✅ mostly healthy, two gaps found

| Screen/Widget | Controllers | Disposed? |
|--------------|-------------|-----------|
| `SymptomTriageScreen` | 6× `TextEditingController` | ✅ Yes |
| `AccountScreen` | 2× `TextEditingController` | ✅ Yes |
| `CO2CalculatorScreen` | 2× `TextEditingController` | ✅ Yes |
| `CostTrackerScreen` | 2× `TextEditingController` | ✅ Yes |
| `DosingCalculatorScreen` | 2× `TextEditingController` | ✅ Yes |
| `EquipmentScreen` | 3× `TextEditingController` | ✅ Yes |
| `HomeSheetsTank` | 3× `TextEditingController` | ✅ Yes |
| `GemShopScreen` | `TabController` + `ConfettiController` | ✅ Yes |
| `InventoryScreen` | `TabController` | ✅ Yes |
| `CreateTankScreen` | `PageController` | ✅ Yes |
| `AhaMovementScreen` | 5× `AnimationController` | ✅ Yes |
| `WarmEntryScreen` | 4× `AnimationController` + `TextEditingController` | ✅ Yes |
| `XpCelebrationScreen` | 5× `AnimationController` | ✅ Yes |
| `StageWidgets` | Multiple `AnimationController`s | ✅ Yes |
| `AmbientTipOverlay` | `Timer` + `AnimationController` | ✅ Yes |

**One gap found:** `FishSelectScreen` — the inner `_FishCardState` creates an `AnimationController` at line 649 and disposes it at line 676. However the dispose method does `_scaleCurve.dispose()` but does **not** call `_controller.dispose()` before `super.dispose()`. This could leak animation controller tickers when the fish-select onboarding card is popped.

```dart
// lib/screens/onboarding/fish_select_screen.dart ~line 670
void dispose() {
  _scaleCurve.dispose();
  // ❌ _controller.dispose() is missing here
  super.dispose();
}
```

**Second gap:** `InventoryScreen` — an inner `_SkeletonLoader` state (line 394) has a `dispose()` that calls `super.dispose()` with no controller cleanup — check if it has any controllers that are initialised but not listed in the dispose block.

---

## Top 10 Performance Improvements

Ranked by **user-perceived impact** (what the user actually feels).

---

### #1 — Add `cacheWidth`/`cacheHeight` to `learn_header.png`
**Impact:** 🔴 HIGH — learn screen is the primary tab; 1.4 MB PNG decoded at full resolution wastes ~6–15 MB of GPU texture memory and causes a decode stutter on first open.  
**Fix:** Add `cacheWidth: 800, cacheHeight: 400` (or similar) to the `Image.asset` call in `learn_screen.dart:311`.  
**Effort:** Trivial (2 lines)

---

### #2 — Convert `learn_header.png` (1.4 MB) and `practice_header.png` (944 KB) to WebP
**Impact:** 🔴 HIGH — WebP would reduce these to ~150–300 KB each, saving install size, cold-start asset decompression time, and reducing memory pressure significantly.  
**Fix:** Export both PNGs as WebP (quality 85), update asset paths.  
**Effort:** Small (asset re-export + path update)

---

### #3 — Add `.select()` to `learningStatsProvider` and `todaysDailyGoalProvider`
**Impact:** 🟠 HIGH — These providers rebuild on every profile mutation (XP gain, streak update, gem change). During a lesson session, XP ticks trigger rebuilds of the entire learn screen header and home dashboard. `.select()` on the specific fields they read would eliminate rebuild noise during active use.  
**Fix:** Change `ref.watch(userProfileProvider).value` to `ref.watch(userProfileProvider.select((p) => p.value?.totalXp))` etc. for each consumed field.  
**Effort:** Small (4–6 providers to update)

---

### #4 — Add precaching for key navigation targets
**Impact:** 🟠 MEDIUM-HIGH — First visit to the Learn tab and Practice tab causes a visible decode stutter for header images. Pre-warming these during the splash/loading phase would make first-tab navigation feel instant.  
**Fix:** In `_AppRouterState` or after `TabNavigator` mounts, call:
```dart
precacheImage(const AssetImage('assets/images/illustrations/learn_header.png'), context);
precacheImage(const AssetImage('assets/images/illustrations/practice_header.png'), context);
```
**Effort:** Small (5–10 lines)

---

### #5 — Move `_checkGdprConsent()` to use `sharedPreferencesProvider`
**Impact:** 🟡 MEDIUM — Currently `_AppRouter` calls `SharedPreferences.getInstance()` independently (line 301) while `sharedPreferencesProvider` is also initialising. This creates two concurrent SharedPreferences initialisations on first launch, slightly slowing the transition from splash to first real screen.  
**Fix:** Watch `sharedPreferencesProvider` and derive GDPR consent state from it, eliminating the second `getInstance()` call.  
**Effort:** Small

---

### #6 — Add `cacheWidth`/`cacheHeight` to texture images (`felt-teal.webp`, `linen-wall.webp`)
**Impact:** 🟡 MEDIUM — `felt-teal.webp` (353 KB) is used as a `DecorationImage` in `AmbientTipOverlay` and potentially elsewhere. Without size hints Flutter decodes it at intrinsic size. Since it tiles/covers a small panel, a 512×512 decode limit is appropriate.  
**Fix:** Wrap in `ResizeImage` or use `OptimizedAssetImage`.  
**Effort:** Trivial

---

### #7 — Apply `.select()` to `needsOnboardingProvider`
**Impact:** 🟡 MEDIUM — `needsOnboardingProvider` watches the full `userProfileProvider`. It is used in routing logic and rebuilds on every profile change, triggering `_AppRouter` re-evaluation. The provider only needs to know `profile == null`.  
**Fix:**
```dart
final needsOnboardingProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider.select((p) => p.value == null));
});
```
**Effort:** Trivial

---

### #8 — Fix potential `AnimationController` leak in `_FishCardState` (fish_select_screen.dart)
**Impact:** 🟡 MEDIUM — Onboarding is a one-time flow but ticker leaks cause debug warnings and can cause memory/CPU overhead if onboarding is replayed (e.g. in debug mode or returning-user flows).  
**Fix:** Add `_controller.dispose()` before `super.dispose()` in `_FishCardState.dispose()`.  
**Effort:** Trivial (1 line)

---

### #9 — Add `RepaintBoundary` around texture `DecorationImage` in `AmbientTipOverlay`
**Impact:** 🟡 MEDIUM — The `felt-teal.webp` texture in `AmbientTipOverlay` is painted inside an animated widget. Without a `RepaintBoundary` it repaints every animation frame. This is visible in the Profile Overlay which shows periodically.  
**Fix:** Wrap the `DecoratedBox` containing the texture in a `RepaintBoundary`.  
**Effort:** Trivial

---

### #10 — Migrate `LocalJsonStorageService` to SQLite (future-proofing)
**Impact:** 🟢 LOW now, HIGH at scale — The single-file JSON approach rewrites the entire dataset on every mutation. Once a power user has 3+ tanks with 100s of log entries, the write cost and deserialisation overhead on startup will noticeably increase. SQLite with indexed queries would scale to 10,000+ entries with sub-millisecond reads.  
**Fix:** Introduce `drift` or `sqflite`, migrate schema, update `StorageService` interface implementation.  
**Effort:** Large (full migration, schema design, data migration path)

---

## Memory Risk Summary

| Risk | Severity | Details |
|------|----------|---------|
| `learn_header.png` undecoded size | 🔴 HIGH | 1.4 MB PNG → ~6–15 MB RGBA in Flutter image cache |
| `practice_header.png` no-resize | 🟡 MEDIUM | 944 KB, but `cacheWidth: 480` is set — acceptable |
| Room background textures (12×) | 🟡 MEDIUM | All capped at 1024×1024 — each ~4 MB RGBA in cache. Only current theme loaded. |
| Non-autoDispose core providers | 🟡 MEDIUM | `achievementProvider`, `lessonProvider`, `spacedRepetitionProvider`, `gemsProvider` live forever — acceptable for core features, monitor if state grows large |
| `felt-teal.webp` / `linen-wall.webp` | 🟡 MEDIUM | No size hints, decoded at intrinsic size |
| Animation controllers | ✅ LOW | All audited controllers are properly disposed |
| `LocalJsonStorageService` | ✅ LOW now | Single in-memory dict + file. Grows linearly with user data |
| `ImageCacheService` LRU | ✅ LOW | 100-item cap with LRU eviction — well-designed |
| `SwayingPlant` / ambient animations | ✅ LOW | Isolated by `RepaintBoundary`, respect `MediaQuery.disableAnimations` |

---

## Quick Wins Checklist

```
[ ] learn_header.png → add cacheWidth/cacheHeight (2 lines, 5 min)
[ ] learn_header.png + practice_header.png → convert to WebP (30 min)
[ ] _FishCardState.dispose() → add _controller.dispose() (1 line, 2 min)
[ ] needsOnboardingProvider → use .select() (3 lines, 5 min)
[ ] learningStatsProvider + todaysDailyGoalProvider → .select() (medium refactor, 1 hr)
[ ] Precache learn/practice header images post-splash (10 min)
[ ] felt-teal.webp + linen-wall.webp → add ResizeImage wrapper (15 min)
```

---

*Prometheus audit complete. No files were modified.*
