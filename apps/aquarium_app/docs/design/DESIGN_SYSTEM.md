# Danio Design System
Version: 1.0 | Date: 2026-02-28

Source of truth: `lib/theme/app_theme.dart`

---

## Spacing Scale (8dp base grid)

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4dp | Icon gaps, tight padding |
| `sm` | 8dp | Small gaps between related elements |
| `sm2` | 12dp | Compact card padding |
| `md` | 16dp | Standard padding, card content |
| `lg2` | 20dp | Section gaps |
| `lg` | 24dp | Large section spacing |
| `xl` | 32dp | Major section breaks |
| `xl2` | 40dp | Extra large spacing |
| `xxl` | 48dp | Screen-level padding |
| `xxxl` | 64dp | Hero spacing |

**Rule:** Use `AppSpacing.*` constants everywhere. Never hardcode pixel values.

---

## Typography Scale

Font: SF Pro Display (falls back to system sans-serif)

| Token | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| `headlineLarge` / `display` | 32sp | Bold (w700) | 1.2 | Screen hero titles |
| `headlineMedium` / `headline` | 24sp | SemiBold (w600) | 1.3 | Section headers |
| `headlineSmall` | 20sp | SemiBold (w600) | 1.3 | AppBar titles, subsection headers |
| `titleLarge` | 22sp | SemiBold (w600) | 1.3 | Card titles (large) |
| `titleMedium` / `title` | 18sp | Medium (w500) | 1.3 | Card titles, list headers |
| `titleSmall` | 16sp | Medium (w500) | 1.3 | Compact titles |
| `bodyLarge` | 17sp | Regular (w400) | 1.5 | Long-form content, lessons |
| `bodyMedium` / `body` | 15sp | Regular (w400) | 1.5 | Default body text |
| `bodySmall` / `caption` | 13sp | Regular (w400) | 1.4 | Captions, meta text |
| `labelLarge` | 15sp | SemiBold (w600) | — | Buttons, emphasis labels |
| `labelMedium` / `label` | 13sp | Medium (w500) | — | Chips, tags |
| `labelSmall` | 11sp | Medium (w500) | — | Nav labels, small badges |
| `overline` | 10sp | SemiBold (w600) | 1.4 | Overline text, ALL CAPS labels |

**Rule:** Use `AppTypography.*` constants. Apply colour via `.copyWith(color: ...)`.

---

## Colour Roles

### Primary Palette — Aquatic teal
| Token | Hex | Usage |
|-------|-----|-------|
| `primary` | `#3D7068` | Main brand, CTAs, active states |
| `primaryLight` | `#5B9A8B` | Dark mode primary, subtle tints |
| `primaryDark` | `#2D5248` | Pressed states, dark accents |

### Secondary Palette — Warm sand/coral
| Token | Hex | Usage |
|-------|-----|-------|
| `secondary` | `#9F6847` | Secondary actions, warmth accents |
| `secondaryLight` | `#E8A87C` | Soft backgrounds, decorative |
| `secondaryDark` | `#8A5838` | Pressed states |

### Accent Colours
| Token | Hex | Usage |
|-------|-----|-------|
| `accent` | `#85C7DE` | Sky blue highlights |
| `accentAlt` | `#C5A3FF` | Lavender — special/premium |
| `xp` | `#D4A574` | Gold — XP, experience points |

### Semantic Colours (WCAG AA compliant on white)
| Token | Hex | Ratio | Usage |
|-------|-----|-------|-------|
| `success` | `#5AAF7A` | 4.52:1 | Safe parameters, correct answers |
| `warning` | `#C99524` | 4.52:1 | Caution, parameter warnings |
| `error` | `#D96A6A` | 4.51:1 | Danger, wrong answers, alerts |
| `info` | `#5C9FBF` | 4.50:1 | Informational highlights |

### Light Mode Surfaces
| Token | Hex | Usage |
|-------|-----|-------|
| `background` | `#F5F1EB` | Scaffold background (warm off-white) |
| `surface` | `#FFFFFF` | Cards, sheets |
| `surfaceVariant` | `#F0EBE3` | Input fills, subtle dividers |
| `card` | `#FFFFFF` | Card background |
| `textPrimary` | `#2D3436` | Primary text |
| `textSecondary` | `#636E72` | Secondary/meta text |
| `textHint` | `#5D6F76` | Placeholder text |

### Dark Mode Surfaces
| Token | Hex | Usage |
|-------|-----|-------|
| `backgroundDark` | `#1A2634` | Scaffold background (deep blue-gray) |
| `surfaceDark` | `#243447` | Cards, elevated surfaces |
| `surfaceVariantDark` | `#2D3E50` | Input fills |
| `cardDark` | `#2A3A4A` | Card background |
| `textPrimaryDark` | `#F5F1EB` | Primary text |
| `textSecondaryDark` | `#B8C5D0` | Secondary text |
| `textHintDark` | `#9DAAB5` | Placeholder text |

### Gradients
| Token | Colours | Usage |
|-------|---------|-------|
| `primaryGradient` | `#7FC8B6` → `#5B9A8B` | Hero cards, headers |
| `warmGradient` | `#F5D0B5` → `#E8A87C` | Warm highlights |
| `oceanGradient` | `#85C7DE` → `#5B9A8B` | Water-themed backgrounds |
| `sunsetGradient` | `#E8A87C` → `#E88B8B` → `#C5A3FF` | Premium/celebration |
| `darkGradient` | `#2D3E50` → `#1A2634` | Dark mode backgrounds |

**Rule:** Use pre-computed alpha colours (`AppColors.primaryAlpha20`) instead of `.withOpacity()` for performance. All alpha variants are defined as constants.

---

## Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4dp | Small chips, inline badges |
| `sm` | 8dp | Compact cards, tags |
| `md2` | 12dp | Medium components |
| `md` | 16dp | Standard cards |
| `lg` | 24dp | Large cards, hero elements |
| `xl` | 32dp | Dialogs, bottom sheets |
| `pill` | 100dp | Buttons, chips, search bars |

**Rule:** Use `AppRadius.*Radius` getters for `BorderRadius` instances.

---

## Elevation & Shadows

| Level | Value | Shadow Style | Usage |
|-------|-------|-------------|-------|
| Level 0 | 0 | None | Flat cards |
| Level 1 | 2 | `AppShadows.subtle` | Resting cards |
| Level 2 | 4 | `AppShadows.soft` | Elevated cards |
| Level 3 | 8 | `AppShadows.medium` | Floating elements |
| Level 4 | 12 | `AppShadows.elevated` | Modals, popovers |
| Level 5 | 24 | — | Reserved |

Premium variants: `dreamySoft`, `glassLight`, `glassDark`, `cozyWarm`

---

## Touch Targets

| Token | Size | Usage |
|-------|------|-------|
| `minimum` / `small` | 48dp | Compact devices minimum (Material 3) |
| `medium` | 56dp | Standard phone buttons |
| `large` | 64dp | Tablet, important actions |

Adaptive via `AppTouchTargets.adaptive(context)` based on screen width.

---

## Motion Rules

Defined in `AppDurations` and `AppCurves`:

| Duration | Value | Usage |
|----------|-------|-------|
| `extraShort` | 50ms | Micro-interactions (ripples) |
| `short` | 100ms | Colour transitions, opacity |
| `medium1` | 150ms | List item stagger |
| `medium2` | 200ms | Standard transitions |
| `medium3` | 250ms | Complex transitions |
| `medium4` | 300ms | Page-level transitions |
| `long1` | 400ms | Emphasized enter/exit |
| `long2` | 500ms | Complex animations |
| `extraLong` | 700ms | Celebration entrance |
| `celebration` | 1500ms | Full celebration sequence |

**Curves:** `emphasized` (easeOutCubic), `standard` (easeInOut), `elastic` (elasticOut), `bounce` (bounceOut)

**Rules:**
- Navigation: instant (no page transition animation by default)
- Button press: use `AppCurves.emphasized` with `medium2`
- List stagger: `medium1` per item
- Celebration/XP: use `celebration` duration with `elastic` curve
- Respect `ReducedMotionProvider` — skip non-essential animations

---

## Component Library

### Glass Card (`lib/widgets/core/glass_card.dart`)
- Frosted glassmorphism effect
- Light/dark variants via `GlassStyles.frostedLight/frostedDark`
- Used for hero sections, overlays

### App Card (`lib/widgets/core/app_card.dart`)
- Standard elevated card
- Uses `AppRadius.largeRadius` (24dp)
- Zero elevation, uses `AppShadows.soft`

### Cozy Card (`lib/widgets/common/cozy_card.dart`)
- Warm-themed card for room/home areas
- Uses `GlassStyles.cozyCard`

### Primary Action Tile (`lib/widgets/common/primary_action_tile.dart`)
- Full-width action row with icon + label
- 48dp minimum touch target

### Buttons (Material 3 themed)
- **Elevated:** Teal fill, white text, pill shape
- **Outlined:** Teal border, teal text, pill shape
- **Text:** Teal text, no border
- **Pill:** Custom `PillButton` widget for tag/filter selection

### Empty State (`lib/widgets/empty_state.dart` + `lib/widgets/common/empty_state.dart`)
- Centered emoji + title + subtitle + optional CTA
- Consistent pattern for all screens

### Loading State (`lib/widgets/loading_state.dart`)
- Skeleton loaders via `skeletonizer` package
- Custom `BubbleLoader`, `FishLoader` for branded loading

### Error State (`lib/widgets/error_state.dart`)
- ErrorBoundary wrapper (`lib/widgets/error_boundary.dart`)
- Consistent error display with retry action

### Progress Bars
- XP progress bar (`lib/widgets/xp_progress_bar.dart`)
- Daily goal progress (`lib/widgets/daily_goal_progress.dart`)
- Linear with rounded caps, uses `primaryGradient`

### Achievement Cards (`lib/widgets/achievement_card.dart`)
- Tiered colours: bronze/silver/gold/platinum/diamond (`AppAchievementColors`)
- Lock/unlock states with animation

### Stat Card (`StatCard` in `app_theme.dart`)
- Coloured icon + value + label
- Used for dashboard metrics
