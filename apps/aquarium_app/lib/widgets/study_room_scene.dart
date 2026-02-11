import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

/// Study room colors - cozy knowledge theme
class StudyColors {
  // Background gradient - warm study atmosphere
  static const background1 = Color(0xFF2D3A4F); // Deep blue-gray
  static const background2 = Color(0xFF1F2937); // Darker blue
  static const background3 = Color(0xFF1A202C); // Deep navy

  // Accent colors
  static const gold = Color(0xFFD4A574); // Warm gold
  static const goldLight = Color(0xFFE8C89E); // Light gold
  static const amber = Color(0xFFB8860B); // Dark amber
  static const cream = Color(0xFFFFF8E7); // Warm cream

  // Glass card
  static const glassCard = Color(0x20FFFFFF);
  static const glassBorder = Color(0x30FFFFFF);

  // Text
  static const textPrimary = Color(0xFFF5F5F5);
  static const textSecondary = Color(0xFFB0B8C8);

  // Accents
  static const bookRed = Color(0xFF8B3A3A);
  static const bookBlue = Color(0xFF3A5A8B);
  static const bookGreen = Color(0xFF3A6B4A);
  static const plantGreen = Color(0xFF4A7C59);
  static const wood = Color(0xFF5D4E37);
  static const woodLight = Color(0xFF7A6548);
}

/// Study Room Scene - cozy illustrated study for learning
class StudyRoomScene extends StatelessWidget {
  final int totalXp;
  final String levelTitle;
  final int currentStreak;
  final int completedLessons;
  final int totalLessons;
  final VoidCallback? onBookshelfTap;
  final VoidCallback? onDeskTap;
  final VoidCallback? onLampTap;

  const StudyRoomScene({
    super.key,
    required this.totalXp,
    required this.levelTitle,
    this.currentStreak = 0,
    this.completedLessons = 0,
    this.totalLessons = 0,
    this.onBookshelfTap,
    this.onDeskTap,
    this.onLampTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : w * 0.7;

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            children: [
              // === Background gradient ===
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        StudyColors.background1,
                        StudyColors.background2,
                        StudyColors.background3,
                      ],
                    ),
                  ),
                ),
              ),

              // === Decorative elements ===
              CustomPaint(painter: _StudyBackgroundPainter(), size: Size(w, h)),

              // === Floating books/stars ===
              Positioned(
                top: h * 0.1,
                right: w * 0.1,
                child: _FloatingElement(icon: Icons.auto_stories, size: 24),
              ),
              Positioned(
                top: h * 0.25,
                left: w * 0.08,
                child: _FloatingElement(icon: Icons.star, size: 16),
              ),
              Positioned(
                bottom: h * 0.3,
                right: w * 0.15,
                child: _FloatingElement(
                  icon: Icons.lightbulb_outline,
                  size: 20,
                ),
              ),

              // === Bookshelf illustration ===
              Positioned(
                top: h * 0.15,
                left: w * 0.08,
                child: GestureDetector(
                  onTap: onBookshelfTap,
                  child: _Bookshelf(width: w * 0.35, height: h * 0.45),
                ),
              ),

              // === Desk with lamp ===
              Positioned(
                top: h * 0.25,
                right: w * 0.08,
                child: GestureDetector(
                  onTap: onDeskTap,
                  child: _StudyDesk(width: w * 0.4, height: h * 0.35),
                ),
              ),

              // === XP Badge (top center) ===
              Positioned(
                top: h * 0.05,
                left: 0,
                right: 0,
                child: Center(
                  child: _GlassBadge(
                    icon: Icons.star,
                    text: '$totalXp XP',
                    subtext: levelTitle,
                  ),
                ),
              ),

              // === Streak indicator (if active) ===
              if (currentStreak > 0)
                Positioned(
                  top: h * 0.05,
                  right: w * 0.05,
                  child: _StreakBadge(streak: currentStreak),
                ),

              // === Progress card (bottom) ===
              Positioned(
                bottom: h * 0.08,
                left: w * 0.1,
                right: w * 0.1,
                child: _ProgressCard(
                  completed: completedLessons,
                  total: totalLessons,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// === Background painter ===
class _StudyBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Soft ambient light from lamp area
    final lampGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.5, 0.2),
        radius: 0.8,
        colors: [
          StudyColors.gold.withOpacity(0.15),
          StudyColors.gold.withOpacity(0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), lampGlow);

    // Decorative wave at bottom
    final wavePaint = Paint()
      ..color = StudyColors.wood.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final wave = Path()
      ..moveTo(0, size.height * 0.85)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.8,
        size.width * 0.5,
        size.height * 0.85,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.9,
        size.width,
        size.height * 0.82,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(wave, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// === Floating decorative elements ===
class _FloatingElement extends StatelessWidget {
  final IconData icon;
  final double size;

  const _FloatingElement({required this.icon, required this.size});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: size, color: StudyColors.gold.withOpacity(0.4));
  }
}

// === Bookshelf illustration ===
class _Bookshelf extends StatelessWidget {
  final double width;
  final double height;

  const _Bookshelf({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _BookshelfPainter(),
        size: Size(width, height),
      ),
    );
  }
}

class _BookshelfPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final woodPaint = Paint()..color = StudyColors.wood;
    final woodLightPaint = Paint()..color = StudyColors.woodLight;

    // Shelf boards
    final shelfHeight = size.height / 4;
    for (var i = 1; i < 4; i++) {
      final y = i * shelfHeight;
      canvas.drawRect(Rect.fromLTWH(0, y - 4, size.width, 8), woodPaint);
      // Shelf edge highlight
      canvas.drawRect(Rect.fromLTWH(0, y - 4, size.width, 2), woodLightPaint);
    }

    // Books on shelves
    final bookColors = [
      StudyColors.bookRed,
      StudyColors.bookBlue,
      StudyColors.bookGreen,
      StudyColors.gold,
      const Color(0xFF6B4E71), // Purple
    ];

    final random = math.Random(42); // Fixed seed for consistency

    for (var shelf = 0; shelf < 3; shelf++) {
      final shelfY = (shelf + 1) * shelfHeight;
      var x = 4.0;

      while (x < size.width - 20) {
        final bookWidth = 8.0 + random.nextDouble() * 12;
        final bookHeight = shelfHeight * (0.6 + random.nextDouble() * 0.3);
        final color = bookColors[random.nextInt(bookColors.length)];

        // Book
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, shelfY - bookHeight - 4, bookWidth, bookHeight),
            const Radius.circular(1),
          ),
          Paint()..color = color,
        );

        // Book spine highlight
        canvas.drawRect(
          Rect.fromLTWH(x + 1, shelfY - bookHeight - 2, 2, bookHeight - 4),
          Paint()..color = color.withOpacity(0.5),
        );

        x += bookWidth + 2 + random.nextDouble() * 4;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// === Study desk with lamp ===
class _StudyDesk extends StatelessWidget {
  final double width;
  final double height;

  const _StudyDesk({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _DeskPainter(), size: Size(width, height)),
    );
  }
}

class _DeskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Desk surface
    final deskPaint = Paint()..color = StudyColors.wood;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.15),
        const Radius.circular(4),
      ),
      deskPaint,
    );

    // Lamp base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.6,
          size.height * 0.5,
          size.width * 0.15,
          size.height * 0.1,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = StudyColors.amber,
    );

    // Lamp arm
    canvas.drawLine(
      Offset(size.width * 0.675, size.height * 0.5),
      Offset(size.width * 0.7, size.height * 0.2),
      Paint()
        ..color = StudyColors.amber
        ..strokeWidth = 3,
    );

    // Lamp shade
    final shadePath = Path()
      ..moveTo(size.width * 0.6, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.2)
      ..lineTo(size.width * 0.75, size.height * 0.08)
      ..lineTo(size.width * 0.65, size.height * 0.08)
      ..close();
    canvas.drawPath(shadePath, Paint()..color = StudyColors.goldLight);

    // Lamp glow
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.35),
      size.width * 0.2,
      Paint()
        ..shader =
            RadialGradient(
              colors: [StudyColors.gold.withOpacity(0.4), Colors.transparent],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.7, size.height * 0.35),
                radius: size.width * 0.2,
              ),
            ),
    );

    // Open book on desk
    final bookLeft = Path()
      ..moveTo(size.width * 0.2, size.height * 0.55)
      ..lineTo(size.width * 0.35, size.height * 0.52)
      ..lineTo(size.width * 0.35, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.38,
        size.width * 0.2,
        size.height * 0.42,
      )
      ..close();
    canvas.drawPath(bookLeft, Paint()..color = StudyColors.cream);

    final bookRight = Path()
      ..moveTo(size.width * 0.5, size.height * 0.55)
      ..lineTo(size.width * 0.35, size.height * 0.52)
      ..lineTo(size.width * 0.35, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.38,
        size.width * 0.5,
        size.height * 0.42,
      )
      ..close();
    canvas.drawPath(
      bookRight,
      Paint()..color = StudyColors.cream.withOpacity(0.9),
    );

    // Text lines on book
    final linePaint = Paint()
      ..color = StudyColors.background2.withOpacity(0.3)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = size.height * 0.44 + i * 3;
      canvas.drawLine(
        Offset(size.width * 0.22, y),
        Offset(size.width * 0.33, y + 1),
        linePaint,
      );
      canvas.drawLine(
        Offset(size.width * 0.37, y + 1),
        Offset(size.width * 0.48, y),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// === Glass badge ===
class _GlassBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final String subtext;

  const _GlassBadge({
    required this.icon,
    required this.text,
    required this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: StudyColors.glassCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: StudyColors.glassBorder, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: StudyColors.gold, size: 20),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      color: StudyColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtext,
                    style: const TextStyle(
                      color: StudyColors.textSecondary,
                      fontSize: 11,
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

// === Streak badge ===
class _StreakBadge extends StatelessWidget {
  final int streak;

  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// === Progress card ===
class _ProgressCard extends StatelessWidget {
  final int completed;
  final int total;

  const _ProgressCard({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: StudyColors.glassCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: StudyColors.glassBorder, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Learning Progress',
                    style: TextStyle(
                      color: StudyColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$completed / $total lessons',
                    style: const TextStyle(
                      color: StudyColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: StudyColors.background2,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    StudyColors.gold,
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
