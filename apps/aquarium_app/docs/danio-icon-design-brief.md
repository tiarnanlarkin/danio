# Danio App Icon — Design Brief
### Apollo | Mount Olympus Design Department
### 24 February 2026

---

## Brand Foundation

| Element | Value |
|---------|-------|
| **App Name** | Danio |
| **Tagline** | The Duolingo of Aquariums |
| **Primary Colour** | `#3D7068` — deep teal (the colour of a healthy planted tank at golden hour) |
| **Secondary Colour** | `#9F6847` — warm driftwood brown |
| **Aesthetic** | Clean, modern, friendly. Duolingo confidence without the cartoon. |

---

## Part 1: Three Icon Concepts

---

### Concept A: "The Shield Fish" ⭐ RECOMMENDED

**Description:** A front-facing stylised danio fish, rendered as a bold, geometric mascot centred on a teal background. The fish is angled slightly (~15° clockwise tilt) to convey movement and energy. Its body is built from smooth, rounded shapes — an elongated oval with a tapered tail — with three clean horizontal stripes running along its flank (the zebrafish's signature). A single large, confident eye gives it personality without being cartoon-y.

Behind the fish, a subtle circular "glow" in lighter teal creates a badge/shield effect — this is the "learning" cue, evoking achievement badges and XP rings from gamified apps. The fish breaks slightly outside this circle, suggesting it's swimming forward, not contained.

**Why it works:**
- **At 512x512:** The stripes, eye detail, and badge ring are all clearly visible. The tilt creates visual energy.
- **At 48x48:** The fish silhouette remains unmistakable. The circle provides a strong containing shape. The stripes simplify to the "zebrafish = knowledge" identity.
- **Learning + Aquarium:** The badge ring reads as "achievement/progress" (gamification) while the fish is obviously aquatic. Together: "learn about fish."
- **Not generic:** Generic fish apps use side-profile realistic fish or bubbles. This is a *mascot* — it has attitude. It's facing you, like Duo the owl faces you.

**Colour palette:**
- Background fill: `#3D7068`
- Fish body: `#E8F0EE` (pale mint-white — pops against teal)
- Fish stripes: `#2A4F49` (darker teal — reads as the classic zebrafish pattern)
- Fish eye: `#1A1A1A` with a `#FFFFFF` specular highlight
- Fish belly/underside: `#F5F0EB` (warm off-white, touch of the brown family)
- Badge ring: `#4D8A80` (mid-teal, 15% lighter than background)
- Subtle drop shadow on fish: `rgba(0,0,0,0.12)`

---

### Concept B: "The Bubble Scholar"

**Description:** A side-profile danio fish swimming rightward through a single, large, translucent bubble. The bubble serves as the icon's primary shape — a perfect circle with a soft glassy sheen. The fish is mid-swim inside it, with its striped body curving slightly to suggest motion. Two or three tiny bubbles trail behind. The background is a warm-to-teal gradient (bottom-left `#9F6847` fading to top-right `#3D7068`), grounding both brand colours.

**Why it works:**
- The bubble = contained world = aquarium. It also reads as a "knowledge sphere" or "learning orb."
- The gradient uses both brand colours naturally.
- Strong circular composition survives scaling.

**Risk:** At 48x48, the bubble's translucency and the gradient may lose definition. The fish inside a circle could read as "fish in a bowl" — which is slightly generic. The gradient also fights for attention against the fish.

---

### Concept C: "The Stripe Wave"

**Description:** Abstract and bold. The icon background is solid `#3D7068`. The entire icon is dominated by a stylised danio fish built from **three sweeping horizontal stripes** — alternating `#E8F0EE` and `#2A4F49` — that curve from the left edge to the right, tapering into a tail. A minimal eye (circle + highlight) sits at the front. The stripes themselves *are* the fish. Nothing else. No ring, no bubble, no extras.

**Why it works:**
- Incredibly bold and distinctive. Would stand out in any app drawer.
- The stripe-as-fish metaphor is unique — no other aquarium app does this.
- Scales beautifully: at 48x48 it's just coloured stripes with an eye. Instantly recognisable.

**Risk:** May feel too abstract for an audience that needs to understand "this is a fish app" at first glance. The educational/gamification angle is entirely absent from the visual — it relies on the store listing to communicate that. Could read as a design studio logo.

---

## Part 2: Recommended Concept — "The Shield Fish" — Full SVG Specification

### Canvas

| Property | Value |
|----------|-------|
| Dimensions | 512 × 512 px |
| Corner radius | 108px (Google Play adaptive icon spec: ~21% of 512) |
| Background | Solid `#3D7068` |

### Layer 1: Badge Ring

| Property | Value |
|----------|-------|
| Shape | Circle |
| Centre | (256, 262) — slightly below vertical centre for optical balance |
| Radius | 155px |
| Fill | None |
| Stroke | `#4D8A80` |
| Stroke width | 14px |
| Opacity | 0.6 |

### Layer 2: Badge Ring Glow

| Property | Value |
|----------|-------|
| Shape | Circle (same as above) |
| Centre | (256, 262) |
| Radius | 155px |
| Fill | Radial gradient — centre `#4D8A80` at 0% opacity → `#3D7068` at edge |
| Opacity | 0.15 |

### Layer 3: Fish Body (main shape)

The fish is constructed from a single compound path, tilted 15° clockwise from horizontal.

**Fish anatomy (before rotation, relative to fish centre at 0,0):**

| Part | Shape | Dimensions |
|------|-------|-----------|
| Body | Elongated ellipse | 220px wide × 95px tall |
| Tail | Two triangular fins merging from rear of body | 55px extension, 70px spread |
| Dorsal fin | Rounded triangle on top | 35px tall, 50px wide, starts at 30% from nose |
| Pectoral fin | Small rounded triangle, lower-front | 20px tall, 30px wide |

**Fish placement (after rotation):**
- Centre of fish body: (256, 255)
- Rotation: 15° clockwise
- The fish nose breaks ~10px outside the badge ring (top-right)
- The tail sits inside the ring (bottom-left)

### Layer 4: Fish Stripes

Three horizontal stripes across the fish body (following body curvature, clipped to body shape):

| Stripe | Y-offset from fish centre | Height | Colour |
|--------|--------------------------|--------|--------|
| Top stripe | -22px | 12px | `#2A4F49` |
| Middle stripe | 0px | 14px | `#2A4F49` |
| Bottom stripe | +22px | 10px | `#2A4F49` |

Stripes follow the body's elliptical curvature — they aren't straight rectangles but curved bands that taper toward nose and tail.

### Layer 5: Fish Colouring

| Area | Colour |
|------|--------|
| Upper body (above middle stripe) | `#E8F0EE` |
| Lower body / belly | `#F5F0EB` |
| Tail fin | `#D4E4E0` (slightly muted) |
| Dorsal fin | `#D4E4E0` |
| Pectoral fin | `#E8F0EE` |

### Layer 6: Eye

| Property | Value |
|----------|-------|
| Position | 70px from nose tip along body axis, centred vertically on upper body |
| Outer circle | 22px diameter, `#1A1A1A` |
| Inner highlight | 7px diameter, `#FFFFFF`, offset top-right by 4px |
| Secondary highlight | 3px diameter, `#FFFFFF` at 60% opacity, offset bottom-left by 2px |

### Layer 7: Drop Shadow

| Property | Value |
|----------|-------|
| Target | Entire fish group |
| Offset | (0px, 4px) |
| Blur | 12px |
| Colour | `rgba(0, 0, 0, 0.12)` |

### Layer 8: Accent Detail — Progress Arc (subtle gamification cue)

A partial arc along the badge ring, suggesting an XP/progress bar:

| Property | Value |
|----------|-------|
| Shape | Arc along badge ring path |
| Start angle | 220° |
| End angle | 340° (bottom-left quadrant, ~120° sweep) |
| Stroke | `#9F6847` (the warm brown — ties in secondary brand colour) |
| Stroke width | 14px |
| Stroke linecap | Round |
| Opacity | 0.85 |

This is the key detail that separates this from a generic fish icon. The brown progress arc on the teal ring reads as a "level-up" or "progress tracker" — instantly communicating gamification to anyone who's used Duolingo, Headspace, or any habit-tracking app.

---

## Part 3: Image Generation Prompt

### For DALL-E 3 / Midjourney v6

```
App icon design, 512x512 pixels, rounded square shape. Deep teal background (#3D7068). A stylised zebrafish (danio) as the central mascot, angled 15 degrees clockwise, facing slightly toward the viewer. The fish has an elongated smooth body in pale mint-white (#E8F0EE) with three clean horizontal dark teal stripes (#2A4F49) running along its flank. Large confident round eye, black with white specular highlight. Warm off-white belly. Simple rounded fins.

Behind the fish, a subtle circular badge ring in lighter teal (#4D8A80) at 60% opacity, like an achievement badge or XP ring. The fish breaks slightly outside the ring at the top-right, swimming forward. A partial arc along the bottom of the ring in warm brown (#9F6847), suggesting a progress bar — a gamification cue.

Style: clean vector illustration, modern app icon aesthetic, bold flat colours with minimal shading, Duolingo-level polish and confidence. Not photorealistic, not cartoon-y. Professional, friendly, approachable. Single light source from top-left creating a very subtle drop shadow beneath the fish.

No text. No bubbles. No water effects. No background pattern. Pure, clean, icon-grade design. The fish is the hero. The ring is the structure. The progress arc is the story.
```

### Midjourney-specific suffix:
```
--ar 1:1 --s 250 --no text, words, letters, bubbles, water drops, realistic --v 6
```

### Stable Diffusion negative prompt:
```
text, words, letters, watermark, signature, bubbles, water drops, water splash, photorealistic, 3D render, cartoon, chibi, multiple fish, background pattern, border, frame, gradient background
```

---

## Quick Reference Card

| Element | Hex | Usage |
|---------|-----|-------|
| Background | `#3D7068` | Icon fill, primary brand |
| Fish body | `#E8F0EE` | Main fish colour |
| Fish belly | `#F5F0EB` | Underside warmth |
| Fish stripes | `#2A4F49` | Zebrafish identity |
| Badge ring | `#4D8A80` | Achievement/container ring |
| Progress arc | `#9F6847` | Gamification cue, secondary brand |
| Eye | `#1A1A1A` | Personality |
| Highlight | `#FFFFFF` | Eye sparkle |
| Fin detail | `#D4E4E0` | Muted fin colour |

---

## Design Rationale — Why "The Shield Fish" Wins

1. **Mascot potential.** Duolingo has Duo. Danio now has... the danio. A front-facing fish with attitude becomes the face of the brand across all touchpoints — store listing, splash screen, notifications, social media.

2. **The progress arc is doing heavy lifting.** Without it, this is a fish icon. With it, it's a *learning* fish icon. That single warm brown arc on the teal ring tells the entire brand story in one visual beat: "track your progress in fishkeeping."

3. **Both brand colours appear naturally.** The teal dominates (as it should — it's the aquatic world), and the brown appears as a purposeful accent, not an afterthought.

4. **Scaling is bulletproof.** At 48x48: teal square, white fish shape with dark stripes, brown accent. Every element survives. At 512x512: full detail, specular highlights, the glow, the progress arc's rounded caps.

5. **Platform compliance.** No transparency. No text. Clean rounded-square format. Passes Google Play adaptive icon requirements without modification.

---

*"The fish isn't just swimming — it's going somewhere. That's the whole point of Danio."*

— Apollo 🎨
