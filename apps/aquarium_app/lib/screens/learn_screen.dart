import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../data/species_database.dart';
import '../models/learning.dart';
import '../models/user_profile.dart';
import '../providers/lesson_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/spaced_repetition_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/core/fish_loader.dart';
import '../widgets/core/app_states.dart';
import '../widgets/study_room_scene.dart';
import 'lesson_screen.dart';
import 'parameter_guide_screen.dart';
import 'practice_screen.dart';
import 'spaced_repetition_practice_screen.dart';
import 'onboarding_screen.dart';
import '../utils/app_constants.dart';
import '../widgets/learning_streak_badge.dart';
import '../widgets/placement_challenge_card.dart';
import '../utils/navigation_throttle.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The main learning hub - shows learning paths and progress
/// Features a cozy illustrated "Study Room" header
class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToFirstLesson = false;
  final GlobalKey _firstPathKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _showFirstVisitTooltip();
  }

  Future<void> _showFirstVisitTooltip() async {
    final prefs = await SharedPreferences.getInstance();
    final visited = prefs.getBool('tab_0_visited') ?? false;
    if (!visited) {
      await prefs.setBool('tab_0_visited', true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📚 Welcome to the Study Room — your learning hub!'),
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Auto-scroll to first lesson module on first visit (no completed lessons).
  /// Uses a post-frame callback to scroll after the widget tree is laid out.
  void _maybeScrollToFirstLesson(UserProfile? profile) {
    if (_hasScrolledToFirstLesson) return;
    if (profile == null) return;
    if (profile.completedLessons.isNotEmpty) return;

    _hasScrolledToFirstLesson = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      // Scroll to the first learning path section dynamically
      final keyContext = _firstPathKey.currentContext;
      if (keyContext != null) {
        Scrollable.ensureVisible(
          keyContext,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      } else {
        // Fallback if key not yet attached
        _scrollController.animateTo(
          320.0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  static Widget _buildSkeletonScreen(
    BuildContext context, {
    ScrollController? controller,
  }) {
    return Semantics(
      liveRegion: true,
      label: 'Loading learning content',
      child: Skeletonizer(
        child: CustomScrollView(
          slivers: [
            // Skeleton header
            SliverToBoxAdapter(
              child: Container(height: 320, color: AppOverlays.primary10),
            ),
            // Skeleton learning paths header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm2,
                ),
                child: Semantics(
                  header: true,
                  child: Text(
                    'Learning Paths',
                    style: AppTypography.headlineSmall,
                  ),
                ),
              ),
            ),
            // Skeleton learning path cards
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
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
                        child: Center(
                          child: Text(
                            '🐟',
                            style: Theme.of(context).textTheme.headlineSmall!,
                          ),
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
                              backgroundColor: context.surfaceVariant,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for streak freeze consumption and show a notification
    ref.listen<bool>(streakFreezeUsedProvider, (prev, next) {
      if (next && mounted) {
        ref.read(streakFreezeUsedProvider.notifier).state = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Text('🧊', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Streak freeze used! Your streak was saved.'),
                ),
              ],
            ),
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final profileAsync = ref.watch(userProfileProvider);
    // Select only the two fields used by StudyRoomScene so that other stat
    // changes (e.g. weeklyXp updates) don't rebuild this 980-line screen.
    final statsXp = ref.watch(
      learningStatsProvider.select((s) => s?.totalXp ?? 0),
    );
    final statsLevel = ref.watch(
      learningStatsProvider.select((s) => s?.levelTitle ?? 'Beginner'),
    );
    // pathMetadataProvider: full list needed for path cards — cannot narrow
    // further without extracting each _LazyLearningPathCard into its own
    // ConsumerWidget (tracked: future refactor).
    final metadata = ref.watch(pathMetadataProvider);

    return Scaffold(
      body: profileAsync.when(
        loading: () =>
            _buildSkeletonScreen(context, controller: _scrollController),
        error: (e, _) => AppErrorState(
          title: 'Oops! Something went wrong',
          message:
              'We could not load your learning paths. Check your connection and try again.',
          onRetry: () => ref.invalidate(userProfileProvider),
        ),
        data: (profile) {
          // Calculate total lessons across all paths using lightweight metadata
          final totalLessons = metadata.fold<int>(
            0,
            (sum, meta) => sum + meta.lessonIds.length,
          );
          final completedLessons = profile?.completedLessons.length ?? 0;

          // Phase 3: auto-scroll to first lesson on first visit
          _maybeScrollToFirstLesson(profile);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userProfileProvider);
              ref.invalidate(learningStatsProvider);
              ref.invalidate(pathMetadataProvider);
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // === Study Room Scene Header ===
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 320,
                    child: Stack(
                      children: [
                        // Study room illustration
                        StudyRoomScene(
                          totalXp: statsXp,
                          levelTitle: statsLevel,
                          currentStreak: profile?.currentStreak ?? 0,
                          completedLessons: completedLessons,
                          totalLessons: totalLessons,
                          isNewUser: !(profile?.hasSeenTutorial ?? false),
                          onMicroscopeTap: () =>
                              _navigateToWaterChemistry(context),
                          onGlobeTap: () => _showRandomFishFact(context),
                        ),

                        // Title is shown inside StudyRoomScene XP badge
                      ],
                    ),
                  ),
                ),

                // === Content below the scene ===
                if (profile == null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_add,
                            size: AppIconSizes.xxl,
                            color: context.textSecondary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Complete your profile setup to start learning!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge!,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton.icon(
                            onPressed: () {
                              NavigationThrottle.push(
                                context,
                                const OnboardingScreen(),
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
                          const SizedBox(height: AppSpacing.xl),
                          // Getting started hints to fill empty space
                          Text(
                            '\u2728 What you\'ll unlock',
                            style: Theme.of(context).textTheme.titleSmall!
                                .copyWith(color: context.textSecondary),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '\ud83c\udf93 44 bite-sized lessons\n'
                            '\ud83e\udde0 Spaced repetition flashcards\n'
                            '\ud83c\udfc6 55+ achievements to earn\n'
                            '\ud83e\udd16 AI fish identification',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: context.textSecondary,
                                  height: 1.8,
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // Placement challenge card (intermediate/expert users only)
                  const SliverToBoxAdapter(child: PlacementChallengeCard()),

                  // Learning streak badge
                  if (profile.lessonProgress.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.sm,
                          AppSpacing.md,
                          0,
                        ),
                        child: LearningStreakBadge(
                          lessonProgress: profile.lessonProgress,
                        ),
                      ),
                    ),

                  // Spaced repetition review banner (due cards)
                  SliverToBoxAdapter(child: _ReviewCardsBanner()),

                  // Daily streak reminder
                  if (profile.currentStreak > 0)
                    SliverToBoxAdapter(child: _StreakCard(profile: profile)),

                  // Practice card
                  SliverToBoxAdapter(child: _PracticeCard(profile: profile)),

                  // Learning paths header with overall progress
                  SliverToBoxAdapter(
                    key: _firstPathKey,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.xs,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              'Learning Paths',
                              style: AppTypography.headlineSmall,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Builder(
                            builder: (context) {
                              final completedPaths = metadata.where((meta) {
                                final done = meta.lessonIds
                                    .where(
                                      (id) =>
                                          profile.completedLessons.contains(id),
                                    )
                                    .length;
                                return done == meta.lessonIds.length &&
                                    meta.lessonIds.isNotEmpty;
                              }).length;
                              final totalPaths = metadata.length;
                              final progress = totalPaths > 0
                                  ? completedPaths / totalPaths
                                  : 0.0;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$completedPaths of $totalPaths paths complete',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: context.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  ClipRRect(
                                    borderRadius: AppRadius.xsRadius,
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: context.surfaceVariant,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            AppColors.primary,
                                          ),
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Learning path cards (using lightweight metadata)
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final meta = metadata[index];
                      final completedInPath = meta.lessonIds
                          .where((id) => profile.completedLessons.contains(id))
                          .length;
                      final reduceMotion = MediaQuery.of(
                        context,
                      ).disableAnimations;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child:
                            _LazyLearningPathCard(
                                  metadata: meta,
                                  completedLessons: completedInPath,
                                  totalLessons: meta.lessonIds.length,
                                  userCompletedLessons:
                                      profile.completedLessons,
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
                    }, childCount: metadata.length),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: kScrollEndPadding),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /// Navigate to water chemistry/parameter guide
  void _navigateToWaterChemistry(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ParameterGuideScreen()));
  }

  /// Show a random fish fact in a dialog
  void _showRandomFishFact(BuildContext context) {
    final species = SpeciesDatabase.species;
    if (species.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fish facts are still loading — check back shortly!'),
        ),
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
            Text('🐠 ', style: Theme.of(context).textTheme.headlineSmall!),
            const Expanded(child: Text('Fish Fact!')),
          ],
        ),
        content: Text(fact, style: AppTypography.bodyLarge),
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
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      child: Semantics(
        button: true,
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
                  color: AppColors.onPrimary,
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
                          '🔔 ',
                          style: Theme.of(context).textTheme.titleLarge!,
                        ),
                        Text(
                          'Time to Review!',
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.onPrimary,
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
                color: AppColors.onPrimary,
                size: AppIconSizes.sm,
              ),
            ],
          ),
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
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      child: Semantics(
        button: true,
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
                  color: AppColors.onPrimary,
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
                            color: AppColors.onPrimary,
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
                              color: AppColors.onPrimary,
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
                color: AppColors.onPrimary,
                size: AppIconSizes.sm,
              ),
            ],
          ),
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
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
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
              color: DanioColors.amberGold,
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
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Keep learning to maintain your streak',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primaryLight,
                  ),
                ),
                if (hasFreeze || usedFreezeThisWeek) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.ac_unit,
                        size: AppIconSizes.xs,
                        color: hasFreeze ? AppColors.info : context.textHint,
                      ),
                      const SizedBox(width: AppSpacing.xs2),
                      Expanded(
                        child: Text(
                          hasFreeze
                              ? 'Streak freeze available (1 skip per week)'
                              : 'Streak freeze used this week',
                          style: AppTypography.bodySmall.copyWith(
                            color: hasFreeze
                                ? AppColors.info
                                : context.textHint,
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

/// Path IDs with mostly stub/empty content — gated as "Coming Soon".
const _comingSoonPathIds = {'advanced_topics'};

/// Individual stub lessons with placeholder content — gated as "Coming Soon"
/// within paths that also contain real, complete lessons.
const _stubLessonIds = <String>{
  // Fish Health stubs (fh_prevention is real content — keep accessible)
  'fh_ich',
  'fh_fin_rot',
  'fh_fungal',
  'fh_parasites',
  'fh_hospital_tank',
  // Species Care stubs (sc_betta, sc_goldfish are real — keep accessible)
  'sc_tetras',
  'sc_cichlids',
  'sc_shrimp',
  'sc_snails',
  // Advanced Topics — all stubs (path-level gated too, but listed for completeness)
  'at_breeding_livebearers',
  'at_breeding_egg_layers',
  'at_aquascaping',
  'at_biotope',
  'at_troubleshooting',
  'at_water_chem',
};

/// Lazy-loading learning path card.
/// Shows metadata (emoji, title, description, progress) immediately.
/// Loads full LearningPath only when the user expands the card.
class _LazyLearningPathCard extends ConsumerStatefulWidget {
  final PathMetadata metadata;
  final int completedLessons;
  final int totalLessons;
  final List<String> userCompletedLessons;

  const _LazyLearningPathCard({
    required this.metadata,
    required this.completedLessons,
    required this.totalLessons,
    required this.userCompletedLessons,
  });

  @override
  ConsumerState<_LazyLearningPathCard> createState() =>
      _LazyLearningPathCardState();
}

class _LazyLearningPathCardState extends ConsumerState<_LazyLearningPathCard> {
  @override
  Widget build(BuildContext context) {
    final meta = widget.metadata;
    final progress = widget.totalLessons > 0
        ? widget.completedLessons / widget.totalLessons
        : 0.0;
    final isComplete =
        widget.completedLessons == widget.totalLessons &&
        widget.totalLessons > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isComingSoon = _comingSoonPathIds.contains(meta.id);

    // Watch load state for this path
    final lessonState = ref.watch(lessonProvider);
    final loadedPath = lessonState.getPath(meta.id);
    final isLoading = lessonState.isPathLoading(meta.id);

    return Opacity(
      opacity: isComingSoon ? 0.6 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.blackAlpha30 : AppColors.blackAlpha05,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            if (isComplete)
              BoxShadow(
                color: isDark
                    ? AppColors.successAlpha20
                    : AppColors.successAlpha10,
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: isComingSoon
              ? _buildComingSoonTile(context, meta, isDark)
              : ExpansionTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  onExpansionChanged: (expanded) {
                    if (expanded && loadedPath == null && !isLoading) {
                      // Lazy-load the full path content when user expands
                      ref.read(lessonProvider.notifier).loadPath(meta.id);
                    }
                  },
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
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(
                        color: isComplete
                            ? AppColors.successAlpha30
                            : AppColors.primaryAlpha15,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        meta.emoji,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall!.copyWith(),
                      ),
                    ),
                  ),
                  title: Text(
                    meta.title,
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        meta.description,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondary,
                        ),
                        maxLines: 3,
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
                                    : AppColors.primaryAlpha15,
                                borderRadius: AppRadius.xsRadius,
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isComplete
                                          ? [
                                              AppColors.success,
                                              AppColors.successAlpha80,
                                            ]
                                          : [
                                              AppColors.primary,
                                              AppColors.secondary,
                                            ],
                                    ),
                                    borderRadius: AppRadius.xsRadius,
                                    boxShadow: progress > 0
                                        ? [
                                            BoxShadow(
                                              color: isComplete
                                                  ? AppColors.successAlpha40
                                                  : AppColors.primaryAlpha40,
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
                          const SizedBox(width: AppSpacing.sm2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.whiteAlpha10
                                  : context.surfaceVariant,
                              borderRadius: AppRadius.md2Radius,
                            ),
                            child: Text(
                              '${widget.completedLessons}/${widget.totalLessons}',
                              style: AppTypography.labelSmall.copyWith(
                                color: isDark
                                    ? context.textSecondary
                                    : context.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  children: _buildExpandedContent(loadedPath, isLoading),
                ),
        ),
      ),
    );
  }

  /// Builds a non-expandable tile for "Coming Soon" paths with a badge.
  Widget _buildComingSoonTile(
    BuildContext context,
    PathMetadata meta,
    bool isDark,
  ) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryAlpha15, AppColors.primaryAlpha10],
          ),
          borderRadius: AppRadius.mediumRadius,
          border: Border.all(color: AppColors.primaryAlpha15, width: 1),
        ),
        child: Center(
          child: Text(
            meta.emoji,
            style: Theme.of(context).textTheme.headlineSmall!,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              meta.title,
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: DanioColors.amberGold.withValues(alpha: 0.15),
              borderRadius: AppRadius.md2Radius,
              border: Border.all(
                color: DanioColors.amberGold.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              'Coming Soon 🚧',
              style: AppTypography.labelSmall.copyWith(
                color: DanioColors.amberGoldText, // WCAG AA text variant
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          meta.description,
          style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                Text(
                  '${meta.emoji} ',
                  style: Theme.of(context).textTheme.headlineSmall!,
                ),
                const Expanded(child: Text('Coming Soon!')),
              ],
            ),
            content: Text(
              'The "${meta.title}" path is coming soon — we\'re crafting something great! '
              'Stay tuned 🐟',
              style: AppTypography.bodyLarge,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Got it!'),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildExpandedContent(LearningPath? path, bool isLoading) {
    if (isLoading || path == null) {
      return [
        const Divider(height: 1),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ];
    }

    return [
      const Divider(height: 1),
      ...path.lessons.map((lesson) {
        final isStub = _stubLessonIds.contains(lesson.id);
        final isCompleted = widget.userCompletedLessons.contains(lesson.id);
        final isUnlocked =
            !isStub && lesson.isUnlocked(widget.userCompletedLessons);

        return Opacity(
          opacity: isStub ? 0.55 : 1.0,
          child: ListTile(
            leading: Hero(
              tag: 'lesson-${lesson.id}',
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isStub
                        ? DanioColors.amberGold.withValues(alpha: 0.15)
                        : isCompleted
                        ? AppOverlays.success20
                        : isUnlocked
                        ? AppOverlays.primary10
                        : context.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isStub
                        ? Icons.construction
                        : isCompleted
                        ? Icons.check
                        : isUnlocked
                        ? Icons.play_arrow
                        : Icons.lock,
                    size: 18,
                    color: isStub
                        ? DanioColors.amberGold
                        : isCompleted
                        ? AppColors.success
                        : isUnlocked
                        ? AppColors.primary
                        : context.textHint,
                  ),
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    lesson.title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isStub
                          ? context.textHint
                          : (isUnlocked ? null : context.textHint),
                    ),
                  ),
                ),
                if (isStub)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: DanioColors.amberGold.withValues(alpha: 0.15),
                      borderRadius: AppRadius.xsRadius,
                      border: Border.all(
                        color: DanioColors.amberGold.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      'Coming Soon 🚧',
                      style: AppTypography.labelSmall.copyWith(
                        color: DanioColors.amberGoldText, // WCAG AA text variant
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              isStub
                  ? 'Coming soon!'
                  : '${lesson.estimatedMinutes} min • ${lesson.xpReward} XP',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
              ),
            ),
            trailing: isCompleted && !isStub
                ? Text(
                    '+${lesson.xpReward} XP',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  )
                : null,
            enabled: isUnlocked && !isStub,
            onTap: isStub
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'This lesson is coming soon — stay tuned! 🚧',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                : isUnlocked
                ? () {
                    NavigationThrottle.push(
                      context,
                      LessonScreen(lesson: lesson, pathTitle: path.title),
                    );
                  }
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Complete the previous lesson to unlock this one 🔒',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
          ),
        );
      }),
    ];
  }
}
