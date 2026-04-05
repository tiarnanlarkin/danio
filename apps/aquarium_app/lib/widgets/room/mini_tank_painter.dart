import 'package:flutter/material.dart';

import '../../theme/room_themes.dart';

/// Paints a simplified aquarium scene for theme preview cards.
///
/// Draws a glass tank with water gradient, sand, plants, and fish using
/// the provided [RoomTheme]'s colour palette. Designed to render at
/// card-preview sizes (~280×200).
class MiniTankPainter extends CustomPainter {
  final RoomTheme theme;

  MiniTankPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Tank dimensions — centred, occupying ~70% width, ~60% height
    final tankW = w * 0.70;
    final tankH = h * 0.60;
    final tankLeft = (w - tankW) / 2;
    final tankTop = h * 0.20;
    final tankRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(tankLeft, tankTop, tankW, tankH),
      const Radius.circular(6),
    );

    // ── Glass tank body ──────────────────────────────────────────────
    canvas.drawRRect(
      tankRect,
      Paint()..color = theme.glassCard,
    );

    // ── Water gradient fill (clipped to tank) ────────────────────────
    canvas.save();
    canvas.clipRRect(tankRect);

    final waterRect = Rect.fromLTWH(
      tankLeft,
      tankTop + tankH * 0.10, // water starts slightly below tank top
      tankW,
      tankH * 0.90,
    );
    final waterGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [theme.waterTop, theme.waterMid, theme.waterBottom],
      stops: const [0.0, 0.5, 1.0],
    );
    canvas.drawRect(
      waterRect,
      Paint()..shader = waterGradient.createShader(waterRect),
    );

    // ── Sand strip at bottom ─────────────────────────────────────────
    final sandH = tankH * 0.12;
    final sandRect = Rect.fromLTWH(
      tankLeft,
      tankTop + tankH - sandH,
      tankW,
      sandH,
    );
    canvas.drawRect(sandRect, Paint()..color = theme.sand);

    // ── Plants ───────────────────────────────────────────────────────
    _drawPlant(
      canvas: canvas,
      cx: tankLeft + tankW * 0.20,
      bottom: tankTop + tankH - sandH,
      height: tankH * 0.30,
      width: tankW * 0.08,
      color: theme.plantPrimary,
    );
    _drawPlant(
      canvas: canvas,
      cx: tankLeft + tankW * 0.35,
      bottom: tankTop + tankH - sandH,
      height: tankH * 0.22,
      width: tankW * 0.06,
      color: theme.plantSecondary,
    );
    _drawPlant(
      canvas: canvas,
      cx: tankLeft + tankW * 0.78,
      bottom: tankTop + tankH - sandH,
      height: tankH * 0.26,
      width: tankW * 0.07,
      color: theme.plantPrimary.withAlpha(200),
    );

    // ── Fish ─────────────────────────────────────────────────────────
    _drawFish(
      canvas: canvas,
      cx: tankLeft + tankW * 0.55,
      cy: tankTop + tankH * 0.35,
      size: tankW * 0.08,
      color: theme.fish1,
      facingLeft: false,
    );
    _drawFish(
      canvas: canvas,
      cx: tankLeft + tankW * 0.30,
      cy: tankTop + tankH * 0.50,
      size: tankW * 0.06,
      color: theme.fish2,
      facingLeft: true,
    );
    _drawFish(
      canvas: canvas,
      cx: tankLeft + tankW * 0.68,
      cy: tankTop + tankH * 0.60,
      size: tankW * 0.07,
      color: theme.fish3,
      facingLeft: false,
    );

    canvas.restore(); // end tank clip

    // ── Glass border ─────────────────────────────────────────────────
    canvas.drawRRect(
      tankRect,
      Paint()
        ..color = theme.glassBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // ── Stand / shelf under tank ─────────────────────────────────────
    final standRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        tankLeft - 4,
        tankTop + tankH,
        tankW + 8,
        h * 0.04,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(
      standRect,
      Paint()..color = theme.sand.withAlpha(180),
    );
  }

  /// Draws a simple leaf-shaped plant silhouette.
  void _drawPlant({
    required Canvas canvas,
    required double cx,
    required double bottom,
    required double height,
    required double width,
    required Color color,
  }) {
    final path = Path()
      ..moveTo(cx, bottom)
      ..quadraticBezierTo(
        cx - width,
        bottom - height * 0.6,
        cx - width * 0.3,
        bottom - height,
      )
      ..quadraticBezierTo(
        cx,
        bottom - height * 0.85,
        cx + width * 0.3,
        bottom - height,
      )
      ..quadraticBezierTo(
        cx + width,
        bottom - height * 0.6,
        cx,
        bottom,
      )
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  /// Draws a simple fish shape (oval body + triangular tail).
  void _drawFish({
    required Canvas canvas,
    required double cx,
    required double cy,
    required double size,
    required Color color,
    required bool facingLeft,
  }) {
    final dir = facingLeft ? -1.0 : 1.0;
    final bodyW = size;
    final bodyH = size * 0.55;

    // Body oval
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: bodyW, height: bodyH),
      Paint()..color = color,
    );

    // Tail
    final tailPath = Path()
      ..moveTo(cx - dir * bodyW * 0.45, cy)
      ..lineTo(cx - dir * bodyW * 0.80, cy - bodyH * 0.45)
      ..lineTo(cx - dir * bodyW * 0.80, cy + bodyH * 0.45)
      ..close();

    canvas.drawPath(tailPath, Paint()..color = color.withAlpha(200));

    // Eye
    final eyeX = cx + dir * bodyW * 0.20;
    canvas.drawCircle(
      Offset(eyeX, cy - bodyH * 0.10),
      size * 0.06,
      Paint()..color = Colors.white.withAlpha(220),
    );
  }

  @override
  bool shouldRepaint(covariant MiniTankPainter oldDelegate) =>
      oldDelegate.theme.name != theme.name;
}
