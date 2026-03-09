import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_card.dart';

class SubstrateGuideScreen extends StatelessWidget {
  const SubstrateGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Substrate Guide')),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          // Intro
          AppCard(
            backgroundColor: AppOverlays.info10,
            padding: AppCardPadding.standard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.layers, color: context.textSecondary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Why Substrate Matters',
                      style: AppTypography.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm2),
                Text(
                  'Substrate affects water chemistry, plant growth, fish behavior, and aesthetics. '
                  'Choose based on your tank inhabitants and goals.',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Substrate types
          Text('Substrate Types', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),

          _SubstrateCard(
            name: 'Gravel',
            description:
                'Classic aquarium substrate. Inert, doesn\'t affect water chemistry.',
            pros: [
              'Cheap',
              'Easy to clean',
              'Many colors',
              'Won\'t cloud water',
            ],
            cons: [
              'No nutrients for plants',
              'Food can get trapped',
              'Too large for some bottom dwellers',
            ],
            bestFor: 'Fish-only tanks, beginners, easy maintenance',
            size: '3-5mm typical',
            depth: '5-8cm (2-3 inches)',
          ),
          _SubstrateCard(
            name: 'Sand',
            description:
                'Fine particles, natural look. Popular for planted tanks and bottom dwellers.',
            pros: [
              'Natural look',
              'Great for corys/loaches',
              'Easy for plants to root',
              'No food trapping',
            ],
            cons: [
              'Can compact',
              'May cause dead spots',
              'Some types cloud water',
              'Harder to vacuum',
            ],
            bestFor: 'Corydoras, loaches, planted tanks, natural biotopes',
            size: '0.5-2mm',
            depth: '3-5cm (1-2 inches), or 5-8cm for plants',
          ),
          _SubstrateCard(
            name: 'Aquasoil (Active Substrate)',
            description:
                'Nutrient-rich, lowers pH. Designed for planted tanks.',
            pros: [
              'Nutrients for plants',
              'Lowers pH/KH',
              'Excellent plant growth',
              'Promotes root development',
            ],
            cons: [
              'Expensive',
              'Leaches ammonia initially',
              'Breaks down over 1-2 years',
              'Clouds if disturbed',
            ],
            bestFor: 'High-tech planted tanks, soft water fish, aquascaping',
            size: '1-4mm granules',
            depth: '5-10cm (2-4 inches)',
            brands:
                'ADA Amazonia, Tropica Aquarium Soil, Fluval Stratum, UNS Controsoil',
          ),
          _SubstrateCard(
            name: 'Flourite',
            description: 'Clay-based planted tank substrate. Inert but porous.',
            pros: [
              'Long-lasting',
              'Doesn\'t break down',
              'No ammonia spike',
              'Holds nutrients',
            ],
            cons: [
              'Very dusty - rinse thoroughly',
              'No initial nutrients',
              'Heavy',
            ],
            bestFor: 'Low-tech planted tanks, long-term setups',
            size: '2-5mm',
            depth: '5-8cm (2-3 inches)',
          ),
          _SubstrateCard(
            name: 'Crushed Coral',
            description: 'Calcium carbite. Raises pH and hardness.',
            pros: [
              'Buffers to high pH',
              'Adds calcium',
              'Good for hard water fish',
            ],
            cons: [
              'Not for soft water fish',
              'Not for most plants',
              'Sharp edges',
            ],
            bestFor: 'African cichlids, livebearers, marine tanks',
            size: '2-5mm',
            depth: '5-8cm (2-3 inches)',
          ),
          _SubstrateCard(
            name: 'Bare Bottom',
            description: 'No substrate at all. Easy maintenance.',
            pros: [
              'Easiest to clean',
              'No detritus buildup',
              'See waste immediately',
            ],
            cons: [
              'Unnatural look',
              'No beneficial bacteria surface',
              'No plants without pots',
              'Fish may be stressed',
            ],
            bestFor: 'Hospital tanks, quarantine, breeding tanks, fry tanks',
            size: 'N/A',
            depth: 'N/A',
          ),

          const SizedBox(height: AppSpacing.lg),

          // By tank type
          Text('Recommended by Tank Type', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),

          _TankTypeCard(
            tankType: 'High-Tech Planted',
            substrate: 'Aquasoil + root tabs',
            notes:
                'Nutrient-rich soil is essential. Cap with sand for aesthetic if desired.',
          ),
          _TankTypeCard(
            tankType: 'Low-Tech Planted',
            substrate: 'Sand or Flourite + root tabs',
            notes:
                'Inert substrate with root tabs works well. Dirted tanks also popular.',
          ),
          _TankTypeCard(
            tankType: 'Fish Only (Community)',
            substrate: 'Gravel or sand',
            notes: 'Choose based on fish needs. Corys need sand.',
          ),
          _TankTypeCard(
            tankType: 'African Cichlid',
            substrate: 'Sand + crushed coral or aragonite',
            notes: 'Buffer pH high. Cichlids love digging in sand.',
          ),
          _TankTypeCard(
            tankType: 'Shrimp',
            substrate: 'Aquasoil (for Caridina) or inert (for Neocaridina)',
            notes:
                'Caridina need low pH - use buffering soil. Neocaridina adaptable.',
          ),
          _TankTypeCard(
            tankType: 'Biotope',
            substrate: 'Match the natural habitat',
            notes:
                'Amazon: sand + leaves. Asian: fine gravel. African stream: rocks.',
          ),
          _TankTypeCard(
            tankType: 'Breeding',
            substrate: 'Bare bottom or marbles',
            notes:
                'Easy to see/collect eggs. Marbles protect eggs from being eaten.',
          ),

          const SizedBox(height: AppSpacing.lg),

          // Layering
          Text('Layering Substrates', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),

          AppCard(
            padding: AppCardPadding.standard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dirted Tank (Walstad Method)',
                  style: AppTypography.labelLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                _LayerRow(
                  layer: 'Top',
                  material: 'Sand or fine gravel cap (3-5cm)',
                  color: Colors.brown.shade300,
                ),
                _LayerRow(
                  layer: 'Bottom',
                  material: 'Organic potting soil (2-3cm)',
                  color: Colors.brown.shade800,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Low-tech method. Soil provides nutrients, cap prevents clouding. '
                  'No CO2 or fertilizers needed for easy plants.',
                  style: AppTypography.bodySmall,
                ),

                const SizedBox(height: AppSpacing.lg2),

                Text('High-Tech Planted', style: AppTypography.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                _LayerRow(
                  layer: 'Top',
                  material: 'Aquasoil (5-8cm)',
                  color: Colors.brown.shade600,
                ),
                _LayerRow(
                  layer: 'Middle',
                  material: 'Power Sand / Pumice (optional, 1-2cm)',
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                _LayerRow(
                  layer: 'Bottom',
                  material: 'Substrate fertilizer (optional)',
                  color: Colors.brown.shade900,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'For maximum plant growth. Power sand adds drainage and bacterial surface area.',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Tips
          AppCard(
            backgroundColor: AppOverlays.warning10,
            padding: AppCardPadding.standard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: AppColors.warning),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Pro Tips', style: AppTypography.headlineSmall),
                ],
              ),
              const SizedBox(height: AppSpacing.sm2),
              _TipItem(
                text: 'Rinse all substrate before use - even "pre-washed"',
              ),
              _TipItem(
                text: 'Slope substrate higher in back for depth illusion',
              ),
              _TipItem(text: 'Use substrate dividers to create zones'),
              _TipItem(
                text: 'Never vacuum planted areas deeply - disturbs roots',
              ),
              _TipItem(text: 'Dark substrate makes fish colors pop'),
              _TipItem(
                text:
                    'Calculate amount: L × W × depth (cm) ÷ 1000 = litres needed',
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

class _SubstrateCard extends StatelessWidget {
  final String name;
  final String description;
  final List<String> pros;
  final List<String> cons;
  final String bestFor;
  final String size;
  final String depth;
  final String? brands;

  const _SubstrateCard({
    required this.name,
    required this.description,
    required this.pros,
    required this.cons,
    required this.bestFor,
    required this.size,
    required this.depth,
    this.brands,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppOverlays.brown20,
            borderRadius: AppRadius.smallRadius,
          ),
          child: const Icon(Icons.layers, color: AppColors.woodBrown),
        ),
        title: Text(name, style: AppTypography.labelLarge),
        subtitle: Text(
          description,
          style: AppTypography.bodySmall,
          maxLines: 2,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✓ Pros',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                          ...pros.map(
                            (p) => Text('• $p', style: AppTypography.bodySmall),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✗ Cons',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                          ...cons.map(
                            (c) => Text('• $c', style: AppTypography.bodySmall),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm2),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm3),
                  decoration: BoxDecoration(
                    color: context.surfaceVariant,
                    borderRadius: AppRadius.smallRadius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Best for: $bestFor',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text('Grain size: $size', style: AppTypography.bodySmall),
                      Text('Depth: $depth', style: AppTypography.bodySmall),
                      if (brands != null)
                        Text('Brands: $brands', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TankTypeCard extends StatelessWidget {
  final String tankType;
  final String substrate;
  final String notes;

  const _TankTypeCard({
    required this.tankType,
    required this.substrate,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.sm2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(tankType, style: AppTypography.labelLarge),
            ),
            const SizedBox(width: AppSpacing.sm2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    substrate,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  Text(notes, style: AppTypography.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LayerRow extends StatelessWidget {
  final String layer;
  final String material;
  final Color color;

  const _LayerRow({
    required this.layer,
    required this.material,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadius.xsRadius,
            ),
          ),
          const SizedBox(width: AppSpacing.sm2),
          Text('$layer: ', style: AppTypography.labelLarge),
          Expanded(child: Text(material, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;

  const _TipItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, size: AppIconSizes.xs, color: AppColors.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}
