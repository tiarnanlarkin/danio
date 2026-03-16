# ARGUS_CODE_DATA.md — Danio App: Notifications & Data Collection Audit

**Generated:** 2026-03-16  
**Source:** `/mnt/c/Users/larki/Documents/Danio Aquarium App Project/repo/apps/aquarium_app`  
**Scope:** `lib/` — all `.dart` files

---

## 1. Notifications

### Are notifications wired up in onboarding?
**YES** — `lib/screens/onboarding/enhanced_tutorial_walkthrough_screen.dart` calls `NotificationService().requestPermissions()` at two points (lines 139 and 195), both labelled `// P5-1: Request notification permission before entering the app`.

Permission is requested **before the user enters the main app** — this is the correct onboarding gate.

### Notification Service (`lib/services/notification_service.dart`)
Uses `flutter_local_notifications: ^18.0.1` (no Firebase Messaging / push — entirely local).

**Notification channels configured:**

| Channel ID | Name | Purpose |
|---|---|---|
| `task_reminders` | Task Reminders | Aquarium maintenance task due dates |
| `streak_reminders` | Streak Reminders | Daily learning streak (morning/evening/night) |
| `review_reminders` | Review Reminders | Spaced repetition card review |
| `water_change_reminders` | Water Change Reminders | Per-tank water change due dates |
| `achievements` | Achievements | Achievement unlock notifications |
| `test` | Test Notifications | Debug only |

**Notification types:**
- **Morning streak reminder** — 9 AM daily (configurable), repeating
- **Evening streak reminder** — 7 PM daily (only if daily XP goal not yet met)
- **Night streak reminder** — 11 PM daily (last call before midnight, Priority.max)
- **Review reminder** — Daily at configurable time, shows card count
- **Task reminders** — Scheduled for 9 AM on task due date
- **Water change reminders** — Scheduled per-tank, based on days since last change
- **Achievement notifications** — Immediate, on unlock

**Android 12+ exact alarm handling:** Runtime check for `canScheduleExactNotifications()`, graceful fallback to `inexactAllowWhileIdle` (P2-007 fix).

**iOS:** `requestAlertPermission`, `requestBadgePermission`, `requestSoundPermission` all true in `DarwinInitializationSettings`.

**No Firebase Cloud Messaging (FCM) / push notifications** — entirely local. `firebase_messaging` is NOT in pubspec.

---

## 2. Firebase Services Used

**`pubspec.yaml` Firebase dependencies:**
```yaml
firebase_core: ^2.24.2
firebase_analytics: ^10.7.4
firebase_crashlytics: ^3.4.9
```

**NOT present:** `firebase_messaging`, `firebase_firestore`, `firebase_auth`, `cloud_firestore`

### Firebase Analytics (`lib/services/firebase_analytics_service.dart`)
Centralised service, all calls guarded — silently no-ops if Firebase not initialised (missing `google-services.json`).

**6 named analytics events:**

| Event Name | Trigger | Parameters |
|---|---|---|
| `lesson_complete` | Lesson finished | `lesson_id` |
| `tank_created` | New tank added | `tank_type` |
| `quiz_passed` | Quiz completed successfully | `quiz_id`, `score` |
| `fish_id_used` | Smart fish ID feature used | none |
| `achievement_unlocked` | Achievement awarded | `achievement_id` |
| `onboarding_complete` | Onboarding flow finished | none |

### Firebase Crashlytics (`lib/main.dart`, `lib/widgets/error_boundary.dart`)
Used for crash/error reporting. `recordError` called from the error boundary widget.

**Summary:** Firebase Analytics + Crashlytics only. No Firestore, no Auth, no Messaging.

---

## 3. Analytics Events Count

**6 custom Firebase Analytics events** (all in `FirebaseAnalyticsService`):
1. `lesson_complete`
2. `tank_created`
3. `quiz_passed`
4. `fish_id_used`
5. `achievement_unlocked`
6. `onboarding_complete`

There is also a local `AnalyticsService` / `AnalyticsSummary` / `AnalyticsInsight` model system (`lib/models/analytics.dart`, `lib/screens/analytics_screen.dart`) — this is **in-app progress analytics** (XP charts, streak calendars, topic mastery radar), entirely local, nothing sent externally.

---

## 4. External API Calls

### OpenAI API (`lib/services/openai_service.dart`)
- **Endpoint:** `https://api.openai.com/v1/chat/completions`
- **Method:** `POST` (streaming via `http.Request`)
- **Package:** `http: ^1.2.2`
- **Used for:** Smart fish ID feature (SMART tab)
- **Key injection:** via `--dart-define=OPENAI_API_KEY=...` at build time

### Supabase (`lib/services/supabase_service.dart`, `lib/services/cloud_sync_service.dart`)
- **Package:** `supabase_flutter: ^2.8.4`
- **URL/Key:** Injected via `--dart-define=SUPABASE_URL` and `--dart-define=SUPABASE_ANON_KEY`
- **Used for:** Cloud sync of user data (tanks, progress, profile)
- **Guard:** Sync is disabled (`CloudSyncStatus.disabled`) if URL/key not provided at build time
- **Status:** Appears to still be using a shared/placeholder instance — `// ROADMAP: Replace with dedicated aquarium-app Supabase project credentials`

### URL Launches (not API calls, just browser opens)
- `lib/screens/privacy_policy_screen.dart` — opens privacy policy URL
- `lib/screens/terms_of_service_screen.dart` — opens ToS URL

---

## 5. Local Data Storage

**`shared_preferences`** used extensively across ~25 files for:
- Onboarding completion state
- Settings (notification prefs, reduced motion, etc.)
- User profile, XP, streak, gems
- Room themes, inventory, wishlist
- Achievements, friends

No `Hive`, no `sqflite` — SharedPreferences is the only local persistence layer (plus `local_json_storage_service.dart` for structured JSON).

---

## Summary Table

| Area | Status | Notes |
|---|---|---|
| Notifications in onboarding | ✅ YES | `requestPermissions()` called at onboarding gate |
| Push notifications (FCM) | ❌ None | Local-only via flutter_local_notifications |
| Firebase Analytics | ✅ Active | 6 custom events, gracefully guarded |
| Firebase Crashlytics | ✅ Active | Error boundary + main.dart |
| Firebase Auth | ❌ None | Not used |
| Firebase Firestore | ❌ None | Not used |
| OpenAI API | ✅ Active | Chat completions for Smart fish ID |
| Supabase | ⚠️ Partial | Present but disabled if env vars not set; placeholder credentials in codebase |
| Local storage | SharedPreferences | ~25 files; no Hive/sqflite |
