import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/room_themes.dart';
import '../ambient/swaying_plant.dart';
import 'fish_tap_interaction.dart';
import 'plant_painters.dart';
import 'tank_fish_manager.dart';

/// The 3-D aquarium illustration rendered inside the room scene.
///
/// Performance notes:
/// - Plants are rendered once per position (4 total) with a Stack z-order
///   that achieves the same depth effect as the old duplicated 8-plant render.
///   Each plant is wrapped in [RepaintBoundary].
/// - Fish are managed by [TankFishManager] which uses [RepaintBoundary] per
///   fish to prevent full-tree repaints on every animation tick.
class ThemedAquarium extends StatelessWidget {
  final double width;
  final double height;
  final RoomTheme theme;

  /// Unused — kept for API compatibility. Fish are always shown via
  /// [TankFishManager]; Rive fish have been replaced by species sprites.
  // ignore: unused_field
  final bool useRiveFish;
  final bool reduceMotion;

  /// Optional tank ID passed to [TankFishManager] for livestock cross-reference.
  final String? tankId;

  const ThemedAquarium({
    super.key,
    required this.width,
    required this.height,
    required this.theme,
    this.useRiveFish = true,
    this.reduceMotion = false,
    this.tankId,
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

            // ── FISH — species sprites managed by TankFishManager ─────────
            // TankFishManager reads unlocked species and renders them as
            // animated sprite fish across depth layers.  Falls back to
            // AnimatedSwimmingFish when the user has no unlocked species.
            // Always rendered — TankFishManager handles reduceMotion internally
            // via MediaQuery.of(context).disableAnimations.
            Positioned.fill(
              child: RepaintBoundary(
                child: TankFishManager(
                  tankWidth: width,
                  tankHeight: height,
                  tankId: tankId,
                ),
              ),
            ),

            // ── FISH TAP INTERACTION ──────────────────────────────────────
            // Transparent layer that detects taps, triggers fish wiggle,
            // shows a splash ripple and species name tooltip.
            Positioned.fill(
              child: TankTapInteractionLayer(
                tankWidth: width,
                tankHeight: height,
                speciesName: 'fish', // generic; TankFishManager picks species
              ),
            ),

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
