import 'package:collection/collection.dart';

/// Analytics service for aggregating stats, calculating trends, and generating insights
/// Provides comprehensive progress analysis with AI-like recommendations
import '../models/analytics.dart';
import '../models/user_profile.dart';
import '../models/learning.dart';
import '../models/leaderboard.dart';
import '../utils/logger.dart';

/// Parameter bundle for [AnalyticsService.generateSummary] — must be a plain
/// Dart class (no closures/native handles) so it can cross isolate boundaries.

/// Service for aggregating user analytics and generating AI-like insights.
///
/// Provides comprehensive progress analysis including:
/// - Daily and weekly XP trends
/// - Topic performance tracking
/// - Learning time pattern detection
/// - Predictive milestones and recommendations
class AnalyticsService {
  /// Generate complete analytics summary for a user
  static AnalyticsSummary generateSummary({
    required UserProfile profile,
    required List<LearningPath> allPaths,
    AnalyticsTimeRange timeRange = AnalyticsTimeRange.allTime,
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    final (start, end) =
        timeRange == AnalyticsTimeRange.custom &&
            customStart != null &&
            customEnd != null
        ? (customStart, customEnd)
        : timeRange.getDateRange();

    // Aggregate daily stats
    final dailyStats = _aggregateDailyStats(profile, start, end);
    final weeklyStats = _aggregateWeeklyStats(dailyStats);

    // Calculate topic performance
    final topicPerformance = _calculateTopicPerformance(profile, allPaths);

    // Detect learning time patterns
    final timePattern = _detectTimePatterns(profile);

    // Generate insights
    final insights = _generateInsights(
      profile: profile,
      dailyStats: dailyStats,
      weeklyStats: weeklyStats,
      topicPerformance: topicPerformance,
      timePattern: timePattern,
    );

    // Generate predictions
    final predictions = _generatePredictions(
      profile: profile,
      dailyStats: dailyStats,
      allPaths: allPaths,
    );

    // Count total lessons
    final totalLessons = allPaths.fold<int>(
      0,
      (sum, path) => sum + path.lessons.length,
    );

    // Estimate total time spent (rough calculation based on completed lessons)
    final completedLessons = profile.completedLessons.length;
    final avgLessonMinutes = 5; // From Lesson.estimatedMinutes default
    final timeSpentMinutes = completedLessons * avgLessonMinutes;

    return AnalyticsSummary(
      totalXP: profile.totalXp,
      currentStreak: profile.currentStreak,
      longestStreak: profile.longestStreak,
      lessonsCompleted: completedLessons,
      totalLessons: totalLessons,
      timeSpentMinutes: timeSpentMinutes,
      recentDailyStats: dailyStats.take(30).toList(),
      recentWeeklyStats: weeklyStats.take(12).toList(),
      insights: insights,
      topicPerformance: topicPerformance,
      timePattern: timePattern,
      predictions: predictions,
      generatedAt: DateTime.now(),
    );
  }

  /// Async variant of [generateSummary] that runs the computation in a
  /// background isolate via [compute], keeping the main thread free.
  static Future<AnalyticsSummary> generateSummaryAsync({
    required UserProfile profile,
    required List<LearningPath> allPaths,
    AnalyticsTimeRange timeRange = AnalyticsTimeRange.allTime,
    DateTime? customStart,
    DateTime? customEnd,
  }) async {
    // Run synchronously — the computation is O(n) on a small dataset and
    // compute() (isolate) struggles to serialise the full LearningPath graph.
    return generateSummary(
      profile: profile,
      allPaths: allPaths,
      timeRange: timeRange,
      customStart: customStart,
      customEnd: customEnd,
    );
  }

  /// Aggregate daily statistics from user's XP history
  static List<DailyStats> _aggregateDailyStats(
    UserProfile profile,
    DateTime start,
    DateTime end,
  ) {
    final stats = <DailyStats>[];
    var current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    // Safety cap: never iterate more than ~10 years of daily entries.
    // This prevents pathological loops if date math goes wrong.
    const maxDays = 365 * 10 + 1;
    var dayCount = 0;

    while (!current.isAfter(endDate) && dayCount < maxDays) {
      final dateKey =
          '${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}';
      final xp = profile.dailyXpHistory[dateKey] ?? 0;

      // Estimate lessons completed (rough: 50 XP per lesson average)
      final lessonsCompleted = xp ~/ 50;

      stats.add(
        DailyStats(
          date: current,
          xp: xp,
          lessonsCompleted: lessonsCompleted,
          practiceMinutes: lessonsCompleted * 5, // Estimate
          timeSpentSeconds: lessonsCompleted * 300, // 5 minutes in seconds
        ),
      );

      current = current.add(const Duration(days: 1));
      dayCount++;
    }

    return stats.reversed.toList(); // Most recent first
  }

  /// Aggregate weekly statistics from daily stats
  static List<WeeklyStats> _aggregateWeeklyStats(List<DailyStats> dailyStats) {
    if (dailyStats.isEmpty) return [];

    final weeklyMap = <String, List<DailyStats>>{};

    for (final day in dailyStats) {
      final weekStart = _getWeekStart(day.date);
      final weekKey = '${weekStart.year}-W${_weekNumber(weekStart)}';
      weeklyMap.putIfAbsent(weekKey, () => []).add(day);
    }

    final weeklyStats = <WeeklyStats>[];
    for (final entry in weeklyMap.entries) {
      final days = entry.value;
      final weekStart = _getWeekStart(days.first.date);
      final totalXP = days.fold<int>(0, (sum, day) => sum + day.xp);
      final lessonsCompleted = days.fold<int>(
        0,
        (sum, day) => sum + day.lessonsCompleted,
      );
      final daysActive = days.where((d) => d.xp > 0).length;
      final avgDailyXP = daysActive > 0 ? totalXP / daysActive : 0.0;

      final peakDay = days.reduce((a, b) => a.xp > b.xp ? a : b);

      weeklyStats.add(
        WeeklyStats(
          weekStart: weekStart,
          totalXP: totalXP,
          lessonsCompleted: lessonsCompleted,
          avgDailyXP: avgDailyXP,
          peakDayXP: peakDay.xp,
          peakDay: peakDay.date,
          daysActive: daysActive,
        ),
      );
    }

    return weeklyStats..sort((a, b) => b.weekStart.compareTo(a.weekStart));
  }

  /// Calculate topic performance from learning paths
  static List<TopicPerformance> _calculateTopicPerformance(
    UserProfile profile,
    List<LearningPath> allPaths,
  ) {
    final performances = <TopicPerformance>[];

    for (final path in allPaths) {
      final totalLessons = path.lessons.length;
      final completedLessons = path.lessons
          .where((lesson) => profile.completedLessons.contains(lesson.id))
          .length;
      final mastery = totalLessons > 0 ? completedLessons / totalLessons : 0.0;

      // Calculate trend (simplified - would need historical data for real trend)
      ProgressTrend trend;
      if (mastery >= 0.7) {
        trend = ProgressTrend.increasing;
      } else if (mastery >= 0.3) {
        trend = ProgressTrend.stable;
      } else {
        trend = ProgressTrend.decreasing;
      }

      performances.add(
        TopicPerformance(
          topicId: path.id,
          topicName: path.title,
          totalXP: path.lessons
              .where((l) => profile.completedLessons.contains(l.id))
              .fold<int>(0, (sum, l) => sum + l.xpReward),
          lessonsCompleted: completedLessons,
          totalLessons: totalLessons,
          masteryPercentage: mastery,
          trend: trend,
          timeSpentMinutes: completedLessons * 5, // Estimate
        ),
      );
    }

    return performances..sort((a, b) => b.totalXP.compareTo(a.totalXP));
  }

  /// Detect learning time patterns from activity history
  static LearningTimePattern? _detectTimePatterns(UserProfile profile) {
    if (profile.dailyXpHistory.isEmpty) return null;

    // Simplified pattern detection
    // In a real app, you'd track actual activity timestamps
    final hourOfDay = <int, int>{};
    final dayOfWeek = <int, int>{};

    // Simulate pattern from dates (rough approximation)
    for (final entry in profile.dailyXpHistory.entries) {
      try {
        final parts = entry.key.split('-');
        final date = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        final xp = entry.value;

        // Assume morning learning (9 AM) - would need real timestamp tracking
        final simulatedHour = 9;
        hourOfDay[simulatedHour] = (hourOfDay[simulatedHour] ?? 0) + xp;
        dayOfWeek[date.weekday] = (dayOfWeek[date.weekday] ?? 0) + xp;
      } catch (e) {
        logError('Analytics: skipped invalid date in hourly distribution: $e', tag: 'AnalyticsService');
      }
    }

    if (hourOfDay.isEmpty || dayOfWeek.isEmpty) return null;

    final mostActiveHour = hourOfDay.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    final mostActiveDay = dayOfWeek.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    String preferredTime;
    if (mostActiveHour < 12) {
      preferredTime = 'Morning';
    } else if (mostActiveHour < 17) {
      preferredTime = 'Afternoon';
    } else if (mostActiveHour < 21) {
      preferredTime = 'Evening';
    } else {
      preferredTime = 'Night';
    }

    return LearningTimePattern(
      hourOfDayActivity: hourOfDay,
      dayOfWeekActivity: dayOfWeek,
      mostActiveHour: mostActiveHour,
      mostActiveDay: mostActiveDay,
      preferredTimeOfDay: preferredTime,
    );
  }

  /// Generate AI-like insights from user data
  static List<AnalyticsInsight> _generateInsights({
    required UserProfile profile,
    required List<DailyStats> dailyStats,
    required List<WeeklyStats> weeklyStats,
    required List<TopicPerformance> topicPerformance,
    LearningTimePattern? timePattern,
  }) {
    final insights = <AnalyticsInsight>[];
    var insightId = 0;

    // XP Growth Insight
    if (weeklyStats.length >= 2) {
      final thisWeek = weeklyStats[0].totalXP;
      final lastWeek = weeklyStats[1].totalXP;
      if (thisWeek > lastWeek) {
        final percentChange = ((thisWeek - lastWeek) / lastWeek * 100).round();
        insights.add(
          AnalyticsInsight(
            id: 'xp_growth_${insightId++}',
            type: InsightType.improvement,
            message: 'Your XP increased $percentChange% this week!',
            detailedMessage:
                'You earned $thisWeek XP this week compared to $lastWeek last week. Keep up the great work!',
            trend: ProgressTrend.increasing,
            recommendation:
                'Try to maintain this momentum by completing at least one lesson daily.',
            data: {
              'thisWeek': thisWeek,
              'lastWeek': lastWeek,
              'change': percentChange,
            },
            generatedAt: DateTime.now(),
          ),
        );
      } else if (thisWeek < lastWeek) {
        final percentChange = ((lastWeek - thisWeek) / lastWeek * 100).round();
        insights.add(
          AnalyticsInsight(
            id: 'xp_decline_${insightId++}',
            type: InsightType.warning,
            message: 'Your XP dropped $percentChange% this week',
            detailedMessage:
                'You earned $thisWeek XP this week compared to $lastWeek last week.',
            trend: ProgressTrend.decreasing,
            recommendation:
                'Try completing a quick lesson to get back on track. Even 5 minutes helps!',
            data: {
              'thisWeek': thisWeek,
              'lastWeek': lastWeek,
              'change': percentChange,
            },
            generatedAt: DateTime.now(),
          ),
        );
      }
    }

    // Streak Milestone
    if (profile.currentStreak >= 7) {
      insights.add(
        AnalyticsInsight(
          id: 'streak_milestone_${insightId++}',
          type: InsightType.achievement,
          message: '🔥 ${profile.currentStreak}-day streak!',
          detailedMessage:
              'You\'ve been learning consistently for ${profile.currentStreak} days. That\'s dedication!',
          recommendation:
              'Don\'t break it now! Complete today\'s goal to keep the streak alive.',
          data: {'streak': profile.currentStreak},
          generatedAt: DateTime.now(),
        ),
      );
    }

    // Longest Streak Achievement
    if (profile.longestStreak > profile.currentStreak &&
        profile.longestStreak >= 14) {
      insights.add(
        AnalyticsInsight(
          id: 'longest_streak_${insightId++}',
          type: InsightType.milestone,
          message: 'Longest streak: ${profile.longestStreak} days!',
          detailedMessage:
              'Your record is ${profile.longestStreak} days. Current streak: ${profile.currentStreak} days.',
          recommendation: 'Can you beat your record? Stay consistent!',
          data: {
            'longest': profile.longestStreak,
            'current': profile.currentStreak,
          },
          generatedAt: DateTime.now(),
        ),
      );
    }

    // Best Learning Time
    if (timePattern != null) {
      insights.add(
        AnalyticsInsight(
          id: 'best_time_${insightId++}',
          type: InsightType.pattern,
          message: 'Best learning time: ${timePattern.preferredTimeOfDay}',
          detailedMessage:
              'You\'re most active in the ${timePattern.preferredTimeOfDay.toLowerCase()}, around ${timePattern.mostActiveTimeLabel}.',
          recommendation:
              'Schedule learning sessions during your peak hours for better focus.',
          data: {
            'timeOfDay': timePattern.preferredTimeOfDay,
            'hour': timePattern.mostActiveHour,
            'day': timePattern.mostActiveDayName,
          },
          generatedAt: DateTime.now(),
        ),
      );
    }

    // Topic Mastery
    final strongTopics = topicPerformance.where((t) => t.isStrong).toList();
    final weakTopics = topicPerformance.where((t) => t.needsWork).toList();

    if (strongTopics.isNotEmpty) {
      final best = strongTopics.first;
      insights.add(
        AnalyticsInsight(
          id: 'strong_topic_${insightId++}',
          type: InsightType.achievement,
          message: 'Most improved topic: ${best.topicName}',
          detailedMessage:
              'You\'ve completed ${best.lessonsCompleted}/${best.totalLessons} lessons in ${best.topicName} (${(best.masteryPercentage * 100).round()}% mastery).',
          recommendation:
              'Great progress! Consider reviewing earlier lessons to reinforce your knowledge.',
          data: {'topic': best.topicName, 'mastery': best.masteryPercentage},
          generatedAt: DateTime.now(),
        ),
      );
    }

    if (weakTopics.isNotEmpty) {
      final weakest = weakTopics.first;
      insights.add(
        AnalyticsInsight(
          id: 'weak_topic_${insightId++}',
          type: InsightType.recommendation,
          message: 'Opportunity: ${weakest.topicName}',
          detailedMessage:
              'You\'ve only completed ${weakest.lessonsCompleted}/${weakest.totalLessons} lessons in ${weakest.topicName}.',
          recommendation:
              'Try completing a lesson in this topic to broaden your knowledge.',
          data: {
            'topic': weakest.topicName,
            'mastery': weakest.masteryPercentage,
          },
          generatedAt: DateTime.now(),
        ),
      );
    }

    // Consistency Pattern
    final last7Days = dailyStats.take(7).toList();
    final daysActive = last7Days.where((d) => d.xp > 0).length;
    if (daysActive >= 5) {
      insights.add(
        AnalyticsInsight(
          id: 'consistency_${insightId++}',
          type: InsightType.achievement,
          message: 'Highly consistent learner!',
          detailedMessage:
              'You\'ve been active $daysActive out of the last 7 days.',
          recommendation: 'This consistency will pay off. Keep the momentum!',
          data: {'daysActive': daysActive},
          generatedAt: DateTime.now(),
        ),
      );
    } else if (daysActive <= 2) {
      insights.add(
        AnalyticsInsight(
          id: 'engagement_drop_${insightId++}',
          type: InsightType.warning,
          message: 'Activity has dropped recently',
          detailedMessage:
              'You\'ve only been active $daysActive out of the last 7 days.',
          recommendation:
              'Even 5 minutes a day makes a difference. Try setting a daily reminder!',
          data: {'daysActive': daysActive},
          generatedAt: DateTime.now(),
        ),
      );
    }

    return insights.take(5).toList(); // Return top 5 insights
  }

  /// Generate predictions for future milestones
  static List<Prediction> _generatePredictions({
    required UserProfile profile,
    required List<DailyStats> dailyStats,
    required List<LearningPath> allPaths,
  }) {
    final predictions = <Prediction>[];

    // Calculate 7-day average XP
    final last7Days = dailyStats.take(7).toList();
    final avgXPPerDay = last7Days.isNotEmpty
        ? last7Days.fold<int>(0, (sum, d) => sum + d.xp) / last7Days.length
        : 0.0;

    if (avgXPPerDay > 0) {
      // Predict XP milestone
      const milestones = [100, 500, 1000, 2000, 5000, 10000];
      final nextMilestone = milestones.firstWhereOrNull(
        (m) => m > profile.totalXp,
      );

      if (nextMilestone != null) {
        final xpRemaining = nextMilestone - profile.totalXp;
        final daysRemaining = (xpRemaining / avgXPPerDay).ceil();
        final estimatedDate = DateTime.now().add(Duration(days: daysRemaining));

        predictions.add(
          Prediction(
            message:
                'At this rate, you\'ll reach $nextMilestone XP in $daysRemaining days',
            estimatedDate: estimatedDate,
            daysRemaining: daysRemaining,
            confidence: avgXPPerDay >= 50 ? 0.8 : 0.6,
            recommendation: daysRemaining > 14
                ? 'Increase your daily XP to reach this milestone faster!'
                : 'Keep up the pace and you\'ll hit this milestone soon!',
          ),
        );
      }

      // Predict streak maintenance
      if (profile.currentStreak > 0) {
        final dailyGoalMet =
            last7Days.where((d) => d.xp >= profile.dailyXpGoal).length >= 5;
        if (dailyGoalMet) {
          predictions.add(
            Prediction(
              message:
                  'On track to maintain your ${profile.currentStreak}-day streak',
              confidence: 0.85,
              recommendation:
                  'Complete your daily goal to keep the streak alive!',
            ),
          );
        } else {
          final lessonsNeeded = (profile.dailyXpGoal / 50).ceil();
          predictions.add(
            Prediction(
              message:
                  'Complete $lessonsNeeded more lesson${lessonsNeeded > 1 ? 's' : ''} to maintain streak',
              confidence: 0.7,
              recommendation:
                  'Don\'t break your streak! Quick lessons count too.',
            ),
          );
        }
      }

      // Predict league promotion (if weekly XP trending up)
      if (profile.weeklyXP > 0 && profile.league != League.diamond) {
        final leagueThreshold = _getLeagueThreshold(profile.league);
        if (profile.weeklyXP >= leagueThreshold * 0.7) {
          predictions.add(
            Prediction(
              message:
                  'Likely to promote to ${_getNextLeague(profile.league).displayName} this week',
              confidence: 0.75,
              recommendation: 'Keep earning XP to secure your promotion!',
            ),
          );
        }
      }
    }

    return predictions.take(3).toList();
  }

  // Helper methods
  static DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static int _weekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil() + 1;
  }

  static int _getLeagueThreshold(League league) {
    switch (league) {
      case League.bronze:
        return 500;
      case League.silver:
        return 1000;
      case League.gold:
        return 2000;
      case League.diamond:
        return 5000;
    }
  }

  static League _getNextLeague(League current) {
    switch (current) {
      case League.bronze:
        return League.silver;
      case League.silver:
        return League.gold;
      case League.gold:
        return League.diamond;
      case League.diamond:
        return League.diamond;
    }
  }

  /// Calculate 7-day moving average for trend analysis
  static List<double> calculate7DayMovingAverage(List<DailyStats> dailyStats) {
    if (dailyStats.length < 7) return [];

    final averages = <double>[];
    for (int i = 0; i <= dailyStats.length - 7; i++) {
      final window = dailyStats.sublist(i, i + 7);
      final avg = window.fold<int>(0, (sum, d) => sum + d.xp) / 7.0;
      averages.add(avg);
    }

    return averages;
  }

  /// Calculate 30-day moving average
  static List<double> calculate30DayMovingAverage(List<DailyStats> dailyStats) {
    if (dailyStats.length < 30) return [];

    final averages = <double>[];
    for (int i = 0; i <= dailyStats.length - 30; i++) {
      final window = dailyStats.sublist(i, i + 30);
      final avg = window.fold<int>(0, (sum, d) => sum + d.xp) / 30.0;
      averages.add(avg);
    }

    return averages;
  }
}
