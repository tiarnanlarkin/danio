/// Enhanced Practice Screen with full Spaced Repetition System
/// Implements review sessions, adaptive difficulty, and progress tracking
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/spaced_repetition.dart';
import '../../providers/spaced_repetition_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/logger.dart';
import '../../widgets/core/app_button.dart';
import '../../widgets/core/app_dialog.dart';
import '../../widgets/core/bubble_loader.dart';
import '../../widgets/danio_snack_bar.dart';
import 'review_session_screen.dart';

class SpacedRepetitionPracticeScreen extends ConsumerStatefulWidget {
  const SpacedRepetitionPracticeScreen({super.key});

  @override
  ConsumerState<SpacedRepetitionPracticeScreen> createState() =>
      _SpacedRepetitionPracticeScreenState();
}

class _SpacedRepetitionPracticeScreenState
    extends ConsumerState<SpacedRepetitionPracticeScreen> {
  @override
  Widget build(BuildContext context) {
    final srState = ref.watch(spacedRepetitionProvider);

    if (srState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Practice')),
        body: const Center(child: BubbleLoader()),
      );
    }

    // If session is active, show session screen
    if (srState.currentSession != null) {
      return ReviewSessionScreen(session: srState.currentSession!);
    }

    final dueCount = srState.stats.dueCards;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            onPressed: () => _showStatsDialog(),
            tooltip: 'Statistics',
          ),
        ],
      ),
      body: dueCount == 0
          ? _buildEmptyState(context)
          : _buildPracticeHome(context, srState),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final srState = ref.watch(spacedRepetitionProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppOverlays.success10,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '🎯',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium!.copyWith(fontSize: 56),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('All caught up!', style: AppTypography.headlineLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No reviews due right now. Your knowledge is fresh!',
              style: AppTypography.bodyLarge.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Try a new lesson',
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              leadingIcon: Icons.auto_stories,
              variant: AppButtonVariant.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            if (srState.stats.totalCards > 0) ...[
              Text(
                'Next review in:',
                style: AppTypography.labelLarge.copyWith(
                  color: context.textHint,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _getNextReviewTime(srState),
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ] else ...[
              Text(
                'Complete lessons to build your practice queue.',
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textHint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeHome(
    BuildContext context,
    SpacedRepetitionState srState,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg2),
      itemCount: _getPracticeHomeItemCount(srState),
      itemBuilder: (context, index) =>
          _buildPracticeHomeItem(context, index, srState),
    );
  }

  int _getPracticeHomeItemCount(SpacedRepetitionState srState) {
    return srState.stats.totalCards > 0 ? 15 : 12;
  }

  Widget _buildPracticeHomeItem(
    BuildContext context,
    int index,
    SpacedRepetitionState srState,
  ) {
    switch (index) {
      case 0:
        return _buildStatsCard(srState);
      case 1:
        return const SizedBox(height: AppSpacing.lg2);
      case 2:
        return Text('Quick Start', style: AppTypography.headlineSmall);
      case 3:
        return const SizedBox(height: AppSpacing.sm2);
      case 4:
        return _buildModeCard(
          icon: Icons.fitness_center,
          title: 'Standard Practice',
          description: '10 cards, mixed difficulty',
          count: srState.stats.dueCards.clamp(0, 10),
          mode: ReviewSessionMode.standard,
          color: AppColors.primary,
        );
      case 5:
        return const SizedBox(height: AppSpacing.sm2);
      case 6:
        return _buildModeCard(
          icon: Icons.flash_on,
          title: 'Quick Review',
          description: '5 cards, fast session',
          count: srState.stats.dueCards.clamp(0, 5),
          mode: ReviewSessionMode.quick,
          color: AppColors.accent,
        );
      case 7:
        return const SizedBox(height: AppSpacing.sm2);
      case 8:
        return _buildModeCard(
          icon: Icons.trending_down,
          title: 'Intensive Practice',
          description: 'Focus on weak concepts',
          count: srState.stats.weakCards.clamp(0, 10),
          mode: ReviewSessionMode.intensive,
          color: AppColors.warning,
          enabled: srState.stats.weakCards > 0,
        );
      case 9:
        return const SizedBox(height: AppSpacing.sm2);
      case 10:
        return _buildModeCard(
          icon: Icons.shuffle,
          title: 'Mixed Practice',
          description: 'Due + strong cards (spaced practice)',
          count: srState.stats.totalCards.clamp(0, 10),
          mode: ReviewSessionMode.mixed,
          color: AppColors.secondary,
        );
      case 11:
        return const SizedBox(height: AppSpacing.sm2);
      case 12:
        return const SizedBox(height: AppSpacing.lg);
      case 13:
        return Text('Mastery Progress', style: AppTypography.headlineSmall);
      case 14:
        return const SizedBox(height: AppSpacing.sm2);
      default:
        return _buildMasteryBreakdown(srState);
    }
  }

  Widget _buildStatsCard(SpacedRepetitionState srState) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg2),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppRadius.mediumRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_graph,
                color: AppColors.onPrimary,
                size: AppIconSizes.lg,
              ),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Progress',
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.onPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${srState.stats.totalCards} concepts learning',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.whiteAlpha70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg2),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Due',
                  '${srState.stats.dueCards}',
                  Icons.event,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Today',
                  '${srState.stats.reviewsToday}',
                  Icons.today,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Streak',
                  '${srState.stats.currentStreak}🔥',
                  Icons.whatshot,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.whiteAlpha70, size: AppIconSizes.sm),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.whiteAlpha70,
          ),
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required IconData icon,
    required String title,
    required String description,
    required int count,
    required ReviewSessionMode mode,
    required Color color,
    bool enabled = true,
  }) {
    return Semantics(
      button: enabled && count > 0,
      child: InkWell(
        onTap: enabled && count > 0 ? () => _startSession(mode) : null,
        borderRadius: AppRadius.mediumRadius,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: enabled ? context.surfaceColor : AppColors.whiteAlpha50,
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(
              color: enabled ? color.withAlpha(76) : context.surfaceVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm2),
                decoration: BoxDecoration(
                  color: enabled ? color.withAlpha(26) : context.surfaceVariant,
                  borderRadius: AppRadius.mediumRadius,
                ),
                child: Icon(icon, color: enabled ? color : context.textHint),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: enabled ? null : context.textHint,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
                      style: AppTypography.bodySmall.copyWith(
                        color: enabled
                            ? context.textSecondary
                            : context.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: AppSpacing.xs2,
                ),
                decoration: BoxDecoration(
                  color: enabled && count > 0
                      ? color.withAlpha(51)
                      : context.surfaceVariant,
                  borderRadius: AppRadius.mediumRadius,
                ),
                child: Text(
                  count == 0 ? 'None' : '$count',
                  style: AppTypography.labelLarge.copyWith(
                    color:
                        enabled && count > 0 ? color : context.textHint,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right,
                color: enabled && count > 0
                    ? context.textSecondary
                    : context.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMasteryBreakdown(SpacedRepetitionState srState) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: context.surfaceVariant),
      ),
      child: Column(
        children: MasteryLevel.values.map((level) {
          final count = srState.stats.cardsByMastery[level] ?? 0;
          final percentage = srState.stats.totalCards > 0
              ? (count / srState.stats.totalCards) * 100
              : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Text(
                  level.emoji,
                  style: Theme.of(context).textTheme.titleLarge!,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            level.displayName,
                            style: AppTypography.labelMedium,
                          ),
                          Text(
                            '$count (${percentage.round()}%)',
                            style: AppTypography.labelSmall.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: context.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getMasteryColor(level),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getMasteryColor(MasteryLevel level) {
    switch (level) {
      case MasteryLevel.new_:
        return context.textHint;
      case MasteryLevel.learning:
        return AppColors.warning;
      case MasteryLevel.familiar:
        return AppColors.info;
      case MasteryLevel.proficient:
        return AppColors.success;
      case MasteryLevel.mastered:
        return AppColors.accent;
    }
  }

  String _getNextReviewTime(SpacedRepetitionState srState) {
    if (srState.cards.isEmpty) return 'No cards';

    final notDueCards = srState.cards.where((c) => !c.isDue).toList();
    if (notDueCards.isEmpty) return 'Now';

    notDueCards.sort((a, b) => a.nextReview.compareTo(b.nextReview));
    final nextCard = notDueCards.first;

    final duration = nextCard.nextReview.difference(DateTime.now());
    if (duration.inHours < 1) return '${duration.inMinutes} minutes';
    if (duration.inDays < 1) return '${duration.inHours} hours';
    return '${duration.inDays} days';
  }

  Future<void> _startSession(ReviewSessionMode mode) async {
    try {
      await ref
          .read(spacedRepetitionProvider.notifier)
          .startSession(mode: mode);
    } catch (e, st) {
      logError(
        'SpacedRepetitionScreen: start session failed: $e',
        stackTrace: st,
        tag: 'SpacedRepetitionScreen',
      );
      if (!mounted) return;

      DanioSnackBar.error(
        context,
        'Couldn\'t start the session, try again',
        onRetry: () => _startSession(mode),
      );
    }
  }

  void _showStatsDialog() {
    final srState = ref.read(spacedRepetitionProvider);

    showAppDialog(
      context: context,
      title: 'Statistics',
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Total Cards', srState.stats.totalCards.toString()),
            _buildStatRow('Due Cards', srState.stats.dueCards.toString()),
            _buildStatRow('Weak Cards', srState.stats.weakCards.toString()),
            _buildStatRow('Mastered', srState.stats.masteredCards.toString()),
            _buildStatRow(
              'Average Strength',
              '${(srState.stats.averageStrength * 100).round()}%',
            ),
            _buildStatRow(
              'Reviews Today',
              srState.stats.reviewsToday.toString(),
            ),
            _buildStatRow(
              'Current Streak',
              '${srState.stats.currentStreak} ${srState.stats.currentStreak == 1 ? 'day' : 'days'}',
            ),
          ],
        ),
      ),
      actions: [
        AppButton(
          label: 'Close',
          onPressed: () => Navigator.of(context).pop(),
          variant: AppButtonVariant.text,
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
