import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../models/user_profile.dart';
import '../../models/learning.dart';
import '../../providers/learning_catalog_provider.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/learning_visuals.dart';
import '../../widgets/core/app_button.dart';
import '../../widgets/core/app_states.dart';
import '../../widgets/core/glass_card.dart';
import '../onboarding_screen.dart';
import '../../widgets/themed_tab_header.dart';
import '../../widgets/learning_streak_badge.dart';
import '../../widgets/placement_challenge_card.dart';
import '../../widgets/danio_bottom_dock.dart';
import '../../navigation/app_routes.dart';
import '../../utils/navigation_throttle.dart';
import '../../widgets/first_visit_tooltip.dart';
import '../../widgets/danio_snack_bar.dart';
import 'learn_review_banner.dart';
import 'learn_streak_card.dart';
import 'lazy_learning_path_card.dart';
import '../lesson_screen.dart';

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

  void _scrollToLearningPaths() {
    final keyContext = _firstPathKey.currentContext;
    if (keyContext == null) return;
    Scrollable.ensureVisible(
      keyContext,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  ({PathMetadata path, String lessonId})? _nextLessonTarget(
    List<PathMetadata> metadata,
    UserProfile profile,
  ) {
    final ordered = [...metadata]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    for (final path in ordered) {
      if (!path.isUnlocked(profile.completedLessons, metadata)) continue;
      for (final lessonId in path.lessonIds) {
        if (!profile.completedLessons.contains(lessonId)) {
          return (path: path, lessonId: lessonId);
        }
      }
    }
    return null;
  }

  Future<void> _openNextLesson(PathMetadata path, String lessonId) async {
    final lessonNotifier = ref.read(lessonProvider.notifier);
    await lessonNotifier.loadPath(path.id);
    if (!mounted) return;

    final loadedPath = ref.read(lessonProvider).getPath(path.id);
    final lesson = loadedPath == null
        ? null
        : _findLessonById(loadedPath.lessons, lessonId);
    if (lesson == null) {
      DanioSnackBar.error(context, 'Couldn\'t open that lesson. Try again.');
      return;
    }

    NavigationThrottle.push(
      context,
      LessonScreen(lesson: lesson, pathTitle: loadedPath!.title),
    );
  }

  Lesson? _findLessonById(List<Lesson> lessons, String lessonId) {
    for (final lesson in lessons) {
      if (lesson.id == lessonId) return lesson;
    }
    return null;
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
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.primary,
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
          'Streak freeze used. Your streak was saved.',
        );
      }
    });

    // Use .select() to pin rebuilds to list-length changes only; avoids
    // spurious rebuilds when unrelated metadata state is updated.
    final metadata = ref.watch(pathMetadataProvider.select((list) => list));
    final catalog = ref.watch(learningCatalogSummaryProvider);

    if (_showTooltip) {
      return Stack(
        children: [
          _buildLearnScaffold(context, metadata, catalog),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: FirstVisitTooltip(
                prefsKey: 'tooltip_seen_learn',
                icon: Icons.menu_book_rounded,
                iconColor: AppColors.primary,
                iconBackgroundColor: AppColors.primaryAlpha10,
                message:
                    'Learn builds safe tank habits. Practice brings them back when they need review.',
                onDismissed: () => setState(() => _showTooltip = false),
              ),
            ),
          ),
        ],
      );
    }
    return _buildLearnScaffold(context, metadata, catalog);
  }

  Widget _buildLearnScaffold(
    BuildContext context,
    List<PathMetadata> metadata,
    LearningCatalogSummary catalog,
  ) {
    // --- Selective watch to avoid full rebuilds on every XP/streak tick ---
    // UserProfile has no == override, so any mutation (XP gain, gem change,
    // review card update, etc.) triggers a rebuild of this entire screen.
    // We select only the fields this screen renders; changes to totalXp,
    // gems, inventory, etc. are ignored. Dart records have value equality.
    final profileState = ref.watch(
      userProfileProvider.select(
        (s) => (
          isLoading: s.isLoading,
          hasError: s.hasError,
          error: s.hasError ? s.error : null,
          isNull: !s.hasValue || s.value == null,
          // Use length (int) not List identity — List has no deep equality.
          completedLessonCount: s.value?.completedLessons.length ?? 0,
          currentStreak: s.value?.currentStreak ?? 0,
          hasLessonProgress: s.value?.lessonProgress.isNotEmpty ?? false,
        ),
      ),
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
              title: 'Couldn\'t load lessons',
              message:
                  'We could not load your learning paths. Check your connection and try again.',
              onRetry: () => ref.invalidate(userProfileProvider),
            )
          : Builder(
              builder: (context) {
                // Read the full profile only when needed by child widgets.
                // This is ref.read (not watch) — rebuilds are driven solely by
                // the selective profileState watch above.
                final profile = ref.read(userProfileProvider).value;
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
                      // Themed Learn Header
                      ThemedTabHeader(
                        tab: TabHeaderContext.learn,
                        height: MediaQuery.of(context).size.height * 0.32,
                        overlays: [
                          // XP / level badge (top-left)
                          Positioned(
                            top: 48,
                            left: AppSpacing.md,
                            child: SafeArea(
                              bottom: false,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  borderRadius: AppRadius.md2Radius,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.stars_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      '$statsXp XP \u00b7 $statsLevel',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Streak badge (top-right)
                          if (profileState.currentStreak > 0)
                            Positioned(
                              top: 48,
                              right: AppSpacing.md,
                              child: SafeArea(
                                bottom: false,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    borderRadius: AppRadius.md2Radius,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.local_fire_department_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        '${profileState.currentStreak}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
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
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge!,
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
                                  'What you\'ll unlock',
                                  style: Theme.of(context).textTheme.titleSmall!
                                      .copyWith(color: context.textSecondary),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                _UnlockList(
                                  lessonCount: catalog.lessonCount,
                                  achievementCount: catalog.achievementCount,
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        SliverToBoxAdapter(
                          child: _NextLearningCard(
                            target: profile == null
                                ? null
                                : _nextLessonTarget(metadata, profile),
                            completedLessons: completedLessons,
                            totalLessons: catalog.lessonCount,
                            onStartLesson: (target) =>
                                _openNextLesson(target.path, target.lessonId),
                            onBrowsePaths: _scrollToLearningPaths,
                          ),
                        ),

                        // Compact handoff to Practice when reviews are due.
                        const SliverToBoxAdapter(child: LearnReviewBanner()),

                        // Placement challenge card
                        const SliverToBoxAdapter(
                          child: PlacementChallengeCard(),
                        ),

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

                        // Daily streak reminder
                        if (profileState.currentStreak > 0)
                          SliverToBoxAdapter(
                            child: LearnStreakCard(profile: profile!),
                          ),

                        // Interactive stories section
                        SliverToBoxAdapter(child: _StoriesSection()),

                        // Cold-start nudge: shown only when user has no completed lessons
                        if (completedLessons == 0)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.md,
                                AppSpacing.md,
                                AppSpacing.md,
                                0,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryAlpha08,
                                  borderRadius: AppRadius.mediumRadius,
                                  border: Border.all(
                                    color: AppColors.primaryAlpha15,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.water_drop_rounded,
                                      color: AppColors.primary,
                                      size: 22,
                                    ),
                                    const SizedBox(width: AppSpacing.sm2),
                                    Expanded(
                                      child: Text(
                                        'Start with safe tank habits. Practice will bring the important ideas back tomorrow.',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.primaryDark,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
                                    final userCompleted =
                                        profile!.completedLessons;
                                    final completedPaths = metadata.where((
                                      meta,
                                    ) {
                                      final done = meta.lessonIds
                                          .where(
                                            (id) => userCompleted.contains(id),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          completedPaths == 0
                                              ? '$totalPaths paths to explore'
                                              : '$completedPaths of $totalPaths paths complete',
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                color: context.textSecondary,
                                              ),
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        ClipRRect(
                                          borderRadius: AppRadius.xsRadius,
                                          child: LinearProgressIndicator(
                                            value: progress,
                                            backgroundColor:
                                                context.surfaceVariant,
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                  Color
                                                >(AppColors.primary),
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
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final meta = metadata[index];
                            final userCompleted = profile!.completedLessons;
                            final completedInPath = meta.lessonIds
                                .where((id) => userCompleted.contains(id))
                                .length;
                            final reduceMotion = MediaQuery.of(
                              context,
                            ).disableAnimations;
                            // Show the first-path badge for
                            // new users who haven't completed any lessons yet.
                            final showStartHere =
                                index == 0 && completedLessons == 0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              child: reduceMotion
                                  ? LazyLearningPathCard(
                                      metadata: meta,
                                      completedLessons: completedInPath,
                                      totalLessons: meta.lessonIds.length,
                                      userCompletedLessons: userCompleted,
                                      allPathMetadata: metadata,
                                      showStartHereBadge: showStartHere,
                                    )
                                  : LazyLearningPathCard(
                                          metadata: meta,
                                          completedLessons: completedInPath,
                                          totalLessons: meta.lessonIds.length,
                                          userCompletedLessons: userCompleted,
                                          allPathMetadata: metadata,
                                          showStartHereBadge: showStartHere,
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
                          }, childCount: metadata.length),
                        ),

                        SliverToBoxAdapter(
                          child: SizedBox(
                            height:
                                MediaQuery.of(context).viewPadding.bottom +
                                DanioBottomDock.contentClearance,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _NextLearningCard extends StatelessWidget {
  final ({PathMetadata path, String lessonId})? target;
  final int completedLessons;
  final int totalLessons;
  final ValueChanged<({PathMetadata path, String lessonId})> onStartLesson;
  final VoidCallback onBrowsePaths;

  const _NextLearningCard({
    required this.target,
    required this.completedLessons,
    required this.totalLessons,
    required this.onStartLesson,
    required this.onBrowsePaths,
  });

  @override
  Widget build(BuildContext context) {
    final target = this.target;
    final hasLesson = target != null;
    final progress = totalLessons > 0 ? completedLessons / totalLessons : 0.0;
    final visual = hasLesson
        ? LearningVisuals.forPath(target.path.id)
        : LearningVisuals.fallbackPathVisual;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      child: GlassCard(
        semanticLabel: hasLesson
            ? 'Continue learning'
            : 'Learning library complete',
        onTap: hasLesson ? () => onStartLesson(target) : onBrowsePaths,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: visual.backgroundColor,
                      borderRadius: AppRadius.mediumRadius,
                    ),
                    child: Icon(
                      hasLesson ? visual.icon : Icons.verified_rounded,
                      color: visual.color,
                      size: AppIconSizes.lg,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasLesson ? 'Today\'s lesson' : 'Learning complete',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          hasLesson
                              ? target.path.title
                              : 'You have completed every lesson in the catalog.',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          hasLesson
                              ? 'Build the care habit now. Danio will seed your review deck and bring it back tomorrow.'
                              : 'Keep mastery fresh from the Practice tab, or revisit any path below.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: AppRadius.xsRadius,
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: context.surfaceVariant,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$completedLessons of $totalLessons lessons complete',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                  AppButton(
                    label: hasLesson ? 'Start Lesson' : 'Browse Paths',
                    trailingIcon: Icons.arrow_forward,
                    onPressed: hasLesson
                        ? () => onStartLesson(target)
                        : onBrowsePaths,
                    size: AppButtonSize.small,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnlockList extends StatelessWidget {
  final int lessonCount;
  final int achievementCount;

  const _UnlockList({
    required this.lessonCount,
    required this.achievementCount,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.menu_book_rounded, '$lessonCount bite-sized lessons'),
      (Icons.repeat_rounded, 'Practice review deck'),
      (Icons.workspace_premium_rounded, '$achievementCount achievements'),
      (Icons.center_focus_strong_rounded, 'Fish identification tools'),
    ];

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.$1,
                    size: AppIconSizes.sm,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    item.$2,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
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
        onTap: () => AppRoutes.toStoryBrowser(context),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.15),
                  borderRadius: AppRadius.mediumRadius,
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
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
              Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
