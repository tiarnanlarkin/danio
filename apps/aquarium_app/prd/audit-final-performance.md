# Danio — Final Performance & Code Quality Audit
**Date:** 2026-03-15  
**Scope:** `lib/` — 323 Dart files  
**Auditor:** Athena (automated static analysis)  
**Status:** READ-ONLY — no files were modified

---

## Executive Summary

The codebase is in **good overall shape** for a Flutter app of this complexity. The team has clearly invested in performance: RepaintBoundaries on animated scenes, debounced saves, lazy-loaded lesson content, ListView.builder in settings, and `.select()` on hot providers. The issues found are mostly P2 (medium) with a few P1 exceptions. **No P0 issues** were found. The biggest wins are resolving the legacy `lesson_content.dart` import and adding RepaintBoundary to a few animation widgets.

---

## Findings

### 1. Unnecessary Rebuilds

---

**[PERF-001] `heartsStateProvider` rebuilds entire HUD on every profile save**
- **File:** `lib/providers/hearts_provider.dart:52`, `lib/widgets/hearts_widgets.dart`
- **Severity:** P1
- **Impact:** `heartsStateProvider` watches `ref.watch(userProfileProvider).value` — a full `UserProfile`. Every XP gain, streak update, or lesson completion triggers a full `HeartsState` recompute and re-render of the entire hearts HUD, even when `hearts` didn't change.
- **Suggested fix:**
  ```dart
  final heartsStateProvider = Provider<HeartsState>((ref) {
    final hearts = ref.watch(userProfileProvider.select((a) => a.value?.hearts));
    final service = ref.watch(heartsServiceProvider);
    return HeartsState.fromProfile(hearts, service);
  });
  ```
  Or use a dedicated `userHeartsProvider` that selects only `profile.hearts`.

---

**[PERF-002] `_HUDWidget` (home_screen) watches full `heartsStateProvider` for a single boolean**
- **File:** `lib/screens/home/home_screen.dart:1849`
- **Severity:** P2
- **Impact:** The widget only uses `hearts.currentHearts <= 1`. The full `HeartsState` struct is watched, causing rebuilds whenever `timeUntilNextRefill` ticks.
- **Suggested fix:**
  ```dart
  final lowHearts = ref.watch(heartsStateProvider.select((s) => s.currentHearts <= 1));
  ```

---

**[PERF-003] `_WaterChangeStreakBanner` watches full `tanksProvider` to get one tank ID**
- **File:** `lib/screens/home/home_screen.dart:1922`
- **Severity:** P2
- **Impact:** `ref.watch(tanksProvider).value ?? []` — rebuilds when _any_ tank in the list changes (add, delete, reorder). Only needs the first tank's ID.
- **Suggested fix:**
  ```dart
  final firstTankId = ref.watch(tanksProvider.select((a) => a.value?.firstOrNull?.id));
  if (firstTankId == null) return const SizedBox.shrink();
  ```

---

**[PERF-004] Multiple widgets watching full `userProfileProvider` for a single field**
- **Files:** `lib/widgets/hearts_widgets.dart` (×4 widgets), `lib/widgets/streak_calendar.dart`, `lib/screens/practice_hub_screen.dart`, `lib/screens/settings_hub_screen.dart`, `lib/screens/workshop_screen.dart`
- **Severity:** P2
- **Impact:** These widgets each call `ref.watch(userProfileProvider).value` to read 1–3 fields. Every profile save (debounced to 200ms) rebuilds all of them.
- **Pattern seen (good example to copy):** `xp_progress_bar.dart` and `gamification_dashboard.dart` already use `.select()` correctly.
- **Suggested fix:** Replace `ref.watch(userProfileProvider).value` with targeted selects:
  ```dart
  // Instead of:
  final profile = ref.watch(userProfileProvider).value;
  final streak = profile?.currentStreak ?? 0;
  
  // Do:
  final streak = ref.watch(userProfileProvider.select((a) => a.value?.currentStreak ?? 0));
  ```

---

### 2. Missing `const` Constructors

---

**[CONST-001] ~163 `SizedBox()` calls missing `const`**
- **Files:** Widespread — `analytics_screen.dart`, `lesson_screen.dart`, `create_tank_screen.dart`, `spaced_repetition_practice_screen.dart`, `tank_detail_screen.dart`, and many more.
- **Severity:** P2
- **Impact:** Each non-const `SizedBox()` allocates a new object on every rebuild. `SizedBox(width: AppSpacing.sm2)` cannot be `const` because `AppSpacing.sm2` is a `static const double` — but only if the call site uses `const SizedBox(width: AppSpacing.sm2)`.
- **Note:** `AppSpacing` constants need to be verified as compile-time `const`. If they are (which they appear to be from `app_theme.dart`), these can all be `const`.
- **Suggested fix:** Run `flutter analyze` with `prefer_const_constructors` lint rule enabled; use `dart fix --apply` to batch-fix eligible widgets.

---

**[CONST-002] ~192 `Icon(Icons.xxx)` calls missing `const`**
- **Files:** Widespread
- **Severity:** P2
- **Impact:** Minor allocation pressure on each rebuild. `Icons.*` members are `const`, so `Icon(Icons.close)` can always be `const Icon(Icons.close)`.
- **Suggested fix:** Same as CONST-001 — dart fix handles this automatically.

---

### 3. Heavy Build Methods

---

**[BUILD-001] `_buildLivingRoomScreen()` in `home_screen.dart` — 441 lines**
- **File:** `lib/screens/home/home_screen.dart:246–687`
- **Severity:** P1
- **Impact:** This is a single method that builds the entire living room UI: tank tiles, FAB, overlays, tip banners, theme picker, etc. It's not a `build()` method itself but is called directly from `build()`, so it runs on every state change. It contains inline anonymous `Builder`/`Consumer` widgets which are the right pattern, but the method itself is unmaintainably large and any mistake risks a full-screen rebuild.
- **Suggested fix:** Extract into clearly named private widgets:
  - `_TankCarousel` (tank switcher + tiles)
  - `_RoomControlFAB`
  - `_DailyNudgeBanner`
  - `_WelcomeBanner`
  Each becomes a `ConsumerWidget` watching only its specific slice.

---

**[BUILD-002] `_buildWaterTestForm()` in `add_log_screen.dart` — 378 lines**
- **File:** `lib/screens/add_log_screen.dart:349–726`
- **Severity:** P1
- **Impact:** A single method building the full water parameter form. Any form field change triggers a `setState` which re-runs all 378 lines. This includes rebuilding ~12 separate form fields, sliders, and validation logic.
- **Suggested fix:** Extract each parameter row (pH, ammonia, nitrite, etc.) into stateless `_WaterParamRow` widgets. They don't need to rebuild when an unrelated field changes.

---

**[BUILD-003] `learn_screen.dart` main `build()` — 318 lines**
- **File:** `lib/screens/learn_screen.dart:140–457`
- **Severity:** P2
- **Impact:** Technically split across helpers, but the main `build()` directly assembles a large widget tree with several `ref.watch` calls. Any provider change rebuilds the entire 318-line method. The `userProfileProvider` watch at line 141 (full watch, not `.select()`) is the main trigger.
- **Suggested fix:** Already partially extracted to sub-widgets. Fix the `ref.watch(userProfileProvider)` to `.select()` for the specific fields needed (e.g. `completedLessons`, `experienceLevel`).

---

**[BUILD-004] `livestock_screen.dart` main `build()` — 478 lines**
- **File:** `lib/screens/livestock_screen.dart:63–540`
- **Severity:** P2
- **Impact:** A single `build()` method that handles loading states, filter chips, search bar, the species selector dialog trigger, and the main list. It's a `ConsumerWidget` so the entire 478-line tree rebuilds whenever `livestockProvider` or the local `_searchQuery` state changes.
- **Suggested fix:** Extract the filter bar, search field, and list into separate stateful sub-widgets so only the affected section rebuilds on a search keystroke.

---

### 4. Animation Performance

---

**[ANIM-001] `LightingPulseWrapper` applies `ColorFiltered` to the entire room scene without `RepaintBoundary`**
- **File:** `lib/widgets/stage/lighting_pulse.dart:72`
- **Severity:** P1
- **Impact:** `AnimatedBuilder` wraps the entire `LivingRoomScene` in a `ColorFiltered` during panel transitions. `ColorFiltered` forces the compositor to re-rasterize every pixel of the room scene (a complex layered scene with painters, textures, and ambient animations) on every animation frame (60fps for 800ms). There is no `RepaintBoundary` isolating the room scene from this wrapper.
- **Context:** The `RepaintBoundary` at `home_screen.dart:325` wraps `LightingPulseWrapper`, which means the boundary is _outside_ the animation — not between the pulse and the room content. This still forces a full re-raster of the room scene interior on every frame of the pulse.
- **Suggested fix:** Use `AnimatedOpacity` on a separate colour overlay _on top of_ the room scene rather than `ColorFiltered` wrapping the scene:
  ```dart
  Stack(
    children: [
      widget.child, // room scene — never repaints for the pulse
      AnimatedOpacity(
        opacity: warmValue,
        child: Container(color: DanioMaterials.warmAmberPulse.withAlpha(20)),
      ),
    ],
  )
  ```

---

**[ANIM-002] `SparkleEffect` in `achievement_card.dart` — no `RepaintBoundary`**
- **File:** `lib/widgets/achievement_card.dart:243`, `lib/widgets/effects/sparkle_effect.dart`
- **Severity:** P2
- **Impact:** `SparkleEffect` uses an `AnimatedBuilder` + `CustomPaint` that repaints at 60fps while active. When used in the achievements grid (`SliverGrid`), multiple sparkle effects can run simultaneously with no repaint isolation, causing the entire grid to mark dirty.
- **Suggested fix:** Wrap the `AnimatedBuilder` inside `SparkleEffect` in a `RepaintBoundary`:
  ```dart
  Positioned.fill(
    child: RepaintBoundary(
      child: IgnorePointer(
        child: AnimatedBuilder(...),
      ),
    ),
  )
  ```

---

**[ANIM-003] `ShimmerGlow` — no `RepaintBoundary`**
- **File:** `lib/widgets/effects/shimmer_glow.dart`
- **Severity:** P2
- **Impact:** `ShimmerGlow` runs a continuous 2-second shimmer animation. It's used on newly unlocked achievement cards. Without `RepaintBoundary`, the shimmer repaints can propagate to sibling widgets in the achievements list.
- **Suggested fix:** Add `RepaintBoundary` wrapping the shimmer `Stack` child.

---

**[ANIM-004] `Opacity()` used inside `AnimatedBuilder` builders (should be `FadeTransition`)**
- **Files:** `lib/widgets/celebrations/streak_milestone_celebration.dart:146`, `lib/widgets/celebrations/water_change_celebration.dart:171`, `lib/widgets/celebrations/streak_milestone_listener.dart:157`
- **Severity:** P2
- **Impact:** Using `Opacity(opacity: animValue)` inside an `AnimatedBuilder` forces a raster-thread composite on every frame. Flutter's `FadeTransition` widget uses the engine's layer opacity which is GPU-free.
- **Suggested fix:**
  ```dart
  // Instead of:
  Opacity(opacity: _fade.value, child: child)
  
  // Use:
  FadeTransition(opacity: _fade, child: child)
  ```
  This applies to all three celebration widgets.

---

**[ANIM-005] `MaskFilter.blur` in `_drawSparkle` called every frame**
- **File:** `lib/widgets/effects/sparkle_effect.dart:221`
- **Severity:** P2
- **Impact:** `canvas.drawCircle` with `MaskFilter.blur(BlurStyle.normal, 4)` is called for each active sparkle particle on every animation frame. Gaussian blur on the raster thread is expensive, especially with 8 particles × 60fps.
- **Suggested fix:** Pre-bake the glow as a `ui.Image` in `initState` (one-time cost) and `drawImage` it per frame, or remove the blur glow and use a simple alpha circle instead. Also present in `daily_goal_progress.dart:141` and `level_up_overlay.dart:680`.

---

**[ANIM-006] `ShimmerEffect` in `sparkle_effect.dart` uses `ShaderMask` on every frame**
- **File:** `lib/widgets/effects/sparkle_effect.dart:298`
- **Severity:** P2
- **Impact:** `ShaderMask` with a custom `GradientTransform` is computed on every animation frame. `ShaderMask` creates a new compositor layer and shader program every frame.
- **Suggested fix:** Use the same approach as `shimmer_glow.dart` (gradient `Container` overlay) which avoids `ShaderMask` entirely.

---

### 5. Memory Leaks

---

**[LEAK-001] No confirmed leaks — all controllers/timers properly disposed**
- **Finding:** All reviewed `AnimationController`, `TextEditingController`, `Timer`, and `Timer.periodic` instances have corresponding `.dispose()` and `.cancel()` calls. The `XpAnimationService` stream subscription (`_subscription`) is correctly cancelled in dispose. `AmbientTimeService` `Timer.periodic` is cancelled on dispose. All good.

---

**[LEAK-002] Potential minor: `ref.listen` in `_WaterChangeStreakBanner.build()` called on every rebuild**
- **File:** `lib/screens/home/home_screen.dart:1928`
- **Severity:** P2 (low risk — Riverpod deduplicates listeners, but it's a code smell)
- **Impact:** `ref.listen(...)` is called inside `build()`. While Riverpod handles this correctly, calling `listen` in `build` is explicitly discouraged in Riverpod docs (it should be in `initState` or `ConsumerStateful`). On each widget rebuild a new listener subscription is registered and the old one removed — minor overhead.
- **Suggested fix:** Move the `ref.listen` block to a `ConsumerStatefulWidget`'s `initState` or use `ref.listen` in a parent widget.

---

### 6. Image/Asset Loading

---

**[IMG-001] Good — `OptimizedAssetImage` and `OptimizedNetworkImage` are used correctly**
- `memCacheWidth` / `memCacheHeight` / `cacheWidth` / `cacheHeight` are set based on `devicePixelRatio`.
- `CachedNetworkImage` used for all network images.
- No `Image.network()` calls found.

---

**[IMG-002] `Image.asset()` in `journey_reveal_screen.dart` — no cache sizing**
- **File:** `lib/screens/onboarding/journey_reveal_screen.dart:84`
- **Severity:** P2
- **Impact:** `Image.asset(...)` called without `cacheWidth`/`cacheHeight`. The image is decoded at full native resolution and held in the image cache. For an onboarding screen this is minor, but still inconsistent with the rest of the app.
- **Suggested fix:** Use `OptimizedAssetImage` widget, or add `cacheWidth`/`cacheHeight`.

---

**[IMG-003] `linen-wall.webp` texture in `room_scene.dart` — correctly sized at 256×256**
- **Finding:** The texture is loaded with `cacheWidth: 256, cacheHeight: 256`. This is good. No issue.

---

### 7. List Performance

---

**[LIST-001] `Column(children: list.map())` in `lesson_screen.dart` — unbounded lists**
- **File:** `lib/screens/lesson_screen.dart:455–480` (two occurrences)
- **Severity:** P2
- **Impact:** `Column(children: items.map(...).toList())` renders all items eagerly. In a lesson with many content items (images, text blocks, callouts), all are built upfront even if not visible.
- **Suggested fix:** The items are inside a `SingleChildScrollView` — replace with `SliverList(delegate: SliverChildBuilderDelegate(...))` inside a `CustomScrollView`, or at minimum use `ListView(children: ...)` which still allocates all items but at least provides proper scroll physics.

---

**[LIST-002] `Column(children: path.lessons.map())` in `learn_screen.dart`**
- **File:** `lib/screens/learn_screen.dart:1064`
- **Severity:** P2
- **Impact:** Each `ExpansionTile` expands to show all lessons for a path via `Column(children: lessons.map(...))`. A path with 10+ lessons renders all at once. The surrounding `CustomScrollView` with `SliverList` is efficient, but the expanded children are not.
- **Suggested fix:** The expanded lesson list is typically ≤10 items, so this is low priority. If paths grow, consider `SliverList` inside the `ExpansionTile` content.

---

**[LIST-003] `Column(children: _suggestions.map())` in `livestock_screen.dart`**
- **File:** `lib/screens/livestock_screen.dart:973`
- **Severity:** P2
- **Impact:** Compatibility suggestions are rendered in a Column inside a bottom sheet. Typically ≤5 items, so impact is negligible. Low priority.

---

**[LIST-004] Settings screen correctly uses `ListView.builder` — GOOD**
- **Finding:** `settings_screen.dart` was previously flagged as a performance issue. It now uses `ListView.builder` with lazy `WidgetBuilder` callbacks. Verified correct.

---

### 8. Provider Patterns

---

**[PROV-001] `lesson_content.dart` (4,979 lines / ~212KB) still imported at startup by 3 screens**
- **Files:** `lib/screens/placement_test_screen.dart:10`, `lib/screens/placement_result_screen.dart:10`, `lib/screens/onboarding/enhanced_placement_test_screen.dart:11`
- **Severity:** P1
- **Impact:** This file imports the entire legacy `LessonContent` class with all learning paths eagerly loaded as `static final` objects. The file's own comment says "⚠️ LEGACY FILE - 212KB startup cost". All three importing screens are navigated to only after onboarding or on explicit user tap — yet because Dart's `import` is static, the entire class definition is loaded into memory when the app starts.
- **Context:** `lesson_content_lazy.dart` and `LessonProvider` already exist as the replacement. The migration just hasn't been completed.
- **Suggested fix:** Migrate `placement_test_screen.dart`, `placement_result_screen.dart`, and `enhanced_placement_test_screen.dart` to use `lessonContentLazy.loadPath(pathId)` or `ref.watch(lessonProvider)`. Then delete `lesson_content.dart`.
- **Estimated savings:** ~212KB RAM freed at startup; faster cold start.

---

**[PROV-002] `tanksProvider` missing `autoDispose` — global app-wide provider**
- **File:** `lib/providers/tank_provider.dart:60`
- **Severity:** P2 (acceptable trade-off for global data)
- **Impact:** `tanksProvider` is a `FutureProvider` without `autoDispose`. It stays alive for the entire app lifecycle. This is intentional for frequently-accessed data, but it means the tank list is never freed from memory even when no screen needs it (e.g. while on the Learn screen).
- **Suggested fix:** This is a deliberate trade-off and acceptable given tanks are used on the home screen (always visible). Leave as-is, but document the intentionality.

---

**[PROV-003] Global `StateNotifierProvider` providers missing `autoDispose` — acceptable for app-global state**
- **Files:** `gemsProvider`, `achievementProgressProvider`, `spacedRepetitionProvider`, `friendsProvider`
- **Severity:** P2 (intentional design — these are app-global state)
- **Impact:** These providers hold state that must persist across screen navigations (gems balance, achievement progress, spaced repetition state). Not having `autoDispose` is correct here. No action needed.

---

**[PROV-004] `heartStateProvider` computes `timeUntilNextRefill` on every rebuild**
- **File:** `lib/providers/hearts_provider.dart:52`
- **Severity:** P2
- **Impact:** `HeartsState.fromProfile()` calls `service.getTimeUntilNextRefill(profile)` on every profile change. If this involves any `DateTime` arithmetic (which it does), this is cheap but runs on the UI thread. More importantly it means `heartsStateProvider` produces a new `HeartsState` instance whenever any profile field changes — not just hearts. See PERF-001.

---

**[PROV-005] `filteredAchievementsProvider` is a `Provider` without `autoDispose`**
- **File:** `lib/providers/achievement_provider.dart:394`
- **Severity:** P2
- **Impact:** Derives the entire filtered achievement list from `achievementProgressProvider`. Since achievement data is large (~50+ achievements × their progress), keeping this computed and in memory at all times is a minor memory overhead. Not critical, but could be `autoDispose` since the achievements screen is visited occasionally.

---

### 9. Startup Performance

---

**[STARTUP-001] Good — Firebase, Supabase, Notifications deferred to `addPostFrameCallback`**
- **Finding:** `main()` correctly defers all heavy init (Firebase, Supabase, NotificationService) to `WidgetsBinding.instance.addPostFrameCallback`. The splash screen renders before any of these await. This is the correct pattern.

---

**[STARTUP-002] `GoogleFonts.config.allowRuntimeFetching = false` — GOOD**
- **Finding:** Runtime font fetching is disabled. Fonts are bundled. No startup network fetch for fonts.

---

**[STARTUP-003] `lesson_content.dart` loaded at startup via static imports (see PROV-001)**
- **File:** `lib/data/lesson_content.dart`
- **Severity:** P1 (cross-reference with PROV-001)
- **Impact:** Even though the screens that import it aren't navigated to immediately, Dart loads all `static final` fields in a class lazily (first access). However, the import itself means the class definition is loaded. The ~212KB of lesson content objects are initialized when first accessed. If `PlacementTestScreen` is visited during onboarding (it is for many users), this causes a ~200ms jank spike as 4,979 lines of lesson data is parsed.

---

**[STARTUP-004] `HeartService.checkAndApplyAutoRefill()` called on every `AppLifecycleState.resumed`**
- **File:** `lib/main.dart:190`
- **Severity:** P2
- **Impact:** Every time the app comes to foreground, this runs synchronously (or near-synchronously). If `checkAndApplyAutoRefill` does I/O (reads SharedPreferences), this could block the UI thread briefly on resume.
- **Suggested fix:** Verify `HeartsService.checkAndApplyAutoRefill()` is async and uses `compute` or is non-blocking. If it reads SharedPreferences, wrap in `unawaited()` or move to a microtask.

---

**[STARTUP-005] `_scheduleReviewNotifications()` runs on first build and every resume**
- **File:** `lib/main.dart:200–215`
- **Severity:** P2
- **Impact:** This reads `spacedRepetitionProvider` and schedules a notification on every app resume. While the notification service is presumably idempotent, it means every resume invokes the platform notification channel. Lightweight, but worth noting.

---

### 10. SharedPreferences

---

**[PREF-001] `userProfileProvider` has 200ms debounced save — GOOD**
- **Finding:** A `Debouncer(delay: 200ms)` is used for all incremental saves. Critical saves (profile deletion, XP awards from store) use `_saveImmediate()`. Pattern is correct.

---

**[PREF-002] `UserProfile.toJson()` serialises full object including `dailyXpHistory` Map**
- **File:** `lib/providers/user_profile_provider.dart:78`
- **Severity:** P2
- **Impact:** Every debounced save serialises the full `UserProfile` including `dailyXpHistory` (a map of date-strings to XP ints). As the user accumulates history over months/years, this map grows unboundedly. Each save encodes and writes the full blob to SharedPreferences.
- **Suggested fix:** Cap `dailyXpHistory` to the last 90 days on save:
  ```dart
  final cutoff = DateTime.now().subtract(const Duration(days: 90));
  final trimmedHistory = Map.fromEntries(
    profile.dailyXpHistory.entries.where(
      (e) => DateTime.tryParse(e.key)?.isAfter(cutoff) ?? false,
    ),
  );
  ```

---

**[PREF-003] `achievementProgressProvider` saves on every achievement check**
- **File:** `lib/providers/achievement_provider.dart:66–73`
- **Severity:** P2
- **Impact:** Achievement checks run after every lesson completion, XP gain, etc. Each check may trigger a `prefs.setString(_key, jsonEncode(toSave))` write if any progress changed. For a user with 50 achievements, this blob could be 10–20KB and is written multiple times in quick succession.
- **Suggested fix:** Add a debounce (even 500ms) to achievement saves, similar to `userProfileProvider`'s debouncer. Or batch: write once after all checks complete for a session.

---

**[PREF-004] `settings_provider.dart` — each setting change creates a new `SharedPreferences.getInstance()` call**
- **File:** `lib/providers/settings_provider.dart:92–134`
- **Severity:** P2 (minor — `getInstance()` is cached internally by the plugin)
- **Impact:** Each setter (`setThemeMode`, `setUseMetric`, etc.) calls `await SharedPreferences.getInstance()` independently. The SharedPreferences plugin caches the instance internally so this is an async-but-cheap call. Low priority.
- **Suggested fix:** Cache the `prefs` instance on first load as a field, reuse on writes.

---

**[PREF-005] `friends_provider.dart` — 3 separate SharedPreferences blobs (friends, activities, encouragements)**
- **File:** `lib/providers/friends_provider.dart:75–290`
- **Severity:** P2
- **Impact:** Friends data is split across 3 separate `setString` keys. Each blob is written independently when its respective data changes. In an active social session this could be 3 writes in quick succession.
- **Suggested fix:** Acceptable for now. If friends feature scales, consider consolidating into one JSON blob or migrating to SQLite.

---

## Summary Table

| ID | Area | File(s) | Severity | Impact | Fix Complexity |
|----|------|---------|----------|--------|----------------|
| PERF-001 | Rebuilds | `hearts_provider.dart` | **P1** | HUD rebuilds on every XP gain | Low — add `.select()` |
| PERF-002 | Rebuilds | `home_screen.dart:1849` | P2 | Unnecessary HeartsState subscription | Low |
| PERF-003 | Rebuilds | `home_screen.dart:1922` | P2 | Banner rebuilds on any tank change | Low |
| PERF-004 | Rebuilds | `hearts_widgets.dart`, 5 other screens | P2 | Full profile watch for 1 field | Low |
| CONST-001 | const | ~163 SizedBox calls | P2 | Minor allocation churn | Trivial (dart fix) |
| CONST-002 | const | ~192 Icon calls | P2 | Minor allocation churn | Trivial (dart fix) |
| BUILD-001 | Build size | `home_screen.dart:246–687` | **P1** | 441-line method, hard to maintain | Medium |
| BUILD-002 | Build size | `add_log_screen.dart:349–726` | **P1** | 378-line form method, all rebuilds on state | Medium |
| BUILD-003 | Build size | `learn_screen.dart:140–457` | P2 | 318-line build with unnecessary full watch | Low |
| BUILD-004 | Build size | `livestock_screen.dart:63–540` | P2 | 478-line build rebuilds on search | Medium |
| ANIM-001 | Animation | `lighting_pulse.dart` | **P1** | ColorFiltered re-rasterizes full room at 60fps | Medium |
| ANIM-002 | Animation | `achievement_card.dart`, `sparkle_effect.dart` | P2 | No RepaintBoundary on sparkle animation | Low |
| ANIM-003 | Animation | `shimmer_glow.dart` | P2 | No RepaintBoundary on shimmer | Low |
| ANIM-004 | Animation | 3 celebration widgets | P2 | `Opacity()` in builder (prefer FadeTransition) | Low |
| ANIM-005 | Animation | `sparkle_effect.dart:221` | P2 | `MaskFilter.blur` per-frame per-particle | Medium |
| ANIM-006 | Animation | `sparkle_effect.dart:298` | P2 | ShaderMask per frame | Medium |
| LEAK-001 | Memory | — | ✅ OK | All controllers disposed correctly | — |
| LEAK-002 | Memory | `home_screen.dart:1928` | P2 | `ref.listen` in build() (code smell) | Low |
| IMG-001 | Images | — | ✅ OK | All network/asset images correctly sized | — |
| IMG-002 | Images | `journey_reveal_screen.dart:84` | P2 | Missing cache sizing on asset | Trivial |
| LIST-001 | Lists | `lesson_screen.dart` | P2 | Column(map()) for lesson content blocks | Medium |
| LIST-002 | Lists | `learn_screen.dart:1064` | P2 | Column(map()) for expanded lesson list | Low |
| LIST-003 | Lists | `livestock_screen.dart:973` | P2 | Column(map()) for suggestions | Low priority |
| PROV-001 | Providers | 3 screens import `lesson_content.dart` | **P1** | 212KB legacy file loaded at startup | Medium |
| PROV-002 | Providers | `tank_provider.dart:60` | P2 | `tanksProvider` no autoDispose (intentional) | — |
| PROV-003 | Providers | Global providers | P2 | Missing autoDispose (intentional) | — |
| PROV-004 | Providers | `hearts_provider.dart` | P2 | `timeUntilNextRefill` recalculated on all profile changes | Low |
| PROV-005 | Providers | `achievement_provider.dart:394` | P2 | Filtered achievements always in memory | Low |
| STARTUP-001 | Startup | `main.dart` | ✅ OK | Firebase/Supabase deferred correctly | — |
| STARTUP-003 | Startup | `lesson_content.dart` | **P1** | (see PROV-001) | — |
| STARTUP-004 | Startup | `main.dart:190` | P2 | `checkAndApplyAutoRefill` on every resume | Low |
| PREF-001 | SharedPrefs | `user_profile_provider.dart` | ✅ OK | Debounced saves correctly implemented | — |
| PREF-002 | SharedPrefs | `user_profile_provider.dart:78` | P2 | `dailyXpHistory` grows unbounded | Low |
| PREF-003 | SharedPrefs | `achievement_provider.dart:66` | P2 | Achievement saves on every check, no debounce | Low |
| PREF-004 | SharedPrefs | `settings_provider.dart` | P2 | `getInstance()` per setter (harmless) | Low |
| PREF-005 | SharedPrefs | `friends_provider.dart` | P2 | 3 separate blobs written independently | Low |

---

## Priority Order for Fixes

### Fix first (P1 — measurable user impact):
1. **PROV-001 + STARTUP-003** — Migrate 3 screens off `lesson_content.dart`. Free 212KB RAM, faster cold start for new users going through placement test.
2. **ANIM-001** — `LightingPulseWrapper`: Change `ColorFiltered` to overlay approach. Prevents full-scene rasterization at 60fps during panel open/close.
3. **PERF-001** — `heartsStateProvider`: Use `.select()` so hearts HUD doesn't rebuild on every XP gain.
4. **BUILD-001** — Extract `_buildLivingRoomScreen()` into sub-widgets. Biggest maintainability win.
5. **BUILD-002** — Extract `_buildWaterTestForm()` into per-parameter widgets. Prevents full form rebuild on each keystroke.

### Fix next (P2 — quality/maintainability):
6. **CONST-001 + CONST-002** — Run `dart fix --apply` for const constructors. Automated, zero risk.
7. **ANIM-002 + ANIM-003** — Add `RepaintBoundary` to `SparkleEffect` and `ShimmerGlow`.
8. **ANIM-004** — Replace `Opacity()` in animation builders with `FadeTransition`.
9. **PERF-002 + PERF-003 + PERF-004** — Targeted `.select()` fixes across HUD and profile watchers.
10. **PREF-002** — Cap `dailyXpHistory` to 90 days on save.

### Low priority (P2 — polish):
11. **ANIM-005 + ANIM-006** — Pre-bake sparkle glow, replace `ShimmerEffect` `ShaderMask`.
12. **BUILD-003 + BUILD-004** — Extract learn/livestock sub-widgets.
13. **LIST-001 + LIST-002** — Consider lazy rendering for lesson content blocks.
14. **LEAK-002** — Move `ref.listen` from `build()` to `initState`.
15. **IMG-002** — Add cache sizing to onboarding image.
16. **PREF-003** — Debounce achievement saves.

---

## What's Already Good ✅

The following are commonly problematic but correctly handled in Danio:

- **RepaintBoundary** on ambient bubbles (`AmbientBubbles` widget) ✅
- **RepaintBoundary** on the room scene in `home_screen.dart:325` ✅
- **RepaintBoundary** on `swaying_plant.dart` ✅
- **`shouldRepaint` returning false** when data unchanged on all 4 custom painters ✅
- **Debounced saves** in `userProfileProvider` (200ms debouncer) ✅
- **`autoDispose.family`** on all per-tank providers (livestock, logs, equipment) ✅
- **`.select()`** used in `xp_progress_bar.dart`, `gamification_dashboard.dart`, `tab_navigator.dart` ✅
- **`ListView.builder`** in settings screen (previously a known ANR cause, now fixed) ✅
- **No `Image.network()` calls** — all network images use `CachedNetworkImage` ✅
- **All timers and animation controllers disposed** — no leaks found ✅
- **Firebase/Supabase/Notifications deferred** to post-first-frame ✅
- **`GoogleFonts.config.allowRuntimeFetching = false`** ✅
- **Reduced motion respected** in all animation widgets ✅
