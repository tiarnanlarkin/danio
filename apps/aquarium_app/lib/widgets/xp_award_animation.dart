/// XP Award Animation Widget
/// Displays a floating "+XP" text that animates upward and fades out
library;

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Slide upward animation
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Fade out animation (starts fading after 50% of animation)
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInCubic),
      ),
    );

    // Scale animation (slight bounce at start)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.5,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 50),
    ]).animate(_controller);

    // Start animation
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
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
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.warning,
                      AppColors.warning.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.warning.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '+${widget.xpAmount} XP',
                      style: AppTypography.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
    final overlay = Overlay.of(context);
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
