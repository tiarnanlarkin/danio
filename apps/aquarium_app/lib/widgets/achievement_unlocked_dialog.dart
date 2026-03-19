/// Full-screen celebratory dialog for achievement unlocks
/// Shows confetti, achievement details, and rewards (XP + Gems)
library;

import 'package:danio/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

/// Full-screen celebratory dialog for major achievement unlocks.
///
/// Features confetti animation, achievement icon with scale/fade transitions,
/// XP and gem rewards display, and rarity-based styling. Modal presentation
/// requires user acknowledgment.
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

    final disableMotion = MediaQuery.of(context).disableAnimations;

    // Animation controller for entrance
    _animationController = AnimationController(
      vsync: this,
      duration: disableMotion ? Duration.zero : AppDurations.long3,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.elastic,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.standardAccelerate,
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
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          rarityColor.withAlpha(242),
                          rarityColor.withAlpha(217),
                        ],
                      ),
                      borderRadius: AppRadius.xlRadius,
                      boxShadow: [
                        BoxShadow(
                          color: rarityColor.withAlpha(128),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: AppSpacing.xl2),

                        // "Achievement Unlocked" header
                        Text(
                          '🎉 ACHIEVEMENT UNLOCKED! 🎉',
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Achievement icon (large)
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppOverlays.black30,
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.achievement.icon,
                              style: Theme.of(
                                context,
                              ).textTheme.headlineMedium!.copyWith(),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Tier badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppOverlays.white30,
                            borderRadius: AppRadius.largeRadius,
                            border: Border.all(
                              color: AppOverlays.white60,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            widget.achievement.rarity.displayName.toUpperCase(),
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Achievement name
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            widget.achievement.name,
                            style: Theme.of(context).textTheme.headlineMedium!
                                .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.sm2),

                        // Achievement description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            widget.achievement.description,
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(
                                  color: AppOverlays.white90,
                                  height: 1.4,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Rewards section
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(AppSpacing.lg2),
                          decoration: BoxDecoration(
                            color: AppOverlays.white20,
                            borderRadius: AppRadius.largeRadius,
                            border: Border.all(
                              color: AppOverlays.white40,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'REWARDS',
                                style: Theme.of(context).textTheme.bodyLarge!
                                    .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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

                        const SizedBox(height: AppSpacing.xl),

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
                                  borderRadius: AppRadius.mediumRadius,
                                ),
                                elevation: AppElevation.level3,
                              ),
                              child: Text(
                                'Awesome!',
                                style: Theme.of(context).textTheme.titleLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl2),
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
          AppColors.primary,
          Colors.green,
          Colors.yellow,
          DanioColors.amethyst,
          DanioColors.amberGold,
          DanioColors.coralAccent,
          DanioColors.tealWater,
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
            Text(icon, style: Theme.of(context).textTheme.headlineMedium!),
            const SizedBox(width: AppSpacing.sm),
            Text(
              amount,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: AppOverlays.white80,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Get rarity color
  Color _getRarityColor(AchievementRarity rarity) {
    return AppAchievementColors.forTier(rarity.name);
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
