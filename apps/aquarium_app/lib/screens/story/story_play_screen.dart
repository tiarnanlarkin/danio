import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/story.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_button.dart';
import '../../widgets/core/glass_card.dart';
import '../../widgets/xp_award_animation.dart';

/// Plays a single interactive story. Renders scenes, shows branching choices,
/// tracks progress, and awards XP on completion.
class StoryPlayScreen extends ConsumerStatefulWidget {
  final Story story;

  const StoryPlayScreen({super.key, required this.story});

  @override
  ConsumerState<StoryPlayScreen> createState() => _StoryPlayScreenState();
}

class _StoryPlayScreenState extends ConsumerState<StoryPlayScreen> {
  late StoryProgress _progress;
  StoryChoice? _selectedChoice;
  bool _showingFeedback = false;
  bool _isAwarding = false;

  @override
  void initState() {
    super.initState();
    _progress = StoryProgress.start(
      widget.story.id,
      widget.story.startScene.id,
    );
  }

  StoryScene get _currentScene {
    return widget.story.getSceneById(_progress.currentSceneId) ??
        widget.story.startScene;
  }

  bool get _isComplete => _progress.completed;

  void _onChoiceTap(StoryChoice choice) {
    if (_showingFeedback || _isComplete) return;

    setState(() {
      _selectedChoice = choice;
      _showingFeedback = true;
    });
  }

  Future<void> _onContinue() async {
    final choice = _selectedChoice;
    if (choice == null) return;

    // Find the next scene
    StoryScene? nextScene;
    if (!choice.endsStory) {
      nextScene = widget.story.getSceneById(choice.nextSceneId);
    }

    final isFinal =
        choice.endsStory || nextScene == null || nextScene.isFinalScene;

    final newProgress = _progress.makeChoice(
      choice: choice,
      nextSceneId: isFinal ? _progress.currentSceneId : choice.nextSceneId,
      isFinalScene: isFinal,
    );

    setState(() {
      _progress = newProgress;
      _selectedChoice = null;
      _showingFeedback = false;
    });

    if (newProgress.completed) {
      await _handleCompletion(newProgress);
    }
  }

  Future<void> _handleCompletion(StoryProgress progress) async {
    if (_isAwarding) return;
    setState(() => _isAwarding = true);

    final xpEarned = progress.calculateXp(widget.story.xpReward);

    // Save to profile — updateStoryProgress handles XP + completedStories
    await ref.read(userProfileProvider.notifier).updateStoryProgress(
      storyId: widget.story.id,
      progressData: progress.toJson(),
      isCompleted: true,
      xpReward: xpEarned,
    );

    if (!mounted) return;

    // Show XP animation
    XpAwardOverlay.show(
      context,
      xpAmount: xpEarned,
      onComplete: () {
        setState(() => _isAwarding = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.story.title),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isComplete)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Center(
                child: Text(
                  '${widget.story.difficulty.emoji} ${widget.story.difficulty.displayName}',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isComplete
          ? _buildCompletionScreen()
          : _buildPlayScreen(),
    );
  }

  Widget _buildPlayScreen() {
    final scene = _currentScene;
    final choice = _selectedChoice;

    return Column(
      children: [
        // Progress indicator
        LinearProgressIndicator(
          value: _progress.totalChoices > 0
              ? (_progress.visitedSceneIds.length /
                      (widget.story.scenes.length.clamp(1, 999)))
                  .clamp(0.0, 1.0)
              : 0.0,
          backgroundColor: context.surfaceVariant,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 4,
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scene text
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    scene.text,
                    style: AppTypography.bodyLarge.copyWith(height: 1.6),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Feedback after choosing
                if (_showingFeedback && choice != null) ...[
                  _buildFeedbackBanner(choice),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Choices (hidden after selection, show Continue instead)
                if (!_showingFeedback) ...[
                  Text(
                    'What do you do?',
                    style: AppTypography.titleSmall.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...scene.choices.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _ChoiceTile(
                        choice: c,
                        onTap: () => _onChoiceTap(c),
                      ),
                    ),
                  ),
                ],

                // Continue button after feedback
                if (_showingFeedback) ...[
                  AppButton(
                    label: 'Continue',
                    onPressed: _onContinue,
                    isFullWidth: true,
                    size: AppButtonSize.large,
                    trailingIcon: Icons.arrow_forward,
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackBanner(StoryChoice choice) {
    final isCorrect = choice.isCorrect;
    final color = isCorrect ? AppColors.success : AppColors.warning;
    final icon = isCorrect ? Icons.check_circle_outline : Icons.info_outline;
    final label = isCorrect ? 'Great choice!' : 'Interesting choice...';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(color: color),
                ),
                if (choice.feedback != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    choice.feedback!,
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    final xpEarned = _progress.calculateXp(widget.story.xpReward);
    final score = _progress.score;

    String emoji;
    String headline;
    if (score >= 90) {
      emoji = '🏆';
      headline = 'Masterful!';
    } else if (score >= 70) {
      emoji = '🎉';
      headline = 'Well done!';
    } else if (score >= 50) {
      emoji = '👍';
      headline = 'Story complete!';
    } else {
      emoji = '📚';
      headline = 'Story complete!';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: AppSpacing.md),
            Text(headline, style: AppTypography.headlineLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.story.title,
              style: AppTypography.titleMedium.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Score card
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatItem(
                    label: 'Score',
                    value: '$score%',
                    icon: Icons.bar_chart,
                    color: AppColors.primary,
                  ),
                  _StatItem(
                    label: 'XP Earned',
                    value: '+$xpEarned',
                    icon: Icons.star,
                    color: AppColors.warning,
                  ),
                  _StatItem(
                    label: 'Choices',
                    value: '${_progress.correctChoices}/${_progress.totalChoices}',
                    icon: Icons.check_circle_outline,
                    color: AppColors.success,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            AppButton(
              label: 'Back to Stories',
              onPressed: () => Navigator.of(context).pop(),
              isFullWidth: true,
              size: AppButtonSize.large,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final StoryChoice choice;
  final VoidCallback onTap;

  const _ChoiceTile({required this.choice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              choice.text,
              style: AppTypography.bodyMedium,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: context.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }
}
