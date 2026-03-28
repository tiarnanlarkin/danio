import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/room_themes.dart';

// === BACKGROUND IMAGE MAPPING ===

/// Returns the asset path for themes that have a dedicated background image,
/// or null for themes that use a gradient fallback.
String? backgroundAssetForTheme(RoomThemeType type) {
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
      return null; // Use gradient fallback for remaining themes
  }
}

/// Returns an intentional gradient background for themes without a photo.
Widget gradientFallbackForTheme(RoomThemeType type) {
  final theme = RoomTheme.fromType(type);
  return DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.45, 1.0],
        colors: [
          theme.waterTop,
          theme.background1,
          theme.background3,
        ],
      ),
    ),
    child: const SizedBox.expand(),
  );
}

/// Builds the room background widget for [type].
Widget buildRoomBackground(RoomThemeType type) {
  final assetPath = backgroundAssetForTheme(type);
  if (assetPath == null) {
    return gradientFallbackForTheme(type);
  }
  return Image.asset(
    assetPath,
    fit: BoxFit.cover,
    cacheWidth: 1024,
    cacheHeight: 1024,
    errorBuilder: (context, error, stackTrace) =>
        gradientFallbackForTheme(type),
  );
}

// === SPARKLE (for whimsical/night themes) ===

class Sparkle extends StatelessWidget {
  final double size;
  final Color color;

  const Sparkle({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: SparklePainter(color: color),
    );
  }
}

class SparklePainter extends CustomPainter {
  final Color color;
  late final Color _colorAlpha178 = color.withAlpha(178);

  SparklePainter({required this.color});

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
