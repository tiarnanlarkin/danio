# HEPHAESTUS MASTER FIX LIST — Danio App
**Generated:** 2026-03-16  
**Author:** Technical PM Sub-agent  
**For:** Hephaestus (Flutter Developer Agent)  
**Status:** ACTIVE — execute in priority order

---

## 📋 Summary

| Priority | Count | Complexity |
|----------|-------|------------|
| P0 (launch blocker) | 13 | 4×S, 5×M, 4×L |
| P1 (important) | 8 | 3×S, 4×M, 1×L |
| P2 (nice to have) | 3 | 1×S, 2×M |
| **TOTAL** | **24** | — |

**Execution order:** Complete all P0s before touching P1s. P2s are post-launch.

---

## 1. PLAY STORE BLOCKERS (P0 — Do not submit without these)

---

### PS-01 — GDPR Consent Dialog (Firebase gate)
- **Priority:** P0
- **Complexity:** L
- **Files:**
  - `lib/main.dart`
  - `lib/services/analytics_service.dart` (create if absent)
  - `lib/screens/onboarding/consent_screen.dart` (create)
- **What to do:**
  1. Create a `ConsentScreen` widget shown on first launch (before any Firebase call).
  2. Present two clear choices: "Accept analytics" / "Decline analytics".
  3. Persist consent decision to `SharedPreferences` key `gdpr_analytics_consent` (bool).
  4. Gate all `FirebaseAnalytics` and `FirebaseCrashlytics` initialisation behind this consent flag — they must not be called before consent is recorded.
  5. In `main()`, read the flag before calling `Firebase.initializeApp()` analytics features; initialise Firebase Core (crash-free) but skip Analytics/Crashlytics if no consent.
  6. If the user is EU-based (or consent is unknown), show the dialog on every cold start until a decision is made.
- **Acceptance criteria:**
  - No Firebase Analytics or Crashlytics events fire before the user taps "Accept".
  - "Decline" path results in zero analytics calls throughout the session.
  - Consent is persisted — dialog does not re-appear after a decision is made.
  - Cold-start on fresh install shows consent dialog before home screen.

---

### PS-02 — Firebase Analytics disabled by default
- **Priority:** P0
- **Complexity:** M
- **Files:**
  - `android/app/src/main/AndroidManifest.xml`
  - `lib/services/analytics_service.dart`
- **What to do:**
  1. Add `<meta-data android:name="firebase_analytics_collection_enabled" android:value="false"/>` inside `<application>` in `AndroidManifest.xml`.
  2. After user accepts consent (PS-01), call `FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true)` at runtime.
  3. Wrap all analytics calls in a guard: `if (await _isConsentGiven()) { ... }`.
- **Acceptance criteria:**
  - Charles/mitmproxy confirms zero analytics traffic before consent.
  - After consent, analytics traffic resumes normally.
  - `AndroidManifest.xml` contains the `firebase_analytics_collection_enabled=false` meta-data entry.

---

### PS-03 — Remove Supabase placeholder credentials from source
- **Priority:** P0
- **Complexity:** S
- **Files:**
  - Any file containing hardcoded Supabase URL/anon key (search: `supabase.co`, `eyJ`)
  - `lib/main.dart` or wherever `Supabase.initialize()` is called
  - CI/CD build script / `Makefile` / `fastlane/Fastfile`
- **What to do:**
  1. Run `grep -rn "supabase.co\|eyJhbGci" lib/` — identify all hardcoded occurrences.
  2. Replace with `dart-define` parameters: `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`.
  3. Read via `const String.fromEnvironment('SUPABASE_URL')` at the call site.
  4. Add both keys to `.gitignore`-protected CI secrets (GitHub Actions secrets or equivalent).
  5. Add a runtime assertion: `assert(supabaseUrl.isNotEmpty, 'SUPABASE_URL must be set via dart-define')`.
- **Acceptance criteria:**
  - `git grep "supabase.co"` returns zero results in `lib/`.
  - Release build fails fast with a clear error if `SUPABASE_URL` is not injected.
  - Placeholder credentials are not present in the published APK/AAB (verify with apktool).

---

### PS-04 — OpenAI API key guaranteed in release build pipeline
- **Priority:** P0
- **Complexity:** S
- **Files:**
  - `lib/services/openai_service.dart` (or wherever the key is consumed)
  - CI/CD build config
- **What to do:**
  1. Confirm `OPENAI_API_KEY` is read via `String.fromEnvironment('OPENAI_API_KEY')`.
  2. Add a startup assertion: `assert(openAiKey.isNotEmpty, 'OPENAI_API_KEY must be set via dart-define')`.
  3. Ensure the release build command in CI explicitly passes `--dart-define=OPENAI_API_KEY=${{ secrets.OPENAI_API_KEY }}`.
  4. Add a CI step that runs `grep -c "sk-" build/app/outputs/flutter-apk/app-release.apk` — it should return 0 (key must not be string-visible in APK binary); if it does, the key is being embedded as plaintext and needs obfuscation.
- **Acceptance criteria:**
  - Release build without the secret set fails immediately with a clear error.
  - The app does not show a "missing API key" error in production.
  - CI pipeline explicitly documents the `OPENAI_API_KEY` secret dependency.

---

### PS-05 — SCHEDULE_EXACT_ALARM — declare use case or switch to WorkManager
- **Priority:** P0
- **Complexity:** M
- **Files:**
  - `android/app/src/main/AndroidManifest.xml`
  - `lib/services/notification_service.dart`
  - Play Console — App content → Permissions declaration
- **What to do:**
  1. Audit whether `SCHEDULE_EXACT_ALARM` is genuinely required (water change reminders, streak nudges).
  2. **Option A (preferred):** Replace exact alarm scheduling with `WorkManager` constraints (`setExact` only for user-initiated alarms). Remove `SCHEDULE_EXACT_ALARM` from the manifest.
  3. **Option B (if exact timing is essential):** Retain the permission, add `USE_EXACT_ALARM` as the proper SDK 33+ alternative, and fill in the Play Console permissions declaration form explaining the use case (e.g. "User-scheduled water change reminder at a specific time").
  4. Whichever option: ensure the manifest permission entry matches the chosen approach.
- **Acceptance criteria:**
  - Either `SCHEDULE_EXACT_ALARM` is absent from the manifest, OR a Play Console permissions declaration is on file explaining the use case.
  - Notifications still fire correctly in both cases.
  - `flutter analyze` passes with no permission-related warnings.

---

### PS-06 — SyncDebugDialog exposed in production
- **Priority:** P0
- **Complexity:** S
- **Files:**
  - Wherever `SyncDebugDialog` is shown (likely a settings screen or developer menu)
- **What to do:**
  1. Search: `grep -rn "SyncDebugDialog" lib/`.
  2. Wrap every call site with `if (kDebugMode) { ... }` from `package:flutter/foundation.dart`.
  3. Ensure the dialog import is also conditionally compiled or at minimum never reachable in release.
- **Acceptance criteria:**
  - `SyncDebugDialog` is completely unreachable in a release build.
  - `flutter build apk --release` followed by manual QA confirms the debug option is not visible anywhere in the UI.

---

### PS-07 — Privacy Policy: OpenAI disclosure + data handling
- **Priority:** P0
- **Complexity:** M
- **Files:**
  - `assets/privacy_policy.html` (or wherever the privacy policy is stored/linked)
  - Play Store listing (manual step — flag for Tiarnan)
- **What to do:**
  Update the Privacy Policy to include all of the following sections. Draft the copy and write it into the asset file:
  1. **OpenAI disclosure** — "We use OpenAI's API to process your inputs. Your data is sent to OpenAI's servers in the United States. OpenAI's privacy policy applies."
  2. **International transfers** — GDPR Article 46 SCCs disclosure for US data transfers (OpenAI, Firebase, Supabase).
  3. **Retention periods** — Specify how long each data type is retained (lesson history, user profile, analytics events).
  4. **Legal basis** — State the GDPR legal basis for each processing activity (consent for analytics, legitimate interest for crash reports, contract for core features).
  5. **ICO right** — Add UK-specific right to lodge a complaint with the ICO (ico.org.uk).
  6. **Data deletion** — Include a dedicated "Right to Erasure" section with an email address for deletion requests (minimum: `privacy@[domain]`).
- **Acceptance criteria:**
  - Privacy Policy contains all 6 sections above.
  - The policy is accessible from the app (footer link or settings screen).
  - Tiarnan has reviewed and approved the copy before submission.

---

### PS-08 — Data deletion mechanism
- **Priority:** P0
- **Complexity:** M
- **Files:**
  - `lib/screens/settings/settings_screen.dart`
  - `lib/services/auth_service.dart` (or equivalent)
  - Privacy Policy (covered in PS-07)
- **What to do:**
  1. Add a "Delete my account and data" option in Settings.
  2. On tap: show a confirmation dialog ("This will permanently delete your account and all data. This cannot be undone.").
  3. On confirm: call the backend (Supabase) to delete the user's row and all associated data, then sign out.
  4. If full deletion is not yet implemented server-side, at minimum: display the support email (`privacy@[domain]`) for deletion requests — this is the Play Store minimum.
  5. Ensure the privacy policy (PS-07) mentions this mechanism.
- **Acceptance criteria:**
  - Users can request account deletion from within the app.
  - The process completes or clearly directs the user to an email contact.
  - Play Store Data Safety form can truthfully state that a deletion mechanism exists.

---

### PS-09 — Play Store Data Safety section
- **Priority:** P0
- **Complexity:** S
- **Files:**
  - Play Console (manual — flag for Tiarnan after code changes are in)
  - Reference: outputs of PS-03, PS-04, PS-07, PS-08
- **What to do:**
  1. Once PS-03/04/07/08 are done, document every data type collected:
     - User email (account, required, not shared)
     - Lesson history (app activity, required, not shared)
     - Analytics events (analytics, optional/consent-gated, shared with Firebase/Google)
     - Crash reports (diagnostics, optional/consent-gated, shared with Firebase/Google)
     - AI input text (sent to OpenAI, required for feature, not stored by us)
  2. Fill in the Play Console Data Safety form accordingly.
  3. Confirm "Does your app collect or share any of the required user data types?" — Yes.
  4. Confirm data encryption in transit — Yes (all services use HTTPS).
  5. Confirm deletion mechanism — Yes (PS-08).
- **Acceptance criteria:**
  - Data Safety form is 100% complete in Play Console.
  - No "incomplete" warnings on the store listing.
  - Tiarnan signs off on the declarations.

---

### PS-10 — Perfectionist achievement broken (P0 gamification)
- **Priority:** P0
- **Complexity:** M
- **Files:**
  - `lib/models/user_stats.dart` (or equivalent stats model)
  - `lib/services/achievement_service.dart`
  - `lib/services/gamification_service.dart`
- **What to do:**
  1. Add `perfectScoreCount` field to the user stats model (int, default 0).
  2. Persist `perfectScoreCount` to local DB / Supabase alongside other stats.
  3. In the lesson completion handler, check if the score was 100% — if so, increment `perfectScoreCount`.
  4. In `checkAchievements()`, evaluate `perfectScoreCount >= [threshold]` for the `perfectionist` achievement.
  5. Write a unit test: simulate 5 perfect scores → assert `perfectionist` is unlocked.
- **Acceptance criteria:**
  - `perfectScoreCount` increments correctly after a 100% lesson.
  - `perfectionist` achievement unlocks at the correct threshold.
  - Achievement does not unlock on non-perfect scores.
  - Unit test passes.

---

### PS-11 — Speed demon achievement broken (P0 gamification)
- **Priority:** P0
- **Complexity:** M
- **Files:**
  - `lib/screens/lesson/lesson_screen.dart` (or wherever lessons run)
  - `lib/services/achievement_service.dart`
- **What to do:**
  1. Record `lessonStartTime = DateTime.now()` when the lesson begins.
  2. On lesson completion, compute `actualElapsedSeconds = DateTime.now().difference(lessonStartTime).inSeconds`.
  3. Pass `actualElapsedSeconds` (not an estimated duration) to the achievement check.
  4. Evaluate `speed_demon` condition against `actualElapsedSeconds`.
  5. Write a unit test with a mocked elapsed time below and above the threshold.
- **Acceptance criteria:**
  - `speed_demon` evaluates against real elapsed time.
  - Completing a lesson faster than the threshold reliably unlocks the achievement.
  - Completing slowly does not unlock it.
  - Unit test passes.

---

### PS-12 — Comeback achievement broken (P0 gamification)
- **Priority:** P0
- **Complexity:** S
- **Files:**
  - `lib/services/achievement_service.dart`
  - `lib/services/gamification_service.dart`
- **What to do:**
  1. In `checkAfterLesson()`, before evaluating the `comeback` achievement, set `lastActivityDate = DateTime.now()` on the user stats object.
  2. Persist `lastActivityDate` to local DB.
  3. The `comeback` condition checks `DateTime.now().difference(lastActivityDate).inDays >= [threshold]` — this only works if `lastActivityDate` was set on the *previous* lesson, not the current one. Ensure the check happens *before* updating `lastActivityDate`.
  4. Write a unit test: set `lastActivityDate` to 7 days ago → complete lesson → assert `comeback` unlocks.
- **Acceptance criteria:**
  - `lastActivityDate` is populated and persisted after every lesson.
  - Returning after the gap threshold correctly unlocks `comeback`.
  - Unit test passes.

---

### PS-13 — Completionist achievement counts hidden achievements (P0 gamification)
- **Priority:** P0
- **Complexity:** S
- **Files:**
  - `lib/services/achievement_service.dart`
  - `lib/models/achievement.dart`
- **What to do:**
  1. Identify the `completionist` check — it likely counts total achievements unlocked vs total achievements.
  2. Filter the denominator: `achievements.where((a) => !a.isHidden).length`.
  3. Filter the numerator: `unlockedAchievements.where((a) => !a.isHidden).length`.
  4. Update the condition accordingly.
  5. Write a unit test: mix of hidden and visible achievements → assert `completionist` unlocks when all visible ones are done.
- **Acceptance criteria:**
  - Hidden achievements are excluded from the `completionist` count.
  - The achievement unlocks when all non-hidden achievements are earned.
  - Unit test passes.

---

## 2. GAMIFICATION FIXES (P1)

---

### GF-01 — Wire checkAfterReview() into spaced repetition screen
- **Priority:** P1
- **Complexity:** M
- **Files:**
  - `lib/screens/review/review_screen.dart` (or spaced repetition equivalent)
  - `lib/services/achievement_service.dart`
- **What to do:**
  1. Locate `checkAfterReview()` in `achievement_service.dart`.
  2. In the review screen's completion handler (wherever the session ends), call `await achievementService.checkAfterReview(result)`.
  3. Pass the review session result (score, duration, streak) into the method.
  4. Display any newly unlocked achievement overlays/toasts.
- **Acceptance criteria:**
  - Completing a review session triggers achievement evaluation.
  - Any achievements that depend on review completion can unlock.
  - No achievements are double-counted (lesson vs review).

---

### GF-02 — Extend XP cap from 2,500 to 10,000+
- **Priority:** P1
- **Complexity:** S
- **Files:**
  - `lib/services/gamification_service.dart`
  - `lib/models/user_stats.dart`
  - Any UI that renders XP bars or progress
- **What to do:**
  1. Search for `2500` or `maxXP` constant — replace with `10000` (or make it configurable via a constant at the top of the file).
  2. Check XP bar UI — ensure it scales correctly to 10,000 without overflowing.
  3. Verify that weekly XP leaderboards (if any) also handle the new range.
- **Acceptance criteria:**
  - Users can accumulate beyond 2,500 XP without capping.
  - XP bar renders correctly at all levels up to 10,000.
  - No integer overflow or display bugs.

---

### GF-03 — Route streak/achievement bonus XP through weeklyXP
- **Priority:** P1
- **Complexity:** S
- **Files:**
  - `lib/services/gamification_service.dart`
- **What to do:**
  1. Find where streak bonus XP and achievement bonus XP are awarded.
  2. Ensure both call the same `_addXP(amount)` method that also increments `weeklyXP`.
  3. If bonuses currently bypass `_addXP` (direct field increment), route them through it.
  4. Add a unit test: trigger a streak bonus → assert `weeklyXP` increments by the bonus amount.
- **Acceptance criteria:**
  - Streak bonuses and achievement bonuses appear in `weeklyXP`.
  - `totalXP` and `weeklyXP` stay in sync.
  - Unit test passes.

---

## 3. NOTIFICATIONS (P1)

---

### NT-01 — Move notification permission request into live onboarding flow
- **Priority:** P1
- **Complexity:** M
- **Files:**
  - `lib/screens/onboarding/onboarding_screen.dart` (or the onboarding flow controller)
  - Wherever the notification permission request is currently dead-coded
- **What to do:**
  1. Find the current notification permission request call (likely in a dead code path or a removed screen).
  2. Create (or update) an onboarding step that explains: "Get reminded about water changes and streaks" with a clear value proposition.
  3. On the "Allow" tap: call `await Permission.notification.request()` (using `permission_handler` package).
  4. Handle the denial gracefully — do not block onboarding progress.
  5. Store the result in `SharedPreferences` key `notification_permission_requested`.
- **Acceptance criteria:**
  - The notification permission prompt appears during onboarding (not before).
  - Denying permission does not crash or block the app.
  - The permission request only fires once (not on every launch).
  - On Android 13+, the system permission dialog appears correctly.

---

### NT-02 — Wire up notification scheduling for water change reminders and streaks
- **Priority:** P1
- **Complexity:** L
- **Files:**
  - `lib/services/notification_service.dart`
  - `lib/screens/tank/tank_detail_screen.dart` (or wherever water change schedule is set)
  - `lib/services/gamification_service.dart` (streak logic)
- **What to do:**
  1. **Water change reminders:** When a user sets or updates a tank's water change schedule, call `NotificationService.scheduleWaterChangeReminder(tankId, nextDueDate)`. Use `flutter_local_notifications` with a repeating schedule.
  2. **Streak nudge:** At the end of each day (or when the app backgrounds), if the user has not completed a lesson that day, schedule a nudge notification for the next morning.
  3. Cancel existing notifications before re-scheduling to avoid duplicates.
  4. On permission denial (NT-01 result), skip scheduling silently.
  5. Test on a physical device — simulators may not fire local notifications reliably.
- **Acceptance criteria:**
  - Water change reminder fires at the correct date/time.
  - Streak nudge fires if no lesson completed by end of day.
  - Notifications are not duplicated on app restart.
  - All notifications are cancelable (settings toggle).

---

## 4. ACCESSIBILITY (P1/P2)

---

### AC-01 — Add Semantics to all 3 onboarding screens
- **Priority:** P1
- **Complexity:** M
- **Files:**
  - `lib/screens/onboarding/onboarding_screen_1.dart`
  - `lib/screens/onboarding/onboarding_screen_2.dart`
  - `lib/screens/onboarding/onboarding_screen_3.dart`
  (adjust filenames to match actual structure)
- **What to do:**
  1. Wrap each major UI element in a `Semantics` widget with appropriate `label`, `hint`, and `button` properties.
  2. For images/illustrations: `Semantics(label: 'Illustration of [description]', child: Image(...))`.
  3. For step indicators: `Semantics(label: 'Step 1 of 3', child: ...)`.
  4. For CTA buttons: ensure the `Text` inside is readable by screen readers (usually automatic, but verify).
  5. Test with TalkBack (Android) — navigate through the entire onboarding flow.
- **Acceptance criteria:**
  - TalkBack reads all interactive and informational elements on all 3 onboarding screens.
  - No "unlabelled element" warnings in accessibility scanner.
  - Navigation order is logical (top to bottom, left to right).

---

### AC-02 — Add Semantics to achievements screen
- **Priority:** P1
- **Complexity:** M
- **Files:**
  - `lib/screens/achievements/achievements_screen.dart`
  - Achievement card widget file
- **What to do:**
  1. Each achievement card needs: `Semantics(label: '${achievement.name}. ${achievement.description}. ${achievement.isUnlocked ? "Unlocked" : "Locked"}')`.
  2. Progress indicators: `Semantics(label: '${achievement.progress} of ${achievement.total} completed')`.
  3. Locked achievements should not expose unlock hints unless intentional.
- **Acceptance criteria:**
  - TalkBack reads achievement name, description, and locked/unlocked state for each card.
  - Progress is announced correctly.

---

### AC-03 — Add Semantics to settings screen
- **Priority:** P1
- **Complexity:** S
- **Files:**
  - `lib/screens/settings/settings_screen.dart`
- **What to do:**
  1. Wrap each settings row in `Semantics` with the setting name and current value: `Semantics(label: 'Notifications. Currently enabled', child: ...)`.
  2. For toggles: use `Switch` with `semanticLabel`.
  3. For navigation rows: `Semantics(button: true, label: 'Privacy Policy', child: ...)`.
- **Acceptance criteria:**
  - TalkBack reads setting name and current state for every row.
  - Toggle state changes are announced immediately.

---

### AC-04 — Label 30+ unlabelled IconButton instances
- **Priority:** P1
- **Complexity:** M
- **Files:**
  - Global search: `grep -rn "IconButton(" lib/` — find all instances
  - Prioritise: navigation bars, lesson controls, tank action buttons
- **What to do:**
  1. For every `IconButton`, ensure `tooltip` is set: `IconButton(tooltip: 'Add fish', icon: Icon(Icons.add), ...)`.
  2. The `tooltip` doubles as the accessibility label on Android.
  3. For icon-only buttons with no obvious label context, add `Semantics(label: 'Description', child: IconButton(...))`.
  4. Run the Flutter accessibility checker: `flutter test --tags accessibility` (if configured).
- **Acceptance criteria:**
  - Zero `IconButton` instances without a `tooltip` or `Semantics` label.
  - TalkBack announces the button purpose for every `IconButton` in the app.

---

### AC-05 — Fix error and success colour contrast (WCAG AA)
- **Priority:** P2
- **Complexity:** S
- **Files:**
  - `lib/theme/app_theme.dart` (or wherever `#D96A6A` and `#5AAF7A` are defined)
- **What to do:**
  1. Replace `#D96A6A` (error red) with a WCAG AA compliant alternative on white (4.5:1 ratio). Suggested: `#C0392B` (ratio ~5.1:1) or `#B03A2E`.
  2. Replace `#5AAF7A` (success green) with a compliant alternative. Suggested: `#1E8449` (ratio ~5.5:1) or `#27AE60` (check: ~4.6:1 on white).
  3. Verify with a contrast checker (e.g. webaim.org/resources/contrastchecker/).
  4. Update all direct hex usages and theme references.
  5. Check dark mode — ensure the replacements still look correct on dark backgrounds.
- **Acceptance criteria:**
  - Both colours achieve ≥4.5:1 contrast ratio on white background (WCAG AA).
  - Colour changes are visually coherent with the rest of the design.
  - No hardcoded old hex values remain in the codebase.
  - Tiarnan approves the visual change.

---

## 5. CODE CLEANUP (P2)

---

### CC-01 — Add Semantics to remaining 64 screens (post-launch)
- **Priority:** P2
- **Complexity:** L
- **Files:**
  - All screens in `lib/screens/` not covered by AC-01/02/03
- **What to do:**
  1. Run the Flutter accessibility audit across the full app.
  2. Systematically add `Semantics` to each screen, starting with highest-traffic screens.
  3. Consider building a reusable `SemanticWrapper` widget to reduce boilerplate.
  4. Track progress in a checklist (create `docs/accessibility_checklist.md`).
- **Acceptance criteria:**
  - 100% of screens have meaningful Semantics annotations.
  - Accessibility audit score reaches 90+.

---

### CC-02 — Remove all dead code paths post-notification refactor
- **Priority:** P2
- **Complexity:** S
- **Files:**
  - Wherever old notification permission dead code lived (identified in NT-01)
- **What to do:**
  1. After NT-01 is done, delete the dead code path.
  2. Run `flutter analyze` — ensure no unused imports or variables remain.
- **Acceptance criteria:**
  - `flutter analyze` returns no warnings related to the removed code.
  - No dead notification code remains in the codebase.

---

### CC-03 — Unit test coverage for all achievement fixes
- **Priority:** P2
- **Complexity:** M
- **Files:**
  - `test/services/achievement_service_test.dart` (create if absent)
- **What to do:**
  Write unit tests for PS-10, PS-11, PS-12, PS-13, GF-01:
  - `perfectionist`: 0 perfect scores → locked; N perfect scores → unlocked
  - `speed_demon`: slow lesson → locked; fast lesson → unlocked
  - `comeback`: recent activity → locked; 7-day gap → unlocked
  - `completionist`: visible only; hidden excluded
  - `checkAfterReview`: called → relevant achievements checked
- **Acceptance criteria:**
  - All 5 achievement types have passing unit tests.
  - `flutter test test/services/achievement_service_test.dart` exits 0.

---

## ⚡ Execution Checklist for Hephaestus

Work in this order. Do not skip ahead.

```
[ ] PS-01  GDPR consent dialog
[ ] PS-02  Firebase Analytics disabled by default  
[ ] PS-03  Remove Supabase placeholder credentials
[ ] PS-04  OpenAI API key guaranteed in pipeline
[ ] PS-05  SCHEDULE_EXACT_ALARM — declare or switch
[ ] PS-06  SyncDebugDialog — kDebugMode guard
[ ] PS-07  Privacy Policy update
[ ] PS-08  Data deletion mechanism
[ ] PS-09  Play Store Data Safety (flag Tiarnan — manual step)
[ ] PS-10  Perfectionist achievement fix
[ ] PS-11  Speed demon achievement fix
[ ] PS-12  Comeback achievement fix
[ ] PS-13  Completionist achievement fix
--- P0 COMPLETE — get Tiarnan sign-off before continuing ---
[ ] GF-01  Wire checkAfterReview()
[ ] GF-02  Extend XP cap to 10,000+
[ ] GF-03  Route bonus XP through weeklyXP
[ ] NT-01  Move notification permission to onboarding
[ ] NT-02  Wire notification scheduling
[ ] AC-01  Semantics — onboarding screens
[ ] AC-02  Semantics — achievements screen
[ ] AC-03  Semantics — settings screen
[ ] AC-04  Label all IconButton instances
--- P1 COMPLETE — ready to submit ---
[ ] AC-05  Fix error/success colours (WCAG AA)
[ ] CC-01  Semantics — remaining 64 screens
[ ] CC-02  Remove dead notification code
[ ] CC-03  Unit tests for all achievement fixes
```

---

## 🚨 Notes for Hephaestus

1. **Run `flutter analyze` after every logical group of changes** — do not batch everything and analyze at the end.
2. **Never run `flutter build` — Athena handles all builds.**
3. **Commit after each completed task** using conventional commit format: `fix(achievements): add perfectScoreCount field and fix perfectionist counter`.
4. **PS-09 is a Play Console action** — flag it to Tiarnan when all other P0s are done; you cannot complete it yourself.
5. **PS-07 copy must be reviewed by Tiarnan** before the privacy policy asset is updated in the repo — draft it and present it for approval first.
6. **For AC-04**, use `grep -rn "IconButton(" lib/ | wc -l` to get the full count before starting.
7. **Test PS-01 manually** — connect a physical device, clear app data, cold-start, and confirm no Firebase traffic fires before consent.
