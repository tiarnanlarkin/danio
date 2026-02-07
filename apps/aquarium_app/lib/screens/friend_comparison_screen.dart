import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/friend.dart';
import '../models/user_profile.dart';
import '../providers/user_profile_provider.dart';
import '../providers/friends_provider.dart';
import '../theme/app_theme.dart';
import 'dart:math';

/// Friend comparison screen - side-by-side stats and encouragement
class FriendComparisonScreen extends ConsumerStatefulWidget {
  const FriendComparisonScreen({super.key, required this.friend});

  final Friend friend;

  @override
  ConsumerState<FriendComparisonScreen> createState() => _FriendComparisonScreenState();
}

class _FriendComparisonScreenState extends ConsumerState<FriendComparisonScreen> {
  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Compare with ${widget.friend.displayName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.celebration),
            onPressed: () => _showEncouragementDialog(context),
            tooltip: 'Send Encouragement',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'remove') {
                _confirmRemoveFriend(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.person_remove, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Remove Friend', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: userProfileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (userProfile) {
          if (userProfile == null) {
            return const Center(child: Text('No user profile found'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // === Header Cards ===
                _HeaderSection(userProfile: userProfile, friend: widget.friend),

                const SizedBox(height: 16),

                // === Stats Comparison ===
                _StatsComparisonSection(userProfile: userProfile, friend: widget.friend),

                const SizedBox(height: 16),

                // === Progress Chart ===
                _ProgressChartSection(userProfile: userProfile, friend: widget.friend),

                const SizedBox(height: 16),

                // === Achievements Comparison ===
                _AchievementsSection(userProfile: userProfile, friend: widget.friend),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEncouragementDialog(BuildContext context) {
    final emojis = ['👍', '🎉', '🔥', '❤️', '💪', '⭐', '🏆', '👏'];
    String selectedEmoji = emojis[0];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Send Encouragement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Cheer on ${widget.friend.displayName}!'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: emojis.map((emoji) {
                  final isSelected = emoji == selectedEmoji;
                  return GestureDetector(
                    onTap: () => setState(() => selectedEmoji = emoji),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.grey.shade100,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                ref.read(encouragementsProvider.notifier).sendEncouragement(
                      toUserId: widget.friend.id,
                      emoji: selectedEmoji,
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sent $selectedEmoji to ${widget.friend.displayName}!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemoveFriend(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend?'),
        content: Text('Are you sure you want to remove ${widget.friend.displayName} from your friends?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(friendsProvider.notifier).removeFriend(widget.friend.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to friends list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Removed ${widget.friend.displayName} from friends'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

/// Header with both user cards
class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.userProfile, required this.friend});

  final UserProfile userProfile;
  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _UserCard(
              name: 'You',
              emoji: '😊',
              level: userProfile.levelTitle,
              xp: userProfile.totalXp,
              isUser: true,
            ),
          ),
          const SizedBox(width: 16),
          const Text('VS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Expanded(
            child: _UserCard(
              name: friend.displayName,
              emoji: friend.avatarEmoji ?? '🐠',
              level: friend.levelTitle,
              xp: friend.totalXp,
              isUser: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.name,
    required this.emoji,
    required this.level,
    required this.xp,
    required this.isUser,
  });

  final String name;
  final String emoji;
  final String level;
  final int xp;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: (isUser ? Colors.blue : AppColors.primary).withOpacity(0.2),
              child: Text(emoji, style: const TextStyle(fontSize: 32)),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                level,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                const SizedBox(width: 4),
                Text(
                  '$xp XP',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Stats comparison grid
class _StatsComparisonSection extends StatelessWidget {
  const _StatsComparisonSection({required this.userProfile, required this.friend});

  final UserProfile userProfile;
  final Friend friend;

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('Total XP', userProfile.totalXp, friend.totalXp, Icons.star, Colors.amber),
      ('Current Streak', userProfile.currentStreak, friend.currentStreak, Icons.local_fire_department, Colors.orange),
      ('Longest Streak', userProfile.longestStreak, friend.longestStreak, Icons.whatshot, Colors.red),
      ('Level', userProfile.currentLevel, friend.currentLevel, Icons.trending_up, Colors.blue),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Stats Comparison',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        ...stats.map((stat) {
          final (label, userValue, friendValue, icon, color) = stat;
          return _StatComparisonRow(
            label: label,
            userValue: userValue,
            friendValue: friendValue,
            icon: icon,
            color: color,
          );
        }),
      ],
    );
  }
}

class _StatComparisonRow extends StatelessWidget {
  const _StatComparisonRow({
    required this.label,
    required this.userValue,
    required this.friendValue,
    required this.icon,
    required this.color,
  });

  final String label;
  final int userValue;
  final int friendValue;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final total = userValue + friendValue;
    final userPercentage = total > 0 ? userValue / total : 0.5;
    final winner = userValue > friendValue ? 'user' : friendValue > userValue ? 'friend' : 'tie';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  userValue.toString(),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: winner == 'user' ? Colors.green : Colors.grey,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: userPercentage,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  friendValue.toString(),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: winner == 'friend' ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Progress chart comparing XP over time
class _ProgressChartSection extends StatelessWidget {
  const _ProgressChartSection({required this.userProfile, required this.friend});

  final UserProfile userProfile;
  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Weekly Progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: _buildChart(context),
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context) {
    // Generate mock data for last 7 days
    final random = Random();
    final now = DateTime.now();
    final userSpots = <FlSpot>[];
    final friendSpots = <FlSpot>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Use real user data if available, otherwise mock
      final userXp = userProfile.dailyXpHistory[dateKey] ?? random.nextInt(100);
      final friendXp = 20 + random.nextInt(80); // Mock friend data

      userSpots.add(FlSpot((6 - i).toDouble(), userXp.toDouble()));
      friendSpots.add(FlSpot((6 - i).toDouble(), friendXp.toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                final index = value.toInt();
                if (index >= 0 && index < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      days[index],
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 150,
        lineBarsData: [
          // User line (blue)
          LineChartBarData(
            spots: userSpots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
          // Friend line (orange)
          LineChartBarData(
            spots: friendSpots,
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orange.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}

/// Achievements comparison
class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection({required this.userProfile, required this.friend});

  final UserProfile userProfile;
  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Achievements',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _AchievementCard(
                  title: 'Your Achievements',
                  count: userProfile.achievements.length,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _AchievementCard(
                  title: '${friend.displayName}\'s',
                  count: friend.totalAchievements,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.title,
    required this.count,
    required this.color,
  });

  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.emoji_events, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
