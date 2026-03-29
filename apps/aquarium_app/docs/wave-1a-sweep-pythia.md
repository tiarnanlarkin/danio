# Wave 1A — Pythia Safety Content Sweep

## Sweep Results

### FB-S1 (Ich Temperature) — FIXED
- **Advanced Topics lesson** (`lib/data/lessons/advanced_topics.dart`): The ich bullet now explicitly states 86°F/30°C is for TROPICAL FISH ONLY, with a prominent coldwater warning against heating goldfish, white cloud minnows, and hillstream loaches above 24°C/75°F. Medication-only treatment is recommended for coldwater species. The quiz question was also narrowed to "TROPICAL fish tank".
- **Fish Health lesson** (`lib/data/lessons/fish_health.dart`): The full ich treatment guide (Step 1–4) now leads with a prominent coldwater fish warning before the tropical heat method. Quiz question narrowed accordingly.

### FB-S2 (Corydoras Warnings) — FIXED
All 6 Corydoras species entries now have `medicationWarnings` field with:
- Copper toxicity warning
- Salt intolerance warning

### Same-Class Sweep — Additional Findings and Fixes

#### ADDITIONAL COLD-WATER TEMPERATURE RISKS (FIXED in this wave)
The following species had no ich/heat treatment warning and were added:
- **Common Goldfish** (`Carassius auratus`) — max 24°C; heat method would kill
- **Fancy Goldfish** (`Carassius auratus`) — max 24°C; heat method would kill
- **White Cloud Mountain Minnow** (`Tanichthys albonubes`) — max 22°C; heat method would kill
- **Golden White Cloud** (`Tanichthys albonubes var. gold`) — max 22°C; same risk
- **Hillstream Loach** (`Sewellia lineolata`) — max 24°C + scaleless sensitivity
- **Weather Loach** (`Misgurnus anguillicaudatus`) — coldwater + loach sensitivity
- **Axolotl** (`Ambystoma mexicanum`) — max 20°C; heat + salt + copper warnings added

#### MISSING MEDICATION SENSITIVITY WARNINGS (FIXED in this wave)
All of the following now have `medicationWarnings`:
- **Otocinclus** — scaleless catfish; copper + salt sensitivity
- **Kuhli Loach** — effectively scaleless; quarter-dose and no-salt
- **Yoyo Loach** — same loach sensitivity
- **Hillstream Loach** — scaleless + coldwater + no-salt
- **Weather Loach** — scaleless + no-salt
- **Cherry Shrimp** — copper lethal; salt fatal
- **Amano Shrimp** — copper lethal; salt fatal
- **Crystal Red Shrimp** — copper lethal; salt fatal
- **Yellow Shrimp** — copper lethal; salt fatal
- **Orange Sakura Shrimp** — copper lethal; salt fatal
- **Bamboo Shrimp** — copper lethal; salt fatal
- **Vampire Shrimp** — copper lethal; salt fatal
- **African Dwarf Frog** — amphibian copper + salt sensitivity
- **Thai Micro Crab** — copper lethal; salt sensitivity

#### REMAINING ITEMS NOT CHANGED (CLEAN or out of scope)
- **Plecos** (Bristlenose, Albino Bristlenose, Super Red Bristlenose, Common Pleco, Otocinclus): Otocinclus fixed above. Armoured plecos (Loricariidae with bony scutes) have documented sensitivity to some chemicals but are less acutely at risk than Corydoras; they are not scaleless in the same way. Consider reviewing in a future wave.
- **Breeding lesson temperature advice** — references to raising temperature 1–2°C for spawning triggers are species-appropriate and do not recommend dangerous absolute temperatures. CLEAN.
- **Water Parameters lesson** — heat advice for heatwave cooling (frozen bottles) is correct and helpful. Temperature scale references are accurate. CLEAN.
- **Maintenance lesson** — seasonal temperature monitoring is appropriate general advice with no species-specific danger. CLEAN.
- **Troubleshooting lesson** — ich symptom identification is correct; the "raise to 86°F" appears only as a wrong answer option in a quiz (correctIndex: 1 = test water first). CLEAN.
- **Species Care (Shrimp section)** — already contained the warning "COPPER KILLS SHRIMP" in lesson text (`species_care.dart` line 428). CLEAN (lesson already correct).
- **Species Care Expanded (Corydoras section)** — already noted "Corydoras are sensitive to medications...use half the recommended dose" in lesson text. CLEAN for lessons; species cards are now also fixed.
- **Species Care Expanded (Loach section)** — already warned "use quarter-strength medication dose and monitor closely. Salt should be avoided entirely with loaches." CLEAN for lessons; species cards are now also fixed.

---

## Changes Made

### `lib/data/species_database.dart`
- Added `medicationWarnings` field to `SpeciesInfo` class (optional, defaults to `[]`)
- Added copper + salt warnings to: **Bronze Corydoras**, **Panda Corydoras**, **Pygmy Corydoras**, **Sterbai Corydoras**, **Julii Corydoras**, **Peppered Corydoras**
- Added copper + salt warnings to: **Otocinclus**, **Kuhli Loach**, **Yoyo Loach**, **Hillstream Loach**, **Weather Loach**
- Added copper lethal + salt warnings to: **Cherry Shrimp**, **Amano Shrimp**, **Crystal Red Shrimp**, **Yellow Shrimp**, **Orange Sakura Shrimp**, **Bamboo Shrimp**, **Vampire Shrimp**
- Added amphibian copper + salt warnings to: **African Dwarf Frog**, **Thai Micro Crab**, **Axolotl**
- Added coldwater ich treatment warning to: **Common Goldfish**, **Fancy Goldfish**, **White Cloud Mountain Minnow**, **Golden White Cloud**
- Added coldwater + loach sensitivity warnings to: **Hillstream Loach** (dual warning)

### `lib/data/lessons/advanced_topics.dart`
- Ich bullet in Emergency Scenarios: added explicit TROPICAL FISH ONLY designation, prominent coldwater warning (do not heat above 24°C/75°F), medication-only recommendation for coldwater species
- Quiz question `at_trouble_q2`: narrowed question to "TROPICAL fish tank"; updated explanation to include coldwater warning

### `lib/data/lessons/fish_health.dart`
- Ich treatment steps: added prominent coldwater fish warning at the top of Step 1, updated Step 2 to explicitly exclude coldwater/loaches/corydoras from salt, expanded Step 3 to cover copper-free options for sensitive species
- Quiz question `fh_ich_q2`: narrowed to "TROPICAL fish tank"; updated explanation with coldwater warning

### `lib/screens/species_browser_screen.dart`
- Added "Treatment Warnings" section to species detail view that renders `medicationWarnings` as prominent red-background cards when present

---

*Sweep completed: 2026-03-29 by Pythia subagent (Wave 1A)*
