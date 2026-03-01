import 'package:danio/theme/app_theme.dart';
// Skeleton loading screens for better perceived performance
// Provides visual placeholders while content loads

import 'package:flutter/material.dart';

/// Shimmer effect for skeleton loaders
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({super.key, required this.child, this.isLoading = true});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.celebration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: AppCurves.standard));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [Colors.grey, Colors.white, Colors.grey],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
              transform: GradientRotation(_animation.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Basic skeleton box
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonBox({super.key, this.width, this.height, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[300],
        borderRadius: borderRadius ?? AppRadius.smallRadius,
      ),
    );
  }
}

/// Skeleton card for list items
class SkeletonCard extends StatelessWidget {
  final double? height;
  final EdgeInsets? padding;

  const SkeletonCard({super.key, this.height, this.padding});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        height: height ?? 100,
        margin:
            padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[100],
          borderRadius: AppRadius.mediumRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(
              width: double.infinity,
              height: 16,
              borderRadius: AppRadius.xsRadius,
            ),
            const SizedBox(height: AppSpacing.sm),
            SkeletonBox(
              width: 200,
              height: 14,
              borderRadius: AppRadius.xsRadius,
            ),
            const Spacer(),
            Row(
              children: [
                SkeletonBox(
                  width: 60,
                  height: 12,
                  borderRadius: AppRadius.xsRadius,
                ),
                const Spacer(),
                SkeletonBox(
                  width: 80,
                  height: 12,
                  borderRadius: AppRadius.xsRadius,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton grid for grid views (like gem shop, achievements)
class SkeletonGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;

  const SkeletonGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.75,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return ShimmerLoading(
          child: SkeletonBox(borderRadius: AppRadius.largeRadius),
        );
      },
    );
  }
}

/// Skeleton list for vertical lists
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const SkeletonList({super.key, this.itemCount = 5, this.itemHeight = 100});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return SkeletonCard(height: itemHeight);
      },
    );
  }
}

/// Skeleton for analytics charts
class SkeletonChart extends StatelessWidget {
  final double height;

  const SkeletonChart({super.key, this.height = 200});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        height: height,
        margin: EdgeInsets.all(AppSpacing.md),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[100],
          borderRadius: AppRadius.mediumRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(
              width: 150,
              height: 20,
              borderRadius: AppRadius.xsRadius,
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  7,
                  (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      child: SkeletonBox(
                        height: 60 + (index * 20).toDouble(),
                        borderRadius: AppRadius.xsRadius,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for story cards
class SkeletonStoryCard extends StatelessWidget {
  const SkeletonStoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[100],
          borderRadius: AppRadius.mediumRadius,
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: SkeletonBox(
                width: 80,
                height: 80,
                borderRadius: AppRadius.mediumRadius,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SkeletonBox(
                      width: double.infinity,
                      height: 18,
                      borderRadius: AppRadius.xsRadius,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SkeletonBox(
                      width: 150,
                      height: 14,
                      borderRadius: AppRadius.xsRadius,
                    ),
                    const SizedBox(height: AppSpacing.sm2),
                    SkeletonBox(
                      width: 100,
                      height: 12,
                      borderRadius: AppRadius.xsRadius,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for achievement cards
class SkeletonAchievementCard extends StatelessWidget {
  const SkeletonAchievementCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: EdgeInsets.all(AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[100],
          borderRadius: AppRadius.largeRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SkeletonBox(
                width: 60,
                height: 60,
                borderRadius: AppRadius.xlRadius,
              ),
            ),
            const SizedBox(height: AppSpacing.sm2),
            SkeletonBox(
              width: double.infinity,
              height: 16,
              borderRadius: AppRadius.xsRadius,
            ),
            const SizedBox(height: AppSpacing.sm),
            SkeletonBox(
              width: 120,
              height: 14,
              borderRadius: AppRadius.xsRadius,
            ),
            const Spacer(),
            SkeletonBox(
              width: double.infinity,
              height: 8,
              borderRadius: AppRadius.xsRadius,
            ),
          ],
        ),
      ),
    );
  }
}
