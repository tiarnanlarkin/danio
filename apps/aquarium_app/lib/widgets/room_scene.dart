import 'package:aquarium_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../theme/room_themes.dart';
import 'ambient/ambient_bubbles.dart';
import 'ambient/ambient_overlay.dart';
import 'ambient/swaying_plant.dart';
import 'effects/ripple_container.dart';
import 'room/interactive_object.dart';
import 'rive/rive_fish.dart';
import 'rive/rive_water_effect.dart';

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
    // Wrap entire scene with day/night ambient lighting overlay
    return AmbientLightingOverlay(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : w * 1.4;

          return SizedBox(
            width: w,
            height: h,
            child: Stack(
              children: [
                // === LAYER 1: Cozy room background with walls, floor, window ===
                Positioned.fill(child: _CozyRoomBackground(theme: theme)),

              // === LAYER 2: Decorative room elements (plants, shelves, lamp) ===
              // Tall plant on left side
              Positioned(
                bottom: h * 0.08,
                left: w * 0.02,
                child: _RoomPlant(height: h * 0.25, theme: theme),
              ),
              
              // Small plant on shelf (right)
              Positioned(
                top: h * 0.12,
                right: w * 0.08,
                child: _ShelfPlant(size: w * 0.08, theme: theme),
              ),

              // Stars/sparkles for whimsical themes
              if (theme.name == 'Whimsical' || theme.name == 'Midnight' || theme.name == 'Aurora') ...[
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
                top: h * 0.54,
                left: w * 0.08,
                right: w * 0.08,
                child: _AquariumStand(
                  width: w * 0.84,
                  height: h * 0.08,
                  theme: theme,
                ),
              ),

              // === LAYER 4: 3D Aquarium illustration (center, sitting on stand) ===
              Positioned(
                top: h * 0.26,
                left: w * 0.1,
                right: w * 0.1,
                child: Hero(
                  tag: 'tank-card-$tankId',
                  child: RippleContainer(
                    onTap: onTankTap,
                    child: _ThemedAquarium(
                      width: w * 0.8,
                      height: h * 0.30,
                      theme: theme,
                      useRiveFish: useRiveFish,
                    ),
                  ),
                ),
              ),

              // === LAYER 5: Glassmorphic UI cards ===

              // Temperature gauge (top left) — compact size
              Positioned(
                top: h * 0.06,
                left: w * 0.05,
                child: GestureDetector(
                  onTap: onStatsTap,
                  child: _CircularTempGauge(
                    size: w * 0.18,
                    temperature: temperature ?? 25,
                    theme: theme,
                  ),
                ),
              ),

              // Water quality card (top right) — positioned to avoid overlap with top bar
              Positioned(
                top: h * 0.08,
                right: w * 0.05,
                child: GestureDetector(
                  onTap: onTestKitTap,
                  child: _WaterQualityCard(
                    width: w * 0.32,
                    ph: ph,
                    ammonia: ammonia,
                    nitrate: nitrate,
                    theme: theme,
                  ),
                ),
              ),

              // Tank name badge
              Positioned(
                top: h * 0.20,
                left: 0,
                right: 0,
                child: Center(
                  child: _GlassBadge(
                    text: tankName,
                    subtext: '${tankVolume.toStringAsFixed(0)}L',
                    theme: theme,
                  ),
                ),
              ),

              // Wave graph card (bottom center) - moved up since actions are in speed dial
              Positioned(
                bottom: h * 0.04,
                left: w * 0.08,
                right: w * 0.08,
                child: _WaveGraphCard(
                  width: w * 0.84,
                  height: 65,
                  theme: theme,
                ),
              ),

              // === LAYER 6: Interactive objects ===
              // Journal object (left side of scene)
              if (onJournalTap != null)
                Positioned(
                  bottom: h * 0.15,
                  left: w * 0.05,
                  child: LivingRoomObjects.journal(
                    onTap: onJournalTap!,
                    isNewUser: isNewUser,
                  ),
                ),

              // Calendar/Schedule object (right side of scene)
              if (onCalendarTap != null)
                Positioned(
                  bottom: h * 0.15,
                  right: w * 0.05,
                  child: LivingRoomObjects.calendar(
                    onTap: onCalendarTap!,
                    isNewUser: isNewUser,
                  ),
                ),

              // Theme switcher hint (top center)
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: onThemeTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.glassCard,
                        borderRadius: AppRadius.mediumRadius,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.palette,
                            size: 14,
                            color: theme.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            theme.name,
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        },
      ),
    );
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

  _SparklePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.7)
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
    canvas.drawCircle(
      center,
      r * 0.3,
      Paint()..color = AppOverlays.white50,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// === COZY ROOM BACKGROUND - Actual room with walls, floor, window ===

class _CozyRoomBackground extends StatelessWidget {
  final RoomTheme theme;

  const _CozyRoomBackground({required this.theme});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CozyRoomPainter(theme: theme),
      size: Size.infinite,
    );
  }
}

class _CozyRoomPainter extends CustomPainter {
  final RoomTheme theme;

  _CozyRoomPainter({required this.theme});

  // Determine if this is a dark/night theme
  bool get _isDarkTheme {
    final luminance = theme.background1.computeLuminance();
    return luminance < 0.3;
  }

  // Cozy room uses warm base colors regardless of theme
  Color get _wallColor => _isDarkTheme 
      ? const Color(0xFF3D4A5C) // Cozy dark blue-gray
      : const Color(0xFFF5EDE5); // Warm cream

  Color get _wallAccent => _isDarkTheme
      ? const Color(0xFF4A5568) // Lighter accent
      : const Color(0xFFEDE5D8); // Soft beige

  Color get _floorColor => _isDarkTheme
      ? const Color(0xFF5C4A3D) // Dark wood
      : const Color(0xFFD4B896); // Warm wood

  Color get _trimColor => _isDarkTheme
      ? const Color(0xFF6B5B4F) // Dark trim
      : const Color(0xFF8B7355); // Wood trim

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // === BASE WALL - WARM CREAM/COZY GRADIENT ===
    final wallGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        _wallColor,
        _wallAccent,
        Color.lerp(_wallAccent, _floorColor, 0.3)!,
      ],
      stops: const [0.0, 0.6, 1.0],
    );
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..shader = wallGradient.createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // === VISIBLE WALL TEXTURE (subtle vertical stripes) ===
    final texturePaint = Paint()
      ..color = (_isDarkTheme ? AppColors.whiteAlpha05 : AppColors.blackAlpha05)
      ..strokeWidth = 1.5;
    
    for (var x = 0.0; x < w; x += 25) {
      canvas.drawLine(Offset(x, 0), Offset(x, h * 0.62), texturePaint);
    }

    // === WAINSCOTING / WALL PANEL (lower wall section) ===
    final panelTop = h * 0.45;
    final panelPaint = Paint()
      ..color = Color.lerp(_wallAccent, _floorColor, 0.15)!;
    canvas.drawRect(
      Rect.fromLTWH(0, panelTop, w, h * 0.17),
      panelPaint,
    );
    
    // Panel trim line
    canvas.drawLine(
      Offset(0, panelTop),
      Offset(w, panelTop),
      Paint()
        ..color = _trimColor.withOpacity(0.4)
        ..strokeWidth = 3,
    );

    // === WOODEN FLOOR (visible at bottom) ===
    final floorTop = h * 0.62;
    final floorGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        _floorColor,
        Color.lerp(_floorColor, Colors.brown, 0.2)!,
      ],
    );
    
    canvas.drawRect(
      Rect.fromLTWH(0, floorTop, w, h - floorTop),
      Paint()..shader = floorGradient.createShader(Rect.fromLTWH(0, floorTop, w, h)),
    );

    // Floor boards (VISIBLE horizontal lines)
    final floorLinePaint = Paint()
      ..color = (_isDarkTheme ? AppColors.blackAlpha15 : AppColors.woodBrownAlpha15)
      ..strokeWidth = 1.5;
    
    for (var y = floorTop + 15; y < h; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(w, y), floorLinePaint);
    }
    
    // Vertical floor board joints
    final jointPaint = Paint()
      ..color = (_isDarkTheme ? AppColors.blackAlpha08 : AppColors.woodBrownAlpha08)
      ..strokeWidth = 1;
    for (var x = 0.0; x < w; x += 60) {
      canvas.drawLine(Offset(x, floorTop), Offset(x, h), jointPaint);
    }

    // === BASEBOARD / TRIM (VISIBLE) ===
    final baseboardRect = Rect.fromLTWH(0, floorTop - 6, w, 10);
    canvas.drawRect(
      baseboardRect,
      Paint()..color = _trimColor,
    );
    // Baseboard highlight
    canvas.drawLine(
      Offset(0, floorTop - 6),
      Offset(w, floorTop - 6),
      Paint()
        ..color = AppColors.whiteAlpha20
        ..strokeWidth = 1,
    );

    // === WINDOW ON LEFT SIDE (visible, not covered by UI) ===
    _drawWindow(canvas, w, h);

    // === COZY RUG under tank area ===
    _drawRug(canvas, w, h, floorTop);

    // === WARM LIGHTING EFFECTS ===
    _drawLightingEffects(canvas, w, h);

    // === DECORATIVE ELEMENTS ===
    _drawShelf(canvas, w, h);
    _drawPicture(canvas, w, h);
  }
  
  void _drawRug(Canvas canvas, double w, double h, double floorTop) {
    // Cozy rug under the tank area
    final rugRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.05, floorTop + 8, w * 0.9, h * 0.12),
      const Radius.circular(8),
    );
    
    // Rug base
    canvas.drawRRect(
      rugRect,
      Paint()..color = theme.accentBlob.withOpacity(_isDarkTheme ? 0.25 : 0.35),
    );
    
    // Rug pattern (simple stripes)
    final patternPaint = Paint()
      ..color = theme.accentBlob2.withOpacity(0.3)
      ..strokeWidth = 3;
    for (var x = w * 0.1; x < w * 0.9; x += 20) {
      canvas.drawLine(
        Offset(x, floorTop + 15),
        Offset(x, floorTop + h * 0.10),
        patternPaint,
      );
    }
    
    // Rug border
    canvas.drawRRect(
      rugRect,
      Paint()
        ..color = theme.accentBlob.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
  
  void _drawPicture(Canvas canvas, double w, double h) {
    // Small framed picture on wall (left side, above tank)
    final frameLeft = w * 0.02;
    final frameTop = h * 0.22;
    final frameWidth = w * 0.12;
    final frameHeight = h * 0.08;
    
    // Frame
    final frameRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(frameLeft, frameTop, frameWidth, frameHeight),
      const Radius.circular(2),
    );
    canvas.drawRRect(
      frameRect,
      Paint()..color = _trimColor,
    );
    
    // Picture inside
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(frameLeft + 3, frameTop + 3, frameWidth - 6, frameHeight - 6),
        const Radius.circular(1),
      ),
      Paint()..color = theme.waterMid.withOpacity(0.5),
    );
  }

  void _drawWindow(Canvas canvas, double w, double h) {
    // Window on LEFT side of room (visible, not covered by UI)
    final windowLeft = w * 0.02;
    final windowTop = h * 0.06;
    final windowWidth = w * 0.22;
    final windowHeight = h * 0.14;

    // Window light glow (outside light coming in)
    final windowGlow = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: _isDarkTheme
            ? [
                AppColors.whiteAlpha30, // Moonlight blue
                Colors.transparent,
              ]
            : [
                AppColors.whiteAlpha40, // Warm sunlight
                AppColors.whiteAlpha20,
                Colors.transparent,
              ],
      ).createShader(Rect.fromLTWH(
        windowLeft - windowWidth * 0.3,
        windowTop - windowHeight * 0.2,
        windowWidth * 1.6,
        windowHeight * 2,
      ));
    
    canvas.drawOval(
      Rect.fromLTWH(
        windowLeft - windowWidth * 0.2,
        windowTop,
        windowWidth * 1.4,
        windowHeight * 1.5,
      ),
      windowGlow,
    );

    // Window frame
    final windowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(windowLeft, windowTop, windowWidth, windowHeight),
      const Radius.circular(4),
    );
    
    // Window glass (sky/outside)
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: _isDarkTheme
          ? [
              const Color(0xFF1A2040), // Night sky
              const Color(0xFF2A3050),
            ]
          : [
              const Color(0xFF87CEEB), // Day sky
              const Color(0xFFB0E0E6),
            ],
    );
    canvas.drawRRect(
      windowRect,
      Paint()..shader = skyGradient.createShader(windowRect.outerRect),
    );

    // Window frame border
    canvas.drawRRect(
      windowRect,
      Paint()
        ..color = _isDarkTheme
            ? theme.textSecondary.withOpacity(0.3)
            : AppColors.whiteAlpha50
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Window cross bars
    final crossPaint = Paint()
      ..color = _isDarkTheme
          ? theme.textSecondary.withOpacity(0.25)
          : AppColors.whiteAlpha40
      ..strokeWidth = 2;
    
    // Vertical bar
    canvas.drawLine(
      Offset(windowLeft + windowWidth / 2, windowTop),
      Offset(windowLeft + windowWidth / 2, windowTop + windowHeight),
      crossPaint,
    );
    // Horizontal bar
    canvas.drawLine(
      Offset(windowLeft, windowTop + windowHeight / 2),
      Offset(windowLeft + windowWidth, windowTop + windowHeight / 2),
      crossPaint,
    );

    // === CURTAINS ===
    final curtainColor = _isDarkTheme
        ? theme.accentBlob.withOpacity(0.4)
        : theme.accentBlob.withOpacity(0.6);
    final curtainPaint = Paint()..color = curtainColor;

    // Left curtain
    final leftCurtain = Path()
      ..moveTo(windowLeft - 8, windowTop - 5)
      ..quadraticBezierTo(
        windowLeft + windowWidth * 0.15,
        windowTop + windowHeight * 0.3,
        windowLeft - 5,
        windowTop + windowHeight + 10,
      )
      ..lineTo(windowLeft - 15, windowTop + windowHeight + 10)
      ..quadraticBezierTo(
        windowLeft - 10,
        windowTop + windowHeight * 0.5,
        windowLeft - 15,
        windowTop - 5,
      )
      ..close();
    canvas.drawPath(leftCurtain, curtainPaint);

    // Right curtain
    final rightCurtain = Path()
      ..moveTo(windowLeft + windowWidth + 8, windowTop - 5)
      ..quadraticBezierTo(
        windowLeft + windowWidth - windowWidth * 0.15,
        windowTop + windowHeight * 0.3,
        windowLeft + windowWidth + 5,
        windowTop + windowHeight + 10,
      )
      ..lineTo(windowLeft + windowWidth + 15, windowTop + windowHeight + 10)
      ..quadraticBezierTo(
        windowLeft + windowWidth + 10,
        windowTop + windowHeight * 0.5,
        windowLeft + windowWidth + 15,
        windowTop - 5,
      )
      ..close();
    canvas.drawPath(rightCurtain, curtainPaint);

    // Curtain rod
    canvas.drawLine(
      Offset(windowLeft - 20, windowTop - 8),
      Offset(windowLeft + windowWidth + 20, windowTop - 8),
      Paint()
        ..color = _isDarkTheme
            ? theme.textSecondary.withOpacity(0.3)
            : AppColors.whiteAlpha60
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Moon or sun in window
    if (_isDarkTheme) {
      // Moon
      canvas.drawCircle(
        Offset(windowLeft + windowWidth * 0.7, windowTop + windowHeight * 0.3),
        8,
        Paint()..color = AppOverlays.lightGrey80,
      );
    }
  }

  void _drawLightingEffects(Canvas canvas, double w, double h) {
    // === LAMP GLOW (left side, for cozy evening feel) ===
    if (_isDarkTheme) {
      // Warm lamp glow for night themes
      final lampGlow = Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.5,
          colors: [
            AppColors.whiteAlpha25,
            AppColors.whiteAlpha12,
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.2, w * 0.5, h * 0.5));
      
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.12, h * 0.45),
          width: w * 0.35,
          height: h * 0.4,
        ),
        lampGlow,
      );

      // Small lamp icon hint
      final lampPaint = Paint()
        ..color = AppColors.whiteAlpha60;
      canvas.drawCircle(
        Offset(w * 0.08, h * 0.38),
        6,
        lampPaint,
      );
    } else {
      // Subtle warm ambient light for day themes
      final ambientGlow = Paint()
        ..shader = RadialGradient(
          center: Alignment.topRight,
          radius: 1.2,
          colors: [
            AppOverlays.cream15,
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h));
      
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), ambientGlow);
    }

    // === AQUARIUM GLOW (centerpiece lighting) ===
    final aquariumGlow = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.5,
        colors: [
          theme.waterMid.withOpacity(_isDarkTheme ? 0.25 : 0.15),
          theme.waterMid.withOpacity(_isDarkTheme ? 0.12 : 0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(w * 0.15, h * 0.25, w * 0.7, h * 0.4));
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.42),
        width: w * 0.6,
        height: h * 0.35,
      ),
      aquariumGlow,
    );
  }

  void _drawShelf(Canvas canvas, double w, double h) {
    // Floating shelf on top right (above window area, decorative)
    final shelfY = h * 0.10;
    final shelfPaint = Paint()
      ..color = _isDarkTheme
          ? theme.textSecondary.withOpacity(0.2)
          : AppOverlays.darkWood30;
    
    // Shelf surface
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.72, shelfY, w * 0.22, 4),
        const Radius.circular(2),
      ),
      shelfPaint,
    );

    // Shelf bracket hints
    canvas.drawLine(
      Offset(w * 0.76, shelfY + 4),
      Offset(w * 0.76, shelfY + 12),
      shelfPaint..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(w * 0.90, shelfY + 4),
      Offset(w * 0.90, shelfY + 12),
      shelfPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CozyRoomPainter old) => old.theme != theme;
}

// === ROOM PLANT (decorative floor plant) ===

class _RoomPlant extends StatelessWidget {
  final double height;
  final RoomTheme theme;

  const _RoomPlant({required this.height, required this.theme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: height * 0.5,
      height: height,
      child: CustomPaint(
        painter: _RoomPlantPainter(theme: theme),
      ),
    );
  }
}

class _RoomPlantPainter extends CustomPainter {
  final RoomTheme theme;

  _RoomPlantPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Plant pot
    final potPaint = Paint()..color = AppOverlays.copperBrown70;
    final potPath = Path()
      ..moveTo(w * 0.25, h * 0.75)
      ..lineTo(w * 0.3, h)
      ..lineTo(w * 0.7, h)
      ..lineTo(w * 0.75, h * 0.75)
      ..close();
    canvas.drawPath(potPath, potPaint);
    
    // Pot rim
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.2, h * 0.72, w * 0.6, h * 0.05),
        const Radius.circular(2),
      ),
      potPaint,
    );

    // Plant leaves
    final leafPaint = Paint()..color = theme.plantPrimary.withOpacity(0.8);
    
    // Multiple leaves going up
    for (var i = 0; i < 5; i++) {
      final angle = -0.4 + i * 0.2;
      final leafH = h * (0.5 + (i % 2) * 0.15);
      final startY = h * 0.72;
      
      final leaf = Path()
        ..moveTo(w * 0.5, startY)
        ..quadraticBezierTo(
          w * 0.5 + math.cos(angle) * w * 0.4,
          startY - leafH * 0.5,
          w * 0.5 + math.cos(angle) * w * 0.25,
          startY - leafH,
        )
        ..quadraticBezierTo(
          w * 0.5 + math.cos(angle) * w * 0.2,
          startY - leafH * 0.6,
          w * 0.5,
          startY,
        );
      
      canvas.drawPath(leaf, leafPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// === SHELF PLANT (small decorative plant) ===

class _ShelfPlant extends StatelessWidget {
  final double size;
  final RoomTheme theme;

  const _ShelfPlant({required this.size, required this.theme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ShelfPlantPainter(theme: theme),
      ),
    );
  }
}

class _ShelfPlantPainter extends CustomPainter {
  final RoomTheme theme;

  _ShelfPlantPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Small pot
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.25, h * 0.6, w * 0.5, h * 0.4),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFD4A574).withOpacity(0.8),
    );

    // Small succulent/plant
    final leafPaint = Paint()..color = theme.plantSecondary.withOpacity(0.9);
    for (var i = 0; i < 3; i++) {
      final angle = -0.3 + i * 0.3;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.5 + math.cos(angle) * w * 0.1, h * 0.45),
          width: w * 0.25,
          height: h * 0.3,
        ),
        leafPaint,
      );
    }
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

  bool get _isDarkTheme => theme.background1.computeLuminance() < 0.3;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final woodColor = _isDarkTheme
        ? const Color(0xFF3D3228)
        : const Color(0xFF8B6914).withOpacity(0.7);
    final woodHighlight = _isDarkTheme
        ? const Color(0xFF4A3D30)
        : const Color(0xFFA67C00).withOpacity(0.5);

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
        Rect.fromLTWH(w * 0.05, h * 0.6, w * 0.9, h * 0.12),
        const Radius.circular(2),
      ),
      legPaint,
    );

    // Decorative cabinet door hint
    final doorPaint = Paint()
      ..color = woodHighlight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.2, h * 0.35, w * 0.25, h * 0.55),
        const Radius.circular(2),
      ),
      doorPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.55, h * 0.35, w * 0.25, h * 0.55),
        const Radius.circular(2),
      ),
      doorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StandPainter old) => old.theme != theme;
}

// === CIRCULAR TEMPERATURE GAUGE ===

class _CircularTempGauge extends StatelessWidget {
  final double size;
  final double temperature;
  final RoomTheme theme;

  const _CircularTempGauge({
    required this.size,
    required this.temperature,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.glassCard,
            border: Border.all(color: theme.glassBorder, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppOverlays.black10,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _TempGaugePainter(temperature: temperature, theme: theme),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.thermostat,
                    color: _getTempColor(temperature),
                    size: size * 0.22,
                  ),
                  Text(
                    '${temperature.toStringAsFixed(1)}°',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: size * 0.22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '°C',
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: size * 0.14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getTempColor(double temp) {
    if (temp < 22) return theme.gaugeColor1;
    if (temp < 26) return theme.gaugeColor2;
    if (temp < 28) return theme.gaugeColor3;
    return theme.buttonFeed;
  }
}

class _TempGaugePainter extends CustomPainter {
  final double temperature;
  final RoomTheme theme;

  _TempGaugePainter({required this.temperature, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      Paint()
        ..color = theme.textSecondary.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    final progress = ((temperature - 15) / 20).clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5 * progress,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: math.pi * 0.75,
          endAngle: math.pi * 2.25,
          colors: [
            theme.gaugeColor1,
            theme.gaugeColor2,
            theme.gaugeColor3,
            theme.buttonFeed,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _TempGaugePainter old) =>
      old.temperature != temperature || old.theme != theme;
}

// === WATER QUALITY CARD ===

class _WaterQualityCard extends StatelessWidget {
  final double width;
  final double? ph;
  final double? ammonia;
  final double? nitrate;
  final RoomTheme theme;

  const _WaterQualityCard({
    required this.width,
    required this.theme,
    this.ph,
    this.ammonia,
    this.nitrate,
  });

  // Status colors for water parameters
  static const Color _safe = Color(0xFF4CAF50);    // Green
  static const Color _warning = Color(0xFFFFA726); // Orange
  static const Color _danger = Color(0xFFEF5350);  // Red
  static const Color _unknown = Color(0xFF9E9E9E); // Gray

  Color _getPhColor(double? value) {
    if (value == null) return _unknown;
    if (value >= 6.5 && value <= 7.8) return _safe;
    if (value >= 6.0 && value <= 8.2) return _warning;
    return _danger;
  }

  Color _getAmmoniaColor(double? value) {
    if (value == null) return _unknown;
    if (value <= 0.25) return _safe;
    if (value <= 0.5) return _warning;
    return _danger;
  }

  Color _getNitrateColor(double? value) {
    if (value == null) return _unknown;
    if (value <= 20) return _safe;
    if (value <= 40) return _warning;
    return _danger;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.largeRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.glassCard,
            borderRadius: AppRadius.largeRadius,
            border: Border.all(color: theme.glassBorder, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.water_drop, color: theme.textSecondary, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    'Water Quality',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: _MiniPieChart(
                      value: ph ?? 7.0,
                      maxValue: 14,
                      label: 'pH',
                      color: _getPhColor(ph),
                      theme: theme,
                      size: 38,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: _MiniPieChart(
                      value: ammonia ?? 0,
                      maxValue: 4,
                      label: 'NH₃',
                      color: _getAmmoniaColor(ammonia),
                      theme: theme,
                      size: 38,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: _MiniPieChart(
                      value: nitrate ?? 10,
                      maxValue: 80,
                      label: 'NO₃',
                      color: _getNitrateColor(nitrate),
                      theme: theme,
                      size: 38,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniPieChart extends StatelessWidget {
  final double value;
  final double maxValue;
  final String label;
  final Color color;
  final RoomTheme theme;
  final double size;

  const _MiniPieChart({
    required this.value,
    required this.maxValue,
    required this.label,
    required this.color,
    required this.theme,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _PieChartPainter(
              value: value,
              maxValue: maxValue,
              color: color,
              theme: theme,
            ),
            child: Center(
              child: Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: TextStyle(color: theme.textSecondary, fontSize: 9)),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final double value;
  final double maxValue;
  final Color color;
  final RoomTheme theme;

  _PieChartPainter({
    required this.value,
    required this.maxValue,
    required this.color,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Background
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = theme.textSecondary.withOpacity(0.1),
    );

    // Progress
    final progress = (value / maxValue).clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      true,
      Paint()..color = color.withOpacity(0.6),
    );

    // Inner circle (donut effect)
    canvas.drawCircle(center, radius * 0.6, Paint()..color = theme.background2);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter old) =>
      old.value != value || old.color != color;
}

// === GLASS BADGE ===

class _GlassBadge extends StatelessWidget {
  final String text;
  final String subtext;
  final RoomTheme theme;

  const _GlassBadge({
    required this.text,
    required this.subtext,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.largeRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: AppOverlays.black15,
            borderRadius: AppRadius.largeRadius,
            border: Border.all(color: theme.glassBorder, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: theme.accentBlob.withOpacity(0.4),
                  borderRadius: AppRadius.mediumRadius,
                ),
                child: Text(
                  subtext,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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

// === THEMED AQUARIUM ===

class _ThemedAquarium extends StatelessWidget {
  final double width;
  final double height;
  final RoomTheme theme;
  final bool useRiveFish;

  const _ThemedAquarium({
    required this.width,
    required this.height,
    required this.theme,
    this.useRiveFish = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: AppRadius.largeRadius,
        boxShadow: [
          BoxShadow(
            color: theme.waterMid.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: AppOverlays.black15,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.largeRadius,
        child: Stack(
          children: [
            // Water gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [theme.waterTop, theme.waterMid, theme.waterBottom],
                ),
              ),
            ),

            // Glass frame
            Container(
              decoration: BoxDecoration(
                borderRadius: AppRadius.largeRadius,
                border: Border.all(
                  color: AppOverlays.white50,
                  width: 4,
                ),
              ),
            ),

            // Sand/substrate
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: height * 0.18,
                decoration: BoxDecoration(
                  color: theme.sand,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
            ),

            // Plants with gentle swaying animation
            Positioned(
              bottom: height * 0.15,
              left: width * 0.08,
              child: SwayingPlantTall(
                index: 0,
                child: _SoftPlant(
                  height: height * 0.5,
                  color: theme.plantPrimary,
                ),
              ),
            ),
            Positioned(
              bottom: height * 0.15,
              left: width * 0.22,
              child: SwayingPlantSmall(
                index: 1,
                child: _SoftPlant(
                  height: height * 0.35,
                  color: theme.plantSecondary,
                ),
              ),
            ),
            Positioned(
              bottom: height * 0.15,
              right: width * 0.1,
              child: SwayingPlantTall(
                index: 2,
                child: _SoftPlant(
                  height: height * 0.55,
                  color: theme.plantPrimary,
                ),
              ),
            ),
            Positioned(
              bottom: height * 0.15,
              right: width * 0.28,
              child: SwayingPlant(
                index: 3,
                child: _SoftPlant(
                  height: height * 0.4,
                  color: theme.plantSecondary,
                ),
              ),
            ),

            // Fish - Rive animated or static drawn
            // BACK LAYER FISH (behind plants) - smaller, more distant
            if (useRiveFish) ...[
              // Small fish in back - behind the tall left plant
              Positioned(
                top: height * 0.25,
                left: width * 0.02,
                child: Opacity(
                  opacity: 0.7, // Slightly faded to appear further back
                  child: RiveFish(
                    fishType: RiveFishType.emotional,
                    size: height * 0.18,
                  ),
                ),
              ),
              // Small fish in back - behind right plant
              Positioned(
                top: height * 0.35,
                right: width * 0.02,
                child: Opacity(
                  opacity: 0.7,
                  child: RiveFish(
                    fishType: RiveFishType.joystick,
                    size: height * 0.16,
                    flipHorizontal: true,
                  ),
                ),
              ),
            ],

            // Plants with gentle swaying animation (duplicated for layering)
            Positioned(
              bottom: height * 0.15,
              left: width * 0.08,
              child: SwayingPlantTall(
                index: 0,
                child: _SoftPlant(
                  height: height * 0.5,
                  color: theme.plantPrimary,
                ),
              ),
            ),
            Positioned(
              bottom: height * 0.15,
              left: width * 0.22,
              child: SwayingPlantSmall(
                index: 1,
                child: _SoftPlant(
                  height: height * 0.35,
                  color: theme.plantSecondary,
                ),
              ),
            ),
            Positioned(
              bottom: height * 0.15,
              right: width * 0.1,
              child: SwayingPlantTall(
                index: 2,
                child: _SoftPlant(
                  height: height * 0.55,
                  color: theme.plantPrimary,
                ),
              ),
            ),
            Positioned(
              bottom: height * 0.15,
              right: width * 0.28,
              child: SwayingPlant(
                index: 3,
                child: _SoftPlant(
                  height: height * 0.4,
                  color: theme.plantSecondary,
                ),
              ),
            ),

            // FRONT LAYER FISH (in front of plants) - main fish, larger
            if (useRiveFish) ...[
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
              // Animated swimming fish
              _AnimatedSwimmingFish(
                size: 28,
                color: theme.fish1,
                tankWidth: width,
                tankHeight: height,
                baseTop: 0.22,
                swimSpeed: 10.0,
                verticalBob: 12.0,
                startOffset: 0.0,
              ),
              _AnimatedSwimmingFish(
                size: AppIconSizes.md,
                color: theme.fish2,
                tankWidth: width,
                tankHeight: height,
                baseTop: 0.40,
                swimSpeed: 8.0,
                verticalBob: 18.0,
                startOffset: 0.6,
              ),
              _AnimatedSwimmingFish(
                size: AppIconSizes.sm,
                color: theme.fish3,
                tankWidth: width,
                tankHeight: height,
                baseTop: 0.55,
                swimSpeed: 12.0,
                verticalBob: 10.0,
                startOffset: 0.3,
              ),
            ],

            // Static bubbles (decorative)
            Positioned(
              right: width * 0.18,
              bottom: height * 0.2,
              child: _SoftBubbles(height: height * 0.5),
            ),

            // Animated floating bubbles
            const AmbientBubblesSubtle(bubbleCount: 12),

            // Water surface effect (Rive animated)
            if (useRiveFish)
              const WaterSurfaceOverlay(
                height: 30,
                opacity: 0.3,
              ),

            // Light reflection
            Positioned(
              top: 4,
              left: 4,
              right: 4,
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.whiteAlpha35,
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
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
                  color: const Color(0xFF37474F),
                  borderRadius: AppRadius.xsRadius,
                  boxShadow: [
                    BoxShadow(
                      color: AppOverlays.amber30,
                      blurRadius: 25,
                      spreadRadius: 10,
                      offset: const Offset(0, 15),
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

    // Fin
    final finPath = Path()
      ..moveTo(size.width * 0.25, size.height * 0.2)
      ..quadraticBezierTo(
        size.width * 0.35,
        0,
        size.width * 0.45,
        size.height * 0.15,
      )
      ..close();
    canvas.drawPath(finPath, paint..color = color.withOpacity(0.8));

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
      duration: Duration(milliseconds: (widget.swimSpeed * 1000).toInt()),
      vsync: this,
    );

    // Swim horizontally across tank
    _swimAnimation = Tween<double>(begin: -0.1, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    // Gentle vertical bobbing
    _bobAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.standardSine),
    );

    // Start at offset position
    _controller.value = widget.startOffset;

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _facingRight = !_facingRight;
        });
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _facingRight = !_facingRight;
        });
        _controller.forward();
      }
    });

    _controller.forward();
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
        final swimX = _swimAnimation.value * widget.tankWidth;
        final bobY = _bobAnimation.value * widget.verticalBob;
        final baseY = widget.baseTop * widget.tankHeight;

        return Positioned(
          left: swimX - widget.size,
          top: baseY + bobY,
          child: Transform.scale(
            scaleX: _facingRight ? 1 : -1,
            child: _SoftFish(
              size: widget.size,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}

class _SoftBubbles extends StatelessWidget {
  final double height;

  const _SoftBubbles({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Bubble(size: 10),
          _Bubble(size: 7),
          _Bubble(size: 12),
          _Bubble(size: 6),
          _Bubble(size: 9),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final double size;

  const _Bubble({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppOverlays.white40,
        border: Border.all(color: AppOverlays.white60, width: 1),
      ),
    );
  }
}

// === WAVE GRAPH CARD ===

class _WaveGraphCard extends StatelessWidget {
  final double width;
  final double height;
  final RoomTheme theme;

  const _WaveGraphCard({
    required this.width,
    required this.height,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.largeRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.glassCard,
            borderRadius: AppRadius.largeRadius,
            border: Border.all(color: theme.glassBorder, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Trends',
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Expanded(
                child: CustomPaint(
                  painter: _WaveGraphPainter(theme: theme),
                  size: Size.infinite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaveGraphPainter extends CustomPainter {
  final RoomTheme theme;

  _WaveGraphPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    // Wave line 1 (coral)
    final wave1 = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.15,
        size.height * 0.4,
        size.width * 0.25,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.7,
        size.width * 0.5,
        size.height * 0.45,
      )
      ..quadraticBezierTo(
        size.width * 0.65,
        size.height * 0.2,
        size.width * 0.75,
        size.height * 0.4,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.6,
        size.width,
        size.height * 0.35,
      );

    canvas.drawPath(
      wave1,
      Paint()
        ..color = theme.accentBlob
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Wave line 2 (teal)
    final wave2 = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.2,
        size.height * 0.5,
        size.width * 0.3,
        size.height * 0.35,
      )
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.15,
        size.width * 0.55,
        size.height * 0.3,
      )
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.5,
        size.width * 0.8,
        size.height * 0.25,
      )
      ..quadraticBezierTo(
        size.width * 0.95,
        size.height * 0.1,
        size.width,
        size.height * 0.2,
      );

    canvas.drawPath(
      wave2,
      Paint()
        ..color = theme.waterMid
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Dots
    final dotPaint = Paint()..color = theme.textPrimary;
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.5),
      4,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.45),
      4,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.4),
      4,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WaveGraphPainter old) => old.theme != theme;
}
