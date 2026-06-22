import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/user_profile.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_button.dart';
import 'onboarding_layout.dart';

/// Captures the user's broad fishkeeping goals without forcing a formal track.
class GoalsScreen extends StatefulWidget {
  final UserGoal recommendedGoal;
  final ValueChanged<List<UserGoal>> onContinue;

  const GoalsScreen({
    super.key,
    required this.recommendedGoal,
    required this.onContinue,
  });

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final List<UserGoal> _selectedGoals = [];

  static const _choices = [
    _GoalChoice(
      goal: UserGoal.keepFishAlive,
      icon: Icons.favorite_border,
      title: 'Keep fish healthy',
      description: 'Spot problems early and build a safe routine.',
    ),
    _GoalChoice(
      goal: UserGoal.learnTheScience,
      icon: Icons.psychology_outlined,
      title: 'Plan with confidence',
      description: 'Understand cycling, water quality, and why care works.',
    ),
    _GoalChoice(
      goal: UserGoal.beautifulDisplay,
      icon: Icons.auto_awesome_outlined,
      title: 'Create a beautiful tank',
      description: 'Shape stocking, plants, layout, and long-term balance.',
    ),
    _GoalChoice(
      goal: UserGoal.relaxation,
      icon: Icons.self_improvement_outlined,
      title: 'Build a calming routine',
      description: 'Keep care simple, steady, and easy to return to.',
    ),
    _GoalChoice(
      goal: UserGoal.breeding,
      icon: Icons.egg_alt_outlined,
      title: 'Breed fish safely',
      description: 'Learn conditioning, fry care, and responsible planning.',
    ),
    _GoalChoice(
      goal: UserGoal.competition,
      icon: Icons.emoji_events_outlined,
      title: 'Prepare show-quality fish',
      description: 'Track detail, consistency, and high-standard husbandry.',
    ),
    _GoalChoice(
      goal: UserGoal.masterTheHobby,
      icon: Icons.school_outlined,
      title: 'Master advanced care',
      description: 'Go deeper into diagnostics, stability, and systems.',
    ),
  ];

  void _toggleGoal(UserGoal goal) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedGoals.contains(goal)) {
        _selectedGoals.remove(goal);
      } else {
        _selectedGoals.add(goal);
      }
    });
  }

  void _continue() {
    HapticFeedback.mediumImpact();
    widget.onContinue(List.unmodifiable(_selectedGoals));
  }

  void _useRecommendation() {
    HapticFeedback.lightImpact();
    widget.onContinue([widget.recommendedGoal]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingWarmCream,
      body: SafeArea(
        child: OnboardingContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Semantics(
                header: true,
                child: Text(
                  'What should Danio help with first?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Pick as many as fit. Danio will quietly use this to shape lessons, reminders, and care suggestions.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView.separated(
                  itemCount: _choices.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm2),
                  itemBuilder: (context, index) {
                    final choice = _choices[index];
                    final isSelected = _selectedGoals.contains(choice.goal);
                    final isRecommended = choice.goal == widget.recommendedGoal;
                    return _GoalCard(
                      choice: choice,
                      isSelected: isSelected,
                      isRecommended: isRecommended,
                      onTap: () => _toggleGoal(choice.goal),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Continue',
                onPressed: _selectedGoals.isEmpty ? null : _continue,
                variant: AppButtonVariant.primary,
                isFullWidth: true,
                size: AppButtonSize.large,
                semanticsLabel: 'Continue',
              ),
              AppButton(
                label: 'Use recommendation',
                onPressed: _useRecommendation,
                variant: AppButtonVariant.text,
                isFullWidth: true,
                semanticsLabel: 'Use recommendation',
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalChoice {
  final UserGoal goal;
  final IconData icon;
  final String title;
  final String description;

  const _GoalChoice({
    required this.goal,
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _GoalCard extends StatelessWidget {
  final _GoalChoice choice;
  final bool isSelected;
  final bool isRecommended;
  final VoidCallback onTap;

  const _GoalCard({
    required this.choice,
    required this.isSelected,
    required this.isRecommended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label:
          '${choice.title}. ${choice.description}${isRecommended ? '. Recommended' : ''}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.medium1,
          curve: AppCurves.standard,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceVariant : AppColors.surface,
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? AppShadows.medium : AppShadows.soft,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.16)
                      : AppColors.background,
                  borderRadius: AppRadius.smallRadius,
                ),
                child: Icon(
                  choice.icon,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            choice.title,
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (isRecommended) ...[
                          const SizedBox(width: AppSpacing.xs),
                          const _RecommendedChip(),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      choice.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.primary : AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendedChip extends StatelessWidget {
  const _RecommendedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.fullRadius,
      ),
      child: Text(
        'Recommended',
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
