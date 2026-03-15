/// Water Change Celebration
/// Shows cascading water droplet emojis and a congratulation message
/// when a water change is logged.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Overlay that shows cascading water droplet emojis when a water change is logged.
///
/// Usage:
/// ```dart
/// WaterChangeCelebration.show(context);
/// ```
class WaterChangeCelebration extends StatefulWidget {
  final VoidCallback? onComplete;

  const WaterChangeCelebration({super.key, this.onComplete});

  /// Show the celebration as a full-screen overlay
  static void show(BuildContext context) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => WaterChangeCelebration(
        onComplete: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  @override
  State<WaterChangeCelebration> createState() =>
      _WaterChangeCelebrationState();
}

class _WaterChangeCelebrationState extends State<WaterChangeCelebration>
    with TickerProviderStateMixin {
  late AnimationController _dropletController;
  late AnimationController _messageController;
  late Animation<double> _messageFade;
  late Animation<double> _messageScale;
  final List<_Droplet> _droplets = [];

  @override
  void initState() {
    super.initState();
    final random = math.Random();

    // Create 25 droplets with random positions and speeds
    for (int i = 0; i < 25; i++) {
      _droplets.add(_Droplet(
        x: random.nextDouble(),
        startDelay: random.nextDouble() * 0.4,
        speed: 0.6 + random.nextDouble() * 0.8,
        wobbleOffset: random.nextDouble() * math.pi * 2,
        size: 20.0 + random.nextDouble() * 16.0,
      ));
    }

    // Droplet cascade: 3 seconds
    _dropletController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _dropletController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    // Message fade in/out
    _messageController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _messageFade = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_messageController);
    _messageScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.05), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(
      parent: _messageController,
      curve: Curves.easeOut,
    ));

    _dropletController.forward();
    _messageController.forward();
  }

  @override
  void dispose() {
    _dropletController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      // Show static celebration message without animation
      return IgnorePointer(
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor.withAlpha(230),
                borderRadius: AppRadius.largeRadius,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('\u{1F4A7}', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Fresh water!',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Your fish are happy \u{1F420}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Droplet cascade
            AnimatedBuilder(
              animation: _dropletController,
              builder: (context, _) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _DropletPainter(
                    droplets: _droplets,
                    progress: _dropletController.value,
                  ),
                );
              },
            ),
            // Center message
            Center(
              child: AnimatedBuilder(
                animation: _messageController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _messageFade.value,
                    child: Transform.scale(
                      scale: _messageScale.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withAlpha(230),
                    borderRadius: AppRadius.largeRadius,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withAlpha(40),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '\u{1F4A7}',
                        style: TextStyle(fontSize: 40),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Fresh water!',
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Your fish are happy \u{1F420}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Droplet {
  final double x;
  final double startDelay;
  final double speed;
  final double wobbleOffset;
  final double size;

  _Droplet({
    required this.x,
    required this.startDelay,
    required this.speed,
    required this.wobbleOffset,
    required this.size,
  });
}

class _DropletPainter extends CustomPainter {
  final List<_Droplet> droplets;
  final double progress;

  _DropletPainter({required this.droplets, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final droplet in droplets) {
      final adjustedProgress =
          ((progress - droplet.startDelay) / (1.0 - droplet.startDelay))
              .clamp(0.0, 1.0);
      if (adjustedProgress <= 0) continue;

      final x = droplet.x * size.width +
          math.sin(adjustedProgress * math.pi * 3 + droplet.wobbleOffset) * 15;
      final y = -droplet.size + adjustedProgress * (size.height + droplet.size * 2) * droplet.speed;
      final opacity = adjustedProgress < 0.1
          ? adjustedProgress / 0.1
          : adjustedProgress > 0.8
              ? (1.0 - adjustedProgress) / 0.2
              : 1.0;

      if (y > size.height || opacity <= 0) continue;

      textPainter.text = TextSpan(
        text: '\u{1F4A7}',
        style: TextStyle(
          fontSize: droplet.size,
          color: Colors.white.withAlpha((opacity * 255).round()),
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - droplet.size / 2, y));
    }
  }

  @override
  bool shouldRepaint(_DropletPainter old) => progress != old.progress;
}
