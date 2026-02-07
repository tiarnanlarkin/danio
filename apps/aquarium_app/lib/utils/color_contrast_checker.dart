// Color contrast checker for WCAG AA compliance
// Ensures all text meets minimum 4.5:1 contrast ratio
// Ensures large text and UI components meet 3:1 ratio

import 'package:flutter/material.dart';
import 'dart:math' as math;

class ColorContrastChecker {
  /// Calculate relative luminance of a color
  /// Formula from WCAG 2.1: https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
  static double _relativeLuminance(Color color) {
    final r = _adjustColorChannel(color.red / 255.0);
    final g = _adjustColorChannel(color.green / 255.0);
    final b = _adjustColorChannel(color.blue / 255.0);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _adjustColorChannel(double channel) {
    return channel <= 0.03928
        ? channel / 12.92
        : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  /// Calculate contrast ratio between two colors
  /// Returns a value between 1:1 and 21:1
  static double contrastRatio(Color foreground, Color background) {
    final l1 = _relativeLuminance(foreground);
    final l2 = _relativeLuminance(background);
    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if color combination meets WCAG AA standard for normal text (4.5:1)
  static bool meetsAA(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 4.5;
  }

  /// Check if color combination meets WCAG AA standard for large text (3:1)
  static bool meetsAALarge(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 3.0;
  }

  /// Check if color combination meets WCAG AAA standard (7:1)
  static bool meetsAAA(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 7.0;
  }

  /// Suggest a darker or lighter version of a color to meet contrast requirements
  static Color suggestContrastingColor(
    Color original,
    Color background, {
    double targetRatio = 4.5,
    bool preferDarker = true,
  }) {
    if (contrastRatio(original, background) >= targetRatio) {
      return original;
    }

    // Try adjusting brightness
    final hsl = HSLColor.fromColor(original);
    
    if (preferDarker) {
      // Darken the color
      for (double lightness = hsl.lightness; lightness >= 0.0; lightness -= 0.05) {
        final adjusted = hsl.withLightness(lightness).toColor();
        if (contrastRatio(adjusted, background) >= targetRatio) {
          return adjusted;
        }
      }
    } else {
      // Lighten the color
      for (double lightness = hsl.lightness; lightness <= 1.0; lightness += 0.05) {
        final adjusted = hsl.withLightness(lightness).toColor();
        if (contrastRatio(adjusted, background) >= targetRatio) {
          return adjusted;
        }
      }
    }

    // Fallback: return black or white based on background luminance
    final bgLuminance = _relativeLuminance(background);
    return bgLuminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Generate a contrast report for debugging
  static String generateReport(Color foreground, Color background) {
    final ratio = contrastRatio(foreground, background);
    final aa = meetsAA(foreground, background);
    final aaLarge = meetsAALarge(foreground, background);
    final aaa = meetsAAA(foreground, background);

    return '''
Contrast Ratio: ${ratio.toStringAsFixed(2)}:1
WCAG AA (normal text): ${aa ? '✅ PASS' : '❌ FAIL'}
WCAG AA (large text): ${aaLarge ? '✅ PASS' : '❌ FAIL'}
WCAG AAA: ${aaa ? '✅ PASS' : '❌ FAIL'}
Foreground: ${foreground.toString()}
Background: ${background.toString()}
''';
  }
}

/// Extension to make contrast checking easier
extension ColorContrastExtension on Color {
  /// Check contrast ratio with another color
  double contrastWith(Color other) {
    return ColorContrastChecker.contrastRatio(this, other);
  }

  /// Check if this color meets AA standard on given background
  bool isAccessibleOn(Color background) {
    return ColorContrastChecker.meetsAA(this, background);
  }

  /// Get a version of this color that meets AA standard on given background
  Color ensureAccessibleOn(Color background, {bool preferDarker = true}) {
    return ColorContrastChecker.suggestContrastingColor(
      this,
      background,
      preferDarker: preferDarker,
    );
  }
}
