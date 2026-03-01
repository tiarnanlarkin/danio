/// Achievements Screen - Trophy Case Gallery
/// Displays all achievements with filtering, sorting, and progress tracking
library;
import 'package:danio/theme/app_theme.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievements.dart';
import '../data/achievements.dart';
import '../widgets/effects/shimmer_glow.dart';
import '../providers/achievement_provider.dart';
import '../widgets/achievement_card.dart';
import '../widgets/achievement_detail_modal.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  AchievementCategory? _selectedCategory;
  AchievementRarity? _selectedRarity;
  AchievementSortBy _sortBy = AchievementSortBy.rarity;
  FilterMode _filterMode = FilterMode.all;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final progressMap = ref.watch(achievementProgressProvider);
    final completionPercent = ref.watch(achievementCompletionProvider);

    // Apply filters
    final filter = AchievementFilter(
      showUnlockedOnly: _filterMode == FilterMode.unlocked,
      showLockedOnly: _filterMode == FilterMode.locked,
      category: _selectedCategory,
      rarity: _selectedRarity,
      sortBy: _sortBy,
    );

    final filteredAchievements = ref.watch(
      filteredAchievementsProvider(filter),
    );

    // Calculate stats
    final totalAchievements = AchievementDefinitions.all.length;
    final unlockedCount = progressMap.values.where((p) => p.isUnlocked).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Trophy Case'),
        actions: [
          // Sort menu
          PopupMenuButton<AchievementSortBy>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: AchievementSortBy.rarity,
                child: Text('Sort by Rarity'),
              ),
              const PopupMenuItem(
                value: AchievementSortBy.dateUnlocked,
                child: Text('Sort by Date Unlocked'),
              ),
              const PopupMenuItem(
                value: AchievementSortBy.progress,
                child: Text('Sort by Progress'),
              ),
              const PopupMenuItem(
                value: AchievementSortBy.name,
                child: Text('Sort by Name'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress header
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.secondaryContainer,
                ],
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$unlockedCount / $totalAchievements',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${(completionPercent * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: AppRadius.smallRadius,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: completionPercent),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 12,
                    backgroundColor: AppOverlays.white30,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                    ),
                ),
              ],
            ),
          ),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                // Filter by lock status
                ChoiceChip(
                  label: const Text('All'),
                  selected: _filterMode == FilterMode.all,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _filterMode = FilterMode.all;
                      });
                    }
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                ChoiceChip(
                  label: const Text('Unlocked'),
                  selected: _filterMode == FilterMode.unlocked,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _filterMode = FilterMode.unlocked;
                      });
                    }
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                ChoiceChip(
                  label: const Text('Locked'),
                  selected: _filterMode == FilterMode.locked,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _filterMode = FilterMode.locked;
                      });
                    }
                  },
                ),
                const SizedBox(width: AppSpacing.md),

                // Filter by category
                ...AchievementCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('${category.icon} ${category.displayName}'),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                        });
                      },
                    ),
                  );
                }),

                const SizedBox(width: AppSpacing.sm),

                // Filter by rarity
                ...AchievementRarity.values.map((rarity) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(rarity.displayName),
                      selected: _selectedRarity == rarity,
                      onSelected: (selected) {
                        setState(() {
                          _selectedRarity = selected ? rarity : null;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          // Achievement list with Recently Unlocked section
          Expanded(
            child: filteredAchievements.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: AppIconSizes.xxl,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No achievements unlocked yet -- keep learning!',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Try adjusting your filters',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(achievementProgressProvider);
                    },
                    color: AppColors.primary,
                    child: _buildAchievementsList(
                      context, filteredAchievements, progressMap),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList(
    BuildContext context,
    List<Achievement> achievements,
    Map<String, AchievementProgress> progressMap,
  ) {
    // Separate recently unlocked (last 3, sorted by date)
    final unlocked = <MapEntry<Achievement, AchievementProgress>>[];
    final inProgress = <Achievement>[];
    final locked = <Achievement>[];

    for (final a in achievements) {
      final p = progressMap[a.id] ?? AchievementProgress(achievementId: a.id);
      if (p.isUnlocked) {
        unlocked.add(MapEntry(a, p));
      } else if (p.currentCount > 0) {
        inProgress.add(a);
      } else {
        locked.add(a);
      }
    }

    // Sort unlocked by date (most recent first)
    unlocked.sort((a, b) {
      final aDate = a.value.unlockedAt ?? DateTime(2000);
      final bDate = b.value.unlockedAt ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    final recentlyUnlocked = unlocked.take(3).toList();

    // Build sorted list: recently unlocked → in progress → locked
    final sortedAchievements = <Achievement>[
      ...unlocked.map((e) => e.key),
      ...inProgress,
      ...locked,
    ];

    return CustomScrollView(
      slivers: [
        // Recently unlocked section
        if (recentlyUnlocked.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '🎉 Recently Unlocked',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: recentlyUnlocked.length,
                itemBuilder: (context, index) {
                  final entry = recentlyUnlocked[index];
                  final achievement = entry.key;
                  final progress = entry.value;
                  final reduceMotion = MediaQuery.of(context).disableAnimations;
                  return Container(
                    width: 160,
                    margin: EdgeInsets.only(
                      right: index < recentlyUnlocked.length - 1 ? 12 : 0,
                    ),
                    child: ShimmerGlow(
                      glowColor: AppColors.primary,
                      child: Card(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        child: InkWell(
                          borderRadius: AppRadius.mediumRadius,
                          onTap: () => _showAchievementDetail(
                            context, achievement, progress),
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.sm2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  achievement.icon,
                                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  achievement.name,
                                  style: AppTypography.labelSmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate(autoPlay: !reduceMotion)
                      .fadeIn(
                        duration: reduceMotion ? 0.ms : 300.ms,
                        delay: reduceMotion ? 0.ms : (index * 80).ms,
                      )
                      .scale(
                        begin: reduceMotion ? const Offset(1, 1) : const Offset(0.9, 0.9),
                        end: const Offset(1, 1),
                        duration: reduceMotion ? 0.ms : 300.ms,
                        delay: reduceMotion ? 0.ms : (index * 80).ms,
                      );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
        ],

        // Main grid (sorted: unlocked → in progress → locked)
        SliverPadding(
          padding: EdgeInsets.all(AppSpacing.md),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final achievement = sortedAchievements[index];
                final progress = progressMap[achievement.id] ??
                    AchievementProgress(achievementId: achievement.id);

                final reduceMotion = MediaQuery.of(context).disableAnimations;
                return RepaintBoundary(
                  child: AchievementCard(
                    achievement: achievement,
                    progress: progress,
                    onTap: () => _showAchievementDetail(
                      context, achievement, progress),
                  ),
                )
                    .animate(autoPlay: !reduceMotion)
                    .fadeIn(
                      duration: reduceMotion ? 0.ms : 250.ms,
                      delay: reduceMotion ? 0.ms : (index * 40).ms,
                    )
                    .scale(
                      begin: reduceMotion ? const Offset(1, 1) : const Offset(0.95, 0.95),
                      end: const Offset(1, 1),
                      duration: reduceMotion ? 0.ms : 250.ms,
                      delay: reduceMotion ? 0.ms : (index * 40).ms,
                    );
              },
              childCount: sortedAchievements.length,
            ),
          ),
        ),
      ],
    );
  }

  void _showAchievementDetail(
    BuildContext context,
    Achievement achievement,
    AchievementProgress progress,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AchievementDetailModal(achievement: achievement, progress: progress),
    );
  }
}

enum FilterMode { all, unlocked, locked }
