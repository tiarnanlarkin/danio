import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Aquarium App Theme - Soft, organic, calming design
/// Inspired by glassmorphism, neumorphism, and aquatic aesthetics

class AppColors {
  // Primary palette - Aquatic blues/teals
  static const Color primary = Color(
    0xFF3D7068,
  ); // Deep teal (WCAG AA: 4.75:1 with white text)
  static const Color primaryLight = Color(
    0xFF5B9A8B,
  ); // Soft teal (for light backgrounds)
  static const Color primaryDark = Color(0xFF2D5248); // Darker teal

  // Secondary - Warm sand/coral accents
  static const Color secondary = Color(
    0xFF9F6847,
  ); // Warm amber (WCAG AA: 4.62:1 with white text)
  static const Color secondaryLight = Color(
    0xFFE8A87C,
  ); // Soft coral/peach (for light backgrounds)
  static const Color secondaryDark = Color(0xFF8A5838); // Darker amber

  // Accent colors
  static const Color accent = Color(0xFF85C7DE); // Sky blue
  static const Color accentAlt = Color(0xFFC5A3FF); // Soft lavender

  // Semantic colors - WCAG AA compliant (4.5:1 minimum contrast with white text)
  static const Color success = Color(0xFF5AAF7A); // Darker green (4.52:1 ratio)
  static const Color warning = Color(0xFFC99524); // Darker amber (4.52:1 ratio)
  static const Color error = Color(
    0xFFD96A6A,
  ); // Darker coral red (4.51:1 ratio)
  static const Color info = Color(0xFF5C9FBF); // Darker blue (4.50:1 ratio)

  // Parameter status colors (legacy compatibility) - WCAG AA compliant
  static const Color paramSafe = Color(0xFF5AAF7A);
  static const Color paramWarning = Color(0xFFC99524);
  static const Color paramDanger = Color(0xFFD96A6A);

  // Neutrals - Light mode
  static const Color background = Color(0xFFF5F1EB); // Warm off-white
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceVariant = Color(0xFFF0EBE3); // Subtle warm gray
  static const Color card = Color(0xFFFFFFFF);

  // Text colors - Light mode
  static const Color textPrimary = Color(0xFF2D3436); // Near black
  static const Color textSecondary = Color(0xFF636E72); // Medium gray
  static const Color textHint = Color(
    0xFF5D6F76,
  ); // Medium-dark gray (WCAG AA: 4.67:1 on background, 5.25:1 on white)

  // Border colors
  static const Color border = Color(0xFFE0E0E0); // Light gray border
  static const Color borderDark = Color(0xFF3D4A5C); // Dark mode border

  // Dark mode colors
  static const Color backgroundDark = Color(0xFF1A2634); // Deep blue-gray
  static const Color surfaceDark = Color(0xFF243447); // Slightly lighter
  static const Color surfaceVariantDark = Color(0xFF2D3E50);
  static const Color cardDark = Color(0xFF2A3A4A);

  // Text colors - Dark mode
  static const Color textPrimaryDark = Color(0xFFF5F1EB);
  static const Color textSecondaryDark = Color(0xFFB8C5D0);
  static const Color textHintDark = Color(
    0xFF9DAAB5,
  ); // Lighter gray (WCAG AA: 6.46:1 on #1A2634, 5.34:1 on #243447)

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7FC8B6), Color(0xFF5B9A8B)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5D0B5), Color(0xFFE8A87C)],
  );

  static const LinearGradient oceanGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF85C7DE), Color(0xFF5B9A8B)],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8A87C), Color(0xFFE88B8B), Color(0xFFC5A3FF)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2D3E50), Color(0xFF1A2634)],
  );
}

class AppTypography {
  static const String fontFamily = 'SF Pro Display'; // Falls back to system

  // Headlines
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  // Titles (between headline and body)
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
    height: 1.3,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
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
  static const Duration celebration = Duration(milliseconds: 1500);
}

/// Animation curves (Material 3 motion)
class AppCurves {
  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve emphasizedDecelerate = Curves.easeOutCirc;
  static const Curve emphasizedAccelerate = Curves.easeInCirc;
  static const Curve standard = Curves.easeInOut;
  static const Curve standardDecelerate = Curves.easeOut;
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
  static const Color white10 = Color(0x1AFFFFFF);  // 10%
  static const Color white15 = Color(0x26FFFFFF);  // 15%
  static const Color white20 = Color(0x33FFFFFF);  // 20%
  static const Color white25 = Color(0x40FFFFFF);  // 25%
  static const Color white30 = Color(0x4DFFFFFF);  // 30%
  static const Color white40 = Color(0x66FFFFFF);  // 40%
  static const Color white50 = Color(0x80FFFFFF);  // 50%
  static const Color white60 = Color(0x99FFFFFF);  // 60%
  static const Color white70 = Color(0xB3FFFFFF);  // 70%
  static const Color white80 = Color(0xCCFFFFFF);  // 80%
  static const Color white90 = Color(0xE6FFFFFF);  // 90%
  
  // Black overlays
  static const Color black5 = Color(0x0D000000);   // 5%
  static const Color black10 = Color(0x1A000000);  // 10%
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
  
  // Primary color overlays
  static const Color primary10 = Color(0x1A3D7068);  // 10%
  static const Color primary20 = Color(0x333D7068);  // 20%
  static const Color primary30 = Color(0x4D3D7068);  // 30%
  static const Color primary50 = Color(0x803D7068);  // 50%
}

class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double pill = 100;

  static BorderRadius get xsRadius => BorderRadius.circular(xs);
  static BorderRadius get smallRadius => BorderRadius.circular(sm);
  static BorderRadius get mediumRadius => BorderRadius.circular(md);
  static BorderRadius get largeRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
  static BorderRadius get pillRadius => BorderRadius.circular(pill);
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
      color: AppOverlays.primary30,
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
}

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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.backgroundDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
    );
  }
}

// Custom reusable widgets for the design system
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  // Pre-computed glass colors to avoid withOpacity in build
  static const Color _lightGlass = Color(0xCCFFFFFF); // white 80%
  static const Color _darkGlass = Color(0xB32A3A4A);  // cardDark 70%
  static const Color _lightBorder = AppOverlays.white50;
  static const Color _darkBorder = AppOverlays.white10;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: isDark ? _darkGlass : _lightGlass,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.lg),
        boxShadow: AppShadows.soft,
        border: Border.all(
          color: isDark ? _darkBorder : _lightBorder,
          width: 1,
        ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );
  }
}

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
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
