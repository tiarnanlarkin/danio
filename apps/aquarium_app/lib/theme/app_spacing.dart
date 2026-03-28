import 'package:flutter/material.dart';

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

/// Material Design 3 touch target size constants.
///
/// The minimum interactive element height/width is **48dp**. Use [adaptive] to
/// choose between [small], [medium], and [large] based on screen width.
///
/// ```dart
/// SizedBox(height: AppTouchTargets.minimum)       // 48dp hard floor
/// SizedBox(height: AppTouchTargets.adaptive(context)) // adaptive
/// ```
class AppTouchTargets {
  // Minimum touch target size (Material Design 3)
  static const double minimum = 48.0;

  // Standard touch target sizes
  static const double small = 48.0; // Compact devices minimum
  static const double medium = 56.0; // Default for most buttons
  static const double large = 64.0; // Tablet/important actions

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

/// Pre-built [EdgeInsets] to pad small interactive elements up to the 48dp minimum touch target.
///
/// ```dart
/// // Wrap a 24dp icon to get a 48dp touch target
/// Padding(padding: AppTouchPadding.for24Icon, child: Icon(Icons.close, size: 24))
/// ```
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

/// Animation duration constants (Material 3 aligned).
///
/// ```dart
/// AnimatedContainer(duration: AppDurations.medium4)  // 300ms — standard transition
/// AnimatedOpacity(duration: AppDurations.short)       // 100ms — quick fade
/// ```
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

/// Animation curve constants (Material 3 motion system).
///
/// Use [emphasized] for most transitions (easeOutCubic), [elastic] for playful
/// bounce moments, and [bounce] for celebratory animations.
///
/// ```dart
/// CurvedAnimation(parent: animation, curve: AppCurves.emphasized)
/// ```
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

/// Standard icon size constants.
///
/// ```dart
/// Icon(Icons.water, size: AppIconSizes.md)  // 24dp — standard
/// Icon(Icons.close, size: AppIconSizes.sm)  // 20dp — compact
/// ```
class AppIconSizes {
  static const double xs = 16.0;
  static const double sm = 20.0;
  static const double md = 24.0;
  static const double lg = 32.0;
  static const double xl = 48.0;
  static const double xxl = 64.0;
}

/// Achievement tier colour constants (Bronze → Diamond).
///
/// ```dart
/// Icon(Icons.star, color: AppAchievementColors.gold)
/// Icon(Icons.star, color: AppAchievementColors.forTier('platinum'))
/// ```
