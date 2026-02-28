import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_card.dart';
import '../learn_screen.dart';
import '../nitrogen_cycle_guide_screen.dart';
import '../parameter_guide_screen.dart';
import '../disease_guide_screen.dart';
import '../acclimation_guide_screen.dart';
import '../quarantine_guide_screen.dart';
import '../breeding_guide_screen.dart';
import '../feeding_guide_screen.dart';
import '../algae_guide_screen.dart';
import '../glossary_screen.dart';
import '../faq_screen.dart';
import '../species_browser_screen.dart';
import '../plant_browser_screen.dart';

/// The Study room - Learning & Knowledge hub
/// Part of the "House Navigation" system - navigation between rooms
/// is handled by swiping or tapping the room indicator bar.
class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with illustrated study room
          // No back button - navigation is via TabNavigator
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            automaticallyImplyLeading: false, // No back button - we're in TabNavigator
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '📚 Study',
                style: TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
              background: _StudyBackground(),
            ),
          ),

          // Learning section (Duolingo-style)
          SliverToBoxAdapter(
            child: _SectionCard(
              title: '🎓 Learn',
              subtitle: 'Interactive lessons with quizzes',
              color: AppColors.primary,
              child: Column(
                children: [
                  _StudyTile(
                    icon: Icons.school,
                    title: 'Learning Paths',
                    subtitle: 'Duolingo-style lessons & quizzes',
                    color: AppColors.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LearnScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Essential Guides
          SliverToBoxAdapter(
            child: _SectionCard(
              title: '📖 Essential Guides',
              subtitle: 'Must-know information for fishkeepers',
              color: Colors.blue,
              child: Column(
                children: [
                  _StudyTile(
                    icon: Icons.loop,
                    title: 'Nitrogen Cycle',
                    subtitle: 'The most important concept',
                    color: Colors.teal,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NitrogenCycleGuideScreen(),
                      ),
                    ),
                  ),
                  _StudyTile(
                    icon: Icons.science,
                    title: 'Water Parameters',
                    subtitle: 'pH, temperature, hardness & more',
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ParameterGuideScreen(),
                      ),
                    ),
                  ),
                  _StudyTile(
                    icon: Icons.local_hospital,
                    title: 'Fish Diseases',
                    subtitle: 'Identify and treat common illnesses',
                    color: Colors.red,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DiseaseGuideScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Care Guides
          SliverToBoxAdapter(
            child: _SectionCard(
              title: '🐟 Care Guides',
              subtitle: 'How to care for your aquatic friends',
              color: Colors.orange,
              child: Column(
                children: [
                  _StudyTile(
                    icon: Icons.transfer_within_a_station,
                    title: 'Acclimation',
                    subtitle: 'Safely introduce new fish',
                    color: Colors.orange,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AcclimationGuideScreen(),
                      ),
                    ),
                  ),
                  _StudyTile(
                    icon: Icons.shield,
                    title: 'Quarantine',
                    subtitle: 'Protect your tank from disease',
                    color: Colors.purple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QuarantineGuideScreen(),
                      ),
                    ),
                  ),
                  _StudyTile(
                    icon: Icons.restaurant,
                    title: 'Feeding',
                    subtitle: 'Nutrition and feeding schedules',
                    color: Colors.amber,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FeedingGuideScreen(),
                      ),
                    ),
                  ),
                  _StudyTile(
                    icon: Icons.favorite,
                    title: 'Breeding',
                    subtitle: 'Raise the next generation',
                    color: Colors.pink,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BreedingGuideScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Problem Solving
          SliverToBoxAdapter(
            child: _SectionCard(
              title: '🔧 Problem Solving',
              subtitle: 'Troubleshoot common issues',
              color: Colors.brown,
              child: Column(
                children: [
                  _StudyTile(
                    icon: Icons.grass,
                    title: 'Algae Control',
                    subtitle: 'Identify and eliminate algae',
                    color: Colors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AlgaeGuideScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Reference
          SliverToBoxAdapter(
            child: _SectionCard(
              title: '📚 Reference',
              subtitle: 'Browse species and terminology',
              color: Colors.indigo,
              child: Column(
                children: [
                  _StudyTile(
                    icon: Icons.pets,
                    title: 'Species Browser',
                    subtitle: 'Explore fish species',
                    color: Colors.cyan,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SpeciesBrowserScreen(),
                      ),
                    ),
                  ),
                  _StudyTile(
                    icon: Icons.eco,
                    title: 'Plant Browser',
                    subtitle: 'Explore aquatic plants',
                    color: Colors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PlantBrowserScreen(),
                      ),
                    ),
                  ),
                  _StudyTile(
                    icon: Icons.menu_book,
                    title: 'Glossary',
                    subtitle: 'Fishkeeping terminology',
                    color: Colors.blueGrey,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GlossaryScreen()),
                    ),
                  ),
                  _StudyTile(
                    icon: Icons.help_outline,
                    title: 'FAQ',
                    subtitle: 'Common questions answered',
                    color: Colors.indigo,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FaqScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

/// Illustrated study room background
class _StudyBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StudyRoomPainter(),
      size: Size.infinite,
    );
  }
}

class _StudyRoomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // === COZY STUDY WALL ===
    final wallGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF3D5A6B), // Deep teal-blue
        const Color(0xFF4A6A7A), // Lighter teal
        const Color(0xFF5A7A8A), // Softer teal
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..shader = wallGradient.createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // === BOOKSHELF (right side) ===
    _drawBookshelf(canvas, w, h);

    // === DESK WITH LAMP (left side) ===
    _drawDesk(canvas, w, h);

    // === WARM LAMP GLOW ===
    final lampGlow = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.6,
        colors: [
          AppOverlays.goldenYellow35,
          AppOverlays.orangeYellow15,
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.3, w * 0.5, h * 0.5));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.18, h * 0.55), width: w * 0.5, height: h * 0.5),
      lampGlow,
    );

    // === WINDOW LIGHT (top) ===
    final windowGlow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppOverlays.skyBlue20,
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.5));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.4), windowGlow);
  }

  void _drawBookshelf(Canvas canvas, double w, double h) {
    final shelfColor = const Color(0xFF5C4033);
    final bookColors = [
      const Color(0xFFC0392B), // Red
      const Color(0xFF2980B9), // Blue
      const Color(0xFF27AE60), // Green
      const Color(0xFFF39C12), // Orange
      const Color(0xFF8E44AD), // Purple
      const Color(0xFF16A085), // Teal
    ];

    // Shelf frame (right side)
    final shelfLeft = w * 0.58;
    final shelfTop = h * 0.15;
    final shelfWidth = w * 0.38;
    final shelfHeight = h * 0.75;

    // Back panel
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(shelfLeft, shelfTop, shelfWidth, shelfHeight),
        const Radius.circular(4),
      ),
      Paint()..color = shelfColor.withOpacity(0.7),
    );

    // Shelves (3 rows)
    final shelfPaint = Paint()..color = shelfColor;
    for (var i = 0; i < 3; i++) {
      final shelfY = shelfTop + (i + 1) * (shelfHeight / 3.5);
      canvas.drawRect(
        Rect.fromLTWH(shelfLeft - 5, shelfY, shelfWidth + 10, 6),
        shelfPaint,
      );

      // Books on each shelf
      var bookX = shelfLeft + 8.0;
      final bookBaseY = shelfY - 2;
      for (var j = 0; j < 5 + (i % 2); j++) {
        final bookWidth = 12.0 + (j % 3) * 4;
        final bookHeight = 35.0 + (j % 4) * 8;
        final bookColor = bookColors[(i * 5 + j) % bookColors.length];

        // Book spine
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(bookX, bookBaseY - bookHeight, bookWidth, bookHeight),
            const Radius.circular(1),
          ),
          Paint()..color = bookColor.withOpacity(0.85),
        );

        // Book spine detail
        canvas.drawLine(
          Offset(bookX + bookWidth / 2, bookBaseY - bookHeight + 5),
          Offset(bookX + bookWidth / 2, bookBaseY - 5),
          Paint()
            ..color = AppColors.whiteAlpha20
            ..strokeWidth = 1,
        );

        bookX += bookWidth + 3;
        if (bookX > shelfLeft + shelfWidth - 20) break;
      }
    }

    // Top shelf decoration
    canvas.drawRect(
      Rect.fromLTWH(shelfLeft - 5, shelfTop - 4, shelfWidth + 10, 6),
      shelfPaint,
    );
  }

  void _drawDesk(Canvas canvas, double w, double h) {
    final deskColor = const Color(0xFF5C4033);
    
    // Desk surface
    final deskTop = h * 0.72;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.02, deskTop, w * 0.45, 8),
        const Radius.circular(2),
      ),
      Paint()..color = deskColor,
    );

    // Desk leg (left)
    canvas.drawRect(
      Rect.fromLTWH(w * 0.05, deskTop + 8, 8, h - deskTop - 8),
      Paint()..color = deskColor.withOpacity(0.8),
    );
    
    // Desk leg (right)
    canvas.drawRect(
      Rect.fromLTWH(w * 0.40, deskTop + 8, 8, h - deskTop - 8),
      Paint()..color = deskColor.withOpacity(0.8),
    );

    // Desk lamp
    final lampBase = Offset(w * 0.18, deskTop);
    
    // Lamp base
    canvas.drawOval(
      Rect.fromCenter(center: lampBase, width: 25, height: 8),
      Paint()..color = const Color(0xFF2C3E50),
    );
    
    // Lamp arm
    canvas.drawLine(
      lampBase,
      Offset(w * 0.15, deskTop - 50),
      Paint()
        ..color = const Color(0xFF2C3E50)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    
    // Lamp shade
    final shadePath = Path()
      ..moveTo(w * 0.10, deskTop - 50)
      ..lineTo(w * 0.08, deskTop - 35)
      ..lineTo(w * 0.22, deskTop - 35)
      ..lineTo(w * 0.20, deskTop - 50)
      ..close();
    canvas.drawPath(shadePath, Paint()..color = const Color(0xFFE8D4B8));
    
    // Lamp light bulb glow
    canvas.drawCircle(
      Offset(w * 0.15, deskTop - 38),
      8,
      Paint()..color = AppOverlays.goldenYellow80,
    );

    // Open book on desk
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.25, deskTop - 15, 40, 25),
        const Radius.circular(2),
      ),
      Paint()..color = AppColors.whiteAlpha90,
    );
    // Book spine
    canvas.drawLine(
      Offset(w * 0.25 + 20, deskTop - 15),
      Offset(w * 0.25 + 20, deskTop + 10),
      Paint()
        ..color = const Color(0xFFDDD6C6)
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          AppCard(padding: AppCardPadding.none, child: child),
        ],
      ),
    );
  }
}

class _StudyTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _StudyTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: AppRadius.mediumRadius,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: AppTypography.labelLarge),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
