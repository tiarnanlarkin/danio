# 🚀 Danio — Master Pre-Launch Checklist

> Status note (2026-05-02): historical checklist for `openclaw/stage-system`. Reconcile blockers against current `main` before release. Use `docs/development/CODEX_SAFE_WORKFLOW.md` as the active gate.

> **Compiled by:** Themis (Legal & Compliance, Mount Olympus)  
> **Date:** 2026-03-29  
> **Branch:** `openclaw/stage-system`  
> **Sources:** Security/Compliance Audit · Legal Verification Report · Play Store Readiness Audit · Visual Asset Audit · Test Coverage Audit · Data Resilience Audit · Pre-Build Verification · Full Audit Report

---

## Legend

| Symbol | Meaning |
|--------|---------|
| 🔴 | **BLOCKER** — submission refused or existential risk if not fixed |
| 🟡 | **SHOULD FIX** — before or very shortly after launch |
| 🟢 | **DONE** — verified complete |

---

## 🏗️ Code & Build

### 🔴 BLOCKERS

| # | Item | Detail | Source |
|---|------|--------|--------|
| CB-2 | **Commit or stash 8 modified files** | 8 files have uncommitted changes on `openclaw/stage-system`. Must be committed before release tag. Files: `empty_room_scene.dart`, `tank_switcher.dart`, `today_board.dart`, `livestock_last_fed.dart`, `onboarding_screen.dart`, `settings_screen.dart`, `ambient_tip_overlay.dart`, `bottom_sheet_panel.dart` | Pre-Build Verification |
| CB-4 | **Do NOT embed `OPENAI_API_KEY` in production build** | If `--dart-define=OPENAI_API_KEY=sk-...` is used at build time, the key is embedded in the compiled APK and extractable via decompilation. Either deploy the Supabase proxy (see Legal section) or omit the key entirely to enable graceful degradation. | Security Audit |

### 🟡 SHOULD FIX

| # | Item | Detail |
|---|------|--------|
| CB-5 | **Address 159 lint issues** | All info-level (`avoid_print` etc.) — non-blocking but should be cleared before v1.1 |
| CB-6 | **Remove legacy `.png` fish assets** | Both `.png` and `.webp` variants exist in `assets/images/fish/`. Dead weight in the bundle. Delete post-migration. |
| CB-7 | **Remove unreferenced `linen-wall.webp`** | 248 KB declared in `pubspec.yaml` but zero code references found. Delete and remove from pubspec. |
| CB-8 | **Fix stale `.png` comment in `species_fish.dart` line 26** | Doc comment says `.png`, code correctly uses `.webp`. Cosmetic only. |
| CB-9 | **Convert illustration PNGs to WebP** | `learn_header.png` (1,410 KB) and `practice_header.png` (943 KB) are uncompressed PNGs. WebP conversion saves ~2.1 MB total (89% reduction). |
| CB-10 | **Reduce remaining 54 `.withOpacity()` calls** | GC pressure; replace with `AppOverlays.*` constants |

### 🟢 DONE

| # | Item |
|---|------|
| CB-✅-1 | App name: `"Danio"` — correct, ≤30 chars |
| CB-✅-2 | Package ID: `com.tiarnanlarkin.danio` — valid |
| CB-✅-3 | Version: `1.0.0+1` — appropriate for v1.0 |
| CB-✅-4 | Target SDK ≥33, Min SDK 21+ — meets Play Store requirements |
| CB-✅-5 | 64-bit architecture support (arm64-v8a, armeabi-v7a, x86_64) |
| CB-✅-6 | ProGuard/R8 minification enabled (`isMinifyEnabled`, `isShrinkResources`) |
| CB-✅-7 | Release signing config (`key.properties` + `aquarium-release.jks`) |
| CB-✅-8 | Adaptive icon (all 5 density buckets, foreground/background/monochrome) |
| CB-✅-9 | Splash screen (legacy + Android 12+ `windowSplashScreenAnimatedIcon`) |
| CB-✅-10 | `android:allowBackup="false"` — good privacy practice |
| CB-✅-11 | Predictive back enabled (`enableOnBackInvokedCallback="true"`) |
| CB-✅-12 | Debug menu hidden in release (`kDebugMode` guard) |
| CB-✅-13 | `GoogleFonts.config.allowRuntimeFetching = false` — fonts bundled, no silent Google call |
| CB-✅-14 | ABI splits enabled — smaller per-architecture download |
| CB-✅-15 | All declared assets verified present and loadable |
| CB-✅-16 | `flutter pub get` resolves cleanly |
| CB-✅-17 | `firebase_analytics` remains absent from `pubspec.yaml`; no `logEvent` call sites exist |
| CB-✅-18 | Release AAB build verified with `.\scripts\flutterw.ps1 build appbundle --release` |

---

## ⚖️ Legal & Compliance

### 🔴 BLOCKERS

| # | Item | Detail | Source |
|---|------|--------|--------|
| LC-2 | **Deploy Supabase AI proxy before any production build using OpenAI key** | Without `SUPABASE_AI_PROXY_URL` in the production build, the OpenAI key would be embedded in the compiled APK. See `docs/ai-proxy-setup.md`. If launching without AI features, ensure no key is in the build config. | Security Audit (R1) |

### 🟡 SHOULD FIX

| # | Item | Detail |
|---|------|--------|
| LC-3 | **Set Play Store target audience to 13+ explicitly** | Declare target audience as "13 and above" in Play Console to match the in-app age gate and avoid triggering Google Play's Children & Families policy requirements |
| LC-4 | **Set content rating to Teen (13+)** | Aligns with age gate; substantially reduces COPPA exposure. See `docs/CONTENT_RATING_ANSWERS.md` for IARC questionnaire answers. |
| LC-5 | **Add postal address to privacy policy** | UK GDPR — data controller record should include a physical address. Can be addressed as "available on request" for a sole trader. |
| LC-6 | **Consider "Use Without Crash Reports" wording** | "No Thanks" is functional, but a more explicit decline label could clarify that users still get the full app without crash diagnostics. |
| LC-7 | **Consider custom domain privacy email** | `larkintiarnanbizz@gmail.com` is functional but `privacy@danio.app` would be more professional on the store listing. Not a compliance requirement. |
| LC-8 | **Future: implement Verifiable Parental Consent (VPC)** | If under-13 users are expected to access the app with parental consent, a VPC mechanism (parental email confirmation) is required by COPPA. Not required at launch if app is rated 13+. |
| LC-9 | **Keep COPPA/privacy copy aligned with crash diagnostics only** | If app reaches US users, the privacy policy should continue to describe the 13+ requirement and consent-gated Crash Reports accurately. |

### 🟢 DONE

| # | Item |
|---|------|
| LC-✅-1 | Privacy policy exists (`docs/privacy-policy.html`) — last updated 28 March 2026 |
| LC-✅-2 | Terms of Service exists (`docs/terms-of-service.html`) — last updated 27 March 2026 |
| LC-✅-3 | Privacy policy linked in-app at `https://tiarnanlarkin.github.io/danio/privacy-policy.html` |
| LC-✅-4 | ToS linked in-app at `https://tiarnanlarkin.github.io/danio/terms-of-service.html` |
| LC-✅-5 | GDPR consent flow: opt-in, gated on both age + ToS, Crash Reports truly optional |
| LC-✅-6 | Firebase Crashlytics disabled by default in `AndroidManifest.xml`; Firebase Analytics dependency absent |
| LC-✅-7 | Crash Reports consent persisted to legacy `gdpr_analytics_consent` SharedPreferences key |
| LC-✅-8 | Under-13 path hard-blocks access: `under_13_blocked` is persisted and routed to `AgeBlockedScreen` on launch |
| LC-✅-9 | In-app "Delete My Data" flow: clears all SharedPreferences + local files |
| LC-✅-10 | Crashlytics deletion note added to Delete My Data dialog (90-day retention, contact email) |
| LC-✅-11 | JSON data export (Right to Portability) available in analytics screen |
| LC-✅-12 | Crash Reports toggle in Settings correctly calls `applyAnalyticsConsent(false)` and disables Crashlytics collection |
| LC-✅-13 | No Firebase Analytics events collected; Crashlytics crash diagnostics are consent-gated and do not include tank data, photos, or learning progress |
| LC-✅-14 | OpenAI disclosure gate (`openai_disclosure_accepted` key) before any AI features |
| LC-✅-15 | No real-money IAP — zero in-app purchase declarations needed |
| LC-✅-16 | Legal bases documented for Crash Reports consent, OpenAI feature consent, local data, and dormant Supabase sync |
| LC-✅-17 | `SCHEDULE_EXACT_ALARM` justification drafted in `docs/PLAY_CONSOLE_DECLARATIONS.md` |
| LC-✅-18 | Data Safety declarations documented in `docs/PLAY_CONSOLE_DECLARATIONS.md` (see also `docs/DATA_SAFETY_FORM.md`) |

---

## 🏪 Store Listing

### 🔴 BLOCKERS

| # | Item | Detail | Source |
|---|------|--------|--------|
| SL-1 | **Host Privacy Policy and Terms of Service at public URLs** | Google Play requires privacy policy URL to be publicly accessible at time of review. HTML files exist — deploy to GitHub Pages (`tiarnanlarkin.github.io/danio/`). Both URLs must return HTTP 200 before submission. | Legal Verification Report (Check 4) |
| SL-2 | **Complete IARC content rating questionnaire in Play Console** | Not yet submitted. App should rate Everyone / PEGI 3 (or Teen if 13+ is chosen — recommended). Takes ~5 minutes in Play Console UI. See `docs/CONTENT_RATING_ANSWERS.md`. | Play Store Audit |
| SL-3 | **Submit SCHEDULE_EXACT_ALARM permission declaration** | Copy-paste text is ready in `docs/PLAY_CONSOLE_DECLARATIONS.md` → Section 1. Submit via Play Console: App content → Permissions. | Play Store Audit |

### 🟡 SHOULD FIX

| # | Item | Detail |
|---|------|--------|
| SL-4 | **Capture 3 missing screenshots** | Home dashboard (post-onboarding), water parameter chart/log screen, AI Fish ID screen. Physical device `RFCY8022D5R` required (emulator crashes in final onboarding). |
| SL-5 | **Remove `00_onboarding.png` and `07_setup_step.png` from screenshot deck** | These show a privacy consent popup and OS notification prompt respectively — weak first impressions. |
| SL-6 | **Add caption bars to screenshots** | Raw captures are strong but unbranded. A colour-matched caption bar (Apollo task) would lift quality significantly. |
| SL-7 | **Verify feature graphic content** | `store_assets/feature-graphic-1024x500.png` — confirm it shows app name + a hook line, not just the logo. |
| SL-8 | **Update `READINESS_CHECKLIST.md`** | Still references old package name `com.tiarnanlarkin.aquarium.aquarium_app`. Misleading for future reference. |
| SL-9 | **Capture tablet screenshots** | 7" and 10" tablet screenshots not captured. Play Store shows these in tablet UI. Low effort; use Pixel Tablet emulator. |

### 🟢 DONE

| # | Item |
|---|------|
| SL-✅-1 | App title: "Danio: Learn Fishkeeping" = 25 chars (≤30 limit) |
| SL-✅-2 | Short description: 79 chars (≤80 limit) — well-crafted |
| SL-✅-3 | Full description: ~2,700 chars — good keyword coverage, room to expand |
| SL-✅-4 | Feature graphic: `store_assets/feature-graphic-1024x500.png` — correct dimensions |
| SL-✅-5 | 8+ raw screenshot captures at 1080×2400 (correct Play Store dimensions) |
| SL-✅-6 | Contact email: `larkintiarnanbizz@gmail.com` documented |
| SL-✅-7 | App category: Education (primary) — correct for the learning system |
| SL-✅-8 | No in-app purchases: correctly stated "No in-app purchases" |
| SL-✅-9 | No ads declaration correct |
| SL-✅-10 | ASO keyword strategy solid — title targets "learn" + "fishkeeping" |

---

## 🎨 Assets

### 🔴 BLOCKERS

| # | Item | Detail | Source |
|---|------|--------|--------|
| AS-1 | **Regenerate `angelfish.png`** | Art style outlier — thinner outlines, realistic gradients, small eyes. Despite recent regen (Mar 29) it doesn't match canonical chibi style. Required before shipping fish-browsing features. | Visual Asset Audit |
| AS-2 | **Regenerate `amano_shrimp.png`** | Naturalistic shrimp, no specular highlight, thin outlines, muted palette. Full rework needed to match art bible. | Visual Asset Audit |
| AS-3 | **Create all 4 badge icons** | `assets/icons/badges/` is completely empty. Required for shop feature visual completeness: `badge_early_bird.png`, `badge_night_owl.png`, `badge_perfectionist.png`, `legendary_badge_display.png` | Visual Asset Audit |

### 🟡 SHOULD FIX

| # | Item | Detail |
|---|------|--------|
| AS-4 | **Regenerate both illustration headers** | `learn_header.png` and `practice_header.png` are wrong art style (vector clipart / flat cel). Must match chibi style. Also convert to WebP (saves 2.1 MB). |
| AS-5 | **Regenerate `room-bg-cozy-living.webp`** | Significantly below quality bar (5.5/10). Very sparse, minimal furnishing, large blank wall. Legacy asset from Wave 1. |
| AS-6 | **Regenerate `room-bg-forest.webp`** | Also below Wave 4 quality bar (6.75/10). Flat execution, no ceiling, limited detail. |
| AS-7 | **Replace `placeholder.webp`** | Amber watercolor wash doesn't match illustrated style. Replace with a Danio-branded illustrated placeholder (simple chibi fish silhouette). |
| AS-8 | **Review `onboarding_journey_bg.webp`** | Photorealistic render in an illustrated app. Dimensions are non-standard (1143×2048 vs app standard 1536×2752). Style mismatch. |
| AS-9 | **Fix `bristlenose_pleco.png` colour mode** | Currently Palette (`P`) mode, not RGBA. Re-export as RGBA PNG for correct transparency handling. |
| AS-10 | **Confirm app icon source at 1024×1024** | Current `store_assets/icon-512.png` is 512×512. Apple App Store requires 1024×1024. Confirm the source file exists at full resolution. |

### 🟢 DONE

| # | Item |
|---|------|
| AS-✅-1 | App icon 512×512 for Play Store: `store_assets/icon-512.png` — confirmed |
| AS-✅-2 | Adaptive icon: all 5 density buckets (mdpi → xxxhdpi) present |
| AS-✅-3 | 13/15 fish sprites pass art bible compliance |
| AS-✅-4 | All 15 fish thumbnails (128×128) present and consistent |
| AS-✅-5 | All 12 room backgrounds present at correct dimensions (1536×2752) |
| AS-✅-6 | All 4 Rive animations present (`water_effect.riv`, `emotional_fish.riv`, `joystick_fish.riv`, `puffer_fish.riv`) |
| AS-✅-7 | All 9 fonts bundled locally (Fredoka + Nunito variants) — GDPR compliant |
| AS-✅-8 | Zero broken static asset references in code |
| AS-✅-9 | Warm cream splash screen (`#FFF5E8`) — on-brand |

---

## 🧪 Testing

### 🔴 BLOCKERS

| # | Item | Detail | Source |
|---|------|--------|--------|
| TE-1 | **Add consent persistence test** | A GDPR compliance requirement: verify that accepting/declining Crash Reports consent correctly sets the legacy `gdpr_analytics_consent` key in SharedPreferences and persists across app restart. Tests exist for the UI but not the restart outcome. | Test Coverage Audit (Risk #4) |

### 🟡 SHOULD FIX

| # | Item | Detail |
|---|------|--------|
| TE-2 | **Add 3 golden-path integration tests** | (1) Create tank → verify appears on home screen; (2) Complete onboarding → verify `onboardingComplete` flag set; (3) Add water log → verify appears in logs screen |
| TE-3 | **Unit test `TankHealthService.calculate()`** | Pure function prominently displayed in UI. Trivially testable. A bug silently shows wrong health scores to every user. |
| TE-4 | **Unit test `StockingCalculator.calculate()`** | Incorrect stocking advice is a real-world fish welfare issue and a 1-star review magnet. |
| TE-5 | **Add `tab_navigator.dart` smoke test** | No test exists. A broken tab navigator import kills the entire app's navigation. |
| TE-6 | **Wire integration tests to CI** | Both integration test files require manual emulator invocation. Add GitHub Actions step at minimum for PRs to main. |

### 🟢 DONE

| # | Item |
|---|------|
| TE-✅-1 | 656 unit + widget tests across 100 test files |
| TE-✅-2 | ~85% of screens have at least a smoke test |
| TE-✅-3 | `InMemoryStorageService` used in widget tests — avoids real I/O |
| TE-✅-4 | Unit tests for models (`spaced_repetition_test.dart`, `user_profile_provider_test.dart`) |
| TE-✅-5 | Data integrity tests (`fish_facts_test.dart`, `species_unlock_map_test.dart`, `lesson_data_test.dart`) |
| TE-✅-6 | Consent screen tested (UI interactions verified) |
| TE-✅-7 | Integration test files exist (`smoke_test.dart`, `smoke_test_v2.dart`) |

---

## 🏗️ Infrastructure

### 🔴 BLOCKERS

| # | Item | Detail | Source |
|---|------|--------|--------|
| IN-1 | **Supabase AI proxy — deploy before any production OpenAI key use** | `docs/ai-proxy-setup.md` has deployment instructions. Set `SUPABASE_AI_PROXY_URL` in production build config. This is both a security blocker (key exposure) and a legal blocker (covered under LC-2). | Security Audit |

### 🟡 SHOULD FIX

| # | Item | Detail |
|---|------|--------|
| IN-2 | **Add `cost_tracker_expenses` to SharedPreferences backup whitelist** | Silent data loss bug: users' full spending history is excluded from ZIP backups. Add `'cost_tracker'` prefix to `SharedPreferencesBackup._exportablePrefixes`. | Data Resilience Audit (#3) |
| IN-3 | **Add JSON schema migration runner** | `_schemaVersion = 1` is written to disk but never read back. Any future field addition or rename will silently produce `null` for existing users. Add `_migrateJson()` in `_loadFromDisk()`. | Data Resilience Audit (#1) |
| IN-4 | **Implement restore atomicity (transactional rollback)** | Backup restore iterates entities one-by-one without a transaction. A partial failure leaves the DB in a mixed state. Load entire backup to memory, validate, then replace atomically. | Data Resilience Audit (#4) |
| IN-5 | **Add draft auto-save for "Add Log" form** | Crash or backgrounding during water-test entry (up to 9 fields) loses all data. Auto-save to `log_draft_<tankId>` in SharedPreferences on each field change. | Data Resilience Audit (#2) |
| IN-6 | **Create Supabase storage bucket `user-backups`** | Listed as "needs manual creation" in backend status. Required for cloud backup feature. | Full Audit Report |
| IN-7 | **Confirm GitHub Pages is live** | `tiarnanlarkin.github.io/danio/` must serve both HTML docs publicly before Play Store submission. Verify both URLs return HTTP 200. | Legal Verification Report |

### 🟢 DONE

| # | Item |
|---|------|
| IN-✅-1 | Supabase project created with all 6 tables |
| IN-✅-2 | RLS policies enabled on all tables |
| IN-✅-3 | Realtime enabled |
| IN-✅-4 | Atomic writes in `LocalJsonStorageService` (`.tmp` → rename) |
| IN-✅-5 | Mutex lock (`_persistLock.synchronized`) on all write operations |
| IN-✅-6 | Corruption detection: `.bak` and `.corrupted.<timestamp>` copies on parse failure |
| IN-✅-7 | All core features work fully offline |
| IN-✅-8 | `OfflineIndicator` banner shown app-wide |
| IN-✅-9 | AI features check `isOnlineProvider` before calling OpenAI |
| IN-✅-10 | Firebase Crashlytics disabled by default; enabled only after explicit Crash Reports consent |

---

## 📊 Submission Readiness Summary

| Category | 🔴 Blockers | 🟡 Should Fix | 🟢 Done |
|----------|------------|--------------|---------|
| Code & Build | 4 | 6 | 16 |
| Legal & Compliance | 2 | 7 | 17 |
| Store Listing | 3 | 6 | 10 |
| Assets | 3 | 7 | 9 |
| Testing | 1 | 5 | 7 |
| Infrastructure | 1 | 6 | 10 |
| **TOTAL** | **14** | **37** | **69** |

**You cannot submit to Play Store until all 14 blockers are resolved.**  
The 37 "should fix" items are strongly recommended before or immediately after launch.

---

*"Did you read the clause?"*  
*— Themis, Legal & Compliance, Mount Olympus*
