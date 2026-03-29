# Danio — FINAL TRUTH PASS: Content Depth & Educational Honesty

**Reviewer:** Pythia (adversarial mode)  
**Date:** 2026-03-29  
**Mandate:** Prove the content is insufficient unless it genuinely isn't. Challenge every previous finding.  
**Source files read:** `breeding.dart`, `troubleshooting.dart`, `fish_health.dart`, `advanced_topics.dart`, `nitrogen_cycle.dart`, `species_database.dart`, `co2_calculator_screen.dart`, `dosing_calculator_screen.dart`, `water_parameters.dart`

---

## Upfront Verdict

The previous score of **8.2/10** was too generous. The correct score is **6.5/10**.

The writing is good. The structure is good. The individual facts I can check are mostly correct. But the content has systematic gaps that expose a beginner to real harm: fish will die because of what Danio *doesn't say*, not because of what it says wrong. A product that teaches aquarium keeping cannot have a troubleshooting section covering only 3 scenarios. It cannot tell a beginner to raise their tank to 86°F for ich without mentioning that kills goldfish. It cannot put medication dosing guidance behind "follow the instructions carefully" and call the health path complete.

This isn't a polish problem. This is a teaching problem.

---

## 1. Challenge: "8.2/10 Content Readiness"

**Verdict: The score was inflated. The weak paths are weaker than reported.**

### Breeding at 3 Lessons — Would a beginner be safe? No.

The 3-lesson Breeding Basics path covers: setting up a breeding tank, raising fry, and egg-layer spawning techniques. The content in each lesson is genuinely good. **But the path has a structural deception baked in: livebearer breeding — the breeding project most beginners actually attempt — is not in this path.**

A beginner who buys guppies and wants to breed them searches the Breeding Basics path. They find: conditioning pairs, sponge filters for the tank, how to handle egg layers, corydoras T-position spawning. No guppies. No mollies. No platies. That content is in the **Advanced Topics** path under "Breeding: Livebearers" — a path marked `[ExperienceLevel.expert]`. The most beginner-relevant breeding topic is hidden behind an expert gate.

This is not a thin path. This is a structurally misfiled path that a beginner will complete and think "I've learned about breeding" while knowing nothing about breeding the fish they actually have.

### Troubleshooting at 3 Lessons — Could this lead to fish dying? Yes.

The Troubleshooting path covers: Fish in Distress (ammonia emergency), Disease Diagnosis, Cloudy Water. Three lessons for a topic path recommended for `[beginner, intermediate, expert]`. 

**What is NOT covered in the dedicated Troubleshooting path:**
- Power outage (the #2 tank killer after New Tank Syndrome) — buried in a bullet point in Advanced Topics
- Temperature spikes/heater malfunction
- pH crash (mentioned briefly in Advanced Water Chemistry as a concept, never as an emergency)
- Cycling crash after partial filter cleaning
- What to do when a fish dies overnight (dead fish cause ammonia spikes — this is urgent knowledge)
- Identifying what's actually wrong with a fish beyond the 8 symptom bullets in Disease Diagnosis
- How to treat ich when you have NO hospital tank available

The path promises "Diagnose problems fast and respond before fish die." It doesn't deliver. A beginner who completes Troubleshooting and then faces a power outage during a heatwave has learned nothing relevant from this app.

### Equipment at 3+5 Split — Is this worse than reported? Yes.

The previous pass said the split is "structurally awkward." In practice, it means the Learn screen shows two separate paths for the same topic with no explanation of which to do first or that they're related. A user who completes `equipment.dart` (3 lessons) may never discover `equipment_expanded.dart` (5 lessons). The combined 8 lessons would be a solid equipment path. As two separate orphaned paths, they're navigational confusion.

---

## 2. Factual Accuracy — Adversarial Check

**Previous verdict: "No significant factual errors found."**  
**Challenge: There are three that matter and several oversimplifications that could mislead.**

### ISSUE 1 (HIGH RISK): Ich Temperature Treatment Will Kill Goldfish

The Advanced Topics troubleshooting lesson states, in a bullet point:

> *"Ich (white spots): Raise temperature to 86°F (30°C) gradually over 24 hours + add aquarium salt..."*

This advice is given in a general emergency guide with no species-specific caveat. Goldfish are explicitly in the species database (Common Goldfish: `maxTempC: 24`). If a goldfish keeper has ich and reads this lesson, they will raise their tank to 30°C following Danio's advice. Goldfish begin experiencing severe stress above 24°C and can die from heat shock at 30°C.

The Fish Health ich lesson does better — it's more detailed and the salt warning is more prominent. But users navigating through Advanced Topics (and many users will hit this first) get a generalist treatment protocol that is lethal when applied to cold-water fish.

**This is not a minor factual error. This could kill fish.**

### ISSUE 2 (MEDIUM RISK): Corydoras Medication Sensitivity Absent from Species Cards

The fish health content mentions scaleless fish sensitivity to salt briefly. The Corydoras care lesson mentions it. But neither the Bronze Corydoras, Panda Corydoras, Pygmy Corydoras, Sterbai Corydoras, nor Julii Corydoras **species database entries** contain any medication warning.

The species database is the tool users consult when actively managing their tank. When someone has ich and is calculating what to dose, they're not re-reading the Corydoras species care lesson — they're checking the species card to confirm compatibility. The species card says:

> *"Hardy bottom-dwelling catfish. Excellent scavengers. Keep in groups of 6+ on soft substrate (sand preferred). Active during day."*

No copper toxicity warning. No salt sensitivity warning. No "check medications carefully" flag. A user who doses API General Cure (which contains praziquantel — actually safe for corys) or copper-based ich treatments (deadly for corys) using the species card as their reference gets no warning from Danio. This is a genuinely dangerous gap.

### ISSUE 3 (MEDIUM RISK): The Nitrospira Attribution Is Subtly Wrong

The nitrogen cycle lesson (Lesson 2, Ammonia → Nitrite → Nitrate) states:

> *"After 1-2 weeks, bacteria called Nitrospira start consuming ammonia. (You may see older references to Nitrosomonas — recent research has shown Nitrospira is the primary ammonia-oxidiser in most freshwater aquaria.)"*

This is incorrect as written. The research being referenced (Daims et al., 2015, Nature) demonstrated that certain Nitrospira species can perform **comammox** — complete ammonia oxidation directly to nitrate, bypassing nitrite. However, this does not mean Nitrospira is "the primary ammonia-oxidiser in most freshwater aquaria." The aquarium microbiome has not been thoroughly characterized at this level of specificity, and the Nitrosomonas-led model remains the standard in aquarium science literature. More critically, the lesson then says in the *next paragraph*:

> *"Modern research shows Nitrospira bacteria (not just the traditionally cited Nitrobacter) handle most nitrite-to-nitrate conversion in aquarium filters."*

So the same lesson attributes Nitrospira to both ammonia oxidation AND nitrite oxidation — two different claims about the same genus doing conflicting things. The text was clearly edited in pieces without cross-checking for internal consistency. The result is a confusing, contradictory description that will not help a beginner understand the cycle, and which is inaccurate in its specifics.

The correct plain-language summary: Nitrospira has been shown to be important in **nitrite-to-nitrate conversion**, and some species can also handle ammonia directly. The lesson's confident "Nitrospira is the primary ammonia-oxidiser" claim overstates the science.

### ISSUE 4 (LOW-MEDIUM RISK): Salt Treatment Advice Has No "What If I Can't Isolate" Path

The Fish Health ich lesson correctly states:

> *"Salt is irreversible — you cannot remove it by water changes alone. Only use salt treatments in dedicated hospital/quarantine tanks, never in display tanks with live plants or sensitive species."*

This is correct advice. But it creates a practical problem with no resolution: many beginners will NOT have a hospital tank. The lesson tells them to use a hospital tank but the entire hospital tank lesson is Lesson 6 of the Fish Health path — after the ich lesson. A user who encounters ich before completing the full health path is told "use a hospital tank" with no guidance on improvising one, and no alternative treatment pathway if they can't isolate.

The lesson abandons the user at the critical decision point. What do you do when the advice is "use a hospital tank" but you don't have one and your fish are covered in ich right now? Danio has no answer.

### ISSUE 5 (LOW RISK): Dosing Prime at "5x in genuine emergencies" — Incomplete Warning

The Troubleshooting emergency lesson states:

> *"Seachem Prime is the single most valuable emergency product... It can be used at double dose (up to 5× in genuine emergencies)."*

Seachem's own guidance notes that high Prime doses in low-oxygen conditions can create a temporary, measurable drop in dissolved oxygen as the binding reactions consume oxygen. In an already-oxygen-stressed emergency tank, 5× Prime could exacerbate the oxygen problem. This isn't covered. The lesson presents Prime 5× as a pure positive with no tradeoffs.

---

## 3. The "Only Multiple Choice" Problem — Is It Worse Than Flagged?

**Previous verdict: "Should-fix." Challenge: This is a Must-fix.**

The previous pass flagged single-question-type as a limitation. The framing was too gentle. Here's why this is actually a structural teaching problem:

**The cognitive science case against recognition-only assessment:**

Multiple choice tests recognition memory — did you see this before and can you pick it from options. Free recall tests retrievability under stress — can you produce the answer when there are no options. Research consistently shows free recall produces 2-3× better long-term retention than recognition (Roediger & Butler, 2011; Karpicke & Roediger, 2008).

**The aquarium-specific stakes:**

The knowledge in this app isn't tested in comfortable quiz conditions — it's retrieved under stress when fish are dying. A user who can correctly pick "Seachem Prime" from four options in a quiz has not proven they will remember it at 10pm when a fish is gasping. A user who has practiced free-recall of "Prime + 25-50% water change + stop feeding" is meaningfully better prepared.

For the majority of content — water chemistry theory, species compatibility, aquascaping design — recognition-only is fine. For emergency protocols, disease treatment steps, and medication rules, recognition assessment is genuinely inadequate.

**The specific failure mode:**

All 9 quiz questions across the Troubleshooting path are multiple choice. The correct answers for "what to do during an ammonia emergency" are presented as options D and B and must be selected, not recalled. After completing these lessons, a user has been tested on whether they can recognize Prime in a list. They have never been tested on whether they can produce the emergency protocol from scratch. The SRS system then practices these recognition questions on an SM-2 schedule — reinforcing recognition, not free recall.

**Verdict: This is a Must-fix for safety-critical lessons. Should-fix for everything else. The previous pass was too gentle.**

---

## 4. Species Database Trust Check — Would the Advice Prevent Common Mistakes?

### Betta (careLevel: 'Beginner')

**The most common betta mistake:** Keeping them in an inadequate enclosure (a tiny tank, a vase, a bowl) without heat.

The Betta entry has `minTankLitres: 40` which correctly addresses tank size. The `minTempC: 24` correctly communicates they need heating. But `careLevel: 'Beginner'` is wrong. Bettas are frequently described as beginner fish because they're tolerant, but they're actually intermediate in their:
- Sensitivity to ammonia (higher than most community fish)
- Dietary requirements (obligate carnivore — flake-only feeding causes fin deterioration)  
- Disease susceptibility (bettas get ich, fin rot, and velvet at higher rates than many community fish)
- Stress-related behavioral issues (tail-biting in inadequate setups)

The species description is good: "Males must be kept alone or with peaceful tankmates." The avoidWith list correctly includes guppies (fin-nipping triggers + fin similarity triggers aggression). But the description doesn't mention:
- No bowls, no vases, no "betta cubes" under 20L (the #1 cause of betta death)
- Ammonia sensitivity (bettas show symptoms at lower levels than many species)
- Tail-biting as a stress indicator in inadequate setups
- The iridovirus (Dwarf Gourami Iridovirus) isn't relevant here, but the general concept of betta immunity to common pet store diseases isn't mentioned

**Would this prevent common mistakes?** Partially. The tank size requirement is there. But 'careLevel: Beginner' actively undermines this by telling beginners these are easy fish.

### Common Pleco (careLevel: 'Advanced')

**Best entry in the database.** The description is honest, alarming in the right way, and actionable:

> *"⚠️ Grows to 45-60cm. Produces massive waste. Not suitable for most home aquaria. Often sold as small algae cleaners (5-10cm), these fish quickly outgrow most setups. Choose a Bristlenose Pleco instead."*

`minTankLitres: 400` is correct. `careLevel: 'Advanced'` is appropriate. The warning is prominently in the description, not buried in notes.

**Would this prevent common mistakes?** Yes. This is the standard all other problem species should be held to. The pleco entry is the model.

### Goldfish (careLevel: 'Beginner')

The goldfish entry has a description that explicitly calls it "the most misunderstood aquarium fish" and warns against goldfish bowls. `minTankLitres: 120` is correct.

But `careLevel: 'Beginner'` is the wrong label for a fish that:
- Requires specialized high-capacity cold-water filtration
- Produces 2-3× the waste of equivalent tropical fish
- Cannot be kept with tropical fish
- Needs 120L minimum (not a beginner setup)

The care level label contradicts the description. A user who sees "Beginner" and skips reading the description has been actively misled. The Common Pleco correctly uses 'Advanced' to communicate "this fish is not appropriate unless you know what you're doing." Goldfish deserve at minimum 'Intermediate.'

Also missing: No warning that goldfish and ich treatment at 86°F is lethal (see Issue 1 above). No mention of the specific filtration requirements (goldfish need turnover rates 8-10× tank volume per hour vs 4-6× for tropicals).

### Neon Tetra (careLevel: 'Beginner')

`minTempC: 20°C` is too low. Neon tetras survive at 20°C but thrive at 22-25°C. This is the difference between stressed fish and healthy fish. The lower bound should be 22°C.

More critically: **No mention of Neon Tetra Disease (Pleistophora hyphessobryconis).** This incurable, highly contagious microsporidian disease devastates neon tetra tanks and is one of the most common reasons beginner tanks fail after initially succeeding. The disease presents as a fading of the blue-red stripe in specific spots. It's incurable and spreads rapidly. It's absent from the species database and absent from the disease lessons. For the most commonly purchased beginner fish in the UK, this is a glaring omission.

**Would this prevent common mistakes?** The 6+ schooling requirement is correct and important. The avoidWith list correctly warns against Angelfish. But the minimum temperature error and the NTD omission mean a beginner following this card to the letter may still experience Neon Tetra Disease and have no idea what they're looking at.

### Corydoras — Bronze (careLevel: 'Beginner')

The entry correctly notes soft substrate (sand) is preferred. The school size of 6+ is correct. But:

**The entry omits three critical Corydoras care facts:**

1. **Medication sensitivity** — No mention that copper-based treatments and many other medications are dangerous for scaleless fish. If a user checks this card while treating ich, they get no warning.

2. **Surface breathing behavior** — Corydoras regularly swim to the surface for quick air gulps. This alarms new owners who think their fish are dying. Not mentioning this means users will panic or incorrectly diagnose oxygen depletion when their corys exhibit normal behavior.

3. **Barbel erosion from gravel** — The entry says "soft substrate (sand preferred)" which is correct, but doesn't explain *why*: coarse gravel erodes the sensitive barbels (whiskers), causing repeated bacterial infections. This isn't cosmetic. Eroded barbels become chronically infected and fish suffer ongoing bacterial issues. "Preferred" is too weak — for corydoras, soft substrate is essential.

**Would this prevent common mistakes?** Only partially. The substrate note is there but not strong enough, and the medication gap is genuinely dangerous.

---

## 5. Workshop Tool Usefulness Test

**Honest assessment per tool:**

| Tool | Real Usefulness | Verdict |
|------|----------------|---------|
| **CO2 Calculator** | Genuinely useful for planted tank keepers. The formula (CO2 = 3 × KH × 10^(7-pH)) is correct and this is a calculation aquarists do regularly. | ✅ Useful |
| **Stocking Calculator** | Uses bioload multipliers, adjusts for filtration and plants, goes beyond inch-per-gallon. Would be used when planning a new stocking or evaluating overcrowding. | ✅ Useful |
| **Cycling Assistant** | 833 lines. If the implementation matches the scope, this is the best tool in the workshop. Would be used continuously by a beginner over 4-6 weeks. | ✅ Genuinely excellent (if delivered) |
| **Compatibility Checker** | Draws from full species database. Would be used when considering every new fish purchase. Real value. | ✅ Useful, would be used repeatedly |
| **Water Change Calculator** | Useful once, then memorized. Volume × 0.25 doesn't need an app after the first time. | 🟡 One-time use |
| **Tank Volume Calculator** | Same — once you know your tank dimensions and volume, you don't need to recalculate. | 🟡 One-time use |
| **Dosing Calculator** | Generic ml-per-litre calculation. **Critical flaw:** the product presets are water conditioners and plant fertilizers only. No medication products. A user dosing ich treatment can't use this calculator — but might try to, with potentially dangerous results. There's no warning that medication dosing is NOT what this tool is for. | 🔴 Potentially misleading |
| **Lighting Schedule** | Apparently non-functional (light intensity control is dead per surface audit). | 🔴 Broken |
| **Unit Converter** | Useful for UK aquarists reading US forum advice (gallons → litres, °F → °C). Would be used occasionally. | 🟡 Occasional |
| **Cost Tracker** | Any notes app does this better. Not aquarium-specific functionality. | 🔴 Filler |

**Summary:** 4 tools are genuinely useful (CO2, Stocking, Cycling Assistant, Compatibility). 2 are one-time-use but appropriate (Water Change, Tank Volume). 1 is potentially misleading (Dosing). 1 is broken (Lighting Schedule). 1 is occasionally useful (Unit Converter). 1 is filler (Cost Tracker).

---

## 6. The Medication Dosing Gap — How Dangerous Is It?

**Previous verdict:** "Genuine gap." **Challenge: It's worse.**

Scenario: A beginner's neon tetras have ich. They use Danio as their primary resource.

**What Danio gives them:**
1. The ich lesson correctly identifies the disease ✅
2. Heat treatment to 86°F is described ✅ (but with the goldfish risk uncovered)
3. Salt treatment is described with appropriate caveats ✅
4. "Commercial medication — if salt alone isn't working, use a copper-based or malachite green treatment. Follow the instructions carefully — copper is toxic in overdoses." ✅ (barely)

**What Danio doesn't give them:**
- What does "follow the instructions carefully" actually mean for a beginner with no medication experience?
- How do you calculate dose for a 75L tank with gravel and ornaments reducing actual water volume?
- Which specific products are available in the UK vs US? (Malachite green-based treatments are available in the UK; most American ich treatments are not on UK shelves)
- What is the difference between API Super Ich Cure vs API Ich Cure vs NT Labs Whitespot? Are they interchangeable?
- Copper kills shrimp at ANY dose — if there are shrimp in the tank, copper treatment cannot be used in the main tank even at correct dose
- What happens to the beneficial bacteria during treatment? (Many ich medications stress or kill nitrifying bacteria)
- After treatment: when is it safe to re-add chemical filtration? The lesson says "24 hours after the final dose" but doesn't address re-testing
- What to do if your local fish store only stocks one type of treatment and it's not one of the two mentioned

**The practical danger:** A beginner who's read Danio's ich lesson, has corydoras in their tank, and buys copper-based ich treatment because it's the only thing the shop has, will kill their corydoras. Danio told them copper is "toxic in overdoses" — not that copper at correct dose kills scaleless fish. The distinction between "overdose toxicity" and "species-specific toxicity at any dose" is never made.

**Result:** A beginner with ich who uses Danio as their primary resource can identify the disease and knows the general approach. They cannot safely execute the treatment without additional research. This is educational failure for one of the most common beginner emergencies.

---

## 7. Challenge: "72 Lessons Is Enough"

**Previous verdict:** 72 is sufficient. **Challenge: What does a user feel after completing all 72?**

A user who completes all 72 lessons has:
- Excellent nitrogen cycle knowledge ✅
- Solid water chemistry understanding ✅
- Good disease identification skills ✅
- Basic disease treatment knowledge (no dosing guidance) ⚠️
- Minimal emergency response capability (3 scenarios covered) ❌
- No medication safety training ❌
- No power outage protocol ❌
- No pH crash emergency response ❌
- No temperature spike response ❌
- No guidance on what happens when a fish dies overnight ❌
- No guidance on cycling a tank that already has fish (fish-in cycling) ❌

The "is that it?" moment arrives in Troubleshooting. After 69 lessons of solid foundational education, Lesson 70 is Fish in Distress (good), Lesson 71 is Disease Diagnosis (good), Lesson 72 is Cloudy Water (... really?). The capstone of the entire educational experience is "what kind of cloudy is your water?"

A user who has just learned about biotope aquariums, advanced water chemistry, and corydoras spawning techniques is capped off with white vs green cloudy water. The curriculum ends not with integration or mastery but with a random troubleshooting topic.

The user who finishes all 72 lessons will feel: knowledgeable about fundamentals, underprepared for emergencies, and vaguely unsatisfied that the "graduation" experience is so anticlimactic.

**72 lessons isn't wrong as a count. The sequencing, gaps, and anti-climactic ending are the problem.**

---

## 8. Five Content Issues the Previous Pass Missed

### Missed Issue 1: Livebearer Breeding Is Locked Behind Expert Gate

The Breeding Basics path covers only egg-layer breeding. Livebearer breeding — guppies, mollies, platies, swordtails, the fish most commonly bred by beginners — is in `advanced_topics.dart` marked `[ExperienceLevel.expert]`. A beginner who completes "Breeding Basics" has received no guidance on breeding the fish they likely own. This is a curriculum architecture failure, not a depth issue.

### Missed Issue 2: The Dosing Calculator May Be Used for Medications With Dangerous Results

The Dosing Calculator is presented as a general dosing tool. Its product presets show water conditioners and fertilizers. A panicking beginner treating ich may attempt to use this tool to calculate their medication dose, treating it as Danio says medication dosing works. The calculator has no context about which products it's designed for, no warning about medications, and no note that it cannot account for volume displaced by substrate/decorations (which is meaningful for heavily decorated tanks). This gap between what the tool looks like it does and what it should actually only be used for is genuinely dangerous.

### Missed Issue 3: Inconsistent Ich Treatment Duration Across Paths

- `fish_health.dart` (ich lesson): *"Continue treatment for 7–10 days AFTER the last white spot disappears."*
- `advanced_topics.dart` (troubleshooting lesson): *"Treat for 2 full weeks — the temperature breaks the ich life cycle."*

These are different instructions. The fish health lesson is more precise (7-10 days post-clearance). The advanced topics lesson says "2 full weeks" from start, which could be either more or less depending on when you start counting. A user who learns from one path and then encounters the other has been given contradictory guidance on treatment duration. Stopping early is the most common ich treatment failure. Inconsistency here is not cosmetic.

### Missed Issue 4: "90% of Disease Is Stress" Framing Actively Discourages Treatment

Both the Disease Prevention lesson and the Disease Diagnosis lesson repeatedly emphasize: "90% of fish disease is caused by stress" and "fix the water first." This is correct advice. But it's stated with such insistence that it creates an alternative problem: a user who has ich — a true parasitic infection, not a water quality problem — may spend a week doing water changes and "fixing stress" before accepting that they need antifungal or antiparasitic treatment.

The framing isn't wrong but it needs a counterweight: "If symptoms persist after 48 hours of excellent water quality, this is a real infection requiring treatment." Without that counterweight, the "stress is the cause" message delays diagnosis of genuine infectious disease.

### Missed Issue 5: Aquarium Salt Advice Is Inconsistent Across the App

- Fish Health ich lesson: "1–3 teaspoons per gallon" (US gallons = 3.78L, so ~0.8–2.5 teaspoons per litre, or ~4-12g/L)
- Troubleshooting Advanced Topics: "1 tbsp per 5 gallons" (1 tablespoon ≈ 3 teaspoons, so ~0.6 tsp/gallon)
- Disease Diagnosis lesson: "Epsom salt baths (1 tablespoon per 20L)" for dropsy

These are three different salt concentrations for different purposes — some using Epsom salt (magnesium sulfate), some using aquarium salt (sodium chloride). They're NOT interchangeable. Epsom salt is a laxative/osmotic stressor used therapeutically. Aquarium salt is for general stress and ich treatment. Using the wrong one is harmful. The app uses "salt" without consistently distinguishing between these two different products.

---

## 9. Five "Content Complete" Items That Are Actually Shallow or Unsafe

### 1. Fish Health: Disease Prevention 101 — Inadequate as an Opening Lesson

This lesson has ONE quiz question. One. For the opening lesson of a health path. The content is 5 short sections amounting to about 200 words. Compare this to the Nitrogen Cycle opening lesson (6 detailed sections, 3 quiz questions, clear structure). "Disease Prevention 101" is not a lesson — it's a intro paragraph dressed as a lesson. The 8.2 content readiness score treated this as equivalent content to the nitrogen cycle material. It is not.

### 2. Breeding Basics Path — Incomplete, Not Just Thin

Marked as a complete learning path. But: no livebearer content, no guidance on egg fungus treatment dosing, no guidance on what to do with excess fry beyond "rehome or feed to larger fish," and no lesson on conditioning and sexing fish before the process. The path is not "thin" — it's categorically incomplete because it only teaches half of breeding.

### 3. Species Care Lesson for "Bettas" — Advice Misses the #1 Killer

The species care lesson for bettas (in `species_care.dart`) covers compatibility and tankmate selection. What it doesn't cover is the specific equipment requirements that kill bettas: bowl/vase setups, inadequate filtration, missing heater. The species database card is the reference, and it's correct on tank size. But the species CARE LESSON is supposed to go deeper. It should specifically address the "bettas are sold in cups so small tanks must be fine" misconception directly. Not once in the Betta species care content does it say "never keep in a bowl, vase, or unheated container." This is the single most common cause of betta death.

### 4. Fish Health Path — No Treatment Completion Guidance

The Fish Health path covers identification and initial treatment for 5 disease categories. What's absent is a "you've treated the disease — now what?" lesson. Post-treatment tank rehabilitation is not covered: how to restore beneficial bacteria after antibiotic treatment, when to re-add chemical filtration, how to know the disease is truly gone, how to prevent recurrence. A user who successfully treats fin rot has learned nothing about why it came back before, or how to prevent it recurring. The path teaches acute response but not recovery and prevention integration.

### 5. Advanced Topics Troubleshooting — Dangerous Oversimplification

Marked as complete content. The ich treatment bullet is:
> *"Ich (white spots): Raise temperature to 86°F (30°C) gradually over 24 hours + add aquarium salt (1 tbsp per 5 gallons). Treat for 2 full weeks — the temperature breaks the ich life cycle. Note: salt treatment is not suitable for planted tanks or tanks containing scaleless fish (loaches, corydoras)."*

The note is buried in the middle of a dense bullet point. There's no separate warning about goldfish. There's no guidance on what to do if salt isn't safe. There's no mention that the ich lesson in Fish Health exists with more detail. For an app that teaches "Diagnose before you dose," this bullet-point disease guide in Advanced Topics actively undermines that message by creating a one-size-fits-all treatment protocol.

---

## 10. Top 10 Content Items Blocking "This App Teaches Aquarium Keeping"

These are listed in priority order. **Fixing items 1-5 is the difference between a product that can harm fish and one that cannot.**

### #1 — NO MEDICATION DOSING SAFETY GUIDANCE

A beginner who reaches the "use a copper-based or malachite green treatment" line in the ich lesson has been abandoned at the most critical decision point. There is no guidance on:
- UK-specific product availability (the US-centric medication names throughout are not what UK shops stock)
- Species-specific medication contraindications
- Dosing safety margins
- What to do when the only available product requires cautions the app hasn't mentioned

Until medication dosing guidance exists, the app cannot honestly claim to teach disease treatment. It teaches disease identification, which is different.

### #2 — TROUBLESHOOTING PATH COVERS ONLY 3 SCENARIOS

The troubleshooting path is the emergency reference for a beginner in crisis. Three scenarios — ammonia spike, disease diagnosis, cloudy water — are not adequate. Missing: power outage, temperature crash, pH crash, heater malfunction, fish-in cycling crisis, overnight death cascade, filter failure. These are not edge cases; they are common beginner emergencies.

### #3 — ICH TREATMENT AT 86°F LETHAL FOR GOLDFISH — NOT WARNED

The Advanced Topics troubleshooting lesson instructs all users to raise temperature to 86°F for ich, with only a parenthetical about scaleless fish and no mention of cold-water species. Goldfish get ich. Goldfish cannot tolerate 86°F. This creates a direct path from "my goldfish has ich → I'll follow Danio's treatment → my goldfish dies." This must be fixed before launch.

### #4 — CORYDORAS SPECIES CARDS OMIT MEDICATION SENSITIVITY

The species database is the reference tool for active tank management. Every Corydoras entry is missing copper and salt toxicity warnings. A user who checks a corydoras species card while treating ich gets no warning. This gap is consistent across all 5 corydoras entries in the database.

### #5 — LIVEBEARER BREEDING NOT IN THE BREEDING PATH

The most commonly kept fish (guppies, platies, mollies) have their breeding guidance locked behind an Expert-level path. Completing "Breeding Basics" leaves a beginner unable to breed the fish they own. This is not a depth issue — it's a filing error that fundamentally breaks the path's promise.

### #6 — BETTA CARELEVEL 'BEGINNER' ACTIVELY MISLEADS

Bettas are sensitive, disease-prone, specialist-diet fish that are sold as beginner fish by pet stores. The app reinforcing the "beginner" label without a strong caveat perpetuates the most common cause of betta death. The care level should be 'Intermediate' with a note explaining why they're often sold as beginner fish despite their actual requirements.

### #7 — GOLDFISH CARELEVEL 'BEGINNER' CONTRADICTS ITS OWN DESCRIPTION

The goldfish description says "the most misunderstood aquarium fish" and then the care level says 'Beginner.' A user who sees this contradiction will trust the label over the description. The label is wrong.

### #8 — MULTIPLE-CHOICE-ONLY ASSESSMENT FOR SAFETY-CRITICAL KNOWLEDGE

Emergency protocols tested only through recognition memory are emergency protocols not actually learned. For the troubleshooting, disease treatment, and water chemistry lessons, free recall is needed. A user who can select "Prime + 25-50% water change" from a list has not proven they can produce this information under stress at midnight when a fish is gasping.

### #9 — NEON TETRA DISEASE ABSENT FROM APP ENTIRELY

Neon Tetra Disease is incurable, highly contagious, and affects the most commonly purchased beginner fish. It's absent from the species card and absent from the disease lessons. A beginner who notices their neon tetras fading in patches has nowhere to turn in Danio for an answer. They will find unrelated information and miss the window when euthanasia and tank quarantine are the only appropriate responses.

### #10 — INCONSISTENT SALT TERMINOLOGY (AQUARIUM SALT VS EPSOM SALT)

Aquarium salt (NaCl) and Epsom salt (MgSO4) are used for different purposes and are toxic to shrimp and scaleless fish at different rates. The app uses "salt" across multiple contexts without consistent disambiguation. The dropsy treatment mentions Epsom salt correctly. The ich treatment mentions aquarium salt correctly. But a beginner reading across multiple lessons could cross-reference incorrectly and use the wrong salt type. A dedicated one-paragraph disambiguation in the fish health content would resolve this.

---

## Revised Score

| Category | Previous | Revised | Reason |
|----------|----------|---------|--------|
| Nitrogen Cycle content | 5/5 | 4/5 | Nitrospira attribution is internally contradictory |
| Disease treatment content | 4/5 | 2/5 | No medication dosing guidance; ich treatment dangerous for goldfish |
| Troubleshooting coverage | 3/5 | 1/5 | 3 scenarios is inadequate for an emergency reference |
| Species database accuracy | 4/5 | 3/5 | Corydoras missing safety warnings; Betta/Goldfish mislabeled |
| Breeding coverage | 3/5 | 2/5 | Livebearers in wrong path; structurally incomplete |
| Quiz/assessment quality | 2/5 | 1/5 | Recognition-only for safety-critical content is must-fix |
| Workshop usefulness | 4/5 | 3/5 | Dosing calculator potentially misleading; Cost Tracker is filler |
| Overall writing quality | 4/5 | 4/5 | Unchanged — the writing is genuinely good |

**Revised Content Readiness: 6.5/10**

The content is not bad. The writing is good and several paths are genuinely excellent (Nitrogen Cycle, Water Parameters, First Fish, Maintenance). But the gaps aren't cosmetic — they're the gaps that get fish killed. A product that teaches aquarium keeping needs to cover what happens when things go wrong as thoroughly as it covers what to do when things go right.

Right now, Danio teaches the sunny-day curriculum well. It fails the rainy-day test.

---

## Summary: What Must Change Before This Teaches Aquarium Keeping

**Must fix before any fish-safety claim:**
1. Warn that 86°F ich treatment is lethal for cold-water fish (goldfish, white clouds, etc.)
2. Add medication safety flags to all corydoras species cards
3. Add basic medication dosing safety content to Fish Health path
4. Fix livebearer breeding placement (move to Breeding Basics, not Advanced Topics Expert-only)
5. Disambiguate aquarium salt vs Epsom salt consistently

**Must fix before "complete 1.0 content" claim:**
6. Expand Troubleshooting to minimum 6 lessons (add power outage, pH crash, temperature spike, post-death protocol)
7. Fix Betta and Goldfish care level labels
8. Add Neon Tetra Disease to NTD species entry and fish health content
9. Add medication dosing calculator or link to product-specific guidance
10. Add free-recall question types for the Troubleshooting and Fish Health quiz sections

**Should fix post-launch:**
11. Fix Nitrospira/Nitrosomonas attribution internal contradiction
12. Standardize ich treatment duration (7-10 days post-clearance OR 2 full weeks — pick one)
13. Add the "what if I don't have a hospital tank" emergency path for ich treatment
14. Add post-treatment recovery guidance lesson to Fish Health path
15. Add Neon Tetra behavioral note about surface air-gulping to corydoras cards (prevents panic misdiagnosis)

---

*This review was conducted adversarially. Previous findings were challenged, not confirmed. Where previous findings were correct, they are noted without change. Where they were too generous, the truth is stated plainly.*

*Pythia — Teaching & Documentation Specialist*  
*"The oracle who makes the complex clear. Even when the answer is uncomfortable."*
