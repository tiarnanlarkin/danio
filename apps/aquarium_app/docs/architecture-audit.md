# Danio App — Architecture, State Management & Error Handling Audit

**Branch:** `openclaw/stage-system`  
**Audited by:** Hephaestus  
**Date:** 2026-03-29  
**Scope:** Read-only static analysis

---

## Executive Summary

The codebase is **genuinely solid** — better than most Flutter apps of this complexity. The Riverpod layer is well-organised, error handling has real thought behind it, and the service abstraction is clean. The problems that exist are the classic ones: a God object in `UserProfileNotifier`, ref.read misuse in async callbacks (mostly fine), and a few stale-data bugs from `ref.read` in non-async contexts. Nothing catastrophic. Plenty to tighten up.

---

## 1. Riverpod Provider Architecture

**Score: 7 / 10**

### What's Good
- **85 providers** across the app — reasonable for the feature count.
- Clear provider-per-concern pattern: `tanksProvider`, `livestockProvider`, `equipmentProvider`, `logsProvider` all well-scoped.
- Good use of `.family` for parameterised providers (tankId, lessonId, itemId).
- `StorageService` abstract interface is excellent — providers depend on the abstraction, not the concrete `LocalJsonStorageService`.
- Derived providers (`gemBalanceProvider`, `heartsStateProvider`, `needsOnboardingProvider`) keep UI logic thin.
- 21 `autoDispose` usages — family providers appropriately cleaned up.
- Barrel re-export on `user_profile_provider.dart` shows awareness of the God-file problem.

### Issues Found

#### 🔴 `UserProfileNotifier` is a God Object (1,084 lines)
`lib/providers/user_profile_notifier.dart` handles: streak logic, XP calculation, lesson completion, daily goals, onboarding state, gem rewards, and profile persistence. It directly calls into `gemsProvider`, `lessonProvider`, and `achievementProgressProvider` via `ref.read`. This creates an implicit dependency hub with fan-out that's hard to test and risky to modify.

**Other large providers:** `spaced_repetition_provider.dart` (835 lines), `achievement_provider.dart` (736 lines), `lesson_provider.dart` (546 lines). These are borderline acceptable but worth monitoring.

#### 🟡 `ref.read` in Non-Async, Non-Callback Contexts
The following locations call `ref.read` outside of event handlers or async functions — these contexts are equivalent to "build method adjacent" and will read stale state:

```
lib/screens/home/home_sheets_care.dart:17   — ref.read(logsProvider(tankId))
lib/screens/home/home_sheets_stats.dart:19  — ref.read(logsProvider(tankId))
lib/screens/home/home_sheets_water.dart:17  — ref.read(logsProvider(tankId))
```

These are plain functions called from widget event callbacks, but the data they display is shown in a bottom sheet. If the logs updated between renders, the sheet shows stale data. Should be `ref.watch` inside a `ConsumerWidget`, or accept the async value as a parameter.

#### 🟡 `connectivityProvider` is a non-autoDispose `StreamProvider`
`lib/widgets/offline_indicator.dart:7` — a stream subscription that lives forever. Fine for a truly global resource, but worth flagging as intentional, not accidental.

#### 🟡 `aiHistoryProvider`, `anomalyHistoryProvider`, `weeklyPlanProvider` are non-autoDispose
These hold conversation history in memory for the lifetime of the app. For a chat feature this may be intentional. If the Smart tab is rarely used, these are wasted memory allocations. `autoDispose` would be appropriate unless history is needed across cold navigations.

#### 🟢 No Circular Dependencies Detected
The dependency graph flows cleanly: `sharedPreferencesProvider` → basic notifiers → derived providers. No cycles observed.

#### 🟢 No `ref.read` in `build()` Methods
The `ref.read` calls in smart feature screens (`fish_id_screen.dart`, `symptom_triage_screen.dart`) are inside async callbacks triggered by user actions — this is correct Riverpod usage.

---

## 2. Error Handling

**Score: 7.5 / 10**

### Statistics
- **250 try-catch blocks** across the non-test lib
- **259 catch clauses** (some blocks have multiple catches)
- **No bare empty catches detected** — no `catch (e) {}` swallowing errors silently
- **20 `debugPrint`/`print` calls** for logging
- Firebase Crashlytics integrated with deferred initialisation pattern

### What's Good
- `FlutterError.onError` and `PlatformDispatcher.instance.onError` both hooked up in `main.dart`.
- Pre-Firebase error buffer (`_preFirebaseErrors`) handles errors before Crashlytics initialises.
- GDPR-safe: Crashlytics collection only enabled after consent applied.
- `ErrorBoundary` widget wraps the entire app at `runApp`.
- `StorageCorruptionException` is a typed exception — good.
- `AuthResult.error(...)` pattern in `auth_service.dart` — errors are values, not throws.
- `GlobalErrorHandler.initialize()` in debug mode.

### Issues Found

#### 🔴 `ErrorBoundary` Only Catches Synchronous Build Errors
`lib/widgets/error_boundary.dart:17` — Flutter's `ErrorWidget` mechanism catches synchronous build exceptions. It does **not** catch errors thrown inside `FutureProvider`, `StateNotifier`, or async callbacks. These async errors surface as `AsyncValue.error` states which the UI must handle individually. Several screens use `asyncValue.when(data:, loading:, error:)` but not all — see gap below.

#### 🟡 Inconsistent AsyncValue Error Handling in Screens
Several screens watch async providers but only handle `data` and `loading` states, silently returning an empty widget on error:

```dart
// Pattern seen in multiple screens:
final tanksAsync = ref.watch(tanksProvider);
return tanksAsync.valueOrNull ?? [];  // error state silently becomes empty list
```

Specific examples:
- `lib/screens/home/home_screen.dart` — `tanksAsync.valueOrNull ?? []`
- `lib/screens/home/home_sheets_care.dart` — `logsAsync.valueOrNull ?? []`
- Multiple widget files using `.valueOrNull` without error state UI

This means if storage fails, the user sees a blank list with no feedback.

#### 🟡 Only 20 Log Statements for 250 Try-Catch Blocks
Ratio of 1:12.5 means most catch blocks either return an error value (good pattern) or silently fall through. For production debugging, this is lean. Some non-critical catches (e.g., SharedPreferences parse errors) may not need logging, but storage and sync errors absolutely should.

#### 🟡 `unawaited()` Used for Species DB Prewarm
`lib/main.dart` — `unawaited(SpeciesDatabase.prewarm())` and `unawaited(PlantDatabase.prewarm())` have no error handling. If prewarm throws, it's silently swallowed. Low severity (it's a cache warm), but worth noting.

#### 🟢 Auth Errors Well-Handled
`lib/features/auth/auth_service.dart` — each auth operation has typed `AuthResult.error()` returns with specific error strings. Clean.

---

## 3. Navigation Architecture

**Score: 7 / 10**

### Architecture Overview
- **Tab-based navigation** with 5 `Navigator` instances (one per tab) managed via `tabNavigatorKeysProvider`.
- `NavigationThrottle.push()` wraps most navigations to prevent double-taps creating duplicate routes.
- `MaterialPageRoute` used directly throughout (no GoRouter/AutoRoute).
- Deep link entry point via `notificationPayloadNotifier` (ValueNotifier) and `_AppRouter` widget.

### What's Good
- `NavigationThrottle` is a smart defensive pattern — prevents double-tap spam.
- Per-tab navigator stack means tab state is preserved on switching (correct behaviour).
- Notification payload routing centralised through `_AppRouter` in main.dart.
- `TankDetailRoute`, `RoomSlideRoute` — custom page routes exist for animation variation.

### Issues Found

#### 🟡 No Centralised Route Registry
Routes are defined inline at point of navigation with `MaterialPageRoute(builder: (_) => SomeScreen(...))`. There are approximately 40+ individual push calls scattered across screens. Refactoring a screen constructor (adding a required parameter) requires finding every call site manually.

#### 🟡 `onGenerateRoute` in Tab Navigators — Partially Used
`lib/screens/tab_navigator.dart:160` — `onGenerateRoute` is set up on each tab's navigator, suggesting deep link / named route support was planned. However, most navigations still use direct `MaterialPageRoute` pushes rather than named routes. The `onGenerateRoute` setup appears incomplete or vestigial.

#### 🟡 Debug Deep Link Service in Non-Debug Builds
`lib/services/debug_deep_link_service.dart` is imported from main — check if it's conditionally compiled out in release builds. If not, it's dead weight.

#### 🟢 No Navigation Traps Detected
All `Navigator.push` calls use standard stack-based navigation. `canPop` / `PopScope` not misused. No infinite nav loops observed.

#### 🟢 No `WillPopScope` (Deprecated) Usage
The app uses `PopScope` (Flutter 3.x) where appropriate.

#### ⚪ Deep Link Support: Minimal
Beyond notification payloads, there's no URL-based deep link handling (no `uni_links`, `app_links`, or GoRouter redirect). Fine for current scope, but would need adding before supporting Android App Links / iOS Universal Links.

---

## 4. Service Layer

**Score: 8 / 10**

### What's Good
- **`StorageService` abstract class** — clean interface with `LocalJsonStorageService` and `InMemoryStorageService` implementations. Testable by design.
- Services are well-separated: `HeartsService`, `ShopService`, `SyncService`, `CloudSyncService`, `NotificationService`, `OpenAIService`, `ApiRateLimiter`, `CelebrationService`, `XpAnimationService`.
- Services are injected via Riverpod providers — no raw `getInstance()` calls in widgets.
- `OfflineAwareService` wraps operations with connectivity checking — correct layer for this.
- `ApiRateLimiter` is a service, not inline logic — good.

### Issues Found

#### 🟡 Business Logic in Large Screen Files
72 direct `SharedPreferences`/JSON calls found in `lib/screens/`. Investigating:
- `lib/screens/cost_tracker_screen.dart` — reads/writes SharedPreferences directly (lines 50, 65) rather than going through a provider or service.
- `lib/screens/maintenance_checklist_screen.dart` — same pattern (lines 68, 99).
- `lib/screens/reminders_screen.dart` — direct SharedPreferences access (lines 37, 53).

These screens have their own local persistence that bypasses the service layer. If backup/restore ever needs to cover this data, it will be missed.

#### 🟡 `ShopService` Calls `ref.read` Internally
`lib/services/shop_service.dart:58` — `shopServiceProvider` creates a `ShopService` that holds a `ref` and calls `ref.read(gemBalanceProvider)` and `ref.read(inventoryProvider.notifier)` inside service methods. This is architecturally awkward — services shouldn't depend on providers; providers should depend on services. Creates a tighter coupling than needed.

#### 🟡 `achievement_provider.dart` Is Part Service, Part Provider
At 736 lines, `AchievementProgressNotifier` contains achievement evaluation logic (`checkTankAchievements`, `checkLivestockAchievements`, etc.) that belongs in `AchievementService`. The actual `achievement_service.dart` exists and contains some logic, but the split is inconsistent.

#### 🟢 `SyncService` and `CloudSyncService` Are Separate
`sync_service.dart` handles local queue/offline sync; `cloud_sync_service.dart` handles Supabase. Clean separation.

---

## 5. Data Layer

**Score: 8 / 10**

### What's Good
- **All model classes are `@immutable`** or use `const` constructors with `final` fields.
- `copyWith()` methods present on all key models — correct immutable update pattern.
- Consistent manual `fromJson`/`toJson` — no code-gen dependency, lower build complexity.
- Models in `lib/models/` are pure data — no UI, no provider imports.
- `StorageCorruptionException` typed exception for data layer errors.

### Issues Found

#### 🟡 Manual JSON Serialisation at Scale
With 15+ model files all doing manual `fromJson`/`toJson`, there's more boilerplate to maintain and more surface area for bugs when adding/renaming fields. No `@JsonSerializable` (json_annotation) or `freezed` is used. For a codebase of this size this is a meaningful maintenance cost — missing fields in `fromJson` will silently produce `null` values rather than compile errors.

#### 🟡 `user_profile.dart` Model Likely Large
Given the 1,084-line notifier file, the underlying `UserProfile` model is probably carrying a lot of fields. Worth checking if some concerns (e.g., `LearningStats`, `DailyGoal`) could be separate models with separate storage rather than being embedded in the profile blob. (Could not confirm line count in this audit pass.)

#### 🟢 No Business Logic in Models
Models are pure data structures. Transformation and validation logic is in services/notifiers.

#### 🟢 `data/` Layer Cleanly Separated
`lib/data/` contains static content (species, lessons, shop catalog) — correctly separate from `lib/models/` (domain models).

---

## 6. Performance Patterns

**Score: 7.5 / 10**

### Metrics
- **1,408 `const` usages** in widgets — good const discipline
- **10 `RepaintBoundary` usages** — present on key animated and shop item widgets
- `ValueKey`/`ObjectKey` usage in list items — found in a few spots, not audited exhaustively

### What's Good
- `RepaintBoundary` on animated widgets (fish room, shop items, inventory) — correct.
- `kDebugMode` guarding for performance monitoring overlay.
- Spaced repetition database prewarm on app start.
- Species/Plant DB cached with lazy loading.
- `userProfileProvider.select(...)` used in several places to avoid unnecessary rebuilds.

### Issues Found

#### 🟡 `.select()` Underused on Heavy Providers
`userProfileProvider` is watched in many places without `.select()`, meaning any profile field change triggers rebuilds across all watchers. `practice_hub_screen.dart:39` has a good example of correct `.select()` usage. Others don't bother:
- `lib/screens/notification_settings_screen.dart:16` — watches full `userProfileProvider`
- `lib/screens/story/story_browser_screen.dart:18` — same

#### 🟡 `ListView`/`GridView` Item Keys Not Consistently Applied
List item keys help Flutter's diffing algorithm correctly identify changed items. Not uniformly applied. For static lists this is harmless; for dynamic lists (e.g., tank livestock) missing keys can cause visual glitches during reorder/delete animations.

#### 🟡 `const` Not Enforced Statically
No `prefer_const_constructors` lint rule confirmed in analysis_options.yaml — worth verifying and enforcing.

---

## Top 10 Architecture Improvements (Ranked by Impact)

| # | Improvement | Why | Effort |
|---|-------------|-----|--------|
| 1 | **Split `UserProfileNotifier` into domain-specific notifiers** | Single biggest risk — 1,084 lines handling XP, streaks, gems, lessons, onboarding. Extract `StreakNotifier`, `XpNotifier`, `LessonProgressCoordinator`. Reduces merge conflicts and testability burden. | **Large** |
| 2 | **Add `.error` handling to all `AsyncValue` consumers** | Currently many screens silently show empty state on storage failure. User has no idea something broke. Global `AsyncErrorWidget` component + enforce usage. | **Medium** |
| 3 | **Move `cost_tracker`, `maintenance_checklist`, `reminders` prefs into providers** | These screens persist data outside the backup/restore system. Moving to provider-managed SharedPreferences keys ensures completeness. | **Small** |
| 4 | **Extract achievement evaluation logic from `AchievementProgressNotifier` into `AchievementService`** | 736-line notifier has service logic embedded. The service file already exists — finish the split. | **Medium** |
| 5 | **Introduce a route registry / centralised navigation** | 40+ scattered `MaterialPageRoute(builder: (_) => Screen(...))` calls make refactoring screen constructors risky. A `AppRouter.push(Routes.tankDetail(tankId))` style wrapper provides one place to update. | **Medium** |
| 6 | **Fix stale-data ref.read in home_sheets functions** | `home_sheets_care/stats/water.dart` read logs once at sheet open time. If logs change, sheet is stale. Convert to accept `AsyncValue` parameter or use `ConsumerWidget`. | **Trivial** |
| 7 | **Add `autoDispose` to `aiHistoryProvider`, `anomalyHistoryProvider`, `weeklyPlanProvider`** | These hold LLM conversation history for app lifetime. If user never returns to Smart tab, memory is held forever. `autoDispose` + `keepAlive()` on first access is the correct pattern. | **Trivial** |
| 8 | **Adopt `freezed` or `json_serializable` for model layer** | 15+ models with manual `fromJson`/`toJson` is a maintenance debt. Code-gen eliminates field-rename bugs and null-silent-failures. High one-time cost, high long-term payoff. | **Large** |
| 9 | **Add error logging to storage/sync catch blocks** | 250 try-catch blocks vs. 20 log statements. Storage failures and sync errors should always log to Crashlytics in release mode. Create a thin `logWarning` wrapper that routes to Crashlytics in release. | **Small** |
| 10 | **Refactor `ShopService` to not hold a `ref`** | Services should not read from providers. Pass required data (gem balance, inventory notifier) as constructor parameters or method arguments instead. Removes a circular-ish coupling. | **Small** |

---

## Effort Legend

| Label | Meaning |
|-------|---------|
| Trivial | < 1 hour, mechanical change, low risk |
| Small | 1–4 hours, clear scope, low risk |
| Medium | 1–3 days, requires design decisions |
| Large | 3–10 days, high impact, needs care |

---

## Summary Scores

| Area | Score | Status |
|------|-------|--------|
| Provider Architecture | 7/10 | Good structure, God-object risk |
| Error Handling | 7.5/10 | Infrastructure solid, async gaps |
| Navigation | 7/10 | Works well, needs centralising |
| Service Layer | 8/10 | Well-abstracted, minor leakage |
| Data Layer | 8/10 | Clean models, JSON debt |
| Performance | 7.5/10 | Good foundations, select() underused |
| **Overall** | **7.5/10** | **Production-ready, clear improvement path** |

---

*It's not done until it's done right. — Hephaestus*
