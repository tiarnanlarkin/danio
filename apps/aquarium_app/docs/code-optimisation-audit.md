# Code Quality + APK Size Optimisation Audit
**Date:** 2026-03-29  
**Branch:** `openclaw/stage-system`  
**Auditor:** Prometheus (T-D-281)  
**Current APK size (arm64-v8a release):** ~35.8 MB  

---

## Executive Summary

The codebase is in good shape overall. ProGuard/R8 is active, ABI splits are configured, and most providers that should auto-dispose do so. The largest wins come from: (1) converting two oversized PNG illustrations to WebP, (2) deleting confirmed dead code, (3) noting a **critical asset bug** (two assets not declared in pubspec), and (4) a dead analytics service that ships with the app but never fires.

Estimated total APK savings: **~2.5–3.5 MB** (arm64 APK; more on AAB/Play Delivery).

---

## 1. Dead Code

### 1.1 Confirmed Dead (can be deleted)

| File(s) | Status | Lines | Notes |
|---|---|---|---|
| `lib/features/smart/anomaly_detector/` | ✅ **Never existed** — no such directory found | — | Mentioned in brief but already cleaned up |
| `lib/models/exercises.dart` | ✅ **Already deleted** | — | Mentioned in brief but file not found |
| `lib/widgets/tutorial_overlay.dart` | ✅ **Already deleted** | — | Mentioned in brief but file not found |
| `lib/services/haptic_service.dart` | ✅ **Already deleted** | — | Mentioned in brief but file not found |
| `lib/services/firebase_analytics_service.dart` | 🔴 **Dead** — defined but never called from any other file | 61 | `FirebaseAnalyticsService.instance` has zero usages outside itself |
| `lib/screens/friends_screen.dart` | 🟡 **Dormant** — unreachable (hidden at `CA-002`, comment in settings_hub_screen.dart) | 108 | Not strictly deletable yet, but adds to APK |

### 1.2 Partially Active (auth feature)

The brief noted `lib/features/auth/` as dead, but it is **not dead**:
- `lib/screens/account_screen.dart` imports and uses `authProvider`, `AuthNotifier`, `AuthState`
- `lib/services/cloud_sync_service.dart` watches `authProvider`
- **Verdict:** Auth feature is **live and wired**. Do not delete.

### 1.3 Placeholder Files (near-zero weight, safe to leave)

| File | Size | Notes |
|---|---|---|
| `lib/screens/livestock/livestock_edit_dialog.dart` | 3 lines | Re-export shim only |
| `lib/screens/livestock/livestock_filter_widget.dart` | 5 lines | Re-export shim only |
| `lib/screens/livestock/livestock_compatibility_check.dart` | 3 lines | Re-export shim only |

These are intentional named-discoverability shims; they cost nothing in the APK.

### 1.4 Dead Code Totals

| Category | Files | ~Lines |
|---|---|---|
| `firebase_analytics_service.dart` (dead singleton) | 1 | 61 |
| `friends_screen.dart` (dormant, CA-002) | 1 | 108 |
| **Deletable subtotal** | **2** | **~169** |

**APK savings from dead code:** Negligible on its own (~5–10 KB), but `firebase_analytics_service.dart` keeping `firebase_analytics` linked unnecessarily is worth checking — see Dependencies section.

---

## 2. Asset Optimisation

### 2.1 🚨 Critical Bug: Missing pubspec Declarations

Two illustration assets are used in Dart code but **not declared in `pubspec.yaml`**:

```
assets/images/illustrations/learn_header.png   (1.44 MB)
assets/images/illustrations/practice_header.png (966 KB)
```

**Used in:**
- `lib/screens/learn/learn_screen.dart:312`
- `lib/screens/practice_hub_screen.dart:62`

**Impact:** These assets will throw a `flutter_assets` error at runtime (`Unable to load asset`) — this is a latent crash bug on any device where the image is rendered. The `assets/images/illustrations/` directory is not listed in pubspec's `assets:` block.

**Fix:** Add `- assets/images/illustrations/` to `pubspec.yaml` assets section. (Not a code change, just YAML — but noting it here as it's a quality issue.)

### 2.2 PNG → WebP Conversion Opportunities

The two illustration PNGs are by far the largest assets in the app:

| File | Current Size | Est. WebP Size | Est. Saving |
|---|---|---|---|
| `assets/images/illustrations/learn_header.png` | **1,444 KB** | ~200–350 KB | **~1.1–1.2 MB** |
| `assets/images/illustrations/practice_header.png` | **966 KB** | ~150–250 KB | **~720–820 KB** |
| **Fish images (13 files)** | **~1.9 MB total** | ~950 KB–1.1 MB | **~800 KB–1 MB** |

Converting these PNGs to WebP (quality 85–90) would save approximately **2–3 MB** from the APK assets.

The fish thumbnails (`assets/images/fish/thumb/`) are small (10–28 KB) — conversion still worth doing but lower priority.

### 2.3 Background WebPs (Already Optimised)

All 12 room backgrounds are already in WebP format (68–155 KB each). No action needed.

### 2.4 Font Audit

Fonts total **2.0 MB** bundled. All are actively used:

| Font | Weights Bundled | Weights Used | Notes |
|---|---|---|---|
| Nunito-Regular.ttf (276 KB) | w400 + w300 alias | ✅ | w300 maps to w400 per R-089 comment |
| Nunito-Italic.ttf (281 KB) | italic | ✅ | Used in Smart screens, breeding guide, etc. |
| Nunito-Medium.ttf (303 KB) | w500 | ✅ | Used in analytics, difficulty settings |
| Nunito-SemiBold.ttf (303 KB) | w600 | ✅ | Widely used |
| Nunito-Bold.ttf (303 KB) | w700 | ✅ | Widely used |
| Nunito-ExtraBold.ttf (303 KB) | w800 | ✅ | Used in onboarding, heater status widget |
| Fredoka-Regular.ttf (159 KB) | w400 | ✅ | Used via GoogleFonts.fredoka() |
| Fredoka-SemiBold.ttf (48 KB) | w600 | ✅ | Used in headings |
| Fredoka-Bold.ttf (48 KB) | w700 | ✅ | Used in headlineLarge |

**Observation:** `google_fonts` package is needed even though runtime fetching is disabled (`allowRuntimeFetching = false`) — GoogleFonts wraps the bundled TTF files. This is correct; no savings available here.

### 2.5 Rive Animations

| File | Size | Used? |
|---|---|---|
| `emotional_fish.riv` | 887 KB | ✅ — `rive_fish.dart` |
| `joystick_fish.riv` | (small) | ✅ — `rive_fish.dart` |
| `puffer_fish.riv` | (small) | ✅ — `rive_fish.dart` |
| `water_effect.riv` | (small) | ✅ — `rive_water_effect.dart` |

All Rive files are used. `emotional_fish.riv` at 887 KB is the largest — worth checking if Rive's export could compress it further, but this is an upstream concern.

### 2.6 Summary: Estimated Asset Savings

| Action | Estimated APK Saving |
|---|---|
| Convert `learn_header.png` + `practice_header.png` to WebP | **~2.0–2.1 MB** |
| Convert fish PNGs (13 files) to WebP | **~0.8–1.0 MB** |
| **Total** | **~2.8–3.1 MB** |

---

## 3. Dependency Audit

### 3.1 All Dependencies

```
flutter_riverpod ^2.6.1       — core, essential
http ^1.2.2                   — used (OpenAI proxy, etc.)
uuid ^4.5.1                   — used
intl ^0.20.2                  — used (date formatting)
collection ^1.19.1            — used
synchronized ^3.3.0+3         — used (storage lock)
connectivity_plus ^6.1.2      — used (offline detection)
fl_chart ^0.69.2              — used (analytics screen)
google_fonts ^6.2.1           — used (bundled font wrapper)
flutter_animate ^4.5.0        — used (widespread)
rive ^0.13.0                  — used (fish animations)
confetti ^0.7.0               — used (gem shop screen)
skeletonizer ^2.1.2           — used (learn/equipment screens)
path_provider ^2.1.5          — used
share_plus ^10.1.4            — used (analytics export)
image_picker ^1.1.2           — used (log photo)
path ^1.9.0                   — used
shared_preferences ^2.3.3     — used
url_launcher ^6.3.1           — used
file_picker ^8.1.7            — used (backup restore)
flutter_local_notifications ^18.0.1 — used (notification service)
in_app_review ^2.0.9          — used (lesson complete)
timezone ^0.10.0              — used (notifications TZ)
archive ^3.6.1                — used (backup compression)
cached_network_image ^3.4.1   — used (livestock images)
supabase_flutter ^2.8.4       — used (auth + sync)
encrypt ^5.0.3                — used (cloud backup encryption)
crypto ^3.0.6                 — used (HMAC/hash for AI proxy)
firebase_core ^2.24.2         — used (init + Crashlytics guard)
firebase_analytics ^10.7.4    — ⚠️ QUESTIONABLE (see below)
firebase_crashlytics ^3.4.9   — used
```

### 3.2 Suspicious Dependency: `firebase_analytics`

- `firebase_analytics ^10.7.4` is declared and initialised in `main.dart`
- `lib/services/firebase_analytics_service.dart` wraps it with a nice API
- **But `FirebaseAnalyticsService` is never imported or called anywhere in the app**

Firebase Analytics is still being initialised and tracking sessions (the SDK auto-tracks screen views and sessions even without explicit calls). This may be intentional. But if analytics was paused pending GDPR consent implementation, the dependency could be temporarily removed to save:
- ~200 KB from the APK (Firebase Analytics SDK)
- Removes the dead `firebase_analytics_service.dart`

**Recommendation:** Either wire `FirebaseAnalyticsService` into the app (it's already fully built) or remove it. Currently it adds dead weight.

### 3.3 Potentially Reduceable: `google_fonts`

The `google_fonts` package is ~1.2 MB in the pub cache but compiles to very little in the APK (it's mostly Dart code). With `allowRuntimeFetching = false`, all fonts are served from bundled TTFs. The package is worth keeping for its convenient API.

### 3.4 No Unused Dependencies Found

All other packages have confirmed call sites in `lib/`.

---

## 4. Build Configuration

### 4.1 Current State ✅

```kotlin
// android/app/build.gradle.kts
buildTypes {
    release {
        isMinifyEnabled = true       ✅ R8 minification ON
        isShrinkResources = true     ✅ Resource shrinking ON
        proguardFiles(...)           ✅ ProGuard rules configured
    }
}
splits {
    abi {
        isEnable = true              ✅ ABI splits active
        include("arm64-v8a", "armeabi-v7a", "x86_64")
        isUniversalApk = true        ✅ Universal APK also built
    }
}
```

**Current release APK sizes:**
- `app-arm64-v8a-release.apk`: **35.8 MB** (primary target)
- `app-armeabi-v7a-release.apk`: 33.4 MB  
- `app-x86_64-release.apk`: 37.5 MB  
- `app-universal-release.apk`: 88.6 MB (includes all ABIs)

### 4.2 Missing: App Bundle (AAB)

The build produces APKs but **no AAB** (Android App Bundle) for Play Store submission. AAB allows Play to serve per-device APKs, reducing download size by ~20–30%.

**Estimated saving:** On Play Store, arm64 download would drop from ~35.8 MB to approximately **28–32 MB** (assets + font subsetting + native lib stripping by Play).

**Action:** Add AAB build step. With Flutter: `flutter build appbundle --release`.

### 4.3 Missing: Baseline Profile

No baseline profile (`.prof` file) is configured. Baseline Profiles pre-compile hot paths, reducing app startup time by 20–40% and jank on first run.

**Action:** Generate with `flutter build apk --profile` + Macrobenchmark, or use [Jetpack Macrobenchmark](https://developer.android.com/topic/performance/baselineprofiles).

### 4.4 ProGuard Rules: Minor Issue

```proguard
-keep class io.flutter.** { *; }
```

The Flutter-specific keep rules are overly broad (keeping all `io.flutter.*`). Flutter's own Gradle plugin provides optimised rules. These broad rules may prevent R8 from removing unused Flutter internals.

**Low priority** — Flutter's plugin handles this correctly in modern versions.

### 4.5 NDK Version Pinned

```kotlin
ndkVersion = "28.2.13676358" // Match plugin-required Windows NDK for local testing
```

This is intentional for local Windows builds. Fine to leave.

### 4.6 Build Summary

| Item | Status | Priority |
|---|---|---|
| R8 minification | ✅ ON | — |
| Resource shrinking | ✅ ON | — |
| ABI splits | ✅ ON | — |
| App Bundle (AAB) | ❌ Missing | **HIGH** |
| Baseline Profile | ❌ Missing | MEDIUM |
| Deferred components | Not used | LOW |

---

## 5. Riverpod Provider Health

### 5.1 AutoDispose Audit

**Total providers found:** ~67 top-level `final *Provider =` declarations  
**AutoDispose providers:** 21  

### 5.2 Providers That Should AutoDispose (Currently Don't)

The following providers hold **per-tank or per-session data** but are not marked `autoDispose`. They persist in memory for the entire app lifecycle:

| Provider | File | Concern |
|---|---|---|
| `stageProvider` | `widgets/stage/stage_provider.dart` | UI state for home screen panels — lives forever |
| `celebrationProvider` | `services/celebration_service.dart` | Animation state — should die with screen |
| `aiHistoryProvider` | `features/smart/smart_providers.dart` | AI call history — only needed while Smart screen is open |
| `anomalyHistoryProvider` | `features/smart/smart_providers.dart` | Same — Smart screen only |
| `weeklyPlanProvider` | `features/smart/smart_providers.dart` | Same — Smart screen only |
| `authProvider` | `features/auth/auth_provider.dart` | App-global — keeping alive is **correct** |
| `gemsProvider` | `providers/gems_provider.dart` | App-global wallet state — correct |
| `settingsProvider` | `providers/settings_provider.dart` | App-global — correct |
| `userProfileProvider` | `providers/user_profile_notifier.dart` | App-global — correct |

**Genuine concerns:**
- `stageProvider` (`StateNotifierProvider`) is used in `home_screen.dart` but doesn't auto-dispose. Since it's a home-screen concern, making it `autoDispose` could cause issues if the home screen rebuilds. **Low leak risk** but worth reviewing.
- Smart feature providers (`aiHistoryProvider`, `anomalyHistoryProvider`, `weeklyPlanProvider`) are not auto-disposing and hold cached API responses indefinitely. These should be `.autoDispose` since the Smart screen is not always visible.

### 5.3 StateNotifier Subscriptions

`AuthNotifier` holds a `StreamSubscription` (`_authSub`) and disposes it correctly in `dispose()`. ✅

`SyncService` and other stateful notifiers appear to cancel subscriptions on dispose. ✅

### 5.4 Family Providers

`tankProvider`, `livestockProvider`, `equipmentProvider`, `logsProvider`, `allLogsProvider`, `recentLogsProvider` — all `FutureProvider.autoDispose.family`. ✅ Correct pattern.

`tasksProvider` — `FutureProvider.autoDispose.family`. ✅

### 5.5 Provider Memory Leak Summary

| Issue | Risk | Recommendation |
|---|---|---|
| Smart feature providers (3) not autoDispose | MEDIUM | Add `.autoDispose` — they cache AI responses in RAM indefinitely |
| `stageProvider` not autoDispose | LOW | Minor; home screen lives for app lifetime anyway |
| Auth/gems/settings/user profile — not autoDispose | ✅ CORRECT | These are intentionally global |

---

## 6. Other Quality Observations

### 6.1 Illustrations Not Declared in pubspec ⚠️

As noted in §2.1, `assets/images/illustrations/` is missing from pubspec `assets:` block. This is a **latent crash bug** — both `learn_header.png` and `practice_header.png` will fail to load at runtime. Given these are large (1.4 MB + 966 KB), they should be converted to WebP before being declared.

### 6.2 Redundant Font Entry

In `pubspec.yaml`, `Nunito-Regular.ttf` is declared **twice** — once without weight and once for `weight: 300`. This is intentional per the R-089 comment and is not a bug, but worth noting.

### 6.3 ImageCacheService Usage

`image_cache_service.dart` (222 lines) is imported in `log_detail_screen.dart` and provides the `CachedImage` widget. It IS used. Not dead code.

### 6.4 Firebase Analytics vs Crashlytics

Firebase Crashlytics is properly wired (initialised in `main.dart`, error handlers set up). Firebase Analytics SDK initialises but no events are ever logged via `FirebaseAnalyticsService`. This means Firebase auto-collects session/screen data but no custom events.

---

## 7. Summary: Recommended Actions by Priority

### HIGH (biggest APK impact)

| # | Action | Est. APK Saving | Effort |
|---|---|---|---|
| H-1 | Convert `learn_header.png` + `practice_header.png` to WebP (quality 85) and add `assets/images/illustrations/` to pubspec | **~2.0–2.1 MB** | 1h |
| H-2 | Convert 13 fish PNGs to WebP | **~0.8–1.0 MB** | 1h |
| H-3 | Build AAB for Play Store (not APK) | **~20–30% download reduction** | 30m |

### MEDIUM

| # | Action | Est. APK Saving | Effort |
|---|---|---|---|
| M-1 | Wire `FirebaseAnalyticsService` into the app OR remove it + remove `firebase_analytics` dep | ~100–200 KB | 2h (wire) / 30m (remove) |
| M-2 | Mark Smart feature providers autoDispose (`aiHistoryProvider`, `anomalyHistoryProvider`, `weeklyPlanProvider`) | Memory (not APK) | 30m |
| M-3 | Delete `lib/services/firebase_analytics_service.dart` if removing analytics | ~0 KB (dead code) | 5m |
| M-4 | Add Baseline Profile for startup performance | Startup time −20–40% | 4h |

### LOW

| # | Action | Notes |
|---|---|---|
| L-1 | Delete `friends_screen.dart` (108 lines, CA-002 feature) | Only when feature is formally cut |
| L-2 | Review `stageProvider` for autoDispose | Low risk; home screen is persistent anyway |
| L-3 | Fix broad ProGuard keep rules for `io.flutter.**` | Modern Flutter plugin handles this |

---

## 8. Estimated Total APK Savings

| Category | Saving |
|---|---|
| PNG → WebP (illustrations + fish) | ~2.8–3.1 MB |
| Remove `firebase_analytics` dep (if cutting) | ~100–200 KB |
| Dead code deletion | ~10 KB |
| **Total (direct APK reduction)** | **~3.0–3.3 MB** |
| **Play Store AAB vs APK** | **Additional ~20–30% on user download** |

Starting from arm64 release APK of **35.8 MB**, optimised result: ~**32–33 MB APK** / ~**25–28 MB Play download**.
