import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import 'hobby_items.dart';

/// A cozy living room scene - warm, filled with plants, golden light
/// Inspired by illustrated cozy room aesthetics
/// Items are LARGE for easy tapping
class LivingRoomScene extends StatelessWidget {
  final String tankName;
  final double tankVolume;
  final double? temperature;
  final double? ph;
  final VoidCallback? onTankTap;
  final VoidCallback? onThermometerTap;
  final VoidCallback? onTestKitTap;
  final VoidCallback? onFoodTap;
  final VoidCallback? onBookTap;
  final VoidCallback? onTeaTap;
  final VoidCallback? onPlantTap;

  const LivingRoomScene({
    super.key,
    required this.tankName,
    required this.tankVolume,
    this.temperature,
    this.ph,
    this.onTankTap,
    this.onThermometerTap,
    this.onTestKitTap,
    this.onFoodTap,
    this.onBookTap,
    this.onTeaTap,
    this.onPlantTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight.isFinite 
            ? constraints.maxHeight 
            : w * 1.2;

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            children: [
              // === BACKGROUND: Warm wall with golden light ===
              Positioned.fill(child: _WarmWallWithLight()),

              // === WINDOW with plants on sill (center-back) ===
              Positioned(
                top: h * 0.02,
                left: w * 0.15,
                right: w * 0.15,
                child: _LargeWindowWithPlants(
                  width: w * 0.7,
                  height: h * 0.32,
                ),
              ),

              // === BOOKSHELF on left wall ===
              Positioned(
                top: h * 0.08,
                left: 0,
                child: _BookShelf(
                  width: w * 0.18,
                  height: h * 0.35,
                  onTap: onBookTap,
                ),
              ),

              // === FRAMED PICTURES on right wall ===
              Positioned(
                top: h * 0.1,
                right: w * 0.03,
                child: _FramedPictures(width: w * 0.15),
              ),

              // === FLOOR ===
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _WarmWoodFloor(height: h * 0.28),
              ),

              // === BIG FLOOR PLANT - left ===
              Positioned(
                bottom: h * 0.22,
                left: w * 0.01,
                child: GestureDetector(
                  onTap: onPlantTap,
                  child: _BigLeafyPlant(height: h * 0.28),
                ),
              ),

              // === BIG FLOOR PLANT - right ===
              Positioned(
                bottom: h * 0.2,
                right: w * 0.02,
                child: _BigLeafyPlant(height: h * 0.22, flip: true),
              ),

              // === TANK STAND/CABINET (middle layer) ===
              Positioned(
                bottom: h * 0.24,
                left: w * 0.2,
                child: _TankCabinet(
                  width: w * 0.6,
                  height: h * 0.1,
                ),
              ),

              // === THE AQUARIUM - main focal point ===
              Positioned(
                bottom: h * 0.33,
                left: w * 0.22,
                child: GestureDetector(
                  onTap: onTankTap,
                  child: _CozyAquarium(
                    width: w * 0.56,
                    height: h * 0.28,
                    name: tankName,
                  ),
                ),
              ),

              // === THERMOMETER on tank - LARGE ===
              Positioned(
                bottom: h * 0.38,
                right: w * 0.2,
                child: GestureDetector(
                  onTap: onThermometerTap,
                  child: _LargeThermometer(
                    height: h * 0.12,
                    temperature: temperature,
                  ),
                ),
              ),

              // === FOREGROUND: Coffee table with items ===
              Positioned(
                bottom: h * 0.05,
                left: w * 0.1,
                right: w * 0.1,
                child: _CoffeeTableWithItems(
                  width: w * 0.8,
                  height: h * 0.2,
                  onTeaTap: onTeaTap,
                  onBookTap: onBookTap,
                  onTestKitTap: onTestKitTap,
                  onFoodTap: onFoodTap,
                ),
              ),

              // === SMALL RUG under table ===
              Positioned(
                bottom: h * 0.02,
                left: w * 0.15,
                right: w * 0.15,
                child: _CozyRug(width: w * 0.7),
              ),
            ],
          ),
        );
      },
    );
  }
}

// === WARM BACKGROUND WITH GOLDEN LIGHT ===

class _WarmWallWithLight extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // Warm cream/beige wall
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFDF6E3), // Warm cream top
            Color(0xFFF5EBD7), // Slightly darker bottom
          ],
        ),
      ),
      child: Stack(
        children: [
          // Golden sunlight from window
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.3),
                  radius: 1.2,
                  colors: [
                    const Color(0xFFFFE4B5).withOpacity(0.6), // Golden glow
                    const Color(0xFFFDF6E3).withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          // Subtle wall texture
          CustomPaint(
            size: Size.infinite,
            painter: _WallTexturePainter(),
          ),
        ],
      ),
    );
  }
}

class _WallTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEDE4D3).withOpacity(0.3)
      ..strokeWidth = 1;

    // Subtle horizontal lines
    for (var y = 0.0; y < size.height * 0.7; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// === LARGE WINDOW WITH PLANTS ON SILL ===

class _LargeWindowWithPlants extends StatelessWidget {
  final double width;
  final double height;

  const _LargeWindowWithPlants({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Window frame
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            decoration: BoxDecoration(
              // Bright sky/light through window
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFFACD), // Bright warm light
                  Color(0xFFE8F5E9), // Hint of green (trees outside)
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF8B7355), // Wood frame
                width: 8,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFE4B5).withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Window panes
                Positioned.fill(
                  child: Row(
                    children: [
                      Expanded(child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF8B7355), width: 3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )),
                      Expanded(child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF8B7355), width: 3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )),
                    ],
                  ),
                ),
                // Light rays
                Positioned.fill(
                  child: CustomPaint(painter: _SunRaysPainter()),
                ),
                // Sheer curtains on sides
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 15,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFF8E7).withOpacity(0.8),
                          const Color(0xFFFFF8E7).withOpacity(0.2),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 15,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFF8E7).withOpacity(0.2),
                          const Color(0xFFFFF8E7).withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Windowsill
          Positioned(
            bottom: 20,
            left: -10,
            right: -10,
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF8B7355),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),

          // Plants on windowsill - LOTS of them!
          Positioned(
            bottom: 30,
            left: 20,
            child: _WindowsillPlant(height: 45, type: 'bushy'),
          ),
          Positioned(
            bottom: 30,
            left: 60,
            child: _WindowsillPlant(height: 35, type: 'trailing'),
          ),
          Positioned(
            bottom: 30,
            left: width * 0.35,
            child: _WindowsillPlant(height: 50, type: 'tall'),
          ),
          Positioned(
            bottom: 30,
            right: width * 0.3,
            child: _WindowsillPlant(height: 40, type: 'bushy'),
          ),
          Positioned(
            bottom: 30,
            right: 50,
            child: _WindowsillPlant(height: 38, type: 'succulent'),
          ),
          Positioned(
            bottom: 30,
            right: 15,
            child: _WindowsillPlant(height: 42, type: 'trailing'),
          ),
        ],
      ),
    );
  }
}

class _SunRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 2;

    // Diagonal light rays
    for (var i = 0; i < 5; i++) {
      final x = size.width * (0.2 + i * 0.15);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + 30, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WindowsillPlant extends StatelessWidget {
  final double height;
  final String type;

  const _WindowsillPlant({required this.height, required this.type});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: height * 0.7,
      height: height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Terracotta pot
          Positioned(
            bottom: 0,
            child: Container(
              width: height * 0.45,
              height: height * 0.3,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFD2691E), Color(0xFFA0522D)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Plant foliage
          Positioned(
            bottom: height * 0.25,
            child: CustomPaint(
              size: Size(height * 0.6, height * 0.7),
              painter: _PlantPainter(type: type),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantPainter extends CustomPainter {
  final String type;

  _PlantPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    switch (type) {
      case 'bushy':
        _drawBushyPlant(canvas, size, paint);
        break;
      case 'trailing':
        _drawTrailingPlant(canvas, size, paint);
        break;
      case 'tall':
        _drawTallPlant(canvas, size, paint);
        break;
      case 'succulent':
        _drawSucculent(canvas, size, paint);
        break;
    }
  }

  void _drawBushyPlant(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFF4CAF50);
    for (var i = 0; i < 7; i++) {
      final angle = (i - 3) * 0.3;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            size.width / 2 + math.sin(angle) * size.width * 0.3,
            size.height * 0.4 + i * 3,
          ),
          width: size.width * 0.4,
          height: size.height * 0.35,
        ),
        paint,
      );
    }
  }

  void _drawTrailingPlant(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFF81C784);
    // Trailing vines
    for (var i = 0; i < 4; i++) {
      final path = Path()
        ..moveTo(size.width / 2, 0)
        ..quadraticBezierTo(
          size.width * (0.2 + i * 0.2),
          size.height * 0.5,
          size.width * (0.1 + i * 0.25),
          size.height,
        );
      canvas.drawPath(
        path,
        paint..style = PaintingStyle.stroke..strokeWidth = 3,
      );
      // Leaves on vine
      canvas.drawCircle(
        Offset(size.width * (0.15 + i * 0.2), size.height * 0.7),
        6,
        paint..style = PaintingStyle.fill,
      );
    }
  }

  void _drawTallPlant(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFF388E3C);
    // Tall leaves
    for (var i = -2; i <= 2; i++) {
      final leafPath = Path()
        ..moveTo(size.width / 2, size.height)
        ..quadraticBezierTo(
          size.width / 2 + i * 12,
          size.height * 0.3,
          size.width / 2 + i * 8,
          0,
        )
        ..quadraticBezierTo(
          size.width / 2 + i * 4,
          size.height * 0.3,
          size.width / 2,
          size.height,
        );
      canvas.drawPath(leafPath, paint);
    }
  }

  void _drawSucculent(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFF66BB6A);
    // Rosette pattern
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            size.width / 2 + math.cos(angle) * 8,
            size.height / 2 + math.sin(angle) * 8,
          ),
          width: 12,
          height: 18,
        ),
        paint,
      );
    }
    // Center
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 6, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// === WARM WOOD FLOOR ===

class _WarmWoodFloor extends StatelessWidget {
  final double height;

  const _WarmWoodFloor({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFDEB887), // Warm wood
            Color(0xFFD2A679),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _WoodFloorPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _WoodFloorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Planks
    final plankPaint = Paint()
      ..color = const Color(0xFFC4996C).withOpacity(0.4)
      ..strokeWidth = 1;

    const plankWidth = 50.0;
    for (var x = 0.0; x < size.width; x += plankWidth) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), plankPaint);
    }

    // Wood grain
    final grainPaint = Paint()
      ..color = const Color(0xFFB8956A).withOpacity(0.2)
      ..strokeWidth = 0.5;

    final random = math.Random(42);
    for (var y = 0.0; y < size.height; y += 4) {
      if (random.nextDouble() > 0.6) {
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y + random.nextDouble() * 2),
          grainPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// === BIG LEAFY FLOOR PLANTS ===

class _BigLeafyPlant extends StatelessWidget {
  final double height;
  final bool flip;

  const _BigLeafyPlant({required this.height, this.flip = false});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flip ? -1 : 1,
      child: SizedBox(
        width: height * 0.8,
        height: height,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Big terracotta pot
            Positioned(
              bottom: 0,
              child: Container(
                width: height * 0.4,
                height: height * 0.25,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFCD853F), Color(0xFF8B4513)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
              ),
            ),
            // Big leaves
            Positioned(
              bottom: height * 0.2,
              child: CustomPaint(
                size: Size(height * 0.8, height * 0.75),
                painter: _BigLeafPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigLeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFF2E7D32),
      const Color(0xFF388E3C),
      const Color(0xFF43A047),
      const Color(0xFF4CAF50),
    ];

    // Draw big monstera-like leaves
    for (var i = -3; i <= 3; i++) {
      final paint = Paint()
        ..color = colors[(i + 3) % colors.length]
        ..style = PaintingStyle.fill;

      final angle = i * 0.35;
      final leafHeight = size.height * (0.6 + (i.abs() % 2) * 0.35);

      final leafPath = Path()
        ..moveTo(size.width / 2, size.height)
        ..quadraticBezierTo(
          size.width / 2 + math.sin(angle) * size.width * 0.6,
          size.height - leafHeight * 0.5,
          size.width / 2 + math.sin(angle) * size.width * 0.4,
          size.height - leafHeight,
        )
        ..quadraticBezierTo(
          size.width / 2 + math.sin(angle) * size.width * 0.1,
          size.height - leafHeight * 0.5,
          size.width / 2,
          size.height,
        );

      canvas.drawPath(leafPath, paint);

      // Leaf vein
      canvas.drawPath(
        leafPath,
        Paint()
          ..color = const Color(0xFF1B5E20).withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// === TANK CABINET ===

class _TankCabinet extends StatelessWidget {
  final double width;
  final double height;

  const _TankCabinet({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5D4037), Color(0xFF4E342E)],
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left cabinet door
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF6D4C41),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF8D6E63), width: 1),
              ),
              child: Center(
                child: Container(
                  width: 8,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          // Right cabinet door
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF6D4C41),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF8D6E63), width: 1),
              ),
              child: Center(
                child: Container(
                  width: 8,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// === THE COZY AQUARIUM - LARGE ===

class _CozyAquarium extends StatelessWidget {
  final double width;
  final double height;
  final String name;

  const _CozyAquarium({
    required this.width,
    required this.height,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // Beautiful water gradient
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF7FCDCD), // Light aqua top
            Color(0xFF5BA3B5), // Teal middle
            Color(0xFF3D8B9F), // Deeper bottom
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
          width: 4,
        ),
        boxShadow: [
          // Glow effect
          BoxShadow(
            color: const Color(0xFF5BA3B5).withOpacity(0.4),
            blurRadius: 25,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Light shimmer from window
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: height * 0.15,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFE4B5).withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ),
          ),

          // Substrate
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: height * 0.15,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFA08060), Color(0xFF8B7355)],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
              ),
              child: CustomPaint(painter: _GravelPainter()),
            ),
          ),

          // Plants - bigger and more lush
          Positioned(
            bottom: height * 0.12,
            left: width * 0.05,
            child: _AquariumPlant(height: height * 0.5),
          ),
          Positioned(
            bottom: height * 0.12,
            left: width * 0.18,
            child: _AquariumPlant(height: height * 0.35, color: const Color(0xFF6B8E23)),
          ),
          Positioned(
            bottom: height * 0.12,
            right: width * 0.08,
            child: _AquariumPlant(height: height * 0.55),
          ),
          Positioned(
            bottom: height * 0.12,
            right: width * 0.25,
            child: _AquariumPlant(height: height * 0.4, color: const Color(0xFF8FBC8F)),
          ),
          Positioned(
            bottom: height * 0.12,
            left: width * 0.4,
            child: _AquariumPlant(height: height * 0.3, color: const Color(0xFF556B2F)),
          ),

          // Driftwood
          Positioned(
            bottom: height * 0.12,
            left: width * 0.3,
            child: _Driftwood(width: width * 0.3),
          ),

          // Fish - bigger and more colorful
          Positioned(
            top: height * 0.2,
            left: width * 0.15,
            child: _ColorfulFish(size: 24, color: Colors.orange),
          ),
          Positioned(
            top: height * 0.35,
            right: width * 0.2,
            child: _ColorfulFish(size: 20, color: const Color(0xFFE57373), flip: true),
          ),
          Positioned(
            top: height * 0.5,
            left: width * 0.45,
            child: _ColorfulFish(size: 18, color: const Color(0xFF64B5F6)),
          ),
          Positioned(
            top: height * 0.3,
            left: width * 0.55,
            child: _ColorfulFish(size: 22, color: const Color(0xFFFFD54F), flip: true),
          ),
          Positioned(
            top: height * 0.55,
            right: width * 0.35,
            child: _ColorfulFish(size: 16, color: const Color(0xFFBA68C8)),
          ),

          // Bubbles
          Positioned(
            right: width * 0.15,
            bottom: height * 0.15,
            child: _Bubbles(height: height * 0.6),
          ),

          // Water surface
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.4),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
          ),

          // LED light on top
          Positioned(
            top: -12,
            left: width * 0.15,
            right: width * 0.15,
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF37474F),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 8,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GravelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(99);
    final colors = [
      const Color(0xFF9E8B7D),
      const Color(0xFF8B7D6B),
      const Color(0xFFA89880),
    ];

    for (var i = 0; i < 150; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        1 + random.nextDouble() * 2.5,
        Paint()..color = colors[random.nextInt(colors.length)],
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AquariumPlant extends StatelessWidget {
  final double height;
  final Color color;

  const _AquariumPlant({
    required this.height,
    this.color = const Color(0xFF228B22),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(height * 0.4, height),
      painter: _AquariumPlantPainter(color: color),
    );
  }
}

class _AquariumPlantPainter extends CustomPainter {
  final Color color;

  _AquariumPlantPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 6; i++) {
      final angle = (i - 2.5) * 0.25;
      final leafHeight = size.height * (0.6 + (i % 3) * 0.2);

      final path = Path()
        ..moveTo(size.width / 2, size.height)
        ..quadraticBezierTo(
          size.width / 2 + math.sin(angle) * size.width,
          size.height - leafHeight / 2,
          size.width / 2 + math.sin(angle) * size.width * 0.6,
          size.height - leafHeight,
        )
        ..quadraticBezierTo(
          size.width / 2,
          size.height - leafHeight / 2,
          size.width / 2,
          size.height,
        );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Driftwood extends StatelessWidget {
  final double width;

  const _Driftwood({required this.width});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, width * 0.35),
      painter: _DriftwoodPainter(),
    );
  }
}

class _DriftwoodPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.2, size.width * 0.4, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.6, size.height * 0.1, size.width * 0.85, size.height * 0.35)
      ..lineTo(size.width, size.height * 0.25)
      ..lineTo(size.width * 0.9, size.height)
      ..lineTo(size.width * 0.1, size.height)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF8D6E63)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ColorfulFish extends StatelessWidget {
  final double size;
  final Color color;
  final bool flip;

  const _ColorfulFish({
    required this.size,
    required this.color,
    this.flip = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flip ? -1 : 1,
      child: CustomPaint(
        size: Size(size * 2, size),
        painter: _FishPainter(color: color),
      ),
    );
  }
}

class _FishPainter extends CustomPainter {
  final Color color;

  _FishPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // Body
    final bodyPath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.05, size.width * 0.6, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.95, size.width * 0.1, size.height * 0.5);

    canvas.drawPath(bodyPath, paint);

    // Tail
    final tailPath = Path()
      ..moveTo(size.width * 0.55, size.height * 0.5)
      ..lineTo(size.width, size.height * 0.1)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.5, size.width, size.height * 0.9)
      ..close();

    canvas.drawPath(tailPath, paint);

    // Top fin
    final finPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.4, 0, size.width * 0.5, size.height * 0.2)
      ..close();

    canvas.drawPath(finPath, paint..color = color.withOpacity(0.8));

    // Eye
    canvas.drawCircle(
      Offset(size.width * 0.22, size.height * 0.4),
      size.width * 0.05,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(size.width * 0.22, size.height * 0.4),
      size.width * 0.03,
      Paint()..color = Colors.black,
    );

    // Highlight
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.28, size.height * 0.35),
        width: size.width * 0.12,
        height: size.width * 0.06,
      ),
      Paint()..color = Colors.white.withOpacity(0.3),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Bubbles extends StatelessWidget {
  final double height;

  const _Bubbles({required this.height});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(25, height),
      painter: _BubblesPainter(),
    );
  }
}

class _BubblesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final random = math.Random(55);
    for (var i = 0; i < 10; i++) {
      final radius = 2 + random.nextDouble() * 4;
      final pos = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      canvas.drawCircle(pos, radius, paint);
      canvas.drawCircle(pos, radius, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// === LARGE THERMOMETER ===

class _LargeThermometer extends StatelessWidget {
  final double height;
  final double? temperature;

  const _LargeThermometer({required this.height, this.temperature});

  @override
  Widget build(BuildContext context) {
    final fillPercent = temperature != null
        ? ((temperature! - 15) / 20).clamp(0.0, 1.0)
        : 0.5;

    return Container(
      width: height * 0.35,
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(height * 0.15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _ThermometerPainter(
          fillPercent: fillPercent,
          color: _tempColor(temperature),
        ),
      ),
    );
  }

  Color _tempColor(double? temp) {
    if (temp == null) return Colors.grey;
    if (temp < 22) return Colors.blue;
    if (temp < 26) return Colors.green;
    if (temp < 30) return Colors.orange;
    return Colors.red;
  }
}

class _ThermometerPainter extends CustomPainter {
  final double fillPercent;
  final Color color;

  _ThermometerPainter({required this.fillPercent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final bulbRadius = size.width * 0.4;
    final tubeWidth = size.width * 0.35;
    final tubeLeft = (size.width - tubeWidth) / 2;

    // Glass tube
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tubeLeft, 4, tubeWidth, size.height - bulbRadius - 4),
        Radius.circular(tubeWidth / 2),
      ),
      Paint()..color = Colors.grey.shade200,
    );

    // Bulb
    canvas.drawCircle(
      Offset(size.width / 2, size.height - bulbRadius),
      bulbRadius,
      Paint()..color = Colors.grey.shade200,
    );

    // Fill
    final fillHeight = (size.height - bulbRadius * 2 - 12) * fillPercent;
    final fillPaint = Paint()..color = color;

    canvas.drawCircle(
      Offset(size.width / 2, size.height - bulbRadius),
      bulbRadius * 0.7,
      fillPaint,
    );

    final innerWidth = tubeWidth * 0.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          (size.width - innerWidth) / 2,
          size.height - bulbRadius - fillHeight - 2,
          innerWidth,
          fillHeight + 2,
        ),
        Radius.circular(innerWidth / 2),
      ),
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ThermometerPainter old) =>
      old.fillPercent != fillPercent || old.color != color;
}

// === COFFEE TABLE WITH ITEMS (FOREGROUND) ===

class _CoffeeTableWithItems extends StatelessWidget {
  final double width;
  final double height;
  final VoidCallback? onTeaTap;
  final VoidCallback? onBookTap;
  final VoidCallback? onTestKitTap;
  final VoidCallback? onFoodTap;

  const _CoffeeTableWithItems({
    required this.width,
    required this.height,
    this.onTeaTap,
    this.onBookTap,
    this.onTestKitTap,
    this.onFoodTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Table surface
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: height * 0.15,
              decoration: BoxDecoration(
                color: const Color(0xFFDEB887),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD2A679), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          // Table legs
          Positioned(
            top: height * 0.14,
            left: width * 0.1,
            child: Container(width: 8, height: height * 0.5, color: const Color(0xFFC4996C)),
          ),
          Positioned(
            top: height * 0.14,
            right: width * 0.1,
            child: Container(width: 8, height: height * 0.5, color: const Color(0xFFC4996C)),
          ),

          // === ITEMS ON TABLE (LARGE for tapping) ===

          // Tea cup - LEFT
          Positioned(
            top: -25,
            left: width * 0.05,
            child: GestureDetector(
              onTap: onTeaTap,
              child: _TeaCup(size: 50),
            ),
          ),

          // Open book - CENTER LEFT
          Positioned(
            top: -15,
            left: width * 0.25,
            child: GestureDetector(
              onTap: onBookTap,
              child: _OpenBook(width: 70),
            ),
          ),

          // Test kit - CENTER RIGHT
          Positioned(
            top: -35,
            right: width * 0.22,
            child: GestureDetector(
              onTap: onTestKitTap,
              child: _TestKit(width: 60),
            ),
          ),

          // Food jar - RIGHT
          Positioned(
            top: -30,
            right: width * 0.03,
            child: GestureDetector(
              onTap: onFoodTap,
              child: FoodJarItem(height: 50),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeaCup extends StatelessWidget {
  final double size;

  const _TeaCup({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.8,
      child: Stack(
        children: [
          // Saucer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size * 0.15,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E7),
                borderRadius: BorderRadius.circular(size * 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          // Cup
          Positioned(
            bottom: size * 0.1,
            left: size * 0.15,
            child: Container(
              width: size * 0.7,
              height: size * 0.5,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFFAF0), Color(0xFFF5F5DC)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  // Tea inside
                  Positioned(
                    top: 4,
                    left: 4,
                    right: 4,
                    child: Container(
                      height: size * 0.35,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCD853F),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Handle
          Positioned(
            right: 0,
            top: size * 0.25,
            child: Container(
              width: size * 0.2,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: const Color(0xFFF5F5DC), width: 4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenBook extends StatelessWidget {
  final double width;

  const _OpenBook({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 0.55,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left page
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFFAF0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
              ),
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (i) => Container(
                  height: 2,
                  color: Colors.grey.shade300,
                )),
              ),
            ),
          ),
          // Spine
          Container(width: 3, color: const Color(0xFF8B4513)),
          // Right page
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFFAF0),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (i) => Container(
                  height: 2,
                  color: Colors.grey.shade300,
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestKit extends StatelessWidget {
  final double width;

  const _TestKit({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 0.9,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF37474F),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TestTube(height: width * 0.7, color: Colors.green.shade200), // pH
          _TestTube(height: width * 0.7, color: Colors.yellow.shade200), // Ammonia
          _TestTube(height: width * 0.7, color: Colors.purple.shade200), // Nitrite
          _TestTube(height: width * 0.7, color: Colors.orange.shade200), // Nitrate
        ],
      ),
    );
  }
}

class _TestTube extends StatelessWidget {
  final double height;
  final Color color;

  const _TestTube({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: height * 0.25,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(height * 0.1),
      ),
      child: Column(
        children: [
          const Spacer(),
          Container(
            height: height * 0.6,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(height * 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

// === COZY RUG ===

class _CozyRug extends StatelessWidget {
  final double width;

  const _CozyRug({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 20,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE8A87C).withOpacity(0.6),
            const Color(0xFFDEB887).withOpacity(0.7),
            const Color(0xFFE8A87C).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CustomPaint(painter: _RugPatternPainter()),
    );
  }
}

class _RugPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCD853F).withOpacity(0.4)
      ..strokeWidth = 1;

    // Simple pattern
    for (var x = 15.0; x < size.width - 15; x += 20) {
      canvas.drawLine(
        Offset(x, size.height * 0.3),
        Offset(x + 8, size.height * 0.7),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// === BOOKSHELF ===

class _BookShelf extends StatelessWidget {
  final double width;
  final double height;
  final VoidCallback? onTap;

  const _BookShelf({required this.width, required this.height, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF6D4C41),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(4),
            bottomRight: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(4, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top shelf with books
            _ShelfWithBooks(height: height * 0.3),
            Container(height: 4, color: const Color(0xFF5D4037)),
            // Middle shelf with plant
            Expanded(
              child: Center(
                child: _WindowsillPlant(height: 35, type: 'succulent'),
              ),
            ),
            Container(height: 4, color: const Color(0xFF5D4037)),
            // Bottom shelf with books
            _ShelfWithBooks(height: height * 0.3),
          ],
        ),
      ),
    );
  }
}

class _ShelfWithBooks extends StatelessWidget {
  final double height;

  const _ShelfWithBooks({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(width: 8, height: height * 0.8, color: const Color(0xFF4A90A4)),
          const SizedBox(width: 2),
          Container(width: 6, height: height * 0.7, color: const Color(0xFFE8A87C)),
          const SizedBox(width: 2),
          Container(width: 7, height: height * 0.85, color: const Color(0xFF85C88A)),
        ],
      ),
    );
  }
}

// === FRAMED PICTURES ===

class _FramedPictures extends StatelessWidget {
  final double width;

  const _FramedPictures({required this.width});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Fish picture
        Container(
          width: width,
          height: width * 1.2,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFF8B7355),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade100, Colors.blue.shade300],
              ),
            ),
            child: Center(
              child: Icon(Icons.set_meal, color: Colors.orange.shade300, size: width * 0.5),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Plant picture
        Container(
          width: width * 0.8,
          height: width * 0.8,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFF8B7355),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Container(
            color: const Color(0xFFF5F5DC),
            child: Center(
              child: Icon(Icons.eco, color: Colors.green.shade400, size: width * 0.4),
            ),
          ),
        ),
      ],
    );
  }
}
