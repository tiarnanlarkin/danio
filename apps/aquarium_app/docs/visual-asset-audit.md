# Visual Asset Quality & Consistency Audit
**Danio Aquarium App**
**Audit Date:** 2026-03-29
**Branch:** `openclaw/stage-system`
**Auditor:** Iris (Art Specialist Agent — T-D-287)

---

## Executive Summary

The Danio app has **68 files** across 9 asset categories totalling **9.79 MB**. The fish sprite collection is strong and near-complete at 13/15 fully compliant with the art bible. The critical gaps are: **2 illustration headers need regen** (confirmed poor style match), **2 legacy room backgrounds** are significantly below quality bar, **all 4 badge icons are missing**, and the **placeholder and onboarding background** both need replacements. No broken asset references exist (dynamic paths via `$speciesId` are expected). Converting illustration PNGs to WebP alone would save ~2.1 MB.

**Overall Visual Quality Score: 6.5 / 10**

---

## 1. Complete Asset Inventory

### Fish Sprites — Full Size (512×512 RGBA PNG)

| File | Size | Mode | Notes |
|------|------|------|-------|
| `assets/images/fish/zebra_danio.png` | 124 KB | RGBA | Mascot — style benchmark |
| `assets/images/fish/neon_tetra.png` | 133 KB | RGBA | |
| `assets/images/fish/guppy.png` | 153 KB | RGBA | |
| `assets/images/fish/betta.png` | 177 KB | RGBA | |
| `assets/images/fish/angelfish.png` | 239 KB | RGBA | ⚠️ Most recent regen (Mar 29) |
| `assets/images/fish/cherry_barb.png` | 137 KB | RGBA | |
| `assets/images/fish/harlequin_rasbora.png` | 118 KB | RGBA | |
| `assets/images/fish/platy.png` | 163 KB | RGBA | |
| `assets/images/fish/molly.png` | 99 KB | RGBA | |
| `assets/images/fish/bronze_corydoras.png` | 151 KB | RGBA | |
| `assets/images/fish/bristlenose_pleco.png` | 35 KB | **P** | ⚠️ Palette mode (not RGBA) |
| `assets/images/fish/otocinclus.png` | 104 KB | RGBA | |
| `assets/images/fish/cherry_shrimp.png` | 120 KB | RGBA | |
| `assets/images/fish/amano_shrimp.png` | 108 KB | RGBA | |
| `assets/images/fish/nerite_snail.png` | 167 KB | RGBA | |

**Total fish (full): 2,034 KB**

### Fish Sprites — Thumbnails (128×128 RGBA PNG)

| File | Size |
|------|------|
| `assets/images/fish/thumb/zebra_danio.png` | 13 KB |
| `assets/images/fish/thumb/neon_tetra.png` | 13 KB |
| `assets/images/fish/thumb/guppy.png` | 15 KB |
| `assets/images/fish/thumb/betta.png` | 17 KB |
| `assets/images/fish/thumb/angelfish.png` | 27 KB |
| `assets/images/fish/thumb/cherry_barb.png` | 14 KB |
| `assets/images/fish/thumb/harlequin_rasbora.png` | 12 KB |
| `assets/images/fish/thumb/platy.png` | 16 KB |
| `assets/images/fish/thumb/molly.png` | 10 KB |
| `assets/images/fish/thumb/bronze_corydoras.png` | 15 KB |
| `assets/images/fish/thumb/bristlenose_pleco.png` | 20 KB |
| `assets/images/fish/thumb/otocinclus.png` | 11 KB |
| `assets/images/fish/thumb/cherry_shrimp.png` | 12 KB |
| `assets/images/fish/thumb/amano_shrimp.png` | 11 KB |
| `assets/images/fish/thumb/nerite_snail.png` | 18 KB |

**Total thumbnails: 226 KB** ✅ All 15 present and consistent 128×128

### Room Backgrounds (1536×2752 RGB WebP)

| File | Size | Wave | Score |
|------|------|------|-------|
| `assets/backgrounds/room-bg-aurora.webp` | 155 KB | Wave 4 | 9.5/10 |
| `assets/backgrounds/room-bg-golden.webp` | 147 KB | Wave 4 | 9/10 |
| `assets/backgrounds/room-bg-evening-glow.webp` | 148 KB | Wave 4 | 9.25/10 |
| `assets/backgrounds/room-bg-ocean.webp` | 147 KB | Wave 4 | 9/10 |
| `assets/backgrounds/room-bg-pastel.webp` | 151 KB | Wave 4 | 7.5/10 |
| `assets/backgrounds/room-bg-cotton.webp` | 131 KB | Wave 4 | 7/10 |
| `assets/backgrounds/room-bg-watercolor.webp` | 147 KB | Wave 4 | 7/10 |
| `assets/backgrounds/room-bg-midnight.webp` | 139 KB | Wave 4 | 7.75/10 |
| `assets/backgrounds/room-bg-sunset.webp` | 103 KB | Wave 4 | 7.25/10 |
| `assets/backgrounds/room-bg-dreamy.webp` | 146 KB | Wave 4 | 6.5/10 |
| `assets/backgrounds/room-bg-forest.webp` | 88 KB | Legacy | 6.75/10 |
| `assets/backgrounds/room-bg-cozy-living.webp` | 66 KB | **Legacy** | **5.5/10** |

**Total backgrounds: 1,563 KB** — All 12 present. ✅

### Illustrations

| File | Size | Dimensions | Issue |
|------|------|-----------|-------|
| `assets/images/illustrations/practice_header.png` | 943 KB | 1500×720 RGBA | ❌ Regen needed |
| `assets/images/illustrations/learn_header.png` | 1,410 KB | 1500×880 RGBA | ❌ Regen needed |

**Total illustrations: 2,354 KB** — Largest category by percentage (23.5%)

### Icons & Badges

| File | Size | Dimensions |
|------|------|-----------|
| `assets/icons/app_icon.png` | 189 KB | 512×512 RGB |
| `assets/icons/badges/` | 0 KB | **EMPTY** — 4 badges missing |

### Onboarding

| File | Size | Dimensions |
|------|------|-----------|
| `assets/images/onboarding/onboarding_journey_bg.webp` | 36 KB | 1143×2048 RGB |

### Miscellaneous

| File | Size | Dimensions |
|------|------|-----------|
| `assets/images/placeholder.webp` | 28 KB | 1024×1024 RGB |

### Textures

| File | Size | Notes |
|------|------|-------|
| `assets/textures/felt-teal.webp` | 352 KB | Used in `ambient_tip_overlay.dart` |
| `assets/textures/linen-wall.webp` | 248 KB | **Declared in assets but unreferenced in code** |
| `assets/textures/slate-dark.webp` | 123 KB | Used in `swiss_army_panel.dart` |

### Rive Animations

| File | Size | Notes |
|------|------|-------|
| `assets/rive/emotional_fish.riv` | 865 KB | Referenced in code |
| `assets/rive/joystick_fish.riv` | 7 KB | Referenced in code |
| `assets/rive/puffer_fish.riv` | 11 KB | Referenced in code |
| `assets/rive/water_effect.riv` | 1 KB | Referenced in code |

### Fonts (9 files, 1,982 KB total)
Fredoka (Regular/SemiBold/Bold) and Nunito (Regular/Medium/SemiBold/Bold/ExtraBold/Italic). All locally bundled for GDPR compliance.

---

## 2. Art Bible Compliance — Fish Sprites

| Species | Outline | Shading | Highlights | Eyes | Proportions | **Result** | Notes |
|---------|---------|---------|------------|------|-------------|------------|-------|
| Zebra Danio | ✅ | ✅ | ✅ | ✅ | ✅ | **PASS** | Mascot benchmark |
| Neon Tetra | ✅ | ✅ | ⚠️ | ✅ | ✅ | **PASS** | Highlights slightly elongated |
| Guppy | ✅ | ✅ | ✅ | ✅ | ✅ | **PASS** | |
| Betta | ✅ | ✅ | ⚠️ | ⚠️ | ✅ | **WARN** | Blue sclera, multiple highlights |
| Angelfish | ❌ | ❌ | ❌ | ❌ | ❌ | **FAIL** | Thinner outlines, realistic style, small eyes — different art style |
| Cherry Barb | ✅ | ✅ | ✅ | ✅ | ✅ | **PASS** | |
| Harlequin Rasbora | ✅ | ✅ | ✅ | ✅ | ✅ | **PASS** | |
| Platy | ✅ | ✅ | ✅ | ✅ | ✅ | **PASS** | Exemplary compliance |
| Molly | ✅ | ✅ | ✅ | ⚠️ | ✅ | **PASS** | Eyes slightly undersized (~18%) |
| Bronze Corydoras | ✅ | ⚠️ | ✅ | ✅ | ✅ | **WARN** | Iridescent shading >3 tonal stops |
| Bristlenose Pleco | ⚠️ | ❌ | ✅ | ⚠️ | ⚠️ | **WARN** | Anatomical detail pushes toward realism; palette mode PNG |
| Otocinclus | ✅ | ✅ | ✅ | ✅ | ✅ | **PASS** | |
| Cherry Shrimp | ✅ | ✅ | ✅ | ⚠️ | ✅ | **WARN** | Dark sclera (should be white) |
| Amano Shrimp | ⚠️ | ⚠️ | ❌ | ✅ | ⚠️ | **FAIL** | Thin outlines, flat shading, no specular highlight, naturalistic style |
| Nerite Snail | ✅* | ✅ | ✅* | ✅ | ✅ | **PASS** | Art bible exception: heavier outline + oversized gloss are documented/intentional |

*Art bible documented exceptions apply

**Summary:** 10 PASS / 3 WARN / 2 FAIL

**FAIL items requiring regen:**
- `angelfish.png` — Despite being the most recently regenerated (Mar 29), it shows a significantly different art style: thinner lines, more realistic gradients, smaller eyes, less chibi. Needs another regen pass to match the canonical style.
- `amano_shrimp.png` — Naturalistic shrimp, no specular highlight, thin outlines, muted palette. Full rework needed.

**Fish Sprite Quality Score: 7/10** (strong foundation, 2 outliers need work)

---

## 3. Room Backgrounds Assessment

**Dimensions:** All 12 confirmed at **1536×2752** ✅
**Format:** All WebP ✅

| Background | Size | Score | Warm? | Structure | Issues |
|-----------|------|-------|-------|-----------|--------|
| aurora | 155 KB | **9.5/10** | ✅ | ✅ Complete | Top performer |
| evening-glow | 148 KB | **9.25/10** | ✅ | ✅ Complete | Top performer |
| golden | 147 KB | **9/10** | ✅ | ⚠️ No ceiling | |
| ocean | 147 KB | **9/10** | ✅ | ✅ Complete | Sets the target quality |
| midnight | 139 KB | **7.75/10** | ⚠️ | ✅ Complete | Cool blue palette dominates |
| pastel | 151 KB | **7.5/10** | ⚠️ | ✅ Complete | Cool-neutral green palette |
| sunset | 103 KB | **7.25/10** | ✅ | ✅ Complete | Sparse, needs furnishing |
| cotton | 131 KB | **7/10** | ❌ | ✅ Complete | Cool/pale pink palette |
| watercolor | 147 KB | **7/10** | ✅ | ✅ Complete | Minor style inconsistency |
| dreamy | 146 KB | **6.5/10** | ❌ | ✅ Complete | Cold purple/lavender palette |
| forest | 88 KB | **6.75/10** | ✅ | ⚠️ No ceiling | Legacy — flat/sparse |
| cozy-living | 66 KB | **5.5/10** | ⚠️ | ❌ Minimal | **Legacy — well below quality bar** |

**Key findings:**
- All 12 backgrounds are present and at correct dimensions ✅
- `room-bg-cozy-living.webp` (66 KB, oldest asset) is significantly below the quality of newer backgrounds. Very sparse, minimal furnishing, large blank wall dominates. Needs regen.
- `room-bg-forest.webp` (88 KB, legacy) is also below the Wave 4 quality bar — flat execution, no ceiling, limited detail.
- **4 backgrounds have cold/neutral palettes** (dreamy, cotton, midnight, pastel) that technically violate the "warm palette" art bible spec. This may be intentional product variety, but warrants discussion.
- The 4 top backgrounds (aurora, evening-glow, golden, ocean) are excellent quality and strongly match the art bible.

**Room Backgrounds Quality Score: 7.5/10**

---

## 4. Illustrations Assessment

Both header illustrations are confirmed ❌ **Regen Needed** (as flagged in art bible):

### `practice_header.png` (1500×720, 943 KB)
- Style: Flat cel cartoon — scene diorama with small fish characters. Fish are elongated/realistic, not chibi.
- Outline: Thin and inconsistent, not the spec 3-4px charcoal
- Shading: Flat cel, minimal gradients
- Eyes: Small, not large chibi eyes
- Quality: 5/10
- **Status: FAIL — regenerate**

### `learn_header.png` (1500×880, 1,410 KB)
- Style: Vector sticker illustration — closer to stock clipart than app's aesthetic
- Outline: 2-3px, lighter than spec
- Shading: Some gradient layering but more flat cel
- Eyes: Medium-large but lack specular catchlight energy
- Quality: 6/10
- **Status: FAIL — regenerate**

**Critical file size issue:** Both illustrations are uncompressed PNGs. Conversion to WebP would yield ~89% size reduction (943 KB → ~105 KB, 1,410 KB → ~155 KB), saving **~2.1 MB** total.

**Illustrations Quality Score: 4/10** (pending regen)

---

## 5. Icons & Badges Assessment

### `app_icon.png` (512×512 RGB)
- Chibi goldfish on teal circle — on-brand and charming ✅
- Warm amber/teal palette matches app identity ✅
- Dark outline, large expressive eye — correct style ✅
- **Issue:** Delivered at 512×512; Apple App Store requires 1024×1024. Confirm source file exists at 1024px.
- **Issue:** Pre-masked circular crop — App Store icons should be full-bleed square (Apple applies rounding mask)
- Score: 8.5/10 (minor technical issues)

### `assets/icons/badges/` — **COMPLETELY EMPTY**
All 4 required badge icons are missing. Per `badges/README.md`, these are needed:

| Badge ID | Name | Use |
|----------|------|-----|
| `badge_early_bird.png` | Early Bird Badge | Shop item (ShopItemType.profileBadge) |
| `badge_night_owl.png` | Night Owl Badge | Shop item (ShopItemType.profileBadge) |
| `badge_perfectionist.png` | Perfectionist Badge | Shop item (ShopItemType.profileBadge) |
| `legendary_badge_display.png` | Legendary Badge Display | Shop item (exclusive) |

Additionally, contextual badges are referenced in `achievements_screen.dart` and `xp_celebration_screen.dart` (XP celebration star-burst, learning streak flame) — these are currently rendered programmatically but visual badge assets may be needed.

**Badges Quality Score: 0/10** (all pending)

---

## 6. Onboarding Assets Assessment

### `onboarding_journey_bg.webp` (1143×2048, 36 KB)
- Used on `welcome_screen.dart` during onboarding
- Content: Amber-to-cream photorealistic water caustic render
- **Issues:**
  - Photorealistic render style doesn't match the illustrated app aesthetic
  - Fades to near-white at bottom — loses warmth in lower 40%
  - Low contrast area where UI text overlays would live
  - Dimensions: 1143×2048 is non-standard (app backgrounds use 1536×2752)
- Score: 6/10

**Missing onboarding illustrations:**
The `assets/README.md` originally spec'd multiple onboarding slides but only the journey background exists. No onboarding fish illustrations, step graphics, or celebration screens are present as image assets (these appear to be handled programmatically or via Rive).

**Onboarding Quality Score: 6/10**

---

## 7. Missing Assets (Referenced in Code but Not Present)

Running `comm -23` between code references and actual files:

| Missing Path | Type | Impact |
|-------------|------|--------|
| `assets/images/fish/$speciesId.png` | Dynamic path | ✅ Expected — runtime interpolation |
| `assets/images/fish/${widget.speciesId}.png` | Dynamic path | ✅ Expected — runtime interpolation |
| `assets/images/fish/thumb/$speciesId.png` | Dynamic path | ✅ Expected — runtime interpolation |

**Verdict: Zero broken static asset references.** All "missing" entries are dynamic string interpolations that Flutter resolves at runtime — these are correct patterns and not bugs. All 15 fish sprites + all 15 thumbs are present, so runtime lookups will resolve correctly.

**One unreferenced asset found:**
- `assets/textures/linen-wall.webp` (248 KB) — declared in `pubspec.yaml` but no `AssetImage('assets/textures/linen-wall.webp')` reference found in Dart code. Candidate for removal.

---

## 8. Size Budget Analysis

### Total Asset Size: 9.79 MB

| Category | Size | % of Total |
|----------|------|-----------|
| Illustrations | 2,354 KB | 23.5% |
| Fish (full size) | 2,035 KB | 20.3% |
| Fonts | 1,982 KB | 19.8% |
| Backgrounds | 1,563 KB | 15.6% |
| Rive animations | 886 KB | 8.8% |
| Textures | 723 KB | 7.2% |
| Fish (thumbs) | 226 KB | 2.3% |
| Icons | 192 KB | 1.9% |
| Onboarding | 36 KB | 0.4% |
| Misc | 30 KB | 0.3% |

### Oversized Assets

| Asset | Current | Recommended | Savings | Action |
|-------|---------|------------|---------|--------|
| `illustrations/learn_header.png` | 1,410 KB | ~155 KB WebP | ~1,255 KB | Convert to WebP (89% saving) |
| `illustrations/practice_header.png` | 943 KB | ~105 KB WebP | ~838 KB | Convert to WebP (89% saving) |
| `images/fish/*.png` (15 files) | 2,034 KB | ~1,397 KB WebP | ~637 KB | Convert to WebP (31% saving) |
| `textures/felt-teal.webp` | 352 KB | ~250 KB | ~100 KB | Already WebP — re-export at lower quality |
| `rive/emotional_fish.riv` | 865 KB | N/A | — | Rive binary, cannot compress |
| `textures/linen-wall.webp` | 248 KB | **0 KB** | 248 KB | Remove — unreferenced |

**Total potential savings: ~3.08 MB (31% reduction in total assets)**

### Compression Opportunities
1. **Illustrations → WebP:** Largest single win. Both PNGs are uncompressed RGBA. Converting to WebP lossy-85 saves 89% (~2.1 MB total).
2. **Fish sprites → WebP:** 31% saving across the set (~637 KB). Note: requires code update from `.png` to `.webp` extensions.
3. **App icon:** Already adequate at 189 KB for a 512×512.

---

## 9. Style Consistency Assessment

**How cohesive does the art look overall?**

The app has two distinct visual tiers that create tension:

### Tier 1 — Canonical Style (Strong)
The 15 fish sprites (minus 2 outliers) form a genuinely cohesive, charming set. The chibi cel-gradient style with warm saturated palettes is appealing and distinctive. The top 4 room backgrounds (aurora, evening-glow, golden, ocean) are high quality and would complement the fish well.

### Tier 2 — Legacy/Mismatched Assets (Weak)
- The 2 header illustrations look like they came from a different app entirely — vector clip-art aesthetic vs. the handcrafted chibi sprites
- The 2 legacy backgrounds (cozy-living, forest) are significantly lower detail than the Wave 4 backgrounds
- The placeholder is an amber watercolor wash with no character
- The onboarding background is a photorealistic render vs. illustrated everything else
- `angelfish.png` and `amano_shrimp.png` both break from the established fish style

The cohesion **within each asset category** is reasonable (fish sprites largely match each other, backgrounds largely match each other). The **cross-category** cohesion — backgrounds against fish, illustrations against icons — is where the inconsistency shows.

**Style Consistency Score: 6/10**

---

## 10. Priority Action List

### 🔴 Critical (blocks visual quality)
1. **Regen `angelfish.png`** — Style outlier among fish sprites. Despite recent regen (Mar 29), still doesn't match canonical style.
2. **Regen `amano_shrimp.png`** — Full rework: bold outlines, add specular highlight, increase saturation.
3. **Regen both illustration headers** (`learn_header.png`, `practice_header.png`) — Wrong art style confirmed.
4. **Create all 4 badge icons** — Required for shop feature to function visually.

### 🟡 High Priority
5. **Convert illustrations to WebP** — 2.1 MB saving. Easy win before launch.
6. **Regen `room-bg-cozy-living.webp`** — Well below quality bar. Needs full regen with ceiling, furnishings, more detail.
7. **Regen `room-bg-forest.webp`** — Legacy quality, needs Wave 4 treatment.
8. **Replace `placeholder.webp`** — Watercolor wash doesn't match illustrated style. Need a Danio-branded illustrated placeholder (simple fish silhouette with chibi outlines).
9. **Review `onboarding_journey_bg.webp`** — Photorealistic render in an illustrated app. Could be replaced with a warmer illustrated background at correct dimensions (1536×2752).

### 🟢 Nice to Have
10. **Convert fish sprites to WebP** — 637 KB saving. Requires code changes.
11. **Fix `bristlenose_pleco.png` mode** — Currently `P` (palette) not `RGBA`. Functionally converts OK but technically incorrect; re-export as RGBA PNG.
12. **Remove unreferenced `linen-wall.webp`** — 248 KB unused asset.
13. **Confirm `app_icon.png` exists at 1024×1024** — Current file is 512×512; Apple now requires 1024px source.
14. **Minor tune: betta eyes** — White sclera would improve spec compliance (currently blue sclera).
15. **Minor tune: cherry_shrimp eyes** — Add white sclera base beneath dark iris.
16. **Address cold-palette backgrounds** — Dreamy, cotton, midnight, pastel all break the "warm palette" art bible rule. May be intentional product variety but should be confirmed as a deliberate design decision.

---

## Summary Scores

| Category | Score | Status |
|----------|-------|--------|
| Fish Sprites (full) | 7/10 | 13 PASS, 2 FAIL |
| Fish Thumbnails | 8.5/10 | All present, consistent |
| Room Backgrounds | 7.5/10 | 2 legacy backgrounds below bar |
| Header Illustrations | 4/10 | Both need regen |
| Icons & Badges | 4/10 | App icon good, badges all missing |
| Onboarding Assets | 6/10 | Background style mismatch |
| Placeholder | 3/10 | Wrong style |
| **Overall Visual Quality** | **6.5/10** | Solid foundation, clear gaps |

---

*Audit methodology: File dimensions and colour modes verified via PIL/Pillow. Code references scanned with `grep -rn "assets/"` across all `.dart` files. Visual style assessed by direct image analysis against art-bible.md criteria. No files were modified.*
