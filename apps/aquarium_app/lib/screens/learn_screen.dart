import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/lesson_content.dart';
import '../models/learning.dart';
import '../models/user_profile.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/study_room_scene.dart';
import 'lesson_screen.dart';

/// The main learning hub - shows learning paths and progress
/// Features a cozy illustrated "Study Room" header
class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final stats = ref.watch(learningStatsProvider);

    return Scaffold(
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          // Calculate total lessons across all paths
          final totalLessons = LessonContent.allPaths
              .fold<int>(0, (sum, path) => sum + path.lessons.length);
          final completedLessons = profile?.completedLessons.length ?? 0;

          return CustomScrollView(
            slivers: [
              // === Study Room Scene Header ===
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 320,
                  child: Stack(
                    children: [
                      // Study room illustration
                      StudyRoomScene(
                        totalXp: stats?.totalXp ?? 0,
                        levelTitle: stats?.levelTitle ?? 'Beginner',
                        currentStreak: profile?.currentStreak ?? 0,
                        completedLessons: completedLessons,
                        totalLessons: totalLessons,
                      ),
                      // Back button overlay
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 8,
                        child: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      // Title overlay
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 16,
                        left: 0,
                        right: 0,
                        child: const Center(
                          child: Text(
                            '📚 Study',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // === Content below the scene ===
              if (profile == null)
                const SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Complete onboarding to start your learning journey!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else ...[
                // Daily streak reminder
                if (profile.currentStreak > 0)
                  SliverToBoxAdapter(
                    child: _StreakCard(profile: profile),
                  ),

                // Learning paths header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Text(
                      'Learning Paths',
                      style: AppTypography.headlineSmall,
                    ),
                  ),
                ),

                // Learning path cards
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final path = LessonContent.allPaths[index];
                      final completedInPath = path.lessons
                          .where((l) => profile.completedLessons.contains(l.id))
                          .length;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: _LearningPathCard(
                          path: path,
                          completedLessons: completedInPath,
                          totalLessons: path.lessons.length,
                          userCompletedLessons: profile.completedLessons,
                          onLessonTap: (lesson) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LessonScreen(
                                  lesson: lesson,
                                  pathTitle: path.title,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: LessonContent.allPaths.length,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final UserProfile profile;

  const _StreakCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final streak = profile.currentStreak;
    final hasFreeze = profile.hasStreakFreeze;
    final usedFreezeThisWeek = profile.streakFreezeUsedThisWeek;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.orange,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak day streak! 🔥',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Keep learning (or logging) to maintain your streak',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.orange.shade600,
                  ),
                ),
                if (hasFreeze || usedFreezeThisWeek) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.ac_unit,
                        size: 16,
                        color: hasFreeze ? AppColors.info : AppColors.textHint,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          hasFreeze
                              ? 'Streak freeze available (1 skip per week)'
                              : 'Streak freeze used this week',
                          style: AppTypography.bodySmall.copyWith(
                            color: hasFreeze ? AppColors.info : AppColors.textHint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningPathCard extends StatelessWidget {
  final LearningPath path;
  final int completedLessons;
  final int totalLessons;
  final List<String> userCompletedLessons;
  final ValueChanged<Lesson> onLessonTap;

  const _LearningPathCard({
    required this.path,
    required this.completedLessons,
    required this.totalLessons,
    required this.userCompletedLessons,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalLessons > 0 ? completedLessons / totalLessons : 0.0;
    final isComplete = completedLessons == totalLessons && totalLessons > 0;

    return Card(
      margin: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isComplete
                  ? AppColors.success.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(path.emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          title: Text(path.title, style: AppTypography.labelLarge),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                path.description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isComplete ? AppColors.success : AppColors.primary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$completedLessons/$totalLessons',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            const Divider(height: 1),
            ...path.lessons.map((lesson) {
              final isCompleted = userCompletedLessons.contains(lesson.id);
              final isUnlocked = lesson.isUnlocked(userCompletedLessons);

              return ListTile(
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.success.withOpacity(0.2)
                        : isUnlocked
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check
                        : isUnlocked
                            ? Icons.play_arrow
                            : Icons.lock,
                    size: 18,
                    color: isCompleted
                        ? AppColors.success
                        : isUnlocked
                            ? AppColors.primary
                            : AppColors.textHint,
                  ),
                ),
                title: Text(
                  lesson.title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isUnlocked ? null : AppColors.textHint,
                  ),
                ),
                subtitle: Text(
                  '${lesson.estimatedMinutes} min • ${lesson.xpReward} XP',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: isCompleted
                    ? Text(
                        '+${lesson.xpReward} XP',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.success,
                        ),
                      )
                    : null,
                enabled: isUnlocked,
                onTap: isUnlocked ? () => onLessonTap(lesson) : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}
