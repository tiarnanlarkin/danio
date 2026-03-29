import 'package:flutter/material.dart';
import '../screens/achievements_screen.dart';
import '../screens/debug_menu_screen.dart';
import '../screens/gem_shop_screen.dart';
import '../screens/smart_screen.dart';
import '../screens/spaced_repetition_practice_screen.dart';
import '../screens/workshop_screen.dart';
import '../utils/navigation_throttle.dart';

/// Centralised route registry.
///
/// Instead of scattering `Navigator.of(context).push(MaterialPageRoute(...))`
/// across every widget, callers use strongly-typed helpers here.
///
/// **Migration status:** 37 inline routes remain in the codebase.  This class
/// covers the most-common navigations as a starting point.  Migrate additional
/// routes here over time — one PR per feature area to keep diffs reviewable.
///
/// Usage:
/// ```dart
/// AppRoutes.toAchievements(context);
/// AppRoutes.toGemShop(context);
/// ```
class AppRoutes {
  AppRoutes._(); // no instances

  // ── Primary destinations ─────────────────────────────────────────────────

  /// Navigate to the Achievements screen.
  static void toAchievements(BuildContext context) {
    NavigationThrottle.push(context, const AchievementsScreen());
  }

  /// Navigate to the Gem Shop screen.
  static void toGemShop(BuildContext context) {
    NavigationThrottle.push(context, const GemShopScreen());
  }

  /// Navigate to the Workshop screen.
  static void toWorkshop(BuildContext context) {
    NavigationThrottle.push(context, const WorkshopScreen());
  }

  /// Navigate to the Smart screen (AI features).
  static void toSmartTools(BuildContext context) {
    NavigationThrottle.push(context, const SmartScreen());
  }

  /// Navigate to the Spaced Repetition practice screen.
  static void toSpacedRepetition(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SpacedRepetitionPracticeScreen(),
      ),
    );
  }

  // ── Debug / internal ─────────────────────────────────────────────────────

  /// Navigate to the Debug Menu screen.
  ///
  /// Should only be called in debug builds.
  static void toDebugMenu(BuildContext context) {
    assert(() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const DebugMenuScreen()),
      );
      return true;
    }(), 'toDebugMenu must only be called in debug mode');
  }
}
