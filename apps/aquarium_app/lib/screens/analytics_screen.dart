import 'package:aquarium_app/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Analytics Dashboard Screen - Comprehensive progress visualization
/// Features: charts, insights, trends, predictions, and export options
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/analytics.dart';
import '../models/user_profile.dart';
import '../models/learning.dart';
import '../services/analytics_service.dart';
import '../providers/lesson_provider.dart';
import '../data/lesson_content_lazy.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/core/app_states.dart';
import '../widgets/core/app_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  AnalyticsTimeRange _selectedRange = AnalyticsTimeRange.last30Days;
  DateTime? _customStart;
  DateTime? _customEnd;
  late Future<AnalyticsSummary> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _loadAnalytics();
  }

  void _refreshAnalytics() {
    setState(() {
      _analyticsFuture = _loadAnalytics();
    });
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSkeletonLoader();
          }

          if (snapshot.hasError) {
            return AppErrorState(
              title: 'Unable to load analytics data',
              message: 'Please check your connection and try again.',
              onRetry: _refreshAnalytics,
            );
          }

          final summary = snapshot.data;
          if (summary == null) {
            return const AppErrorState(
              title: 'No analytics data available',
              message: 'Complete some lessons to see your progress analytics.',
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeRangeSelector(),
                _buildOverviewSection(summary),
                const Divider(height: 32),
                _buildXPChart(summary),
                const Divider(height: 32),
                _buildWeeklyXPBarChart(summary),
                const Divider(height: 32),
                _buildTopicMasteryRadar(summary),
                const Divider(height: 32),
                _buildStreakCalendar(summary),
                const Divider(height: 32),
                _buildInsightsSection(summary),
                const Divider(height: 32),
                _buildTopicBreakdown(summary),
                const Divider(height: 32),
                _buildPredictionsSection(summary),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Load analytics data
  Future<AnalyticsSummary> _loadAnalytics() async {
    // In a real app, you'd fetch the UserProfile from storage/state management
    // For now, create a sample profile
    final profile = _getSampleProfile();
    // Lazy-load all paths for analytics (user explicitly navigated here)
    final allPaths = await lessonContentLazy.getAllPaths();

    return AnalyticsService.generateSummary(
      profile: profile,
      allPaths: allPaths,
      timeRange: _selectedRange,
      customStart: _customStart,
      customEnd: _customEnd,
    );
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
                    SizedBox(width: 12),
                    Expanded(child: SkeletonCard(height: 80)),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: SkeletonCard(height: 80)),
                    SizedBox(width: 12),
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
          const Text(
            'Time Range',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
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
          const Text(
            'Overview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.star,
                  label: 'Total XP',
                  value: summary.totalXP.toString(),
                  color: Colors.amber,
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
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_fire_department,
                  label: 'Current Streak',
                  value: '${summary.currentStreak} days',
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.book,
                  label: 'Lessons',
                  value: '${summary.lessonsCompleted}/${summary.totalLessons}',
                  color: Colors.blue,
                  subtitle:
                      '${(summary.completionPercentage * 100).toStringAsFixed(0)}% complete',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.schedule,
                  label: 'Time Spent',
                  value: summary.timeSpentFormatted,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          if (summary.longestStreak > summary.currentStreak) ...[
            const SizedBox(height: 12),
            _buildStatCard(
              icon: Icons.emoji_events,
              label: 'Longest Streak',
              value: '${summary.longestStreak} days',
              color: Colors.purple,
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
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
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
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
          const Text(
            'XP Over Time',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
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
                    color: Colors.blue,
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
          const Text(
            'Last 7 Days',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
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
                        color: isToday ? Colors.amber : Colors.blue,
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
          const Text(
            'Topic Mastery',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 300,
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                tickCount: 5,
                ticksTextStyle: const TextStyle(
                  fontSize: 10,
                  color: Colors.transparent,
                ),
                radarBorderData: const BorderSide(color: Colors.grey, width: 1),
                gridBorderData: const BorderSide(
                  color: Colors.grey,
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
                    borderColor: Colors.blue,
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
          const Text(
            'Activity Calendar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  color = Colors.grey[200]!;
                } else if (dayData.xp < 25) {
                  color = Colors.green[200]!;
                } else if (dayData.xp < 50) {
                  color = Colors.green[400]!;
                } else if (dayData.xp < 100) {
                  color = Colors.green[600]!;
                } else {
                  color = Colors.green[800]!;
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Less', style: TextStyle(fontSize: 11)),
              const SizedBox(width: AppSpacing.xs),
              _buildLegendBox(Colors.grey[200]!),
              _buildLegendBox(Colors.green[200]!),
              _buildLegendBox(Colors.green[400]!),
              _buildLegendBox(Colors.green[600]!),
              _buildLegendBox(Colors.green[800]!),
              const SizedBox(width: AppSpacing.xs),
              const Text('More', style: TextStyle(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
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
          const Text(
            'Insights & Recommendations',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        color = Colors.amber;
        break;
      case InsightType.improvement:
        color = Colors.green;
        break;
      case InsightType.warning:
        color = Colors.orange;
        break;
      case InsightType.recommendation:
        color = Colors.blue;
        break;
      case InsightType.pattern:
        color = Colors.purple;
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
                Text(insight.type.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight.message,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
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
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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
                    Icon(Icons.lightbulb_outline, color: color, size: AppIconSizes.sm),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        insight.recommendation!,
                        style: TextStyle(fontSize: 13, color: color),
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
          const Text(
            'Topic Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(topic.trend.emoji, style: const TextStyle(fontSize: 20)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      LinearProgressIndicator(
                        value: topic.masteryPercentage,
                        backgroundColor: Colors.grey[200],
                        color: topic.isStrong
                            ? Colors.green
                            : topic.needsWork
                            ? Colors.orange
                            : Colors.blue,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${topic.lessonsCompleted}/${topic.totalLessons} lessons (${(topic.masteryPercentage * 100).toInt()}%)',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${topic.totalXP} XP',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    Text(
                      '${topic.timeSpentMinutes} min',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
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
          const Text(
            'Predictions & Goals',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        backgroundColor: Colors.blue[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_graph, color: Colors.blue, size: AppIconSizes.md),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    prediction.message,
                    style: const TextStyle(
                      fontSize: 15,
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
                    color: Colors.blue,
                    borderRadius: AppRadius.mediumRadius,
                  ),
                  child: Text(
                    prediction.confidenceLabel,
                    style: const TextStyle(fontSize: 11, color: Colors.white),
                  ),
                ),
                if (prediction.estimatedDate != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'ETA: ${DateFormat('MMM d').format(prediction.estimatedDate!)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ],
            ),
            if (prediction.recommendation != null) ...[
              const SizedBox(height: 12),
              Text(
                prediction.recommendation!,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
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
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export as CSV'),
              subtitle: const Text('Spreadsheet-friendly format'),
              onTap: () async {
                Navigator.pop(context);
                await _exportAsCSV(summary);
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Export as JSON'),
              subtitle: const Text('Technical format'),
              onTap: () async {
                Navigator.pop(context);
                await _exportAsJson(summary);
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Share Progress Report'),
              subtitle: const Text('Human-readable text'),
              onTap: () async {
                Navigator.pop(context);
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
      debugPrint('Export failed: $e');
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
      debugPrint('CSV Export failed: $e');
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

  /// Sample profile for testing (replace with real data from state management)
  UserProfile _getSampleProfile() {
    final now = DateTime.now();
    final dailyXpHistory = <String, int>{};

    // Generate sample data for the last 90 days
    for (int i = 0; i < 90; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      // Random XP between 0 and 150
      final xp = (i % 3 == 0) ? 0 : 30 + (i * 7) % 100;
      dailyXpHistory[dateKey] = xp;
    }

    return UserProfile(
      id: 'sample',
      name: 'Sample User',
      totalXp: 2450,
      currentStreak: 12,
      longestStreak: 28,
      completedLessons: ['lesson1', 'lesson2', 'lesson3', 'lesson4', 'lesson5'],
      dailyXpHistory: dailyXpHistory,
      createdAt: now.subtract(const Duration(days: 90)),
      updatedAt: now,
    );
  }
}
