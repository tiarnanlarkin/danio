// Stories library screen - Browse and select interactive stories
// Duolingo-style story selection with difficulty filtering

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/story.dart';
import '../models/user_profile.dart';
import '../data/stories.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/error_state.dart';
import 'story_player_screen.dart';

enum StorySortOrder { newest, difficulty, completion }

class StoriesScreen extends ConsumerStatefulWidget {
  const StoriesScreen({super.key});

  @override
  ConsumerState<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends ConsumerState<StoriesScreen> {
  StoryDifficulty? _selectedDifficulty;
  StorySortOrder _sortOrder = StorySortOrder.newest;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                '📖 Stories',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.shade700,
                      Colors.blue.shade600,
                      Colors.cyan.shade500,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: CustomPaint(painter: StoryPatternPainter()),
                      ),
                    ),
                    // Subtitle
                    const Positioned(
                      bottom: 60,
                      left: 16,
                      right: 16,
                      child: Text(
                        'Learn through interactive scenarios',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filters and sorting
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterChips(),
                  const SizedBox(height: 12),
                  _buildSortDropdown(),
                ],
              ),
            ),
          ),

          // Story list
          profileAsync.when(
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const SkeletonStoryCard(),
                childCount: 5,
              ),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: ErrorState(
                message: 'Unable to load stories',
                details: 'Please check your connection and try again.',
                onRetry: () => ref.invalidate(userProfileProvider),
              ),
            ),
            data: (profile) => _buildStoryList(profile),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: const Text('All'),
          selected: _selectedDifficulty == null,
          onSelected: (selected) {
            setState(() {
              _selectedDifficulty = null;
            });
          },
        ),
        ...StoryDifficulty.values.map((difficulty) {
          return FilterChip(
            label: Text('${difficulty.emoji} ${difficulty.displayName}'),
            selected: _selectedDifficulty == difficulty,
            onSelected: (selected) {
              setState(() {
                _selectedDifficulty = selected ? difficulty : null;
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildSortDropdown() {
    return Row(
      children: [
        const Text('Sort by:', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 12),
        DropdownButton<StorySortOrder>(
          value: _sortOrder,
          underline: Container(),
          items: const [
            DropdownMenuItem(
              value: StorySortOrder.newest,
              child: Text('Newest'),
            ),
            DropdownMenuItem(
              value: StorySortOrder.difficulty,
              child: Text('Difficulty'),
            ),
            DropdownMenuItem(
              value: StorySortOrder.completion,
              child: Text('Completion'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _sortOrder = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildStoryList(UserProfile? profile) {
    if (profile == null) {
      return const SliverFillRemaining(
        child: Center(child: Text('Profile not loaded')),
      );
    }
    // Get all stories
    var stories = Stories.allStories;

    // Filter by difficulty
    if (_selectedDifficulty != null) {
      stories = stories
          .where((s) => s.difficulty == _selectedDifficulty)
          .toList();
    }

    // Sort stories
    final sortedStories = List<Story>.from(stories);
    switch (_sortOrder) {
      case StorySortOrder.newest:
        // Keep original order (newest first in data file)
        break;
      case StorySortOrder.difficulty:
        sortedStories.sort((a, b) {
          final diffCompare = a.difficulty.index.compareTo(b.difficulty.index);
          if (diffCompare != 0) return diffCompare;
          return a.title.compareTo(b.title);
        });
        break;
      case StorySortOrder.completion:
        sortedStories.sort((a, b) {
          final aCompleted = profile.completedStories.contains(a.id);
          final bCompleted = profile.completedStories.contains(b.id);
          if (aCompleted == bCompleted) {
            return a.title.compareTo(b.title);
          }
          return aCompleted ? 1 : -1; // Incomplete first
        });
        break;
    }

    if (sortedStories.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No stories found')),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final story = sortedStories[index];
          final isUnlocked = story.isUnlocked(
            profile,
            profile.completedStories,
          );
          final isCompleted = profile.completedStories.contains(story.id);
          final storyProgress = profile.storyProgress[story.id];
          final hasProgress = storyProgress != null;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: StoryCard(
              story: story,
              isUnlocked: isUnlocked,
              isCompleted: isCompleted,
              hasProgress: hasProgress,
              onTap: isUnlocked
                  ? () => _navigateToStory(context, story.id)
                  : null,
            ),
          );
        }, childCount: sortedStories.length),
      ),
    );
  }

  void _navigateToStory(BuildContext context, String storyId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StoryPlayerScreen(storyId: storyId),
      ),
    );
  }
}

class StoryCard extends StatelessWidget {
  final Story story;
  final bool isUnlocked;
  final bool isCompleted;
  final bool hasProgress;
  final VoidCallback? onTap;

  const StoryCard({
    super.key,
    required this.story,
    required this.isUnlocked,
    required this.isCompleted,
    required this.hasProgress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.6,
      child: Material(
        color: Colors.white,
        elevation: isUnlocked ? 4 : 2,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCompleted
                    ? Colors.green.shade300
                    : Colors.grey.shade200,
                width: isCompleted ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail/Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(
                          story.difficulty,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          story.thumbnailImage ?? '📖',
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Story info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  story.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isCompleted)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 24,
                                )
                              else if (!isUnlocked)
                                const Icon(
                                  Icons.lock,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            story.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Metadata chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      icon: Icons.signal_cellular_alt,
                      label: story.difficulty.displayName,
                      color: _getDifficultyColor(story.difficulty),
                    ),
                    _buildInfoChip(
                      icon: Icons.access_time,
                      label: '${story.estimatedMinutes} min',
                      color: Colors.blue,
                    ),
                    _buildInfoChip(
                      icon: Icons.star,
                      label: '+${story.xpReward} XP',
                      color: Colors.amber,
                    ),
                  ],
                ),
                // Continue/Start button
                if (isUnlocked)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (hasProgress && !isCompleted)
                          const Text(
                            'Continue • ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                          ),
                        Text(
                          isCompleted
                              ? 'Replay'
                              : hasProgress
                              ? 'Resume'
                              : 'Start',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                // Lock reason
                if (!isUnlocked)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getLockReason(story),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _getColorShade(color)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getColorShade(color),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(StoryDifficulty difficulty) {
    switch (difficulty) {
      case StoryDifficulty.beginner:
        return Colors.green;
      case StoryDifficulty.intermediate:
        return Colors.orange;
      case StoryDifficulty.advanced:
        return Colors.red;
    }
  }

  Color _getColorShade(Color color) {
    // Get a darker shade of the color
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor();
  }

  String _getLockReason(Story story) {
    if (story.minLevel > 0) {
      return 'Reach level ${story.minLevel} to unlock';
    }
    if (story.prerequisites.isNotEmpty) {
      return 'Complete previous stories first';
    }
    return 'Locked';
  }
}

/// Custom painter for decorative pattern in header
class StoryPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw some book/page icons as pattern
    for (var i = 0; i < 5; i++) {
      for (var j = 0; j < 3; j++) {
        final x = (i * size.width / 4) + 20;
        final y = (j * size.height / 2) + 20;

        // Simple book shape
        canvas.drawRect(Rect.fromLTWH(x, y, 30, 40), paint);
        canvas.drawLine(Offset(x + 15, y), Offset(x + 15, y + 40), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
