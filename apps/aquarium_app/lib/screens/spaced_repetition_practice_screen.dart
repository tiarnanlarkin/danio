/// Enhanced Practice Screen with full Spaced Repetition System
/// Implements review sessions, adaptive difficulty, and progress tracking

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/spaced_repetition.dart';
import '../models/exercises.dart';
import '../providers/spaced_repetition_provider.dart';
import '../providers/user_profile_provider.dart';
import '../services/review_queue_service.dart';
import '../theme/app_theme.dart';
import '../widgets/confetti_overlay.dart';

class SpacedRepetitionPracticeScreen extends ConsumerStatefulWidget {
  const SpacedRepetitionPracticeScreen({super.key});

  @override
  ConsumerState<SpacedRepetitionPracticeScreen> createState() => _SpacedRepetitionPracticeScreenState();
}

class _SpacedRepetitionPracticeScreenState extends ConsumerState<SpacedRepetitionPracticeScreen> {
  ReviewSessionMode _selectedMode = ReviewSessionMode.standard;

  @override
  Widget build(BuildContext context) {
    final srState = ref.watch(spacedRepetitionProvider);
    
    if (srState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If session is active, show session screen
    if (srState.currentSession != null) {
      return ReviewSessionScreen(session: srState.currentSession!);
    }

    final dueCount = srState.stats.dueCards;
    final weakCount = srState.stats.weakCards;
    
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🎯', style: TextStyle(fontSize: 56)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'All caught up!',
              style: AppTypography.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'No reviews due right now. Your knowledge is fresh!',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (srState.stats.totalCards > 0) ...[
              Text(
                'Next review in:',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getNextReviewTime(srState),
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
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

  Widget _buildPracticeHome(BuildContext context, SpacedRepetitionState srState) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Stats Overview Card
        _buildStatsCard(srState),
        const SizedBox(height: 20),

        // Quick Start Section
        Text(
          'Quick Start',
          style: AppTypography.headlineSmall,
        ),
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
        
        const SizedBox(height: 24),

        // Mastery Progress
        if (srState.stats.totalCards > 0) ...[
          Text(
            'Mastery Progress',
            style: AppTypography.headlineSmall,
          ),
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
        borderRadius: BorderRadius.circular(16),
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
                    const SizedBox(height: 4),
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
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white70,
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
    return InkWell(
      onTap: enabled && count > 0
          ? () => _startSession(mode)
          : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enabled ? AppColors.surface : AppColors.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled ? color.withOpacity(0.3) : AppColors.surfaceVariant,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: enabled ? color.withOpacity(0.1) : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: enabled ? color : AppColors.textHint),
            ),
            const SizedBox(width: 16),
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
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: enabled ? AppColors.textSecondary : AppColors.textHint,
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
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                count == 0 ? 'None' : '$count',
                style: AppTypography.labelLarge.copyWith(
                  color: enabled && count > 0 ? color : AppColors.textHint,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: enabled && count > 0 ? AppColors.textSecondary : AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasteryBreakdown(SpacedRepetitionState srState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
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
                const SizedBox(width: 8),
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
                      const SizedBox(height: 4),
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
    await ref.read(spacedRepetitionProvider.notifier).startSession(mode: mode);
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
              _buildStatRow('Average Strength', 
                  '${(srState.stats.averageStrength * 100).round()}%'),
              _buildStatRow('Reviews Today', srState.stats.reviewsToday.toString()),
              _buildStatRow('Current Streak', '${srState.stats.currentStreak} days'),
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
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
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

  const ReviewSessionScreen({
    super.key,
    required this.session,
  });

  @override
  ConsumerState<ReviewSessionScreen> createState() => _ReviewSessionScreenState();
}

class _ReviewSessionScreenState extends ConsumerState<ReviewSessionScreen> {
  int _currentCardIndex = 0;
  bool _showingAnswer = false;
  DateTime? _questionStartTime;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _questionStartTime = DateTime.now();
  }

  ReviewCard get _currentCard => widget.session.cards[_currentCardIndex];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await _showExitDialog();
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Practice Session'),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${_currentCardIndex + 1}/${widget.session.cards.length}',
                  style: AppTypography.labelLarge,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (_currentCardIndex + 1) / widget.session.cards.length,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),

            // Card content
            Expanded(
              child: _buildCardContent(),
            ),

            // Answer buttons
            if (!_showingAnswer)
              _buildAnswerButtons(),
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
              const SizedBox(width: 8),
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
          const SizedBox(height: 24),

          // Question card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                Text(
                  _getQuestionText(),
                  style: AppTypography.headlineMedium,
                ),
              ],
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage!,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
              ),
            ),
          ],

          if (_showingAnswer) ...[
            const SizedBox(height: 20),
            _buildFeedback(),
          ],
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
            color: Colors.black.withOpacity(0.05),
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
                        SizedBox(height: 4),
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
                        SizedBox(height: 4),
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
            ? AppColors.success.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: lastResult.correct 
              ? AppColors.success.withOpacity(0.3)
              : AppColors.error.withOpacity(0.3),
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
                        color: lastResult.correct ? AppColors.success : AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 4),
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
          const SizedBox(height: 16),
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
    if (_questionStartTime == null) return;

    final timeSpent = DateTime.now().difference(_questionStartTime!);

    try {
      await ref.read(spacedRepetitionProvider.notifier).recordSessionResult(
        cardId: _currentCard.id,
        correct: correct,
        timeSpent: timeSpent,
      );

      // Award XP to user profile
      final result = widget.session.results.last;
      await ref.read(userProfileProvider.notifier).addXp(result.xpEarned);

      setState(() {
        _showingAnswer = true;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error recording answer: $e';
      });
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
    final score = (widget.session.score * 100).round();
    
    return AlertDialog(
      title: Row(
        children: [
          const Text('Session Complete!'),
          const SizedBox(width: 8),
          const Text('🎉'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Score: $score%',
            style: AppTypography.headlineLarge.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total XP: ${widget.session.totalXp}',
            style: AppTypography.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            '${widget.session.results.where((r) => r.correct).length}/${widget.session.cards.length} cards correct',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
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
          child: const Text('Done'),
        ),
      ],
    );
  }

  Future<bool?> _showExitDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Session?'),
        content: const Text(
          'Your progress will be saved, but you\'ll need to start a new session to continue practicing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
