// Analytics Dashboard Screen - Comprehensive progress visualization
// Features: charts, insights, trends, predictions, and export options
import 'dart:convert';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/lesson_content_lazy.dart';
import '../../models/analytics.dart';
import '../../providers/user_profile_provider.dart';
import '../../services/analytics_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_feedback.dart';
import '../../utils/logger.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/core/app_states.dart';
import 'analytics_stat_card.dart';
import 'analytics_insight_card.dart';
import 'analytics_topic_card.dart';
import 'analytics_prediction_card.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  AnalyticsTimeRange _selectedRange = AnalyticsTimeRange.last30Days;
  DateTime? _customStart;
  DateTime? _customEnd;
  late Future<AnalyticsSummary> _analyticsFuture;

  /// Monotonically increasing version counter. Incremented each time a new
  /// analytics load is requested so that stale `compute()` results from
  /// previous range selections are discarded.
  int _loadVersion = 0;

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _loadAnalytics();
  }

  void _refreshAnalytics() {
    _loadVersion++;
    setState(() {
      _analyticsFuture = _loadAnalytics();
    });
  }

  /// Returns true when a summary has no meaningful data to display.
  bool _isEmptySummary(AnalyticsSummary summary) {
    return summary.totalXP == 0 &&
        summary.lessonsCompleted == 0 &&
        summary.currentStreak == 0 &&
        summary.recentDailyStats.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _exportData(context),
            tooltip: 'Export Data',
          ),
        ],
      ),
      body: FutureBuilder<AnalyticsSummary>(
        future: _analyticsFuture,
        builder: (context, snapshot) {
          Widget body;
          if (snapshot.connectionState == ConnectionState.waiting) {
            body = _buildSkeletonLoader();
          } else if (snapshot.hasError) {
            body = AppErrorState(
              title: 'Couldn\'t load analytics',
              message: 'Something went wrong. Tap to try again.',
              onRetry: _refreshAnalytics,
            );
          } else {
            final summary = snapshot.data;
            if (summary == null) {
              body = const AppErrorState(
                title: 'No analytics data available',
                message:
                    'Complete some lessons to see your progress analytics.',
              );
            } else if (_isEmptySummary(summary)) {
              final theme = Theme.of(context);
              body = Center(
                key: const ValueKey('analytics-empty'),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      size: 64,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('No data yet', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Complete lessons and log activities\nto see your progress here',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              body = SingleChildScrollView(
                key: const ValueKey('analytics-content'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimeRangeSelector(),
                    _buildOverviewSection(summary),
                    const Divider(height: AppSpacing.xl),
                    _buildXPChart(summary),
                    const Divider(height: AppSpacing.xl),
                    _buildWeeklyXPBarChart(summary),
                    const Divider(height: AppSpacing.xl),
                    _buildTopicMasteryRadar(summary),
                    const Divider(height: AppSpacing.xl),
                    _buildStreakCalendar(summary),
                    const Divider(height: AppSpacing.xl),
                    _buildInsightsSection(summary),
                    const Divider(height: AppSpacing.xl),
                    _buildTopicBreakdown(summary),
                    const Divider(height: AppSpacing.xl),
                    _buildPredictionsSection(summary),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              );
            }
          }
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            child: body,
          );
        },
      ),
    );
  }

  Future<AnalyticsSummary> _loadAnalytics() async {
    final version = _loadVersion;

    final profile = ref.read(userProfileProvider).valueOrNull;
    if (profile == null) {
      return AnalyticsSummary(
        totalXP: 0,
        currentStreak: 0,
        longestStreak: 0,
        lessonsCompleted: 0,
        totalLessons: 0,
        timeSpentMinutes: 0,
        recentDailyStats: const [],
        recentWeeklyStats: const [],
        insights: const [],
        topicPerformance: const [],
        predictions: const [],
        generatedAt: DateTime.now(),
      );
    }
    final allPaths = await lessonContentLazy.getAllPaths();

    if (version != _loadVersion) {
      return AnalyticsSummary(
        totalXP: profile.totalXp,
        currentStreak: profile.currentStreak,
        longestStreak: profile.longestStreak,
        lessonsCompleted: profile.completedLessons.length,
        totalLessons: allPaths.fold<int>(
          0,
          (sum, path) => sum + path.lessons.length,
        ),
        timeSpentMinutes: 0,
        recentDailyStats: const [],
        recentWeeklyStats: const [],
        insights: const [],
        topicPerformance: const [],
        predictions: const [],
        generatedAt: DateTime.now(),
      );
    }

    try {
      return await AnalyticsService.generateSummaryAsync(
        profile: profile,
        allPaths: allPaths,
        timeRange: _selectedRange,
        customStart: _customStart,
        customEnd: _customEnd,
      );
    } catch (e) {
      logError(
        'Analytics compute failed (v$version): $e',
        tag: 'AnalyticsScreen',
      );
      return AnalyticsSummary(
        totalXP: profile.totalXp,
        currentStreak: profile.currentStreak,
        longestStreak: profile.longestStreak,
        lessonsCompleted: profile.completedLessons.length,
        totalLessons: allPaths.fold<int>(
          0,
          (sum, p) => sum + p.lessons.length,
        ),
        timeSpentMinutes: 0,
        recentDailyStats: const [],
        recentWeeklyStats: const [],
        insights: const [],
        topicPerformance: const [],
        predictions: const [],
        generatedAt: DateTime.now(),
      );
    }
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeRangeSelector(),
          const SizedBox(height: AppSpacing.md),
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: SkeletonCard(height: 80)),
                    SizedBox(width: AppSpacing.sm2),
                    Expanded(child: SkeletonCard(height: 80)),
                  ],
                ),
                SizedBox(height: AppSpacing.sm2),
                Row(
                  children: [
                    Expanded(child: SkeletonCard(height: 80)),
                    SizedBox(width: AppSpacing.sm2),
                    Expanded(child: SkeletonCard(height: 80)),
                  ],
                ),
              ],
            ),
          ),
          const SkeletonChart(height: 250),
          const SkeletonChart(height: 200),
          const SkeletonChart(height: 200),
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                SkeletonCard(height: 60),
                SkeletonCard(height: 60),
                SkeletonCard(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time Range',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm2),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AnalyticsTimeRange.values
                .where((r) => r != AnalyticsTimeRange.custom)
                .map((range) {
                  final isSelected = _selectedRange == range;
                  return ChoiceChip(
                    label: Text(
                      range.displayName,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Theme.of(context).colorScheme.primary,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                      width: isSelected ? 2 : 1,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedRange = range;
                          _customStart = null;
                          _customEnd = null;
                        });
                        _refreshAnalytics();
                      }
                    },
                  );
                })
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(AnalyticsSummary summary) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AnalyticsStatCard(
                  icon: Icons.star,
                  label: 'Total XP',
                  value: summary.totalXP.toString(),
                  color: DanioColors.amberGold,
                  trend: summary.recentWeeklyStats.isNotEmpty &&
                          summary.recentWeeklyStats.length >= 2
                      ? summary.recentWeeklyStats[0].totalXP >
                                summary.recentWeeklyStats[1].totalXP
                            ? ProgressTrend.increasing
                            : ProgressTrend.decreasing
                      : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: AnalyticsStatCard(
                  icon: Icons.local_fire_department,
                  label: 'Current Streak',
                  value:
                      '${summary.currentStreak} ${summary.currentStreak == 1 ? "day" : "days"}',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm2),
          Row(
            children: [
              Expanded(
                child: AnalyticsStatCard(
                  icon: Icons.book,
                  label: 'Lessons',
                  value:
                      '${summary.lessonsCompleted}/${summary.totalLessons}',
                  color: AppColors.info,
                  subtitle:
                      '${(summary.completionPercentage * 100).toStringAsFixed(0)}% complete',
                ),
              ),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: AnalyticsStatCard(
                  icon: Icons.schedule,
                  label: 'Time Spent',
                  value: summary.timeSpentFormatted,
                  color: DanioColors.emeraldGreen,
                ),
              ),
            ],
          ),
          if (summary.longestStreak > summary.currentStreak) ...[
            const SizedBox(height: AppSpacing.sm2),
            AnalyticsStatCard(
              icon: Icons.emoji_events,
              label: 'Longest Streak',
              value:
                  '${summary.longestStreak} ${summary.longestStreak == 1 ? "day" : "days"}',
              color: AppColors.accentAlt,
              subtitle: 'Your personal best!',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildXPChart(AnalyticsSummary summary) {
    if (summary.recentDailyStats.isEmpty) return const SizedBox.shrink();

    final data = summary.recentDailyStats.reversed.toList();
    final maxXP = data.map((d) => d.xp).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'XP Over Time',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.lg),
          Semantics(
            label:
                'Line chart: XP earned over time. ${data.length} data points.',
            excludeSemantics: true,
            child: SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxXP > 0 ? maxXP / 4 : 25,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: AppTypography.labelSmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: data.length > 14 ? data.length / 7 : 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            final date = data[index].date;
                            return Padding(
                              padding: const EdgeInsets.only(top: AppSpacing.sm),
                              child: Text(
                                DateFormat('M/d').format(date),
                                style: AppTypography.labelSmall,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(
                              e.key.toDouble(),
                              e.value.xp.toDouble(),
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: AppColors.info,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppOverlays.blue10,
                      ),
                    ),
                  ],
                  minY: 0,
                  maxY: maxXP > 0 ? maxXP * 1.2 : 100,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyXPBarChart(AnalyticsSummary summary) {
    if (summary.recentDailyStats.isEmpty) return const SizedBox.shrink();

    final last7Days = summary.recentDailyStats
        .take(7)
        .toList()
        .reversed
        .toList();
    final maxXP = last7Days.map((d) => d.xp).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last 7 Days',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.lg),
          Semantics(
            label: 'Bar chart: XP earned over last 7 days.',
            excludeSemantics: true,
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxXP > 0 ? maxXP * 1.2 : 100,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()} XP',
                          const TextStyle(color: AppColors.onPrimary),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: AppTypography.labelSmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < last7Days.length) {
                            final date = last7Days[index].date;
                            return Padding(
                              padding: const EdgeInsets.only(top: AppSpacing.sm),
                              child: Text(
                                DateFormat('E').format(date)[0],
                                style: AppTypography.labelSmall,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxXP > 0 ? maxXP / 4 : 25,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: last7Days.asMap().entries.map((entry) {
                    final isToday =
                        entry.value.date.day == DateTime.now().day;
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.xp.toDouble(),
                          color: isToday
                              ? DanioColors.amberGold
                              : AppColors.primaryLight,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicMasteryRadar(AnalyticsSummary summary) {
    if (summary.topicPerformance.isEmpty) return const SizedBox.shrink();

    final topics = summary.topicPerformance.take(6).toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Topic Mastery',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.lg),
          Semantics(
            label:
                'Radar chart: topic mastery across ${topics.length} subjects.',
            excludeSemantics: true,
            child: SizedBox(
              height: 300,
              child: RadarChart(
                RadarChartData(
                  radarShape: RadarShape.polygon,
                  tickCount: 5,
                  ticksTextStyle: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.transparent),
                  radarBorderData: BorderSide(
                    color: AppColors.textSecondaryAlpha30,
                    width: 1,
                  ),
                  gridBorderData: BorderSide(
                    color: AppColors.textSecondaryAlpha30,
                    width: 0.5,
                  ),
                  tickBorderData: const BorderSide(color: Colors.transparent),
                  getTitle: (index, angle) {
                    if (index >= topics.length) {
                      return const RadarChartTitle(text: '');
                    }
                    return RadarChartTitle(
                      text: topics[index].topicName.split(' ').first,
                      angle: angle,
                    );
                  },
                  dataSets: [
                    RadarDataSet(
                      fillColor: AppOverlays.blue20,
                      borderColor: AppColors.info,
                      dataEntries: topics
                          .map(
                            (t) =>
                                RadarEntry(value: t.masteryPercentage * 100),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCalendar(AnalyticsSummary summary) {
    if (summary.recentDailyStats.isEmpty) return const SizedBox.shrink();

    final today = DateTime.now();
    const daysToShow = 84; // 12 weeks
    final startDate = today.subtract(const Duration(days: daysToShow));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Calendar',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 120,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: daysToShow,
              itemBuilder: (context, index) {
                final date = startDate.add(Duration(days: index));
                final dateKey =
                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                final dayData = summary.recentDailyStats.firstWhere(
                  (d) => d.dateKey == dateKey,
                  orElse: () => DailyStats(
                    date: date,
                    xp: 0,
                    lessonsCompleted: 0,
                    practiceMinutes: 0,
                    timeSpentSeconds: 0,
                  ),
                );

                Color color;
                if (dayData.xp == 0) {
                  color = Theme.of(context).brightness == Brightness.dark
                      ? context.surfaceVariant
                      : context.borderColor;
                } else if (dayData.xp < 25) {
                  color = DanioColors.algaeGreenPale;
                } else if (dayData.xp < 50) {
                  color = DanioColors.algaeGreenBright;
                } else if (dayData.xp < 100) {
                  color = DanioColors.emeraldGreen;
                } else {
                  color = DanioColors.algaeGreenDark;
                }

                return Tooltip(
                  message:
                      '${DateFormat('MMM d').format(date)}: ${dayData.xp} XP',
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(AppRadius.xxs),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Less', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(width: AppSpacing.xs),
              _buildLegendBox(
                Theme.of(context).brightness == Brightness.dark
                    ? context.surfaceVariant
                    : context.borderColor,
              ),
              _buildLegendBox(DanioColors.algaeGreenPale),
              _buildLegendBox(DanioColors.algaeGreenBright),
              _buildLegendBox(DanioColors.emeraldGreen),
              _buildLegendBox(DanioColors.algaeGreenDark),
              const SizedBox(width: AppSpacing.xs),
              Text('More', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.xxs),
      ),
    );
  }

  Widget _buildInsightsSection(AnalyticsSummary summary) {
    if (summary.insights.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Insights & Recommendations',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          ...summary.insights.map(
            (insight) => AnalyticsInsightCard(insight: insight),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicBreakdown(AnalyticsSummary summary) {
    if (summary.topicPerformance.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Topic Breakdown',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          ...summary.topicPerformance.map(
            (topic) => AnalyticsTopicCard(topic: topic),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionsSection(AnalyticsSummary summary) {
    if (summary.predictions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Predictions & Goals',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          ...summary.predictions.map(
            (prediction) => AnalyticsPredictionCard(prediction: prediction),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    final summary = await _loadAnalytics();

    if (!context.mounted) return;

    await showAppDragSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export as CSV'),
              subtitle: const Text('Spreadsheet-friendly format'),
              onTap: () async {
                Navigator.maybePop(context);
                await _exportAsCSV(summary);
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Export as JSON'),
              subtitle: const Text('Technical format'),
              onTap: () async {
                Navigator.maybePop(context);
                await _exportAsJson(summary);
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Share Progress Report'),
              subtitle: const Text('Human-readable text'),
              onTap: () async {
                Navigator.maybePop(context);
                await _shareReport(summary);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAsJson(AnalyticsSummary summary) async {
    try {
      final jsonData = {
        'totalXP': summary.totalXP,
        'currentStreak': summary.currentStreak,
        'longestStreak': summary.longestStreak,
        'lessonsCompleted': summary.lessonsCompleted,
        'totalLessons': summary.totalLessons,
        'insights': summary.insights.map((i) => i.toJson()).toList(),
        'exportedAt': DateTime.now().toIso8601String(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/analytics_export.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Danio Analytics Export',
      );
    } catch (e) {
      logError('Export failed: $e', tag: 'AnalyticsScreen');
      if (mounted) {
        AppFeedback.showError(
          context,
          'Export didn\'t work. Give it another go!',
        );
      }
    }
  }

  Future<void> _exportAsCSV(AnalyticsSummary summary) async {
    try {
      final csvLines = <String>[];
      csvLines.add('Metric,Value');
      csvLines.add('Total XP,${summary.totalXP}');
      csvLines.add('Current Streak,${summary.currentStreak}');
      csvLines.add('Longest Streak,${summary.longestStreak}');
      csvLines.add('Lessons Completed,${summary.lessonsCompleted}');
      csvLines.add('Total Lessons,${summary.totalLessons}');
      csvLines.add(
        'Completion Rate,${(summary.lessonsCompleted / summary.totalLessons * 100).toStringAsFixed(1)}%',
      );
      csvLines.add('Time Spent,${summary.timeSpentFormatted}');

      if (summary.insights.isNotEmpty) {
        csvLines.add('');
        csvLines.add('Insights');
        for (final insight in summary.insights) {
          final message = insight.message.replaceAll('"', '""');
          csvLines.add('"${insight.type}","$message"');
        }
      }

      csvLines.add('');
      csvLines.add(
        'Exported At,${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',
      );

      final csvContent = csvLines.join('\n');
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/analytics_export.csv');
      await file.writeAsString(csvContent);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Danio Analytics Export (CSV)',
      );
    } catch (e) {
      logError('CSV Export failed: $e', tag: 'AnalyticsScreen');
      if (mounted) {
        AppFeedback.showError(
          context,
          'CSV export didn\'t work. Give it another go!',
        );
      }
    }
  }

  Future<void> _shareReport(AnalyticsSummary summary) async {
    final report = '''
📊 My Aquarium Learning Progress

🌟 Total XP: ${summary.totalXP}
🔥 Current Streak: ${summary.currentStreak} ${summary.currentStreak == 1 ? 'day' : 'days'}
📚 Lessons Completed: ${summary.lessonsCompleted}/${summary.totalLessons}
⏱️ Time Spent: ${summary.timeSpentFormatted}

${summary.insights.isNotEmpty ? '💡 Top Insights:\n${summary.insights.take(3).map((i) => '• ${i.message}').join('\n')}' : ''}

Generated: ${DateFormat('MMM d, yyyy').format(DateTime.now())}
''';

    await Share.share(report, subject: 'My Danio Learning Progress');
  }
}
