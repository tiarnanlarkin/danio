/// Achievement Notification Widget - Popup with confetti when unlocking
/// Shows achievement details with celebration animation
library;

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../models/achievements.dart';

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

    // Show overlay
    Overlay.of(context).insert(_currentOverlay!);

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
      curve: Curves.elasticOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
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
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.purple,
                Colors.orange,
                Colors.pink,
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
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
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                rarityColor,
                                rarityColor.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                '🎉 ACHIEVEMENT UNLOCKED! 🎉',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 16,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    widget.achievement.icon,
                                    style: const TextStyle(fontSize: 60),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(24),
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
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  widget.achievement.rarity.displayName
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Achievement name
                              Text(
                                widget.achievement.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 8),

                              // Description
                              Text(
                                widget.achievement.description,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 24),

                              // XP reward
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(12),
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
                                    const SizedBox(width: 12),
                                    Text(
                                      '+${widget.xpAwarded} XP',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Dismiss button
                              TextButton(
                                onPressed: widget.onDismiss,
                                child: Text(
                                  'Tap anywhere to continue',
                                  style: TextStyle(color: Colors.grey.shade600),
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
    switch (rarity) {
      case AchievementRarity.bronze:
        return const Color(0xFFCD7F32);
      case AchievementRarity.silver:
        return const Color(0xFFC0C0C0);
      case AchievementRarity.gold:
        return const Color(0xFFFFD700);
      case AchievementRarity.platinum:
        return const Color(0xFFE5E4E2);
    }
  }
}
