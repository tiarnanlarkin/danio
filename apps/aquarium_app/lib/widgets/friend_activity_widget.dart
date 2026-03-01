/// Friend Activity Widget - Shows recent friend activities on home screen
/// Can be added to home screen or any other screen for quick social updates
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/friend.dart';
import '../providers/friends_provider.dart';
import '../screens/activity_feed_screen.dart';
import '../screens/friend_comparison_screen.dart';
import '../theme/app_theme.dart';

/// Compact friend activity widget showing recent 3 activities
class FriendActivityWidget extends ConsumerWidget {
  const FriendActivityWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(friendActivitiesProvider);

    return activitiesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (activities) {
        if (activities.isEmpty) return const SizedBox.shrink();

        // Show only top 3 recent activities
        final recentActivities = activities.take(3).toList();

        return Card(
          margin: const EdgeInsets.all(16),
          elevation: AppElevation.level1,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mediumRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ActivityFeedScreen(),
                    ),
                  );
                },
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.feed,
                        color: AppColors.primary,
                        size: AppIconSizes.sm,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Text(
                        'Friend Activity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: AppIconSizes.xs,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 1),

              // Recent activities
              ...recentActivities.map((activity) {
                return _CompactActivityTile(activity: activity);
              }),

              // View all button
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ActivityFeedScreen(),
                    ),
                  );
                },
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      'View All Activities',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Compact activity tile for widget display
class _CompactActivityTile extends ConsumerWidget {
  const _CompactActivityTile({required this.activity});

  final FriendActivity activity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        // Navigate to friend comparison
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Small avatar
            CircleAvatar(
              radius: 16,
              backgroundColor: AppOverlays.primary20,
              child: Text(
                activity.friendAvatarEmoji ?? '🐠',
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(width: 12),

            // Activity content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      children: [
                        TextSpan(
                          text: activity.friendDisplayName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' ${activity.type.displayName}',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        activity.type.emoji,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          activity.description,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (activity.xpEarned != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '+${activity.xpEarned}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Time
            Text(
              activity.timeAgo,
              style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline friend activity banner (alternative minimal version)
/// Can be placed anywhere as a horizontal scrollable banner
class FriendActivityBanner extends ConsumerWidget {
  const FriendActivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(friendActivitiesProvider);

    return activitiesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (activities) {
        if (activities.isEmpty) return const SizedBox.shrink();

        return Container(
          height: 80,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: activities.take(10).length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return _BannerActivityCard(activity: activity);
            },
          ),
        );
      },
    );
  }
}

class _BannerActivityCard extends ConsumerWidget {
  const _BannerActivityCard({required this.activity});

  final FriendActivity activity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: InkWell(
          onTap: () {
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
            padding: const EdgeInsets.all(AppSpacing.sm2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      activity.friendAvatarEmoji ?? '🐠',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        activity.friendDisplayName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      activity.type.emoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        activity.description,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  activity.timeAgo,
                  style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
