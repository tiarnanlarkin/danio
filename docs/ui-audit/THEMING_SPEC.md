# Theming Specification & Dark Mode Audit

**Date:** 2025-01-23  
**Audited by:** Theming Agent  
**Status:** ⚠️ IMPROVEMENTS NEEDED

---

## Executive Summary

The Aquarium App has a **solid theming foundation** with Material 3 support, well-designed color tokens, and existing WCAG AA compliance work. However, **dark mode compatibility is inconsistent** across screens due to widespread use of hardcoded colors instead of theme tokens.

### Key Findings
- ✅ **AppTheme architecture**: Well-structured with light/dark variants
- ✅ **Color tokens**: Comprehensive semantic color system with WCAG compliance
- ✅ **Room themes**: 10 beautiful decorative themes for the aquarium view
- ✅ **No true black (#000000)**: Good practice followed
- ⚠️ **573 hardcoded color usages** across screens
- ⚠️ **Only 32 dark mode checks** (`isDark` / `Theme.of`)
- ❌ **Many screens will break in dark mode**

---

## Part 1: Current Theme Architecture

### 1.1 AppColors Token System

Located in `lib/theme/app_theme.dart`:

```dart
// ✅ GOOD: Semantic light/dark pairs
AppColors.background      / AppColors.backgroundDark
AppColors.surface         / AppColors.surfaceDark
AppColors.textPrimary     / AppColors.textPrimaryDark
AppColors.textSecondary   / AppColors.textSecondaryDark
AppColors.textHint        / AppColors.textHintDark
```

**WCAG AA Compliance (documented in code):**
- `primary`: 4.75:1 with white text ✅
- `secondary`: 4.62:1 with white text ✅
- `success/warning/error/info`: All ~4.5:1 ✅
- `textHint`: 4.67:1 on background ✅
- `textHintDark`: 6.46:1 on backgroundDark ✅

### 1.2 Room Themes (Decorative)

Located in `lib/theme/room_themes.dart`:

| Theme | Description | Best For |
|-------|-------------|----------|
| Ocean | Teal & coral | Light/Dark |
| Pastel | Soft pastels | Light mode |
| Sunset | Oranges & purples | Light/Dark |
| Midnight | Deep blues | Dark mode |
| Forest | Earthy greens | Light/Dark |
| Dreamy | Ultra-soft | Light mode |
| Watercolor | Painted washes | Light mode |
| Cotton | Gradient mesh | Light mode |
| Aurora | Northern lights | Dark mode |
| Golden | Warm sunset | Light mode |

**Note:** Room themes are for the aquarium scene decoration only; they should NOT affect app UI colors.

### 1.3 Theme Mode Settings

Located in `lib/providers/settings_provider.dart`:
- System (follows device) ✅
- Light mode ✅  
- Dark mode ✅

---

## Part 2: Dark Mode Issues Found

### 2.1 Critical Issues (Screens Will Break)

#### 🔴 Hardcoded Light Colors (High Priority)

**Files with most hardcoded colors:**

| File | Issues |
|------|--------|
| `activity_feed_screen.dart` | `Colors.grey.shade300/500/600`, `Colors.amber` |
| `achievements_screen.dart` | `Colors.white`, `Colors.grey` |
| `algae_guide_screen.dart` | `Colors.green.*`, `Colors.grey.*`, `Colors.brown` |
| `add_log_screen.dart` | `Colors.white`, `Colors.black` |
| `home_screen.dart` | Multiple hardcoded hex colors |
| `house_navigator.dart` | Hardcoded nav colors |
| `gem_shop_screen.dart` | Own color palette (intentional) |
| `inventory_screen.dart` | Own color palette (intentional) |
| `shop_street_screen.dart` | Own color palette (intentional) |

#### 🔴 Specific Anti-Patterns Found

```dart
// ❌ BAD: Hardcoded white won't work in dark mode
color: Colors.white

// ❌ BAD: Grey shades don't adapt
color: Colors.grey.shade300

// ❌ BAD: Border color hardcoded
BorderSide(color: Colors.grey.shade300, width: 1)

// ❌ BAD: Divider color hardcoded
Divider(color: Colors.grey.shade300)

// ❌ BAD: Semantic color for decoration
color: Colors.green  // Should be theme-aware or from AppColors
```

### 2.2 Screens Requiring Fixes

**Priority 1 (Core Screens):**
- [ ] `home_screen.dart` - Uses hardcoded hex colors for badges
- [ ] `activity_feed_screen.dart` - All grey shades hardcoded
- [ ] `achievements_screen.dart` - White/grey text on cards
- [ ] `settings_screen.dart` - Needs audit
- [ ] `analytics_screen.dart` - Chart colors

**Priority 2 (Feature Screens):**
- [ ] `add_log_screen.dart` - Mixed theme/hardcoded
- [ ] `algae_guide_screen.dart` - All algae type colors hardcoded
- [ ] `disease_guide_screen.dart` - Similar to algae
- [ ] `charts_screen.dart` - Chart colors
- [ ] `cost_tracker_screen.dart` - Data visualization

**Priority 3 (Guide Screens):**
- [ ] All `*_guide_screen.dart` files need review

### 2.3 Intentional Themed Screens (No Fix Needed)

These screens have their own immersive color palettes by design:
- ✅ `gem_shop_screen.dart` - Gem shop aesthetic (dark navy)
- ✅ `inventory_screen.dart` - Inventory UI (purple)
- ✅ `shop_street_screen.dart` - Market aesthetic (forest green)
- ✅ `theme_gallery_screen.dart` - Shows theme previews

---

## Part 3: Recommended Fixes

### 3.1 Color Token Additions Needed

Add to `AppColors`:

```dart
// Borders (missing dark variant usage)
static const Color dividerLight = Color(0xFFE0E0E0);
static const Color dividerDark = Color(0xFF3D4A5C);

// Status indicators (for guides - algae types, diseases, etc.)
static const Color indicatorGreen = Color(0xFF4CAF50);
static const Color indicatorGreenDark = Color(0xFF66BB6A);
static const Color indicatorBrown = Color(0xFF795548);
static const Color indicatorBrownDark = Color(0xFF8D6E63);
// ... etc for each algae/guide type color

// Badge backgrounds (for home screen quick actions)
static Color badge(Color accent, Brightness brightness) {
  return brightness == Brightness.dark 
    ? accent.withOpacity(0.2) 
    : accent.withOpacity(0.1);
}
```

### 3.2 Theme Extension Pattern

Create `lib/theme/app_theme_extensions.dart`:

```dart
extension BuildContextTheme on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  
  Color get dividerColor => isDark 
    ? AppColors.dividerDark 
    : AppColors.dividerLight;
    
  Color get cardBorderColor => isDark
    ? Colors.white.withOpacity(0.1)
    : Colors.black.withOpacity(0.08);
    
  Color textOn(Color background) {
    return background.computeLuminance() > 0.5 
      ? AppColors.textPrimary 
      : AppColors.textPrimaryDark;
  }
}
```

### 3.3 Migration Strategy

**Phase 1: Quick Wins (1-2 hours)**
```dart
// Replace all instances of:
Colors.grey.shade300  →  Theme.of(context).dividerColor
Colors.grey.shade500  →  AppColors.textHint / textHintDark
Colors.grey.shade600  →  AppColors.textSecondary / textSecondaryDark
```

**Phase 2: Conditional Colors (2-3 hours)**
```dart
// Add isDark checks where needed:
final isDark = Theme.of(context).brightness == Brightness.dark;
color: isDark ? AppColors.surfaceDark : AppColors.surface
```

**Phase 3: Semantic Colors (Ongoing)**
- Create new tokens for guide-specific colors (algae, diseases)
- Ensure each has light/dark variants
- Update ColorContrastChecker to validate

---

## Part 4: Dark Mode Best Practices

### 4.1 Material 3 Dark Theme Guidelines

**DO:**
- Use elevation-based surface colors (Flutter handles this)
- Reduce contrast for comfortable reading (not pure white)
- Use desaturated primary colors in dark mode
- Add subtle tint to surfaces (already done: blue-gray background)

**DON'T:**
- Use pure black (#000000) backgrounds ✅ Already avoided
- Use pure white (#FFFFFF) text ✅ Using textPrimaryDark
- Apply box shadows in dark mode (use surface elevation instead)
- Use the same vibrant colors as light mode without desaturation

### 4.2 Elevation & Shadows

Current `AppShadows` uses black opacity - these should be **disabled or reduced** in dark mode:

```dart
// lib/theme/app_theme.dart
static List<BoxShadow> soft(Brightness brightness) {
  if (brightness == Brightness.dark) {
    return []; // No shadows in dark mode
  }
  return [
    BoxShadow(color: Colors.black.withOpacity(0.04), ...),
  ];
}
```

### 4.3 Images & Icons

- SVG icons: Use `ColorFilter` to adapt
- PNG images: Consider white-on-transparent variants
- Fish/plant illustrations: Already use room theme colors ✅

### 4.4 Contrast Requirements

| Element | Light Mode | Dark Mode |
|---------|------------|-----------|
| Body text | 4.5:1 min | 4.5:1 min |
| Large text | 3:1 min | 3:1 min |
| UI components | 3:1 min | 3:1 min |
| Decorative | No requirement | No requirement |

---

## Part 5: Dynamic Theming Analysis

### 5.1 Material You / Dynamic Color

**What It Does:**
- Extracts colors from device wallpaper (Android 12+)
- Creates harmonious palette automatically
- iOS: Not supported natively

**Implementation:**
```dart
// pubspec.yaml
dependencies:
  dynamic_color: ^1.6.8

// main.dart
DynamicColorBuilder(
  builder: (lightDynamic, darkDynamic) {
    return MaterialApp(
      theme: lightDynamic?.harmonized() ?? AppTheme.light,
      darkTheme: darkDynamic?.harmonized() ?? AppTheme.dark,
    );
  },
);
```

### 5.2 Recommendation: NOT WORTH IT YET

**Reasons:**
1. **Brand consistency**: Aquarium app has strong teal/coral identity
2. **Room themes already exist**: Users can customize visual style
3. **Implementation complexity**: Would need to maintain 3 systems (static, room, dynamic)
4. **Platform fragmentation**: Only Android 12+ supports it
5. **Aquarium theme conflict**: What if wallpaper is red? Doesn't match aquarium aesthetic.

**Alternative Approach:**
- Keep current semantic colors
- Let room themes handle personalization
- Consider dynamic color for accent highlights only (future)

---

## Part 6: Theme Customization Recommendations

### 6.1 Current State

- ✅ Room themes: 10 decorative themes for aquarium scene
- ✅ Theme mode: System/Light/Dark
- ❌ Accent color picker: Not implemented
- ❌ Font size options: Not implemented

### 6.2 Future Customization Options

**Recommended (Low Effort, High Value):**
```
Settings > Appearance
├── Theme Mode: System | Light | Dark
├── Room Theme: [Gallery Picker]
└── Accent Color: [Preset choices] ← NEW
    ├── Ocean (default teal)
    ├── Coral (warm)
    ├── Forest (green)
    ├── Lavender (purple)
    └── Custom (color picker)
```

**Implementation:**
```dart
// Store in settings_provider.dart
enum AccentColorChoice { ocean, coral, forest, lavender, custom }

// Modify AppTheme to accept accent color
static ThemeData light({Color? accentColor}) {
  final primary = accentColor ?? AppColors.primary;
  // ...
}
```

### 6.3 Seasonal Themes

**Low Priority** - Consider for future:
- 🎄 Winter/Holiday
- 🌸 Spring
- 🏖️ Summer
- 🍂 Autumn

These would be room themes, not app UI themes.

---

## Part 7: Implementation Checklist

### Immediate Actions (This Sprint)

- [ ] Create `app_theme_extensions.dart` helper
- [ ] Replace all `Colors.grey.shade*` with theme colors
- [ ] Add `isDark` checks to top 10 screens by usage
- [ ] Disable shadows in dark mode
- [ ] Audit divider colors app-wide

### Short Term (Next Sprint)

- [ ] Create semantic tokens for guide colors
- [ ] Add dark variants for all guide types (algae, diseases)
- [ ] Update GlassCard/GradientCard for dark mode
- [ ] Test all screens in dark mode (manual QA pass)

### Medium Term (Backlog)

- [ ] Consider accent color picker
- [ ] Add font size accessibility options
- [ ] Create dark mode screenshots for store listing
- [ ] Document color token usage in README

---

## Appendix A: Files Requiring Dark Mode Fixes

```
lib/screens/
├── about_screen.dart ⚠️
├── achievements_screen.dart ⚠️
├── activity_feed_screen.dart 🔴
├── add_log_screen.dart ⚠️
├── algae_guide_screen.dart 🔴
├── analytics_screen.dart ⚠️
├── charts_screen.dart ⚠️
├── co2_calculator_screen.dart ⚠️
├── compatibility_checker_screen.dart ⚠️
├── cost_tracker_screen.dart ⚠️
├── create_tank_screen.dart ⚠️
├── difficulty_settings_screen.dart ⚠️
├── disease_guide_screen.dart 🔴
├── emergency_guide_screen.dart ⚠️
├── enhanced_onboarding_screen.dart ⚠️
├── enhanced_quiz_screen.dart ⚠️
├── friend_comparison_screen.dart ⚠️
├── friends_screen.dart ⚠️
├── hardscape_guide_screen.dart ⚠️
├── home_screen.dart 🔴
├── house_navigator.dart ⚠️
└── [continue for all screens...]

Legend:
🔴 Critical - Will visibly break
⚠️ Moderate - May have contrast issues
✅ OK - Theme-aware or intentionally styled
```

## Appendix B: Color Contrast Checker Usage

The existing `ColorContrastChecker` utility should be used during development:

```dart
// Check any new color combinations:
final ratio = ColorContrastChecker.contrastRatio(
  foregroundColor,
  backgroundColor,
);
print(ColorContrastChecker.generateReport(fg, bg));

// Extension method:
if (!textColor.isAccessibleOn(bgColor)) {
  textColor = textColor.ensureAccessibleOn(bgColor);
}
```

---

## Summary

The Aquarium App has **good theming bones** but needs a **dark mode polish pass**. The main issues are hardcoded colors scattered across screens. The recommended approach is:

1. **Short-term**: Replace hardcoded colors with theme tokens
2. **Medium-term**: Add helper extensions for common patterns
3. **Long-term**: Consider accent color customization

Dynamic theming (Material You) is **not recommended** at this time due to complexity and brand consistency concerns.

**Estimated effort to achieve A+ dark mode: 8-12 hours of developer time**
