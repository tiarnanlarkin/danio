import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

/// Interactive thermometer - tap to see temperature
class ThermometerItem extends StatelessWidget {
  final double? temperature;
  final VoidCallback? onTap;
  final double height;

  const ThermometerItem({
    super.key,
    this.temperature,
    this.onTap,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    final fillPercent = temperature != null
        ? ((temperature! - 15) / 20).clamp(0.0, 1.0)
        : 0.3;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: height * 0.3,
        height: height,
        child: CustomPaint(
          painter: _ThermometerPainter(
            fillPercent: fillPercent,
            color: _tempColor(temperature),
          ),
        ),
      ),
    );
  }

  Color _tempColor(double? temp) {
    if (temp == null) return AppColors.textHint;
    if (temp < 22) return AppColors.info;
    if (temp < 26) return AppColors.success;
    if (temp < 30) return AppColors.warning;
    return AppColors.error;
  }
}

class _ThermometerPainter extends CustomPainter {
  final double fillPercent;
  final Color color;

  _ThermometerPainter({required this.fillPercent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final bulbRadius = size.width * 0.45;
    final tubeWidth = size.width * 0.35;
    final tubeLeft = (size.width - tubeWidth) / 2;

    // Glass outline
    final glassPaint = Paint()
      ..color = AppOverlays.white80
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = AppColors.textHint.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw tube
    final tubeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(tubeLeft, 8, tubeWidth, size.height - bulbRadius - 8),
      Radius.circular(tubeWidth / 2),
    );
    canvas.drawRRect(tubeRect, glassPaint);
    canvas.drawRRect(tubeRect, outlinePaint);

    // Draw bulb
    canvas.drawCircle(
      Offset(size.width / 2, size.height - bulbRadius),
      bulbRadius,
      glassPaint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height - bulbRadius),
      bulbRadius,
      outlinePaint,
    );

    // Fill (mercury)
    final fillPaint = Paint()..color = color;
    final fillHeight = (size.height - bulbRadius * 2 - 16) * fillPercent;

    // Bulb fill
    canvas.drawCircle(
      Offset(size.width / 2, size.height - bulbRadius),
      bulbRadius * 0.7,
      fillPaint,
    );

    // Tube fill
    final innerTubeWidth = tubeWidth * 0.5;
    final innerTubeLeft = (size.width - innerTubeWidth) / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          innerTubeLeft,
          size.height - bulbRadius - fillHeight - 4,
          innerTubeWidth,
          fillHeight + 4,
        ),
        Radius.circular(innerTubeWidth / 2),
      ),
      fillPaint,
    );

    // Tick marks
    final tickPaint = Paint()
      ..color = AppColors.textHint.withOpacity(0.4)
      ..strokeWidth = 1;

    for (var i = 0; i < 5; i++) {
      final y = 16 + (size.height - bulbRadius * 2 - 24) * (i / 4);
      canvas.drawLine(
        Offset(tubeLeft - 2, y),
        Offset(tubeLeft + 4, y),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ThermometerPainter old) =>
      old.fillPercent != fillPercent || old.color != color;
}

/// Test tube rack with tubes showing water params
class TestTubeRack extends StatelessWidget {
  final double? ph;
  final double? ammonia;
  final double? nitrite;
  final double? nitrate;
  final VoidCallback? onTap;
  final double width;

  const TestTubeRack({
    super.key,
    this.ph,
    this.ammonia,
    this.nitrite,
    this.nitrate,
    this.onTap,
    this.width = 100,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: width * 0.9,
        child: CustomPaint(
          painter: _TestTubeRackPainter(
            colors: [
              _phColor(ph),
              _ammoniaColor(ammonia),
              _nitriteColor(nitrite),
              _nitrateColor(nitrate),
            ],
          ),
        ),
      ),
    );
  }

  Color _phColor(double? val) {
    if (val == null) return Colors.grey.shade300;
    if (val < 6.5) return Colors.orange;
    if (val < 7.5) return Colors.green;
    return Colors.blue;
  }

  Color _ammoniaColor(double? val) {
    if (val == null) return Colors.grey.shade300;
    if (val < 0.25) return Colors.yellow.shade200;
    if (val < 1.0) return Colors.green.shade300;
    return Colors.green.shade600;
  }

  Color _nitriteColor(double? val) {
    if (val == null) return Colors.grey.shade300;
    if (val < 0.25) return Colors.purple.shade100;
    if (val < 1.0) return Colors.purple.shade300;
    return Colors.purple.shade600;
  }

  Color _nitrateColor(double? val) {
    if (val == null) return Colors.grey.shade300;
    if (val < 20) return Colors.orange.shade100;
    if (val < 40) return Colors.orange.shade300;
    return Colors.orange.shade600;
  }
}

class _TestTubeRackPainter extends CustomPainter {
  final List<Color> colors;

  _TestTubeRackPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final rackPaint = Paint()
      ..color = const Color(0xFFD4A574)
      ..style = PaintingStyle.fill;

    // Rack base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, size.height - 12, size.width - 8, 12),
        const Radius.circular(3),
      ),
      rackPaint,
    );

    // Rack top holder
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, size.height * 0.35, size.width - 8, 8),
        const Radius.circular(2),
      ),
      rackPaint,
    );

    // Draw 4 test tubes
    final tubeWidth = (size.width - 24) / 4;
    final glassPaint = Paint()
      ..color = AppOverlays.white60
      ..style = PaintingStyle.fill;
    final outlinePaint = Paint()
      ..color = AppColors.textHint.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final x = 10 + i * (tubeWidth + 4);
      final tubeHeight = size.height * 0.65;

      // Tube glass
      final tubePath = Path()
        ..moveTo(x, size.height * 0.3)
        ..lineTo(x, size.height * 0.3 + tubeHeight - tubeWidth / 2)
        ..arcToPoint(
          Offset(x + tubeWidth, size.height * 0.3 + tubeHeight - tubeWidth / 2),
          radius: Radius.circular(tubeWidth / 2),
        )
        ..lineTo(x + tubeWidth, size.height * 0.3)
        ..close();

      canvas.drawPath(tubePath, glassPaint);
      canvas.drawPath(tubePath, outlinePaint);

      // Liquid fill
      final fillPaint = Paint()..color = colors[i].withOpacity(0.8);
      final fillHeight = tubeHeight * 0.6;
      final fillPath = Path()
        ..moveTo(x + 2, size.height * 0.3 + tubeHeight - fillHeight)
        ..lineTo(x + 2, size.height * 0.3 + tubeHeight - tubeWidth / 2)
        ..arcToPoint(
          Offset(
            x + tubeWidth - 2,
            size.height * 0.3 + tubeHeight - tubeWidth / 2,
          ),
          radius: Radius.circular(tubeWidth / 2 - 2),
        )
        ..lineTo(x + tubeWidth - 2, size.height * 0.3 + tubeHeight - fillHeight)
        ..close();

      canvas.drawPath(fillPath, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TestTubeRackPainter old) =>
      old.colors != colors;
}

/// Filter canister with visible media layers
class FilterItem extends StatelessWidget {
  final List<String>? mediaTypes; // e.g., ['sponge', 'ceramic', 'carbon']
  final bool isRunning;
  final VoidCallback? onTap;
  final double height;

  const FilterItem({
    super.key,
    this.mediaTypes,
    this.isRunning = true,
    this.onTap,
    this.height = 90,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: height * 0.6,
        height: height,
        child: CustomPaint(
          painter: _FilterPainter(
            mediaTypes: mediaTypes ?? ['sponge', 'ceramic', 'carbon'],
            isRunning: isRunning,
          ),
        ),
      ),
    );
  }
}

class _FilterPainter extends CustomPainter {
  final List<String> mediaTypes;
  final bool isRunning;

  _FilterPainter({required this.mediaTypes, required this.isRunning});

  @override
  void paint(Canvas canvas, Size size) {
    // Canister body
    final bodyPaint = Paint()
      ..color = const Color(0xFF4A5568)
      ..style = PaintingStyle.fill;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(4, 16, size.width - 8, size.height - 20),
      const Radius.circular(6),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Lid
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 8, size.width - 4, 12),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF2D3748),
    );

    // Tubes coming out
    final tubePaint = Paint()
      ..color = const Color(0xFF718096)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.3, 8),
      Offset(size.width * 0.3, 0),
      tubePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 8),
      Offset(size.width * 0.7, 0),
      tubePaint,
    );

    // Media layers (visible through "window")
    final windowRect = Rect.fromLTWH(8, 24, size.width - 16, size.height - 36);

    // Window background
    canvas.drawRect(windowRect, Paint()..color = const Color(0xFF1A202C));

    // Draw media layers
    final layerHeight = windowRect.height / mediaTypes.length;
    for (var i = 0; i < mediaTypes.length; i++) {
      final layerRect = Rect.fromLTWH(
        windowRect.left + 2,
        windowRect.top + i * layerHeight + 1,
        windowRect.width - 4,
        layerHeight - 2,
      );
      canvas.drawRect(layerRect, Paint()..color = _mediaColor(mediaTypes[i]));

      // Add texture based on media type
      _drawMediaTexture(canvas, layerRect, mediaTypes[i]);
    }

    // Running indicator light
    canvas.drawCircle(
      Offset(size.width - 10, size.height - 8),
      3,
      Paint()..color = isRunning ? AppColors.success : AppColors.error,
    );
  }

  Color _mediaColor(String type) {
    switch (type.toLowerCase()) {
      case 'sponge':
        return const Color(0xFF2D3748);
      case 'ceramic':
        return const Color(0xFFE2E8F0);
      case 'carbon':
        return const Color(0xFF1A1A1A);
      case 'bio':
        return const Color(0xFF9AE6B4);
      case 'floss':
        return const Color(0xFFF7FAFC);
      default:
        return const Color(0xFF718096);
    }
  }

  void _drawMediaTexture(Canvas canvas, Rect rect, String type) {
    final paint = Paint()
      ..color = AppOverlays.white20
      ..strokeWidth = 1;

    switch (type.toLowerCase()) {
      case 'sponge':
        // Dots for pores
        for (var x = rect.left + 4; x < rect.right - 4; x += 6) {
          for (var y = rect.top + 3; y < rect.bottom - 3; y += 5) {
            canvas.drawCircle(Offset(x, y), 1, paint);
          }
        }
        break;
      case 'ceramic':
        // Small rings for ceramic rings
        for (var x = rect.left + 5; x < rect.right - 5; x += 8) {
          for (var y = rect.top + 4; y < rect.bottom - 4; y += 6) {
            canvas.drawCircle(
              Offset(x, y),
              2,
              Paint()
                ..color = Colors.grey.shade400
                ..style = PaintingStyle.stroke,
            );
          }
        }
        break;
      case 'carbon':
        // Random specks
        final random = math.Random(42);
        for (var i = 0; i < 15; i++) {
          canvas.drawCircle(
            Offset(
              rect.left + random.nextDouble() * rect.width,
              rect.top + random.nextDouble() * rect.height,
            ),
            1,
            Paint()..color = Colors.grey.shade800,
          );
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _FilterPainter old) =>
      old.mediaTypes != mediaTypes || old.isRunning != isRunning;
}

/// Food container/jar
class FoodJarItem extends StatelessWidget {
  final String? foodType;
  final double fillLevel; // 0.0 to 1.0
  final VoidCallback? onTap;
  final double height;

  const FoodJarItem({
    super.key,
    this.foodType,
    this.fillLevel = 0.7,
    this.onTap,
    this.height = 70,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: height * 0.6,
        height: height,
        child: CustomPaint(
          painter: _FoodJarPainter(
            foodType: foodType ?? 'flakes',
            fillLevel: fillLevel,
          ),
        ),
      ),
    );
  }
}

class _FoodJarPainter extends CustomPainter {
  final String foodType;
  final double fillLevel;

  _FoodJarPainter({required this.foodType, required this.fillLevel});

  @override
  void paint(Canvas canvas, Size size) {
    // Jar body (glass)
    final glassPaint = Paint()
      ..color = AppOverlays.white30
      ..style = PaintingStyle.fill;

    final jarRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(4, 16, size.width - 8, size.height - 20),
      const Radius.circular(4),
    );
    canvas.drawRRect(jarRect, glassPaint);

    // Jar outline
    canvas.drawRRect(
      jarRect,
      Paint()
        ..color = AppColors.textHint.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Lid
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 8, size.width - 4, 12),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFE53E3E), // Red lid
    );

    // Lid highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 10, size.width - 8, 4),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFFC8181),
    );

    // Food fill
    final fillHeight = (size.height - 24) * fillLevel;
    final foodRect = Rect.fromLTWH(
      6,
      size.height - 6 - fillHeight,
      size.width - 12,
      fillHeight,
    );

    canvas.drawRect(foodRect, Paint()..color = _foodColor());

    // Food texture
    _drawFoodTexture(canvas, foodRect);

    // Label
    canvas.drawRect(
      Rect.fromLTWH(8, size.height * 0.45, size.width - 16, 14),
      Paint()..color = AppOverlays.white90,
    );
  }

  Color _foodColor() {
    switch (foodType.toLowerCase()) {
      case 'flakes':
        return const Color(0xFFED8936);
      case 'pellets':
        return const Color(0xFF805AD5);
      case 'frozen':
        return const Color(0xFF4299E1);
      case 'live':
        return const Color(0xFF48BB78);
      default:
        return const Color(0xFFED8936);
    }
  }

  void _drawFoodTexture(Canvas canvas, Rect rect) {
    final random = math.Random(123);
    final paint = Paint()..color = AppOverlays.black10;

    for (var i = 0; i < 20; i++) {
      final x = rect.left + random.nextDouble() * rect.width;
      final y = rect.top + random.nextDouble() * rect.height;
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FoodJarPainter old) =>
      old.foodType != foodType || old.fillLevel != fillLevel;
}

/// Heater with temperature indicator
class HeaterItem extends StatelessWidget {
  final double? setTemp;
  final bool isOn;
  final VoidCallback? onTap;
  final double height;

  const HeaterItem({
    super.key,
    this.setTemp,
    this.isOn = true,
    this.onTap,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: height * 0.25,
        height: height,
        child: CustomPaint(
          painter: _HeaterPainter(setTemp: setTemp, isOn: isOn),
        ),
      ),
    );
  }
}

class _HeaterPainter extends CustomPainter {
  final double? setTemp;
  final bool isOn;

  _HeaterPainter({required this.setTemp, required this.isOn});

  @override
  void paint(Canvas canvas, Size size) {
    // Heater body
    final bodyPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 8, size.width - 4, size.height - 12),
        Radius.circular(size.width / 2),
      ),
      bodyPaint,
    );

    // Glass tube section
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, size.height * 0.3, size.width - 8, size.height * 0.5),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF2D3748),
    );

    // Heating element (coil suggestion)
    if (isOn) {
      final coilPaint = Paint()
        ..color = const Color(0xFFFC8181)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final coilPath = Path();
      for (var y = size.height * 0.35; y < size.height * 0.75; y += 6) {
        coilPath.moveTo(6, y);
        coilPath.lineTo(size.width - 6, y);
      }
      canvas.drawPath(coilPath, coilPaint);
    }

    // Power cord at top
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, 8),
      Paint()
        ..color = const Color(0xFF4A5568)
        ..strokeWidth = 3,
    );

    // Indicator light
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.2),
      3,
      Paint()..color = isOn ? const Color(0xFFFC8181) : const Color(0xFF4A5568),
    );

    // Suction cups
    canvas.drawCircle(
      Offset(size.width / 2, size.height - 6),
      4,
      Paint()..color = const Color(0xFF718096),
    );
  }

  @override
  bool shouldRepaint(covariant _HeaterPainter old) =>
      old.setTemp != setTemp || old.isOn != isOn;
}

/// Light fixture
class LightItem extends StatelessWidget {
  final bool isOn;
  final double brightness; // 0.0 to 1.0
  final VoidCallback? onTap;
  final double width;

  const LightItem({
    super.key,
    this.isOn = true,
    this.brightness = 0.8,
    this.onTap,
    this.width = 80,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: width * 0.35,
        child: CustomPaint(
          painter: _LightPainter(isOn: isOn, brightness: brightness),
        ),
      ),
    );
  }
}

class _LightPainter extends CustomPainter {
  final bool isOn;
  final double brightness;

  _LightPainter({required this.isOn, required this.brightness});

  @override
  void paint(Canvas canvas, Size size) {
    // Light housing
    final housingPaint = Paint()
      ..color = const Color(0xFF2D3748)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.6),
        const Radius.circular(4),
      ),
      housingPaint,
    );

    // Light panel (LEDs)
    final panelRect = Rect.fromLTWH(
      4,
      size.height * 0.5,
      size.width - 8,
      size.height * 0.4,
    );

    if (isOn) {
      // Glow effect
      canvas.drawRect(
        panelRect.inflate(4),
        Paint()
          ..color = AppColors.yellowAlpha08
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    canvas.drawRect(
      panelRect,
      Paint()
        ..color = isOn
            ? Color.lerp(const Color(0xFF4A5568), Colors.yellow, brightness)!
            : const Color(0xFF4A5568),
    );

    // LED dots
    final ledPaint = Paint()
      ..color = isOn
          ? AppColors.whiteAlpha08
          : const Color(0xFF718096);

    for (var x = panelRect.left + 6; x < panelRect.right - 6; x += 8) {
      canvas.drawCircle(Offset(x, panelRect.center.dy), 2, ledPaint);
    }

    // Mounting brackets
    canvas.drawRect(
      Rect.fromLTWH(8, 0, 6, 4),
      Paint()..color = const Color(0xFF718096),
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width - 14, 0, 6, 4),
      Paint()..color = const Color(0xFF718096),
    );
  }

  @override
  bool shouldRepaint(covariant _LightPainter old) =>
      old.isOn != isOn || old.brightness != brightness;
}

/// Net for catching fish
class NetItem extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;

  const NetItem({super.key, this.onTap, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size * 1.5,
        child: CustomPaint(painter: _NetPainter()),
      ),
    );
  }
}

class _NetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Handle
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height * 0.4),
      Paint()
        ..color = const Color(0xFF805AD5)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Net frame
    final framePath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.35,
        size.width * 0.9,
        size.height * 0.4,
      )
      ..lineTo(size.width * 0.7, size.height * 0.95)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height,
        size.width * 0.3,
        size.height * 0.95,
      )
      ..close();

    canvas.drawPath(
      framePath,
      Paint()
        ..color = AppColors.studyGoldAlpha40
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      framePath,
      Paint()
        ..color = const Color(0xFF805AD5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Net mesh lines
    final meshPaint = Paint()
      ..color = AppColors.studyGoldAlpha60
      ..strokeWidth = 0.5;

    for (var i = 0.2; i < 0.9; i += 0.15) {
      canvas.drawLine(
        Offset(size.width * i, size.height * 0.4),
        Offset(size.width * (0.3 + (i - 0.2) * 0.5), size.height * 0.95),
        meshPaint,
      );
    }
    for (var i = 0.5; i < 0.95; i += 0.1) {
      canvas.drawLine(
        Offset(size.width * 0.15, size.height * i),
        Offset(size.width * 0.85, size.height * i),
        meshPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Bucket for water changes
class BucketItem extends StatelessWidget {
  final double fillLevel;
  final VoidCallback? onTap;
  final double height;

  const BucketItem({
    super.key,
    this.fillLevel = 0.0,
    this.onTap,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: height * 0.9,
        height: height,
        child: CustomPaint(painter: _BucketPainter(fillLevel: fillLevel)),
      ),
    );
  }
}

class _BucketPainter extends CustomPainter {
  final double fillLevel;

  _BucketPainter({required this.fillLevel});

  @override
  void paint(Canvas canvas, Size size) {
    // Bucket body
    final bucketPath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.25)
      ..lineTo(size.width * 0.05, size.height * 0.95)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height,
        size.width * 0.95,
        size.height * 0.95,
      )
      ..lineTo(size.width * 0.9, size.height * 0.25)
      ..close();

    canvas.drawPath(bucketPath, Paint()..color = const Color(0xFF4299E1));

    // Water fill
    if (fillLevel > 0) {
      final waterHeight = (size.height * 0.65) * fillLevel;
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * 0.08,
          size.height * 0.9 - waterHeight,
          size.width * 0.84,
          waterHeight,
        ),
        Paint()..color = AppColors.accent.withOpacity(0.6),
      );
    }

    // Handle
    final handlePath = Path()
      ..moveTo(size.width * 0.15, size.height * 0.25)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.05,
        size.width * 0.85,
        size.height * 0.25,
      );

    canvas.drawPath(
      handlePath,
      Paint()
        ..color = const Color(0xFF2B6CB0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Rim
    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.25),
      Offset(size.width * 0.92, size.height * 0.25),
      Paint()
        ..color = const Color(0xFF2B6CB0)
        ..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(covariant _BucketPainter old) =>
      old.fillLevel != fillLevel;
}
