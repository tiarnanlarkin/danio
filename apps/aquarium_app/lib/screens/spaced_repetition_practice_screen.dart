/// Enhanced Practice Screen with full Spaced Repetition System
/// Implements review sessions, adaptive difficulty, and progress tracking
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/spaced_repetition.dart';
import '../models/exercises.dart';
import '../widgets/core/bubble_loader.dart';
import '../providers/spaced_repetition_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/inventory_provider.dart';
import '../services/review_queue_service.dart';
import '../theme/app_theme.dart';
import '../widgets/confetti_overlay.dart';

class SpacedRepetitionPracticeScreen extends ConsumerStatefulWidget {
  const SpacedRepetitionPracticeScreen({super.key});

  @override
  ConsumerState<SpacedRepetitionPracticeScreen> createState() =>
      _SpacedRepetitionPracticeScreenState();
}

class _SpacedRepetitionPracticeScreenState
    extends ConsumerState<SpacedRepetitionPracticeScreen> {
  // Unused: Mode selection handled via navigation parameters
  // ReviewSessionMode _selectedMode = ReviewSessionMode.standard;

  @override
  Widget build(BuildContext context) {
    final srState = ref.watch(spacedRepetitionProvider);

    if (srState.isLoading) {
      return const Scaffold(body: Center(child: BubbleLoader()));
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
              child: const Center(
                child: Text('🎯', style: TextStyle(fontSize: 56)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('All caught up!', style: AppTypography.headlineLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No reviews due right now. Your knowledge is fresh!',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (srState.stats.totalCards > 0) ...[
              Text(
                'Next review in:',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textHint,
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
              const SizedBox(height: AppSpacing.md),
              Text(
                'Complete lessons to build your practice queue.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textHint,
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
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Stats Overview Card
        _buildStatsCard(srState),
        const SizedBox(height: 20),

        // Quick Start Section
        Text('Quick Start', style: AppTypography.headlineSmall),
        const SizedBox(height: 12),
        _buildModeCard(
          icon: Icons.fitness_center,
          title: 'Standard Practice',
          description: '10 cards, mixed difficulty',
          count: srState.stats.dueCards.clamp(0, 10),
          mode: ReviewSessionMode.standard,
          color: AppColors.primary,
        ),
        const SizedBox(height: 12),
        _buildModeCard(
          icon: Icons.flash_on,
          title: 'Quick Review',
          description: '5 cards, fast session',
          count: srState.stats.dueCards.clamp(0, 5),
          mode: ReviewSessionMode.quick,
          color: AppColors.accent,
        ),
        const SizedBox(height: 12),
        _buildModeCard(
          icon: Icons.trending_down,
          title: 'Intensive Practice',
          description: 'Focus on weak concepts',
          count: srState.stats.weakCards.clamp(0, 10),
          mode: ReviewSessionMode.intensive,
          color: AppColors.warning,
          enabled: srState.stats.weakCards > 0,
        ),
        const SizedBox(height: 12),
        _buildModeCard(
          icon: Icons.shuffle,
          title: 'Mixed Practice',
          description: 'Due + strong cards (spaced practice)',
          count: srState.stats.totalCards.clamp(0, 10),
          mode: ReviewSessionMode.mixed,
          color: AppColors.secondary,
        ),

        const SizedBox(height: AppSpacing.lg),

        // Mastery Progress
        if (srState.stats.totalCards > 0) ...[
          Text('Mastery Progress', style: AppTypography.headlineSmall),
          const SizedBox(height: 12),
          _buildMasteryBreakdown(srState),
        ],
      ],
    );
  }

  Widget _buildStatsCard(SpacedRepetitionState srState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppRadius.mediumRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Progress',
                      style: AppTypography.headlineMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${srState.stats.totalCards} concepts learning',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: Colors.white70),
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
    return InkWell(
      onTap: enabled && count > 0 ? () => _startSession(mode) : null,
      borderRadius: AppRadius.mediumRadius,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.surface
              : AppColors.whiteAlpha50,
          borderRadius: AppRadius.mediumRadius,
          border: Border.all(
            color: enabled ? color.withOpacity(0.3) : AppColors.surfaceVariant,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: enabled
                    ? color.withOpacity(0.1)
                    : AppColors.surfaceVariant,
                borderRadius: AppRadius.mediumRadius,
              ),
              child: Icon(icon, color: enabled ? color : AppColors.textHint),
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
                      color: enabled ? null : AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: enabled
                          ? AppColors.textSecondary
                          : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: enabled && count > 0
                    ? color.withOpacity(0.2)
                    : AppColors.surfaceVariant,
                borderRadius: AppRadius.mediumRadius,
              ),
              child: Text(
                count == 0 ? 'None' : '$count',
                style: AppTypography.labelLarge.copyWith(
                  color: enabled && count > 0 ? color : AppColors.textHint,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right,
              color: enabled && count > 0
                  ? AppColors.textSecondary
                  : AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasteryBreakdown(SpacedRepetitionState srState) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppColors.surfaceVariant),
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
                Text(level.emoji, style: const TextStyle(fontSize: 20)),
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
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: AppColors.surfaceVariant,
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
        return Colors.grey;
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
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start session: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _startSession(mode),
          ),
        ),
      );
    }
  }

  void _showStatsDialog() {
    final srState = ref.read(spacedRepetitionProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistics'),
        content: SingleChildScrollView(
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
                '${srState.stats.currentStreak} days',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
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

// ==========================================
// REVIEW SESSION SCREEN
// ==========================================

class ReviewSessionScreen extends ConsumerStatefulWidget {
  final ReviewSession session;

  const ReviewSessionScreen({super.key, required this.session});

  @override
  ConsumerState<ReviewSessionScreen> createState() =>
      _ReviewSessionScreenState();
}

class _ReviewSessionScreenState extends ConsumerState<ReviewSessionScreen> {
  int _currentCardIndex = 0;
  bool _showingAnswer = false;
  DateTime? _questionStartTime;
  String? _errorMessage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _questionStartTime = DateTime.now();
  }

  ReviewCard get _currentCard => widget.session.cards[_currentCardIndex];

  @override
  Widget build(BuildContext context) {
    final progress = (_currentCardIndex + 1) / widget.session.cards.length;
    final cardsReviewed = widget.session.results.length;
    final correctSoFar = widget.session.results.where((r) => r.correct).length;
    final accuracy = cardsReviewed > 0
        ? (correctSoFar / cardsReviewed * 100).round()
        : 0;

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await _showExitDialog();
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Practice Session'),
          actions: [
            // Exit button
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Exit Session',
              onPressed: () async {
                final shouldExit = await _showExitDialog();
                if (shouldExit == true && mounted) {
                  Navigator.of(this.context).pop();
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Enhanced progress bar with stats
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppOverlays.black5,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Card ${_currentCardIndex + 1} of ${widget.session.cards.length}',
                        style: AppTypography.labelLarge,
                      ),
                      Text(
                        '${(progress * 100).round()}% complete',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: AppRadius.xsRadius,
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      minHeight: 8,
                    ),
                  ),
                  if (cardsReviewed > 0) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '$correctSoFar correct',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Icon(Icons.cancel, size: 16, color: AppColors.error),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '${cardsReviewed - correctSoFar} incorrect',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          '($accuracy% accuracy)',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Card content
            Expanded(child: _buildCardContent()),

            // Answer buttons
            if (!_showingAnswer) _buildAnswerButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mastery indicator
          Row(
            children: [
              Text(
                _currentCard.masteryLevel.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _currentCard.masteryLevel.displayName,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '${(_currentCard.strength * 100).round()}%',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Question card
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: AppColors.surfaceVariant),
              boxShadow: [
                BoxShadow(
                  color: AppOverlays.black5,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review this concept:',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(_getQuestionText(), style: AppTypography.headlineMedium),
              ],
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppOverlays.error10,
                borderRadius: AppRadius.smallRadius,
              ),
              child: Text(
                _errorMessage!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],

          if (_showingAnswer) ...[const SizedBox(height: 20), _buildFeedback()],
        ],
      ),
    );
  }

  Widget _buildAnswerButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppOverlays.black5,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How well did you remember this?',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            if (_isSubmitting)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: AppSpacing.sm),
                  Text('Submitting...'),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _recordAnswer(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 56),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close),
                          SizedBox(height: AppSpacing.xs),
                          Text('Forgot'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _recordAnswer(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 56),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check),
                          SizedBox(height: AppSpacing.xs),
                          Text('Remembered'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    final lastResult = widget.session.results.last;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lastResult.correct
            ? AppOverlays.success10
            : AppOverlays.error10,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(
          color: lastResult.correct
              ? AppOverlays.success30
              : AppColors.errorAlpha30,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                lastResult.correct ? Icons.check_circle : Icons.cancel,
                color: lastResult.correct ? AppColors.success : AppColors.error,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lastResult.correct ? 'Great job!' : 'Keep practicing!',
                      style: AppTypography.headlineSmall.copyWith(
                        color: lastResult.correct
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '+${lastResult.xpEarned} XP',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: _nextCard,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(
              _currentCardIndex < widget.session.cards.length - 1
                  ? 'Next Card'
                  : 'Complete Session',
            ),
          ),
        ],
      ),
    );
  }

  String _getQuestionText() {
    // In a real implementation, this would fetch the actual question content
    // For now, show concept ID as placeholder
    return 'Review: ${_currentCard.conceptId}';
  }

  Future<void> _recordAnswer(bool correct) async {
    if (_questionStartTime == null || _isSubmitting) return;

    final timeSpent = DateTime.now().difference(_questionStartTime!);

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(spacedRepetitionProvider.notifier)
          .recordSessionResult(
            cardId: _currentCard.id,
            correct: correct,
            timeSpent: timeSpent,
          );

      // Award XP to user profile (with boost if active)
      final result = widget.session.results.last;
      final isBoostActive = ref.read(xpBoostActiveProvider);
      await ref.read(userProfileProvider.notifier).addXp(
        result.xpEarned,
        xpBoostActive: isBoostActive,
      );

      if (mounted) {
        setState(() {
          _showingAnswer = true;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error recording answer: $e';
        });

        // Show SnackBar with retry option
        // Card scheduling errors will not break review flow (handled in provider)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to record answer: ${e.toString()}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _recordAnswer(correct),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _nextCard() {
    if (_currentCardIndex < widget.session.cards.length - 1) {
      setState(() {
        _currentCardIndex++;
        _showingAnswer = false;
        _questionStartTime = DateTime.now();
        _errorMessage = null;
      });
    } else {
      _completeSession();
    }
  }

  Future<void> _completeSession() async {
    await ref.read(spacedRepetitionProvider.notifier).completeSession();

    if (mounted) {
      // Show completion dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildCompletionDialog(),
      );
    }
  }

  Widget _buildCompletionDialog() {
    final totalCards = widget.session.cards.length;
    final correctCards = widget.session.results.where((r) => r.correct).length;
    final incorrectCards = totalCards - correctCards;
    final accuracy = (widget.session.score * 100).round();
    final totalXp = widget.session.totalXp;

    return AlertDialog(
      title: Row(
        children: [
          const Text('Session Complete!'),
          const SizedBox(width: AppSpacing.sm),
          const Text('🎉'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score display
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accuracy >= 80
                    ? AppOverlays.success10
                    : accuracy >= 60
                    ? AppOverlays.warning10
                    : AppOverlays.error10,
                borderRadius: AppRadius.mediumRadius,
              ),
              child: Column(
                children: [
                  Text(
                    '$accuracy%',
                    style: AppTypography.headlineLarge.copyWith(
                      color: accuracy >= 80
                          ? AppColors.success
                          : accuracy >= 60
                          ? AppColors.warning
                          : AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 48,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Accuracy',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Stats breakdown
          _buildStatRow('Cards Reviewed', '$totalCards'),
          const SizedBox(height: AppSpacing.sm),
          _buildStatRow(
            'Correct',
            '$correctCards',
            iconColor: AppColors.success,
            icon: Icons.check_circle,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildStatRow(
            'Incorrect',
            '$incorrectCards',
            iconColor: AppColors.error,
            icon: Icons.cancel,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          _buildStatRow(
            'XP Earned',
            '+$totalXp',
            iconColor: AppColors.accent,
            icon: Icons.star,
            valueStyle: AppTypography.bodyLarge.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            Navigator.of(context).pop(); // Close session screen
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Done'),
        ),
      ],
    );
  }

  Widget _buildStatRow(
    String label,
    String value, {
    IconData? icon,
    Color? iconColor,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: iconColor ?? AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Text(
          value,
          style:
              valueStyle ??
              AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Future<bool?> _showExitDialog() {
    final cardsReviewed = widget.session.results.length;
    final cardsRemaining = widget.session.cards.length - cardsReviewed;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.exit_to_app, color: AppColors.warning),
            SizedBox(width: 12),
            Text('Exit Session?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your progress will be saved, but you\'ll need to start a new session to continue practicing.',
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppRadius.smallRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Cards reviewed: $cardsReviewed',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(
                        Icons.pending,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Cards remaining: $cardsRemaining',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continue Session'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
