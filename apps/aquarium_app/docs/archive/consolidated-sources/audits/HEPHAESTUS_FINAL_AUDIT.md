# Hephaestus Final Audit — Danio App
**Date:** 2026-03-01  
**Branch:** `openclaw/ui-fixes`  
**Auditor:** Hephaestus (builder agent)

---

## 1. Hive Data Integrity

### Storage Architecture
Danio does **NOT** use Hive TypeAdapters. All data is stored as `Box<Map>` (raw JSON maps) via `HiveStorageService`. Models use manual `toJson()` / `fromJson()` methods.

### TypeAdapter ID Map
**N/A** — No `@HiveType` or `@HiveField` annotations in use. No TypeAdapter IDs to conflict.

### Serialization Correctness
- All models (`Tank`, `Livestock`, `Equipment`, `LogEntry`, `Task`, `UserProfile`, etc.) implement `toJson()` and `factory fromJson()` manually ✅
- No unserializable types in storage (no `Duration`, `Color`, `DateTime` objects stored directly — all converted to ISO strings or ints) ✅

### Migration Strategy
- `kStorageSchemaVersion = 1` with a `_runMigrations()` stub in `HiveStorageService` ✅
- Migration plumbing exists but has never been exercised (version still at 1)
- ⚠️ **Risk:** If model shapes change (e.g., adding a required field), existing data in Hive boxes won't have that field. `fromJson()` must handle missing keys gracefully with defaults. Most models do this via `??` operators, but not all fields are guarded — a comprehensive null-safety pass on all `fromJson` methods is recommended before any model changes.

### Verdict: ✅ PASS (with caution on future migrations)

---

## 2. Provider State Reset Audit

### Stateful Providers Inventory
| Provider | Type | Holds Mutable State? | Resets on Logout? |
|----------|------|---------------------|-------------------|
| `tanksProvider` | FutureProvider | No (reads from storage) | N/A (data persists) |
| `tankActionsProvider` | Provider | No | N/A |
| `aiHistoryProvider` | StateNotifierProvider | Yes (SharedPrefs) | ❌ No |
| `anomalyHistoryProvider` | StateNotifierProvider | Yes (SharedPrefs) | ❌ No |
| `weeklyPlanProvider` | StateNotifierProvider | Yes (SharedPrefs) | ❌ No |
| `settingsProvider` | StateNotifier | Yes | Persists deliberately |
| `userProfileProvider` | FutureProvider | Reads storage | Invalidated by auth |
| `authProvider` | StateNotifierProvider | Yes | Clears on signOut ✅ |

### Soft Delete State (Global Singletons)
`_softDeleteState` and `_softDeleteLivestockState` are **global** `SoftDeleteState` instances with active `Timer`s. These:
- ✅ Are intentionally global (survive provider refreshes during 5s undo window)
- ✅ Have a `dispose()` method that cancels all timers
- ⚠️ `dispose()` is **never called** — these live for the app's lifetime. Acceptable since they self-clean after 5s per item.

### Logout Flow
`signOut()` in `AuthProvider` only calls `AuthService.instance.signOut()` — it does **not**:
- Clear AI history, anomaly history, or weekly plan cache from SharedPreferences
- Invalidate tank/livestock/profile providers
- Clear Hive boxes

**Assessment:** This is **by design** — the app says "Your local data will remain on this device." Local-first means data persists across auth state changes. However, if multi-user support is ever added, this becomes a data leak.

### Verdict: ✅ PASS (single-user design is intentional)

---

## 3. Navigation Correctness

### Architecture
The app uses a **custom `MaterialApp` + `TabNavigator`** pattern, NOT GoRouter. Navigation is via:
- `TabNavigator` with 5 tabs (Learn, Quiz, Tank, Smart, Settings)
- Per-tab `GlobalKey<NavigatorState>` for preserving tab stacks
- `MaterialPageRoute` pushes for sub-screens

### Route Coverage
- All screens referenced in `TabNavigator` exist ✅
- Notification payloads map to: `learn` → `LearnScreen`, `review` → `SpacedRepetitionPracticeScreen`, `achievements` → `AchievementsScreen` ✅
- `water_change` payload has **no navigation handler** ⚠️ — tapping a water change notification does nothing

### Deep Link / Notification Navigation
- Notification tap handler in `main.dart` uses `navigatorKey.currentState?.push()` ✅
- BUT: if the app is cold-launched from a notification, `navigatorKey.currentState` may be null (the widget tree isn't built yet) ⚠️
- No `getNotificationAppLaunchDetails()` call to handle cold-start notification taps

### 404 / Unknown Route
- No `onUnknownRoute` or `onGenerateRoute` fallback — `MaterialApp` uses default behavior
- Since the app doesn't use named routes or deep links extensively, this is low risk

### Back Button Handling
- Double-tap-to-exit implemented in `TabNavigator` ✅
- Per-tab navigator stack properly checked before exiting ✅

### Verdict: ⚠️ MINOR ISSUES
- Missing `water_change` notification navigation handler
- No cold-start notification handling

---

## 4. Notification Correctness

### Android 13+ Permissions
- `requestNotificationsPermission()` called via `AndroidFlutterLocalNotificationsPlugin` ✅
- Proper null-safety on the result ✅

### Notification Channels (Android 8+)
| Channel ID | Name | Used By |
|-----------|------|---------|
| `task_reminders` | Task Reminders | Task due dates |
| `test` | Test Notifications | Test button |
| `achievements` | Achievements | Achievement unlocks |
| `streak_reminders` | Streak Reminders | Morning/evening/night streaks |
| `review_reminders` | Review Reminders | Spaced repetition |
| `water_change_reminders` | Water Change Reminders | Water change schedule |

All channels properly defined ✅

### Water Change Reminder Scheduling
- Correctly calculates days until due ✅
- Handles overdue case (schedules within 1 hour) ✅
- Uses unique notification IDs per tank (`_waterChangeNotificationId + tankIndex`) ✅
- ⚠️ `tankIndex` parameter relies on caller providing correct index — could collide if tanks are reordered

### 🐛 BUG FIXED: `scheduleAllTaskReminders` was calling `cancelAll()`
**Before:** Rescheduling task reminders wiped ALL notifications (streak, review, water change).  
**After:** Now only cancels task-specific notification IDs before rescheduling.

### Permission Denial
- If user denies permission, `requestPermissions()` returns `false` ✅
- No in-app messaging to explain why permissions are needed (nice-to-have)

### Verdict: ✅ PASS (bug fixed this audit)

---

## 5. OpenAI Resilience

### Error Handling Matrix
| Scenario | Handled? | How |
|---------|---------|-----|
| API key not set | ✅ | `_assertConfigured()` throws, UI shows friendly message |
| HTTP 429 (rate limit) | ✅ | Exponential backoff: 2s, 4s, 6s (3 retries) |
| HTTP 500+ (server error) | ✅ | Linear backoff: 1s, 2s, 3s (3 retries) |
| Network error (no internet) | ✅ | `http.ClientException` caught, retries, then throws `OpenAIException` |
| Malformed JSON response | ✅ | `jsonDecode` would throw, caught by generic catch in callers |
| No choices returned | ✅ | Explicit check: `if (choices.isEmpty) throw` |
| Streaming chunk errors | ✅ | `try/catch` in stream loop, skips malformed chunks |
| Key valid but no credits | ⚠️ | Returns HTTP 429 — handled by retry, but error message says "rate limited" not "insufficient credits" |

### 🐛 FIXED: No HTTP Request Timeout
**Before:** `_client.post()` had no timeout — could hang indefinitely on slow connections.  
**After:** Added 30-second `_requestTimeout` with `TimeoutException` catch and retry.

### Rate Limiting
- Client-side rate limiter: 500ms minimum between calls ✅
- Monthly usage counter (for internal tracking) ✅

### Caller Error Handling (Smart Features)
- `FishIdScreen`: catches `OpenAIException` specifically + generic catch ✅
- `SymptomTriageScreen`: catches `OpenAIException` + generic catch ✅
- `WeeklyPlanScreen`: catches `OpenAIException` + generic catch ✅
- `AnomalyDetectorService`: returns rules-based anomalies even if AI fails ✅ (graceful degradation)

### Verdict: ✅ PASS (timeout bug fixed this audit)

---

## 6. Offline Behaviour

### First Launch (No Internet)
- Onboarding is fully local (UI + Hive) ✅
- Profile creation is local ✅
- Demo tank seeding is local ✅
- **No internet required for core functionality** ✅

### AI Features Without Internet
- All AI screens check `openai.isConfigured` first ✅
- If API call fails due to network, `OpenAIException` is caught and displayed ✅
- `AnomalyDetectorService` returns rules-based results even without AI ✅

### Network Error Coverage
- `OfflineAwareService` wraps actions: executes locally first, queues for sync ✅
- `isOnlineProvider` tracks connectivity state ✅
- Offline indicator widget shows in UI ✅
- Supabase initialization fails gracefully if credentials are placeholders ✅

### Verdict: ✅ PASS — solid offline-first architecture

---

## 7. Memory Leak Findings

### AnimationController Audit
| File | Controllers | Disposed? |
|------|------------|-----------|
| `enhanced_quiz_screen.dart` | `_progressController`, `_feedbackController` | ✅ Yes |
| `onboarding_screen.dart` | `_contentController` (main), `_controller` (sub-widget) | ✅ Yes |
| `enhanced_tutorial_walkthrough_screen.dart` | `_animationController` (main), `_controller` (sub) | ✅ Yes |
| `story_player_screen.dart` | `_textAnimationController`, `_choiceAnimationController` | ✅ Yes |
| `quick_add_fab.dart` | `_controller` | ✅ Yes |
| `celebration_service.dart` | `_controller` (via `_disposeController()`) | ✅ Yes |

### Timer Audit
| File | Timers | Disposed? |
|------|--------|-----------|
| `ambient_time_service.dart` | `_updateTimer`, `_transitionTimer` | ✅ Yes |
| `tank_provider.dart` | `SoftDeleteState._timers` | ⚠️ Global singleton, self-cleans after 5s |

### StreamSubscription Audit
| File | Subscriptions | Disposed? |
|------|--------------|-----------|
| `auth_provider.dart` | `_sub`, `_authSub` | ✅ Yes |

### Verdict: ✅ PASS — no memory leaks found

---

## 8. Performance Recommendations

### Widget Rebuild Efficiency
- **2,433** `const` widget usages vs **2,520** non-const usages (~49% const ratio)
- Many `SizedBox`, `Padding`, `Text` widgets could be promoted to `const`

### Largest Screen Build Methods
| Screen | Lines | Concern |
|--------|-------|---------|
| `livestock_screen.dart` | 1,520 | `fold()` to count livestock in build — acceptable (small list) |
| `settings_screen.dart` | 1,518 | Static UI — no compute in build ✅ |
| `home_screen.dart` | 1,314 | `.where()` filters on logs in build — should be in provider ⚠️ |
| `add_log_screen.dart` | 1,268 | Form state — fine ✅ |
| `analytics_screen.dart` | 1,171 | `.map()`, `.reduce()`, `.reversed.toList()` in build — **should be cached** ⚠️ |

### Specific Recommendations
1. **`home_screen.dart`** — Water test/feeding/water change filtering happens in the build method. Move to a computed provider.
2. **`analytics_screen.dart`** — Multiple `.reduce()` and `.reversed.toList()` calls in build. Move max XP calculation to a computed provider.
3. **Const promotion** — A pass to add `const` to eligible `SizedBox(height: ...)`, `Padding(...)`, and `EdgeInsets.all(...)` would reduce widget rebuilds.

### Verdict: ⚠️ MINOR — no critical perf issues, but home/analytics do unnecessary work in build

---

## 9. Additional Findings

### Notification: `water_change` Payload Unhandled
In `main.dart`, the notification tap handler checks for `learn`, `review`, and `achievements` — but `water_change` has no handler. Tapping a water change notification opens the app but doesn't navigate.

### Cold-Start Notification Gap
`getNotificationAppLaunchDetails()` is not called — cold-start notification taps are silently lost.

### Splash Screen Hardcoded Font Size
`_AppRouter.build()` uses `fontSize: 32` for "Danio" text — violates CLAUDE.md convention. Should use `Theme.of(context).textTheme.headlineLarge`.

---

## Summary

| Area | Status | Notes |
|------|--------|-------|
| Hive Data Integrity | ✅ PASS | JSON-map approach, no TypeAdapter conflicts |
| Provider State Reset | ✅ PASS | Single-user design, intentional data persistence |
| Navigation | ⚠️ MINOR | Missing water_change handler, no cold-start notifications |
| Notifications | ✅ PASS | Bug fixed: cancelAll no longer nukes all notifications |
| OpenAI Resilience | ✅ PASS | Bug fixed: added 30s timeout, TimeoutException handling |
| Offline Behaviour | ✅ PASS | Solid offline-first architecture |
| Memory Leaks | ✅ PASS | All controllers/timers/subscriptions properly disposed |
| Performance | ⚠️ MINOR | home_screen and analytics_screen compute in build() |

## Bugs Fixed This Audit
1. **OpenAI HTTP timeout** — Added 30s timeout + `TimeoutException` catch with retry
2. **Notification cancelAll** — `scheduleAllTaskReminders` no longer wipes streak/review/water notifications

## Overall Stability Score: **8/10**

The app is solid for a pre-launch state. The architecture is clean, error handling is thorough, and the offline-first approach is well-implemented. The two bugs fixed this audit were the most impactful finds. Remaining items are enhancement-tier, not stability risks.
