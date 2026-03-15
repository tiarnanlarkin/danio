# Final Production Audit: Polishing & Optimization

**Auditor:** Production Release Auditor (automated)  
**Date:** 2026-03-15  
**Codebase:** `apps/aquarium_app/` — Danio v1.0.0+1  
**Total Dart files:** ~210 | **Total lines:** ~133K  

---

## Executive Summary

The codebase is **solid** — well-structured theme system, good error handling, proper storage corruption recovery, and a polished onboarding flow. However, there are **3 P0s**, **8 P1s**, and **12 P2s** that need attention before Play Store submission.

---

## 1. First-Run Experience (Fresh Install)

### Flow: Splash → OnboardingScreen → PersonalisationScreen → JourneyRevealScreen → TabNavigator

**Verdict:** Flow is clean. Provider-driven routing in `_AppRouter` prevents the duplicate-TabNavigator bug. Splash shows brand gradient + "Danio" text + spinner while providers load. Onboarding has 3-page intro with animated content (fade+slide). JourneyRevealScreen confirms personalisation before completing onboarding.

### Issues Found

| ID | Issue | File(s) | Severity | Fix |
|----|-------|---------|----------|-----|
| FRE-1 | **Firebase init deferred to post-frame callback but may cause timing issues** — Crashlytics error handler is set up AFTER `runApp()`. Any error thrown during the very first build frame (before the post-frame callback fires) will be lost in release mode. | `main.dart:52-76` | P1 | Move `FlutterError.onError` assignment to before `runApp()` with a buffer that replays errors once Crashlytics is ready, or at minimum set a temporary handler that queues errors. |
| FRE-2 | **Onboarding pushes to PersonalisationScreen via Navigator on force-quit recovery** — `OnboardingScreen.initState` uses `Navigator.of(context).pushReplacement` to redirect if a profile already exists. This creates a navigation state inconsistency with `_AppRouter`'s provider-driven routing (which also watches `userProfileProvider`). | `screens/onboarding_screen.dart:75-82` | P2 | The `_AppRouter` already handles this case — it will show PersonalisationScreen if onboarding is complete but no profile exists. The `pushReplacement` in OnboardingScreen is redundant and could cause a brief flash. Consider removing it and relying solely on provider-driven routing. |
| FRE-3 | **GoogleFonts runtime fetching disabled but fonts not bundled** — `GoogleFonts.config.allowRuntimeFetching = false` is set in `main.dart`, but the pubspec does not include Nunito or Fredoka as bundled font assets. This means the fonts will fall back to system fonts on first run with no network, producing inconsistent typography. | `main.dart:41`, `pubspec.yaml` | P1 | Either: (a) Bundle Nunito and Fredoka .ttf files in `assets/fonts/` and reference them in pubspec.yaml, OR (b) remove `allowRuntimeFetching = false` and accept the network fetch (but this adds ~100ms first-frame jank). Option (a) is strongly recommended for production. |

---

## 2. Visual Polish

### Theme System

The theme system (`app_theme.dart`) is **excellent** — comprehensive `AppColors`, `AppSpacing`, `AppRadius`, `AppTypography`, `AppShadows`, `AppOverlays` with pre-computed alpha colors. Both light and dark themes are fully defined.

### Issues Found

| ID | Issue | File(s) | Severity | Fix |
|----|-------|---------|----------|-----|
| VP-1 | **159 hardcoded `Color(0x...)` values in screens/widgets** not using `AppColors`/`AppOverlays`/`DanioColors`. Examples: algae_guide_screen uses `Color(0xFF81C784)`, analytics_screen uses `Color(0xFFA5D6A7)`, gem_shop_screen defines local `_GemShopColors`, inventory_screen and shop_street_screen define local color constants. | `screens/algae_guide_screen.dart`, `screens/analytics_screen.dart`, `screens/gem_shop_screen.dart`, `screens/inventory_screen.dart`, `screens/shop_street_screen.dart`, + ~15 more files | P2 | Migrate hardcoded colors to `AppColors`/`DanioColors` or `AppOverlays`. Priority: screens visible to users (algae guide, analytics, gem shop). Low priority: custom painters (`rooms/study_screen.dart`) where hardcoded colors are acceptable for artistic rendering. |
| VP-2 | **354 uses of `Colors.xxx` (Material defaults)** in screens/widgets — e.g. `Colors.white`, `Colors.grey`, `Colors.amber`. While some are fine (e.g. `Colors.white` for icon foreground on dark), many bypass the theme. | Multiple screens/widgets | P2 | Audit and replace where appropriate. `Colors.white` on primary-colored backgrounds is fine. `Colors.grey` for text/borders should use `context.textHint` or `AppColors.textSecondary`. |
| VP-3 | **54 remaining `.withOpacity()` calls** — the theme has an extensive pre-computed alpha system (`AppColors.primaryAlpha20` etc.) but 54 call sites still use the deprecated pattern. This creates new Color objects on every build. | `screens/difficulty_settings_screen.dart` (14 instances), `screens/activity_feed_screen.dart`, `screens/friends_screen.dart`, `screens/leaderboard_screen.dart`, + others | P2 | Migrate to pre-computed alpha constants or `Color.fromRGBO()`/`.withAlpha()`. |
| VP-4 | **~30 hardcoded `fontSize:` values** not using `AppTypography` — mostly for emoji text (`TextStyle(fontSize: 28)` for emoji icons), chart axis labels (`fontSize: 10`), and decorative elements. | `screens/analytics_screen.dart`, `screens/home/home_screen.dart`, `widgets/celebrations/`, `screens/placement_result_screen.dart` | P2 | Emoji font sizes are acceptable as-is (emoji sizing is decorative, not part of the text scale). Chart axis labels (`fontSize: 10`, `12`) should be `AppTypography.labelSmall` or a chart-specific constant. |
| VP-5 | **About screen uses placeholder icon** instead of actual app icon — shows a generic `Icons.water_drop` in a gradient container instead of the actual launcher icon. | `screens/about_screen.dart:22-44` | P1 | Replace with `Image.asset('assets/images/app_icon.png')` or use the actual app icon asset. This is visible in Settings > About and looks unprofessional. |
| VP-6 | **Splash screen uses generic `Icons.water_drop`** — same issue as VP-5. The splash visible during provider loading should show the actual branded app icon/logo. | `main.dart:275-285` | P1 | Replace with the actual app logo/icon asset. |

### Small Screen / Large Screen

No explicit `LayoutBuilder` or responsive breakpoint usage found in most screens. The app is portrait-locked (`SystemChrome.setPreferredOrientations`) which mitigates tablet landscape issues. `AppTouchTargets.adaptive()` exists for touch target scaling. Most layouts use `SingleChildScrollView` or `ListView` which handles vertical overflow naturally.

No obvious overflow risks detected for 360dp width — spacing uses `AppSpacing` constants which are modest (4-16dp).

---

## 3. String Quality

| ID | Issue | File(s) | Severity | Fix |
|----|-------|---------|----------|-----|
| SQ-1 | **Friends screen has "Coming Soon" placeholder** with construction icon — `TODO: Hidden until feature ships (CA-002)`. While hidden from navigation, the file still exists and could be reached via deep links or search. | `screens/friends_screen.dart:1` | P2 | Verify this screen is truly unreachable. It's commented out of `settings_hub_screen.dart` imports, which is correct. No risk unless a route accidentally references it. |
| SQ-2 | **Leaderboard screen has "Coming Soon" placeholder** — same pattern as SQ-1, `TODO: Hidden until feature ships (CA-003)`. | `screens/leaderboard_screen.dart:1` | P2 | Same as SQ-1 — verify unreachable. |
| SQ-3 | **Tab label inconsistency: "Toolbox" vs "Settings"** — The last tab is labelled "Toolbox" with a construction icon (`Icons.construction`) in `tab_navigator.dart`, but it leads to `SettingsHubScreen`. | `screens/tab_navigator.dart:194-198` | P1 | Either rename the tab to "Settings" (with gear icon), or rename `SettingsHubScreen` to `ToolboxScreen`. Currently misleading for users. |
| SQ-4 | **No string localisation** — all user-facing strings are hardcoded English inline. No `l10n/`, no `AppLocalizations`, no `.arb` files. | Codebase-wide | P2 | Acceptable for v1.0 English-only launch. Flag for v1.1+ if targeting non-English markets. |

---

## 4. Error Resilience

### Storage (LocalJsonStorageService)

**Verdict: Excellent.** The storage service has:
- ✅ Proper `StorageState` enum (idle/loading/loaded/corrupted/ioError)
- ✅ Corruption detection with backup (`.corrupted.{timestamp}`)
- ✅ Lock-based concurrency protection (`synchronized` package)
- ✅ Empty file / missing file handled gracefully (fresh start)
- ✅ Schema versioning (`_schemaVersion = 1`)

### SharedPreferences (Settings/Onboarding)

**Verdict: Good.** `SettingsNotifier` loads with defaults (`const AppSettings()`) before SharedPreferences is ready. `onboardingCompletedProvider` returns `false` by default. No crash risk on fresh install.

### Issues Found

| ID | Issue | File(s) | Severity | Fix |
|----|-------|---------|----------|-----|
| ER-1 | **`auth_service.dart` has 6 force-unwrap (`!`) calls on `_auth`** — `_auth!.signUp()`, `_auth!.signInWithPassword()`, etc. If Supabase initialisation fails (offline, bad config), `_auth` remains null and these crash. | `features/auth/auth_service.dart:40,62,85,110,126` | P0 | Add null check: `if (_auth == null) return AuthResult.failure('Not connected');` before each call. Or make `_auth` non-nullable with a safe-init pattern. |
| ER-2 | **`fish_id_screen.dart:116` force-unwraps `_selectedImage!.readAsBytes()`** — if `_selectedImage` is null when the user taps "Identify", this crashes. | `features/smart/fish_id/fish_id_screen.dart:116` | P1 | Add null guard or disable the button when no image is selected. |
| ER-3 | **`equipment.dart:56,63` force-unwraps `lastServiced!` and `maintenanceIntervalDays!`** — these are nullable fields that crash if the user hasn't set a service date. | `models/equipment.dart:56,63` | P1 | Add null checks: `if (lastServiced == null || maintenanceIntervalDays == null) return null;` |
| ER-4 | **`fish_id_screen.dart:398` force-unwraps `r.maxSizeCm!`** — if the AI response doesn't include size data, this crashes the results display. | `features/smart/fish_id/fish_id_screen.dart:398` | P1 | Use `r.maxSizeCm?.toStringAsFixed(0) ?? '?'` |
| ER-5 | **Missing INTERNET permission in release AndroidManifest** — The main `AndroidManifest.xml` does NOT include `<uses-permission android:name="android.permission.INTERNET"/>`. It's only in the debug manifest. Supabase, Firebase, and Google Fonts (if re-enabled) all require network access. | `android/app/src/main/AndroidManifest.xml` | P0 | Add `<uses-permission android:name="android.permission.INTERNET"/>` to the main AndroidManifest.xml. Without this, **all network features silently fail in release builds** — Supabase sync, Firebase analytics/crashlytics, and any future API calls. |

---

## 5. Memory & Resource Usage

| ID | Issue | File(s) | Severity | Fix |
|----|-------|---------|----------|-----|
| MR-1 | **`lesson_content.dart` — 4,980 lines of dead code** — The file comment says `TODO(cleanup): This 4,975-line file duplicates content in data/lessons/ individual files.` No imports reference it. | `data/lesson_content.dart` | P2 | Delete the file. It inflates the app size and confuses navigation. The lazy-loaded `lesson_content_lazy.dart` + individual `data/lessons/*.dart` files are the active versions. |
| MR-2 | **`activity_feed_screen.dart` has unbounded `_displayCount`** — `_onScroll` increments `_displayCount += 20` with no upper bound. While this only controls display count (not data loading), if the activity list is very long, it grows the rendered list without limit. | `screens/activity_feed_screen.dart:45-50` | P2 | Cap at the actual list length: `_displayCount = min(_displayCount + 20, activities.length)`. |
| MR-3 | **`LocalJsonStorageService` is a singleton with in-memory maps** — `_tanks`, `_livestock`, `_equipment`, `_logs`, `_tasks` are all held in memory for the lifetime of the app. For power users with many entries, this could be significant. | `services/local_json_storage_service.dart:87-91` | P2 | Acceptable for MVP. Flag for migration to Hive/SQLite if users report memory issues. Monitor via Firebase Performance. |

---

## 6. Code Smells & Consistency

| ID | Issue | File(s) | Severity | Fix |
|----|-------|---------|----------|-----|
| CS-1 | **4 TODO/FIXME comments indicating unfinished work** | See below | P1 | Address or document each: |
| | `TODO(cleanup): This 4,975-line file duplicates content` | `data/lesson_content.dart:1` | — | Delete the file (see MR-1) |
| | `TODO: Hidden until feature ships (CA-002)` | `screens/friends_screen.dart:1` | — | Keep hidden, document in release notes |
| | `TODO: Hidden until feature ships (CA-003)` | `screens/leaderboard_screen.dart:1` | — | Keep hidden, document in release notes |
| | `TODO(UX-sprint11): Notification tap handlers should switch to the correct...` | `services/notification_service.dart:26` | — | Either implement or remove the TODO and accept current behaviour |
| CS-2 | **13 files over 1000 lines** — `home_screen.dart` (2091), `room_scene.dart` (1873), `livestock_screen.dart` (1541), `settings_screen.dart` (1433), `lesson_screen.dart` (1414), `add_log_screen.dart` (1352), `spaced_repetition_practice_screen.dart` (1289), `learn_screen.dart` (1178), `analytics_screen.dart` (1177), `exercise_widgets.dart` (1162), `charts_screen.dart` (1082), `user_profile_provider.dart` (1071), `create_tank_screen.dart` (1054). Data files (`species_database.dart`, `stories.dart`, `plant_database.dart`) excluded. | Multiple | P2 | Extract widgets/helpers into sub-files. Priority: `home_screen.dart` (2091 lines) — already has a `widgets/` subfolder, continue extracting. |
| CS-3 | **`AppOverlays` and `AppColors` have significant overlap** — Both define alpha variants of the same colours (e.g., `AppColors.primaryAlpha20` and `AppOverlays.primary20`). This creates confusion about which to use. | `theme/app_theme.dart` | P2 | Long-term: consolidate into a single system. Short-term: add a code comment clarifying that `AppOverlays` is the canonical source for overlay alphas. |

---

## 7. Play Store Readiness

| ID | Issue | File(s) | Severity | Fix |
|----|-------|---------|----------|-----|
| PS-1 | **Version string `1.0.0+1` is correct** for first Play Store release. | `pubspec.yaml:5` | ✅ OK | — |
| PS-2 | **App name "Danio" is professional** and matches the brand. | `AndroidManifest.xml: android:label="Danio"` | ✅ OK | — |
| PS-3 | **App icon configured for all densities** — mdpi through xxxhdpi, plus adaptive icon (v26). Foreground and background images present. | `android/app/src/main/res/mipmap-*` | ✅ OK | — |
| PS-4 | **Signing config present and correct** — keystore properties loaded from `key.properties`, R8 minification enabled, ProGuard rules cover Flutter, Gson, Play Core, and Firebase. | `android/app/build.gradle.kts` | ✅ OK | — |
| PS-5 | **`SCHEDULE_EXACT_ALARM` permission may trigger Play Store policy review** — This permission requires justification on Android 14+ (API 34). The notification service already handles the runtime check (`canScheduleExactNotifications`), but Play Store may flag the manifest declaration. | `AndroidManifest.xml:8` | P1 | Either: (a) switch to `USE_EXACT_ALARM` if the app is an alarm/reminder app, or (b) use `setAndAllowWhileIdle()` / `setWindow()` instead of exact alarms to avoid the permission entirely. If keeping it, prepare a Play Store declaration explaining the use case (tank maintenance reminders). |
| PS-6 | **Missing INTERNET permission in release manifest** (see ER-5) | `AndroidManifest.xml` | P0 | **Critical** — add `<uses-permission android:name="android.permission.INTERNET"/>` |
| PS-7 | **`google-services.json` present** — Firebase properly configured. | `android/app/google-services.json` | ✅ OK | — |
| PS-8 | **ProGuard rules adequate** — Flutter, Gson, Play Core, and Firebase are covered. Supabase uses OkHttp under the hood (via the Android SDK) which is already handled by default R8 rules. | `android/app/proguard-rules.pro` | ✅ OK | — |
| PS-9 | **`android:allowBackup="false"` is set** — Good for security (prevents ADB backup extraction of user data). | `AndroidManifest.xml` | ✅ OK | — |

---

## P0 Summary (Must Fix Before Release)

| ID | Issue | Impact |
|----|-------|--------|
| **ER-5 / PS-6** | Missing INTERNET permission in release AndroidManifest | **All network features silently broken in release builds** — Firebase, Supabase, any API calls. App appears to work but analytics/sync/crash reporting are dead. |
| **ER-1** | Force-unwrap on nullable `_auth` in auth_service.dart | **Crash if Supabase init fails** — affects sign-up, sign-in, password reset flows. |

## P1 Summary (Should Fix Before Release)

| ID | Issue |
|----|-------|
| FRE-1 | Crashlytics error handler set up after runApp — first-frame errors lost |
| FRE-3 | Fonts not bundled but runtime fetching disabled — fallback to system fonts |
| VP-5 | About screen uses placeholder icon instead of actual app icon |
| VP-6 | Splash screen uses generic water_drop icon instead of branded logo |
| ER-2 | Force-unwrap on `_selectedImage` in fish_id_screen |
| ER-3 | Force-unwrap on nullable equipment fields |
| ER-4 | Force-unwrap on `maxSizeCm` in fish ID results |
| SQ-3 | Tab label "Toolbox" misleading (leads to Settings) |
| CS-1 | 4 TODO comments indicating unfinished work |
| PS-5 | SCHEDULE_EXACT_ALARM may need Play Store justification |

## P2 Summary (Nice to Have)

| ID | Issue |
|----|-------|
| FRE-2 | Redundant Navigator push in OnboardingScreen |
| VP-1 | 159 hardcoded Color values |
| VP-2 | 354 uses of Material Colors.xxx |
| VP-3 | 54 remaining .withOpacity() calls |
| VP-4 | ~30 hardcoded fontSize values |
| SQ-1/2 | Friends/Leaderboard "Coming Soon" screens exist (hidden) |
| SQ-4 | No string localisation |
| MR-1 | 4,980-line dead code file |
| MR-2 | Unbounded _displayCount in activity feed |
| MR-3 | In-memory singleton storage (MVP acceptable) |
| CS-2 | 13 files over 1000 lines |
| CS-3 | Overlapping AppOverlays/AppColors alpha systems |

---

## What's Good (Highlights)

- **Theme system is production-grade** — comprehensive constants, pre-computed alphas, dual light/dark themes, adaptive extensions
- **Error boundary with recovery UI** — catches Flutter errors and shows user-friendly fallback
- **Storage corruption handling** — automatic backup, state tracking, graceful degradation
- **Custom page transitions** — consistent slide+fade across all platforms
- **Accessibility foundations** — `AppTouchTargets`, `AppTouchPadding`, WCAG-compliant color contrast noted in comments
- **Performance optimizations** — lazy-loaded lesson content, portrait lock, deferred Firebase init
- **Clean provider-driven routing** — prevents duplicate screen bugs
- **Double-back-to-exit** — proper UX for Android back button
- **Rive animations** — 4 animation files for premium feel
- **Rich asset library** — onboarding images, empty states, error states, badge icons all present
