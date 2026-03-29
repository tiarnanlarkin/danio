# Play Store Readiness & ASO Audit — Danio

> **Auditor:** Aphrodite (Growth Specialist, Mount Olympus)
> **Date:** 2026-03-29
> **Branch:** `openclaw/stage-system`
> **Scope:** Google Play Store submission readiness, ASO, marketing material quality

---

## Launch Readiness Score: **7.5 / 10**

The app is functionally excellent and surprisingly well-prepared for a first submission. The main drag on the score is the absence of an AAB build (now mandatory for new Play Store submissions), two missing critical screenshots, and the outdated READINESS_CHECKLIST reflecting an old package name. Fix those three things and this is an 8.5+.

---

## 1. Play Store Requirements Checklist

### Technical Requirements

| Requirement | Status | Notes |
|---|---|---|
| App name set correctly | ✅ | `"Danio"` — clean, memorable, fits 30-char limit |
| Package ID format valid | ✅ | `com.tiarnanlarkin.danio` |
| Version name / code set | ✅ | `1.0.0+1` — appropriate for v1.0 launch |
| Target SDK 33+ | ✅ | Uses `flutter.targetSdkVersion` (≥33 in Flutter 3.10+) |
| Min SDK 21+ | ✅ | `flutter.minSdkVersion` |
| 64-bit architecture support | ✅ | ABI splits include `arm64-v8a`, `armeabi-v7a`, `x86_64` |
| ProGuard / R8 minification | ✅ | `isMinifyEnabled = true`, `isShrinkResources = true` |
| Release signing config | ✅ | Keystore config present (`key.properties`) |
| Android App Bundle (AAB) | ❌ | **CRITICAL** — Only APK found; Play Store requires AAB for all new apps since Aug 2021. Run `flutter build appbundle --release`. |
| APK size (universal) | ⚠️ | Universal APK is 92.8MB — acceptable but large. Split APKs (arm64: 37.6MB) are better. AAB delivery will further reduce install size. |
| Adaptive icon (API 26+) | ✅ | `mipmap-anydpi-v26/ic_launcher.xml` with foreground, background, monochrome layers all present |
| Icon sizes (mdpi → xxxhdpi) | ✅ | All 5 density buckets present for launcher, background, foreground, monochrome |
| App icon (512×512 for store) | ✅ | `store_assets/icon-512.png` — 512×512 RGB PNG ✅ |
| Splash screen (legacy) | ✅ | `launch_background.xml` with warm cream `#FFF5E8` background |
| Splash screen (Android 12+) | ✅ | `values-v31/styles.xml` with `windowSplashScreenAnimatedIcon` |
| `android:allowBackup="false"` | ✅ | Good privacy practice |
| Predictive back (Android 13+) | ✅ | `enableOnBackInvokedCallback="true"` |
| Firebase disabled by default | ✅ | Analytics + Crashlytics both off until user consent — GDPR-safe |
| Debug menu hidden in release | ✅ | `kDebugMode` guard prevents exposure — 5-tap Easter egg safe |

### Permissions Assessment

| Permission | Status | Notes |
|---|---|---|
| `INTERNET` | ✅ | Needed for Supabase, Firebase, OpenAI — legitimate |
| `POST_NOTIFICATIONS` | ✅ | Needed for reminders — standard, declared correctly for API 33+ |
| `VIBRATE` | ✅ | Haptic feedback — no user prompt required |
| `RECEIVE_BOOT_COMPLETED` | ✅ | Reschedule reminders after reboot — common, expected |
| `SCHEDULE_EXACT_ALARM` | ⚠️ | Requires Play Console justification declaration (docs/PLAY_CONSOLE_DECLARATIONS.md already has the copy-paste text ✅). This will trigger a review question. |
| `USE_EXACT_ALARM` | ⚠️ | Paired with above — justified for user-set tank maintenance reminders |
| `CAMERA` | ✅ | Fish ID feature — marked `android:required="false"` ✅ |
| `READ_MEDIA_IMAGES` | ✅ | Gallery access for Fish ID — API 33+ media permission used correctly |

**Verdict:** Permissions are minimal and well-justified. No suspicious bloat. The `SCHEDULE_EXACT_ALARM` declaration needs submitting via Play Console App Content → Permissions. The copy is ready in `docs/PLAY_CONSOLE_DECLARATIONS.md`.

### Store Listing Assets

| Asset | Status | Notes |
|---|---|---|
| App title (≤30 chars) | ✅ | "Danio: Learn Fishkeeping" = 25 chars |
| Short description (≤80 chars) | ✅ | 79 chars — right at the sweet spot |
| Full description (≤4000 chars) | ✅ | ~2700 chars — room to expand if desired |
| Feature graphic (1024×500) | ✅ | `store_assets/feature-graphic-1024x500.png` — correct dimensions |
| Screenshots (phone, ≥2) | ⚠️ | 8+ raw captures exist at 1080×2400 ✅ but 2 critical screens are missing (see §5) |
| Screenshots (tablet) | ❌ | No tablet (7" or 10") screenshots captured |
| Privacy Policy URL | ✅ | `docs/privacy-policy.html` exists — needs hosting at a public URL before submission |
| Terms of Service URL | ✅ | `docs/terms-of-service.html` exists — same hosting caveat |
| Content rating questionnaire | ⚠️ | Not yet submitted; app should rate **Everyone / PEGI 3** |
| Data Safety form | ✅ | Answers fully documented in `docs/PLAY_CONSOLE_DECLARATIONS.md` |
| Contact email | ✅ | `larkintiarnanbizz@gmail.com` documented |
| App category | ✅ | Education (primary) — correct call |

### Legal / Privacy

| Requirement | Status | Notes |
|---|---|---|
| Privacy Policy exists | ✅ | HTML version ready |
| GDPR consent flow | ✅ | `ConsentScreen` exists; Firebase disabled until consent given |
| "Delete my data" mechanism | ✅ | Documented in Data Safety answers |
| No PII in local storage | ✅ | Offline-first architecture; no silent cloud egress |
| In-app purchase declarations | ✅ | No real-money IAP — none to declare |

---

## 2. ASO Recommendations

### Current Keyword Strategy Assessment

The existing `docs/STORE_LISTING.md` is **well-crafted**. The title targets the two highest-value terms ("learn" + "fishkeeping"), the short description hits the utility angle clearly, and the full description naturally embeds 30+ long-tail terms without stuffing. This is better ASO groundwork than most hobby apps ship with.

### Recommended Primary Keywords

| Priority | Keyword | Rationale |
|---|---|---|
| 🔴 Must-have | `fishkeeping` | Core identity; low competition vs "aquarium" |
| 🔴 Must-have | `aquarium` | Highest volume in category |
| 🔴 Must-have | `fish tank app` | How beginners search |
| 🟠 High | `water parameters` | Specific, intent-rich |
| 🟠 High | `nitrogen cycle` | Pain point for beginners; exact match in lessons |
| 🟠 High | `fish identification` | AI feature differentiator |
| 🟡 Solid | `aquarium tracker` | Tracks tank + parameter logs |
| 🟡 Solid | `betta fish care` | Huge search volume for single species |
| 🟡 Solid | `planted tank` | High-engagement niche |
| 🟢 Long-tail | `fish disease guide` | Captures "my fish is sick" panic searches |
| 🟢 Long-tail | `aquarium maintenance` | Task-oriented searchers |
| 🟢 Long-tail | `freshwater aquarium` | Qualifier that filters out saltwater noise |

### Title Recommendation

**Current:** `Danio: Learn Fishkeeping`
**Keep as-is.** "Learn" + "Fishkeeping" is the right combination. Don't swap for "Aquarium" in the title — "learn fishkeeping" is a more emotionally resonant promise for the beginner audience than "aquarium app."

### Short Description Recommendation

**Current:** `Learn fishkeeping step by step. Track tanks, log water tests & ID fish with AI.`

This is good. One tweak to consider for A/B:

> `The Duolingo of fishkeeping. Bite-sized lessons, tank tracker & AI fish ID. Free.`

This explicitly anchors the mental model (Duolingo comparison), emphasises the learning arc, and adds "Free" — which converts at higher rates in Education category.

### Full Description Gaps

The current description is solid but under-represents two winning differentiators:

1. **The spaced repetition angle** — mention Anki/Duolingo-style learning explicitly. That's a sticky hook for productivity-minded hobbyists.
2. **The "no account required" opener** — this should be in the first paragraph, not buried. Privacy-first positioning is a strong differentiator when competitors require signup.

**Suggested opening paragraph swap:**

> Danio teaches you fishkeeping the way Duolingo teaches languages — bite-sized lessons, daily streaks, and a spaced-repetition system that makes knowledge stick. No account needed. No ads. No subscription. Just you and your fish.

### Category

**Primary:** Education ✅
**No change recommended.** Competing in Education over Tools/Lifestyle is the right call — the lesson system is the core differentiator and it positions Danio away from the generic "aquarium tracker" apps.

---

## 3. Missing Materials List

These must be resolved before Play Store submission:

### 🔴 Blockers (cannot submit without these)

| Item | What's Needed | How to Get It |
|---|---|---|
| **Android App Bundle (AAB)** | `flutter build appbundle --release` — play store has required AAB since Aug 2021 | Run build command, verify signing |
| **Privacy Policy URL** | `docs/privacy-policy.html` needs to be hosted at a public HTTPS URL | Host on GitHub Pages, Firebase Hosting, or any static host |
| **Terms of Service URL** | Same as above | Same solution |
| **Content Rating** | Must complete IARC questionnaire in Play Console | Takes 5 minutes in Play Console UI |

### 🟠 Required Before Upload

| Item | Gap | Action |
|---|---|---|
| **AI fish ID screenshot** | Explicitly promised in short description; no screenshot of it exists | Capture on physical device post-onboarding |
| **Water parameter tracking screenshot** | Core feature, not shown in current deck | Capture charts or log screen |
| **Main dashboard / home screenshot** | 60% of current deck is onboarding — buyers want to see the product | Capture home tab with tank card visible |

### 🟡 Strongly Recommended

| Item | Gap | Action |
|---|---|---|
| Tablet screenshots (7" or 10") | Not captured; Play Store shows these in tablet UI | Capture on Pixel Tablet emulator |
| Achievements / gamification screenshot | XP + streaks are selling points not shown | Quick capture |
| `versionName` / `versionCode` confirmation | `pubspec.yaml` has `1.0.0+1` — confirm this is intentional first-ever release | Confirm with Tiarnan |

---

## 4. Monetisation Assessment

### Current State

Danio uses a **virtual gem economy with zero real-money transactions**:

- Gems are earned through gameplay (lesson completion, streaks, achievements, level-ups)
- Gems are spent in an in-app shop (`gem_shop_screen.dart`, `shop_street_screen.dart`) on functional items (streak freezes, XP boosts, themes)
- **No Google Play Billing integration** — confirmed: `in_app_purchases` / `purchases_flutter` packages are absent from `pubspec.yaml`
- **No real-money price points** anywhere in the codebase

### Play Store Compliance

✅ **Fully compliant.** Because there are no real-money transactions, Danio has zero IAP declarations to make. The store listing correctly states "No in-app purchases" and this matches the implementation exactly.

### Monetisation Readiness for Future

The gem economy infrastructure is well-built and could support real-money top-ups in a future version (gems purchase via Play Billing) without architectural rework. This is smart design — launch free, prove engagement, then add monetisation if warranted. The "shop" UX is already there to ease users into the mental model.

**No action required for launch.** Future revenue options (optional gem top-ups, "Danio Pro" subscription) are feasible from this codebase.

---

## 5. Screenshot Quality Assessment

### What Exists (1080×2400 — correct Play Store dimensions)

| File | Content | Store Value | Status |
|---|---|---|---|
| `01_welcome.png` | Hero onboarding — "Your fish deserve better than guesswork" | ⭐⭐⭐⭐⭐ Best hero shot | ✅ Use |
| `05_post_species.png` | Betta care profile (pH, tankmates, care level) | ⭐⭐⭐⭐ | ✅ Use |
| `06_care_guide_ready.png` | "Your Betta care guide is ready" + feature bullets | ⭐⭐⭐⭐ | ✅ Use |
| `04_species_picker.png` | Species grid (Neon Tetra, Betta, Guppy, etc.) | ⭐⭐⭐ | ✅ Use |
| `03_xp_first_lesson.png` | "First lesson complete 🎯 +10 XP" reward screen | ⭐⭐⭐⭐ | ✅ Use |
| `02_onboarding_quiz.png` | Experience level selection | ⭐⭐ | ⚠️ Weak — shows setup not product |
| `00_onboarding.png` | Privacy / data consent dialog | ⭐ | ❌ Skip — opens with privacy popup |
| `07_setup_step.png` | Notification permission prompt | ⭐ | ❌ Skip — system OS dialog as screenshot #8 is weak |

### Missing Critical Shots

1. **AI Fish ID screen** — the short description says "ID fish with AI" — if there's no screenshot of it, users distrust the claim
2. **Water parameter chart / log screen** — the core utility feature, nowhere in the current deck
3. **Home dashboard (post-onboarding)** — tank card + streak counter + hearts. This is the product.

### Recommended Final 8-Shot Deck

| Slot | Shot | Caption |
|---|---|---|
| 1 | `01_welcome.png` | *Stop guessing. Start fishkeeping with confidence.* |
| 2 | **NEED: Home dashboard** | *Your aquarium, beautifully organised.* |
| 3 | `05_post_species.png` | *Get species-specific care guidance instantly.* |
| 4 | **NEED: Water parameter chart** | *Track water tests before problems become disasters.* |
| 5 | `03_xp_first_lesson.png` | *Learn step by step — and stay motivated.* |
| 6 | **NEED: AI fish ID** | *Identify any fish with your camera.* |
| 7 | `04_species_picker.png` | *120+ species profiles at your fingertips.* |
| 8 | `06_care_guide_ready.png` | *Everything you need to keep your fish healthy.* |

---

## 6. Technical Debt (Non-Blocking for Launch)

| Item | Severity | Notes |
|---|---|---|
| No l10n / i18n setup | ℹ️ Info | All 149 screens use hardcoded English strings. Acceptable for v1.0 English-first launch. If global expansion is a goal, this is a large undertaking (~150 screens to instrument). |
| Outdated `READINESS_CHECKLIST.md` | ℹ️ Info | Still references old package name `com.tiarnanlarkin.aquarium.aquarium_app` — harmless but misleading for future reference |
| Only 14 fish species have images | ⚠️ Low | Species database has 122+ species; only 14 have real images + thumbnails. Others show placeholder. This doesn't block launch but affects perceived polish. |
| `emotional_fish.riv` asset size | ℹ️ Info | Previously flagged at ~867KB vs ~300KB target. 892KB Rive folder total. Minor. |
| Universal APK at 92.8MB | ℹ️ Info | Normal for Flutter with all dependencies. AAB + Play Asset Delivery will fix this for end users. |

---

## 7. Prioritised Action Items

### Before Any Submission

1. **Build the AAB** — `flutter build appbundle --release` — verify signing works
2. **Host Privacy Policy + ToS** — GitHub Pages takes 5 minutes; add the URLs to Play Console
3. **Complete content rating** — IARC questionnaire in Play Console; expect "Everyone"
4. **Capture 3 missing screenshots** — home dashboard, water parameters, AI fish ID. Physical device `RFCY8022D5R` required (emulator crashes in final onboarding).
5. **Submit SCHEDULE_EXACT_ALARM declaration** — copy-paste from `docs/PLAY_CONSOLE_DECLARATIONS.md`

### Before Feature Graphic / Screenshots Go Live

6. **Add store captions to screenshots** — the raw captures are strong but unbranded. Even a simple colour-matched caption bar underneath each shot (Apollo task) would lift the visual quality significantly.
7. **Verify feature graphic quality** — `store_assets/feature-graphic-1024x500.png` exists but content hasn't been audited. Make sure it shows the app name + a hook line, not just the logo.

### Optional Improvements (Post-Launch or v1.1)

8. **Tablet screenshots** — low effort, adds professionalism, increases impression rate on tablet
9. **A/B test short description** — try the "Duolingo of fishkeeping" variant after 500+ installs
10. **Fish species image coverage** — 14/122 species have images. A batch generation run (Apollo + ComfyUI) would meaningfully improve the species database feel
11. **l10n groundwork** — wrap strings in `AppLocalizations` if global launch is in the roadmap

---

## Summary

Danio is in excellent shape for a first Play Store submission. The app itself is feature-rich, well-tested, and architecturally sound. The permissions are minimal and well-justified. The monetisation model is Play Store-safe with zero IAP complexity. The ASO groundwork in `docs/STORE_LISTING.md` is genuinely good and well above the average indie launch.

The gaps are procedural, not fundamental: build the AAB, host the legal docs, capture three more screenshots, and submit. This is a weekend's work, not a month's.

*"Irresistible isn't accidental."* — but it also isn't far away.

---

*Audit performed by Aphrodite (Growth Agent, Mount Olympus). READ-ONLY — no source files modified.*
