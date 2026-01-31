import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../theme/app_theme.dart';

/// Hybrid room scene: cozy illustration + glassmorphic UI overlays
/// Combines warm room aesthetic with modern app elements
class LivingRoomScene extends StatelessWidget {
  final String tankName;
  final double tankVolume;
  final double? temperature;
  final double? ph;
  final double? ammonia;
  final double? nitrate;
  final VoidCallback? onTankTap;
  final VoidCallback? onTestKitTap;
  final VoidCallback? onFoodTap;
  final VoidCallback? onPlantTap;
  final VoidCallback? onStatsTap;

  const LivingRoomScene({
    super.key,
    required this.tankName,
    required this.tankVolume,
    this.temperature,
    this.ph,
    this.ammonia,
    this.nitrate,
    this.onTankTap,
    this.onTestKitTap,
    this.onFoodTap,
    this.onPlantTap,
    this.onStatsTap,
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
              // === LAYER 1: Abstract organic background ===
              Positioned.fill(
                child: _OrganicBackground(),
              ),

              // === LAYER 2: Room scene ===
              Positioned.fill(
                child: _RoomScene(
                  tankName: tankName,
                  onTankTap: onTankTap,
                  onPlantTap: onPlantTap,
                ),
              ),

              // === LAYER 3: Glassmorphic UI overlays ===
              
              // Temperature card (top left)
              Positioned(
                top: h * 0.08,
                left: w * 0.04,
                child: GestureDetector(
                  onTap: onStatsTap,
                  child: _GlassCard(
                    width: w * 0.28,
                    height: 70,
                    child: _TempDisplay(temperature: temperature),
                  ),
                ),
              ),

              // Water params card (top right)
              Positioned(
                top: h * 0.08,
                right: w * 0.04,
                child: GestureDetector(
                  onTap: onTestKitTap,
                  child: _GlassCard(
                    width: w * 0.32,
                    height: 85,
                    child: _WaterParamsDisplay(ph: ph, ammonia: ammonia, nitrate: nitrate),
                  ),
                ),
              ),

              // Quick actions (bottom)
              Positioned(
                bottom: h * 0.03,
                left: w * 0.05,
                right: w * 0.05,
                child: _QuickActionsBar(
                  onFoodTap: onFoodTap,
                  onTestKitTap: onTestKitTap,
                  onPlantTap: onPlantTap,
                ),
              ),

              // Tank name badge (floating near tank)
              Positioned(
                bottom: h * 0.38,
                left: w * 0.5 - 60,
                child: _GlassBadge(
                  text: tankName,
                  subtext: '${tankVolume.toStringAsFixed(0)}L',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// === ORGANIC BACKGROUND ===

class _OrganicBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6B9B9B), // Sage/teal
            Color(0xFF5A8A8A),
            Color(0xFF4A7A7A),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _OrganicShapesPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _OrganicShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Flowing organic shapes like in the UI reference
    
    // Large teal wave (top)
    final wave1 = Path()
      ..moveTo(0, size.height * 0.15)
      ..quadraticBezierTo(
        size.width * 0.3, size.height * 0.05,
        size.width * 0.5, size.height * 0.12,
      )
      ..quadraticBezierTo(
        size.width * 0.8, size.height * 0.22,
        size.width, size.height * 0.1,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    
    canvas.drawPath(
      wave1,
      Paint()..color = const Color(0xFF5D8888).withOpacity(0.5),
    );

    // Coral/terracotta blob (right side)
    final blob1 = Path()
      ..moveTo(size.width * 0.85, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 1.1, size.height * 0.4,
        size.width * 0.95, size.height * 0.55,
      )
      ..quadraticBezierTo(
        size.width * 0.75, size.height * 0.5,
        size.width * 0.85, size.height * 0.3,
      );

    canvas.drawPath(
      blob1,
      Paint()..color = const Color(0xFFD4A574).withOpacity(0.3),
    );

    // Sage wave (bottom)
    final wave2 = Path()
      ..moveTo(0, size.height * 0.85)
      ..quadraticBezierTo(
        size.width * 0.25, size.height * 0.78,
        size.width * 0.5, size.height * 0.88,
      )
      ..quadraticBezierTo(
        size.width * 0.75, size.height * 0.95,
        size.width, size.height * 0.82,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      wave2,
      Paint()..color = const Color(0xFF4A6B6B).withOpacity(0.4),
    );

    // Small accent circles
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.25),
      20,
      Paint()..color = const Color(0xFFE8A87C).withOpacity(0.2),
    );
    canvas.drawCircle(
      Offset(size.width * 0.92, size.height * 0.7),
      15,
      Paint()..color = const Color(0xFF7FCDCD).withOpacity(0.3),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// === ROOM SCENE ===

class _RoomScene extends StatelessWidget {
  final String tankName;
  final VoidCallback? onTankTap;
  final VoidCallback? onPlantTap;

  const _RoomScene({
    required this.tankName,
    this.onTankTap,
    this.onPlantTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          children: [
            // Floor (warm wood)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _WarmFloor(height: h * 0.32),
            ),

            // Wall accent (subtle)
            Positioned(
              top: h * 0.18,
              left: 0,
              right: 0,
              child: Container(
                height: h * 0.52,
                color: const Color(0xFFF5EDE0).withOpacity(0.15),
              ),
            ),

            // Window (right side, with proper detail)
            Positioned(
              top: h * 0.12,
              right: w * 0.06,
              child: _DetailedWindow(width: w * 0.22, height: h * 0.2),
            ),

            // Floor plant (left corner - detailed)
            Positioned(
              bottom: h * 0.28,
              left: w * 0.02,
              child: GestureDetector(
                onTap: onPlantTap,
                child: _DetailedPlant(height: h * 0.18),
              ),
            ),

            // Side table with lamp (left)
            Positioned(
              bottom: h * 0.28,
              left: w * 0.14,
              child: _SideTableWithLamp(width: w * 0.14),
            ),

            // THE AQUARIUM (center focal point)
            Positioned(
              bottom: h * 0.28,
              left: w * 0.32,
              right: w * 0.18,
              child: GestureDetector(
                onTap: onTankTap,
                child: _DetailedAquarium(
                  width: w * 0.5,
                  height: h * 0.26,
                ),
              ),
            ),

            // Tank stand
            Positioned(
              bottom: h * 0.2,
              left: w * 0.33,
              right: w * 0.19,
              child: _TankStand(width: w * 0.48, height: h * 0.09),
            ),

            // Small shelf with items (right of tank)
            Positioned(
              bottom: h * 0.35,
              right: w * 0.04,
              child: _SmallShelf(width: w * 0.12),
            ),

            // Cozy rug (front center)
            Positioned(
              bottom: h * 0.08,
              left: w * 0.25,
              right: w * 0.25,
              child: _DetailedRug(width: w * 0.5),
            ),

            // Small plant pot (right of rug)
            Positioned(
              bottom: h * 0.12,
              right: w * 0.18,
              child: _SmallPottedPlant(size: 40),
            ),
          ],
        );
      },
    );
  }
}

// === DETAILED ROOM ELEMENTS ===

class _WarmFloor extends StatelessWidget {
  final double height;

  const _WarmFloor({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFDEC4A8),
            Color(0xFFCEB498),
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
    final plankPaint = Paint()
      ..color = const Color(0xFFC4A888).withOpacity(0.3)
      ..strokeWidth = 1;

    // Planks
    const plankWidth = 45.0;
    for (var x = 0.0; x < size.width; x += plankWidth) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), plankPaint);
    }

    // Wood grain details
    final grainPaint = Paint()
      ..color = const Color(0xFFB89878).withOpacity(0.15)
      ..strokeWidth = 0.5;

    final random = math.Random(42);
    for (var i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final length = 20 + random.nextDouble() * 40;
      canvas.drawLine(Offset(x, y), Offset(x + length, y + 2), grainPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DetailedWindow extends StatelessWidget {
  final double width;
  final double height;

  const _DetailedWindow({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Window frame top
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF8B7355),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
          ),
          // Window panes
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Expanded(child: _WindowPane()),
                  const SizedBox(width: 4),
                  Expanded(child: _WindowPane()),
                ],
              ),
            ),
          ),
          // Window sill
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFF8B7355),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WindowPane extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        // Sky gradient (soft evening)
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFB8D4E8),
            Color(0xFFE8D8C8),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF8B7355), width: 3),
      ),
      child: Stack(
        children: [
          // Light glow
          Positioned(
            top: 5,
            right: 5,
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailedPlant extends StatelessWidget {
  final double height;

  const _DetailedPlant({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: height * 0.7,
      height: height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Pot
          Positioned(
            bottom: 0,
            child: Container(
              width: height * 0.4,
              height: height * 0.28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFCD8B65), Color(0xFFA66B45)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  // Pot rim
                  Positioned(
                    top: 0,
                    left: -4,
                    right: -4,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB87B55),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // Soil
                  Positioned(
                    top: 6,
                    left: 4,
                    right: 4,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5D4037),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Leaves (more detailed)
          Positioned(
            bottom: height * 0.22,
            child: CustomPaint(
              size: Size(height * 0.7, height * 0.7),
              painter: _DetailedLeavesPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailedLeavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final leafColors = [
      const Color(0xFF4CAF50),
      const Color(0xFF388E3C),
      const Color(0xFF66BB6A),
      const Color(0xFF2E7D32),
    ];

    // Draw multiple detailed leaves
    for (var i = 0; i < 6; i++) {
      final angle = (i - 2.5) * 0.35;
      final leafHeight = size.height * (0.5 + (i % 3) * 0.2);
      final color = leafColors[i % leafColors.length];

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final leafPath = Path()
        ..moveTo(size.width / 2, size.height)
        ..quadraticBezierTo(
          size.width / 2 + math.sin(angle) * size.width * 0.5,
          size.height - leafHeight * 0.4,
          size.width / 2 + math.sin(angle) * size.width * 0.35,
          size.height - leafHeight,
        )
        ..quadraticBezierTo(
          size.width / 2 + math.sin(angle) * size.width * 0.15,
          size.height - leafHeight * 0.5,
          size.width / 2,
          size.height,
        );

      canvas.drawPath(leafPath, paint);

      // Leaf vein
      final veinPaint = Paint()
        ..color = const Color(0xFF1B5E20).withOpacity(0.3)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(size.width / 2, size.height),
        Offset(
          size.width / 2 + math.sin(angle) * size.width * 0.25,
          size.height - leafHeight * 0.7,
        ),
        veinPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SideTableWithLamp extends StatelessWidget {
  final double width;

  const _SideTableWithLamp({required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * 1.5,
      child: Stack(
        children: [
          // Table
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
                  colors: [Color(0xFFD2B48C), Color(0xFFC4A67C)],
                ),
                borderRadius: BorderRadius.circular(8),
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
                    margin: const EdgeInsets.fromLTRB(6, 0, 6, 8),
                    height: width * 0.22,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8D8C8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Container(
                        width: 12,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Lamp
          Positioned(
            bottom: width * 0.78,
            left: width * 0.25,
            child: _TableLamp(size: width * 0.5),
          ),
        ],
      ),
    );
  }
}

class _TableLamp extends StatelessWidget {
  final double size;

  const _TableLamp({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.4,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Base
          Positioned(
            bottom: 0,
            child: Container(
              width: size * 0.5,
              height: size * 0.12,
              decoration: BoxDecoration(
                color: const Color(0xFF6D5A47),
                borderRadius: BorderRadius.circular(size * 0.06),
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
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B7355), Color(0xFF6D5A47)],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          // Shade (with warm glow)
          Positioned(
            top: 0,
            child: Container(
              width: size * 0.8,
              height: size * 0.55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF8E7), Color(0xFFFFE4B5)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 0.1),
                  topRight: Radius.circular(size * 0.1),
                  bottomLeft: Radius.circular(size * 0.3),
                  bottomRight: Radius.circular(size * 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                    blurRadius: 25,
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

class _DetailedAquarium extends StatelessWidget {
  final double width;
  final double height;

  const _DetailedAquarium({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          // Ambient glow
          BoxShadow(
            color: const Color(0xFF5BA8B8).withOpacity(0.4),
            blurRadius: 25,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Water gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF7ECACA),
                    Color(0xFF5AABAB),
                    Color(0xFF4A9898),
                  ],
                ),
              ),
            ),

            // Glass frame
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.6),
                    width: 4,
                  ),
                ),
              ),
            ),

            // Substrate with detail
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: height * 0.18,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFBEA882), Color(0xFFA89070)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: CustomPaint(painter: _SubstratePainter()),
              ),
            ),

            // Driftwood
            Positioned(
              bottom: height * 0.14,
              left: width * 0.35,
              child: _Driftwood(width: width * 0.25),
            ),

            // Plants (more detailed)
            Positioned(
              bottom: height * 0.15,
              left: width * 0.06,
              child: _AquariumPlant(height: height * 0.5, type: 'tall'),
            ),
            Positioned(
              bottom: height * 0.15,
              left: width * 0.2,
              child: _AquariumPlant(height: height * 0.35, type: 'medium'),
            ),
            Positioned(
              bottom: height * 0.15,
              right: width * 0.08,
              child: _AquariumPlant(height: height * 0.55, type: 'tall'),
            ),
            Positioned(
              bottom: height * 0.15,
              right: width * 0.25,
              child: _AquariumPlant(height: height * 0.3, type: 'short'),
            ),

            // Fish (detailed)
            Positioned(
              top: height * 0.2,
              left: width * 0.2,
              child: _DetailedFish(size: 22, color: const Color(0xFFFF8A65)),
            ),
            Positioned(
              top: height * 0.4,
              right: width * 0.2,
              child: _DetailedFish(size: 18, color: const Color(0xFFE57373), flip: true),
            ),
            Positioned(
              top: height * 0.55,
              left: width * 0.45,
              child: _DetailedFish(size: 16, color: const Color(0xFF64B5F6)),
            ),

            // Bubbles
            Positioned(
              right: width * 0.15,
              bottom: height * 0.2,
              child: _DetailedBubbles(height: height * 0.45),
            ),

            // Light reflection
            Positioned(
              top: 4,
              left: 4,
              right: 4,
              child: Container(
                height: 15,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.35),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ),
            ),

            // LED light bar
            Positioned(
              top: -6,
              left: width * 0.2,
              right: width * 0.2,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF37474F),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubstratePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(77);
    final colors = [
      const Color(0xFFAA9070),
      const Color(0xFF9A8060),
      const Color(0xFFB8A080),
    ];

    for (var i = 0; i < 80; i++) {
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
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.2, size.width * 0.4, size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.6, size.height * 0.15, size.width * 0.85, size.height * 0.35)
      ..lineTo(size.width, size.height * 0.3)
      ..lineTo(size.width * 0.9, size.height)
      ..lineTo(size.width * 0.1, size.height)
      ..close();

    canvas.drawPath(path, paint);

    // Wood texture
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

class _AquariumPlant extends StatelessWidget {
  final double height;
  final String type;

  const _AquariumPlant({required this.height, required this.type});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(height * 0.4, height),
      painter: _AquariumPlantPainter(type: type),
    );
  }
}

class _AquariumPlantPainter extends CustomPainter {
  final String type;

  _AquariumPlantPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = type == 'tall'
        ? [const Color(0xFF388E3C), const Color(0xFF2E7D32)]
        : type == 'medium'
            ? [const Color(0xFF4CAF50), const Color(0xFF388E3C)]
            : [const Color(0xFF66BB6A), const Color(0xFF4CAF50)];

    for (var i = 0; i < 5; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      final angle = (i - 2) * 0.25;
      final leafHeight = size.height * (0.6 + (i % 2) * 0.35);

      final path = Path()
        ..moveTo(size.width / 2, size.height)
        ..quadraticBezierTo(
          size.width / 2 + math.sin(angle) * size.width * 0.8,
          size.height - leafHeight * 0.5,
          size.width / 2 + math.sin(angle) * size.width * 0.5,
          size.height - leafHeight,
        )
        ..quadraticBezierTo(
          size.width / 2,
          size.height - leafHeight * 0.6,
          size.width / 2,
          size.height,
        );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DetailedFish extends StatelessWidget {
  final double size;
  final Color color;
  final bool flip;

  const _DetailedFish({
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
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.1, size.width * 0.6, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.9, size.width * 0.1, size.height * 0.5);

    canvas.drawPath(bodyPath, paint);

    // Tail
    final tailPath = Path()
      ..moveTo(size.width * 0.55, size.height * 0.5)
      ..lineTo(size.width * 0.95, size.height * 0.15)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.5, size.width * 0.95, size.height * 0.85)
      ..close();

    canvas.drawPath(tailPath, paint);

    // Fin
    final finPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.38, size.height * 0.05, size.width * 0.45, size.height * 0.2)
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
      size.width * 0.025,
      Paint()..color = Colors.black,
    );

    // Highlight
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.28, size.height * 0.35),
        width: size.width * 0.1,
        height: size.width * 0.05,
      ),
      Paint()..color = Colors.white.withOpacity(0.3),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DetailedBubbles extends StatelessWidget {
  final double height;

  const _DetailedBubbles({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 25,
      height: height,
      child: CustomPaint(painter: _BubblesPainter()),
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
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final positions = [
      Offset(10, size.height * 0.1),
      Offset(5, size.height * 0.3),
      Offset(15, size.height * 0.5),
      Offset(8, size.height * 0.7),
      Offset(18, size.height * 0.85),
    ];

    final sizes = [4.0, 3.0, 5.0, 3.5, 6.0];

    for (var i = 0; i < positions.length; i++) {
      canvas.drawCircle(positions[i], sizes[i], paint);
      canvas.drawCircle(positions[i], sizes[i], strokePaint);
      // Highlight
      canvas.drawCircle(
        Offset(positions[i].dx - sizes[i] * 0.3, positions[i].dy - sizes[i] * 0.3),
        sizes[i] * 0.25,
        Paint()..color = Colors.white.withOpacity(0.6),
      );
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
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6D5A47), Color(0xFF5D4A37)],
        ),
        borderRadius: BorderRadius.circular(8),
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
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF7D6A57),
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
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF7D6A57),
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
          ),
        ],
      ),
    );
  }
}

class _SmallShelf extends StatelessWidget {
  final double width;

  const _SmallShelf({required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * 1.2,
      child: Stack(
        children: [
          // Shelf
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF8B7355),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          // Items on shelf
          Positioned(
            bottom: 6,
            left: 4,
            child: Container(
              width: width * 0.35,
              height: width * 0.5,
              decoration: BoxDecoration(
                color: const Color(0xFFE57373), // Food jar
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(
            bottom: 6,
            right: 4,
            child: Container(
              width: width * 0.3,
              height: width * 0.4,
              decoration: BoxDecoration(
                color: const Color(0xFF4DB6AC), // Test bottle
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailedRug extends StatelessWidget {
  final double width;

  const _DetailedRug({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 35,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE8A87C).withOpacity(0.7),
            const Color(0xFFD4956C).withOpacity(0.8),
            const Color(0xFFE8A87C).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(painter: _RugPatternPainter()),
    );
  }
}

class _RugPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBF7B4C).withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Border pattern
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, 6, size.width - 16, size.height - 12),
        const Radius.circular(12),
      ),
      paint,
    );

    // Inner details
    for (var x = 20.0; x < size.width - 20; x += 25) {
      canvas.drawLine(
        Offset(x, size.height * 0.35),
        Offset(x + 10, size.height * 0.65),
        paint..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SmallPottedPlant extends StatelessWidget {
  final double size;

  const _SmallPottedPlant({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.3,
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
                gradient: const LinearGradient(
                  colors: [Color(0xFFCD8B65), Color(0xFFA66B45)],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          // Plant (simple but detailed)
          Positioned(
            bottom: size * 0.35,
            child: Container(
              width: size * 0.5,
              height: size * 0.7,
              decoration: BoxDecoration(
                color: const Color(0xFF66BB6A),
                borderRadius: BorderRadius.circular(size * 0.2),
              ),
            ),
          ),
          // Second leaf
          Positioned(
            bottom: size * 0.4,
            left: size * 0.1,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: size * 0.3,
                height: size * 0.5,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(size * 0.15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// === GLASSMORPHIC UI ELEMENTS ===

class _GlassCard extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;

  const _GlassCard({
    required this.width,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _TempDisplay extends StatelessWidget {
  final double? temperature;

  const _TempDisplay({this.temperature});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Temp circle indicator
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFE8A87C),
                const Color(0xFFD4956C),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE8A87C).withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.thermostat,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              temperature != null ? '${temperature!.toStringAsFixed(1)}°' : '--°',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Temperature',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WaterParamsDisplay extends StatelessWidget {
  final double? ph;
  final double? ammonia;
  final double? nitrate;

  const _WaterParamsDisplay({this.ph, this.ammonia, this.nitrate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Water Quality',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ParamPill(label: 'pH', value: ph?.toStringAsFixed(1) ?? '--', color: const Color(0xFF81C784)),
            _ParamPill(label: 'NH₃', value: ammonia?.toStringAsFixed(1) ?? '--', color: const Color(0xFFFFD54F)),
            _ParamPill(label: 'NO₃', value: nitrate?.toStringAsFixed(0) ?? '--', color: const Color(0xFFFFB74D)),
          ],
        ),
      ],
    );
  }
}

class _ParamPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ParamPill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassBadge extends StatelessWidget {
  final String text;
  final String subtext;

  const _GlassBadge({required this.text, required this.subtext});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  subtext,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionsBar extends StatelessWidget {
  final VoidCallback? onFoodTap;
  final VoidCallback? onTestKitTap;
  final VoidCallback? onPlantTap;

  const _QuickActionsBar({
    this.onFoodTap,
    this.onTestKitTap,
    this.onPlantTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickActionButton(
                icon: Icons.restaurant,
                label: 'Feed',
                color: const Color(0xFFE8A87C),
                onTap: onFoodTap,
              ),
              _QuickActionButton(
                icon: Icons.science,
                label: 'Test',
                color: const Color(0xFF81C784),
                onTap: onTestKitTap,
              ),
              _QuickActionButton(
                icon: Icons.water_drop,
                label: 'Change',
                color: const Color(0xFF64B5F6),
                onTap: onPlantTap,
              ),
              _QuickActionButton(
                icon: Icons.auto_graph,
                label: 'Stats',
                color: const Color(0xFFBA68C8),
                onTap: onPlantTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
