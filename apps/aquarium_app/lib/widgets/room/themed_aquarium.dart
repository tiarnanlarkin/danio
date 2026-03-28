import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/room_themes.dart';
import '../ambient/swaying_plant.dart';
import '../rive/rive_fish.dart';
import 'animated_swimming_fish.dart';
import 'plant_painters.dart';

/// The 3-D aquarium illustration rendered inside the room scene.
///
/// Performance notes:
/// - Plants are rendered once per position (4 total) with a Stack z-order
///   that achieves the same depth effect as the old duplicated 8-plant render.
///   Each plant is wrapped in [RepaintBoundary].
/// - Each [RiveFish] and [AnimatedSwimmingFish] is wrapped in [RepaintBoundary]
///   to prevent full-tree repaints on every animation tick.
class ThemedAquarium extends StatelessWidget {
  final double width;
  final double height;
  final RoomTheme theme;
  final bool useRiveFish;
  final bool reduceMotion;

  const ThemedAquarium({
    super.key,
    required this.width,
    required this.height,
    required this.theme,
    this.useRiveFish = true,
    this.reduceMotion = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: AppRadius.largeRadius,
        // Glass border: icy blue, 2dp, border ONLY — no fill (design system §2.4)
        border: Border.all(
          color: const Color(0xFFB8DDE8), // glassBorder
          width: 2.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000), // 10% black — outer shadow
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x337FBECC), // 20% icy inner glow
            blurRadius: 6,
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.largeRadius,
        child: Stack(
          children: [
            // Water gradient — crystal clear teal, fixed palette (design system §2.3)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.25, 0.65, 1.0],
                    colors: [
                      Color(0xEB9ED8EC), // waterSurface — icy top
                      Color(0xEB6BBDD8), // waterMidUpper — clear mid
                      Color(0xEB4A9DB5), // waterMidLower — deeper
                      Color(0xEB2D7A94), // waterDepth — dark bottom
                    ],
                  ),
                ),
              ),
            ),

            // Sand/substrate — warm beige, fixed palette (design system §5)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: height * 0.12,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE8D5B0), // sandLight — warm cream
                      Color(0xFFD4BC8A), // sandMid
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
            ),

            // ── BACK LAYER: plants behind fish (z-index: bottom) ──────────
            // B1: 4 plants total (was 8 duplicated). Each wrapped in
            // RepaintBoundary so swaying animations don't repaint the tank.
            _buildPlant(
              bottom: height * 0.15,
              left: width * 0.08,
              plantHeight: height * 0.5,
              color: theme.plantPrimary,
              swayIndex: 0,
              tall: true,
            ),
            _buildPlant(
              bottom: height * 0.15,
              left: width * 0.22,
              plantHeight: height * 0.35,
              color: theme.plantSecondary,
              swayIndex: 1,
              tall: false,
            ),
            _buildPlant(
              bottom: height * 0.15,
              right: width * 0.1,
              plantHeight: height * 0.55,
              color: theme.plantPrimary,
              swayIndex: 2,
              tall: true,
            ),
            _buildPlant(
              bottom: height * 0.15,
              right: width * 0.28,
              plantHeight: height * 0.4,
              color: theme.plantSecondary,
              swayIndex: 3,
              tall: false,
            ),

            // ── BACK LAYER FISH (behind front plants, smaller / distant) ──
            if (useRiveFish && !reduceMotion) ...[
              Positioned(
                top: height * 0.28,
                left: width * 0.08,
                child: RepaintBoundary(
                  child: RiveFish(
                    fishType: RiveFishType.emotional,
                    size: height * 0.18,
                  ),
                ),
              ),
              Positioned(
                top: height * 0.35,
                right: width * 0.08,
                child: RepaintBoundary(
                  child: RiveFish(
                    fishType: RiveFishType.joystick,
                    size: height * 0.16,
                    flipHorizontal: true,
                  ),
                ),
              ),
            ],

            // ── FRONT LAYER FISH ──────────────────────────────────────────
            if (useRiveFish && !reduceMotion) ...[
              Positioned(
                top: height * 0.12,
                left: width * 0.25,
                child: RepaintBoundary(
                  child: RiveFish(
                    fishType: RiveFishType.puffer,
                    size: height * 0.28,
                  ),
                ),
              ),
              Positioned(
                top: height * 0.38,
                right: width * 0.15,
                child: RepaintBoundary(
                  child: RiveFish(
                    fishType: RiveFishType.joystick,
                    size: height * 0.24,
                    flipHorizontal: true,
                  ),
                ),
              ),
              Positioned(
                top: height * 0.55,
                left: width * 0.38,
                child: RepaintBoundary(
                  child: RiveFish(
                    fishType: RiveFishType.emotional,
                    size: height * 0.22,
                  ),
                ),
              ),
              Positioned(
                top: height * 0.08,
                right: width * 0.25,
                child: RepaintBoundary(
                  child: RiveFish(
                    fishType: RiveFishType.puffer,
                    size: height * 0.18,
                    flipHorizontal: true,
                  ),
                ),
              ),
              Positioned(
                top: height * 0.48,
                left: width * 0.12,
                child: RepaintBoundary(
                  child: RiveFish(
                    fishType: RiveFishType.joystick,
                    size: height * 0.20,
                  ),
                ),
              ),
            ] else ...[
              // Animated swimming fish — flat vector palette (design system §1.4)
              // AnimatedSwimmingFish already includes RepaintBoundary internally.
              AnimatedSwimmingFish(
                size: 28,
                color: const Color(0xFFE8503A), // fishCoralRed
                tankWidth: width,
                tankHeight: height,
                baseTop: 0.22,
                swimSpeed: 10.0,
                verticalBob: 12.0,
                startOffset: 0.0,
              ),
              AnimatedSwimmingFish(
                size: AppIconSizes.md,
                color: const Color(0xFF3A78C9), // fishCobaltBlue
                tankWidth: width,
                tankHeight: height,
                baseTop: 0.40,
                swimSpeed: 8.0,
                verticalBob: 18.0,
                startOffset: 0.6,
              ),
              AnimatedSwimmingFish(
                size: AppIconSizes.sm,
                color: const Color(0xFFE8A030), // fishAmberGold
                tankWidth: width,
                tankHeight: height,
                baseTop: 0.55,
                swimSpeed: 12.0,
                verticalBob: 10.0,
                startOffset: 0.3,
              ),
            ],

            // Top light bar
            Positioned(
              top: -4,
              left: width * 0.2,
              right: width * 0.2,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C), // dark hood
                  borderRadius: AppRadius.xsRadius,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x33FFD080), // subtle warm glow
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a single plant Positioned widget — with or without swaying animation
  /// and wrapped in RepaintBoundary.
  Widget _buildPlant({
    required double bottom,
    double? left,
    double? right,
    required double plantHeight,
    required Color color,
    required int swayIndex,
    required bool tall,
  }) {
    final plant = SoftPlant(height: plantHeight, color: color);

    final animated = reduceMotion
        ? plant
        : tall
            ? SwayingPlantTall(index: swayIndex, child: plant)
            : (swayIndex == 3
                ? SwayingPlant(index: swayIndex, child: plant)
                : SwayingPlantSmall(index: swayIndex, child: plant));

    return Positioned(
      bottom: bottom,
      left: left,
      right: right,
      child: RepaintBoundary(child: animated),
    );
  }
}
