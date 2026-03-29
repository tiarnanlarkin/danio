# Danio — Design Direction

**Updated:** 2026-03-29
**Reference for:** All visual work, art generation, UI decisions

---

## The Art Identity

**Style:** Chibi-proportioned, warm, illustrated
**Benchmark:** The Zebra Danio mascot fish sprite — everything should feel like it came from the same artist
**Palette:** Warm cream, amber, teal, soft gradients
**Surface treatment:** Glassmorphism on home stage system, soft frosted panels
**Typography:** Nunito (body) + Fredoka (display/fun), managed via AppTypography tokens
**Component system:** GlassCard (5 variants: frosted, soft, aurora, cozy, watercolor), AppButton, AppRadius, AppSpacing

---

## What Matches the Art Bible ✅

- Zebra Danio mascot
- 13 of 15 fish sprites
- 10 of 12 room backgrounds
- GlassCard component system
- Warm cream/amber/teal palette throughout app
- Home room view with animated swimming sprites
- Quiz/lesson screens
- Bottom sheet glassmorphism

## What Breaks the Art Bible ❌

| Asset | Problem | Fix ID |
|-------|---------|--------|
| learn_header.webp | Flat-cel illustration, not chibi | FQ-V1 |
| practice_header.webp | Flat-cel illustration, not chibi | FQ-V1 |
| angelfish.webp | Doesn't match art bible proportions | FQ-V2 |
| amano_shrimp.webp | Doesn't match art bible proportions | FQ-V2 |
| onboarding_journey_bg.webp | Photorealistic in an illustrated app | FQ-V3 |
| placeholder.webp | Watercolour style, not chibi | FQ-V4 |
| room-bg-cozy-living.webp | Below quality bar (5.5/10) | FQ-V5 |
| Badge icons (4) | Don't exist | FQ-V6 |
| bristlenose_pleco.png | Saved in Palette mode, not RGBA | FQ-V7 |

---

## Design System State

### What's Strong
- 200+ named colour constants with pre-computed alpha variants
- WCAG AA annotations on colour tokens
- AppSpacing: 91.6% compliance (2,953 token vs 271 bypass)
- AppRadius: 97% compliance (509 token vs 16 bypass)
- Only 5 BackdropFilter instances (exceptional discipline)
- 159 reduced-motion checks
- GlassCard: haptics, 5 variants, semantic labels

### What's Weak
- AppTypography: 89.1% compliance (1,226 token vs 150 bypass)
- Onboarding exception zone: 59 raw GoogleFonts calls, ~25 raw buttons
- 339 hardcoded Color(0x...) values (deferred — DE-9)
- AppButton/AppCard bypass their own tokens in places (deferred)

### Accessibility Baseline
- WCAG AA contrast required on all body text (AppColors.primaryLight FAILS — FQ-D3)
- ≥48dp touch targets on all interactive elements (Quick Start fails — FQ-D4)
- Tooltip on all icon-only buttons (password toggle fails — FQ-D5)
- reduced-motion respected (currently strong — 159 checks)

---

## Art Generation Notes

When generating replacement assets:
- **Style reference:** Use existing chibi sprites that pass the art bible as references
- **Resolution:** Match existing asset sizes (check cacheWidth values in code)
- **Format:** WebP for illustrations, PNG for sprites
- **Naming:** Match existing filename exactly (drop-in replacement)
- **Validation:** Must pass art bible comparison before committing
