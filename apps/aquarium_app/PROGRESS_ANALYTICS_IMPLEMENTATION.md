# Progress Analytics Dashboard - Implementation Guide

## Overview

The Progress Analytics Dashboard provides visual insights into the user's learning journey, helping them understand patterns, strengths, weaknesses, and engagement trends.

**Key Features:**
- 📊 Visual analytics (XP trends, completion rates, quiz accuracy)
- 🧠 Auto-generated insights ("You learn best in the morning!")
- 📈 Comparative metrics (week-over-week, month-over-month)
- 🗓️ Activity heatmaps and streak visualization
- 📤 Export analytics as PDF/image

---

## Architecture

### 1. Data Models

#### `AnalyticsData` Model

**Location:** `/lib/models/analytics_data.dart`

```dart
import 'package:flutter/foundation.dart';

/// Aggregated analytics data for the user's learning progress
@immutable
class AnalyticsData {
  // XP History (last 90 days)
  final Map<String, int> xpHistory; // 'YYYY-MM-DD' -> XP earned
  
  // Lesson Completion Rates by Path
  final Map<String, PathProgress> pathProgress; // pathId -> PathProgress
  
  // Quiz Accuracy by Topic/Path
  final Map<String, QuizStats> quizAccuracy; // pathId -> QuizStats
  
  // Study Time Distribution (hour of day 0-23)
  final Map<int, int> studyTimeByHour; // hour -> minutes studied
  
  // Study Time Distribution (day of week 1-7, Monday=1)
  final Map<int, int> studyTimeByWeekday; // weekday -> minutes studied
  
  // Streak History (last 90 days)
  final Map<String, int> streakHistory; // 'YYYY-MM-DD' -> XP earned
  
  // Lesson Completion Timestamps
  final Map<String, DateTime> lessonCompletionDates; // lessonId -> completedDate
  
  const AnalyticsData({
    required this.xpHistory,
    required this.pathProgress,
    required this.quizAccuracy,
    required this.studyTimeByHour,
    required this.studyTimeByWeekday,
    required this.streakHistory,
    required this.lessonCompletionDates,
  });
  
  /// Generate analytics from UserProfile
  factory AnalyticsData.fromUserProfile(UserProfile profile) {
    // Calculate path progress
    final pathProgress = <String, PathProgress>{};
    for (final path in LessonContent.allPaths) {
      final completedInPath = profile.completedLessons
          .where((lessonId) => path.lessons.any((l) => l.id == lessonId))
          .length;
      pathProgress[path.id] = PathProgress(
        pathId: path.id,
        totalLessons: path.lessons.length,
        completedLessons: completedInPath,
      );
    }
    
    // Estimate study time distribution from completion dates
    final studyByHour = <int, int>{};
    final studyByWeekday = <int, int>{};
    
    for (final progress in profile.lessonProgress.values) {
      final hour = progress.completedDate.hour;
      final weekday = progress.completedDate.weekday;
      
      // Estimate 5-10 minutes per lesson
      studyByHour[hour] = (studyByHour[hour] ?? 0) + 7;
      studyByWeekday[weekday] = (studyByWeekday[weekday] ?? 0) + 7;
    }
    
    // Extract lesson completion dates
    final completionDates = <String, DateTime>{};
    for (final entry in profile.lessonProgress.entries) {
      completionDates[entry.key] = entry.value.completedDate;
    }
    
    return AnalyticsData(
      xpHistory: profile.dailyXpHistory,
      pathProgress: pathProgress,
      quizAccuracy: {}, // TODO: Implement quiz tracking
      studyTimeByHour: studyByHour,
      studyTimeByWeekday: studyByWeekday,
      streakHistory: profile.dailyXpHistory,
      lessonCompletionDates: completionDates,
    );
  }
  
  /// Total XP earned
  int get totalXp => xpHistory.values.fold(0, (sum, xp) => sum + xp);
  
  /// Total lessons completed
  int get totalLessonsCompleted => 
      pathProgress.values.fold(0, (sum, p) => sum + p.completedLessons);
  
  /// Average XP per day (last 30 days)
  double get averageXpPerDay {
    final last30Days = _getLastNDays(30);
    final xpSum = last30Days.fold(0, (sum, date) {
      return sum + (xpHistory[_formatDate(date)] ?? 0);
    });
    return xpSum / 30;
  }
  
  /// Best hour for studying (hour with most activity)
  int? get bestStudyHour {
    if (studyTimeByHour.isEmpty) return null;
    return studyTimeByHour.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
  
  /// Best day for studying (weekday with most activity)
  int? get bestStudyDay {
    if (studyTimeByWeekday.isEmpty) return null;
    return studyTimeByWeekday.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
  
  /// Calculate XP growth (compare last 7 days vs previous 7 days)
  double get xpGrowthRate {
    final last7 = _getXpForDateRange(0, 7);
    final prev7 = _getXpForDateRange(7, 14);
    
    if (prev7 == 0) return last7 > 0 ? 1.0 : 0.0;
    return (last7 - prev7) / prev7;
  }
  
  List<DateTime> _getLastNDays(int n) {
    final now = DateTime.now();
    return List.generate(n, (i) => now.subtract(Duration(days: i)));
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  int _getXpForDateRange(int startDaysAgo, int endDaysAgo) {
    final now = DateTime.now();
    int total = 0;
    for (int i = startDaysAgo; i < endDaysAgo; i++) {
      final date = now.subtract(Duration(days: i));
      total += xpHistory[_formatDate(date)] ?? 0;
    }
    return total;
  }
}

/// Progress for a specific learning path
@immutable
class PathProgress {
  final String pathId;
  final int totalLessons;
  final int completedLessons;
  
  const PathProgress({
    required this.pathId,
    required this.totalLessons,
    required this.completedLessons,
  });
  
  double get completionRate => 
      totalLessons > 0 ? completedLessons / totalLessons : 0.0;
  
  int get remainingLessons => totalLessons - completedLessons;
}

/// Quiz statistics for a path/topic
@immutable
class QuizStats {
  final String pathId;
  final int totalQuizzes;
  final int passedQuizzes;
  final int totalQuestions;
  final int correctAnswers;
  
  const QuizStats({
    required this.pathId,
    required this.totalQuizzes,
    required this.passedQuizzes,
    required this.totalQuestions,
    required this.correctAnswers,
  });
  
  double get passRate => 
      totalQuizzes > 0 ? passedQuizzes / totalQuizzes : 0.0;
  
  double get accuracy => 
      totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0;
}
```

---

### 2. Insights Engine

#### `AnalyticsInsights` Class

**Location:** `/lib/utils/analytics_insights.dart`

```dart
import '../models/analytics_data.dart';
import '../models/user_profile.dart';
import 'package:intl/intl.dart';

/// Auto-generated insights from analytics data
class AnalyticsInsights {
  final AnalyticsData analytics;
  final UserProfile profile;
  
  const AnalyticsInsights({
    required this.analytics,
    required this.profile,
  });
  
  /// Generate all insights
  List<Insight> generateInsights() {
    final insights = <Insight>[];
    
    // Streak insights
    insights.addAll(_generateStreakInsights());
    
    // Learning pattern insights
    insights.addAll(_generateLearningPatternInsights());
    
    // Progress insights
    insights.addAll(_generateProgressInsights());
    
    // Performance insights
    insights.addAll(_generatePerformanceInsights());
    
    return insights..sort((a, b) => b.priority.compareTo(a.priority));
  }
  
  List<Insight> _generateStreakInsights() {
    final insights = <Insight>[];
    final currentStreak = profile.currentStreak;
    final longestStreak = profile.longestStreak;
    
    // Current streak achievement
    if (currentStreak >= 7) {
      insights.add(Insight(
        title: '🔥 On Fire!',
        message: 'You\'re on a $currentStreak day streak! Keep it going!',
        category: InsightCategory.motivation,
        priority: 10,
      ));
    }
    
    // Approaching longest streak
    if (currentStreak >= longestStreak - 2 && currentStreak < longestStreak) {
      insights.add(Insight(
        title: '🎯 Almost There!',
        message: 'Just ${longestStreak - currentStreak} more days to beat your record of $longestStreak days!',
        category: InsightCategory.motivation,
        priority: 9,
      ));
    }
    
    // New personal record
    if (currentStreak > longestStreak) {
      insights.add(Insight(
        title: '🏆 New Record!',
        message: 'You\'ve set a new personal best with a $currentStreak day streak!',
        category: InsightCategory.achievement,
        priority: 10,
      ));
    }
    
    return insights;
  }
  
  List<Insight> _generateLearningPatternInsights() {
    final insights = <Insight>[];
    
    // Best time of day
    final bestHour = analytics.bestStudyHour;
    if (bestHour != null) {
      final timeOfDay = _getTimeOfDayName(bestHour);
      insights.add(Insight(
        title: '⏰ Peak Performance',
        message: 'You learn best in the $timeOfDay (${_formatHour(bestHour)}). Try scheduling lessons then!',
        category: InsightCategory.pattern,
        priority: 7,
      ));
    }
    
    // Best day of week
    final bestDay = analytics.bestStudyDay;
    if (bestDay != null) {
      final dayName = DateFormat('EEEE').format(DateTime(2024, 1, bestDay));
      insights.add(Insight(
        title: '📅 Favorite Day',
        message: 'You\'re most active on ${dayName}s!',
        category: InsightCategory.pattern,
        priority: 6,
      ));
    }
    
    // Consistency check
    final xpGrowth = analytics.xpGrowthRate;
    if (xpGrowth > 0.2) {
      insights.add(Insight(
        title: '📈 Accelerating!',
        message: 'You\'re earning ${(xpGrowth * 100).toStringAsFixed(0)}% more XP this week than last week!',
        category: InsightCategory.progress,
        priority: 8,
      ));
    } else if (xpGrowth < -0.2) {
      insights.add(Insight(
        title: '💡 Keep Going',
        message: 'Your activity has dropped ${(xpGrowth.abs() * 100).toStringAsFixed(0)}% this week. Even 5 minutes helps!',
        category: InsightCategory.motivation,
        priority: 8,
      ));
    }
    
    return insights;
  }
  
  List<Insight> _generateProgressInsights() {
    final insights = <Insight>[];
    
    // Path completion
    final pathProgress = analytics.pathProgress.values.toList()
      ..sort((a, b) => b.completionRate.compareTo(a.completionRate));
    
    if (pathProgress.isNotEmpty) {
      final bestPath = pathProgress.first;
      if (bestPath.completionRate > 0.8) {
        insights.add(Insight(
          title: '🌟 Almost Done!',
          message: 'You\'re ${(bestPath.completionRate * 100).toStringAsFixed(0)}% through ${_getPathName(bestPath.pathId)}!',
          category: InsightCategory.progress,
          priority: 7,
        ));
      }
    }
    
    // Total lessons milestone
    final totalLessons = analytics.totalLessonsCompleted;
    if (totalLessons > 0 && totalLessons % 10 == 0) {
      insights.add(Insight(
        title: '🎓 Milestone Reached!',
        message: 'You\'ve completed $totalLessons lessons. Great progress!',
        category: InsightCategory.achievement,
        priority: 8,
      ));
    }
    
    return insights;
  }
  
  List<Insight> _generatePerformanceInsights() {
    final insights = <Insight>[];
    
    // Average XP per day
    final avgXp = analytics.averageXpPerDay;
    if (avgXp > profile.dailyXpGoal) {
      insights.add(Insight(
        title: '💪 Exceeding Goals!',
        message: 'You\'re averaging ${avgXp.toStringAsFixed(0)} XP/day, above your ${profile.dailyXpGoal} XP goal!',
        category: InsightCategory.achievement,
        priority: 7,
      ));
    }
    
    return insights;
  }
  
  String _getTimeOfDayName(int hour) {
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }
  
  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:00 $period';
  }
  
  String _getPathName(String pathId) {
    // TODO: Look up from LessonContent
    return pathId.replaceAll('_', ' ').replaceAll('-', ' ');
  }
}

/// A single insight
@immutable
class Insight {
  final String title;
  final String message;
  final InsightCategory category;
  final int priority; // Higher = shown first
  
  const Insight({
    required this.title,
    required this.message,
    required this.category,
    this.priority = 5,
  });
}

enum InsightCategory {
  motivation,   // Encouragement, streak reminders
  pattern,      // Learning patterns (time of day, etc.)
  progress,     // Completion rates, milestones
  achievement,  // Personal records, goals met
  performance,  // Quiz accuracy, XP trends
}
```

---

## UI Implementation

### 3. Analytics Screen with Tabs

**Location:** `/lib/screens/analytics_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/analytics_data.dart';
import '../models/user_profile.dart';
import '../providers/user_profile_provider.dart';
import '../utils/analytics_insights.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Export',
            onPressed: () => _showExportDialog(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Learning'),
            Tab(text: 'Engagement'),
            Tab(text: 'Time'),
          ],
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No profile data'));
          }

          final analytics = AnalyticsData.fromUserProfile(profile);
          final insights = AnalyticsInsights(
            analytics: analytics,
            profile: profile,
          ).generateInsights();

          return TabBarView(
            controller: _tabController,
            children: [
              _OverviewTab(profile: profile, analytics: analytics, insights: insights),
              _LearningTab(analytics: analytics),
              _EngagementTab(profile: profile, analytics: analytics),
              _TimeTab(analytics: analytics),
            ],
          );
        },
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Analytics'),
        content: const Text('Export your progress data as an image or PDF.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement image export
            },
            child: const Text('Image'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement PDF export
            },
            child: const Text('PDF'),
          ),
        ],
      ),
    );
  }
}

// ============================================
// TAB 1: OVERVIEW
// ============================================

class _OverviewTab extends StatelessWidget {
  final UserProfile profile;
  final AnalyticsData analytics;
  final List<Insight> insights;

  const _OverviewTab({
    required this.profile,
    required this.analytics,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Stats Cards
          _KeyStatsRow(profile: profile, analytics: analytics),
          
          const SizedBox(height: 24),
          
          // Insights Section
          Text('💡 Insights', style: AppTypography.headlineSmall),
          const SizedBox(height: 12),
          if (insights.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Keep learning to unlock insights!'),
              ),
            )
          else
            ...insights.take(3).map((insight) => _InsightCard(insight: insight)),
          
          const SizedBox(height: 24),
          
          // XP Trend (last 30 days)
          Text('📈 XP Trend (Last 30 Days)', style: AppTypography.headlineSmall),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: _XpLineChart(analytics: analytics, days: 30),
          ),
        ],
      ),
    );
  }
}

class _KeyStatsRow extends StatelessWidget {
  final UserProfile profile;
  final AnalyticsData analytics;

  const _KeyStatsRow({required this.profile, required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: '⭐',
            label: 'Total XP',
            value: profile.totalXp.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: '🔥',
            label: 'Streak',
            value: '${profile.currentStreak} days',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: '📚',
            label: 'Lessons',
            value: analytics.totalLessonsCompleted.toString(),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(value, style: AppTypography.headlineMedium),
            Text(label, style: AppTypography.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final Insight insight;

  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(
          _getCategoryIcon(insight.category),
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(insight.title, style: AppTypography.titleMedium),
        subtitle: Text(insight.message),
      ),
    );
  }

  String _getCategoryIcon(InsightCategory category) {
    switch (category) {
      case InsightCategory.motivation:
        return '💪';
      case InsightCategory.pattern:
        return '🔍';
      case InsightCategory.progress:
        return '📈';
      case InsightCategory.achievement:
        return '🏆';
      case InsightCategory.performance:
        return '⚡';
    }
  }
}

// ============================================
// TAB 2: LEARNING
// ============================================

class _LearningTab extends StatelessWidget {
  final AnalyticsData analytics;

  const _LearningTab({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lessons Completed by Path (Bar Chart)
          Text('📚 Lessons by Path', style: AppTypography.headlineSmall),
          const SizedBox(height: 12),
          SizedBox(
            height: 250,
            child: _PathProgressBarChart(analytics: analytics),
          ),
          
          const SizedBox(height: 24),
          
          // Path Completion Rates (List)
          Text('Path Progress', style: AppTypography.headlineSmall),
          const SizedBox(height: 12),
          ...analytics.pathProgress.entries.map((entry) {
            return _PathProgressCard(
              pathId: entry.key,
              progress: entry.value,
            );
          }),
          
          const SizedBox(height: 24),
          
          // Quiz Accuracy (if available)
          Text('Quiz Performance', style: AppTypography.headlineSmall),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Quiz tracking coming soon!'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PathProgressCard extends StatelessWidget {
  final String pathId;
  final PathProgress progress;

  const _PathProgressCard({
    required this.pathId,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatPathName(pathId),
                  style: AppTypography.titleMedium,
                ),
                Text(
                  '${progress.completedLessons}/${progress.totalLessons}',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.completionRate,
              backgroundColor: AppColors.surfaceVariant,
              minHeight: 8,
            ),
            const SizedBox(height: 4),
            Text(
              '${(progress.completionRate * 100).toStringAsFixed(0)}% complete',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _formatPathName(String pathId) {
    return pathId
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}

// ============================================
// TAB 3: ENGAGEMENT
// ============================================

class _EngagementTab extends StatelessWidget {
  final UserProfile profile;
  final AnalyticsData analytics;

  const _EngagementTab({
    required this.profile,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Streak Calendar (Heatmap)
          Text('🔥 Activity Heatmap', style: AppTypography.headlineSmall),
          const SizedBox(height: 12),
          _ActivityHeatmap(analytics: analytics),
          
          const SizedBox(height: 24),
          
          // XP Chart (Last 90 Days)
          Text('📊 XP Over Time', style: AppTypography.headlineSmall),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: _XpLineChart(analytics: analytics, days: 90),
          ),
          
          const SizedBox(height: 24),
          
          // Daily Goal Stats
          Text('🎯 Daily Goals', style: AppTypography.headlineSmall),
          const SizedBox(height: 12),
          _DailyGoalStats(profile: profile),
        ],
      ),
    );
  }
}

class _ActivityHeatmap extends StatelessWidget {
  final AnalyticsData analytics;

  const _ActivityHeatmap({required this.analytics});

  @override
  Widget build(BuildContext context) {
    // Simple 12-week heatmap (similar to GitHub contributions)
    final weeks = 12;
    final cellSize = 12.0;
    final gap = 2.0;
    
    return SizedBox(
      height: (7 * cellSize) + (6 * gap) + 20, // 7 days + labels
      child: Row(
        children: [
          // Day labels
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _DayLabel('Mon', cellSize),
              _DayLabel('Wed', cellSize),
              _DayLabel('Fri', cellSize),
            ],
          ),
          const SizedBox(width: 8),
          // Heatmap grid
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                children: List.generate(weeks, (weekIndex) {
                  return Padding(
                    padding: EdgeInsets.only(right: gap),
                    child: Column(
                      children: List.generate(7, (dayIndex) {
                        final daysAgo = (weeks - weekIndex - 1) * 7 + dayIndex;
                        final date = DateTime.now().subtract(Duration(days: daysAgo));
                        final dateKey = _formatDate(date);
                        final xp = analytics.xpHistory[dateKey] ?? 0;
                        
                        return Padding(
                          padding: EdgeInsets.only(bottom: dayIndex < 6 ? gap : 0),
                          child: _HeatmapCell(xp: xp, size: cellSize),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _DayLabel extends StatelessWidget {
  final String label;
  final double height;

  const _DayLabel(this.label, this.height);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Text(label, style: AppTypography.bodySmall),
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  final int xp;
  final double size;

  const _HeatmapCell({required this.xp, required this.size});

  @override
  Widget build(BuildContext context) {
    final intensity = _getIntensity(xp);
    final color = _getColor(intensity);
    
    return Tooltip(
      message: '$xp XP',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  int _getIntensity(int xp) {
    if (xp == 0) return 0;
    if (xp < 25) return 1;
    if (xp < 50) return 2;
    if (xp < 100) return 3;
    return 4;
  }

  Color _getColor(int intensity) {
    switch (intensity) {
      case 0:
        return AppColors.surfaceVariant;
      case 1:
        return AppColors.primary.withOpacity(0.2);
      case 2:
        return AppColors.primary.withOpacity(0.4);
      case 3:
        return AppColors.primary.withOpacity(0.6);
      case 4:
        return AppColors.primary.withOpacity(0.9);
      default:
        return AppColors.surfaceVariant;
    }
  }
}

class _DailyGoalStats extends StatelessWidget {
  final UserProfile profile;

  const _DailyGoalStats({required this.profile});

  @override
  Widget build(BuildContext context) {
    final last30Days = _getLast30Days();
    final goalsMet = last30Days.where((date) {
      final dateKey = _formatDate(date);
      final xp = profile.dailyXpHistory[dateKey] ?? 0;
      return xp >= profile.dailyXpGoal;
    }).length;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Goals Met (30 days)', style: AppTypography.bodyMedium),
                    Text(
                      '$goalsMet / 30',
                      style: AppTypography.headlineMedium,
                    ),
                  ],
                ),
                CircularProgressIndicator(
                  value: goalsMet / 30,
                  backgroundColor: AppColors.surfaceVariant,
                  strokeWidth: 8,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: goalsMet / 30,
              backgroundColor: AppColors.surfaceVariant,
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }

  List<DateTime> _getLast30Days() {
    final now = DateTime.now();
    return List.generate(30, (i) => now.subtract(Duration(days: i)));
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// ============================================
// TAB 4: TIME
// ============================================

class _TimeTab extends StatelessWidget {
  final AnalyticsData analytics;

  const _TimeTab({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Study Time by Hour (Bar Chart)
          Text('⏰ Study Time by Hour', style: AppTypography.headlineSmall),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: _HourBarChart(analytics: analytics),
          ),
          
          const SizedBox(height: 24),
          
          // Study Time by Weekday (Pie Chart)
          Text('📅 Study Time by Day of Week', style: AppTypography.headlineSmall),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: _WeekdayPieChart(analytics: analytics),
          ),
          
          const SizedBox(height: 24),
          
          // Best Times Summary
          Text('Best Times', style: AppTypography.headlineSmall),
          const SizedBox(height: 12),
          _BestTimesSummary(analytics: analytics),
        ],
      ),
    );
  }
}

class _BestTimesSummary extends StatelessWidget {
  final AnalyticsData analytics;

  const _BestTimesSummary({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final bestHour = analytics.bestStudyHour;
    final bestDay = analytics.bestStudyDay;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (bestHour != null)
              ListTile(
                leading: const Text('⏰', style: TextStyle(fontSize: 32)),
                title: const Text('Best Hour'),
                subtitle: Text(_formatHour(bestHour)),
              ),
            if (bestDay != null)
              ListTile(
                leading: const Text('📅', style: TextStyle(fontSize: 32)),
                title: const Text('Best Day'),
                subtitle: Text(DateFormat('EEEE').format(DateTime(2024, 1, bestDay))),
              ),
            if (bestHour == null && bestDay == null)
              const Text('Keep learning to discover your patterns!'),
          ],
        ),
      ),
    );
  }

  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:00 $period';
  }
}

// ============================================
// CHART WIDGETS
// ============================================

class _XpLineChart extends StatelessWidget {
  final AnalyticsData analytics;
  final int days;

  const _XpLineChart({required this.analytics, required this.days});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    final now = DateTime.now();
    
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: days - i - 1));
      final dateKey = _formatDate(date);
      final xp = analytics.xpHistory[dateKey] ?? 0;
      spots.add(FlSpot(i.toDouble(), xp.toDouble()));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 25,
              getDrawingHorizontalLine: (value) => FlLine(
                color: AppColors.surfaceVariant,
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: AppTypography.bodySmall,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: days / 6,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= days) return const Text('');
                    final date = now.subtract(Duration(days: days - index - 1));
                    return Text(
                      DateFormat('M/d').format(date),
                      style: AppTypography.bodySmall,
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColors.primary,
                barWidth: 3,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _PathProgressBarChart extends StatelessWidget {
  final AnalyticsData analytics;

  const _PathProgressBarChart({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final entries = analytics.pathProgress.entries.toList();
    if (entries.isEmpty) {
      return const Card(
        child: Center(child: Text('No path data yet')),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: entries.map((e) => e.value.totalLessons).reduce((a, b) => a > b ? a : b).toDouble() + 2,
            barGroups: List.generate(entries.length, (index) {
              final entry = entries[index];
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.completedLessons.toDouble(),
                    color: AppColors.primary,
                    width: 16,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              );
            }),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: AppTypography.bodySmall,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= entries.length) return const Text('');
                    final pathId = entries[index].key;
                    return Text(
                      _formatPathName(pathId).split(' ').first,
                      style: AppTypography.bodySmall,
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }

  String _formatPathName(String pathId) {
    return pathId
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}

class _HourBarChart extends StatelessWidget {
  final AnalyticsData analytics;

  const _HourBarChart({required this.analytics});

  @override
  Widget build(BuildContext context) {
    if (analytics.studyTimeByHour.isEmpty) {
      return const Card(
        child: Center(child: Text('No study time data yet')),
      );
    }

    final maxMinutes = analytics.studyTimeByHour.values.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxMinutes.toDouble() + 5,
            barGroups: List.generate(24, (hour) {
              final minutes = analytics.studyTimeByHour[hour] ?? 0;
              return BarChartGroupData(
                x: hour,
                barRods: [
                  BarChartRodData(
                    toY: minutes.toDouble(),
                    color: AppColors.secondary,
                    width: 8,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                  ),
                ],
              );
            }),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: AppTypography.bodySmall,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 3,
                  getTitlesWidget: (value, meta) {
                    final hour = value.toInt();
                    if (hour % 3 != 0) return const Text('');
                    final period = hour >= 12 ? 'p' : 'a';
                    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
                    return Text('$displayHour$period', style: AppTypography.bodySmall);
                  },
                ),
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }
}

class _WeekdayPieChart extends StatelessWidget {
  final AnalyticsData analytics;

  const _WeekdayPieChart({required this.analytics});

  @override
  Widget build(BuildContext context) {
    if (analytics.studyTimeByWeekday.isEmpty) {
      return const Card(
        child: Center(child: Text('No study time data yet')),
      );
    }

    final sections = analytics.studyTimeByWeekday.entries.map((entry) {
      final percentage = entry.value / 
          analytics.studyTimeByWeekday.values.reduce((a, b) => a + b) * 100;
      
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        color: _getWeekdayColor(entry.key),
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 0,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(7, (i) {
                final weekday = i + 1;
                final minutes = analytics.studyTimeByWeekday[weekday] ?? 0;
                if (minutes == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        color: _getWeekdayColor(weekday),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEE').format(DateTime(2024, 1, weekday)),
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Color _getWeekdayColor(int weekday) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
    ];
    return colors[(weekday - 1) % colors.length];
  }
}
```

---

## Integration

### 4. Navigation Hook

Add analytics access from the **Profile/Settings screen**:

**Location:** `/lib/screens/settings_screen.dart` or wherever profile is shown

```dart
// In the settings/profile screen, add a tile:
ListTile(
  leading: const Icon(Icons.analytics),
  title: const Text('📊 Progress Analytics'),
  subtitle: const Text('View your learning insights'),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AnalyticsScreen(),
    ),
  ),
),
```

---

## Export Functionality

### 5. Screenshot + Share

**Dependencies Already Available:**
- `share_plus` ✅
- `path_provider` ✅

**Implementation:**

```dart
// In AnalyticsScreen:
Future<void> _exportAsImage(BuildContext context) async {
  try {
    // Use GlobalKey to capture widget as image
    final boundary = _screenshotKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    
    final bytes = byteData.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/analytics_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'My Aquarium Learning Progress',
    );
  } catch (e) {
    AppFeedback.showError(context, 'Export failed: $e');
  }
}

// Wrap the TabBarView in RepaintBoundary with key:
final GlobalKey _screenshotKey = GlobalKey();

// ...
RepaintBoundary(
  key: _screenshotKey,
  child: TabBarView(...),
)
```

---

## Testing Checklist

### Manual Testing

- [ ] **Overview Tab:**
  - [ ] Key stats display correctly (XP, streak, lessons)
  - [ ] Insights generate and display
  - [ ] XP line chart shows last 30 days
  
- [ ] **Learning Tab:**
  - [ ] Bar chart shows lessons per path
  - [ ] Path progress cards show completion rates
  - [ ] Progress bars animate correctly
  
- [ ] **Engagement Tab:**
  - [ ] Activity heatmap renders (12 weeks)
  - [ ] XP chart shows 90 days
  - [ ] Daily goal stats calculate correctly
  
- [ ] **Time Tab:**
  - [ ] Hour bar chart shows study patterns
  - [ ] Weekday pie chart displays correctly
  - [ ] Best times summary accurate

- [ ] **Export:**
  - [ ] Screenshot capture works
  - [ ] Share dialog appears
  - [ ] Image quality acceptable

---

## Sample Insights

### Streak Insights
- 🔥 "You're on a 7 day streak! Keep it going!"
- 🎯 "Just 2 more days to beat your record of 15 days!"
- 🏆 "New Record! You've set a new personal best with a 16 day streak!"

### Pattern Insights
- ⏰ "You learn best in the morning (9:00 AM). Try scheduling lessons then!"
- 📅 "You're most active on Saturdays!"
- 📈 "You're earning 45% more XP this week than last week!"
- 💡 "Your activity has dropped 30% this week. Even 5 minutes helps!"

### Progress Insights
- 🌟 "You're 85% through the Nitrogen Cycle path!"
- 🎓 "You've completed 20 lessons. Great progress!"
- 💪 "You're averaging 65 XP/day, above your 50 XP goal!"

---

## Chart Examples

### 1. XP Line Chart (Engagement Tab)
```
📊 XP Over Time (Last 90 Days)

   100 ┤        ╭╮    ╭╮
    75 ┤      ╭╯╰╮  ╭╯╰╮
    50 ┤    ╭╯   ╰╮╭╯  ╰╮
    25 ┤╭╮╭╯      ╰╯    ╰╮
     0 ┴─────────────────────
       3/1      3/15     3/30
```

### 2. Path Progress Bar Chart (Learning Tab)
```
📚 Lessons by Path

    10 ┤ █
     8 ┤ █    █
     6 ┤ █    █    █
     4 ┤ █    █    █    █
     2 ┤ █    █    █    █    █
     0 ┴─────────────────────────
       Cycle  Water  Plants Fish  Equip
```

### 3. Activity Heatmap (Engagement Tab)
```
🔥 Activity Heatmap (GitHub-style)

Mon ░░▓▓░░▓▓▓░░░
Wed ░▓██░░░▓▓░░░
Fri ░░▓█▓░░▓░░░░
    ← 12 weeks ago
    
░ = No activity
▓ = Some activity
█ = Goal met
```

### 4. Hour Bar Chart (Time Tab)
```
⏰ Study Time by Hour

  30 ┤     █
  20 ┤   █ █
  10 ┤   █ █ █
   0 ┴─────────────────────
     6a  9a  12p  3p  6p  9p
```

### 5. Weekday Pie Chart (Time Tab)
```
📅 Study Time by Day of Week

     Mon 25%
     ╱────╲
    │██    │
    │  ██  │ Wed 15%
     ╲────╱
     Sat 35%
```

---

## Future Enhancements

### Phase 2 (Optional)
1. **Quiz Tracking:**
   - Track individual quiz attempts
   - Show accuracy trends over time
   - Identify weak topics

2. **Comparative Analytics:**
   - Week-over-week comparison cards
   - Month-over-month XP trends
   - Personal bests timeline

3. **Social Features:**
   - Compare with friends (opt-in)
   - Leaderboard integration
   - Share achievements

4. **Advanced Insights:**
   - ML-based predictions ("You'll reach 1000 XP by...")
   - Optimal study schedule recommendations
   - Retention rate analysis

---

## Implementation Timeline

**Estimated: 6-8 hours**

1. **Models** (1 hour)
   - Create `analytics_data.dart`
   - Create `analytics_insights.dart`

2. **UI Scaffolding** (1 hour)
   - Create `analytics_screen.dart` with tabs
   - Add navigation from settings

3. **Chart Implementation** (3 hours)
   - XP line chart
   - Path progress bar chart
   - Activity heatmap
   - Hour/weekday charts

4. **Insights Engine** (1-2 hours)
   - Implement insight generators
   - Test insight logic

5. **Export Feature** (1 hour)
   - Screenshot capture
   - Share integration

6. **Polish & Testing** (1-2 hours)
   - Edge case handling
   - Empty state UIs
   - Animations

---

## Dependencies

**Already in pubspec.yaml:**
- ✅ `fl_chart: ^0.69.2` (charts)
- ✅ `intl: ^0.20.2` (date formatting)
- ✅ `share_plus: ^10.1.4` (export)
- ✅ `path_provider: ^2.1.5` (file access)

**No new dependencies needed!**

---

## Notes

- **Data Privacy:** All analytics are local, no data sent to servers
- **Performance:** Charts are lazy-loaded within tabs
- **Accessibility:** All charts include tooltips and labels
- **Responsive:** Works on all screen sizes
- **Theme:** Uses existing AppColors and AppTypography

---

## Completion Criteria

✅ **Analytics screen accessible from profile**  
✅ **4 tabs: Overview, Learning, Engagement, Time**  
✅ **Auto-generated insights display**  
✅ **Charts render correctly with real data**  
✅ **Export to image works**  
✅ **Empty states handled gracefully**  
✅ **All existing tests pass**

---

**Questions?** Refer to existing implementations:
- Chart examples: `/lib/screens/charts_screen.dart`
- User data: `/lib/models/user_profile.dart`
- Learning models: `/lib/models/learning.dart`
