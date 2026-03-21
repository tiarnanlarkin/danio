import 'package:danio/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Analytics Dashboard Screen - Comprehensive progress visualization
/// Features: charts, insights, trends, predictions, and export options
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/analytics.dart';
import '../models/learning.dart';
import '../services/analytics_service.dart';
import '../providers/lesson_provider.dart';
import '../providers/user_profile_provider.dart';
import '../data/lesson_content_lazy.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/core/app_states.dart';
import '../widgets/core/app_card.dart';
import 'package:danio/utils/logger.dart';

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
    _analyticsFuture = _loadAnalytics();
  }

  /// Darkens a decorative colour to meet WCAG AA (4.5:1) for text on light bg.
  /// Only adjusts if luminance suggests insufficient contrast with white.
  static Color _ensureTextContrast(Color color) {
    final luminance = color.computeLuminance();
    // White luminance = 1.0. WCAG AA = 4.5:1 → min luminance ≈ 0.143
    if (luminance > 0.18) {
      // Blend toward black until contrast is sufficient
      return Color.from(alpha: color.a, red: (color.r * 0.6).clamp(0, 1), green: (color.g * 0.6).clamp(0, 1), blue: (color.b * 0.6).clamp(0, 1));
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Analytics'),
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
              title: 'Couldn\'t load your analytics',
              message: 'Check your connection and give it another go!',
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

  /// Load analytics data using real user profile.
  ///
  /// Uses a [_loadVersion] counter so that when the user taps a different
  /// range chip before a previous `compute()` finishes, the stale result
  /// is discarded. This prevents the "Couldn't load your analytics" error
  /// that occurred when rapid range switching caused old isolate results
  /// to arrive out of order or fail.
  Future<AnalyticsSummary> _loadAnalytics() async {
    final version = _loadVersion;

    final profile = ref.read(userProfileProvider).valueOrNull;
    if (profile == null) {
      // Return empty analytics when no profile is loaded yet
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
    // Lazy-load all paths for analytics (user explicitly navigated here)
    final allPaths = await lessonContentLazy.getAllPaths();

    // If the user has already tapped a different range, discard this result.
    if (version != _loadVersion) {
      // Return empty — the FutureBuilder for the newer version will handle display.
      return AnalyticsSummary(
        totalXP: profile.totalXp,
        currentStreak: profile.currentStreak,
        longestStreak: profile.longestStreak,
        lessonsCompleted: profile.completedLessons.length,
        totalLessons: allPaths.fold<int>(0, (sum, path) => sum + path.lessons.length),
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
      logError('Analytics compute failed (v$version): $e', tag: 'AnalyticsScreen');
      // Re-throw so FutureBuilder shows the error state with retry button.
      rethrow;
    }
  }

  /// Skeleton loader for analytics
  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeRangeSelector(),
          const SizedBox(height: AppSpacing.md),
          // Overview skeleton
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

  /// Time range selector widget
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
                    label: Text(range.displayName),
                    selected: isSelected,
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

  /// Overview section with key metrics
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
                child: _buildStatCard(
                  icon: Icons.star,
                  label: 'Total XP',
                  value: summary.totalXP.toString(),
                  color: DanioColors.amberGold,
                  trend:
                      summary.recentWeeklyStats.isNotEmpty &&
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
                child: _buildStatCard(
                  icon: Icons.local_fire_department,
                  label: 'Current Streak',
                  value: '${summary.currentStreak} days',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm2),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.book,
                  label: 'Lessons',
                  value: '${summary.lessonsCompleted}/${summary.totalLessons}',
                  color: AppColors.info,
                  subtitle:
                      '${(summary.completionPercentage * 100).toStringAsFixed(0)}% complete',
                ),
              ),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: _buildStatCard(
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
            _buildStatCard(
              icon: Icons.emoji_events,
              label: 'Longest Streak',
              value: '${summary.longestStreak} days',
              color: AppColors.accentAlt,
              subtitle: 'Your personal best!',
            ),
          ],
        ],
      ),
    );
  }

  /// Stat card widget
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    String? subtitle,
    ProgressTrend? trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: AppIconSizes.md),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(153),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trend != null) Text(trend.emoji),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: _ensureTextContrast(color),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// XP over time line chart
  Widget _buildXPChart(AnalyticsSummary summary) {
    if (summary.recentDailyStats.isEmpty) {
      return const SizedBox.shrink();
    }

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
                            style: const TextStyle(fontSize: 10),
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
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                DateFormat('M/d').format(date),
                                style: const TextStyle(fontSize: 10),
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
                            (e) =>
                                FlSpot(e.key.toDouble(), e.value.xp.toDouble()),
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
          ), // Semantics
        ],
      ),
    );
  }

  /// Weekly XP bar chart
  Widget _buildWeeklyXPBarChart(AnalyticsSummary summary) {
    if (summary.recentDailyStats.isEmpty) return const SizedBox.shrink();

    // Get last 7 days
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
                          const TextStyle(color: Colors.white),
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
                            style: const TextStyle(fontSize: 10),
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
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                DateFormat('E').format(date)[0],
                                style: const TextStyle(fontSize: 12),
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
                    final isToday = entry.value.date.day == DateTime.now().day;
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
          ), // Semantics
        ],
      ),
    );
  }

  /// Topic mastery radar chart
  Widget _buildTopicMasteryRadar(AnalyticsSummary summary) {
    if (summary.topicPerformance.isEmpty) return const SizedBox.shrink();

    // Take top 6 topics for radar chart
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
                            (t) => RadarEntry(value: t.masteryPercentage * 100),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ), // Semantics
        ],
      ),
    );
  }

  /// GitHub-style streak calendar
  Widget _buildStreakCalendar(AnalyticsSummary summary) {
    if (summary.recentDailyStats.isEmpty) return const SizedBox.shrink();

    final today = DateTime.now();
    final daysToShow = 84; // 12 weeks
    final startDate = today.subtract(Duration(days: daysToShow));

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
                  color = const Color(0xFFA5D6A7);
                } else if (dayData.xp < 50) {
                  color = const Color(0xFF66BB6A);
                } else if (dayData.xp < 100) {
                  color = DanioColors.emeraldGreen;
                } else {
                  color = const Color(0xFF2E7D32);
                }

                return Tooltip(
                  message:
                      '${DateFormat('MMM d').format(date)}: ${dayData.xp} XP',
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
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
              _buildLegendBox(const Color(0xFFA5D6A7)),
              _buildLegendBox(const Color(0xFF66BB6A)),
              _buildLegendBox(DanioColors.emeraldGreen),
              _buildLegendBox(const Color(0xFF2E7D32)),
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
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// Insights section with AI-generated recommendations
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
          ...summary.insights.map((insight) => _buildInsightCard(insight)),
        ],
      ),
    );
  }

  Widget _buildInsightCard(AnalyticsInsight insight) {
    Color color;
    switch (insight.type) {
      case InsightType.achievement:
      case InsightType.milestone:
        color = DanioColors.amberGold;
        break;
      case InsightType.improvement:
        color = DanioColors.emeraldGreen;
        break;
      case InsightType.warning:
        color = DanioColors.coralAccent;
        break;
      case InsightType.recommendation:
        color = AppColors.info;
        break;
      case InsightType.pattern:
        color = AppColors.accentAlt;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: AppCardPadding.standard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  insight.type.emoji,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(width: AppSpacing.sm2),
                Expanded(
                  child: Text(
                    insight.message,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _ensureTextContrast(color),
                    ),
                  ),
                ),
                if (insight.trend != null) Text(insight.trend!.emoji),
              ],
            ),
            if (insight.detailedMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                insight.detailedMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
                ),
              ),
            ],
            if (insight.recommendation != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm2),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: AppRadius.smallRadius,
                  border: Border.all(color: color.withAlpha(76)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: color,
                      size: AppIconSizes.sm,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        insight.recommendation!,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: color),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Topic breakdown section
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
          ...summary.topicPerformance.map((topic) => _buildTopicCard(topic)),
        ],
      ),
    );
  }

  Widget _buildTopicCard(TopicPerformance topic) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: AppCardPadding.standard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    topic.topicName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  topic.trend.emoji,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm2),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      LinearProgressIndicator(
                        value: topic.masteryPercentage,
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? context.surfaceVariant
                            : context.borderColor,
                        color: topic.isStrong
                            ? DanioColors.emeraldGreen
                            : topic.needsWork
                            ? DanioColors.coralAccent
                            : AppColors.info,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${topic.lessonsCompleted}/${topic.totalLessons} lessons (${(topic.masteryPercentage * 100).toInt()}%)',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${topic.totalXP} XP',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: DanioColors.amberGold,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${topic.timeSpentMinutes} min',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(153),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Predictions section
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
            (prediction) => _buildPredictionCard(prediction),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(Prediction prediction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: AppCardPadding.standard,
        backgroundColor: AppColors.infoAlpha10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_graph,
                  color: AppColors.info,
                  size: AppIconSizes.md,
                ),
                const SizedBox(width: AppSpacing.sm2),
                Expanded(
                  child: Text(
                    prediction.message,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info,
                    borderRadius: AppRadius.mediumRadius,
                  ),
                  child: Text(
                    prediction.confidenceLabel,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: Colors.white),
                  ),
                ),
                if (prediction.estimatedDate != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'ETA: ${DateFormat('MMM d').format(prediction.estimatedDate!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(178),
                    ),
                  ),
                ],
              ],
            ),
            if (prediction.recommendation != null) ...[
              const SizedBox(height: AppSpacing.sm2),
              Text(
                prediction.recommendation!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Export data options
  Future<void> _exportData(BuildContext context) async {
    final summary = await _loadAnalytics();

    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
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

      await Share.shareXFiles([
        XFile(file.path),
      ], subject: 'Danio Analytics Export');
    } catch (e) {
      logError('Export failed: $e', tag: 'AnalyticsScreen');
    }
  }

  Future<void> _exportAsCSV(AnalyticsSummary summary) async {
    try {
      // Create CSV content
      final csvLines = <String>[];

      // Header
      csvLines.add('Metric,Value');

      // Summary data
      csvLines.add('Total XP,${summary.totalXP}');
      csvLines.add('Current Streak,${summary.currentStreak}');
      csvLines.add('Longest Streak,${summary.longestStreak}');
      csvLines.add('Lessons Completed,${summary.lessonsCompleted}');
      csvLines.add('Total Lessons,${summary.totalLessons}');
      csvLines.add(
        'Completion Rate,${(summary.lessonsCompleted / summary.totalLessons * 100).toStringAsFixed(1)}%',
      );
      csvLines.add('Time Spent,${summary.timeSpentFormatted}');

      // Add insights section
      if (summary.insights.isNotEmpty) {
        csvLines.add('');
        csvLines.add('Insights');
        for (final insight in summary.insights) {
          // Escape commas and quotes in text
          final message = insight.message.replaceAll('"', '""');
          csvLines.add('"${insight.type}","$message"');
        }
      }

      // Add export metadata
      csvLines.add('');
      csvLines.add(
        'Exported At,${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',
      );

      final csvContent = csvLines.join('\n');
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/analytics_export.csv');
      await file.writeAsString(csvContent);

      await Share.shareXFiles([
        XFile(file.path),
      ], subject: 'Danio Analytics Export (CSV)');
    } catch (e) {
      logError('CSV Export failed: $e', tag: 'AnalyticsScreen');
    }
  }

  Future<void> _shareReport(AnalyticsSummary summary) async {
    final report =
        '''
📊 My Aquarium Learning Progress

🌟 Total XP: ${summary.totalXP}
🔥 Current Streak: ${summary.currentStreak} days
📚 Lessons Completed: ${summary.lessonsCompleted}/${summary.totalLessons}
⏱️ Time Spent: ${summary.timeSpentFormatted}

${summary.insights.isNotEmpty ? '💡 Top Insights:\n${summary.insights.take(3).map((i) => '• ${i.message}').join('\n')}' : ''}

Generated: ${DateFormat('MMM d, yyyy').format(DateTime.now())}
''';

    await Share.share(report, subject: 'My Danio Learning Progress');
  }
}
