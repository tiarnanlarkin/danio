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

/// Themeable room scene - supports multiple visual styles
/// Includes day/night ambient lighting overlay based on real time.
class LivingRoomScene extends ConsumerWidget {
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

  const LivingRoomScene({
    super.key,
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
                // === LAYER 1: Organic abstract background ===
                Positioned.fill(child: _OrganicBackground(theme: theme)),

              // === LAYER 2: Decorative elements ===
              // Stars/sparkles for whimsical themes
              if (theme.name == 'Whimsical') ...[
                Positioned(
                  top: h * 0.15,
                  left: w * 0.1,
                  child: _Sparkle(size: 12, color: theme.accentCircles[0]),
                ),
                Positioned(
                  top: h * 0.25,
                  right: w * 0.15,
                  child: _Sparkle(size: 8, color: theme.accentCircles[1]),
                ),
                Positioned(
                  top: h * 0.45,
                  left: w * 0.05,
                  child: _Sparkle(size: 10, color: theme.accentCircles[2]),
                ),
                Positioned(
                  bottom: h * 0.35,
                  right: w * 0.08,
                  child: _Sparkle(size: 14, color: theme.accentCircles[0]),
                ),
              ],

              // === LAYER 3: 3D Aquarium illustration (center) ===
              Positioned(
                top: h * 0.28,
                left: w * 0.1,
                right: w * 0.1,
                child: RippleContainer(
                  onTap: onTankTap,
                  child: _ThemedAquarium(
                    width: w * 0.8,
                    height: h * 0.32,
                    theme: theme,
                  ),
                ),
              ),

              // === LAYER 4: Glassmorphic UI cards ===

              // Temperature gauge (top left)
              Positioned(
                top: h * 0.06,
                left: w * 0.05,
                child: GestureDetector(
                  onTap: onStatsTap,
                  child: _CircularTempGauge(
                    size: w * 0.28,
                    temperature: temperature ?? 25,
                    theme: theme,
                  ),
                ),
              ),

              // Water quality card (top right)
              Positioned(
                top: h * 0.06,
                right: w * 0.05,
                child: GestureDetector(
                  onTap: onTestKitTap,
                  child: _WaterQualityCard(
                    width: w * 0.38,
                    ph: ph,
                    ammonia: ammonia,
                    nitrate: nitrate,
                    theme: theme,
                  ),
                ),
              ),

              // Tank name badge
              Positioned(
                top: h * 0.22,
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
                bottom: h * 0.12,
                left: w * 0.08,
                right: w * 0.08,
                child: _WaveGraphCard(
                  width: w * 0.84,
                  height: 70,
                  theme: theme,
                ),
              ),

              // Action buttons removed - now using SpeedDialFAB in home_screen

              // === LAYER 5: Interactive objects ===
              // Journal object (left side of scene)
              if (onJournalTap != null)
                Positioned(
                  bottom: h * 0.25,
                  left: w * 0.05,
                  child: LivingRoomObjects.journal(
                    onTap: onJournalTap!,
                    isNewUser: isNewUser,
                  ),
                ),

              // Calendar/Schedule object (right side of scene)
              if (onCalendarTap != null)
                Positioned(
                  bottom: h * 0.25,
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

// === SPARKLE (for whimsical theme) ===

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
      ..color = color.withOpacity(0.6)
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

// === ORGANIC ABSTRACT BACKGROUND ===

class _OrganicBackground extends StatelessWidget {
  final RoomTheme theme;

  const _OrganicBackground({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.background1, theme.background2, theme.background3],
        ),
      ),
      child: CustomPaint(
        painter: _OrganicShapesPainter(theme: theme),
        size: Size.infinite,
      ),
    );
  }
}

class _OrganicShapesPainter extends CustomPainter {
  final RoomTheme theme;

  _OrganicShapesPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    // Large wave (top)
    final wave1Paint = Paint()
      ..color = theme.primaryWave.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final wave1 = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height * 0.2)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.12,
        size.width * 0.5,
        size.height * 0.2,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.28,
        size.width,
        size.height * 0.15,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(wave1, wave1Paint);

    // Accent blob (right side)
    final blobPaint = Paint()
      ..color = theme.accentBlob.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final blob = Path()
      ..moveTo(size.width * 0.7, size.height * 0.12)
      ..quadraticBezierTo(
        size.width * 1.1,
        size.height * 0.22,
        size.width * 0.95,
        size.height * 0.42,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.48,
        size.width * 0.85,
        size.height * 0.32,
      )
      ..quadraticBezierTo(
        size.width * 0.65,
        size.height * 0.22,
        size.width * 0.7,
        size.height * 0.12,
      );

    canvas.drawPath(blob, blobPaint);

    // Second blob (bottom left)
    final blob2 = Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.18,
        size.height * 0.5,
        size.width * 0.22,
        size.height * 0.68,
      )
      ..quadraticBezierTo(
        size.width * 0.12,
        size.height * 0.82,
        0,
        size.height * 0.78,
      )
      ..close();

    canvas.drawPath(
      blob2,
      Paint()..color = theme.accentBlob2.withOpacity(0.35),
    );

    // Bottom wave
    final wave2Paint = Paint()
      ..color = theme.secondaryWave.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final wave2 = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.78,
        size.width * 0.5,
        size.height * 0.85,
      )
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.92,
        size.width,
        size.height * 0.82,
      )
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(wave2, wave2Paint);

    // Accent circles
    for (var i = 0; i < theme.accentCircles.length; i++) {
      final positions = [
        Offset(size.width * 0.15, size.height * 0.32),
        Offset(size.width * 0.88, size.height * 0.68),
        Offset(size.width * 0.6, size.height * 0.1),
      ];
      final sizes = [22.0, 16.0, 10.0];

      if (i < positions.length) {
        canvas.drawCircle(
          positions[i],
          sizes[i],
          Paint()..color = theme.accentCircles[i].withOpacity(0.25),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OrganicShapesPainter old) => old.theme != theme;
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
          padding: const EdgeInsets.all(16),
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
                  Icon(Icons.water_drop, color: theme.textSecondary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Water Quality',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
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
                      size: 42,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: _MiniPieChart(
                      value: ammonia ?? 0,
                      maxValue: 4,
                      label: 'NH₃',
                      color: _getAmmoniaColor(ammonia),
                      theme: theme,
                      size: 42,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: _MiniPieChart(
                      value: nitrate ?? 10,
                      maxValue: 80,
                      label: 'NO₃',
                      color: _getNitrateColor(nitrate),
                      theme: theme,
                      size: 42,
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
        Text(label, style: TextStyle(color: theme.textSecondary, fontSize: 10)),
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.accentBlob.withOpacity(0.4),
                  borderRadius: AppRadius.mediumRadius,
                ),
                child: Text(
                  subtext,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 12,
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

  const _ThemedAquarium({
    required this.width,
    required this.height,
    required this.theme,
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

            // Fish
            Positioned(
              top: height * 0.22,
              left: width * 0.2,
              child: _SoftFish(size: 28, color: theme.fish1),
            ),
            Positioned(
              top: height * 0.4,
              right: width * 0.18,
              child: _SoftFish(size: 24, color: theme.fish2, flip: true),
            ),
            Positioned(
              top: height * 0.55,
              left: width * 0.45,
              child: _SoftFish(size: 20, color: theme.fish3),
            ),

            // Static bubbles (decorative)
            Positioned(
              right: width * 0.18,
              bottom: height * 0.2,
              child: _SoftBubbles(height: height * 0.5),
            ),

            // Animated floating bubbles
            const AmbientBubblesSubtle(bubbleCount: 12),

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
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.35),
                      Colors.white.withOpacity(0.0),
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
                      color: Colors.amber.withOpacity(0.3),
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
  final bool flip;

  const _SoftFish({required this.size, required this.color, this.flip = false});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flip ? -1 : 1,
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
          padding: const EdgeInsets.all(16),
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
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
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
