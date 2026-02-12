import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Celebration intensity levels
enum CelebrationLevel {
  /// Subtle feedback (haptic only or small visual)
  subtle,
  
  /// Medium celebration (small confetti burst, glow)
  medium,
  
  /// Large celebration (full confetti, sound)
  large,
  
  /// Epic celebration (full screen effects, everything)
  epic,
}

/// Service for triggering celebrations across the app
class CelebrationService {
  static final CelebrationService _instance = CelebrationService._internal();
  factory CelebrationService() => _instance;
  CelebrationService._internal();

  /// Global key for overlay
  final GlobalKey<OverlayState>? overlayKey = null;

  /// Trigger a celebration
  void celebrate(BuildContext context, CelebrationLevel level, {
    Offset? origin,
    String? message,
  }) {
    switch (level) {
      case CelebrationLevel.subtle:
        HapticFeedback.lightImpact();
        break;
        
      case CelebrationLevel.medium:
        HapticFeedback.mediumImpact();
        _showConfetti(context, intensity: 0.5, origin: origin);
        break;
        
      case CelebrationLevel.large:
        HapticFeedback.heavyImpact();
        _showConfetti(context, intensity: 1.0, origin: origin);
        break;
        
      case CelebrationLevel.epic:
        HapticFeedback.heavyImpact();
        _showFullScreenCelebration(context, message: message);
        break;
    }
  }

  /// Show confetti overlay
  void _showConfetti(BuildContext context, {
    double intensity = 1.0,
    Offset? origin,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => ConfettiOverlay(
        origin: origin ?? Offset(
          MediaQuery.of(context).size.width / 2,
          MediaQuery.of(context).size.height / 2,
        ),
        intensity: intensity,
        onComplete: () => entry.remove(),
      ),
    );
    
    overlay.insert(entry);
  }

  /// Show full screen celebration
  void _showFullScreenCelebration(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => _EpicCelebrationDialog(message: message),
    );
  }
}

/// Confetti overlay widget
class ConfettiOverlay extends StatefulWidget {
  final Offset origin;
  final double intensity;
  final VoidCallback? onComplete;
  final Duration duration;

  const ConfettiOverlay({
    super.key,
    required this.origin,
    this.intensity = 1.0,
    this.onComplete,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ConfettiParticle> _particles;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    // Generate particles
    final count = (50 * widget.intensity).toInt();
    _particles = List.generate(count, (_) => _ConfettiParticle(
      random: _random,
      origin: widget.origin,
    ));
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }
}

class _ConfettiParticle {
  final double angle;
  final double velocity;
  final double rotationSpeed;
  final Color color;
  final double size;
  final Offset origin;
  final double delay;

  _ConfettiParticle({
    required math.Random random,
    required this.origin,
  }) : angle = (random.nextDouble() * 2 - 1) * math.pi * 0.8 - math.pi / 2,
       velocity = 300 + random.nextDouble() * 400,
       rotationSpeed = (random.nextDouble() - 0.5) * 10,
       color = _confettiColors[random.nextInt(_confettiColors.length)],
       size = 8 + random.nextDouble() * 8,
       delay = random.nextDouble() * 0.2;

  static const _confettiColors = [
    Color(0xFFFF6B6B), // Red
    Color(0xFF4ECDC4), // Teal
    Color(0xFFFFE66D), // Yellow
    Color(0xFF95E1D3), // Mint
    Color(0xFFF38181), // Coral
    Color(0xFFAA96DA), // Purple
    Color(0xFF74B9FF), // Blue
    Color(0xFFFDA7DF), // Pink
  ];
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final effectiveProgress = ((progress - particle.delay) / (1 - particle.delay))
          .clamp(0.0, 1.0);
      if (effectiveProgress <= 0) continue;

      final gravity = 500 * effectiveProgress * effectiveProgress;
      final x = particle.origin.dx + 
          math.cos(particle.angle) * particle.velocity * effectiveProgress;
      final y = particle.origin.dy + 
          math.sin(particle.angle) * particle.velocity * effectiveProgress +
          gravity;

      final opacity = (1 - effectiveProgress).clamp(0.0, 1.0);
      final rotation = particle.rotationSpeed * effectiveProgress * math.pi;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: particle.size,
        height: particle.size * 0.6,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(2)),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}

/// Epic celebration dialog
class _EpicCelebrationDialog extends StatefulWidget {
  final String? message;

  const _EpicCelebrationDialog({this.message});

  @override
  State<_EpicCelebrationDialog> createState() => _EpicCelebrationDialogState();
}

class _EpicCelebrationDialogState extends State<_EpicCelebrationDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  final _random = math.Random();
  late List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: AppDurations.long2,
      vsync: this,
    );
    
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: AppCurves.elastic),
    );
    
    // Generate more particles for epic celebration
    _particles = List.generate(100, (_) => _ConfettiParticle(
      random: _random,
      origin: Offset.zero, // Will be set in build
    ));
    
    _scaleController.forward();
    _confettiController.forward();
    
    // Auto-dismiss after animation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        // Confetti background
        AnimatedBuilder(
          animation: _confettiController,
          builder: (context, _) {
            // Update particle origins to screen center
            for (var i = 0; i < _particles.length; i++) {
              if (_particles[i].origin == Offset.zero) {
                _particles[i] = _ConfettiParticle(
                  random: _random,
                  origin: Offset(size.width / 2, size.height / 2),
                );
              }
            }
            return CustomPaint(
              painter: _ConfettiPainter(
                particles: _particles,
                progress: _confettiController.value,
              ),
              size: size,
            );
          },
        ),
        
        // Center content
        Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.largeRadius,
                boxShadow: AppShadows.elevated,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.celebration,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    widget.message ?? 'Congratulations!',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    '🎉',
                    style: TextStyle(fontSize: 48),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// XP gain animation widget
class XpGainAnimation extends StatefulWidget {
  final int amount;
  final Offset startPosition;
  final VoidCallback? onComplete;

  const XpGainAnimation({
    super.key,
    required this.amount,
    required this.startPosition,
    this.onComplete,
  });

  @override
  State<XpGainAnimation> createState() => _XpGainAnimationState();
}

class _XpGainAnimationState extends State<XpGainAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.celebration,
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0, end: -60).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.8, curve: Curves.easeOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.2), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
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
    return Positioned(
      left: widget.startPosition.dx,
      top: widget.startPosition.dy,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppRadius.pillRadius,
            boxShadow: AppShadows.glow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: Colors.white, size: 16),
              SizedBox(width: AppSpacing.xs),
              Text(
                '+${widget.amount} XP',
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper to show XP gain in overlay
void showXpGain(BuildContext context, int amount, {Offset? position}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  
  final effectivePosition = position ?? Offset(
    MediaQuery.of(context).size.width / 2 - 40,
    MediaQuery.of(context).size.height / 2,
  );
  
  entry = OverlayEntry(
    builder: (context) => XpGainAnimation(
      amount: amount,
      startPosition: effectivePosition,
      onComplete: () => entry.remove(),
    ),
  );
  
  overlay.insert(entry);
  HapticFeedback.lightImpact();
}
