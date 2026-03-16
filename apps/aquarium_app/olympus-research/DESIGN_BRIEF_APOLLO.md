# 🎨 Danio Visual Design & Brand Standards
**Apollo Design Brief — March 2026**

---

## Overview

Danio is "Duolingo for Fishkeeping" — a warm, cosy, game-like Android app with a Golden Hour aesthetic. The brand concept is **a house with different rooms**: each tab has its own personality but they're clearly all the same home. Think National Geographic meets a warm study at dusk.

The visual north star: **premium nature meets cosy learning**. Warm. Alive. Trustworthy. Never sterile.

---

## 1. TYPOGRAPHY RECOMMENDATIONS

### Primary Pairing: Nunito + Lora

| Role | Font | Weight | Size | Notes |
|------|------|--------|------|-------|
| App name / Hero title | **Nunito** | ExtraBold (800) | 28–34sp | Rounded, warm, friendly |
| Tab names / Section headers | **Nunito** | SemiBold (600) | 18–22sp | Consistent brand voice |
| Body / Learn content | **Lora** | Regular (400) | 16sp | Serif warmth, readable, feels like a book |
| Body emphasis | **Lora** | Bold (700) | 16sp | For key terms, fish names |
| Captions / Labels | **Nunito** | Medium (500) | 12–14sp | Friendly, never cold |
| UI labels (buttons etc.) | **Nunito** | Bold (700) | 14–16sp | |

**Why this pairing:**
- Nunito's rounded terminals = warm, approachable, Duolingo-adjacent without copying
- Lora's serif character = credibility, education, "reading a nature book"
- Together they create the warm-educational tension that defines the brand

### Alternative Display Font (for special moments)
- **DM Serif Display** — for single hero words, tank names, achievement unlocks. Has elegance without coldness.

### Avoid
- Roboto (too cold/corporate)
- Open Sans (generic)
- Playfair Display (too formal)
- Any condensed fonts

### Flutter Implementation
```dart
// In your theme
TextTheme(
  displayLarge: GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.w800),
  headlineMedium: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w600),
  bodyLarge: GoogleFonts.lora(fontSize: 16, fontWeight: FontWeight.w400),
  bodyMedium: GoogleFonts.lora(fontSize: 14, fontWeight: FontWeight.w400),
  labelLarge: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700),
  labelSmall: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w500),
)
```

---

## 2. COLOUR SYSTEM

### Design Philosophy
The palette comes from two sources: **Golden Hour photography** (low sun, warm shadows, rich amber light) and **aquarium water** (deep teal, cool blue-green). These are complementary — warm light ON cool water. That tension is the brand.

### Primary Palette (Light Mode)

| Role | Name | Hex | Usage |
|------|------|-----|-------|
| Primary | Amber Glow | `#F5A623` | Main CTA buttons, active tab indicators, streaks |
| Primary Dark | Burnished Gold | `#C97A0C` | Button pressed state, shadows on primary |
| Primary Light | Honey | `#FFD580` | Highlights, selected chips, warm accents |
| Secondary | Deep Teal | `#1B7A6E` | Water elements, fish health indicators, secondary actions |
| Secondary Light | Aqua Mist | `#4DB8AB` | Secondary chip highlights, water badges |
| Tertiary | Coral Sunset | `#E05A2B` | Warnings, temperature alerts, streak-endangered state |
| Surface | Warm Cream | `#FFF8F0` | Card backgrounds, main screen background |
| Surface Variant | Parchment | `#F5ECD6` | Slightly differentiated surfaces, drawer bg |
| Background | Warm White | `#FFFBF5` | Base app background |
| Outline | Warm Grey | `#9E8F7A` | Dividers, borders (never cold grey) |
| Error | `#D64B2F` | Error states |

### Text Colours

| Role | Hex | Notes |
|------|-----|-------|
| On-surface (body) | `#2C1E0F` | Warm near-black, never pure #000 |
| On-surface medium | `#6B5442` | Secondary text, labels |
| On-surface subtle | `#A08B76` | Hints, disabled, placeholder |
| On-primary | `#FFFFFF` | Text on amber buttons |
| On-secondary | `#FFFFFF` | Text on teal |

### Dark Mode Palette

Dark mode for a warm palette = **evening aquarium room**. Not black. Deep brown-blacks with amber glow.

| Role | Name | Hex | Notes |
|------|------|-----|-------|
| Background | Dark Walnut | `#1A1108` | Main bg — very dark warm brown, not pure black |
| Surface | Dark Oak | `#251A0D` | Card surfaces |
| Surface Variant | Dusk | `#332517` | Slightly lighter surface |
| Primary | Amber Glow | `#F5A623` | Stays same — glows in dark |
| Primary Container | `#4A2E00` | Background of primary chips/containers |
| Secondary | Aqua Glow | `#5CC8BB` | Slightly lighter teal for dark |
| On-surface | `#F5E9D5` | Warm off-white, never pure white |
| On-surface medium | `#C9B49A` | Secondary text in dark |
| Outline | `#6B5030` | Warm dark dividers |

### Material You Seed Colour
**Seed: `#F5A623` (Amber Glow)**
```dart
ColorScheme.fromSeed(
  seedColor: Color(0xFFF5A623),
  brightness: Brightness.light, // or Brightness.dark
  dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
)
```
Use `DynamicSchemeVariant.fidelity` — it preserves your amber character more faithfully than `tonalSpot`.

### Colour Rules
1. Never use pure `#000000` or pure `#FFFFFF` — always warm versions
2. All greys must have a warm undertone (never cool grey)
3. Water-related elements: always the teal family
4. Achievement/reward moments: amber + honey gradient
5. Error/danger: coral, not red (softer, fits the palette)

---

## 3. ICON STYLE GUIDE

### Style: Warm Outlined with Tonal Fill

**The Style:** 2px warm amber/dark stroke, rounded caps and joins, with subtle tonal fill at ~15–20% opacity. Think "hand-drawn but precise" — like labels in a nature journal.

- **Stroke weight:** 2px (at 24×24dp), rounding all corners (min 1px radius)
- **Fill:** subtle tonal at low opacity for selected/active states only
- **Corner style:** rounded everywhere — no sharp corners
- **Optical sizing:** icons at 24dp for tabs, 20dp for inline, 32dp for featured
- **Grid:** 24×24dp with 2dp padding (20dp live area)

### Icon Families by Function

| Category | Style notes | Inspiration |
|----------|-------------|-------------|
| **Fish icons** | Illustrated silhouette, side-on profile view, consistent style — line weight matches UI icons | Natural history illustration |
| **Equipment icons** | Simplified but recognizable — filter looks like a filter, heater looks like a heater. No generic "settings cog" for aquarium equipment | Ikea-style clarity |
| **Water/quality icons** | Abstract but evocative — waves, droplets, bubbles. Consistent family | |
| **Navigation icons** | Custom per-room icons (see room briefs below) — unique to Danio | |
| **Achievement icons** | More decorative, golden/amber coloured, slight shimmer | Trophy-adjacent |

### References to study
- **Google's Material Symbols** (outlined, rounded variant) — base style to extend from
- **Phosphor Icons** (duotone style) — for the fill logic
- **The Noun Project** nature set — for natural motifs
- **Tabler Icons** — clean line quality to aspire to

### Icon Colour States
- **Default (unselected):** `#9E8F7A` (Warm Grey)
- **Selected/Active:** `#F5A623` (Amber Glow) with amber tonal bg pill
- **Disabled:** `#C9B49A` at 50% opacity

---

## 4. ROOM-BY-ROOM DESIGN BRIEF

The concept: **every tab is a different room in the same house.** Same family of materials, different atmosphere. Like moving through rooms at golden hour.

---

### 🐠 Living Room — Tank Tab (already established)

**What makes it work:**
- The NanaBanana room background creates depth and domestic warmth instantly
- Animated aquarium scene (fish swimming, bubbles) layered over it = life and movement
- The filing cabinet UI metaphor is clever — physical, tactile, familiar
- Amber light from the background bleeds naturally into the UI surfaces

**Design principles to preserve:**
- Background always shows through surfaces (use transparency, not opaque cards)
- Animation is background-level — never interrupts content interaction
- Keep the "looking into a tank in a warm room" feeling
- Primary colour accent (amber) should feel like the room's lamplight

**Don't change:**
- The layered background → tank → UI hierarchy
- The filing cabinet tabs
- The warm cream surface colours

---

### 📚 Study/Library — Learn Tab

**Atmosphere:** Late afternoon in a wood-panelled study. Books, warm desk lamp, learning materials spread out. Focused but cosy.

**Background direction:**
- NanaBanana prompt: a cosy study/library, bookshelves with fish books and specimen jars, warm amber desk lamp, late afternoon light, painted illustration style
- Colour temperature: slightly cooler than the Living Room (more golden-hour amber → more late-afternoon amber)
- Bookshelves visible, perhaps a fish print on the wall

**UI elements:**
- Cards should feel like index cards or book pages — slight cream tint (`#FFF8F0`), very subtle paper texture via a background image (not CSS texture, use a thin WebP overlay)
- Lesson path feels like a trail through the study — vertical scrolling progression
- Progress indicators: bookmark ribbons, not progress bars
- Section dividers: thin warm amber line with a small fish watermark

**Typography emphasis:**
- Lora gets MORE play here — this is a reading environment
- Nunito for headers/chapter names, Lora for content
- Line height generous: 1.6 for body text

**Micro-details:**
- Correct answer animation: page-turn flourish (180ms, easeOut)
- Lesson complete: warm glow pulse on the screen
- Streak: flame-amber colour, not the Duolingo green

---

### 🎯 Practice Studio — Practice Tab

**Atmosphere:** A bright but warm artist's studio or practice room. Open space, natural light, energy and focus.

**Background direction:**
- NanaBanana prompt: a bright studio room, clean workbench/table, natural warm light through window, neutral but warm walls, a few aquarium-related tools on the desk
- More energetic than the Study — slightly lighter, more contrast
- No clutter — clean surfaces for the practice activity to breathe

**UI elements:**
- Cards are more "game-like" — cleaner, more whitespace, bigger touch targets
- Answer options: prominent rounded rectangles, amber glow on selection
- Timer (if used): water-fill animation bottom to top
- Correct/incorrect feedback: should be unmistakable but not jarring
  - Correct: warm golden shimmer sweep left-to-right (200ms)
  - Incorrect: subtle red tint pulse + slight shake (150ms, easeInOut)

**Motion emphasis:**
- The most animated tab — rewards, progress, celebrations
- XP earned: number floats upward and fades (score floater pattern)
- Combo streaks: amber particles

**Typography:**
- Both fonts in balance — Nunito dominates (action-oriented)
- Question text: Lora for credibility
- Answer options: Nunito Bold for clarity and decisiveness

---

### 🔬 Workshop/Lab — Smart AI Tab

**Atmosphere:** A naturalist's workshop or specimen lab. Interesting, a little mysterious, intelligent. Think Darwin's study meets a Marine Biology lab.

**Background direction:**
- NanaBanana prompt: a naturalist's workshop, specimen jars, a magnifying glass, scientific diagrams pinned to the wall, warm brass instruments, amber-tinted laboratory light
- Slightly more dramatic lighting than other rooms — darker corners, focused pools of light
- Scientific feel without being sterile

**UI elements:**
- AI chat: messages in "note paper" styled bubbles — slightly textured cream for user, teal-tinted for AI
- AI avatar: a wise-looking fish or aquarium creature, illustrated, not photorealistic
- Input field: styled like a lab notebook page with pen-line bottom border only
- Results/identifications: expand with a specimen-reveal animation (scale from 0.95 to 1.0, fade in)

**Colour temperature:**
- Can go slightly darker here — more atmospheric
- Teal accent more prominent (scientific precision = water/nature)
- Amber still present but as accent rather than dominant

**Motion:**
- Thinking indicator: slow amber pulse or "bubbling" animation
- Not loading spinners — something thematic (tiny fish swimming in a circle)
- Transitions: smooth slide from edge, not aggressive pop

---

### ⚙️ Settings/Utility — Settings Tab

**Atmosphere:** The hallway or entryway of the house. Practical, clean, still warm. Not an afterthought.

**Background direction:**
- Simpler than other rooms — maybe a clean wall, a few hooks, warm lighting
- Or no full-background image — just warm surface colour with subtle texture
- Most functional tab, so let clarity lead

**UI elements:**
- Clean list tiles with warm dividers
- Section headers: small amber dot or warm line accent
- Toggles: amber when on, warm grey when off
- Profile section: warm illustrated avatar/fish frame at top

**Typography:**
- Nunito dominant — clear, legible settings UI
- Lora only for descriptive text or premium section headers

**Tone:**
- Still has Danio personality — settings should have friendly microcopy ("Notifications — so we can remind you your tank needs attention")
- Not a dumping ground — every setting should feel intentional

---

## 5. TOP 10 VISUAL POLISH RULES FOR DANIO

**These are non-negotiable. Every screen, every build.**

1. **The backgrounds are alive — never obscure them.**
   Card opacity should be 85–95%, never 100%. The room breathes through every surface. If you can't see hints of the background, you've over-covered it.

2. **Warm shadows only.**
   No cool grey drop shadows. All shadows use `Color(0x33C97A0C)` — a warm dark amber at 20% opacity. This is the difference between premium and generic.

3. **Rounded everything, consistently.**
   All cards: 16dp radius. All buttons: 24dp radius (fully rounded). All chips: 20dp radius. Input fields: 12dp. No mixing. No exceptions.

4. **Typography is a design element, not an afterthought.**
   Every screen should have deliberate typographic hierarchy. If everything is the same size, nothing is. Use Nunito + Lora as a conversation between warmth and depth.

5. **Space is your friend.**
   Generous padding: minimum 16dp card padding, 24dp between sections. The background rooms should always breathe. Cramped UI kills the atmosphere.

6. **Colour weight = hierarchy.**
   Only one amber element should "pop" per screen. Everything else is supporting. If three things are amber, nothing is primary.

7. **Animations serve the user, not the designer.**
   If an animation makes something take longer to reach, it fails. All navigation transitions: ≤300ms. All micro-animations: ≤200ms. No animation for animation's sake.

8. **Icons must speak the same language.**
   Never mix icon families. Custom fish icons must match the weight and style of the navigation icons. If it looks like it came from a different app, it doesn't belong.

9. **Dark mode is a warm evening, not a cold night.**
   Dark background: `#1A1108`, not `#000000`. Dark surfaces: `#251A0D`. Text: `#F5E9D5`. Dark mode should feel like sitting in the living room with the lights dimmed.

10. **The room transitions must feel like walking through a house.**
    Tab switching: cross-fade with subtle scale (0.97 → 1.0), 250ms easeOut. Not a jarring slide. Movement should feel spatial and gentle.

---

## 6. FLUTTER ANIMATION SPECIFICATIONS

### Duration Standards

| Animation Type | Duration | Curve | Notes |
|----------------|----------|-------|-------|
| Tab switch | 250ms | `Curves.easeOut` | Cross-fade + subtle scale |
| Card appear | 200ms | `Curves.easeOut` | Fade + slide 8dp upward |
| Button press | 100ms | `Curves.easeIn` | Scale 1.0 → 0.96 |
| Button release | 150ms | `Curves.elasticOut` | Scale back with tiny spring |
| Score floater | 800ms | `Curves.easeOut` | Float up 40dp and fade |
| Correct answer | 200ms | `Curves.easeOut` | Golden shimmer sweep |
| Wrong answer | 300ms | Custom (shake) | Translate ±6dp x3 |
| Page transition | 300ms | `Curves.easeInOut` | |
| Fish swim (idle) | 3000–5000ms | `Curves.easeInOut` | Loop, vary per fish |
| Bubble rise | 2000–4000ms | Linear | Slight sway offset |
| Loading pulse | 1000ms | `Curves.easeInOut` | Repeat |
| Achievement pop | 600ms | `Curves.elasticOut` | Scale from 0 with spring |

### Use Animation For:
- Idle aquarium scene (fish, bubbles, light shimmer)
- Tab switches and page transitions
- Feedback (correct/wrong)
- Reward moments (XP, streaks, unlocks)
- Loading states
- Button interactions (press feedback)

### Never Animate:
- Text content appearing (flashing text is distracting)
- Navigation controls mid-interaction
- Anything that blocks user action
- Background images (they're already animated enough)
- Error messages (they need to be immediate and readable)

---

## 7. WHAT TO AVOID

### The "AI-Generated" Traps

1. **Perfect symmetry everywhere** — Real premium apps have deliberate asymmetry. Not all cards the same width. Not all sections the same padding. Intentional variation = human craft.

2. **The generic card stack** — White/grey cards in a vertical list with rounded corners and a shadow. Every app does this. Danio needs cards that feel like they're part of the room — semi-transparent, with the background bleeding through.

3. **Cold grey tones anywhere** — A single cool-grey element will break the warmth spell immediately. Check every default widget. Flutter's defaults are cool-grey. Override everything.

4. **Gradient abuse** — One strategic gradient (e.g., scrim at the bottom of the tank view) is premium. Gradients on every card header is cheap.

5. **System defaults for icons** — Using stock Material icons without customisation instantly signals "default". The navigation icons should be custom to Danio. At minimum, the tab icons should be unique.

6. **Mismatched animation speeds** — Some things snap, some things crawl. Inconsistent timing makes an app feel unstable and unfinished.

7. **Text hierarchy collapse** — Every text style the same weight and size except for minor size differences. Use the font pairing deliberately — some text is Lora, some is Nunito, and the mix is intentional.

8. **Flat colour backgrounds** — A solid amber background is not the Golden Hour aesthetic. The NanaBanana room backgrounds ARE the aesthetic. Don't fill backgrounds with flat colour.

9. **Ignoring safe areas and system chrome** — On Android, the status bar and navigation bar should integrate with the app's colour. Use `SystemChrome.setSystemUIOverlayStyle()` to match the room palette.

10. **Over-animating the aquarium** — Too many fish, too many bubbles, all moving at the same speed = cheap screensaver. Vary speeds, depths, directions. Use parallax if possible. The tank should feel like a real observation, not a GIF.

---

## 8. REFERENCE APPS TO STUDY

| App | What to Learn |
|-----|--------------|
| **Duolingo** | Gamification loop, mascot integration, reward moments |
| **Calm / Headspace** | Warm palette, nature backgrounds layered with UI, serenity |
| **Notion** (mobile) | Typography hierarchy, spacing, surface system |
| **Bearable** | Warm colour palette, personality without being childish |
| **Obsidian (mobile)** | How to make a "workshop/study" feel cosy |
| **iNaturalist** | How nature apps handle species data without being sterile |

---

## Quick Reference Card

```
FONTS:    Nunito (headers/UI) + Lora (body/content)
PRIMARY:  #F5A623 Amber Glow
SECONDARY:#1B7A6E Deep Teal  
SURFACE:  #FFF8F0 Warm Cream (light) / #251A0D Dark Oak (dark)
TEXT:     #2C1E0F (light) / #F5E9D5 (dark)
SHADOWS:  Color(0x33C97A0C) warm amber at 20%
RADIUS:   Cards 16dp | Buttons 24dp | Chips 20dp
ANIM:     Tabs 250ms easeOut | Micro 100-200ms | Rewards 600ms elasticOut
```

---

*Prepared by Apollo, Design Agent — Mount Olympus*
*For Tiarnan Larkin / Danio App — March 2026*
