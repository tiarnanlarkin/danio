import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/tank_provider.dart';
import '../../providers/storage_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/room_theme_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/room_themes.dart';
import '../../utils/app_page_routes.dart';
import '../../utils/navigation_throttle.dart';
import '../add_log_screen.dart';
import '../analytics_screen.dart';
import '../journal_screen.dart';
import '../reminders_screen.dart';
import '../search_screen.dart';
import '../../widgets/daily_goal_progress.dart';
import '../../widgets/streak_calendar.dart';
import '../../widgets/gamification_dashboard.dart';
import '../../widgets/hobby_desk.dart';
import 'widgets/xp_source_row.dart';

/// Helper to format a DateTime as a friendly relative string.
String timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${dt.day}/${dt.month}/${dt.year}';
}

/// A parameter row for info sheets.
Widget buildParamRow(BuildContext context, String label, String value, String ideal) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(child: Text(label, style: AppTypography.bodyMedium)),
        Text(value, style: AppTypography.labelLarge),
        if (ideal.isNotEmpty) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            '(ideal: $ideal)',
            style: AppTypography.bodySmall.copyWith(color: context.textHint),
          ),
        ],
      ],
    ),
  );
}

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

void showWaterParams(BuildContext context, WidgetRef ref, String? tankId) {
  if (tankId == null) return;

  final logsAsync = ref.read(logsProvider(tankId));
  final logs = logsAsync.valueOrNull ?? [];

  final waterTests = logs
      .where((l) => l.type == LogType.waterTest && l.waterTest != null)
      .toList();
  final latestTest = waterTests.isNotEmpty ? waterTests.first : null;
  final wt = latestTest?.waterTest;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const Text('\u{1F9EA}', style: TextStyle(fontSize: 40)),
                const SizedBox(height: AppSpacing.sm),
                Semantics(
                  header: true,
                  child: Text('Water Parameters', style: AppTypography.headlineSmall),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm2),
            decoration: BoxDecoration(
              color: AppColors.accent.withAlpha(20),
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: AppColors.accent.withAlpha(60)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u{2705} Ideal Ranges (Freshwater)',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'pH 6.5-7.5  |  Ammonia 0 ppm  |  Nitrite 0 ppm  |  Nitrate <40 ppm',
                  style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (wt == null || !wt.hasValues) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Column(
                  children: [
                    Text('No test results yet 🧪', style: AppTypography.bodyMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Log your first water test to see results here!',
                      style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            buildParamRow(context, 'pH', wt.ph?.toStringAsFixed(1) ?? '--', '6.5 - 7.5'),
            buildParamRow(context, 'Ammonia', wt.ammonia != null ? '${wt.ammonia!.toStringAsFixed(2)} ppm' : '--', '0 ppm'),
            buildParamRow(context, 'Nitrite', wt.nitrite != null ? '${wt.nitrite!.toStringAsFixed(2)} ppm' : '--', '0 ppm'),
            buildParamRow(context, 'Nitrate', wt.nitrate != null ? '${wt.nitrate!.toStringAsFixed(1)} ppm' : '--', '<40 ppm'),
            const Divider(height: AppSpacing.lg),
            Text(
              'Last tested: ${timeAgo(latestTest!.timestamp)}',
              style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            '\u{1F41F} What this means for your fish',
            style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Stable water parameters are the single most important factor in fish health. Test weekly and after any changes to your tank.',
            style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                NavigationThrottle.push(
                  context,
                  AddLogScreen(tankId: tankId, initialType: LogType.waterTest),
                  route: RoomSlideRoute(page: AddLogScreen(tankId: tankId, initialType: LogType.waterTest)),
                );
              },
              icon: const Icon(Icons.science, size: 18),
              label: const Text('Log Water Test'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    ),
  );
}

void showFeedingInfo(BuildContext context, WidgetRef ref, String? tankId) {
  if (tankId == null) return;

  final logsAsync = ref.read(logsProvider(tankId));
  final logs = logsAsync.valueOrNull ?? [];

  final feedings = logs.where((l) => l.type == LogType.feeding).toList();
  final latestFeeding = feedings.isNotEmpty ? feedings.first : null;

  final today = DateTime.now();
  final feedingsToday = feedings
      .where((l) =>
          l.timestamp.year == today.year &&
          l.timestamp.month == today.month &&
          l.timestamp.day == today.day)
      .length;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const Text('\u{1F3A3}', style: TextStyle(fontSize: 40)),
                const SizedBox(height: AppSpacing.sm),
                Semantics(
                  header: true,
                  child: Text('Feeding', style: AppTypography.headlineSmall),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm2),
            decoration: BoxDecoration(
              color: AppColors.secondary.withAlpha(20),
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: AppColors.secondary.withAlpha(60)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u{1F4CB} Feeding Guidelines',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Feed 2-3 times daily  |  Only what they eat in 2 min  |  Variety is key',
                  style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          buildParamRow(context, 'Fed today', '$feedingsToday time${feedingsToday == 1 ? '' : 's'}', '2-3x'),
          buildParamRow(context, 'Last fed', latestFeeding != null ? timeAgo(latestFeeding.timestamp) : 'Not yet', ''),
          const SizedBox(height: AppSpacing.md),
          Text(
            '\u{1F41F} What this means for your fish',
            style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Overfeeding is the #1 cause of water quality issues. Feed small amounts your fish can finish in 2 minutes.',
            style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                NavigationThrottle.push(
                  context,
                  AddLogScreen(tankId: tankId, initialType: LogType.feeding),
                  route: RoomSlideRoute(page: AddLogScreen(tankId: tankId, initialType: LogType.feeding)),
                );
              },
              icon: const Icon(Icons.restaurant, size: 18),
              label: const Text('Log Feeding'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    ),
  );
}

void showPlantInfo(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const Text('\u{1FAB4}', style: TextStyle(fontSize: 40)),
                const SizedBox(height: AppSpacing.sm),
                Semantics(
                  header: true,
                  child: Text('Tank Plants', style: AppTypography.headlineSmall),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm2),
            decoration: BoxDecoration(
              color: DanioColors.emeraldGreen.withAlpha(20),
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: DanioColors.emeraldGreen.withAlpha(60)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u{2728} Plant Care Tips',
                  style: AppTypography.labelMedium.copyWith(
                    color: DanioColors.emeraldGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '8-10 hrs light daily  |  Trim dead leaves  |  Root tabs for heavy feeders',
                  style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '\u{1F41F} What this means for your fish',
            style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Live plants absorb nitrates, produce oxygen, and provide shelter. They are one of the best things you can add to any tank.',
            style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '\u{1F4A1} Pro tip: Use old tank water to water your houseplants — packed with nutrients!',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    ),
  );
}

void showThemePicker(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg2),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: AppRadius.largeRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette, size: AppIconSizes.md),
              const SizedBox(width: AppSpacing.sm2),
              Semantics(
                header: true,
                child: Text('Room Theme', style: AppTypography.headlineSmall),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg2),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: RoomThemeType.values.map((type) {
              final theme = RoomTheme.fromType(type);
              final isSelected = ref.watch(roomThemeProvider) == type;
              return Semantics(
                label: '${theme.name} theme${isSelected ? ', selected' : ''}',
                button: true,
                selected: isSelected,
                child: GestureDetector(
                  onTap: () {
                    ref.read(roomThemeProvider.notifier).setTheme(type);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.all(AppSpacing.sm2),
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(
                        color: isSelected ? theme.accentBlob : context.borderColor,
                        width: isSelected ? 3 : 1,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [theme.background1, theme.background2],
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(radius: 8, backgroundColor: theme.accentBlob),
                            const SizedBox(width: AppSpacing.xs),
                            CircleAvatar(radius: 8, backgroundColor: theme.waterMid),
                            const SizedBox(width: AppSpacing.xs),
                            CircleAvatar(radius: 8, backgroundColor: theme.plantPrimary),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          theme.name,
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: theme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          theme.description,
                          style: Theme.of(context).textTheme.labelSmall!.copyWith(color: theme.textSecondary),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    ),
  );
}

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

void showStreakCalendar(BuildContext context) {
  NavigationThrottle.push(
    context,
    const StreakCalendarScreen(),
    route: RoomSlideRoute(page: const StreakCalendarScreen()),
  );
}

void showTankToolbox(BuildContext context, WidgetRef ref, String tankId) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Semantics(
            header: true,
            child: Text('Tank Toolbox 🔧', style: AppTypography.headlineSmall),
          ),
          const SizedBox(height: AppSpacing.sm2),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Reminders'),
            onTap: () {
              Navigator.pop(ctx);
              NavigationThrottle.push(
                context,
                const RemindersScreen(),
                route: RoomSlideRoute(page: const RemindersScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.book_outlined),
            title: const Text('Tank Journal'),
            onTap: () {
              Navigator.pop(ctx);
              NavigationThrottle.push(
                context,
                JournalScreen(tankId: tankId),
                route: RoomSlideRoute(page: JournalScreen(tankId: tankId)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics_outlined),
            title: const Text('Analytics'),
            onTap: () {
              Navigator.pop(ctx);
              NavigationThrottle.push(context, const AnalyticsScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Species Search'),
            onTap: () {
              Navigator.pop(ctx);
              NavigationThrottle.push(
                context,
                const SearchScreen(),
                route: RoomSlideRoute(page: const SearchScreen()),
              );
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    ),
  );
}

void showItemSheet(
  BuildContext context, {
  required String title,
  required IconData icon,
  required Color color,
  required List<ItemDetailRow> rows,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: ItemDetailPopup(
        title: title,
        icon: icon,
        accentColor: color,
        rows: rows,
        onClose: () => Navigator.pop(ctx),
      ),
    ),
  );
}

void showQuickLogSheet(BuildContext context, WidgetRef ref, Tank tank) {
  final phC = TextEditingController();
  final tempC = TextEditingController();
  final ammoniaC = TextEditingController();

  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            header: true,
            child: Text('Quick Water Test', style: AppTypography.headlineSmall),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: phC,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'pH'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: tempC,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Temp (°C)'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: ammoniaC,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'NH3'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save & Earn 10 XP'),
              onPressed: () async {
                final ph = double.tryParse(phC.text);
                final temp = double.tryParse(tempC.text);
                final ammonia = double.tryParse(ammoniaC.text);
                if (ph == null && temp == null && ammonia == null) return;
                Navigator.pop(ctx);
                final now = DateTime.now();
                final log = LogEntry(
                  id: now.microsecondsSinceEpoch.toString(),
                  tankId: tank.id,
                  type: LogType.waterTest,
                  timestamp: now,
                  createdAt: now,
                  title: 'Quick test',
                  waterTest: WaterTestResults(
                    ph: ph,
                    temperature: temp,
                    ammonia: ammonia,
                  ),
                );
                final storage = ref.read(storageServiceProvider);
                await storage.saveLog(log);
                ref.invalidate(logsProvider(tank.id));
                ref.invalidate(allLogsProvider(tank.id));
                await ref.read(userProfileProvider.notifier).addXp(10);
              },
            ),
          ),
        ],
      ),
    ),
  ).whenComplete(() {
    phC.dispose();
    tempC.dispose();
    ammoniaC.dispose();
  });
}
