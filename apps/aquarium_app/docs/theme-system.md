# Theme System Guide — Danio Aquarium App

> **"How do I style things in this app?"** — This is that document.

All design tokens live in one file: `lib/theme/app_theme.dart`.  
Never use raw hex colours, raw `TextStyle()`, or `withOpacity()` — use the classes below.

---

## Table of Contents

1. [AppColors — colours](#appcolors--colours)
2. [AppOverlays — pre-computed alpha colours](#appoverlays--pre-computed-alpha-colours)
3. [AppTypography — fonts & text styles](#apptypography--fonts--text-styles)
4. [AppSpacing — layout spacing](#appspacing--layout-spacing)
5. [AppRadius — border radius](#appradius--border-radius)
6. [AppShadows — box shadows](#appshadows--box-shadows)
7. [AppElevation — elevation scale](#appelevation--elevation-scale)
8. [AppDurations & AppCurves — animation](#appdurations--appcurves--animation)
9. [AppTouchTargets — accessibility](#apptouchtargets--accessibility)
10. [AppTheme — light & dark ThemeData](#apptheme--light--dark-themedata)
11. [AdaptiveColors extension](#adaptivecolors-extension)
12. [DanioColors & DanioMaterials — brand accents](#daniocolors--daniomaterials--brand-accents)
13. [Dos and Don'ts](#dos-and-donts)

---

## AppColors — colours

```dart
import 'package:danio/theme/app_theme.dart';

Container(color: AppColors.primary) // ✅
Container(color: Color(0xFFB45309)) // ❌ raw hex — don't do this
```

### Primary palette (Danio Amber-Gold brand)

| Token | Hex | Notes |
|-------|-----|-------|
| `primary` | `#B45309` | Amber 700 — WCAG AA 4.7:1 on white |
| `primaryLight` | `#D97706` | Amber 600 — use on light backgrounds |
| `primaryDark` | `#92400E` | Amber 800 |

### Secondary palette (Blue-Slate)

| Token | Hex | Notes |
|-------|-----|-------|
| `secondary` | `#4A5A6B` | Blue-Slate |
| `secondaryLight` | `#6B7F8E` | Lighter |
| `secondaryDark` | `#2A3548` | Deep Violet |

### Accent colours

| Token | Hex | Notes |
|-------|-----|-------|
| `accent` | `#5B9EA6` | Teal Water — decorative only, **not for text** |
| `accentText` | `#3D7F88` | WCAG AA safe teal for text on light backgrounds |
| `accentAlt` | `#8B6BAE` | Amethyst |

> **Rule:** Tokens ending in `Text` are the safe, darkened version of the decorative colour, guaranteed to pass WCAG AA (4.5:1) on light backgrounds.

### Semantic colours

All semantic colours are WCAG AA compliant with white text.

| Token | Hex | Contrast | Use |
|-------|-----|----------|-----|
| `success` | `#1E8449` | 7.3:1 | Positive outcomes |
| `warning` | `#C99524` | 4.52:1 | Caution states |
| `error` | `#C0392B` | 5.9:1 | Errors, destructive |
| `info` | `#2E86AB` | 5.2:1 | Neutral information |
| `xp` | `#D97706` | — | XP/score displays |

### Surface & background

| Token | Hex | Use |
|-------|-----|-----|
| `background` | `#FFF5E8` | Scaffold background (warm cream) |
| `surface` | `#FFFBF5` | Card surfaces (ivory white) |
| `surfaceVariant` | `#FFF0DC` | Input fills, chip backgrounds |
| `card` | `#FFFFFF` | Card colour |

### Text colours (light mode)

| Token | Hex | Contrast on white | Use |
|-------|-----|-------------------|-----|
| `textPrimary` | `#2D3436` | — | Body text, headings |
| `textSecondary` | `#636E72` | 6.4:1 | Supporting text |
| `textHint` | `#5D6F76` | 4.67:1 | Placeholder, hints |

### Dark mode equivalents

Append `Dark` to get the dark-mode variant: `backgroundDark`, `surfaceDark`, `textPrimaryDark`, etc.

### Gradients

Pre-built `LinearGradient` constants on `AppColors`:

```dart
decoration: BoxDecoration(gradient: AppColors.primaryGradient)
decoration: BoxDecoration(gradient: AppColors.warmGradient)
decoration: BoxDecoration(gradient: AppColors.oceanGradient)
decoration: BoxDecoration(gradient: AppColors.sunsetGradient)
decoration: BoxDecoration(gradient: AppColors.darkGradient)
```

---

## AppOverlays — pre-computed alpha colours

**Never use `color.withOpacity()`.** It allocates a new `Color` object on every build, adding GC pressure.

Instead, use the pre-computed constants on `AppColors` (named `[color]Alpha[pct]`) or `AppOverlays` (named `[color][pct]`):

```dart
// ❌ Allocates a new object every build
color: AppColors.primary.withOpacity(0.2)

// ✅ Compile-time constant — zero cost
color: AppColors.primaryAlpha20
color: AppOverlays.primary20
```

### Available alpha families

| Class | Family | Example |
|-------|--------|---------|
| `AppColors` | `whiteAlpha*`, `blackAlpha*`, `primaryAlpha*`, `secondaryAlpha*`, `accentAlpha*`, `successAlpha*`, `warningAlpha*`, `errorAlpha*`, `infoAlpha*` | `AppColors.blackAlpha30` |
| `AppOverlays` | `white*`, `black*`, `primary*`, `secondary*`, `accent*`, `success*`, `error*`, `warning*`, `info*`, `orange*`, `grey*`, `green*`, `amber*`, `purple*` | `AppOverlays.black30` |

### Alpha hex quick reference

| Opacity | Hex |
|---------|-----|
| 5% | `0x0D` |
| 10% | `0x1A` |
| 15% | `0x26` |
| 20% | `0x33` |
| 30% | `0x4D` |
| 50% | `0x80` |
| 70% | `0xB3` |
| 90% | `0xE6` |

---

## AppTypography — fonts & text styles

### Font roles

| Font | Character | Role |
|------|-----------|------|
| **Fredoka** | Playful, rounded | Display / headlines — brand "wow" moments |
| **Nunito** | Clean, rounded, legible | UI chrome — titles, labels, body, nav |
| **Lora** | Serif, warm, scholarly | Lesson content only (educational prose) |

### Material TextTheme tokens

Access via `Theme.of(context).textTheme.*` or the equivalent `AppTypography.*` alias — they return **identical** styles.

| Token | Font | Size | Weight | Role |
|-------|------|------|--------|------|
| `displayLarge` | Fredoka | 40 | w700 | Hero banners, splash |
| `displayMedium` | Fredoka | 34 | w700 | Section heroes |
| `displaySmall` | Fredoka | 28 | w600 | Onboarding highlights |
| `headlineLarge` | Fredoka | 32 | w700 | Primary screen titles |
| `headlineMedium` | Fredoka | 24 | w600 | Section headings, card titles |
| `headlineSmall` | Fredoka | 20 | w600 | Sub-headings, dialog titles |
| `titleLarge` | Fredoka | 22 | w600 | AppBar titles |
| `titleMedium` | Nunito | 18 | w700 | Sheet titles, list primaries |
| `titleSmall` | Nunito | 16 | w600 | Compact titles |
| `bodyLarge` | Nunito | 17 | w400 | Primary body text |
| `bodyMedium` | Nunito | 15 | w400 | Standard body (most common) |
| `bodySmall` | Nunito | 13 | w400 | Captions, metadata |
| `labelLarge` | Nunito | 15 | w700 | Buttons, active nav labels |
| `labelMedium` | Nunito | 13 | w600 | Chips, tags |
| `labelSmall` | Nunito | 11 | w600 | Overlines, badges, timestamps |

### AppTypography semantic aliases

```dart
AppTypography.display      // → headlineLarge (Fredoka 32)
AppTypography.headline     // → headlineMedium (Fredoka 24)
AppTypography.title        // → titleMedium (Nunito 18)
AppTypography.body         // → bodyMedium (Nunito 15)
AppTypography.label        // → labelMedium (Nunito 13)
AppTypography.caption      // → bodySmall (Nunito 13)
AppTypography.overline     // Nunito 10 w700 ls:1.5 (unique token)
```

### Lesson content styles (Lora)

For educational reading content only — not for UI chrome:

```dart
AppTypography.lessonBody       // Lora 16 w400 lh:1.6
AppTypography.lessonBodyLarge  // Lora 17 w400 lh:1.6
AppTypography.lessonQuote      // Lora 15 w400 italic lh:1.6
```

### Usage examples

```dart
// In a screen — prefer AppTypography for clarity
Text('My Tank', style: AppTypography.headlineSmall)
Text('3.5 pH', style: AppTypography.titleMedium.copyWith(color: AppColors.primary))
Text('Last measured today', style: AppTypography.caption.copyWith(color: AppColors.textSecondary))

// For lesson card prose
Text(lessonContent, style: AppTypography.lessonBody.copyWith(color: context.textPrimary))
```

> **Rule:** Use `AppTypography.*` for new code. `Theme.of(context).textTheme.*` is also fine — they're identical. Never write `TextStyle(fontSize: 16, fontFamily: 'Nunito')` inline.

---

## AppSpacing — layout spacing

```dart
const spacing = AppSpacing.md; // 16dp
SizedBox(height: AppSpacing.lg) // 24dp
EdgeInsets.all(AppSpacing.sm)   // 8dp
```

| Token | dp |
|-------|----|
| `hairline` | 1 |
| `xxs` | 2 |
| `xs` | 4 |
| `xs2` | 6 |
| `sm` | 8 |
| `sm3` | 10 |
| `sm2` | 12 |
| `sm4` | 14 |
| `md` | 16 |
| `lg2` | 20 |
| `lg` | 24 |
| `xl` | 32 |
| `xl2` | 40 |
| `xxl` | 48 |
| `xxxl` | 64 |

---

## AppRadius — border radius

```dart
borderRadius: AppRadius.largeRadius     // BorderRadius.circular(24)
borderRadius: AppRadius.pillRadius      // BorderRadius.circular(100)
borderRadius: BorderRadius.circular(AppRadius.md) // 16dp
```

| Token | dp | `BorderRadius` getter |
|-------|----|-----------------------|
| `xs` | 4 | `xsRadius` |
| `sm` | 8 | `smallRadius` |
| `md2` | 12 | `md2Radius` |
| `md` | 16 | `mediumRadius` |
| `lg2` | 20 | — |
| `lg` | 24 | `largeRadius` |
| `xl` | 32 | `xlRadius` |
| `xxl` | 48 | — |
| `pill` | 100 | `pillRadius` |
| `full` | 999 | `fullRadius` |

---

## AppShadows — box shadows

Pre-built shadow lists for consistent depth:

```dart
decoration: BoxDecoration(boxShadow: AppShadows.soft)
decoration: BoxDecoration(boxShadow: AppShadows.medium)
decoration: BoxDecoration(boxShadow: AppShadows.elevated)
decoration: BoxDecoration(boxShadow: AppShadows.subtle)
decoration: BoxDecoration(boxShadow: AppShadows.glow)      // amber glow
decoration: BoxDecoration(boxShadow: AppShadows.dreamySoft)
decoration: BoxDecoration(boxShadow: AppShadows.glassLight)
decoration: BoxDecoration(boxShadow: AppShadows.glassDark)
decoration: BoxDecoration(boxShadow: AppShadows.cozyWarm)  // warm gold tint
```

---

## AppElevation — elevation scale

Material-style numeric elevation levels + `BoxShadow` constants:

```dart
AppElevation.level0  // 0dp
AppElevation.level1  // 2dp
AppElevation.level2  // 4dp
AppElevation.level3  // 8dp
AppElevation.level4  // 12dp
AppElevation.level5  // 24dp

// BoxShadow presets
boxShadow: [AppElevation.xs]
boxShadow: [AppElevation.sm]
boxShadow: [AppElevation.md]
boxShadow: [AppElevation.lg]
```

---

## AppDurations & AppCurves — animation

```dart
// Durations
AppDurations.extraShort   // 50ms
AppDurations.short        // 100ms
AppDurations.medium1      // 150ms
AppDurations.medium2      // 200ms
AppDurations.medium3      // 250ms
AppDurations.medium4      // 300ms — most common for standard transitions
AppDurations.long1        // 400ms
AppDurations.long2        // 500ms
AppDurations.extraLong    // 700ms
AppDurations.celebration  // 1500ms — level-up, streak animations

// Curves
AppCurves.emphasized           // easeOutCubic — primary transitions
AppCurves.emphasizedDecelerate // easeOutCirc
AppCurves.emphasizedAccelerate // easeInCirc
AppCurves.standard             // easeInOut
AppCurves.standardDecelerate   // easeOut
AppCurves.elastic              // elasticOut
AppCurves.bounce               // bounceOut
```

---

## AppTouchTargets — accessibility

Material Design 3 mandates 48dp minimum touch targets:

```dart
// Constants
AppTouchTargets.minimum   // 48dp
AppTouchTargets.small     // 48dp
AppTouchTargets.medium    // 56dp
AppTouchTargets.large     // 64dp (tablet / prominent actions)

// Adaptive helper (reads screen width)
SizedBox(height: AppTouchTargets.adaptive(context))

// Padding helpers for small icons to reach 48dp touch target
padding: AppTouchPadding.for24Icon  // 12dp all sides
padding: AppTouchPadding.for20Icon  // 14dp all sides
```

---

## AppTheme — light & dark ThemeData

Apply in your `MaterialApp`:

```dart
MaterialApp(
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  themeMode: ThemeMode.system,
  scrollBehavior: const DanioScrollBehavior(),
  ...
)
```

`DanioScrollBehavior` removes the Android glow/stretch overscroll effect for a cleaner feel.

All `MaterialPageRoute` transitions automatically get the custom slide+fade animation via `_DanioPageTransitionsBuilder` — no extra code needed.

### Standard card decorations

```dart
// Static decoration recipes (no widget needed)
decoration: AppCardDecoration.standard(context)   // white card + thin border
decoration: AppCardDecoration.elevated(context)   // white card + soft shadow
decoration: AppCardDecoration.outlined(context)   // transparent + border

// For the interactive widget, see lib/widgets/core/app_card.dart
AppCard(variant: AppCardVariant.elevated, child: ...)
```

---

## AdaptiveColors extension

A `BuildContext` extension provides adaptive colour lookups that automatically return the correct light/dark token:

```dart
// In any Widget.build(BuildContext context):
color: context.textPrimary       // AppColors.textPrimary or textPrimaryDark
color: context.textSecondary
color: context.textHint
color: context.backgroundColor
color: context.surfaceColor
color: context.surfaceVariant
color: context.cardColor
color: context.primaryColor
color: context.borderColor
```

Use this instead of manual `Theme.of(context).brightness == Brightness.dark` checks.

---

## DanioColors & DanioMaterials — brand accents

`DanioColors` is a curated list of named brand colours for use in illustrations, decorative elements, and themed UI. Each decorative colour has a paired `*Text` variant that passes WCAG AA.

```dart
// Decorative (use in backgrounds, icons, illustrations)
DanioColors.amberGold       // #C8884A — decorative only
DanioColors.tealWater       // #5B9EA6 — decorative only
DanioColors.coralAccent     // #E8734A — decorative only

// Text-safe equivalents
DanioColors.amberGoldText   // #9A6830 — WCAG AA on light bg
DanioColors.tealWaterText   // #3D7F88 — WCAG AA on light bg
DanioColors.coralAccentText // #C05A33 — WCAG AA on light bg

// Other named colours
DanioColors.blueSlate       // #4A5A6B
DanioColors.deepViolet      // #2A3548
DanioColors.creamWarm       // #FFF5E8
DanioColors.emeraldGreen    // #4CAF7D
DanioColors.amethyst        // #8B6BAE
```

`DanioMaterials` provides texture base colours for the stage system:

```dart
DanioMaterials.cognacBase        // Leather grain warm tone
DanioMaterials.espressoBase      // Leather grain dark tone
DanioMaterials.warmAmberPulse    // 8% warm amber — lighting animation pulse
DanioMaterials.coolBluePulse     // 6% cool blue — lighting animation pulse
```

---

## Dos and Don'ts

### ✅ Do

```dart
// Use theme tokens
color: AppColors.primary
style: AppTypography.bodyMedium
padding: EdgeInsets.all(AppSpacing.md)
borderRadius: AppRadius.largeRadius
boxShadow: AppShadows.soft
color: AppColors.primaryAlpha20   // pre-computed alpha

// Use adaptive extension
color: context.textPrimary

// Use semantic AppTypography
Text('Learn', style: AppTypography.labelLarge)
```

### ❌ Don't

```dart
// Raw hex
color: Color(0xFFB45309)

// Inline TextStyle
style: TextStyle(fontSize: 15, fontFamily: 'Nunito')

// withOpacity() — allocates every frame
color: AppColors.primary.withOpacity(0.2)

// Raw colours for text that need WCAG compliance
color: AppColors.accent  // ← use AppColors.accentText instead
```

---

## Further Reading

- `lib/theme/app_theme.dart` — the definitive source
- `plans/typography-spec.md` — full font rationale and mapping tables
- `docs/widgets.md` — how to use styled widgets
