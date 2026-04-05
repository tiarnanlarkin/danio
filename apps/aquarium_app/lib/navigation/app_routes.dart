import 'package:flutter/material.dart';
import '../features/smart/fish_id/fish_id_screen.dart';
import '../features/smart/symptom_triage/symptom_triage_screen.dart';
import '../features/smart/weekly_plan/weekly_plan_screen.dart';
import '../models/models.dart';
import '../screens/achievements_screen.dart';
import '../screens/add_log_screen.dart';
import '../screens/create_tank_screen.dart';
import '../screens/debug_menu_screen.dart';
import '../screens/gem_shop_screen.dart';
import '../screens/lesson_screen.dart';
import '../screens/smart_screen.dart';
import '../screens/spaced_repetition_practice_screen.dart';
import '../screens/story/story_browser_screen.dart';
import '../screens/story/story_play_screen.dart';
import '../screens/tank_detail/tank_detail_screen.dart';
import '../screens/workshop_screen.dart';
import '../utils/app_page_routes.dart';
import '../utils/navigation_throttle.dart';

/// Centralised route registry.
///
/// Instead of scattering `Navigator.of(context).push(MaterialPageRoute(...))`
/// across every widget, callers use strongly-typed helpers here.
///
/// **Migration status:** ~20 inline routes remain in the codebase.  This class
/// covers the highest-impact navigations.  Migrate additional routes here over
/// time — one PR per feature area to keep diffs reviewable.
///
/// Usage:
/// ```dart
/// AppRoutes.toAchievements(context);
/// AppRoutes.toGemShop(context);
/// AppRoutes.toAddLog(context, tankId);
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
    NavigationThrottle.push(context, const SpacedRepetitionPracticeScreen());
  }

  // ── Tank management ──────────────────────────────────────────────────────

  /// Navigate to the Add Log screen.
  ///
  /// [initialType] defaults to [LogType.waterTest] if not specified.
  static void toAddLog(
    BuildContext context,
    String tankId, {
    LogType initialType = LogType.waterTest,
  }) {
    NavigationThrottle.push(
      context,
      AddLogScreen(tankId: tankId, initialType: initialType),
    );
  }

  /// Navigate to the Tank Detail screen with the hero-enabled transition.
  static void toTankDetail(BuildContext context, String tankId) {
    final page = TankDetailScreen(tankId: tankId);
    NavigationThrottle.push(
      context,
      page,
      route: TankDetailRoute(page: page),
    );
  }

  /// Navigate to the Create Tank screen.
  static void toCreateTank(BuildContext context) {
    NavigationThrottle.push(context, const CreateTankScreen());
  }

  // ── Smart / AI features ──────────────────────────────────────────────────

  /// Navigate to the Symptom Triage screen.
  static void toSymptomTriage(BuildContext context) {
    NavigationThrottle.push(context, const SymptomTriageScreen());
  }

  /// Navigate to the Fish ID screen.
  static void toFishId(BuildContext context) {
    NavigationThrottle.push(context, const FishIdScreen());
  }

  /// Navigate to the Weekly Plan screen.
  static void toWeeklyPlan(BuildContext context) {
    NavigationThrottle.push(context, const WeeklyPlanScreen());
  }

  // ── Stories & lessons ────────────────────────────────────────────────────

  /// Navigate to the Story Browser screen.
  static void toStoryBrowser(BuildContext context) {
    NavigationThrottle.push(context, const StoryBrowserScreen());
  }

  /// Navigate to a specific story's play screen.
  static void toStoryPlay(BuildContext context, Story story) {
    NavigationThrottle.push(context, StoryPlayScreen(story: story));
  }

  /// Replace the current route with the next lesson (used in lesson
  /// completion flows). Uses [Navigator.pushReplacement] directly since
  /// NavigationThrottle does not have a pushReplacement variant.
  static void toLessonReplacement(
    BuildContext context,
    Lesson lesson,
    String pathTitle,
  ) {
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LessonScreen(lesson: lesson, pathTitle: pathTitle),
      ),
    );
  }

  // ── Debug / internal ─────────────────────────────────────────────────────

  /// Navigate to the Debug Menu screen.
  ///
  /// Should only be called in debug builds.
  static void toDebugMenu(BuildContext context) {
    assert(() {
      NavigationThrottle.push(context, const DebugMenuScreen());
      return true;
    }(), 'toDebugMenu must only be called in debug mode');
  }
}
