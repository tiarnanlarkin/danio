import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import 'hobby_items.dart';

/// A complete room scene with a tank as the centerpiece
/// Everything positioned where you'd expect it in a real room
class LivingRoomScene extends StatelessWidget {
  final String tankName;
  final double tankVolume;
  final double? temperature;
  final double? ph;
  final VoidCallback? onTankTap;
  final VoidCallback? onThermometerTap;
  final VoidCallback? onShelfTap;
  final VoidCallback? onTestKitTap;
  final VoidCallback? onFoodTap;
  final VoidCallback? onPlantTap;

  const LivingRoomScene({
    super.key,
    required this.tankName,
    required this.tankVolume,
    this.temperature,
    this.ph,
    this.onTankTap,
    this.onThermometerTap,
    this.onShelfTap,
    this.onTestKitTap,
    this.onFoodTap,
    this.onPlantTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight.isFinite 
            ? constraints.maxHeight 
            : width * 0.9;

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              // === BACK WALL ===
              Positioned.fill(
                child: _BackWall(),
              ),

              // === WINDOW (upper right) ===
              Positioned(
                top: height * 0.05,
                right: width * 0.08,
                child: _Window(
                  width: width * 0.22,
                  height: height * 0.28,
                ),
              ),

              // === WALL SHELF (above tank, left side) ===
              Positioned(
                top: height * 0.08,
                left: width * 0.05,
                child: GestureDetector(
                  onTap: onShelfTap,
                  child: _WallShelf(
                    width: width * 0.35,
                    items: [
                      _ShelfItem(
                        child: FoodJarItem(height: 35, onTap: onFoodTap),
                      ),
                      _ShelfItem(
                        child: _SmallPlantPot(height: 30),
                      ),
                      _ShelfItem(
                        child: _BookStack(height: 28),
                      ),
                    ],
                  ),
                ),
              ),

              // === SMALL FRAMED PICTURE ===
              Positioned(
                top: height * 0.12,
                left: width * 0.52,
                child: _FramedPicture(width: width * 0.12),
              ),

              // === FLOOR ===
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _Floor(height: height * 0.18),
              ),

              // === CABINET/STAND (tank sits on this) ===
              Positioned(
                bottom: height * 0.15,
                left: width * 0.1,
                child: _TankStand(
                  width: width * 0.55,
                  height: height * 0.12,
                ),
              ),

              // === THE TANK (main focal point) ===
              Positioned(
                bottom: height * 0.26,
                left: width * 0.12,
                child: GestureDetector(
                  onTap: onTankTap,
                  child: _AquariumTank(
                    width: width * 0.5,
                    height: height * 0.35,
                    name: tankName,
                    volume: tankVolume,
                  ),
                ),
              ),

              // === THERMOMETER (stuck to tank glass) ===
              Positioned(
                bottom: height * 0.35,
                left: width * 0.58,
                child: ThermometerItem(
                  temperature: temperature,
                  height: 55,
                  onTap: onThermometerTap,
                ),
              ),

              // === SIDE TABLE (right of tank) ===
              Positioned(
                bottom: height * 0.15,
                right: width * 0.08,
                child: _SideTable(
                  width: width * 0.2,
                  height: height * 0.18,
                ),
              ),

              // === TEST KIT (on side table) ===
              Positioned(
                bottom: height * 0.32,
                right: width * 0.1,
                child: GestureDetector(
                  onTap: onTestKitTap,
                  child: TestTubeRack(
                    ph: ph,
                    width: 55,
                  ),
                ),
              ),

              // === FLOOR PLANT (corner) ===
              Positioned(
                bottom: height * 0.12,
                right: width * 0.02,
                child: GestureDetector(
                  onTap: onPlantTap,
                  child: _FloorPlant(height: height * 0.25),
                ),
              ),

              // === SMALL RUG ===
              Positioned(
                bottom: height * 0.08,
                left: width * 0.25,
                child: _Rug(width: width * 0.35),
              ),

              // === CAT (optional cozy element) ===
              Positioned(
                bottom: height * 0.1,
                left: width * 0.05,
                child: _SleepingCat(width: width * 0.12),
              ),
            ],
          ),
        );
      },
    );
  }
}

// === ROOM ELEMENTS ===

class _BackWall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Warm cozy wall color
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF5EDE3), // Cream
            const Color(0xFFEDE5DA), // Slightly darker at bottom
          ],
        ),
      ),
      child: CustomPaint(
        painter: _WallTexturePainter(),
      ),
    );
  }
}

class _WallTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Subtle horizontal lines suggesting wallpaper or texture
    final paint = Paint()
      ..color = const Color(0xFFE8DFD4).withOpacity(0.5)
      ..strokeWidth = 1;

    for (var y = 0.0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Window extends StatelessWidget {
  final double width;
  final double height;

  const _Window({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // Sky through window
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF87CEEB), // Light blue sky
            Color(0xFFB8E0F0),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF8B7355), // Wood frame
          width: 6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Window panes (cross)
          Center(
            child: Container(
              width: 4,
              height: height,
              color: const Color(0xFF8B7355),
            ),
          ),
          Center(
            child: Container(
              width: width,
              height: 4,
              color: const Color(0xFF8B7355),
            ),
          ),
          // Subtle light rays
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: width * 0.4,
              height: height * 0.4,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Curtain hints on sides
          Positioned(
            left: -2,
            top: 0,
            bottom: 0,
            child: Container(
              width: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFDDD5C8),
                    const Color(0xFFDDD5C8).withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -2,
            top: 0,
            bottom: 0,
            child: Container(
              width: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFDDD5C8).withOpacity(0.3),
                    const Color(0xFFDDD5C8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Floor extends StatelessWidget {
  final double height;

  const _Floor({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        // Warm wood floor
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFD4A574), // Light wood
            Color(0xFFC49664), // Darker at bottom
          ],
        ),
      ),
      child: CustomPaint(
        painter: _WoodFloorPainter(),
      ),
    );
  }
}

class _WoodFloorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBE8C5A).withOpacity(0.3)
      ..strokeWidth = 1;

    // Wood plank lines
    const plankWidth = 60.0;
    for (var x = 0.0; x < size.width; x += plankWidth) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal grain lines
    final grainPaint = Paint()
      ..color = const Color(0xFFAA7744).withOpacity(0.15)
      ..strokeWidth = 0.5;

    for (var y = 0.0; y < size.height; y += 8) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grainPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TankStand extends StatelessWidget {
  final double width;
  final double height;

  const _TankStand({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // Dark wood cabinet
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF5D4037),
            Color(0xFF4E342E),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left door
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF6D4C41),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: const Color(0xFF8D6E63),
                  width: 1,
                ),
              ),
              child: Center(
                child: Container(
                  width: 6,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ),
          // Right door
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF6D4C41),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: const Color(0xFF8D6E63),
                  width: 1,
                ),
              ),
              child: Center(
                child: Container(
                  width: 6,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(1),
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

class _AquariumTank extends StatelessWidget {
  final double width;
  final double height;
  final String name;
  final double volume;

  const _AquariumTank({
    required this.width,
    required this.height,
    required this.name,
    required this.volume,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // Glass tank with water
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF7EC8E3).withOpacity(0.6), // Water surface
            const Color(0xFF5BA3C6).withOpacity(0.7),
            const Color(0xFF3D8EB9).withOpacity(0.8), // Deeper water
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.white.withOpacity(0.7),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5BA3C6).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Light from above/window reflection
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: width * 0.4,
              height: height * 0.3,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  colors: [
                    Colors.white.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(4),
                ),
              ),
            ),
          ),

          // Substrate (gravel/sand)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: height * 0.12,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFA08060),
                    Color(0xFF8B7355),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(2),
                  bottomRight: Radius.circular(2),
                ),
              ),
              child: CustomPaint(
                painter: _GravelPainter(),
              ),
            ),
          ),

          // Plants
          Positioned(
            bottom: height * 0.1,
            left: width * 0.08,
            child: _TankPlant(height: height * 0.45, lean: -0.1),
          ),
          Positioned(
            bottom: height * 0.1,
            left: width * 0.22,
            child: _TankPlant(height: height * 0.35, lean: 0.05, color: const Color(0xFF6B8E23)),
          ),
          Positioned(
            bottom: height * 0.1,
            right: width * 0.15,
            child: _TankPlant(height: height * 0.5, lean: 0.08),
          ),
          Positioned(
            bottom: height * 0.1,
            right: width * 0.3,
            child: _TankPlant(height: height * 0.3, lean: -0.05, color: const Color(0xFF8FBC8F)),
          ),

          // Driftwood
          Positioned(
            bottom: height * 0.1,
            left: width * 0.35,
            child: _Driftwood(width: width * 0.25),
          ),

          // Fish
          Positioned(
            top: height * 0.25,
            left: width * 0.2,
            child: _SwimmingFish(size: 18, color: Colors.orange),
          ),
          Positioned(
            top: height * 0.4,
            right: width * 0.25,
            child: _SwimmingFish(size: 14, color: Colors.red.shade300, flip: true),
          ),
          Positioned(
            top: height * 0.55,
            left: width * 0.5,
            child: _SwimmingFish(size: 12, color: Colors.blue.shade300),
          ),
          Positioned(
            top: height * 0.35,
            left: width * 0.6,
            child: _SwimmingFish(size: 16, color: Colors.yellow.shade600, flip: true),
          ),

          // Bubbles
          Positioned(
            right: width * 0.2,
            bottom: height * 0.2,
            child: _Bubbles(height: height * 0.5),
          ),

          // Water surface shimmer
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.5),
                    Colors.white.withOpacity(0.2),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(2),
                ),
              ),
            ),
          ),

          // Light fixture on top
          Positioned(
            top: -8,
            left: width * 0.2,
            right: width * 0.2,
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF2D3748),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
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
    final random = math.Random(42);
    final paint = Paint();

    for (var i = 0; i < 100; i++) {
      paint.color = Color.lerp(
        const Color(0xFF9E8B7D),
        const Color(0xFF7A6B5D),
        random.nextDouble(),
      )!;

      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        1 + random.nextDouble() * 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TankPlant extends StatelessWidget {
  final double height;
  final double lean;
  final Color color;

  const _TankPlant({
    required this.height,
    this.lean = 0,
    this.color = const Color(0xFF228B22),
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()..rotateZ(lean),
      child: CustomPaint(
        size: Size(height * 0.4, height),
        painter: _TankPlantPainter(color: color),
      ),
    );
  }
}

class _TankPlantPainter extends CustomPainter {
  final Color color;

  _TankPlantPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw multiple leaves
    for (var i = 0; i < 5; i++) {
      final leafPath = Path();
      final angle = (i - 2) * 0.2;
      final leafHeight = size.height * (0.7 + (i % 2) * 0.3);

      leafPath.moveTo(size.width / 2, size.height);
      leafPath.quadraticBezierTo(
        size.width / 2 + math.sin(angle) * size.width,
        size.height - leafHeight / 2,
        size.width / 2 + math.sin(angle) * size.width * 0.5,
        size.height - leafHeight,
      );
      leafPath.quadraticBezierTo(
        size.width / 2 - math.sin(angle) * size.width * 0.3,
        size.height - leafHeight / 2,
        size.width / 2,
        size.height,
      );

      canvas.drawPath(leafPath, paint);
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
      size: Size(width, width * 0.3),
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
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.3, size.width * 0.4, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.6, size.height * 0.2, size.width * 0.8, size.height * 0.4)
      ..lineTo(size.width, size.height * 0.3)
      ..lineTo(size.width * 0.9, size.height)
      ..lineTo(size.width * 0.1, size.height)
      ..close();

    canvas.drawPath(path, paint);

    // Wood grain
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF8D6E63)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SwimmingFish extends StatelessWidget {
  final double size;
  final Color color;
  final bool flip;

  const _SwimmingFish({
    required this.size,
    required this.color,
    this.flip = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flip ? -1 : 1,
      child: CustomPaint(
        size: Size(size * 1.8, size),
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
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Body
    final bodyPath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.1, size.width * 0.6, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.9, size.width * 0.1, size.height * 0.5);

    canvas.drawPath(bodyPath, paint);

    // Tail
    final tailPath = Path()
      ..moveTo(size.width * 0.55, size.height * 0.5)
      ..lineTo(size.width, size.height * 0.15)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.5, size.width, size.height * 0.85)
      ..close();

    canvas.drawPath(tailPath, paint);

    // Fin
    final finPath = Path()
      ..moveTo(size.width * 0.35, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.05, size.width * 0.5, size.height * 0.25)
      ..close();

    canvas.drawPath(finPath, paint..color = color.withOpacity(0.7));

    // Eye
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.4),
      size.width * 0.04,
      Paint()..color = Colors.black,
    );

    // Highlight
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.35),
      size.width * 0.06,
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
      size: Size(20, height),
      painter: _BubblesPainter(),
    );
  }
}

class _BubblesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final random = math.Random(77);
    for (var i = 0; i < 8; i++) {
      final radius = 2 + random.nextDouble() * 3;
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SideTable extends StatelessWidget {
  final double width;
  final double height;

  const _SideTable({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tabletop
        Container(
          width: width,
          height: height * 0.15,
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
        // Legs
        SizedBox(
          width: width,
          height: height * 0.85,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 6, color: const Color(0xFF6D4C41)),
              Container(width: 6, color: const Color(0xFF6D4C41)),
            ],
          ),
        ),
      ],
    );
  }
}

class _FloorPlant extends StatelessWidget {
  final double height;

  const _FloorPlant({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: height * 0.5,
      height: height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Pot
          Positioned(
            bottom: 0,
            child: Container(
              width: height * 0.3,
              height: height * 0.25,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFCD853F), Color(0xFFA0522D)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
            ),
          ),
          // Plant
          Positioned(
            bottom: height * 0.2,
            child: CustomPaint(
              size: Size(height * 0.5, height * 0.8),
              painter: _BigPlantPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BigPlantPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF228B22)
      ..style = PaintingStyle.fill;

    // Multiple large leaves
    for (var i = -2; i <= 2; i++) {
      final leafPath = Path();
      final angle = i * 0.4;
      final leafHeight = size.height * (0.6 + (i.abs() % 2) * 0.4);

      leafPath.moveTo(size.width / 2, size.height);
      leafPath.quadraticBezierTo(
        size.width / 2 + math.sin(angle) * size.width * 0.8,
        size.height - leafHeight * 0.6,
        size.width / 2 + math.sin(angle) * size.width * 0.5,
        size.height - leafHeight,
      );
      leafPath.quadraticBezierTo(
        size.width / 2,
        size.height - leafHeight * 0.6,
        size.width / 2,
        size.height,
      );

      canvas.drawPath(leafPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WallShelf extends StatelessWidget {
  final double width;
  final List<Widget> items;

  const _WallShelf({required this.width, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Items on shelf
        SizedBox(
          width: width,
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: items,
          ),
        ),
        // Shelf board
        Container(
          width: width,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFF8B7355),
            borderRadius: BorderRadius.circular(1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        // Brackets
        SizedBox(
          width: width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ShelfBracket(),
              _ShelfBracket(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShelfBracket extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(12, 12),
      painter: _BracketPainter(),
    );
  }
}

class _BracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6D4C41)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShelfItem extends StatelessWidget {
  final Widget child;

  const _ShelfItem({required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class _SmallPlantPot extends StatelessWidget {
  final double height;

  const _SmallPlantPot({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: height * 0.8,
      height: height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: height * 0.5,
            height: height * 0.4,
            decoration: BoxDecoration(
              color: const Color(0xFFCD853F),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Positioned(
            bottom: height * 0.35,
            child: Container(
              width: height * 0.3,
              height: height * 0.6,
              decoration: BoxDecoration(
                color: const Color(0xFF228B22),
                borderRadius: BorderRadius.circular(height * 0.15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookStack extends StatelessWidget {
  final double height;

  const _BookStack({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: height * 1.2,
      height: height,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: height * 0.9,
              height: height * 0.25,
              color: const Color(0xFF4A90A4),
            ),
          ),
          Positioned(
            bottom: height * 0.25,
            left: 4,
            child: Container(
              width: height * 0.85,
              height: height * 0.3,
              color: const Color(0xFFE8A87C),
            ),
          ),
          Positioned(
            bottom: height * 0.55,
            left: 2,
            child: Container(
              width: height * 0.8,
              height: height * 0.35,
              color: const Color(0xFF85C88A),
            ),
          ),
        ],
      ),
    );
  }
}

class _FramedPicture extends StatelessWidget {
  final double width;

  const _FramedPicture({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 1.2,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF8B7355),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          // Simple fish picture
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade200,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.set_meal,
            size: width * 0.4,
            color: Colors.orange.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}

class _Rug extends StatelessWidget {
  final double width;

  const _Rug({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 0.15,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B4513).withOpacity(0.6),
            const Color(0xFFCD853F).withOpacity(0.7),
            const Color(0xFF8B4513).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: CustomPaint(
        painter: _RugPatternPainter(),
      ),
    );
  }
}

class _RugPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDEB887).withOpacity(0.5)
      ..strokeWidth = 1;

    // Simple geometric pattern
    for (var x = 10.0; x < size.width - 10; x += 15) {
      canvas.drawLine(
        Offset(x, size.height * 0.3),
        Offset(x + 5, size.height * 0.7),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SleepingCat extends StatelessWidget {
  final double width;

  const _SleepingCat({required this.width});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, width * 0.5),
      painter: _CatPainter(),
    );
  }
}

class _CatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..style = PaintingStyle.fill;

    // Body (curled up oval)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.6),
        width: size.width * 0.8,
        height: size.height * 0.6,
      ),
      paint,
    );

    // Head
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.4),
      size.width * 0.18,
      paint,
    );

    // Ears
    final earPath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.3)
      ..lineTo(size.width * 0.05, size.height * 0.1)
      ..lineTo(size.width * 0.18, size.height * 0.25)
      ..close();
    canvas.drawPath(earPath, paint);

    final earPath2 = Path()
      ..moveTo(size.width * 0.25, size.height * 0.25)
      ..lineTo(size.width * 0.28, size.height * 0.05)
      ..lineTo(size.width * 0.35, size.height * 0.22)
      ..close();
    canvas.drawPath(earPath2, paint);

    // Tail
    final tailPath = Path()
      ..moveTo(size.width * 0.85, size.height * 0.5)
      ..quadraticBezierTo(
        size.width, size.height * 0.3,
        size.width * 0.9, size.height * 0.2,
      );
    canvas.drawPath(
      tailPath,
      Paint()
        ..color = paint.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
