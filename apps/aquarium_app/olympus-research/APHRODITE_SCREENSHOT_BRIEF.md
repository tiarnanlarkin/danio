# Danio — Store Screenshot Capture Brief
> Written by: Aphrodite (Growth Agent)  
> Date: 2026-03-16  
> Target: Google Play Store — 7 portrait screenshots + Feature Graphic  
> Spec: 1080×1920px, 24-bit PNG, no alpha channel  
> Device: Samsung Z Fold (SM-F966B, serial: RFCY8022D5R) — inner foldable display (`--display 2`)

---

## ⚠️ Blocker Report — Current Capture Script

**`scripts/store_screenshots.sh` does not exist.**  
Only `scripts/qa_smoke.sh` and `scripts/quality_gates/run_all_checks.sh` are present.

**Blockers found in `qa_smoke.sh` (which would be adapted):**

| # | Blocker | Impact |
|---|---------|--------|
| 1 | `screencap -p` without `--display 2` — captures cover screen (~21KB) not inner display | All screenshots would be wrong display |
| 2 | Default device is `emulator-5554` — Z Fold has serial `RFCY8022D5R` | Will target wrong/no device |
| 3 | Script does `pm clear "$PKG"` at start — wipes all user data/XP/streaks | Test state would be wiped immediately |
| 4 | No state-seeding mechanism — no way to set XP=2450, streak=14 etc before capture | Screenshots would show empty/zero state |
| 5 | ADB path is Windows `.exe` — only works from WSL when Windows ADB is available | May fail in some WSL environments |
| 6 | No ImageMagick caption overlay step — just raw screenshots, no text overlays | Captions must be added in post |

**Resolution:** A new `scripts/store_screenshots.sh` must be created (see Section 8 below). Do NOT adapt `qa_smoke.sh` — it wipes app state.

---

## Global Specs

### ADB Command Template (Samsung Z Fold inner screen)
```bash
ADB="/mnt/c/Users/larki/AppData/Local/Android/Sdk/platform-tools/adb.exe"
DEVICE="RFCY8022D5R"
OUT="/mnt/c/Users/larki/Documents/Danio Aquarium App Project/store_screenshots"
# Capture inner display:
"$ADB" -s $DEVICE exec-out screencap --display 2 -p > "$OUT/XX_name.png"
```

### Caption Font Specs (apply to ALL screenshots)
- **Headline font:** Nunito ExtraBold (weight 800)
- **Subline font:** Nunito SemiBold (weight 600) or Lora Regular for warmer feel
- **Headline size:** 72–80px (at 1080px canvas width)
- **Subline size:** 42–48px
- **Headline colour:** `#FFFFFF` (white) with `rgba(0,0,0,0.45)` drop shadow, offset 0 4px, blur 12px
- **Subline colour:** `#FFF5E6` (warm white) or `#F5A623` (amber) depending on background darkness
- **Caption position:** Bottom third of image — headline at ~y=1480, subline at ~y=1580 (above safe zone)
- **Caption background:** Semi-transparent dark scrim — `rgba(20,12,5,0.55)` gradient, full-width, ~240px tall, fading upward
- **Padding:** 48px left/right

### ImageMagick Overlay Command Template
```bash
convert "$OUT/XX_raw.png" \
  -fill 'rgba(20,12,5,0.55)' -draw 'rectangle 0,1380 1080,1920' \
  -font 'Nunito-ExtraBold' -pointsize 76 -fill white \
  -annotate +48+1490 'HEADLINE TEXT HERE' \
  -font 'Nunito-SemiBold' -pointsize 44 -fill '#FFF5E6' \
  -annotate +48+1570 'Subline text here' \
  "$OUT/XX_final.png"
```
> Note: adjust y-values per screenshot based on background content. Install Nunito via `sudo apt install fonts-nunito` or place TTF files in `~/.fonts/`.

---

## Screenshot 1 — Lesson In Progress / Hero
> **Billboard rule: Must work as a standalone image in search results. The only screenshot most users will see.**

### 1. SCREEN TO CAPTURE
`LearnScreen` with a lesson card expanded/mid-lesson — specifically inside `lesson_screen.dart` showing a multiple-choice quiz question mid-lesson. The **"Nitrogen Cycle"** lesson is ideal (universal fishkeeping knowledge, visually compelling).

**Route:** Tab 0 (Learn) → tap "Nitrogen Cycle" learning path → tap first incomplete lesson → reach a quiz question slide.

### 2. APP STATE
```
totalXp: 1240
currentStreak: 14
currentLesson: "nitrogen_cycle" → lesson 3 of 5 open
lessonProgress: show question slide (not intro text slide)
heartsRemaining: 5 (full hearts bar)
dailyXpGoal: 50 (half complete — progress bar at ~50%)
userName: "Sam"  ← visible in lesson header
```

**SharedPreferences JSON to inject (key: `user_profile`):**
```json
{
  "displayName": "Sam",
  "totalXp": 1240,
  "currentStreak": 14,
  "longestStreak": 21,
  "dailyXpGoal": {"targetXp": 50, "earnedToday": 25, "lastGoalDate": "2026-03-16"},
  "completedLessons": ["nitrogen_1", "nitrogen_2"],
  "lessonProgress": {},
  "level": 5
}
```

**Inject via ADB:**
```bash
"$ADB" -s RFCY8022D5R shell am broadcast \
  -a com.tiarnanlarkin.danio.DEBUG_SET_PREFS \
  --es key "user_profile" \
  --es value '{"displayName":"Sam","totalXp":1240,"currentStreak":14,"longestStreak":21,"completedLessons":["nitrogen_1","nitrogen_2"]}'
```
> If broadcast receiver not available, use `adb shell run-as com.tiarnanlarkin.danio` approach or manually seed via debug menu.

**Manual seed alternative (fastest):**
```bash
"$ADB" -s RFCY8022D5R shell "run-as com.tiarnanlarkin.danio \
  cat /data/data/com.tiarnanlarkin.danio/shared_prefs/FlutterSharedPreferences.xml"
# Edit and push back, or use debug mode if available
```

### 3. CAPTION OVERLAY
```
Headline:  Learn fishkeeping the fun way 🐟
Subline:   Bite-sized lessons. Real skills. Zero boredom.
```

### 4. DESIGN NOTES
- **Position:** Caption at bottom third, over the lesson card UI
- **Background scrim:** Amber-tinted gradient (`rgba(30,15,0,0.6)`) so amber brand colour bleeds through
- **Accent element:** Add a small 🔥 14-day streak badge in top-right corner (amber pill, white text) as a visual hook
- **Finn the mascot:** Should be visible if the lesson screen shows him — don't obscure
- **NanaBanana background:** Study room scene should be visible at top (microscope/globe elements)
- **Amber accent:** `#F5A623` for XP/streak numbers visible in UI
- **DO NOT** show a completed lesson — must show active engagement (question visible, options not yet selected)

### 5. CAPTURE COMMAND
```bash
# Navigate to lesson mid-quiz:
"$ADB" -s RFCY8022D5R shell am start -n com.tiarnanlarkin.danio/.MainActivity
sleep 3
"$ADB" -s RFCY8022D5R shell input tap 540 960   # Tap Learn tab (tab 0, left-most)
sleep 1
"$ADB" -s RFCY8022D5R shell input tap 540 700   # Tap Nitrogen Cycle learning path card
sleep 1
"$ADB" -s RFCY8022D5R shell input tap 540 900   # Tap first available lesson
sleep 2
"$ADB" -s RFCY8022D5R shell input tap 540 900   # Swipe through intro to quiz question
sleep 1
# Capture:
"$ADB" -s RFCY8022D5R exec-out screencap --display 2 -p > "$OUT/01_lesson_raw.png"
# Add caption:
convert "$OUT/01_lesson_raw.png" \
  -fill 'rgba(30,15,0,0.60)' -draw 'rectangle 0,1340 1080,1920' \
  -font 'Nunito-ExtraBold' -pointsize 78 -fill white \
  -gravity SouthWest -annotate +48+360 'Learn fishkeeping\nthe fun way 🐟' \
  -font 'Nunito-SemiBold' -pointsize 44 -fill '#FFF5E6' \
  -gravity SouthWest -annotate +48+240 'Bite-sized lessons. Real skills. Zero boredom.' \
  "$OUT/01_lesson_final.png"
```

---

## Screenshot 2 — Streak + XP Dashboard
> **Emotional hook: "I've been doing this for 14 days and I'm crushing it"**

### 1. SCREEN TO CAPTURE
`LearnScreen` home (Tab 0 root), scrolled to show the **GamificationDashboard widget** prominently. This shows streak flame, XP total, gems, hearts, and daily goal progress bar.

**Route:** Tab 0 (Learn) → scroll down slightly so gamification dashboard is centred on screen.

### 2. APP STATE
```
totalXp: 2450       ← Level 8, feels substantial
currentStreak: 14   ← 2-week streak, impressive but believable
heartsRemaining: 5  ← full (green)
gemsCount: 340
dailyXpGoal: 50, earnedToday: 45  ← almost at goal (tension/progress)
recentAchievement: "Fortnight Fisher" unlocked (streak milestone)
```

**SharedPreferences injection:**
```json
{
  "displayName": "Sam",
  "totalXp": 2450,
  "currentStreak": 14,
  "longestStreak": 14,
  "dailyXpGoal": {"targetXp": 50, "earnedToday": 45, "lastGoalDate": "2026-03-16"},
  "completedLessons": ["nitrogen_1","nitrogen_2","nitrogen_3","nitrogen_4","water_1","water_2","fish_health_1"]
}
```

**Gems (key: `gems_count`):**
```bash
"$ADB" -s RFCY8022D5R shell "run-as com.tiarnanlarkin.danio \
  sh -c 'echo {\\\"gems\\\":340} > /data/data/com.tiarnanlarkin.danio/shared_prefs/gems.xml'"
```

### 3. CAPTION OVERLAY
```
Headline:  14-day streak 🔥 Keep it going
Subline:   Every day you learn, your fish live better.
```

### 4. DESIGN NOTES
- **Position:** Caption in top portion of screen (above the dashboard card) — reverse placement from other screenshots
- **Background:** Keep UI fully visible — the numbers ARE the story
- **Amber accent:** The 🔥 streak number in the dashboard UI should show `14` prominently
- **Daily goal bar:** Should be ~90% full (earnedToday: 45 of 50) — creates anticipation
- **Finn:** If mascot appears with encouraging message, keep it — adds warmth
- **Scrim:** Light scrim at top (not bottom) — `rgba(245,166,35,0.15)` amber wash
- **Hearts:** Full hearts bar visible and green

### 5. CAPTURE COMMAND
```bash
# Navigate to Learn tab root:
"$ADB" -s RFCY8022D5R shell input tap 200 1870   # Learn tab (leftmost of 5)
sleep 1
"$ADB" -s RFCY8022D5R shell input swipe 540 900 540 700 300   # Scroll down slightly
sleep 0.5
# Capture:
"$ADB" -s RFCY8022D5R exec-out screencap --display 2 -p > "$OUT/02_streak_raw.png"
# Add caption (top placement this time):
convert "$OUT/02_streak_raw.png" \
  -fill 'rgba(245,166,35,0.20)' -draw 'rectangle 0,0 1080,300' \
  -font 'Nunito-ExtraBold' -pointsize 76 -fill white \
  -gravity NorthWest -annotate +48+80 '14-day streak 🔥 Keep it going' \
  -font 'Nunito-SemiBold' -pointsize 42 -fill '#FFF5E6' \
  -gravity NorthWest -annotate +48+190 'Every day you learn, your fish live better.' \
  "$OUT/02_streak_final.png"
```

---

## Screenshot 3 — Lesson Card
> **Shows the product: structured, bite-sized, visual learning**

### 1. SCREEN TO CAPTURE
`LearnScreen` — the learning path grid with **cards expanded** showing lesson titles, progress bars, and lock states. Show the "Water Chemistry" or "Your First Fish" path with 2-3 lessons completed and 2 locked/upcoming.

**Route:** Tab 0 (Learn) → scroll to show at least one learning path card fully expanded with progress visible.

### 2. APP STATE
```
totalXp: 2450
learningPaths: "Your First Fish" — 3/5 lessons complete
lessonCards: shows titles like "Setting Up Your Tank", "The Nitrogen Cycle", "Choosing Your Fish"
Progress bar: 60% on "Your First Fish" path
```

**JSON:**
```json
{
  "totalXp": 2450,
  "currentStreak": 14,
  "completedLessons": ["first_fish_1","first_fish_2","first_fish_3","nitrogen_1","nitrogen_2"]
}
```

### 3. CAPTION OVERLAY
```
Headline:  9 learning paths. Hundreds of lessons.
Subline:   From first tank to expert keeper — we've got you.
```

### 4. DESIGN NOTES
- **Position:** Caption at bottom third
- **Background:** The cream/warm card surface should be prominent
- **Progress bars:** Amber (#F5A623) progress bars visible — brand colour in context
- **Lock icons:** One or two locked lessons visible — creates aspiration ("I want to unlock that")
- **Lesson card art:** If lesson cards have fish thumbnails, ensure at least one colourful fish visible
- **Font:** Lora for subline instead of Nunito — warmer, editorial feel fits "learning" context

### 5. CAPTURE COMMAND
```bash
"$ADB" -s RFCY8022D5R shell input tap 200 1870   # Learn tab
sleep 1
"$ADB" -s RFCY8022D5R shell input swipe 540 1200 540 600 400   # Scroll to path cards
sleep 0.5
"$ADB" -s RFCY8022D5R exec-out screencap --display 2 -p > "$OUT/03_lessons_raw.png"
convert "$OUT/03_lessons_raw.png" \
  -fill 'rgba(20,12,5,0.55)' -draw 'rectangle 0,1380 1080,1920' \
  -font 'Nunito-ExtraBold' -pointsize 72 -fill white \
  -gravity SouthWest -annotate +48+360 '9 learning paths.\nHundreds of lessons.' \
  -font 'Lora-Regular' -pointsize 42 -fill '#FFF5E6' \
  -gravity SouthWest -annotate +48+240 'From first tank to expert keeper — we'\''ve got you.' \
  "$OUT/03_lessons_final.png"
```

---

## Screenshot 4 — Species Discovery
> **Aspirational: "I could have THAT fish in my tank"**

### 1. SCREEN TO CAPTURE
`SpeciesBrowserScreen` — scrolled to show a visually stunning species entry. Best candidate: **Betta splendens** (Betta fish) — iconic, colourful, recognisable to non-hobbyists. Or **Neon Tetra** — universally beloved.

**Route:** Tab 4 (More) → Species Browser → scroll to Betta splendens → tap to open `_SpeciesDetailSheet`.

### 2. APP STATE
```
speciesBrowser: open
selectedSpecies: "Betta splendens" (Siamese Fighting Fish)
filterMode: All species visible (not filtered)
detailSheet: open showing: care level badge, water params, tank mates
```
No special SharedPreferences needed — species data is static.

**Best species to show:** Betta splendens or Cardinal Tetra. Both have:
- Vivid colouration (great visual)
- "Beginner Friendly" / "Intermediate" badge
- Clear care requirements

### 3. CAPTION OVERLAY
```
Headline:  500+ species. Find your perfect fish. 🐠
Subline:   Care guides, water requirements & tank compatibility.
```

### 4. DESIGN NOTES
- **Position:** Caption at bottom, species detail sheet visible behind it
- **Fish image:** If species has a photo/illustration, it should dominate top 60% of screen
- **Care badge:** "Beginner Friendly" badge should be visible (amber/green pill)
- **Water params row:** pH, temp, size — visible data communicates app depth
- **Colour:** Vivid fish colours against warm cream card background = strong visual
- **DO NOT** show a grey placeholder fish — must have real species imagery

### 5. CAPTURE COMMAND
```bash
# Navigate to More tab → Species Browser:
"$ADB" -s RFCY8022D5R shell input tap 880 1870   # More tab (rightmost)
sleep 1
# Tap Species Browser button (exact coordinates depend on More screen layout)
"$ADB" -s RFCY8022D5R shell input tap 540 500    # Species browser card/button
sleep 1
# Scroll to find Betta / tap it:
"$ADB" -s RFCY8022D5R shell input tap 540 700    # Tap first featured species
sleep 1
"$ADB" -s RFCY8022D5R exec-out screencap --display 2 -p > "$OUT/04_species_raw.png"
convert "$OUT/04_species_raw.png" \
  -fill 'rgba(20,12,5,0.55)' -draw 'rectangle 0,1380 1080,1920' \
  -font 'Nunito-ExtraBold' -pointsize 72 -fill white \
  -gravity SouthWest -annotate +48+360 '500+ species.\nFind your perfect fish. 🐠' \
  -font 'Nunito-SemiBold' -pointsize 42 -fill '#FFF5E6' \
  -gravity SouthWest -annotate +48+230 'Care guides, water requirements & tank compatibility.' \
  "$OUT/04_species_final.png"
```

---

## Screenshot 5 — Virtual Aquarium / Tank View
> **"My tank, tracked" — the management side made beautiful**

### 1. SCREEN TO CAPTURE
`TankDetailScreen` — showing a healthy, fully stocked tank with:
- Tank name visible
- Multiple fish in the livestock list (4–6 fish)
- Water parameters all in the green zone
- Tank health badge showing "Healthy" or good score
- Recent water test log entry

**Route:** Tab 2 (Tank) → tap an existing tank → `TankDetailScreen` open.

### 2. APP STATE
**Pre-create a demo tank with test data.** Best approach: manual setup via app UI before capture session, then lock state.

```
tankName: "Living Room Tank"
tankSize: 60L
fishCount: 6
livestock: [
  Neon Tetra (×6), 
  Corydoras (×3),
  Bristlenose Pleco (×1)
]
lastWaterTest: today
  pH: 7.0 (✅ green)
  Ammonia: 0 ppm (✅ green)  
  Nitrite: 0 ppm (✅ green)
  Nitrate: 10 ppm (✅ green)
tankHealth: "Excellent"
waterChangeReminder: 3 days away
```

**Create via app UI:** Go to Tank tab → Create Tank → fill details → add livestock manually. This is the safest state-seeding method for tank data (uses Firestore/local DB, not just SharedPreferences).

### 3. CAPTION OVERLAY
```
Headline:  Your tanks. Always healthy. 🪣
Subline:   Track water, livestock & maintenance in one place.
```

### 4. DESIGN NOTES
- **Position:** Caption at bottom third
- **Green health indicators:** pH/ammonia/nitrate all green — visual reassurance
- **Tank name:** "Living Room Tank" should be legible in header
- **Fish list:** Multiple species visible with health status icons (🟢 Healthy)
- **NanaBanana room background:** If the tank detail screen uses the room scene, it should be warm and cosy
- **Avoid:** Empty tank state, red/amber parameter warnings, or zero fish

### 5. CAPTURE COMMAND
```bash
"$ADB" -s RFCY8022D5R shell input tap 540 1870   # Tank tab (middle)
sleep 1
"$ADB" -s RFCY8022D5R shell input tap 540 700    # Tap demo tank card
sleep 1
"$ADB" -s RFCY8022D5R exec-out screencap --display 2 -p > "$OUT/05_tank_raw.png"
convert "$OUT/05_tank_raw.png" \
  -fill 'rgba(20,12,5,0.55)' -draw 'rectangle 0,1380 1080,1920' \
  -font 'Nunito-ExtraBold' -pointsize 78 -fill white \
  -gravity SouthWest -annotate +48+360 'Your tanks.\nAlways healthy. 🪣' \
  -font 'Nunito-SemiBold' -pointsize 42 -fill '#FFF5E6' \
  -gravity SouthWest -annotate +48+230 'Track water, livestock & maintenance in one place.' \
  "$OUT/05_tank_final.png"
```

---

## Screenshot 6 — Achievement Grid
> **FOMO trigger: "Look at all the stuff I could unlock"**

### 1. SCREEN TO CAPTURE
`AchievementsScreen` — grid view showing a mix of unlocked (gold/amber) and locked (greyed out) achievements. Aim for ~40% unlocked to show progress without looking empty.

**Route:** Tab 4 (More) → Achievements → filter: All.

### 2. APP STATE
```
achievementsUnlocked: [
  "first_steps",        ← "You completed your very first lesson!"
  "week_warrior",       ← 7-day streak
  "fortnight_fisher",   ← 14-day streak
  "chemistry_student",  ← Complete water chemistry path
  "first_fish_keeper",  ← Create first tank
  "nitrogen_master",    ← Complete nitrogen cycle
  "quiz_beast",         ← 10 perfect quiz scores
  "early_bird",         ← Complete daily goal before 9am
]
totalAchievements: 55
unlockedCount: 8
```

**Inject via profile JSON** — add achievement keys to `unlockedAchievements` map in the user profile SharedPreferences, each with `{"isUnlocked": true, "unlockedAt": "2026-03-10T09:00:00Z"}`.

### 3. CAPTION OVERLAY
```
Headline:  55 achievements to unlock 🏆
Subline:   From First Fish to Master Aquarist. How far will you go?
```

### 4. DESIGN NOTES
- **Position:** Caption at bottom third
- **Unlocked tiles:** Amber/gold background with achievement icon — warm and rewarding
- **Locked tiles:** Tasteful grey with padlock — not dark/depressing, just "coming soon"
- **Grid layout:** 3 columns, ~6 rows visible — feels rich and deep
- **Recent unlock badge:** "NEW" pill on most recently unlocked achievement (top-left of its tile)
- **Count badge:** "8 / 55 unlocked" visible in screen header — shows the journey ahead
- **Amber gradient:** Ambient amber glow behind unlocked tiles

### 5. CAPTURE COMMAND
```bash
"$ADB" -s RFCY8022D5R shell input tap 880 1870   # More tab
sleep 1
"$ADB" -s RFCY8022D5R shell input tap 540 800    # Achievements button
sleep 1
"$ADB" -s RFCY8022D5R shell input swipe 540 900 540 700 300   # Scroll to show grid
sleep 0.5
"$ADB" -s RFCY8022D5R exec-out screencap --display 2 -p > "$OUT/06_achievements_raw.png"
convert "$OUT/06_achievements_raw.png" \
  -fill 'rgba(20,12,5,0.55)' -draw 'rectangle 0,1380 1080,1920' \
  -font 'Nunito-ExtraBold' -pointsize 76 -fill white \
  -gravity SouthWest -annotate +48+360 '55 achievements to unlock 🏆' \
  -font 'Nunito-SemiBold' -pointsize 42 -fill '#FFF5E6' \
  -gravity SouthWest -annotate +48+240 'From First Fish to Master Aquarist.\nHow far will you go?' \
  "$OUT/06_achievements_final.png"
```

---

## Screenshot 7 — Beginner CTA
> **Conversion shot: "This app is for me, right now, for free"**

### 1. SCREEN TO CAPTURE
`LearnScreen` root — showing the **"Start Here"** section or the onboarding placement test card, with a clear Beginner-friendly learning path at the top. Alternatively: the **Placement Test complete screen** showing "You're a Beginner — here's your path!"

**Best option:** The Learn tab with the "Your First Fish" path card prominent at the top, showing 0% progress (clean start) and a warm "Start here 🐟" CTA visible. This is the most persuasive "this is easy, join me" shot.

**Route:** Tab 0 (Learn) → scroll to top → show first learning path card with "Beginner" badge.

### 2. APP STATE
```
totalXp: 0 (or low — 50 XP, just started)
currentStreak: 1 (first day)
completedLessons: []
onboardingComplete: true
showPlacementTest: false
learningPathHighlighted: "first_fish"
userName: "You" (or leave as default)
```

**JSON (clean state for CTA screenshot):**
```json
{
  "displayName": "You",
  "totalXp": 50,
  "currentStreak": 1,
  "longestStreak": 1,
  "completedLessons": [],
  "dailyXpGoal": {"targetXp": 50, "earnedToday": 0, "lastGoalDate": "2026-03-16"}
}
```

> Note: Use a separate test device state or clear + re-seed to get this clean state without wiping the main test state used for screenshots 1–6.

### 3. CAPTION OVERLAY
```
Headline:  New to fishkeeping? Start here. 🐠
Subline:   Free lessons. Daily streaks. No experience needed.
```

### 4. DESIGN NOTES
- **Position:** Caption at bottom third
- **Tone:** Warm and inviting — this is the "welcome" shot
- **Finn:** If mascot is visible (waving mood), keep him — he IS the welcome
- **"Beginner" badge:** Amber pill on the first learning path should be clearly visible
- **Clean state:** No completed lessons, no XP bar filled — this is day one energy
- **NanaBanana room:** The study room scene at the top (warm, cosy, inviting)
- **CTA visual:** If there's a "Start Learning" button visible, ensure it's in frame — reinforces action
- **Avoid:** Showing locked content, paid features, or complex UI — keep it simple and welcoming

### 5. CAPTURE COMMAND
```bash
"$ADB" -s RFCY8022D5R shell input tap 200 1870   # Learn tab
sleep 1
"$ADB" -s RFCY8022D5R shell input swipe 540 600 540 1200 300   # Scroll to top
sleep 0.5
"$ADB" -s RFCY8022D5R exec-out screencap --display 2 -p > "$OUT/07_beginner_raw.png"
convert "$OUT/07_beginner_raw.png" \
  -fill 'rgba(20,12,5,0.55)' -draw 'rectangle 0,1380 1080,1920' \
  -font 'Nunito-ExtraBold' -pointsize 76 -fill white \
  -gravity SouthWest -annotate +48+360 'New to fishkeeping?\nStart here. 🐠' \
  -font 'Nunito-SemiBold' -pointsize 44 -fill '#FFF5E6' \
  -gravity SouthWest -annotate +48+230 'Free lessons. Daily streaks. No experience needed.' \
  "$OUT/07_beginner_final.png"
```

---

## Feature Graphic Brief (1024×500px)
> Shown at top of Play Store listing. First impression before screenshots.

### Concept: "The Fishkeeper's Learning Room"
A warm, illustrated banner combining:
- **Left side (40%):** Danio app icon (round, large — ~200px) with the app name "Danio" in Nunito ExtraBold below
- **Centre (40%):** Tagline in large text: **"Learn Fishkeeping. Level Up. Keep Happy Fish."** in Nunito ExtraBold white
- **Right side (20%):** Small illustrated aquarium/fish motif (tropical fish silhouettes, coral)
- **Background:** Deep warm navy-to-teal gradient (`#0A1628` → `#1A4A5C`) with subtle amber particle effects
- **Accent elements:** Small amber XP stars scattered in background, a tiny 🔥 streak icon near tagline
- **Bottom strip:** Amber bar (#F5A623) 8px tall at very bottom — brand colour anchor

### Generation prompt (for NanaBanana/Gemini Image):
```
Feature graphic banner for a fishkeeping app. 1024x500px. 
Dark teal to navy gradient background (#0A1628 to #1A4A5C). 
Left side: round app icon placeholder. Centre: white sans-serif text "Learn Fishkeeping. Level Up. Keep Happy Fish." 
Right side: beautiful tropical fish silhouettes (betta, neon tetra, angelfish) in warm amber and teal tones.
Small amber stars/XP icons scattered as particles. Warm, modern, gamified aesthetic. 
No photorealism — clean, flat-ish illustration style. Bottom amber stripe accent.
```

### Output path:
```
/mnt/c/Users/larki/Documents/Danio Aquarium App Project/store_screenshots/feature_graphic_1024x500.png
```

---

## Section 8 — New `scripts/store_screenshots.sh`

Create this file at:
`/mnt/c/Users/larki/Documents/Danio Aquarium App Project/repo/apps/aquarium_app/scripts/store_screenshots.sh`

```bash
#!/usr/bin/env bash
# store_screenshots.sh — Capture store screenshots for Danio (Google Play)
# Usage: bash scripts/store_screenshots.sh [device_serial]
# Default device: RFCY8022D5R (Samsung Z Fold inner display)
#
# Prerequisites:
#   - App installed and running on device
#   - Test data seeded BEFORE running this script (see APHRODITE_SCREENSHOT_BRIEF.md)
#   - ImageMagick installed: sudo apt install imagemagick
#   - Nunito font installed: sudo apt install fonts-nunito OR place TTF in ~/.fonts/
#   - Screen on and unlocked

set -uo pipefail

ADB="/mnt/c/Users/larki/AppData/Local/Android/Sdk/platform-tools/adb.exe"
DEVICE="${1:-RFCY8022D5R}"
OUT_DIR="/mnt/c/Users/larki/Documents/Danio Aquarium App Project/store_screenshots/$(date +%Y-%m-%d)"
PKG="com.tiarnanlarkin.danio"
MAIN_ACTIVITY="com.tiarnanlarkin.danio.MainActivity"

mkdir -p "$OUT_DIR"

adb_cmd() { "$ADB" -s "$DEVICE" "$@"; }

cap() {
  local name="$1"
  local path="$OUT_DIR/${name}_raw.png"
  # Use --display 2 for Samsung Z Fold inner (foldable) display
  adb_cmd exec-out screencap --display 2 -p > "$path"
  local size
  size=$(stat -c%s "$path" 2>/dev/null || echo "0")
  if [ "$size" -lt 50000 ]; then
    echo "⚠️  WARNING: $name screenshot may be wrong display (${size} bytes) — check --display flag"
  else
    echo "✅  Captured: $name (${size} bytes)"
  fi
}

overlay() {
  local raw="$OUT_DIR/${1}_raw.png"
  local out="$OUT_DIR/${1}_final.png"
  local headline="$2"
  local subline="$3"
  
  convert "$raw" \
    -fill 'rgba(20,12,5,0.55)' -draw 'rectangle 0,1380 1080,1920' \
    -font 'Nunito-ExtraBold' -pointsize 74 -fill white \
    -gravity SouthWest -annotate +48+360 "$headline" \
    -font 'Nunito-SemiBold' -pointsize 42 -fill '#FFF5E6' \
    -gravity SouthWest -annotate +48+240 "$subline" \
    "$out" 2>/dev/null && echo "✅  Overlay: $1" || echo "⚠️  Overlay failed for $1 (check ImageMagick + fonts)"
}

echo "🎬 Danio Store Screenshots"
echo "Device: $DEVICE | Output: $OUT_DIR"
echo ""

# Verify device connected
if ! adb_cmd get-state >/dev/null 2>&1; then
  echo "❌ FATAL: Device $DEVICE not connected. Check ADB and try again."
  exit 1
fi

# Launch app
adb_cmd shell am start -n "$PKG/$MAIN_ACTIVITY" 2>/dev/null
sleep 3

echo "⚠️  MANUAL STEPS REQUIRED before capture:"
echo "   1. Ensure test data is seeded (XP=2450, streak=14) — see APHRODITE_SCREENSHOT_BRIEF.md"
echo "   2. Ensure 'Living Room Tank' exists with 6 fish and green parameters"
echo "   3. Ensure achievements are seeded (8 unlocked)"
echo ""
read -r -p "Press ENTER when app is in correct state to begin capture..."

# === Screenshot 1: Lesson in progress ===
echo "📸 Screenshot 1: Lesson in progress..."
adb_cmd shell input tap 200 1870; sleep 1    # Learn tab
adb_cmd shell input tap 540 700; sleep 1     # Tap learning path
adb_cmd shell input tap 540 900; sleep 2     # Tap lesson
cap "01_lesson"
overlay "01_lesson" \
  "Learn fishkeeping\nthe fun way 🐟" \
  "Bite-sized lessons. Real skills. Zero boredom."

# === Screenshot 2: Streak + XP ===
echo "📸 Screenshot 2: Streak + XP dashboard..."
adb_cmd shell input keyevent KEYCODE_BACK; sleep 1
adb_cmd shell input tap 200 1870; sleep 1    # Learn tab root
adb_cmd shell input swipe 540 900 540 700 300; sleep 0.5
cap "02_streak"
overlay "02_streak" \
  "14-day streak 🔥 Keep it going" \
  "Every day you learn, your fish live better."

# === Screenshot 3: Lesson cards ===
echo "📸 Screenshot 3: Lesson cards..."
adb_cmd shell input swipe 540 1200 540 600 400; sleep 0.5
cap "03_lessons"
overlay "03_lessons" \
  "9 learning paths.\nHundreds of lessons." \
  "From first tank to expert keeper — we've got you."

# === Screenshot 4: Species browser ===
echo "📸 Screenshot 4: Species discovery..."
adb_cmd shell input tap 880 1870; sleep 1    # More tab
# Navigate to species browser — tap the species browser option
adb_cmd shell input tap 540 500; sleep 1
adb_cmd shell input tap 540 700; sleep 1     # Tap a species (Betta ideally)
cap "04_species"
overlay "04_species" \
  "500+ species. Find your perfect fish. 🐠" \
  "Care guides, water requirements & tank compatibility."

# === Screenshot 5: Tank view ===
echo "📸 Screenshot 5: Tank management..."
adb_cmd shell input keyevent KEYCODE_BACK; sleep 1
adb_cmd shell input tap 540 1870; sleep 1    # Tank tab
adb_cmd shell input tap 540 700; sleep 1     # Tap demo tank
cap "05_tank"
overlay "05_tank" \
  "Your tanks. Always healthy. 🪣" \
  "Track water, livestock & maintenance in one place."

# === Screenshot 6: Achievements ===
echo "📸 Screenshot 6: Achievement grid..."
adb_cmd shell input tap 880 1870; sleep 1    # More tab
adb_cmd shell input tap 540 800; sleep 1     # Achievements
adb_cmd shell input swipe 540 900 540 700 300; sleep 0.5
cap "06_achievements"
overlay "06_achievements" \
  "55 achievements to unlock 🏆" \
  "From First Fish to Master Aquarist.\nHow far will you go?"

# === Screenshot 7: Beginner CTA ===
echo "📸 Screenshot 7: Beginner CTA..."
echo "⚠️  Switch to clean/beginner state before this shot (low XP, streak=1)"
read -r -p "Press ENTER when beginner state is set..."
adb_cmd shell input tap 200 1870; sleep 1    # Learn tab
adb_cmd shell input swipe 540 600 540 1200 300; sleep 0.5
cap "07_beginner"
overlay "07_beginner" \
  "New to fishkeeping?\nStart here. 🐠" \
  "Free lessons. Daily streaks. No experience needed."

echo ""
echo "✅ All screenshots captured!"
echo "📁 Output: $OUT_DIR"
echo ""
echo "Final files:"
ls "$OUT_DIR"/*_final.png 2>/dev/null || echo "(No final files — check ImageMagick overlay step)"
```

---

## Section 9 — State Seeding Quick Reference

### Method A: SharedPreferences via `adb shell`
```bash
PREFS_PATH="/data/data/com.tiarnanlarkin.danio/shared_prefs/FlutterSharedPreferences.xml"
# Read current prefs:
"$ADB" -s RFCY8022D5R shell "run-as com.tiarnanlarkin.danio cat $PREFS_PATH"
# Write profile JSON:
"$ADB" -s RFCY8022D5R shell "run-as com.tiarnanlarkin.danio sh -c \
  'echo PROFILE_JSON > $PREFS_PATH'"
```

### Method B: Flutter integration test / debug flag
If a debug mode flag exists (`--dart-define=DEBUG_SEED_DATA=true`), use:
```bash
~/flutter/bin/flutter run \
  --dart-define=DEBUG_SEED_DATA=true \
  -d RFCY8022D5R
```

### Method C: Manual setup (most reliable)
1. Install debug build
2. Complete onboarding
3. Manually do 5–7 lessons (earns real XP, streak, achievements)
4. Create "Living Room Tank", add fish, log a water test
5. Unlock 8 achievements naturally (or via debug menu if present)
6. Lock that state: `adb backup` or note SharedPreferences values
7. Run capture script

### Key SharedPreferences Keys
| Data | Key | Type |
|------|-----|------|
| User profile (XP, streak, lessons) | `flutter.user_profile` | String (JSON) |
| Theme mode | `flutter.theme_mode` | Int |
| Tab visited flag | `flutter.tab_2_visited` | Bool |
| Gems | `flutter.gems_count` | Int |
| Hearts | `flutter.hearts_count` | Int |

---

## Summary — Caption Text Quick Reference

| # | Screen | Headline | Subline |
|---|--------|----------|---------|
| 1 | Lesson Hero | "Learn fishkeeping the fun way 🐟" | "Bite-sized lessons. Real skills. Zero boredom." |
| 2 | Streak + XP | "14-day streak 🔥 Keep it going" | "Every day you learn, your fish live better." |
| 3 | Lesson Cards | "9 learning paths. Hundreds of lessons." | "From first tank to expert keeper — we've got you." |
| 4 | Species | "500+ species. Find your perfect fish. 🐠" | "Care guides, water requirements & tank compatibility." |
| 5 | Tank View | "Your tanks. Always healthy. 🪣" | "Track water, livestock & maintenance in one place." |
| 6 | Achievements | "55 achievements to unlock 🏆" | "From First Fish to Master Aquarist. How far will you go?" |
| 7 | Beginner CTA | "New to fishkeeping? Start here. 🐠" | "Free lessons. Daily streaks. No experience needed." |

---

*Brief complete. Next step: create the screenshot script, seed test data, and run a dry-capture pass. Review raws before adding overlays.*
