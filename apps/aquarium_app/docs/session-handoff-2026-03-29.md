# Danio — Session Handoff
**Date:** 2026-03-29 14:30 GMT+1  
**Branch:** `openclaw/stage-system`  
**HEAD:** `d7e14ac`  
**Tests:** 750/750 ✅ | **Analyze:** 0 issues ✅ | **APK:** ~86.8MB  
**Working tree:** clean

---

## 1. What Is Already Built

Danio is a substantial Flutter app — a Duolingo-style aquarium fishkeeping education + tank management app. It has:

### Core Features (functional, wired, tested)
- **4-tab navigation:** Home (tank view) · Learn · Practice · Settings
- **Tank management:** create/edit/delete tanks, multi-tank switcher, livestock tracking, equipment tracking, water log entry, task scheduling, water change reminders
- **Learning system:** 72 lessons across 12+ learning paths (nitrogen cycle, water params, first fish, maintenance, equipment, planted tanks, aquascaping, breeding, fish health, species care, advanced topics, troubleshooting)
- **Spaced repetition:** SRS practice engine with card review, streak system, XP/gems/hearts economy
- **Quiz system:** multiple exercise types, quiz answer options with animations
- **Story system:** interactive branching narrative scenarios (wired to learn screen + debug menu)
- **Species/plant database:** 125+ fish species, 50+ plants with full care guides
- **Smart features (AI):** Fish ID, Symptom Checker, Weekly Plan — all behind Supabase AI proxy (deployed, working)
- **Onboarding:** 10-screen flow with micro-lesson, fish selection, XP celebration, push permission
- **Gamification:** XP levels, gems, hearts, streaks, achievements, daily goals, gem shop, inventory
- **Tank visualisation:** animated fish sprites (15 species) swimming in themed aquarium rooms (12 themes), glassmorphism bottom sheet with 4 tabs
- **Offline-first:** all core features work without network. Cloud sync optional via Supabase
- **COPPA/GDPR:** age gate with hard block, analytics consent flow, data deletion, data export

### Infrastructure (done)
- Supabase project active (Zurich), AI proxy Edge Function deployed and verified
- GitHub Pages live — privacy policy + ToS both return 200
- Release signing configured (keystore exists)
- Firebase Analytics/Crashlytics wired (disabled by default, consent-gated)
- Notification system with onboarding drip sequence, streak reminders, task alerts
- 750 tests, 100+ test files

---

## 2. What Is Complete (high confidence, polished)

- Design token system (AppColors, AppTypography, AppSpacing, AppRadius) — 95%+ coverage
- GlassCard component — best-in-class, reduced motion, haptics, accessibility
- Lesson content — 72 lessons, substantive, no stubs
- Notification copy — warm, well-crafted
- Error handling framework — try-catch coverage, ErrorBoundary, Crashlytics integration
- Fish sprites — 13/15 match art bible (chibi style, consistent)
- Room backgrounds — 10/12 at quality bar
- Onboarding flow structure — well-designed product UX
- Supabase integration — proxy deployed, auth redirect configured, credentials in 1Password
- Legal docs — privacy policy, ToS, data safety form, content rating answers all drafted

---

## 3. What Is Partial (started but has gaps)

### UX/UI Polish
- **170 hardcoded `Colors.white`** — many in the glassmorphism sheet, intentional for glass effect but not theme-adaptive
- **~1143 hardcoded hex `Color(0x...)` values** — significant chunk of these are legitimate (design tokens defined as hex), but audit flagged many that bypass the token system
- **Bottom sheet panel:** works well but docstring says 3 tabs (actually 4), tool cards have no press animation
- **Onboarding:** no progress indicator across the 10-screen flow — users don't know how far along they are
- **Empty room scene:** fixed positioning doesn't respect safe area insets on notched phones
- **Fish select grid:** 3-column layout with 13sp names truncates on most phones

### Content/Copy
- **7 remaining American `behavior`** instances in lesson/screen files (was 22, most fixed)
- **~5 hyphens used where em dashes should be** in lesson content
- **Raw SnackBar** in smart_screen.dart (bypasses DanioSnackBar)
- **Some generic error messages** ("Something went wrong") with no context

### Visual Assets
- **Angelfish + amano shrimp** — files exist but style doesn't match art bible
- **Learn/practice header illustrations** — converted to WebP but flagged as wrong art style (flat cel vs chibi)
- **Placeholder.webp** — amber watercolor, doesn't match illustrated app style
- **2 room backgrounds** (cozy-living, forest) below quality bar
- **Onboarding background** — photorealistic render in an illustrated app (style mismatch)

### Architecture
- **UserProfileNotifier** — 1,084-line god object (XP, streaks, gems, lessons, onboarding, daily goals). Refactoring plan written in docs/REFACTORING_PLAN.md but not executed
- **AchievementProgressNotifier** — 736 lines, also flagged for decomposition
- **87 broad `ref.watch()` without `.select()`** — unnecessary rebuilds
- **3 `ref.read` in non-async contexts** (home sheets) — stale data risk
- **Non-autoDispose providers** for AI history, anomaly history, weekly plan — wasted memory if Smart tab unused
- **AsyncValue error handling inconsistent** — some screens silently return empty lists on error

### Testing
- 750 tests but mostly smoke tests (render + find text)
- 0 service unit tests
- 3/17 providers have direct tests
- Integration tests exist but not wired to CI
- No golden-path integration tests (create tank → verify on home, complete onboarding → verify flag)

---

## 4. What Is Still Weak

| Area | Score | Key Issue |
|------|-------|-----------|
| Visual asset consistency | 6.5/10 | 2 fish + 2 headers + placeholder don't match art bible |
| Test quality (not quantity) | 5/10 | High count but shallow — mostly "renders without crash" |
| Architecture cleanliness | 7/10 | God objects, broad watches, stale reads |
| UK English consistency | 7/10 | 7 behavior instances remain, hyphens vs em dashes |
| Theme-adaptability | 6/10 | 170 Colors.white, many hardcoded hex |
| Error UX | 7/10 | Some generic messages, silent empty-list fallbacks |
| Onboarding UX | 7.5/10 | No progress indicator, "Quick start" tap target too small |
| Performance | 8/10 | Startup is good, deferred loading correct, but learn_header was 1.4MB PNG (now WebP with cacheWidth) |

---

## 5. What Remains Blocked Externally

| Item | Blocked On | Notes |
|------|-----------|-------|
| IARC content rating | Play Console — Tiarnan only | Answers in docs/CONTENT_RATING_ANSWERS.md |
| SCHEDULE_EXACT_ALARM declaration | Play Console — Tiarnan only | Copy-paste text in docs/PLAY_CONSOLE_DECLARATIONS.md |
| AAB build + submission | Play Console — ON HOLD per Tiarnan | App still needs work |
| Google/Apple auth providers | Supabase config — needs OAuth credentials | Email auth is live |
| Cloud backup bucket | Supabase — `user-backups` bucket needs creation | Non-blocking for v1 |

---

## 6. Likely Finish-Line Categories

These are the categories of remaining work. **Not prescribing what "done" means** — that's for next session.

1. **Visual consistency** — get all assets matching art bible (fish, headers, placeholder, backgrounds)
2. **UX polish** — onboarding progress indicator, tap targets, safe area, error messages
3. **Copy cleanup** — remaining spellings, em dashes, error message specificity
4. **Token system completion** — reduce hardcoded colours, move remaining hex to named tokens
5. **Architecture hygiene** — UserProfileNotifier decomposition, ref.watch .select(), error state handling
6. **Test depth** — service unit tests, provider tests, golden-path integration tests
7. **Dead code / asset cleanup** — linen-wall.webp (unreferenced), friends_screen (dormant), barrel shims
8. **Performance** — remaining .withOpacity calls (now only 2), BackdropFilter count (5, acceptable)

---

## 7. Audit Reports Available

All read-only audits from Wave 8 are in `docs/`:
- `ux-optimisation-audit.md` (28 findings, 4 P1, 11 P2, 13 P3)
- `content-audit.md` (content completeness 8.5/10)
- `architecture-audit.md` (Riverpod 7/10, error handling 7.5/10)
- `visual-asset-audit.md` (overall 6.5/10)
- `code-optimisation-audit.md` (dead code, APK size)
- `performance-deep-audit.md` (startup, images, providers)
- `security-compliance-audit.md` (COPPA, GDPR, key exposure)
- `test-coverage-audit.md` (750 tests, coverage gaps)
- `data-resilience-audit.md` (schema migration, backup gaps)
- `accessibility-audit.md`
- `LAUNCH_CHECKLIST.md` (120 items — 10/14 blockers resolved)
- `REFACTORING_PLAN.md` (UserProfileNotifier decomposition plan)

---

*Prepared for next-session review. No finish line defined — that's the first order of business.*
