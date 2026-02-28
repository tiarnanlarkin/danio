import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/friend.dart';
import '../providers/friends_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import '../utils/debouncer.dart';
import '../widgets/empty_state.dart';
import '../widgets/core/app_states.dart';
import '../widgets/skeleton_loader.dart';
import 'friend_comparison_screen.dart';
import '../widgets/mascot/mascot_widgets.dart';

/// Social features screen - friends list and activity feed
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin, DebounceMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  late TextDebouncer _searchDebouncer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchDebouncer = TextDebouncer(
      delay: AppDurations.medium4,
      onChanged: (value) => setState(() => _searchQuery = value),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsProvider);
    final activitiesAsync = ref.watch(friendActivitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        elevation: AppElevation.level0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Friends'),
            Tab(icon: Icon(Icons.feed), text: 'Activity'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddFriendDialog(context),
            tooltip: 'Add Friend',
          ),
        ],
      ),
      body: Column(
        children: [
          // Demo data indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  'Demo data — connect your account for real friends',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
        controller: _tabController,
        children: [
          // Friends Tab
          friendsAsync.when(
            loading: () => const SkeletonList(itemCount: 5, itemHeight: 80),
            error: (e, _) => AppErrorState(
              title: 'Unable to load friends',
              message: 'Please check your connection and try again.',
              onRetry: () => ref.read(friendsProvider.notifier).reload(),
            ),
            data: (friends) => _FriendsListView(
              friends: friends,
              searchQuery: _searchQuery,
              onSearchChanged: (query) => _searchDebouncer.update(query),
              searchController: _searchController,
            ),
          ),

          // Activity Feed Tab
          activitiesAsync.when(
            loading: () => const SkeletonList(itemCount: 6, itemHeight: 100),
            error: (e, _) => AppErrorState(
              title: 'Unable to load activity feed',
              message: 'Please check your connection and try again.',
              onRetry: () =>
                  ref.read(friendActivitiesProvider.notifier).reload(),
            ),
            data: (activities) => _ActivityFeedView(activities: activities),
          ),
        ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Friend'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter username to add friend',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'e.g., aqua_explorer',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _addFriend(context, controller.text),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm2),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: AppRadius.smallRadius,
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: AppIconSizes.sm, color: Colors.blue),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'This is a demo - try adding any username!',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => _addFriend(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addFriend(BuildContext context, String username) async {
    if (username.trim().isEmpty) return;

    try {
      await ref.read(friendsProvider.notifier).addFriend(username.trim());
      if (!context.mounted) return;

      Navigator.pop(context);
      AppFeedback.showSuccess(context, 'Added $username as friend!');
    } catch (error) {
      if (!context.mounted) return;

      AppFeedback.showError(context, error.toString());
    }
  }
}

/// Friends list view with search
class _FriendsListView extends ConsumerWidget {
  const _FriendsListView({
    required this.friends,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.searchController,
  });

  final List<Friend> friends;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (friends.isEmpty) {
      return EmptyState.withMascot(
        icon: Icons.people_outline,
        title: 'No friends yet',
        message:
            'Add friends to compare progress and share your aquarium journey!',
        mascotContext: MascotContext.encouragement,
        actionLabel: 'Tap + above to add friends',
        onAction: () {
          AppFeedback.showInfo(context, 'Tap the + icon above to add friends');
        },
      );
    }

    // Filter friends by search query
    final filteredFriends = searchQuery.isEmpty
        ? friends
        : friends
              .where(
                (f) =>
                    f.username.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    f.displayName.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ),
              )
              .toList();

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search friends...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: AppRadius.mediumRadius,
              ),
              filled: true,
            ),
            onChanged: onSearchChanged,
          ),
        ),

        // Friends count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Text(
                '${filteredFriends.length} ${filteredFriends.length == 1 ? 'friend' : 'friends'}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // Friends list
        Expanded(
          child: filteredFriends.isEmpty
              ? Center(
                  child: Text(
                    'No friends match "$searchQuery"',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredFriends.length,
                  itemBuilder: (context, index) {
                    final friend = filteredFriends[index];
                    return _FriendListTile(friend: friend);
                  },
                ),
        ),
      ],
    );
  }
}

/// Individual friend list tile
class _FriendListTile extends ConsumerWidget {
  const _FriendListTile({required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FriendComparisonScreen(friend: friend),
            ),
          );
        },
        borderRadius: AppRadius.mediumRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm2),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppOverlays.primary20,
                    child: Text(
                      friend.avatarEmoji ?? '🐠',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  if (friend.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 12),

              // Friend info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${friend.username}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            '${friend.totalXp} XP',
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (friend.currentStreak > 0) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.local_fire_department,
                            size: 14,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              '${friend.currentStreak}d 🔥',
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Status - constrained to prevent overflow
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getLevelColor(friend.currentLevel),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        friend.levelTitle,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      friend.statusText,
                      style: TextStyle(
                        fontSize: 11,
                        color: friend.isOnline
                            ? Colors.green
                            : Colors.grey.shade500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(int level) {
    if (level >= 7) return Colors.purple;
    if (level >= 5) return Colors.orange;
    if (level >= 3) return Colors.blue;
    return Colors.green;
  }
}

/// Activity feed view
class _ActivityFeedView extends StatelessWidget {
  const _ActivityFeedView({required this.activities});

  final List<FriendActivity> activities;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return EmptyState.withMascot(
        icon: Icons.feed_outlined,
        title: 'No recent activity',
        message: 'Your friends\' achievements will appear here once they start learning!',
        mascotContext: MascotContext.encouragement,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _ActivityTile(activity: activity);
      },
    );
  }
}

/// Individual activity tile
class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final FriendActivity activity;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: AppOverlays.primary20,
              child: Text(
                activity.friendAvatarEmoji ?? '🐠',
                style: const TextStyle(fontSize: 20),
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
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Text(
                        activity.type.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
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
                  if (activity.xpEarned != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
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
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    activity.timeAgo,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error view with retry button (UNUSED - Kept for reference)
/*
class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: AppIconSizes.xxl, color: Colors.red),
          const SizedBox(height: AppSpacing.md),
          Text(message),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
*/
