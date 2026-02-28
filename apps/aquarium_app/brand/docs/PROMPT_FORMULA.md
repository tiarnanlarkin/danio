# Danio — Image Generation Prompt Formula
> Derived from design reference `v2-t3kol-wjwpf.jpg`
> Target model: Nano Banana Pro (gemini-3-pro-image-preview)

---

## The Core Style DNA

| Element | Value |
|---------|-------|
| Art style | Pixar / DreamWorks concept art, cinematic animation background painting |
| Technique | Digital cel-shading with painterly gradients, variable-weight linework |
| Lighting | Warm primary (amber/gold) + cool ambient fill (blue-slate) — always this contrast |
| Shadows | Chromatic, never grey — darks shift cool (blue-purple), lights stay amber |
| Colours | Warm honey-amber #C8884A + cool slate #4A5A6B + teal accent #4A9A8C |
| Mood | Cosy, intimate, aspirational — "sanctuary" feeling |
| Depth | Layered z-depth with atmospheric perspective on backgrounds |

---

## Master Template

```
[SUBJECT], [POSE/ACTION], [SETTING],
Pixar concept art style, cinematic animation illustration,
warm amber-gold key lighting, cool blue-slate ambient fill,
chromatic shadows in cool purple-blue, painterly gradients,
variable-weight dark linework, cel-shading with soft gradient overlays,
cosy and aspirational mood, warm golden-hour colour palette,
aquarium blues and ambers, rich depth and layering,
professional animation studio quality
```

---

## Asset-Specific Formulas

### App Icon
```
[FISH] cartoon character, centered, confident pose,
rounded square icon composition with warm amber gradient background,
Pixar animation style, warm amber-gold key lighting, cool blue-slate shadow fill,
chromatic shadows in blue-purple, bold variable-weight linework,
cel-shading with painterly gradients, golden-hour palette,
clean white highlight on eye, no text, icon-safe composition,
professional animation studio quality, 1:1 square format
```

### Mascot (full body)
```
Friendly [FISH] mascot character, full body, [EMOTION] expression,
big expressive eyes with white catchlight, Pixar animation style,
warm amber-gold key lighting from upper-left, cool blue-slate ambient fill,
chromatic shadows in cool purple-blue, painterly gradients,
bold dark linework, cel-shading, white background,
cosy and approachable personality, golden-hour colour palette,
aquarium teal accent tones, professional animation studio quality
```

### Hero Illustration (scene)
```
[SCENE], cosy home aquarium setting,
Pixar/DreamWorks environment concept art, cinematic animation background painting,
warm amber key light, cool blue-slate ambient fill,
layered z-depth: foreground details, midground focal tank, background soft-focus,
chromatic shadows in blue-purple, atmospheric perspective on background,
painterly gradients, variable-weight linework, cel-shading,
golden-hour warm palette with aquarium blue-teal accents,
organised richness — curated detail without clutter,
cosy aspirational mood, professional animation studio quality, 16:9 wide format
```

### Feature Graphic (Play Store banner)
```
[FOCAL SUBJECT] in [SETTING],
cinematic Pixar concept art style, wide hero composition,
dramatic warm amber-gold backlight, cool blue-slate fill shadows,
chromatic shadows in purple-blue, deep layered depth,
painterly gradients with cel-shading, golden-hour atmosphere,
aquarium blue-teal water tones contrasting warm amber room tones,
aspirational and premium mood, atmospheric perspective,
professional animation studio quality, 16:9 widescreen format
```

---

## The 5 Style Lock Words (always include)
1. `Pixar concept art style`
2. `warm amber-gold key lighting, cool blue-slate ambient fill`
3. `chromatic shadows in cool purple-blue`
4. `painterly gradients, cel-shading`
5. `cosy golden-hour palette`

---

## Avoid (kills the style)
- photorealistic, watercolour, flat design, neon, vibrant, 3D render, anime

---

## Colour Palette
| Name | Hex | Use |
|------|-----|-----|
| Honey amber | #C8884A | Key light, warm surfaces |
| Slate blue-grey | #4A5A6B | Ambient fill, cool areas |
| Deep blue-violet | #2A3548 | Deep shadows |
| Teal accent | #4A9A8C | Fish, water, aquarium glass |
| Brass-gold | #B8862A | Highlights, metallic accents |
| Cream-white | #F5EED8 | Hotspot highlights, catchlights |

---

## Validation Prompt (test style consistency)
```
A happy clownfish swimming near coral in a cosy home aquarium,
Pixar concept art style, cinematic animation illustration,
warm amber-gold key lighting, cool blue-slate ambient fill,
chromatic shadows in cool purple-blue, painterly gradients, cel-shading,
variable-weight dark linework, cosy golden-hour palette,
aquarium teal accent, professional animation studio quality
```

---

## v2 Refinements (2026-02-28) — 8.2/10

Key changes that improved score from 6.5 → 8.2:

**Add to all prompts:**
- `no outlines, no line art, fully painterly`
- `volumetric lighting, god rays`
- `subsurface scattering on fish scales`
- `soft atmospheric depth, visible brushwork`

**Remove from prompts:**
- ~~`cel-shading`~~ (pulls toward cartoon, not painterly)
- ~~`variable-weight dark linework`~~ (adds outlines)

**Still to solve:**
- Chromatic shadows need pushing harder: add `deep violet-indigo shadows in cool zones, warm ochre-amber in lit zones`
- Character integration: add `atmospheric perspective, character integrated into scene lighting`

### Updated Master Template (v2)
```
[SUBJECT], [POSE/ACTION], [SETTING],
Pixar DreamWorks environment concept art style,
no outlines, no line art, fully painterly,
volumetric lighting with god rays, subsurface scattering,
warm amber-gold key light from upper right,
cool blue-slate ambient fill in shadows,
deep violet-indigo shadows in cool zones, warm ochre-amber in lit zones,
rich painterly gradients with visible brushwork,
soft atmospheric depth, character integrated into scene lighting,
golden-hour colour palette, aquarium teal-blue water tones,
contrasting warm amber background tones,
cosy aspirational mood, cinematic composition,
professional animation studio background painting quality
```
