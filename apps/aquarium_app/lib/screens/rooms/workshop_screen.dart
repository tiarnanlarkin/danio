import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../co2_calculator_screen.dart';
import '../dosing_calculator_screen.dart';
import '../stocking_calculator_screen.dart';
import '../tank_volume_calculator_screen.dart';
import '../water_change_calculator_screen.dart';
import '../unit_converter_screen.dart';
import '../compatibility_checker_screen.dart';
import '../reminders_screen.dart';
import '../tasks_screen.dart';
import '../maintenance_checklist_screen.dart';
import '../backup_restore_screen.dart';

/// The Workshop room - Tools & Maintenance hub
/// Part of the "House Navigation" system
class WorkshopScreen extends ConsumerWidget {
  final String? tankId;
  final String? tankName;
  
  const WorkshopScreen({super.key, this.tankId, this.tankName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with illustrated workshop
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '🔧 Workshop',
                style: TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
              background: _WorkshopBackground(),
            ),
          ),

          // Calculators section
          SliverToBoxAdapter(
            child: _SectionCard(
              title: '🧮 Calculators',
              subtitle: 'Crunch the numbers',
              color: Colors.orange,
              child: Column(
                children: [
                  _WorkshopTile(
                    icon: Icons.straighten,
                    title: 'Tank Volume',
                    subtitle: 'Calculate tank capacity',
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TankVolumeCalculatorScreen()),
                    ),
                  ),
                  _WorkshopTile(
                    icon: Icons.water_drop,
                    title: 'Water Change',
                    subtitle: 'Plan your water changes',
                    color: Colors.cyan,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WaterChangeCalculatorScreen()),
                    ),
                  ),
                  _WorkshopTile(
                    icon: Icons.pets,
                    title: 'Stocking Level',
                    subtitle: 'Check if your tank is overstocked',
                    color: Colors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StockingCalculatorScreen()),
                    ),
                  ),
                  _WorkshopTile(
                    icon: Icons.bubble_chart,
                    title: 'CO2 Calculator',
                    subtitle: 'Calculate CO2 levels from pH/KH',
                    color: Colors.teal,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Co2CalculatorScreen()),
                    ),
                  ),
                  _WorkshopTile(
                    icon: Icons.science,
                    title: 'Dosing Calculator',
                    subtitle: 'Calculate fertilizer doses',
                    color: Colors.purple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DosingCalculatorScreen()),
                    ),
                  ),
                  _WorkshopTile(
                    icon: Icons.swap_horiz,
                    title: 'Unit Converter',
                    subtitle: 'Convert between units',
                    color: Colors.indigo,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UnitConverterScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Compatibility section
          SliverToBoxAdapter(
            child: _SectionCard(
              title: '🐟 Compatibility',
              subtitle: 'Check fish compatibility',
              color: Colors.green,
              child: Column(
                children: [
                  _WorkshopTile(
                    icon: Icons.compare_arrows,
                    title: 'Compatibility Checker',
                    subtitle: 'Will these fish get along?',
                    color: Colors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CompatibilityCheckerScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Maintenance section
          SliverToBoxAdapter(
            child: _SectionCard(
              title: '🧹 Maintenance',
              subtitle: 'Keep your tank healthy',
              color: Colors.brown,
              child: Column(
                children: [
                  _WorkshopTile(
                    icon: Icons.notifications,
                    title: 'Reminders',
                    subtitle: 'Set maintenance reminders',
                    color: Colors.orange,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RemindersScreen()),
                    ),
                  ),
                  if (tankId != null) ...[
                    _WorkshopTile(
                      icon: Icons.task_alt,
                      title: 'Tasks',
                      subtitle: 'View and manage tasks',
                      color: Colors.blue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TasksScreen(tankId: tankId!)),
                      ),
                    ),
                    _WorkshopTile(
                      icon: Icons.checklist,
                      title: 'Maintenance Checklist',
                      subtitle: 'Weekly and monthly checks',
                      color: Colors.teal,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MaintenanceChecklistScreen(
                            tankId: tankId!,
                            tankName: tankName ?? 'Tank',
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Data section
          SliverToBoxAdapter(
            child: _SectionCard(
              title: '💾 Data',
              subtitle: 'Backup and restore your data',
              color: Colors.grey,
              child: Column(
                children: [
                  _WorkshopTile(
                    icon: Icons.backup,
                    title: 'Backup & Restore',
                    subtitle: 'Save or restore your data',
                    color: Colors.blueGrey,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BackupRestoreScreen()),
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

/// Illustrated workshop background
class _WorkshopBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF5D4037), // Brown
            Color(0xFF795548), // Lighter brown
          ],
        ),
      ),
      child: Stack(
        children: [
          // Tools silhouette
          Positioned(
            right: 20,
            bottom: 40,
            child: Icon(
              Icons.build,
              size: 100,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          // Wrench
          Positioned(
            left: 30,
            bottom: 50,
            child: Icon(
              Icons.settings,
              size: 70,
              color: Colors.white.withOpacity(0.15),
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

class _WorkshopTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _WorkshopTile({
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
