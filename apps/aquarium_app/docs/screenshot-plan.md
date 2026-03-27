# Play Store Screenshot Plan — Danio

Date: 2026-03-27
Branch: `openclaw/stage-system`

---

## What exists

### Fresh ADB captures (`docs/screenshots/`)

| File | Size | Description |
|------|------|-------------|
| `00_onboarding.png` | 740KB | Privacy / data dialog |
| `01_welcome.png` | 738KB | ✅ Strong hero — "Your fish deserve better than guesswork" |
| `02_onboarding_quiz.png` | 157KB | Onboarding quiz step (experience level) |
| `03_xp_first_lesson.png` | 150KB | ✅ XP reward — "First lesson complete 🎯 +10 XP" |
| `04_species_picker.png` | 282KB | ✅ Species selection grid (Neon Tetra, Betta, Guppy, etc.) |
| `05_post_species.png` | 219KB | ✅ Betta care profile (pH, tank mates, care level) |
| `06_care_guide_ready.png` | 152KB | ✅ "Your Betta care guide is ready" + feature list |
| `07_setup_step.png` | 112KB | Notification permission prompt |

### QA reference captures (`docs/screenshots/qa_refs/`)

Copied from `qa_screenshots/post-master-plan/FINDINGS.md` (Argus QA, 2026-03-19).

⚠️ Several of these PNGs share identical MD5 hashes despite different filenames — they are **not** reliable for final store use but serve as content labels.

| File | Labelled content |
|------|-----------------|
| `01_home_qa.png` | Home screen with streak/hearts |
| `02_tank_qa.png` | Tank tab |
| `03_learn_qa.png` | Learn tab / lesson browser |
| `04_achievements_qa.png` | Achievements tab (duplicate hash — unreliable) |
| `05_settings_qa.png` | Settings tab (duplicate hash — unreliable) |
| `06_tank_stage_panel_qa.png` | Tank stage panel expanded |
| `07_lesson_detail_qa.png` | Lesson detail screen (duplicate hash) |
| `08_back_from_lesson_qa.png` | Back navigation from lesson (648KB — likely real) |
| `09_back_from_home_qa.png` | App exit (1.3MB — likely real) |

### Smoke captures (repo root)

- `smoke-01-intro.png`, `smoke-01-launch.png` — tiny (~19KB), likely blank/broken
- `smoke-02-after-quickstart.png`, `smoke-03-current-screen.png` — 322KB, usable

### Store assets (`store_assets/`)

- `feature-graphic-1024x500.png` — Play Store feature graphic
- `icon-512.png` — app icon
- `screenshot-hero-base-1080x1920.png` — hero base template

---

## ADB status

- **Physical device** (`RFCY8022D5R`) was **not connected** during capture
- All captures taken on **emulator-5554** (Pixel 7 Pro)
- App **crashes near end of onboarding** on this emulator build, which blocked fresh main-tab captures
- The crash occurs at the name entry → finalisation step (after "Skip")

---

## Recommended final 8 Play Store screenshots

| # | Source file | What it shows | Store caption | Status |
|---|------------|---------------|---------------|--------|
| 1 | `01_welcome.png` | Hero onboarding value prop | **Stop guessing. Start fishkeeping with confidence.** | ✅ Ready |
| 2 | `05_post_species.png` | Betta care profile (pH, tank mates, care level) | **Get species-specific care guidance instantly.** | ✅ Ready |
| 3 | `06_care_guide_ready.png` | "Care guide ready" + feature bullets | **Everything you need to keep your fish healthy.** | ✅ Ready |
| 4 | `04_species_picker.png` | Species selection grid | **Choose from 2,000+ species with detailed profiles.** | ✅ Ready |
| 5 | `03_xp_first_lesson.png` | XP / first lesson complete | **Learn step by step — and stay motivated.** | ✅ Ready |
| 6 | `08_back_from_lesson_qa.png` | Lesson / learn tab (648KB, likely real) | **Build your skills with daily spaced lessons.** | ⚠️ Needs recapture on real device |
| 7 | **MISSING** | AI fish identification screen | **Identify fish with AI in seconds.** | ❌ Must capture |
| 8 | **MISSING** | Water parameter tracking | **Track water tests before problems become disasters.** | ❌ Must capture |

---

## Screenshots still needed

### Critical (must capture before store upload)

1. **AI fish identification** — the short description explicitly promises this. Show photo upload + result.
2. **Water parameter tracking** — pH / ammonia / nitrite / nitrate logging or chart view.
3. **Tank compatibility checker** — species comparison or compatibility outcome.

### Important (needed for strongest listing)

4. **Main home/dashboard** — clean tank overview with streaks / tank health. Much stronger opener than onboarding alone.
5. **Achievements/gamification tab** — streaks, badges, XP milestones.
6. **Settings / privacy controls** — supports the "private, offline-first" messaging.

---

## Draft deck (best 8 from current assets)

If we need a draft submission today, use these in order:

1. `01_welcome.png` — hero
2. `05_post_species.png` — care profile
3. `06_care_guide_ready.png` — feature bullets
4. `04_species_picker.png` — species grid
5. `03_xp_first_lesson.png` — gamification
6. `08_back_from_lesson_qa.png` — learn tab
7. `02_onboarding_quiz.png` — learning content
8. `07_setup_step.png` — polish / notification prompt

This deck is **60% strong** but under-represents AI ID, water tracking, compatibility, and main-app surfaces. Not recommended for final upload.

---

## Capture plan for missing screenshots

To get the remaining 6 screenshots:

1. Build latest `openclaw/stage-system` branch to APK
2. Install on **physical device** `RFCY8022D5R` (emulator crashes on final onboarding)
3. Complete onboarding once
4. Capture each screen in sequence:
   - Home dashboard
   - AI fish ID flow
   - Water parameter tracking
   - Tank compatibility checker
   - Achievements tab
   - Settings

All captures at 1080×2400 via:
```bash
adb -s RFCY8022D5R exec-out screencap --display 2 -p > <file>.png
```
