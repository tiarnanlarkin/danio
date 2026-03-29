# Feature Graphic Brief — Danio: Learn Fishkeeping
> Version: v1.0 — March 2026
> For: Google Play Store Feature Graphic
> Produced by: Aphrodite · Mount Olympus Growth Division

---

## Specification

| Property | Value |
|---|---|
| **Dimensions** | 1024 × 500 px |
| **Format** | PNG or JPEG (PNG preferred for sharpness) |
| **Max file size** | 1MB |
| **Safe zone** | Keep all key elements within central 924 × 400 px (50px margin each side) |
| **Text overlay** | Design must read perfectly WITHOUT text — Google may overlay app name |
| **Orientation** | Landscape only |

---

## Art Style Reference

Follow the **Danio Art Bible** (`docs/art-bible.md`) exactly:

- **Outlines:** 3–4px charcoal/navy (`#1A1A1A`–`#2D2D2D`), clean, uniform weight
- **Shading:** Cel-gradient hybrid — soft gradient blending, 2–3 tonal stops per zone
- **Highlights:** White circular specular spots (glossy wet-surface suggestion)
- **Eyes:** Large, expressive (kawaii-adjacent), with white sclera + dark iris + pupil + single catchlight
- **Colour palette:** Warm amber/gold/teal — vibrant, saturated, warm palette bias
- **Background style:** Warm illustrated environment — NOT photorealistic, NOT flat
- **Characters must POP** against background; use depth and contrast

**Reference files:** `assets/images/fish/zebra_danio.png` is the mascot and style bible. All fish in the graphic must match this standard.

---

## Colour Palette

| Role | Colour | Hex |
|---|---|---|
| Primary warm | Amber gold | `#F5A623` |
| Primary cool | Teal/aqua | `#2AC4B3` |
| Deep water | Dark teal | `#0D5E6B` |
| Light accent | Warm cream | `#FFF5E4` |
| Outline | Charcoal navy | `#1A1A2E` |
| Bubble/highlight | Pure white | `#FFFFFF` |
| Shadow tint | Deep amber shadow | `#C47A1A` |

The overall impression should be: **warm, inviting, slightly magical, aquatic but not cold**.

---

## Required Elements

### Must Include
- **Zebra Danio mascot** — the hero character (`zebra_danio.png` style). Friendly, curious expression. The mascot is the emotional anchor.
- **Aquarium glass/tank** — implied or explicit, with water-blue/teal gradient
- **Aquatic plants** — lush green (e.g., Amazon swords, vallisneria, java fern) — add life and depth
- **Bubbles** — rising bubble trails; white, semi-transparent, vary in size
- **Warm ambient glow** — the "cosy tank" feeling; backlit from tank light or warm room light
- **Depth** — foreground elements (plants, pebbles) + midground (fish) + background (tank wall, room glow)

### Optional / Variant-specific
- Secondary fish species (guppy, neon tetra, betta — depending on variant)
- Tank substrate (pebbles, sand, gravel — warm amber/rust tones)
- XP/learning elements (small floating gem or graduation cap — only in Variant 3)
- Soft bokeh or light-ray effect in background water

### Must NOT Include
- Any text (the Play Store will overlay app name if it chooses)
- Real-world photography
- Pure black `#000000` anywhere
- Cold blue/grey palettes
- Cluttered or busy compositions — breathe, give the mascot room

---

## Variants

### Variant 1 — "Mascot Hero" (RECOMMENDED for primary submission)

**Composition:** Centred mascot, landscape panorama

- **Focus:** The Zebra Danio mascot fills ~40% of vertical height, positioned slightly left of centre (rule of thirds)
- **Background:** Wide aquarium panorama — teal-to-amber gradient from bottom to top, lush plant life on left and right edges framing the fish
- **Foreground:** A few gentle bubbles rising past the mascot, one or two small pebbles bottom-edge
- **Mood:** Calm, confident, welcoming. Like meeting a friend underwater.
- **Use case:** Best general-purpose. Works at all sizes thumbnails down to 200px wide.

**Layout sketch:**
```
[plants]  [DANIO MASCOT — centre-left]  [plants]
           ^^^^^bubbles^^^^^
[pebbles/substrate — bottom strip]
```

---

### Variant 2 — "Aquarium World" (Wide scene)

**Composition:** Full aquascape — the tank as a world

- **Focus:** A beautifully planted aquarium interior. The mascot is present but slightly smaller — swimming through the scene rather than posing for it
- **Background:** Suggested room beyond the glass (warm amber glow through tank glass, bokeh room)
- **Multiple fish:** Danio mascot + 2–3 secondary species swimming in loose formation (neon tetras or guppies)
- **Plants:** Dense, layered planting — creates a rich, lush "reward" feeling
- **Mood:** Aspirational. "This is what your tank could look like." Slightly more complex.
- **Use case:** Best if Google overlays text on the left; the right side has visual interest without competing

**Layout sketch:**
```
[DENSE PLANTS - left]  [open water + fish group - centre-right]
                       [warm glow from behind glass - far right]
[substrate + foreground pebbles - bottom]
```

---

### Variant 3 — "Learning Journey" (Gamified feel)

**Composition:** Mascot + subtle learning/game elements

- **Focus:** The Zebra Danio mascot wearing a subtle graduate cap (or surrounded by floating XP gems/stars) — the "smart fish" concept
- **Background:** Simplified aquarium environment — more stylised, slightly flatter, lets the character and elements breathe
- **Accent elements:** 3–5 small floating gems (in brand teal/amber) and a subtle XP bar arc or star burst behind the mascot
- **Mood:** Playful, gamified, "this is fun to learn". Closer to a game icon aesthetic.
- **Use case:** Best for A/B test against Variant 1. May perform better in the "Games" browse context if Play Store categorises there.

**Layout sketch:**
```
[simplified aquarium bg]
     [gem ✦] [gem ✦]
[DANIO MASCOT — slightly right of centre, looking left]
     [gem ✦]    [XP arc/glow behind]
[simple substrate strip]
```

---

## Composition Rules (All Variants)

1. **Rule of thirds** — the mascot's eye should land on a third-line intersection
2. **Depth layers** — minimum 3: foreground plants/pebbles, midground fish, background water/glow
3. **Leading lines** — bubble trails and plant stems should direct the eye toward the mascot
4. **Breathing room** — the safe zone has ~50px padding; keep mascot eye-line in upper 40% of canvas
5. **Thumbnail test** — must read clearly at 300×147px (how it appears in Play Store browse grids)

---

## Deliverables

| File | Variant | Notes |
|---|---|---|
| `feature_graphic_v1_hero.png` | Variant 1 | Primary submission |
| `feature_graphic_v2_world.png` | Variant 2 | A/B test option |
| `feature_graphic_v3_learning.png` | Variant 3 | A/B test option |

All at 1024×500px, PNG, exported at 72dpi (screen), <1MB each.

---

## Notes for Apollo

- The Zebra Danio mascot file: `assets/images/fish/zebra_danio.png` — use this as the direct character reference. Do not redesign; extend the existing character.
- The warm ambient glow from room backgrounds in the app (`assets/images/rooms/`) can be referenced for background lighting mood.
- Avoid overly dark backgrounds — the Play Store feature graphic sits on a white/grey card; too-dark images lose contrast.
- Test all variants at 50% zoom on a white background before finalising.

---

*Brief written by Aphrodite · "Irresistible isn't accidental."*
