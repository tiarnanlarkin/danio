# Danio Fix Brief — Concept Lock (2026-04-07)

**Branch:** `feature/danio-fix-brief-2026-04`
**Status:** Awaiting user approval before Phases 3–5 start
**Source brief:** `Danio_Claude_Fix_Brief.md` (Tiarnan, 2026-04)
**Plan reference:** `C:\Users\larki\.claude\plans\playful-cooking-glade.md`

## Phase 0 Findings (corrections to plan v2)

### 1. The "fish on a hook" image is actually a 🎣 emoji

The brief states the welcome screen has a fish-on-hook image. After reading the actual asset (`assets/images/onboarding/onboarding_journey_bg.webp`) it's a beautiful warm watercolor of golden water caustics — no hook, no fish, nothing problematic.

The actual problem is the **🎣 fishing rod emoji** used in celebration text. Confirmed locations:

| # | File | Line | Text |
|---|------|------|------|
| 1 | `lib/screens/onboarding/xp_celebration_screen.dart` | 294 | `'First lesson complete 🎣'` |
| 2 | `lib/screens/onboarding/returning_user_flows.dart` | 373 | `'30 days of Danio 🎣'` |

**Fix scope:** 2 emoji swaps. ~5 minutes total.

### 2. Audit of fishing-related text

Grep across `lib/` for `catch|caught|hook|hooked|lure|fishing` returned mostly Dart `try/catch` keywords (irrelevant) plus:

| # | File | Line | Text | Verdict |
|---|------|------|------|---------|
| A | `lib/data/achievements.dart` | 152 | `'You are hooked!'` (streak_14 achievement description) | **Borderline** — idiom for "addicted to a hobby" but reads literally in fish-care context |
| B | `lib/screens/acclimation_guide_screen.dart` | 201 | `'Wild-caught fish'` | **Keep** — standard aquarium hobby terminology |
| C | `lib/data/lessons/fish_health.dart` | 320 | `"treatable when caught early"` | **Keep** — idiomatic for "detected early" |
| D | `lib/data/species_database.dart` | 1555, 2345 | `"eye-catching variety"` | **Keep** — safe idiom |
| E | `lib/data/stories.dart` | 201 | `"the bacteria catch up"` | **Keep** — safe idiom |
| F | `lib/providers/spaced_repetition_provider.dart` | 715 | `"It'll catch up next time"` | **Keep** — safe idiom |

**Recommendation:** Fix #1, #2, and ask user about A. The rest are safe idioms or industry terminology.

### 3. Bug evidence screenshots

`gap.png` and `gap2.png` in project root are NOT the bug evidence (they're a Google search screenshot and the Danio splash). The actual evidence is in:
- `screen_stage.png` — clear bottom-sheet gap visible
- `screen_tank.png` — same gap, slightly different state
- `screen_detail2.png` — gap visible plus the Zebra Danio info card overlay

The right-edge transparency bug is NOT clearly visible in any of these screenshots — needs runtime inspection during Phase 2 implementation.

### 4. Pre-existing visual prior art (incorporated)

- `design-concepts/room-concept-A.png` through `room-concept-F2.png` (7 finished room illustrations)
- `generated-art/comfyui-outputs/aquarium_living_room_00001.png` (usable populated tank scene)
- `generated-art/comfyui-outputs/danio_asset_00001-15.png` (Danio brand fish icon variants)
- `generated-art/comfyui-outputs/aquarium_lab_00001-3.png` (BLANK — failed generations, not usable)

### 5. Apollo's TANK_ROOM_AUDIT.md "DO NOT TOUCH"

Apollo's 2026-03-09 audit explicitly says do not touch `_AnimatedSwimmingFish`. Per user decision, this is overridden — fish motion IS in scope for the current fix brief. The "do not touch" was scoped to the room-redesign workstream; the current brief is a separate workstream with explicit fish motion ask. Tank rendering and fish appearance remain sacred; only motion changes.

### 6. Project codebase corrections (from plan v2)

- `temp_panel_content.dart` (NOT `temperature_panel_content.dart`) — barrel re-export of `temperature/` subfolder
- `widgets/room_scene.dart` is a barrel re-export of `widgets/room/living_room_scene.dart` and friends
- Fish painter at `widgets/room/fish_painter.dart` — confirmed in plan v2
- Branch policy: `feature/danio-fix-brief-2026-04` created, do not commit to `openclaw/stage-system`

---

## Locked Visual Direction

### Empty-Tank State — LOCKED to design-concepts/room-concept-A.png

**Reference:** `design-concepts/room-concept-A.png`

**Description:** Cozy classic interior — cream walls with white wainscoting, dark wood floor, persian rug centered with empty white space (where the tank sits), warm table lamp glow, crescent moon visible through curtained window, plant in pot, framed landscape painting on wall, floating shelves with small house decorations, cream sofa.

**Why this works for the brief:**
- Calm palette (cream, warm wood, soft lamplight)
- Soft materials (wainscoting, persian rug, fabric curtains)
- Premium feel (architectural detail, layered decor)
- Empty rug center provides natural placement for the empty tank state
- Window with moon ties to the day/night ambient system already in the app
- Aligned with the existing `cozyLiving` and `eveningGlow` themes

**Translation to Flutter widgets (empty_room_scene.dart redesign):**
- Background: warm cream gradient with subtle wainscoting suggestion (CustomPainter or layered Containers)
- Empty tank stand: visible wood stand with empty/dusty glass aquarium silhouette where the tank would be
- Floor: dark wood gradient (`#A0805C` walnut per Apollo's audit)
- Persian rug: stylized rounded rectangle with simple repeating pattern in warm rust tones
- Lamp glow: warm amber radial in upper-left (`#FFB347` per Apollo's audit color spec)
- Window with crescent moon icon (top-right corner)
- Mascot Finn: positioned beside the empty stand as "waiting helper"
- Setup path selector: floating card or two side-by-side cards over the rug area
- Reuse existing `MascotAvatar`, replace `NotebookCard` with a more integrated material treatment

### Welcome Screen Background — KEEP existing onboarding_journey_bg.webp

The existing asset is a beautiful warm watercolor of water caustics. No replacement needed. This contradicts the brief but the brief was based on a misread of the asset (the 🎣 emoji on the celebration screen was the actual problem).

### Side Panels — Lab View (Water Quality) and Gauge Instrument (Temperature)

**Concept image generation:** Attempted via z-image-turbo MCP tool but GPU quota exceeded. Falling back to text specs + reference imagery from existing assets. Image generation can be retried in a future session if needed.

#### Water Quality "Lab View" Spec

**Mood:** Floating laboratory instruments suspended over the aquarium scene. Like equipment from the tank itself drifted up onto the screen — not a separate UI panel.

**Layout (top to bottom, fits in available space without scroll):**

```
┌─────────────────────────────────────────┐
│   [HEALTH SCORE RING — large, central]  │  ← Reuse WqHealthScoreCard
│        92% — "Excellent"                │     remove its card container
│                                         │
│   ┌────┐ ┌────┐ ┌────┐                  │
│   │ pH │ │NH₃ │ │NO₂ │  ← Top 3 priority parameters
│   │7.0 │ │ 0  │ │ 0  │     as floating brass medallions
│   └────┘ └────┘ └────┘                  │
│   ┌────┐ ┌────┐ ┌────┐                  │
│   │NO₃ │ │ GH │ │ KH │  ← Bottom 3 secondary parameters
│   │ 12 │ │ 8  │ │ 5  │     same brass medallion treatment
│   └────┘ └────┘ └────┘                  │
│                                         │
│   [pH trend sparkline — 7 days]         │
│   [Nitrate trend sparkline — 7 days]    │
│                                         │
│         [Log Water Test button]         │
└─────────────────────────────────────────┘
```

**Visual treatment:**
- NO outer card container (no rounded rect background, no border)
- NO frosted top/bottom segmented caps
- Each instrument is a self-contained "floating" element with its own subtle shadow
- Brass/copper accent rings on each medallion (echoes the room scene aesthetic)
- Cream/ivory backgrounds for the medallions, with the room theme color tinting subtly
- Sparkline charts use minimal axes — just the line on a transparent background
- Health score ring stays as the existing widget but loses its card wrapper
- Log button is a clean bordered pill, not a filled rectangle

**Material:**
- σ:14 backdrop blur on the instruments (slightly less than current σ:20)
- 0.92 alpha on instrument fills (slightly less opaque to feel more integrated)
- Drop shadow: 0,2,8 black at alpha 25 (subtle depth)

#### Temperature "Gauge Instrument" Spec

**Mood:** A single hero gauge — like a vintage brass thermometer mounted on the side of the tank.

**Layout:**

```
┌─────────────────────────────────────────┐
│        Temperature                       │  ← Small label
│                                         │
│         ╭───────────╮                   │
│       ╱   ╲___24°╱   ╲                  │  ← Large circular gauge
│      │   ╱       ╲   │                  │     analog needle, brass ring
│      │  │  24°C   │  │                  │
│      │   ╲   ✓   ╱   │                  │
│       ╲   ╲___╱   ╱                     │
│         ╰───────────╯                   │
│                                         │
│      Optimal range: 24°–26°            │
│                                         │
│      Heater: ON  ●  Last test: 2h ago  │
│                                         │
│      [7-day sparkline — slim row]       │
│                                         │
│         [Log Temperature button]        │
└─────────────────────────────────────────┘
```

**Visual treatment:**
- The existing `temperature_gauge.dart` becomes the hero element — enlarge it
- Brass ring around the dial (use `kTempTeal` or a warm brass tone)
- Optimal range shown as a soft green arc on the dial
- Status pill below (Heater ON/OFF)
- Sparkline stays but becomes much smaller (just a slim row)
- NO outer card, NO segmented caps
- TempHeader, TempHeroSection (just the gauge), TempTrendSection (slim), TempLogButton — but stripped of their card containers

### Notification Banner Direction

**Mood:** Layered material with a geometric accent. Less rectangle, more architecture.

**Visual treatment:**
- Translucent base: σ:14 blur + theme.glassCard at alpha 0.85
- Diagonal accent stripe on the left edge (4px wide, theme accent color)
- Rounded right side (8px), squared left side (creates a "label" or "tag" feel)
- 1px border in theme.glassBorder
- Drop shadow: 0,2,12 black at alpha 30
- Icon in a small circle on the left, message text middle, optional dismiss × on right
- Banner-style variants:
  - **welcome:** primary accent stripe, fish emoji (🐠) icon
  - **comeback:** warning accent stripe, returning fish emoji (🐠) icon
  - **demo:** info accent stripe, science icon (Icons.science_outlined)
  - **nudge:** primary accent stripe, learning icon (Icons.school_outlined or 🎯)

### Fish Animation Behavior Spec

**Goal:** Replace the linear back-and-forth tween with goal-seeking motion that feels deliberate.

**Algorithm:**
1. Pick a random target position within the tank bounds (with margin from glass)
2. Move toward the target with a smooth ease curve, varying speed
3. On approach, slow down (ease-out)
4. On arrival, briefly hover, then pick a new target
5. Random "wander" — small lateral offset added during traversal for organic feel
6. Edge response: if a fish would hit a glass wall, choose a target that turns away from the wall (soft turn, not pop-and-reverse)

**Speed model:**
- Slow at edges (target chosen near edge → reduced speed)
- Faster in open water (target far from current position → higher speed)
- Vertical bob continues but as a sine wave layered on top of the goal seek
- Direction flip: based on horizontal velocity sign, not on `_previousValue` boundary detection

**Safety constraints (preserve from current implementation):**
- ✅ No `AnimationStatus` listeners that recurse (the `repeat(reverse: true)` was a documented stack-overflow fix)
- ✅ Reduced motion: long duration freeze (5 minutes), NOT zero
- ✅ Non-finite guards (R-088)
- ✅ Boundary clamps (BUG-08)
- ✅ `RepaintBoundary` optimization
- ✅ Public widget API: `size`, `color`, `swimSpeed`, `verticalBob`, `startOffset`, `tankWidth`, `tankHeight`, `baseTop`

**Implementation approach:**
- Single `Ticker` driven by `vsync`, ticking each frame
- Internal `Offset _currentTarget`, `Offset _currentPosition`, `double _currentSpeed`
- On each tick: move toward target by `speed * dt`, check arrival, reset target if reached
- No `AnimationController.repeat()` — direct ticker control avoids the recursion bug

---

## Decisions Pending User Approval

1. **Lock concept-A as the empty-tank state visual direction?** ✅ Already approved
2. **Fix #1 and #2 emoji + ask about #A "hooked" achievement?** Waiting for user
3. **Side-panel concept image regeneration?** z-image-turbo quota exceeded — proceed with text specs only OR retry image generation later?
4. **Phase 2 structural fixes can begin now in parallel** — user OK to start coding while reviewing this concept doc?

---

*End of Phase 0/1 concept lock document.*
