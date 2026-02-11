/// Achievements Screen - Trophy Case Gallery
/// Displays all achievements with filtering, sorting, and progress tracking
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievements.dart';
import '../data/achievements.dart';
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
            padding: const EdgeInsets.all(16),
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
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: completionPercent,
                    minHeight: 12,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
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
                const SizedBox(width: 8),
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
                const SizedBox(width: 8),
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
                const SizedBox(width: 16),

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

                const SizedBox(width: 8),

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

          // Achievement grid
          Expanded(
            child: filteredAchievements.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No achievements found',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: filteredAchievements.length,
                    itemBuilder: (context, index) {
                      final achievement = filteredAchievements[index];
                      final progress =
                          progressMap[achievement.id] ??
                          AchievementProgress(achievementId: achievement.id);

                      return RepaintBoundary(
                        child: AchievementCard(
                          achievement: achievement,
                          progress: progress,
                          onTap: () => _showAchievementDetail(
                            context,
                            achievement,
                            progress,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
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
