import 'package:flutter/material.dart';

class AppColors {
  // Primary palette - Danio Amber-Gold brand
  static const Color primary = Color(
    0xFFB45309,
  ); // Amber 700 (WCAG AA: 4.7:1 with white text)
  static const Color primaryLight = Color(
    0xFFD97706,
  ); // Amber 600 (for light backgrounds)
  static const Color primaryDark = Color(0xFF92400E); // Amber 800

  // Secondary - Blue-Slate
  static const Color secondary = Color(0xFF4A5A6B); // Blue-Slate
  static const Color secondaryLight = Color(0xFF6B7F8E); // lighter blue-slate
  static const Color secondaryDark = Color(0xFF2A3548); // Deep Violet

  // Accent colors
  static const Color accent = Color(0xFF5B9EA6); // Teal Water — decorative only — not for text
  static const Color accentText = Color(0xFF3D7F88); // WCAG AA text on light bg (4.6:1)
  static const Color accentAlt = Color(0xFF8B6BAE); // Amethyst

  // Semantic colors - WCAG AA compliant (4.5:1 minimum contrast with white text)
  static const Color success = Color(0xFF1E8449); // WCAG AA green (7.3:1 ratio)
  static const Color warning = Color(0xFF8B6914); // Darker amber (~4.5:1 ratio on white — WCAG AA)
  static const Color error = Color(0xFFC0392B); // WCAG AA red (5.9:1 ratio)
  static const Color info = Color(0xFF2E86AB); // WCAG AA blue (5.2:1 ratio)
  static const Color xp = Color(0xFFD97706); // Amber - matches brand

  // Semantic "on" colors - foreground on semantic backgrounds
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF2D3436); // textPrimary
  static const Color onBackground = Color(0xFF2D3436); // textPrimary
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color onWarning = Color(0xFFFFFFFF);

  // Parameter status colors (legacy compatibility) - WCAG AA compliant
  static const Color paramSafe = Color(0xFF1E8449);
  static const Color paramWarning = Color(0xFF8B6914);
  static const Color paramDanger = Color(0xFFC0392B);

  // Onboarding palette (consolidated from 7+ onboarding screens)
  static const Color onboardingWarmCream = Color(0xFFFFF8F0);
  static const Color onboardingAmber = Color(0xFFF5A623);
  static const Color onboardingAmberText = Color(0xFF9E6008); // WCAG AA on warm cream

  // Neutrals - Light mode
  static const Color background = Color(0xFFFFF5E8); // Warm Cream
  static const Color surface = Color(0xFFFFFBF5); // Ivory White
  static const Color surfaceVariant = Color(0xFFFFF0DC); // Warm tinted
  static const Color card = Color(0xFFFFFFFF);

  // Text colors - Light mode
  static const Color textPrimary = Color(0xFF2D3436); // Near black
  static const Color textSecondary = Color(0xFF636E72); // Medium gray (WCAG AA: 6.4:1 on white)
  static const Color textSecondaryAlpha10 = Color(0x1A636E72); // 10%
  static const Color textSecondaryAlpha30 = Color(0x4C636E72); // 30%
  static const Color textHint = Color(
    0xFF5D6F76,
  ); // Medium-dark gray (WCAG AA: 4.67:1 on background, 5.25:1 on white)

  // Border colors
  static const Color border = Color(0xFFE0E0E0); // Light gray border
  static const Color borderDark = Color(0xFF3D4A5C); // Dark mode border

  // Dark mode colors
  static const Color backgroundDark = Color(
    0xFF1C1917,
  ); // Warm Charcoal (NOT cold blue-grey)
  static const Color surfaceDark = Color(0xFF231F1E); // Slightly lighter
  static const Color surfaceVariantDark = Color(0xFF292524);
  static const Color cardDark = Color(0xFF2A2220);

  // Text colors - Dark mode
  static const Color textPrimaryDark = Color(0xFFFAF5F0); // Warm white
  static const Color textSecondaryDark = Color(0xFFCDBFAE);
  static const Color textHintDark = Color(
    0xFF9A8F82,
  ); // Lighter gray (WCAG AA compliant on dark backgrounds)

  // ============================================================================
  // PRE-COMPUTED ALPHA COLORS - PERFORMANCE OPTIMIZATION
  // ============================================================================
  // Instead of using .withOpacity() (which creates new Color objects on every
  // build and causes GC pressure), use these pre-computed alpha colors.
  //
  // Naming convention: [color]Alpha[opacity]
  // Example: whiteAlpha50 = white at 50% opacity (0x80 = 128/255 ≈ 0.5)
  //
  // Alpha hex values reference:
  // 0.05 = 0x0D, 0.08 = 0x14, 0.10 = 0x1A, 0.12 = 0x1F, 0.15 = 0x26,
  // 0.20 = 0x33, 0.25 = 0x40, 0.30 = 0x4D, 0.35 = 0x59, 0.40 = 0x66,
  // 0.50 = 0x80, 0.60 = 0x99, 0.70 = 0xB3, 0.80 = 0xCC, 0.85 = 0xD9,
  // 0.90 = 0xE6, 0.95 = 0xF2
  //
  // ============================================================================
  // MIGRATION GUIDE
  // ============================================================================
  // ❌ BEFORE (creates new object every build):
  //    color: AppColors.whiteAlpha50
  //    color: AppColors.primaryAlpha20
  //
  // ✅ AFTER (zero-cost constant):
  //    color: AppColors.whiteAlpha50
  //    color: AppColors.primaryAlpha20
  //
  // Performance impact: Eliminates ~378 object allocations per frame = smoother UI
  // ============================================================================

  // White with alpha (most common for overlays, glassmorphism)
  static const Color whiteAlpha05 = Color(0x0DFFFFFF);
  static const Color whiteAlpha08 = Color(0x14FFFFFF);
  static const Color whiteAlpha10 = Color(0x1AFFFFFF);
  static const Color whiteAlpha12 = Color(0x1FFFFFFF);
  static const Color whiteAlpha15 = Color(0x26FFFFFF);
  static const Color whiteAlpha20 = Color(0x33FFFFFF);
  static const Color whiteAlpha25 = Color(0x40FFFFFF);
  static const Color whiteAlpha30 = Color(0x4DFFFFFF);
  static const Color whiteAlpha35 = Color(0x59FFFFFF);
  static const Color whiteAlpha40 = Color(0x66FFFFFF);
  static const Color whiteAlpha50 = Color(0x80FFFFFF);
  static const Color whiteAlpha60 = Color(0x99FFFFFF);
  static const Color whiteAlpha70 = Color(0xB3FFFFFF);
  static const Color whiteAlpha80 = Color(0xCCFFFFFF);
  static const Color whiteAlpha85 = Color(0xD9FFFFFF);
  static const Color whiteAlpha90 = Color(0xE6FFFFFF);
  static const Color whiteAlpha95 = Color(0xF2FFFFFF);

  // Black with alpha (for shadows, darkening overlays)
  static const Color blackAlpha02 = Color(0x05000000); // 3%
  static const Color blackAlpha03 = Color(0x08000000); // 3%
  static const Color blackAlpha05 = Color(0x0D000000);
  static const Color blackAlpha08 = Color(0x14000000);
  static const Color blackAlpha10 = Color(0x1A000000);
  static const Color blackAlpha12 = Color(0x1F000000);
  static const Color blackAlpha15 = Color(0x26000000);
  static const Color blackAlpha20 = Color(0x33000000);
  static const Color blackAlpha25 = Color(0x40000000);
  static const Color blackAlpha30 = Color(0x4D000000);
  static const Color blackAlpha35 = Color(0x59000000);
  static const Color blackAlpha40 = Color(0x66000000);
  static const Color blackAlpha50 = Color(0x80000000);
  static const Color blackAlpha60 = Color(0x99000000);
  static const Color blackAlpha70 = Color(0xB3000000);
  static const Color blackAlpha80 = Color(0xCC000000);
  static const Color blackAlpha85 = Color(0xD9000000);
  static const Color blackAlpha90 = Color(0xE6000000);

  // Primary color with alpha (Amber brand)
  static const Color primaryAlpha05 = Color(0x0DB45309);
  static const Color primaryAlpha08 = Color(0x14B45309);
  static const Color primaryAlpha10 = Color(0x1AB45309);
  static const Color primaryAlpha12 = Color(0x1FB45309);
  static const Color primaryAlpha15 = Color(0x26B45309);
  static const Color primaryAlpha20 = Color(0x33B45309);
  static const Color primaryAlpha25 = Color(0x40B45309);
  static const Color primaryAlpha30 = Color(0x4DB45309);
  static const Color primaryAlpha40 = Color(0x66B45309);
  static const Color primaryAlpha50 = Color(0x80B45309);
  static const Color primaryAlpha60 = Color(0x99B45309);
  static const Color primaryAlpha70 = Color(0xB3B45309);
  static const Color primaryAlpha85 = Color(0xD9B45309);
  static const Color primaryAlpha90 = Color(0xE6B45309);

  // Primary Light with alpha
  static const Color primaryLightAlpha10 = Color(0x1AD97706);
  static const Color primaryLightAlpha20 = Color(0x33D97706);
  static const Color primaryLightAlpha30 = Color(0x4DD97706);
  static const Color primaryLightAlpha40 = Color(0x66D97706);
  static const Color primaryLightAlpha50 = Color(0x80D97706);

  // Primary Dark with alpha
  static const Color primaryDarkAlpha40 = Color(0x6692400E);

  // Secondary color with alpha (Blue-Slate)
  static const Color secondaryAlpha05 = Color(0x0D4A5A6B);
  static const Color secondaryAlpha10 = Color(0x1A4A5A6B);
  static const Color secondaryAlpha15 = Color(0x264A5A6B);
  static const Color secondaryAlpha20 = Color(0x334A5A6B);
  static const Color secondaryAlpha25 = Color(0x404A5A6B);
  static const Color secondaryAlpha30 = Color(0x4D4A5A6B);
  static const Color secondaryAlpha40 = Color(0x664A5A6B);
  static const Color secondaryAlpha50 = Color(0x804A5A6B);
  static const Color secondaryAlpha90 = Color(0xE64A5A6B);

  // Accent color with alpha (base: AppColors.accent = 0xFF5B9EA6 — Teal Water)
  static const Color accentAlpha10 = Color(0x1A5B9EA6);
  static const Color accentAlpha20 = Color(0x335B9EA6);
  static const Color accentAlpha30 = Color(0x4D5B9EA6);
  static const Color accentAlpha40 = Color(0x665B9EA6);
  static const Color accentAlpha50 = Color(0x805B9EA6);
  static const Color accentAlpha60 = Color(0x995B9EA6);

  // Success color with alpha
  static const Color successAlpha10 = Color(0x1A1E8449);
  static const Color successAlpha12 = Color(0x1F1E8449); // 12%
  static const Color successAlpha15 = Color(0x261E8449);
  static const Color successAlpha20 = Color(0x331E8449);
  static const Color successAlpha30 = Color(0x4D1E8449);
  static const Color successAlpha40 = Color(0x661E8449);
  static const Color successAlpha50 = Color(0x801E8449);
  static const Color successAlpha80 = Color(0xCC1E8449);
  static const Color successAlpha95 = Color(0xF21E8449);
  static const Color successAlpha100 = Color(0xFF1E8449);

  // Warning color with alpha (base: 0xFF8B6914 — WCAG AA ~4.5:1 on white)
  static const Color warningAlpha05 = Color(0x0D8B6914); // 3%
  static const Color warningAlpha08 = Color(0x148B6914); // ~8%
  static const Color warningAlpha10 = Color(0x1A8B6914);
  static const Color warningAlpha12 = Color(0x1F8B6914); // 7%
  static const Color warningAlpha15 = Color(0x268B6914);
  static const Color warningAlpha20 = Color(0x338B6914);
  static const Color warningAlpha30 = Color(0x4D8B6914);
  static const Color warningAlpha40 = Color(0x668B6914);
  static const Color warningAlpha50 = Color(0x808B6914);
  static const Color warningAlpha60 = Color(0x998B6914);
  static const Color warningAlpha70 = Color(0xB38B6914);
  static const Color warningAlpha80 = Color(0xCC8B6914);

  // Error color with alpha
  static const Color errorAlpha05 = Color(0x0DC0392B);
  static const Color errorAlpha08 = Color(0x14C0392B); // ~8%
  static const Color errorAlpha10 = Color(0x1AC0392B);
  static const Color errorAlpha15 = Color(0x26C0392B);
  static const Color errorAlpha20 = Color(0x33C0392B);
  static const Color errorAlpha30 = Color(0x4DC0392B);
  static const Color errorAlpha40 = Color(0x66C0392B);
  static const Color errorAlpha50 = Color(0x80C0392B);
  static const Color errorAlpha90 = Color(0xE6C0392B);
  static const Color errorAlpha95 = Color(0xF2C0392B);
  static const Color errorAlpha100 = Color(0xFFC0392B);

  // Info color with alpha
  static const Color infoAlpha10 = Color(0x1A2E86AB);
  static const Color infoAlpha20 = Color(0x332E86AB);
  static const Color infoAlpha30 = Color(0x4D2E86AB);
  static const Color infoAlpha40 = Color(0x662E86AB);
  static const Color infoAlpha50 = Color(0x802E86AB);

  // Background color with alpha
  static const Color backgroundAlpha05 = Color(0x0DF5F1EB);
  static const Color backgroundAlpha10 = Color(0x1AF5F1EB);
  static const Color backgroundAlpha20 = Color(0x33F5F1EB);
  static const Color backgroundAlpha30 = Color(0x4DF5F1EB);
  static const Color backgroundAlpha50 = Color(0x80F5F1EB);
  static const Color backgroundAlpha70 = Color(0xB3F5F1EB);
  static const Color backgroundAlpha90 = Color(0xE6F5F1EB);

  // Text color with alpha (for subtle text)
  static const Color textPrimaryAlpha10 = Color(0x1A2D3436);
  static const Color textPrimaryAlpha20 = Color(0x332D3436);
  static const Color textPrimaryAlpha30 = Color(0x4D2D3436);
  static const Color textPrimaryAlpha50 = Color(0x802D3436);
  static const Color textPrimaryAlpha70 = Color(0xB32D3436);

  // Wood/Brown colors (for cozy room furniture, floors, trim)
  static const Color woodBrown = Color(0xFF8B7355);
  static const Color woodBrownAlpha05 = Color(0x0D8B7355);
  static const Color woodBrownAlpha08 = Color(0x148B7355);
  static const Color woodBrownAlpha10 = Color(0x1A8B7355);
  static const Color woodBrownAlpha12 = Color(0x1F8B7355);
  static const Color woodBrownAlpha15 = Color(0x268B7355);
  static const Color woodBrownAlpha20 = Color(0x338B7355);
  static const Color woodBrownAlpha25 = Color(0x408B7355);
  static const Color woodBrownAlpha30 = Color(0x4D8B7355);
  static const Color woodBrownAlpha35 = Color(0x598B7355);
  static const Color woodBrownAlpha40 = Color(0x668B7355);
  static const Color woodBrownAlpha50 = Color(0x808B7355);

  // Yellow color with alpha (for hobby items gold highlights)
  static const Color yellowAlpha08 = Color(0x14FFFF00); // 3%
  static const Color yellowAlpha15 = Color(0x26FFFF00); // 8%
  static const Color yellowAlpha20 = Color(0x33FFFF00); // 20%
  static const Color yellowAlpha30 = Color(0x4DFFFF00); // 30%
  static const Color yellowAlpha40 = Color(0x66FFFF00); // 40%

  // Study gold color with alpha
  static const Color studyGoldAlpha05 = Color(0x0DD4A574); // 3%
  static const Color studyGoldAlpha10 = Color(0x19D4A574); // 6%
  static const Color studyGoldAlpha15 = Color(0x26D4A574); // 10%
  static const Color studyGoldAlpha20 = Color(0x33D4A574); // 20%
  static const Color studyGoldAlpha30 = Color(0x4DD4A574); // 30%
  static const Color studyGoldAlpha40 = Color(0x66D4A574); // 40%

  // XP color with alpha (same as studyGold - 0xD4A574)
  static const Color xpAlpha20 = Color(0x33D4A574); // 20%

  // Cozy room colors with alpha (for theme variations)
  static const Color cozyGreen05 = Color(0x0D4CAF50); // livingRoomPlant at 3%
  static const Color cozyGreen08 = Color(0x144CAF50); // 8%
  static const Color cozyGreen10 = Color(0x1A4CAF50); // 10%
  static const Color cozyGreen15 = Color(0x264CAF50); // 15%
  static const Color cozyGreen20 = Color(0x334CAF50); // 20%
  static const Color cozyGreen30 = Color(0x4D4CAF50); // 30%

  static const Color cozyBlue05 = Color(0x0D87CEEB); // shopSky at 3%
  static const Color cozyBlue08 = Color(0x1487CEEB); // 8%
  static const Color cozyBlue10 = Color(0x1A87CEEB); // 10%
  static const Color cozyBlue15 = Color(0x2687CEEB); // 15%
  static const Color cozyBlue20 = Color(0x3387CEEB); // 20%

  // Dark mode background with alpha (base: AppColors.backgroundDark = 0xFF1C1917 — Warm Charcoal)
  static const Color backgroundDarkAlpha10 = Color(0x1A1C1917);
  static const Color backgroundDarkAlpha20 = Color(0x331C1917);
  static const Color backgroundDarkAlpha30 = Color(0x4D1C1917);
  static const Color backgroundDarkAlpha50 = Color(0x801C1917);
  static const Color backgroundDarkAlpha70 = Color(0xB31C1917);
  static const Color backgroundDarkAlpha90 = Color(0xE61C1917);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD97706), Color(0xFFB45309)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF0DC), Color(0xFFE8C07A)],
  );

  static const LinearGradient oceanGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF8BC4CA), Color(0xFF5B9EA6)],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8A87C), Color(0xFFE88B8B), Color(0xFFC5A3FF)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF292524), Color(0xFF1C1917)],
  );

  // Learn screen header gradient tokens — replaced by ThemedTabHeader
  @Deprecated('Use ThemedTabHeader with headerGradientForTheme() instead')
  static const Color learnHeaderTop = Color(0xFF5B8FA8);
  @Deprecated('Use ThemedTabHeader with headerGradientForTheme() instead')
  static const Color learnHeaderMid = Color(0xFF3D6B7A);
  @Deprecated('Use ThemedTabHeader with headerGradientForTheme() instead')
  static const Color learnHeaderBottom = Color(0xFF2D5566);
}

/// Material constants for the stage system textures and surfaces.
///
/// Provides base colours for leather grain materials and lighting pulse animations
/// used in the cosy room / stage scene system.
class DanioMaterials {
  // Leather grain
  static const Color cognacBase = Color(0xFFC68B3E);
  static const Color espressoBase = Color(0xFF3D2416);

  // Lighting pulse colours
  static const Color warmAmberPulse = Color(0x14FFB74D); // 8% warm amber
  static const Color coolBluePulse = Color(0x0F64B5F6); // 6% cool blue
}

/// Named brand colour palette for Danio.
///
/// Prefer these for new UI components where a semantic name is clearer than a hex value.
/// Each decorative colour has a `*Text` paired token that is WCAG AA compliant for text
/// on light backgrounds.
///
/// ```dart
/// // Decorative (backgrounds, icons, illustrations)
/// color: DanioColors.tealWater
///
/// // WCAG AA safe for text
/// color: DanioColors.tealWaterText
/// ```
class DanioColors {
  static const Color amberGold = Color(0xFFC8884A); // Decorative amber — not for text
  static const Color amberGoldText = Color(0xFF9A6830); // WCAG AA text on light bg (4.6:1)
  static const Color amberText = Color(0xFFB45309); // Text on light (WCAG AA)
  static const Color amberTextDark = Color(
    0xFFFBBF24,
  ); // Text on dark (WCAG AA)
  static const Color blueSlate = Color(0xFF4A5A6B);
  static const Color deepViolet = Color(0xFF2A3548);
  static const Color tealWater = Color(0xFF5B9EA6); // Decorative teal — not for text
  static const Color tealWaterText = Color(0xFF3D7F88); // WCAG AA text on light bg (4.6:1)
  static const Color coralAccent = Color(0xFFE8734A); // Decorative coral — not for text
  static const Color coralAccentText = Color(0xFFC05A33); // WCAG AA text on light bg (4.6:1)
  static const Color seafoamLight = Color(0xFFB8D8D0);
  static const Color creamWarm = Color(0xFFFFF5E8);
  static const Color ivoryWhite = Color(0xFFFFFBF5);
  static const Color emeraldGreen = Color(0xFF4CAF7D);
  static const Color rubyRed = Color(0xFFD94F5C); // Decorative red — not for text
  static const Color rubyRedText = Color(0xFFB03A47); // WCAG AA text on light bg (4.6:1)
  static const Color sapphireBlue = Color(0xFF4A7BC8);
  static const Color amethyst = Color(0xFF8B6BAE);
  static const Color topaz = Color(0xFFE8A84A);

  // ── Algae guide type indicators ──────────────────────────────────
  // Used in AlgaeGuideScreen to colour-code algae types by appearance.
  static const Color algaeGreenPale = Color(0xFFA5D6A7);   // Rhizoclonium / very light green
  static const Color algaeGreenLight = Color(0xFF81C784);  // Green water / light green
  static const Color algaeGreenBright = Color(0xFF66BB6A); // Hair algae / medium green
  static const Color algaeGreenDark = Color(0xFF2E7D32);   // Heavy algae / deep green (also analytics heatmap)
  static const Color algaeBlack = Color(0xFF424242);       // Black beard algae indicator
  static const Color algaeStaghorn = Color(0xFF9E9E9E);    // Staghorn algae / neutral grey

  // ── Wishlist / workshop tool card accents ────────────────────────
  static const Color wishlistAmber = Color(0xFFFFCA28);    // Wishlist section + workshop tool card accent
  static const Color equipmentGold = Color(0xFFFFB300);    // Equipment wishlist accent (deeper gold)

  // ── Mascot mood gradient colours ─────────────────────────────────
  static const Color mascotCelebrate1 = Color(0xFFFFD700); // Celebrating mood — gradient start (gold)
  static const Color mascotCelebrate2 = Color(0xFFFFA500); // Celebrating mood — gradient end (orange)
  static const Color mascotThinkingDark = Color(0xFF4A8A92); // Thinking mood — dark teal pair for DanioColors.tealWater
  static const Color mascotEncourage1 = Color(0xFF9F6847);   // Encouraging mood — warm brown
  static const Color mascotEncourage2 = Color(0xFFE8A87C);   // Encouraging mood — soft amber
  static const Color mascotCurious1 = Color(0xFFC5A3FF);     // Curious mood — soft lavender
  static const Color mascotCurious2 = Color(0xFF9F7AEA);     // Curious mood — mid purple

  // ── Level up overlay accent ──────────────────────────────────────
  static const Color levelUpFuchsia = Color(0xFFD946EF);   // Level-up ring pulse — fuchsia highlight

  // ── Decorative element defaults ──────────────────────────────────
  static const Color plantDecoration = Color(0xFF7AC29A);  // Default PlantDecoration widget colour
  static const Color waterWave = Color(0xFF85C7DE);        // Default WaterWave widget colour

  // ── Decorative surface tones (notebook / aquarium frame) ─────────
  static const Color notebookDark = Color(0xFF2A3A4A);     // Notebook card background (dark mode)
  static const Color notebookLight = Color(0xFFFFFDF8);    // Notebook card background (light mode)
  static const Color notebookBorderLight = Color(0xFFE8E4DC); // Notebook card border (light mode)
  static const Color aquariumFrameLight = Color(0xFF3D4852); // Aquarium frame shell (light mode)
  static const Color aquariumFrameDark = Color(0xFF1E2A38);  // Aquarium frame shell (dark mode)
  static const Color aquariumScreenLight = Color(0xFFF0F4F8); // Aquarium screen glass (light mode)
  static const Color aquariumScreenDark = Color(0xFF243447);  // Aquarium screen glass (dark mode)
  static const Color windowFrameLight = Color(0xFFD4D0C8);  // Window widget frame/divider (light mode)
  static const Color windowPaneLight1 = Color(0xFFB8D4E3);  // Window pane top gradient (light mode)
  static const Color windowPaneLight2 = Color(0xFFD4E8F0);  // Window pane mid gradient (light mode)
  static const Color windowPaneDark1 = Color(0xFF2D3E50);   // Window pane top gradient (dark mode)
  static const Color windowPaneDark2 = Color(0xFF1A2634);   // Window pane bottom gradient (dark mode)
  static const Color windowPaneLight3 = Color(0xFFE8F4F8);  // Window bottom pane gradient light (lightest sky blue)

  // ── Filter media painter tones ───────────────────────────────────
  // Used in _FilterPainter (hobby_items.dart) for aquarium filter media visuals.
  static const Color filterFloss = Color(0xFFBDBDBD);      // Filter floss / wool stroke (light grey)
  static const Color filterCarbon = Color(0xFF424242);     // Activated carbon specks (near-black, shares algaeBlack)
  // LED panel tones — for aquarium light painter
  static const Color ledPanelDark = Color(0xFF4A5568);     // LED panel off-state (dark blue-grey)
  static const Color ledPanelOff = Color(0xFF718096);      // LED panel dot off-state (mid grey)
  static const Color ledYellow = Color(0xFFFFEB3B);        // LED light on-state — pure yellow (lerp target)

  // ── Water parameter test-tube indicator tones ───────────────────
  // Used in WaterTestWidget / hobby_items.dart to indicate parameter levels.
  // Ammonia scale
  static const Color paramAmmoniaNull = Color(0xFFE0E0E0);  // No reading — matches AppColors.border
  static const Color paramAmmoniaLow = Color(0xFFFFF59D);   // Ammonia < 0.25 ppm — safe (pale yellow)
  static const Color paramAmmoniaMid = Color(0xFF81C784);   // Ammonia 0.25–1.0 ppm — caution (matches algaeGreenLight)
  static const Color paramAmmoniaHigh = Color(0xFF43A047);  // Ammonia > 1.0 ppm — danger (matches algaeGreenBright)
  // Nitrite scale (purple — distinct from ammonia/nitrate)
  static const Color paramNitriteLow = Color(0xFFE1BEE7);   // Nitrite < 0.25 ppm — safe (pale purple)
  static const Color paramNitriteMid = Color(0xFFBA68C8);   // Nitrite 0.25–1.0 ppm — caution
  static const Color paramNitriteHigh = Color(0xFF8E24AA);  // Nitrite > 1.0 ppm — danger
  // Nitrate scale (orange — distinct from above)
  static const Color paramNitrateLow = Color(0xFFFFE0B2);   // Nitrate < 20 ppm — safe (pale orange)
  static const Color paramNitrateMid = Color(0xFFFFB74D);   // Nitrate 20–40 ppm — caution
  static const Color paramNitrateHigh = Color(0xFFFB8C00);  // Nitrate > 40 ppm — elevated

  // ── Substrate layer indicator tones ─────────────────────────────
  // Used in SubstrateGuideScreen to colour-code substrate depth layers.
  static const Color substrateSand = Color(0xFFA1887F);    // Sand / fine gravel cap layer (light brown)
  static const Color substrateAquasoil = Color(0xFF6D4C41); // Aquasoil / mid layer (dark brown)
  static const Color substrateSoil = Color(0xFF4E342E);    // Potting soil layer (very dark brown)
  static const Color substrateBase = Color(0xFF3E2723);    // Deep base substrate (darkest brown)

  // ── Shelf / wood bracket tones ───────────────────────────────────
  static const Color studyGold = Color(0xFFD4A574);        // Study-room warm gold (base for studyGoldAlpha*)
  static const Color shelfWoodLight = Color(0xFFC49A6C);   // Shelf wood gradient — lighter tone
  static const Color shelfWoodDark1 = Color(0xFF4A3728);   // Shelf bracket gradient — dark tone
  static const Color shelfWoodDark2 = Color(0xFF3D2E22);   // Shelf bracket gradient — darker tone

  // ── Shop Street room backgrounds ─────────────────────────────────
  static const Color shopStreetBackground1 = Color(0xFF4A7C59); // Forest green
  static const Color shopStreetBackground2 = Color(0xFF3D6B4A); // Darker green
  static const Color shopStreetBackground3 = Color(0xFF2F5A3B); // Deep green
  static const Color shopStreetBackground1Dark = Color(0xFF5A8E6A); // Lighter forest green (dark mode)
  static const Color shopStreetBackground2Dark = Color(0xFF4D7D5C); // Lighter mid green (dark mode)
  static const Color shopStreetBackground3Dark = Color(0xFF3F6C4D); // Lighter base green (dark mode)

  // ── Workshop room backgrounds ─────────────────────────────────────
  static const Color workshopBackground1 = Color(0xFF5D4E37); // Warm brown
  static const Color workshopBackground2 = Color(0xFF4A3F2E); // Darker brown
  static const Color workshopBackground3 = Color(0xFF3D3425); // Deep brown
  static const Color workshopBackground1Dark = Color(0xFF6E5F48); // Lighter warm brown (dark mode)
  static const Color workshopBackground2Dark = Color(0xFF5B5039); // Lighter mid brown (dark mode)
  static const Color workshopBackground3Dark = Color(0xFF4E4430); // Lighter base brown (dark mode)
  static const Color workshopAccentSteel = Color(0xFFA0AEC0); // Steel blue — tool card accent
  static const Color workshopMetal = Color(0xFF6B7280); // Steel gray — equipment card accent
  static const Color workshopTextSecondary = Color(0xFFB8B0A0); // Warm subdued text on dark brown bg

  // ── Gem Shop room backgrounds ────────────────────────────────────
  static const Color gemShopBackground1 = Color(0xFF1A1A2E); // Deep navy
  static const Color gemShopBackground2 = Color(0xFF16213E); // Dark blue
  static const Color gemShopBackground3 = Color(0xFF0F1A2E); // Darkest blue
  static const Color gemPrimary = Color(0xFF5FD9CF);          // Turquoise gem accent
  static const Color gemGlow = Color(0xFF95E1D3);             // Light turquoise glow
  static const Color gemPowerUp = Color(0xFFFF7B7B);          // Power-up red — decorative only

  // Gem Shop pre-computed alphas
  static const Color gemPrimary20 = Color(0x335FD9CF); // 20%
  static const Color gemPrimary30 = Color(0x4D5FD9CF); // 30%
  static const Color gemPrimary50 = Color(0x805FD9CF); // 50%
  static const Color gemGlow20 = Color(0x3395E1D3);    // 20%
  static const Color gemPowerUp80 = Color(0xCCFF7B7B); // 80%

  // ── Inventory room backgrounds ───────────────────────────────────
  static const Color inventoryBackground1 = Color(0xFF2D1B4E);     // Deep purple
  static const Color inventoryBackground2 = Color(0xFF1F1337);     // Darker purple
  static const Color inventoryBackground3 = Color(0xFF150D26);     // Deepest purple
  static const Color inventoryBackground1Dark = Color(0xFF3A2660); // Dark mode
  static const Color inventoryBackground2Dark = Color(0xFF2A1C48); // Dark mode
  static const Color inventoryBackground3Dark = Color(0xFF1E1435); // Dark mode
  static const Color inventoryConsumable = Color(0xFF4CAF50); // Green — decorative only
  static const Color inventoryActive = Color(0xFF2196F3);     // Blue — decorative only
  static const Color inventoryPermanent = Color(0xFFE91E63);  // Pink — decorative only
}

/// Text style tokens for the Danio app.
///
/// ## Font Roles
/// | Font | Use |
/// |------|-----|
/// | **Fredoka** | Display / headline — brand "wow" moments (≥ 20 px) |
/// | **Nunito** | UI chrome — titles, labels, body, navigation |
/// | **Nunito** (lesson) | Lesson content only — educational reading prose |
///
/// ## Usage
/// ```dart
/// Text('My Tank', style: AppTypography.headlineSmall)
/// Text('body copy', style: AppTypography.body)
/// Text(lessonText, style: AppTypography.lessonBody)
/// ```
///
/// Both `AppTypography.*` and `Theme.of(context).textTheme.*` return identical styles —
/// use whichever reads more clearly at the call site.
///
/// See also: `plans/typography-spec.md` for full font rationale.

class AppAchievementColors {
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color gold = Color(0xFFFFD700);
  static const Color platinum = Color(0xFFE5E4E2);
  static const Color diamond = Color(0xFFB9F2FF);

  /// Get color for tier name
  static Color forTier(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return bronze;
      case 'silver':
        return silver;
      case 'gold':
        return gold;
      case 'platinum':
        return platinum;
      case 'diamond':
        return diamond;
      default:
        return bronze;
    }
  }
}

/// Pre-computed semi-transparent overlay colours.
///
/// Use instead of `color.withOpacity()` — these are compile-time constants and
/// create **zero** object allocations at runtime.
///
/// Naming convention: `[colour][pct]` where pct is the opacity percentage.
///
/// ```dart
/// color: AppOverlays.black20      // black at 20% opacity
/// color: AppOverlays.primary10    // primary amber at 10%
/// color: AppOverlays.white50      // white at 50% — glass overlays
/// ```
///
/// See also: [AppColors] `*Alpha*` constants which follow the `[colour]Alpha[pct]` naming.

class AppOverlays {
  // White overlays
  static const Color white5 = Color(0x0DFFFFFF); // 5%
  static const Color white8 = Color(0x14FFFFFF); // 8%
  static const Color white10 = Color(0x1AFFFFFF); // 10%
  static const Color white12 = Color(0x1FFFFFFF); // 12%
  static const Color white15 = Color(0x26FFFFFF); // 15%
  static const Color white20 = Color(0x33FFFFFF); // 20%
  static const Color white25 = Color(0x40FFFFFF); // 25%
  static const Color white30 = Color(0x4DFFFFFF); // 30%
  static const Color white40 = Color(0x66FFFFFF); // 40%
  static const Color white50 = Color(0x80FFFFFF); // 50%
  static const Color white60 = Color(0x99FFFFFF); // 60%
  static const Color white70 = Color(0xB3FFFFFF); // 70%
  static const Color white80 = Color(0xCCFFFFFF); // 80%
  static const Color white88 = Color(0xE0FFFFFF); // 88%
  static const Color white90 = Color(0xE6FFFFFF); // 90%
  static const Color white95 = Color(0xF2FFFFFF); // 95%

  // Black overlays
  static const Color black5 = Color(0x0D000000); // 5%
  static const Color black8 = Color(0x14000000); // 8%
  static const Color black10 = Color(0x1A000000); // 10%
  static const Color black12 = Color(0x1F000000); // 12%
  static const Color black15 = Color(0x26000000); // 15%
  static const Color black20 = Color(0x33000000); // 20%
  static const Color black25 = Color(0x40000000); // 25%
  static const Color black30 = Color(0x4D000000); // 30%
  static const Color black40 = Color(0x66000000); // 40%
  static const Color black50 = Color(0x80000000); // 50%
  static const Color black60 = Color(0x99000000); // 60%
  static const Color black70 = Color(0xB3000000); // 70%
  static const Color black80 = Color(0xCC000000); // 80%
  static const Color black90 = Color(0xE6000000); // 90%

  // Primary color overlays (AppColors.primary = 0xFFB45309 - Amber)
  static const Color primary8 = Color(0x14B45309); // 8%
  static const Color primary10 = Color(0x1AB45309); // 10%
  static const Color primary15 = Color(0x26B45309); // 15%
  static const Color primary20 = Color(0x33B45309); // 20%
  static const Color primary30 = Color(0x4DB45309); // 30%
  static const Color primary50 = Color(0x80B45309); // 50%

  // Secondary color overlays (AppColors.secondary = 0xFF4A5A6B - Blue-Slate)
  static const Color secondary10 = Color(0x1A4A5A6B); // 10%
  static const Color secondary20 = Color(0x334A5A6B); // 20%
  static const Color secondary30 = Color(0x4D4A5A6B); // 30%
  static const Color secondary60 = Color(0x994A5A6B); // 60%
  static const Color secondary80 = Color(0xCC4A5A6B); // 80%

  // Surface variant overlays (AppColors.surfaceVariant = 0xFFFFF0DC)
  static const Color surfaceVariant30 = Color(0x4DFFF0DC); // 30%
  static const Color surfaceVariant50 = Color(0x80FFF0DC); // 50%
  static const Color surfaceVariant60 = Color(0x99FFF0DC); // 60%

  // Text hint overlays (AppColors.textHint = 0xFF5D6F76)
  static const Color textHint30 = Color(0x4D5D6F76); // 30%
  static const Color textHintAlpha40 = Color(0x665D6F76); // 40%
  static const Color textHint50 = Color(0x805D6F76); // 50%
  static const Color textHintAlpha80 = Color(0xCC5D6F76); // 80%

  // Custom color overlays for specific UI elements
  static const Color forestGreen50 = Color(0x80228B22); // Forest green 50%
  static const Color peru50 = Color(0x80CD853F); // Peru/tan 50%

  // Success color overlays (AppColors.success = 0xFF1E8449)
  static const Color success5 = Color(0x0D1E8449); // 5%
  static const Color success10 = Color(0x1A1E8449); // 10%
  static const Color success20 = Color(0x331E8449); // 20%

  // Error color overlays (AppColors.error = 0xFFC0392B)
  static const Color error5 = Color(0x0DC0392B); // 5%
  static const Color error10 = Color(0x1AC0392B); // 10%
  static const Color error15 = Color(0x26C0392B); // 15%
  static const Color error20 = Color(0x33C0392B); // 20%
  static const Color error30 = Color(0x4DC0392B); // 30%
  static const Color error50 = Color(0x80C0392B); // 50%

  // Accent color overlays (AppColors.accent = 0xFF5B9EA6 - Teal Water)
  static const Color accent5 = Color(0x0D5B9EA6); // 5%
  static const Color accent10 = Color(0x1A5B9EA6); // 10%
  static const Color accent20 = Color(0x335B9EA6); // 20%
  static const Color accent30 = Color(0x4D5B9EA6); // 30%
  static const Color accent80 = Color(0xCC5B9EA6); // 80%

  // Primary color additional overlays
  static const Color primary80 = Color(0xCCB45309); // 80%

  // Orange/warning overlays (for locked states etc.)
  static const Color orange10 = Color(0x1AFF9800); // 10%
  static const Color orange20 = Color(0x33FF9800); // 20%
  static const Color orange30 = Color(0x4DFF9800); // 30%

  // Blue overlays (AppColors.primary = 0xFF2196F3)
  static const Color blue10 = Color(0x1A2196F3); // 10%
  static const Color blue20 = Color(0x332196F3); // 20%

  // Info color overlays (AppColors.info = 0xFF2E86AB)
  static const Color info5 = Color(0x0D2E86AB); // 5%
  static const Color info10 = Color(0x1A2E86AB); // 10%
  static const Color info20 = Color(0x332E86AB); // 20%
  static const Color info30 = Color(0x4D2E86AB); // 30%

  // Primary color additional overlays (AppColors.primary = 0xFFB45309)
  static const Color primary5 = Color(0x0DB45309); // 5%

  // Warning color overlays (AppColors.warning = 0xFF8B6914)
  static const Color warning10 = Color(0x1A8B6914); // 10%
  static const Color warning30 = Color(0x4D8B6914); // 30%

  // Success additional overlays
  static const Color success30 = Color(0x4D1E8449); // 30%

  // Purple overlays (Colors.purple = 0xFF9C27B0)
  static const Color purple10 = Color(0x1A9C27B0); // 10%
  static const Color purple30 = Color(0x4D9C27B0); // 30%

  // Amber overlays (Colors.amber = 0xFFFFC107)
  static const Color amber20 = Color(0x33FFC107); // 20%
  static const Color amber30 = Color(0x4DFFC107); // 30%

  // Orange overlays (Colors.orange = 0xFFFF9800) - extended
  static const Color orange40 = Color(0x66FF9800); // 40%
  static const Color orange50 = Color(0x80FF9800); // 50%
  static const Color orange70 = Color(0xB3FF9800); // 70%
  static const Color orange90 = Color(0xE6FF9800); // 90%

  // Grey overlays (Colors.grey = 0xFF9E9E9E)
  static const Color grey10 = Color(0x1A9E9E9E); // 10%
  static const Color grey20 = Color(0x339E9E9E); // 20%
  static const Color grey30 = Color(0x4D9E9E9E); // 30%

  // Brown overlays (Colors.brown = 0xFF795548)
  static const Color brown20 = Color(0x33795548); // 20%
  static const Color brown30 = Color(0x4D795548); // 30%

  // Red overlays (Colors.red = 0xFFF44336)
  static const Color red20 = Color(0x33F44336); // 20%
  static const Color red50 = Color(0x80F44336); // 50%

  // Green overlays (Colors.green = 0xFF4CAF50)
  static const Color green10 = Color(0x1A4CAF50); // 10%
  static const Color green20 = Color(0x334CAF50); // 20%
  static const Color green90 = Color(0xE64CAF50); // 90%

  // Cyan overlays (Colors.cyan = 0xFF00BCD4)
  static const Color cyan15 = Color(0x2600BCD4); // 15%
  static const Color cyan20 = Color(0x3300BCD4); // 20%

  // Light Blue overlays (Colors.lightBlue = 0xFF03A9F4)
  static const Color lightBlue15 = Color(0x2603A9F4); // 15%
  static const Color lightBlue20 = Color(0x3303A9F4); // 20%

  // Golden Yellow overlays (0xFFFFD54F - study room warm light)
  static const Color goldenYellow08 = Color(0x14FFD54F); // 8%
  static const Color goldenYellow35 = Color(0x59FFD54F); // 35%
  static const Color goldenYellow80 = Color(0xCCFFD54F); // 80%

  // Orange Yellow overlays (0xFFFFB74D - study room accent)
  static const Color orangeYellow15 = Color(0x26FFB74D); // 15%

  // Sky Blue overlays (0xFF87CEEB - already partially defined as cozyBlue)
  static const Color skyBlue05 = Color(0x0D87CEEB); // 5%
  static const Color skyBlue20 = Color(0x3387CEEB); // 20%

  // Teal Green overlays (0xFF5FBFB3 - cozy room aqua accent)
  static const Color tealGreen20 = Color(0x335FBFB3); // 20%

  // Desk wood tones (hobby desk gradients)
  static const Color burlyWood30 = Color(0x4DDEB887); // 30% - 0xFFDEB887
  static const Color tan40 = Color(0x66D2B48C); // 40% - 0xFFD2B48C
  static const Color darkGold50 = Color(0x80C4A574); // 50% - 0xFFC4A574
  static const Color darkWood30 = Color(0x4D8B7355); // 30% - 0xFF8B7355
  static const Color darkWood60 = Color(0x998B7355); // 60% - 0xFF8B7355
  static const Color deepWood80 = Color(0xCC6B5344); // 80% - 0xFF6B5344
  static const Color copperBrown70 = Color(0xB3B87333); // 70% - 0xFFB87333

  // Nature greens and browns (cozy room plants/furniture)
  static const Color forestGreen08 = Color(0x143D6B4A); // 8% - 0xFF3D6B4A
  static const Color darkBrown10 = Color(0x1A5D4E37); // 10% - 0xFF5D4E37

  // Book colors (subtle for shelves)
  static const Color bookRed12 = Color(0x1F8B3A3A); // 12% - 0xFF8B3A3A
  static const Color bookBlue12 = Color(0x1F3A5A8B); // 12% - 0xFF3A5A8B
  static const Color bookGreen12 = Color(0x1F3A6B4A); // 12% - 0xFF3A6B4A

  // Soft neutrals (decorative accents)
  static const Color lightGrey80 = Color(0xCCE8E8F0); // 80% - 0xFFE8E8F0
  static const Color cream15 = Color(0x26FFF8E7); // 15% - 0xFFFFF8E7
  static const Color lightBlueGrey80 = Color(0xCCE8F4F8); // 80% - 0xFFE8F4F8
  static const Color lightBlueGrey90 = Color(0xE6E8F4F8); // 90% - 0xFFE8F4F8
}

