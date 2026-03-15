import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

/// Soft organic blob shape for backgrounds
class SoftBlob extends StatelessWidget {
  final double size;
  final Color color;
  final int seed;

  const SoftBlob({
    super.key,
    this.size = 200,
    this.color = AppColors.primary,
    this.seed = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size(size, size),
        painter: _BlobPainter(color: color.withAlpha(38), seed: seed),
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  final Color color;
  final int seed;

  _BlobPainter({required this.color, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final random = math.Random(seed);
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    path.moveTo(center.dx + radius, center.dy);

    for (var i = 0; i < 6; i++) {
      final angle1 = (i / 6) * 2 * math.pi;
      final angle2 = ((i + 1) / 6) * 2 * math.pi;
      final midAngle = (angle1 + angle2) / 2;

      final r1 = radius * (0.8 + random.nextDouble() * 0.4);
      final r2 = radius * (0.7 + random.nextDouble() * 0.3);

      final cp = Offset(
        center.dx + r2 * math.cos(midAngle),
        center.dy + r2 * math.sin(midAngle),
      );
      final end = Offset(
        center.dx + r1 * math.cos(angle2),
        center.dy + r1 * math.sin(angle2),
      );

      path.quadraticBezierTo(cp.dx, cp.dy, end.dx, end.dy);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple plant/leaf decoration
class PlantDecoration extends StatelessWidget {
  final double height;
  final Color color;
  final bool flip;

  const PlantDecoration({
    super.key,
    this.height = 120,
    this.color = const Color(0xFF7AC29A),
    this.flip = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()..scale(flip ? -1.0 : 1.0, 1.0),
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size(height * 0.4, height),
        painter: _PlantPainter(color: color.withAlpha(51)),
      ),
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

    // Draw 3-4 overlapping leaves
    for (var i = 0; i < 4; i++) {
      final leafPath = Path();
      final startY = size.height - (i * size.height * 0.15);
      final endY = size.height * 0.2 + (i * size.height * 0.1);
      final curveX = size.width * (0.3 + i * 0.15);

      leafPath.moveTo(size.width * 0.5, startY);
      leafPath.quadraticBezierTo(
        curveX,
        (startY + endY) / 2,
        size.width * 0.5 + (i * 2),
        endY,
      );
      leafPath.quadraticBezierTo(
        size.width - curveX + (i * 4),
        (startY + endY) / 2,
        size.width * 0.5,
        startY,
      );

      canvas.drawPath(leafPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Notebook/paper style card for data display
class NotebookCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? rotation; // subtle tilt in degrees

  const NotebookCard({
    super.key,
    required this.child,
    this.padding,
    this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Transform.rotate(
      angle: (rotation ?? 0) * math.pi / 180,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A3A4A) : const Color(0xFFFFFDF8),
          borderRadius: AppRadius.smallRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.blackAlpha08,
              blurRadius: 12,
              offset: const Offset(2, 4),
            ),
          ],
          // Subtle paper texture border
          border: Border.all(
            color: isDark
                ? AppOverlays.white5
                : const Color(0xFFE8E4DC),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Notebook lines (subtle)
            if (!isDark)
              Positioned.fill(
                child: CustomPaint(painter: _NotebookLinesPainter()),
              ),
            // Content
            Padding(padding: padding ?? EdgeInsets.all(AppSpacing.md), child: child),
          ],
        ),
      ),
    );
  }
}

class _NotebookLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.errorAlpha50
      ..strokeWidth = 1;

    // Horizontal lines
    for (var y = 24.0; y < size.height; y += 24) {
      canvas.drawLine(Offset(16, y), Offset(size.width - 16, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Tablet/screen style card for digital data
class TabletCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? screenColor;

  const TabletCard({
    super.key,
    required this.child,
    this.padding,
    this.screenColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2A38) : const Color(0xFF3D4852),
        borderRadius: AppRadius.mediumRadius,
        boxShadow: [
          BoxShadow(
            color: AppOverlays.black20,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.xs2),
      child: Container(
        decoration: BoxDecoration(
          color:
              screenColor ??
              (isDark ? const Color(0xFF243447) : const Color(0xFFF0F4F8)),
          borderRadius: AppRadius.mediumRadius,
        ),
        padding: padding ?? EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );
  }
}

/// Wooden shelf decoration for tank display
class ShelfDecoration extends StatelessWidget {
  final Widget child;
  final double shelfThickness;

  const ShelfDecoration({
    super.key,
    required this.child,
    this.shelfThickness = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Item on shelf
        child,
        // Shelf
        Container(
          height: shelfThickness,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF4A3728), const Color(0xFF3D2E22)]
                  : [const Color(0xFFD4A574), const Color(0xFFC49A6C)],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: AppOverlays.black15,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
        // Shelf bracket shadows
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ShelfBracket(isDark: isDark),
            _ShelfBracket(isDark: isDark),
          ],
        ),
      ],
    );
  }
}

class _ShelfBracket extends StatelessWidget {
  final bool isDark;

  const _ShelfBracket({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF3D2E22),
                  AppColors.successAlpha100,
                ]
              : [
                  const Color(0xFFC49A6C),
                  AppColors.successAlpha100,
                ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
    );
  }
}

/// Cozy room background with decorative elements
class CozyRoomBackground extends StatelessWidget {
  final Widget child;
  final bool showPlants;
  final bool showBlobs;

  const CozyRoomBackground({
    super.key,
    required this.child,
    this.showPlants = true,
    this.showBlobs = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background blobs
        if (showBlobs) ...[
          Positioned(
            top: -50,
            right: -30,
            child: SoftBlob(size: 180, color: AppColors.primary, seed: 1),
          ),
          Positioned(
            bottom: 100,
            left: -40,
            child: SoftBlob(size: 150, color: AppColors.secondary, seed: 2),
          ),
          Positioned(
            top: 200,
            right: -60,
            child: SoftBlob(size: 120, color: AppColors.accent, seed: 3),
          ),
        ],

        // Plants in corners
        if (showPlants) ...[
          Positioned(
            bottom: 0,
            left: 0,
            child: PlantDecoration(height: 140, color: AppColors.success),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: PlantDecoration(
              height: 100,
              color: AppColors.primary,
              flip: true,
            ),
          ),
        ],

        // Main content
        child,
      ],
    );
  }
}

/// Simple window decoration suggesting indoor scene
class WindowDecoration extends StatelessWidget {
  final double width;
  final double height;

  const WindowDecoration({super.key, this.width = 120, this.height = 160});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundDarkAlpha50
            : AppOverlays.lightBlueGrey80,
        borderRadius: AppRadius.smallRadius,
        border: Border.all(
          color: isDark
              ? AppOverlays.white10
              : const Color(0xFFD4D0C8),
          width: 6,
        ),
      ),
      child: Column(
        children: [
          // Top pane
          Expanded(
            child: Container(
              margin: EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [const Color(0xFF2D3E50), const Color(0xFF1A2634)]
                      : [const Color(0xFFB8D4E3), const Color(0xFFD4E8F0)],
                ),
                borderRadius: AppRadius.xsRadius,
              ),
            ),
          ),
          // Window divider
          Container(
            height: 6,
            color: isDark
                ? AppOverlays.white10
                : const Color(0xFFD4D0C8),
          ),
          // Bottom pane
          Expanded(
            child: Container(
              margin: EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [const Color(0xFF2D3E50), const Color(0xFF1A2634)]
                      : [const Color(0xFFD4E8F0), const Color(0xFFE8F4F8)],
                ),
                borderRadius: AppRadius.xsRadius,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating stat bubble (like reading from a gauge)
class StatBubble extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final double size;

  const StatBubble({
    super.key,
    required this.value,
    required this.label,
    this.color = AppColors.primary,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        shape: BoxShape.circle,
        border: Border.all(color: color.withAlpha(76), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(26),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: size * 0.25,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: size * 0.12,
              color: color.withAlpha(204),
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative wave/water line
class WaterWave extends StatelessWidget {
  final double height;
  final Color color;

  const WaterWave({
    super.key,
    this.height = 40,
    this.color = const Color(0xFF85C7DE),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _WavePainter(color: color.withAlpha(51)),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;

  _WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    // Create wave
    for (var x = 0.0; x <= size.width; x += 1) {
      final y =
          size.height * 0.5 +
          math.sin(x * 0.02) * size.height * 0.3 +
          math.sin(x * 0.01 + 1) * size.height * 0.1;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
