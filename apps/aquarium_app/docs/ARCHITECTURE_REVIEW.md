# Danio Architecture Review
Date: 2026-02-28

## Architecture Map

```
┌─────────────────────────────────────────────────────────────────┐
│                        main.dart                                │
│  ErrorBoundary → ProviderScope → AquariumApp → _AppRouter       │
│  (onboarding check → ProfileCreation or TabNavigator)           │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                     TabNavigator (5 tabs)                       │
│  IndexedStack + per-tab Navigator keys (preserves state)        │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────────┐             │
│  │Learn │ │Quiz  │ │Tank  │ │Smart │ │Settings  │             │
│  │Screen│ │Hub   │ │(Home)│ │Screen│ │Hub       │             │
│  └──┬───┘ └──┬───┘ └──┬───┘ └──┬───┘ └──┬───────┘             │
│     │        │        │        │        │                      │
│   82 screens pushed via imperative Navigator.push               │
└─────────────────────────────────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│               State Management (Riverpod)                       │
│  15 provider files │ StateNotifier pattern dominant              │
│  SharedPreferences for persistence (profile, settings, SR, etc.)│
│  LocalJsonStorageService for tank/livestock/equipment/logs       │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                     Data Layer                                  │
│  ┌──────────────┐  ┌────────────────┐  ┌────────────────────┐  │
│  │SharedPrefs   │  │LocalJSON file  │  │Supabase (optional) │  │
│  │(settings,    │  │(tanks, logs,   │  │(cloud sync, auth)  │  │
│  │ profile, SR) │  │ livestock,     │  │                    │  │
│  │              │  │ equipment,     │  │                    │  │
│  │              │  │ tasks)         │  │                    │  │
│  └──────────────┘  └────────────────┘  └────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                  Static Data (Compiled In)                      │
│  lesson_content.dart (4917 lines) │ species_database (3004)     │
│  stories (1522) │ plant_database (1286) │ shop_catalog, etc.    │
│  Total static data: ~12,000+ lines compiled into binary         │
└─────────────────────────────────────────────────────────────────┘
```

**Codebase Stats:** 299 Dart files, ~128,000 lines of code, 82 screens, 68 widgets, 28 services, 15 providers, 26 models.

---

## State Management Assessment

### Provider Architecture

| Provider | Type | Lines | Assessment |
|----------|------|-------|------------|
| `userProfileProvider` | `StateNotifierProvider<..., AsyncValue<UserProfile?>>` | 932 | ⚠️ **God provider** — handles profile, XP, streaks, daily goals, lesson progress, gems, inventory actions. Should be split into focused providers. |
| `spacedRepetitionProvider` | `StateNotifierProvider<..., SpacedRepetitionState>` | 705 | ✅ Appropriate type, well-scoped to SR domain. Custom state class is clean. |
| `achievementProgressProvider` | Provider (computed) | 492 | ✅ Good use of derived provider. But achievement checker does heavy reads. |
| `tankProvider` (tanksProvider) | `FutureProvider` | 434 | ✅ Good — async loading from storage, correct type. Soft-delete pattern is clever. |
| `lessonProvider` | `StateNotifierProvider` | 416 | ✅ **Excellent** — lazy-loads lesson content via deferred imports. Good perf win. |
| `inventoryProvider` | `StateNotifierProvider<..., AsyncValue<List<InventoryItem>>>` | 388 | ⚠️ Reaches into gems, hearts, and profile providers — tight coupling. |
| `gemsProvider` | `StateNotifierProvider<..., AsyncValue<GemsState>>` | 349 | ✅ Good encapsulation. Has derived `gemBalanceProvider` and `recentGemTransactionsProvider`. |
| `wishlistProvider` | StateNotifier | 293 | ✅ Clean, self-contained. |
| `friendsProvider` | `StateNotifierProvider<..., AsyncValue<List<Friend>>>` | 279 | ⚠️ Uses mock data — expected for MVP. |
| `reducedMotionProvider` | StateNotifier | 189 | ✅ Good accessibility pattern. Respects system + user override. |
| `settingsProvider` | `StateNotifierProvider` | 146 | ✅ Clean, focused. Each setting persisted independently. |
| `heartsProvider` | Provider (derived) | 105 | ✅ Properly derived from profile state. |
| `leaderboardProvider` | Unknown | 86 | ✅ Lightweight, fine. |
| `roomThemeProvider` | StateNotifier | 55 | ✅ Minimal, clean. |
| `storageProvider` | `Provider<StorageService>` | 9 | ✅ Clean abstraction over storage implementation. |

### Key Issues

1. **`userProfileProvider` is a 932-line god object** — It handles XP awards, streak calculations, lesson completion, daily goals, level-ups, gem transactions, inventory management, and profile CRUD. This is the single biggest architectural debt.

2. **SharedPreferences as primary persistence** — Profile, settings, spaced repetition cards, and smart features all store JSON blobs in SharedPreferences. This works for MVP but won't scale — SharedPreferences loads synchronously on Android main thread and has size limits.

3. **No clear error propagation strategy** — Some providers use `AsyncValue.error()`, others use `try/catch` with `debugPrint`, and some silently swallow errors. Inconsistent.

4. **Over-watching in some screens** — `ref.watch(userProfileProvider)` is called in many screens that only need XP or level, causing unnecessary rebuilds when any profile field changes.

---

## Performance Opportunities

### Critical Files

| File | Lines | Issue |
|------|-------|-------|
| `lib/data/lesson_content.dart` | 4,917 | ⚠️ Legacy monolith — partially addressed by lazy loading via `lesson_provider.dart`, but this file is still compiled into the binary. Verify it's tree-shaken if truly unused. |
| `lib/data/species_database.dart` | 3,004 | 🔴 Always compiled in. Contains hundreds of species objects. Should be loaded from JSON asset or database at runtime. |
| `lib/data/stories.dart` | 1,522 | 🔴 Same — large static data. |
| `lib/data/plant_database.dart` | 1,286 | 🔴 Same pattern. |
| `lib/widgets/room_scene.dart` | 2,281 | ⚠️ Very large widget file with complex painting. Should be decomposed. |
| `lib/screens/settings_screen.dart` | 1,518 | ⚠️ Monolithic settings — already has `settings_hub_screen.dart` suggesting migration in progress. |
| `lib/screens/livestock_screen.dart` | 1,353 | ⚠️ Large, could extract list items into separate widgets. |

### Build Method Concerns

- **382 `setState` calls** across the codebase — very high for a Riverpod app. Many of these should be replaced with provider state updates. `setState` in `ConsumerStatefulWidget` triggers full widget rebuilds.
- **Filtering in build methods** — `TodayBoard`, `AlertsCard`, `LogsList`, `TaskPreview` all run `.where().toList()` during build. These should be pre-computed in providers or cached with `useMemoized`/`select`.
- **IndexedStack with 5 Navigators** — All 5 tab trees are built and kept alive simultaneously. Memory-heavy, especially with room scenes and animations.

### Image & Animation Loading

- `OptimizedNetworkImage` and `OptimizedAssetImage` wrappers exist ✅ — good pattern.
- Rive animations (`rive: ^0.13.0`) loaded for room scenes — ensure these dispose properly on tab switch.
- `floating_bubbles`, `confetti`, `lottie` — multiple animation packages. Check if all are actively used; each adds to binary size.

---

## Data Persistence Map

### What Persists (survives app restart)

| Data | Storage | Location |
|------|---------|----------|
| User Profile (XP, level, streaks, goals, lesson progress) | SharedPreferences | `user_profile` key |
| App Settings (theme, units, notifications) | SharedPreferences | Individual keys |
| Spaced Repetition Cards | SharedPreferences | JSON blob |
| Smart Feature Preferences | SharedPreferences | Individual keys |
| Tanks, Livestock, Equipment, Logs, Tasks | LocalJsonStorageService | Single JSON file on disk |
| Room Theme Selection | SharedPreferences | `room_theme` key |
| Reduced Motion Preference | SharedPreferences | Key-based |
| Onboarding Completion | SharedPreferences (via OnboardingService) | Flag |

### What Does NOT Persist

| Data | Status |
|------|--------|
| Friends/Social | Mock data only — no persistence |
| Leaderboard | Mock/computed — no persistence |
| Achievements Progress | Computed from profile — no direct persistence |
| Inventory | Stored within UserProfile JSON blob |
| Gem Transaction History | Stored within UserProfile JSON blob (unbounded growth risk) |
| Analytics/Insights | Computed on-demand from profile history |

### Gaps & Risks

1. **SharedPreferences JSON blobs growing unbounded** — UserProfile stores lesson history, gem transactions, daily XP records. Over months, this JSON string could hit SharedPreferences' practical limits (~500KB-1MB on some devices).
2. **Single-file JSON storage** — `LocalJsonStorageService` writes ALL tanks/livestock/logs to one file. With many tanks and log entries, reads/writes become slow and risk corruption.
3. **No migration strategy** — No versioning on stored data. Schema changes could break existing user data silently.
4. **Cloud sync is additive but incomplete** — Supabase integration exists but is optional. No conflict resolution tests visible.

---

## Dependency Audit

### Heavy Dependencies

| Package | Size Impact | Usage | Verdict |
|---------|-------------|-------|---------|
| `supabase_flutter: ^2.8.4` | **Very heavy** (~5MB+) | Cloud sync (optional) | ⚠️ Consider making it a deferred/conditional import if most users are offline-only |
| `rive: ^0.13.0` | **Heavy** (~2-3MB) | Fish animations in room scene | ✅ Core feature, justified |
| `lottie: ^3.0.0` | **Medium** (~1MB) | Celebrations? | ⚠️ Verify usage — `confetti` package already exists |
| `audioplayers: ^6.1.0` | **Medium** | Celebration sounds | ✅ If used |
| `fl_chart: ^0.69.2` | **Medium** | Water parameter charts | ✅ Core feature |
| `archive: ^3.6.1` | **Medium** | Backup compression | ✅ Justified for backup feature |
| `pointycastle: ^3.9.1` | **Medium** | Backup encryption | ⚠️ Plus `encrypt` + `crypto` — three crypto packages is excessive |

### Potentially Unused/Redundant

- `vibration: ^2.0.0` — Flutter has `HapticFeedback` built-in (already used via `HapticFeedback.selectionClick()`). Check if `vibration` adds anything.
- `confetti: ^0.7.0` + custom `confetti_overlay.dart` + `celebrations/confetti_overlay.dart` — **duplicate widgets AND a package**.
- `lottie: ^3.0.0` — No `.json` lottie files visible in assets. May be unused.
- Three crypto packages (`encrypt`, `crypto`, `pointycastle`) — likely only one is needed.

### Firebase (Commented Out)

Firebase deps are commented out with a TODO. If not planned soon, remove the comments to avoid confusion.

---

## Code Quality Findings

### TODOs/FIXMEs

Only **1 TODO** found: `main.dart:35` — Firebase configuration. Very clean codebase in this regard.

### Duplicate/Dead Code

| Issue | Files |
|-------|-------|
| Duplicate confetti overlay | `widgets/confetti_overlay.dart` (208 lines) vs `widgets/celebrations/confetti_overlay.dart` (364 lines) |
| Duplicate empty state | `widgets/empty_state.dart` (326 lines) vs `widgets/common/empty_state.dart` (84 lines) |
| Legacy `house_navigator.dart` still exists | Replaced by `tab_navigator.dart` but not removed — 200+ lines of dead code |
| `lesson_content.dart` (4917 lines) | Appears superseded by `data/lessons/*.dart` split files + lazy loading |
| `lesson_content_lazy.dart` exists alongside the lazy provider | Potential overlap |

### Complex Widget Files

| File | `child:` count | Concern |
|------|----------------|---------|
| `create_tank_screen.dart` | 59 | Very deep nesting — multi-step form |
| `lesson_screen.dart` | 55 | Deep widget tree |
| `learn_screen.dart` | 55 | Heavy nesting |
| `livestock_screen.dart` | 46 | Complex list + detail |
| `theme_gallery_screen.dart` | 45 | Grid of themes |

### Navigation

- **Imperative routing** — 469 instances of `Navigator.push` / `MaterialPageRoute`. No `GoRouter` or declarative routing.
- **No deep linking** — App uses imperative navigation exclusively. Adding deep links later will require significant refactoring.
- **HouseNavigator still imported** — `HomeScreen` imports it, suggesting the migration from swipe-rooms to tabs isn't fully complete.

---

## Top 15 Optimisation Recommendations

### 🔴 Critical (High Impact)

**1. Split `userProfileProvider` into domain-focused providers**
- Files: `lib/providers/user_profile_provider.dart` (932 lines)
- Split into: `xp_provider.dart`, `streak_provider.dart`, `lesson_progress_provider.dart`, `daily_goal_provider.dart`, keeping `user_profile_provider.dart` as a thin coordinator.
- Impact: Reduces unnecessary widget rebuilds across the entire app. Currently, changing XP rebuilds everything watching profile.
- Effort: **8-12 hours**

**2. Migrate from SharedPreferences JSON blobs to structured local DB**
- Files: All providers using `SharedPreferences` for complex data
- Use `drift` (SQLite) or `isar` for UserProfile, SpacedRepetition cards, and gem transactions. Keep SharedPreferences only for simple key-value settings.
- Impact: Eliminates unbounded JSON growth, enables queries, and moves off main-thread sync I/O.
- Effort: **16-24 hours**

**3. Externalise static data to JSON assets**
- Files: `lib/data/species_database.dart` (3004 lines), `lib/data/plant_database.dart` (1286 lines), `lib/data/stories.dart` (1522 lines)
- Move to `assets/data/*.json`, load lazily at runtime via `rootBundle.loadString()`.
- Impact: Reduces compiled binary size by ~50-80KB. Enables updating data without recompiling.
- Effort: **6-8 hours**

**4. Reduce `setState` usage — convert to provider-driven state**
- Files: 382 occurrences across `lib/`
- Audit top 20 screens. Replace local `setState` for loading/error/selection state with `StateProvider` or `StateNotifierProvider` where state is shared or complex.
- Impact: More predictable rebuilds, better testability.
- Effort: **12-16 hours** (incremental)

### 🟡 Important (Medium Impact)

**5. Pre-compute filtered lists in providers instead of build methods**
- Files: `home/widgets/today_board.dart`, `tank_detail/widgets/alerts_card.dart`, `tank_detail/widgets/logs_list.dart`
- Create derived providers: `overdueTasksProvider`, `todayTasksProvider`, `recentAlertsProvider`.
- Impact: Eliminates repeated `.where().toList()` on every build frame.
- Effort: **3-4 hours**

**6. Remove duplicate and dead code**
- Delete: `widgets/confetti_overlay.dart` (keep `celebrations/` version), `widgets/empty_state.dart` (keep `common/` version), `screens/house_navigator.dart`, `data/lesson_content.dart` (if fully replaced by `data/lessons/`).
- Update all imports accordingly.
- Impact: ~5,500 lines removed. Cleaner codebase, smaller binary.
- Effort: **2-3 hours**

**7. Adopt declarative routing (GoRouter)**
- Files: `lib/screens/tab_navigator.dart`, all 469 `Navigator.push` sites
- Replace with `GoRouter` for type-safe routes, deep linking support, and declarative navigation.
- Impact: Enables deep linking, better testability, cleaner navigation code.
- Effort: **16-20 hours** (can be incremental)

**8. Consolidate crypto dependencies**
- Files: `pubspec.yaml`, `lib/services/backup_service.dart`
- Replace `encrypt` + `crypto` + `pointycastle` with just `cryptography` or `encrypt` alone.
- Impact: Smaller binary, fewer transitive deps.
- Effort: **2-3 hours**

**9. Audit and remove unused animation packages**
- Check usage of `lottie`, `vibration`, `floating_bubbles`. Remove if unused.
- Verify no duplicate animation logic between `confetti` package and custom celebration overlays.
- Impact: Binary size reduction of 1-3MB.
- Effort: **2-3 hours**

### 🟢 Nice to Have (Lower Impact but Clean)

**10. Decompose `room_scene.dart` (2,281 lines)**
- Split into: `room_painter.dart`, `room_decorations.dart`, `room_interactive_layer.dart`.
- Impact: Maintainability. Currently very difficult to modify.
- Effort: **4-6 hours**

**11. Add data versioning/migration system**
- Create a `StorageMigration` class that checks schema version on app start and runs migrations.
- Impact: Prevents silent data loss on model changes. Essential before any model refactoring.
- Effort: **4-6 hours**

**12. Implement `ref.watch(provider.select(...))` for fine-grained rebuilds**
- Files: Screens watching `userProfileProvider` for only XP or level.
- Use `.select((profile) => profile.xp)` to rebuild only when the specific value changes.
- Impact: Quick win — reduces unnecessary rebuilds without restructuring providers.
- Effort: **3-4 hours**

**13. Lazy-load IndexedStack tabs**
- Currently all 5 tabs build immediately. Use a custom `LazyIndexedStack` that only builds a tab when first selected.
- Impact: Faster initial load, lower memory baseline.
- Effort: **2-3 hours**

**14. Complete the HouseNavigator → TabNavigator migration**
- Remove `house_navigator.dart`, `currentRoomProvider`, and all "room" references from navigation.
- Clean up imports in `home_screen.dart` that still reference `house_navigator.dart`.
- Effort: **1-2 hours**

**15. Add error boundary per tab**
- Currently one global `ErrorBoundary`. Add per-tab error boundaries so a crash in one tab doesn't blank the whole app.
- Effort: **1-2 hours**

---

## Estimated Effort Summary

| # | Recommendation | Hours | Priority |
|---|---------------|-------|----------|
| 1 | Split userProfileProvider | 8-12 | 🔴 Critical |
| 2 | Migrate to structured DB | 16-24 | 🔴 Critical |
| 3 | Externalise static data | 6-8 | 🔴 Critical |
| 4 | Reduce setState usage | 12-16 | 🔴 Critical |
| 5 | Pre-compute filtered lists | 3-4 | 🟡 Important |
| 6 | Remove duplicate/dead code | 2-3 | 🟡 Important |
| 7 | Adopt GoRouter | 16-20 | 🟡 Important |
| 8 | Consolidate crypto deps | 2-3 | 🟡 Important |
| 9 | Audit animation packages | 2-3 | 🟡 Important |
| 10 | Decompose room_scene | 4-6 | 🟢 Nice |
| 11 | Data versioning/migration | 4-6 | 🟢 Nice |
| 12 | Provider `.select()` usage | 3-4 | 🟢 Nice |
| 13 | Lazy IndexedStack | 2-3 | 🟢 Nice |
| 14 | Complete nav migration | 1-2 | 🟢 Nice |
| 15 | Per-tab error boundaries | 1-2 | 🟢 Nice |
| | **Total** | **~82-116 hours** | |

### Suggested Execution Order

**Phase 1 — Quick Wins (Week 1):** Items 6, 12, 13, 14, 15 (~10-14 hours)
**Phase 2 — Architecture (Weeks 2-3):** Items 1, 5, 11 (~15-22 hours)
**Phase 3 — Data Layer (Weeks 3-5):** Items 2, 3 (~22-32 hours)
**Phase 4 — Polish (Weeks 5-7):** Items 4, 7, 8, 9, 10 (~36-48 hours)

---

## Overall Assessment

**Danio is a well-structured MVP** with some genuinely good patterns (lazy lesson loading, storage abstraction, accessibility support, offline-first design). The main risks are:

1. **The god provider** (`userProfileProvider`) — this will become increasingly painful as features are added.
2. **SharedPreferences as a database** — works now, will break at scale.
3. **Binary bloat from static data** — 12,000+ lines of Dart objects that should be assets.

The codebase is clean (only 1 TODO!), well-organised into logical directories, and shows evidence of iterative improvement (e.g., the lesson lazy-loading refactor). The architecture is sound for MVP and the recommendations above provide a clear path to production-grade quality.
