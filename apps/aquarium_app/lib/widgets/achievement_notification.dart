/// Achievement Notification Widget - Popup with confetti when unlocking
/// Shows achievement details with celebration animation
library;

import 'package:danio/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../models/achievements.dart';

/// Overlay notification system for achievement unlocks with confetti animation.
///
/// Shows a celebratory popup when achievements are unlocked. Manages its own
/// overlay entry and confetti controller for non-blocking visual feedback.
class AchievementNotification {
  static OverlayEntry? _currentOverlay;
  static ConfettiController? _confettiController;

  /// Show achievement unlock notification
  static void show(
    BuildContext context,
    Achievement achievement,
    int xpAwarded,
  ) {
    // Remove any existing notification
    dismiss();

    // Create confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Create overlay entry
    _currentOverlay = OverlayEntry(
      builder: (context) => _AchievementNotificationWidget(
        achievement: achievement,
        xpAwarded: xpAwarded,
        confettiController: _confettiController!,
        onDismiss: dismiss,
      ),
    );

    // Show overlay — use rootOverlay so this works during navigation transitions
    Overlay.of(context, rootOverlay: true).insert(_currentOverlay!);

    // Start confetti
    _confettiController!.play();

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      dismiss();
    });
  }

  /// Dismiss current notification
  static void dismiss() {
    _confettiController?.stop();
    _confettiController?.dispose();
    _confettiController = null;

    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

class _AchievementNotificationWidget extends StatefulWidget {
  final Achievement achievement;
  final int xpAwarded;
  final ConfettiController confettiController;
  final VoidCallback onDismiss;

  const _AchievementNotificationWidget({
    required this.achievement,
    required this.xpAwarded,
    required this.confettiController,
    required this.onDismiss,
  });

  @override
  State<_AchievementNotificationWidget> createState() =>
      _AchievementNotificationWidgetState();
}

class _AchievementNotificationWidgetState
    extends State<_AchievementNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.elastic,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: AppCurves.emphasized,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor(widget.achievement.rarity);

    return Material(
      color: Colors.black38,
      child: Stack(
        children: [
          // Tap to dismiss
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: Container(color: Colors.transparent),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: widget.confettiController,
              blastDirection: pi / 2, // Down
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.3,
              shouldLoop: false,
              colors: const [
                Colors.red,
                AppColors.primary,
                Colors.green,
                Colors.yellow,
                DanioColors.amethyst,
                DanioColors.amberGold,
                DanioColors.coralAccent,
              ],
            ),
          ),

          // Notification card
          Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: AppRadius.largeRadius,
                      boxShadow: [
                        BoxShadow(
                          color: AppOverlays.black30,
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header with rarity color
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [rarityColor, rarityColor.withAlpha(178)],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '🎉 ACHIEVEMENT UNLOCKED! 🎉',
                                style: Theme.of(context).textTheme.titleMedium!
                                    .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppOverlays.black20,
                                      blurRadius: 16,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    widget.achievement.icon,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .copyWith(fontSize: 60),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            children: [
                              // Rarity badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: rarityColor,
                                  borderRadius: AppRadius.mediumRadius,
                                ),
                                child: Text(
                                  widget.achievement.rarity.displayName
                                      .toUpperCase(),
                                  style: Theme.of(context).textTheme.bodySmall!
                                      .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                ),
                              ),

                              const SizedBox(height: AppSpacing.md),

                              // Achievement name
                              Text(
                                widget.achievement.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: AppSpacing.sm),

                              // Description
                              Text(
                                widget.achievement.description,
                                style: Theme.of(context).textTheme.titleMedium!
                                    .copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: AppSpacing.lg),

                              // XP reward
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: AppRadius.mediumRadius,
                                  border: Border.all(
                                    color: Colors.amber.shade200,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 32,
                                    ),
                                    const SizedBox(width: AppSpacing.sm2),
                                    Text(
                                      '+${widget.xpAwarded} XP',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber,
                                          ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: AppSpacing.md),

                              // Dismiss button
                              TextButton(
                                onPressed: widget.onDismiss,
                                child: Text(
                                  'Tap anywhere to continue',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(AchievementRarity rarity) {
    return AppAchievementColors.forTier(rarity.name);
  }
}
