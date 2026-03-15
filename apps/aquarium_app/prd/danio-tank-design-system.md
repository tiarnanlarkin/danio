# 🐟 Danio Tank Page — Design System
**Version:** 2.0 (Reference Image Aligned)
**Author:** Apollo, Designer of Mount Olympus
**Date:** 2026-03-15
**Status:** IMPLEMENTATION READY — no decisions pending

---

## 0. North Star: The Reference Image

> *"The tank is a jewel. The room is its setting. Everything else is framing."*

The reference image establishes the definitive aesthetic target. Every decision in this document flows from it.

### What the Reference Shows

| Element | Description |
|---------|-------------|
| **Water** | Crystal-clear teal-blue gradient — top lighter (`#A8D8E8`-ish), bottom deeper (`#4A9DB5`-ish). ZERO opacity overlay. Fish completely unobscured. |
| **Room background** | Warm cozy evening living room. Amber lamp glow. Candles. Potted plants. Framed art on walls. Sofa visible at edges. |
| **Fish** | Flat vector style. Bold solid colors — coral red and cobalt blue. ~3 fish visible. Charming, NOT realistic. |
| **Plants** | Flat vector leaf shapes. Dark forest green. 2-3 clusters at tank bottom corners. |
| **Substrate** | Warm beige/cream sand. Simple flat band. |
| **Glass border** | Subtle icy-blue/white rounded rectangle. ~24dp corner radius. Barely-there — glass suggests itself. |
| **Tank light** | Warm golden hood at top-center of tank. Radiates warmth downward. |
| **Bubbles** | Small semi-transparent circles, varying sizes, rising gently. |
| **Stand** | Simple dark charcoal/black metal frame. Minimal, architectural. |
| **Floor** | Warm wood surface under stand. Rich grain. |
| **Label** | Frosted pill at bottom of screen: "Living Room Tank · 120L". |
| **Proportions** | Tank is ~70% of screen height and ~88% of screen width. It IS the screen. |

### The Core Problem with Current Code

The current `_ThemedAquarium` applies **multiple stacked opacity layers**:
- Water gradient with opacity
- Glass overlay with opacity  
- Ambient water shimmer with opacity
- `AmbientLightingOverlay` wrapping everything with opacity

These layers **multiply together**. At 85% × 90% × 95% = 72.7% of original fish visibility. That's why it looks milky. The fix is architectural: **only the glass border itself should have any translucency**. Everything else renders at full opacity.

---

## 1. Design Tokens

### 1.1 Aquarium Water Colors

```dart
// WATER — crystal clear, rich teal gradient
// These replace any milky/faded water currently rendered
static const Color waterSurface    = Color(0xFF9ED8EC);  // Light icy teal at top
static const Color waterMidUpper   = Color(0xFF6BBDD8);  // Mid-upper body
static const Color waterMidLower   = Color(0xFF4A9DB5);  // Mid-lower body
static const Color waterDepth      = Color(0xFF2D7A94);  // Deep teal at substrate
static const Color waterHighlight  = Color(0xFFD4EEF7);  // Surface shimmer strip (very faint)

// GLASS — icy translucent border only
static const Color glassBorder     = Color(0xFFB8DDE8);  // Icy blue-white
static const Color glassBorderDark = Color(0xFF7FBECC);  // Slightly deeper for dark side
static const Color glassInner      = Color(0x0AFFFFFF);  // Nearly invisible inner tint (4% white)

// SUBSTRATE
static const Color sandLight       = Color(0xFFE8D5B0);  // Warm cream sand
static const Color sandMid         = Color(0xFFD4BC8A);  // Mid sand
static const Color sandDark        = Color(0xFFC0A070);  // Shadow at base of plants

// TANK LIGHT (hood)
static const Color lightBarWarm    = Color(0xFFFFCC66);  // Golden warm LED
static const Color lightBarGlow    = Color(0x33FFD080);  // Glow radial below bar (20% alpha)
static const Color lightBarBody    = Color(0xFF2C2C2C);  // Dark hood body
```

### 1.2 Room Background Colors

```dart
// WALLS — warm cream, NOT cold blue-grey
static const Color wallLight       = Color(0xFFF2E6D9);  // Warm golden cream
static const Color wallLightAccent = Color(0xFFE8D8C8);  // Deeper warm cream gradient
static const Color wallDark        = Color(0xFF3D3830);  // Warm charcoal brown (NOT blue-grey)
static const Color wallDarkAccent  = Color(0xFF4A4238);  // Warm grey-brown

// FLOOR — rich walnut wood
static const Color floorLight      = Color(0xFFA0805C);  // Rich walnut
static const Color floorDark       = Color(0xFF5A4030);  // Deep espresso

// TRIM
static const Color trimLight       = Color(0xFF6B4E35);  // Warm mahogany
static const Color trimDark        = Color(0xFF584038);  // Dark mahogany

// STAND — dark architectural metal (from reference image)
static const Color standPrimary    = Color(0xFF2A2A2A);  // Near-black charcoal
static const Color standHighlight  = Color(0xFF404040);  // Subtle edge highlight
static const Color standShadow     = Color(0xFF1A1A1A);  // Shadow underside

// RUG — warm persian rust, consistent across themes
static const Color rugBase         = Color(0xFFC4725A);  // Persian rust (light)
static const Color rugBaseDark     = Color(0xFF8B4F3A);  // Dark rust (dark mode)
static const Color rugPattern      = Color(0xFFE8C89C);  // Cream-gold accent
static const Color rugBorder       = Color(0xFF964B38);  // Deep burgundy border
```

### 1.3 Lighting Colors

```dart
// LAMP GLOW — warm amber (replaces cold white)
static const Color lampGlow        = Color(0xFFFFB347);  // Warm amber
static const Color lampIndicator   = Color(0xFFFFCC66);  // Bright amber dot
static const Color ambientLight    = Color(0xFFF5D68B);  // Warm honey ambient

// CANDLE (new element)
static const Color candleFlame     = Color(0xFFFF8C00);  // Deep orange
static const Color candleGlow      = Color(0x1FFFA040);  // 12% alpha warm glow

// TANK BACKGLOW (subtle warm glow behind tank on wall)
static const Color tankBackglow    = Color(0x26FFD68B);  // 15% alpha soft gold

// WINDOW
static const Color curtainLight    = Color(0xB3B88A68);  // Linen at 70%
static const Color curtainDark     = Color(0x807A6050);  // Dark linen at 50%
static const Color nightSkyGlow    = Color(0x26FFE4B5);  // Warm interior warmth in window panes
```

### 1.4 Fish Colors

```dart
// FLAT VECTOR FISH — bold, charming, reference-matched
static const Color fishCoralRed    = Color(0xFFE8503A);  // Coral/clownfish red
static const Color fishCobaltBlue  = Color(0xFF3A78C9);  // Cobalt blue
static const Color fishAmberGold   = Color(0xFFE8A030);  // Golden danio reference
static const Color fishWhiteAccent = Color(0xFFF5F0E8);  // Belly/stripe highlight
static const Color fishDarkFin     = Color(0xFF1A1A2E);  // Fin outline/dark accent
```

### 1.5 Interactive Object Colors

```dart
// INTERACTIVE BUTTONS — warm amber family (matches app primary)
static const Color actionFood      = Color(0xFFE8A030);  // Food: amber-gold
static const Color actionTestKit   = Color(0xFF4A9DB5);  // Test kit: teal (matches water)
static const Color actionPlant     = Color(0xFF4A7A50);  // Plant: forest green
static const Color actionWater     = Color(0xFF5ABBE8);  // Water change: sky blue
static const Color actionBgLight   = Color(0xFFFFF8F0);  // Button background (light)
static const Color actionBgDark    = Color(0xFF2A2218);  // Button background (dark)
```

### 1.6 Typography (Tank Page)

```dart
// TANK LABEL PILL (frosted, bottom of screen)
// Font: App primary (e.g., Nunito / Poppins — match existing app_theme.dart)
// Size: 14sp Medium weight
// Color: Adaptive — dark on light frosted, light on dark frosted

// TANK SWITCHER PILL
// Size: 13sp Medium weight, centered
// Truncate at 20 chars with ellipsis

// STREAK/HEARTS BANNERS
// Size: 16sp Bold
// Emoji icon at 20sp

// BOTTOM NAV LABELS
// Size: 10sp Regular (inactive), 10sp SemiBold (active)
```

---

## 2. The Aquarium (Layer Stack Architecture)

### 2.1 THE CRITICAL FIX: Layer Stack

This is the most important section. The current code stacks opacity-bearing layers causing cumulative milkiness.

**RULE: Only the glass border renders with translucency. Everything inside the tank renders at full opacity (alpha: 255).**

```
ThemedAquarium (ClipRRect, cornerRadius: 24dp)
│
├── LAYER 1: Water gradient                    ← FULL OPACITY (no overlay)
│   LinearGradient top→bottom:
│   waterSurface → waterMidUpper → waterMidLower → waterDepth
│   NO opacity modifier on this widget.
│
├── LAYER 2: Background plants (behind fish)   ← FULL OPACITY
│   SwayingPlant × 2 (rear, larger, darker green)
│   positioned at 10% and 80% x, bottom-aligned
│
├── LAYER 3: Sand substrate                    ← FULL OPACITY  
│   Simple arc/rounded-rect at bottom 14% of tank height
│   sandLight → sandMid gradient
│   sandDark shadow at very bottom edge (4px)
│
├── LAYER 4: Fish                              ← FULL OPACITY
│   RiveFish or _AnimatedSwimmingFish
│   3 fish: coral red (large), cobalt blue (medium), amber (small)
│
├── LAYER 5: Foreground plants (in front of fish) ← FULL OPACITY
│   SwayingPlant × 2 (front, smaller, brighter green)
│   positioned at 25% and 70% x, bottom-aligned
│
├── LAYER 6: Bubbles                           ← SEMI-TRANSPARENT (correct: bubbles ARE translucent)
│   AmbientBubblesSubtle: opacity 0.65-0.85 (per bubble)
│   Bubbles themselves have translucency — not a blanket overlay
│
├── LAYER 7: Water surface shimmer             ← VERY LOW OPACITY ONLY (max 15%)
│   WaterSurfaceOverlay (Rive)
│   ⚠️ If this Rive animation uses opacity > 15%, cap it.
│   This should be nearly invisible — just a suggestion of surface movement.
│
├── LAYER 8: Tank light bar (top)              ← FULL OPACITY bar + glow
│   Height: 8dp bar
│   Color: lightBarBody (#2C2C2C)
│   Below bar: RadialGradient glow, lightBarGlow (20% alpha, radius: tankWidth * 0.4)
│   ⚠️ This glow should NOT tint the water — it sits BELOW the light bar, 
│      between bar and water surface, radiates DOWN.
│
└── LAYER 9: Glass border (outermost)          ← THE ONLY TRANSLUCENCY ON THE TANK CONTAINER
    Border: 2dp, glassBorder (#B8DDE8)
    Corner radius: 24dp (matches ClipRRect)
    Inner shadow: BoxShadow(color: glassBorderDark, blurRadius: 3, spreadRadius: -1)
    ⚠️ NO background fill on this border widget. It is ONLY a border.
    ⚠️ DO NOT apply any Container color or BoxDecoration fill.
```

### 2.2 What MUST NOT Happen

```
❌ Water gradient with opacity: 0.8 applied to the widget
❌ A white/cream Container ABOVE the water layer (this is the current bug)
❌ AmbientLightingOverlay wrapped around the entire tank widget
❌ Any BackdropFilter/blur applied to the tank interior
❌ Stacking a semi-transparent glass Container ON TOP of water + fish
❌ The light bar glow tinting the entire water column (use ClipRect to constrain it)
```

### 2.3 Water Gradient Specification

```dart
// EXACT gradient — implement this, nothing else
BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.25, 0.65, 1.0],
    colors: [
      Color(0xFF9ED8EC),  // waterSurface — icy top
      Color(0xFF6BBDD8),  // waterMidUpper — clear mid
      Color(0xFF4A9DB5),  // waterMidLower — deeper
      Color(0xFF2D7A94),  // waterDepth — dark bottom
    ],
  ),
)
// NO opacity: parameter. NO withAlpha(). Full alpha on all stops.
```

### 2.4 Glass Container Treatment

```dart
// The tank is a ClipRRect with a DecoratedBox ONLY for the border
// CORRECT implementation:
ClipRRect(
  borderRadius: BorderRadius.circular(24),
  child: Stack(
    children: [
      // ... all tank layers inside here ...
    ],
  ),
)
// Border applied via parent Container's decoration:
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: Color(0xFFB8DDE8),  // glassBorder
      width: 2.0,
    ),
    // DO NOT ADD: color: Colors.white.withOpacity(0.x) — this is the milky bug
    boxShadow: [
      BoxShadow(
        color: Color(0x1A000000),  // 10% black shadow on outside
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
      BoxShadow(
        color: Color(0x337FBECC),  // 20% icy inner glow
        blurRadius: 6,
        spreadRadius: -2,
      ),
    ],
  ),
)
```

### 2.5 Aquarium Proportions

```
Tank width:   screenWidth × 0.88      (leave 6% margin each side)
Tank height:  screenHeight × 0.44     (from y: 0.10 to y: 0.54)
Corner radius: 24dp (consistent everywhere)
Top margin from screen top: ~80dp (below tank switcher pill)
Bottom of tank to bottom of stand: screenHeight × 0.08
```

---

## 3. Fish Design Specification

### 3.1 Style Mandate

**FLAT VECTOR. NOT REALISTIC.** Think: charmingly simple cartoon fish. Each fish is 5–7 shapes maximum.

Reference: like the fish in a children's illustration or a 2D mobile game (Neko Atsume energy, not Finding Nemo realism).

### 3.2 Fish Anatomy (per fish)

```
Body:    Rounded oval/teardrop. Fill: fishCoralRed or fishCobaltBlue. No outline.
Tail:    Simple triangle or chevron. Same color as body or slightly darker.
Eye:     White circle (6dp) + black pupil circle (3dp). NO iris gradient.
Fin:     1–2 simple triangles. fishDarkFin at 70% opacity.
Stripe:  Optional single fishWhiteAccent stripe across mid-body (for danio species authenticity).
```

### 3.3 Fish Sizing

```
Large fish (foreground):   bodyWidth: 48dp, bodyHeight: 28dp
Medium fish (midground):   bodyWidth: 36dp, bodyHeight: 20dp
Small fish (background):   bodyWidth: 24dp, bodyHeight: 14dp
```

### 3.4 Fish Colors (3 visible fish)

```
Fish 1 (large, foreground):  fishCoralRed (#E8503A) body, fishDarkFin tail
Fish 2 (medium, midground):  fishCobaltBlue (#3A78C9) body, fishWhiteAccent stripe
Fish 3 (small, background):  fishAmberGold (#E8A030) body — reads as a danio
```

### 3.5 Fish Motion

```
Swimming:     Slow sinusoidal horizontal path. Duration: 8–12s per pass. Ease in/out.
Tail wag:     Subtle rotation oscillation ±8°. Duration: 0.6s. Continuous.
Depth change: Fish slowly drift up/down ±10% of tank height over 15–25s.
Direction:    Fish face the direction of travel (flip horizontally on turnaround).
Idle:         Fish occasionally pause (2–3s), gentle tail wag in place.
NO: Jerky movement. NO: Fish passing through each other. NO: All fish same rhythm.
```

---

## 4. Plant Design Specification

### 4.1 Style Mandate

**FLAT VECTOR LEAF SHAPES.** Dark forest green. Simple elegant curves. NOT detailed botanical illustration.

### 4.2 Plant Structure

```
Rear plants (behind fish):
  Color:    #2D5A30 (dark forest green) — slightly muted for depth
  Height:   50–65% of tank height
  Count:    2 clusters (left rear, right rear)
  Stem:     1px dark green vertical line
  Leaves:   4–6 rounded lance shapes per stem. Gentle sway animation.

Front plants (in front of fish):  
  Color:    #3A7040 (brighter forest green) — more vivid, feels closer
  Height:   35–50% of tank height
  Count:    2 clusters (centre-left, centre-right)
  Leaves:   3–4 leaves per stem. Faster sway than rear plants (parallax depth cue).
```

### 4.3 Plant Sway Motion

```
Rear plants:   Amplitude: ±6dp, Duration: 3.5s, Ease in/out sine. Offset timing per plant.
Front plants:  Amplitude: ±4dp, Duration: 2.8s. Slightly faster = feels closer.
Direction:     All sway in same general direction at same time (unified "current" feel).
              Offset each plant by 0.3–0.7s to avoid identical sync.
```

---

## 5. Sand/Substrate Specification

```dart
// Simple flat substrate at tank bottom
// Height: 13% of tank height

// Layer 1: Sand base
Paint sandBase = Paint()
  ..shader = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE8D5B0), Color(0xFFD4BC8A)],  // sandLight → sandMid
  ).createShader(substrateRect);

// Layer 2: Sand surface (subtle arc at top of substrate)
// Draw a gentle irregular arc to avoid perfectly flat look
// Amplitude: ±3dp variation across width using sin wave at 3–4 cycles
// Color: sandLight with very slight transparency edge at top (gradient fade-in over 4dp)

// Layer 3: Plant base shadows
// At each plant cluster base: elliptical shadow
// Color: sandDark (#C0A070) at 40% opacity
// Size: 20dp × 6dp ellipse
```

---

## 6. Room Scene Architecture

### 6.1 Full Layer Stack (screen order, bottom to top)

```
Screen
│
├── L1: Room Background                        z-index: 0
│   _CozyRoomPainter (CustomPainter)
│   Draws: Wall, wainscoting, floor, baseboard, window, rug, shelf, picture, curtains
│   + Linen texture overlay (assets/textures/linen-wall.png, opacity: 0.25)
│
├── L2: Room Decorative Objects                z-index: 1
│   _RoomPlant (tall floor plant, left)
│   _ShelfPlant (shelf plant, right)
│   [Optional] _Sparkles (Whimsical/Midnight/Aurora themes only)
│
├── L3: Lamp Glow (dark mode only)             z-index: 2
│   RadialGradient overlay, positioned at lamp
│   Color: lampGlow (#FFB347) at 15% alpha
│   ⚠️ This renders BELOW the stand, does not affect tank
│
├── L4: Aquarium Stand                         z-index: 3
│   _AquariumStand (CustomPainter)
│   Dark charcoal metal frame (standPrimary #2A2A2A)
│   OPEN SHELF design with books, plant, vase (see §6.4)
│
├── L5: ThemedAquarium (THE TANK — SACRED)     z-index: 4
│   All internal layers per §2.1
│   ⚠️ AmbientLightingOverlay must NOT wrap this widget
│
├── L6: Tank Glass Badge                       z-index: 5
│   TankGlassBadge widget (name + volume label)
│   Frosted pill style (see §8)
│
├── L7: Interactive Objects                    z-index: 6
│   4 buttons: Food, Test Kit, Plant, Water Change
│   Positioned at screen edges (see §7)
│
├── L8: Streak/Hearts Banners                  z-index: 7
│   Conditional overlay banners (see §9)
│
├── L9: Tank Switcher Pill (top)               z-index: 8
│   Top-center pill (see §10)
│
└── L10: Bottom Navigation Bar                 z-index: 9
    (see §11)
```

### 6.2 AmbientLightingOverlay — Where It MUST NOT Go

```dart
// ❌ WRONG — current code wraps the entire scene including the tank:
AmbientLightingOverlay(
  child: Stack(
    children: [
      _CozyRoomBackground(...),
      _ThemedAquarium(...),  // ← tank gets tinted too
    ],
  ),
)

// ✅ CORRECT — overlay wraps ONLY the room, tank is exempt:
Stack(
  children: [
    AmbientLightingOverlay(
      child: _CozyRoomBackground(...),  // tints room background only
    ),
    _RoomPlant(...),       // tinted is fine (part of room)
    _AquariumStand(...),   // tinted is fine (part of room)
    _ThemedAquarium(...),  // ← NOT wrapped, renders pure
    // ... rest of UI
  ],
)
```

### 6.3 Room Background Specification

**Wall:**
```
Light mode:
  Upper: #F2E6D9 (warm cream with golden undertone)
  Lower: #E8D8C8 (deeper warm cream)
  Vertical stripe texture: 1.5px lines every 25px, blackAlpha 3%
  
Dark mode:
  Upper: #3D3830 (warm charcoal-brown — NOT #4A5668 cold blue-grey)
  Lower: #4A4238 (warm grey-brown)
  
Wainscoting panel:
  From h×0.45 to h×0.62
  Color: lerp(wallAccent, floorColor, 0.25) — slightly deeper than wall
  Top trim: 3px line, trimColor at 40% opacity
  Bottom trim: 2px line, trimColor at 30% opacity (new — adds depth)
  Shadow: 2px gradient below top trim (blackAlpha 5%)
```

**Floor:**
```
Light mode:  #A0805C → lerp(#A0805C, #7A6040, 0.2)  — rich walnut
Dark mode:   #5A4030 → lerp(#5A4030, #3D2818, 0.2)  — espresso

Board lines:  Horizontal every 22px (was 18px — wider planks = premium)
Joints:       Vertical every 80px (was 60px)
Alternating:  Every other board gets +blackAlpha05 overlay for subtle variation
Baseboard:    10px tall, #6B4E35 light / #584038 dark
              1px highlight line on top
              1px shadow below (touches floor color)
```

**Window (upper-left):**
```
Position:   w×0.02, h×0.06 — 22% × 14% of screen
Sky:        Day: #87CEEB → #B0D8F0 (soft blue sky)
            Night: #1A1A3A → #2A2A50 (deep night blue)
Moon:       Off-white circle, dark themes only, upper-right of window
Curtains:   #B88A68 at 70% opacity (warm linen, NOT theme-dependent)
            Fabric texture: 2–3 gentle vertical curves suggesting folds
Curtain rod: 4px, #8B7355 (brass)
Night warmth: Faint #FFE4B5 at alpha 15 inside panes (suggests warm interior)
Window glow: RadialGradient from center, lampGlow at 8% alpha (light from outside/inside)
```

**Picture frame (upper-left wall):**
```
Position:   w×0.02, h×0.22 — 14% × 10% of screen
Frame:      #6B4E35 (warm mahogany), 3px border
Matt:       #F5EDE5 at 80% (cream inner border)
Content:    Simple 2-band landscape:
            Top 55%: #8BB8C8 at 70% (sky blue-grey)
            Bottom 45%: #6B9B6B at 70% (sage green ground)
            Horizon line: 1px #FFFFFF at 30%
```

**Shelf (upper-right):**
```
Position:   h×0.10, w×0.72 to w×0.94
Surface:    4px thick, #8B7355 (warm wood)
Brackets:   2 small L-shapes below shelf, same wood color
Shelf plant: Small pot + 2–3 leaf ovals (reuse _ShelfPlantPainter)
```

**Rug:**
```
Position:   Under tank, w×0.05 to w×0.95, floor_top +8px, height h×0.12
Shape:      RRect, cornerRadius: 12
Color:      #C4725A light / #8B4F3A dark — FIXED, not theme-dependent
Border:     2px, #964B38 light / #6B3828 dark
Pattern:    Double-border (NOT vertical stripes):
            Inner border inset 8px from outer border
            Fill between borders: #D88C6E (rust-copper)
            Centre field: rugBase
            Optional: subtle diamond outline at centre (rugPattern at 40%)
```

**Tall room plant (left):**
```
No changes needed. Existing _RoomPlantPainter is adequate.
Terracotta pot with leaf fronds. Keep.
```

### 6.4 Aquarium Stand Redesign

**Replace current "two mystery boxes" with open shelf + items.**

```
Stand dimensions: w×0.08 to w×0.92, positioned directly below tank
Stand height: h×0.08

Structure:
  Top surface:  RRect(radius 4), dark wood (#2A2A2A charcoal per reference)
  Left leg:     w×0.05–0.13, full stand height, standPrimary (#2A2A2A)
  Right leg:    w×0.87–0.95, full stand height
  Shelf surface: w×0.13–0.87, at stand height×0.40, 3px thick, standHighlight (#404040)
  Shadow below shelf: 2px gradient, blackAlpha 20%
  
  REMOVE: Cabinet door stroked rectangles
  
Shelf items (left to right):

  1. Book stack (left section: w×0.18–0.35 of stand, on shelf):
     3 books stacked horizontally with slight angle variation:
     Book A: 22dp wide, 14dp tall, #4A6B8C (navy)
     Book B: 20dp wide, 12dp tall, #8B5E3C (leather brown) — 2° tilt
     Book C: 18dp wide, 13dp tall, #5A8060 (sage green)
     Spine: 2dp left edge, slightly darker shade of book color
     
  2. Small plant (centre: w×0.45–0.55 of stand, on shelf):
     Pot: 14dp wide, 10dp tall, #C0825A (terracotta)
     Pot rim: 2px, #A06040 (darker rim)
     2 leaf ovals: #3A6840 (forest green), 8dp × 12dp each
     
  3. Decorative vase/jar (right section: w×0.65–0.78 of stand, on shelf):
     Shape: 12dp wide rounded rect, 16dp tall
     Color: #8BAEB8 (soft teal — echoes tank water)
     Highlight: 2dp right-side white at 30% (gloss)
     
Leg foot detail:
  At base of each leg, 4dp wide × 3dp tall flat rect (foot plate)
  Color: standHighlight (#404040)
```

### 6.5 Lighting Effects

**Dark Mode:**
```
Lamp glow:
  Position: w×0.08, h×0.38 (upper-left, where lamp "lives")
  Type: RadialGradient
  Color: #FFB347 (warm amber) at alpha 38 (15%) → transparent
  Radius: 0.60 of scene width
  Lamp dot: 8dp circle, #FFCC66 (bright amber) — reads as actual light source

Tank backglow (NEW):
  Position: Behind tank (renders between room background and tank)
  Type: RadialGradient from tank centre
  Color: #FFD68B at alpha 38 (15%) → transparent
  Radius: w×0.50 horizontal, h×0.30 vertical
  Effect: Makes tank appear to radiate warmth onto the wall behind it
  
Candle glow (optional, dark mode):
  2 candle positions on shelf: small flame (#FF8C00) 4dp circle
  Glow: RadialGradient, #FFA040 at alpha 30, radius 20dp
  Animation: Gentle flicker — opacity oscillates 80%→100%, duration 1.5–2.5s random
```

**Light Mode:**
```
Ambient light:
  Type: RadialGradient from top-right
  Color: #F5D68B (warm honey) at alpha 64 (25%) → transparent
  Radius: 0.70 of scene width
```

---

## 7. Interactive Objects (Action Buttons)

### 7.1 What They Are

4 circular action buttons that float in the room scene:
- 🍟 **Food** — feed the fish
- 🧪 **Test Kit** — check water parameters  
- 🌿 **Plant** — add/manage plants
- 💧 **Water Change** — perform maintenance

### 7.2 Visual Style

```
Shape:      Circle, diameter: 56dp
Background: White at 85% opacity (light mode) / #1A1A1A at 85% (dark mode)
            Frosted glass effect: BackdropFilter(blur: 8) behind the circle
Border:     1px, white at 60% (light) / #404040 (dark)
Shadow:     BoxShadow(color: #1A000000, blurRadius: 12, offset: Offset(0,4))
Icon:       28dp, actionFood/actionTestKit/actionPlant/actionWater colors
Label:      10sp, below button, medium weight, theme text color
```

### 7.3 Positioning

```
Buttons float in pairs at tank sides:
Left side:    Food (top-left of tank) and Plant (bottom-left)
Right side:   Test Kit (top-right of tank) and Water Change (bottom-right)

Exact positions (relative to tank widget):
  Food:         x: tank.left - 32, y: tank.top + tank.height × 0.25
  Plant:        x: tank.left - 32, y: tank.top + tank.height × 0.60
  Test Kit:     x: tank.right - 24, y: tank.top + tank.height × 0.25
  Water Change: x: tank.right - 24, y: tank.top + tank.height × 0.60
  
(Buttons overhang the tank edge slightly — creates integrated feel)
```

### 7.4 States and Animation

```
Default:    Opacity 1.0, scale 1.0
Hover:      Scale 1.05 (200ms ease-out)
Pressed:    Scale 0.92 + haptic feedback (HapticFeedback.mediumImpact)
            Duration: 100ms
Release:    Scale back to 1.0 (150ms ease-out)
Pulse:      Idle pulse animation — outer ring at 30% opacity, scale 1.0→1.3, 
            duration 2.5s, repeat. Suggests interactivity to new users.
Active/In-progress: Ring fills with action color (animated sweep, 360°)
```

### 7.5 What MUST NOT Happen

```
❌ Buttons float in mid-air with no visual grounding
❌ Buttons overlap fish or plants inside the tank
❌ All 4 buttons visible simultaneously with equal visual weight
   (consider showing 2 per side, with subtle priority ordering)
❌ Pulse animations that are distracting during normal use
   (pulse only for the first 3 sessions or until first use of each button)
```

---

## 8. Tank Glass Badge (Frosted Label)

### 8.1 Design

```
Position:   Bottom-center of screen, 16dp above bottom navigation
            OR: Overlapping bottom edge of tank glass (if bottom nav isn't shown)
Shape:      Pill (RRect, cornerRadius: 20dp)
Width:      Auto (text-width + 32dp padding each side), max 80% screen width
Height:     36dp

Background: 
  Light: Colors.white.withOpacity(0.85) + BackdropFilter(blur: 12)
  Dark:  Colors.black.withOpacity(0.50) + BackdropFilter(blur: 12)
Border:     1px, white at 50% (light) / white at 20% (dark)
Shadow:     BoxShadow(color: #14000000, blurRadius: 8, offset: Offset(0,2))

Content:    "[Tank Name] · [Volume]L"
            Example: "Living Room Tank · 120L"
Font:       14sp, medium weight
Color:      Dark grey #1A1A1A (light) / white #FFFFFF (dark)
Separator:  "·" character with left/right padding 6dp
```

### 8.2 Interaction

```
Tap:    Opens tank detail/edit screen
Long press: Shows quick-edit tank name inline
Animation on tap: Scale 0.96 → 1.00 (80ms), then navigate
```

---

## 9. Banners and Overlays (Streak, Hearts)

### 9.1 Streak Banner

```
Trigger:    User opens app on a streak day / completes daily task
Position:   Top of screen, below safe area, slides down
Style:      Full-width, height 52dp
Background: Gradient — #FF8C00 → #FFB347 (fire gradient)
            OR: dark mode — #6B3800 → #9B5200
Content:    "🔥 X day streak!" — 16sp Bold white
Shadow:     Below banner, 8dp blur, #40FF8C00 (warm amber shadow)
Animation:  Slide from top (y: -100% → 0), ease-out, 300ms
            Auto-dismiss after 3 seconds: slide back up
```

### 9.2 Hearts Banner

```
Trigger:    Hearts refilled / hearts at max
Position:   Same top area as streak banner
Style:      Full-width, height 52dp  
Background: #E8503A → #C0404A (hearts red gradient)
Content:    "❤️ Full lives!" — 16sp Bold white
Animation:  Same as streak banner
```

### 9.3 Overlay Rules

```
- Only ONE banner shows at a time (streak takes priority over hearts)
- Banners must NOT cover the tank switcher pill (position below it)
- Banners must NOT trigger during active fish animations (queue until fish settle)
- Banner text must meet WCAG AA contrast on its background
- Dismiss on tap (in addition to auto-dismiss timer)
```

---

## 10. Tank Switcher (Top Bar)

### 10.1 Pill Design

```
Position:   Top-center, y: safeAreaTop + 12dp
Shape:      Pill/capsule, auto-width (tank name + chevrons + padding)
Max width:  70% of screen width
Height:     36dp
Corner:     18dp (fully rounded)

Background:
  Light: Colors.white.withOpacity(0.85) + BackdropFilter(blur: 10)
  Dark:  Colors.black.withOpacity(0.60) + BackdropFilter(blur: 10)
Border:     1px solid, white at 40%
Shadow:     BoxShadow(color: #1A000000, blurRadius: 8, offset: Offset(0,2))

Content:
  Left chevron: Icons.chevron_left, 20dp, #808080 (grey, dimmed if at first tank)
  Tank name:    13sp Medium, centered, max 20 chars with ellipsis
  Right chevron: Icons.chevron_right, 20dp, #808080 (grey, dimmed if at last tank)
  
Theme indicator: Small colored dot (6dp) left of tank name — theme accent color
                 Provides visual differentiation when switching tanks
```

### 10.2 Switching Animation

```
Left/right swipe or chevron tap:
  Current tank content: Slide out (opposite direction), 200ms ease-in
  New tank content:     Slide in (from direction of navigation), 200ms ease-out
  Tank switcher label:  Crossfade, 150ms
  
DO NOT: Full-screen transition (jarring)
DO: Smooth in-place content swap
```

### 10.3 Multi-tank States

```
1 tank:   Both chevrons dimmed to 30% opacity (but still visible — hint there could be more)
2 tanks:  Left dimmed at first, right dimmed at last
3+ tanks: Full opacity, position indicator dots below pill (3dp circles, active = primary color)
```

---

## 11. Bottom Navigation

### 11.1 Style

```
Height:     60dp + safe area bottom inset
Background: 
  Light: Colors.white.withOpacity(0.95)
  Dark:  #1A1A1A withOpacity(0.97)
Border:     Top border only: 0.5px, #E0E0E0 (light) / #303030 (dark)
Blur:       BackdropFilter(blur: 20) — navigation floats above content
Shadow:     BoxShadow(color: #0A000000, blurRadius: 16, offset: Offset(0, -4))

Tabs: Home | Learn | Smart | Profile
```

### 11.2 Tab Item Style

```
Active:
  Icon:       28dp, filled version, app primary color (amber #E8A030)
  Label:      10sp SemiBold, app primary color
  Indicator:  4dp × 4dp filled circle above icon, primary color
              OR: Pill background behind icon+label (preferred Duolingo-style)

Inactive:
  Icon:       28dp, outlined version, #909090 (grey)
  Label:      10sp Regular, #909090
  No indicator

Transition: 200ms, ease-out
Home tab icon: Custom fish/tank icon (not a generic home icon)
```

### 11.3 Bottom Nav Positioning

```
⚠️ The bottom nav must NOT overlap the tank glass badge pill.
   If they would collide:
   - Tank glass badge gets precedence (it's the identity anchor)
   - Position badge 8dp above the nav bar top edge
   
⚠️ Interactive object buttons must account for nav bar height
   (they should NOT be obscured by the nav bar)
```

---

## 12. Room Theme System

### 12.1 What Themes Control

Themes modify the ROOM environment only. The tank water gradient is fixed (crystal clear teal). Fish colors don't change with themes.

```dart
// RoomTheme parameters that STILL matter:
theme.background1   → Used for AmbientLightingOverlay tint (low opacity wash)
theme.background2   → Secondary ambient color
theme.accentBlob    → Interactive object icon colors (subtle)
theme.accentBlob2   → Shelf decorative item accents
theme.waterMid      → Tank backglow color (replaces hardcoded #FFD68B)
                      (so the backglow color harmonizes per theme)

// RoomTheme parameters that NO LONGER affect tank water:
// theme.waterTop, theme.waterBottom — these are RETIRED from water gradient use
// The water is now fixed to the crystal-clear teal palette from §1.1
// If needed, rename these fields to theme.accentWarm and theme.accentCool
```

### 12.2 Theme-to-Room Mapping

| Theme | Wall Wash | Accent Override | Ambient | Special |
|-------|-----------|-----------------|---------|---------|
| Cozy Living | None (base) | None | Warm honey | None |
| Evening Glow | Orange tint 5% | Gold accents | Deep amber | Lamp brighter |
| Ocean | Soft blue 5% | Teal accents | Blue-green | Bubbles +20% |
| Pastel | Pink/lilac 5% | Pastel accents | Soft pink | Lighter rug |
| Sunset | Orange-rose 8% | Coral accents | Rose-gold | No curtains? |
| Midnight | Blue-navy 10% | Purple accents | Deep blue | Stars sparkle |
| Forest | Green 5% | Sage accents | Emerald | More plants |
| Aurora | Multi-color 3% | Shifting | Cool teal | Shimmer |

### 12.3 Theme Application Rules

```
Wall colors:    Base palette from §1.3, then additive color wash per theme (low opacity)
                ⚠️ DO NOT multiply opacity — ADD the theme color at 5-10% alpha as overlay
                
Tank interior:  NEVER modified by theme
Fish colors:    NEVER modified by theme  
Sand:           NEVER modified by theme (warm beige always)
Glass border:   NEVER modified by theme (icy blue always)

Room furniture: CAN be theme-influenced (rug, shelf items, curtain tint)
Ambient glow:   SHOULD be theme-influenced (mood lighting varies)
Sparkle effects: Theme-specific (Whimsical, Midnight, Aurora only)
```

---

## 13. Motion Design System

### 13.1 Motion Principles

```
1. LAYERED: Near objects move more than far objects (parallax depth)
2. CONTINUOUS: The tank is always alive — nothing fully stops
3. RESTFUL: Motion is calming, not urgent. Slow curves, not snappy.
4. PURPOSEFUL: Every animation communicates something (depth, life, feedback)
```

### 13.2 Animation Inventory

| Element | Type | Duration | Easing | Notes |
|---------|------|----------|--------|-------|
| Fish swimming | Path + position | 8–12s | EaseInOutSine | See §3.5 |
| Fish tail wag | Rotation | 0.6s | SineCurve | Continuous |
| Plant sway (rear) | Translation | 3.5s | EaseInOutSine | See §4.3 |
| Plant sway (front) | Translation | 2.8s | EaseInOutSine | Faster = closer |
| Bubbles rise | Position | 4–8s | Linear | Vary per bubble |
| Bubble fade | Opacity | 1.5s at top | EaseOut | Pop at surface |
| Water surface | Rive animation | — | — | Cap at 15% opacity |
| Candle flicker | Opacity | 1.5–2.5s | Random | Dark mode only |
| Button pulse | Scale | 2.5s | EaseOut | See §7.4 |
| Banner slide | Position | 300ms | EaseOut | See §9.1 |
| Tank switch | Slide | 200ms | EaseInOut | See §10.2 |
| Bottom nav | Crossfade | 200ms | EaseOut | — |
| Ripple on tank tap | Scale+Opacity | 600ms | EaseOut | Existing — keep |

### 13.3 Performance Rules

```
Target framerate: 60fps on mid-range Android (Snapdragon 700 series)
                  60fps on iPhone 12 and above

Budget allocation:
  Fish + plants (Rive):  Budget 5ms/frame GPU
  Bubbles:               Budget 2ms/frame GPU  
  Room static:           Budget 1ms/frame GPU
  UI chrome:             Budget 2ms/frame GPU
  Total:                 ≤10ms/frame GPU (leaves headroom)

Rules:
  ❌ NO BackdropFilter inside the tank (expensive, causes milkiness)
  ❌ NO multiple BackdropFilter layers stacked (each costs ~3ms)
  ✅ Limit BackdropFilter to: Tank glass badge pill, Tank switcher pill, Bottom nav
     (3 total — acceptable)
  ✅ Use RepaintBoundary around the tank widget
  ✅ Use RepaintBoundary around the room background (static, can be cached)
  ✅ Bubbles: use CustomPainter not individual Container widgets
```

---

## 14. Code Architecture Recommendations

### 14.1 Decomposing room_scene.dart (1923 lines → target: <400 lines per file)

```
lib/widgets/
  room/
    room_scene.dart              ← Orchestrator only (Stack + layout) < 200 lines
    room_background.dart         ← _CozyRoomPainter + linen texture
    room_stand.dart              ← _AquariumStand + shelf items
    room_lighting.dart           ← _LampGlow + _TankBackglow + _CandleFlicker
    room_decorations.dart        ← _RoomPlant + _ShelfPlant + _Sparkles
  tank/
    themed_aquarium.dart         ← _ThemedAquarium orchestrator
    tank_water.dart              ← Water gradient + substrate
    tank_glass.dart              ← Glass border + badge
    tank_plants.dart             ← SwayingPlant wrappers
    tank_bubbles.dart            ← AmbientBubblesSubtle
  ui/
    tank_switcher.dart           ← Top pill + switching logic
    interactive_objects.dart     ← 4 action buttons
    banners.dart                 ← Streak + hearts overlays
```

### 14.2 Decomposing home_screen.dart (2132 lines → target: split by responsibility)

```
lib/screens/
  home/
    home_screen.dart             ← State management + routing only < 300 lines
    home_body.dart               ← Main layout (SafeArea + Stack) < 200 lines
    home_controller.dart         ← Business logic (tank switching, actions) 
```

### 14.3 Critical Opacity Audit Checklist

Before any release, verify these are NOT present in the codebase:

```
grep -rn "withOpacity" lib/widgets/tank/          # Should only be for glass border
grep -rn "withAlpha" lib/widgets/tank/            # Should be 0 results inside tank
grep -rn "AmbientLightingOverlay" lib/            # Should wrap ONLY room background
grep -rn "BackdropFilter" lib/widgets/tank/       # Should be 0 results
```

---

## 15. Spec at a Glance (Quick Reference Card)

```
┌──────────────────────────────────────────────────────────┐
│                    DANIO TANK PAGE                       │
│                  Quick Reference Card                     │
├──────────────────────────────────────────────────────────┤
│ TANK PROPORTIONS                                         │
│  Width:          screenWidth × 0.88                      │
│  Height:         screenHeight × 0.44                     │
│  Corner radius:  24dp                                    │
│  Margin top:     ~80dp                                   │
├──────────────────────────────────────────────────────────┤
│ WATER (NEVER milky)                                      │
│  Top:    #9ED8EC  (icy teal)    — 100% opacity           │
│  Mid-hi: #6BBDD8  (clear teal)  — 100% opacity           │
│  Mid-lo: #4A9DB5  (deeper teal) — 100% opacity           │
│  Bottom: #2D7A94  (deep teal)   — 100% opacity           │
├──────────────────────────────────────────────────────────┤
│ GLASS BORDER                                             │
│  Color:  #B8DDE8, 2dp, 24dp radius                      │
│  NO fill. Border only.                                   │
├──────────────────────────────────────────────────────────┤
│ WALL                                                     │
│  Light: #F2E6D9 → #E8D8C8 (warm cream)                  │
│  Dark:  #3D3830 → #4A4238 (warm charcoal, NOT blue)     │
├──────────────────────────────────────────────────────────┤
│ FLOOR                                                    │
│  Light: #A0805C (walnut)                                 │
│  Dark:  #5A4030 (espresso)                               │
├──────────────────────────────────────────────────────────┤
│ STAND: #2A2A2A charcoal (NOT wood, see reference image) │
├──────────────────────────────────────────────────────────┤
│ LAMP GLOW: #FFB347 amber (NOT white)                    │
├──────────────────────────────────────────────────────────┤
│ RUG: #C4725A rust / #8B4F3A dark — double-border pattern│
├──────────────────────────────────────────────────────────┤
│ FISH: Flat vector. 3 fish. Coral / Blue / Amber.        │
├──────────────────────────────────────────────────────────┤
│ LABEL: "Living Room Tank · 120L" — frosted pill         │
│         Bottom-center, 36dp height, 20dp radius         │
├──────────────────────────────────────────────────────────┤
│ OPACITY RULES                                           │
│  ✅ Glass border: 100% (solid color, no transparency)   │
│  ✅ Bubbles: 65–85% per bubble (they ARE translucent)   │
│  ✅ Water surface Rive: MAX 15% opacity                  │
│  ❌ Everything else inside tank: NO opacity reduction    │
└──────────────────────────────────────────────────────────┘
```

---

## 16. Design Inspiration: 5 Reference Apps

These apps nail the aesthetic Danio is going for. Study them when making decisions.

### 1. Tap Tap Fish — AbyssRium
**Why it's relevant:** The gold standard for aquarium games. Crystal-clear water with fish that are 100% visible and crisp. The backgrounds are rich illustrated environments — not photorealistic, not diagram-like, but painterly and atmospheric. The environment frames the aquarium; the aquarium is the star. Their UI chrome (buttons, HUD) is minimal and warm-toned, never competing with the fish.
**Steal this:** The water clarity approach. Their fish render at full opacity, no tinting, ever. The backdrop has depth through layering — near objects are warmer/more saturated than far.

### 2. Neko Atsume 2
**Why it's relevant:** Cozy, charming, front-view room scene with furniture. Simple illustration style — not complex, not photorealistic, but packed with personality. The room feels lived-in through small intentional details: a book left out, a plant on a shelf, a warm lamp. The cats (equivalent to fish) are bold, flat, high-contrast against the background.
**Steal this:** The "lived-in room" language. Details that suggest habitation without overwhelming. Charming simplicity > realistic complexity.

### 3. Duolingo (Home Screen)
**Why it's relevant:** The gamification UX master class. Streak banners, heart indicators, progress visualization — all integrated without overwhelming the main experience. The home screen hero (the character/path) occupies ~60–70% of the screen, just like Danio's tank. Everything else is supporting chrome.
**Steal this:** Banner treatment (slide in from top, auto-dismiss, bold emoji + text). Bottom navigation active state (filled icon + color). The 60%+ hero-to-chrome ratio.

### 4. Fishbowl — Social Brain Break App
**Why it's relevant:** A fish bowl as a UI metaphor, with clean flat illustration style. The container (bowl/tank) is rendered with clear glass — you see everything inside perfectly. The water is a color field, not a complex simulation. Proves that simplicity in the water rendering reads as MORE premium, not less.
**Steal this:** The confidence to keep water clean and simple. A rich color doesn't need opacity tricks to feel deep.

### 5. Lofi Girl (YouTube Channel / App Aesthetic)
**Why it's relevant:** Not an app — but the definitive visual language for "warm cozy evening room." The room framing formula: warm amber lamp on one side, cool window on the other, detailed but calm mid-range furniture, a central focused figure/object. This is the exact mood the room scene should evoke.
**Steal this:** The warm lamp vs. cool window contrast. The way the window shows night sky makes the room feel cozier. The "in here is warm, out there is cold" visual story. Apply this to the window treatment and ambient lighting system.

---

## 17. Implementation Priority Order

If coding-agent must prioritize, do these in order:

```
PRIORITY 1 — CRITICAL (fixes the milky water bug):
  1. Remove all opacity modifiers from ThemedAquarium internals
  2. Implement correct water gradient (§2.3)
  3. Move AmbientLightingOverlay to wrap room ONLY, not tank (§6.2)
  4. Fix glass border to be border-only, no fill (§2.4)

PRIORITY 2 — HIGH IMPACT (warmth and polish):
  5. Fix wall dark mode: #4A5668 → #3D3830 (single color change, huge mood lift)
  6. Fix lamp glow: white → #FFB347 amber (single color change)
  7. Add tank backglow (§6.5)
  8. Rug redesign: remove stripes, add double-border pattern (§6.3)

PRIORITY 3 — POLISH (room detail improvements):
  9. Stand redesign: remove cabinet boxes, add open shelf with items (§6.4)
  10. Floor richness: color update + alternating board shading (§6.3)
  11. Picture content: 2-band landscape instead of flat fill (§6.3)
  12. Window curtain: fixed warm linen color + night warmth glow (§6.3)

PRIORITY 4 — ARCHITECTURE (technical debt):
  13. Decompose room_scene.dart (§14.1)
  14. Decompose home_screen.dart (§14.2)
  15. Add RepaintBoundary wrappers (§13.3)
```

---

*"The tank is a jewel. The room is its setting. Crystal water. Bold fish. Warm room. Simple. Beautiful. Done."*

— Apollo 🌟
