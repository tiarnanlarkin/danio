import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/spaced_repetition.dart';
import '../providers/guidance_provider.dart';
import '../providers/spaced_repetition_provider.dart';
import '../providers/user_profile_provider.dart';
import '../services/guidance_service.dart';
import '../theme/app_theme.dart';
import '../theme/learning_visuals.dart';
import '../utils/logger.dart';
import '../widgets/hearts_widgets.dart';
import '../widgets/danio_snack_bar.dart';
import '../widgets/first_visit_tooltip.dart';
import '../widgets/themed_tab_header.dart';
import '../widgets/danio_bottom_dock.dart';
import 'spaced_repetition_practice_screen.dart';
import 'tab_navigator.dart';
import '../utils/navigation_throttle.dart';

/// Practice Hub - Central location for all quiz and practice activities
/// This is Tab 1 in the new navigation structure
class PracticeHubScreen extends ConsumerStatefulWidget {
  const PracticeHubScreen({super.key});

  @override
  ConsumerState<PracticeHubScreen> createState() => _PracticeHubScreenState();
}

class _PracticeHubScreenState extends ConsumerState<PracticeHubScreen> {
  bool _showTooltip = false;
  bool _guidanceCheckQueued = false;
  int? _lastGuidanceCardCount;
  SpacedRepetitionState? _latestSrState;

  @override
  void initState() {
    super.initState();
  }

  void _queueGuidanceCheck(int totalCards) {
    if (totalCards <= 0 || _guidanceCheckQueued) return;
    if (_lastGuidanceCardCount == totalCards) return;

    _guidanceCheckQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkTooltip(totalCards);
    });
  }

  Future<void> _checkTooltip(int totalCards) async {
    final service = await ref.read(guidanceServiceProvider.future);
    final decision = await service.shouldShow(
      GuidancePromptId.practiceFirstUsefulVisit,
      GuidanceContext(
        surface: GuidanceSurface.practice,
        practiceCardCount: totalCards,
      ),
    );
    if (!mounted) return;
    setState(() {
      _showTooltip = decision.shouldShow;
      _lastGuidanceCardCount = totalCards;
      _guidanceCheckQueued = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final srState = ref.watch(spacedRepetitionProvider);
    final profile = ref.watch(
      userProfileProvider.select((p) => p.value?.currentStreak),
    );
    final dueCards = srState.stats.dueCards;
    final totalCards = srState.stats.totalCards;
    _latestSrState = srState;
    _queueGuidanceCheck(totalCards);

    final body = Scaffold(
      body: CustomScrollView(
        slivers: [
          // Themed Practice Header
          ThemedTabHeader(
            tab: TabHeaderContext.practice,
            height: 180,
            overlays: [
              // Top-left title
              Positioned(
                top: 16,
                left: 16,
                child: SafeArea(
                  bottom: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.blackAlpha35,
                      borderRadius: AppRadius.md2Radius,
                    ),
                    child: Text(
                      'Practice',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ),
              // Top-right hearts indicator
              Positioned(
                top: 16,
                right: 16,
                child: SafeArea(
                  bottom: false,
                  child: HeartIndicator(compact: true),
                ),
              ),
            ],
          ),
          // 8dp gap
          const SliverPadding(padding: EdgeInsets.only(top: AppSpacing.sm)),
          // Content list
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                _buildPracticeHubItems(
                  context,
                  ref,
                  dueCards,
                  totalCards,
                  srState,
                  profile,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height:
                  MediaQuery.of(context).viewPadding.bottom +
                  DanioBottomDock.contentClearance,
            ),
          ),
        ],
      ),
    );

    if (_showTooltip && totalCards > 0) {
      return Stack(
        children: [
          body,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: FirstVisitTooltip(
                prefsKey: GuidanceService.storageKey(
                  GuidancePromptId.practiceFirstUsefulVisit,
                ),
                icon: Icons.repeat_rounded,
                iconColor: AppColors.primary,
                iconBackgroundColor: AppColors.primaryAlpha10,
                message:
                    'Practice strengthens concepts you have unlocked in Learn.',
                onDismissed: () => setState(() => _showTooltip = false),
              ),
            ),
          ),
        ],
      );
    }

    return body;
  }

  List<Widget> _buildPracticeHubItems(
    BuildContext context,
    WidgetRef ref,
    int dueCards,
    int totalCards,
    SpacedRepetitionState srState,
    dynamic profile,
  ) {
    final items = totalCards == 0
        ? _buildEmptyPracticeDeckItems(context, ref)
        : <Widget>[
            for (
              int index = 0;
              index < _getPracticeHubItemCount(dueCards, totalCards);
              index++
            )
              _buildPracticeHubItem(
                context,
                ref,
                index,
                dueCards,
                totalCards,
                srState,
                profile,
              ),
          ];

    if (srState.errorMessage != null) {
      final insertAt = items.length > 2 ? 2 : items.length;
      items.insert(
        insertAt,
        _buildErrorBanner(context, ref, srState.errorMessage!),
      );
      items.insert(insertAt + 1, const SizedBox(height: AppSpacing.lg));
    }

    return items;
  }

  List<Widget> _buildEmptyPracticeDeckItems(
    BuildContext context,
    WidgetRef ref,
  ) {
    return [
      _buildHeroCard(
        context,
        title: 'Build your review deck',
        subtitle: 'Finish one Learn lesson to create Practice cards.',
        icon: Icons.auto_stories_rounded,
        color: AppColors.primary,
        actionLabel: 'Start first lesson',
        onTap: () {
          ref.read(currentTabProvider.notifier).state = 0;
        },
      ),
      const SizedBox(height: AppSpacing.md),
      _buildLearningLoopCard(context),
      const SizedBox(height: AppSpacing.md),
      _buildEmptyModeHint(context),
    ];
  }

  Widget _buildErrorBanner(
    BuildContext context,
    WidgetRef ref,
    String message,
  ) {
    return Card(
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg2Radius),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm2),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () =>
                  ref.read(spacedRepetitionProvider.notifier).reload(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningLoopCard(BuildContext context) {
    const steps = [
      _LoopStep(
        icon: Icons.menu_book_rounded,
        label: 'Learn',
        detail: 'Unlock one safe tank habit',
      ),
      _LoopStep(
        icon: Icons.repeat_rounded,
        label: 'Practice',
        detail: 'First review tomorrow',
      ),
      _LoopStep(
        icon: Icons.verified_rounded,
        label: 'Mastery',
        detail: 'Build care confidence',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.lg2Radius,
        border: Border.all(color: AppColors.primaryAlpha15),
      ),
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            Expanded(child: _buildLoopStep(context, steps[i])),
            if (i < steps.length - 1)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primary,
                size: AppIconSizes.sm,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoopStep(BuildContext context, _LoopStep step) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.primaryAlpha10,
            shape: BoxShape.circle,
          ),
          child: Icon(step.icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          step.label,
          style: AppTypography.labelMedium.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          step.detail,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondary,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyModeHint(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceVariant,
        borderRadius: AppRadius.md2Radius,
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_clock_rounded,
            color: context.textSecondary,
            size: AppIconSizes.sm,
          ),
          const SizedBox(width: AppSpacing.sm2),
          Expanded(
            child: Text(
              'Quick, Standard, Weak Spots, and Mixed sessions unlock once your review deck has cards.',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startReviewSession(ReviewSessionMode mode) async {
    try {
      await ref
          .read(spacedRepetitionProvider.notifier)
          .startSession(mode: mode);
      if (!mounted) return;
      NavigationThrottle.push(
        context,
        const SpacedRepetitionPracticeScreen(),
        rootNavigator: true,
      );
    } catch (e, st) {
      logError(
        'PracticeHubScreen: start session failed: $e',
        stackTrace: st,
        tag: 'PracticeHubScreen',
      );
      if (!mounted) return;
      DanioSnackBar.error(context, 'No cards are ready for that session yet.');
    }
  }

  int _getPracticeHubItemCount(int dueCards, int totalCards) {
    // Hero (1) + spacer + stats row + spacer +
    // section header (Review Sessions) + spacer + SR choices + spacer +
    // section header (Mastery Breakdown) + spacer + mastery widget + spacer +
    // section header (Your Progress) + spacer +
    // streak + spacer + mastered + spacer + accuracy = 19 items
    return 19;
  }

  Widget _buildPracticeHubItem(
    BuildContext context,
    WidgetRef ref,
    int index,
    int dueCards,
    int totalCards,
    SpacedRepetitionState srState,
    dynamic profile,
  ) {
    switch (index) {
      case 0: // Hero card
        if (dueCards > 0) {
          return _buildHeroCard(
            context,
            title: 'Start Review',
            subtitle: '$dueCards card${dueCards == 1 ? '' : 's'} ready now',
            icon: Icons.replay,
            color: AppColors.error,
            actionLabel: 'Start Review',
            onTap: () => _startReviewSession(ReviewSessionMode.standard),
          );
        } else if (dueCards == 0 &&
            totalCards > 0 &&
            srState.stats.weakCards > 0) {
          return _buildHeroCard(
            context,
            title: 'Weak spots available',
            subtitle: 'No due reviews right now. Reinforce your weak cards.',
            icon: Icons.trending_down,
            color: AppColors.warning,
            actionLabel: 'Practice Weak Spots',
            onTap: () => _startReviewSession(ReviewSessionMode.intensive),
          );
        } else if (dueCards == 0 && totalCards > 0) {
          // Has cards but none are due — genuinely all caught up
          return _buildHeroCard(
            context,
            title: 'All caught up',
            subtitle:
                'No reviews due right now. Learn the next concept to grow your queue.',
            icon: Icons.check_circle,
            color: AppColors.success,
            actionLabel: 'Learn Next',
            onTap: () {
              ref.read(currentTabProvider.notifier).state = 0;
            },
          );
        } else {
          // No cards at all — user hasn't started yet
          return _buildHeroCard(
            context,
            title: 'No practice cards yet',
            subtitle: 'Complete a Learn lesson to create review cards',
            icon: Icons.auto_stories,
            color: AppColors.primary,
            actionLabel: 'Start Learning',
            onTap: () {
              ref.read(currentTabProvider.notifier).state = 0;
            },
          );
        }
      case 1:
        return const SizedBox(height: AppSpacing.lg);
      case 2: // Practice Stats — BUG-05: gray for zero values, semantic color only when >0
        return _buildStatsRow(
          context,
          stats: [
            _StatItem(
              label: 'Due Today',
              value: '$dueCards',
              color: dueCards > 0 ? AppColors.error : context.textSecondary,
            ),
            _StatItem(
              label: 'Mastered',
              value: '${srState.stats.masteredCards}',
              color: srState.stats.masteredCards > 0
                  ? AppColors.success
                  : context.textSecondary,
            ),
            _StatItem(
              label: 'Total Cards',
              value: '${srState.stats.totalCards}',
              color: context.textSecondary,
            ),
          ],
        );
      case 3:
        return const SizedBox(height: AppSpacing.lg);
      case 4: // Section: Review Sessions
        return Text('Review Sessions', style: AppTypography.headlineSmall);
      case 5:
        return const SizedBox(height: AppSpacing.sm2);
      case 6: // Spaced Repetition card — PRIMARY practice mode
        return _buildPracticeCard(
          context,
          title: 'Spaced Repetition',
          subtitle:
              'Review cards based on memory strength — the most effective way to learn',
          icon: Icons.psychology,
          iconColor: AppColors.primary,
          onTap: () {
            NavigationThrottle.push(
              context,
              const SpacedRepetitionPracticeScreen(),
              rootNavigator: true,
            );
          },
        );
      case 7:
        return const SizedBox(height: AppSpacing.lg);
      case 8: // Section: Mastery Breakdown
        return Text('Mastery Breakdown', style: AppTypography.headlineSmall);
      case 9:
        return const SizedBox(height: AppSpacing.sm2);
      case 10: // Mastery level breakdown
        return _buildMasteryBreakdown(context, srState);
      case 11:
        return const SizedBox(height: AppSpacing.lg);
      case 12: // Section: Your Progress
        return Text('Your Progress', style: AppTypography.headlineSmall);
      case 13:
        return const SizedBox(height: AppSpacing.sm2);
      case 14: // Study Streak card — BUG-06: neutral look when streak=0
        {
          final streak = profile ?? 0;
          return _buildProgressCard(
            context,
            title: 'Study Streak',
            value: streak > 0
                ? (streak == 1 ? '1 day' : '$streak days')
                : '0 days',
            icon: streak > 0
                ? Icons.local_fire_department
                : Icons.local_fire_department_outlined,
            color: streak > 0 ? AppColors.warning : context.textSecondary,
          );
        }
      case 15:
        return const SizedBox(height: AppSpacing.sm2);
      case 16: // Cards Mastered card
        return _buildProgressCard(
          context,
          title: 'Cards Mastered',
          value: '${srState.stats.masteredCards}',
          icon: Icons.stars,
          color: AppColors.success,
        );
      case 17:
        return const SizedBox(height: AppSpacing.sm2);
      case 18: // Practice Accuracy — computed from ReviewCard history
        {
          final totalReviews = srState.stats.totalReviews;
          final allCards = srState.cards;
          final totalCorrect = allCards.fold<int>(
            0,
            (sum, card) => sum + card.correctCount,
          );
          if (totalReviews == 0) {
            return _buildProgressCard(
              context,
              title: 'Practice Accuracy',
              value: 'Complete a review session',
              icon: Icons.track_changes,
              color: context.textSecondary,
            );
          }
          final accuracyPct = allCards.isEmpty
              ? 0
              : (totalCorrect /
                        allCards.fold<int>(
                          0,
                          (sum, card) => sum + card.reviewCount,
                        ) *
                        100)
                    .round();
          final accuracyColor = accuracyPct >= 80
              ? AppColors.success
              : accuracyPct >= 60
              ? AppColors.warning
              : AppColors.error;
          return _buildProgressCard(
            context,
            title: 'Practice Accuracy',
            value: '$accuracyPct%',
            icon: Icons.track_changes,
            color: accuracyColor,
          );
        }
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHeroCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    String? actionLabel,
    required VoidCallback? onTap,
  }) {
    return Semantics(
      button: onTap != null,
      child: Card(
        elevation: AppElevation.level1,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lg2Radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lg2Radius,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withAlpha(24),
                    borderRadius: AppRadius.md2Radius,
                  ),
                  child: Icon(icon, size: 34, color: color),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                      if (actionLabel != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: color.withAlpha(24),
                            borderRadius: AppRadius.md2Radius,
                          ),
                          child: Text(
                            actionLabel,
                            style: AppTypography.labelMedium.copyWith(
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(Icons.arrow_forward_ios, color: color, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(
    BuildContext context, {
    required List<_StatItem> stats,
  }) {
    return Row(
      children: List.generate(stats.length, (index) {
        final stat = stats[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == stats.length - 1 ? 0 : AppSpacing.sm,
            ),
            child: Card(
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.lg2Radius),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    Text(
                      stat.value,
                      style: AppTypography.headlineMedium.copyWith(
                        color: stat.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      stat.label,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPracticeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback? onTap,
  }) {
    final srState = _latestSrState;
    if (title == 'Spaced Repetition' && srState != null) {
      return _buildSessionChoices(context, srState);
    }

    return _buildModeChoice(
      context,
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      onTap: onTap,
    );
  }

  Widget _buildSessionChoices(
    BuildContext context,
    SpacedRepetitionState srState,
  ) {
    final dueCards = srState.stats.dueCards;
    final mixedAvailable =
        dueCards > 0 || srState.cards.any((card) => card.isStrong);

    return Column(
      children: [
        _buildModeChoice(
          context,
          title: 'Standard Review',
          subtitle: '${dueCards.clamp(0, 10)} due cards, balanced pace',
          icon: Icons.psychology,
          iconColor: AppColors.primary,
          onTap: dueCards > 0
              ? () => _startReviewSession(ReviewSessionMode.standard)
              : null,
        ),
        const SizedBox(height: AppSpacing.sm2),
        _buildModeChoice(
          context,
          title: 'Quick Review',
          subtitle: '${dueCards.clamp(0, 5)} due cards, fast session',
          icon: Icons.flash_on,
          iconColor: AppColors.accent,
          onTap: dueCards > 0
              ? () => _startReviewSession(ReviewSessionMode.quick)
              : null,
        ),
        const SizedBox(height: AppSpacing.sm2),
        _buildModeChoice(
          context,
          title: 'Weak Spots',
          subtitle:
              '${srState.stats.weakCards.clamp(0, 10)} cards that need reinforcement',
          icon: Icons.trending_down,
          iconColor: AppColors.warning,
          onTap: srState.stats.weakCards > 0
              ? () => _startReviewSession(ReviewSessionMode.intensive)
              : null,
        ),
        const SizedBox(height: AppSpacing.sm2),
        _buildModeChoice(
          context,
          title: 'Mixed Practice',
          subtitle: 'Due cards plus strong cards for interleaving',
          icon: Icons.shuffle,
          iconColor: AppColors.secondary,
          onTap: mixedAvailable
              ? () => _startReviewSession(ReviewSessionMode.mixed)
              : null,
        ),
      ],
    );
  }

  Widget _buildModeChoice(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    final effectiveColor = enabled ? iconColor : context.textHint;

    return Card(
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg2Radius),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm2,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: effectiveColor.withAlpha(26),
            borderRadius: AppRadius.smallRadius,
          ),
          child: Icon(icon, color: effectiveColor, size: AppIconSizes.md),
        ),
        title: Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            color: enabled ? null : context.textHint,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodyMedium.copyWith(
            color: enabled ? context.textSecondary : context.textHint,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: enabled ? context.textSecondary : context.textHint,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildMasteryBreakdown(
    BuildContext context,
    SpacedRepetitionState srState,
  ) {
    if (srState.stats.totalCards == 0) {
      return Card(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lg2Radius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            'Complete lessons to earn flashcards and track your mastery here.',
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final byMastery = srState.stats.cardsByMastery;
    final levels = [
      MasteryLevel.mastered,
      MasteryLevel.proficient,
      MasteryLevel.familiar,
      MasteryLevel.learning,
      MasteryLevel.new_,
    ];
    final levelColors = {
      MasteryLevel.mastered: AppColors.success,
      MasteryLevel.proficient: AppColors.primary,
      MasteryLevel.familiar: AppColors.warning,
      MasteryLevel.learning: AppColors.secondary,
      MasteryLevel.new_: context.textSecondary,
    };

    return Card(
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg2Radius),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: levels.map((level) {
            final count = byMastery[level] ?? 0;
            final total = srState.stats.totalCards;
            final fraction = total > 0 ? count / total : 0.0;
            final color =
                levelColors[level] ??
                LearningVisuals.masteryColor(context, level);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Icon(
                    LearningVisuals.masteryIcon(level),
                    size: AppIconSizes.sm,
                    color: color,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 80,
                    child: Text(
                      level.displayName,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: AppRadius.xsRadius,
                      child: LinearProgressIndicator(
                        value: fraction,
                        backgroundColor: context.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 28,
                    child: Text(
                      '$count',
                      textAlign: TextAlign.end,
                      style: AppTypography.labelSmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    // Long CTA strings overflow the ~72dp trailing slot — show them as a
    // subtitle instead and use an em-dash placeholder in trailing.
    const longCta = 'Complete a review session';
    final isLongCta = value == longCta;

    return Card(
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg2Radius),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Icon(icon, color: color, size: AppIconSizes.lg),
        title: Text(title, style: AppTypography.titleSmall),
        subtitle: isLongCta
            ? Text(
                longCta,
                style: AppTypography.bodySmall.copyWith(color: color),
              )
            : null,
        trailing: Text(
          isLongCta ? '—' : value,
          style: AppTypography.titleLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final Color color;

  _StatItem({required this.label, required this.value, required this.color});
}

class _LoopStep {
  final IconData icon;
  final String label;
  final String detail;

  const _LoopStep({
    required this.icon,
    required this.label,
    required this.detail,
  });
}
