import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Soft plant widget — renders using [PlantPainter].
class SoftPlant extends StatelessWidget {
  final double height;
  final Color color;

  const SoftPlant({super.key, required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: height * 0.4,
      height: height,
      child: CustomPaint(painter: PlantPainter(color: color)),
    );
  }
}

class PlantPainter extends CustomPainter {
  final Color color;

  PlantPainter({required this.color});

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
