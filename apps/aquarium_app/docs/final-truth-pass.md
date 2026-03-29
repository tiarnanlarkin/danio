# Danio — Final Truth Pass

**Date:** 2026-03-29
**Branch:** `openclaw/stage-system` | **HEAD:** `d7e14ac`
**Tests:** 750/750 ✅ | **Analyze:** 0 ✅ | **APK:** ~86.8 MB

**9 agents. 207KB of adversarial findings. No pulled punches.**

---

## Revised Honest Scores

| Dimension | Previous Score | Truth Pass Score | Delta |
|-----------|---------------|-----------------|-------|
| Product Feel (Apollo) | 7.2/10 | **5.8/10** | -1.4 |
| Content Depth (Pythia) | 8.2/10 | **6.5/10** | -1.7 |
| Architecture (Hephaestus) | 7.8/10 | **~7.0/10** | -0.8 |
| Polish/Craft (Daedalus) | 8.1/10 | **~7.0/10** | -1.1 |
| Runtime Trust (Argus) | 7.2/10 | **REJECTED** | — |
| **Overall** | **~7.5/10** | **~6.0/10** | **-1.5** |

---

## THE 15 BLOCKERS — Things That Must Be Fixed Before Any User Sees This

### 🔴 P0 — Dangerous / Dishonest (Would Harm Fish or Break Trust)

| # | Finding | Source | Detail |
|---|---------|--------|--------|
| **B1** | **Ich treatment advice will kill goldfish** | Pythia | Advanced Topics lesson tells ALL users to raise tank to 86°F/30°C. Goldfish max temp is 24°C. Following this kills the fish. |
| **B2** | **SyncService lies to users** | Themis, Aphrodite | Displays "Synced 3 actions" after a 500ms fake delay. No HTTP request is ever made. Data never leaves the device. |
| **B3** | **Onboarding personalisation is fake** | Apollo | 10+ screens of "tell us about you" → tank named "New Tank", hardcoded to 60L for everyone. Users feel tricked. |
| **B4** | **Weekend Amulet is a 20-gem scam** | Hephaestus | User pays 20 gems. Item activates in inventory. Zero code reads it. Daily goal never adjusts. Money for nothing. |
| **B5** | **XP Boost doesn't work for lessons** | Hephaestus | Works on activities/tasks/reviews but NOT on the main game loop (lesson_screen.dart). Users buy boost, do a lesson, get normal XP. |
| **B6** | **Fish Health lessons locked behind Nitrogen Cycle** | Prometheus | User's fish has ich RIGHT NOW → can't access ich lesson until 6 unrelated lessons complete. Crisis user abandons app. |

### 🔴 P0 — Broken Features Visible to Users

| # | Finding | Source | Detail |
|---|---------|--------|--------|
| **B7** | **Difficulty Settings don't persist** | Aphrodite, Orpheus | Rich UI, initialises from blank profile, pure in-memory. Resets on navigate away. |
| **B8** | **Placement Test is fake** | Aphrodite, Orpheus | "Take the test" opens standard SRS screen. `completePlacementTest()` never callable. Achievement permanently locked. |
| **B9** | **Reminders never fire OS notifications** | Aphrodite | Users set reminders, see them in-app, assume they'll get notified. `NotificationService` is never called by `RemindersScreen`. |
| **B10** | **Lighting Schedule crashes at midnight** | Orpheus | `hour - 1` when hour=0 → `TimeOfDay(hour: -1)` → AssertionError in debug, corrupt display in release. |
| **B11** | **Notification payloads unhandled** | Orpheus | Tapping `care` and `water_change` notifications does nothing. Handler silently exits. |

### 🔴 P0 — Silent Data / Trust Issues

| # | Finding | Source | Detail |
|---|---------|--------|--------|
| **B12** | **13 silent fallbacks on critical paths** | Argus | `valueOrNull ?? []` across inventory, tanks, profile. Storage errors show empty lists, not error states. Inventory bug lets users re-purchase owned items, burning gems. |
| **B13** | **24 silent catch blocks swallow errors** | Argus | Including `spaced_repetition_provider.dart:133` with zero logging. SRS save failures are invisible. |
| **B14** | **SchemaMigration is a stub** | Argus | No real migrations for JSON storage. App update = potential data mismatch with zero handling. |
| **B15** | **Gems debounce has no lifecycle flush** | Orpheus | 500ms debounce + app kill = silent gem loss. |

---

## THE 15 HIGH-VALUE IMPROVEMENTS — Not Blockers, But Define Quality

| # | Finding | Source | Impact |
|---|---------|--------|--------|
| **H1** | Lesson completion has no celebration | Apollo | The most important moment in a learning app is the flattest screen emotionally |
| **H2** | 88% of species have no sprite (15/126) | Apollo | Aha moment personalisation falls back to 🐠 emoji for most fish |
| **H3** | GDPR consent is the first screen | Apollo | Legal form before user knows what Danio is |
| **H4** | Corydoras species cards missing medication safety warnings | Pythia | 5 entries, no copper toxicity or salt sensitivity flags |
| **H5** | Livebearer breeding in wrong path | Pythia | Guppies/mollies in Advanced Topics, not Breeding Basics |
| **H6** | Troubleshooting only 3 lessons (unsafe) | Pythia | Power outage, temp crash, pH crash, heater failure all absent |
| **H7** | Dosing Calculator has no "not for medication" warning | Pythia, Prometheus | Users WILL try to dose ich treatment with it |
| **H8** | Multiple-choice only for emergency protocols | Pythia | Recognition memory insufficient for "how to treat ammonia poisoning NOW" |
| **H9** | Onboarding is a design system exception zone | Daedalus | 59 raw GoogleFonts calls, virtually zero token compliance on first screens |
| **H10** | 339 hardcoded Color(0x...) values | Daedalus | Design system coverage for colours is nowhere near 90% |
| **H11** | Tank Comparison shows only 3 fields | Aphrodite | Screen ends after name/volume/type. Placeholder-level feature. |
| **H12** | AI Proxy key not deployed | Themis | Production builds either expose API key in APK or all AI features fail |
| **H13** | Disease Guide and Symptom Checker unlinked | Prometheus | Two tools for same need, no navigation between them |
| **H14** | Today Tab task rows are decorative | Prometheus | Show tasks but tap to nothing, breaking daily ritual loop |
| **H15** | Fish have no mood/happiness state | Apollo | Core Tamagotchi feedback loop (care → visible fish reaction) doesn't exist |

---

## MISCLASSIFICATIONS — Where Previous Audits Were Wrong

### Overrated (Previously Scored Higher Than Reality)
| Item | Previous | Reality | Why |
|------|----------|---------|-----|
| Difficulty Settings | 7/10 "feature" | **Broken** — pure in-memory | Looks complete, persists nothing |
| Placement Test | 7/10 "feature" | **Broken** — routes to wrong screen | No test exists, achievement locked |
| SyncService | "Scaffolding" | **Actively deceptive** — shows fake sync counts | Worse than scaffolding |
| Content readiness | 8.2/10 | **6.5/10** — safety gaps could harm fish | Ich advice, missing emergency topics |
| Product feel | 7.2/10 | **5.8/10** — onboarding lies, no celebration | Gap is in things marked "complete" that aren't |
| "90% token coverage" | Claimed | **True for spacing/typography only** | 339 hardcoded colours make it misleading holistically |
| "750 tests, 25% genuine" | Claimed | **78% are genuine** | Previous audit was too harsh on test quality |

### Underrated (Previous Audit Was Too Harsh)
| Item | Previous | Reality | Why |
|------|----------|---------|-----|
| Test quality | "~25% genuine" | **78% genuine** | Sampled tests are mostly behaviour-level, high quality |
| Persistence architecture | Questioned | **Solid** — atomic writes, lock guards, correct patterns | Two edge cases (gems debounce, SRS catch) but core is sound |
| Cost Tracker | 7/10 | **Best utility feature** — add/delete/totals/categories, persisted | Deserves 8.5/10 |
| Maintenance Checklist | 7/10 | **Solid** — per-tank, auto-resets, persisted | Deserves 8/10 |
| British English in UI | Questioned | **Clean** — zero American spellings in user-facing strings | 35 in comments only, all API-adjacent |

---

## STRUCTURAL THEMES

### 1. The Honesty Gap
Multiple features present rich UI that hides emptiness: sync that doesn't sync, personalisation that doesn't personalise, settings that don't persist, purchases that don't deliver. This is worse than missing features — it actively breaks trust.

### 2. The Crisis User Blind Spot
Danio is designed for the learner who studies before problems arise. A significant percentage of real users download during a crisis (sick fish, new tank emergency). The app fails this group: health lessons are locked, dosing tools don't exist, AI responses are capped at 2-4 sentences for emergencies.

### 3. The Celebration Deficit
The app lacks emotional payoff at every milestone: lesson completion is flat, streak achievements are silent, streak loss goes unacknowledged, level-ups exist but feel mechanical. Duolingo's entire model is "make the user feel something." Danio doesn't, at the moments that matter most.

### 4. Content Safety
Content quality is genuinely high — but two specific safety gaps (ich temperature advice for coldwater fish, missing medication warnings on corydoras cards) could result in actual fish death. For an education app, this is the highest-severity category.

---

## WHAT'S GENUINELY GOOD (The Truth Pass Also Found Strengths)

- **Persistence architecture** is sound — atomic writes, lock guards, correct JSON patterns
- **Test quality** is much better than claimed — 78% genuine behaviour tests
- **Gems economy** is correctly wired and persists
- **SRS scheduling** works exactly as designed (1→3→7→14→30)
- **Streak Freeze** actually works
- **Cost Tracker** and **Maintenance Checklist** are legitimately useful tools
- **British English** is clean in all user-facing strings
- **GlassCard** design system component is exceptional (5 variants, haptics, reduced motion)
- **Content writing quality** is genuinely warm and knowledgeable
- **Nitrogen Cycle** learning path is best-in-class
- **Zero FIXMEs, zero HACKs** in the codebase — problems are structural, not sloppy
- **Species database** is factually accurate with correct scientific names
- **Hearts/Energy system** works correctly

---

## SOURCE FILES

| File | Size | Agent |
|------|------|-------|
| `docs/truth-pass-apollo.md` | 22KB | Apollo — First impression & emotional layer |
| `docs/truth-pass-argus-silent.md` | 26KB | Argus — Silent failures & error swallowing |
| `docs/truth-pass-daedalus-tokens.md` | 15KB | Daedalus — Token coverage & consistency |
| `docs/truth-pass-fake-features.md` | 19KB | Aphrodite — Fake-complete feature challenge |
| `docs/truth-pass-heph-wiring.md` | 17KB | Hephaestus — Feature wiring verification |
| `docs/truth-pass-persistence.md` | 22KB | Orpheus — Persistence & test quality |
| `docs/truth-pass-prometheus.md` | 39KB | Prometheus — User journey stress test |
| `docs/truth-pass-pythia.md` | 38KB | Pythia — Content depth & safety |
| `docs/truth-pass-todos.md` | 8KB | Themis — TODO/FIXME/HACK audit |

**Total findings: ~207KB across 9 agents.**

---

## DECISION REQUIRED

This document is the **finish-line definition**, not the execution plan. Tiarnan reviews, decides what's in scope, then we plan.

The 15 blockers (B1–B15) are things that would embarrass, deceive, or harm users if shipped. The 15 improvements (H1–H15) are what separate "works" from "someone cared."

*The owl sees what the lion misses. Today, it saw a lot.*
