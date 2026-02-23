import '../../theme/app_theme.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A sparkle/glitter effect overlay that adds magical shine to widgets.
/// 
/// Perfect for:
/// - Achievement unlocks
/// - Rare items/fish
/// - Premium features
/// - Celebration moments
/// 
/// Example:
/// ```dart
/// SparkleEffect(
///   child: AchievementBadge(),
///   isActive: isNewlyUnlocked,
/// )
/// ```
class SparkleEffect extends StatefulWidget {
  /// The widget to add sparkles to
  final Widget child;
  
  /// Whether the sparkle effect is active
  final bool isActive;
  
  /// Number of sparkle particles
  final int particleCount;
  
  /// Color of the sparkles (default: gold)
  final Color sparkleColor;
  
  /// Size range of sparkles
  final double minSize;
  final double maxSize;
  
  /// Duration of one sparkle cycle
  final Duration cycleDuration;

  const SparkleEffect({
    super.key,
    required this.child,
    this.isActive = true,
    this.particleCount = 8,
    this.sparkleColor = const Color(0xFFFFD700),
    this.minSize = 4,
    this.maxSize = 8,
    this.cycleDuration = const Duration(milliseconds: 2000),
  });

  @override
  State<SparkleEffect> createState() => _SparkleEffectState();
}

class _SparkleEffectState extends State<SparkleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_SparkleParticle> _particles;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.cycleDuration,
      vsync: this,
    );
    
    _generateParticles();
    
    if (widget.isActive) {
      _controller.repeat();
    }
  }

  void _generateParticles() {
    _particles = List.generate(widget.particleCount, (i) {
      return _SparkleParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: widget.minSize + _random.nextDouble() * (widget.maxSize - widget.minSize),
        delay: _random.nextDouble(),
        duration: 0.3 + _random.nextDouble() * 0.4,
      );
    });
  }

  @override
  void didUpdateWidget(SparkleEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isActive)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _SparklePainter(
                      particles: _particles,
                      progress: _controller.value,
                      color: widget.sparkleColor,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _SparkleParticle {
  final double x;
  final double y;
  final double size;
  final double delay;
  final double duration;

  _SparkleParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.delay,
    required this.duration,
  });
}

class _SparklePainter extends CustomPainter {
  final List<_SparkleParticle> particles;
  final double progress;
  final Color color;

  _SparklePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Calculate particle's local progress
      final localProgress = (progress - particle.delay) % 1.0;
      
      // Only draw if within the particle's active window
      if (localProgress < particle.duration) {
        final normalizedProgress = localProgress / particle.duration;
        
        // Fade in then fade out
        final opacity = normalizedProgress < 0.5
            ? normalizedProgress * 2
            : (1 - normalizedProgress) * 2;
        
        // Scale up then down
        final scale = normalizedProgress < 0.5
            ? 0.5 + normalizedProgress
            : 1.5 - normalizedProgress;
        
        final x = particle.x * size.width;
        final y = particle.y * size.height;
        final sparkleSize = particle.size * scale;
        
        _drawSparkle(canvas, Offset(x, y), sparkleSize, color.withOpacity(opacity.clamp(0.0, 1.0)));
      }
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Draw a 4-pointed star
    final path = Path();
    
    // Vertical line
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx - size * 0.2, center.dy);
    path.lineTo(center.dx, center.dy + size);
    path.lineTo(center.dx + size * 0.2, center.dy);
    path.close();
    
    // Horizontal line
    path.moveTo(center.dx - size, center.dy);
    path.lineTo(center.dx, center.dy - size * 0.2);
    path.lineTo(center.dx + size, center.dy);
    path.lineTo(center.dx, center.dy + size * 0.2);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Add glow
    final glowPaint = Paint()
      ..color = color.withOpacity(color.opacity * 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center, size * 0.8, glowPaint);
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// A shimmer effect that creates a sweeping shine across a widget.
/// 
/// Great for:
/// - Loading placeholders
/// - Premium/locked content hints
/// - Call-to-action highlights
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Color shimmerColor;
  final Duration duration;
  final double angle;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.isActive = true,
    this.shimmerColor = Colors.white,
    this.duration = AppDurations.celebration,
    this.angle = 0.4, // radians
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final progress = _controller.value;
            final startX = bounds.width * (progress * 2 - 0.5);
            
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.transparent,
                widget.shimmerColor.withOpacity(0.3),
                widget.shimmerColor.withOpacity(0.5),
                widget.shimmerColor.withOpacity(0.3),
                Colors.transparent,
              ],
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
              transform: _SlideGradientTransform(startX / bounds.width),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlideGradientTransform extends GradientTransform {
  final double offset;

  const _SlideGradientTransform(this.offset);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * offset, 0, 0);
  }
}
