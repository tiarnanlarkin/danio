import 'package:flutter/material.dart';

/// Static drawn fish widget — uses [FishPainter].
class SoftFish extends StatelessWidget {
  final double size;
  final Color color;

  const SoftFish({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: 1,
      child: SizedBox(
        width: size * 2,
        height: size,
        child: CustomPaint(painter: FishPainter(color: color)),
      ),
    );
  }
}

class FishPainter extends CustomPainter {
  final Color color;
  late final Color _finColor = color.withAlpha(204);

  FishPainter({required this.color});

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
