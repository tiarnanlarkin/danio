/// Animated flame widget for streak display
/// Features multiple flame tongues, dynamic intensity, and celebration effects
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Custom painted animated flame effect
class AnimatedFlame extends StatefulWidget {
  /// Size of the flame widget
  final double size;

  /// Streak count - affects flame intensity (bigger streak = bigger flame)
  final int streakCount;

  /// Whether to show celebration burst (when streak increments)
  final bool showCelebration;

  /// Callback when celebration animation completes
  final VoidCallback? onCelebrationComplete;

  const AnimatedFlame({
    super.key,
    this.size = 48,
    this.streakCount = 1,
    this.showCelebration = false,
    this.onCelebrationComplete,
  });

  @override
  State<AnimatedFlame> createState() => _AnimatedFlameState();
}

class _AnimatedFlameState extends State<AnimatedFlame>
    with TickerProviderStateMixin {
  late AnimationController _flameController;
  late AnimationController _glowController;
  late AnimationController _celebrationController;

  // Multiple flame tongue animations with different phases
  late List<Animation<double>> _tongueAnimations;
  late Animation<double> _glowAnimation;
  late Animation<double> _celebrationScale;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Main flame flicker controller - continuous
    _flameController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();

    // Glow pulse controller
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Celebration burst controller
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Create staggered tongue animations (5 flames with different phases)
    _tongueAnimations = List.generate(5, (index) {
      final phase = index * 0.15; // Stagger by 15%
      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.85, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.85)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 50,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _flameController,
          curve: Interval(phase, 1.0, curve: Curves.linear),
        ),
      );
    });

    _glowAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _celebrationScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_celebrationController);

    _celebrationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCelebrationComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedFlame oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger celebration if streak increased
    if (widget.showCelebration && !oldWidget.showCelebration) {
      _celebrationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _flameController.dispose();
    _glowController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  /// Calculate flame intensity based on streak count
  double get _flameIntensity {
    // Intensity grows logarithmically with streak
    // Min: 0.6 (streak 1), Max: 1.2 (streak 30+)
    final normalizedStreak = (widget.streakCount - 1).clamp(0, 30) / 30.0;
    return 0.6 + (normalizedStreak * 0.6);
  }

  /// Get flame colors based on intensity
  List<Color> get _flameColors {
    final intensity = _flameIntensity;

    if (intensity > 1.0) {
      // Hot flame for long streaks (more white/yellow core)
      return [
        const Color(0xFFFFF176), // Bright yellow
        const Color(0xFFFF9800), // Orange
        const Color(0xFFFF5722), // Deep orange
        const Color(0xFFE53935), // Red
      ];
    } else if (intensity > 0.8) {
      // Medium flame
      return [
        const Color(0xFFFFCA28), // Amber
        const Color(0xFFFF9800), // Orange
        const Color(0xFFFF5722), // Deep orange
        const Color(0xFFD84315), // Deep red-orange
      ];
    } else {
      // Small flame for new streaks
      return [
        const Color(0xFFFFB74D), // Light orange
        const Color(0xFFFF8A65), // Soft orange
        const Color(0xFFFF7043), // Orange
        const Color(0xFFE64A19), // Deep orange
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _flameController,
        _glowController,
        _celebrationController,
      ]),
      builder: (context, child) {
        final scale =
            widget.showCelebration ? _celebrationScale.value : 1.0;

        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow
                _buildGlow(),

                // Main flame
                CustomPaint(
                  size: Size(widget.size * 0.7, widget.size * 0.85),
                  painter: FlamePainter(
                    tongueValues: _tongueAnimations.map((a) => a.value).toList(),
                    colors: _flameColors,
                    intensity: _flameIntensity,
                  ),
                ),

                // Celebration particles
                if (widget.showCelebration && _celebrationController.isAnimating)
                  _buildCelebrationParticles(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlow() {
    final glowSize = widget.size * (1.2 + (_flameIntensity * 0.3));

    return Container(
      width: glowSize,
      height: glowSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            _flameColors[1].withOpacity(_glowAnimation.value * _flameIntensity),
            _flameColors[2].withOpacity(_glowAnimation.value * 0.3),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildCelebrationParticles() {
    return Stack(
      children: List.generate(8, (index) {
        final angle = (index * 45.0) * (math.pi / 180);
        final progress = _celebrationController.value;
        final distance = widget.size * 0.6 * progress;

        return Transform.translate(
          offset: Offset(
            math.cos(angle) * distance,
            math.sin(angle) * distance,
          ),
          child: Opacity(
            opacity: (1.0 - progress).clamp(0.0, 1.0),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _flameColors[index % _flameColors.length],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _flameColors[1].withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Custom painter that draws the animated flame
class FlamePainter extends CustomPainter {
  final List<double> tongueValues;
  final List<Color> colors;
  final double intensity;

  FlamePainter({
    required this.tongueValues,
    required this.colors,
    this.intensity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final baseY = size.height;
    final flameHeight = size.height * intensity;

    // Draw multiple flame tongues from back to front
    for (int i = tongueValues.length - 1; i >= 0; i--) {
      _drawFlameTongue(
        canvas,
        centerX,
        baseY,
        flameHeight,
        tongueValues[i],
        i,
        tongueValues.length,
      );
    }
  }

  void _drawFlameTongue(
    Canvas canvas,
    double centerX,
    double baseY,
    double height,
    double animValue,
    int index,
    int total,
  ) {
    // Calculate tongue position and size
    final offset = (index - total ~/ 2) * (height * 0.08);
    final tongueWidth = height * (0.25 + (animValue - 0.85) * 0.3);
    final tongueHeight = height * (0.7 + (animValue - 0.85) * 0.8);

    // Create flame path using bezier curves
    final path = Path();
    final tongueX = centerX + offset;

    // Start at base
    path.moveTo(tongueX - tongueWidth / 2, baseY);

    // Left edge curve
    path.quadraticBezierTo(
      tongueX - tongueWidth * 0.6,
      baseY - tongueHeight * 0.5,
      tongueX - tongueWidth * 0.1,
      baseY - tongueHeight * 0.85,
    );

    // Top point (flame tip)
    path.quadraticBezierTo(
      tongueX,
      baseY - tongueHeight,
      tongueX + tongueWidth * 0.1,
      baseY - tongueHeight * 0.85,
    );

    // Right edge curve
    path.quadraticBezierTo(
      tongueX + tongueWidth * 0.6,
      baseY - tongueHeight * 0.5,
      tongueX + tongueWidth / 2,
      baseY,
    );

    path.close();

    // Create gradient for this tongue
    final gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        colors[colors.length - 1].withOpacity(0.9 - (index * 0.1)),
        colors[(index * 2) % colors.length].withOpacity(0.85 - (index * 0.08)),
        colors[0].withOpacity(0.7 - (index * 0.1)),
      ],
      stops: const [0.0, 0.4, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, baseY - tongueHeight, tongueWidth * 2, tongueHeight),
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(FlamePainter oldDelegate) {
    return tongueValues != oldDelegate.tongueValues ||
        intensity != oldDelegate.intensity;
  }
}

/// Compact wrapper that combines the flame with optional text
class StreakFlameDisplay extends StatelessWidget {
  final int streakCount;
  final double size;
  final bool showCount;
  final bool showCelebration;
  final VoidCallback? onCelebrationComplete;

  const StreakFlameDisplay({
    super.key,
    required this.streakCount,
    this.size = 48,
    this.showCount = true,
    this.showCelebration = false,
    this.onCelebrationComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedFlame(
          size: size,
          streakCount: streakCount,
          showCelebration: showCelebration,
          onCelebrationComplete: onCelebrationComplete,
        ),
        if (showCount && streakCount > 0) ...[
          const SizedBox(height: 4),
          Text(
            '$streakCount',
            style: TextStyle(
              fontSize: size * 0.35,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFF6B35),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(
                duration: 2.seconds,
                color: const Color(0x4DFFCA28),  // 30% amber
              ),
        ],
      ],
    );
  }
}
