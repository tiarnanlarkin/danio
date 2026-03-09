import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_card.dart';

class ParameterGuideScreen extends StatelessWidget {
  const ParameterGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Water Parameters Guide')),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          // Intro
          AppCard(
            backgroundColor: AppOverlays.info10,
            padding: AppCardPadding.standard,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: context.textSecondary),
                const SizedBox(width: AppSpacing.sm2),
                Expanded(
                  child: Text(
                    'Understanding your water parameters is key to keeping healthy fish. '
                    'Test regularly and maintain stable values.',
                    style: AppTypography.bodyMedium,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Parameters
          _ParameterSection(
            title: 'Ammonia (NH₃)',
            icon: Icons.warning,
            color: AppColors.error,
            ideal: '0 ppm',
            danger: '>0.25 ppm',
            description:
                'Produced by fish waste and decaying matter. Highly toxic - burns gills and causes stress. '
                'Should always be 0 in a cycled tank.',
            tips: [
              'If detected, do an immediate 25-50% water change',
              'Check for dead fish or uneaten food',
              'Reduce feeding',
              'Use Seachem Prime to detoxify temporarily',
            ],
          ),

          _ParameterSection(
            title: 'Nitrite (NO₂)',
            icon: Icons.science,
            color: AppColors.warning,
            ideal: '0 ppm',
            danger: '>0.5 ppm',
            description:
                'Intermediate product of the nitrogen cycle. Prevents fish from absorbing oxygen. '
                'Should be 0 in a cycled tank.',
            tips: [
              'Indicates incomplete cycling',
              'Water changes dilute nitrite',
              'Salt (1 tsp/10L) can help reduce toxicity',
              'Don\'t add more fish until 0',
            ],
          ),

          _ParameterSection(
            title: 'Nitrate (NO₃)',
            icon: Icons.check_circle,
            color: AppColors.success,
            ideal: '<20 ppm',
            danger: '>40 ppm',
            description:
                'End product of nitrogen cycle. Much less toxic but builds up over time. '
                'Removed by water changes and plants.',
            tips: [
              'Weekly 20-25% water changes keep it low',
              'Live plants absorb nitrate',
              'High levels promote algae',
              'Some fish tolerate higher levels',
            ],
          ),

          _ParameterSection(
            title: 'pH',
            icon: Icons.science,
            color: AppColors.primary,
            ideal: '6.5-7.5 (species dependent)',
            danger: '<6.0 or >8.0',
            description:
                'Measures acidity/alkalinity. Most tropical fish prefer 6.5-7.5. '
                'Stability is more important than hitting a specific number.',
            tips: [
              'Don\'t chase a specific pH - stability matters more',
              'Driftwood and peat lower pH',
              'Crusite and limestone raise pH',
              'Test tap water to know your baseline',
            ],
          ),

          _ParameterSection(
            title: 'GH (General Hardness)',
            icon: Icons.opacity,
            color: AppColors.secondary,
            ideal: '4-12 dGH (species dependent)',
            danger: 'Depends on species',
            description:
                'Measures dissolved minerals (calcium, magnesium). Affects fish health and breeding. '
                'Soft water fish: 4-8 dGH. Hard water fish: 8-20 dGH.',
            tips: [
              'Livebearers prefer harder water (12+ dGH)',
              'Tetras and rasboras prefer softer (4-8 dGH)',
              'Crushed coral raises GH',
              'RO water is very soft (0 GH)',
            ],
          ),

          _ParameterSection(
            title: 'KH (Carbonate Hardness)',
            icon: Icons.shield,
            color: context.textSecondary,
            ideal: '4-8 dKH',
            danger: '<2 dKH',
            description:
                'Measures buffering capacity - prevents pH crashes. Low KH means pH can swing dangerously.',
            tips: [
              'Acts as pH buffer',
              'Low KH = risk of pH crash',
              'Baking soda raises KH (carefully!)',
              'Test if pH seems unstable',
            ],
          ),

          _ParameterSection(
            title: 'Temperature',
            icon: Icons.thermostat,
            color: AppColors.paramWarning,
            ideal: '24-26°C (tropical)',
            danger: '<20°C or >30°C',
            description:
                'Most tropical fish thrive at 24-26°C. Temperature affects metabolism, immune system, and oxygen levels.',
            tips: [
              'Use a reliable heater with thermostat',
              'Place thermometer away from heater',
              'Gradual changes (<2°C per hour)',
              'Hot weather: increase aeration',
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Quick reference table
          Text(
            'Quick Reference by Fish Type',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.md),

          AppCard(
            padding: AppCardPadding.compact,
            child: Column(
              children: [
                _QuickRefRow(
                  type: 'Community (tetras, rasboras)',
                  temp: '24-26°C',
                  ph: '6.5-7.5',
                  gh: '4-10',
                ),
                const Divider(),
                _QuickRefRow(
                  type: 'Livebearers (guppies, mollies)',
                  temp: '24-28°C',
                  ph: '7.0-8.0',
                  gh: '10-20',
                ),
                const Divider(),
                _QuickRefRow(
                  type: 'Cichlids (African)',
                  temp: '24-28°C',
                  ph: '7.5-8.5',
                  gh: '10-20',
                ),
                const Divider(),
                _QuickRefRow(
                  type: 'Discus',
                  temp: '28-30°C',
                  ph: '6.0-7.0',
                  gh: '1-4',
                ),
                const Divider(),
                _QuickRefRow(
                  type: 'Bettas',
                  temp: '25-28°C',
                  ph: '6.5-7.5',
                  gh: '4-10',
                ),
                const Divider(),
                _QuickRefRow(
                  type: 'Corydoras',
                  temp: '22-26°C',
                  ph: '6.0-7.5',
                  gh: '2-12',
                ),
                const Divider(),
                _QuickRefRow(
                  type: 'Shrimp (Neocaridina)',
                  temp: '20-25°C',
                  ph: '6.5-8.0',
                  gh: '6-12',
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _ParameterSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String ideal;
  final String danger;
  final String description;
  final List<String> tips;

  const _ParameterSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.ideal,
    required this.danger,
    required this.description,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: ExpansionTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: AppRadius.smallRadius,
            ),
            child: Icon(icon, color: color, size: AppIconSizes.sm),
          ),
          title: Text(title, style: AppTypography.labelLarge),
          subtitle: Row(
            children: [
              Text('Ideal: ', style: AppTypography.bodySmall),
              Text(
                ideal,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.dangerous, size: 14, color: AppColors.error),
                      const SizedBox(width: AppSpacing.xs),
                      Text('Danger: ', style: AppTypography.bodySmall),
                      Text(
                        danger,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm2),
                  Text(description, style: AppTypography.bodyMedium),
                  const SizedBox(height: AppSpacing.sm2),
                  Text('Tips:', style: AppTypography.labelLarge),
                  const SizedBox(height: AppSpacing.xs2),
                  ...tips.map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: AppTypography.bodySmall),
                          Expanded(
                            child: Text(tip, style: AppTypography.bodySmall),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickRefRow extends StatelessWidget {
  final String type;
  final String temp;
  final String ph;
  final String gh;

  const _QuickRefRow({
    required this.type,
    required this.temp,
    required this.ph,
    required this.gh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(type, style: AppTypography.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              _MiniChip(label: temp, icon: Icons.thermostat),
              const SizedBox(width: AppSpacing.sm),
              _MiniChip(label: 'pH $ph', icon: Icons.science),
              const SizedBox(width: AppSpacing.sm),
              _MiniChip(label: '$gh dGH', icon: Icons.opacity),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _MiniChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.smallRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: context.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
