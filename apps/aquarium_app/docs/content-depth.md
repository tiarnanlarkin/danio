# Danio — Content Depth

**Updated:** 2026-03-29
**Reference for:** All content work, lesson writing, species data

---

## Content Inventory

| Type | Count | Quality | Notes |
|------|-------|---------|-------|
| Learning paths | 12 | Strong | Well-structured progression |
| Lessons | 72 | 8/10 writing quality | Warm, knowledgeable, accurate |
| Quiz questions | 261 | Good | All multiple-choice. Plausible distractors. Explanations on all. |
| Stories | 6 | Excellent | 82 scenes, 110 choices, genuinely educational branching |
| Fish species | 125+ | Accurate | Scientific names correct, tank sizes realistic |
| Plants | 52 | Solid | No expansion needed |
| Workshop tools | 10 | Functional | Cycling Assistant and Compatibility Checker are standouts |

---

## Path Ratings (from Pythia truth pass)

| Path | Lessons | Rating | Notes |
|------|---------|--------|-------|
| Nitrogen Cycle | 6 | ⭐⭐⭐⭐⭐ | Best-in-class. Correctly names Nitrospira. |
| Your First Fish | 6 | ⭐⭐⭐⭐⭐ | |
| Water Parameters | 6 | ⭐⭐⭐⭐ | |
| Maintenance | 6 | ⭐⭐⭐⭐ | |
| Planted Tanks | 5 | ⭐⭐⭐⭐ | |
| Fish Health | 6 | ⭐⭐⭐⭐ | Locked behind Nitrogen Cycle (FB-S3) |
| Species Care | 13 (2 files) | ⭐⭐⭐⭐ | |
| Advanced Topics | 6 | ⭐⭐⭐⭐ | Contains ich safety issue (FB-S1) |
| Aquascaping | 4 | ⭐⭐⭐⭐ | |
| Equipment | 8 (2 files) | ⭐⭐⭐ | Structurally awkward split (FQ-C6) |
| Breeding | 3 | ⭐⭐⭐ | Thin. Livebearer content in wrong path. (FQ-C2) |
| Troubleshooting | 3 | ⭐⭐⭐ | Dangerously thin for emergency topic. (FQ-C1) |

---

## Content Safety Issues (Finish Blockers)

| ID | Issue | Fix Required |
|----|-------|-------------|
| FB-S1 | Ich treatment lesson tells ALL users 86°F/30°C — kills goldfish (max 24°C) | Add species-specific temperature guidance. Flag coldwater incompatibility. |
| FB-S2 | 5 Corydoras cards missing copper toxicity + salt sensitivity | Add safety warnings to species data |
| FB-S3 | Fish Health path locked behind Nitrogen Cycle completion | Remove or reduce prerequisite. Crisis users must access health content immediately. |
| FB-S4 | Dosing Calculator named for meds, built for fertilisers | Add prominent "NOT for medication dosing" warning |

---

## Content Gaps to Fill (Finish Quality)

| ID | What | Target |
|----|------|--------|
| FQ-C1 | Troubleshooting: expand 3→6 lessons | Add: power outage, temperature crash, pH crash |
| FQ-C2 | Breeding: expand 3→6 lessons | Move livebearer content from Advanced Topics |
| FQ-C3 | Medication dosing lesson | Copper toxicity, mixing warnings, proper dosing |
| FQ-C4 | QT tank size inconsistency | Pick 20L, update all references |
| FQ-C5 | ~54 American spellings in lesson data | Batch fix: color→colour, behavior→behaviour |
| FQ-C6 | Equipment path restructure | Merge or clearly sequence the split files |
| FQ-C7 | Add Pea Puffer to species DB | Popular, commonly mistreated |

---

## Content Quality Standards

- **Tone:** Warm, knowledgeable, like a real fishkeeper explaining to a friend
- **Accuracy:** Scientifically correct. Modern attributions (Nitrospira, not Nitrosomonas alone).
- **Spelling:** British English throughout. No American spellings in user-facing content.
- **Safety:** Any treatment/medication content must include species-specific warnings.
- **Depth:** Each path should have 5-6 lessons minimum. 3 is too thin for any topic.
- **Quiz questions:** Plausible distractors, always include explanation. Multiple-choice sufficient for v1.

---

## SRS System

Correctly implemented:
- SM-2 algorithm
- Exponential forgetting curve
- 5 mastery levels
- Intervals: 1→3→7→14→30 days (verified by Hephaestus)
- Per-card scheduling persists

Known issue: save errors swallowed silently (FB-T5), achievements bypass system (FB-O6).

---

## Gamification Economy

| Element | Earning | Spending | Status |
|---------|---------|----------|--------|
| XP | Lessons, activities, streaks | — | ✅ Works |
| Gems | ~8/day at normal pace | Shop items | ✅ Works (debounce gap: FB-T4) |
| Hearts | Regen over time (pull-based) | Lost on wrong quiz answer | ✅ Works |
| Streak Freeze | Shop purchase (10 gems) | Prevents streak reset | ✅ Verified |
| XP Boost | Shop purchase | Should double XP | 🔴 Broken for lessons (FB-H4) |
| Weekend Amulet | Shop purchase (20 gems) | Should adjust daily goal | 🔴 Complete no-op (FB-H3) |
