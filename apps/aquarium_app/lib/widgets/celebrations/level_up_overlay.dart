/// Level Up Overlay - Celebratory full-screen animation
/// Displays when users gain enough XP to reach a new level
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '../../theme/app_theme.dart';
import 'confetti_overlay.dart';

/// Full-screen level up celebration overlay
///
/// Animation sequence:
/// 1. Screen dims (dark overlay fades in)
/// 2. "LEVEL UP!" text scales from 0 → 1.2 → 1.0 with bounce
/// 3. Level number appears with golden glow
/// 4. Confetti fires from sides
/// 5. Auto-dismiss after 3 seconds or on tap
class LevelUpOverlay extends StatefulWidget {
  /// The new level achieved
  final int newLevel;

  /// Optional level title (e.g., "Aquarist", "Expert")
  final String? levelTitle;

  /// Callback when overlay is dismissed
  final VoidCallback? onDismiss;

  /// Duration before auto-dismiss (default 3 seconds)
  final Duration autoDismissDuration;

  /// Whether to show the overlay (for animated visibility)
  final bool isVisible;

  const LevelUpOverlay({
    super.key,
    required this.newLevel,
    this.levelTitle,
    this.onDismiss,
    this.autoDismissDuration = const Duration(seconds: 3),
    this.isVisible = true,
  });

  /// Show level up overlay as a dialog
  static Future<void> show(
    BuildContext context, {
    required int newLevel,
    String? levelTitle,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Level Up',
      barrierColor: Colors.transparent,
      transitionDuration: AppDurations.medium4,
      pageBuilder: (context, animation, secondaryAnimation) {
        return LevelUpOverlay(
          newLevel: newLevel,
          levelTitle: levelTitle,
          onDismiss: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _overlayController;
  late AnimationController _textController;
  late AnimationController _levelController;
  late AnimationController _glowController;
  late AnimationController _particleController;

  // Confetti controllers
  late ConfettiController _leftConfettiController;
  late ConfettiController _rightConfettiController;

  // Animations
  late Animation<double> _overlayFade;
  late Animation<double> _textScale;
  late Animation<double> _levelScale;
  late Animation<double> _levelFade;
  late Animation<double> _glowPulse;

  // Prevent double-dismiss (auto-dismiss + button tap race condition)
  bool _isDismissing = false;

  // Sparkle particles
  final List<_SparkleParticle> _sparkles = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeConfetti();
    _generateSparkles();
    _startAnimationSequence();

    // Haptic feedback
    HapticFeedback.heavyImpact();
  }

  void _initializeAnimations() {
    // Overlay fade (300ms)
    _overlayController = AnimationController(
      vsync: this,
      duration: AppDurations.medium4,
    );
    _overlayFade = CurvedAnimation(
      parent: _overlayController,
      curve: AppCurves.standardDecelerate,
    );

    // "LEVEL UP!" text bounce scale (600ms)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.2,
        ).chain(CurveTween(curve: AppCurves.standardDecelerate)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: AppCurves.elastic)),
        weight: 40,
      ),
    ]).animate(_textController);

    // Level number appearance (500ms)
    _levelController = AnimationController(
      vsync: this,
      duration: AppDurations.long2,
    );
    _levelScale = CurvedAnimation(
      parent: _levelController,
      curve: AppCurves.elastic,
    );
    _levelFade = CurvedAnimation(
      parent: _levelController,
      curve: AppCurves.standardAccelerate,
    );

    // Glow pulse (continuous)
    _glowController = AnimationController(
      vsync: this,
      duration: AppDurations.celebration,
    );
    _glowPulse = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: AppCurves.standard),
    );

    // Particle animation (2 seconds)
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  void _initializeConfetti() {
    _leftConfettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _rightConfettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  void _generateSparkles() {
    for (int i = 0; i < 20; i++) {
      _sparkles.add(
        _SparkleParticle(
          angle: _random.nextDouble() * 2 * math.pi,
          distance: 80 + _random.nextDouble() * 120,
          size: 4 + _random.nextDouble() * 8,
          delay: _random.nextDouble() * 0.3,
          rotationSpeed: (_random.nextDouble() - 0.5) * 4,
          color: _getSparkleColor(_random.nextInt(5)),
        ),
      );
    }
  }

  Color _getSparkleColor(int index) {
    const colors = [
      Color(0xFFE8A84A), // Gold
      Color(0xFFD97706), // Amber
      Color(0xFFFFE082), // Light gold
      Color(0xFFFFFFFF), // White
      Color(0xFFB45309), // Deep gold
    ];
    return colors[index];
  }

  void _startAnimationSequence() async {
    // Step 1: Fade in overlay
    _overlayController.forward();

    await Future.delayed(AppDurations.medium2);

    // Step 2: "LEVEL UP!" text bounces in
    _textController.forward();

    await Future.delayed(AppDurations.medium4);

    // Step 3: Level number appears with glow
    _levelController.forward();
    _glowController.repeat(reverse: true);

    // Step 4: Fire confetti and sparkles
    await Future.delayed(AppDurations.medium2);
    _leftConfettiController.play();
    _rightConfettiController.play();
    _particleController.forward();

    // Step 5: Auto-dismiss after duration
    await Future.delayed(widget.autoDismissDuration);
    if (mounted && !_isDismissing) {
      _dismiss();
    }
  }

  void _dismiss() async {
    // Guard against double-dismiss (race between button tap and auto-dismiss)
    if (_isDismissing) return;
    _isDismissing = true;
    // Reverse animations
    if (mounted) await _overlayController.reverse();
    widget.onDismiss?.call();
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _textController.dispose();
    _levelController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _leftConfettiController.dispose();
    _rightConfettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    // Reduced motion: show static level text without animations/confetti
    if (reduceMotion) {
      return Material(
        type: MaterialType.transparency,
        child: Semantics(
          label: 'Dismiss level up notification',
          button: true,
          child: GestureDetector(
            onTap: _dismiss,
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: AppOverlays.black60,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLevelUpText(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildLevelNumber(),
                    if (widget.levelTitle != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      _buildLevelTitle(),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    ElevatedButton(
                      onPressed: _dismiss,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        backgroundColor: const Color(0xFF8B6BAE),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'Continue',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      type: MaterialType.transparency,
      child: Semantics(
        label: 'Dismiss level up notification',
        button: true,
        child: GestureDetector(
          onTap: _dismiss,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // Dark overlay
              FadeTransition(
                opacity: _overlayFade,
                child: Container(color: AppOverlays.black60),
              ),

            // Sparkle particles
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, _) => CustomPaint(
                painter: _SparklePainter(
                  sparkles: _sparkles,
                  progress: _particleController.value,
                  center: Offset(size.width / 2, size.height / 2 - 40),
                ),
                size: size,
              ),
            ),

            // Confetti from left
            Positioned(
              left: 0,
              top: size.height * 0.3,
              child: ConfettiWidget(
                confettiController: _leftConfettiController,
                blastDirection: -math.pi / 4, // Up-right
                blastDirectionality: BlastDirectionality.directional,
                emissionFrequency: 0.05,
                numberOfParticles: 15,
                gravity: 0.2,
                colors: ConfettiColors.levelUp,
                createParticlePath: _createStarPath,
              ),
            ),

            // Confetti from right
            Positioned(
              right: 0,
              top: size.height * 0.3,
              child: ConfettiWidget(
                confettiController: _rightConfettiController,
                blastDirection: -3 * math.pi / 4, // Up-left
                blastDirectionality: BlastDirectionality.directional,
                emissionFrequency: 0.05,
                numberOfParticles: 15,
                gravity: 0.2,
                colors: ConfettiColors.levelUp,
                createParticlePath: _createStarPath,
              ),
            ),

            // Central content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // "LEVEL UP!" text
                  ScaleTransition(
                    scale: _textScale,
                    child: _buildLevelUpText(),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Level number with glow
                  FadeTransition(
                    opacity: _levelFade,
                    child: ScaleTransition(
                      scale: _levelScale,
                      child: _buildLevelNumber(),
                    ),
                  ),

                  // Level title (if provided)
                  if (widget.levelTitle != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    FadeTransition(
                      opacity: _levelFade,
                      child: _buildLevelTitle(),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // Continue button instead of just tap hint
                  FadeTransition(
                    opacity: _overlayFade,
                    child: ElevatedButton(
                      onPressed: _dismiss,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        backgroundColor: const Color(0xFF8B6BAE),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'Continue',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Tap anywhere hint
                  FadeTransition(
                    opacity: _overlayFade,
                    child: Text(
                      'or tap anywhere',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppOverlays.white50,
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
    );
  }

  Widget _buildLevelUpText() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFFE8A84A), // Gold
          Color(0xFFB45309), // Orange
          Color(0xFFE8A84A), // Gold
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(bounds),
      child: Text(
        'LEVEL UP!',
        style: AppTypography.headlineLarge.copyWith(
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 4,
          shadows: [
            Shadow(
              color: const Color(0xFFE8A84A).withValues(alpha: 0.8),
              blurRadius: 20,
            ),
            Shadow(
              color: const Color(0xFFB45309).withValues(alpha: 0.6),
              blurRadius: 40,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelNumber() {
    return AnimatedBuilder(
      animation: _glowPulse,
      builder: (context, child) {
        return Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2A3548), // Indigo
                Color(0xFF8B6BAE), // Purple
                Color(0xFFD946EF), // Fuchsia
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF8B6BAE,
                ).withValues(alpha: 0.4 + _glowPulse.value * 0.4),
                blurRadius: 30 + _glowPulse.value * 20,
                spreadRadius: 5 + _glowPulse.value * 10,
              ),
              BoxShadow(
                color: const Color(
                  0xFFD946EF,
                ).withValues(alpha: 0.3 + _glowPulse.value * 0.3),
                blurRadius: 50 + _glowPulse.value * 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.newLevel}',
                  style: AppTypography.headlineLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppOverlays.white15,
        borderRadius: AppRadius.pillRadius,
        border: Border.all(color: AppOverlays.white30, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🏆', style: Theme.of(context).textTheme.titleLarge!),
          const SizedBox(width: AppSpacing.sm),
          Text(
            widget.levelTitle!,
            style: AppTypography.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Path _createStarPath(Size size) {
    final path = Path();
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    path.moveTo(centerX, centerY - externalRadius);

    for (int i = 0; i < numberOfPoints; i++) {
      final angle = i * (2 * math.pi / numberOfPoints) - math.pi / 2;
      final x1 = centerX + externalRadius * math.cos(angle);
      final y1 = centerY + externalRadius * math.sin(angle);
      path.lineTo(x1, y1);

      final halfStep = math.pi / numberOfPoints;
      final x2 = centerX + internalRadius * math.cos(angle + halfStep);
      final y2 = centerY + internalRadius * math.sin(angle + halfStep);
      path.lineTo(x2, y2);
    }

    path.close();
    return path;
  }
}

/// Sparkle particle data
class _SparkleParticle {
  final double angle;
  final double distance;
  final double size;
  final double delay;
  final double rotationSpeed;
  final Color color;

  _SparkleParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
    required this.rotationSpeed,
    required this.color,
  });
}

/// Custom painter for sparkle particles
class _SparklePainter extends CustomPainter {
  final List<_SparkleParticle> sparkles;
  final double progress;
  final Offset center;

  _SparklePainter({
    required this.sparkles,
    required this.progress,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final sparkle in sparkles) {
      final effectiveProgress =
          ((progress - sparkle.delay) / (1 - sparkle.delay)).clamp(0.0, 1.0);
      if (effectiveProgress <= 0) continue;

      // Fade out near the end
      final opacity = effectiveProgress < 0.7
          ? 1.0
          : (1.0 - (effectiveProgress - 0.7) / 0.3);

      // Expand outward
      final currentDistance = sparkle.distance * effectiveProgress;
      final x = center.dx + math.cos(sparkle.angle) * currentDistance;
      final y = center.dy + math.sin(sparkle.angle) * currentDistance;

      // Scale down as they expand
      final currentSize = sparkle.size * (1.0 - effectiveProgress * 0.5);

      // Rotation
      final rotation = sparkle.rotationSpeed * effectiveProgress * math.pi;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      // Draw star shape
      _drawStar(
        canvas,
        Offset.zero,
        currentSize,
        sparkle.color.withValues(alpha: opacity),
      );

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    const numberOfPoints = 4;
    final externalRadius = size;
    final internalRadius = size * 0.4;

    path.moveTo(center.dx, center.dy - externalRadius);

    for (int i = 0; i < numberOfPoints; i++) {
      final angle = i * (2 * math.pi / numberOfPoints) - math.pi / 2;
      final x1 = center.dx + externalRadius * math.cos(angle);
      final y1 = center.dy + externalRadius * math.sin(angle);
      path.lineTo(x1, y1);

      final halfStep = math.pi / numberOfPoints;
      final x2 = center.dx + internalRadius * math.cos(angle + halfStep);
      final y2 = center.dy + internalRadius * math.sin(angle + halfStep);
      path.lineTo(x2, y2);
    }

    path.close();
    canvas.drawPath(path, paint);

    // Add glow effect
    final glowPaint = Paint()
      ..color = color.withValues(alpha: color.a * 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) =>
      progress != oldDelegate.progress;
}

/// Extension to trigger level up celebration from CelebrationService
extension LevelUpCelebration on BuildContext {
  /// Show level up celebration overlay
  void showLevelUpCelebration({required int newLevel, String? levelTitle}) {
    LevelUpOverlay.show(this, newLevel: newLevel, levelTitle: levelTitle);
  }
}
