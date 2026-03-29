import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

export 'app_colors.dart';
export 'app_spacing.dart';
export 'app_typography.dart';
export 'app_radius.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';
import 'app_radius.dart';

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
      reverseCurve: Curves.easeOutCubic,
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

/// Entry point for the Danio [ThemeData].
///
/// Apply in your [MaterialApp]:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
///   themeMode: ThemeMode.system,
///   scrollBehavior: const DanioScrollBehavior(),
/// )
/// ```
///
/// Both themes share the same [_textTheme] (Fredoka + Nunito) and the same
/// page transition builder. Dark mode applies warm-charcoal backgrounds rather
/// than the cold blue-grey typical of Material defaults.
class AppTheme {
  /// Unified type scale — single source of truth.
  ///
  /// Font roles:
  ///   Fredoka  → display / headline / titleLarge: playful brand moments, screen titles
  ///   Nunito   → titleMedium down through labelSmall: UI chrome, body text, navigation
  ///
  /// Nunito (lesson aliases) is NOT in the Material TextTheme because 300+ call sites use
  /// textTheme for UI chrome. Lesson styles are exposed via AppTypography.lesson* aliases.
  /// See plans/typography-spec.md for full rationale. (Lora removed R-089)
  static TextTheme get _textTheme => TextTheme(
    // ── Display (Fredoka — hero/splash, largest impact text) ──────
    displayLarge: GoogleFonts.fredoka(fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.2),
    displayMedium: GoogleFonts.fredoka(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.2),
    displaySmall: GoogleFonts.fredoka(fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.3, height: 1.25),

    // ── Headline (Fredoka — section headings, card titles) ────────
    headlineLarge: GoogleFonts.fredoka(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.2),
    headlineMedium: GoogleFonts.fredoka(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.3, height: 1.3),
    headlineSmall: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.2, height: 1.3),

    // ── Title (Fredoka large, Nunito medium/small) ────────────────
    titleLarge: GoogleFonts.fredoka(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.2, height: 1.3),
    titleMedium: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.1, height: 1.3),
    titleSmall: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0, height: 1.3),

    // ── Body (Nunito — readable, friendly UI prose) ───────────────
    bodyLarge: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w400, height: 1.5),
    bodyMedium: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w400, height: 1.5),
    bodySmall: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w400, height: 1.4),

    // ── Label (Nunito — buttons, chips, navigation) ───────────────
    labelLarge: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.1),
    labelMedium: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.1),
    labelSmall: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2),
  );

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
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: AppSpacing.sm4,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: AppSpacing.sm4,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: AppSpacing.sm4,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: AppSpacing.sm3,
          ),
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

      // Text theme — Nunito + Fredoka pairing
      textTheme: _textTheme,
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
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: AppSpacing.sm4,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.backgroundDark,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: AppSpacing.sm4,
          ),
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
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.largeRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.largeRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
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

      // Text theme — Nunito + Fredoka pairing (dark mode colours applied)
      textTheme: _textTheme.apply(
        bodyColor: AppColors.textPrimaryDark,
        displayColor: AppColors.textPrimaryDark,
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
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: AppSpacing.sm3,
          ),
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
          (cardColor.r * 255.0).round().clamp(0, 255),
          (cardColor.g * 255.0).round().clamp(0, 255),
          (cardColor.b * 255.0).round().clamp(0, 255),
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

/// Custom [ScrollBehavior] that removes Android's glow/stretch overscroll effect
/// and enforces clamping physics for a clean, cross-platform feel.
///
/// Pass to [MaterialApp.scrollBehavior]:
/// ```dart
/// MaterialApp(scrollBehavior: const DanioScrollBehavior(), ...)
/// ```
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

/// [BuildContext] extension that resolves theme-aware colours without manual
/// `Theme.of(context).brightness` checks.
///
/// ```dart
/// color: context.textPrimary        // light or dark text colour, automatically resolved
/// color: context.backgroundColor    // scaffold background for current brightness
/// color: context.primaryColor       // primary (bright in light, light in dark)
/// ```
extension AdaptiveColors on BuildContext {
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;
  Color get textPrimary =>
      _isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
  Color get textSecondary =>
      _isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
  Color get textHint => _isDark ? AppColors.textHintDark : AppColors.textHint;
  Color get backgroundColor =>
      _isDark ? AppColors.backgroundDark : AppColors.background;
  Color get surfaceColor => _isDark ? AppColors.surfaceDark : AppColors.surface;
  Color get surfaceVariant =>
      _isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant;
  Color get cardColor => _isDark ? AppColors.cardDark : AppColors.card;
  Color get primaryColor =>
      _isDark ? AppColors.primaryLight : AppColors.primary;
  Color get borderColor => _isDark ? AppColors.borderDark : AppColors.border;
}
