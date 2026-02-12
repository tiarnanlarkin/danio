/// Activity Feed Screen - Dedicated screen for friend activities
/// Shows chronological feed of all friend activities with filtering
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/friend.dart';
import '../providers/friends_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import 'friend_comparison_screen.dart';

/// Standalone activity feed screen
class ActivityFeedScreen extends ConsumerStatefulWidget {
  const ActivityFeedScreen({super.key});

  @override
  ConsumerState<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends ConsumerState<ActivityFeedScreen> {
  String? _selectedFriendId;
  final ScrollController _scrollController = ScrollController();
  int _displayCount = 20; // Initial load count

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load more when scrolled to 80% of the list
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      setState(() {
        _displayCount += 20;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(friendActivitiesProvider);
    final friendsAsync = ref.watch(friendsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Feed'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(friendActivitiesProvider.notifier).reload();
            },
            tooltip: 'Refresh',
          ),
          if (_selectedFriendId != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _selectedFriendId = null;
                });
              },
              tooltip: 'Clear filter',
            ),
        ],
      ),
      body: Column(
        children: [
          // Friend Filter Chips
          friendsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (friends) => _FriendFilterBar(
              friends: friends,
              selectedFriendId: _selectedFriendId,
              onFriendSelected: (friendId) {
                setState(() {
                  _selectedFriendId = friendId;
                  _displayCount = 20; // Reset count when filtering
                });
              },
            ),
          ),

          // Activity Feed
          Expanded(
            child: activitiesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => ErrorState(
                message: 'Error loading activities',
                onRetry: () =>
                    ref.read(friendActivitiesProvider.notifier).reload(),
              ),
              data: (activities) {
                // Filter by selected friend
                final filteredActivities = _selectedFriendId == null
                    ? activities
                    : activities
                          .where((a) => a.friendId == _selectedFriendId)
                          .toList();

                // Limit display count for pagination
                final displayedActivities = filteredActivities
                    .take(_displayCount)
                    .toList();
                final hasMore =
                    filteredActivities.length > displayedActivities.length;

                return _ActivityFeedView(
                  activities: displayedActivities,
                  scrollController: _scrollController,
                  hasMore: hasMore,
                  onLoadMore: () {
                    setState(() {
                      _displayCount += 20;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Friend filter bar with horizontal scrollable chips
class _FriendFilterBar extends StatelessWidget {
  const _FriendFilterBar({
    required this.friends,
    required this.selectedFriendId,
    required this.onFriendSelected,
  });

  final List<Friend> friends;
  final String? selectedFriendId;
  final ValueChanged<String?> onFriendSelected;

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: selectedFriendId == null,
              onSelected: (_) => onFriendSelected(null),
              avatar: selectedFriendId == null
                  ? const Icon(Icons.check, size: 16)
                  : const Icon(Icons.people, size: 16),
            ),
          ),

          // Friend chips
          ...friends.map((friend) {
            final isSelected = friend.id == selectedFriendId;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(friend.displayName),
                selected: isSelected,
                onSelected: (_) =>
                    onFriendSelected(isSelected ? null : friend.id),
                avatar: Text(
                  friend.avatarEmoji ?? '🐠',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Activity feed list view
class _ActivityFeedView extends StatelessWidget {
  const _ActivityFeedView({
    required this.activities,
    required this.scrollController,
    required this.hasMore,
    required this.onLoadMore,
  });

  final List<FriendActivity> activities;
  final ScrollController scrollController;
  final bool hasMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return EmptyState(
        icon: Icons.feed_outlined,
        title: 'No activities yet',
        message: 'Your friends\' achievements and progress will appear here',
        actionLabel: 'Add friends to see activity',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Trigger reload via provider
        // Provider already handles the refresh
      },
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: activities.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= activities.length) {
            // Loading indicator for "load more"
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final activity = activities[index];
          final isLastInDay = _isLastActivityOfDay(activities, index);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ActivityTile(activity: activity),
              if (isLastInDay) ...[
                const SizedBox(height: AppSpacing.sm),
                _DateDivider(date: activity.timestamp),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Check if this is the last activity of the day
  bool _isLastActivityOfDay(List<FriendActivity> activities, int index) {
    if (index >= activities.length - 1) return true;

    final current = activities[index];
    final next = activities[index + 1];

    final currentDay = DateTime(
      current.timestamp.year,
      current.timestamp.month,
      current.timestamp.day,
    );
    final nextDay = DateTime(
      next.timestamp.year,
      next.timestamp.month,
      next.timestamp.day,
    );

    return currentDay != nextDay;
  }
}

/// Individual activity tile with friend info and action
class _ActivityTile extends ConsumerWidget {
  const _ActivityTile({required this.activity});

  final FriendActivity activity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to friend comparison when tapping activity
          final friendsAsync = ref.read(friendsProvider);
          friendsAsync.whenData((friends) {
            final friend = friends.firstWhere(
              (f) => f.id == activity.friendId,
              orElse: () => friends.first,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FriendComparisonScreen(friend: friend),
              ),
            );
          });
        },
        borderRadius: AppRadius.mediumRadius,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Text(
                  activity.friendAvatarEmoji ?? '🐠',
                  style: const TextStyle(fontSize: 24),
                ),
              ),

              const SizedBox(width: 12),

              // Activity content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Friend name and action
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        children: [
                          TextSpan(
                            text: activity.friendDisplayName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: ' ${activity.type.displayName}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Activity description with emoji
                    Row(
                      children: [
                        Text(
                          activity.type.emoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            activity.description,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // XP and time
                    Row(
                      children: [
                        if (activity.xpEarned != null) ...[
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '+${activity.xpEarned} XP',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          activity.timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Chevron
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

/// Date divider for grouping activities by day
class _DateDivider extends StatelessWidget {
  const _DateDivider({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final activityDay = DateTime(date.year, date.month, date.day);

    String label;
    if (activityDay == today) {
      label = 'Today';
    } else if (activityDay == yesterday) {
      label = 'Yesterday';
    } else if (now.difference(activityDay).inDays < 7) {
      // Within last week - show day name
      const days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      label = days[activityDay.weekday - 1];
    } else {
      // Older - show date
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      label = '${months[activityDay.month - 1]} ${activityDay.day}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }
}
