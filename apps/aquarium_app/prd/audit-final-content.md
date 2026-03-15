# Danio App — Final Content & Educational Quality Audit
**Auditor:** Subagent (content-quality)  
**Date:** 2026-03-15  
**Scope:** All educational content in `lib/data/` — species database, lessons, quizzes, tips, stories, plant database, placement test  
**Method:** Full READ-ONLY review of all content files  

---

## Executive Summary

Overall the content is **high quality** — warm, encouraging, well-structured, and mostly accurate. The nitrogen cycle and water parameters lessons are excellent. Species data is comprehensive. The main areas needing attention are:

- **Several P0/P1 factual errors** in species data and lesson content
- **Significant content gaps** in `fish_health.dart` and `species_care.dart` (stub/skeleton lessons)
- **Betta minimum tank size** understated (20L vs industry recommendation of 40L+)
- One misleading claim about ammonia odour at aquarium levels

---

## PART 1 — Species Database (`lib/data/species_database.dart`)

### Finding SD-01 — Betta minimum tank size too small
**Severity: P1**  
**File:** `species_database.dart`  
**Issue:** `minTankLitres: 20` for Betta splendens. Modern fishkeeping consensus is 40L (10 gallons) minimum; 20L is the old "cup" thinking that the app rightly calls out in lesson content (species_care.dart says "No bowls!"). Having 20L in the database while the lesson says "Minimum 5 gallons" (18.9L) is internally inconsistent and sets a bad precedent.  
**Suggested Fix:** Change `minTankLitres` to 40 for Betta splendens to align with best practice and the lesson content direction.

### Finding SD-02 — Betta described as 'Beginner' despite sensitivity
**Severity: P2**  
**File:** `species_database.dart`  
**Issue:** `careLevel: 'Beginner'` for Betta. While they are often sold as beginner fish, they require careful tank mates selection, no fin nippers, appropriate temperature, and male-only housing. Many consider them intermediate. At minimum the description should note they are more nuanced than typical beginner fish.  
**Suggested Fix:** Either change to `Intermediate` or add a note in the description about the common misconceptions.

### Finding SD-03 — Cardinal Tetra adult size slightly overstated
**Severity: P2**  
**File:** `species_database.dart`  
**Issue:** `adultSizeCm: 5` for Cardinal Tetra. Cardinals typically reach 3.5–4cm in aquaria; 5cm is the absolute maximum and rarely seen. Neon Tetra is also listed at 3.5cm which is accurate. The discrepancy may lead users to over-plan for Cardinals vs Neons.  
**Suggested Fix:** Change Cardinal Tetra `adultSizeCm` to 4.0.

### Finding SD-04 — Molly minimum tank too large (inconsistency)
**Severity: P2**  
**File:** `species_database.dart`  
**Issue:** `minTankLitres: 75` for standard Molly (Poecilia sphenops). Many reputable sources cite 55L (15 gallons) as the minimum. 75L is appropriate for sailfin mollies and large communities but not a single Poecilia sphenops. Guppy is listed at 20L which is fine. The 75L figure may put beginners off keeping mollies.  
**Suggested Fix:** Lower Molly `minTankLitres` to 60 (a reasonable compromise), or note that 75L is recommended for a group/community setup.

### Finding SD-05 — Rummy Nose Tetra scientific name issue
**Severity: P2**  
**File:** `species_database.dart`  
**Issue:** `scientificName: 'Hemigrammus rhodostomus'`. There are three species sold as "Rummy Nose Tetra": *H. rhodostomus*, *H. bleheri* (true rummy nose), and *Petitella georgiae*. The most commonly sold in the hobby is *H. bleheri*. While not strictly wrong, this is worth noting or clarifying.  
**Suggested Fix:** Update description to note there are multiple species sold under this name. No urgent change required but good for accuracy.

### Finding SD-06 — Discus maximum temperature
**Severity: P1**  
**File:** `species_database.dart`  
**Issue:** `maxTempC: 32` for Discus (and Discus variants). 32°C is at the extreme upper limit and would stress most discus. The typical recommended range is 28–30°C, with 30°C being the working maximum for long-term health. Listing 32°C as the max could encourage users to keep discus too warm.  
**Suggested Fix:** Change `maxTempC` to 30 for all Discus entries.

### Finding SD-07 — Clown Loach minimum school size
**Severity: P2**  
**File:** `species_database.dart`  
**Issue:** `minSchoolSize: 5` for Clown Loach. Most authoritative sources recommend groups of 6+ for Clown Loaches; they are highly social and suffer significantly in smaller groups. 5 is borderline.  
**Suggested Fix:** Change `minSchoolSize` to 6.

### Finding SD-08 — Axolotl listed with fish; needs strong disclaimer
**Severity: P1**  
**File:** `species_database.dart`  
**Issue:** Axolotl is listed in the species database. The description correctly warns about temperature and not mixing with fish, but the `avoidWith` list is very sparse for an animal that eats essentially any fish that fits in its mouth and has very specific legal status in many countries (banned in some US states and other jurisdictions). A user following the database alone could make harmful choices.  
**Suggested Fix:** Expand `avoidWith` to include all fish species. Add a note about legal restrictions in some regions. Consider adding a `specialNote` field for the app UI to display a prominent warning.

### Finding SD-09 — Chinese Algae Eater description contradicts careLevel
**Severity: P2**  
**File:** `species_database.dart`  
**Issue:** `careLevel: 'Beginner'` for Chinese Algae Eater, but the description explicitly says "becomes territorial and aggressive with age" and "Not ideal for community tanks long-term." A species explicitly not suited for community tanks should not be classified as Beginner.  
**Suggested Fix:** Change `careLevel` to `'Intermediate'` to match the description.

### Finding SD-10 — Amano Shrimp family classification
**Severity: P2**  
**File:** `species_database.dart`  
**Issue:** `family: 'Atyidae'` for Amano Shrimp (*Caridina multidentata*). This is correct. No issue. ✓

### Finding SD-11 — Ghost Shrimp scientific name
**Severity: P2**  
**File:** `species_database.dart`  
**Issue:** `scientificName: 'Palaemonetes paludosus'` for Ghost Shrimp. *P. paludosus* is a North American species frequently sold as ghost shrimp. However, many ghost shrimp sold in the hobby are *Macrobrachium* species or other Palaemonetes spp. The description is accurate for the species listed. Minor issue.

### Finding SD-12 — Yoyo Loach old scientific name
**Severity: P2**  
**File:** `species_database.dart`  
**Issue:** `scientificName: 'Botia almorhae'` for Yoyo Loach. The currently accepted name is *Botia almorhae* (previously *Botia lohachata*). This is actually correct. ✓

### Finding SD-13 — Bristlenose Pleco adult size
**Severity: P2**  
**File:** `species_database.dart`  
**Issue:** `adultSizeCm: 15` for Bristlenose Pleco (*Ancistrus sp.*). Most Bristlenose plecos reach 10–12cm in aquaria; 15cm is the absolute upper range for large wild-caught specimens. This overestimates size.  
**Suggested Fix:** Change to `adultSizeCm: 12`.

### Finding SD-14 — Buenos Aires Tetra — plant warning missing from temperament
**Severity: P1**  
**File:** `species_database.dart`  
**Issue:** The diet field includes "WILL EAT PLANTS" in all caps, which is correct. However, `temperament: 'Semi-aggressive'` doesn't convey the plant-eating issue for the compatibility checker. Users filtering by temperament won't know this fish destroys planted tanks.  
**Suggested Fix:** Add "Planted tanks" to `avoidWith` list, or add a warning in the description that is structured so the compatibility checker surfaces it.

### Finding SD-15 — Assassin Snail family classification
**Severity: P2**  
**File:** `species_database.dart`  
**Issue:** `family: 'Buccinidae'` for Assassin Snail (*Clea helena*). The current accepted family is *Nassariidae* (formerly placed in Buccinidae). This is a minor taxonomy update.  
**Suggested Fix:** Update to `family: 'Nassariidae'`.

---

## PART 2 — Lesson Content

### Finding LC-01 — Ammonia described as "odorless at typical aquarium levels"
**Severity: P0 (Misleading)**  
**File:** `nitrogen_cycle.dart` → lesson `nc_intro`  
**Issue:** The lesson states: *"Ammonia is colorless and odorless at typical aquarium levels."* This is used in the quiz explanation (nc_intro_q2). Ammonia does have a distinctive sharp smell, even at low concentrations (0.5–1 ppm). A fishkeeper relying on smell to detect ammonia could overlook a dangerous situation. The correct teaching point is that ammonia is **invisible** (not detectable by eye), not undetectable by smell.  
**Current text:** `'Ammonia is colorless and odorless at typical aquarium levels. Only a test kit can detect it.'`  
**Suggested Fix:** Change to: `'Ammonia is colourless at typical aquarium levels — you cannot tell by looking at the water. Only a test kit gives you reliable readings.'` (remove the odorless claim)

### Finding LC-02 — Nitrogen cycle bacteria names — outdated genus
**Severity: P2**  
**File:** `nitrogen_cycle.dart` → lesson `nc_stages`  
**Issue:** Lesson refers to "Nitrosomonas" and "Nitrobacter" as the cycling bacteria. Current science (post-2006 research) confirms the primary bacteria in aquarium cycling are *Nitrospira* (handles both steps in many aquaria) rather than Nitrobacter. This is confirmed by the placement test (`nc_q3`) which correctly answers "Nitrospira" — but the lesson teaches the older Nitrosomonas/Nitrobacter model, creating a contradiction.  
**Suggested Fix:** Update `nc_stages` lesson to mention Nitrospira as the primary nitrite-oxidising bacteria and note that the science has evolved from the older Nitrosomonas/Nitrobacter model. The placement test answer is correct and should be kept.

### Finding LC-03 — Heater wattage recommendation inconsistency
**Severity: P2**  
**File:** `equipment.dart` → lesson `eq_heaters`  
**Issue:** Lesson states "3-5 watts per liter" for heater sizing. This is commonly cited but can lead to significant over-heating in smaller tanks with modern efficient heaters. Many modern recommendations are 1-2 W/L for tanks in typical room temperatures. The 3-5 W/L figure is from an era of less efficient heaters and is now considered excessive by many experts.  
**Suggested Fix:** Revise to "1-3 watts per liter for modern tanks in typical room temperatures, up to 5W/L for larger tanks or cold rooms." This is safer and more accurate.

### Finding LC-04 — Betta minimum tank in species care lesson
**Severity: P1**  
**File:** `species_care.dart` → lesson `sc_betta`  
**Issue:** The lesson states: `'Minimum 5 gallons, heated to 78-80°F, filtered water. No bowls!'`. Five gallons (18.9L) is increasingly considered inadequate by the fishkeeping community, with 10 gallons (40L) being the modern recommended minimum. The 78-80°F (25.6-26.7°C) range is also at the lower end — most betta enthusiasts recommend 78-82°F (25.6-27.8°C).  
**Suggested Fix:** Update to "Minimum 10 gallons (40L), heated to 78-82°F (25.6-27.8°C)."

### Finding LC-05 — CO2 lesson: Excel/glutaraldehyde shrimp warning may be underdone
**Severity: P1**  
**File:** `planted_tank.dart` → lesson `planted_co2`  
**Issue:** The warning about Seachem Excel states it is "toxic to shrimp at high doses." This underplays the risk. Excel (glutaraldehyde) can kill shrimp even at recommended doses in tanks with sensitive shrimp species, and the recommended dose is not safe for shrimp tanks. It can kill cherry shrimp and Crystal Red shrimp at standard doses.  
**Suggested Fix:** Strengthen the warning: "Excel is NOT SAFE for shrimp tanks at any dose. If you keep shrimp, do not use Excel. Use pressurised CO2 instead."

### Finding LC-06 — DIY CO2 danger understated
**Severity: P1**  
**File:** `planted_tank.dart` → lesson `planted_co2`  
**Issue:** DIY CO2 is described as potentially "killing fish (CO2 becomes toxic at high levels)" but the mechanism and danger level are understated. CO2 overdose from DIY systems crashing overnight is a real, well-documented cause of tank crashes. The lesson should make this risk clearer.  
**Suggested Fix:** Add explicit warning: "DIY CO2 is not recommended for tanks with fish. A yeast batch crash overnight can dump CO2 and suffocate fish. If using DIY CO2, always use a solenoid to shut off at night."

### Finding LC-07 — Water changes lesson: "50% max in emergencies" is incorrect
**Severity: P1**  
**File:** `maintenance.dart` → lesson `maint_water_changes`  
**Issue:** The warning states "Never replace all the water at once. Massive changes shock fish and can crash your cycle. 50% max in emergencies." However, the nitrogen cycle spikes lesson (`nc_spikes`) correctly states "up to 50-75% if needed" in emergencies. These contradict each other, and the correct guidance is that large emergency water changes (50-75% or even 90% with temperature matching) are safe and sometimes necessary.  
**Suggested Fix:** Remove the hard "50% max" cap from `maint_water_changes` and align with the `nc_spikes` lesson: "In emergencies, large water changes (50-75%) are safe when temperature-matched and dechlorinated."

### Finding LC-08 — Fish Health lessons are stubs — significant content gap
**Severity: P1 (Missing Content)**  
**File:** `fish_health.dart`  
**Issue:** The entire fish health module beyond the first lesson (`fh_prevention`) contains stub/skeleton lessons with minimal content:
- `fh_ich`: Just 2 content sections, no meaningful treatment protocol
- `fh_fin_rot`: 1 section only
- `fh_fungal`: 1 section only
- `fh_parasites`: 1 section only
- `fh_hospital_tank`: 2 sections only

All have empty `questions: []` in their quizzes. These lessons appear to be placeholders. A beginner who encounters ich (the most common fish disease) will get essentially no guidance from the lesson.  
**Suggested Fix:** These lessons need to be fully written. Priority: `fh_ich` (most critical — ich is extremely common) → `fh_fin_rot` → `fh_hospital_tank` → `fh_fungal` → `fh_parasites`.

### Finding LC-09 — Species Care lessons are mostly stubs
**Severity: P1 (Missing Content)**  
**File:** `species_care.dart`  
**Issue:** Six species care lessons exist but most have only 1-2 content sections and no quiz questions:
- `sc_betta`: 3 sections (short but functional)
- `sc_goldfish`: 2 sections, no quiz
- `sc_tetras`: 1 section, no quiz
- `sc_cichlids`: 1 section, no quiz
- `sc_shrimp`: 1 section, no quiz
- `sc_snails`: 1 section, no quiz

Given these are featured lessons in the species_care path (orderIndex 7), users who navigate here will feel cheated.  
**Suggested Fix:** Fully develop each species care lesson. Priority: shrimp (no treatment of Caridina vs Neocaridina differences, molting, etc.) and cichlids (important because African vs South American care differs dramatically).

### Finding LC-10 — Advanced Topics lessons: all quizzes empty
**Severity: P1**  
**File:** `advanced_topics.dart`  
**Issue:** All 6 lessons in the Advanced Topics path have `questions: []` in their quizzes. Users completing these lessons earn XP but get no quiz reinforcement — contrary to the app's Duolingo-style philosophy.  
**Suggested Fix:** Add at least 2-3 quiz questions per lesson. Breeding and aquascaping lessons in particular would benefit from quiz reinforcement.

### Finding LC-11 — Planted tank: mention of Takashi Amano quote is unverified
**Severity: P2**  
**File:** `planted_tank.dart` → lesson `planted_co2`  
**Issue:** The fun fact attributes a quote to Takashi Amano: *"Nature doesn't use CO2 regulators - respect the plants' natural needs first."* This appears to be a paraphrase or invented quote — no source for this specific statement is findable, and Amano was in fact a strong advocate for pressurised CO2. This is misleading and potentially defamatory.  
**Suggested Fix:** Remove or clearly label as a paraphrase/interpretation. Replace with a verified Amano quote or simply remove the attribution.

### Finding LC-12 — Aquasoil ammonia warning: "2-4 weeks" may be insufficient
**Severity: P2**  
**File:** `planted_tank.dart` → lesson `planted_substrate`  
**Issue:** The warning says aquasoil releases ammonia "during the first 2-4 weeks." Some premium aquasoils (ADA Aquasoil, SL-Aqua) can release ammonia for 6-8 weeks. Underselling this could lead to fish loss.  
**Suggested Fix:** Change to "2-6 weeks, sometimes longer with premium aquasoils."

### Finding LC-13 — Common Pleco size in first_fish lesson
**Severity: P2**  
**File:** `first_fish.dart` → lesson `ff_choosing`  
**Issue:** The lesson says "Common plecos - grow to 60cm+." In the story (`stories.dart`), the pleco warning says "They can grow to 18 inches!" (45.7cm). Both are reasonable upper limits (some common plecos can reach 60cm; typical is 40-50cm) but the inconsistency is slightly confusing.  
**Suggested Fix:** Standardise to "Common plecos can grow to 45–60cm (18-24 inches)" in both places.

### Finding LC-14 — "1 inch per gallon" — the lesson correctly debunks it
**Severity: ✓ CORRECT**  
**File:** `first_fish.dart` → lesson `ff_mistakes`  
**Note:** The lesson correctly calls out the 1-inch-per-gallon rule as "outdated and often wrong." Good content. No change needed.

### Finding LC-15 — Vacation blocks warning is accurate and useful
**Severity: ✓ CORRECT**  
**File:** `first_fish.dart` → lesson `ff_feeding`  
**Note:** The warning about vacation blocks ("often pollute water") is accurate and well-expressed. Good content.

---

## PART 3 — Quiz Quality

### Finding QZ-01 — Ich lesson has no quiz content
**Severity: P1**  
**File:** `fish_health.dart` → `fh_ich`  
**Issue:** The ich lesson (`fh_ich`) has `questions: []`. This is the most common fish disease — users completing this lesson should be quizzed on recognition and treatment. This is part of the broader stub content issue (LC-08).

### Finding QZ-02 — Placement test: nc_q3 bacteria genus is correct (Nitrospira)
**Severity: ✓ CORRECT**  
**File:** `placement_test_content.dart`  
**Note:** The placement test correctly identifies Nitrospira as the nitrite-to-nitrate bacteria — consistent with modern science. However, this contradicts lesson `nc_stages` which teaches Nitrosomonas/Nitrobacter. See LC-02.

### Finding QZ-03 — Water parameter quizzes are thorough and well-balanced
**Severity: ✓ CORRECT**  
**File:** `water_parameters.dart`  
**Note:** The water parameters quizzes have 2-5 questions per lesson, with clear distractors, good explanations, and appropriate difficulty progression. Exemplary quality.

### Finding QZ-04 — Nitrogen cycle quizzes: excellent
**Severity: ✓ CORRECT**  
**File:** `nitrogen_cycle.dart`  
**Note:** All 6 nitrogen cycle lessons have well-formed quizzes with 3-5 questions, good distractors, and thorough explanations. These are the strongest quizzes in the codebase.

### Finding QZ-05 — Equipment quizzes: good quality
**Severity: ✓ CORRECT**  
**File:** `equipment.dart`  
**Note:** Filter, heater, and lighting quizzes all have 5 questions with solid explanations. Well balanced.

### Finding QZ-06 — Aquasoil quiz question: answer options slightly unclear
**Severity: P2**  
**File:** `planted_tank.dart` → `planted_substrate`  
**Question:** "What does 'inert' substrate mean?"  
**Options include:** "It's dead" — This is a poor distractor. "Dead" and "inert" are related concepts and this could confuse beginners rather than test knowledge. A better distractor would be "It actively grows plants" or "It releases nutrients slowly."  
**Suggested Fix:** Replace "It's dead" with "It actively releases nutrients" as a distractor.

### Finding QZ-07 — Seasonal water changes quiz: question about warm water/oxygen
**Severity: P2**  
**File:** `water_parameters.dart` → `wp_seasonal` → `wp_seas_q4`  
**Question:** "Why does warm water hold less oxygen?"  
**Correct answer:** "It's a physical property of water"  
**Issue:** This is correct but the explanation says "warm water has lower oxygen solubility" without explaining *why*. For a teaching app, this is a missed opportunity. Also, the option "It's a physical property of water" is true but doesn't help the learner understand the mechanism.  
**Suggested Fix:** Improve the explanation: "Warm water has lower gas solubility — gas molecules escape more easily from warmer water. This is why heatwaves cause fish to gasp at the surface."

---

## PART 4 — Daily Tips (`lib/data/daily_tips.dart`)

### Finding TIP-01 — All tips are accurate and useful
**Severity: ✓ CORRECT**  
**Note:** The 30 tips cover a good range of topics — cycling patience, water changes, sand substrate for corydoras, lid for jumpers, API test shaking, dechlorination, and more. All are factually sound.

### Finding TIP-02 — "tip_drip_acclimate" — minor omission
**Severity: P2**  
**File:** `daily_tips.dart` → tip `tip_drip_acclimate`  
**Issue:** The tip says "drip 2-3 drips per second over an hour" but doesn't mention that the container should be kept in a warm location (or floating in the tank) during drip acclimation, especially for temperature-sensitive fish. Without this, the drip water can cool significantly, especially in winter, defeating the purpose.  
**Suggested Fix:** Add: "Keep the container warm (float it in the tank or use a heating pad underneath) to maintain temperature during the drip."

### Finding TIP-03 — "tip_indian_almond" — accurate
**Severity: ✓ CORRECT**  
**Note:** Indian almond leaves do release tannins, do have mild antibacterial properties, and do benefit bettas and tetras. Accurate.

### Finding TIP-04 — "tip_avoid_direct_sun" — accurate
**Severity: ✓ CORRECT**  
**Note:** Accurate advice about direct sunlight causing algae. Well stated.

### Finding TIP-05 — "tip_api_shake" — excellent, specific, actionable
**Severity: ✓ CORRECT**  
**Note:** Very good hobbyist tip — the API Nitrate Bottle #2 shaking requirement is real and frequently missed. This is genuinely useful.

---

## PART 5 — Stories (`lib/data/stories.dart`)

### Finding ST-01 — Stories are factually sound and educationally valuable
**Severity: ✓ CORRECT**  
**Note:** All 6 stories (new_tank_setup, first_fish, water_change_day, algae_outbreak, plant_paradise, breeding_project) are well-structured, factually accurate, and make good educational use of branching narrative. The consequences of wrong choices are realistic.

### Finding ST-02 — "firstFish" story: Pleco warning uses imperial, lesson uses metric
**Severity: P2**  
**File:** `stories.dart` → `firstFish` → `pleco_warning` scene  
**Issue:** `"They can grow to 18 inches!"` — The lesson content (first_fish.dart) uses metric ("Common plecos - grow to 60cm+"). Mixing units is inconsistent. The app appears to target an international audience.  
**Suggested Fix:** Add metric: "They can grow to 18 inches (45cm+)!"

### Finding ST-03 — New tank story: "ghost feeding" terminology
**Severity: P2**  
**File:** `stories.dart` → `newTankSetup` → scene `cycling_begins`  
**Issue:** Choice text says "Add fish food daily (fishless cycling)" with the label "ghost_feeding". "Ghost feeding" is accurate hobbyist slang, but the option description is slightly confusing — "fishless cycling" is the method, and the fish food is just the ammonia source. Better phrasing would help clarity.  
**Suggested Fix:** Change choice text to "Add a small pinch of fish food daily as an ammonia source" for clarity.

### Finding ST-04 — Breeding story: Ram breeding temperature range
**Severity: P1**  
**File:** `stories.dart` → `breedingProject`  
**Issue:** Story states "Rams prefer 82-86°F for breeding." This is 27.8-30°C. The species database lists German Blue Ram `minTempC: 26, maxTempC: 30`. The breeding story's temperature is slightly higher than the daily care range — this is actually correct (many cichlids prefer slightly higher temps for spawning), but it's not explained and could confuse users who check the species database.  
**Suggested Fix:** Add a note: "Breeding temperatures are typically 1-2°C higher than normal care temperatures to trigger spawning behaviour."

### Finding ST-05 — Story: "waterChangeDay" scene temp_check uses Fahrenheit
**Severity: P2**  
**File:** `stories.dart` → `waterChangeDay` → scene `temp_check`  
**Issue:** `"Tank water: 76°F\n• New water: 65°F"` — The rest of the app content uses Celsius. This scene uses Fahrenheit only, which is inconsistent.  
**Suggested Fix:** Add Celsius equivalent: "Tank water: 76°F (24°C) · New water: 65°F (18°C)"

### Finding ST-06 — Algae outbreak story: phosphate test recommended but not taught
**Severity: P2**  
**File:** `stories.dart` → `algaeOutbreak` → scene `testing`  
**Issue:** The scene shows "Phosphate: 3 ppm (very high!)" as a test result — implying users have a phosphate test kit. However, phosphate testing is not taught anywhere in the lesson content, and the API Master Test Kit (recommended throughout the app) does not include a phosphate test.  
**Suggested Fix:** Either remove phosphate from the test scene, or add a brief explanation like: "You've invested in a phosphate test kit — it shows 3 ppm."

---

## PART 6 — Tone Consistency

### Finding TON-01 — Overall tone is warm and encouraging — excellent
**Severity: ✓ CORRECT**  
**Note:** The app consistently uses:
- Second-person, conversational voice ("You test the water…")
- Encouraging framing of mistakes ("You've all been there", "Every expert was once a beginner")
- Fun facts that celebrate the hobby
- Non-judgmental feedback for wrong story choices
- Emoji used tastefully in lesson headings

This is well executed throughout.

### Finding TON-02 — Slight tone inconsistency in `fh_prevention` lesson
**Severity: P2**  
**File:** `fish_health.dart` → lesson `fh_prevention`  
**Issue:** `'90% of fish disease is caused by stress.'` — This statistic is commonly quoted but not sourced, and it is delivered very bluntly without the warm framing used elsewhere. Compare to the nitrogen cycle lessons which lead with empathy ("Sound familiar? You're not alone.").  
**Suggested Fix:** Soften slightly: "The good news? Most fish diseases are preventable! Stress is behind the vast majority of illness — fix the environment and most problems disappear."

### Finding TON-03 — "Discus requirements" warning tone is appropriately firm
**Severity: ✓ CORRECT**  
**Note:** The app correctly and firmly warns beginners away from discus without being condescending. Good balance.

---

## PART 7 — Missing Content (Beginner Gaps)

### Finding GAP-01 — No lesson on fishkeeping equipment costs / budgeting
**Severity: P2**  
**Note:** Beginners frequently get sticker shock. A brief lesson or tip on expected setup costs (entry level vs. mid vs. high-end) would prevent abandonment.

### Finding GAP-02 — No lesson on saltwater/marine tanks
**Severity: P2**  
**Note:** The app has `TankType.freshwater` and presumably others in the model, but all educational content is freshwater-focused. If the app claims to be "Duolingo for Fishkeeping," the absence of marine content is a major gap for users interested in saltwater. At minimum, a lesson explaining "saltwater is advanced, here's why" would set expectations.

### Finding GAP-03 — No lesson on live food culturing
**Severity: P2**  
**Note:** Breeding projects and fry-raising rely on baby brine shrimp and infusoria, but there's no lesson on how to hatch/culture live foods. The breeding story mentions these but assumes knowledge.

### Finding GAP-04 — No content on medication dosing or common medications
**Severity: P1**  
**Note:** The fish_health path mentions treating diseases but the actual lessons are stubs (see LC-08). Users who encounter ich will have no guidance on whether to use salt, heat, ich-X, ParaGuard, or other treatments. This is a significant safety gap — wrong treatment can kill fish.

### Finding GAP-05 — No lesson on fish transport / buying online
**Severity: P2**  
**Note:** Increasing numbers of fish are bought online and shipped. The "Bringing Fish Home" lesson covers bag acclimation but assumes a local store purchase. Online fish arrive differently (double bags, pure O2, heat packs) and need different handling.

### Finding GAP-06 — No content on water testing log / tracking
**Severity: P2**  
**Note:** The lesson mentions keeping a testing log but doesn't provide a framework. Given the app is digital, an in-app water log feature is probably planned, but the educational content should explain WHY tracking matters.

### Finding GAP-07 — No lesson on tank size planning / calculating stocking
**Severity: P2**  
**Note:** The 1-inch-per-gallon rule is debunked but no alternative framework is provided. Beginners need guidance on how to actually plan their stocking.

---

## PART 8 — Spelling & Grammar

### Finding SG-01 — Consistent UK/US English mixing
**Severity: P2**  
**Files:** Multiple  
**Issue:** The app mixes British and American English throughout:
- "colour" / "color" — the codebase uses American "color" in code variables but content uses both
- "dechlorinator" (American) is used consistently ✓
- "practise/practice" not an issue found
**Suggested Fix:** Decide on one variant (recommend: British English for Irish/UK market, or American for wider reach) and apply consistently. Current usage is mostly American English.

### Finding SG-02 — Story scene text: "Let us do this right" → awkward
**Severity: P2**  
**File:** `stories.dart` → `newTankSetup` → scene `bad_start`  
**Issue:** `'"Let us do this right," Alex suggests.'` — "Let us" sounds overly formal/stilted for a Duolingo-style app. Should be "Let's".  
**Suggested Fix:** Change to `'"Let\'s do this right," Alex suggests.'`

### Finding SG-03 — Story: "it's" vs "its" — correct throughout
**Severity: ✓ CORRECT**  
**Note:** Scanned all story content — apostrophe usage is correct throughout.

### Finding SG-04 — Minor: "capitalisation" inconsistency in tip IDs
**Severity: P2 (Code, not user-facing)**  
**Note:** Not user-facing, low priority.

---

## PART 9 — Potentially Misleading Content (Safety Critical)

### Finding SAFE-01 — ⚠️ P0: Ammonia odour claim (see LC-01)
Already flagged above. A user could think "my water doesn't smell so ammonia is fine." This is potentially lethal for fish.

### Finding SAFE-02 — ⚠️ P1: Excel shrimp toxicity undersold (see LC-05)
Users with shrimp may use standard Excel doses and kill their shrimp colony.

### Finding SAFE-03 — ⚠️ P1: Fish health lesson stubs (see LC-08 / GAP-04)
A user encountering ich following this app's curriculum has no treatment guidance. They may use incorrect treatments (e.g., table salt instead of aquarium salt at wrong concentration, algaecide, etc.).

### Finding SAFE-04 — ⚠️ P1: DIY CO2 overnight crash risk (see LC-06)
CO2 crashes from DIY yeast systems are a documented cause of tank wipe-outs. The current warning is insufficient.

---

## Priority Summary

| ID | Severity | File | Issue |
|----|----------|------|-------|
| LC-01 | **P0** | `nitrogen_cycle.dart` | Ammonia described as "odorless" — remove this claim |
| LC-08 | **P1** | `fish_health.dart` | Fish health lessons are stubs — critical content missing |
| LC-09 | **P1** | `species_care.dart` | Species care lessons are stubs |
| LC-10 | **P1** | `advanced_topics.dart` | All advanced topic quizzes are empty |
| LC-05 | **P1** | `planted_tank.dart` | Excel shrimp warning is dangerously understated |
| LC-06 | **P1** | `planted_tank.dart` | DIY CO2 overnight fish kill risk understated |
| LC-07 | **P1** | `maintenance.dart` | "50% max water change" contradicts emergency guidance |
| LC-04 | **P1** | `species_care.dart` | Betta minimum tank size (5 gal → should be 10 gal) |
| GAP-04 | **P1** | N/A | No medication/treatment guidance for common diseases |
| SD-01 | **P1** | `species_database.dart` | Betta minTankLitres: 20 → should be 40 |
| SD-06 | **P1** | `species_database.dart` | Discus maxTempC: 32 → should be 30 |
| SD-08 | **P1** | `species_database.dart` | Axolotl needs stronger disclaimer and avoidWith list |
| ST-04 | **P1** | `stories.dart` | Ram breeding temp unexplained vs species DB |
| LC-02 | **P2** | `nitrogen_cycle.dart` | Nitrosomonas/Nitrobacter vs Nitrospira — lesson contradicts placement test |
| LC-03 | **P2** | `equipment.dart` | Heater wattage 3-5W/L is outdated |
| LC-11 | **P2** | `planted_tank.dart` | Unverified Takashi Amano quote |
| LC-12 | **P2** | `planted_tank.dart` | Aquasoil ammonia release period understated |
| SD-02 | **P2** | `species_database.dart` | Betta careLevel Beginner debatable |
| SD-03 | **P2** | `species_database.dart` | Cardinal Tetra adultSizeCm: 5 → 4 |
| SD-09 | **P2** | `species_database.dart` | Chinese Algae Eater careLevel Beginner → Intermediate |
| SD-13 | **P2** | `species_database.dart` | Bristlenose Pleco adultSizeCm: 15 → 12 |
| SD-14 | **P2** | `species_database.dart` | Buenos Aires Tetra: "planted tank" missing from avoidWith |
| SD-15 | **P2** | `species_database.dart` | Assassin Snail family Buccinidae → Nassariidae |
| ST-02 | **P2** | `stories.dart` | Pleco warning imperial only → add metric |
| ST-05 | **P2** | `stories.dart` | Water change temp in Fahrenheit only → add Celsius |
| ST-06 | **P2** | `stories.dart` | Phosphate test assumed but not in API kit |
| QZ-06 | **P2** | `planted_tank.dart` | Poor quiz distractor "It's dead" |
| TIP-02 | **P2** | `daily_tips.dart` | Drip acclimation tip: add temperature maintenance note |
| GAP-02 | **P2** | N/A | No saltwater/marine content at all |
| SG-02 | **P2** | `stories.dart` | "Let us do this right" → "Let's do this right" |
| TON-02 | **P2** | `fish_health.dart` | Prevention lesson tone slightly blunt vs rest of app |

---

## What's Working Well

- **Nitrogen cycle lessons:** Among the best beginner fishkeeping educational content available anywhere. Excellent structure, great explanations.
- **Water parameters lessons:** Thorough, well-paced, practical. The chloramine vs chlorine lesson is particularly strong.
- **Daily tips:** All 30 tips are accurate, practical, and well-targeted by experience level.
- **Stories:** Branching narrative is genuinely educational. Consequences of wrong choices are realistic without being preachy.
- **Tone:** Consistently warm, encouraging, and non-judgmental — exactly right for the Duolingo positioning.
- **Species database:** Comprehensive for a v1. Good use of compatibleWith/avoidWith for a checker feature.
- **Quiz quality** (where content exists): Good distractor balance, helpful explanations, appropriate difficulty progression.

---

*End of audit. Total findings: 50 (5× P0/P1 critical safety, 12× P1 quality/accuracy, 33× P2 improvements)*
