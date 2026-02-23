import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../data/daily_tips.dart';
import '../data/lesson_content.dart';
import '../data/species_database.dart';
import '../models/learning.dart';
import '../models/user_profile.dart';
import '../providers/gems_provider.dart';
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

                // Daily streak reminder — or encouraging recovery message
                SliverToBoxAdapter(child: _StreakCard(profile: profile)),

                // Practice card
                SliverToBoxAdapter(child: _PracticeCard(profile: profile)),

                // Daily plan card — always visible, shows today's tasks
                SliverToBoxAdapter(child: _DailyPlanCard(profile: profile)),

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

class _StreakCard extends ConsumerWidget {
  final UserProfile profile;

  const _StreakCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = profile.currentStreak;
    final hasFreeze = profile.hasStreakFreeze;
    final usedFreezeThisWeek = profile.streakFreezeUsedThisWeek;
    final longestStreak = profile.longestStreak;

    // Detect recently-broken streak: streak is low but longest was high
    final streakWasRecentlyBroken =
        streak <= 1 && longestStreak >= 5 && streak < longestStreak;

    if (streakWasRecentlyBroken) {
      return _buildBrokenStreakCard(context, ref, streak, longestStreak, hasFreeze);
    }

    if (streak == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                            ? 'Streak freeze ready — 1 skip per week covered 🧊'
                            : usedFreezeThisWeek
                                ? 'Streak freeze used this week'
                                : 'No streak freeze this week',
                        style: AppTypography.bodySmall.copyWith(
                          color: hasFreeze ? AppColors.info : AppColors.textHint,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrokenStreakCard(
    BuildContext context,
    WidgetRef ref,
    int currentStreak,
    int longestStreak,
    bool hasFreeze,
  ) {
    final gems = ref.watch(gemBalanceProvider);
    final canBuyFreeze = gems >= 10;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: const Color(0xFFFFCC02).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💪', style: TextStyle(fontSize: 28)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You\'re back! Start fresh 🌟',
                      style: AppTypography.labelLarge.copyWith(
                        color: const Color(0xFFE65100),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your best streak was $longestStreak days — you can beat it!',
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFFBF360C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!hasFreeze && canBuyFreeze) ...[
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: () => _buyStreakFreeze(context, ref),
              borderRadius: AppRadius.smallRadius,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.12),
                  borderRadius: AppRadius.smallRadius,
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.ac_unit, size: 16, color: AppColors.info),
                    const SizedBox(width: 6),
                    Text(
                      'Buy streak freeze for 💎10 gems',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _buyStreakFreeze(BuildContext context, WidgetRef ref) async {
    final gems = ref.read(gemBalanceProvider);
    if (gems < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough gems. Earn more by completing lessons!')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🧊 Buy Streak Freeze'),
        content: const Text(
          'Spend 10 gems to get a streak freeze that protects your streak for one missed day.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Buy (💎10)'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(gemsProvider.notifier).spendGems(
        amount: 10,
        itemId: 'streak_freeze',
        itemName: 'Streak Freeze',
      );
      await ref.read(userProfileProvider.notifier).addStreakFreeze();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🧊 Streak freeze activated! One missed day is covered.'),
            backgroundColor: AppColors.info,
          ),
        );
      }
    }
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

// ─────────────────────────────────────────────────────────────────────────────
// PHASE 3.1 — DAILY PLAN CARD
// Shows: micro lesson suggestion + quick quiz CTA + tank action + completion
// ─────────────────────────────────────────────────────────────────────────────

/// Daily Plan Card — always visible on the learn screen.
/// Surfaces today's suggested micro lesson, a quick quiz CTA, and a practical
/// tank action drawn from the daily-tips data.  Completion tracking is shown
/// via the daily-XP progress integrated below.
class _DailyPlanCard extends ConsumerWidget {
  final UserProfile profile;

  const _DailyPlanCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Suggested micro lesson ──
    final Lesson? suggestedLesson = _findNextLesson();

    // ── Tank action tip ──
    // Seed by day-of-year so it stays stable all day
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final tipIndex = dayOfYear % DailyTips.all.length;
    final tip = DailyTips.all[tipIndex];

    // ── Quick quiz available? ──
    final srState = ref.watch(spacedRepetitionProvider);
    final reviewDue = srState.stats.dueCards;

    // ── Daily goal completion ──
    final todayKey = _todayKey();
    final todayXp = profile.dailyXpHistory[todayKey] ?? 0;
    final goalXp = profile.dailyXpGoal;
    final dailyDone = todayXp >= goalXp;

    // Count completed tasks for the badge
    int tasksCompleted = 0;
    if (dailyDone) tasksCompleted++;
    if (reviewDue == 0 && srState.stats.totalCards > 0) tasksCompleted++;
    if (suggestedLesson != null &&
        profile.completedLessons.contains(suggestedLesson.id)) {
      tasksCompleted++;
    }
    final totalTasks = 3;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2035) : const Color(0xFFF0F7FF),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(
          color: AppColors.primary.withOpacity(isDark ? 0.3 : 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm,
            ),
            child: Row(
              children: [
                const Text('📋', style: TextStyle(fontSize: 20)),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Today\'s Plan',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: tasksCompleted == totalTasks
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: AppRadius.smallRadius,
                  ),
                  child: Text(
                    '$tasksCompleted/$totalTasks done',
                    style: AppTypography.labelSmall.copyWith(
                      color: tasksCompleted == totalTasks
                          ? AppColors.success
                          : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Task 1 — Micro lesson
          _DailyTask(
            emoji: '📖',
            title: suggestedLesson != null
                ? suggestedLesson.title
                : 'All lessons complete! Great work 🎉',
            subtitle: suggestedLesson != null
                ? '${suggestedLesson.estimatedMinutes} min · ${suggestedLesson.xpReward} XP'
                : 'Start a new path below',
            isDone: suggestedLesson == null ||
                profile.completedLessons.contains(suggestedLesson.id),
            onTap: suggestedLesson != null &&
                    !profile.completedLessons.contains(suggestedLesson.id)
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LessonScreen(
                          lesson: suggestedLesson,
                          pathTitle: _pathTitleFor(suggestedLesson),
                        ),
                      ),
                    )
                : null,
          ),

          // Task 2 — Quick quiz
          _DailyTask(
            emoji: '⚡',
            title: reviewDue > 0
                ? 'Quick Quiz — $reviewDue card${reviewDue == 1 ? '' : 's'} ready'
                : 'Quick Quiz — all cards reviewed!',
            subtitle: reviewDue > 0 ? 'Tap to review now' : 'Come back tomorrow',
            isDone: reviewDue == 0 && srState.stats.totalCards > 0,
            onTap: reviewDue > 0
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SpacedRepetitionPracticeScreen(),
                      ),
                    )
                : null,
          ),

          // Task 3 — Practical tank action
          _DailyTask(
            emoji: '🐠',
            title: tip.title,
            subtitle: tip.content,
            isDone: dailyDone, // If daily goal met, consider tank action "done"
            isSubtitleMultiline: true,
            onTap: null, // Informational
          ),

          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Find the first unfinished lesson across all paths
  Lesson? _findNextLesson() {
    for (final path in LessonContent.allPaths) {
      for (final lesson in path.lessons) {
        if (!profile.completedLessons.contains(lesson.id) &&
            lesson.isUnlocked(profile.completedLessons)) {
          return lesson;
        }
      }
    }
    return null;
  }

  String _pathTitleFor(Lesson lesson) {
    for (final path in LessonContent.allPaths) {
      if (path.lessons.any((l) => l.id == lesson.id)) return path.title;
    }
    return 'Learning';
  }
}

class _DailyTask extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool isDone;
  final VoidCallback? onTap;
  final bool isSubtitleMultiline;

  const _DailyTask({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isDone,
    this.onTap,
    this.isSubtitleMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Completion indicator
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.success.withOpacity(0.15)
                    : AppColors.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone
                      ? AppColors.success.withOpacity(0.4)
                      : Colors.transparent,
                ),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, size: 16, color: AppColors.success)
                    : Text(emoji, style: const TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDone
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onTap != null && !isDone) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: AppColors.textHint,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: isSubtitleMultiline ? 3 : 1,
                    overflow: TextOverflow.ellipsis,
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
