import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import 'co2_calculator_screen.dart';
import 'dosing_calculator_screen.dart';
import 'compatibility_checker_screen.dart';
// import 'equipment_screen.dart'; // Requires tankId - use settings instead
import 'cost_tracker_screen.dart';
import 'water_change_calculator_screen.dart';
import 'stocking_calculator_screen.dart';
import 'unit_converter_screen.dart';
import 'tank_volume_calculator_screen.dart';
import 'lighting_schedule_screen.dart';
// charts_screen.dart requires tankId - accessed from tank detail screen

/// Workshop colors - practical maker space theme
class WorkshopColors {
  static const background1 = Color(0xFF5D4E37); // Warm brown
  static const background2 = Color(0xFF4A3F2E); // Darker brown
  static const background3 = Color(0xFF3D3425); // Deep brown
  static const accent = Color(0xFFA0AEC0); // Steel blue
  static const accentWarm = Color(0xFFD4A574); // Warm gold
  static const wood = Color(0xFF7A6548); // Light wood
  static const metal = Color(0xFF6B7280); // Steel gray
  static const glassCard = Color(0x20FFFFFF);
  static const glassBorder = Color(0x30FFFFFF);
  static const textPrimary = Color(0xFFF5F5F5);
  static const textSecondary = Color(0xFFB8B0A0);
}

/// Workshop Room - Tools & Calculators
class WorkshopScreen extends ConsumerWidget {
  const WorkshopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            WorkshopColors.background1,
            WorkshopColors.background2,
            WorkshopColors.background3,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(child: _WorkshopHeader()),

            // Tool cards
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildListDelegate([
                  _ToolCard(
                    icon: Icons.water_drop,
                    title: 'Water Change',
                    subtitle: 'Calculate changes',
                    color: Colors.blue.shade400,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WaterChangeCalculatorScreen(),
                      ),
                    ),
                  ),
                  _ToolCard(
                    icon: Icons.set_meal,
                    title: 'Stocking',
                    subtitle: 'Fish capacity',
                    color: Colors.cyan.shade400,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StockingCalculatorScreen(),
                      ),
                    ),
                  ),
                  _ToolCard(
                    icon: Icons.science,
                    title: 'CO₂ Calculator',
                    subtitle: 'From pH & KH',
                    color: Colors.green.shade400,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const Co2CalculatorScreen(),
                      ),
                    ),
                  ),
                  _ToolCard(
                    icon: Icons.medication_liquid,
                    title: 'Dosing',
                    subtitle: 'Fertilizer calculator',
                    color: Colors.purple.shade300,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DosingCalculatorScreen(),
                      ),
                    ),
                  ),
                  _ToolCard(
                    icon: Icons.swap_horiz,
                    title: 'Unit Converter',
                    subtitle: 'Convert units',
                    color: Colors.amber.shade400,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UnitConverterScreen(),
                      ),
                    ),
                  ),
                  _ToolCard(
                    icon: Icons.calculate,
                    title: 'Tank Volume',
                    subtitle: 'Calculate capacity',
                    color: WorkshopColors.accent,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TankVolumeCalculatorScreen(),
                      ),
                    ),
                  ),
                  _ToolCard(
                    icon: Icons.lightbulb,
                    title: 'Lighting',
                    subtitle: 'Schedule lights',
                    color: Colors.yellow.shade600,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LightingScheduleScreen(),
                      ),
                    ),
                  ),
                  _ToolCard(
                    icon: Icons.bar_chart,
                    title: 'Charts',
                    subtitle: 'Analytics & trends',
                    color: Colors.indigo.shade400,
                    onTap: () => _showChartsInfo(context),
                  ),
                  _ToolCard(
                    icon: Icons.pets,
                    title: 'Compatibility',
                    subtitle: 'Check fish matches',
                    color: Colors.orange.shade400,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CompatibilityCheckerScreen(),
                      ),
                    ),
                  ),
                  _ToolCard(
                    icon: Icons.build_circle,
                    title: 'Equipment',
                    subtitle: 'Manage gear',
                    color: WorkshopColors.metal,
                    onTap: () => _showEquipmentInfo(context),
                  ),
                  _ToolCard(
                    icon: Icons.attach_money,
                    title: 'Cost Tracker',
                    subtitle: 'Track expenses',
                    color: Colors.teal.shade400,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CostTrackerScreen(),
                      ),
                    ),
                  ),
                ]),
              ),
            ),

            // Quick conversions section
            SliverToBoxAdapter(child: _QuickConversions()),

            // Bottom padding for navigation bar
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  void _showEquipmentInfo(BuildContext context) {
    AppFeedback.showInfo(context, 'Select a tank first to manage equipment.');
  }

  void _showChartsInfo(BuildContext context) {
    AppFeedback.showInfo(context, 'Select a tank first to view charts.');
  }
}

class _WorkshopHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: WorkshopColors.glassCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: WorkshopColors.glassBorder),
                ),
                child: const Icon(
                  Icons.build,
                  color: WorkshopColors.accentWarm,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '🔧 Workshop',
                    style: TextStyle(
                      color: WorkshopColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tools & calculators',
                    style: TextStyle(
                      color: WorkshopColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: WorkshopColors.glassCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: WorkshopColors.glassBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: WorkshopColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: WorkshopColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickConversions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: WorkshopColors.glassCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: WorkshopColors.glassBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Reference',
                  style: TextStyle(
                    color: WorkshopColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _ConversionRow('1 gallon', '3.785 liters'),
                _ConversionRow('1 inch', '2.54 cm'),
                _ConversionRow('°F to °C', '(°F - 32) × 5/9'),
                _ConversionRow('ppm', 'mg/L (same)'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversionRow extends StatelessWidget {
  final String left;
  final String right;

  const _ConversionRow(this.left, this.right);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: const TextStyle(
              color: WorkshopColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            right,
            style: const TextStyle(
              color: WorkshopColors.accentWarm,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _VolumeCalculatorSheet extends StatefulWidget {
  const _VolumeCalculatorSheet();

  @override
  State<_VolumeCalculatorSheet> createState() => _VolumeCalculatorSheetState();
}

class _VolumeCalculatorSheetState extends State<_VolumeCalculatorSheet> {
  double _length = 60;
  double _width = 30;
  double _height = 36;
  bool _isMetric = true;

  double get _volumeLiters {
    if (_isMetric) {
      return (_length * _width * _height) / 1000;
    } else {
      // Convert inches to cm, then calculate
      final lcm = _length * 2.54;
      final wcm = _width * 2.54;
      final hcm = _height * 2.54;
      return (lcm * wcm * hcm) / 1000;
    }
  }

  double get _volumeGallons => _volumeLiters / 3.785;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: WorkshopColors.background2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tank Volume Calculator',
                style: TextStyle(
                  color: WorkshopColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ToggleButtons(
                isSelected: [_isMetric, !_isMetric],
                onPressed: (i) => setState(() => _isMetric = i == 0),
                borderRadius: BorderRadius.circular(8),
                selectedColor: WorkshopColors.textPrimary,
                fillColor: WorkshopColors.accent.withOpacity(0.3),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'cm',
                      style: TextStyle(color: WorkshopColors.textSecondary),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'in',
                      style: TextStyle(color: WorkshopColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _DimensionSlider(
            label: 'Length',
            value: _length,
            unit: _isMetric ? 'cm' : 'in',
            min: 10,
            max: _isMetric ? 200 : 80,
            onChanged: (v) => setState(() => _length = v),
          ),
          _DimensionSlider(
            label: 'Width',
            value: _width,
            unit: _isMetric ? 'cm' : 'in',
            min: 10,
            max: _isMetric ? 100 : 40,
            onChanged: (v) => setState(() => _width = v),
          ),
          _DimensionSlider(
            label: 'Height',
            value: _height,
            unit: _isMetric ? 'cm' : 'in',
            min: 10,
            max: _isMetric ? 80 : 32,
            onChanged: (v) => setState(() => _height = v),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: WorkshopColors.glassCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${_volumeLiters.toStringAsFixed(1)}L',
                      style: const TextStyle(
                        color: WorkshopColors.accentWarm,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Liters',
                      style: TextStyle(color: WorkshopColors.textSecondary),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: WorkshopColors.glassBorder,
                ),
                Column(
                  children: [
                    Text(
                      '${_volumeGallons.toStringAsFixed(1)}G',
                      style: const TextStyle(
                        color: WorkshopColors.accent,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Gallons',
                      style: TextStyle(color: WorkshopColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

class _DimensionSlider extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _DimensionSlider({
    required this.label,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(color: WorkshopColors.textSecondary),
            ),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              activeColor: WorkshopColors.accent,
              inactiveColor: WorkshopColors.glassBorder,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              '${value.toStringAsFixed(0)} $unit',
              style: const TextStyle(
                color: WorkshopColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
