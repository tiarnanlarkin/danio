import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../theme/app_theme.dart';

/// A cozy isometric-style room scene for backgrounds.
/// Inspired by warm, detailed room illustrations.
class CozyRoomScene extends StatelessWidget {
  final RoomStyle style;
  final bool showAquarium;
  final bool animate;
  
  const CozyRoomScene({
    super.key,
    this.style = RoomStyle.livingRoom,
    this.showAquarium = true,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _CozyRoomPainter(
            style: style,
            showAquarium: showAquarium,
          ),
        );
      },
    );
  }
}

/// Visual style variations for the cozy room scene.
///
/// Defines color schemes and lighting for different moods/times of day.
enum RoomStyle {
  livingRoom,
  cozyNight,
  sunlit,
  minimal,
}

class _CozyRoomPainter extends CustomPainter {
  final RoomStyle style;
  final bool showAquarium;

  _CozyRoomPainter({
    required this.style,
    required this.showAquarium,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background gradient
    _drawBackground(canvas, size);
    
    // Draw room elements based on style
    switch (style) {
      case RoomStyle.livingRoom:
        _drawLivingRoom(canvas, size);
        break;
      case RoomStyle.cozyNight:
        _drawCozyNight(canvas, size);
        break;
      case RoomStyle.sunlit:
        _drawSunlit(canvas, size);
        break;
      case RoomStyle.minimal:
        _drawMinimal(canvas, size);
        break;
    }

    // Draw aquarium if enabled
    if (showAquarium) {
      _drawAquarium(canvas, size);
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    final colors = _getBackgroundColors();
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
      stops: const [0.0, 0.4, 1.0],
    );

    canvas.drawRect(
      rect,
      Paint()..shader = gradient.createShader(rect),
    );
  }

  List<Color> _getBackgroundColors() {
    switch (style) {
      case RoomStyle.livingRoom:
        return [
          const Color(0xFF5B9A8B), // Soft teal top
          const Color(0xFF4A8B7C), // Medium teal
          const Color(0xFF3D7A6C), // Deep teal bottom
        ];
      case RoomStyle.cozyNight:
        return [
          const Color(0xFF1A1A2E), // Deep night
          const Color(0xFF16213E), // Midnight blue
          const Color(0xFF0F3460), // Dark blue
        ];
      case RoomStyle.sunlit:
        return [
          const Color(0xFFFFF8E7), // Warm cream
          const Color(0xFFFFEDD5), // Soft peach
          const Color(0xFFE8D5B7), // Warm beige
        ];
      case RoomStyle.minimal:
        return [
          const Color(0xFFF5F5F5), // Light gray
          const Color(0xFFE8E8E8), // Medium gray
          const Color(0xFFD0D0D0), // Darker gray
        ];
    }
  }

  void _drawLivingRoom(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Floor boards hint (subtle)
    final floorPaint = Paint()
      ..color = AppOverlays.forestGreen08
      ..strokeWidth = 1;
    
    for (var y = h * 0.7; y < h; y += 25) {
      canvas.drawLine(
        Offset(0, y),
        Offset(w, y + 10),
        floorPaint,
      );
    }

    // Warm light glow from window area
    final windowGlow = Paint()
      ..shader = RadialGradient(
        center: Alignment.topRight,
        radius: 0.8,
        colors: [
          AppColors.whiteAlpha30,
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.85, h * 0.15),
        width: w * 0.6,
        height: h * 0.4,
      ),
      windowGlow,
    );

    // Plant silhouette on left
    _drawPlantSilhouette(canvas, Offset(w * 0.08, h * 0.5), h * 0.35);
    
    // Small plant on right
    _drawPlantSilhouette(canvas, Offset(w * 0.92, h * 0.6), h * 0.2);

    // Shelf hint at top
    _drawShelfHint(canvas, size);
  }

  void _drawCozyNight(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Window with moonlight
    final moonGlow = Paint()
      ..shader = RadialGradient(
        center: Alignment.topLeft,
        radius: 0.5,
        colors: [
          AppColors.whiteAlpha15,
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.2, h * 0.2),
        width: w * 0.5,
        height: h * 0.4,
      ),
      moonGlow,
    );

    // Warm lamp glow
    final lampGlow = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.3,
        colors: [
          AppColors.whiteAlpha25,
          AppColors.whiteAlpha10,
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.15, h * 0.4),
        width: w * 0.3,
        height: h * 0.35,
      ),
      lampGlow,
    );

    // Stars hint
    final starPaint = Paint()
      ..color = AppColors.whiteAlpha30;
    
    final random = math.Random(42);
    for (var i = 0; i < 8; i++) {
      final x = w * (0.1 + random.nextDouble() * 0.3);
      final y = h * (0.05 + random.nextDouble() * 0.25);
      canvas.drawCircle(Offset(x, y), 1.5, starPaint);
    }
  }

  void _drawSunlit(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sun rays
    final rayPaint = Paint()
      ..color = AppOverlays.goldenYellow08;
    
    for (var i = 0; i < 5; i++) {
      final startX = w * (0.6 + i * 0.08);
      final path = Path()
        ..moveTo(startX, 0)
        ..lineTo(startX - w * 0.15, h)
        ..lineTo(startX + w * 0.05, h)
        ..close();
      canvas.drawPath(path, rayPaint);
    }

    // Window frame hint
    final framePaint = Paint()
      ..color = AppColors.woodBrownAlpha20
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.65, h * 0.05, w * 0.3, h * 0.35),
        const Radius.circular(4),
      ),
      framePaint,
    );

    // Plants
    _drawPlantSilhouette(canvas, Offset(w * 0.1, h * 0.55), h * 0.3);
  }

  void _drawMinimal(Canvas canvas, Size size) {
    // Just subtle texture
    final w = size.width;
    final h = size.height;
    
    final texturePaint = Paint()
      ..color = const Color(0x05000000);
    
    for (var y = 0.0; y < h; y += 50) {
      canvas.drawLine(
        Offset(0, y),
        Offset(w, y),
        texturePaint,
      );
    }
  }

  void _drawPlantSilhouette(Canvas canvas, Offset position, double height) {
    final paint = Paint()
      ..color = AppColors.whiteAlpha15;
    
    // Simple leaf shapes
    for (var i = 0; i < 5; i++) {
      final angle = -0.3 + i * 0.15;
      final leafHeight = height * (0.6 + i * 0.1);
      
      final path = Path()
        ..moveTo(position.dx, position.dy)
        ..quadraticBezierTo(
          position.dx + math.cos(angle) * leafHeight * 0.4,
          position.dy - leafHeight * 0.6,
          position.dx + math.cos(angle) * leafHeight * 0.2,
          position.dy - leafHeight,
        )
        ..quadraticBezierTo(
          position.dx + math.cos(angle) * leafHeight * 0.3,
          position.dy - leafHeight * 0.5,
          position.dx,
          position.dy,
        );
      
      canvas.drawPath(path, paint);
    }
  }

  void _drawShelfHint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    final shelfPaint = Paint()
      ..color = AppOverlays.darkBrown10
      ..strokeWidth = 2;
    
    // Simple shelf line
    canvas.drawLine(
      Offset(w * 0.3, h * 0.15),
      Offset(w * 0.7, h * 0.15),
      shelfPaint,
    );
  }

  void _drawAquarium(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    // Aquarium glow (the centerpiece!)
    final aquariumGlow = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.4,
        colors: [
          AppOverlays.tealGreen20,
          AppColors.primaryAlpha10,
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.45),
        width: w * 0.5,
        height: h * 0.35,
      ),
      aquariumGlow,
    );

    // Subtle water reflection lines
    final waterPaint = Paint()
      ..color = AppOverlays.skyBlue05
      ..strokeWidth = 1;
    
    for (var i = 0; i < 3; i++) {
      final y = h * (0.38 + i * 0.05);
      canvas.drawLine(
        Offset(w * 0.35, y),
        Offset(w * 0.65, y + 5),
        waterPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CozyRoomPainter oldDelegate) {
    return style != oldDelegate.style || showAquarium != oldDelegate.showAquarium;
  }
}

/// Ambient floating particles for room atmosphere
class RoomParticles extends StatefulWidget {
  final Color particleColor;
  final int particleCount;
  final double maxSize;
  
  const RoomParticles({
    super.key,
    this.particleColor = Colors.white,
    this.particleCount = 15,
    this.maxSize = 4,
  });

  @override
  State<RoomParticles> createState() => _RoomParticlesState();
}

class _RoomParticlesState extends State<RoomParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    final random = math.Random();
    _particles = List.generate(
      widget.particleCount,
      (i) => _Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 1 + random.nextDouble() * widget.maxSize,
        speed: 0.005 + random.nextDouble() * 0.01,
        opacity: 0.1 + random.nextDouble() * 0.3,
      ),
    );
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
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlesPainter(
            particles: _particles,
            progress: _controller.value,
            color: widget.particleColor,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  double x, y, size, speed, opacity;
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;

  _ParticlesPainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final x = size.width * p.x;
      final y = size.height * ((p.y + progress * p.speed * 50) % 1.0);
      
      final paint = Paint()
        ..color = color.withAlpha((p.opacity * (0.5 + 0.5 * math.sin(progress * math.pi * 2 + p.x * 10 * 255).round())));
      
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) => true;
}
