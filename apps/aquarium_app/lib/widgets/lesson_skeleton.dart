/// Skeleton loaders for lesson content
/// Shows while lessons are being lazy-loaded
library;

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Skeleton loader for a learning path card
class PathCardSkeleton extends StatelessWidget {
  const PathCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildShimmer(50, 50, borderRadius: AppRadius.pillRadius),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmer(150, 20),
                      const SizedBox(height: AppSpacing.xs),
                      _buildShimmer(double.infinity, 14),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildShimmer(double.infinity, 12),
            const SizedBox(height: AppSpacing.xs),
            _buildShimmer(200, 12),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(
    double width,
    double height, {
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.textSecondaryAlpha10,
        borderRadius: borderRadius ?? AppRadius.smallRadius,
      ),
      child: const _ShimmerAnimation(),
    );
  }
}

/// Skeleton loader for a lesson list item
class LessonListSkeleton extends StatelessWidget {
  const LessonListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          _buildShimmer(40, 40, borderRadius: AppRadius.pillRadius),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmer(180, 16),
                const SizedBox(height: AppSpacing.xs),
                _buildShimmer(120, 12),
              ],
            ),
          ),
          _buildShimmer(60, 28),
        ],
      ),
    );
  }

  Widget _buildShimmer(
    double width,
    double height, {
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.textSecondaryAlpha10,
        borderRadius: borderRadius ?? AppRadius.smallRadius,
      ),
      child: const _ShimmerAnimation(),
    );
  }
}

/// Skeleton loader for lesson content
class LessonContentSkeleton extends StatelessWidget {
  const LessonContentSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _buildShimmer(200, 28), // Title
        const SizedBox(height: AppSpacing.sm),
        _buildShimmer(double.infinity, 16), // Text
        const SizedBox(height: AppSpacing.xs),
        _buildShimmer(double.infinity, 16),
        const SizedBox(height: AppSpacing.xs),
        _buildShimmer(250, 16),
        const SizedBox(height: AppSpacing.lg),
        _buildShimmer(150, 20), // Heading
        const SizedBox(height: AppSpacing.sm),
        _buildShimmer(double.infinity, 14),
        _buildShimmer(double.infinity, 14),
        _buildShimmer(200, 14),
        const SizedBox(height: AppSpacing.lg),
        _buildShimmer(double.infinity, 200), // Image placeholder
        const SizedBox(height: AppSpacing.lg),
        _buildShimmer(double.infinity, 14),
        _buildShimmer(double.infinity, 14),
        _buildShimmer(300, 14),
      ],
    );
  }

  Widget _buildShimmer(
    double width,
    double height, {
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.textSecondaryAlpha10,
        borderRadius: borderRadius ?? AppRadius.smallRadius,
      ),
      child: const _ShimmerAnimation(),
    );
  }
}

/// Animated shimmer effect
class _ShimmerAnimation extends StatefulWidget {
  const _ShimmerAnimation();

  @override
  State<_ShimmerAnimation> createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<_ShimmerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.celebration,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.standard),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.transparent,
                AppColors.whiteAlpha20,
                Colors.transparent,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Error state for lesson loading
class LessonErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const LessonErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: AppIconSizes.xxl,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Failed to Load Content',
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
