# DANIO — MASTER IMPLEMENTATION PLAN
**Author:** Athena (final synthesis of all 21 research outputs)  
**Date:** 2026-03-16  
**Status:** APPROVED FOR EXECUTION  
**Goal:** Play Store submission-ready

---

## What's Already Done (2026-03-15 Sprints)

Before planning, acknowledge the massive overnight sprint results already landed:

- ✅ Asset compression: 265MB → ~35MB (Sprint 0)
- ✅ 10 critical bugs fixed — INTERNET perm, auth null safety, quiz guard, atomic JSON writes, duplicate providers (Sprint 1)
- ✅ 8 visual bugs fixed — drag handles, quiz overflow, splash dark mode, orientation lock (Sprint 2)
- ✅ 8 build config fixes — ProGuard, Supabase → dart-define, dead code removal, version dart-define (Sprint 3)
- ✅ 5 game balance fixes — hearts refill 5→60min, gem economy, autoDispose.family, history caps (Sprint 5)
- ✅ Accessibility basics — reduced motion, ExcludeSemantics decorative widgets, liveRegion for AI/sync, headers (Sprint 6)
- ✅ Sprint A–F quick wins — heater wattage, betta temps, const optimization, performance .select(), content UX, data fixes
- ✅ Flutter analyze: 0 errors, 0 warnings (as of commit `120f727`)
- ✅ Firebase wired: google-services.json, Firebase Core/Analytics/Crashlytics
- ✅ GitHub Pages: Privacy Policy + Terms of Service live
- ✅ Release signing configured, ProGuard configured
- ✅ UI overhaul: milky tank fixed, room backgrounds (WebP), filing tabs, new app icon, elaborate panels

---

## Execution Phases

### PHASE 1 — COMPLIANCE & STORE BLOCKERS (P0)
*Must complete before submission. No exceptions.*

#### Sprint 1A: GDPR & Privacy (Hephaestus — ~45 min)

| # | Task | Source | Complexity | Notes |
|---|------|--------|-----------|-------|
| 1 | **GDPR consent dialog** — show before any Firebase call on first launch. Persist to SharedPreferences `gdpr_analytics_consent`. Gate Analytics + Crashlytics behind consent. | PS-01, Themis §1.1 | L | Include withdraw-consent toggle in Settings |
| 2 | **Firebase Analytics disabled by default** — add `firebase_analytics_collection_enabled=false` meta-data in AndroidManifest. Enable at runtime only after consent. | PS-02, Themis §1.1 | M | Must pair with PS-01 |
| 3 | **SyncDebugDialog kDebugMode guard** — wrap all call sites in `if (kDebugMode)` | PS-06, Argus Store §3.2 | S | |
| 4 | **OpenAI disclosure consent** — before first fish ID use, show a one-time notice: "Photos are sent to OpenAI servers in the US for identification." Persist acknowledgement. | Themis §1.3 (OpenAI), Argus Data §— | M | *Not in original master fix list — GAP FILLED* |

#### Sprint 1B: Credentials & Pipeline Safety (Hephaestus — ~20 min)

| # | Task | Source | Complexity | Notes |
|---|------|--------|-----------|-------|
| 5 | **Verify Supabase credentials fully removed** — `git grep "supabase.co\|eyJhbGci" lib/` must return 0. Sprint 3 converted to dart-define — verify no remnants. | PS-03 | S | Verification pass |
| 6 | **OpenAI API key startup assertion** — add `assert(openAiKey.isNotEmpty)` with clear error message. Confirm CI pipeline passes the key. | PS-04 | S | |
| 7 | **SCHEDULE_EXACT_ALARM decision** — audit whether exact timing is needed (water change reminders at user-set times = yes). Keep permission, add `USE_EXACT_ALARM` for SDK 33+. Document justification for Play Console declaration. | PS-05, Themis §3.3 | M | Play Console declaration is Tiarnan's task |

#### Sprint 1C: Privacy Policy & Data Deletion (Hephaestus — ~30 min)

| # | Task | Source | Complexity | Notes |
|---|------|--------|-----------|-------|
| 8 | **Privacy Policy update** — add all 6 required sections: OpenAI disclosure, international transfers (US), retention periods, legal basis per activity, ICO complaint right, data deletion mechanism. Draft in `docs/privacy-policy-v2.md` for Tiarnan review before committing to asset. | PS-07, Themis §1.3 | M | ⚠️ REQUIRES TIARNAN REVIEW before merge |
| 9 | **Data deletion mechanism** — add "Delete My Data" in Settings. Show confirmation dialog. Since no server accounts yet (Supabase dormant), clear all local data + show `privacy@tiarnanlarkin.com` email for any residual requests. | PS-08, Themis §5.2 | M | Minimum viable: email contact + local wipe |
| 10 | **GitHub Pages privacy policy** — update the live page at `tiarnanlarkin.github.io/danio/privacy-policy.html` with the approved v2 copy. | PS-07 | S | After Tiarnan approves copy |

#### Sprint 1D: Broken Achievements (Hephaestus — ~40 min)

| # | Task | Source | Complexity | Notes |
|---|------|--------|-----------|-------|
| 11 | **Perfectionist fix** — add `perfectScoreCount` to user stats, increment on 100% quiz, evaluate against threshold. | PS-10, Argus Species §4 | M | |
| 12 | **Speed demon fix** — record `DateTime.now()` at lesson start, pass real elapsed seconds (not estimated). | PS-11, Argus Species §4 | M | |
| 13 | **Comeback fix** — check `lastActivityDate` gap *before* updating it. Persist `lastActivityDate` after every lesson. | PS-12, Argus Species §4 | S | |
| 14 | **Completionist fix** — filter hidden achievements from both numerator and denominator. | PS-13, Argus Species §4 | S | |
| 15 | **Social butterfly fix** — wire `checkAfterFriendAdded()` into friend list changes. Since friends feature is hidden (CA-002), either: (a) hide this achievement too, or (b) wire it for when the feature ships. Recommend: mark hidden. | Argus Species §4 | S | *Not in original master fix list — GAP FILLED* |

---

### PHASE 2 — CONTENT FIXES (P0/P1)
*Factual errors damage credibility. Fix before launch.*

#### Sprint 2A: Factual Quick Fixes (Hephaestus — ~20 min)

| # | Task | Source | File | Fix |
|---|------|--------|------|-----|
| 16 | Betta minimum tank size | Content Quality §Error 1 | `species_care.dart` | 10gal → "5 gallons (19L) minimum, 10 gallons ideal" |
| 17 | Goldfish fancy/common sentence | Content Quality §Error 2 | `species_care.dart` | Remove misleading "fancy need less space" |
| 18 | Ammonia odour quiz explanation | Content Quality §Error 3 | `nitrogen_cycle.dart` | Reword to not claim "odorless" |
| 19 | Livebearer GH range | Content Quality §Error 4 | `water_parameters.dart` | 10-20 → 10-16 dGH |
| 20 | CO₂ atmospheric level | Content Quality §Error 7 | `planted_tank.dart` | 2-5 → 3-5 ppm |
| 21 | Placement test goldfish temp | Content Quality §Error 6 | `placement_test_content.dart` | 75-80°F → 75-82°F |
| 22 | Ammonia toxicity level | Content Quality §Error 5 | `nitrogen_cycle.dart` | 0.25 → 0.5 ppm with nuance |

#### Sprint 2B: Stub Content Gating (Hephaestus — ~15 min)

| # | Task | Source | Notes |
|---|------|--------|-------|
| 23 | **Gate 6 stub lessons behind "Coming Soon" badge** — `fh_ich`, `fh_fin_rot`, `fh_fungal`, `fh_parasites`, `fh_hospital_tank`, `sc_tetras`, `sc_cichlids`, `sc_shrimp`, `sc_snails`. These are 1-2 sentence skeletons. Show as locked/coming soon in the UI, don't present as complete lessons. | Content Quality §Flag 2-4 | Better to hide than to damage credibility |

---

### PHASE 3 — GAMIFICATION & NOTIFICATIONS (P1)
*Important for retention. Do after all P0s.*

#### Sprint 3A: Gamification Polish (Hephaestus — ~20 min)

| # | Task | Source | Complexity |
|---|------|--------|-----------|
| 24 | **Wire `checkAfterReview()`** into spaced repetition completion handler | GF-01 | M |
| 25 | **Extend XP cap** from 2,500 to 10,000+ (constant change + UI scaling check) | GF-02 | S |
| 26 | **Route streak/achievement bonus XP through weeklyXP** | GF-03 | S |

#### Sprint 3B: Notification Wiring (Hephaestus — ~30 min)

| # | Task | Source | Complexity | Notes |
|---|------|--------|-----------|-------|
| 27 | **Move notification permission to live onboarding flow** — currently in dead code (`EnhancedTutorialWalkthroughScreen`). Add a step in the live onboarding path (after GDPR consent) with value proposition: "Get reminded about water changes and streaks." | NT-01, Argus Data §1, Argus Nav §4 | M | Don't block onboarding on denial |
| 28 | **Wire notification scheduling** — water change reminders (per-tank due date), streak nudges (end of day if no lesson). Cancel before re-schedule to avoid duplicates. | NT-02 | L | Service exists with channels — just needs wiring |

---

### PHASE 4 — ACCESSIBILITY (P1)
*Google Play increasingly flags poor TalkBack support.*

#### Sprint 4: Critical Path Accessibility (Hephaestus — ~25 min)

| # | Task | Source | Complexity |
|---|------|--------|-----------|
| 29 | **Semantics on all onboarding screens** (3 screens + GDPR consent dialog) | AC-01 | M |
| 30 | **Semantics on achievements screen** — name, description, locked/unlocked state, progress | AC-02 | M |
| 31 | **Semantics on settings screen** — each row with current state | AC-03 | S |
| 32 | **Label all IconButton instances** — add `tooltip:` to every `IconButton` (`grep -rn "IconButton(" lib/`). Prioritise nav bars, lesson controls, tank actions. | AC-04 | M |
| 33 | **Fix error/success colour contrast** — `#D96A6A` → `#C0392B` (error), `#5AAF7A` → `#1E8449` (success), `#5C9FBF` → `#2E86AB` (info). All need ≥4.5:1 on white. | AC-05, Argus Store §1.3 | S |

---

### PHASE 5 — CODE CLEANUP (P1/P2)
*Polish before submission.*

#### Sprint 5: Dead Code & Cleanup (Hephaestus — ~15 min)

| # | Task | Source | Complexity |
|---|------|--------|-----------|
| 34 | **Remove 7 orphaned screens** — `StudyScreen`, `AquariumSupplyScreen`, `EnhancedQuizScreen`, `PlacementTestScreen` (old), `StoriesScreen`, `StoryPlayerScreen`, `ActivityFeedScreen`. Keep `FriendsScreen` (CA-002) and `LeaderboardScreen` (CA-003) as intentionally hidden. | Argus Nav §4 | M |
| 35 | **Remove dead notification code** from `EnhancedTutorialWalkthroughScreen` after NT-01 is done | CC-02 | S |
| 36 | **Remove dead widgets** — `StoriesCard`, `FriendActivityWidget` (never instantiated) | Argus Nav §5 | S |

---

### PHASE 6 — SUBMISSION PREPARATION
*Not agent work — Athena + Tiarnan.*

#### 6A: Build & Verify (Athena — ~30 min)

| # | Task | Owner | Notes |
|---|------|-------|-------|
| 37 | **Flutter analyze** — confirm 0 errors, 0 warnings after all sprints | Athena | Run directly, not via agent |
| 38 | **Signed AAB build** — `flutter build appbundle --dart-define=OPENAI_API_KEY=...` | Athena | timeout: 420s |
| 39 | **Install + smoke test on Z Fold** — check GDPR dialog, consent flow, fish ID, lesson completion, water test log | Tiarnan | Physical device required |

#### 6B: Store Assets (Athena + Tiarnan — ~45 min)

| # | Task | Owner | Notes |
|---|------|-------|-------|
| 40 | **Store screenshots** — 7 screenshots per Aphrodite brief. Need ADB screencap on device with real data. Script must be written from scratch (store_screenshots.sh doesn't exist — *GAP from Aphrodite audit*). | Athena | Use `adb shell screencap -p /sdcard/` then pull |
| 41 | **Store listing copy** — already exists in `docs/STORE_LISTING.md`. Review against Aphrodite ASO recommendations. | Tiarnan review | Title: "Danio: Learn Fishkeeping & Fish Care" |
| 42 | **Feature graphic** — 1024×500 PNG for Play Store header. Generate via Nano Banana. | Athena | |

#### 6C: Play Console (Tiarnan — manual)

| # | Task | Notes |
|---|------|-------|
| 43 | **Data Safety section** — declare all data types per PS-09 checklist. Must be 100% complete. | After all code changes are in |
| 44 | **SCHEDULE_EXACT_ALARM declaration** — "User-scheduled water change and streak reminder notifications at specific times" | PS-05/Themis §3.3 |
| 45 | **Content rating questionnaire** — PEGI 3 expected (fishkeeping, education, no violence/language) | |
| 46 | **Target audience** — declare 18+ adults (avoids COPPA/Children's Code complexity) | Themis §2.1 recommendation |
| 47 | **Privacy policy URL** — `https://tiarnanlarkin.github.io/danio/privacy-policy.html` | Already live |
| 48 | **Upload AAB + submit for review** | Final step |

---

## Dependency Graph

```
Phase 1A (GDPR consent) ──┐
Phase 1B (credentials)  ──┤
Phase 1C (privacy policy)─┤── All P0s must pass before Phase 6
Phase 1D (achievements)  ─┘
                            │
Phase 2 (content fixes)  ───┤── Can run parallel to Phase 1
                            │
Phase 3 (gamification)   ───┤── After Phase 1D (achievement fixes first)
Phase 3B (notifications) ───┤── After Phase 1A (GDPR consent must exist first)
                            │
Phase 4 (accessibility)  ───┤── Independent, can run anytime
                            │
Phase 5 (cleanup)        ───┤── After Phase 3B (dead notification code)
                            │
Phase 6 (submission)     ───┘── After ALL phases complete
```

---

## Parallelisation Strategy

**Wave 1 (can run simultaneously):**
- Sprint 1A (GDPR) — touches main.dart, analytics_service, consent_screen (NEW)
- Sprint 1D (achievements) — touches achievement_service, gamification_service, user_stats
- Sprint 2A (content fixes) — touches lesson content .dart files only
- Sprint 4 (accessibility) — touches screen widgets only (Semantics wrappers)

**Wave 2 (after Wave 1):**
- Sprint 1B (credentials verify) — quick pass
- Sprint 1C (privacy policy) — needs GDPR dialog design finalised
- Sprint 2B (stub gating) — needs content fix pass done first
- Sprint 3A (gamification) — needs achievement fixes from 1D

**Wave 3 (after Wave 2):**
- Sprint 3B (notifications) — needs GDPR consent from 1A
- Sprint 5 (cleanup) — needs notification refactor from 3B

**Wave 4 (final):**
- Phase 6 (build, screenshots, submission)

---

## Total Estimates

| Phase | Hephaestus Time | Athena Time | Tiarnan Time |
|-------|----------------|-------------|-------------|
| Phase 1 (compliance) | ~2.5 hours | 30 min (review) | 15 min (privacy review) |
| Phase 2 (content) | ~35 min | 5 min (verify) | — |
| Phase 3 (gamification + notifications) | ~50 min | 10 min (verify) | — |
| Phase 4 (accessibility) | ~25 min | 5 min (verify) | — |
| Phase 5 (cleanup) | ~15 min | 5 min (verify) | — |
| Phase 6 (submission) | — | ~1.5 hours | ~1 hour (Play Console) |
| **TOTAL** | **~4.5 hours** | **~2 hours** | **~1.5 hours** |

**Realistic wall-clock time:** 6-8 hours with parallelisation, review cycles, and agent timeouts.

---

## Items NOT In This Plan (Deferred Post-Launch)

These were identified by research agents but are explicitly **not required for v1 submission**:

| Item | Source | Why Deferred |
|------|--------|-------------|
| Full onboarding rewrite (10-screen Artemis spec) | ARTEMIS_ONBOARDING_SPEC.md | Current 4-screen flow is functional. Rewrite is v1.1 |
| RevenueCat / billing integration | PROMETHEUS_BILLING_DECISION.md | No paywall for v1 — free launch, add monetisation after retention data |
| Full 64-screen Semantics sweep | CC-01 | Critical paths covered in Phase 4; rest is post-launch |
| Age gate (COPPA) | Themis §2.1 | Declaring 18+ audience avoids this; add age gate in v1.1 if needed |
| Notification sequences (60+ messages) | DIONYSUS_NOTIFICATION_SEQUENCE.md | Basic reminders in Phase 3; elaborate sequences are post-launch |
| Full content rewrite (fish health, species care stubs) | ARGUS_CONTENT_QUALITY §Rewrites | Gated behind "Coming Soon" in Phase 2B; write real content post-launch |
| Achievement unit tests | CC-03 | Nice to have, not a blocker |
| i18n / ARB infrastructure | Argus Store §2 | English-only v1 |
| OpenAI Zero Data Retention | Themis §1.4 | Investigate post-launch |
| Full CMP (Google UMP) | Themis §6 | Manual consent dialog sufficient for v1 |
| UK ICO registration | Themis §6 | Recommended but not blocking |
| A/B tests (screenshots, pricing) | PROMETHEUS_AB_TESTS.md | Post-launch after baseline data |
| PR outreach / community launch | PROMETHEUS_PR_OUTREACH.md | After app is live |
| Supabase cloud sync | — | Entire feature deferred |

---

## Tiarnan Actions Required (Cannot Be Automated)

| # | Action | When | Blocking? |
|---|--------|------|-----------|
| T1 | **Review privacy policy v2 draft** | After Sprint 1C delivers draft | Yes — must approve before merge |
| T2 | **Fill Play Console Data Safety section** | After all code changes | Yes — submission blocker |
| T3 | **Declare SCHEDULE_EXACT_ALARM in Play Console** | After all code changes | Yes — submission blocker |
| T4 | **Complete content rating questionnaire** | Before submission | Yes |
| T5 | **Set target audience to 18+** | Before submission | Yes |
| T6 | **Smoke test on Z Fold** — GDPR flow, fish ID, lesson, water test | After AAB build | Yes |
| T7 | **Submit app for review** | Final step | — |

---

## Hephaestus Execution Rules (Unchanged)

1. Run `flutter analyze` after every sprint — 0 errors required
2. Never run `flutter build` — Athena handles builds
3. Commit after each completed sprint: `fix(scope): description`
4. Flag PS-09 / T1-T7 items to Tiarnan — cannot be automated
5. Do not modify `main.dart` error handler chain (Sprint 1 already fixed this)
6. Test GDPR consent on physical device (clear data, cold start)

---

*Plan compiled by Athena from 21 research outputs across 10 specialist agents.*
*Cross-referenced against: HEPHAESTUS_MASTER_FIX_LIST.md, THEMIS_COMPLIANCE_AUDIT.md, ARGUS_CODE_STORE.md, ARGUS_CONTENT_QUALITY.md, ARGUS_CONTENT_SPECIES.md, ARGUS_CODE_NAVIGATION.md, ARGUS_CODE_DATA.md, ARTEMIS_ONBOARDING_SPEC.md, PROMETHEUS_BILLING_DECISION.md, APHRODITE_SCREENSHOT_BRIEF.md*
