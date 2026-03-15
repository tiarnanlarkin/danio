import 'package:danio/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../theme/room_themes.dart';
import 'ambient/ambient_bubbles.dart';
import 'ambient/ambient_overlay.dart';
import 'ambient/swaying_plant.dart';
import 'effects/ripple_container.dart';
import 'room/interactive_object.dart';
import 'rive/rive_fish.dart';
import 'rive/rive_water_effect.dart';
import 'stage/stage_provider.dart';
import 'stage/tank_glass_badge.dart';
import 'stage/swiss_army_panel.dart';

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
              // === LAYER 1: Cozy room background with walls, floor, window ===
              // AmbientLightingOverlay wraps ONLY the room background — not the tank
              Positioned.fill(
                child: AmbientLightingOverlay(
                  child: _CozyRoomBackground(theme: theme),
                ),
              ),

              // === LAYER 2: Decorative room elements (plants, shelves, lamp) ===
              // Tall plant on left side — BUG-03: repositioned to stay above stand boundary
              Positioned(
                bottom: h * 0.38,
                left: w * 0.02,
                child: _RoomPlant(height: h * 0.20, theme: theme),
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

              // === LAYER 5: Tank badge ===
              // Note: StageHandleStrip widgets are rendered by home_screen.dart
              // (full-height Positioned, 48dp hit area) — do NOT add them here
              // or they will appear as duplicate tabs.

              // Tank glass badge (bottom-right of tank)
              Positioned(
                bottom: h * 0.27,
                right: w * 0.12,
                child: TankGlassBadge(
                  tankName: tankName,
                  tankVolume: tankVolume,
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

              // P0-3 FIX: Add visual tap targets for test kit, food, and plant
              if (onTestKitTap != null)
                Positioned(
                  bottom: h * 0.28,
                  left: w * 0.05,
                  child: InteractiveObject(
                    icon: Icons.science_rounded,
                    label: 'Test Kit',
                    onTap: onTestKitTap,
                    size: 44,
                    iconColor: const Color(0xFF64B5F6),
                    glowColor: const Color(0xFF64B5F6),
                    isNewUser: isNewUser,
                    animationStyle: InteractiveAnimationStyle.shimmer,
                  ),
                ),

              if (onFoodTap != null)
                Positioned(
                  bottom: h * 0.28,
                  left: w * 0.38,
                  child: InteractiveObject(
                    icon: Icons.restaurant_rounded,
                    label: 'Feed',
                    onTap: onFoodTap,
                    size: 44,
                    iconColor: const Color(0xFFFF8A65),
                    glowColor: const Color(0xFFFF8A65),
                    isNewUser: isNewUser,
                    animationStyle: InteractiveAnimationStyle.bounce,
                  ),
                ),

              if (onPlantTap != null)
                Positioned(
                  bottom: h * 0.28,
                  right: w * 0.05,
                  child: InteractiveObject(
                    icon: Icons.eco_rounded,
                    label: 'Plants',
                    onTap: onPlantTap,
                    size: 44,
                    iconColor: const Color(0xFF81C784),
                    glowColor: const Color(0xFF81C784),
                    isNewUser: isNewUser,
                    animationStyle: InteractiveAnimationStyle.pulse,
                  ),
                ),

              // Theme switcher hint (top center)
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Semantics(
                    label: 'Change room theme',
                    button: true,
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
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: theme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
    return Stack(
      children: [
        CustomPaint(
          painter: _CozyRoomPainter(theme: theme),
          size: Size.infinite,
        ),
        // Linen texture overlay for material depth — warm amber tint at 20% opacity
        Positioned.fill(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              const Color(0xFFD4956C).withAlpha(30), // subtle warm amber wash
              BlendMode.srcATop,
            ),
            child: Opacity(
              opacity: 0.25,
              child: Image.asset(
                'assets/textures/linen-wall.webp',
                repeat: ImageRepeat.repeat,
                fit: BoxFit.none,
                cacheWidth: 256,
                cacheHeight: 256,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CozyRoomPainter extends CustomPainter {
  final RoomTheme theme;

  _CozyRoomPainter({required this.theme});

  // Pre-computed withAlpha colors to avoid per-frame allocations in paint()
  late final Color _trimAlpha102 = _trimColor.withAlpha(102);
  late final Color _textSecAlpha76 = theme.textSecondary.withAlpha(76);
  late final Color _textSecAlpha64 = theme.textSecondary.withAlpha(64);
  late final Color _textSecAlpha51 = theme.textSecondary.withAlpha(51);
  late final Color _waterMidAlpha64 = theme.waterMid.withAlpha(64);
  late final Color _waterMidAlpha38 = theme.waterMid.withAlpha(38);
  late final Color _waterMidAlpha31 = theme.waterMid.withAlpha(31);
  late final Color _waterMidAlpha13 = theme.waterMid.withAlpha(13);

  // Warm lighting constants (not theme-dependent)
  static const _lampAmber38 = Color(0x26FFB347);  // #FFB347 at alpha 38
  static const _lampAmber20 = Color(0x14FFB347);  // #FFB347 at alpha 20
  static const _lampBright = Color(0xFFFFCC66);    // Lamp indicator
  static const _warmHoney25 = Color(0x19F5D68B);  // #F5D68B at alpha 25
  static const _tankGlow15 = Color(0x0FFFD68B);   // #FFD68B at alpha 15
  static const _tankGlow20 = Color(0x14FFD68B);   // #FFD68B at alpha 20

  // Determine if this is a dark/night theme
  bool get _isDarkTheme {
    final luminance = theme.background1.computeLuminance();
    return luminance < 0.3;
  }

  // Cozy room uses warm base colors regardless of theme
  Color get _wallColor => _isDarkTheme 
      ? const Color(0xFF3D3830) // Warm charcoal-brown
      : const Color(0xFFF2E6D9); // Warmer golden cream

  Color get _wallAccent => _isDarkTheme
      ? const Color(0xFF4A4238) // Warm gray-brown
      : const Color(0xFFE8D8C8); // Deeper warm cream

  Color get _floorColor => _isDarkTheme
      ? const Color(0xFF5A4030) // Deep espresso
      : const Color(0xFFA0805C); // Rich walnut

  Color get _trimColor => _isDarkTheme
      ? const Color(0xFF584038) // Dark mahogany
      : const Color(0xFF6B4E35); // Warm mahogany

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
      ..color = Color.lerp(_wallAccent, _floorColor, 0.25)!;
    canvas.drawRect(
      Rect.fromLTWH(0, panelTop, w, h * 0.17),
      panelPaint,
    );
    
    // Panel trim line
    canvas.drawLine(
      Offset(0, panelTop),
      Offset(w, panelTop),
      Paint()
        ..color = _trimAlpha102
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
    
    for (var y = floorTop + 15; y < h; y += 22) {
      canvas.drawLine(Offset(0, y), Offset(w, y), floorLinePaint);
    }
    
    // Vertical floor board joints
    final jointPaint = Paint()
      ..color = (_isDarkTheme ? AppColors.blackAlpha08 : AppColors.woodBrownAlpha08)
      ..strokeWidth = 1;
    for (var x = 0.0; x < w; x += 80) {
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
    final rugRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.05, floorTop + 8, w * 0.9, h * 0.12),
      const Radius.circular(12),  // softened from 8
    );
    
    // Double-border pattern: outer ring = rust-copper fill band, centre = rugBase
    // Step 1: Fill whole rug with border band colour (#D88C6E / dark equivalent)
    canvas.drawRRect(
      rugRect,
      Paint()..color = _isDarkTheme 
          ? const Color(0xFF7A4A34)   // dark rust-copper band
          : const Color(0xFFD88C6E),  // rust-copper band
    );
    
    // Step 2: Fill inner field with rugBase (covers centre, leaving border ring visible)
    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.05 + 8, floorTop + 16, w * 0.9 - 16, h * 0.12 - 16),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      innerRect,
      Paint()..color = _isDarkTheme
          ? const Color(0xFF8B4F3A)   // dark rust (rugBaseDark)
          : const Color(0xFFC4725A),  // persian rust (rugBase)
    );
    
    // Outer border
    canvas.drawRRect(
      rugRect,
      Paint()
        ..color = _isDarkTheme
            ? const Color(0xFF6B3828)   // dark burgundy
            : const Color(0xFF964B38)   // deep burgundy
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    
    // Inner border
    canvas.drawRRect(
      innerRect,
      Paint()
        ..color = _isDarkTheme
            ? const Color(0xFF7A5A42)   // muted terracotta
            : const Color(0xFFD88C6E)   // warm terracotta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }
  
  void _drawPicture(Canvas canvas, double w, double h) {
    // Small framed picture on wall (left side, above tank)
    final frameLeft = w * 0.02;
    final frameTop = h * 0.22;
    final frameWidth = w * 0.14;
    final frameHeight = h * 0.10;
    
    // Frame
    final frameRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(frameLeft, frameTop, frameWidth, frameHeight),
      const Radius.circular(2),
    );
    canvas.drawRRect(
      frameRect,
      Paint()..color = _trimColor,
    );
    
    // Picture content — mini landscape painting
    final pictureInset = 3.0;
    final pictureRect = Rect.fromLTWH(
      frameLeft + pictureInset, frameTop + pictureInset,
      frameWidth - pictureInset * 2, frameHeight - pictureInset * 2,
    );
    // Sky band (top half)
    canvas.drawRect(
      Rect.fromLTWH(pictureRect.left, pictureRect.top,
          pictureRect.width, pictureRect.height / 2),
      Paint()..color = _isDarkTheme
          ? const Color(0x806A90A0)   // muted sky
          : const Color(0x998BB8C8),  // sky blue-grey
    );
    // Ground band (bottom half)
    canvas.drawRect(
      Rect.fromLTWH(pictureRect.left, pictureRect.top + pictureRect.height / 2,
          pictureRect.width, pictureRect.height / 2),
      Paint()..color = _isDarkTheme
          ? const Color(0x804A7A50)   // dark sage
          : const Color(0x996B9B6B),  // sage green
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

    // Warm interior glow on window glass (dark mode only)
    if (_isDarkTheme) {
      canvas.drawRRect(
        windowRect,
        Paint()..color = const Color(0x26FFE4B5),  // warm interior glow at 15% alpha
      );
    }

    // Window frame border
    canvas.drawRRect(
      windowRect,
      Paint()
        ..color = _isDarkTheme
            ? _textSecAlpha76
            : AppColors.whiteAlpha50
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Window cross bars
    final crossPaint = Paint()
      ..color = _isDarkTheme
          ? _textSecAlpha64
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
        ? const Color(0x807A6050) 
        : const Color(0x99B88A68);
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
            ? _textSecAlpha76
            : AppColors.whiteAlpha60
        ..strokeWidth = 4
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
          radius: 0.6,
          colors: [
            _lampAmber38,
            _lampAmber20,
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
        ..color = _lampBright;
      canvas.drawCircle(
        Offset(w * 0.08, h * 0.38),
        8,
        lampPaint,
      );
    } else {
      // Subtle warm ambient light for day themes
      final ambientGlow = Paint()
        ..shader = RadialGradient(
          center: Alignment.topRight,
          radius: 1.2,
          colors: [
            _warmHoney25,
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
          _isDarkTheme ? _waterMidAlpha64 : _waterMidAlpha38,
          _isDarkTheme ? _waterMidAlpha31 : _waterMidAlpha13,
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

    // === TANK BACKGLOW (warm radiating effect behind tank) ===
    final tankBackglow = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.5,
        colors: [
          _isDarkTheme ? _tankGlow20 : _tankGlow15,
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(w * 0.15, h * 0.48, w * 0.7, h * 0.15));
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.56),
        width: w * 0.7,
        height: h * 0.15,
      ),
      tankBackglow,
    );
  }

  void _drawShelf(Canvas canvas, double w, double h) {
    // Floating shelf on top right (above window area, decorative)
    final shelfY = h * 0.10;
    final shelfPaint = Paint()
      ..color = _isDarkTheme
          ? _textSecAlpha51
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

    // Decorative candles
    final candleBaseY = shelfY;
    const candleBodyColor = Color(0xFFF5EDE0);
    const candleWickColor = Color(0xFF4A3D30);
    const candleFlameColor = Color(0xFFFFB347);
    const candleGlowColor = Color(0x14FFCC66);

    // Candle 1
    final c1x = w * 0.76;
    canvas.drawRect(Rect.fromLTWH(c1x, candleBaseY - 10, 3.5, 10), Paint()..color = candleBodyColor);
    canvas.drawLine(Offset(c1x + 1.75, candleBaseY - 10), Offset(c1x + 1.75, candleBaseY - 12), Paint()..color = candleWickColor..strokeWidth = 1);
    canvas.drawCircle(Offset(c1x + 1.75, candleBaseY - 13), 2.5, Paint()..color = candleFlameColor);
    canvas.drawCircle(Offset(c1x + 1.75, candleBaseY - 13), 8, Paint()..color = candleGlowColor);

    // Candle 2
    final c2x = w * 0.82;
    canvas.drawRect(Rect.fromLTWH(c2x, candleBaseY - 12, 4, 12), Paint()..color = candleBodyColor);
    canvas.drawLine(Offset(c2x + 2, candleBaseY - 12), Offset(c2x + 2, candleBaseY - 14), Paint()..color = candleWickColor..strokeWidth = 1);
    canvas.drawCircle(Offset(c2x + 2, candleBaseY - 15), 3, Paint()..color = candleFlameColor);
    canvas.drawCircle(Offset(c2x + 2, candleBaseY - 15), 9, Paint()..color = candleGlowColor);
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
  late final Color _leafColor = theme.plantPrimary.withAlpha(204);

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
    final leafPaint = Paint()..color = _leafColor;
    
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
  late final Color _leafColor = theme.plantSecondary.withAlpha(230);

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
      Paint()..color = const Color(0xCCD4A574),
    );

    // Small succulent/plant
    final leafPaint = Paint()..color = _leafColor;
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

    // Dark charcoal metal frame per §6.4 — NOT wood coloured
    const woodColor = Color(0xFF2A2A2A);      // standPrimary charcoal
    const woodHighlight = Color(0xFF404040);  // standHighlight

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

    // Shelf items
    final shelfTop = h * 0.6;

    // Book stack (left third)
    final bookColors = [
      const Color(0xFF4A6B8C),
      const Color(0xFF8B5E3C),
      const Color(0xFF5A8060),
      const Color(0xFFC4725A),
    ];
    final bookOpacity = _isDarkTheme ? 0.8 : 1.0;
    var bookY = shelfTop - 4;
    for (var i = 0; i < 4; i++) {
      final bw = w * (0.18 + (i % 2 == 0 ? 0.02 : 0));
      bookY -= h * 0.06;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.15, bookY, bw, h * 0.055),
          const Radius.circular(1),
        ),
        Paint()..color = bookColors[i].withAlpha((255 * bookOpacity).round()),
      );
    }

    // Small potted plant (centre)
    final potX = w * 0.47;
    final potW = w * 0.06;
    final potH = h * 0.08;
    final potTop = shelfTop - potH;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(potX, potTop + potH * 0.4, potW, potH * 0.6),
        const Radius.circular(2),
      ),
      Paint()..color = Color.fromARGB(_isDarkTheme ? 204 : 255, 0xC0, 0x82, 0x5A),
    );
    final leafPaint = Paint()
      ..color = (theme.plantSecondary).withAlpha(_isDarkTheme ? 204 : 255);
    canvas.drawOval(
      Rect.fromLTWH(potX - potW * 0.2, potTop, potW * 0.7, potH * 0.5),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(potX + potW * 0.4, potTop + potH * 0.1, potW * 0.7, potH * 0.45),
      leafPaint,
    );

    // Decorative vase (right third)
    final vaseX = w * 0.65;
    final vaseW = w * 0.08;
    final vaseH = h * 0.10;
    final vaseTop = shelfTop - vaseH + 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(vaseX, vaseTop, vaseW, vaseH),
        Radius.circular(vaseW * 0.3),
      ),
      Paint()..color = Color.fromARGB(_isDarkTheme ? 178 : 255, 0x8B, 0xAE, 0xB8),
    );
    canvas.drawLine(
      Offset(vaseX + vaseW * 0.25, vaseTop + vaseH * 0.15),
      Offset(vaseX + vaseW * 0.25, vaseTop + vaseH * 0.7),
      Paint()
        ..color = const Color(0x40FFFFFF)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
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
            // MUST use Positioned.fill so the gradient fills the entire tank
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.25, 0.65, 1.0],
                    colors: [
                      Color(0xFF9ED8EC), // waterSurface — icy top
                      Color(0xFF6BBDD8), // waterMidUpper — clear mid
                      Color(0xFF4A9DB5), // waterMidLower — deeper
                      Color(0xFF2D7A94), // waterDepth — dark bottom
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
                height: height * 0.18,
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
                child: RiveFish(
                  fishType: RiveFishType.emotional,
                  size: height * 0.18,
                ),
              ),
              // Small fish in back - behind right plant
              Positioned(
                top: height * 0.35,
                right: width * 0.02,
                child: RiveFish(
                  fishType: RiveFishType.joystick,
                  size: height * 0.16,
                  flipHorizontal: true,
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
                      color: const Color(0x33FFD080), // subtle warm glow, 20% alpha
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




