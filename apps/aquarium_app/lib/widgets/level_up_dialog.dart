/// Level Up Celebration Dialog
/// Shows a celebratory dialog with confetti when user levels up
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Full-screen celebration dialog shown when user levels up.
///
/// Features confetti animation, level badge with scale animation, total XP display,
/// level title, and optional unlock message for new features or rewards.
class LevelUpDialog extends StatefulWidget {
  final int newLevel;
  final String levelTitle;
  final int totalXp;
  final String? unlockMessage;

  const LevelUpDialog({
    super.key,
    required this.newLevel,
    required this.levelTitle,
    required this.totalXp,
    this.unlockMessage,
  });

  /// Show the level up dialog
  static Future<void> show(
    BuildContext context, {
    required int newLevel,
    required String levelTitle,
    required int totalXp,
    String? unlockMessage,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LevelUpDialog(
        newLevel: newLevel,
        levelTitle: levelTitle,
        totalXp: totalXp,
        unlockMessage: unlockMessage,
      ),
    );
  }

  @override
  State<LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<LevelUpDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation for dialog
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: AppCurves.elastic,
    );

    // Confetti animation (continuous loop)
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    // Start animations
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Confetti particles
        ...List.generate(30, (index) => _buildConfettiParticle(index)),

        // Dialog content
        Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.xlRadius,
              ),
              child: Container(
                padding: EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppRadius.xlRadius,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryAlpha40,
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Star icon with glow
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppOverlays.white20,
                        boxShadow: [
                          BoxShadow(
                            color: AppOverlays.white30,
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // "Level Up!" text
                    Text(
                      'Level Up!',
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // New level badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppOverlays.white20,
                        borderRadius: AppRadius.largeRadius,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Level ${widget.newLevel}',
                            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            widget.levelTitle,
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Total XP
                    Text(
                      '${widget.totalXp} Total XP',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: AppOverlays.white90,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Unlock message (if any)
                    if (widget.unlockMessage != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppOverlays.white15,
                          borderRadius: AppRadius.mediumRadius,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lock_open,
                              color: Colors.white,
                              size: AppIconSizes.sm,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.unlockMessage!,
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.lg),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.largeRadius,
                          ),
                          elevation: AppElevation.level0,
                        ),
                        child: Text(
                          'Continue',
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfettiParticle(int index) {
    // Random properties for each particle
    final random = math.Random(index);
    final startX = random.nextDouble();
    final endY = random.nextDouble() * 0.3 + 0.7; // Fall 70-100% down
    final size = random.nextDouble() * 8 + 4; // 4-12px
    final rotation = random.nextDouble() * 2 * math.pi;
    final color = _getRandomColor(random);
    final delay = random.nextInt(500);

    return AnimatedBuilder(
      animation: _confettiController,
      builder: (context, child) {
        // Calculate position based on animation progress
        final progress = (_confettiController.value + (delay / 3000)) % 1.0;

        return Positioned(
          left: MediaQuery.of(context).size.width * startX,
          top: MediaQuery.of(context).size.height * progress * endY,
          child: Transform.rotate(
            angle: rotation + (progress * 4 * math.pi),
            child: Opacity(
              opacity: (1 - progress).clamp(0.0, 1.0),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color,
                  shape: random.nextBool()
                      ? BoxShape.circle
                      : BoxShape.rectangle,
                  borderRadius: random.nextBool()
                      ? null
                      : BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getRandomColor(math.Random random) {
    final colors = [
      AppColors.warning,
      AppColors.secondary,
      AppColors.accent,
      AppColors.accentAlt,
      AppColors.success,
      DanioColors.coralAccent,
      Colors.yellow.shade400,
    ];
    return colors[random.nextInt(colors.length)];
  }
}
