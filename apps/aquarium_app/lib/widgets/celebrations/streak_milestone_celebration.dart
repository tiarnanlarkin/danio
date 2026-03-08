/// Streak Milestone Celebration
/// Shows a special celebration overlay when the user hits a streak milestone.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

/// Displays a celebration overlay for streak milestones (3, 7, 14, 30 days).
class StreakMilestoneCelebration extends StatefulWidget {
  final int streakDays;
  final VoidCallback? onComplete;

  const StreakMilestoneCelebration({
    super.key,
    required this.streakDays,
    this.onComplete,
  });

  /// Show as an overlay
  static void show(BuildContext context, int streakDays) {
    // Only celebrate milestones
    if (![3, 7, 14, 30, 50, 100].contains(streakDays)) return;

    HapticFeedback.heavyImpact();

    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => StreakMilestoneCelebration(
        streakDays: streakDays,
        onComplete: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  @override
  State<StreakMilestoneCelebration> createState() =>
      _StreakMilestoneCelebrationState();
}

class _StreakMilestoneCelebrationState extends State<StreakMilestoneCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  String get _emoji {
    if (widget.streakDays >= 100) return '\u{1F451}';
    if (widget.streakDays >= 50) return '\u{2B50}';
    if (widget.streakDays >= 30) return '\u{1F3C6}';
    if (widget.streakDays >= 14) return '\u{1F4AA}';
    if (widget.streakDays >= 7) return '\u{1F525}';
    return '\u{2728}';
  }

  String get _message {
    if (widget.streakDays >= 100) return 'Legendary! 100-day streak!';
    if (widget.streakDays >= 50) return 'Incredible! 50-day streak!';
    if (widget.streakDays >= 30) return 'A whole month! Unstoppable!';
    if (widget.streakDays >= 14) return '2-week warrior! Keep going!';
    if (widget.streakDays >= 7) return '${widget.streakDays}-day streak! You\'re on fire!';
    return '${widget.streakDays}-day streak! Nice start!';
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fade = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.1), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 75),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fade.value,
            child: Center(
              child: Transform.scale(
                scale: _scale.value,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.lg2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withAlpha(240),
                    borderRadius: AppRadius.largeRadius,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryAlpha20,
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.primary.withAlpha(60),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _emoji,
                        style: const TextStyle(fontSize: 52),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _message,
                        style: AppTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Your fish appreciate the dedication!',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
