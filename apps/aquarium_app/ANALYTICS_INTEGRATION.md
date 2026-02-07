# Analytics Dashboard Integration Guide

## Overview

The analytics system provides comprehensive progress tracking with:
- **Charts**: XP trends, weekly bars, topic mastery radar, streak calendar
- **Insights**: AI-generated recommendations based on learning patterns
- **Predictions**: Future milestone estimates based on current progress
- **Export**: JSON data export and shareable reports

## Files Created

### Models (`lib/models/analytics.dart`)
- `DailyStats` - Daily XP and activity tracking
- `WeeklyStats` - Weekly aggregations
- `MonthlyStats` - Monthly summaries
- `AnalyticsInsight` - AI-generated insights
- `TopicPerformance` - Per-topic mastery analysis
- `Prediction` - Future milestone predictions
- `AnalyticsSummary` - Complete analytics package
- `AnalyticsTimeRange` - Time range selector

### Service (`lib/services/analytics_service.dart`)
- `generateSummary()` - Main analytics generation
- `_aggregateDailyStats()` - Daily data aggregation
- `_aggregateWeeklyStats()` - Weekly rollups
- `_calculateTopicPerformance()` - Topic mastery calculations
- `_detectTimePatterns()` - Learning time pattern analysis
- `_generateInsights()` - AI insight generation
- `_generatePredictions()` - Milestone predictions
- `calculate7DayMovingAverage()` - Trend smoothing
- `calculate30DayMovingAverage()` - Long-term trends

### Screen (`lib/screens/analytics_screen.dart`)
Complete dashboard with:
- Time range selector (Today, Week, Month, All Time, Custom)
- Overview cards (XP, Streak, Lessons, Time)
- XP over time line chart
- Weekly bar chart
- Topic mastery radar chart
- GitHub-style activity calendar
- Insights cards with recommendations
- Topic breakdown with progress bars
- Predictions section
- Export options (JSON, Share report)

### Tests (`test/services/analytics_service_test.dart`)
Comprehensive test coverage:
- ✅ Summary generation
- ✅ Daily/weekly aggregation
- ✅ Topic performance calculations
- ✅ Insight generation
- ✅ Prediction accuracy
- ✅ Moving averages
- ✅ Edge cases (empty data, varied progress)

## Integration Steps

### 1. Add Navigation Route

In your router configuration (e.g., `lib/main.dart` or router file):

```dart
import 'package:aquarium_app/screens/analytics_screen.dart';

// Add to your GoRouter routes:
GoRoute(
  path: '/analytics',
  name: 'analytics',
  builder: (context, state) => const AnalyticsScreen(),
),
```

### 2. Add Tab/Menu Item

#### Option A: Bottom Navigation Tab
```dart
BottomNavigationBar(
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Progress'),
    BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Learn'),
  ],
  onTap: (index) {
    if (index == 1) {
      context.go('/analytics');
    }
  },
)
```

#### Option B: Drawer Menu Item
```dart
ListTile(
  leading: const Icon(Icons.analytics),
  title: const Text('Progress Analytics'),
  onTap: () {
    Navigator.pop(context); // Close drawer
    context.go('/analytics');
  },
)
```

#### Option C: Home Screen Widget
```dart
Card(
  child: InkWell(
    onTap: () => context.go('/analytics'),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.trending_up, size: 32, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('View Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Charts, insights & predictions', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios),
        ],
      ),
    ),
  ),
)
```

### 3. Connect Real User Data

Replace the `_getSampleProfile()` method in `analytics_screen.dart` with your actual user profile:

```dart
// Using Riverpod (example)
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Progress Analytics')),
      body: FutureBuilder<AnalyticsSummary>(
        future: _loadAnalytics(profile),
        builder: (context, snapshot) {
          // ... existing builder code
        },
      ),
    );
  }

  Future<AnalyticsSummary> _loadAnalytics(UserProfile profile) async {
    final allPaths = LessonContent.allPaths;
    
    return AnalyticsService.generateSummary(
      profile: profile,
      allPaths: allPaths,
      timeRange: _selectedRange,
    );
  }
}
```

### 4. Mini Analytics Widget (Optional)

Create a home screen widget to show quick stats:

```dart
// lib/widgets/analytics_widget.dart
class MiniAnalyticsWidget extends StatelessWidget {
  final UserProfile profile;

  const MiniAnalyticsWidget({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This Week', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(Icons.star, '${profile.weeklyXP}', 'XP'),
                _buildStat(Icons.local_fire_department, '${profile.currentStreak}', 'Day Streak'),
                _buildStat(Icons.trending_up, '${profile.completedLessons.length}', 'Lessons'),
              ],
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => context.go('/analytics'),
              icon: const Icon(Icons.analytics),
              label: const Text('View Full Analytics'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
```

### 5. Weekly Summary Notification (Optional)

Add a notification service call:

```dart
// In your notification service or weekly cron job
Future<void> sendWeeklySummary(UserProfile profile) async {
  final summary = AnalyticsService.generateSummary(
    profile: profile,
    allPaths: LessonContent.allPaths,
    timeRange: AnalyticsTimeRange.thisWeek,
  );

  final topInsight = summary.insights.isNotEmpty 
      ? summary.insights.first.message 
      : 'Keep learning!';

  await notificationService.scheduleNotification(
    title: '📊 Your Weekly Progress',
    body: 'You earned ${summary.totalXP} XP this week! $topInsight',
    scheduledTime: DateTime.now().add(const Duration(days: 7)),
  );
}
```

## Testing

Run the analytics tests:

```bash
flutter test test/services/analytics_service_test.dart
```

All tests should pass ✅

## Features Breakdown

### Charts
- **Line Chart**: XP over time with gradient fill
- **Bar Chart**: Last 7 days with today highlighted
- **Radar Chart**: Topic mastery (6 topics max)
- **Heatmap Calendar**: GitHub-style 84-day activity grid

### Insights Types
- 🎉 **Achievement**: Milestones reached
- 📈 **Improvement**: Positive changes
- ⚠️ **Warning**: Engagement drops
- 💡 **Recommendation**: Suggested actions
- 🔍 **Pattern**: Behavioral patterns
- 🏆 **Milestone**: Major accomplishments

### Predictions
- XP milestone ETA (next: 100, 500, 1000, 2000, 5000, 10000)
- Streak maintenance requirements
- League promotion likelihood

### Export Options
- **JSON Export**: Complete data download
- **Share Report**: Formatted markdown summary

## Customization

### Change Time Ranges
Edit `AnalyticsTimeRange` enum in `analytics.dart`:
```dart
enum AnalyticsTimeRange {
  today,
  thisWeek,
  thisMonth,
  last7Days,
  last30Days,
  last90Days,
  allTime,
  custom,
}
```

### Adjust Insight Logic
Modify `_generateInsights()` in `analytics_service.dart`:
```dart
// Example: Add custom insight
if (profile.totalXp > 10000) {
  insights.add(AnalyticsInsight(
    id: 'expert_${insightId++}',
    type: InsightType.milestone,
    message: 'You\'re a certified aquarium expert! 🎓',
    recommendation: 'Consider helping other beginners in the community!',
    generatedAt: DateTime.now(),
  ));
}
```

### Customize Chart Colors
In `analytics_screen.dart`, update chart colors:
```dart
LineChartBarData(
  color: Colors.blue, // Change to your theme color
  // ...
)
```

## Performance Considerations

- Analytics are calculated on-demand (not persisted)
- For large datasets (>365 days), consider caching summaries
- Moving averages are efficient but can be expensive for 1000+ days
- Consider pagination for very long time ranges

## Future Enhancements

Potential additions:
- [ ] Comparison with other users (anonymized)
- [ ] Achievement unlocking from analytics
- [ ] Goal setting with progress tracking
- [ ] CSV export for external analysis
- [ ] Push notifications for insights
- [ ] Dark mode chart themes
- [ ] Interactive chart tooltips
- [ ] Time-of-day heatmap (hour × weekday)
- [ ] Learning velocity trends
- [ ] Spaced repetition analytics

## Troubleshooting

**Charts not displaying?**
- Ensure fl_chart is in pubspec.yaml (already added ✅)
- Check that dailyXpHistory has data

**Insights empty?**
- Verify user has activity data
- Check last 7 days have XP entries

**Export failing?**
- Ensure path_provider and share_plus are in pubspec.yaml (already added ✅)
- Check file permissions on device

**Tests failing?**
- Run `flutter pub get` to ensure dependencies are installed
- Check that all model imports are correct

## Support

For issues or questions, check:
- Test file for usage examples
- Service file for calculation logic
- Screen file for UI implementation

---

**Status**: ✅ Complete and tested
**Dependencies**: fl_chart, intl, share_plus, path_provider (all already in pubspec.yaml)
**Next Steps**: Add navigation route and connect real user data
