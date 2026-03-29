# Danio — Endgame Execution Plan (v2)

**Created:** 2026-03-29
**Revised:** 2026-03-29 17:01 (Tiarnan adjustments applied)
**Authority:** Tiarnan Larkin (directive) + Athena (planning)
**Source:** `final-gap-register.md`, `finish-contract.md`, `finish-line.md`
**Rule:** No execution starts until Tiarnan approves this plan.

---

## Plan Structure

| Wave | Focus | Items | Estimated Effort |
|------|-------|-------|-----------------|
| **R** | Research First (decisions) | 9 RF items | Tiarnan decision session |
| **1A** | Safety + simple honesty fixes | 7 FB items | Half session |
| **1B** | Complex honesty fixes | 4 FB items | Half session |
| **2** | Broken flows → silent trust → durability | 13 FB items | 1 session (overnight capable) |
| **3** | Remaining blockers + sweeps | 11 FB items | 1 session |
| **⛔ HARD GATE** | All 35 FB verified resolved | — | Gate check |
| **4** | Finish Quality Requirements | 27 FQ items | 2–3 sessions |
| **V** | Final Verification | Re-run truth pass | 1 session |
| **EX** | External / Setup | 7 EX items | Tiarnan-gated, parallel |

**Total: 71 product items + 7 external items + verification pass**

---

## HARD GATE RULE

**No Finish Quality (FQ) work begins until:**
1. All 35 Finish Blockers (FB) are resolved in code
2. All 35 are verified by Argus against original findings
3. `final-gap-register.md` shows all FB items in Resolved section
4. `residual-work.md` confirms zero FB items remaining
5. Athena signs off on gate passage and logs in `decision-ledger.md`

**No exceptions. No "just starting one FQ item while we wait." The gate is binary.**

The only parallel exception: **art generation (FQ-V1–V6) may begin during FB waves** because it has zero code dependency and long iteration cycles. Art assets are not committed until Wave 4.

---

## HEARTBEAT / SUPERVISION STRUCTURE

Applies to every wave uniformly.

### Active Agent/Task Table
At wave start, Athena posts a live status table:

```
| # | Agent | Task IDs | Status | Started | Last Update |
|---|-------|----------|--------|---------|-------------|
| 1 | Hephaestus | FB-S3, FB-S4 | 🔄 Running | 17:05 | 17:12 |
| 2 | Pythia | FB-S1, FB-S2 | ✅ Complete | 17:05 | 17:18 |
| 3 | Argus | — | ⏳ Waiting | — | — |
```

Updated on every agent completion or status change.

### Heartbeat Cadence
- **Athena checks agent status** every **10 minutes** during active execution
- **Progress update to Tiarnan** every **20 minutes** (or on agent completion, whichever is sooner)
- **Format:** 3-line max digest. What finished. What's running. Any blockers.

### Stale Timeout Threshold
- **Agent stale after:** 12 minutes with no output file writes
- **Action on stale:** Athena checks session, steers or kills + respawns with tighter scope
- **Hard timeout:** 20 minutes — kill and respawn unconditionally

### Return Brief Format
When Tiarnan returns to a session mid-wave:

```
## Return Brief — Wave [X]
**Status:** [X/Y items complete]
**Running:** [agent names + task IDs]
**Blocked:** [anything waiting on decision/Tiarnan]
**Since last update:** [what changed]
**Next:** [what happens when current agents finish]
```

### Wave Closure Format
Every wave ends with:

```
## Wave [X] Closure
**Items resolved:** [list with IDs]
**Verification:** Argus confirmed [X/Y] items against original findings
**Same-class sweep:** [result — clean / N new items found]
**Tests:** [pass count] / analyze: [0]
**Commit:** [hash]
**Docs updated:** [list]
**Decision:** Wave [X] CLOSED. Proceeding to Wave [X+1].
```

Logged in `decision-ledger.md`.

---

## SAME-CLASS SWEEP RULE

Every blocker wave (1A, 1B, 2, 3) must include a **same-class sweep** after fixes are committed:

| Wave | Sweep Type | Method |
|------|-----------|--------|
| 1A | Safety content sweep | Pythia re-greps all lesson/species data for remaining unsafe advice, missing warnings, temperature claims |
| 1B | Fake-feature sweep | Hephaestus greps for other `setState()`-only "persistence", other shop items with no read-side code, other dead `completeSomething()` calls |
| 2 | Dead-button + silent-error sweep | Argus greps for remaining `Navigator.pop()`-only handlers, remaining `catch(_) {}` with no logging, remaining `valueOrNull ?? []` on critical paths |
| 3 | Debug/cleanup sweep | Daedalus greps for remaining `print(` debug calls, duplicate UI entries, version string mismatches |

**If sweep finds new items:** classify as FB (enter current wave) or DE (defer with reason). Log in `decision-ledger.md`.

---

## WAVE R — RESEARCH FIRST (Decision Wave)

**Purpose:** Make the 9 design/product decisions before implementation touches them.
**When:** Before Wave 1A starts. Same session as plan approval.

| ID | Decision Needed | Athena Recommendation | Gates |
|----|----------------|----------------------|-------|
| RF-1 | TankComparisonScreen: enrich or hide? | **Hide.** Building real comparison is new feature work. | Wave 2 |
| RF-2 | Bottom sheet: 3 tabs or 4? | **Keep 3.** Update docs to match code. | None |
| RF-3 | Cycling Assistant: add to Workshop grid? | **Yes.** Single route addition, tool is polished. | Wave 3 |
| RF-4 | ThemeGalleryScreen: connect or remove? | **Remove.** Orphaned dead code. | Wave 3 |
| RF-5 | Dual level-up systems: merge or gate? | **Gate.** Guard so only one fires per event. | Wave 3 |
| RF-6 | Light Intensity button: wire or remove? | **Remove.** Dead UI worse than absent UI. | Wave 2 |
| RF-7 | Fish ID "Add to Tank" flow | **Navigate to livestock add with pre-filled species.** | Wave 3 |
| RF-8 | Anomaly dismiss semantics | **"Dismissed — will flag again if detected."** | Wave 3 |
| RF-9 | GDPR consent placement | **Move after welcome screen.** | Wave 1B |

**Decided by:** Tiarnan (overrides any recommendation)
**Output:** All 9 logged in `decision-ledger.md` before Wave 1A starts.

---

## WAVE 1A — SAFETY + SIMPLE HONESTY

**Purpose:** Eliminate dangerous content and simple dishonest features. These are well-scoped fixes with clear boundaries.

**Why grouped:** Safety items are highest severity. FB-H1/H6/H7 are straightforward wire-it-or-hide-it fixes that don't risk scope creep.

### Items

| ID | Issue | Agent | Effort | Dependencies |
|----|-------|-------|--------|-------------|
| **FB-S1** | Ich advice kills goldfish — add species-specific temperature guidance | Pythia | Small | None |
| **FB-S2** | Corydoras cards missing safety warnings — add copper/salt flags | Pythia | Small | None |
| **FB-S3** | Fish Health locked behind Nitrogen Cycle — remove/reduce prerequisite | Hephaestus | Small | None |
| **FB-S4** | Dosing Calculator missing medication warning | Hephaestus | Trivial | None |
| **FB-H1** | SyncService lies — hide sync UI or show "local only" | Hephaestus | Small | None |
| **FB-H6** | Difficulty Settings don't persist — load/save via StorageService | Hephaestus | Small | None |
| **FB-H7** | Reminders don't fire notifications — wire NotificationService | Hephaestus | Small | None |

### Agent Assignment

| Agent | Items | Role |
|-------|-------|------|
| **Pythia** | FB-S1, FB-S2 | Content data file edits |
| **Hephaestus** | FB-S3, FB-S4, FB-H1, FB-H6, FB-H7 | Code changes |
| **Argus** | All 7 | Verification against original findings |

### Parallelisation
- Pythia (S1, S2) and Hephaestus (S3, S4, H1, H6, H7) run fully in parallel
- Hephaestus batch order: FB-S3 + FB-S4 first (trivial), then FB-H1, FB-H6, FB-H7

### Same-Class Sweep (1A)
After fixes committed, Pythia sweeps ALL lesson and species data for:
- Other temperature claims that could harm specific species
- Other species cards missing medication sensitivity warnings
- Other treatment advice without species-specific caveats

### Definition of Done
- [ ] `flutter analyze` = 0
- [ ] All existing tests pass
- [ ] Argus verifies each fix against original finding:
  - FB-S1: Lesson no longer recommends universal 86°F. Species-specific guidance present for coldwater fish.
  - FB-S2: All 5 Corydoras cards show copper toxicity + salt sensitivity warnings.
  - FB-S3: Fish Health path accessible without completing Nitrogen Cycle.
  - FB-S4: Dosing Calculator shows prominent "for fertilisers only, not medication" warning.
  - FB-H1: No UI displays fake sync counts. Either hidden or shows "local only."
  - FB-H6: Change difficulty → navigate away → return → settings preserved.
  - FB-H7: Set reminder → receive OS notification at scheduled time.
- [ ] Same-class sweep: clean (or new items classified + logged)
- [ ] Commit pushed
- [ ] `residual-work.md` updated: 7 items → Resolved
- [ ] `decision-ledger.md` updated with any in-wave decisions

### Docs Updated on Close
- `residual-work.md` — 7 items resolved
- `feature-registry.md` — affected features updated
- `decision-ledger.md` — wave closure + any scope calls

---

## WAVE 1B — COMPLEX HONESTY FIXES

**Purpose:** Fix the honesty items that carry scope-creep risk. Separated from 1A because each requires careful boundaries.

**Why grouped:** FB-H2 touches onboarding files extensively. FB-H3/H4 are shop wiring with test implications. FB-H5 is the highest scope-creep risk in the entire plan.

### Items

| ID | Issue | Agent | Effort | Dependencies |
|----|-------|-------|--------|-------------|
| **FB-H2** | Onboarding personalisation fake — use actual user selections | Hephaestus | Medium | RF-9 decided |
| **FB-H3** | Weekend Amulet no-op — wire to daily goal | Hephaestus | Medium | None |
| **FB-H4** | XP Boost broken for lessons — add boost param to completeLesson | Hephaestus | Small | None |
| **FB-H5** | Placement Test fake — **remove/hide CTA** | Hephaestus | Small | Tiarnan default rule |

### Placement Test Rule (Tiarnan directive)
**Default decision:** Remove/hide the fake Placement Test CTA. Do not build a real placement flow. Do not allow scope creep. If a real placement flow exists and is genuinely small to wire (< 30 min), Hephaestus may wire it — otherwise hide the card and log the defer.

### Agent Assignment

| Agent | Items | Role |
|-------|-------|------|
| **Hephaestus** | All 4 | Code changes |
| **Argus** | All 4 | Verification |

### Scope Boundaries (enforced)
- **FB-H2:** Wire existing user selections (tank name from fish selection, volume from tank type screen) to tank creation. Do NOT redesign the onboarding flow. Do NOT add new screens.
- **FB-H3:** Wire `isItemActive('weekend_amulet')` into `todaysDailyGoalProvider`. Do NOT redesign the shop or goal system.
- **FB-H4:** Add `xpBoostActive` parameter to `completeLesson()`, pass `ref.read(xpBoostActiveProvider)` from lesson_screen. Do NOT redesign the XP system.
- **FB-H5:** Hide PlacementChallengeCard. Log as DE-19 in gap register. Do NOT build a placement test.

### Same-Class Sweep (1B)
Hephaestus sweeps for:
- Other shop items where purchase activates but no code reads the active state
- Other `setState()`-only "persistence" patterns (settings that look saved but aren't)
- Other CTAs that route to wrong/unrelated screens
- Other `completeX()` methods that are never callable from UI

### Definition of Done
- [ ] `flutter analyze` = 0
- [ ] All existing tests pass
- [ ] Argus verifies each fix:
  - FB-H2: Onboarding → tank created with user's actual fish name + selected volume (not "New Tank" / 60L).
  - FB-H3: Buy Weekend Amulet → daily goal reduces on Saturday/Sunday.
  - FB-H4: Buy XP Boost → complete lesson → XP is doubled.
  - FB-H5: No Placement Test CTA visible anywhere. Card hidden. Achievement either hidden or unlockable via other means.
- [ ] Same-class sweep: clean (or new items classified + logged)
- [ ] Commit pushed
- [ ] `residual-work.md` updated: 4 items → Resolved

---

## WAVE 2 — RELIABILITY + BROKEN FLOWS

**Purpose:** Fix every crash, dead button, and silent failure. Priority-locked order: visible broken → silent trust → durability.

**Why grouped:** All mechanical trustworthiness issues. User-visible breaks first because they're the most embarrassing, silent trust second because they cause insidious harm, durability third because they're preventive.

### Priority-Locked Order

**Phase 2A — Visible broken flows and crashes (fix first)**

| ID | Issue | Agent | Effort |
|----|-------|-------|--------|
| **FB-B1** | Lighting Schedule midnight crash | Hephaestus | Trivial |
| **FB-B3** | Day7MilestoneCard CTA dead | Hephaestus | Small |
| **FB-B4** | Day30CommittedCard CTA dead | Hephaestus | Small |
| **FB-B5** | "Run Symptom Triage" button dead | Hephaestus | Small |
| **FB-B6** | "Save to Journal" in Symptom Triage dead | Hephaestus | Small |
| **FB-B7** | WarmEntryScreen chevron dead | Hephaestus | Trivial |
| **FB-B8** | Markdown raw in Symptom Triage | Hephaestus | Small |
| **FB-B2** | Notification tap: care/water_change unhandled | Hephaestus | Small |

**Phase 2B — Silent trust plumbing (fix second)**

| ID | Issue | Agent | Effort |
|----|-------|-------|--------|
| **FB-T1** | 13 silent fallbacks on critical paths | Hephaestus | Medium |
| **FB-T2** | Critical silent catch blocks | Hephaestus | Medium |
| **FB-T5** | SR error state swallowed | Hephaestus | Small |

**Phase 2C — Durability (fix third)**

| ID | Issue | Agent | Effort |
|----|-------|-------|--------|
| **FB-T4** | Gems debounce lifecycle flush | Hephaestus | Small |
| **FB-T3** | SchemaMigration stub | Hephaestus | Medium |

### Agent Assignment

| Agent | Items | Role |
|-------|-------|------|
| **Hephaestus** | All 13 | Code changes (can split across 2 sessions: 2A+2B then 2C) |
| **Argus** | All 13 | Verification |

### Scope Boundaries
- **FB-T3 (SchemaMigration):** Build version-check + safe-default migration ONLY. Do NOT build a full migration framework. Scope: detect version mismatch → apply safe defaults for new fields → log migration event. That's it.
- **FB-B8 (Markdown):** Use `flutter_markdown` or simple regex strip. Do NOT build a custom markdown renderer.

### Same-Class Sweep (Wave 2)
Argus sweeps for:
- Remaining `Navigator.pop()`-only button handlers (grepping for pop() in onPressed/onTap callbacks)
- Remaining `catch(_) {}` or `catch(e) {}` with no logging on critical paths
- Remaining `valueOrNull ?? []` or `valueOrNull ?? {}` on data-critical providers
- Remaining commented-out navigation (`// Navigate to...`)

### Definition of Done
- [ ] `flutter analyze` = 0
- [ ] All existing tests pass
- [ ] Argus verifies each fix against original finding:
  - FB-B1: Lighting Schedule with lights-on at 00:xx renders correctly, no crash.
  - FB-B2: Tapping care/water_change notification navigates to relevant screen.
  - FB-B3: Day7 button navigates to Compatibility Checker.
  - FB-B4: Day30 button navigates to real destination OR CTA removed (log decision).
  - FB-B5: "Run Symptom Triage" navigates to Symptom Triage.
  - FB-B6: "Save to Journal" persists diagnosis text to tank journal entry.
  - FB-B7: WarmEntry lesson card tap navigates to first available lesson.
  - FB-B8: Symptom Triage renders AI markdown as formatted text.
  - FB-T1: Storage errors on critical paths show error UI, not empty lists. Zero `valueOrNull ?? []` on critical paths after sweep.
  - FB-T2: Critical catch blocks log error + show user feedback. Zero silent swallows on critical paths after sweep.
  - FB-T3: Version-check migration exists. App detects schema version change and applies safe defaults.
  - FB-T4: `didChangeAppLifecycleState(paused/inactive)` flushes pending gem writes.
  - FB-T5: SR practice screen shows error message when provider is in error state.
- [ ] Same-class sweep: clean (or new items classified + logged)
- [ ] Commit pushed
- [ ] `residual-work.md` updated: 13 items → Resolved

---

## WAVE 3 — REMAINING BLOCKERS + SWEEPS

**Purpose:** Close every remaining FB item. After this wave, zero finish blockers remain. Gate check follows.

**Why grouped:** All small/trivial cleanup items that depend on Wave R decisions or are low-risk mechanical fixes.

### Items

| ID | Issue | Agent | Effort |
|----|-------|-------|--------|
| **FB-O1** | Three version strings → centralise | Hephaestus | Trivial |
| **FB-O2** | Duplicate About entries → remove generic | Hephaestus | Trivial |
| **FB-O3** | FishSelectScreen safe area padding | Hephaestus | Trivial |
| **FB-O4** | Decimal input on calculators | Hephaestus | Trivial |
| **FB-O5** | Numeric keyboard on Symptom Triage | Hephaestus | Trivial |
| **FB-O6** | SRS achievements → route through checkAchievements() | Hephaestus | Small |
| **FB-O7** | Remove 5 debug print statements | Hephaestus | Trivial |
| **RF-3** | Add Cycling Assistant to Workshop grid | Hephaestus | Trivial |
| **RF-4** | Remove ThemeGalleryScreen dead code | Hephaestus | Trivial |
| **RF-5** | Gate dual level-up systems | Hephaestus | Small |
| **RF-6** | Remove dead Light Intensity button | Hephaestus | Trivial |

### Agent Assignment

| Agent | Items | Role |
|-------|-------|------|
| **Hephaestus** | All 11 | Code changes (single batch, mostly trivial) |
| **Argus** | All 11 | Verification |
| **Daedalus** | — | Same-class sweep |

### Same-Class Sweep (Wave 3)
Daedalus sweeps for:
- Remaining `print(` debug statements (beyond the 5 known)
- Remaining duplicate UI entries (settings, menus)
- Remaining version string mismatches
- Remaining dead/orphaned screens with no route

### Definition of Done
- [ ] `flutter analyze` = 0
- [ ] All existing tests pass
- [ ] Argus verifies each fix against original finding
- [ ] Same-class sweep: clean
- [ ] **ZERO FB items remain in `final-gap-register.md`**
- [ ] Commit pushed
- [ ] `residual-work.md` updated: 11 items → Resolved, FB section empty

---

## ⛔ HARD GATE — FB → FQ TRANSITION

**After Wave 3 closes, before Wave 4 begins:**

### Gate Checklist

- [ ] All 35 Finish Blockers show as Resolved in `residual-work.md`
- [ ] All 35 verified by Argus against original truth pass findings
- [ ] All 4 same-class sweeps completed and clean (or findings classified + logged)
- [ ] `flutter analyze` = 0
- [ ] All tests pass
- [ ] `final-gap-register.md` FB section fully resolved
- [ ] `feature-registry.md` updated — no 🔴 Broken or 🟠 Scaffold features remain (except explicitly deferred items)

### Gate Decision
Athena reviews the checklist. If all boxes checked:
- Log "HARD GATE PASSED" in `decision-ledger.md` with date and evidence
- Proceed to Wave 4

If any box unchecked:
- Identify gap, classify as FB (fix now) or new item
- Do NOT proceed to Wave 4
- Log the blocker in `decision-ledger.md`

---

## WAVE 4 — FINISH QUALITY REQUIREMENTS

**Purpose:** Elevate from "works correctly" to "someone cared." 27 items across 4 parallel sub-waves.

**Prerequisite:** Hard gate passed. Zero FB items remaining.

### Sub-wave 4A: Content + Code Quality (Pythia + Hephaestus)

| ID | Issue | Agent | Effort |
|----|-------|-------|--------|
| FQ-C1 | Troubleshooting: 3→6 lessons | Pythia | Medium |
| FQ-C2 | Breeding: 3→6 lessons, move livebearer | Pythia | Medium |
| FQ-C3 | Medication dosing lesson | Pythia | Medium |
| FQ-C4 | QT tank size → 20L | Pythia | Trivial |
| FQ-C5 | Fix ~54 American spellings | Pythia | Trivial |
| FQ-C6 | Equipment paths restructure | Pythia | Small |
| FQ-C7 | Add Pea Puffer | Pythia | Small |
| FQ-Q1 | FishCardState controller leak | Hephaestus | Trivial |
| FQ-Q2 | 3 golden-path persistence tests | Hephaestus | Small |
| FQ-Q3 | AI providers → autoDispose | Hephaestus | Trivial |

### Sub-wave 4B: Visual Cohesion (Iris / Tiarnan)

| ID | Issue | Agent | Effort |
|----|-------|-------|--------|
| FQ-V1 | Regen learn + practice headers | Iris / Tiarnan | Medium |
| FQ-V2 | Regen angelfish + amano shrimp | Iris / Tiarnan | Medium |
| FQ-V3 | Replace onboarding background | Iris / Tiarnan | Medium |
| FQ-V4 | Replace placeholder.webp | Iris / Tiarnan | Small |
| FQ-V5 | Regen room-bg-cozy-living | Iris / Tiarnan | Medium |
| FQ-V6 | Create 4 badge icons | Iris / Tiarnan | Medium |
| FQ-V7 | Fix bristlenose_pleco palette | Hephaestus | Trivial |

**Note:** Art generation (FQ-V1–V6) may begin during FB waves as parallel work. Zero code dependency. Assets not committed until Wave 4.

### Sub-wave 4C: Design System + Accessibility (Daedalus)

| ID | Issue | Agent | Effort |
|----|-------|-------|--------|
| FQ-D1 | Replace 59 raw GoogleFonts in onboarding | Daedalus | Medium |
| FQ-D2 | Replace ~25 raw buttons with AppButton | Daedalus | Small |
| FQ-D3 | Fix AppColors.primaryLight contrast | Daedalus | Trivial |
| FQ-D4 | Fix Quick Start tap target | Daedalus | Trivial |
| FQ-D5 | Add password toggle tooltip | Daedalus | Trivial |

**Dependency:** Start after 4A content changes are committed (avoid merge conflicts in onboarding files shared with FB-H2 from Wave 1B).

### Sub-wave 4D: Emotional / Product Feel (Apollo design → Hephaestus build)

| ID | Issue | Agent | Effort |
|----|-------|-------|--------|
| FQ-E1 | Lesson completion celebration | Apollo (design) → Hephaestus (build) | Medium |
| FQ-E2 | Streak loss acknowledgement | Hephaestus | Small |
| FQ-E3 | Daily goal on home view | Hephaestus | Small |
| FQ-E4 | Today Tab task rows → tappable | Hephaestus | Small |

**Dependency:** FQ-E1 needs Apollo design spec before Hephaestus builds. Keep scope to animation + sound + warm copy — no new screens.

### Parallelisation
```
4A (Pythia content + Hephaestus code) ──┐
4B (Iris art — may start earlier) ──────┤── all parallel
4C (Daedalus design system) ────────────┤── start after 4A commits
4D (Apollo design → Hephaestus build) ──┘── FQ-E1 needs Apollo first
```

### Definition of Done
- [ ] `flutter analyze` = 0
- [ ] All tests pass (including 3 new golden-path tests from FQ-Q2)
- [ ] Argus verifies all 27 items
- [ ] All visual assets reviewed against `design-direction.md`
- [ ] Zero FQ items remain in `final-gap-register.md`
- [ ] All canonical docs updated to reflect final state

---

## WAVE V — FINAL VERIFICATION

**Purpose:** Adversarial re-check to confirm finish contract passes.

### Process
1. Athena deploys 5 agents with verification briefs scoped to their original findings
2. Each agent confirms their findings are resolved in the fixed codebase
3. Any new findings classified: genuine miss → re-enter pipeline, or acceptable → log + defer
4. Finish contract 7 gates walked

### Agents

| Agent | Re-checks |
|-------|-----------|
| **Pythia** | Safety content (FB-S1–S4), content depth (FQ-C1–C7) |
| **Hephaestus** | Wiring (FB-H3, H4), broken flows (FB-B1–B8) |
| **Argus** | Silent failures (FB-T1–T5), persistence, error handling |
| **Apollo** | Product feel, onboarding honesty, emotional layer |
| **Daedalus** | Design system compliance, accessibility, token coverage |

### Definition of Done
- [ ] Every original truth pass finding verified resolved or explicitly deferred
- [ ] Finish contract 7 gates all checked
- [ ] `flutter analyze` = 0, all tests pass
- [ ] Final commit tagged
- [ ] All canonical docs reflect final state
- [ ] "FINISH CONTRACT PASSED" logged in `decision-ledger.md`

---

## EXTERNAL / SETUP BLOCKERS (Parallel Track)

Do not block product work. Block deployment/submission only.

| ID | Issue | When Needed | Action |
|----|-------|-------------|--------|
| EX-1 | Firebase google-services.json | Before production build | Tiarnan provides |
| EX-2 | Supabase deep link | Before auth testing | Tiarnan configures |
| EX-3 | AI Proxy Edge Function | Before production AI | Tiarnan deploys |
| EX-4 | IARC content rating | Before store submission | Tiarnan completes form |
| EX-5 | SCHEDULE_EXACT_ALARM | Before store submission | Hephaestus, 1 line (can do in Wave 3) |
| EX-6 | Google/Apple OAuth | Post-finish | v1.1 |
| EX-7 | Play Console setup | ON HOLD | Not until Tiarnan unblocks |

---

## AGENT ASSIGNMENT MATRIX

| Agent | Wave 1A | Wave 1B | Wave 2 | Wave 3 | Wave 4A | Wave 4B | Wave 4C | Wave 4D | Wave V |
|-------|---------|---------|--------|--------|---------|---------|---------|---------|--------|
| **Athena** | Coord | Coord | Coord | Coord | Coord | Coord | Coord | Coord | Coord |
| **Hephaestus** | 5 items | 4 items | 13 items | 11 items | 3 items | 1 item | — | 4 items | Verify |
| **Pythia** | 2 items | — | — | — | 7 items | — | — | — | Verify |
| **Argus** | Verify 7 | Verify 4 | Verify 13 | Verify 11 | Verify 10 | Verify 7 | Verify 5 | Verify 4 | Verify all |
| **Apollo** | — | — | — | — | — | — | — | Design E1 | Verify |
| **Daedalus** | — | — | — | Sweep | — | — | 5 items | — | Verify |
| **Iris** | — | — | — | — | — | 6 items | — | — | — |

---

## TOPOLOGICAL ORDER

```
Wave R (9 decisions) ──────────────────────────────┐
    │                                               │
    ├──→ Wave 1A (safety + simple honesty) ─────────┤
    │        │                                      │
    │        ▼                                      │
    └──→ Wave 1B (complex honesty) ── FB-H2←RF-9 ──┘
             │
             ▼
         Wave 2A (visible broken flows)
             │
             ▼
         Wave 2B (silent trust)
             │
             ▼
         Wave 2C (durability)
             │
             ▼
         Wave 3 (remaining blockers + RF implementations)
             │
             ▼
         ⛔ HARD GATE (all 35 FB verified)
             │
             ▼
         Wave 4A+4B+4C+4D (parallel, with noted dependencies)
             │
             ▼
         Wave V (final verification)

Art generation (4B): can start any time, zero code dependency.
```

---

## EXPECTED RISKS

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| FB-H2 scope creep (onboarding is complex) | Medium | Medium | Hard boundary: wire existing selections only. No new screens. No redesign. |
| FB-H3 Weekend Amulet wiring touches daily goal logic | Medium | Low | Isolated change: add one `if` check in `todaysDailyGoalProvider`. Test manually. |
| FB-T1 + FB-T2 cascade (fixing silent errors reveals more) | Medium | Medium | Same-class sweep catches cascades. New items classified immediately. |
| FB-T3 SchemaMigration scope creep | Medium | High | Hard scope: version-check + safe-defaults only. No migration framework. |
| Art generation quality (4B) | Medium | High | Start with 1 test asset. Get Tiarnan sign-off before batching. |
| Hephaestus overload (38 items across Waves 1–3) | Medium | Medium | Priority-locked batches. Split Wave 2 across 2 sessions if needed. |
| Same-class sweeps finding large new item counts | Low | Medium | Classify immediately. Only FB-class items enter current wave. Everything else defers. |
| Merge conflicts in onboarding files (Wave 1B ↔ Wave 4C) | Low | Low | Sequential waves. 4C starts after all FB waves committed. |

---

## TONIGHT / NEXT SESSION

### Recommended sequence:

1. **Wave R** (15 min) — walk through 9 decisions, I log them
2. **Launch Wave 1A overnight** — Pythia + Hephaestus in parallel, Argus verifies on completion
3. **If time: launch Wave 1B** immediately after 1A (or overnight continuation)

### Don't start tonight:
- Art generation (needs method decision from Tiarnan)
- Any Wave 4 work (hard gate hasn't passed)
- External/setup blockers (on hold)

---

## COMPLETION FORECAST

| Session | Waves | Cumulative Items Resolved |
|---------|-------|--------------------------|
| **Tonight** | R + 1A | 9 decisions + 7 FB = 16 |
| **Session 2** | 1B + 2 (phases A-B) | 4 + 10 = 30 |
| **Session 3** | 2 (phase C) + 3 | 3 + 11 = 44 |
| **⛔ GATE** | Verify all 35 FB | 44 (gate check) |
| **Session 4** | 4A + 4C | 15 FQ = 59 |
| **Session 5** | 4B + 4D | 12 FQ = 71 |
| **Session 6** | V | Verification pass |

**Optimistic:** 4 sessions (merge 1B into 1A, merge 2+3)
**Realistic:** 5–6 sessions
**Art generation runs in parallel — may iterate separately.**

---

*71 items. 6 waves. 4 same-class sweeps. 1 hard gate. Zero ambiguity.*

*The owl has a plan. The lion decides when to start.*
