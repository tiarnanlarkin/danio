import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

/// Soft and puffy room scene - minimal, warm, well-spaced objects
/// Inspired by cozy isometric 3D art style
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
  final VoidCallback? onLampTap;

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
    this.onLampTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight.isFinite 
            ? constraints.maxHeight 
            : w * 1.2;

        return Container(
          width: w,
          height: h,
          // Soft teal background (like the reference)
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF5D8A8C), // Muted teal top
                Color(0xFF4A7678), // Slightly darker bottom
              ],
            ),
          ),
          child: Stack(
            children: [
              // === FLOOR (warm wood checkered pattern) ===
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _SoftFloor(height: h * 0.35),
              ),

              // === WINDOW (back wall, soft glow) ===
              Positioned(
                top: h * 0.08,
                right: w * 0.08,
                child: _SoftWindow(
                  width: w * 0.28,
                  height: h * 0.22,
                ),
              ),

              // === WALL LAMP (warm glow) ===
              Positioned(
                top: h * 0.05,
                left: w * 0.15,
                child: GestureDetector(
                  onTap: onLampTap,
                  child: _HangingLamp(size: 40),
                ),
              ),

              // === SMALL SHELF with plant ===
              Positioned(
                top: h * 0.15,
                left: w * 0.05,
                child: GestureDetector(
                  onTap: onPlantTap,
                  child: _WallShelfWithPlant(width: w * 0.2),
                ),
              ),

              // === THE AQUARIUM (center focal point) ===
              Positioned(
                bottom: h * 0.32,
                left: w * 0.2,
                right: w * 0.2,
                child: GestureDetector(
                  onTap: onTankTap,
                  child: _SoftAquarium(
                    width: w * 0.6,
                    height: h * 0.28,
                    name: tankName,
                  ),
                ),
              ),

              // === CABINET under tank ===
              Positioned(
                bottom: h * 0.22,
                left: w * 0.22,
                right: w * 0.22,
                child: _SoftCabinet(
                  width: w * 0.56,
                  height: h * 0.11,
                ),
              ),

              // === FLOOR LAMP (right side, warm glow) ===
              Positioned(
                bottom: h * 0.25,
                right: w * 0.06,
                child: GestureDetector(
                  onTap: onLampTap,
                  child: _FloorLamp(height: h * 0.22),
                ),
              ),

              // === SIDE TABLE with books (left) ===
              Positioned(
                bottom: h * 0.22,
                left: w * 0.02,
                child: GestureDetector(
                  onTap: onBookTap,
                  child: _SideTableWithBooks(width: w * 0.16),
                ),
              ),

              // === SMALL RUG (front) ===
              Positioned(
                bottom: h * 0.12,
                left: w * 0.28,
                right: w * 0.28,
                child: _SoftRug(width: w * 0.44),
              ),

              // === FOOD JAR (on floor, right of rug) ===
              Positioned(
                bottom: h * 0.14,
                right: w * 0.2,
                child: GestureDetector(
                  onTap: onFoodTap,
                  child: _SoftFoodJar(size: 45),
                ),
              ),

              // === TEST KIT (on floor, left of rug) ===
              Positioned(
                bottom: h * 0.13,
                left: w * 0.18,
                child: GestureDetector(
                  onTap: onTestKitTap,
                  child: _SoftTestKit(size: 50),
                ),
              ),

              // === SMALL PLANT POT (corner) ===
              Positioned(
                bottom: h * 0.24,
                right: w * 0.32,
                child: _SmallPlantPot(size: 35),
              ),
            ],
          ),
        );
      },
    );
  }
}

// === SOFT FLOOR ===

class _SoftFloor extends StatelessWidget {
  final double height;

  const _SoftFloor({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8D4B8), // Warm light wood
            Color(0xFFD4C4A8), // Slightly darker
          ],
        ),
      ),
      child: CustomPaint(
        painter: _CheckeredFloorPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _CheckeredFloorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final lightPaint = Paint()..color = const Color(0xFFEEDDCC);
    final darkPaint = Paint()..color = const Color(0xFFDDCCBB);
    
    const tileSize = 40.0;
    
    for (var y = 0.0; y < size.height; y += tileSize) {
      for (var x = 0.0; x < size.width; x += tileSize) {
        final isLight = ((x ~/ tileSize) + (y ~/ tileSize)) % 2 == 0;
        canvas.drawRect(
          Rect.fromLTWH(x, y, tileSize, tileSize),
          isLight ? lightPaint : darkPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// === SOFT WINDOW ===

class _SoftWindow extends StatelessWidget {
  final double width;
  final double height;

  const _SoftWindow({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // Dark window (nighttime like reference)
        color: const Color(0xFF3D5A5C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B7355),
          width: 6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Window panes
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A6B6D),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A6B6D),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Curtain (one side)
          Positioned(
            right: -5,
            top: 0,
            bottom: 0,
            child: Container(
              width: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF6B8B8D).withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// === HANGING LAMP (warm glow) ===

class _HangingLamp extends StatelessWidget {
  final double size;

  const _HangingLamp({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.5,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Cord
          Positioned(
            top: 0,
            child: Container(
              width: 2,
              height: size * 0.4,
              color: const Color(0xFF5D4037),
            ),
          ),
          // Lamp shade (soft, puffy)
          Positioned(
            top: size * 0.35,
            child: Container(
              width: size,
              height: size * 0.6,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFE4B5),
                    Color(0xFFFFD700),
                  ],
                ),
                borderRadius: BorderRadius.circular(size * 0.3),
                boxShadow: [
                  // Warm glow
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
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

// === WALL SHELF WITH PLANT ===

class _WallShelfWithPlant extends StatelessWidget {
  final double width;

  const _WallShelfWithPlant({required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * 0.8,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Shelf bracket
          Positioned(
            bottom: 0,
            child: Container(
              width: width,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF8B7355),
                borderRadius: BorderRadius.circular(4),
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
          // Soft plant pot
          Positioned(
            bottom: 10,
            child: _SoftPlantPot(size: width * 0.6),
          ),
        ],
      ),
    );
  }
}

// === SOFT PLANT POT ===

class _SoftPlantPot extends StatelessWidget {
  final double size;

  const _SoftPlantPot({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.3,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Pot (soft, rounded)
          Positioned(
            bottom: 0,
            child: Container(
              width: size * 0.7,
              height: size * 0.5,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFD2691E),
                    Color(0xFFA0522D),
                  ],
                ),
                borderRadius: BorderRadius.circular(size * 0.15),
              ),
            ),
          ),
          // Plant (soft blob shapes)
          Positioned(
            bottom: size * 0.4,
            child: _SoftPlantLeaves(size: size * 0.9),
          ),
        ],
      ),
    );
  }
}

class _SoftPlantLeaves extends StatelessWidget {
  final double size;

  const _SoftPlantLeaves({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.8,
      child: Stack(
        children: [
          // Center leaf
          Positioned(
            left: size * 0.35,
            bottom: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.7,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(size * 0.15),
              ),
            ),
          ),
          // Left leaf
          Positioned(
            left: size * 0.1,
            bottom: size * 0.1,
            child: Transform.rotate(
              angle: -0.4,
              child: Container(
                width: size * 0.25,
                height: size * 0.5,
                decoration: BoxDecoration(
                  color: const Color(0xFF66BB6A),
                  borderRadius: BorderRadius.circular(size * 0.12),
                ),
              ),
            ),
          ),
          // Right leaf
          Positioned(
            right: size * 0.1,
            bottom: size * 0.1,
            child: Transform.rotate(
              angle: 0.4,
              child: Container(
                width: size * 0.25,
                height: size * 0.5,
                decoration: BoxDecoration(
                  color: const Color(0xFF81C784),
                  borderRadius: BorderRadius.circular(size * 0.12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// === THE SOFT AQUARIUM ===

class _SoftAquarium extends StatelessWidget {
  final double width;
  final double height;
  final String name;

  const _SoftAquarium({
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
        // Soft water gradient
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF7EC8D8), // Light aqua
            Color(0xFF5BA8B8), // Teal
            Color(0xFF4A98A8), // Deeper
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 4,
        ),
        boxShadow: [
          // Soft glow
          BoxShadow(
            color: const Color(0xFF5BA8B8).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Soft sand at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: height * 0.18,
              decoration: BoxDecoration(
                color: const Color(0xFFD4B896),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
            ),
          ),

          // Simple soft plant (left)
          Positioned(
            bottom: height * 0.15,
            left: width * 0.08,
            child: _SoftAquaPlant(height: height * 0.45),
          ),

          // Simple soft plant (right)
          Positioned(
            bottom: height * 0.15,
            right: width * 0.12,
            child: _SoftAquaPlant(height: height * 0.35, color: const Color(0xFF81C784)),
          ),

          // Soft fish (just 2-3, simple shapes)
          Positioned(
            top: height * 0.25,
            left: width * 0.25,
            child: _SoftFish(size: 22, color: const Color(0xFFFFB74D)),
          ),
          Positioned(
            top: height * 0.45,
            right: width * 0.25,
            child: _SoftFish(size: 18, color: const Color(0xFFEF5350), flip: true),
          ),

          // Bubbles (just a few)
          Positioned(
            right: width * 0.2,
            bottom: height * 0.25,
            child: _SoftBubbles(height: height * 0.4),
          ),

          // Light reflection on top
          Positioned(
            top: 4,
            left: 4,
            right: 4,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftAquaPlant extends StatelessWidget {
  final double height;
  final Color color;

  const _SoftAquaPlant({
    required this.height,
    this.color = const Color(0xFF4CAF50),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: height * 0.5,
      height: height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Main leaf
          Positioned(
            bottom: 0,
            child: Container(
              width: height * 0.2,
              height: height * 0.9,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(height * 0.1),
              ),
            ),
          ),
          // Side leaf left
          Positioned(
            bottom: height * 0.2,
            left: 0,
            child: Transform.rotate(
              angle: -0.5,
              child: Container(
                width: height * 0.15,
                height: height * 0.5,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(height * 0.08),
                ),
              ),
            ),
          ),
          // Side leaf right
          Positioned(
            bottom: height * 0.3,
            right: 0,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                width: height * 0.15,
                height: height * 0.4,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(height * 0.08),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftFish extends StatelessWidget {
  final double size;
  final Color color;
  final bool flip;

  const _SoftFish({
    required this.size,
    required this.color,
    this.flip = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flip ? -1 : 1,
      child: SizedBox(
        width: size * 1.6,
        height: size,
        child: Stack(
          children: [
            // Body (soft oval)
            Positioned(
              left: 0,
              top: size * 0.15,
              child: Container(
                width: size * 1.1,
                height: size * 0.7,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(size * 0.35),
                ),
              ),
            ),
            // Tail (soft triangle)
            Positioned(
              right: 0,
              top: size * 0.2,
              child: Container(
                width: size * 0.5,
                height: size * 0.6,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(size * 0.15),
                ),
              ),
            ),
            // Eye
            Positioned(
              left: size * 0.2,
              top: size * 0.35,
              child: Container(
                width: size * 0.2,
                height: size * 0.2,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: size * 0.1,
                    height: size * 0.1,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
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

class _SoftBubbles extends StatelessWidget {
  final double height;

  const _SoftBubbles({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

// === SOFT CABINET ===

class _SoftCabinet extends StatelessWidget {
  final double width;
  final double height;

  const _SoftCabinet({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF8B7355),
            Color(0xFF6D5A47),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left drawer
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF9E8B7A),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Container(
                  width: 12,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          // Right drawer
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF9E8B7A),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Container(
                  width: 12,
                  height: 6,
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

// === FLOOR LAMP ===

class _FloorLamp extends StatelessWidget {
  final double height;

  const _FloorLamp({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: height * 0.4,
      height: height,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Lamp shade (glowing)
          Positioned(
            top: 0,
            child: Container(
              width: height * 0.35,
              height: height * 0.3,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFE4B5),
                    Color(0xFFFFD54F),
                  ],
                ),
                borderRadius: BorderRadius.circular(height * 0.08),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.6),
                    blurRadius: 40,
                    spreadRadius: 15,
                  ),
                ],
              ),
            ),
          ),
          // Stand
          Positioned(
            top: height * 0.28,
            child: Container(
              width: 6,
              height: height * 0.6,
              decoration: BoxDecoration(
                color: const Color(0xFF5D4037),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          // Base
          Positioned(
            bottom: 0,
            child: Container(
              width: height * 0.25,
              height: height * 0.08,
              decoration: BoxDecoration(
                color: const Color(0xFF5D4037),
                borderRadius: BorderRadius.circular(height * 0.04),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// === SIDE TABLE WITH BOOKS ===

class _SideTableWithBooks extends StatelessWidget {
  final double width;

  const _SideTableWithBooks({required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * 1.1,
      child: Stack(
        children: [
          // Table body
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: width * 0.8,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFD2B48C),
                    Color(0xFFC4A67C),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(2, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Spacer(),
                  // Drawer
                  Container(
                    margin: const EdgeInsets.all(6),
                    height: width * 0.25,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8D8C8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Container(
                        width: 10,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
          // Books on top
          Positioned(
            bottom: width * 0.78,
            left: width * 0.15,
            child: _SoftBookStack(width: width * 0.7),
          ),
          // Small lamp
          Positioned(
            bottom: width * 0.85,
            right: width * 0.1,
            child: _TinyLamp(size: width * 0.35),
          ),
        ],
      ),
    );
  }
}

class _SoftBookStack extends StatelessWidget {
  final double width;

  const _SoftBookStack({required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * 0.4,
      child: Stack(
        children: [
          // Bottom book
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: width * 0.8,
              height: width * 0.15,
              decoration: BoxDecoration(
                color: const Color(0xFF5D8AA8),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          // Middle book
          Positioned(
            bottom: width * 0.12,
            left: width * 0.05,
            child: Container(
              width: width * 0.7,
              height: width * 0.15,
              decoration: BoxDecoration(
                color: const Color(0xFFE8A87C),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          // Top book
          Positioned(
            bottom: width * 0.24,
            left: width * 0.1,
            child: Container(
              width: width * 0.6,
              height: width * 0.12,
              decoration: BoxDecoration(
                color: const Color(0xFF85C88A),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyLamp extends StatelessWidget {
  final double size;

  const _TinyLamp({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.2,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Base
          Positioned(
            bottom: 0,
            child: Container(
              width: size * 0.5,
              height: size * 0.15,
              decoration: BoxDecoration(
                color: const Color(0xFF8B7355),
                borderRadius: BorderRadius.circular(size * 0.08),
              ),
            ),
          ),
          // Stem
          Positioned(
            bottom: size * 0.1,
            child: Container(
              width: size * 0.12,
              height: size * 0.5,
              decoration: BoxDecoration(
                color: const Color(0xFF8B7355),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Shade (glowing)
          Positioned(
            top: 0,
            child: Container(
              width: size * 0.7,
              height: size * 0.5,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4B5),
                borderRadius: BorderRadius.circular(size * 0.15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 8,
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

// === SOFT RUG ===

class _SoftRug extends StatelessWidget {
  final double width;

  const _SoftRug({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 0.25,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFB39DDB).withOpacity(0.6),
            const Color(0xFF9575CD).withOpacity(0.7),
            const Color(0xFFB39DDB).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(width * 0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _SoftRugPatternPainter(),
      ),
    );
  }
}

class _SoftRugPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7E57C2).withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Simple decorative border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 6, size.width - 20, size.height - 12),
        const Radius.circular(8),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// === SOFT FOOD JAR ===

class _SoftFoodJar extends StatelessWidget {
  final double size;

  const _SoftFoodJar({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 0.6,
      height: size,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Jar body
          Positioned(
            bottom: 0,
            child: Container(
              width: size * 0.5,
              height: size * 0.7,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(size * 0.1),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  const Spacer(),
                  // Food inside
                  Container(
                    margin: const EdgeInsets.all(4),
                    height: size * 0.35,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8A87C),
                      borderRadius: BorderRadius.circular(size * 0.06),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Lid
          Positioned(
            top: size * 0.15,
            child: Container(
              width: size * 0.55,
              height: size * 0.18,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(size * 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// === SOFT TEST KIT ===

class _SoftTestKit extends StatelessWidget {
  final double size;

  const _SoftTestKit({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.7,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF455A64),
        borderRadius: BorderRadius.circular(10),
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
          _SoftTestTube(height: size * 0.5, color: const Color(0xFF81C784)),
          _SoftTestTube(height: size * 0.5, color: const Color(0xFFFFF176)),
          _SoftTestTube(height: size * 0.5, color: const Color(0xFFCE93D8)),
          _SoftTestTube(height: size * 0.5, color: const Color(0xFFFFB74D)),
        ],
      ),
    );
  }
}

class _SoftTestTube extends StatelessWidget {
  final double height;
  final Color color;

  const _SoftTestTube({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: height * 0.35,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(height * 0.15),
      ),
      child: Column(
        children: [
          const Spacer(),
          Container(
            height: height * 0.55,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(height * 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

// === SMALL PLANT POT ===

class _SmallPlantPot extends StatelessWidget {
  final double size;

  const _SmallPlantPot({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.2,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Pot
          Positioned(
            bottom: 0,
            child: Container(
              width: size * 0.6,
              height: size * 0.4,
              decoration: BoxDecoration(
                color: const Color(0xFFCD853F),
                borderRadius: BorderRadius.circular(size * 0.1),
              ),
            ),
          ),
          // Plant (simple blob)
          Positioned(
            bottom: size * 0.35,
            child: Container(
              width: size * 0.5,
              height: size * 0.6,
              decoration: BoxDecoration(
                color: const Color(0xFF66BB6A),
                borderRadius: BorderRadius.circular(size * 0.25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
