# Micro-Lessons Redesign: Bite-Sized Daily Learning

## Overview
Transforming 12 comprehensive lessons (4-6 min each) into **48 micro-lessons** (60-90 seconds each) for daily habit formation.

**Target:** 48 micro-lessons across 5 learning paths
**Reading Time:** 60-90 seconds per lesson (~150-250 words)
**XP per Lesson:** 10-20 XP (down from 50 XP)
**Exercise per Lesson:** 1 focused interactive exercise

---

## Design Philosophy

### Why Micro-Lessons?
- **Daily habit formation**: Easy to complete one lesson per day
- **Lower friction**: 90 seconds vs 5 minutes reduces abandonment
- **Bite-sized learning**: Single concept per lesson = better retention
- **Progress satisfaction**: 48 achievements vs 12 = more dopamine hits
- **Mobile-first**: Perfect for quick phone sessions

### Content Strategy
Each micro-lesson follows this structure:
1. **Hook** (1 sentence): Grab attention immediately
2. **Core Concept** (2-3 paragraphs): One focused idea
3. **Key Takeaway** (1 highlight box): The thing to remember
4. **Exercise** (1 interactive): Reinforce the concept
5. **XP Reward** (10-20): Instant gratification

---

## Exercise Types

### Implemented (Current Model)
- **Multiple Choice**: 4 options, 1 correct answer

### Needed (Model Extension Required)
- **True/False**: Binary choice, great for debunking myths
- **Fill-in-the-Blank**: Type missing word/number
- **Matching**: Connect items in two columns (e.g., parameter → safe range)
- **Ordering**: Arrange steps in correct sequence
- **Image Selection**: Tap the correct item in an image

### Model Changes Required
```dart
enum ExerciseType {
  multipleChoice,
  trueFalse,
  fillBlank,
  matching,
  ordering,
  imageSelection,
}

class Exercise {
  final String id;
  final ExerciseType type;
  final String prompt;
  
  // Multiple Choice / True-False
  final List<String>? options;
  final int? correctIndex;
  
  // Fill-in-the-Blank
  final String? correctAnswer;
  final bool? caseSensitive;
  
  // Matching
  final Map<String, String>? pairs;
  
  // Ordering
  final List<String>? correctOrder;
  
  // Image Selection
  final String? imageUrl;
  final List<TapRegion>? correctRegions;
  
  final String? explanation;
}
```

---

## 🔄 Path 1: Nitrogen Cycle (14 micro-lessons)

### Module 1.1: The Hidden Killer (4 lessons)

#### Lesson 1.1.1: "Why Fish Die in New Tanks"
**Duration:** 90 seconds | **XP:** 10

**Content:**
You buy a beautiful new tank, fill it with water, add some fish... and within a week, they're dead. This is New Tank Syndrome, and it's the #1 killer of aquarium fish.

Fish produce waste. That waste breaks down into ammonia - a toxic chemical that burns fish gills. In nature, beneficial bacteria consume this ammonia instantly. In a new tank, those bacteria don't exist yet.

The solution? Cycling your tank means growing these bacteria BEFORE adding fish. It takes 2-6 weeks, but it prevents heartbreak.

**Key Point:** New tanks = no bacteria = ammonia buildup = dead fish

**Exercise Type:** Multiple Choice
- Question: "What is New Tank Syndrome?"
- Options:
  1. When a tank leaks water
  2. Fish dying due to lack of beneficial bacteria ✓
  3. Algae growing too fast
  4. The tank being too cold
- Explanation: "New Tank Syndrome occurs when toxic ammonia builds up because beneficial bacteria haven't established yet."

---

#### Lesson 1.1.2: "The Invisible Killer"
**Duration:** 60 seconds | **XP:** 10

**Content:**
Here's the scary part: ammonia is completely invisible. Your water can look crystal clear while being deadly toxic.

You can't see it. You can't smell it (at aquarium levels). The only way to know if your water is safe is to test it with a liquid test kit.

Even low levels are dangerous. Just 0.25 ppm can stress fish. Above 1 ppm is often fatal within hours.

**Key Point:** Clear water ≠ safe water. Always test!

**Exercise Type:** True/False
- Statement: "You can tell if water has ammonia just by looking at it"
- Answer: FALSE
- Explanation: "Ammonia is colorless and odorless at typical aquarium levels. Only a test kit can detect it."

---

#### Lesson 1.1.3: "What Produces Ammonia?"
**Duration:** 75 seconds | **XP:** 10

**Content:**
Ammonia comes from three main sources in your tank:

1. **Fish waste** - Every time fish poop or pee, ammonia is produced
2. **Uneaten food** - That food you overfed? It decays into ammonia
3. **Decaying plants** - Dead leaves break down and release ammonia

More fish = more waste = more ammonia. This is why you can't just fill a new tank with fish. The bacteria colony needs time to grow large enough to handle the bioload.

**Key Point:** Everything organic that decays in your tank produces ammonia

**Exercise Type:** Fill-in-the-Blank
- Prompt: "The three sources of ammonia are fish waste, uneaten _____, and decaying plants."
- Answer: "food"
- Explanation: "Uneaten food decays and produces ammonia, which is why overfeeding is dangerous."

---

#### Lesson 1.1.4: "How Long to Cycle?"
**Duration:** 90 seconds | **XP:** 15

**Content:**
"How long until I can add fish?" is every beginner's question. The honest answer: 2-6 weeks for most tanks.

Week 1-2: Ammonia-eating bacteria (Nitrosomonas) start growing
Week 2-4: Nitrite-eating bacteria (Nitrobacter) catch up
Week 4-6: Both colonies stabilize

You can speed it up slightly with bottled bacteria (like Seachem Stability), but there's no magic shortcut. The bacteria need time to multiply.

**Key Point:** Patience is the most important skill in fishkeeping

**Exercise Type:** Multiple Choice
- Question: "How long does it typically take to cycle a new tank?"
- Options:
  1. 1-2 days
  2. 2-6 weeks ✓
  3. 6 months
  4. Tanks don't need cycling
- Explanation: "Cycling typically takes 2-6 weeks. Rushing this phase is the #1 reason new fishkeepers lose fish."

---

### Module 1.2: The Three Stages (5 lessons)

#### Lesson 1.2.1: "Stage 1 - Ammonia"
**Duration:** 75 seconds | **XP:** 10

**Content:**
Ammonia (NH₃) is the first stage of the nitrogen cycle. It's what fish waste immediately breaks down into.

At the start of cycling, ammonia levels rise quickly because nothing is consuming it. In a fishless cycle, you'll see it spike to 2-4 ppm.

Ammonia is highly toxic:
- 0-0.25 ppm: Safe
- 0.25-1 ppm: Stressful
- 1+ ppm: Often fatal

This is the danger zone for new tanks.

**Key Point:** Ammonia is stage 1 - highly toxic to fish

**Exercise Type:** True/False
- Statement: "Ammonia levels above 1 ppm are safe for fish"
- Answer: FALSE
- Explanation: "Ammonia above 1 ppm is often fatal. Even 0.25 ppm causes stress."

---

#### Lesson 1.2.2: "Stage 2 - Nitrite"
**Duration:** 90 seconds | **XP:** 10

**Content:**
After 1-2 weeks, bacteria called Nitrosomonas start consuming your ammonia. Great news! But they produce nitrite (NO₂) as a byproduct. Bad news: nitrite is also toxic!

Nitrite prevents fish blood from carrying oxygen - called "brown blood disease." Fish can survive low ammonia better than nitrite spikes.

The nitrite stage is often the most dangerous phase of cycling. You'll see ammonia drop to zero, then nitrite spike to 2-5 ppm. Don't add fish yet!

**Key Point:** Ammonia drops → Nitrite spikes. Both are toxic!

**Exercise Type:** Multiple Choice
- Question: "What do Nitrosomonas bacteria convert ammonia into?"
- Options:
  1. Oxygen
  2. Nitrate
  3. Nitrite ✓
  4. Carbon dioxide
- Explanation: "Nitrosomonas convert ammonia to nitrite - which is still toxic and requires a second type of bacteria."

---

#### Lesson 1.2.3: "Stage 3 - Nitrate"
**Duration:** 75 seconds | **XP:** 10

**Content:**
A second type of bacteria (Nitrobacter) converts nitrite into nitrate (NO₃). Nitrate is much less toxic - fish can tolerate 20-40 ppm.

When you see nitrate appear in your tests, celebrate! It means both bacteria colonies are working.

But here's the catch: nitrate doesn't just disappear. It slowly builds up over time. At high levels (80+ ppm), it stresses fish and fuels algae.

That's why we do water changes - to export nitrate.

**Key Point:** Nitrate = end product. Safe at low levels, removed by water changes.

**Exercise Type:** Fill-in-the-Blank
- Prompt: "Fish can tolerate nitrate levels up to _____ ppm."
- Answer: "20-40" or "40"
- Explanation: "Nitrate is much less toxic than ammonia or nitrite. Most fish handle 20-40 ppm fine."

---

#### Lesson 1.2.4: "The Correct Order"
**Duration:** 60 seconds | **XP:** 15

**Content:**
The nitrogen cycle always follows the same order:

**Fish Waste → Ammonia → Nitrite → Nitrate → Water Change**

Think of it like a relay race. Each bacteria type hands off to the next. If one team is missing (no bacteria), the toxic stuff piles up.

A fully cycled tank has both bacteria teams working 24/7 to keep ammonia and nitrite at zero.

**Key Point:** Ammonia → Nitrite → Nitrate (memorize this!)

**Exercise Type:** Ordering
- Prompt: "Arrange the nitrogen cycle in the correct order:"
- Items to order:
  1. "Fish produce waste"
  2. "Ammonia forms"
  3. "Bacteria convert to nitrite"
  4. "Bacteria convert to nitrate"
  5. "Water changes remove nitrate"
- Explanation: "The cycle always follows this order. Each step depends on the previous one."

---

#### Lesson 1.2.5: "Testing the Stages"
**Duration:** 90 seconds | **XP:** 10

**Content:**
During cycling, you'll test your water every 2-3 days and watch this pattern:

**Week 1:** Ammonia rises (2-4 ppm)
**Week 2:** Ammonia drops, Nitrite spikes (2-5 ppm)
**Week 3-4:** Nitrite drops, Nitrate appears (10-20 ppm)
**Week 4-6:** Ammonia 0, Nitrite 0, Nitrate present = CYCLED!

This pattern tells you the bacteria are growing. If you see ammonia and nitrite both at zero with nitrate present, your tank is ready for fish.

**Key Point:** Zero ammonia + Zero nitrite + Nitrate present = Fully cycled!

**Exercise Type:** Multiple Choice
- Question: "How do you know your tank is fully cycled?"
- Options:
  1. The water looks clear
  2. It's been running for a week
  3. Ammonia and nitrite are 0, nitrate is present ✓
  4. The filter is making bubbles
- Explanation: "A cycled tank processes ammonia all the way to nitrate. The presence of nitrate with zero ammonia/nitrite proves both bacteria colonies are established."

---

### Module 1.3: How to Cycle (5 lessons)

#### Lesson 1.3.1: "Fishless vs Fish-In Cycling"
**Duration:** 90 seconds | **XP:** 10

**Content:**
Old method: Add "hardy" fish and hope they survive the ammonia spike. This is cruel and often kills fish.

Modern method: Fishless cycling. You add ammonia from a bottle (or decaying fish food) to feed the bacteria, without risking any fish lives.

Fishless cycling takes the same time (2-6 weeks) but is humane and actually more reliable. You can maintain higher ammonia levels to grow more bacteria faster.

**Key Point:** Fishless cycling = no suffering. Always the better choice.

**Exercise Type:** True/False
- Statement: "Fish-in cycling is the recommended method for beginners"
- Answer: FALSE
- Explanation: "Fish-in cycling is outdated and cruel. Modern fishless cycling is more humane and more effective."

---

#### Lesson 1.3.2: "What You Need"
**Duration:** 75 seconds | **XP:** 10

**Content:**
Shopping list for fishless cycling:

1. **Test Kit** - API Master Test Kit is the gold standard (liquid tests, not strips)
2. **Ammonia Source** - Pure ammonia (no additives) OR fish food
3. **Patience** - Can't skip this one!
4. **Running Filter** - Bacteria need surface area and water flow

Optional but helpful:
- Bottled bacteria (Seachem Stability, Dr. Tim's)
- Heater (warm water = faster bacteria growth)

**Key Point:** Test kit is mandatory. You're flying blind without it.

**Exercise Type:** Multiple Choice
- Question: "What is the most essential tool for cycling a tank?"
- Options:
  1. Heater
  2. Live plants
  3. Water test kit ✓
  4. LED lights
- Explanation: "You can't cycle without knowing your ammonia/nitrite/nitrate levels. A test kit is mandatory."

---

#### Lesson 1.3.3: "Adding the Ammonia"
**Duration:** 90 seconds | **XP:** 10

**Content:**
You need to "feed" the growing bacteria. Two methods:

**Method 1: Pure Ammonia**
Add ammonia until your test reads 2-4 ppm. Use pure ammonia with no surfactants or perfumes (check ingredient list - should be just ammonia and water).

**Method 2: Fish Food**
Drop a pinch of fish food in the tank daily. It decays and releases ammonia. Less precise but it works.

Don't go over 4 ppm - too much ammonia actually slows bacteria growth.

**Key Point:** Target 2-4 ppm ammonia to start the cycle

**Exercise Type:** Fill-in-the-Blank
- Prompt: "During fishless cycling, you should maintain ammonia at _____ ppm."
- Answer: "2-4"
- Explanation: "2-4 ppm provides enough food for bacteria without overdoing it. Higher levels can inhibit bacteria growth."

---

#### Lesson 1.3.4: "The Waiting Game"
**Duration:** 75 seconds | **XP:** 10

**Content:**
Once you've added ammonia, resist the urge to do anything! Let the bacteria work.

**Your job:**
- Test every 2-3 days
- Keep ammonia at 2-4 ppm (add more as it drops)
- Wait for nitrite spike
- Wait for nitrite to drop
- Watch nitrate appear

**Don't:**
- Do water changes (you'll remove the ammonia bacteria need)
- Add fish early
- mess with pH or other parameters
- give up!

The bacteria will come. Sometimes it takes 6 weeks. That's okay.

**Key Point:** Patience! Your only job is testing and adding ammonia.

**Exercise Type:** True/False
- Statement: "You should do daily water changes during cycling"
- Answer: FALSE
- Explanation: "Water changes remove the ammonia that bacteria need to grow. Only do water changes if ammonia exceeds 5 ppm (toxic to even bacteria)."

---

#### Lesson 1.3.5: "Adding Fish Gradually"
**Duration:** 90 seconds | **XP:** 15

**Content:**
Your tests show 0 ammonia, 0 nitrite, 20 ppm nitrate. You're cycled! But don't add all your fish at once.

**The right way:**
1. Do a 50% water change to reduce nitrate
2. Add 25% of your planned fish
3. Test daily for a week
4. If ammonia/nitrite stay at zero, add another 25%
5. Repeat until fully stocked

Your bacteria colony grew to match the ammonia you were adding. Adding too many fish at once overloads it.

**Key Point:** Add fish gradually over 2-4 weeks to let bacteria catch up

**Exercise Type:** Multiple Choice
- Question: "After cycling, should you add all your fish at once?"
- Options:
  1. Yes, the tank is ready
  2. No, add them gradually over weeks ✓
  3. Only if they're small fish
  4. It doesn't matter
- Explanation: "Your bacteria colony needs time to grow to match increased waste production. Stock gradually over 2-4 weeks."

---

## 💧 Path 2: Water Parameters (11 micro-lessons)

### Module 2.1: pH Basics (4 lessons)

#### Lesson 2.1.1: "What is pH?"
**Duration:** 75 seconds | **XP:** 10

**Content:**
pH measures how acidic or alkaline (basic) your water is. The scale runs from 0 (battery acid) to 14 (drain cleaner), with 7 being neutral.

Most tap water is between pH 6.5-8.0. Most tropical fish thrive in this range too. 

The pH scale is logarithmic - pH 6 is 10x more acidic than pH 7. Small numbers, big differences!

**Key Point:** pH 7 = neutral. Lower = acidic. Higher = alkaline.

**Exercise Type:** Multiple Choice
- Question: "What pH is considered neutral?"
- Options:
  1. 0
  2. 5
  3. 7 ✓
  4. 14
- Explanation: "pH 7 is neutral - neither acidic nor alkaline. Pure water has pH 7."

---

#### Lesson 2.1.2: "Stability Over Perfection"
**Duration:** 90 seconds | **XP:** 15

**Content:**
Here's the secret most beginners don't know: **stable pH is way more important than "perfect" pH**.

Fish can adapt to a wide range of pH (usually 6.0-8.0). But sudden swings stress them badly. A fish that lives happily at pH 7.8 can die if you suddenly change it to pH 7.0.

Think of it like temperature for humans. You can adapt to living in different climates (cold Alaska, hot Arizona), but if someone moved you between them daily, you'd get sick!

**Key Point:** Keep pH stable. Don't chase perfection.

**Exercise Type:** True/False
- Statement: "Stable pH is more important than having exactly pH 7.0"
- Answer: TRUE
- Explanation: "Fish adapt to various pH levels, but sudden changes cause stress and death. Stability beats perfection."

---

#### Lesson 2.1.3: "Avoid pH Adjusters"
**Duration:** 75 seconds | **XP:** 10

**Content:**
Walk into any fish store and you'll see bottles of "pH Up" and "pH Down." Avoid them!

These chemicals cause temporary changes that wear off, leading to dangerous pH swings. You end up on a chemical treadmill, constantly dosing.

**Better approach:** Test your tap water. That's your baseline. Choose fish that thrive at that pH rather than fighting to change it.

**Key Point:** Work with your tap water, not against it

**Exercise Type:** Multiple Choice
- Question: "What's the best way to manage pH?"
- Options:
  1. Use pH adjusters daily
  2. Choose fish suited to your tap water pH ✓
  3. Add vinegar to lower pH
  4. Add baking soda to raise pH
- Explanation: "Chemicals cause swings. Stock fish that match your water's natural pH instead of fighting chemistry."

---

#### Lesson 2.1.4: "pH for Different Fish"
**Duration:** 90 seconds | **XP:** 10

**Content:**
While most fish tolerate pH 6.5-7.5, some have preferences:

**Prefer Acidic (6.0-6.8):**
- Tetras (neon, cardinal, rummy nose)
- Discus
- Ram cichlids
- Most South American fish

**Prefer Alkaline (7.5-8.5):**
- African cichlids (Lake Malawi, Tanganyika)
- Livebearers (guppies, mollies, platies)
- Goldfish

**Key Point:** Research your species! Match fish to your pH, not the other way around.

**Exercise Type:** Matching
- Prompt: "Match the fish to their preferred pH range:"
- Pairs:
  - "Neon tetras" → "Acidic (6.0-6.8)"
  - "African cichlids" → "Alkaline (7.5-8.5)"
  - "Guppies" → "Alkaline (7.5-8.5)"
  - "Discus" → "Acidic (6.0-6.8)"
- Explanation: "Different species evolved in different waters. Tetras come from acidic rivers; African cichlids from alkaline lakes."

---

### Module 2.2: Temperature Control (3 lessons)

#### Lesson 2.2.1: "Fish Are Cold-Blooded"
**Duration:** 75 seconds | **XP:** 10

**Content:**
Fish can't regulate their body temperature like humans. They're cold-blooded (ectothermic) - their body temperature matches the water.

This means:
- Cold water = slow metabolism, sluggish fish
- Warm water = fast metabolism, active fish
- Wrong temp = stressed, sick, or dead fish

Temperature is just as important as water quality!

**Key Point:** Fish depend entirely on their environment's temperature

**Exercise Type:** True/False
- Statement: "Fish can regulate their own body temperature like humans"
- Answer: FALSE
- Explanation: "Fish are cold-blooded (ectothermic). Their body temperature matches the water, so stable tank temperature is critical."

---

#### Lesson 2.2.2: "Temperature Ranges"
**Duration:** 90 seconds | **XP:** 10

**Content:**
Different fish need different temperatures:

**Tropical (most aquarium fish):** 24-28°C (75-82°F)
- Tetras, barbs, cichlids, bettas, gouramis

**Coldwater:** 18-22°C (64-72°F)
- Goldfish, white cloud minnows

**Warm water:** 26-30°C (79-86°F)
- Discus, some bettas

Never mix coldwater and tropical fish! Goldfish in a tropical tank are stressed by the heat.

**Key Point:** Most tropical fish need 24-28°C. Always research your species!

**Exercise Type:** Multiple Choice
- Question: "What temperature range do most tropical fish need?"
- Options:
  1. 10-15°C (50-59°F)
  2. 18-22°C (64-72°F)
  3. 24-28°C (75-82°F) ✓
  4. 30-35°C (86-95°F)
- Explanation: "Most tropical aquarium fish thrive at 24-28°C. Colder is for goldfish; hotter is usually only for treating disease."

---

#### Lesson 2.2.3: "Heaters and Thermometers"
**Duration:** 90 seconds | **XP:** 15

**Content:**
For tropical tanks, you need two things:

**1. A reliable heater**
- Size: 3-5 watts per liter (roughly 5W per gallon)
- Placement: Near filter outlet for even heat distribution
- Quality matters: Cheap heaters fail and cook fish

**2. A separate thermometer**
- Stick-on strip thermometers are inaccurate
- Use a glass or digital thermometer
- Don't trust the heater's dial!

Pro tip: Place heater horizontally near the bottom. Heat rises, ensuring even distribution.

**Key Point:** Heater + separate thermometer = must-haves for tropical tanks

**Exercise Type:** Fill-in-the-Blank
- Prompt: "You need approximately _____ watts per liter for an aquarium heater."
- Answer: "3-5" or "5"
- Explanation: "3-5 watts per liter (roughly 5W per gallon) is the standard sizing for aquarium heaters."

---

### Module 2.3: Water Hardness (4 lessons)

#### Lesson 2.3.1: "What is Hardness?"
**Duration:** 75 seconds | **XP:** 10

**Content:**
Water hardness measures the mineral content in your water - mainly calcium and magnesium.

**Hard water** = lots of minerals (like London tap water)
**Soft water** = few minerals (like rainwater)

There are two types:
- **GH** (General Hardness): Total calcium and magnesium
- **KH** (Carbonate Hardness): Carbonates that buffer pH

Both matter for fish health!

**Key Point:** Hardness = minerals in water. GH and KH are different things.

**Exercise Type:** Multiple Choice
- Question: "What do GH and KH measure?"
- Options:
  1. pH levels
  2. Temperature
  3. Mineral content ✓
  4. Ammonia levels
- Explanation: "GH measures total hardness (calcium/magnesium). KH measures carbonates that stabilize pH."

---

#### Lesson 2.3.2: "GH - General Hardness"
**Duration:** 90 seconds | **XP:** 10

**Content:**
GH measures calcium and magnesium ions. Fish need these minerals for:
- Healthy bones and scales
- Egg development
- Osmoregulation (water balance in their bodies)

**GH Ranges:**
- 0-4 dGH: Very soft
- 4-8 dGH: Soft
- 8-12 dGH: Medium
- 12-18 dGH: Hard
- 18+ dGH: Very hard

Most tropical fish do fine in 4-12 dGH.

**Key Point:** GH = total minerals. Most fish adapt to a wide range.

**Exercise Type:** True/False
- Statement: "Soft water has more minerals than hard water"
- Answer: FALSE
- Explanation: "Soft water has fewer minerals (low GH). Hard water has lots of dissolved calcium and magnesium."

---

#### Lesson 2.3.3: "KH - The pH Buffer"
**Duration:** 90 seconds | **XP:** 15

**Content:**
KH (carbonate hardness) measures carbonates and bicarbonates. These act as a pH buffer - they prevent pH swings.

High KH = stable pH (hard to change)
Low KH = unstable pH (swings easily)

**Danger zone:** KH below 3 dKH can cause overnight pH crashes, especially in planted tanks. Plants release CO2 at night, which lowers pH. Without KH to buffer it, pH can drop dangerously.

**Key Point:** KH keeps pH stable. Low KH = risky pH swings.

**Exercise Type:** Multiple Choice
- Question: "What does KH help stabilize?"
- Options:
  1. Temperature
  2. pH ✓
  3. Ammonia
  4. Nitrate
- Explanation: "KH (carbonate hardness) acts as a pH buffer, preventing dangerous pH swings. Low KH tanks are unstable."

---

#### Lesson 2.3.4: "Hardness for Different Fish"
**Duration:** 90 seconds | **XP:** 10

**Content:**
Like pH, different fish prefer different hardness:

**Prefer Soft Water (2-8 dGH):**
- Tetras
- Discus
- Bettas
- South American fish

**Prefer Hard Water (10-20 dGH):**
- Livebearers (guppies, mollies, platies)
- African cichlids
- Goldfish

**Test your tap water first!** Your water company may have data online. Then choose compatible fish.

**Key Point:** Match fish to your water's natural hardness

**Exercise Type:** Matching
- Prompt: "Match fish to their preferred water hardness:"
- Pairs:
  - "Guppies and mollies" → "Hard water (10-20 dGH)"
  - "Tetras and bettas" → "Soft water (2-8 dGH)"
  - "African cichlids" → "Hard water (10-20 dGH)"
  - "Discus" → "Soft water (2-8 dGH)"
- Explanation: "Livebearers and African cichlids evolved in hard water. Tetras and discus come from soft rainforest waters."

---

## 🐠 Path 3: First Fish (7 micro-lessons)

### Module 3.1: Choosing Species (4 lessons)

#### Lesson 3.1.1: "Not All Fish Are Equal"
**Duration:** 75 seconds | **XP:** 10

**Content:**
Some fish forgive beginner mistakes. Others die at the slightest water quality issue.

**Hardy beginner fish:**
- Tolerate parameter swings
- Adapt to various water conditions
- Don't have special diet needs
- Peaceful temperaments

**Delicate expert fish:**
- Need pristine water quality
- Specific pH/hardness requirements
- Specialized diets
- Aggressive or sensitive behaviors

Start with hardy species that can handle your learning curve!

**Key Point:** Not all "beginner fish" are actually beginner-friendly. Research first!

**Exercise Type:** True/False
- Statement: "All fish sold in pet stores are suitable for beginners"
- Answer: FALSE
- Explanation: "Many stores sell difficult fish to beginners. Always research care requirements before buying."

---

#### Lesson 3.1.2: "Great Starter Fish"
**Duration:** 90 seconds | **XP:** 10

**Content:**
Here are genuinely beginner-friendly species:

**Livebearers:**
- Guppies (colorful, active, breed easily)
- Platies (peaceful, many colors)
- Mollies (larger, beautiful)

**Schooling fish:**
- Zebra danios (very hardy, active)
- Cherry barbs (peaceful, beautiful red color)

**Bottom dwellers:**
- Corydoras catfish (adorable, social)
- Bristlenose plecos (algae eaters, stay small)

All of these tolerate beginner mistakes and have peaceful temperaments.

**Key Point:** These species are forgiving and perfect for learning

**Exercise Type:** Multiple Choice
- Question: "Which of these is a great beginner fish?"
- Options:
  1. Discus
  2. Oscar
  3. Corydoras catfish ✓
  4. Common pleco
- Explanation: "Corydoras are hardy, peaceful, and forgiving of water parameter swings. Discus and oscars need expert care."

---

#### Lesson 3.1.3: "Fish to Avoid"
**Duration:** 90 seconds | **XP:** 10

**Content:**
These fish are tempting but NOT beginner-friendly:

**❌ Discus** - Need pH 6.0-6.5, 30°C, pristine water
**❌ Oscars** - Grow to 30cm+, need 200L+ tanks, aggressive
**❌ Common plecos** - Grow to 60cm, massive waste producers
**❌ Goldfish in tropical tanks** - Need coldwater (18-22°C)
**❌ Chinese algae eaters** - Become aggressive, attack fish

Save these for when you have experience!

**Key Point:** If a fish has "special requirements," it's not beginner-friendly

**Exercise Type:** True/False
- Statement: "Oscars are good beginner fish because they're sold as babies"
- Answer: FALSE
- Explanation: "Oscars grow to 30cm+ and need massive tanks (200L+). Many beginners buy them as cute babies and can't house them as adults."

---

#### Lesson 3.1.4: "Research Before Buying"
**Duration:** 75 seconds | **XP:** 15

**Content:**
Before buying ANY fish, research:

1. **Adult size** - That 2cm baby might grow to 30cm
2. **Tank size needed** - Minimum volume in liters/gallons
3. **Temperature range** - Tropical or coldwater?
4. **Compatibility** - Peaceful or aggressive? Schooling or solo?
5. **Diet** - Special food requirements?
6. **Lifespan** - Are you ready for a 10+ year commitment?

Write down your planned species and tank size. Double-check compatibility. Don't impulse buy!

**Key Point:** 10 minutes of research prevents months of heartbreak

**Exercise Type:** Fill-in-the-Blank
- Prompt: "Before buying a fish, you must research its _____ size, not just its baby size."
- Answer: "adult"
- Explanation: "Many fish sold as babies grow huge. Always research adult size before buying!"

---

### Module 3.2: Bringing Fish Home (3 lessons)

#### Lesson 3.2.1: "The Journey Stresses Fish"
**Duration:** 75 seconds | **XP:** 10

**Content:**
Imagine being scooped out of your home, sealed in a bag, driven around in a car, then dumped into a completely different environment. Stressful, right?

Fish experience this every time they're bought. The stress makes them vulnerable to disease and shock.

Your job: minimize that stress through proper acclimation. Give their bodies time to adjust to new temperature, pH, and hardness.

**Key Point:** Acclimation isn't optional. It can mean life or death.

**Exercise Type:** True/False
- Statement: "You can dump fish straight into your tank if you bought them nearby"
- Answer: FALSE
- Explanation: "Even a short trip causes stress. Store water and your tank water have different temperatures and chemistry. Always acclimate!"

---

#### Lesson 3.2.2: "Float Method"
**Duration:** 90 seconds | **XP:** 10

**Content:**
Float method is the simple acclimation technique:

**Step 1:** Float the sealed bag in your tank for 15-20 minutes
- This equalizes temperature slowly

**Step 2:** Open bag, add 1 cup of tank water
- Wait 5 minutes

**Step 3:** Add another cup of tank water
- Wait 5 minutes

**Step 4:** Repeat 2-3 more times over 30-45 minutes
- This gradually adjusts pH and hardness

**Step 5:** Net the fish out, add to tank
- Discard bag water! Don't add it to your tank.

**Key Point:** Slow and steady. 30-45 minutes minimum.

**Exercise Type:** Multiple Choice
- Question: "What does floating the bag accomplish?"
- Options:
  1. Removes chlorine
  2. Feeds the fish
  3. Equalizes temperature ✓
  4. Adds oxygen
- Explanation: "Floating allows the bag water temperature to slowly match your tank temperature, preventing temperature shock."

---

#### Lesson 3.2.3: "Never Add Store Water"
**Duration:** 90 seconds | **XP:** 15

**Content:**
**Critical rule:** NEVER pour bag water into your tank!

Store water can contain:
- Diseases and parasites from other tanks
- Medications that harm your beneficial bacteria
- High ammonia from the stressed fish
- Unwanted hitchhikers (snails, planaria)

Always net the fish out and discard the bag water. It's not worth the risk.

Also: Keep lights dim for the first few hours. Stressed fish need time to explore and find hiding spots without bright lights.

**Key Point:** Net the fish, dump the water. Every single time.

**Exercise Type:** Multiple Choice
- Question: "Why should you never add store bag water to your tank?"
- Options:
  1. It's too cold
  2. It may contain diseases or parasites ✓
  3. It has too much oxygen
  4. It's the wrong color
- Explanation: "Store water may carry diseases, parasites, or medications from other tanks. Only add the fish, never the water."

---

## 🧹 Path 4: Tank Maintenance (8 micro-lessons)

### Module 4.1: Water Changes (4 lessons)

#### Lesson 4.1.1: "Why Water Changes?"
**Duration:** 75 seconds | **XP:** 10

**Content:**
Your filter removes particles and processes ammonia/nitrite, but nitrate still builds up. Water changes are the ONLY way to remove it.

Water changes also:
- Replenish trace minerals fish need
- Remove dissolved organic compounds (DOCs)
- Dilute hormones and growth inhibitors
- Make water sparkle clear

Think of it like changing the oil in your car. The engine might run without it... but not for long.

**Key Point:** Water changes are the foundation of a healthy tank

**Exercise Type:** True/False
- Statement: "If your filter is working, you don't need water changes"
- Answer: FALSE
- Explanation: "Filters process ammonia but don't remove nitrate. Only water changes export nitrate and replenish minerals."

---

#### Lesson 4.1.2: "How Much, How Often?"
**Duration:** 90 seconds | **XP:** 10

**Content:**
The golden rule: **20-30% weekly**

This keeps nitrate low (<20 ppm) without shocking fish with big parameter swings.

**Can you do more?** Yes! 50% weekly is even better if your tap water matches your tank parameters.

**Can you do less?** In heavily planted tanks with low bioload, you might get away with 15% weekly. But 20-30% is the safe zone for most tanks.

**Never replace all the water** - that's a total reset that kills bacteria and shocks fish.

**Key Point:** 20-30% weekly = the sweet spot

**Exercise Type:** Multiple Choice
- Question: "How much water should you change weekly?"
- Options:
  1. 5-10%
  2. 20-30% ✓
  3. 50-75%
  4. 100%
- Explanation: "20-30% weekly maintains low nitrate without shocking fish with big parameter changes."

---

#### Lesson 4.1.3: "The Right Way"
**Duration:** 90 seconds | **XP:** 10

**Content:**
Step-by-step for safe water changes:

**1. Match temperature** - New water should feel the same as tank water (hand test works)

**2. Add dechlorinator** - Chlorine/chloramine in tap water kills bacteria and fish. ALWAYS dechlorinate.

**3. Use gravel vacuum** - Siphon water out while vacuuming debris from substrate

**4. Refill slowly** - Pour gently to avoid stirring up debris or stressing fish

**5. Test parameters** - Quick check that everything's stable

**Key Point:** Temperature matching and dechlorination are non-negotiable

**Exercise Type:** Fill-in-the-Blank
- Prompt: "Before adding tap water to your tank, you must add _____ to remove chlorine."
- Answer: "dechlorinator" or "water conditioner"
- Explanation: "Tap water contains chlorine/chloramine that kills beneficial bacteria and fish. Always dechlorinate first!"

---

#### Lesson 4.1.4: "Common Mistakes"
**Duration:** 75 seconds | **XP:** 15

**Content:**
**Mistake 1:** Changing water "when it looks dirty"
- Schedule it weekly whether it looks dirty or not. Nitrate is invisible!

**Mistake 2:** Forgetting dechlorinator
- One mistake can crash your cycle and kill fish

**Mistake 3:** Cold water straight from tap
- Temperature shock stresses or kills fish

**Mistake 4:** Vacuuming all substrate at once
- Spread it out over several weeks to preserve bacteria colonies

**Key Point:** Consistency beats perfection. Same day, same amount, every week.

**Exercise Type:** True/False
- Statement: "You only need to do water changes when the tank looks dirty"
- Answer: FALSE
- Explanation: "Nitrate buildup is invisible. Stick to a weekly schedule regardless of appearance."

---

### Module 4.2: Filter Maintenance (4 lessons)

#### Lesson 4.2.1: "Your Filter is Alive"
**Duration:** 90 seconds | **XP:** 10

**Content:**
Your filter isn't just a mechanical device - it's a living ecosystem!

Most of your beneficial bacteria live in the filter media:
- Sponges
- Ceramic rings
- Bio-balls
- Filter floss

These bacteria are processing ammonia and nitrite 24/7. They're what keeps your fish alive.

**Key Point:** Filter media = bacteria home. Treat it with care!

**Exercise Type:** Multiple Choice
- Question: "Where do most beneficial bacteria live?"
- Options:
  1. In the water
  2. On decorations
  3. In the filter media ✓
  4. In the substrate
- Explanation: "The filter provides constant water flow and surface area, making it the primary home for beneficial bacteria colonies."

---

#### Lesson 4.2.2: "The Cardinal Rule"
**Duration:** 90 seconds | **XP:** 15

**Content:**
**NEVER rinse filter media in tap water!**

Tap water contains chlorine/chloramine that kills beneficial bacteria instantly. One mistake can crash your cycle.

**The right way:**
1. During a water change, save some OLD tank water in a bucket
2. Remove filter media
3. Gently squeeze/swish in the old tank water
4. You're removing gunk, not sterilizing - it should still look "used"
5. Put media back
6. Discard the dirty water

**Key Point:** Old tank water only! Tap water = bacteria killer.

**Exercise Type:** True/False
- Statement: "It's okay to rinse filter sponges in tap water if you do it quickly"
- Answer: FALSE
- Explanation: "Even brief contact with chlorinated tap water kills beneficial bacteria. ALWAYS use old tank water."

---

#### Lesson 4.2.3: "When to Clean"
**Duration:** 75 seconds | **XP:** 10

**Content:**
**Don't over-clean your filter!** Only clean when flow is noticeably reduced.

Signs it's time:
- Water flow is weak
- Surface agitation decreased
- It's been 4-6 weeks
- Media is packed with visible gunk

**Not** signs to clean:
- It "looks dirty" (it should!)
- It's been 2 weeks
- You're bored

Monthly cleaning is usually enough for most tanks.

**Key Point:** Clean only when necessary. Over-cleaning harms bacteria.

**Exercise Type:** Multiple Choice
- Question: "How often should you clean filter media?"
- Options:
  1. Daily
  2. Weekly
  3. When flow is reduced (usually monthly) ✓
  4. Never
- Explanation: "Only clean when necessary - when you notice reduced flow. Over-cleaning harms the beneficial bacteria."

---

#### Lesson 4.2.4: "Replacing Media"
**Duration:** 90 seconds | **XP:** 10

**Content:**
**Sponges and bio-media** (ceramic rings, bio-balls) rarely need replacing. Just rinse and reuse for years!

**Activated carbon** should be replaced monthly if you use it (or just remove it - it's optional).

**If you must replace sponges:**
1. Only replace one at a time
2. Wait 3-4 weeks before replacing another
3. This preserves bacteria colonies

Many companies say "replace monthly" to sell more cartridges. Don't fall for it! Sponges last years.

**Key Point:** Don't replace media unless it's literally falling apart

**Exercise Type:** True/False
- Statement: "You should replace filter sponges every month as the manufacturer recommends"
- Answer: FALSE
- Explanation: "Manufacturers want to sell cartridges. Sponges last years - only replace if they're falling apart. Rinse and reuse!"

---

## 🌿 Path 5: Planted Tanks (8 micro-lessons)

### Module 5.1: Why Plants? (4 lessons)

#### Lesson 5.1.1: "Plants Are Filters"
**Duration:** 75 seconds | **XP:** 10

**Content:**
Live plants aren't just decoration - they're a natural filtration system!

Plants absorb:
- **Ammonia** - They prefer it over nitrate as a nitrogen source
- **Nitrate** - Their main fertilizer
- **CO2** - Produces oxygen during photosynthesis
- **Heavy metals** - Trace amounts that could harm fish

A heavily planted tank can have near-zero nitrate readings. The plants export it as they grow!

**Key Point:** Plants = living filters that work 24/7

**Exercise Type:** Multiple Choice
- Question: "How do plants help with water quality?"
- Options:
  1. They add oxygen only
  2. They absorb nitrate and ammonia ✓
  3. They make water harder
  4. They increase pH
- Explanation: "Plants absorb ammonia and nitrate as fertilizer, providing natural filtration and reducing algae."

---

#### Lesson 5.1.2: "Oxygen Production"
**Duration:** 90 seconds | **XP:** 10

**Content:**
Plants produce oxygen through photosynthesis - but only during daylight!

**Day:** Plants absorb CO2, release O2
**Night:** Plants consume O2, release CO2 (respiration)

This means heavily planted tanks can have oxygen swings. If your fish gasp at the surface in the morning, you might have too many plants with too little surface agitation.

**Solution:** Keep filter return or air stone running at night for gas exchange.

**Key Point:** Plants make oxygen during the day, consume it at night

**Exercise Type:** True/False
- Statement: "Plants produce oxygen 24 hours a day"
- Answer: FALSE
- Explanation: "Plants only photosynthesize (produce O2) during light hours. At night, they respire and consume oxygen like fish do."

---

#### Lesson 5.1.3: "Algae Competition"
**Duration:** 90 seconds | **XP:** 10

**Content:**
Algae and plants compete for the same resources:
- Light
- CO2
- Nutrients (nitrogen, phosphorus, potassium)

Healthy, fast-growing plants out-compete algae for these resources. This is why heavily planted tanks have less algae problems.

**The balance:** You need enough light and nutrients for plants, but not so much that excess feeds algae. It's a tightrope walk!

**Key Point:** Thriving plants = less algae. They compete for the same food.

**Exercise Type:** Fill-in-the-Blank
- Prompt: "Plants help control _____ by competing for nutrients and light."
- Answer: "algae"
- Explanation: "Plants and algae compete for the same resources. Healthy plants starve out algae."

---

#### Lesson 5.1.4: "Easy Starter Plants"
**Duration:** 90 seconds | **XP:** 15

**Content:**
Start with "low-tech" plants that don't need CO2 injection or high light:

**Attach to hardscape (don't bury roots!):**
- Java fern - indestructible, low light
- Anubias - slow growing, beautiful
- Java moss - great for shrimp

**Plant in substrate:**
- Amazon sword - impressive centerpiece
- Cryptocoryne - variety of sizes/colors
- Vallisneria - fast growing background

These tolerate beginner mistakes and thrive in regular aquarium conditions.

**Key Point:** Master low-tech plants before going high-tech

**Exercise Type:** Multiple Choice
- Question: "Which plant is best for beginners?"
- Options:
  1. Java fern ✓
  2. HC Cuba (carpet plant)
  3. Rotala macrandra
  4. Glossostigma
- Explanation: "Java fern is nearly indestructible, tolerates low light, and doesn't need CO2. The others need high-tech setups."

---

### Module 5.2: Light & Nutrients (4 lessons)

#### Lesson 5.2.1: "The Growth Triangle"
**Duration:** 90 seconds | **XP:** 10

**Content:**
Plants need three things to grow:
1. **Light** - Energy for photosynthesis
2. **CO2** - Carbon source
3. **Nutrients** - Nitrogen, phosphorus, iron, etc.

These must be **balanced**. Too much light without CO2/nutrients = algae explosion!

Think of it like ingredients in a recipe. You can't compensate for missing eggs by adding more flour.

**Key Point:** Light, CO2, and nutrients must be balanced

**Exercise Type:** True/False
- Statement: "More light always means better plant growth"
- Answer: FALSE
- Explanation: "Excess light without balanced CO2 and nutrients feeds algae instead of plants. Balance is everything."

---

#### Lesson 5.2.2: "Lighting Basics"
**Duration:** 90 seconds | **XP:** 10

**Content:**
For low-tech planted tanks, aim for:
- **6-8 hours** of light per day
- **Moderate intensity** (20-30 lumens per liter)
- **Consistent schedule** (use a timer!)

Too much light (10+ hours or high intensity) without CO2 injection triggers algae blooms.

**Timer is essential!** Plants and algae both need consistent photoperiods. Random light schedules confuse plant biology and favor algae.

**Key Point:** 6-8 hours on a timer. Consistency prevents algae.

**Exercise Type:** Multiple Choice
- Question: "Why is a light timer essential for planted tanks?"
- Options:
  1. To save electricity
  2. Consistent photoperiod prevents algae ✓
  3. Fish need darkness to sleep
  4. All of the above
- Explanation: "While all are benefits, consistency is the key reason. Plants and algae both respond to photoperiod. Randomness favors algae."

---

#### Lesson 5.2.3: "Nutrients Basics"
**Duration:** 90 seconds | **XP:** 10

**Content:**
Plants need **macro** and **micro** nutrients:

**Macros (NPK):**
- Nitrogen (N) - From fish waste + fertilizer
- Phosphorus (P) - Fertilizer
- Potassium (K) - Fertilizer

**Micros:**
- Iron (Fe) - Keeps leaves green
- Manganese, zinc, boron, etc.

Fish waste provides some nitrogen, but planted tanks usually need supplements.

**Key Point:** Low-tech plants need less, but some fertilizer helps

**Exercise Type:** Fill-in-the-Blank
- Prompt: "The three main macronutrients plants need are nitrogen, phosphorus, and _____."
- Answer: "potassium"
- Explanation: "NPK (nitrogen, phosphorus, potassium) are the three macronutrients. Fish waste provides some nitrogen, but P and K usually need supplementing."

---

#### Lesson 5.2.4: "Root Tabs vs Liquid Ferts"
**Duration:** 90 seconds | **XP:** 15

**Content:**
Different plants eat differently:

**Root feeders** (feed from substrate):
- Amazon swords
- Cryptocoryne
- Vallisneria
- **Use:** Root tabs (push into substrate near roots)

**Column feeders** (feed from water):
- Stem plants
- Floating plants
- Java fern, anubias
- **Use:** Liquid fertilizers (dose into water weekly)

**For beginners:** Get an all-in-one liquid fertilizer. Dose once weekly at half the recommended amount. Less is more!

**Key Point:** Root tabs for heavy root feeders, liquid for everything else

**Exercise Type:** Matching
- Prompt: "Match the plant to its fertilizer type:"
- Pairs:
  - "Amazon sword" → "Root tabs"
  - "Java fern" → "Liquid fertilizer"
  - "Stem plants" → "Liquid fertilizer"
  - "Cryptocoryne" → "Root tabs"
- Explanation: "Root feeders need substrate fertilizer. Epiphyte plants (java fern, anubias) and stem plants feed from the water column."

---

## Implementation Plan

### Phase 1: Data Model Updates

#### New MicroLesson Model
```dart
@immutable
class MicroLesson extends Lesson {
  final int readingTimeSeconds; // 60-90 seconds
  final String moduleId; // Groups micro-lessons
  final Exercise exercise; // Single focused exercise
  
  const MicroLesson({
    required String id,
    required String pathId,
    required this.moduleId,
    required String title,
    required String description,
    required int orderIndex,
    required this.readingTimeSeconds,
    int xpReward = 10, // Lower XP per lesson
    required List<LessonSection> sections,
    required this.exercise,
    List<String> prerequisites = const [],
  }) : super(
    id: id,
    pathId: pathId,
    title: title,
    description: description,
    orderIndex: orderIndex,
    xpReward: xpReward,
    estimatedMinutes: 1, // Always 1-2 min
    sections: sections,
    quiz: null, // Replaced by exercise
    prerequisites: prerequisites,
  );
}
```

#### New Exercise Model
```dart
enum ExerciseType {
  multipleChoice,
  trueFalse,
  fillBlank,
  matching,
  ordering,
  imageSelection,
}

@immutable
class Exercise {
  final String id;
  final String lessonId;
  final ExerciseType type;
  final String prompt;
  final String? explanation;
  
  // Multiple Choice / True-False
  final List<String>? options;
  final int? correctIndex;
  
  // Fill-in-the-Blank
  final List<String>? acceptedAnswers; // Multiple correct answers
  final bool caseSensitive;
  
  // Matching
  final Map<String, String>? pairs;
  
  // Ordering
  final List<String>? correctOrder;
  
  // Image Selection
  final String? imageUrl;
  final List<TapRegion>? correctRegions;
  
  const Exercise({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.prompt,
    this.explanation,
    this.options,
    this.correctIndex,
    this.acceptedAnswers,
    this.caseSensitive = false,
    this.pairs,
    this.correctOrder,
    this.imageUrl,
    this.correctRegions,
  });
}
```

#### Module Grouping
```dart
@immutable
class LessonModule {
  final String id;
  final String pathId;
  final String title;
  final String description;
  final int orderIndex;
  final List<MicroLesson> lessons;
  
  const LessonModule({
    required this.id,
    required this.pathId,
    required this.title,
    required this.description,
    required this.orderIndex,
    required this.lessons,
  });
  
  int get totalXp => lessons.fold(0, (sum, l) => sum + l.xpReward);
}
```

### Phase 2: UI Adjustments

#### Lesson Screen Changes
- **Progress bar:** Show N of M micro-lessons in current module
- **Shorter content:** 2-3 short paragraphs max
- **Single exercise:** Replaces multi-question quiz
- **Module completion:** Celebrate finishing 3-5 related micro-lessons
- **Reading time:** Display "60 sec" instead of "4 min"

#### Home Screen Changes
- **Daily lesson:** One micro-lesson per day suggested
- **Streak tracking:** Consecutive days completing 1+ lesson
- **Module cards:** Show progress within modules (3/5 complete)

#### Progress Tracking
- Track micro-lesson completion separately
- Unlock achievements for completing modules
- Adjust XP curve (48 lessons × 10-15 XP = 480-720 total XP)

### Phase 3: Content Migration

#### Step 1: Create lesson_modules.dart
New file structure:
```dart
class LessonModules {
  static List<LessonModule> get allModules => [
    // Nitrogen Cycle modules
    nitrogenCycleHiddenKiller,
    nitrogenCycleThreeStages,
    nitrogenCycleHowToCycle,
    
    // Water Parameters modules
    waterParamsPHBasics,
    waterParamsTemperature,
    waterParamsHardness,
    
    // ... etc
  ];
}
```

#### Step 2: Migrate content from lesson_content.dart
- Split each existing lesson into 3-5 micro-lessons
- One concept per micro-lesson
- Add exercises (start with multiple choice, expand types later)
- Assign 10-20 XP per lesson

#### Step 3: Update LearningPath references
```dart
static final nitrogenCyclePath = LearningPath(
  id: 'nitrogen_cycle',
  title: 'The Nitrogen Cycle',
  description: 'The #1 thing every fishkeeper must understand.',
  emoji: '🔄',
  recommendedFor: [ExperienceLevel.beginner],
  orderIndex: 0,
  modules: [ // Changed from lessons
    nitrogenCycleHiddenKiller,    // 4 micro-lessons
    nitrogenCycleThreeStages,     // 5 micro-lessons
    nitrogenCycleHowToCycle,      // 5 micro-lessons
  ],
);
```

### Phase 4: Exercise Implementation

#### Priority Order:
1. **Multiple Choice** (already implemented) - ✅
2. **True/False** (simplest new type) - Week 1
3. **Fill-in-the-Blank** (typed input) - Week 2
4. **Matching** (drag-drop or tap pairs) - Week 3
5. **Ordering** (drag-drop sequence) - Week 4
6. **Image Selection** (future enhancement) - Week 5+

#### UI Components Needed:
- `TrueFalseExerciseWidget`
- `FillBlankExerciseWidget`
- `MatchingExerciseWidget`
- `OrderingExerciseWidget`

### Phase 5: Achievement Updates

New achievements for micro-lessons:
```dart
Achievement(
  id: 'first_micro',
  title: 'First Step',
  description: 'Complete your first micro-lesson',
  emoji: '📖',
  category: AchievementCategory.learning,
  tier: AchievementTier.bronze,
),
Achievement(
  id: 'module_complete',
  title: 'Module Master',
  description: 'Complete a full module',
  emoji: '📚',
  category: AchievementCategory.learning,
  tier: AchievementTier.silver,
),
Achievement(
  id: 'daily_learner',
  title: 'Daily Learner',
  description: 'Complete 1 micro-lesson per day for 7 days',
  emoji: '🔥',
  category: AchievementCategory.streak,
  tier: AchievementTier.gold,
),
```

---

## Content Summary

### Total Breakdown:
- **5 Learning Paths** (unchanged)
- **15 Modules** (3 per path on average)
- **48 Micro-Lessons** (3-5 per module)
- **48 Interactive Exercises** (1 per lesson)
- **Total XP:** ~600 XP (vs 600 XP in old system, but more granular)

### Reading Time:
- Old: 12 lessons × 4-6 min = 48-72 minutes total
- New: 48 micro-lessons × 60-90 sec = 48-72 minutes total
- **Same total time, but chunked into bite-sized pieces!**

### Daily Habit Target:
- 1 micro-lesson per day = 48 days to complete
- 2 micro-lessons per day = 24 days to complete
- Perfect for building daily engagement habit

---

## Next Steps

1. **Review this document** - Confirm content structure and breakdown
2. **Extend data models** - Add MicroLesson and Exercise models
3. **Implement exercise types** - Priority: TrueFalse, FillBlank, Matching
4. **Create lesson_modules.dart** - Migrate content with detailed writing
5. **Update UI** - Lesson screen, progress tracking, module grouping
6. **Test flow** - Complete entire nitrogen cycle path as a user
7. **Gather feedback** - Does 60-90 seconds feel right?

---

## Design Decisions

### Why 48 instead of 40 or 50?
- Natural breakdown: most lessons split into 3-4 micro-lessons
- 48 = 3-4 per module × 3-4 modules per path × 5 paths
- Allows even distribution across paths

### Why 60-90 seconds?
- Mobile attention span sweet spot
- Long enough to convey one concept
- Short enough to complete during a commute
- **150-250 words** = comfortable reading pace

### Why 10-20 XP per lesson?
- Total XP remains similar (~600 XP)
- More frequent rewards = better dopamine hits
- Encourages daily habit ("just one more lesson")
- Allows bonus XP for perfect scores (10 base + 5 bonus)

### Why modules?
- Psychological grouping (3-5 related lessons)
- Milestone celebration (completing a module)
- Clearer learning path visualization
- Matches Duolingo-style progression

---

## Success Metrics

Track these to measure redesign success:
- **Completion rate:** % users who finish a full path
- **Daily active users:** Do micro-lessons increase daily engagement?
- **Streak length:** Average consecutive days with activity
- **Time to complete:** Days from first to last lesson
- **Lesson abandonment:** % who start but don't finish a lesson
- **User feedback:** Qualitative responses about lesson length

**Target improvements:**
- 2x completion rate (from ~30% to 60%)
- 3x daily active users
- 10+ day average streak
- <2% abandonment rate per lesson

---

## Questions for Review

1. Is 60-90 seconds the right target, or should we aim for 45-60 seconds?
2. Should some advanced lessons be longer (e.g., "How to Cycle" steps)?
3. Priority order for exercise types - agree with TrueFalse → FillBlank → Matching?
4. Should we keep old long-form lessons as "deep dive" bonus content?
5. Module titles - should they be more creative/engaging?
6. XP distribution - should harder concepts (nitrite spike) give more XP?

---

**Status:** Ready for review and implementation
**Last Updated:** 2025-02-07
**Version:** 1.0
