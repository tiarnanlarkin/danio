import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../theme/app_theme.dart';

/// Room types for the house navigation system
enum RoomType {
  livingRoom,
  study,
  workshop,
  shopStreet,
  trophyRoom,
  friends,
}

/// Theme-aware room background colors
class RoomBackgroundColors {
  // Living Room - Cozy home with warm greens and cream
  static const livingRoomGradient1 = Color(0xFF5B9A8B); // Soft teal
  static const livingRoomGradient2 = Color(0xFF4A8B7C); // Medium teal
  static const livingRoomGradient3 = Color(0xFF3D7A6C); // Deep teal
  static const livingRoomAccent = Color(0xFFFFF8E7); // Cream
  static const livingRoomPlant = Color(0xFF4CAF50); // Plant green

  // Study - Library/learning with deep greens and wood tones
  static const studyGradient1 = Color(0xFF2D3A4F); // Deep blue-gray
  static const studyGradient2 = Color(0xFF1F2937); // Darker blue
  static const studyGradient3 = Color(0xFF1A202C); // Deep navy
  static const studyWood = Color(0xFF5D4E37); // Wood brown
  static const studyGold = Color(0xFFD4A574); // Warm gold

  // Workshop - Industrial with concrete grey and orange accents
  static const workshopGradient1 = Color(0xFF5D4E37); // Warm brown
  static const workshopGradient2 = Color(0xFF4A3F2E); // Darker brown
  static const workshopGradient3 = Color(0xFF3D3425); // Deep brown
  static const workshopOrange = Color(0xFFE07C3E); // Orange accent
  static const workshopMetal = Color(0xFF6B7280); // Steel gray

  // Shop Street - Outdoor market with sky blue and sunny feel
  static const shopGradient1 = Color(0xFF4A7C59); // Forest green
  static const shopGradient2 = Color(0xFF3D6B4A); // Darker green
  static const shopGradient3 = Color(0xFF2F5A3B); // Deep green
  static const shopSky = Color(0xFF87CEEB); // Sky blue
  static const shopSunny = Color(0xFFF0C040); // Sunny yellow

  // Trophy Room - Achievement hall with dark purple and gold
  static const trophyGradient1 = Color(0xFF3D2B5A); // Deep purple
  static const trophyGradient2 = Color(0xFF2D1F47); // Darker purple
  static const trophyGradient3 = Color(0xFF1F1433); // Near black purple
  static const trophyGold = Color(0xFFFFD700); // Gold
  static const trophySpotlight = Color(0xFFFFE57F); // Light gold

  // Friends - Social/bright with warm yellows
  static const friendsGradient1 = Color(0xFFF5D76E); // Warm yellow
  static const friendsGradient2 = Color(0xFFE8C547); // Medium yellow
  static const friendsGradient3 = Color(0xFFD4A520); // Deep yellow
  static const friendsWindow = Color(0xFFFFF9E6); // Window light
  static const friendsCozy = Color(0xFFFFE4B5); // Moccasin
}

/// Universal room background widget that renders themed backgrounds
/// with subtle ambient animations for each room type.
class RoomBackground extends StatelessWidget {
  final RoomType roomType;
  final Widget? child;

  const RoomBackground({
    super.key,
    required this.roomType,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient background
        Positioned.fill(child: _buildGradient()),
        
        // Decorative elements specific to room
        Positioned.fill(child: _buildDecorativeElements()),
        
        // Ambient animated particles
        Positioned.fill(child: _buildAmbientEffects()),
        
        // Child content
        if (child != null) Positioned.fill(child: child!),
      ],
    );
  }

  Widget _buildGradient() {
    final colors = _getGradientColors();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
    );
  }

  List<Color> _getGradientColors() {
    switch (roomType) {
      case RoomType.livingRoom:
        return [
          RoomBackgroundColors.livingRoomGradient1,
          RoomBackgroundColors.livingRoomGradient2,
          RoomBackgroundColors.livingRoomGradient3,
        ];
      case RoomType.study:
        return [
          RoomBackgroundColors.studyGradient1,
          RoomBackgroundColors.studyGradient2,
          RoomBackgroundColors.studyGradient3,
        ];
      case RoomType.workshop:
        return [
          RoomBackgroundColors.workshopGradient1,
          RoomBackgroundColors.workshopGradient2,
          RoomBackgroundColors.workshopGradient3,
        ];
      case RoomType.shopStreet:
        return [
          RoomBackgroundColors.shopGradient1,
          RoomBackgroundColors.shopGradient2,
          RoomBackgroundColors.shopGradient3,
        ];
      case RoomType.trophyRoom:
        return [
          RoomBackgroundColors.trophyGradient1,
          RoomBackgroundColors.trophyGradient2,
          RoomBackgroundColors.trophyGradient3,
        ];
      case RoomType.friends:
        return [
          RoomBackgroundColors.friendsGradient1,
          RoomBackgroundColors.friendsGradient2,
          RoomBackgroundColors.friendsGradient3,
        ];
    }
  }

  Widget _buildDecorativeElements() {
    switch (roomType) {
      case RoomType.livingRoom:
        return const _LivingRoomDecorations();
      case RoomType.study:
        return const _StudyDecorations();
      case RoomType.workshop:
        return const _WorkshopDecorations();
      case RoomType.shopStreet:
        return const _ShopStreetDecorations();
      case RoomType.trophyRoom:
        return const _TrophyRoomDecorations();
      case RoomType.friends:
        return const _FriendsDecorations();
    }
  }

  Widget _buildAmbientEffects() {
    // Disabled repeating animations - they cause ANR on some devices
    // TODO: Re-enable with optimized non-repeating versions
    return const SizedBox.shrink();
  }
}

// ============================================================================
// LIVING ROOM DECORATIONS
// ============================================================================

class _LivingRoomDecorations extends StatelessWidget {
  const _LivingRoomDecorations();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LivingRoomPainter(),
      size: Size.infinite,
    );
  }
}

class _LivingRoomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Subtle wall texture pattern (vertical lines)
    final wallPaint = Paint()
      ..color = AppOverlays.white5
      ..strokeWidth = 1;

    for (var x = 0.0; x < w; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), wallPaint);
    }

    // Plant shadow on left side
    final shadowPaint = Paint()
      ..color = RoomBackgroundColors.livingRoomPlant.withOpacity(0.08);

    final plantShadow = Path()
      ..moveTo(0, h * 0.4)
      ..quadraticBezierTo(w * 0.15, h * 0.35, w * 0.12, h * 0.55)
      ..quadraticBezierTo(w * 0.18, h * 0.65, w * 0.08, h * 0.75)
      ..quadraticBezierTo(w * 0.05, h * 0.85, 0, h * 0.9)
      ..close();
    canvas.drawPath(plantShadow, shadowPaint);

    // Second plant shadow on right
    final plantShadow2 = Path()
      ..moveTo(w, h * 0.5)
      ..quadraticBezierTo(w * 0.88, h * 0.48, w * 0.9, h * 0.65)
      ..quadraticBezierTo(w * 0.85, h * 0.75, w * 0.92, h * 0.85)
      ..lineTo(w, h * 0.88)
      ..close();
    canvas.drawPath(plantShadow2, shadowPaint);

    // Soft cream accent blob (cozy warm spot)
    final creamPaint = Paint()
      ..color = RoomBackgroundColors.livingRoomAccent.withOpacity(0.06);
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.3),
        width: w * 0.6,
        height: h * 0.3,
      ),
      creamPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// STUDY DECORATIONS
// ============================================================================

class _StudyDecorations extends StatelessWidget {
  const _StudyDecorations();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StudyPainter(),
      size: Size.infinite,
    );
  }
}

class _StudyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Bookshelf silhouette on left
    final shelfPaint = Paint()
      ..color = RoomBackgroundColors.studyWood.withOpacity(0.15);

    // Tall bookshelf shape
    final shelf = Path()
      ..moveTo(0, h * 0.1)
      ..lineTo(w * 0.25, h * 0.1)
      ..lineTo(w * 0.25, h * 0.85)
      ..lineTo(0, h * 0.85)
      ..close();
    canvas.drawPath(shelf, shelfPaint);

    // Shelf dividers
    final dividerPaint = Paint()
      ..color = RoomBackgroundColors.studyWood.withOpacity(0.1)
      ..strokeWidth = 2;

    for (var y = h * 0.2; y < h * 0.85; y += h * 0.15) {
      canvas.drawLine(Offset(0, y), Offset(w * 0.25, y), dividerPaint);
    }

    // Book shapes on shelves
    final bookPaint = Paint()..style = PaintingStyle.fill;
    final bookColors = [
      const Color(0xFF8B3A3A).withOpacity(0.12), // Red
      const Color(0xFF3A5A8B).withOpacity(0.12), // Blue
      const Color(0xFF3A6B4A).withOpacity(0.12), // Green
      RoomBackgroundColors.studyGold.withOpacity(0.12), // Gold
    ];

    var bookX = w * 0.02;
    var colorIndex = 0;
    for (var y = h * 0.22; y < h * 0.8; y += h * 0.15) {
      bookX = w * 0.02;
      while (bookX < w * 0.22) {
        final bookWidth = w * 0.02 + (colorIndex % 3) * w * 0.01;
        bookPaint.color = bookColors[colorIndex % bookColors.length];
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(bookX, y, bookWidth, h * 0.12),
            const Radius.circular(1),
          ),
          bookPaint,
        );
        bookX += bookWidth + w * 0.005;
        colorIndex++;
      }
    }

    // Warm lighting effect from top right (desk lamp glow)
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topRight,
        radius: 0.8,
        colors: [
          RoomBackgroundColors.studyGold.withOpacity(0.12),
          RoomBackgroundColors.studyGold.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// WORKSHOP DECORATIONS
// ============================================================================

class _WorkshopDecorations extends StatelessWidget {
  const _WorkshopDecorations();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WorkshopPainter(),
      size: Size.infinite,
    );
  }
}

class _WorkshopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Concrete texture - subtle grid pattern
    final gridPaint = Paint()
      ..color = AppOverlays.white5
      ..strokeWidth = 0.5;

    for (var x = 0.0; x < w; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (var y = 0.0; y < h; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Tool silhouettes on wall (pegboard feel)
    final toolPaint = Paint()
      ..color = RoomBackgroundColors.workshopMetal.withOpacity(0.08);

    // Wrench silhouette
    canvas.drawCircle(
      Offset(w * 0.85, h * 0.15),
      w * 0.04,
      toolPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.83, h * 0.17, w * 0.04, h * 0.12),
        const Radius.circular(4),
      ),
      toolPaint,
    );

    // Hammer silhouette
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.75, h * 0.12, w * 0.02, h * 0.15),
        const Radius.circular(2),
      ),
      toolPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.72, h * 0.1, w * 0.08, h * 0.04),
        const Radius.circular(2),
      ),
      toolPaint,
    );

    // Workbench at bottom
    final benchPaint = Paint()
      ..color = RoomBackgroundColors.workshopGradient1.withOpacity(0.2);

    final bench = Path()
      ..moveTo(0, h * 0.88)
      ..lineTo(w, h * 0.88)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(bench, benchPaint);

    // Orange accent stripe
    final accentPaint = Paint()
      ..color = RoomBackgroundColors.workshopOrange.withOpacity(0.15)
      ..strokeWidth = 3;

    canvas.drawLine(
      Offset(0, h * 0.88),
      Offset(w, h * 0.88),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// SHOP STREET DECORATIONS
// ============================================================================

class _ShopStreetDecorations extends StatelessWidget {
  const _ShopStreetDecorations();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShopStreetPainter(),
      size: Size.infinite,
    );
  }
}

class _ShopStreetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky gradient at top
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          RoomBackgroundColors.shopSky.withOpacity(0.2),
          RoomBackgroundColors.shopSky.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.4));

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.4), skyPaint);

    // Storefront shapes
    final storefrontPaint = Paint()
      ..color = AppOverlays.white10;

    // Left storefront
    final leftStore = Path()
      ..moveTo(0, h * 0.2)
      ..lineTo(w * 0.35, h * 0.2)
      ..lineTo(w * 0.35, h * 0.9)
      ..lineTo(0, h * 0.9)
      ..close();
    canvas.drawPath(leftStore, storefrontPaint);

    // Right storefront
    final rightStore = Path()
      ..moveTo(w * 0.65, h * 0.25)
      ..lineTo(w, h * 0.25)
      ..lineTo(w, h * 0.85)
      ..lineTo(w * 0.65, h * 0.85)
      ..close();
    canvas.drawPath(rightStore, storefrontPaint);

    // Awning shapes (striped effect)
    final awningPaint = Paint()
      ..color = RoomBackgroundColors.shopSunny.withOpacity(0.15);

    // Left awning
    final leftAwning = Path()
      ..moveTo(0, h * 0.2)
      ..lineTo(w * 0.38, h * 0.2)
      ..lineTo(w * 0.35, h * 0.28)
      ..lineTo(0, h * 0.26)
      ..close();
    canvas.drawPath(leftAwning, awningPaint);

    // Right awning
    final rightAwning = Path()
      ..moveTo(w * 0.62, h * 0.25)
      ..lineTo(w, h * 0.25)
      ..lineTo(w, h * 0.31)
      ..lineTo(w * 0.65, h * 0.33)
      ..close();
    canvas.drawPath(rightAwning, awningPaint);

    // Street/path at bottom
    final streetPaint = Paint()
      ..color = AppOverlays.black10;

    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.92, w, h * 0.08),
      streetPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// TROPHY ROOM DECORATIONS
// ============================================================================

class _TrophyRoomDecorations extends StatelessWidget {
  const _TrophyRoomDecorations();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TrophyRoomPainter(),
      size: Size.infinite,
    );
  }
}

class _TrophyRoomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Spotlight effects from top
    final spotlightPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 1.2,
        colors: [
          RoomBackgroundColors.trophySpotlight.withOpacity(0.08),
          RoomBackgroundColors.trophySpotlight.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), spotlightPaint);

    // Left spotlight cone
    final conePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          RoomBackgroundColors.trophyGold.withOpacity(0.1),
          RoomBackgroundColors.trophyGold.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w * 0.4, h));

    final leftCone = Path()
      ..moveTo(w * 0.2, 0)
      ..lineTo(0, h * 0.7)
      ..lineTo(w * 0.4, h * 0.7)
      ..close();
    canvas.drawPath(leftCone, conePaint);

    // Right spotlight cone
    final rightCone = Path()
      ..moveTo(w * 0.8, 0)
      ..lineTo(w * 0.6, h * 0.7)
      ..lineTo(w, h * 0.7)
      ..close();
    canvas.drawPath(rightCone, conePaint);

    // Trophy pedestal silhouettes
    final pedestalPaint = Paint()
      ..color = RoomBackgroundColors.trophyGold.withOpacity(0.08);

    // Center pedestal
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.85),
          width: w * 0.2,
          height: h * 0.15,
        ),
        const Radius.circular(4),
      ),
      pedestalPaint,
    );

    // Trophy cup silhouette
    final cupPaint = Paint()
      ..color = RoomBackgroundColors.trophyGold.withOpacity(0.1);

    final cup = Path()
      ..moveTo(w * 0.44, h * 0.78)
      ..quadraticBezierTo(w * 0.42, h * 0.7, w * 0.45, h * 0.65)
      ..quadraticBezierTo(w * 0.5, h * 0.58, w * 0.55, h * 0.65)
      ..quadraticBezierTo(w * 0.58, h * 0.7, w * 0.56, h * 0.78)
      ..lineTo(w * 0.52, h * 0.78)
      ..lineTo(w * 0.52, h * 0.72)
      ..quadraticBezierTo(w * 0.5, h * 0.68, w * 0.48, h * 0.72)
      ..lineTo(w * 0.48, h * 0.78)
      ..close();
    canvas.drawPath(cup, cupPaint);

    // Decorative gold frame border
    final framePaint = Paint()
      ..color = RoomBackgroundColors.trophyGold.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.03, h * 0.03, w * 0.94, h * 0.94),
        const Radius.circular(8),
      ),
      framePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// FRIENDS DECORATIONS
// ============================================================================

class _FriendsDecorations extends StatelessWidget {
  const _FriendsDecorations();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FriendsPainter(),
      size: Size.infinite,
    );
  }
}

class _FriendsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Window light effect from top-left
    final windowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.7, -0.7),
        radius: 1.0,
        colors: [
          RoomBackgroundColors.friendsWindow.withOpacity(0.2),
          RoomBackgroundColors.friendsWindow.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), windowPaint);

    // Window frame silhouette
    final framePaint = Paint()
      ..color = AppOverlays.white15
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.3, h * 0.35),
        const Radius.circular(4),
      ),
      framePaint,
    );

    // Window cross-bar
    canvas.drawLine(
      Offset(w * 0.2, h * 0.05),
      Offset(w * 0.2, h * 0.4),
      framePaint,
    );
    canvas.drawLine(
      Offset(w * 0.05, h * 0.225),
      Offset(w * 0.35, h * 0.225),
      framePaint,
    );

    // Cozy corner accent (soft warm glow)
    final cozyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.8, 0.8),
        radius: 0.8,
        colors: [
          RoomBackgroundColors.friendsCozy.withOpacity(0.15),
          RoomBackgroundColors.friendsCozy.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), cozyPaint);

    // Social bubble decorations
    final bubblePaint = Paint()
      ..color = AppOverlays.white10
      ..style = PaintingStyle.fill;

    // Speech bubble shapes (decorative)
    canvas.drawCircle(Offset(w * 0.85, h * 0.2), 15, bubblePaint);
    canvas.drawCircle(Offset(w * 0.9, h * 0.25), 10, bubblePaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.15), 8, bubblePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// AMBIENT EFFECTS
// ============================================================================

/// Floating dust motes animation - for cozy indoor rooms
class _DustMotes extends StatefulWidget {
  final Color color;

  const _DustMotes({required this.color});

  @override
  State<_DustMotes> createState() => _DustMotesState();
}

class _DustMotesState extends State<_DustMotes>
    with SingleTickerProviderStateMixin {
  late final List<_Particle> _particles;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(12, (_) => _Particle.random(_random));
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: _particles.map((p) {
          return Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: _AnimatedDustMote(
              particle: p,
              color: widget.color,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AnimatedDustMote extends StatelessWidget {
  final _Particle particle;
  final Color color;

  const _AnimatedDustMote({
    required this.particle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Transform.translate(
          offset: Offset(w * particle.x, h * particle.y),
          child: Container(
            width: particle.size,
            height: particle.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15 * particle.opacity),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .move(
                begin: Offset.zero,
                end: Offset(
                  particle.driftX * 20,
                  particle.driftY * 30,
                ),
                duration: Duration(seconds: 6 + (particle.speed * 4).toInt()),
                curve: Curves.easeInOut,
              )
              .then()
              .move(
                begin: Offset(
                  particle.driftX * 20,
                  particle.driftY * 30,
                ),
                end: Offset.zero,
                duration: Duration(seconds: 6 + (particle.speed * 4).toInt()),
                curve: Curves.easeInOut,
              )
              .fadeIn(duration: const Duration(seconds: 2))
              .then(delay: Duration(seconds: 8 + (particle.speed * 4).toInt()))
              .fadeOut(duration: const Duration(seconds: 2)),
        );
      },
    );
  }
}

/// Spark particles - for workshop industrial feel
class _SparkParticles extends StatefulWidget {
  final Color color;

  const _SparkParticles({required this.color});

  @override
  State<_SparkParticles> createState() => _SparkParticlesState();
}

class _SparkParticlesState extends State<_SparkParticles> {
  late final List<_Particle> _particles;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(8, (_) => _Particle.random(_random));
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: _particles.map((p) {
          return Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: _AnimatedSpark(
              particle: p,
              color: widget.color,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AnimatedSpark extends StatelessWidget {
  final _Particle particle;
  final Color color;

  const _AnimatedSpark({
    required this.particle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Transform.translate(
          offset: Offset(w * particle.x, h * particle.y),
          child: Container(
            width: particle.size * 0.6,
            height: particle.size * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.3 * particle.opacity),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          )
              .animate(
                onPlay: (c) => c.repeat(),
                delay: Duration(milliseconds: (particle.speed * 3000).toInt()),
              )
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.0, 1.0),
                duration: const Duration(milliseconds: 200),
              )
              .then()
              .fadeOut(duration: const Duration(milliseconds: 800))
              .then(delay: Duration(seconds: 3 + (particle.speed * 2).toInt())),
        );
      },
    );
  }
}

/// Sunbeam effect - for outdoor shop street
class _SunbeamEffect extends StatelessWidget {
  const _SunbeamEffect();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _SunbeamPainter(),
        size: Size.infinite,
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .fadeIn(begin: 0.4, duration: const Duration(seconds: 4))
          .then()
          .fadeOut(begin: 0.6, duration: const Duration(seconds: 4)),
    );
  }
}

class _SunbeamPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sun rays from top-right corner
    final rayPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          RoomBackgroundColors.shopSunny.withOpacity(0.12),
          RoomBackgroundColors.shopSunny.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Draw multiple rays
    for (var i = 0; i < 3; i++) {
      final angle = -0.3 - (i * 0.15);
      canvas.save();
      canvas.translate(w, 0);
      canvas.rotate(angle);

      canvas.drawRect(
        Rect.fromLTWH(-w * 0.1, 0, w * 0.08, h * 1.5),
        rayPaint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Spotlight shimmer - for trophy room prestige
class _SpotlightShimmer extends StatelessWidget {
  const _SpotlightShimmer();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Central shimmer
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.5,
                  colors: [
                    RoomBackgroundColors.trophyGold.withOpacity(0.08),
                    RoomBackgroundColors.trophyGold.withOpacity(0.0),
                  ],
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(
                  begin: 0.3,
                  end: 1.0,
                  duration: const Duration(seconds: 3),
                ),
          ),
        ],
      ),
    );
  }
}

/// Window light rays - for friends social warmth
class _WindowLightRays extends StatelessWidget {
  const _WindowLightRays();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _WindowRaysPainter(),
        size: Size.infinite,
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .fade(
            begin: 0.5,
            end: 1.0,
            duration: const Duration(seconds: 5),
            curve: Curves.easeInOut,
          ),
    );
  }
}

class _WindowRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Light rays from window area
    final rayPaint = Paint()
      ..shader = LinearGradient(
        begin: const Alignment(-0.8, -0.8),
        end: const Alignment(0.5, 0.5),
        colors: [
          RoomBackgroundColors.friendsWindow.withOpacity(0.15),
          RoomBackgroundColors.friendsWindow.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w * 0.6, h * 0.6));

    // Draw diagonal ray
    final ray = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.4, 0)
      ..lineTo(w * 0.7, h * 0.6)
      ..lineTo(w * 0.3, h * 0.5)
      ..close();

    canvas.drawPath(ray, rayPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// HELPER CLASSES
// ============================================================================

class _Particle {
  final double x;
  final double y;
  final double size;
  final double opacity;
  final double speed;
  final double driftX;
  final double driftY;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.driftX,
    required this.driftY,
  });

  factory _Particle.random(math.Random random) {
    return _Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      size: 2 + random.nextDouble() * 4,
      opacity: 0.3 + random.nextDouble() * 0.7,
      speed: random.nextDouble(),
      driftX: (random.nextDouble() - 0.5) * 2,
      driftY: (random.nextDouble() - 0.5) * 2,
    );
  }
}
