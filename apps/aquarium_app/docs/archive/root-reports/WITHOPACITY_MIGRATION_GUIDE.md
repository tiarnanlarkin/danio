# withOpacity Migration Guide

## Task
Replace dynamic `Colors.*.withOpacity()` calls with pre-computed alpha color constants from AppColors.

## Why This Matters
- **Performance:** withOpacity() creates new Color objects at runtime → GC pressure
- **Solution:** Use pre-computed alpha colors → zero runtime cost
- **Impact:** Smoother rendering, especially in animations and scrolling

## Available Pre-Computed Colors

### White Alpha Variants
```dart
AppColors.whiteAlpha05  // 5% opacity  (0x0DFFFFFF)
AppColors.whiteAlpha10  // 10% opacity (0x19FFFFFF)
AppColors.whiteAlpha15  // 15% opacity (0x26FFFFFF)
AppColors.whiteAlpha20  // 20% opacity (0x33FFFFFF)
AppColors.whiteAlpha30  // 30% opacity (0x4DFFFFFF)
AppColors.whiteAlpha40  // 40% opacity (0x66FFFFFF)
AppColors.whiteAlpha50  // 50% opacity (0x80FFFFFF)
AppColors.whiteAlpha60  // 60% opacity (0x99FFFFFF)
AppColors.whiteAlpha70  // 70% opacity (0xB3FFFFFF)
AppColors.whiteAlpha80  // 80% opacity (0xCCFFFFFF)
AppColors.whiteAlpha90  // 90% opacity (0xE6FFFFFF)
```

### Black Alpha Variants
```dart
AppColors.blackAlpha05  // 5% opacity  (0x0D000000)
AppColors.blackAlpha10  // 10% opacity (0x19000000)
AppColors.blackAlpha15  // 15% opacity (0x26000000)
AppColors.blackAlpha20  // 20% opacity (0x33000000)
AppColors.blackAlpha30  // 30% opacity (0x4D000000)
AppColors.blackAlpha40  // 40% opacity (0x66000000)
AppColors.blackAlpha50  // 50% opacity (0x80000000)
AppColors.blackAlpha60  // 60% opacity (0x99000000)
AppColors.blackAlpha70  // 70% opacity (0xB3000000)
AppColors.blackAlpha80  // 80% opacity (0xCC000000)
AppColors.blackAlpha90  // 90% opacity (0xE6000000)
```

### Primary/Theme Alpha Variants
```dart
// Primary color (blue)
AppColors.primaryAlpha10
AppColors.primaryAlpha20
AppColors.primaryAlpha30
// ... etc (check app_theme.dart for full list)
```

### Special Colors with Alpha
Many theme colors also have alpha variants. Check `lib/theme/app_theme.dart` for:
- Room background colors (cozyBrown, studyGold, etc.)
- Overlay colors (AppOverlays.*)
- All have alpha10, alpha20, alpha30, alpha40 variants

## Migration Patterns

### Pattern 1: Simple White/Black Opacity
```dart
// BEFORE
Colors.white.withOpacity(0.1)
Colors.black.withOpacity(0.2)

// AFTER
AppColors.whiteAlpha10
AppColors.blackAlpha20
```

### Pattern 2: Opacity in Range (Round to Nearest)
```dart
// BEFORE
Colors.white.withOpacity(0.12)  // 12%
Colors.white.withOpacity(0.25)  // 25%
Colors.white.withOpacity(0.85)  // 85%

// AFTER
AppColors.whiteAlpha10  // 10% (closest to 12%)
AppColors.whiteAlpha20  // 20% (closest to 25%)
AppColors.whiteAlpha90  // 90% (closest to 85%)

// OR if precision matters, use whiteAlpha15
AppColors.whiteAlpha15  // 15% (if 12% needs to round up)
```

### Pattern 3: Theme Color Opacity
```dart
// BEFORE
AppColors.primary.withOpacity(0.2)

// AFTER
AppColors.primaryAlpha20
```

### Pattern 4: Dynamic/Animated Opacity
```dart
// BEFORE (animated)
Colors.white.withOpacity(_controller.value)

// AFTER - KEEP AS IS
// Dynamic opacity in animations MUST stay as withOpacity()
// Only replace STATIC opacity values
```

## Opacity Conversion Chart
- 0.05 → alpha05 (5%)
- 0.10 → alpha10 (10%)
- 0.15 → alpha15 (15%)
- 0.20 → alpha20 (20%)
- 0.25 → alpha20 or alpha30 (round to nearest)
- 0.30 → alpha30 (30%)
- 0.40 → alpha40 (40%)
- 0.50 → alpha50 (50%)
- 0.60 → alpha60 (60%)
- 0.70 → alpha70 (70%)
- 0.80 → alpha80 (80%)
- 0.90 → alpha90 (90%)

## Process
1. Search for all `.withOpacity(` in your assigned file
2. For each instance:
   - Check if it's **static** (hardcoded number) or **dynamic** (variable/animation)
   - If **dynamic** → SKIP (must stay as withOpacity)
   - If **static** → Convert to pre-computed alpha color
3. Round opacity values to nearest available alpha constant
4. Test build: `flutter build apk --debug`
5. Commit: `perf: eliminate withOpacity in [filename] (N instances)`

## Example File Migration

**Before:**
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        AppColors.primary.withOpacity(0.3),
        Colors.white.withOpacity(0.1),
      ],
    ),
  ),
)
```

**After:**
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        AppColors.primaryAlpha30,
        AppColors.whiteAlpha10,
      ],
    ),
  ),
)
```

## DO NOT Replace
❌ **Animated opacity:**
```dart
Colors.white.withOpacity(_animation.value)  // KEEP
Colors.white.withOpacity(opacity)           // KEEP (if opacity is variable)
```

❌ **Colors without alpha variants:**
```dart
Colors.red.withOpacity(0.5)     // KEEP (no redAlpha50 in theme)
Color(0xFF123456).withOpacity() // KEEP (custom color)
```

✅ **Only replace:**
```dart
Colors.white.withOpacity(0.2)    // → AppColors.whiteAlpha20
Colors.black.withOpacity(0.1)    // → AppColors.blackAlpha10
AppColors.primary.withOpacity()  // → AppColors.primaryAlpha*
```

## Success Criteria
- ✅ All static Colors.white/black.withOpacity() replaced
- ✅ All static AppColors.*.withOpacity() replaced (if alpha variant exists)
- ✅ Dynamic/animated withOpacity() left unchanged
- ✅ Build succeeds
- ✅ Changes committed

## Commit Message Template
```
perf: eliminate withOpacity in [filename] (N instances)

Replaced static withOpacity() calls with pre-computed alpha colors:
- Colors.white.withOpacity() → AppColors.whiteAlpha*
- Colors.black.withOpacity() → AppColors.blackAlpha*
- AppColors.*.withOpacity() → AppColors.*Alpha*

Improves performance by eliminating runtime Color object creation.
```

## Notes
- Check `lib/theme/app_theme.dart` lines 60-200 for full list of alpha colors
- When in doubt, round to nearest 10% increment
- Visual difference between 12% and 10% opacity is negligible
- Focus on eliminating the runtime overhead, not pixel-perfect opacity matching
