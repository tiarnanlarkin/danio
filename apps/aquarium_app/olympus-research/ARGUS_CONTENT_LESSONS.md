# ARGUS Content Audit: Lessons, Quizzes & Tips
**Generated:** 2026-03-16 06:27 GMT  
**Repo:** `/mnt/c/Users/larki/Documents/Danio Aquarium App Project/repo/apps/aquarium_app`  
**Source files:** `lib/data/lessons/*.dart` (9 canonical files) + `lib/data/daily_tips.dart`

---

## ⚠️ Architecture Note

There are **two lesson stores** in this codebase:

| File | Status | Lessons |
|------|--------|---------|
| `lib/data/lesson_content.dart` | **LEGACY** (212KB, flagged CLEANUP-001) | 50 `Lesson()` calls (largely mirrors the canonical files below) |
| `lib/data/lessons/*.dart` (9 files) | **CANONICAL** (lazy-loaded, active) | 50 lessons across 9 paths |
| `lib/providers/lesson_provider.dart` | Provider wiring the canonical files | — |

**The canonical files are the source of truth.** The legacy file is being retired. Counts below are from canonical files only.

---

## 📚 LESSON COUNT

### Summary Table

| Path | File | Lessons | Quizzes with Qs | Total Questions |
|------|------|---------|-----------------|-----------------|
| Nitrogen Cycle | `nitrogen_cycle.dart` | 6 | 6 | 24 |
| Water Parameters 101 | `water_parameters.dart` | 6 | 6 | 20 |
| Your First Fish | `first_fish.dart` | 6 | 6 | 26 |
| Tank Maintenance | `maintenance.dart` | 6 | 6 | 23 |
| Planted Tanks | `planted_tank.dart` | 5 | 5 | 18 |
| Equipment Guide | `equipment.dart` | 3 | 3 | 15 |
| Fish Health | `fish_health.dart` | 6 | 1 full + 5 stubs | 1 (+ 5 empty) |
| Species Care | `species_care.dart` | 6 | 0 full (all stubs) | 0 |
| Advanced Topics | `advanced_topics.dart` | 6 | 0 full (all stubs) | 0 |
| **TOTAL** | | **50 lessons** | **33 full quizzes** | **127 questions** |

---

## 📋 FULL LESSON LISTING (by path)

### PATH 1: Nitrogen Cycle 🔄 (6 lessons)
| # | ID | Title |
|---|----|----|
| 1 | `nc_intro` | What is the Nitrogen Cycle? |
| 2 | `nc_stages` | The 3 Stages: Ammonia → Nitrite → Nitrate |
| 3 | `nc_how_to` | How to Cycle Your Tank |
| 4 | `nc_testing` | Testing Your Water |
| 5 | `nc_spikes` | Cycle Emergency: Handling Spikes |
| 6 | `nc_minicycle` | Mini-Cycles: When Good Tanks Go Bad |

**Quiz questions:** nc_intro (3), nc_stages (3), nc_how_to (3), nc_testing (5), nc_spikes (5), nc_minicycle (5) = **24 total**

---

### PATH 2: Water Parameters 101 💧 (6 lessons)
| # | ID | Title |
|---|----|----|
| 1 | `wp_ph` | pH: Acid vs Alkaline |
| 2 | `wp_temp` | Temperature Control |
| 3 | `wp_hardness` | Water Hardness (GH & KH) |
| 4 | `wp_chlorine` | Chlorine vs Chloramine |
| 5 | `wp_tds` | Understanding TDS |
| 6 | `wp_seasonal` | Seasonal Water Challenges |

**Quiz questions:** wp_ph (2), wp_temp (1), wp_hardness (2), wp_chlorine (5), wp_tds (5), wp_seasonal (5) = **20 total**

---

### PATH 3: Your First Fish 🐠 (6 lessons)
| # | ID | Title |
|---|----|----|
| 1 | `ff_choosing` | Choosing Hardy Species |
| 2 | `ff_acclimation` | Bringing Fish Home |
| 3 | `ff_feeding` | Feeding 101: Less is More |
| 4 | `ff_behavior` | Reading Fish Behavior |
| 5 | `ff_quarantine` | Quarantine Tanks: Insurance Policy |
| 6 | `ff_mistakes` | Common Mistakes (And How to Avoid Them) |

**Quiz questions:** ff_choosing (4), ff_acclimation (2), ff_feeding (5), ff_behavior (5), ff_quarantine (5), ff_mistakes (5) = **26 total**

---

### PATH 4: Tank Maintenance 🧹 (6 lessons)
| # | ID | Title |
|---|----|----|
| 1 | `maint_water_changes` | Water Changes 101 |
| 2 | `maint_filter` | Filter Care |
| 3 | `maint_gravel_vac` | Gravel Vacuuming Mastery |
| 4 | `maint_algae` | Algae Control: The Battle |
| 5 | `maint_cleaning` | Safe Cleaning Techniques |
| 6 | `maint_schedule` | Your Maintenance Routine |

**Quiz questions:** maint_water_changes (1), maint_filter (2), maint_gravel_vac (5), maint_algae (5), maint_cleaning (5), maint_schedule (5) = **23 total**

---

### PATH 5: Planted Tanks 🌿 (5 lessons)
| # | ID | Title |
|---|----|----|
| 1 | `planted_basics` | Why Live Plants? |
| 2 | `planted_light` | Light & Nutrients |
| 3 | `planted_substrate` | Substrate: The Foundation |
| 4 | `planted_co2` | CO2: Is It Worth It? |
| 5 | `planted_propagation` | Plant Propagation: Growing Your Own |

**Quiz questions:** planted_basics (1), planted_light (2), planted_substrate (5), planted_co2 (5), planted_propagation (5) = **18 total**

---

### PATH 6: Equipment Guide ⚙️ (3 lessons)
| # | ID | Title |
|---|----|----|
| 1 | `eq_filters` | Choosing the Right Filter |
| 2 | `eq_heaters` | Heater Selection and Safety |
| 3 | `eq_lighting` | Lighting 101: What Fish Need |

**Quiz questions:** eq_filters (5), eq_heaters (5), eq_lighting (5) = **15 total**

> ⚠️ **CONTENT GAP:** Provider metadata lists 5 equipment lessons (`eq_filters`, `eq_heaters`, `eq_lighting`, `eq_air_pump`, `eq_substrate`) but only 3 exist in the file. 2 are missing.

---

### PATH 7: Fish Health 🏥 (6 lessons)
| # | ID | Title | Quiz Status |
|---|----|----|---|
| 1 | `fh_prevention` | Disease Prevention 101 | ✅ 1 question |
| 2 | `fh_ich` | Ich: The White Spot Killer | ⚠️ Empty (stub) |
| 3 | `fh_fin_rot` | Fin Rot & Bacterial Infections | ⚠️ Empty (stub) |
| 4 | `fh_fungal` | Fungal Infections | ⚠️ Empty (stub) |
| 5 | `fh_parasites` | Parasites: Identification & Treatment | ⚠️ Empty (stub) |
| 6 | `fh_hospital_tank` | Hospital Tank Setup | ⚠️ Empty (stub) |

**Quiz questions:** 1 real, 5 empty stubs = **1 usable question**

> ⚠️ **CONTENT GAP:** Fish Health path is largely stub content. Lessons exist but quiz questions are missing for 5/6 lessons. Lesson body content is also minimal for lessons 2–6.

---

### PATH 8: Species Care 🐟 (6 lessons)
| # | ID | Title | Quiz Status |
|---|----|----|---|
| 1 | `sc_betta` | Betta Fish Care | ⚠️ Empty stub |
| 2 | `sc_goldfish` | Goldfish: The Misunderstood Fish | ⚠️ Empty stub |
| 3 | `sc_tetras` | Tetras: Community Tank Stars | ⚠️ Empty stub |
| 4 | `sc_cichlids` | Cichlids: Personality Fish | ⚠️ Empty stub |
| 5 | `sc_shrimp` | Shrimp Keeping | ⚠️ Empty stub |
| 6 | `sc_snails` | Snails: Cleanup Crew | ⚠️ Empty stub |

**Quiz questions:** 0 (all stubs)

> ⚠️ **CONTENT GAP:** All Species Care lessons have stub content (1–2 LessonSections each) and empty quizzes. Content exists at structural level but needs full writing.

---

### PATH 9: Advanced Topics 🎓 (6 lessons)
| # | ID | Title | Quiz Status |
|---|----|----|---|
| 1 | `at_breeding_livebearers` | Breeding Basics: Livebearers | ⚠️ Empty stub |
| 2 | `at_breeding_egg_layers` | Breeding: Egg Layers | ⚠️ Empty stub |
| 3 | `at_aquascaping` | Aquascaping Fundamentals | ⚠️ Empty stub |
| 4 | `at_biotope` | Biotope Aquariums | ⚠️ Empty stub |
| 5 | `at_troubleshooting` | Troubleshooting: Emergency Guide | ⚠️ Empty stub |
| 6 | `at_water_chem` | Advanced Water Chemistry | ⚠️ Empty stub |

**Quiz questions:** 0 (all stubs)

---

## 🧠 QUIZ SUMMARY

| Metric | Count |
|--------|-------|
| Total quizzes | 50 (one per lesson) |
| Quizzes with real questions | 27 |
| Quizzes that are stubs (empty) | 23 |
| **Total real quiz questions** | **127** |
| Avg questions per full quiz | ~4.7 |

### Questions by Path (fully-fleshed paths only)
| Path | Questions |
|------|-----------|
| Nitrogen Cycle | 24 |
| Water Parameters | 20 |
| First Fish | 26 |
| Maintenance | 23 |
| Planted Tank | 18 |
| Equipment | 15 |
| Fish Health | 1 |
| Species Care | 0 |
| Advanced Topics | 0 |
| **TOTAL** | **127** |

---

## 💡 TIPS COUNT

**File:** `lib/data/daily_tips.dart`

| # | ID | Title |
|---|----|----|
| 1 | `tip_patience` | Patience Pays Off |
| 2 | `tip_test_regularly` | Test Your Water |
| 3 | `tip_less_food` | Less is More |
| 4 | `tip_observe` | Watch Your Fish |
| 5 | `tip_quarantine` | Quarantine New Fish |
| 6 | `tip_dechlorinator` | Always Dechlorinate |
| 7 | `tip_temperature_match` | Match Temperature |
| 8 | `tip_filter_media` | Don't Over-Clean |
| 9 | `tip_plant_timer` | Use a Light Timer |
| 10 | `tip_plant_ferts` | Start Low, Go Slow |
| 11 | `tip_trim_plants` | Trim Dead Leaves |
| 12 | `tip_stability` | Stability Over Perfection |
| 13 | `tip_research_first` | Research Before Buying |
| 14 | `tip_backup_heater` | Backup Equipment |
| 15 | `tip_water_change_routine` | Make It Routine |
| 16 | `tip_gravel_vac` | Vacuum That Gravel |
| 17 | `tip_slow_changes` | Slow and Steady |
| 18 | `tip_community` | Join the Community |
| 19 | `tip_enjoy` | Enjoy the Journey |
| 20 | `tip_hospital_tank` | Hospital Tank Ready |
| 21 | `tip_drip_acclimate` | Drip Acclimation |
| 22 | `tip_sand_substrate` | Sand vs Gravel |
| 23 | `tip_lid_jumpers` | Lid Your Tank |
| 24 | `tip_live_plants_help` | Plants Are Your Friends |
| 25 | `tip_avoid_direct_sun` | Sunlight = Algae |
| 26 | `tip_count_fish` | Count Your Fish Daily |
| 27 | `tip_api_shake` | Shake That Bottle! |
| 28 | `tip_cycle_patience` | The Hardest Part |
| 29 | `tip_snail_hitchhikers` | Check New Plants |
| 30 | `tip_indian_almond` | Tannin Power |
| 31 | `tip_overstock_warning` | Less is More (Fish) |

**Total tips: 31**

---

## 📅 DAYS OF CONTENT (at 1 lesson/day)

| Scenario | Lessons | Days |
|----------|---------|------|
| Fully-written lessons only (paths 1–6) | 32 | **32 days** |
| All lessons including stubs (paths 1–9) | 50 | **50 days** |
| All lessons + if stubs are completed | 50 | **50 days** |

> **Note:** At 1 lesson/day, the *fully-fleshed content* supports **32 days** of learning. If paths 7–9 (Fish Health, Species Care, Advanced Topics) had their stubs completed with full content, that rises to **50 days**.

---

## 🚨 CONTENT GAPS & RECOMMENDATIONS

### Critical Gaps

| Gap | Impact | Effort |
|-----|--------|--------|
| Fish Health: 5/6 quiz stubs + thin lesson bodies | Path feels broken | Medium |
| Species Care: All 6 lessons are stubs | Path non-functional | High |
| Advanced Topics: All 6 lessons are stubs | Path non-functional | High |
| Equipment: 2 lessons missing (`eq_air_pump`, `eq_substrate`) | Metadata/reality mismatch | Low |

### Quick Wins (to reach 50 fully-written lessons)
1. **Write 18 quiz sets** (5 questions each) for stubs = ~90 questions added
2. **Flesh out lesson bodies** for species care (6 lessons) and advanced topics (6 lessons)  
3. **Add 2 missing equipment lessons** (`eq_air_pump`, `eq_substrate`)

### Day-by-day content volume
- **Current state:** 32 full days (100% complete content), 50 total days (with stubs scaffolded)
- **Full completion state:** 50 complete days — nearly 7 weeks of daily lessons

---

## 📊 TOTALS AT A GLANCE

| Metric | Count |
|--------|-------|
| **Total Lessons** | **50** |
| **Fully-fleshed Lessons** | **32** |
| **Stub/Incomplete Lessons** | **18** |
| **Total Quizzes** | **50** (one per lesson) |
| **Quizzes with Real Questions** | **27** |
| **Total Quiz Questions** | **127** |
| **Total Daily Tips** | **31** |
| **Days of Content (full lessons)** | **32** |
| **Days of Content (all inc. stubs)** | **50** |
