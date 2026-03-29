/// Reusable confetti overlay widget for celebrations
/// Uses the confetti package with aquatic-themed particles
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../theme/app_theme.dart';

/// Types of confetti blast patterns
enum ConfettiBlastType {
  /// Confetti explodes in all directions from center
  explosive,

  /// Confetti falls from the top
  topDown,

  /// Confetti shoots up like a fountain
  fountain,

  /// Confetti from multiple corners
  corners,
}

/// Types of confetti particle shapes
enum ConfettiParticleShape {
  /// Simple circles
  circles,

  /// Star shapes
  stars,

  /// Fish-shaped particles (aquarium themed!)
  fish,

  /// Bubble shapes
  bubbles,
}

/// Aquatic color scheme for confetti
class ConfettiColors {
  /// Primary aquatic colors - teal, coral, white
  static const List<Color> aquatic = [
    AppColors.primary,
    AppColors.primaryLight,
    AppColors.secondary,
    AppColors.secondaryLight,
    Colors.white,
    AppColors.accent,
  ];

  /// Celebratory rainbow colors
  static const List<Color> rainbow = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    AppColors.primary,
    DanioColors.amethyst,
    DanioColors.coralAccent,
  ];

  /// Gold/achievement colors
  static const List<Color> gold = [
    DanioColors.topaz,        // E8A84A — warm gold
    AppColors.xp,             // D97706 — amber xp
    Color(0xFFFFE082),        // light gold — no exact token
    Colors.white,
    AppColors.primary,        // B45309 — deep amber
  ];

  /// Level up special colors
  static const List<Color> levelUp = [
    AppColors.secondaryDark,  // 2A3548 — deep violet
    AppColors.accentAlt,      // 8B6BAE — amethyst
    Color(0xFFA855F7),        // violet — no exact token
    DanioColors.levelUpFuchsia, // D946EF — fuchsia
    Colors.white,
    Color(0xFF22D3EE),        // cyan — no exact token
  ];
}

/// A reusable confetti overlay widget
class ConfettiOverlay extends StatefulWidget {
  /// Controller to trigger confetti (external control)
  final ConfettiController? controller;

  /// Blast type determines the pattern
  final ConfettiBlastType blastType;

  /// Particle shape
  final ConfettiParticleShape particleShape;

  /// Colors for the confetti
  final List<Color> colors;

  /// Number of particles per emission
  final int numberOfParticles;

  /// Emission frequency (0.0 to 1.0)
  final double emissionFrequency;

  /// Gravity strength (0.0 to 1.0)
  final double gravity;

  /// Whether confetti should loop
  final bool shouldLoop;

  /// Duration of the confetti burst
  final Duration duration;

  /// Child widget to overlay confetti on
  final Widget? child;

  /// Whether to auto-play on mount
  final bool autoPlay;

  const ConfettiOverlay({
    super.key,
    this.controller,
    this.blastType = ConfettiBlastType.explosive,
    this.particleShape = ConfettiParticleShape.stars,
    this.colors = ConfettiColors.aquatic,
    this.numberOfParticles = 20,
    this.emissionFrequency = 0.05,
    this.gravity = 0.2,
    this.shouldLoop = false,
    this.duration = const Duration(seconds: 3),
    this.child,
    this.autoPlay = false,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> {
  late ConfettiController _internalController;

  ConfettiController get _controller =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = ConfettiController(duration: widget.duration);

    if (widget.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.play();
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  Path _createParticlePath(Size size) {
    switch (widget.particleShape) {
      case ConfettiParticleShape.circles:
        return _drawCircle(size);
      case ConfettiParticleShape.stars:
        return _drawStar(size);
      case ConfettiParticleShape.fish:
        return _drawFish(size);
      case ConfettiParticleShape.bubbles:
        return _drawBubble(size);
    }
  }

  Path _drawCircle(Size size) {
    final path = Path();
    path.addOval(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ),
    );
    return path;
  }

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

  /// Draw a simple fish shape
  Path _drawFish(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Fish body (ellipse-ish)
    path.moveTo(w * 0.2, h * 0.5);
    path.quadraticBezierTo(w * 0.5, h * 0.1, w * 0.8, h * 0.5);
    path.quadraticBezierTo(w * 0.5, h * 0.9, w * 0.2, h * 0.5);

    // Tail
    path.moveTo(w * 0.15, h * 0.5);
    path.lineTo(0, h * 0.2);
    path.lineTo(0, h * 0.8);
    path.close();

    return path;
  }

  /// Draw a bubble shape (circle with highlight)
  Path _drawBubble(Size size) {
    final path = Path();
    path.addOval(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ),
    );
    // Add a small highlight circle
    path.addOval(
      Rect.fromCircle(
        center: Offset(size.width * 0.35, size.height * 0.35),
        radius: size.width / 6,
      ),
    );
    return path;
  }

  double _degToRad(double deg) => deg * (pi / 180.0);

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      // Purely decorative — skip confetti entirely when reduced motion is on
      return widget.child ?? const SizedBox.shrink();
    }

    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        ..._buildConfettiWidgets(),
      ],
    );
  }

  List<Widget> _buildConfettiWidgets() {
    switch (widget.blastType) {
      case ConfettiBlastType.explosive:
        return [
          Align(
            alignment: Alignment.center,
            child: _buildConfettiWidget(BlastDirectionality.explosive),
          ),
        ];

      case ConfettiBlastType.topDown:
        return [
          Align(
            alignment: Alignment.topCenter,
            child: _buildConfettiWidget(
              BlastDirectionality.directional,
              blastDirection: pi / 2, // Down
            ),
          ),
        ];

      case ConfettiBlastType.fountain:
        return [
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildConfettiWidget(
              BlastDirectionality.directional,
              blastDirection: -pi / 2, // Up
            ),
          ),
        ];

      case ConfettiBlastType.corners:
        return [
          Align(
            alignment: Alignment.topLeft,
            child: _buildConfettiWidget(
              BlastDirectionality.directional,
              blastDirection: pi / 4,
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: _buildConfettiWidget(
              BlastDirectionality.directional,
              blastDirection: 3 * pi / 4,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _buildConfettiWidget(
              BlastDirectionality.directional,
              blastDirection: pi / 2,
            ),
          ),
        ];
    }
  }

  Widget _buildConfettiWidget(
    BlastDirectionality directionality, {
    double blastDirection = pi,
  }) {
    return ConfettiWidget(
      confettiController: _controller,
      blastDirectionality: directionality,
      blastDirection: blastDirection,
      emissionFrequency: widget.emissionFrequency,
      numberOfParticles: widget.numberOfParticles,
      gravity: widget.gravity,
      shouldLoop: widget.shouldLoop,
      colors: widget.colors,
      createParticlePath: _createParticlePath,
    );
  }
}

/// Simple wrapper to show confetti on top of any screen
class ConfettiScreen extends StatelessWidget {
  final Widget child;
  final ConfettiController controller;
  final ConfettiBlastType blastType;
  final List<Color> colors;

  const ConfettiScreen({
    super.key,
    required this.child,
    required this.controller,
    this.blastType = ConfettiBlastType.corners,
    this.colors = ConfettiColors.aquatic,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        ConfettiOverlay(
          controller: controller,
          blastType: blastType,
          colors: colors,
        ),
      ],
    );
  }
}
