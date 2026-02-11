import 'package:flutter/foundation.dart';

/// Analytics models for progress tracking, insights, and trend analysis
/// Powers the analytics dashboard with comprehensive learning statistics

/// Daily statistics snapshot
@immutable
class DailyStats {
  final DateTime date;
  final int xp;
  final int lessonsCompleted;
  final int practiceMinutes;
  final int timeSpentSeconds;
  final Map<String, int> topicXp; // XP earned per topic
  final List<String> activitiesCompleted; // Lesson IDs, quiz IDs, etc.

  const DailyStats({
    required this.date,
    required this.xp,
    required this.lessonsCompleted,
    required this.practiceMinutes,
    required this.timeSpentSeconds,
    this.topicXp = const {},
    this.activitiesCompleted = const [],
  });

  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'xp': xp,
    'lessonsCompleted': lessonsCompleted,
    'practiceMinutes': practiceMinutes,
    'timeSpentSeconds': timeSpentSeconds,
    'topicXp': topicXp,
    'activitiesCompleted': activitiesCompleted,
  };

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: DateTime.parse(json['date'] as String),
      xp: json['xp'] as int? ?? 0,
      lessonsCompleted: json['lessonsCompleted'] as int? ?? 0,
      practiceMinutes: json['practiceMinutes'] as int? ?? 0,
      timeSpentSeconds: json['timeSpentSeconds'] as int? ?? 0,
      topicXp:
          (json['topicXp'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int),
          ) ??
          {},
      activitiesCompleted:
          (json['activitiesCompleted'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

/// Weekly aggregated statistics
@immutable
class WeeklyStats {
  final DateTime weekStart; // Monday of the week
  final int totalXP;
  final int lessonsCompleted;
  final double avgDailyXP;
  final int peakDayXP;
  final DateTime peakDay;
  final int daysActive; // Days with any XP
  final Map<String, int> topicXp;

  const WeeklyStats({
    required this.weekStart,
    required this.totalXP,
    required this.lessonsCompleted,
    required this.avgDailyXP,
    required this.peakDayXP,
    required this.peakDay,
    required this.daysActive,
    this.topicXp = const {},
  });

  String get weekKey => '${weekStart.year}-W${_weekNumber(weekStart)}';

  static int _weekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil() + 1;
  }

  Map<String, dynamic> toJson() => {
    'weekStart': weekStart.toIso8601String(),
    'totalXP': totalXP,
    'lessonsCompleted': lessonsCompleted,
    'avgDailyXP': avgDailyXP,
    'peakDayXP': peakDayXP,
    'peakDay': peakDay.toIso8601String(),
    'daysActive': daysActive,
    'topicXp': topicXp,
  };

  factory WeeklyStats.fromJson(Map<String, dynamic> json) {
    return WeeklyStats(
      weekStart: DateTime.parse(json['weekStart'] as String),
      totalXP: json['totalXP'] as int? ?? 0,
      lessonsCompleted: json['lessonsCompleted'] as int? ?? 0,
      avgDailyXP: (json['avgDailyXP'] as num?)?.toDouble() ?? 0.0,
      peakDayXP: json['peakDayXP'] as int? ?? 0,
      peakDay: DateTime.parse(json['peakDay'] as String),
      daysActive: json['daysActive'] as int? ?? 0,
      topicXp:
          (json['topicXp'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int),
          ) ??
          {},
    );
  }
}

/// Monthly aggregated statistics
@immutable
class MonthlyStats {
  final DateTime month; // First day of the month
  final int totalXP;
  final int lessonsCompleted;
  final double avgDailyXP;
  final int daysActive;
  final int longestStreak;
  final Map<String, int> topicXp;

  const MonthlyStats({
    required this.month,
    required this.totalXP,
    required this.lessonsCompleted,
    required this.avgDailyXP,
    required this.daysActive,
    required this.longestStreak,
    this.topicXp = const {},
  });

  String get monthKey =>
      '${month.year}-${month.month.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
    'month': month.toIso8601String(),
    'totalXP': totalXP,
    'lessonsCompleted': lessonsCompleted,
    'avgDailyXP': avgDailyXP,
    'daysActive': daysActive,
    'longestStreak': longestStreak,
    'topicXp': topicXp,
  };

  factory MonthlyStats.fromJson(Map<String, dynamic> json) {
    return MonthlyStats(
      month: DateTime.parse(json['month'] as String),
      totalXP: json['totalXP'] as int? ?? 0,
      lessonsCompleted: json['lessonsCompleted'] as int? ?? 0,
      avgDailyXP: (json['avgDailyXP'] as num?)?.toDouble() ?? 0.0,
      daysActive: json['daysActive'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      topicXp:
          (json['topicXp'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int),
          ) ??
          {},
    );
  }
}

/// Trend direction for analytics insights
enum ProgressTrend { increasing, stable, decreasing }

extension ProgressTrendExt on ProgressTrend {
  String get emoji {
    switch (this) {
      case ProgressTrend.increasing:
        return '📈';
      case ProgressTrend.stable:
        return '➡️';
      case ProgressTrend.decreasing:
        return '📉';
    }
  }

  String get displayName {
    switch (this) {
      case ProgressTrend.increasing:
        return 'Increasing';
      case ProgressTrend.stable:
        return 'Stable';
      case ProgressTrend.decreasing:
        return 'Decreasing';
    }
  }
}

/// Types of analytics insights
enum InsightType {
  achievement, // Milestone reached
  improvement, // Positive change
  warning, // Engagement drop
  recommendation, // Suggested action
  pattern, // Behavioral pattern detected
  milestone, // Major accomplishment
}

extension InsightTypeExt on InsightType {
  String get emoji {
    switch (this) {
      case InsightType.achievement:
        return '🎉';
      case InsightType.improvement:
        return '📈';
      case InsightType.warning:
        return '⚠️';
      case InsightType.recommendation:
        return '💡';
      case InsightType.pattern:
        return '🔍';
      case InsightType.milestone:
        return '🏆';
    }
  }
}

/// AI-generated insight with recommendations
@immutable
class AnalyticsInsight {
  final String id;
  final InsightType type;
  final String message;
  final String? detailedMessage; // Longer explanation
  final ProgressTrend? trend;
  final String? recommendation;
  final Map<String, dynamic>? data; // Supporting data (XP change, etc.)
  final DateTime generatedAt;

  const AnalyticsInsight({
    required this.id,
    required this.type,
    required this.message,
    this.detailedMessage,
    this.trend,
    this.recommendation,
    this.data,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'message': message,
    'detailedMessage': detailedMessage,
    'trend': trend?.name,
    'recommendation': recommendation,
    'data': data,
    'generatedAt': generatedAt.toIso8601String(),
  };

  factory AnalyticsInsight.fromJson(Map<String, dynamic> json) {
    return AnalyticsInsight(
      id: json['id'] as String,
      type: InsightType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => InsightType.pattern,
      ),
      message: json['message'] as String,
      detailedMessage: json['detailedMessage'] as String?,
      trend: json['trend'] != null
          ? ProgressTrend.values.firstWhere(
              (e) => e.name == json['trend'],
              orElse: () => ProgressTrend.stable,
            )
          : null,
      recommendation: json['recommendation'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }
}

/// Learning time pattern analysis
@immutable
class LearningTimePattern {
  final Map<int, int> hourOfDayActivity; // Hour (0-23) -> XP earned
  final Map<int, int> dayOfWeekActivity; // Weekday (1-7) -> XP earned
  final int mostActiveHour;
  final int mostActiveDay;
  final String preferredTimeOfDay; // Morning/Afternoon/Evening/Night

  const LearningTimePattern({
    required this.hourOfDayActivity,
    required this.dayOfWeekActivity,
    required this.mostActiveHour,
    required this.mostActiveDay,
    required this.preferredTimeOfDay,
  });

  String get mostActiveDayName {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[mostActiveDay - 1];
  }

  String get mostActiveTimeLabel {
    final hour = mostActiveHour;
    if (hour < 12) return '$hour:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }
}

/// Topic performance analysis
@immutable
class TopicPerformance {
  final String topicId;
  final String topicName;
  final int totalXP;
  final int lessonsCompleted;
  final int totalLessons;
  final double masteryPercentage;
  final ProgressTrend trend;
  final int timeSpentMinutes;

  const TopicPerformance({
    required this.topicId,
    required this.topicName,
    required this.totalXP,
    required this.lessonsCompleted,
    required this.totalLessons,
    required this.masteryPercentage,
    required this.trend,
    required this.timeSpentMinutes,
  });

  bool get isStrong => masteryPercentage >= 0.7;
  bool get needsWork => masteryPercentage < 0.4;
}

/// Prediction for future milestones
@immutable
class Prediction {
  final String message;
  final DateTime? estimatedDate;
  final int? daysRemaining;
  final double confidence; // 0.0 - 1.0
  final String? recommendation;

  const Prediction({
    required this.message,
    this.estimatedDate,
    this.daysRemaining,
    required this.confidence,
    this.recommendation,
  });

  String get confidenceLabel {
    if (confidence >= 0.8) return 'Very likely';
    if (confidence >= 0.6) return 'Likely';
    if (confidence >= 0.4) return 'Possible';
    return 'Uncertain';
  }
}

/// Complete analytics summary
@immutable
class AnalyticsSummary {
  final int totalXP;
  final int currentStreak;
  final int longestStreak;
  final int lessonsCompleted;
  final int totalLessons;
  final int timeSpentMinutes;
  final List<DailyStats> recentDailyStats;
  final List<WeeklyStats> recentWeeklyStats;
  final List<AnalyticsInsight> insights;
  final List<TopicPerformance> topicPerformance;
  final LearningTimePattern? timePattern;
  final List<Prediction> predictions;
  final DateTime generatedAt;

  const AnalyticsSummary({
    required this.totalXP,
    required this.currentStreak,
    required this.longestStreak,
    required this.lessonsCompleted,
    required this.totalLessons,
    required this.timeSpentMinutes,
    required this.recentDailyStats,
    required this.recentWeeklyStats,
    required this.insights,
    required this.topicPerformance,
    this.timePattern,
    required this.predictions,
    required this.generatedAt,
  });

  double get completionPercentage {
    if (totalLessons == 0) return 0.0;
    return lessonsCompleted / totalLessons;
  }

  String get timeSpentFormatted {
    final hours = timeSpentMinutes ~/ 60;
    final minutes = timeSpentMinutes % 60;
    if (hours > 0) {
      return '$hours hr $minutes min';
    }
    return '$minutes min';
  }
}

/// Time range selector for analytics
enum AnalyticsTimeRange {
  today,
  thisWeek,
  thisMonth,
  allTime,
  custom,
  last7Days,
  last30Days,
  last90Days,
}

extension AnalyticsTimeRangeExt on AnalyticsTimeRange {
  String get displayName {
    switch (this) {
      case AnalyticsTimeRange.today:
        return 'Today';
      case AnalyticsTimeRange.thisWeek:
        return 'This Week';
      case AnalyticsTimeRange.thisMonth:
        return 'This Month';
      case AnalyticsTimeRange.allTime:
        return 'All Time';
      case AnalyticsTimeRange.custom:
        return 'Custom';
      case AnalyticsTimeRange.last7Days:
        return 'Last 7 Days';
      case AnalyticsTimeRange.last30Days:
        return 'Last 30 Days';
      case AnalyticsTimeRange.last90Days:
        return 'Last 90 Days';
    }
  }

  (DateTime, DateTime) getDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (this) {
      case AnalyticsTimeRange.today:
        return (today, now);
      case AnalyticsTimeRange.thisWeek:
        final weekStart = today.subtract(Duration(days: now.weekday - 1));
        return (weekStart, now);
      case AnalyticsTimeRange.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        return (monthStart, now);
      case AnalyticsTimeRange.last7Days:
        return (today.subtract(const Duration(days: 7)), now);
      case AnalyticsTimeRange.last30Days:
        return (today.subtract(const Duration(days: 30)), now);
      case AnalyticsTimeRange.last90Days:
        return (today.subtract(const Duration(days: 90)), now);
      case AnalyticsTimeRange.allTime:
        return (DateTime(2020), now); // Arbitrary start date
      case AnalyticsTimeRange.custom:
        return (today, now); // Default, should be overridden
    }
  }
}
