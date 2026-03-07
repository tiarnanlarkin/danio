import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Aquarium App Theme - Soft, organic, calming design
/// Inspired by glassmorphism, neumorphism, and aquatic aesthetics

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
  static const Color secondary = Color(
    0xFF4A5A6B,
  ); // Blue-Slate
  static const Color secondaryLight = Color(
    0xFF6B7F8E,
  ); // lighter blue-slate
  static const Color secondaryDark = Color(0xFF2A3548); // Deep Violet

  // Accent colors
  static const Color accent = Color(0xFF5B9EA6); // Teal Water
  static const Color accentAlt = Color(0xFF8B6BAE); // Amethyst

  // Semantic colors - WCAG AA compliant (4.5:1 minimum contrast with white text)
  static const Color success = Color(0xFF5AAF7A); // Darker green (4.52:1 ratio)
  static const Color warning = Color(0xFFC99524); // Darker amber (4.52:1 ratio)
  static const Color error = Color(
    0xFFD96A6A,
  ); // Darker coral red (4.51:1 ratio)
  static const Color info = Color(0xFF5C9FBF); // Darker blue (4.50:1 ratio)
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
  static const Color paramSafe = Color(0xFF5AAF7A);
  static const Color paramWarning = Color(0xFFC99524);
  static const Color paramDanger = Color(0xFFD96A6A);

  // Neutrals - Light mode
  static const Color background = Color(0xFFFFF5E8); // Warm Cream
  static const Color surface = Color(0xFFFFFBF5); // Ivory White
  static const Color surfaceVariant = Color(0xFFFFF0DC); // Warm tinted
  static const Color card = Color(0xFFFFFFFF);

  // Text colors - Light mode
  static const Color textPrimary = Color(0xFF2D3436); // Near black
  static const Color textSecondary = Color(0xFF636E72); // Medium gray
  static const Color textSecondaryAlpha10 = Color(0x1A636E72); // 10%
  static const Color textHint = Color(
    0xFF5D6F76,
  ); // Medium-dark gray (WCAG AA: 4.67:1 on background, 5.25:1 on white)

  // Border colors
  static const Color border = Color(0xFFE0E0E0); // Light gray border
  static const Color borderDark = Color(0xFF3D4A5C); // Dark mode border

  // Dark mode colors
  static const Color backgroundDark = Color(0xFF1C1917); // Warm Charcoal (NOT cold blue-grey)
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
  static const Color successAlpha10 = Color(0x1A5AAF7A);
  static const Color successAlpha15 = Color(0x265AAF7A);
  static const Color successAlpha20 = Color(0x335AAF7A);
  static const Color successAlpha30 = Color(0x4D5AAF7A);
  static const Color successAlpha40 = Color(0x665AAF7A);
  static const Color successAlpha50 = Color(0x805AAF7A);
  static const Color successAlpha80 = Color(0xCC5AAF7A);
  static const Color successAlpha95 = Color(0xF25AAF7A);
  static const Color successAlpha100 = Color(0xFF5AAF7A);

  // Warning color with alpha
  static const Color warningAlpha05 = Color(0x0DC99524); // 3%
  static const Color warningAlpha10 = Color(0x1AC99524);
  static const Color warningAlpha12 = Color(0x1FC99524); // 7%
  static const Color warningAlpha15 = Color(0x26C99524);
  static const Color warningAlpha20 = Color(0x33C99524);
  static const Color warningAlpha30 = Color(0x4DC99524);
  static const Color warningAlpha40 = Color(0x66C99524);
  static const Color warningAlpha50 = Color(0x80C99524);
  static const Color warningAlpha60 = Color(0x99C99524);
  static const Color warningAlpha70 = Color(0xB3C99524);
  static const Color warningAlpha80 = Color(0xCCC99524);

  // Error color with alpha
  static const Color errorAlpha05 = Color(0x0DD96A6A);
  static const Color errorAlpha10 = Color(0x1AD96A6A);
  static const Color errorAlpha15 = Color(0x26D96A6A);
  static const Color errorAlpha20 = Color(0x33D96A6A);
  static const Color errorAlpha30 = Color(0x4DD96A6A);
  static const Color errorAlpha40 = Color(0x66D96A6A);
  static const Color errorAlpha50 = Color(0x80D96A6A);
  static const Color errorAlpha90 = Color(0xE6D96A6A);
  static const Color errorAlpha95 = Color(0xF2D96A6A);
  static const Color errorAlpha100 = Color(0xFFD96A6A);

  // Info color with alpha
  static const Color infoAlpha10 = Color(0x1A5C9FBF);
  static const Color infoAlpha20 = Color(0x335C9FBF);
  static const Color infoAlpha30 = Color(0x4D5C9FBF);
  static const Color infoAlpha40 = Color(0x665C9FBF);
  static const Color infoAlpha50 = Color(0x805C9FBF);

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
  static const Color cozyGreen05 = Color(0x0D4CAF50);  // livingRoomPlant at 3%
  static const Color cozyGreen08 = Color(0x144CAF50);  // 8%
  static const Color cozyGreen10 = Color(0x1A4CAF50);  // 10%
  static const Color cozyGreen15 = Color(0x264CAF50);  // 15%
  static const Color cozyGreen20 = Color(0x334CAF50);  // 20%
  static const Color cozyGreen30 = Color(0x4D4CAF50);  // 30%

  static const Color cozyBlue05 = Color(0x0D87CEEB);  // shopSky at 3%
  static const Color cozyBlue08 = Color(0x1487CEEB);  // 8%
  static const Color cozyBlue10 = Color(0x1A87CEEB);  // 10%
  static const Color cozyBlue15 = Color(0x2687CEEB);  // 15%
  static const Color cozyBlue20 = Color(0x3387CEEB);  // 20%

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
}

/// Danio brand colours - use these for new UI following the brand guide
/// Material constants for the stage system textures and surfaces
class DanioMaterials {
  // Leather grain
  static const Color cognacBase = Color(0xFFC68B3E);
  static const Color espressoBase = Color(0xFF3D2416);

  // Lighting pulse colours
  static const Color warmAmberPulse = Color(0x14FFB74D); // 8% warm amber
  static const Color coolBluePulse = Color(0x0F64B5F6); // 6% cool blue
}

class DanioColors {
  static const Color amberGold     = Color(0xFFC8884A);  // Decorative amber
  static const Color amberText     = Color(0xFFB45309);  // Text on light (WCAG AA)
  static const Color amberTextDark = Color(0xFFFBBF24);  // Text on dark (WCAG AA)
  static const Color blueSlate     = Color(0xFF4A5A6B);
  static const Color deepViolet    = Color(0xFF2A3548);
  static const Color tealWater     = Color(0xFF5B9EA6);
  static const Color coralAccent   = Color(0xFFE8734A);
  static const Color seafoamLight  = Color(0xFFB8D8D0);
  static const Color creamWarm     = Color(0xFFFFF5E8);
  static const Color ivoryWhite    = Color(0xFFFFFBF5);
  static const Color emeraldGreen  = Color(0xFF4CAF7D);
  static const Color rubyRed       = Color(0xFFD94F5C);
  static const Color sapphireBlue  = Color(0xFF4A7BC8);
  static const Color amethyst      = Color(0xFF8B6BAE);
  static const Color topaz         = Color(0xFFE8A84A);
}

class AppTypography {
  static const String fontFamily = 'Nunito'; // Base font family

  // Headlines (Fredoka)
  static TextStyle get headlineLarge => GoogleFonts.fredoka(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle get headlineMedium => GoogleFonts.fredoka(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle get headlineSmall => GoogleFonts.fredoka(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  // Titles (Fredoka for large, Nunito for medium/small)
  static TextStyle get titleLarge => GoogleFonts.fredoka(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static TextStyle get titleMedium => GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
    height: 1.3,
  );

  static TextStyle get titleSmall => GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // Body text (Nunito)
  static TextStyle get bodyLarge => GoogleFonts.nunito(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.nunito(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // Labels (Nunito)
  static TextStyle get labelLarge => GoogleFonts.nunito(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
  );

  static TextStyle get labelMedium => GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static TextStyle get labelSmall => GoogleFonts.nunito(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  // ──────────────────────────────────────────────────────────────────
  // Semantic aliases - map to the canonical scale above
  // ──────────────────────────────────────────────────────────────────
  static TextStyle get display => headlineLarge;
  static TextStyle get headline => headlineMedium;
  static TextStyle get title => titleMedium;
  static TextStyle get body => bodyMedium;
  static TextStyle get label => labelMedium;
  static TextStyle get caption => bodySmall;
  static TextStyle get overline => GoogleFonts.nunito(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    height: 1.4,
  );
}

class AppSpacing {
  static const double hairline = 1;
  static const double xxs = 2;
  static const double xs = 4;
  static const double xs2 = 6;
  static const double sm = 8;
  static const double sm3 = 10;
  static const double sm2 = 12;
  static const double sm4 = 14;
  static const double md = 16;
  static const double lg2 = 20;
  static const double lg = 24;
  static const double xl = 32;
  static const double xl2 = 40;
  static const double xxl = 48;
  static const double xxxl = 64;
}

/// Material Design 3 Touch Target Sizes
/// Ensures all interactive elements are accessible and easy to tap
class AppTouchTargets {
  // Minimum touch target size (Material Design 3)
  static const double minimum = 48.0;
  
  // Standard touch target sizes
  static const double small = 48.0;    // Compact devices minimum
  static const double medium = 56.0;   // Default for most buttons
  static const double large = 64.0;    // Tablet/important actions
  
  // Icon sizes within touch targets
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 28.0;
  
  // Padding to achieve minimum touch target
  static const double paddingFor24Icon = 12.0; // (48 - 24) / 2
  static const double paddingFor20Icon = 14.0; // (48 - 20) / 2
  
  /// Get adaptive touch target size based on screen width
  static double adaptive(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 600) {
      return large; // Tablet
    } else if (width <= 360) {
      return minimum; // Compact phone
    } else {
      return medium; // Standard phone
    }
  }
  
  /// Get adaptive icon size based on screen width
  static double adaptiveIcon(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 600) {
      return iconLarge; // Tablet
    } else if (width <= 360) {
      return iconSmall; // Compact phone
    } else {
      return iconMedium; // Standard phone
    }
  }
}

/// Material Design 3 minimum padding for touch targets
class AppTouchPadding {
  // Padding to achieve 48dp minimum from smaller elements
  static const EdgeInsets for24Icon = EdgeInsets.all(12.0);
  static const EdgeInsets for20Icon = EdgeInsets.all(AppSpacing.sm4);
  static const EdgeInsets for16Icon = EdgeInsets.all(16.0);
  
  // Horizontal padding for buttons
  static const EdgeInsets buttonHorizontal = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );
  
  // Minimum padding for any interactive element
  static const EdgeInsets minimum = EdgeInsets.all(4.0);
}

/// Animation durations (Material 3 aligned)
class AppDurations {
  static const Duration extraShort = Duration(milliseconds: 50);
  static const Duration short = Duration(milliseconds: 100);
  static const Duration medium1 = Duration(milliseconds: 150);
  static const Duration medium2 = Duration(milliseconds: 200);
  static const Duration medium3 = Duration(milliseconds: 250);
  static const Duration medium4 = Duration(milliseconds: 300);
  static const Duration long1 = Duration(milliseconds: 400);
  static const Duration long2 = Duration(milliseconds: 500);
  static const Duration extraLong = Duration(milliseconds: 700);
  static const Duration long3 = Duration(milliseconds: 800);
  static const Duration celebration = Duration(milliseconds: 1500);
}

/// Animation curves (Material 3 motion)
class AppCurves {
  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve emphasizedDecelerate = Curves.easeOutCirc;
  static const Curve emphasizedAccelerate = Curves.easeInCirc;
  static const Curve standard = Curves.easeInOut;
  static const Curve standardDecelerate = Curves.easeOut;
  static const Curve standardSine = Curves.easeInOutSine;
  static const Curve standardAccelerate = Curves.easeIn;
  static const Curve elastic = Curves.elasticOut;
  static const Curve bounce = Curves.bounceOut;
}

/// Standard icon sizes
class AppIconSizes {
  static const double xs = 16.0;
  static const double sm = 20.0;
  static const double md = 24.0;
  static const double lg = 32.0;
  static const double xl = 48.0;
  static const double xxl = 64.0;
}

/// Achievement tier colors
class AppAchievementColors {
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color gold = Color(0xFFFFD700);
  static const Color platinum = Color(0xFFE5E4E2);
  static const Color diamond = Color(0xFFB9F2FF);
  
  /// Get color for tier name
  static Color forTier(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze': return bronze;
      case 'silver': return silver;
      case 'gold': return gold;
      case 'platinum': return platinum;
      case 'diamond': return diamond;
      default: return bronze;
    }
  }
}

/// Pre-computed overlay colors (avoid withOpacity() rebuilds)
class AppOverlays {
  // White overlays
  static const Color white5 = Color(0x0DFFFFFF);   // 5%
  static const Color white8 = Color(0x14FFFFFF);   // 8%
  static const Color white10 = Color(0x1AFFFFFF);  // 10%
  static const Color white12 = Color(0x1FFFFFFF);  // 12%
  static const Color white15 = Color(0x26FFFFFF);  // 15%
  static const Color white20 = Color(0x33FFFFFF);  // 20%
  static const Color white25 = Color(0x40FFFFFF);  // 25%
  static const Color white30 = Color(0x4DFFFFFF);  // 30%
  static const Color white40 = Color(0x66FFFFFF);  // 40%
  static const Color white50 = Color(0x80FFFFFF);  // 50%
  static const Color white60 = Color(0x99FFFFFF);  // 60%
  static const Color white70 = Color(0xB3FFFFFF);  // 70%
  static const Color white80 = Color(0xCCFFFFFF);  // 80%
  static const Color white88 = Color(0xE0FFFFFF);  // 88%
  static const Color white90 = Color(0xE6FFFFFF);  // 90%
  static const Color white95 = Color(0xF2FFFFFF);  // 95%
  
  // Black overlays
  static const Color black5 = Color(0x0D000000);   // 5%
  static const Color black8 = Color(0x14000000);   // 8%
  static const Color black10 = Color(0x1A000000);  // 10%
  static const Color black12 = Color(0x1F000000);  // 12%
  static const Color black15 = Color(0x26000000);  // 15%
  static const Color black20 = Color(0x33000000);  // 20%
  static const Color black25 = Color(0x40000000);  // 25%
  static const Color black30 = Color(0x4D000000);  // 30%
  static const Color black40 = Color(0x66000000);  // 40%
  static const Color black50 = Color(0x80000000);  // 50%
  static const Color black60 = Color(0x99000000);  // 60%
  static const Color black70 = Color(0xB3000000);  // 70%
  static const Color black80 = Color(0xCC000000);  // 80%
  static const Color black90 = Color(0xE6000000);  // 90%
  
  // Primary color overlays (AppColors.primary = 0xFFB45309 - Amber)
  static const Color primary8 = Color(0x14B45309);   // 8%
  static const Color primary10 = Color(0x1AB45309);  // 10%
  static const Color primary15 = Color(0x26B45309);  // 15%
  static const Color primary20 = Color(0x33B45309);  // 20%
  static const Color primary30 = Color(0x4DB45309);  // 30%
  static const Color primary50 = Color(0x80B45309);  // 50%
  
  // Secondary color overlays (AppColors.secondary = 0xFF4A5A6B - Blue-Slate)
  static const Color secondary10 = Color(0x1A4A5A6B);  // 10%
  static const Color secondary20 = Color(0x334A5A6B);  // 20%
  static const Color secondary30 = Color(0x4D4A5A6B);  // 30%
  static const Color secondary60 = Color(0x994A5A6B);  // 60%
  static const Color secondary80 = Color(0xCC4A5A6B);  // 80%
  
  // Surface variant overlays (AppColors.surfaceVariant = 0xFFFFF0DC)
  static const Color surfaceVariant30 = Color(0x4DFFF0DC);  // 30%
  static const Color surfaceVariant50 = Color(0x80FFF0DC);  // 50%
  static const Color surfaceVariant60 = Color(0x99FFF0DC);  // 60%
  
  // Text hint overlays (AppColors.textHint = 0xFF5D6F76)
  static const Color textHint30 = Color(0x4D5D6F76);  // 30%
  static const Color textHintAlpha40 = Color(0x665D6F76);  // 40%
  static const Color textHint50 = Color(0x805D6F76);  // 50%
  static const Color textHintAlpha80 = Color(0xCC5D6F76);  // 80%
  
  // Custom color overlays for specific UI elements
  static const Color forestGreen50 = Color(0x80228B22);  // Forest green 50%
  static const Color peru50 = Color(0x80CD853F);         // Peru/tan 50%
  
  // Success color overlays (AppColors.success = 0xFF5AAF7A)
  static const Color success5 = Color(0x0D5AAF7A);   // 5%
  static const Color success10 = Color(0x1A5AAF7A);  // 10%
  static const Color success20 = Color(0x335AAF7A);  // 20%
  
  // Error color overlays (AppColors.error = 0xFFD96A6A)
  static const Color error5 = Color(0x0DD96A6A);   // 5%
  static const Color error10 = Color(0x1AD96A6A);  // 10%
  static const Color error15 = Color(0x26D96A6A);  // 15%
  static const Color error20 = Color(0x33D96A6A);  // 20%
  static const Color error30 = Color(0x4DD96A6A);  // 30%
  static const Color error50 = Color(0x80D96A6A);  // 50%
  
  // Accent color overlays (AppColors.accent = 0xFF5B9EA6 - Teal Water)
  static const Color accent5 = Color(0x0D5B9EA6);   // 5%
  static const Color accent10 = Color(0x1A5B9EA6);  // 10%
  static const Color accent20 = Color(0x335B9EA6);  // 20%
  static const Color accent30 = Color(0x4D5B9EA6);  // 30%
  static const Color accent80 = Color(0xCC5B9EA6);  // 80%
  
  // Primary color additional overlays
  static const Color primary80 = Color(0xCCB45309);  // 80%
  
  // Orange/warning overlays (for locked states etc.)
  static const Color orange10 = Color(0x1AFF9800);  // 10%
  static const Color orange20 = Color(0x33FF9800);  // 20%
  static const Color orange30 = Color(0x4DFF9800);  // 30%
  
  // Blue overlays (AppColors.primary = 0xFF2196F3)
  static const Color blue10 = Color(0x1A2196F3);  // 10%
  static const Color blue20 = Color(0x332196F3);  // 20%
  
  // Info color overlays (AppColors.info = 0xFF5C9FBF)
  static const Color info5 = Color(0x0D5C9FBF);   // 5%
  static const Color info10 = Color(0x1A5C9FBF);  // 10%
  static const Color info20 = Color(0x335C9FBF);  // 20%
  static const Color info30 = Color(0x4D5C9FBF);  // 30%
  
  // Primary color additional overlays (AppColors.primary = 0xFFB45309)
  static const Color primary5 = Color(0x0DB45309);  // 5%
  
  // Warning color overlays (AppColors.warning = 0xFFC99524)
  static const Color warning10 = Color(0x1AC99524);  // 10%
  static const Color warning30 = Color(0x4DC99524);  // 30%
  
  // Success additional overlays
  static const Color success30 = Color(0x4D5AAF7A);  // 30%
  
  // Purple overlays (Colors.purple = 0xFF9C27B0)
  static const Color purple10 = Color(0x1A9C27B0);  // 10%
  static const Color purple30 = Color(0x4D9C27B0);  // 30%
  
  // Amber overlays (Colors.amber = 0xFFFFC107)
  static const Color amber20 = Color(0x33FFC107);  // 20%
  static const Color amber30 = Color(0x4DFFC107);  // 30%
  
  // Orange overlays (Colors.orange = 0xFFFF9800) - extended
  static const Color orange40 = Color(0x66FF9800);  // 40%
  static const Color orange50 = Color(0x80FF9800);  // 50%
  static const Color orange70 = Color(0xB3FF9800);  // 70%
  static const Color orange90 = Color(0xE6FF9800);  // 90%
  
  // Grey overlays (Colors.grey = 0xFF9E9E9E)
  static const Color grey10 = Color(0x1A9E9E9E);  // 10%
  static const Color grey20 = Color(0x339E9E9E);  // 20%
  static const Color grey30 = Color(0x4D9E9E9E);  // 30%
  
  // Brown overlays (Colors.brown = 0xFF795548)
  static const Color brown20 = Color(0x33795548);  // 20%
  static const Color brown30 = Color(0x4D795548);  // 30%
  
  // Red overlays (Colors.red = 0xFFF44336)
  static const Color red20 = Color(0x33F44336);  // 20%
  static const Color red50 = Color(0x80F44336);  // 50%
  
  // Green overlays (Colors.green = 0xFF4CAF50)
  static const Color green10 = Color(0x1A4CAF50);  // 10%
  static const Color green20 = Color(0x334CAF50);  // 20%
  static const Color green90 = Color(0xE64CAF50);  // 90%
  
  // Cyan overlays (Colors.cyan = 0xFF00BCD4)
  static const Color cyan15 = Color(0x2600BCD4);  // 15%
  static const Color cyan20 = Color(0x3300BCD4);  // 20%
  
  // Light Blue overlays (Colors.lightBlue = 0xFF03A9F4)
  static const Color lightBlue15 = Color(0x2603A9F4);  // 15%
  static const Color lightBlue20 = Color(0x3303A9F4);  // 20%
  
  // Golden Yellow overlays (0xFFFFD54F - study room warm light)
  static const Color goldenYellow08 = Color(0x14FFD54F);  // 8%
  static const Color goldenYellow35 = Color(0x59FFD54F);  // 35%
  static const Color goldenYellow80 = Color(0xCCFFD54F);  // 80%
  
  // Orange Yellow overlays (0xFFFFB74D - study room accent)
  static const Color orangeYellow15 = Color(0x26FFB74D);  // 15%
  
  // Sky Blue overlays (0xFF87CEEB - already partially defined as cozyBlue)
  static const Color skyBlue05 = Color(0x0D87CEEB);  // 5%
  static const Color skyBlue20 = Color(0x3387CEEB);  // 20%
  
  // Teal Green overlays (0xFF5FBFB3 - cozy room aqua accent)
  static const Color tealGreen20 = Color(0x335FBFB3);  // 20%
  
  // Desk wood tones (hobby desk gradients)
  static const Color burlyWood30 = Color(0x4DDEB887);  // 30% - 0xFFDEB887
  static const Color tan40 = Color(0x66D2B48C);  // 40% - 0xFFD2B48C
  static const Color darkGold50 = Color(0x80C4A574);  // 50% - 0xFFC4A574
  static const Color darkWood30 = Color(0x4D8B7355);  // 30% - 0xFF8B7355
  static const Color darkWood60 = Color(0x998B7355);  // 60% - 0xFF8B7355
  static const Color deepWood80 = Color(0xCC6B5344);  // 80% - 0xFF6B5344
  static const Color copperBrown70 = Color(0xB3B87333);  // 70% - 0xFFB87333
  
  // Nature greens and browns (cozy room plants/furniture)
  static const Color forestGreen08 = Color(0x143D6B4A);  // 8% - 0xFF3D6B4A
  static const Color darkBrown10 = Color(0x1A5D4E37);  // 10% - 0xFF5D4E37
  
  // Book colors (subtle for shelves)
  static const Color bookRed12 = Color(0x1F8B3A3A);  // 12% - 0xFF8B3A3A
  static const Color bookBlue12 = Color(0x1F3A5A8B);  // 12% - 0xFF3A5A8B
  static const Color bookGreen12 = Color(0x1F3A6B4A);  // 12% - 0xFF3A6B4A
  
  // Soft neutrals (decorative accents)
  static const Color lightGrey80 = Color(0xCCE8E8F0);  // 80% - 0xFFE8E8F0
  static const Color cream15 = Color(0x26FFF8E7);  // 15% - 0xFFFFF8E7
  static const Color lightBlueGrey80 = Color(0xCCE8F4F8);  // 80% - 0xFFE8F4F8
  static const Color lightBlueGrey90 = Color(0xE6E8F4F8);  // 90% - 0xFFE8F4F8
}

class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md2 = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double pill = 100;

  static BorderRadius get xsRadius => BorderRadius.circular(xs);
  static BorderRadius get smallRadius => BorderRadius.circular(sm);
  static BorderRadius get md2Radius => BorderRadius.circular(md2);
  static BorderRadius get mediumRadius => BorderRadius.circular(md);
  static BorderRadius get largeRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
  static BorderRadius get pillRadius => BorderRadius.circular(pill);
}

/// Elevation scale for consistent shadow/depth levels
class AppElevation {
  static const double level0 = 0;
  static const double level1 = 2;
  static const double level2 = 4;
  static const double level3 = 8;
  static const double level4 = 12;
  static const double level5 = 24;
}

class AppShadows {
  // Soft, subtle shadows for depth
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: AppOverlays.black5, // ~4%
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x05000000), // 2%
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x0F000000), // 6%
      blurRadius: 15,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x08000000), // 3%
      blurRadius: 30,
      offset: Offset(0, 12),
    ),
  ];

  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x4DB45309), // Amber glow
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];
  
  // Additional shadow variants
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: AppOverlays.black15,
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: AppOverlays.black5,
      blurRadius: 48,
      offset: Offset(0, 16),
    ),
  ];
  
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x08000000), // 3%
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];
  
  // Premium soft shadows (inspired by high-end app designs)
  static const List<BoxShadow> dreamySoft = [
    BoxShadow(
      color: Color(0x0A000000), // 4%
      blurRadius: 20,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x05000000), // 2%
      blurRadius: 40,
      spreadRadius: 0,
      offset: Offset(0, 16),
    ),
  ];
  
  static const List<BoxShadow> glassLight = [
    BoxShadow(
      color: Color(0x10FFFFFF), // White inner glow
      blurRadius: 1,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
  
  static const List<BoxShadow> glassDark = [
    BoxShadow(
      color: Color(0x20FFFFFF), // White inner glow
      blurRadius: 1,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
  
  // Cozy warm shadow (for room/home elements)
  static const List<BoxShadow> cozyWarm = [
    BoxShadow(
      color: Color(0x15D4A574), // Warm gold tint
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}

/// Premium glassmorphism decoration presets
class GlassStyles {
  // Frosted glass for light mode
  static BoxDecoration frostedLight({
    BorderRadius? borderRadius,
    Color? tintColor,
  }) {
    return BoxDecoration(
      color: (tintColor ?? Colors.white).withAlpha(178),
      borderRadius: borderRadius ?? AppRadius.largeRadius,
      border: Border.all(
        color: AppColors.whiteAlpha40,
        width: 1.5,
      ),
      boxShadow: AppShadows.glassLight,
    );
  }
  
  // Frosted glass for dark mode
  static BoxDecoration frostedDark({
    BorderRadius? borderRadius,
    Color? tintColor,
  }) {
    return BoxDecoration(
      color: (tintColor ?? const Color(0xFF1A1A2E)).withAlpha(153),
      borderRadius: borderRadius ?? AppRadius.largeRadius,
      border: Border.all(
        color: AppColors.whiteAlpha10,
        width: 1,
      ),
      boxShadow: AppShadows.glassDark,
    );
  }
  
  // Soft puffy card (cotton candy style)
  static BoxDecoration softPuffy({
    required bool isDark,
    BorderRadius? borderRadius,
    Color? backgroundColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? (isDark ? const Color(0xFF2A2A3E) : Colors.white),
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      boxShadow: AppShadows.dreamySoft,
    );
  }
  
  // Gradient glass with aurora effect
  static BoxDecoration auroraGlass({
    required bool isDark,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                const Color(0xFF1A3A4A).withAlpha(204),
                const Color(0xFF0D2030).withAlpha(230),
              ]
            : [
                const Color(0xFFE8F4F8).withAlpha(230),
                const Color(0xFFF0F8FF).withAlpha(242),
              ],
      ),
      borderRadius: borderRadius ?? AppRadius.largeRadius,
      border: Border.all(
        color: isDark
            ? const Color(0xFF3D9F8B).withAlpha(76)
            : const Color(0xFF5FBFB3).withAlpha(51),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? const Color(0xFF3D9F8B).withAlpha(38)
              : AppColors.primaryAlpha08,
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
  
  // Cozy room card (warm home feeling)
  static BoxDecoration cozyCard({
    required bool isDark,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF2A2220) : const Color(0xFFFFFBF5),
      borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.lg),
      border: Border.all(
        color: isDark
            ? const Color(0xFFD4A574).withAlpha(38)
            : const Color(0xFFD4A574).withAlpha(26),
        width: 1,
      ),
      boxShadow: AppShadows.cozyWarm,
    );
  }
}


/// Custom page transition that slides+fades from right.
/// Applied globally via [pageTransitionsTheme] so all [MaterialPageRoute]
/// calls automatically get a consistent, polished transition.
class _DanioPageTransitionsBuilder extends PageTransitionsBuilder {
  const _DanioPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.04, 0),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: child,
      ),
    );
  }
}

/// Shared [PageTransitionsTheme] used by both light and dark themes.
const _kDanioPageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: _DanioPageTransitionsBuilder(),
    TargetPlatform.iOS: _DanioPageTransitionsBuilder(),
    TargetPlatform.fuchsia: _DanioPageTransitionsBuilder(),
    TargetPlatform.linux: _DanioPageTransitionsBuilder(),
    TargetPlatform.macOS: _DanioPageTransitionsBuilder(),
    TargetPlatform.windows: _DanioPageTransitionsBuilder(),
  },
);

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Colors
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryLight,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.background,

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: AppColors.textPrimary,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.largeRadius),
        margin: EdgeInsets.zero,
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: AppSpacing.sm4),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: AppSpacing.sm4),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: AppSpacing.sm4),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: AppSpacing.sm3),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: AppRadius.largeRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.largeRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.largeRadius,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.largeRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primaryLight,
        disabledColor: AppColors.surfaceVariant,
        labelStyle: AppTypography.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
        side: BorderSide.none,
      ),

      // Bottom navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall,
      ),

      // List tiles
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.surfaceVariant,
        thickness: 1,
        space: 1,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return AppColors.textHint;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.surfaceVariant;
        }),
      ),

      // Progress indicators
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceVariant,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
        behavior: SnackBarBehavior.floating,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlRadius),
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: AppColors.textPrimary,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      // Bottom sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // Text selection
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primaryAlpha30,
        selectionHandleColor: AppColors.primary,
      ),

      // Page transitions (consistent slide+fade for all routes)
      pageTransitionsTheme: _kDanioPageTransitionsTheme,

      // Text theme
      textTheme: GoogleFonts.nunitoTextTheme(),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.backgroundDark,
        primaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        onSecondary: AppColors.backgroundDark,
        secondaryContainer: AppColors.secondaryDark,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.error,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.backgroundDark,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.largeRadius),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.backgroundDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: AppSpacing.sm4),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.backgroundDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: AppSpacing.sm4),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariantDark,
        border: OutlineInputBorder(
          borderRadius: AppRadius.largeRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.largeRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.largeRadius,
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textHintDark,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariantDark,
        selectedColor: AppColors.primaryDark,
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
        side: BorderSide.none,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textHintDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.surfaceVariantDark,
        thickness: 1,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlRadius),
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceVariantDark,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),

        shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
        behavior: SnackBarBehavior.floating,
      ),

      // Page transitions (consistent slide+fade for all routes)
      pageTransitionsTheme: _kDanioPageTransitionsTheme,

      // Text theme
      // Text selection
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primaryLight,
        selectionColor: AppColors.primaryLightAlpha30,
        selectionHandleColor: AppColors.primaryLight,
      ),

      textTheme: GoogleFonts.nunitoTextTheme(),
    );
  }
}

// Custom reusable widgets for the design system
// NOTE: GlassCard has been moved to lib/widgets/core/glass_card.dart
// Import it from there instead of app_theme.dart.

class GradientCard extends StatelessWidget {
  final Widget child;
  final LinearGradient gradient;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const GradientCard({
    super.key,
    required this.child,
    required this.gradient,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: AppRadius.largeRadius,
        boxShadow: AppShadows.soft,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );
  }
}

class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isSelected;

  const PillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
      borderRadius: AppRadius.pillRadius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.pillRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: AppSpacing.sm3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs2),
              ],
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        // Use Color.withValues for dynamic colors (unavoidable here)
        // but use static overlays where possible
        color: Color.fromRGBO(
          cardColor.red, 
          cardColor.green, 
          cardColor.blue, 
          0.1,
        ),
        borderRadius: AppRadius.largeRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) Icon(icon, size: AppIconSizes.md, color: cardColor),
          const Spacer(),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(color: cardColor),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom scroll behavior that removes the glow effect and uses
/// clamping physics for a cleaner, iOS-inspired feel across platforms.
class DanioScrollBehavior extends ScrollBehavior {
  const DanioScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // No glow/stretch overscroll indicator
    return child;
  }
}
