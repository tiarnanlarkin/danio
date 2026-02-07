/// Full-screen celebratory dialog for achievement unlocks
/// Shows confetti, achievement details, and rewards (XP + Gems)
library;

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../models/achievements.dart';
import '../models/gem_economy.dart';

/// Show full-screen achievement unlocked dialog
Future<void> showAchievementUnlockedDialog({
  required BuildContext context,
  required Achievement achievement,
  required int xpAwarded,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false, // Must tap button to dismiss
    builder: (context) => AchievementUnlockedDialog(
      achievement: achievement,
      xpAwarded: xpAwarded,
    ),
  );
}

class AchievementUnlockedDialog extends StatefulWidget {
  final Achievement achievement;
  final int xpAwarded;

  const AchievementUnlockedDialog({
    super.key,
    required this.achievement,
    required this.xpAwarded,
  });

  @override
  State<AchievementUnlockedDialog> createState() =>
      _AchievementUnlockedDialogState();
}

class _AchievementUnlockedDialogState extends State<AchievementUnlockedDialog>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );

    // Animation controller for entrance
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // Start animations
    _confettiController.play();
    _animationController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor(widget.achievement.rarity);
    final gemReward = _getGemReward(widget.achievement.rarity);

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          // Confetti - multiple blast directions for full coverage
          _buildConfetti(Alignment.topCenter, pi / 2), // Down
          _buildConfetti(Alignment.topLeft, pi / 2.5), // Down-right
          _buildConfetti(Alignment.topRight, pi / 1.5), // Down-left

          // Main content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          rarityColor.withOpacity(0.95),
                          rarityColor.withOpacity(0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: rarityColor.withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 40),

                        // "Achievement Unlocked" header
                        const Text(
                          '🎉 ACHIEVEMENT UNLOCKED! 🎉',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Achievement icon (large)
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.achievement.icon,
                              style: const TextStyle(fontSize: 80),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Tier badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.6),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            widget.achievement.rarity.displayName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Achievement name
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            widget.achievement.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Achievement description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            widget.achievement.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Rewards section
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'REWARDS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  // XP reward
                                  _buildRewardItem(
                                    icon: '⭐',
                                    amount: '+${widget.xpAwarded}',
                                    label: 'XP',
                                  ),
                                  // Gems reward
                                  _buildRewardItem(
                                    icon: '💎',
                                    amount: '+$gemReward',
                                    label: 'Gems',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // "Awesome!" button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: rarityColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                              ),
                              child: const Text(
                                'Awesome!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
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

  /// Build confetti widget at specific alignment and direction
  Widget _buildConfetti(Alignment alignment, double blastDirection) {
    return Align(
      alignment: alignment,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirection: blastDirection,
        emissionFrequency: 0.05,
        numberOfParticles: 15,
        gravity: 0.2,
        shouldLoop: false,
        colors: const [
          Colors.red,
          Colors.blue,
          Colors.green,
          Colors.yellow,
          Colors.purple,
          Colors.orange,
          Colors.pink,
          Colors.cyan,
          Colors.amber,
        ],
        createParticlePath: _drawStar,
      ),
    );
  }

  /// Draw star-shaped confetti
  Path _drawStar(Size size) {
    final path = Path();
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = _degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    path.moveTo(centerX, centerY - externalRadius);

    for (int i = 0; i < numberOfPoints; i++) {
      final angle = i * degreesPerStep - pi / 2;
      final x1 = centerX + externalRadius * cos(angle);
      final y1 = centerY + externalRadius * sin(angle);
      path.lineTo(x1, y1);

      final x2 = centerX + internalRadius * cos(angle + halfDegreesPerStep);
      final y2 = centerY + internalRadius * sin(angle + halfDegreesPerStep);
      path.lineTo(x2, y2);
    }

    path.close();
    return path;
  }

  double _degToRad(double deg) => deg * (pi / 180.0);

  /// Build individual reward item (XP or Gems)
  Widget _buildRewardItem({
    required String icon,
    required String amount,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 8),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Get rarity color
  Color _getRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.bronze:
        return const Color(0xFFCD7F32); // Bronze
      case AchievementRarity.silver:
        return const Color(0xFFC0C0C0); // Silver
      case AchievementRarity.gold:
        return const Color(0xFFFFD700); // Gold
      case AchievementRarity.platinum:
        return const Color(0xFFB9F2FF); // Platinum (lighter blue-white)
    }
  }

  /// Get gem reward based on rarity
  int _getGemReward(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.bronze:
        return GemRewards.achievementBronze;
      case AchievementRarity.silver:
        return GemRewards.achievementSilver;
      case AchievementRarity.gold:
        return GemRewards.achievementGold;
      case AchievementRarity.platinum:
        return GemRewards.achievementPlatinum;
    }
  }
}
