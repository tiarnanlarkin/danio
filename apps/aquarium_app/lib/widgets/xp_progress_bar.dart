/// Animated XP Progress Bar Widget
/// Shows user's level progress with smooth fill animation
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';

/// Animated progress bar showing XP toward next level.
///
/// Displays current level, XP progress with smooth fill animation, and optional
/// labels showing XP amounts. Animates smoothly when XP increases.
class XpProgressBar extends ConsumerStatefulWidget {
  final double height;
  final bool showLabels;
  final bool showLevel;

  const XpProgressBar({
    super.key,
    this.height = 12,
    this.showLabels = true,
    this.showLevel = true,
  });

  @override
  ConsumerState<XpProgressBar> createState() => _XpProgressBarState();
}

class _XpProgressBarState extends ConsumerState<XpProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  double _currentProgress = 0.0;
  double _targetProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: AppCurves.emphasized));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateProgress(double newProgress) {
    if (newProgress != _targetProgress) {
      setState(() {
        _currentProgress = _targetProgress;
        _targetProgress = newProgress;
      });
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => Padding(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                        SizedBox(width: AppSpacing.xs),
                        Text('Unable to load', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning)),
                      ],
                    ),
                  ),
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();

        // Update animation target when profile changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateProgress(profile.levelProgress);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Level and XP labels
            if (widget.showLabels)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.showLevel)
                    Row(
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          size: AppIconSizes.xs,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Level ${profile.currentLevel}',
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  Text(
                    profile.xpToNextLevel > 0
                        ? '${profile.xpToNextLevel} XP to next level'
                        : 'Max Level!',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

            if (widget.showLabels) const SizedBox(height: AppSpacing.sm),

            // Animated progress bar
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                final animatedProgress =
                    _currentProgress +
                    (_targetProgress - _currentProgress) *
                        _progressAnimation.value;

                return Stack(
                  children: [
                    // Background
                    Container(
                      height: widget.height,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(widget.height / 2),
                      ),
                    ),

                    // Animated progress fill
                    FractionallySizedBox(
                      widthFactor: animatedProgress.clamp(0.0, 1.0),
                      child: Container(
                        height: widget.height,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(
                            widget.height / 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryAlpha40,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        // Shimmer effect
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            widget.height / 2,
                          ),
                          child: _ShimmerEffect(
                            isAnimating: _controller.isAnimating,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // XP count below bar
            if (widget.showLabels) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${profile.totalXp} Total XP',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Shimmer effect overlay for progress bar
class _ShimmerEffect extends StatefulWidget {
  final bool isAnimating;

  const _ShimmerEffect({required this.isAnimating});

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: AppDurations.celebration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAnimating) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.transparent,
                AppOverlays.white30,
                Colors.transparent,
              ],
              stops: [
                _shimmerController.value - 0.3,
                _shimmerController.value,
                _shimmerController.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Compact XP progress card for home screen
class XpProgressCard extends ConsumerWidget {
  final VoidCallback? onTap;

  const XpProgressCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => Padding(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                        SizedBox(width: AppSpacing.xs),
                        Text('Unable to load', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning)),
                      ],
                    ),
                  ),
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.warningAlpha15,
                AppColors.secondaryAlpha10,
              ],
            ),
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(
              color: AppColors.warningAlpha30,
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: AppRadius.mediumRadius,
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                borderRadius: AppRadius.smallRadius,
                              ),
                              child: const Icon(
                                Icons.workspace_premium,
                                color: Colors.white,
                                size: AppIconSizes.sm,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Level ${profile.currentLevel}',
                                  style: AppTypography.headlineSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  profile.levelTitle,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          '${profile.totalXp} XP',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    XpProgressBar(
                      height: 8,
                      showLabels: false,
                      showLevel: false,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      profile.xpToNextLevel > 0
                          ? '${profile.xpToNextLevel} XP to Level ${profile.currentLevel + 1}'
                          : 'Maximum level reached!',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
