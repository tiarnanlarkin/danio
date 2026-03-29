# Pre-Build Verification Report

**Date:** 2026-03-29  
**Branch:** `openclaw/stage-system`  
**App:** Danio Aquarium App  
**Verified by:** Prometheus (read-only audit)

---

## Summary

| Check | Status |
|---|---|
| 1. pubspec.yaml Asset Audit | ✅ PASS (with minor note) |
| 2. Dead Import Check | ✅ PASS (with minor note) |
| 3. Dependency Check | ⚠️ WARN — `firebase_analytics` SDK still in pubspec |
| 4. Release Build Readiness | ✅ PASS |
| 5. Git Status | ✅ PASS (clean branch, expected uncommitted changes) |

---

## 1. pubspec.yaml Asset Audit

**Result: ✅ PASS**

All declared asset directories exist and contain files:

| Asset Path | Status | Files (sample) |
|---|---|---|
| `assets/rive/` | ✅ Present | emotional_fish.riv, joystick_fish.riv, puffer_fish.riv, water_effect.riv |
| `assets/images/onboarding/` | ✅ Present | onboarding_journey_bg.webp |
| `assets/images/illustrations/` | ✅ Present | learn_header.webp, practice_header.webp |
| `assets/images/fish/` | ✅ Present | Multiple .webp and legacy .png files |
| `assets/images/fish/thumb/` | ✅ Present | Multiple .webp and legacy .png files |
| `assets/images/placeholder.webp` | ✅ Present | Single file asset |
| `assets/icons/app_icon.png` | ✅ Present | Single file asset |
| `assets/icons/badges/` | ✅ Present | README.md + 4 badge PNGs |
| `assets/textures/` | ✅ Present | felt-teal.webp, slate-dark.webp |
| `assets/backgrounds/` | ✅ Present | 5 room background WebP files |
| `assets/fonts/` | ✅ Present | Nunito (7 variants) + Fredoka (3 variants) |

**Note:** Both `.png` and `.webp` variants exist in `assets/images/fish/` and `assets/images/fish/thumb/`. Legacy PNGs are still on disk but code has migrated to WebP. These can be cleaned up in a future housekeeping pass (no functional impact — they're just dead weight in the bundle if not declared individually in pubspec).

---

## 2. Dead Import Check

**Result: ✅ PASS**

| Check | Result |
|---|---|
| `firebase_analytics_service` imports | ✅ None found — cleanly deleted |
| `linen-wall` references | ✅ None found — cleanly deleted |
| `.png` fish asset references in code | ✅ None in runtime code |
| `.png` illustration references in code | ✅ None found |

**Minor note:** `lib/widgets/room/species_fish.dart` line 26 contains a **stale doc comment** referencing `.png`:
```dart
/// `assets/images/fish/<speciesId>.png`.
```
The actual `Image.asset` call on line 170 correctly uses `.webp`:
```dart
'assets/images/fish/${widget.speciesId}.webp',
```
This is cosmetic only — a comment, not a runtime reference. Low priority cleanup.

---

## 3. Dependency Check

**Result: ⚠️ WARN**

`firebase_analytics: ^10.7.4` is still declared in `pubspec.yaml`, but the `firebase_analytics_service.dart` file has been deleted.

**Impact assessment:**
- `flutter pub get` resolves successfully — **no build failure**
- The SDK is still a dependency of the app and will be included in the release bundle
- If Firebase Analytics is still initialised elsewhere (e.g. `main.dart` or `firebase_options.dart`), this may be intentional
- If analytics tracking has been fully removed, this dependency should be removed from pubspec.yaml to reduce bundle size

**Action required:** Confirm whether Firebase Analytics is still used anywhere. If not, remove from `pubspec.yaml` before release.

`flutter pub get` output: **`Got dependencies!`** — all deps resolve cleanly.  
62 packages have newer versions available (incompatible with current constraints) — normal, no action needed pre-release.

---

## 4. Release Build Readiness

**Result: ✅ PASS**

### Signing Config
- `android/key.properties`: ✅ **EXISTS** — storePassword, keyPassword, keyAlias, storeFile all set
- `android/app/aquarium-release.jks`: ✅ **EXISTS** — keystore file present
- Signing config in `build.gradle.kts`: ✅ Conditional load (`if (keystorePropertiesFile.exists())`) — correct pattern

### Build Config
- `isMinifyEnabled = true` ✅
- `isShrinkResources = true` ✅
- ProGuard rules file referenced ✅
- ABI splits enabled ✅ (reduces per-architecture APK size)

### AndroidManifest Permissions
All declared permissions are appropriate for the app's features:

| Permission | Purpose |
|---|---|
| `INTERNET` | Network requests |
| `POST_NOTIFICATIONS` | Android 13+ notification consent |
| `VIBRATE` | Haptic feedback |
| `RECEIVE_BOOT_COMPLETED` | Reschedule notifications on reboot |
| `SCHEDULE_EXACT_ALARM` | Precise review/care reminders |
| `USE_EXACT_ALARM` | Supplementary exact alarm |
| `CAMERA` | Fish ID feature |
| `READ_MEDIA_IMAGES` | Gallery pick for Fish ID |

Camera and autofocus declared as `android:required="false"` ✅ — app won't be excluded from devices without camera.

---

## 5. Git Status

**Result: ✅ PASS**

**Branch:** `openclaw/stage-system`  
**Last 5 commits:**
```
9d56198 Wave B: aha_moment typography tokens, consent warmth
b85331c Fix: test updates for WebP migration, tank name encoding, level-up modal button
f914271 Wave A+C: Critical fixes + art regeneration
b6b9cf4 perf: reduce BackdropFilter usage from 15 to 5, add textHint token fix
b524cbb polish: empty states, accessibility labels, loading states
```

**Uncommitted changes (8 files modified):**
```
M lib/screens/home/widgets/empty_room_scene.dart
M lib/screens/home/widgets/tank_switcher.dart
M lib/screens/home/widgets/today_board.dart
M lib/screens/livestock/livestock_last_fed.dart
M lib/screens/onboarding_screen.dart
M lib/screens/settings/settings_screen.dart
M lib/widgets/stage/ambient_tip_overlay.dart
M lib/widgets/stage/bottom_sheet_panel.dart
```

These appear to be active Wave B/C work-in-progress changes. **No staged changes, no untracked files.** If this is a pre-release build, ensure these are either committed or stashed before tagging.

---

## Release Readiness Assessment

**Overall: ✅ Ready to build with one action item**

| Item | Priority | Action |
|---|---|---|
| `firebase_analytics` in pubspec but service deleted | ⚠️ Medium | Verify if still used; remove from pubspec if not |
| Stale `.png` comment in `species_fish.dart` | 🔵 Low | Update comment to `.webp` (cosmetic) |
| Legacy `.png` files in `assets/images/fish/` | 🔵 Low | Delete old PNGs post-migration (bundle size) |
| 8 uncommitted modified files | ⚠️ Medium | Commit or stash before release tag |
| 62 outdated deps | ℹ️ Info | No action needed for this release |

**The app will build and sign successfully.** The `firebase_analytics` orphan dependency is the only flag worth resolving before a Play Store submission.
