/// Celebration Provider - StateNotifier and provider declarations for celebrations
/// Moved from celebration_service.dart; the service file re-exports this.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../widgets/celebrations/level_up_overlay.dart';
import 'reduced_motion_provider.dart';

/// State for active celebrations
class CelebrationState {
  final bool isActive;
  final String? title;
  final String? subtitle;
  final CelebrationLevel level;
  final ConfettiController? confettiController;

  const CelebrationState({
    this.isActive = false,
    this.title,
    this.subtitle,
    this.level = CelebrationLevel.standard,
    this.confettiController,
  });

  CelebrationState copyWith({
    bool? isActive,
    String? title,
    String? subtitle,
    CelebrationLevel? level,
    ConfettiController? confettiController,
  }) {
    return CelebrationState(
      isActive: isActive ?? this.isActive,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      level: level ?? this.level,
      confettiController: confettiController ?? this.confettiController,
    );
  }
}

/// Levels of celebration intensity
enum CelebrationLevel {
  /// Quick confetti burst
  standard,

  /// Achievement unlocked - confetti + overlay
  achievement,

  /// Level up - special effects
  levelUp,

  /// Milestone - big celebration
  milestone,
}

/// Provider for celebration state
final celebrationProvider =
    StateNotifierProvider<CelebrationNotifier, CelebrationState>(
      (ref) => CelebrationNotifier(ref),
    );

/// Notifier for managing celebrations
class CelebrationNotifier extends StateNotifier<CelebrationState> {
  CelebrationNotifier(this._ref) : super(const CelebrationState());

  final Ref _ref;
  ConfettiController? _controller;
  Timer? _dismissTimer;

  /// Cancel any pending auto-dismiss timer.
  void _cancelDismissTimer() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
  }

  /// Trigger a standard confetti burst
  /// With reduced motion: skips confetti, shows simple success indicator
  void confetti({Duration duration = const Duration(seconds: 2)}) {
    final reducedMotion = _ref.read(reducedMotionProvider);

    if (reducedMotion.disableDecorativeAnimations) {
      // Skip confetti animation entirely for reduced motion
      return;
    }

    _disposeController();
    _cancelDismissTimer();
    _controller = ConfettiController(duration: duration);

    state = CelebrationState(
      isActive: true,
      level: CelebrationLevel.standard,
      confettiController: _controller,
    );

    _controller?.play();

    // Auto-dismiss after duration
    _dismissTimer = Timer(duration + const Duration(milliseconds: 500), () {
      if (mounted) {
        dismiss();
      }
    });
  }

  /// Trigger an achievement celebration with title overlay
  /// With reduced motion: simplified overlay, no confetti
  void achievement(String title, {String? subtitle}) {
    final reducedMotion = _ref.read(reducedMotionProvider);

    _disposeController();
    _cancelDismissTimer();

    // Skip confetti for reduced motion, but still show title
    if (!reducedMotion.disableDecorativeAnimations) {
      _controller = ConfettiController(duration: const Duration(seconds: 3));
    }

    state = CelebrationState(
      isActive: true,
      title: title,
      subtitle: subtitle ?? 'Achievement Unlocked!',
      level: CelebrationLevel.achievement,
      confettiController: _controller,
    );

    _controller?.play();

    // Auto-dismiss after animation (shorter for reduced motion)
    final dismissDelay = reducedMotion.isEnabled
        ? const Duration(seconds: 2)
        : const Duration(seconds: 4);

    _dismissTimer = Timer(dismissDelay, () {
      if (mounted) {
        dismiss();
      }
    });
  }

  /// Trigger a level up celebration (basic confetti version)
  /// For the enhanced overlay, use showLevelUpOverlay() with a BuildContext
  void levelUp(int level, {String? levelTitle}) {
    _disposeController();
    _cancelDismissTimer();
    _controller = ConfettiController(duration: const Duration(seconds: 4));

    state = CelebrationState(
      isActive: true,
      title: 'Level $level!',
      subtitle: levelTitle ?? 'Keep up the great work! 🎉',
      level: CelebrationLevel.levelUp,
      confettiController: _controller,
    );

    _controller?.play();

    // Auto-dismiss after animation
    _dismissTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        dismiss();
      }
    });
  }

  /// Show enhanced level up overlay with full-screen animation
  /// This is the preferred method when a BuildContext is available
  void showLevelUpOverlay(
    BuildContext context,
    int level, {
    String? levelTitle,
  }) {
    // Dismiss any existing celebration
    dismiss();

    // Defer overlay to post-frame callback to avoid _ElementLifecycle.active
    // assertion during build transitions (e.g. onboarding → TabNavigator).
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        LevelUpOverlay.show(context, newLevel: level, levelTitle: levelTitle);
      }
    });
  }

  /// Trigger a milestone celebration (big achievement)
  void milestone(String title, {String? subtitle}) {
    _disposeController();
    _cancelDismissTimer();
    _controller = ConfettiController(duration: const Duration(seconds: 5));

    state = CelebrationState(
      isActive: true,
      title: title,
      subtitle: subtitle ?? 'Amazing milestone reached!',
      level: CelebrationLevel.milestone,
      confettiController: _controller,
    );

    _controller?.play();

    // Auto-dismiss after animation
    _dismissTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) {
        dismiss();
      }
    });
  }

  /// Dismiss active celebration
  void dismiss() {
    _cancelDismissTimer();
    _disposeController();
    state = const CelebrationState();
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _cancelDismissTimer();
    _disposeController();
    super.dispose();
  }
}
