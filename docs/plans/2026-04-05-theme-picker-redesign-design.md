# Theme Picker Redesign — Stacked Card Browser

**Date:** 2026-04-05
**Status:** Approved

## Problem

The current theme picker is a bottom sheet with a `Wrap` of 100px cards showing 3 colour dots each. With 12 themes this feels cramped, the previews are too abstract to convey what a theme actually looks like, and the interaction lacks delight.

## Solution

Replace the theme picker with a **stacked-card browser** inside a taller bottom sheet. Each card shows the room's WebP background image with a **painted mini-aquarium overlay** (tank outline, water gradient, plant silhouettes, tiny fish). Users swipe through the stack to browse and tap to select.

## Design

### Bottom Sheet Layout
- Height: ~75% of screen, draggable to expand
- Header: "Room Theme" title + close button
- Centre: Card stack (~280x380px cards)
- Footer: Theme name, description, "Apply" button
- Background: respects current light/dark theme

### Card Stack Interaction
- Cards are stacked with slight rotation (~2deg) and offset (~8px)
- Top card is fully visible; 2-3 cards peek behind
- **Swipe left/right** — dismiss the top card, reveals next theme
- **Tap** — selects and applies the theme
- Cards cycle (wraps from last to first)
- Entrance animation: cards fan in from below with spring curve

### Card Content
**Top 70% — Mini Aquarium Scene:**
- Room WebP background image (fitted/cropped)
- Painted overlay via `MiniTankPainter`:
  - Transparent glass rectangle (`glassCard`/`glassBorder`)
  - Water gradient fill (`waterTop`/`waterMid`/`waterBottom`)
  - 2-3 plant silhouettes (`plantPrimary`/`plantSecondary`)
  - 2-3 fish ovals (`fish1`/`fish2`/`fish3`)
  - Sand strip at bottom (`sand`)

**Bottom 30% — Info Area:**
- Frosted glass overlay
- Theme name (bold) + description
- Row of 5 colour dots (accent, water, plant, fish, sand)

### Apply Behaviour
1. Selected card scales up with brief glow
2. Theme applied via `roomThemeProvider.setTheme()`
3. Sheet dismisses with slide-down
4. Dismissing without selecting preserves original theme

### Accessibility & Reduced Motion
- Semantics: `"{name} theme, {description}. Swipe to browse, tap to select"`
- Reduced motion: instant card transitions (no fly-off, just fade)
- Keyboard/focus navigable
- Info area contrast meets WCAG AA

## File Changes
- **New:** `lib/screens/home/theme_picker_sheet.dart` — Stacked card picker widget
- **New:** `lib/painters/mini_tank_painter.dart` — CustomPainter for mini aquarium overlay
- **Modified:** `lib/screens/home/home_sheets_theme.dart` — `showThemePicker()` rewired
- **Modified:** `lib/screens/settings/settings_screen.dart` — `_RoomThemeTile` uses new picker

## Reusable Infrastructure
- `backgroundAssetForTheme()` in `room_background.dart` — asset paths for all 12 themes
- `RoomTheme` colour properties — all ~30 colours per theme for the painted overlay
- `showAppBottomSheet()` / `showAppDragSheet()` — existing sheet primitives
- `SparklePainter` pattern — established CustomPainter conventions
- `roomThemeProvider` / `currentRoomThemeProvider` — theme state management
- `AppRadius`, `AppSpacing`, `AppTypography` — design system tokens
