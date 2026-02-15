import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../data/lesson_content.dart';
import '../data/species_database.dart';
import '../models/learning.dart';
import '../models/user_profile.dart';
import '../providers/user_profile_provider.dart';
import '../providers/spaced_repetition_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/core/fish_loader.dart';
import '../widgets/study_room_scene.dart';
import '../widgets/hearts_widgets.dart';
import 'lesson_screen.dart';
import 'parameter_guide_screen.dart';
import 'practice_screen.dart';
import 'spaced_repetition_practice_screen.dart';
import 'onboarding/profile_creation_screen.dart';

/// The main learning hub - shows learning paths and progress
/// Features a cozy illustrated "Study Room" header
class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  static Widget _buildSkeletonScreen(BuildContext context) {
    return Skeletonizer(
      child: CustomScrollView(
        slivers: [
          // Skeleton header
          SliverToBoxAdapter(
            child: Container(
              height: 320,
              color: AppOverlays.primary10,
            ),
          ),
          // Skeleton learning paths header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Text('Learning Paths', style: AppTypography.headlineSmall),
            ),
          ),
          // Skeleton learning path cards
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppOverlays.primary10,
                        borderRadius: AppRadius.mediumRadius,
                      ),
                      child: const Center(
                        child: Text('🐟', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    title: const Text('Loading learning path'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.xs),
                        const Text('Description of this learning path'),
                        const SizedBox(height: AppSpacing.sm),
                        ClipRRect(
                          borderRadius: AppRadius.xsRadius,
                          child: LinearProgressIndicator(
                            value: 0.5,
                            backgroundColor: AppColors.surfaceVariant,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              childCount: 4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final stats = ref.watch(learningStatsProvider);

    return Scaffold(
      body: profileAsync.when(
        loading: () => _buildSkeletonScreen(context),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          // Calculate total lessons across all paths
          final totalLessons = LessonContent.allPaths.fold<int>(
            0,
            (sum, path) => sum + path.lessons.length,
          );
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
                        isNewUser: !(profile?.hasSeenTutorial ?? false),
                        onMicroscopeTap: () => _navigateToWaterChemistry(context),
                        onGlobeTap: () => _showRandomFishFact(context),
                      ),
                      // No back button - LearnScreen is Room 0 in HouseNavigator
                      // Navigation between rooms is via swipe or room indicator bar
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
                                Shadow(color: Colors.black45, blurRadius: 8),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Hearts indicator
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 12,
                        right: 16,
                        child: const HeartIndicator(compact: true),
                      ),
                    ],
                  ),
                ),
              ),

              // === Content below the scene ===
              if (profile == null)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person_add,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Text(
                            'Complete your profile setup to start learning!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfileCreationScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Create Profile'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                // Spaced repetition review banner (due cards)
                SliverToBoxAdapter(child: _ReviewCardsBanner()),

                // Daily streak reminder
                if (profile.currentStreak > 0)
                  SliverToBoxAdapter(child: _StreakCard(profile: profile)),

                // Practice card
                SliverToBoxAdapter(child: _PracticeCard(profile: profile)),

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
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final path = LessonContent.allPaths[index];
                    final completedInPath = path.lessons
                        .where((l) => profile.completedLessons.contains(l.id))
                        .length;
                    final reduceMotion = MediaQuery.of(context).disableAnimations;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                      )
                          .animate(autoPlay: !reduceMotion)
                          .fadeIn(
                            duration: reduceMotion ? 0.ms : 300.ms,
                            delay: reduceMotion ? 0.ms : (index * 50).ms,
                          )
                          .slideY(
                            begin: reduceMotion ? 0 : 0.2,
                            end: 0,
                            duration: reduceMotion ? 0.ms : 300.ms,
                            delay: reduceMotion ? 0.ms : (index * 50).ms,
                          ),
                    );
                  }, childCount: LessonContent.allPaths.length),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Navigate to water chemistry/parameter guide
  void _navigateToWaterChemistry(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ParameterGuideScreen()),
    );
  }

  /// Show a random fish fact in a dialog
  void _showRandomFishFact(BuildContext context) {
    final species = SpeciesDatabase.species;
    if (species.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No fish facts available yet!')),
      );
      return;
    }

    final random = math.Random();
    final randomSpecies = species[random.nextInt(species.length)];

    // Generate a fun fact
    final facts = [
      '${randomSpecies.commonName} (${randomSpecies.scientificName}) can grow up to ${randomSpecies.adultSizeCm}cm!',
      'Did you know? ${randomSpecies.commonName} prefers a temperature of ${randomSpecies.minTempC}°C - ${randomSpecies.maxTempC}°C.',
      '${randomSpecies.commonName} is ${randomSpecies.temperament.toLowerCase()} and swims at the ${randomSpecies.swimLevel.toLowerCase()} level.',
      'The ${randomSpecies.commonName} is from the ${randomSpecies.family} family.',
      '${randomSpecies.commonName} needs at least ${randomSpecies.minTankLitres}L of tank space.',
      'A ${randomSpecies.commonName} is best kept in groups of ${randomSpecies.minSchoolSize} or more.',
    ];

    final fact = facts[random.nextInt(facts.length)];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Text('🐠 ', style: TextStyle(fontSize: 24)),
            const Expanded(child: Text('Fish Fact!')),
          ],
        ),
        content: Text(
          fact,
          style: AppTypography.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cool!'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showRandomFishFact(context); // Show another
            },
            child: const Text('Another!'),
          ),
        ],
      ),
    );
  }
}

/// Banner showing spaced repetition cards due for review
class _ReviewCardsBanner extends ConsumerWidget {
  const _ReviewCardsBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final srState = ref.watch(spacedRepetitionProvider);
    final dueCount = srState.stats.dueCards;

    // Don't show banner if no cards are due
    if (dueCount == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SpacedRepetitionPracticeScreen(),
            ),
          );
        },
        borderRadius: AppRadius.mediumRadius,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.accent, AppOverlays.accent80],
            ),
            borderRadius: AppRadius.mediumRadius,
            boxShadow: const [
              BoxShadow(
                color: AppOverlays.accent30,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppOverlays.white20,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🔔 ', style: TextStyle(fontSize: 18)),
                        Text(
                          'Time to Review!',
                          style: AppTypography.headlineSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'You have $dueCount card${dueCount == 1 ? '' : 's'} ready to review',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppOverlays.white90,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Tap to start practicing',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppOverlays.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PracticeCard extends ConsumerWidget {
  final UserProfile profile;

  const _PracticeCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weakLessons = ref
        .read(userProfileProvider.notifier)
        .getWeakestLessons();
    final weakCount = weakLessons.length;

    // Don't show if no lessons to review
    if (weakCount == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: InkWell(
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const PracticeScreen()));
        },
        borderRadius: AppRadius.mediumRadius,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppOverlays.primary80],
            ),
            borderRadius: AppRadius.mediumRadius,
            boxShadow: const [
              BoxShadow(
                color: AppOverlays.primary30,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppOverlays.white20,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Practice Mode',
                          style: AppTypography.headlineSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: AppRadius.mediumRadius,
                          ),
                          child: Text(
                            '$weakCount',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$weakCount lesson${weakCount == 1 ? '' : 's'} need review',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppOverlays.white90,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Review before you forget!',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppOverlays.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppOverlays.orange10,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppOverlays.orange30),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppOverlays.orange20,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.orange,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
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
                  const SizedBox(height: AppSpacing.sm),
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
                            color: hasFreeze
                                ? AppColors.info
                                : AppColors.textHint,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2030) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.blackAlpha30 : AppColors.blackAlpha05,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          if (isComplete)
            BoxShadow(
              color: AppColors.success.withOpacity(isDark ? 0.2 : 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: isComplete
                  ? LinearGradient(
                      colors: [
                        AppColors.successAlpha20,
                        AppColors.successAlpha10,
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        AppColors.primaryAlpha15,
                        AppColors.primaryAlpha10,
                      ],
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isComplete
                    ? AppColors.successAlpha30
                    : AppColors.primaryAlpha15,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(path.emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          title: Text(
            path.title,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xs),
              Text(
                path.description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: isDark 
                            ? AppColors.whiteAlpha10
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isComplete
                                  ? [AppColors.success, AppColors.successAlpha80]
                                  : [AppColors.primary, AppColors.secondary],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: progress > 0
                                ? [
                                    BoxShadow(
                                      color: isComplete ? AppColors.successAlpha40 : AppColors.primaryAlpha40,
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.whiteAlpha10
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$completedLessons/$totalLessons',
                      style: AppTypography.labelSmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
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
                leading: Hero(
                  tag: 'lesson-${lesson.id}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppOverlays.success20
                            : isUnlocked
                            ? AppOverlays.primary10
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
