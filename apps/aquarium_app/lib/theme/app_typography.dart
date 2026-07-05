import 'package:flutter/material.dart';

class AppTypography {
  static const String fontFamily = 'Nunito'; // Base font family
  static const String displayFontFamily = 'Fredoka';

  // Headlines (Fredoka)
  static TextStyle get headlineLarge => const TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.2,
  );

  static TextStyle get headlineMedium => const TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );

  static TextStyle get headlineSmall => const TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );

  // Titles (Fredoka for large, Nunito for medium/small)
  static TextStyle get titleLarge => const TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );

  static TextStyle get titleMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.3,
  );

  static TextStyle get titleSmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // Body text (Nunito)
  static TextStyle get bodyLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get bodySmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // Labels (Nunito)
  static TextStyle get labelLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
  );

  static TextStyle get labelMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static TextStyle get labelSmall => const TextStyle(
    fontFamily: fontFamily,
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
  static TextStyle get overline => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    height: 1.4,
  );

  // ──────────────────────────────────────────────────────────────────
  // Lesson / educational content aliases — Nunito (was Lora, R-089)
  // Use these for lesson cards, fact panels, and reading-weight prose.
  // Hephaestus will apply these at the correct call sites in Wave 4.
  // ──────────────────────────────────────────────────────────────────
  static TextStyle get lessonBody => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static TextStyle get lessonBodyLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static TextStyle get lessonQuote => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 1.6,
  );
}

/// Spacing scale for layout — padding, gaps, margins.
///
/// All values are in logical pixels (dp).
///
/// ```dart
/// SizedBox(height: AppSpacing.md)         // 16dp
/// EdgeInsets.all(AppSpacing.lg)           // 24dp
/// EdgeInsets.symmetric(horizontal: AppSpacing.xl) // 32dp
/// ```
///
/// Scale: `hairline(1) → xxs(2) → xs(4) → xs2(6) → sm(8) → sm3(10) → sm2(12) →
/// sm4(14) → md(16) → lg2(20) → lg(24) → xl(32) → xl2(40) → xxl(48) → xxxl(64)`
