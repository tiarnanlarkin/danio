/// Animated Empty State Widget
/// Expressive empty states using emoji, text, and Flutter animations.
/// Emoji gently floats up/down (subtle, 2s loop), title+subtitle fade in.
library;

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A beautiful animated empty state with a floating emoji and fade-in text.
///
/// Use this for any screen or section that has no content yet.
/// The emoji bobs gently up and down in a 2-second loop, while the
/// title and subtitle fade in on first render.
class AnimatedEmptyState extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Widget? cta;

  const AnimatedEmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.cta,
  });

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _fadeController;
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Floating emoji: gentle bob up/down, 2s loop
    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _floatAnimation = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _floatController.repeat(reverse: true);

    // Fade-in for title + subtitle
    _fadeController = AnimationController(
      duration: AppDurations.long3,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating emoji
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, reduceMotion ? 0 : _floatAnimation.value),
                  child: child,
                );
              },
              child: Text(widget.emoji, style: const TextStyle(fontSize: 64)),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Fade-in title
            FadeTransition(
              opacity: reduceMotion
                  ? const AlwaysStoppedAnimation(1.0)
                  : _fadeAnimation,
              child: Text(
                widget.title,
                style: AppTypography.headlineMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Fade-in subtitle
            FadeTransition(
              opacity: reduceMotion
                  ? const AlwaysStoppedAnimation(1.0)
                  : _fadeAnimation,
              child: Text(
                widget.subtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Optional CTA button
            if (widget.cta != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FadeTransition(
                opacity: reduceMotion
                    ? const AlwaysStoppedAnimation(1.0)
                    : _fadeAnimation,
                child: widget.cta!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
