import 'package:flutter/material.dart';

/// Mini analytics widget for home screen
/// Shows quick stats and links to full analytics dashboard

import '../models/user_profile.dart';
import '../models/analytics.dart';
import '../models/learning.dart';
import '../services/analytics_service.dart';
import '../data/lesson_content.dart';

class MiniAnalyticsWidget extends StatelessWidget {
  final UserProfile profile;

  const MiniAnalyticsWidget({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AnalyticsSummary>(
      future: _loadQuickStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final summary = snapshot.data;
        if (summary == null) {
          return const SizedBox.shrink();
        }

        return Card(
          elevation: 2,
          child: InkWell(
            onTap: () {
              // Navigate to analytics screen
              // Using Navigator.push for now, adapt to your routing
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const Placeholder(), // Replace with AnalyticsScreen()
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Progress',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.analytics, color: Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quick stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickStat(
                        context,
                        icon: Icons.star,
                        value: summary.totalXP.toString(),
                        label: 'Total XP',
                        color: Colors.amber,
                      ),
                      _buildQuickStat(
                        context,
                        icon: Icons.local_fire_department,
                        value: '${summary.currentStreak}',
                        label: 'Day Streak',
                        color: Colors.deepOrange,
                      ),
                      _buildQuickStat(
                        context,
                        icon: Icons.book,
                        value: '${summary.lessonsCompleted}',
                        label: 'Lessons',
                        color: Colors.blue,
                      ),
                    ],
                  ),

                  if (summary.insights.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Top insight preview
                    Row(
                      children: [
                        Text(
                          summary.insights.first.type.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            summary.insights.first.message,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),

                  // View full analytics button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        // Navigate to full analytics
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const Placeholder(), // Replace with AnalyticsScreen()
                          ),
                        );
                      },
                      icon: const Icon(Icons.trending_up, size: 18),
                      label: const Text('View Detailed Analytics'),
                      style: TextButton.styleFrom(foregroundColor: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStat(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Future<AnalyticsSummary> _loadQuickStats() async {
    // Generate analytics for last 7 days (fast)
    return AnalyticsService.generateSummary(
      profile: profile,
      allPaths: LessonContent.allPaths,
      timeRange: AnalyticsTimeRange.last7Days,
    );
  }
}
