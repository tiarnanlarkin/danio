# Wave 4 — Content Depth (Part 3): Equipment Path + Pea Puffer

**Subagent:** Pythia · **Date:** 2026-03-29

---

## Summary

Two tasks completed: equipment learning path restructured into a clear beginner → intermediate flow, and Pea Puffer added to the species database.

---

## FQ-C6: Equipment Learning Path Restructure

### Changes Made

**File:** `lib/data/lessons/equipment_expanded.dart`
**File:** `lib/providers/lesson_provider.dart`

#### New lesson order (11 lessons total)

| # | ID | Title | Level |
|---|-----|-------|-------|
| 0 | `eq_filters` | Choosing the Right Filter | Beginner |
| 1 | `eq_heaters` | Heater Selection and Safety | Beginner |
| 2 | `eq_lighting` | Lighting 101 | Beginner |
| 3 | `eq_test_kits` | Test Kits: Your Water Quality Dashboard | Beginner ← *moved up* |
| 4 | `eq_setup_guide` | Setting Up Your First Tank | Beginner ← **NEW** |
| 5 | `eq_filter_maintenance` | Filter Maintenance: Keeping the Biology Alive | Intermediate ← **NEW** |
| 6 | `eq_water_change_gear` | Water Change Equipment and Technique | Intermediate ← **NEW** |
| 7 | `eq_air_pumps` | Air Pumps & Aeration | Intermediate |
| 8 | `eq_co2_systems` | CO2 Systems: Pressurised vs DIY | Advanced |
| 9 | `eq_aquascape_tools` | Aquascaping Tools & Hardscape | Advanced |
| 10 | `eq_substrate` | Choosing Your Substrate | Intermediate |

#### Three new lessons added

**`eq_setup_guide` — Setting Up Your First Tank**
- Step-by-step from empty box to cycled aquarium
- Covers: rinse, substrate, hardscape, water fill, equipment installation, heater caution, planting, switching on, cycling
- Includes a comprehensive ✅ setup checklist
- 8 min · 75 XP · 4 quiz questions

**`eq_filter_maintenance` — Filter Maintenance: Keeping the Biology Alive**
- The golden rule of only cleaning when flow drops (not on schedule)
- HOB and canister maintenance procedures
- Why never to replace all media at once
- How to upgrade away from proprietary cartridges
- 6 min · 50 XP · 3 quiz questions

**`eq_water_change_gear` — Water Change Equipment and Technique**
- Siphon types (manual, pump-start, electric, Python)
- Manual siphon starting techniques
- Gravel vacuuming method and sand technique
- Dedicated bucket rule
- Dechlorinator comparison (Prime, Stress Coat, AquaSafe)
- Temperature matching and why it matters
- Python No Spill upgrade for larger tanks
- 6 min · 50 XP · 3 quiz questions

#### `eq_test_kits` repositioned
Moved from orderIndex 7 → 3 (right after the three core equipment lessons). A test kit is essential gear, not an advanced topic. Duplicate entry at the end of `equipment_expanded.dart` removed.

#### `lesson_provider.dart` updated
- `PathMetadata` for `equipment` now lists all 11 lesson IDs in correct order
- Path description updated to reflect beginner→advanced scope

---

## FQ-C7: Pea Puffer Added to Species Database

**File:** `lib/data/species_database.dart`

New entry appended under a `// Pufferfish` section comment at the end of `_allSpecies`.

### Key data points

| Field | Value |
|-------|-------|
| Common name | Pea Puffer (Dwarf Puffer) |
| Scientific name | *Carinotetraodon travancoricus* |
| Family | Tetraodontidae |
| Care level | Intermediate |
| Min tank | 30L |
| Temperature | 22–28°C |
| pH | 6.5–7.5 |
| GH | 5–15 |
| Min school size | 1 |
| Temperament | Aggressive |
| Diet | Carnivore — live/frozen only (snails, bloodworms, brine shrimp). No flake/pellet. |
| Adult size | 2.5 cm |
| Swim level | All |

### Medication warnings (5 entries)
1. Scaleless fish — highly sensitive to most medications
2. Never use copper-based treatments (fatal)
3. Half-dose most treatments
4. Avoid salt treatments — not freshwater-salt tolerant
5. Always research compatibility before treating

### Compatible with / Avoid
- `compatibleWith`: empty (species-only)
- `avoidWith`: any tank mates, shrimp, small fish, snails-as-pets

---

## Flutter Analyze Results

**6 issues found — all pre-existing, none introduced by this wave:**

| Level | File | Issue |
|-------|------|-------|
| error | `returning_user_flows.dart:431` | Undefined name `context` (pre-existing) |
| error | `golden_path_persistence_test.dart:69` | Undefined name `GemEarnReason` (pre-existing) |
| info | `tab_navigator_test.dart:8` | Package not in deps (pre-existing) |
| info | `tab_navigator_test.dart:9` | Package not in deps (pre-existing) |
| warning | `tab_navigator_test.dart:23` | Override on non-overriding member (pre-existing) |
| info | `tab_navigator_test.dart:64` | Could use super parameter (pre-existing) |

Zero new errors or warnings introduced.

---

## Files Modified

| File | Change |
|------|--------|
| `lib/data/lessons/equipment_expanded.dart` | Added 3 new lessons; moved `eq_test_kits` to position 3; removed duplicate; updated orderIndexes for CO2, aquascape, substrate |
| `lib/providers/lesson_provider.dart` | Updated `PathMetadata` for `equipment` — 11 lesson IDs, new description |
| `lib/data/species_database.dart` | Added Pea Puffer entry with full care data and medication warnings |

---

*Pythia — making the complex clear, one lesson at a time 🔮*
