import 'package:flutter/material.dart';

import '../../theme/room_themes.dart';

/// Furniture stand that the aquarium sits on.
class AquariumStand extends StatelessWidget {
  final double width;
  final double height;
  final RoomTheme theme;

  const AquariumStand({
    super.key,
    required this.width,
    required this.height,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: AquariumStandPainter(theme: theme),
    );
  }
}

class AquariumStandPainter extends CustomPainter {
  final RoomTheme theme;

  AquariumStandPainter({required this.theme});

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
  bool shouldRepaint(covariant AquariumStandPainter old) =>
      old.theme != theme;
}
