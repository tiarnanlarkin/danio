/// Streak calendar widget - GitHub-style activity visualization
/// Shows daily goal completion with color-coded squares
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/daily_goal.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';

/// GitHub-style calendar showing daily learning streak history.
///
/// Visualizes daily goal completion over time with color-coded squares.
/// Intensity indicates XP earned each day. Includes weekday labels and tooltips.
class StreakCalendar extends ConsumerWidget {
  final int weeks;
  final double cellSize;
  final double spacing;

  const StreakCalendar({
    super.key,
    this.weeks = 12,
    this.cellSize = 12,
    this.spacing = 3,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileData = ref.watch(userProfileProvider.select((p) => (p.value?.dailyXpGoal, p.value?.dailyXpHistory)));

    if (profileData.$1 == null || profileData.$2 == null) {
      return const SizedBox.shrink();
    }

    final recentGoals = DailyGoal.getRecentDays(
      days: weeks * 7,
      dailyXpGoal: profileData.$1!,
      dailyXpHistory: profileData.$2!,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and legend
        Row(
          children: [
            Text(
              'Activity',
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            _Legend(cellSize: cellSize),
          ],
        ),
        const SizedBox(height: AppSpacing.sm2),

        // Calendar grid
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _CalendarGrid(
            goals: recentGoals,
            cellSize: cellSize,
            spacing: spacing,
          ),
        ),
      ],
    );
  }
}

class _CalendarGrid extends StatefulWidget {
  final List<DailyGoal> goals;
  final double cellSize;
  final double spacing;

  const _CalendarGrid({
    required this.goals,
    required this.cellSize,
    required this.spacing,
  });

  @override
  State<_CalendarGrid> createState() => _CalendarGridState();
}

class _CalendarGridState extends State<_CalendarGrid> {
  /// Cached week grouping — recomputed only when [goals] reference changes.
  late List<List<DailyGoal>> _weeks;

  @override
  void initState() {
    super.initState();
    _weeks = _groupIntoWeeks(widget.goals);
  }

  @override
  void didUpdateWidget(covariant _CalendarGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.goals, widget.goals)) {
      _weeks = _groupIntoWeeks(widget.goals);
    }
  }

  /// Pre-compute week grouping from the given goals.
  static List<List<DailyGoal>> _groupIntoWeeks(List<DailyGoal> goals) {
    final weeks = <List<DailyGoal>>[];
    var currentWeek = <DailyGoal>[];

    for (final goal in goals) {
      currentWeek.add(goal);

      // Sunday is end of week (weekday = 7)
      if (goal.date.weekday == DateTime.sunday || goal == goals.last) {
        weeks.add(List.from(currentWeek));
        currentWeek.clear();
      }
    }

    // Ensure first week starts on Sunday
    if (weeks.isNotEmpty && weeks.first.first.date.weekday != DateTime.sunday) {
      final firstWeek = weeks.first;
      final daysToAdd = firstWeek.first.date.weekday % 7;
      for (int i = 0; i < daysToAdd; i++) {
        firstWeek.insert(
          0,
          DailyGoal(
            date: firstWeek.first.date.subtract(Duration(days: 1)),
            targetXp: 0,
            earnedXp: 0,
            isCompleted: false,
            isToday: false,
          ),
        );
      }
    }

    return weeks;
  }

  @override
  Widget build(BuildContext context) {
    final cellSize = widget.cellSize;
    final spacing = widget.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Week day labels (M W F)
        Padding(
          padding: EdgeInsets.only(left: cellSize + spacing),
          child: Row(
            children: [
              SizedBox(
                width: cellSize,
                child: Text(
                  'M',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall!.copyWith(color: context.textHint),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: spacing),
              SizedBox(width: cellSize + spacing), // Tuesday
              SizedBox(
                width: cellSize,
                child: Text(
                  'W',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall!.copyWith(color: context.textHint),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: spacing),
              SizedBox(width: cellSize + spacing), // Thursday
              SizedBox(
                width: cellSize,
                child: Text(
                  'F',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall!.copyWith(color: context.textHint),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),

        // Calendar cells
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month labels (vertical)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _buildMonthLabels(context),
            ),
            SizedBox(width: spacing),

            // Week columns
            ..._weeks.map(
              (week) => _WeekColumn(
                goals: week,
                cellSize: cellSize,
                spacing: spacing,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildMonthLabels(BuildContext context) {
    final cellSize = widget.cellSize;
    final spacing = widget.spacing;
    final labels = <Widget>[];
    String? lastMonth;

    for (int i = 0; i < 7; i++) {
      String? monthLabel;

      for (final week in _weeks) {
        if (week.length > i) {
          final goal = week[i];
          final month = DateFormat('MMM').format(goal.date);

          if (month != lastMonth && (lastMonth == null || i == 0)) {
            monthLabel = month;
            lastMonth = month;
            break;
          }
        }
      }

      labels.add(
        SizedBox(
          height: cellSize,
          child: monthLabel != null
              ? Text(
                  monthLabel,
                  style: TextStyle(fontSize: 10, color: context.textHint),
                )
              : null,
        ),
      );

      if (i < 6) {
        labels.add(SizedBox(height: spacing));
      }
    }

    return labels;
  }
}

class _WeekColumn extends StatelessWidget {
  final List<DailyGoal> goals;
  final double cellSize;
  final double spacing;

  const _WeekColumn({
    required this.goals,
    required this.cellSize,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < 7; i++) ...[
          if (i < goals.length)
            _DayCell(goal: goals[i], size: cellSize)
          else
            SizedBox(width: cellSize, height: cellSize),
          if (i < 6) SizedBox(height: spacing),
        ],
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final DailyGoal goal;
  final double size;

  const _DayCell({required this.goal, required this.size});

  @override
  Widget build(BuildContext context) {
    final intensity = StreakCalculator.getIntensityLevel(
      earnedXp: goal.earnedXp,
      dailyXpGoal: goal.targetXp,
    );

    final color = _getColorForIntensity(intensity, context);

    return Tooltip(
      message: _getTooltipText(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
          border: goal.isToday
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
      ),
    );
  }

  Color _getColorForIntensity(int intensity, BuildContext context) {
    switch (intensity) {
      case 0:
        return context.surfaceVariant;
      case 1:
        return const Color(0xFFFFE6B8); // Light amber
      case 2:
        return const Color(0xFFFFD28A); // Medium-light amber
      case 3:
        return const Color(0xFFFFB84D); // Medium amber
      case 4:
        return const Color(0xFFD97706); // Brand amber gold
      default:
        return context.surfaceVariant;
    }
  }

  String _getTooltipText() {
    final dateStr = DateFormat('MMM d, yyyy').format(goal.date);

    if (goal.earnedXp == 0) {
      return '$dateStr\nNo activity';
    }

    return '$dateStr\n${goal.earnedXp} XP earned\n${goal.progressPercent}% of goal';
  }
}

class _Legend extends StatelessWidget {
  final double cellSize;

  const _Legend({required this.cellSize});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Less',
          style: Theme.of(
            context,
          ).textTheme.labelSmall!.copyWith(color: context.textHint),
        ),
        const SizedBox(width: AppSpacing.xs),
        _LegendCell(color: context.surfaceVariant, size: cellSize),
        const SizedBox(width: AppSpacing.xxs),
        _LegendCell(color: const Color(0xFFFFE6B8), size: cellSize),
        const SizedBox(width: AppSpacing.xxs),
        _LegendCell(color: const Color(0xFFFFD28A), size: cellSize),
        const SizedBox(width: AppSpacing.xxs),
        _LegendCell(color: const Color(0xFFFFB84D), size: cellSize),
        const SizedBox(width: AppSpacing.xxs),
        _LegendCell(color: const Color(0xFFD97706), size: cellSize),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'More',
          style: Theme.of(
            context,
          ).textTheme.labelSmall!.copyWith(color: context.textHint),
        ),
      ],
    );
  }
}

class _LegendCell extends StatelessWidget {
  final Color color;
  final double size;

  const _LegendCell({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// Full-page streak calendar view
class StreakCalendarScreen extends ConsumerWidget {
  const StreakCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streaks = ref.watch(userProfileProvider.select((p) => (p.value?.currentStreak, p.value?.longestStreak)));

    return Scaffold(
      appBar: AppBar(title: const Text('Activity Calendar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Current Streak',
                    value: '${streaks.$1 ?? 0}',
                    icon: Icons.local_fire_department,
                    color: const Color(0xFFFF6B35),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm2),
                Expanded(
                  child: _StatCard(
                    label: 'Longest Streak',
                    value: '${streaks.$2 ?? 0}',
                    icon: Icons.emoji_events,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Calendar
            const StreakCalendar(
              weeks: 52, // Full year
              cellSize: 14,
              spacing: 4,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: context.surfaceVariant),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppIconSizes.lg),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
