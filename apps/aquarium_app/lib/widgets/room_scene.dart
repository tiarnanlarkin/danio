import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../providers/room_theme_provider.dart';
import '../theme/room_themes.dart';
import 'ambient/ambient_overlay.dart';
import 'ambient/swaying_plant.dart';
import 'effects/ripple_container.dart';
import 'rive/rive_fish.dart';
import 'stage/tank_glass_badge.dart';

/// Water fill opacity — 0.92 lets the room background bleed through slightly.
/// Adjust this constant to tune the water transparency across all gradient stops.
const double kWaterOpacity = 0.92;

/// Themeable room scene - supports multiple visual styles
/// Includes day/night ambient lighting overlay based on real time.
class LivingRoomScene extends ConsumerWidget {
  final String tankId;
  final String tankName;
  final double tankVolume;
  final double? temperature;
  final double? ph;
  final double? ammonia;
  final double? nitrate;
  final RoomTheme theme;
  final VoidCallback? onTankTap;
  final VoidCallback? onTestKitTap;
  final VoidCallback? onFoodTap;
  final VoidCallback? onPlantTap;
  final VoidCallback? onStatsTap;
  final VoidCallback? onThemeTap;
  final VoidCallback? onJournalTap;
  final VoidCallback? onCalendarTap;
  final bool isNewUser;

  /// Whether to use animated Rive fish instead of static drawn fish
  final bool useRiveFish;

  const LivingRoomScene({
    super.key,
    required this.tankId,
    required this.tankName,
    required this.tankVolume,
    required this.theme,
    this.temperature,
    this.ph,
    this.ammonia,
    this.nitrate,
    this.onTankTap,
    this.onTestKitTap,
    this.onFoodTap,
    this.onPlantTap,
    this.onStatsTap,
    this.onThemeTap,
    this.onJournalTap,
    this.onCalendarTap,
    this.isNewUser = false,
    this.useRiveFish = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : w * 1.4;

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            // BUG-03: clip room scene children to prevent overflow into panel area
            clipBehavior: Clip.hardEdge,
            children: [
              // === LAYER 1: Background image with ambient lighting overlay ===
              // AmbientLightingOverlay wraps the background image for time-of-day tinting.
              // _CozyRoomBackground and plant widgets are retired — room is now image-based.
              Positioned.fill(
                child: AmbientLightingOverlay(
                  child: ExcludeSemantics(
                    child: Image.asset(
                      _backgroundForTheme(ref.watch(roomThemeProvider)),
                      fit: BoxFit.cover,
                      cacheWidth: 1024,
                      cacheHeight: 1024,
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),

              // === LAYER 2: Decorative room elements ===
              // Plants, shelves, lamp are now part of the background image.
              // Only sparkles for special themes remain here.

              // Stars/sparkles for whimsical themes
              if (theme.name == 'Whimsical' ||
                  theme.name == 'Midnight' ||
                  theme.name == 'Aurora') ...[
                Positioned(
                  top: h * 0.08,
                  left: w * 0.15,
                  child: _Sparkle(size: 8, color: theme.accentCircles[0]),
                ),
                Positioned(
                  top: h * 0.12,
                  right: w * 0.25,
                  child: _Sparkle(size: 6, color: theme.accentCircles[1]),
                ),
                Positioned(
                  top: h * 0.06,
                  left: w * 0.35,
                  child: _Sparkle(size: 5, color: theme.accentCircles[2]),
                ),
                Positioned(
                  top: h * 0.15,
                  left: w * 0.08,
                  child: _Sparkle(size: 4, color: theme.accentCircles[0]),
                ),
              ],

              // === LAYER 3: Furniture stand for aquarium ===
              Positioned(
                top: h * 0.66,
                left: w * 0.06,
                right: w * 0.06,
                child: _AquariumStand(
                  width: w * 0.88,
                  height: h * 0.08,
                  theme: theme,
                ),
              ),

              // === LAYER 4: 3D Aquarium illustration (center, sitting on stand) ===
              Positioned(
                top: h * 0.24,
                left: w * 0.06,
                right: w * 0.06,
                child: Hero(
                  tag: 'tank-card-$tankId',
                  child: RippleContainer(
                    onTap: onTankTap,
                    child: _ThemedAquarium(
                      width: w * 0.88,
                      height: h * 0.44,
                      theme: theme,
                      useRiveFish: useRiveFish,
                      reduceMotion: MediaQuery.of(context).disableAnimations,
                    ),
                  ),
                ),
              ),

              // === LAYER 5: Tank badge ===
              // Note: StageHandleStrip widgets are rendered by home_screen.dart
              // (full-height Positioned, 48dp hit area) — do NOT add them here
              // or they will appear as duplicate tabs.

              // Tank glass badge — etched manufacturer sticker at very bottom-right corner of glass.
              // Tank bottom edge = h*0.24 + h*0.44 = h*0.68; right edge = w - w*0.06 = w*0.94
              // Use small offsets (6dp) so the badge hugs the corner tightly.
              Positioned(
                bottom:
                    h -
                    (h * 0.68) +
                    6, // 6dp above tank bottom edge (inside glass border)
                right: w * 0.06 + 6, // 6dp inside tank right edge
                child: TankGlassBadge(
                  tankName: tankName,
                  tankVolume: tankVolume,
                  theme: theme,
                ),
              ),

              // Theme selection lives in quick action menu / settings
            ],
          ),
        );
      },
    );
  }
}

// === BACKGROUND IMAGE MAPPING ===

/// Maps a [RoomThemeType] to the corresponding background image asset path.
String _backgroundForTheme(RoomThemeType type) {
  switch (type) {
    case RoomThemeType.cozyLiving:
    case RoomThemeType.eveningGlow:
      return 'assets/backgrounds/room-bg-cozy-living.webp';
    case RoomThemeType.midnight:
      return 'assets/backgrounds/room-bg-midnight.webp';
    case RoomThemeType.ocean:
      return 'assets/backgrounds/room-bg-ocean.webp';
    case RoomThemeType.forest:
      return 'assets/backgrounds/room-bg-forest.webp';
    default:
      return 'assets/backgrounds/room-bg-cozy-living.webp';
  }
}

// === SPARKLE (for whimsical/night themes) ===

class _Sparkle extends StatelessWidget {
  final double size;
  final Color color;

  const _Sparkle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SparklePainter(color: color),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final Color color;
  late final Color _colorAlpha178 = color.withAlpha(178);

  _SparklePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _colorAlpha178
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // 4-point star
    final path = Path()
      ..moveTo(center.dx, center.dy - r)
      ..quadraticBezierTo(
        center.dx + r * 0.2,
        center.dy - r * 0.2,
        center.dx + r,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + r * 0.2,
        center.dy + r * 0.2,
        center.dx,
        center.dy + r,
      )
      ..quadraticBezierTo(
        center.dx - r * 0.2,
        center.dy + r * 0.2,
        center.dx - r,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx - r * 0.2,
        center.dy - r * 0.2,
        center.dx,
        center.dy - r,
      );

    canvas.drawPath(path, paint);

    // Inner glow
    canvas.drawCircle(center, r * 0.3, Paint()..color = AppOverlays.white50);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// === AQUARIUM STAND (furniture) ===

class _AquariumStand extends StatelessWidget {
  final double width;
  final double height;
  final RoomTheme theme;

  const _AquariumStand({
    required this.width,
    required this.height,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _StandPainter(theme: theme),
    );
  }
}

class _StandPainter extends CustomPainter {
  final RoomTheme theme;

  _StandPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Dark charcoal metal frame per §6.4 — NOT wood coloured
    const woodColor = Color(0xFF2A2A2A); // standPrimary charcoal
    const woodHighlight = Color(0xFF404040); // standHighlight

    // Stand top surface
    final topRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h * 0.35),
      const Radius.circular(3),
    );
    canvas.drawRRect(topRect, Paint()..color = woodColor);

    // Highlight on top
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.05, 2, w * 0.9, 3),
        const Radius.circular(2),
      ),
      Paint()..color = woodHighlight,
    );

    // Stand legs
    final legPaint = Paint()..color = woodColor;

    // Left leg
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.05, h * 0.3, w * 0.08, h * 0.7),
        const Radius.circular(2),
      ),
      legPaint,
    );

    // Right leg
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.87, h * 0.3, w * 0.08, h * 0.7),
        const Radius.circular(2),
      ),
      legPaint,
    );

    // Cross support
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.05, h * 0.6, w * 0.9, h * 0.15),
        const Radius.circular(2),
      ),
      legPaint,
    );

    // Shelf shadow
    canvas.drawRect(
      Rect.fromLTWH(w * 0.06, h * 0.6 + h * 0.15, w * 0.88, 2),
      Paint()..color = const Color(0x14000000),
    );

    // Shelf items removed — clean open shelf
  }

  @override
  bool shouldRepaint(covariant _StandPainter old) => old.theme != theme;
}

// === THEMED AQUARIUM ===

class _ThemedAquarium extends StatelessWidget {
  final double width;
  final double height;
  final RoomTheme theme;
  final bool useRiveFish;
  final bool reduceMotion;

  const _ThemedAquarium({
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
            // MUST use Positioned.fill so the gradient fills the entire tank.
            // Alpha 0xEB = 235 = round(kWaterOpacity * 255) = 92% — lets room bg bleed through.
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.25, 0.65, 1.0],
                    colors: [
                      Color(
                        0xEB9ED8EC,
                      ), // waterSurface — icy top (kWaterOpacity 0.92)
                      Color(
                        0xEB6BBDD8,
                      ), // waterMidUpper — clear mid (kWaterOpacity 0.92)
                      Color(
                        0xEB4A9DB5,
                      ), // waterMidLower — deeper (kWaterOpacity 0.92)
                      Color(
                        0xEB2D7A94,
                      ), // waterDepth — dark bottom (kWaterOpacity 0.92)
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

            // Plants with gentle swaying animation
            if (reduceMotion) ...[
              Positioned(
                bottom: height * 0.15,
                left: width * 0.08,
                child: _SoftPlant(height: height * 0.5, color: theme.plantPrimary),
              ),
              Positioned(
                bottom: height * 0.15,
                left: width * 0.22,
                child: _SoftPlant(height: height * 0.35, color: theme.plantSecondary),
              ),
              Positioned(
                bottom: height * 0.15,
                right: width * 0.1,
                child: _SoftPlant(height: height * 0.55, color: theme.plantPrimary),
              ),
              Positioned(
                bottom: height * 0.15,
                right: width * 0.28,
                child: _SoftPlant(height: height * 0.4, color: theme.plantSecondary),
              ),
            ] else ...[
              Positioned(
                bottom: height * 0.15,
                left: width * 0.08,
                child: SwayingPlantTall(
                  index: 0,
                  child: _SoftPlant(height: height * 0.5, color: theme.plantPrimary),
                ),
              ),
              Positioned(
                bottom: height * 0.15,
                left: width * 0.22,
                child: SwayingPlantSmall(
                  index: 1,
                  child: _SoftPlant(height: height * 0.35, color: theme.plantSecondary),
                ),
              ),
              Positioned(
                bottom: height * 0.15,
                right: width * 0.1,
                child: SwayingPlantTall(
                  index: 2,
                  child: _SoftPlant(height: height * 0.55, color: theme.plantPrimary),
                ),
              ),
              Positioned(
                bottom: height * 0.15,
                right: width * 0.28,
                child: SwayingPlant(
                  index: 3,
                  child: _SoftPlant(height: height * 0.4, color: theme.plantSecondary),
                ),
              ),
            ],

            // Fish - Rive animated or static drawn
            // BACK LAYER FISH (behind plants) - smaller, more distant
            if (useRiveFish && !reduceMotion) ...[
              // Small fish in back - behind the tall left plant
              // Positioned away from tank edge to avoid ClipRRect corner clipping
              Positioned(
                top: height * 0.28,
                left: width * 0.08,
                child: RiveFish(
                  fishType: RiveFishType.emotional,
                  size: height * 0.18,
                ),
              ),
              // Small fish in back - behind right plant
              Positioned(
                top: height * 0.35,
                right: width * 0.08,
                child: RiveFish(
                  fishType: RiveFishType.joystick,
                  size: height * 0.16,
                  flipHorizontal: true,
                ),
              ),
            ],

            // Plants with gentle swaying animation (duplicated for layering)
            if (reduceMotion) ...[
              Positioned(
                bottom: height * 0.15,
                left: width * 0.08,
                child: _SoftPlant(height: height * 0.5, color: theme.plantPrimary),
              ),
              Positioned(
                bottom: height * 0.15,
                left: width * 0.22,
                child: _SoftPlant(height: height * 0.35, color: theme.plantSecondary),
              ),
              Positioned(
                bottom: height * 0.15,
                right: width * 0.1,
                child: _SoftPlant(height: height * 0.55, color: theme.plantPrimary),
              ),
              Positioned(
                bottom: height * 0.15,
                right: width * 0.28,
                child: _SoftPlant(height: height * 0.4, color: theme.plantSecondary),
              ),
            ] else ...[
              Positioned(
                bottom: height * 0.15,
                left: width * 0.08,
                child: SwayingPlantTall(
                  index: 0,
                  child: _SoftPlant(height: height * 0.5, color: theme.plantPrimary),
                ),
              ),
              Positioned(
                bottom: height * 0.15,
                left: width * 0.22,
                child: SwayingPlantSmall(
                  index: 1,
                  child: _SoftPlant(height: height * 0.35, color: theme.plantSecondary),
                ),
              ),
              Positioned(
                bottom: height * 0.15,
                right: width * 0.1,
                child: SwayingPlantTall(
                  index: 2,
                  child: _SoftPlant(height: height * 0.55, color: theme.plantPrimary),
                ),
              ),
              Positioned(
                bottom: height * 0.15,
                right: width * 0.28,
                child: SwayingPlant(
                  index: 3,
                  child: _SoftPlant(height: height * 0.4, color: theme.plantSecondary),
                ),
              ),
            ],

            // FRONT LAYER FISH (in front of plants) - main fish, larger
            if (useRiveFish && !reduceMotion) ...[
              // Main puffer fish - upper left, swimming right
              Positioned(
                top: height * 0.12,
                left: width * 0.25,
                child: RiveFish(
                  fishType: RiveFishType.puffer,
                  size: height * 0.28,
                ),
              ),
              // Joystick fish - mid right area, swimming left
              Positioned(
                top: height * 0.38,
                right: width * 0.15,
                child: RiveFish(
                  fishType: RiveFishType.joystick,
                  size: height * 0.24,
                  flipHorizontal: true,
                ),
              ),
              // Emotional fish - center bottom, interactive
              Positioned(
                top: height * 0.55,
                left: width * 0.38,
                child: RiveFish(
                  fishType: RiveFishType.emotional,
                  size: height * 0.22,
                ),
              ),
              // Extra small puffer - upper right for variety
              Positioned(
                top: height * 0.08,
                right: width * 0.25,
                child: RiveFish(
                  fishType: RiveFishType.puffer,
                  size: height * 0.18,
                  flipHorizontal: true,
                ),
              ),
              // Extra joystick fish - lower left
              Positioned(
                top: height * 0.48,
                left: width * 0.12,
                child: RiveFish(
                  fishType: RiveFishType.joystick,
                  size: height * 0.20,
                ),
              ),
            ] else ...[
              // Animated swimming fish — flat vector palette (design system §1.4)
              _AnimatedSwimmingFish(
                size: 28,
                color: const Color(0xFFE8503A), // fishCoralRed
                tankWidth: width,
                tankHeight: height,
                baseTop: 0.22,
                swimSpeed: 10.0,
                verticalBob: 12.0,
                startOffset: 0.0,
              ),
              _AnimatedSwimmingFish(
                size: AppIconSizes.md,
                color: const Color(0xFF3A78C9), // fishCobaltBlue
                tankWidth: width,
                tankHeight: height,
                baseTop: 0.40,
                swimSpeed: 8.0,
                verticalBob: 18.0,
                startOffset: 0.6,
              ),
              _AnimatedSwimmingFish(
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

            // Static bubbles — DISABLED: contributes to milkiness
            // Positioned(
            //   right: width * 0.18,
            //   bottom: height * 0.2,
            //   child: _SoftBubbles(height: height * 0.5),
            // ),

            // Animated floating bubbles — DISABLED: contributes to milkiness
            // const AmbientBubblesSubtle(bubbleCount: 12),

            // Water surface effect — DISABLED: not used when useRiveFish=false

            // Light reflection — DISABLED: whiteAlpha35 strip washes out water
            // Positioned(
            //   top: 4,
            //   left: 4,
            //   right: 4,
            //   child: Container(
            //     height: 20,
            //     decoration: BoxDecoration(
            //       gradient: LinearGradient(
            //         colors: [
            //           Colors.transparent,
            //           AppColors.whiteAlpha35,
            //           Colors.transparent,
            //         ],
            //       ),
            //       borderRadius: const BorderRadius.vertical(
            //         top: Radius.circular(20),
            //       ),
            //     ),
            //   ),
            // ),

            // Top light bar — simplified: removed massive glow that washed out tank
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
                      color: const Color(
                        0x33FFD080,
                      ), // subtle warm glow, 20% alpha
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
}

class _SoftPlant extends StatelessWidget {
  final double height;
  final Color color;

  const _SoftPlant({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: height * 0.4,
      height: height,
      child: CustomPaint(painter: _PlantPainter(color: color)),
    );
  }
}

class _PlantPainter extends CustomPainter {
  final Color color;

  _PlantPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 5; i++) {
      final angle = (i - 2) * 0.3;
      final leafHeight = size.height * (0.6 + (i % 2) * 0.35);

      final path = Path()
        ..moveTo(size.width / 2, size.height)
        ..quadraticBezierTo(
          size.width / 2 + math.sin(angle) * size.width,
          size.height - leafHeight * 0.5,
          size.width / 2 + math.sin(angle) * size.width * 0.6,
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

class _SoftFish extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftFish({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: 1,
      child: SizedBox(
        width: size * 2,
        height: size,
        child: CustomPaint(painter: _FishPainter(color: color)),
      ),
    );
  }
}

class _FishPainter extends CustomPainter {
  final Color color;
  late final Color _finColor = color.withAlpha(204);

  _FishPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // Body
    final bodyPath = Path()
      ..addOval(
        Rect.fromLTWH(
          0,
          size.height * 0.15,
          size.width * 0.65,
          size.height * 0.7,
        ),
      );
    canvas.drawPath(bodyPath, paint);

    // Tail
    final tailPath = Path()
      ..moveTo(size.width * 0.55, size.height * 0.5)
      ..lineTo(size.width, size.height * 0.15)
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.5,
        size.width,
        size.height * 0.85,
      )
      ..close();
    canvas.drawPath(tailPath, paint);

    // Fin — use a separate Paint to avoid mutating the body paint's color
    final finPaint = Paint()..color = _finColor;
    final finPath = Path()
      ..moveTo(size.width * 0.25, size.height * 0.2)
      ..quadraticBezierTo(
        size.width * 0.35,
        0,
        size.width * 0.45,
        size.height * 0.15,
      )
      ..close();
    canvas.drawPath(finPath, finPaint);

    // Eye
    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.4),
      size.width * 0.06,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.4),
      size.width * 0.03,
      Paint()..color = Colors.black,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Animated fish that swims smoothly across the tank
class _AnimatedSwimmingFish extends StatefulWidget {
  final double size;
  final Color color;
  final double swimSpeed; // seconds for one swim cycle
  final double verticalBob; // how much to bob up/down
  final double startOffset; // 0-1, where in the animation to start
  final double tankWidth;
  final double tankHeight;
  final double baseTop; // base Y position (0-1 of tank height)

  const _AnimatedSwimmingFish({
    required this.size,
    required this.color,
    required this.tankWidth,
    required this.tankHeight,
    this.swimSpeed = 8.0,
    this.verticalBob = 15.0,
    this.startOffset = 0.0,
    this.baseTop = 0.3,
  });

  @override
  State<_AnimatedSwimmingFish> createState() => _AnimatedSwimmingFishState();
}

class _AnimatedSwimmingFishState extends State<_AnimatedSwimmingFish>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _swimAnimation;
  late Animation<double> _bobAnimation;
  bool _facingRight = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 8000), // default; updated in didChangeDependencies
      vsync: this,
    );

    // Swim horizontally across tank
    _swimAnimation = Tween<double>(
      begin: -0.1,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    // Gentle vertical bobbing
    _bobAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.standardSine),
    );

    // Use repeat(reverse: true) for native ping-pong instead of manual
    // forward()/reverse() status listeners. The manual approach caused
    // stack overflow on relaunch when reduce-motion set duration to 16ms,
    // allowing the animation to complete within a single frame and
    // recurse infinitely via status callbacks.
    _controller.repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableMotion = MediaQuery.of(context).disableAnimations;
    // When motion is reduced, use a very long duration so the fish barely
    // moves. Must not be Duration.zero to avoid internal Flutter assertions.
    final targetDuration = disableMotion
        ? const Duration(minutes: 5)
        : Duration(milliseconds: (widget.swimSpeed * 1000).toInt());
    if (_controller.duration != targetDuration) {
      _controller.duration = targetDuration;
    }
  }

  // Track the previous value to detect direction changes for flip.
  double _previousValue = 0.0;

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
        final value = _controller.value;

        // Detect direction change for fish flip: when the animation
        // value was increasing and now decreases (or vice versa), flip.
        if (value >= _previousValue && _previousValue > 0.9) {
          _facingRight = false; // swimming left (reverse phase)
        } else if (value <= _previousValue && _previousValue < 0.1) {
          _facingRight = true; // swimming right (forward phase)
        }
        _previousValue = value;

        final swimX = _swimAnimation.value * widget.tankWidth;
        final bobY = _bobAnimation.value * widget.verticalBob;
        final rawBaseY = widget.baseTop * widget.tankHeight;

        // BUG-08: clamp fish position to stay within tank glass bounds
        const glassBorder = 4.0;
        final sandBoundary = widget.tankHeight * 0.78;
        final clampedTop = (rawBaseY + bobY).clamp(
          glassBorder,
          sandBoundary - widget.size,
        );
        // Clamp X to keep fish within tank walls
        final clampedLeft = (swimX - widget.size / 2).clamp(
          glassBorder,
          widget.tankWidth - widget.size - glassBorder,
        );

        return Positioned(
          left: clampedLeft,
          top: clampedTop,
          child: Transform.scale(
            scaleX: _facingRight ? 1 : -1,
            child: _SoftFish(size: widget.size, color: widget.color),
          ),
        );
      },
    );
  }
}
