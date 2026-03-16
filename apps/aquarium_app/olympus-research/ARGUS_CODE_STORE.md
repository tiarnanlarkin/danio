# ARGUS — Accessibility & Store Readiness Audit
**Date:** 2026-03-16  
**Auditor:** Argus sub-agent  
**Repo:** `/mnt/c/Users/larki/Documents/Danio Aquarium App Project/repo/apps/aquarium_app`  
**Scope:** Accessibility gaps, hardcoded strings, Play Store readiness

---

## TL;DR

| Metric | Result |
|--------|--------|
| **Accessibility gaps (screens w/ no semantics)** | **69 of 110 screen files (63%)** |
| **Play Store blockers** | **2 blockers, 3 warnings** |
| **Permissions declared** | **6 permissions** |
| **App version** | **1.0.0+1** (versionCode: 1) |

---

## 1. ACCESSIBILITY

### 1.1 Semantics Coverage

- **42 files** use `Semantics()`, `semanticsLabel`, or `tooltip:` — these are partially covered
- **69 of 110 screen files** have **zero** accessibility annotations (no Semantics, no tooltip, no semanticsLabel)
- **41 widgets exist** (`accessibility_utils.dart` is present — good foundation, not universally applied)

#### Screens With Zero Semantics Coverage (HIGH PRIORITY — user-facing with interactive elements)

| Screen | Interactive Elements | Risk |
|--------|---------------------|------|
| `onboarding_screen.dart` | 7 buttons/gestures | 🔴 CRITICAL — first run |
| `onboarding/learning_style_screen.dart` | 2 | 🔴 CRITICAL |
| `onboarding/enhanced_placement_test_screen.dart` | 3 | 🔴 CRITICAL |
| `achievements_screen.dart` | Interactive cards | 🔴 HIGH |
| `learn_screen.dart` | Lesson cards (has partial coverage via `Coming Soon` labels) | 🟡 MEDIUM |
| `add_log_screen.dart` | Forms, inputs | 🔴 HIGH |
| `settings_screen.dart` | Toggle switches | 🔴 HIGH |
| `notification_settings_screen.dart` | Toggles | 🔴 HIGH |
| `tank_settings_screen.dart` | Buttons | 🟡 MEDIUM |
| `backup_restore_screen.dart` | Buttons | 🟡 MEDIUM |
| `friends_screen.dart` | (Stub UI — "On the Way") | 🟢 LOW (no real interactions) |
| `leaderboard_screen.dart` | (Stub UI — "On the Way") | 🟢 LOW |
| `photo_gallery_screen.dart` | Images, grid | 🟡 MEDIUM |
| `inventory_screen.dart` | List items | 🟡 MEDIUM |
| `compatibility_checker_screen.dart` | Search + results | 🟡 MEDIUM |
| `co2_calculator_screen.dart` | Inputs, results | 🟡 MEDIUM |
| `difficulty_settings_screen.dart` | Options | 🔴 HIGH |
| `placement_test_screen.dart` | Quiz interactions | 🔴 HIGH |
| `tab_navigator.dart` | Tab bar (labels present via `label:` prop — ✅ covered) | 🟢 LOW |

**Tank Detail widgets with no semantics (affects all tank views):**
- `alerts_card.dart`, `quick_stats.dart`, `tank_health_card.dart`, `trends_section.dart`, `stocking_indicator.dart`, `livestock_preview.dart`, `equipment_preview.dart`, `logs_list.dart`

### 1.2 IconButtons Without Tooltips (Screen Reader Gap)

Multiple `IconButton` widgets across **53 screen files** lack `tooltip:` — screen readers will announce "button" with no context:

| Screen | Unlabelled IconButtons |
|--------|----------------------|
| `home_screen.dart` | Settings icon, close buttons (some have tooltip, some don't) |
| `cost_tracker_screen.dart` | Delete trailing button |
| `log_detail_screen.dart` | Edit + delete actions |
| `gem_shop_screen.dart` | Back/info button |
| `account_screen.dart` | Password visibility toggle |
| `create_tank_screen.dart` | Back button in custom wrapper |

**Note:** `home_screen.dart` line 500 has `tooltip: 'Tank Settings'` ✅ but line 491 close button has no tooltip ❌.

### 1.3 Hardcoded Colours — Contrast Risk

Theme is defined centrally in `app_theme.dart`. Key colours with potential contrast issues:

| Colour | Hex | Use Case | Risk |
|--------|-----|----------|------|
| `AppColors.error` | `#D96A6A` | Error text on white backgrounds | 🔴 **Fails WCAG AA** (~3.0:1 ratio on white — needs 4.5:1) |
| `AppColors.accent` | `#5B9EA6` | Teal on white/cream backgrounds | 🟡 Borderline (~3.1:1 on white) |
| `AppColors.primaryLight` | `#D97706` (xp colour) | XP display on light bg | 🟡 Borderline on cream backgrounds |
| `AppColors.paramDanger` | `#D96A6A` | Parameter danger text | 🔴 Same as error — fails on white |
| `AppColors.textSecondary` | `#636E72` | Secondary text on `#FFF5E8` cream | 🟡 ~4.3:1 — borderline, close to AA |
| `AppColors.success` | `#5AAF7A` | Success text on white | 🟡 ~3.4:1 — fails WCAG AA for text |
| `AppColors.warning` | `#C99524` | Warning text on white | ✅ ~4.52:1 (team noted this, compliant) |
| `AppColors.info` | `#5C9FBF` | Info text on white | 🔴 ~3.1:1 — fails |

**Theme note:** `AppColors.error` (`#D96A6A`) is used directly as **text colour** in:
- `fish_id_screen.dart` — `TextStyle(color: AppColors.error)` on white background ❌
- `symptom_triage_screen.dart` — same pattern ❌
- `algae_guide_screen.dart`, `co2_calculator_screen.dart` — same ❌

The `success` and `info` colours also used as text directly in multiple screens — all fail WCAG AA on white backgrounds.

### 1.4 Sync Debug Dialog in Production

`SyncDebugDialog` is shown to users via `SyncIndicator` (tap the sync banner) **with no `kDebugMode` guard**. This exposes internal sync state details (queue size, error messages, timestamps) to all users. Not a crash risk but unprofessional and leaks implementation details.

---

## 2. HARDCODED STRINGS

The following user-visible strings are hardcoded in widget build methods (not localised via ARB/l10n):

### Critical (visible on main user journeys)

| Screen | String | Location |
|--------|--------|----------|
| `home_screen.dart` | `'Community Tank'` | Line 266 — tank name fallback |
| `home_screen.dart` | `'Quick Water Test'` | Section header |
| `home_screen.dart` | `'Water Parameters'` | Section header |
| `home_screen.dart` | `'Feeding'` | Section header |
| `home_screen.dart` | `'Tank Stats'` | Stats card title |
| `home_screen.dart` | `'Check your connection and give it another go'` | Offline error message |
| `home_screen.dart` | `'Log Water Test'` | Button label |
| `home_screen.dart` | `'Just now'` | Time formatter output |
| `home_screen.dart` | `'Not recorded yet'`, `'Not logged yet'` | Empty state strings |
| `home_screen.dart` | `'💡 Swipe from the edges...'` | Coach tip snackbar |
| `learn_screen.dart` | `'Coming Soon 🚧'` | Feature badge |
| `friends_screen.dart` | `'On the Way!'`, `'Social Features'` | Stub screen |
| `leaderboard_screen.dart` | `'Leaderboard'`, coming soon copy | Stub screen |
| `tab_navigator.dart` | `'Learn'`, `'Practice'`, `'Tank'`, `'Smart'`, `'More'` | Nav bar labels |

**Note:** The app has no `l10n`/ARB infrastructure at all — there's no `intl_en.arb` or `AppLocalizations` class. All strings are hardcoded. This is acceptable for a v1 English-only launch but blocks future localisation.

---

## 3. STORE READINESS

### 3.1 AndroidManifest.xml — Permissions

| Permission | Declared? | Justification Present | Status |
|------------|-----------|----------------------|--------|
| `INTERNET` | ✅ | In comment | ✅ Required |
| `POST_NOTIFICATIONS` | ✅ | In comment | ✅ Required (Android 13+) |
| `VIBRATE` | ✅ | In comment | ✅ Required for notifications |
| `RECEIVE_BOOT_COMPLETED` | ✅ | In comment | ✅ Required for scheduled reminders |
| `SCHEDULE_EXACT_ALARM` | ✅ | **Full justification comment present** ✅ | ⚠️ Play Store scrutiny expected |
| `CAMERA` | ✅ | In comment (Fish ID) | ✅ with `required="false"` |
| `READ_MEDIA_IMAGES` | ✅ | In comment (gallery for Fish ID) | ✅ Required |

**Total: 6 permissions declared.**

**`SCHEDULE_EXACT_ALARM` note:** This permission triggers mandatory Play Store review. The inline comment justification is solid (exact times for tank care reminders). Make sure this is reflected verbatim in the Play Store declaration form.

**Potentially unused:** `READ_MEDIA_IMAGES` — only needed if users pick images from gallery for Fish ID. If the Fish ID gallery picker isn't implemented or is gated, this may need `READ_MEDIA_VISUAL_USER_SELECTED` instead (Android 14+ granular permission) to avoid review flags.

### 3.2 Debug Flags & Test Keys

| Finding | File | Risk |
|---------|------|------|
| `const bool _showPerformanceOverlay = false;` | `main.dart:35` | ✅ Off in release — safe |
| `kDebugMode && false` performance monitoring | `main.dart:34` | ✅ Disabled — safe |
| `PerformanceDebugScreen` widget exists | `performance_overlay.dart` | ✅ Not accessible in release |
| `SyncDebugDialog` accessible via tap in production | `sync_indicator.dart:31` | ⚠️ No `kDebugMode` guard |
| OpenAI API key via `--dart-define` | `openai_service.dart:11` | ✅ Correct pattern — not hardcoded |
| No hardcoded API keys found | — | ✅ Clean |
| No `test_key` or `TODO: replace` in lib | — | ✅ Clean |

### 3.3 pubspec.yaml

```
name: danio
version: 1.0.0+1
description: "Danio — learn aquarium keeping through bite-sized lessons..."
package: com.tiarnanlarkin.danio  (set in build.gradle.kts)
```

| Check | Status |
|-------|--------|
| Version | `1.0.0+1` — versionCode **1** |
| Description | Real, meaningful description ✅ |
| Placeholder values | None found ✅ |
| `publish_to: 'none'` | Set correctly ✅ |
| SDK constraint | `^3.10.8` ✅ |

**Note:** versionCode `1` is fine for initial submission. Increment to `2` on any subsequent resubmission or you'll get a "version code must be higher" rejection.

### 3.4 Placeholder / Lorem Ipsum Content

No lorem ipsum found. The following are legitimate "coming soon" screens (intentional stubs, tracked in PRD):
- `friends_screen.dart` — "On the Way! Social Features" (TRACKED: CA-002)
- `leaderboard_screen.dart` — "On the Way!" (TRACKED: CA-003)
- `learn_screen.dart` — `'Coming Soon 🚧'` badge on unfinished learning paths

**Verdict:** These are acceptable for submission IF the Play Store listing doesn't promise these features as core functionality in screenshots/description. Flag them in the store listing as "future update" if visible in screenshots.

### 3.5 ProGuard / R8 Rules

`android/app/proguard-rules.pro` **exists and is configured** ✅

Contents:
- Flutter wrapper classes kept ✅
- Gson rules ✅  
- Play Core keep rules ✅  
- Firebase keep rules ✅

`isMinifyEnabled = true` and `isShrinkResources = true` are set in `buildTypes.release` ✅

---

## 4. android/app/build.gradle.kts

| Setting | Value | Status |
|---------|-------|--------|
| `namespace` | `com.tiarnanlarkin.danio` | ✅ |
| `compileSdk` | `flutter.compileSdkVersion` (resolved at build time) | ✅ |
| `minSdk` | `flutter.minSdkVersion` = **24** (Android 7.0) | ✅ Good — targets 94%+ of active devices |
| `targetSdk` | `flutter.targetSdkVersion` (Flutter 3.38.9 default = **35**) | ✅ Required for new Play Store submissions |
| `versionCode` | `flutter.versionCode` = **1** | ✅ |
| `versionName` | `flutter.versionName` = **1.0.0** | ✅ |
| Release signing | `signingConfigs.release` configured via `key.properties` | ✅ |
| keystore file | `aquarium-release.jks` with alias `aquarium` | ✅ |
| `isMinifyEnabled` (release) | `true` | ✅ |
| `isShrinkResources` (release) | `true` | ✅ |
| ProGuard | `proguard-android-optimize.txt` + `proguard-rules.pro` | ✅ |
| Core library desugaring | `isCoreLibraryDesugaringEnabled = true` | ✅ |

**Note:** `suppressMinSdkVersionError=21` in `gradle.properties` — this suppresses an NDK 28 error but the actual minSdk is 24. The suppression is safe but slightly misleading. Document this.

---

## 5. PLAY STORE BLOCKERS

### 🔴 BLOCKER 1: `SCHEDULE_EXACT_ALARM` requires Play Store declaration
This permission requires filling out a **"Alarms & reminders" declaration** in Play Console (Policy → App content). You must describe exactly why exact alarms are needed. The inline code comment is good source material — copy it to the declaration.

### 🔴 BLOCKER 2: OpenAI API Key must be injected at build time
The app uses `String.fromEnvironment('OPENAI_API_KEY')`. If the AAB is built **without** `--dart-define=OPENAI_API_KEY=sk-...`, the key will be empty and Fish ID / AI features will silently fail. Ensure the CI/release build pipeline always passes this key. No hardcoded fallback means no error message if omitted.

### ⚠️ WARNING 1: `AppColors.error` fails WCAG AA contrast
`#D96A6A` on white is ~3.0:1 — below the 4.5:1 minimum for normal text. Google Play's accessibility policy doesn't block on this, but it's a real usability issue. Replace error text colours with the darker `#C0392B` (≥4.5:1) or use `onError` semantically.

### ⚠️ WARNING 2: `SyncDebugDialog` exposed in production
Users can tap the sync banner to see internal state. Not a blocker but unprofessional. Wrap in `if (kDebugMode)` or replace with a user-friendly "Sync status" summary.

### ⚠️ WARNING 3: Accessibility coverage is 37% (63% screens have no semantics)
Not a Play Store blocker but Google Play has been flagging apps with poor TalkBack support since 2024. Critical paths (onboarding, lesson, practice) should be fixed before submission.

---

## 6. SUMMARY TABLE

| Category | Count | Severity |
|----------|-------|----------|
| Screens with zero accessibility annotations | 69 | 🔴 High |
| Unlabelled IconButton instances across screens | ~30+ | 🟡 Medium |
| Colour contrast failures (error/success/info text on white) | 3 colour tokens | 🔴 High (WCAG) |
| SyncDebugDialog in production | 1 | 🟡 Medium |
| Play Store blockers | 2 | 🔴 Must fix |
| Play Store warnings | 3 | 🟡 Should fix |
| Hardcoded user-visible strings | ~40+ | 🟢 Low (v1 acceptable) |
| Permissions declared | 6 | — |
| Proguard configured | ✅ Yes | — |
| Release signing configured | ✅ Yes | — |
| App version | 1.0.0+1 | — |

---

## 7. RECOMMENDED FIX PRIORITY

1. **Before submission:** Declare `SCHEDULE_EXACT_ALARM` justification in Play Console
2. **Before submission:** Confirm OpenAI API key is in the release build pipeline
3. **Before submission:** Fix `AppColors.error` used as text colour (swap to darker shade ≥4.5:1)
4. **Soon after launch:** Add `tooltip:` to all `IconButton` widgets across 53 screens
5. **Soon after launch:** Add `Semantics()` wrappers to onboarding flow (screens 1-3 of new user journey)
6. **Near-term:** Guard `SyncDebugDialog` with `kDebugMode`
7. **Future:** Full semantics sweep on tank detail widgets and guide screens
