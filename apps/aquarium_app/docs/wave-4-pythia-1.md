# Wave 4 — Content Depth (Part 1): Troubleshooting + Breeding
**Subagent:** Pythia  
**Date:** 2026-03-29  
**Status:** ✅ Complete

---

## What Was Done

### FQ-C1: Troubleshooting Path — 3 → 6 Lessons

Added 3 new lessons to `lib/data/lessons/troubleshooting.dart`:

| ID | Title | Order |
|----|-------|-------|
| `tr_power_outage` | Power Outage Recovery | 3 |
| `tr_temperature_crash` | Temperature Crash: Heater Failure | 4 |
| `tr_ph_crash` | pH Crash and Overnight Deaths | 5 |

**TR-4 — Power Outage Recovery**
- Covers: timeline of risk (1h → 8h+), immediate response (battery air pump first), equipment check on restoration, post-outage fish stress and disease monitoring.
- Key message: battery-powered air pump is the single most important emergency accessory.
- 3 quiz questions.

**TR-5 — Temperature Crash: Heater Failure**
- Covers: signs of heater failure, warming fish after a crash (1–2°C/hr max), dual-heater redundancy strategy, and the opposite problem (heater stuck ON).
- Includes warning about heaters overheating after power restoration.
- 3 quiz questions.

**TR-6 — pH Crash and Overnight Deaths**
- Covers: why pH crashes overnight in planted tanks (CO₂ / photosynthesis cycle), KH as the buffer, CO₂ injection timing, differential diagnosis for overnight deaths, and prevention (air stone on timer, KH top-up).
- Prerequisite: `wp_ph` (water parameters path) added alongside `tr_emergency`.
- 3 quiz questions.

---

### FQ-C2: Breeding Path — 3 → 6 Lessons

Added 3 new lessons to `lib/data/lessons/breeding.dart`:

| ID | Title | Order |
|----|-------|-------|
| `br_livebearers` | Livebearer Breeding: Guppies, Platys & Mollies | 3 |
| `br_fry_care` | Fry Care: Grow-Out and Health | 4 |
| `br_rehoming` | Separating Fry and Responsible Rehoming | 5 |

**BR-4 — Livebearer Breeding (livebearer content moved from advanced_topics)**
- Content based on `at_breeding_livebearers` in `advanced_topics.dart`, expanded for a beginner audience.
- Covers: male:female ratios, recognising gravid females, squaring-off, breeding box vs dense planting, fry feeding, basic guppy colour genetics, female sperm storage, and responsible disposal of surplus fry.
- Prerequisite: `br_breeding_tank` (accessible to beginners in the breeding path).
- 3 quiz questions.

**BR-5 — Fry Care: Grow-Out and Health**
- Covers: grow-out tank setup, varied diet for maximum growth rate, daily water changes in fry tanks, size-grading at 3–4 weeks, and humane culling of deformed fry.
- 3 quiz questions.

**BR-6 — Separating Fry and Responsible Rehoming**
- Covers: when to move fry to the community tank by species type, rehoming options (LFS, aquarium clubs, online classifieds, fish swaps), responsible disposal of surplus, bagging and transporting fry safely.
- Strong warning section on the illegality of wild release.
- 3 quiz questions.

---

### Cross-Path Fix

- **`br_egg_layers` prerequisite cleaned up**: was `at_breeding_egg_layers` (cross-path reference to an advanced topics lesson). Changed to `br_raising_fry` — keeping all breeding path prerequisites internal to the breeding path.

### `lesson_provider.dart` — PathMetadata Updated

Both paths updated in `allPathMetadata`:

```dart
// breeding_basics — now 6 lessons
lessonIds: [
  'br_breeding_tank', 'br_raising_fry', 'br_egg_layers',
  'br_livebearers', 'br_fry_care', 'br_rehoming',
],

// troubleshooting — now 6 lessons
lessonIds: [
  'tr_emergency', 'tr_disease_diagnosis', 'tr_cloudy_water',
  'tr_power_outage', 'tr_temperature_crash', 'tr_ph_crash',
],
```

### Note on `at_breeding_livebearers`
The original `at_breeding_livebearers` lesson in `advanced_topics.dart` was **left in place** (not deleted). Removing it would break existing user progress records for anyone who has already completed it. The new `br_livebearers` in the breeding path serves beginners with the same content, expanded for a beginner audience.

---

## Flutter Analyze Results

**7 issues found — 0 related to wave-4 changes.**

Pre-existing issues only:
- `returning_user_flows.dart:431` — `undefined_identifier` for `context` (pre-existing)
- `warm_entry_screen.dart:418` — `undefined_identifier` for `GoogleFonts` (pre-existing)
- `golden_path_persistence_test.dart:69` — `undefined_identifier` for `GemEarnReason` (pre-existing, test file)
- `tab_navigator_test.dart` — 3 info/warning items (pre-existing, test file)

No new errors introduced by this wave.

---

## Files Modified

| File | Change |
|------|--------|
| `lib/data/lessons/troubleshooting.dart` | +3 lessons (TR-4, TR-5, TR-6) |
| `lib/data/lessons/breeding.dart` | +3 lessons (BR-4, BR-5, BR-6); fixed BR-3 prerequisite |
| `lib/providers/lesson_provider.dart` | Updated PathMetadata lessonIds for both paths |

---

## Content Summary

- **Troubleshooting path**: 6 lessons covering emergency response, disease diagnosis, cloudy water, power outages, heater failure, and pH crashes.
- **Breeding path**: 6 lessons covering breeding tank setup, raising fry, egg-layer techniques, livebearer breeding, fry grow-out, and responsible rehoming.
- Total new lessons added: **6**
- Total quiz questions added: **18** (3 per lesson)
