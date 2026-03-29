# Danio Art Bible

**Last updated:** 2026-03-29
**Canonical reference:** The 15 fish/invertebrate assets in `assets/images/fish/` are the style bible. Every new asset must match these.

---

## 1. The Canonical Style (from onboarding fish)

### Outline
- **Color:** Deep charcoal/navy `#1A1A1A` to `#2D2D2D` (NOT pure black `#000000`)
- **Weight:** 3–4px for body contour, 2px for internal details (gills, fin rays, mouth)
- **Consistency:** Uniform thickness — minimal tapering
- **Quality:** Clean, smooth, vector-like with very slight organic wobble
- **Edges:** Fully closed shapes, no broken lines

### Shading
- **Technique:** Soft gradient blending (cel-gradient hybrid) — NOT flat cel, NOT photorealistic
- **Tonal stops:** 2–3 per colour zone (base → shadow → optional deep shadow)
- **Shadow colour:** Darker, desaturated version of local colour (never pure black)
- **Shadow placement:** Underside of body, base of fins, between overlapping elements
- **Transitions:** Soft airbrush-style gradients, not hard edges
- **Light direction:** Top-left, consistent 45° overhead lighting across ALL assets

### Highlights
- **Primary:** 1–2 white circular specular spots on upper head/body
- **Shape:** Perfect circles or small ellipses (stylised, not realistic)
- **Colour:** Pure white `#FFFFFF`
- **Placement:** Upper-left quadrant, suggesting glossy wet surface
- **Secondary:** Subtle lighter gradient on upper body curve (rim light effect)

### Eyes
- **Shape:** Large, circular, oversized (kawaii influence)
- **Size:** ~20–25% of head area
- **Structure:** White sclera → dark iris → black pupil → single white circular catchlight (upper-left)
- **Expression:** Friendly, curious, forward-facing
- **Outline:** Same weight as body outline

### Fins
- **Rendering:** Semi-detailed — subtle linear striations suggesting fin rays
- **Colour:** Local species colour with gradient (base → deeper at edges)
- **Translucency:** Slight — not opaque blocks, not fully transparent
- **Outline:** Consistent with body, slightly softer on flowing edges

### Body Proportions
- **Head-to-body:** ~1:2 (head is roughly 1/3 of body length)
- **Eye-to-head:** Exaggerated, ~20–25% of head width
- **Shape:** Compact, rounded — chibi-adjacent but not extreme chibi
- **Overall:** Sticker/mascot aesthetic, readable at small sizes

### Background
- **All characters:** Transparent PNG with subtle drop shadow
- **Shadow:** Soft, blurred, grey, offset downward

### Colour Approach
- **Vibrant and saturated** — bold species-accurate colours
- **Warm palette bias** overall (teals, corals, ambers, golds)
- **Complementary schemes** per species (guppy = teal + orange, betta = blue + red)

---

## 2. What This Means for New Assets

### Scene Illustrations (headers, panels, badges)
Any fish characters WITHIN scene illustrations must match the canonical style above. The scene/environment around them can be slightly simpler but must:
- Use the same **3–4px outline weight** on any characters
- Use the same **gradient shading** (not flat cel-shading)
- Use the same **circular specular highlights**
- Use the same **large expressive eyes**
- Match the **warm, vibrant, saturated palette**

Environments/backgrounds can be slightly flatter and simpler than characters — that's fine. Characters should POP against backgrounds.

### Room Backgrounds
Room backgrounds should be **warm illustrated interiors** with:
- Visible structure: wall, floor, ceiling, window, shelving
- Warm lighting from a visible source
- Bold colour blocks with soft shading
- The **warm ambient glow** that matches the onboarding journey background's golden warmth
- Style: Think Animal Crossing interiors with Studio Ghibli colour warmth

### Assets to Avoid
- ❌ Flat cel-shading with hard shadow edges (too stark)
- ❌ Photorealism (clashes with cartoon characters)
- ❌ Pure black `#000000` outlines (use charcoal/navy)
- ❌ Thin/varied line weight (ours is thick and uniform)
- ❌ Chibi extreme proportions (head = body) — ours are chibi-adjacent, not full chibi
- ❌ Matte/flat colours without gradient depth
- ❌ Neon or cold colour palettes

---

## 3. Existing Asset Inventory

### Canonical Fish (15 assets) — `assets/images/fish/`
| Species | File | Style Match |
|---------|------|-------------|
| Zebra Danio | zebra_danio.png | ✅ Mascot — defines the standard |
| Neon Tetra | neon_tetra.png | ✅ |
| Guppy | guppy.png | ✅ |
| Betta | betta.png | ✅ |
| Cherry Barb | cherry_barb.png | ✅ |
| Harlequin Rasbora | harlequin_rasbora.png | ✅ |
| Platy | platy.png | ✅ |
| Molly | molly.png | ✅ |
| Bronze Corydoras | bronze_corydoras.png | ✅ |
| Bristlenose Pleco | bristlenose_pleco.png | ⚠️ Outline slightly softer |
| Otocinclus | otocinclus.png | ✅ |
| Angelfish | angelfish.png | ✅ (replaced Wave 1) |
| Cherry Shrimp | cherry_shrimp.png | ✅ |
| Amano Shrimp | amano_shrimp.png | ✅ |
| Nerite Snail | nerite_snail.png | ⚠️ Outline heavier, gloss oversized |

### Headers — `assets/images/illustrations/`
| Asset | Status |
|-------|--------|
| practice_header.png | ❌ REGEN NEEDED — flat cel style, thin outlines, chibi fish |
| learn_header.png | ❌ REGEN NEEDED — flat cel style, thin outlines, different character proportions |

### Room Backgrounds — `assets/backgrounds/`
12 total. Cotton, dreamy, pastel, watercolor regenerated in Wave 4. All need style review against this bible.

### Placeholder
| Asset | Status |
|-------|--------|
| placeholder.webp | ❌ REVIEW — amber watercolor wash, not matching illustrated style |

---

## 4. Generation Prompt Template

When generating ANY new illustrated asset for Danio, include this style block in the prompt:

```
MANDATORY ART STYLE (match exactly):
- Bold uniform dark charcoal outlines (#1A1A1A), 3-4px weight, no tapering
- Soft gradient shading (NOT flat cel-shading), 2-3 tonal stops per colour zone
- Light from top-left at 45°, shadows on underside using darker desaturated local colour
- 1-2 pure white circular specular highlights on upper-left of each rounded shape
- Large expressive circular eyes (20-25% of head), white sclera, dark pupil, white catchlight dot upper-left
- Warm vibrant saturated colours — teals, corals, ambers, golds
- Semi-detailed fin rendering with subtle gradient and linear striations
- Chibi-adjacent proportions (head ~1/3 body, NOT extreme chibi)
- Clean smooth vector-like outlines with slight organic quality
- Drop shadow beneath character/object
- NO pure black (#000000), NO neon, NO photorealism, NO thin varied lines, NO flat matte colours
- Reference images: neon_tetra.png, guppy.png, betta.png, zebra_danio.png from Danio app
```

---

*This document is the final authority on Danio's visual style. When in doubt, look at zebra_danio.png — it's the mascot and the benchmark.*
