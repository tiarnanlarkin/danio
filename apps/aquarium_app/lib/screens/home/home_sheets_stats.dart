import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/tank_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gamification_dashboard.dart';
import '../../widgets/streak_calendar.dart';
import '../../widgets/daily_goal_progress.dart';
import '../../utils/app_page_routes.dart';
import '../../utils/navigation_throttle.dart';
import 'widgets/xp_source_row.dart';
import 'home_sheets_helpers.dart' show timeAgo, showItemSheet;
import '../../widgets/hobby_desk.dart' show ItemDetailRow;
/// Tank stats overview bottom sheet.
void showStatsInfo(BuildContext context, WidgetRef ref, String? tankId) {
  if (tankId == null) return;

  final logsAsync = ref.read(logsProvider(tankId));
  final logs = logsAsync.valueOrNull ?? [];

  final waterTests = logs
      .where((l) => l.type == LogType.waterTest && l.waterTest != null)
      .toList();
  final latestTest = waterTests.isNotEmpty ? waterTests.first : null;
  final temp = latestTest?.waterTest?.temperature;

  final feedings = logs.where((l) => l.type == LogType.feeding).toList();
  final latestFeeding = feedings.isNotEmpty ? feedings.first : null;

  final waterChanges = logs.where((l) => l.type == LogType.waterChange).toList();
  final latestChange = waterChanges.isNotEmpty ? waterChanges.first : null;

  showItemSheet(
    context,
    title: 'Tank Stats',
    icon: Icons.auto_graph,
    color: DanioColors.amethyst,
    rows: [
      ItemDetailRow(
        label: 'Temperature',
        value: temp != null ? '${temp.toStringAsFixed(1)} °C' : 'Not recorded yet',
      ),
      ItemDetailRow(
        label: 'Last fed',
        value: latestFeeding != null ? timeAgo(latestFeeding.timestamp) : 'Not logged yet',
      ),
      ItemDetailRow(
        label: 'Water change',
        value: latestChange != null ? timeAgo(latestChange.timestamp) : 'Log your first change!',
      ),
    ],
  );
}

/// Detailed stats/progress bottom sheet with gamification dashboard.
void showStatsDetails(BuildContext context, WidgetRef ref) {
  final screenContext = context;
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg2),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: AppRadius.largeRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.insights, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm2),
              Semantics(
                header: true,
                child: Text('Your Progress', style: AppTypography.headlineSmall),
              ),
              const Spacer(),
              Semantics(
                label: 'Close progress',
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg2),
          const GamificationDashboard(showAsCard: false),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    showDailyGoalDetails(screenContext);
                  },
                  icon: const Icon(Icons.flag),
                  label: const Text('Daily Goal'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    showStreakCalendar(screenContext);
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Calendar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg2),
        ],
      ),
    ),
  );
}

/// Daily goal details bottom sheet with XP breakdown.
void showDailyGoalDetails(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg2),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: AppRadius.largeRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.flag, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm2),
              Semantics(
                header: true,
                child: Text('Daily Goal', style: AppTypography.headlineSmall),
              ),
              const Spacer(),
              Semantics(
                label: 'Close daily goal',
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg2),
          const DailyGoalProgress(size: 120),
          const SizedBox(height: AppSpacing.lg2),
          Text('Ways to earn XP:', style: AppTypography.labelLarge),
          const SizedBox(height: AppSpacing.sm2),
          XpSourceRow(icon: Icons.school, label: 'Complete lesson', xp: 50),
          XpSourceRow(icon: Icons.quiz, label: 'Pass quiz', xp: 25),
          XpSourceRow(icon: Icons.science, label: 'Log water test', xp: 10),
          XpSourceRow(icon: Icons.water_drop, label: 'Water change', xp: 10),
          XpSourceRow(icon: Icons.task_alt, label: 'Complete task', xp: 15),
          const SizedBox(height: AppSpacing.lg2),
        ],
      ),
    ),
  );
}

/// Navigate to streak calendar screen.
void showStreakCalendar(BuildContext context) {
  NavigationThrottle.push(
    context,
    const StreakCalendarScreen(),
    route: RoomSlideRoute(page: const StreakCalendarScreen()),
  );
}
