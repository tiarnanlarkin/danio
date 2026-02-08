import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
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
/// Part of the "House Navigation" system
class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with illustrated study room
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
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
                      MaterialPageRoute(builder: (_) => const NitrogenCycleGuideScreen()),
                    ),
                  ),
                  _StudyTile(
                    icon: Icons.science,
                    title: 'Water Parameters',
                    subtitle: 'pH, temperature, hardness & more',
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ParameterGuideScreen()),
                    ),
                  ),
                  _StudyTile(
                    icon: Icons.local_hospital,
                    title: 'Fish Diseases',
                    subtitle: 'Identify and treat common illnesses',
                    color: Colors.red,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DiseaseGuideScreen()),
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
                      MaterialPageRoute(builder: (_) => const AcclimationGuideScreen()),
                    ),
                  ),
                  _StudyTile(
                    icon: Icons.shield,
                    title: 'Quarantine',
                    subtitle: 'Protect your tank from disease',
                    color: Colors.purple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QuarantineGuideScreen()),
                    ),
                  ),
                  _StudyTile(
                    icon: Icons.restaurant,
                    title: 'Feeding',
                    subtitle: 'Nutrition and feeding schedules',
                    color: Colors.amber,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FeedingGuideScreen()),
                    ),
                  ),
                  _StudyTile(
                    icon: Icons.favorite,
                    title: 'Breeding',
                    subtitle: 'Raise the next generation',
                    color: Colors.pink,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BreedingGuideScreen()),
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
                      MaterialPageRoute(builder: (_) => const AlgaeGuideScreen()),
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
                      MaterialPageRoute(builder: (_) => const SpeciesBrowserScreen()),
                    ),
                  ),
                  _StudyTile(
                    icon: Icons.eco,
                    title: 'Plant Browser',
                    subtitle: 'Explore aquatic plants',
                    color: Colors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PlantBrowserScreen()),
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A237E), // Deep blue
            Color(0xFF3949AB), // Lighter blue
          ],
        ),
      ),
      child: Stack(
        children: [
          // Bookshelf silhouette
          Positioned(
            right: 20,
            bottom: 40,
            child: Icon(
              Icons.menu_book,
              size: 120,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          // Desk lamp
          Positioned(
            left: 30,
            bottom: 60,
            child: Icon(
              Icons.lightbulb_outline,
              size: 60,
              color: Colors.amber.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
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
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: child,
          ),
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
          borderRadius: BorderRadius.circular(12),
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
