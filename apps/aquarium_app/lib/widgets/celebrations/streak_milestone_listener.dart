/// Streak Milestone Listener Widget
/// Automatically shows celebrations when user hits streak milestones
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_theme.dart';

/// Widget that listens for streak changes and shows milestone celebrations.
///
/// Wrap around your main content. Shows a celebration overlay
/// when the user hits 3, 7, 14, 30, 50, or 100 day streaks.
class StreakMilestoneListener extends ConsumerStatefulWidget {
  final Widget child;

  const StreakMilestoneListener({super.key, required this.child});

  @override
  ConsumerState<StreakMilestoneListener> createState() =>
      _StreakMilestoneListenerState();
}

class _StreakMilestoneListenerState
    extends ConsumerState<StreakMilestoneListener> {
  bool _isShowing = false;

  static const _milestones = {3, 7, 14, 30, 50, 100};

  @override
  Widget build(BuildContext context) {
    ref.listen(userProfileProvider, (previous, next) {
      final prevStreak = previous?.valueOrNull?.currentStreak;
      final newStreak = next.valueOrNull?.currentStreak;

      if (newStreak != null &&
          prevStreak != null &&
          newStreak > prevStreak &&
          _milestones.contains(newStreak) &&
          !_isShowing) {
        _showCelebration(newStreak);
      }
    });

    return widget.child;
  }

  Future<void> _showCelebration(int streakDays) async {
    if (!mounted) return;
    _isShowing = true;
    HapticFeedback.heavyImpact();

    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _StreakCelebrationOverlay(
        streakDays: streakDays,
        onComplete: () {
          entry.remove();
          _isShowing = false;
        },
      ),
    );
    overlay.insert(entry);
  }
}

class _StreakCelebrationOverlay extends StatefulWidget {
  final int streakDays;
  final VoidCallback onComplete;

  const _StreakCelebrationOverlay({
    required this.streakDays,
    required this.onComplete,
  });

  @override
  State<_StreakCelebrationOverlay> createState() =>
      _StreakCelebrationOverlayState();
}

class _StreakCelebrationOverlayState extends State<_StreakCelebrationOverlay>
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
    if (widget.streakDays >= 100) return 'Legendary! ${widget.streakDays}-day streak!';
    if (widget.streakDays >= 50) return 'Incredible! ${widget.streakDays}-day streak!';
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
        widget.onComplete();
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
                        color: AppColors.primary.withAlpha(50),
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
                      Text(_emoji, style: const TextStyle(fontSize: 52)),
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
