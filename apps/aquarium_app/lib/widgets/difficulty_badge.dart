/// Reusable difficulty badge widget
/// Shows difficulty level with color-coded styling
library;

import 'package:danio/theme/app_theme.dart';

import 'package:flutter/material.dart';
import '../models/adaptive_difficulty.dart';
import '../services/difficulty_service.dart';

/// Badge displaying lesson difficulty level with color-coded styling.
///
/// Shows difficulty as colored chip (green=easy, blue=medium, orange=hard,
/// pink=expert). Supports optional text label and size customization.
class DifficultyBadge extends StatelessWidget {
  final DifficultyLevel difficulty;
  final bool showLabel;
  final double size;

  const DifficultyBadge({
    super.key,
    required this.difficulty,
    this.showLabel = true,
    this.size = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final difficultyService = DifficultyService();
    final color = Color(difficultyService.getDifficultyColor(difficulty));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * size, vertical: 6 * size),
      decoration: BoxDecoration(
        color: color.withAlpha(51),
        borderRadius: BorderRadius.circular(20 * size),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(difficulty.emoji, style: TextStyle(fontSize: 16 * size)),
          if (showLabel) ...[
            SizedBox(width: 6 * size),
            Text(
              difficulty.displayName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14 * size,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Skill level indicator with progress bar
class SkillLevelIndicator extends StatelessWidget {
  final double skillLevel; // 0.0-1.0
  final String? label;
  final bool showPercentage;

  const SkillLevelIndicator({
    super.key,
    required this.skillLevel,
    this.label,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (skillLevel * 100).toInt();
    final color = _getSkillColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label!,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (showPercentage)
                  Text(
                    '$percentage%',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: AppRadius.smallRadius,
          child: LinearProgressIndicator(
            value: skillLevel,
            minHeight: 12,
            backgroundColor: context.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Color _getSkillColor() {
    if (skillLevel < 0.3) return AppColors.error;
    if (skillLevel < 0.6) return AppColors.warning;
    if (skillLevel < 0.8) return AppColors.info;
    return AppColors.success;
  }
}

/// Performance trend widget
class PerformanceTrendWidget extends StatelessWidget {
  final PerformanceTrend trend;
  final bool showLabel;

  const PerformanceTrendWidget({
    super.key,
    required this.trend,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getTrendColor();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs + 1,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(trend.emoji, style: Theme.of(context).textTheme.bodyLarge!),
          if (showLabel) ...[
            const SizedBox(width: AppSpacing.sm - 2),
            Text(
              trend.displayName,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getTrendColor() {
    switch (trend) {
      case PerformanceTrend.improving:
        return AppColors.success;
      case PerformanceTrend.stable:
        return AppColors.info;
      case PerformanceTrend.declining:
        return AppColors.warning;
    }
  }
}

/// Skill level up animation widget
class SkillLevelUpAnimation extends StatefulWidget {
  final String message;
  final VoidCallback onComplete;

  const SkillLevelUpAnimation({
    super.key,
    required this.message,
    required this.onComplete,
  });

  @override
  State<SkillLevelUpAnimation> createState() => _SkillLevelUpAnimationState();
}

class _SkillLevelUpAnimationState extends State<SkillLevelUpAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _disableMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: AppCurves.elastic),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: AppCurves.standardAccelerate),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(AppDurations.long2, () {
        if (mounted) {
          widget.onComplete();
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newValue = MediaQuery.of(context).disableAnimations;
    if (newValue != _disableMotion) {
      _disableMotion = newValue;
      _controller.duration = _disableMotion ? Duration.zero : const Duration(milliseconds: 2000);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [DanioColors.topaz, DanioColors.amberGold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.mediumRadius,
                boxShadow: [
                  BoxShadow(
                    color: AppOverlays.orange50,
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🎉',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium!.copyWith(fontSize: 48),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'LEVEL UP!',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium!.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Difficulty change notification
class DifficultyChangeNotification extends StatelessWidget {
  final DifficultyLevel oldLevel;
  final DifficultyLevel newLevel;
  final String reason;

  const DifficultyChangeNotification({
    super.key,
    required this.oldLevel,
    required this.newLevel,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    final isIncrease = newLevel.index > oldLevel.index;
    final color = isIncrease ? AppColors.success : AppColors.warning;
    final icon = isIncrease ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: AppIconSizes.lg),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      oldLevel.emoji,
                      style: Theme.of(context).textTheme.titleMedium!,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.arrow_forward,
                      size: AppIconSizes.xs,
                      color: color,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      newLevel.emoji,
                      style: Theme.of(context).textTheme.titleMedium!,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      newLevel.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  reason,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mastery badge for completed topics
class MasteryBadge extends StatelessWidget {
  final bool hasMastery;
  final double size;

  const MasteryBadge({super.key, required this.hasMastery, this.size = 1.0});

  @override
  Widget build(BuildContext context) {
    if (!hasMastery) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * size, vertical: 5 * size),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DanioColors.topaz, DanioColors.amberGold],
        ),
        borderRadius: BorderRadius.circular(12 * size),
        boxShadow: [
          BoxShadow(color: AppOverlays.amber30, blurRadius: 8, spreadRadius: 2),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🏆', style: TextStyle(fontSize: 14 * size)),
          SizedBox(width: 4 * size),
          Text(
            'Mastered',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12 * size,
            ),
          ),
        ],
      ),
    );
  }
}
