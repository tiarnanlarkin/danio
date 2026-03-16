# DANIO — PRODUCTION ROADMAP
### The Definitive Single Source of Truth
**Author:** Strategic Planning Agent (Athena subagent)  
**Date:** 2026-03-16  
**Cross-references:** All 21 research outputs + MASTER_IMPLEMENTATION_PLAN + HEPHAESTUS_MASTER_FIX_LIST  
**Status:** APPROVED FOR EXECUTION  
**Codebase:** 322 .dart files | `com.tiarnanlarkin.danio` | Flutter 3.38.9 | Dart 3.10.8

---

# PART 1 — CURRENT STATE AUDIT

## 1.1 What's Already Done (Overnight Sprints 2026-03-15 + 2026-03-16)

### Sprints Completed
| Sprint | What | Commit(s) | Key Results |
|--------|------|-----------|-------------|
| 0 — Asset Compression | PNG→WebP | `d7f3643` | 265MB → ~35MB (95 images converted) |
| 1 — Critical Bugs | 10 crash/logic fixes | `a7e7107` | INTERNET perm, auth null, quiz guard, gems, atomic JSON |
| 2 — Visual Bugs | 8 UI fixes | `46f4aff`+ | Drag handles, quiz overflow, splash dark mode, orientation lock |
| 3 — Build Config | 8 config fixes | multiple | ProGuard, Supabase→dart-define, dead code, version dart-define |
| 5 — Game Balance | 5 economy fixes | `c234ca14`+ | Hearts 5→60min, gem economy, autoDispose.family, history caps |
| 6 — Accessibility | Reduced motion + semantics | `2a5e7a6`+ | ExcludeSemantics decorative, liveRegion AI/sync, headers |
| A–F — Quick Wins | Polish | `a97d2c0`+ | Heater wattage, betta temps, const, .select(), content, data |
| UI Overhaul | Tank page | `32261ee`+ | Milky tank fixed, room bg images (WebP), filing tabs, new icon, panels |
| Firebase | Integration | `983f6fa` | google-services.json, Core/Analytics/Crashlytics wired |
| Pages | Privacy + ToS | `77e314b` | GitHub Pages live at tiarnanlarkin.github.io/danio/ |

### Current Build Status
- **Flutter analyze:** 0 errors, 0 warnings (as of commit `120f727`)
- **Release APK:** 90.2MB built and tested on Z Fold
- **Signing:** `aquarium-release.jks` configured, ProGuard enabled, minify+shrink on
- **App version:** 1.0.0+1 (versionCode 1)
- **Package:** `com.tiarnanlarkin.danio`
- **minSdk:** 24 (Android 7.0) | **targetSdk:** 35

## 1.2 What's Broken Right Now

| # | Issue | Source | Severity | Files |
|---|-------|--------|----------|-------|
| 1 | **No GDPR consent dialog** — Firebase Analytics fires before consent | Themis §1.1, PS-01 | 🔴 BLOCKER | `lib/main.dart`, new `consent_screen.dart` |
| 2 | **Firebase Analytics NOT disabled by default** — missing AndroidManifest meta-data | Themis §1.1, PS-02 | 🔴 BLOCKER | `android/app/src/main/AndroidManifest.xml` |
| 3 | **`perfectionist` achievement broken** — counter logic checks string not count | Argus Species §4, PS-10 | 🔴 P0 | `lib/services/achievement_service.dart` |
| 4 | **`speed_demon` achievement broken** — uses estimated not actual elapsed time | Argus Species §4, PS-11 | 🔴 P0 | `lib/services/achievement_service.dart`, lesson screen |
| 5 | **`comeback` achievement broken** — `lastActivityDate` never populated | Argus Species §4, PS-12 | 🔴 P0 | `lib/services/achievement_service.dart` |
| 6 | **`completionist` achievement unreachable** — counts hidden achievements | Argus Species §4, PS-13 | 🔴 P0 | `lib/services/achievement_service.dart` |
| 7 | **`social_butterfly` achievement broken** — `checkAfterFriendAdded()` never called | Argus Species §4 | 🟡 P1 | `lib/services/achievement_service.dart` |
| 8 | **SyncDebugDialog exposed in production** — no kDebugMode guard | Argus Store §3.2, PS-06 | 🔴 P0 | `lib/widgets/sync_indicator.dart:31` |
| 9 | **Privacy Policy incomplete** — missing OpenAI disclosure, transfers, retention, ICO | Themis §1.3, PS-07 | 🔴 BLOCKER | Privacy policy asset/page |
| 10 | **No data deletion mechanism** | Themis §5.2, PS-08 | 🔴 BLOCKER | `lib/screens/settings_hub_screen.dart` |
| 11 | **SCHEDULE_EXACT_ALARM not declared in Play Console** | Themis §3.3, PS-05 | 🔴 BLOCKER | Play Console (manual) |
| 12 | **Notification permission in dead code** — not in live onboarding flow | Argus Data §1, Argus Nav §4, NT-01 | 🟡 P1 | `lib/screens/onboarding/` |
| 13 | **7 factual errors in lesson content** | Argus Content Quality | 🟡 P1 | `lib/data/lessons/*.dart` |
| 14 | **18 stub/incomplete lessons** presented as complete | Argus Content Lessons | 🟡 P1 | `lib/data/lessons/fish_health.dart` + 2 |
| 15 | **Error colour #D96A6A fails WCAG AA** (~3.0:1 on white) | Argus Store §1.3 | 🟡 P1 | `lib/theme/app_theme.dart` |
| 16 | **`checkAfterReview()` not wired** into spaced repetition | GF-01 | 🟡 P1 | Review screen |
| 17 | **XP cap at 2,500** — hits max too fast | GF-02 | 🟡 P1 | `lib/constants/aquarium_constants.dart` |
| 18 | **Bonus XP bypasses weeklyXP** | GF-03 | 🟡 P1 | Gamification logic |
| 19 | **Supabase placeholder comment in code** | Themis §4.1, PS-03 | 🟡 Low | `lib/services/supabase_service.dart:27` |
| 20 | **69 of 110 screens have zero Semantics** | Argus Store §1.1 | 🟡 P2 | All screens in `lib/screens/` |
| 21 | **9 orphaned screens** (7 dead code + 2 intentionally hidden) | Argus Nav §4 | 🟡 P2 | Various |

## 1.3 What's Missing for V1.0 Submission

| Category | Missing Items | Source |
|----------|--------------|--------|
| **Compliance** | GDPR consent dialog, Firebase default-off, privacy policy v2, data deletion, OpenAI disclosure, Play Console Data Safety | Themis, PS-01/02/07/08/09 |
| **Store** | Screenshots (7), feature graphic, Data Safety form, SCHEDULE_EXACT_ALARM declaration, content rating questionnaire | Aphrodite Screenshot Brief, Themis §3.3 |
| **Content** | 7 factual errors, 18 stub lessons need gating | Argus Content Quality/Lessons |
| **Gamification** | 4 broken achievements | Argus Species §4 |
| **Notifications** | Permission not in live onboarding, scheduling not wired | Argus Data §1, NT-01/02 |
| **Accessibility** | Critical path Semantics (onboarding, achievements, settings), IconButton tooltips, colour contrast | Argus Store §1 |

## 1.4 Dependency State (pubspec.yaml)

| Category | Packages | Status |
|----------|----------|--------|
| State | flutter_riverpod ^2.6.1, riverpod_annotation ^2.6.1 | ✅ |
| Storage | hive ^2.2.3, hive_flutter ^1.1.0, shared_preferences ^2.3.3 | ✅ |
| Firebase | firebase_core ^2.24.2, firebase_analytics ^10.7.4, firebase_crashlytics ^3.4.9 | ✅ |
| Cloud | supabase_flutter ^2.8.4 | ⚠️ Dormant (dart-define gated) |
| AI | http ^1.2.2 (for OpenAI) | ✅ |
| Notifications | flutter_local_notifications ^18.0.1 | ✅ |
| NOT present | purchases_flutter (RevenueCat), permission_handler | ❌ Needed for v1.1 |

---

# PART 2 — V1.0 SUBMISSION ROADMAP (Play Store Ready)

## Execution Principles
1. **Run `flutter analyze` after every sprint** — 0 errors required before moving on
2. **Hephaestus never runs `flutter build`** — Athena handles all builds
3. **Commit after each completed sprint** using conventional commit format
4. **PS-09 / Play Console tasks are manual** — flag to Tiarnan
5. **Privacy policy copy must be reviewed by Tiarnan** before merge

## Sprint Overview

| Sprint | Focus | Tasks | Est. Time | Wave |
|--------|-------|-------|-----------|------|
| 1A | GDPR & Privacy | 4 tasks | 45 min | 1 |
| 1B | Credentials & Pipeline | 3 tasks | 20 min | 1 |
| 1C | Privacy Policy & Deletion | 3 tasks | 30 min | 2 |
| 1D | Broken Achievements | 5 tasks | 40 min | 1 |
| 2A | Factual Quick Fixes | 7 tasks | 20 min | 1 |
| 2B | Stub Content Gating | 1 task | 15 min | 2 |
| 3A | Gamification Polish | 3 tasks | 20 min | 2 |
| 3B | Notification Wiring | 2 tasks | 30 min | 3 |
| 4 | Critical Accessibility | 5 tasks | 25 min | 1 |
| 5 | Dead Code Cleanup | 3 tasks | 15 min | 3 |
| 6 | Submission Preparation | 12 tasks | ~2.5 hrs | 4 |

**Total Hephaestus time:** ~4.5 hours  
**Total Athena time:** ~2 hours  
**Total Tiarnan time:** ~1.5 hours  
**Realistic wall-clock time:** 6-8 hours with parallelisation, reviews, and agent timeouts

---

## SPRINT 1A — GDPR & Privacy (Hephaestus — ~45 min)

### [PS-01] GDPR Consent Dialog
- **Priority:** P0 — LAUNCH BLOCKER
- **Source:** Themis §1.1, HEPHAESTUS_MASTER_FIX_LIST PS-01
- **Files:**
  - `lib/main.dart` ✅ (exists)
  - `lib/services/analytics_service.dart` ✅ (exists)
  - `lib/services/firebase_analytics_service.dart` ✅ (exists)
  - `lib/screens/onboarding/consent_screen.dart` (CREATE)
- **Changes:**
  1. Create `ConsentScreen` widget — two clear buttons: "Accept analytics" / "Decline analytics"
  2. Explain in plain language: "We use Firebase Analytics and Crashlytics to improve the app. Data is sent to Google servers."
  3. Persist consent to `SharedPreferences` key `gdpr_analytics_consent` (bool)
  4. In `main()`: read consent flag before calling `Firebase.initializeApp()` analytics features
  5. Initialise Firebase Core always (crash-safe), but gate Analytics + Crashlytics behind consent
  6. If consent is unknown/undecided, show dialog before home screen on every cold start
  7. Add a "Withdraw consent" toggle in Settings (re-disables analytics)
- **Testing:**
  - [ ] Fresh install → consent dialog shows before home screen
  - [ ] Tap "Decline" → zero Firebase Analytics events fire (verify via Firebase DebugView)
  - [ ] Tap "Accept" → analytics events fire normally
  - [ ] Consent persists across app restarts — dialog doesn't re-appear after decision
  - [ ] Withdraw consent in Settings → analytics stops
  - [ ] flutter analyze passes
  - [ ] Device test needed? YES — verify no traffic fires before consent
- **Risk:** Breaking Firebase initialisation order could crash the app
- **Rollback:** Revert consent_screen.dart, restore original main.dart Firebase init
- **Dependencies:** None
- **Estimated time:** 15 min

### [PS-02] Firebase Analytics Disabled by Default
- **Priority:** P0 — LAUNCH BLOCKER
- **Source:** Themis §1.1, HEPHAESTUS_MASTER_FIX_LIST PS-02
- **Files:**
  - `android/app/src/main/AndroidManifest.xml` ✅ (exists)
  - `lib/services/firebase_analytics_service.dart` ✅ (exists)
- **Changes:**
  1. Add `<meta-data android:name="firebase_analytics_collection_enabled" android:value="false"/>` inside `<application>` in AndroidManifest.xml
  2. After user accepts consent (PS-01), call `FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true)` at runtime
  3. Wrap all analytics calls in a guard: `if (await _isConsentGiven()) { ... }`
- **Testing:**
  - [ ] AndroidManifest.xml contains the meta-data entry
  - [ ] Verify via Firebase DebugView: zero events before consent
  - [ ] After consent, events fire normally
  - [ ] flutter analyze passes
  - [ ] Device test needed? YES
- **Risk:** Low — additive change to manifest
- **Rollback:** Remove meta-data line from AndroidManifest.xml
- **Dependencies:** Must pair with PS-01
- **Estimated time:** 10 min

### [PS-06] SyncDebugDialog kDebugMode Guard
- **Priority:** P0
- **Source:** Argus Store §3.2, HEPHAESTUS_MASTER_FIX_LIST PS-06
- **Files:**
  - `lib/widgets/sync_indicator.dart` ✅ (exists, line 31 — `builder: (context) => const SyncDebugDialog()`)
  - `lib/widgets/sync_debug_dialog.dart` ✅ (exists)
- **Changes:**
  1. Wrap the `showModalBottomSheet` call at `sync_indicator.dart:31` with `if (kDebugMode) { ... }`
  2. Import `package:flutter/foundation.dart`
- **Testing:**
  - [ ] Tap sync indicator in release build → no dialog appears
  - [ ] Tap sync indicator in debug build → dialog still works
  - [ ] flutter analyze passes
  - [ ] Device test needed? YES (verify in release APK)
- **Risk:** Very low — single guard
- **Rollback:** Remove kDebugMode guard
- **Dependencies:** None
- **Estimated time:** 5 min

### [PS-OAI] OpenAI Disclosure Consent (GAP — not in original fix list)
- **Priority:** P0
- **Source:** Themis §1.3 (OpenAI data sharing), Argus Data §4
- **Files:**
  - `lib/features/smart/fish_id/fish_id_screen.dart` ✅ (exists)
  - `lib/services/openai_service.dart` ✅ (exists)
- **Changes:**
  1. Before the first Fish ID use, show a one-time notice dialog: "Photos you submit are sent to OpenAI's servers in the United States for identification. OpenAI may retain them for up to 30 days."
  2. Persist acknowledgement to SharedPreferences key `openai_disclosure_accepted` (bool)
  3. If not accepted, don't allow the Fish ID request to proceed
  4. Include this in the privacy policy (PS-07)
- **Testing:**
  - [ ] First Fish ID attempt → disclosure dialog appears
  - [ ] Dismiss without accepting → cannot use Fish ID
  - [ ] Accept → Fish ID works normally, dialog doesn't re-appear
  - [ ] flutter analyze passes
  - [ ] Device test needed? YES
- **Risk:** Low — additive dialog
- **Rollback:** Remove disclosure check
- **Dependencies:** None
- **Estimated time:** 15 min

---

## SPRINT 1B — Credentials & Pipeline Safety (Hephaestus — ~20 min)

### [PS-03] Verify Supabase Credentials Fully Removed
- **Priority:** P0
- **Source:** Themis §4.1, HEPHAESTUS_MASTER_FIX_LIST PS-03
- **Files:**
  - `lib/services/supabase_service.dart` ✅ (exists — line 27 has comment with `supabase.com` URL)
- **Changes:**
  1. Run `grep -rn "supabase.co\|eyJhbGci\|supabase.com" lib/` — verify only comments remain
  2. Sprint 3 already converted to dart-define — verify `String.fromEnvironment` pattern in place
  3. Remove any remaining URL comments that reference actual project URLs
  4. Add runtime assertion: `assert(supabaseUrl.isEmpty || supabaseUrl.startsWith('http'), 'Invalid SUPABASE_URL')`
- **Testing:**
  - [ ] `grep -rn "supabase.co\|eyJhbGci" lib/` returns 0 results (excluding comments about setup)
  - [ ] Release build without SUPABASE_URL → Supabase silently disabled (already guarded)
  - [ ] flutter analyze passes
  - [ ] Device test needed? No
- **Risk:** Very low — verification pass
- **Rollback:** N/A
- **Dependencies:** None
- **Estimated time:** 5 min

### [PS-04] OpenAI API Key Startup Assertion
- **Priority:** P0
- **Source:** Themis §5.2, HEPHAESTUS_MASTER_FIX_LIST PS-04
- **Files:**
  - `lib/services/openai_service.dart` ✅ (exists)
- **Changes:**
  1. Confirm `OPENAI_API_KEY` is read via `String.fromEnvironment('OPENAI_API_KEY')`
  2. Add startup assertion: `assert(openAiKey.isNotEmpty, 'OPENAI_API_KEY must be set via dart-define')`
  3. In the UI: if key is empty, show "AI features unavailable" instead of a crash
- **Testing:**
  - [ ] Build without `--dart-define=OPENAI_API_KEY` → assertion fires in debug, graceful message in release
  - [ ] Build with key → Fish ID works normally
  - [ ] flutter analyze passes
  - [ ] Device test needed? No
- **Risk:** Very low
- **Rollback:** Remove assertion
- **Dependencies:** None
- **Estimated time:** 5 min

### [PS-05] SCHEDULE_EXACT_ALARM — Decision & Declaration
- **Priority:** P0
- **Source:** Themis §3.3, HEPHAESTUS_MASTER_FIX_LIST PS-05
- **Files:**
  - `android/app/src/main/AndroidManifest.xml` ✅ (exists — permission already declared with justification comment)
  - `lib/services/notification_service.dart` ✅ (exists — already has `canScheduleExactNotifications()` check with fallback)
- **Changes:**
  1. **Keep SCHEDULE_EXACT_ALARM** — water change reminders at user-set times require exact timing
  2. Add `USE_EXACT_ALARM` as the SDK 33+ alternative in AndroidManifest
  3. Document justification for Play Console declaration form (for Tiarnan): "User-scheduled water change and streak reminder notifications at specific times set by the user"
  4. Write justification to `docs/PLAY_CONSOLE_DECLARATIONS.md`
- **Testing:**
  - [ ] AndroidManifest has both SCHEDULE_EXACT_ALARM and USE_EXACT_ALARM
  - [ ] Notification scheduling still works on SDK 33+
  - [ ] flutter analyze passes
  - [ ] Device test needed? YES (test notification on Z Fold)
- **Risk:** Low — permission already declared and working
- **Rollback:** N/A
- **Dependencies:** None (Play Console declaration is Tiarnan's task — T3)
- **Estimated time:** 10 min

---

## SPRINT 1C — Privacy Policy & Data Deletion (Hephaestus — ~30 min)

### [PS-07] Privacy Policy v2
- **Priority:** P0 — LAUNCH BLOCKER
- **Source:** Themis §1.3, HEPHAESTUS_MASTER_FIX_LIST PS-07
- **Files:**
  - `docs/privacy-policy-v2.md` (CREATE — draft for Tiarnan review)
  - GitHub Pages: `privacy-policy.html` (UPDATE after approval)
- **Changes:**
  Draft the following 6 required sections:
  1. **OpenAI disclosure** — "We use OpenAI's API to process fish identification requests. Your images are sent to OpenAI's servers in the United States. OpenAI retains API data for up to 30 days. OpenAI's privacy policy applies."
  2. **International transfers** — GDPR Article 46 SCCs disclosure for US data transfers (OpenAI, Firebase)
  3. **Retention periods** — Firebase Analytics: 2 months; Crashlytics: 90 days; OpenAI images: 30 days; Local data: until app uninstall
  4. **Legal basis** — Consent for analytics (Art. 6(1)(a)); legitimate interest for crash reports (Art. 6(1)(f)); contract for core features (Art. 6(1)(b))
  5. **ICO complaint right** — "You have the right to lodge a complaint with the Information Commissioner's Office (ico.org.uk)"
  6. **Data deletion** — Dedicated "Right to Erasure" section with email: `privacy@tiarnanlarkin.com` (or similar)
- **Testing:**
  - [ ] All 6 sections present in draft
  - [ ] Tiarnan has reviewed and approved copy (**⚠️ BLOCKS MERGE**)
  - [ ] Privacy policy accessible from app (Settings → About → Privacy Policy link)
  - [ ] flutter analyze passes
  - [ ] Device test needed? No (content review)
- **Risk:** Low — content change only. BUT requires Tiarnan sign-off
- **Rollback:** Revert to v1 privacy policy
- **Dependencies:** PS-01 (consent dialog design informs consent language)
- **Estimated time:** 15 min (draft), then blocked on Tiarnan review

### [PS-08] Data Deletion Mechanism
- **Priority:** P0 — LAUNCH BLOCKER
- **Source:** Themis §5.2, HEPHAESTUS_MASTER_FIX_LIST PS-08
- **Files:**
  - `lib/screens/settings_hub_screen.dart` ✅ (exists)
  - `lib/screens/account_screen.dart` ✅ (exists)
- **Changes:**
  1. Add "Delete My Data" option in Settings Hub or Account screen
  2. Tap → confirmation dialog: "This will permanently delete all your local data (tanks, progress, achievements). This cannot be undone."
  3. On confirm: clear all SharedPreferences, delete local JSON files, reset onboarding state, show "Data deleted" and return to onboarding
  4. Since Supabase is dormant: also display `privacy@tiarnanlarkin.com` for any residual server-side deletion requests
  5. Link to this mechanism in Privacy Policy (PS-07)
- **Testing:**
  - [ ] "Delete My Data" visible in settings
  - [ ] Confirmation dialog shows with warning text
  - [ ] Confirming → all local data cleared (verify SharedPreferences empty)
  - [ ] App returns to fresh/onboarding state after deletion
  - [ ] Cancel → no data deleted
  - [ ] flutter analyze passes
  - [ ] Device test needed? YES
- **Risk:** Medium — must not accidentally delete data without confirmation
- **Rollback:** Remove the Delete option from settings
- **Dependencies:** None
- **Estimated time:** 15 min

### [PS-09-DOC] Play Console Data Safety Documentation
- **Priority:** P0 — LAUNCH BLOCKER (manual step)
- **Source:** Themis §5.1, HEPHAESTUS_MASTER_FIX_LIST PS-09
- **Files:**
  - `docs/PLAY_CONSOLE_DECLARATIONS.md` (CREATE)
- **Changes:**
  Write a reference document for Tiarnan listing every data type to declare:
  
  | Data Type | Collection | Sharing | Purpose | Encryption |
  |-----------|-----------|---------|---------|------------|
  | Device/other IDs (AAID) | Yes (Firebase) | Shared w/ Google | Analytics | Yes |
  | App activity (6 events) | Yes (Firebase) | Shared w/ Google | Analytics | Yes |
  | Crash logs | Yes (Crashlytics) | Shared w/ Google | Crash reporting | Yes |
  | Photos (fish ID) | Yes | Shared w/ OpenAI | App functionality | Yes (transit) |
  
  + Deletion mechanism: YES (PS-08)  
  + Encryption in transit: YES (HTTPS)
- **Testing:**
  - [ ] Document complete with all data types
  - [ ] Tiarnan can fill Play Console form directly from this doc
  - [ ] flutter analyze passes (no code change)
  - [ ] Device test needed? No
- **Risk:** None — documentation only
- **Rollback:** N/A
- **Dependencies:** PS-07, PS-08 must be done first
- **Estimated time:** 10 min (writing doc)

---

## SPRINT 1D — Broken Achievements (Hephaestus — ~40 min)

### [PS-10] Perfectionist Achievement Fix
- **Priority:** P0
- **Source:** Argus Species §4, HEPHAESTUS_MASTER_FIX_LIST PS-10
- **Files:**
  - `lib/models/user_profile.dart` ✅ (exists)
  - `lib/services/achievement_service.dart` ✅ (exists)
- **Changes:**
  1. Add `perfectScoreCount` field (int, default 0) to user profile model
  2. Persist `perfectScoreCount` to SharedPreferences alongside other stats
  3. In lesson completion handler: check if score was 100% → increment `perfectScoreCount`
  4. In `checkAchievements()`: evaluate `perfectScoreCount >= 10` for `perfectionist`
- **Testing:**
  - [ ] Complete lesson with 100% → `perfectScoreCount` increments
  - [ ] Complete lesson with <100% → `perfectScoreCount` unchanged
  - [ ] After 10 perfect scores → `perfectionist` achievement unlocks
  - [ ] flutter analyze passes
  - [ ] Device test needed? No (logic test)
- **Risk:** Low — additive field
- **Rollback:** Remove `perfectScoreCount` field
- **Dependencies:** None
- **Estimated time:** 10 min

### [PS-11] Speed Demon Achievement Fix
- **Priority:** P0
- **Source:** Argus Species §4, HEPHAESTUS_MASTER_FIX_LIST PS-11
- **Files:**
  - `lib/screens/lesson_screen.dart` ✅ (exists)
  - `lib/services/achievement_service.dart` ✅ (exists)
- **Changes:**
  1. Record `lessonStartTime = DateTime.now()` when lesson screen initialises
  2. On lesson completion: `actualElapsedSeconds = DateTime.now().difference(lessonStartTime).inSeconds`
  3. Pass `actualElapsedSeconds` (not `widget.lesson.estimatedMinutes * 60`) to achievement check
  4. `speed_demon` condition: `actualElapsedSeconds < 120`
- **Testing:**
  - [ ] Fast lesson completion (<2 min) → `speed_demon` unlocks
  - [ ] Normal pace completion → does NOT unlock
  - [ ] flutter analyze passes
  - [ ] Device test needed? No
- **Risk:** Low — changing one parameter source
- **Rollback:** Revert to estimated duration
- **Dependencies:** None
- **Estimated time:** 10 min

### [PS-12] Comeback Achievement Fix
- **Priority:** P0
- **Source:** Argus Species §4, HEPHAESTUS_MASTER_FIX_LIST PS-12
- **Files:**
  - `lib/services/achievement_service.dart` ✅ (exists)
  - `lib/models/user_profile.dart` ✅ (exists)
- **Changes:**
  1. In `checkAfterLesson()`: check `lastActivityDate` gap BEFORE updating it
  2. Set `lastActivityDate = DateTime.now()` AFTER the check
  3. Persist `lastActivityDate` to SharedPreferences after every lesson
  4. `comeback` condition: `DateTime.now().difference(lastActivityDate).inDays >= 30`
- **Testing:**
  - [ ] Set `lastActivityDate` to 31 days ago → complete lesson → `comeback` unlocks
  - [ ] Recent activity → `comeback` does NOT unlock
  - [ ] flutter analyze passes
  - [ ] Device test needed? No
- **Risk:** Low — order-of-operations fix
- **Rollback:** Revert check order
- **Dependencies:** None
- **Estimated time:** 5 min

### [PS-13] Completionist Achievement Fix
- **Priority:** P0
- **Source:** Argus Species §4, HEPHAESTUS_MASTER_FIX_LIST PS-13
- **Files:**
  - `lib/services/achievement_service.dart` ✅ (exists)
  - `lib/data/achievements.dart` ✅ (exists)
  - `lib/models/achievements.dart` ✅ (exists)
- **Changes:**
  1. Filter denominator: `achievements.where((a) => !a.isHidden).length`
  2. Filter numerator: `unlockedAchievements.where((a) => !a.isHidden).length`
  3. `completionist` condition: visible unlocked == visible total (excluding `completionist` itself)
- **Testing:**
  - [ ] With hidden achievements excluded, count matches expected
  - [ ] When all visible achievements unlocked → `completionist` fires
  - [ ] flutter analyze passes
  - [ ] Device test needed? No
- **Risk:** Low
- **Rollback:** Revert filter logic
- **Dependencies:** PS-10, PS-11, PS-12 (those 4 broken achievements must be fixed first for completionist to be reachable)
- **Estimated time:** 5 min

### [PS-SB] Social Butterfly — Mark as Hidden (GAP FILLED)
- **Priority:** P0
- **Source:** Argus Species §4 — `social_butterfly` requires friends feature (CA-002, hidden)
- **Files:**
  - `lib/data/achievements.dart` ✅ (exists)
- **Changes:**
  1. Set `social_butterfly` achievement to `isHidden: true` (since friends feature is hidden behind CA-002)
  2. This ensures it doesn't block `completionist` since friends aren't available
- **Testing:**
  - [ ] `social_butterfly` no longer appears in visible achievements list
  - [ ] `completionist` denominator excludes it
  - [ ] flutter analyze passes
  - [ ] Device test needed? No
- **Risk:** Very low
- **Rollback:** Set isHidden back to false
- **Dependencies:** None
- **Estimated time:** 5 min

---

## SPRINT 2A — Factual Quick Fixes (Hephaestus — ~20 min)

### [CQ-01] Betta Minimum Tank Size
- **Priority:** P1
- **Source:** Argus Content Quality §Error 1
- **Files:** `lib/data/lessons/species_care.dart` ✅
- **Changes:** `"Minimum 10 gallons (40 litres)"` → `"Minimum 5 gallons (19 litres), 10 gallons is ideal"`
- **Testing:** [ ] String updated [ ] flutter analyze passes [ ] Device test: No
- **Risk:** None | **Rollback:** Revert string | **Dependencies:** None | **Est:** 2 min

### [CQ-02] Goldfish Fancy/Common Sentence
- **Priority:** P1
- **Source:** Argus Content Quality §Error 2
- **Files:** `lib/data/lessons/species_care.dart` ✅
- **Changes:** Remove or rewrite "Fancy goldfish need less space than commons/comets" — this is factually backwards
- **Testing:** [ ] String updated [ ] flutter analyze passes | **Est:** 2 min

### [CQ-03] Ammonia Odour Quiz Explanation
- **Priority:** P1
- **Source:** Argus Content Quality §Error 3
- **Files:** `lib/data/lessons/nitrogen_cycle.dart` ✅
- **Changes:** Replace "Ammonia is colorless and odorless" with "Ammonia is colorless at typical aquarium levels — you can't see it. While it does have a faint smell, you can't reliably detect low levels. Only a test kit gives accurate readings."
- **Testing:** [ ] String updated [ ] flutter analyze passes | **Est:** 2 min

### [CQ-04] Livebearer GH Range
- **Priority:** P1
- **Source:** Argus Content Quality §Error 4
- **Files:** `lib/data/lessons/water_parameters.dart` ✅
- **Changes:** `"10-20 dGH"` → `"10-16 dGH"`
- **Testing:** [ ] String updated [ ] flutter analyze passes | **Est:** 1 min

### [CQ-05] CO₂ Atmospheric Level
- **Priority:** P1
- **Source:** Argus Content Quality §Error 7
- **Files:** `lib/data/lessons/planted_tank.dart` ✅
- **Changes:** `"2-5 ppm"` → `"3-5 ppm"`
- **Testing:** [ ] String updated [ ] flutter analyze passes | **Est:** 1 min

### [CQ-06] Placement Test Goldfish Temp
- **Priority:** P1
- **Source:** Argus Content Quality §Error 6
- **Files:** `lib/data/placement_test_content.dart` ✅
- **Changes:** `"75-80°F"` → `"75-82°F"`
- **Testing:** [ ] String updated [ ] flutter analyze passes | **Est:** 1 min

### [CQ-07] Ammonia Toxicity Level
- **Priority:** P1
- **Source:** Argus Content Quality §Error 5
- **Files:** `lib/data/lessons/nitrogen_cycle.dart` ✅
- **Changes:** `"Even 0.25 ppm can stress fish"` → `"Even 0.5 ppm can stress fish; levels above 2 ppm are dangerous for most species"`
- **Testing:** [ ] String updated [ ] flutter analyze passes | **Est:** 2 min

---

## SPRINT 2B — Stub Content Gating (Hephaestus — ~15 min)

### [CG-01] Gate Stub Lessons Behind "Coming Soon"
- **Priority:** P1
- **Source:** Argus Content Quality §Flag 2-4, Argus Content Lessons
- **Files:**
  - `lib/data/lessons/fish_health.dart` ✅ — stubs: `fh_ich`, `fh_fin_rot`, `fh_fungal`, `fh_parasites`, `fh_hospital_tank`
  - `lib/data/lessons/species_care.dart` ✅ — stubs: `sc_tetras`, `sc_cichlids`, `sc_shrimp`, `sc_snails`
  - `lib/data/lessons/advanced_topics.dart` ✅ — all 6 lessons are stubs
  - `lib/providers/lesson_provider.dart` ✅
- **Changes:**
  1. Add `isStub: true` flag to each stub lesson definition (or add lesson IDs to a `stubLessonIds` set)
  2. In the learn screen / lesson provider: if `isStub`, show "Coming Soon 🚧" badge and disable tap-to-open
  3. Keep `fh_prevention` (Fish Health lesson 1) accessible — it has real content and 1 quiz question
  4. Keep `sc_betta` and `sc_goldfish` accessible — they have real (if thin) content
  5. Total: gate 15 stub lessons, keep 3 fish health/species care lessons accessible
- **Testing:**
  - [ ] Stub lessons show "Coming Soon" badge in lesson list
  - [ ] Tapping a stub lesson does NOT open it
  - [ ] Non-stub lessons still open normally
  - [ ] `fh_prevention`, `sc_betta`, `sc_goldfish` remain accessible
  - [ ] flutter analyze passes
  - [ ] Device test needed? YES (verify UI appearance)
- **Risk:** Low — UI gating only
- **Rollback:** Remove isStub flag
- **Dependencies:** Sprint 2A (content fixes applied first)
- **Estimated time:** 15 min

---

## SPRINT 3A — Gamification Polish (Hephaestus — ~20 min)

### [GF-01] Wire checkAfterReview() into Spaced Repetition
- **Priority:** P1
- **Source:** HEPHAESTUS_MASTER_FIX_LIST GF-01
- **Files:**
  - `lib/screens/spaced_repetition_practice_screen.dart` ✅ (exists)
  - `lib/services/achievement_service.dart` ✅ (exists)
- **Changes:**
  1. In review screen completion handler, call `await achievementService.checkAfterReview(result)`
  2. Pass review session result (score, duration, streak) into the method
  3. Display any newly unlocked achievement overlays
- **Testing:** [ ] Review session → achievement evaluation fires [ ] No double-counting [ ] flutter analyze passes
- **Risk:** Low | **Dependencies:** Sprint 1D (achievement fixes) | **Est:** 10 min

### [GF-02] Extend XP Cap to 10,000+
- **Priority:** P1
- **Source:** HEPHAESTUS_MASTER_FIX_LIST GF-02, Argus Species §3
- **Files:**
  - `lib/constants/aquarium_constants.dart` ✅ (exists — search for `2500` or `maxXP`)
  - `lib/widgets/gamification_dashboard.dart` ✅ (exists)
  - `lib/models/user_profile.dart` ✅ (exists)
- **Changes:**
  1. Replace XP cap constant from `2500` to `10000`
  2. Verify XP bar UI scales correctly to 10,000
  3. Add level 8 (5,000 XP, "Sage") and level 9 (10,000 XP, "Grandmaster") titles
- **Testing:** [ ] XP accumulates beyond 2,500 [ ] UI renders correctly at all levels [ ] flutter analyze passes
- **Risk:** Low | **Dependencies:** None | **Est:** 5 min

### [GF-03] Route Bonus XP Through weeklyXP
- **Priority:** P1
- **Source:** HEPHAESTUS_MASTER_FIX_LIST GF-03
- **Files:**
  - `lib/widgets/gamification_dashboard.dart` ✅ or wherever XP award logic lives
  - `lib/models/user_profile.dart` ✅
- **Changes:**
  1. Find where streak bonus XP and achievement bonus XP are awarded
  2. Ensure both call the same `_addXP(amount)` method that also increments `weeklyXP`
  3. If bonuses bypass `_addXP` (direct field increment), route them through it
- **Testing:** [ ] Streak bonus → `weeklyXP` increments [ ] `totalXP` and `weeklyXP` stay in sync [ ] flutter analyze passes
- **Risk:** Low | **Dependencies:** None | **Est:** 5 min

---

## SPRINT 3B — Notification Wiring (Hephaestus — ~30 min)

### [NT-01] Move Notification Permission to Live Onboarding
- **Priority:** P1
- **Source:** Argus Data §1, Argus Nav §4, HEPHAESTUS_MASTER_FIX_LIST NT-01
- **Files:**
  - `lib/screens/onboarding_screen.dart` ✅ (exists) OR `lib/screens/onboarding/journey_reveal_screen.dart` ✅
  - `lib/screens/onboarding/enhanced_tutorial_walkthrough_screen.dart` ✅ (current dead code location)
  - `lib/services/notification_service.dart` ✅ (exists)
- **Changes:**
  1. Add notification permission step in live onboarding after GDPR consent (PS-01), before `JourneyRevealScreen`
  2. Value proposition: "Get reminded about water changes and streak goals 💧"
  3. "Allow" → call `NotificationService().requestPermissions()`
  4. "Not now" → skip, don't block onboarding
  5. Store result in SharedPreferences: `notification_permission_requested` (bool)
- **Testing:**
  - [ ] Fresh install onboarding includes notification step
  - [ ] Denying permission does NOT crash or block
  - [ ] Permission request only fires once per install
  - [ ] On Android 13+, system dialog appears correctly
  - [ ] flutter analyze passes
  - [ ] Device test needed? YES
- **Risk:** Medium — touches onboarding flow
- **Rollback:** Remove notification step from onboarding
- **Dependencies:** PS-01 (GDPR consent must come before notification permission)
- **Estimated time:** 15 min

### [NT-02] Wire Notification Scheduling
- **Priority:** P1
- **Source:** HEPHAESTUS_MASTER_FIX_LIST NT-02
- **Files:**
  - `lib/services/notification_service.dart` ✅ (exists — channels already configured)
  - `lib/screens/tank_detail/tank_detail_screen.dart` ✅ (exists)
- **Changes:**
  1. **Water change reminders:** When user sets/updates tank water change schedule, call `NotificationService.scheduleWaterChangeReminder(tankId, nextDueDate)` — use existing `water_change_reminders` channel
  2. **Streak nudge:** At end of day (or app backgrounding), if no lesson completed, schedule morning nudge via `streak_reminders` channel
  3. Cancel existing notifications before re-scheduling (avoid duplicates)
  4. Skip scheduling silently if permission denied
- **Testing:**
  - [ ] Water change reminder fires at correct date/time
  - [ ] Streak nudge fires if no lesson completed by end of day
  - [ ] Notifications not duplicated on app restart
  - [ ] Settings toggle can disable each notification type
  - [ ] flutter analyze passes
  - [ ] Device test needed? YES (simulators unreliable for local notifications)
- **Risk:** Medium — notification timing edge cases
- **Rollback:** Remove scheduling calls (channels remain)
- **Dependencies:** NT-01 (permission must be requested first)
- **Estimated time:** 15 min

---

## SPRINT 4 — Critical Path Accessibility (Hephaestus — ~25 min)

### [AC-01] Semantics on Onboarding Screens
- **Priority:** P1
- **Source:** Argus Store §1.1, HEPHAESTUS_MASTER_FIX_LIST AC-01
- **Files:**
  - `lib/screens/onboarding_screen.dart` ✅
  - `lib/screens/onboarding/personalisation_screen.dart` ✅
  - `lib/screens/onboarding/journey_reveal_screen.dart` ✅
  - New `consent_screen.dart` (from PS-01)
- **Changes:** Wrap major UI elements in `Semantics` with `label`, `hint`, `button`. Images get descriptive labels. Step indicators get "Step X of Y". CTAs already readable via Text children — verify.
- **Testing:** [ ] TalkBack reads all elements [ ] Navigation order logical [ ] flutter analyze passes
- **Risk:** Low | **Dependencies:** PS-01 (consent screen must exist) | **Est:** 8 min

### [AC-02] Semantics on Achievements Screen
- **Priority:** P1
- **Source:** Argus Store §1.1, HEPHAESTUS_MASTER_FIX_LIST AC-02
- **Files:** `lib/screens/achievements_screen.dart` ✅
- **Changes:** Each card: `Semantics(label: '${name}. ${desc}. ${isUnlocked ? "Unlocked" : "Locked"}')`
- **Testing:** [ ] TalkBack reads name, desc, state [ ] Progress announced [ ] flutter analyze passes
- **Risk:** Low | **Dependencies:** None | **Est:** 5 min

### [AC-03] Semantics on Settings Screen
- **Priority:** P1
- **Source:** HEPHAESTUS_MASTER_FIX_LIST AC-03
- **Files:** `lib/screens/settings_hub_screen.dart` ✅
- **Changes:** Each row: `Semantics(label: 'Setting name. Currently enabled/disabled')`
- **Testing:** [ ] TalkBack reads setting + state [ ] flutter analyze passes
- **Risk:** Low | **Dependencies:** None | **Est:** 3 min

### [AC-04] Label All IconButton Instances
- **Priority:** P1
- **Source:** HEPHAESTUS_MASTER_FIX_LIST AC-04
- **Files:** All files containing `IconButton(` — run `grep -rn "IconButton(" lib/ | wc -l` to get full count (estimated 30+)
- **Changes:** Add `tooltip:` to every `IconButton` that lacks one. Prioritise: nav bars, lesson controls, tank actions, home screen.
- **Testing:** [ ] Zero untipped IconButtons [ ] TalkBack announces purpose for each [ ] flutter analyze passes
- **Risk:** Low — additive | **Dependencies:** None | **Est:** 10 min

### [AC-05] Fix Error/Success Colour Contrast
- **Priority:** P1 (WCAG AA compliance)
- **Source:** Argus Store §1.3, HEPHAESTUS_MASTER_FIX_LIST AC-05
- **Files:** `lib/theme/app_theme.dart` ✅
- **Changes:**
  - `#D96A6A` (error) → `#C0392B` (ratio ~5.1:1 on white)
  - `#5AAF7A` (success) → `#1E8449` (ratio ~5.5:1 on white)
  - `#5C9FBF` (info) → `#2E86AB` (ratio ~4.7:1 on white)
  - Update all direct hex usages and theme references
  - Verify dark mode compatibility
- **Testing:** [ ] All 3 colours ≥4.5:1 on white [ ] Visual coherence maintained [ ] Dark mode OK [ ] flutter analyze passes
- **Risk:** Low — colour change only | **Dependencies:** None | **Est:** 5 min

---

## SPRINT 5 — Dead Code Cleanup (Hephaestus — ~15 min)

### [CC-01] Remove 7 Orphaned Screens
- **Priority:** P2 (but reduces APK size and audit surface)
- **Source:** Argus Nav §4
- **Files (verified to exist):**
  - `lib/screens/rooms/study_screen.dart` — zero navigation calls
  - `lib/screens/aquarium_supply_screen.dart` — zero navigation calls
  - `lib/screens/enhanced_quiz_screen.dart` — replaced by LessonScreen + PracticeScreen
  - `lib/screens/placement_test_screen.dart` — old version, replaced by `EnhancedPlacementTestScreen`
  - `lib/screens/stories_screen.dart` — only via never-instantiated `StoriesCard`
  - `lib/screens/story_player_screen.dart` — only from orphaned `StoriesScreen`
  - `lib/screens/activity_feed_screen.dart` — only via never-instantiated `FriendActivityWidget`
  - **KEEP:** `lib/screens/friends_screen.dart` (CA-002), `lib/screens/leaderboard_screen.dart` (CA-003)
- **Changes:** Delete the 7 files. Remove any imports referencing them. Run `flutter analyze`.
- **Testing:** [ ] All 7 files deleted [ ] No broken imports [ ] flutter analyze passes [ ] App launches normally
- **Risk:** Low — verified unreachable | **Rollback:** `git checkout -- <file>` | **Dependencies:** None | **Est:** 5 min

### [CC-02] Remove Dead Notification Code
- **Priority:** P2
- **Source:** HEPHAESTUS_MASTER_FIX_LIST CC-02
- **Files:** `lib/screens/onboarding/enhanced_tutorial_walkthrough_screen.dart` ✅
- **Changes:** After NT-01 moves notification permission to live onboarding, remove the dead code path from `EnhancedTutorialWalkthroughScreen`
- **Testing:** [ ] flutter analyze — no unused imports/variables [ ] App works [ ] flutter analyze passes
- **Risk:** Low | **Dependencies:** NT-01 | **Est:** 5 min

### [CC-03] Remove Dead Widgets
- **Priority:** P2
- **Source:** Argus Nav §5
- **Files:** Search for `StoriesCard` and `FriendActivityWidget` — these are defined but never instantiated
- **Changes:** Delete the widget classes. Remove imports.
- **Testing:** [ ] `grep -rn "StoriesCard\|FriendActivityWidget" lib/` returns 0 [ ] flutter analyze passes
- **Risk:** Low | **Dependencies:** CC-01 (stories screen removed) | **Est:** 5 min

---

## SPRINT 6 — Submission Preparation (Athena + Tiarnan)

### 6A: Build & Verify (Athena — ~30 min)

### [SUB-01] Flutter Analyze Final
- **Priority:** P0
- **Source:** All sprints
- **Changes:** Run `flutter analyze --no-pub` on full codebase. Must be 0 errors, 0 warnings.
- **Testing:** [ ] 0 errors [ ] 0 warnings
- **Dependencies:** ALL sprints 1A-5 complete
- **Est:** 5 min

### [SUB-02] Signed AAB Build
- **Priority:** P0
- **Changes:** `flutter build appbundle --dart-define=OPENAI_API_KEY=...`
- **Testing:** [ ] Build succeeds [ ] AAB file created
- **Dependencies:** SUB-01
- **Est:** 10 min (build time ~7 min)

### [SUB-03] Smoke Test on Z Fold
- **Priority:** P0 — **TIARNAN REQUIRED**
- **Changes:** Install release APK on Samsung Z Fold. Walk through all 10 critical journeys (see Part 3).
- **Testing:** All 10 journeys pass
- **Dependencies:** SUB-02
- **Est:** 15 min

### 6B: Store Assets (Athena + Tiarnan — ~45 min)

### [SUB-04] Store Screenshots
- **Priority:** P0
- **Source:** Aphrodite Screenshot Brief
- **Changes:**
  1. Create `scripts/store_screenshots.sh` (script spec in Aphrodite brief)
  2. Seed test data on device (XP=2450, streak=14, 8 achievements, demo tank with 6 fish)
  3. Capture 7 screenshots per brief spec (1080×1920, inner display)
  4. Apply caption overlays via ImageMagick (Nunito font, amber scrim)
- **Testing:** [ ] 7 final PNGs at 1080×1920 [ ] Captions readable [ ] No placeholder/debug UI visible
- **Dependencies:** SUB-02 (release build installed)
- **Est:** 20 min

### [SUB-05] Feature Graphic
- **Priority:** P0
- **Changes:** Generate 1024×500 feature graphic per Aphrodite brief (Nano Banana or manual)
- **Testing:** [ ] 1024×500 PNG [ ] Brand-consistent
- **Dependencies:** None
- **Est:** 10 min

### [SUB-06] Store Listing Copy Review
- **Priority:** P0
- **Source:** Aphrodite ASO Launch
- **Changes:** Review `docs/STORE_LISTING.md` against Aphrodite ASO recommendations. Title: "Danio: Learn Fishkeeping & Fish Care". Short desc: "Gamified fishkeeping lessons, quizzes & your virtual aquarium 🐠"
- **Testing:** [ ] Title ≤30 chars [ ] Short desc ≤80 chars [ ] Full desc ≤4000 chars [ ] Keywords seeded
- **Dependencies:** None
- **Est:** 15 min

### 6C: Play Console (Tiarnan — manual)

### [T1] Review Privacy Policy v2 Draft
- **When:** After Sprint 1C delivers draft
- **Blocking:** YES — must approve before merge

### [T2] Fill Play Console Data Safety Section
- **When:** After all code changes
- **Reference:** `docs/PLAY_CONSOLE_DECLARATIONS.md` (from PS-09-DOC)
- **Blocking:** YES

### [T3] Declare SCHEDULE_EXACT_ALARM
- **When:** After all code changes
- **Copy:** "User-scheduled water change and streak reminder notifications at specific times"
- **Blocking:** YES

### [T4] Complete Content Rating Questionnaire
- **Expected:** PEGI 3 (fishkeeping, education, no violence/language)
- **Blocking:** YES

### [T5] Set Target Audience to 18+ Adults
- **Reason:** Avoids COPPA/Children's Code complexity (Themis §2.1 recommendation)
- **Blocking:** YES

### [T6] Smoke Test on Z Fold
- **When:** After AAB build
- **Duration:** ~15 min
- **Blocking:** YES

### [T7] Upload AAB + Submit for Review
- **When:** After all above complete
- **Final step**

---

## Parallelisation Strategy & Dependency Graph

### Wave 1 (can run simultaneously — no file conflicts)
| Sprint | Touches | Conflicts with |
|--------|---------|----------------|
| 1A (GDPR) | main.dart, analytics_service, NEW consent_screen, AndroidManifest | 1B (AndroidManifest only — serialise 1A before 1B) |
| 1D (Achievements) | achievement_service, user_profile, achievements data | None in wave 1 |
| 2A (Content fixes) | lesson .dart data files only | None |
| 4 (Accessibility) | screen widgets (Semantics wrappers), app_theme.dart | None — wrappers don't conflict |

### Wave 2 (after Wave 1)
| Sprint | Dependencies |
|--------|-------------|
| 1B (Credentials) | 1A must finish (both touch AndroidManifest) |
| 1C (Privacy policy) | 1A must finish (consent design informs language) |
| 2B (Stub gating) | 2A must finish (content fixes first) |
| 3A (Gamification) | 1D must finish (achievement fixes first) |

### Wave 3 (after Wave 2)
| Sprint | Dependencies |
|--------|-------------|
| 3B (Notifications) | 1A must finish (GDPR consent before notification permission) |
| 5 (Cleanup) | 3B must finish (dead notification code) |

### Wave 4 (final)
| Sprint | Dependencies |
|--------|-------------|
| 6 (Submission) | ALL waves 1-3 complete |

```
Wave 1:  [1A-GDPR]  [1D-Achievements]  [2A-Content]  [4-A11y]
              │              │                │
Wave 2:  [1B-Creds]  [1C-Privacy]  [2B-Stubs]  [3A-Gamif]
              │              │                      │
Wave 3:           [3B-Notifications]           [5-Cleanup]
                        │                          │
Wave 4:              [6-SUBMISSION PREP]
```

---

# PART 3 — TESTING STRATEGY

## 3.1 Pre-Submission Testing Checklist

### Flutter Analyze Gate
- [ ] `flutter analyze --no-pub` → 0 errors, 0 warnings
- [ ] Run after EVERY sprint, not just at the end

### 10 Critical User Journeys (Must Pass on Physical Device)

#### Journey 1: Fresh Install → Onboarding → First Lesson
```
Steps:
1. Clear app data: adb shell pm clear com.tiarnanlarkin.danio
2. Cold launch app
3. EXPECTED: GDPR consent dialog appears FIRST (PS-01)
4. Accept analytics
5. Swipe through onboarding slides
6. Complete personalisation (experience level + tank status)
7. Notification permission prompt appears (NT-01)
8. Allow/deny → proceeds either way
9. Journey reveal → "Let's go" → TabNavigator
10. Tap Learn tab → tap first lesson → complete it
11. EXPECTED: XP earned, lesson marked complete, streak = 1
PASS: All steps complete without crash or unexpected state
```

#### Journey 2: Create Tank → Add Fish → Log Water Test
```
Steps:
1. Tap Tank tab → Create Tank
2. Enter name ("Test Tank"), select type, set volume
3. Save → tank appears in list
4. Open tank → Add Livestock → search "Neon Tetra" → add
5. Tap "Log Water Test" → enter pH 7.0, NH3 0, NO2 0, NO3 10
6. Save → parameters show green in dashboard
PASS: Tank created, fish added, water test logged, all green
```

#### Journey 3: Fish ID (Camera) → AI Response
```
Steps:
1. Tap Smart tab → Fish ID
2. EXPECTED: OpenAI disclosure dialog (first time only) (PS-OAI)
3. Accept → camera/gallery opens
4. Select/take photo of a fish
5. EXPECTED: AI response with species identification
PASS: Response received without crash, disclosure shown first time
```

#### Journey 4: GDPR Consent → Decline → Verify No Analytics
```
Steps:
1. Fresh install → consent dialog
2. Tap "Decline"
3. Use app normally for 2 minutes
4. EXPECTED: Zero Firebase Analytics events in DebugView/mitmproxy
PASS: No analytics traffic detected
```

#### Journey 5: GDPR Consent → Accept → Verify Analytics Fire
```
Steps:
1. Fresh install → consent dialog
2. Tap "Accept"
3. Complete a lesson
4. EXPECTED: `lesson_complete` event in Firebase DebugView
PASS: Analytics events visible
```

#### Journey 6: Delete Data → Verify Clean State
```
Steps:
1. Use app (create tank, complete lessons, earn XP)
2. Settings → Delete My Data → Confirm
3. EXPECTED: All local data cleared, app returns to onboarding/fresh state
4. Verify: no old tanks, no XP, no achievements
PASS: Clean state after deletion
```

#### Journey 7: Notification Permission → Water Change Reminder Fires
```
Steps:
1. Grant notification permission during onboarding
2. Create tank → set water change schedule to "today" or "1 day"
3. Verify notification is scheduled (check notification shade or wait)
PASS: Notification fires at expected time
```

#### Journey 8: All 5 Tabs Navigate Correctly
```
Steps:
1. Tap each tab: Learn, Practice, Tank, Smart, More
2. Verify each loads without crash
3. Navigate into a sub-screen from each tab
4. Press back → returns to tab
5. Repeat for all 5 tabs
PASS: No crashes, no blank screens, back navigation works
```

#### Journey 9: Achievement Unlocks
```
Steps:
1. Complete first lesson → "First Steps" achievement should unlock
2. Verify XP awarded (50 XP for bronze)
3. Complete 3 lessons in a row (streak test)
4. Verify "Getting Consistent" (3-day streak) unlocks
5. Check achievements screen — unlocked shown, locked shown correctly
PASS: Achievements fire at correct thresholds, display correctly
```

#### Journey 10: Offline Mode → Graceful Degradation
```
Steps:
1. Enable airplane mode on device
2. Open app → lessons should load (local data)
3. Try Fish ID → should show "No internet connection" message
4. Try Supabase sync → should show "Offline" indicator
5. Return to airplane mode off → app resumes normally
PASS: No crashes offline, graceful error messages, resumes online
```

## 3.2 Regression Test Plan

After each sprint, re-test:
| Sprint | Re-test |
|--------|---------|
| 1A (GDPR) | Journey 1, 4, 5 |
| 1B (Credentials) | Journey 3, 10 |
| 1C (Privacy) | Journey 6 |
| 1D (Achievements) | Journey 9 |
| 2A/2B (Content) | Journey 1 (lesson content correct) |
| 3A (Gamification) | Journey 9 |
| 3B (Notifications) | Journey 7 |
| 4 (Accessibility) | Journey 8 (all tabs) |
| 5 (Cleanup) | Journey 8 (no broken navigation) |

## 3.3 Device Testing Requirements

| Test | Physical Z Fold Required? | Can Verify via analyze? |
|------|--------------------------|------------------------|
| GDPR consent flow | YES (Firebase traffic) | No |
| Notification scheduling | YES (local notifications) | No |
| Fish ID / OpenAI | YES (camera + API) | No |
| Achievement logic | No (logic test) | Partially (unit test) |
| Content string fixes | No | Yes (grep) |
| Accessibility / Semantics | YES (TalkBack) | Partially |
| Colour contrast | No (calculation) | No |
| Tab navigation | YES | No |
| Offline mode | YES | No |
| SyncDebugDialog hidden | YES (release build) | No |

## 3.4 Smoke Test Script Outline

```bash
#!/usr/bin/env bash
# qa_pre_submission.sh — Quick smoke test for Danio v1.0
ADB="/mnt/c/Users/larki/AppData/Local/Android/Sdk/platform-tools/adb.exe"
DEVICE="RFCY8022D5R"
PKG="com.tiarnanlarkin.danio"

echo "=== Danio Pre-Submission Smoke Test ==="

# 1. Clean install
echo "1. Clean install..."
$ADB -s $DEVICE shell pm clear $PKG
$ADB -s $DEVICE shell am start -n $PKG/.MainActivity
sleep 5

# 2. Verify consent dialog appears (manual check)
echo "2. CHECK: GDPR consent dialog visible? [y/n]"
read -r consent_check

# 3. Navigate through onboarding (manual)
echo "3. Complete onboarding manually, then press ENTER"
read -r

# 4. Tab navigation test
echo "4. Testing tab navigation..."
for tab_x in 200 400 540 720 880; do
  $ADB -s $DEVICE shell input tap $tab_x 1870
  sleep 1
done
echo "   CHECK: All 5 tabs loaded? [y/n]"
read -r tab_check

# 5. Capture final state
$ADB -s $DEVICE exec-out screencap --display 2 -p > /tmp/smoke_test_final.png
echo "Screenshot saved to /tmp/smoke_test_final.png"
echo "=== Smoke test complete ==="
```

---

# PART 4 — V1.1 POST-LAUNCH ROADMAP

Everything below was identified by research agents but explicitly deferred from v1.0. Each item includes: scope, effort, dependencies, success metrics, and WHY it was deferred.

## 4.1 Onboarding Rewrite (Artemis 10-Screen Spec)

- **Source:** `ARTEMIS_ONBOARDING_SPEC.md` (38K, extremely detailed)
- **Scope:** Replace current 4-screen onboarding with 10-screen flow:
  1. Welcome/Hook (NanaBanana room bg, animated tank)
  2. Experience Level (3 cards, 2 taps)
  3. Tank Status (3 cards, 2 taps)
  4. Micro-Lesson ("The #1 Mistake" — interactive quiz)
  5. First XP Earned (celebration animation)
  6. Add Your Fish (search + select from species DB)
  7. **Personalised Fish Care Reveal** (THE AHA MOMENT — 3 care cards)
  8. Paywall (contextual, fish-specific — requires RevenueCat)
  9. Push Notification Permission
  10. Warm App Entry (personalised home screen)
- **Effort:** 3-5 days (Hephaestus) + design assets (Apollo)
- **Dependencies:** RevenueCat integration (for paywall screen 8), species DB enhancements
- **Success Metrics:** Onboarding completion rate >60% (currently estimated ~55%), aha moment reached within 3 minutes
- **Why deferred:** Current 4-screen flow is functional. Rewrite is high-effort and requires RevenueCat for paywall screen. Ship free v1 first, add paywall + rewrite together.

## 4.2 RevenueCat Integration (Prometheus Billing Decision)

- **Source:** `PROMETHEUS_BILLING_DECISION.md`
- **Scope:** Add `purchases_flutter` package, create `SubscriptionService`, wire paywall
- **Implementation:**
  1. `flutter pub add purchases_flutter`
  2. Create Play Console subscription products: `danio_premium_annual` ($24.99/yr, 7-day trial), `danio_premium_monthly` ($3.99/mo), `danio_lifetime` ($49.99)
  3. Set up RevenueCat dashboard: project, entitlement ("premium"), offerings
  4. Create `lib/services/subscription_service.dart` (ChangeNotifier)
  5. Create `lib/widgets/premium_gate.dart` (reusable gate widget)
  6. Create `lib/screens/paywall_screen.dart` (single entry point, `entryPoint` parameter for analytics)
- **Effort:** 2-3 days (Hephaestus) + RevenueCat dashboard setup (30 min)
- **Dependencies:** Play Console subscription products configured (Tiarnan)
- **Success Metrics:** 4%+ freemium→paid conversion, $500+ MRR by month 3
- **Why deferred:** Free launch strategy to build retention data before monetisation. RevenueCat is free until $2,500/mo revenue.

## 4.3 Paywall Design & Implementation (Apollo + Aphrodite)

- **Source:** `APOLLO_PAYWALL_DESIGN.md` (18K) + `APHRODITE_PAYWALL_STRATEGY.md` (15K)
- **Scope:** 4 paywall variants:
  - **Variant A:** Post-aha moment (primary — fish-specific headline, trial timeline, annual pre-selected)
  - **Variant B:** Streak milestone (Day 7 — "protect your streak")
  - **Variant C:** Content wall (Lesson 4+ — "keep learning")
  - **Variant D:** Species encyclopedia (locked species)
- **Pricing:**
  - Annual: $24.99/yr (UK: £19.99/yr) — "MOST POPULAR"
  - Monthly: $3.99/mo (UK: £2.99/mo)
  - Lifetime: $49.99 (UK: £34.99)
- **Effort:** 3-5 days (Hephaestus) + design (Apollo)
- **Dependencies:** RevenueCat (4.2), Onboarding rewrite (4.1 — for Variant A)
- **Success Metrics:** Trial start rate >30%, annual plan selection >60%
- **Why deferred:** Requires RevenueCat + onboarding rewrite. Ship free first.

## 4.4 Full Notification Sequences (Dionysus)

- **Source:** `DIONYSUS_NOTIFICATION_SEQUENCE.md` — 60+ notification specs
- **Scope:**
  - 30-day daily sequence (Days 1-30)
  - Re-engagement sequence (3/7/14 day silence)
  - 10+ special triggers (first fish, streak milestones, level up, water overdue)
  - Dynamic variables ([fish_name], [species_name], [Level Name])
  - Timing windows (08:00-21:00 local, max 1/day Days 1-14, every 2-3 days after)
- **Effort:** 2-3 days (Hephaestus) — mostly content + scheduling logic
- **Dependencies:** NT-01/NT-02 (basic notification wiring from v1.0)
- **Success Metrics:** Notification open rate >8%, D7 retention improvement >5%
- **Why deferred:** Basic reminders (water change + streak) ship in v1.0. Full sequence is post-launch optimisation.

## 4.5 Content Expansion

- **Source:** Argus Content Lessons, Argus Content Quality
- **Scope:**
  - Write 15 stub lessons fully (Fish Health ×5, Species Care ×4, Advanced Topics ×6)
  - Add 90 quiz questions (5 per stub lesson × 18 lessons, minus 3 already accessible)
  - Add 2 missing equipment lessons (`eq_air_pump`, `eq_substrate`)
  - Fix 9 AI-feeling/generic content flags (Argus Content Quality §Flags 1-9)
  - Expand betta care lesson (sc_betta) — currently 4 sections, needs 8-12
- **Effort:** 15-20 hours (content writing — not code, mostly copy)
- **Dependencies:** CG-01 (stub gating in v1.0)
- **Success Metrics:** 50 fully-written lessons (up from 32), content exhaustion Day >30

## 4.6 Full Accessibility Sweep (64 Remaining Screens)

- **Source:** Argus Store §1.1, HEPHAESTUS_MASTER_FIX_LIST CC-01
- **Scope:** Add Semantics to all 64 remaining screens with zero accessibility annotations
- **Effort:** 3-5 days (systematic, screen-by-screen)
- **Dependencies:** Sprint 4 (critical path accessibility in v1.0)
- **Success Metrics:** 100% screen coverage, accessibility audit score >90

## 4.7 Age Gate (COPPA/Children's Code)

- **Source:** Themis §2.1, §2.2
- **Scope:** Add year-of-birth selector on first launch. Block access + disable analytics for under-13. Declaring 18+ audience in v1.0 sidesteps this temporarily.
- **Effort:** 1 day
- **Dependencies:** None
- **Success Metrics:** COPPA compliance, Children's Code compliance
- **Why deferred:** Declaring 18+ target audience in Play Console avoids this for v1.0.

## 4.8 i18n Infrastructure

- **Source:** Argus Store §2 (40+ hardcoded user-visible strings, no ARB/l10n)
- **Scope:** Create `intl_en.arb`, set up AppLocalizations, migrate all hardcoded strings
- **Effort:** 3-5 days (scaffolding + migration of ~400 strings)
- **Dependencies:** None
- **Success Metrics:** All strings in ARB files, ready for translation

## 4.9 A/B Testing Framework

- **Source:** `PROMETHEUS_AB_TESTS.md` (17K)
- **Scope:** 7 tests in priority order:
  1. Hero screenshot (Play Store Experiments — zero dev work)
  2. Onboarding length (Firebase Remote Config)
  3. Notification permission timing
  4. Paywall headline personalisation
  5. Paywall CTA copy
  6. Free trial framing
  7. Streak mechanic framing ("learning streak" vs "care streak")
- **Dependencies:** Firebase Remote Config (add immediately), sufficient traffic (~100+ daily installs for meaningful tests)
- **Effort:** 1-2 days for instrumentation, then ongoing

## 4.10 Community Launch Plan

- **Source:** `PROMETHEUS_PR_OUTREACH.md` (24K)
- **Scope:**
  - Reddit: r/Aquariums (3.5M), r/androiddev, r/IndieDev, r/Duolingo
  - Product Hunt launch (Tuesday/Wednesday, 12:01am PST)
  - UK press: Practical Fishkeeping magazine, Stuff, T3, The Guardian
  - YouTube: George Farmer, MD Fish Tanks, Girl Talks Fish
  - Facebook: Tropical Fish UK (40-60K), UK Aquarium Keepers (20-35K)
- **Realistic 30-day downloads:** 500-2,000 from zero-budget outreach
- **Dependencies:** Live Play Store listing, screenshots, feature graphic

## 4.11 UK Market Strategy

- **Source:** `PROMETHEUS_UK_LAUNCH.md` (20K)
- **Key actions:**
  1. en-GB Play Store listing (British English, £ pricing)
  2. Practical Fishkeeping magazine outreach
  3. Maidenhead Aquatics partnership (QR code cards with fish purchases)
  4. UK-specific content (regional water hardness, UK LFS species)
  5. FBAS events (Festival of Fishkeeping)

## 4.12 Monitoring + KPI Dashboards

- **Source:** `PROMETHEUS_MONITORING_PLAN.md` (17K)
- **Key metrics:**
  - D1 retention: ≥40%
  - D7 retention: ≥15%
  - D30 retention: ≥8%
  - Onboarding completion: ≥55%
  - Crash-free rate: >99%
  - ANR rate: <0.47%
- **Tools:** Firebase Analytics + Crashlytics (already wired), Firebase Remote Config (add), RevenueCat (when billing ships), AppFollow (review alerts)
- **6 alerts to configure:** Onboarding crisis, engagement cliff, crash emergency, accuracy crisis ("fish died"), conversion target miss, notification fatigue

---

# PART 5 — V1.2+ FEATURE ROADMAP

## 5.1 Social Features (v1.2)
- **Currently:** FriendsScreen (CA-002) and LeaderboardScreen (CA-003) exist but are intentionally hidden
- **Scope:** Shareable tank profile cards, community care notes per species, care milestone cards
- **Note from Dionysus:** Fishkeepers are NOT competitive — leaderboards demotivate the majority. Use "social proof without social pressure" instead.
- **Effort:** 2-4 weeks
- **Dependencies:** Backend (Supabase or dedicated)

## 5.2 Supabase Cloud Sync (v1.2)
- **Currently:** `supabase_flutter` in pubspec, `cloud_sync_service.dart` exists, dormant (dart-define gated)
- **Scope:** Enable cross-device sync for tanks, progress, achievements
- **Effort:** 1-2 weeks
- **Dependencies:** Dedicated Supabase project (not placeholder), GDPR consent update, privacy policy update

## 5.3 Cross-Platform — iOS (v1.3)
- **Scope:** iOS build + App Store submission
- **Effort:** 2-4 weeks (mostly platform-specific: permissions, StoreKit, design guidelines)
- **Dependencies:** RevenueCat (already cross-platform), Apple Developer account

## 5.4 Advanced Content (v1.3+)
- **Breeding guides** (currently stub: `at_breeding_livebearers`, `at_breeding_egg_layers`)
- **Aquascaping** (currently stub: `at_aquascaping`)
- **Biotope aquariums** (currently stub: `at_biotope`)
- **Advanced water chemistry** (currently stub: `at_water_chem`)
- **Effort:** 10-20 hours content writing per module

## 5.5 AI Companion Features (v1.4+)
- **Fish ID already works** (OpenAI API)
- **Symptom Triage** exists (`symptom_triage_screen.dart`)
- **Weekly Plan** exists (`weekly_plan_screen.dart`)
- **Future:** Personalised care recommendations based on tank data, anomaly detection (`anomaly_detector_service.dart` exists), proactive alerts

## 5.6 Community Features (v2.0)
- **Community feed** (like AquaBuildr has — nested comments)
- **Species care notes** (community-contributed, self-reinforcing)
- **Tank showcase** (share beautiful tank photos)
- **Note:** r/Aquariums and forums own this space. Don't compete directly — complement.

---

# PART 6 — RISK REGISTER

| # | Risk | Likelihood | Impact | Source | Mitigation | Owner |
|---|------|-----------|--------|--------|------------|-------|
| R1 | **Firebase Analytics fires before GDPR consent** — ICO enforcement + Play Store rejection | HIGH (currently happening) | HIGH | Themis §1.1 | PS-01 + PS-02 (Sprint 1A) | Hephaestus |
| R2 | **Play Store rejects for missing Data Safety declarations** | HIGH (not yet filled) | HIGH | Themis §5.1 | PS-09-DOC + T2 | Tiarnan |
| R3 | **SCHEDULE_EXACT_ALARM rejection** without Play Console declaration | HIGH (not declared) | MEDIUM | Themis §3.3 | PS-05 + T3 | Tiarnan |
| R4 | **"Fish died from wrong advice" 1-star reviews** — reputation destruction | MEDIUM | HIGH | Argus Content Quality, Prometheus Monitoring | Sprint 2A fixes, accuracy crisis alert (monitoring plan), respond within 2h | Athena |
| R5 | **Content exhaustion** — users run out of lessons in <2 weeks | MEDIUM | HIGH | Argus Content Lessons (32 full lessons = 32 days at 1/day) | CG-01 gates stubs, v1.1 content expansion | Athena |
| R6 | **Onboarding drop-off** — current flow lacks aha moment | MEDIUM | HIGH | Artemis Audit (no fish added, no personalisation used) | v1.1 onboarding rewrite | Athena |
| R7 | **OpenAI API key exposed in APK binary** | LOW (dart-define used) | HIGH | Themis §4, PS-04 | Startup assertion + CI verification | Hephaestus |
| R8 | **Broken achievements demotivate completionists** | HIGH (4 confirmed broken) | MEDIUM | Argus Species §4 | Sprint 1D fixes all 4 | Hephaestus |
| R9 | **Notification fatigue → opt-out → retention collapse** | MEDIUM (post-launch) | HIGH | Dionysus, Prometheus Monitoring §3 | Cadence limits (max 1/day), care-first copy, pause after 3-day silence | Athena |
| R10 | **No offline mode** — competitor advantage (Aquarium Fish offline-first) | MEDIUM | MEDIUM | Prometheus Competitor Matrix §3 | Core lessons are local (SharedPreferences). AI features degrade gracefully. Full offline mode v1.2 | Hephaestus |
| R11 | **Crash rate >1.09%** → Play Store "crash issues" badge | LOW (currently stable) | HIGH | Prometheus Monitoring §1 | Crashlytics monitoring, 24h hotfix SLA | Hephaestus |
| R12 | **ANR rate >0.47%** → Play Store "ANR issues" badge | LOW | HIGH | Prometheus Monitoring §1 | Performance profiling post-launch | Hephaestus |
| R13 | **Monthly churn >15%** (when subscriptions ship) | MEDIUM | HIGH | Prometheus Monitoring §4 | Value delivery review, paywall timing A/B test | Athena |
| R14 | **Competitor copies gamification** (Fishelly or AquaBuildr) | LOW (short-term) | MEDIUM | Prometheus Competitor Matrix §3 | Ship fast, iterate on retention data, community moat | Athena |
| R15 | **Supabase placeholder comment in code discovered by reviewer** | LOW | LOW | Themis §4.1 | PS-03 verification (Sprint 1B) | Hephaestus |
| R16 | **SyncDebugDialog leaks implementation details** | MEDIUM (currently exposed) | LOW | Argus Store §3.2 | PS-06 kDebugMode guard (Sprint 1A) | Hephaestus |
| R17 | **WCAG colour contrast failures flagged by Play Store** | LOW (not currently blocking) | LOW | Argus Store §1.3 | AC-05 colour fix (Sprint 4) | Hephaestus |
| R18 | **Privacy policy lacking required GDPR sections** | HIGH (currently lacking) | HIGH | Themis §1.3 | PS-07 privacy policy v2 (Sprint 1C) | Hephaestus + Tiarnan |
| R19 | **No data deletion mechanism → Play Store rejection** | HIGH (currently missing) | HIGH | Themis §5.2 | PS-08 (Sprint 1C) | Hephaestus |
| R20 | **Stub lessons damage credibility if users open them** | MEDIUM | MEDIUM | Argus Content Quality §Flag 2-4 | CG-01 gates stubs behind "Coming Soon" (Sprint 2B) | Hephaestus |
| R21 | **versionCode 1 — must increment for any resubmission** | LOW | LOW | Argus Store §3.3 | Increment to 2+ if resubmitting | Athena |
| R22 | **OpenAI 30-day image retention** — privacy concern | LOW | MEDIUM | Themis §1.4 | Disclose in privacy policy (PS-07). Investigate Zero Data Retention API post-launch | Athena |
| R23 | **UK ICO registration not done** — technically required as data controller | MEDIUM | LOW | Themis §6 | Low annual fee, recommended post-launch | Tiarnan |

---

# APPENDIX A — COMPLETE RESEARCH-TO-ROADMAP TRACEABILITY

Every finding from every research document mapped to where it appears in this roadmap:

| Research File | Key Findings | Roadmap Location |
|--------------|-------------|------------------|
| `ARTEMIS_ONBOARDING_SPEC.md` | 10-screen onboarding rewrite | §4.1 (v1.1) |
| `ARTEMIS_ONBOARDING_AUDIT.md` | No aha moment, dead code flows, personalisation unused | §1.2 (#6, #12), §4.1 |
| `APOLLO_PAYWALL_DESIGN.md` | Full paywall UI spec, 4 variants, animation spec | §4.3 (v1.1) |
| `DESIGN_BRIEF_APOLLO.md` | Nunito+Lora, Golden Hour palette, room-by-room | Reference for all UI work |
| `APHRODITE_ASO_LAUNCH.md` | Store listing copy, keyword strategy, screenshots | SUB-04/05/06 (Sprint 6) |
| `APHRODITE_PAYWALL_STRATEGY.md` | Post-aha paywall, 7-day trial, feature gates | §4.3 (v1.1) |
| `APHRODITE_SCREENSHOT_BRIEF.md` | 7 screenshot specs, capture script | SUB-04 (Sprint 6) |
| `DIONYSUS_USER_PSYCHOLOGY.md` | 10 psych hooks, retention risks, re-engagement | Informs all notification + onboarding work |
| `DIONYSUS_NOTIFICATION_SEQUENCE.md` | 60+ notification specs | §4.4 (v1.1), basic wiring in Sprint 3B |
| `PROMETHEUS_COMPETITOR_MATRIX.md` | 3 moats, 5 gaps, 6 competitors | §5 (feature roadmap), Risk R14 |
| `PROMETHEUS_UK_LAUNCH.md` | UK communities, PFK magazine, LFS, pricing | §4.11 (v1.1) |
| `PROMETHEUS_BILLING_DECISION.md` | RevenueCat recommended, implementation outline | §4.2 (v1.1) |
| `PROMETHEUS_MONITORING_PLAN.md` | D1/D7/D30 targets, 6 alerts, war room checklist | §4.12, Risks R11/R12/R13 |
| `PROMETHEUS_AB_TESTS.md` | 7 tests in priority order, statistical thresholds | §4.9 (v1.1) |
| `PROMETHEUS_PR_OUTREACH.md` | Reddit, PH, UK press, YouTube, pitch templates | §4.10 (v1.1) |
| `THEMIS_COMPLIANCE_AUDIT.md` | 7 GDPR/Play Store blockers | Sprint 1A/1B/1C, Risks R1/R2/R3/R18/R19 |
| `ARGUS_CONTENT_LESSONS.md` | 50 lessons, 32 full, 18 stubs, 127 questions | Sprint 2B (stub gating), §4.5 |
| `ARGUS_CONTENT_SPECIES.md` | 121 species, 55 achievements, 4 broken, XP cap | Sprint 1D, Sprint 3A |
| `ARGUS_CONTENT_QUALITY.md` | 7 factual errors, 9 AI flags, 2 quiz issues | Sprint 2A |
| `ARGUS_CODE_NAVIGATION.md` | 9 orphaned screens, dual onboarding paths | Sprint 5 (cleanup) |
| `ARGUS_CODE_STORE.md` | 69/110 screens no Semantics, WCAG failures, Play Store blockers | Sprint 4, §4.6 |
| `ARGUS_CODE_DATA.md` | Notifications in dead code, 6 Firebase events, OpenAI API, Supabase dormant | Sprint 1A/1B/3B |
| `HEPHAESTUS_MASTER_FIX_LIST.md` | 24 tasks (13 P0, 8 P1, 3 P2) | Sprints 1A-5 (all tasks mapped) |

---

# APPENDIX B — TIARNAN ACTIONS REQUIRED (Cannot Be Automated)

| # | Action | When | Blocking? | Est. Time |
|---|--------|------|-----------|-----------|
| T1 | Review privacy policy v2 draft | After Sprint 1C | YES | 10 min |
| T2 | Fill Play Console Data Safety section | After all code changes | YES | 15 min |
| T3 | Declare SCHEDULE_EXACT_ALARM in Play Console | After all code changes | YES | 5 min |
| T4 | Complete content rating questionnaire | Before submission | YES | 5 min |
| T5 | Set target audience to 18+ adults | Before submission | YES | 2 min |
| T6 | Smoke test on Z Fold (10 journeys) | After AAB build | YES | 15 min |
| T7 | Upload AAB + submit for review | Final step | — | 10 min |

**Total Tiarnan time: ~1 hour**

---

# APPENDIX C — FILE PATH VERIFICATION

All file paths in this document have been verified to exist on disk as of 2026-03-16 07:00 GMT:

```
✅ lib/main.dart
✅ lib/services/analytics_service.dart
✅ lib/services/firebase_analytics_service.dart
✅ lib/services/achievement_service.dart
✅ lib/services/notification_service.dart
✅ lib/services/openai_service.dart
✅ lib/services/cloud_sync_service.dart
✅ lib/services/backup_service.dart
✅ lib/models/user_profile.dart
✅ lib/models/achievements.dart
✅ lib/data/achievements.dart
✅ lib/data/lessons/nitrogen_cycle.dart
✅ lib/data/lessons/water_parameters.dart
✅ lib/data/lessons/species_care.dart
✅ lib/data/lessons/planted_tank.dart
✅ lib/data/lessons/fish_health.dart
✅ lib/data/lessons/advanced_topics.dart
✅ lib/data/lessons/equipment.dart
✅ lib/data/placement_test_content.dart
✅ lib/screens/onboarding_screen.dart
✅ lib/screens/onboarding/personalisation_screen.dart
✅ lib/screens/onboarding/journey_reveal_screen.dart
✅ lib/screens/onboarding/enhanced_tutorial_walkthrough_screen.dart
✅ lib/screens/settings_hub_screen.dart
✅ lib/screens/account_screen.dart
✅ lib/screens/achievements_screen.dart
✅ lib/screens/lesson_screen.dart
✅ lib/screens/spaced_repetition_practice_screen.dart
✅ lib/screens/tab_navigator.dart
✅ lib/screens/smart_screen.dart
✅ lib/screens/privacy_policy_screen.dart
✅ lib/screens/rooms/study_screen.dart (orphaned — to delete)
✅ lib/screens/aquarium_supply_screen.dart (orphaned — to delete)
✅ lib/screens/enhanced_quiz_screen.dart (orphaned — to delete)
✅ lib/screens/placement_test_screen.dart (orphaned — to delete)
✅ lib/screens/stories_screen.dart (orphaned — to delete)
✅ lib/screens/story_player_screen.dart (orphaned — to delete)
✅ lib/screens/activity_feed_screen.dart (orphaned — to delete)
✅ lib/screens/friends_screen.dart (CA-002, keep)
✅ lib/screens/leaderboard_screen.dart (CA-003, keep)
✅ lib/features/smart/fish_id/fish_id_screen.dart
✅ lib/theme/app_theme.dart
✅ lib/widgets/sync_indicator.dart
✅ lib/widgets/sync_debug_dialog.dart
✅ lib/widgets/gamification_dashboard.dart
✅ lib/constants/aquarium_constants.dart
✅ lib/providers/lesson_provider.dart
✅ android/app/src/main/AndroidManifest.xml
❌ lib/services/gamification_service.dart (DOES NOT EXIST — gamification logic is in constants/aquarium_constants.dart and widgets/gamification_dashboard.dart)
```

**Note on gamification_service.dart:** The HEPHAESTUS_MASTER_FIX_LIST references this file but it doesn't exist. Gamification logic is spread across `lib/constants/aquarium_constants.dart`, `lib/widgets/gamification_dashboard.dart`, and `lib/models/user_profile.dart`. Hephaestus should grep for relevant constants/methods rather than assuming file names.

---

*Plan compiled from 21 research outputs across 10 specialist agents + 2 daily notes + full codebase scan.*
*Every finding from every research doc appears in this roadmap. Deferred items are explicitly justified.*
*This document is the SINGLE SOURCE OF TRUTH for Danio's path to production.*
*Cross-referenced against: all files in olympus-research/, pubspec.yaml, AndroidManifest.xml, lib/ structure (322 dart files)*
