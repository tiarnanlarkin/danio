import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../data/species_database.dart';
import '../../models/user_profile.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_button.dart';
import '../../widgets/core/app_dialog.dart';
import '../../widgets/core/app_states.dart';
import '../../widgets/core/glass_card.dart';
import '../../widgets/study_room_scene.dart';
import '../onboarding_screen.dart';
import '../parameter_guide_screen.dart';
import '../../utils/app_constants.dart';
import '../../widgets/learning_streak_badge.dart';
import '../../widgets/placement_challenge_card.dart';
import '../../utils/navigation_throttle.dart';
import '../../widgets/first_visit_tooltip.dart';
import '../../widgets/danio_snack_bar.dart';
import 'learn_review_banner.dart';
import 'learn_practice_card.dart';
import 'learn_streak_card.dart';
import 'lazy_learning_path_card.dart';
import '../story/story_browser_screen.dart';

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
  bool _showTooltip = true;
  final GlobalKey _firstPathKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _checkFirstVisitTooltip();
  }

  Future<void> _checkFirstVisitTooltip() async {
    final seen = await hasSeenTooltip('tooltip_seen_learn', ref);
    if (mounted) setState(() => _showTooltip = !seen);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Auto-scroll to first lesson module on first visit (no completed lessons).
  void _maybeScrollToFirstLesson(UserProfile? userProfile) {
    if (_hasScrolledToFirstLesson) return;
    if (userProfile == null) return;
    if (userProfile.completedLessons.isNotEmpty) return;

    _hasScrolledToFirstLesson = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final keyContext = _firstPathKey.currentContext;
      if (keyContext != null) {
        Scrollable.ensureVisible(
          keyContext,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_scrollController.hasClients) return;
          final retryContext = _firstPathKey.currentContext;
          if (retryContext != null) {
            Scrollable.ensureVisible(
              retryContext,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
            );
          }
        });
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
            SliverToBoxAdapter(
              child: Builder(
                builder: (context) => Container(
                  height: MediaQuery.of(context).size.height * 0.38,
                  color: AppOverlays.primary10,
                ),
              ),
            ),
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
    ref.listen<bool>(streakFreezeUsedProvider, (prev, next) {
      if (next && mounted) {
        ref.read(streakFreezeUsedProvider.notifier).state = false;
        DanioSnackBar.info(
          context,
          '🧊 Streak freeze used! Your streak was saved.',
        );
      }
    });

    final metadata = ref.watch(pathMetadataProvider);

    if (_showTooltip) {
      return Stack(
        children: [
          _buildLearnScaffold(context, metadata),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: FirstVisitTooltip(
                prefsKey: 'tooltip_seen_learn',
                emoji: '📚',
                message: 'Welcome to the Study Room — your learning hub!',
                onDismissed: () => setState(() => _showTooltip = false),
              ),
            ),
          ),
        ],
      );
    }
    return _buildLearnScaffold(context, metadata);
  }

  Widget _buildLearnScaffold(
    BuildContext context,
    List<PathMetadata> metadata,
  ) {
    // --- Selective watch to avoid full rebuilds on every XP/streak tick ---
    // UserProfile has no == override, so any mutation (XP gain, gem change,
    // review card update, etc.) triggers a rebuild of this entire screen.
    // We select only the fields this screen renders; changes to totalXp,
    // gems, inventory, etc. are ignored. Dart records have value equality.
    final profileState = ref.watch(
      userProfileProvider.select((s) => (
        isLoading: s.isLoading,
        hasError: s.hasError,
        error: s.hasError ? s.error : null,
        isNull: !s.hasValue || s.value == null,
        // Use length (int) not List identity — List has no deep equality.
        completedLessonCount: s.value?.completedLessons.length ?? 0,
        currentStreak: s.value?.currentStreak ?? 0,
        hasSeenTutorial: s.value?.hasSeenTutorial ?? false,
        hasLessonProgress: s.value?.lessonProgress.isNotEmpty ?? false,
      )),
    );
    final statsXp = ref.watch(
      learningStatsProvider.select((s) => s?.totalXp ?? 0),
    );
    final statsLevel = ref.watch(
      learningStatsProvider.select((s) => s?.levelTitle ?? 'Beginner'),
    );

    return Scaffold(
      body: profileState.isLoading
          ? _buildSkeletonScreen(context, controller: _scrollController)
          : profileState.hasError
              ? AppErrorState(
                  title: 'Oops! Something went wrong',
                  message:
                      'We could not load your learning paths. Check your connection and try again.',
                  onRetry: () => ref.invalidate(userProfileProvider),
                )
              : Builder(builder: (context) {
          // Read the full profile only when needed by child widgets.
          // This is ref.read (not watch) — rebuilds are driven solely by
          // the selective profileState watch above.
          final profile = ref.read(userProfileProvider).value;
          final totalLessons = metadata.fold<int>(
            0,
            (sum, meta) => sum + meta.lessonIds.length,
          );
          final completedLessons = profileState.completedLessonCount;

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
                // Study Room Scene Header
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.38,
                    child: Stack(
                      children: [
                        StudyRoomScene(
                          totalXp: statsXp,
                          levelTitle: statsLevel,
                          currentStreak: profileState.currentStreak,
                          completedLessons: completedLessons,
                          totalLessons: totalLessons,
                          isNewUser: !profileState.hasSeenTutorial,
                          onMicroscopeTap: () =>
                              _navigateToWaterChemistry(context),
                          onGlobeTap: () => _showRandomFishFact(context),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content below the scene
                if (profileState.isNull)
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
                          AppButton(
                            onPressed: () {
                              NavigationThrottle.push(
                                context,
                                const OnboardingScreen(),
                              );
                            },
                            trailingIcon: Icons.arrow_forward,
                            label: 'Create Profile',
                            size: AppButtonSize.large,
                          ),
                          const SizedBox(height: AppSpacing.xl),
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
                  // Placement challenge card
                  const SliverToBoxAdapter(child: PlacementChallengeCard()),

                  // Learning streak badge
                  if (profileState.hasLessonProgress)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.sm,
                          AppSpacing.md,
                          0,
                        ),
                        child: LearningStreakBadge(
                          lessonProgress: profile!.lessonProgress,
                        ),
                      ),
                    ),

                  // Spaced repetition review banner
                  const SliverToBoxAdapter(child: LearnReviewBanner()),

                  // Daily streak reminder
                  if (profileState.currentStreak > 0)
                    SliverToBoxAdapter(
                      child: LearnStreakCard(profile: profile!),
                    ),

                  // Practice card
                  SliverToBoxAdapter(
                    child: LearnPracticeCard(profile: profile!),
                  ),

                  // Interactive stories section
                  SliverToBoxAdapter(
                    child: _StoriesSection(),
                  ),

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
                              final userCompleted = profile.completedLessons;
                              final completedPaths = metadata.where((meta) {
                                final done = meta.lessonIds
                                    .where(
                                      (id) =>
                                          userCompleted.contains(id),
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

                  // Learning path cards
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final meta = metadata[index];
                        final userCompleted = profile.completedLessons;
                        final completedInPath = meta.lessonIds
                            .where(
                              (id) => userCompleted.contains(id),
                            )
                            .length;
                        final reduceMotion =
                            MediaQuery.of(context).disableAnimations;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: reduceMotion
                              ? LazyLearningPathCard(
                                  metadata: meta,
                                  completedLessons: completedInPath,
                                  totalLessons: meta.lessonIds.length,
                                  userCompletedLessons: userCompleted,
                                  allPathMetadata: metadata,
                                )
                              : LazyLearningPathCard(
                                  metadata: meta,
                                  completedLessons: completedInPath,
                                  totalLessons: meta.lessonIds.length,
                                  userCompletedLessons: userCompleted,
                                  allPathMetadata: metadata,
                                )
                                .animate()
                                .fadeIn(
                                  duration: 300.ms,
                                  delay: (index * 50).ms,
                                )
                                .slideY(
                                  begin: 0.2,
                                  end: 0,
                                  duration: 300.ms,
                                  delay: (index * 50).ms,
                                ),
                        );
                      },
                      childCount: metadata.length,
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: kScrollEndPadding),
                  ),
                ],
              ],
            ),
          );
        }),
    );
  }

  void _navigateToWaterChemistry(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ParameterGuideScreen()),
    );
  }

  void _showRandomFishFact(BuildContext context) {
    final species = SpeciesDatabase.species;
    if (species.isEmpty) {
      DanioSnackBar.info(
        context,
        'Fish facts are still loading — check back shortly!',
      );
      return;
    }

    final random = math.Random();
    final randomSpecies = species[random.nextInt(species.length)];

    final facts = [
      '${randomSpecies.commonName} (${randomSpecies.scientificName}) can grow up to ${randomSpecies.adultSizeCm}cm!',
      'Did you know? ${randomSpecies.commonName} prefers a temperature of ${randomSpecies.minTempC}°C - ${randomSpecies.maxTempC}°C.',
      '${randomSpecies.commonName} is ${randomSpecies.temperament.toLowerCase()} and swims at the ${randomSpecies.swimLevel.toLowerCase()} level.',
      'The ${randomSpecies.commonName} is from the ${randomSpecies.family} family.',
      '${randomSpecies.commonName} needs at least ${randomSpecies.minTankLitres}L of tank space.',
      'A ${randomSpecies.commonName} is best kept in groups of ${randomSpecies.minSchoolSize} or more.',
    ];

    final fact = facts[random.nextInt(facts.length)];

    showAppDialog(
      context: context,
      title: '🐠 Fish Fact!',
      child: Text(fact, style: AppTypography.bodyLarge),
      actions: [
        AppButton(
          label: 'Cool!',
          onPressed: () => Navigator.of(context).pop(),
          variant: AppButtonVariant.text,
          isFullWidth: true,
        ),
        const SizedBox(height: AppSpacing.xs),
        AppButton(
          label: 'Another!',
          onPressed: () {
            Navigator.of(context).pop();
            _showRandomFishFact(context);
          },
          variant: AppButtonVariant.primary,
          isFullWidth: true,
        ),
      ],
    );
  }
}

/// Section in the Learn tab that links to interactive stories.
class _StoriesSection extends StatelessWidget {
  const _StoriesSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: GlassCard(
        semanticLabel: 'Interactive Stories',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const StoryBrowserScreen(),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Center(
                  child: Text('📖', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interactive Stories',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Learn through choose-your-own-adventure scenarios',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
