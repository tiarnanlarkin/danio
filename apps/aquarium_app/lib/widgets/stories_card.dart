// Stories card widget for Learn Screen integration
// Quick access to interactive story mode

library;
import 'package:aquarium_app/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../data/stories.dart';
import '../screens/stories_screen.dart';

/// Card displaying Instagram-style stories access with progress ring.
///
/// Shows daily tips and educational content in story format. Displays completion
/// percentage and highlights next unlocked story. Taps navigate to full stories screen.
class StoriesCard extends ConsumerWidget {
  final UserProfile profile;

  const StoriesCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedStories = profile.completedStories.length;
    final totalStories = Stories.allStories.length;
    final progressPercent = totalStories > 0
        ? (completedStories / totalStories * 100).round()
        : 0;

    // Find an unlocked incomplete story to highlight
    final unlockedStories = Stories.getUnlockedStories(
      profile.completedStories,
      profile.currentLevel,
    );
    final incompleteStories = unlockedStories
        .where((s) => !profile.completedStories.contains(s.id))
        .toList();
    final suggestedStory = incompleteStories.isNotEmpty
        ? incompleteStories.first
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: AppElevation.level2,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const StoriesScreen()),
          );
        },
        borderRadius: AppRadius.mediumRadius,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg2),
          decoration: BoxDecoration(
            borderRadius: AppRadius.mediumRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple.shade400, Colors.deepPurple.shade600],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm2),
                    decoration: BoxDecoration(
                      color: AppOverlays.white20,
                      borderRadius: AppRadius.mediumRadius,
                    ),
                    child: const Text('📖', style: TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Interactive Stories',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Learn through scenarios',
                          style: TextStyle(
                            color: AppOverlays.white90,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: AppIconSizes.sm,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$completedStories/$totalStories completed',
                        style: TextStyle(
                          color: AppOverlays.white90,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$progressPercent%',
                        style: TextStyle(
                          color: AppOverlays.white90,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: AppRadius.xsRadius,
                    child: LinearProgressIndicator(
                      value: completedStories / totalStories,
                      backgroundColor: AppOverlays.white30,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.amber,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),

              // Suggested story
              if (suggestedStory != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm2),
                  decoration: BoxDecoration(
                    color: AppOverlays.white15,
                    borderRadius: AppRadius.mediumRadius,
                    border: Border.all(color: AppOverlays.white30),
                  ),
                  child: Row(
                    children: [
                      Text(
                        suggestedStory.thumbnailImage ?? '📖',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Try this:',
                              style: TextStyle(
                                color: AppOverlays.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              suggestedStory.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppOverlays.amber30,
                          borderRadius: AppRadius.smallRadius,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '+${suggestedStory.xpReward}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
