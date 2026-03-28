/// XP Award Animation Widget
/// Displays a floating "+XP" text that animates upward and fades out
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated floating "+XP" text shown when user earns experience points.
///
/// Displays XP amount that slides upward while fading out and scaling.
/// Calls [onComplete] callback when animation finishes. Used for immediate
/// visual feedback on XP gains.
class XpAwardAnimation extends StatefulWidget {
  final int xpAmount;
  final VoidCallback? onComplete;

  const XpAwardAnimation({super.key, required this.xpAmount, this.onComplete});

  @override
  State<XpAwardAnimation> createState() => _XpAwardAnimationState();
}

class _XpAwardAnimationState extends State<XpAwardAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<int> _countUpAnimation;

  @override
  void initState() {
    super.initState();

    // Scale celebration duration by XP amount (larger reward = bigger moment)
    final baseDuration = AppDurations.celebration;
    final scale = math.min(1.0 + widget.xpAmount / 200.0, 2.0);
    final duration = Duration(
      milliseconds: (baseDuration.inMilliseconds * scale).round(),
    );

    _controller = AnimationController(duration: duration, vsync: this);

    // Slide upward animation — larger XP goes higher
    final slideEnd = -1.0 - (widget.xpAmount / 100.0).clamp(0.0, 1.0);
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, slideEnd),
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.emphasized),
    );

    // Fade out (starts at 50%)
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInCubic),
      ),
    );

    // Scale — larger XP gets a bigger pop
    final maxScale = math.min(1.2 + widget.xpAmount / 100.0 * 0.15, 1.5);
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.5,
          end: maxScale,
        ).chain(CurveTween(curve: AppCurves.standardDecelerate)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: maxScale,
          end: 1.0,
        ).chain(CurveTween(curve: AppCurves.standard)),
        weight: 20,
      ),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 50),
    ]).animate(_controller);

    // Count-up: number ticks from 0 to xpAmount over the first 60% of animation
    _countUpAnimation = IntTween(begin: 0, end: widget.xpAmount).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildContent({required int displayXp, required double fontSize}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg2,
        vertical: AppSpacing.sm2,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.warning, AppColors.warningAlpha80],
        ),
        borderRadius: AppRadius.largeRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.warningAlpha40,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.white, size: AppIconSizes.md),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '+$displayXp XP',
            style: AppTypography.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    // Font size scales with XP amount
    final fontSize = math.min(18.0 + widget.xpAmount / 50.0 * 4.0, 32.0);

    if (reduceMotion) {
      return _buildContent(displayXp: widget.xpAmount, fontSize: fontSize);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildContent(
                displayXp: _countUpAnimation.value,
                fontSize: fontSize,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Overlay widget to show XP animation on top of content
class XpAwardOverlay extends StatelessWidget {
  final int xpAmount;
  final VoidCallback? onComplete;

  const XpAwardOverlay({super.key, required this.xpAmount, this.onComplete});

  /// Show XP award animation as an overlay
  static void show(
    BuildContext context, {
    required int xpAmount,
    VoidCallback? onComplete,
  }) {
    // Use rootOverlay: true to avoid _dependents.isEmpty assertion when the
    // lesson screen's own overlay scope is being deactivated during navigation.
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.35,
        left: 0,
        right: 0,
        child: Center(
          child: XpAwardAnimation(
            xpAmount: xpAmount,
            onComplete: () {
              entry.remove();
              onComplete?.call();
            },
          ),
        ),
      ),
    );

    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.35,
      left: 0,
      right: 0,
      child: Center(
        child: XpAwardAnimation(xpAmount: xpAmount, onComplete: onComplete),
      ),
    );
  }
}
