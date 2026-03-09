import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_card.dart';

class HardscapeGuideScreen extends StatelessWidget {
  const HardscapeGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hardscape Guide')),
      body: ListView.builder(
        padding: EdgeInsets.all(AppSpacing.md),
        itemCount: _buildItems().length,
        itemBuilder: (context, index) => _buildItems()[index],
      ),
    );
  }

  List<Widget> _buildItems() {
    return [
          // Intro
          AppCard(
            backgroundColor: AppOverlays.info10,
            padding: AppCardPadding.standard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.landscape, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'What is Hardscape?',
                      style: AppTypography.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm2),
                Text(
                  'Hardscape refers to rocks, driftwood, and other non-living decorative elements. '
                  'Good hardscape creates structure, hiding spots, and visual interest. '
                  'It\'s the backbone of aquascaping.',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Rocks
          Text('Rocks', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),

          _RockCard(
            name: 'Seiryu Stone',
            description:
                'Blue-grey limestone with dramatic texture and white veins.',
            affectsWater: 'Raises pH and KH (calcium carbonate)',
            bestFor: 'Iwagumi, nature style, hard water tanks',
            tips: [
              'Very popular for iwagumi',
              'Sharp edges - handle carefully',
              'Not for soft water fish without buffering',
            ],
          ),
          _RockCard(
            name: 'Dragon Stone (Ohko)',
            description: 'Clay-based stone with holes and weathered texture.',
            affectsWater: 'Inert - minimal effect',
            bestFor: 'Planted tanks, nature style',
            tips: [
              'Lightweight',
              'Soft - can be carved',
              'Holes perfect for planting',
            ],
          ),
          _RockCard(
            name: 'Lava Rock',
            description: 'Porous volcanic rock, black or red.',
            affectsWater: 'Inert',
            bestFor: 'Biological filtration, planted tanks, cichlid caves',
            tips: [
              'Excellent bacteria colonization',
              'Very rough - can injure fish',
              'Great for attaching plants',
            ],
          ),
          _RockCard(
            name: 'River Rocks',
            description: 'Smooth, rounded stones in various colors.',
            affectsWater: 'Usually inert (test with vinegar first)',
            bestFor: 'Natural biotopes, riverbeds',
            tips: [
              'Test for calcium - fizz = raises pH',
              'Smooth is safer for bottom dwellers',
              'Avoid collecting from polluted areas',
            ],
          ),
          _RockCard(
            name: 'Slate',
            description: 'Flat, layered stone, grey or black.',
            affectsWater: 'Inert',
            bestFor: 'Caves, ledges, cichlid tanks',
            tips: ['Easy to stack', 'Great for caves', 'Can have sharp edges'],
          ),
          _RockCard(
            name: 'Texas Holey Rock',
            description: 'Limestone with natural holes, beige/white.',
            affectsWater: 'Raises pH and hardness significantly',
            bestFor: 'African cichlids, hard water fish',
            tips: [
              'Perfect for Malawi/Tanganyikan tanks',
              'Provides lots of hiding spots',
              'Heavy',
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Driftwood
          Text('Driftwood', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),

          _WoodCard(
            name: 'Mopani Wood',
            description:
                'Dense African hardwood, two-toned with interesting shapes.',
            characteristics: 'Sinks immediately, releases tannins, very hard',
            bestFor: 'Blackwater tanks, plecos',
            tips: [
              'Heavy tannin release - soak first',
              'Very dense - sinks right away',
              'Won\'t rot quickly',
            ],
          ),
          _WoodCard(
            name: 'Malaysian Driftwood',
            description: 'Gnarly, twisted shapes with bark-like texture.',
            characteristics: 'Usually sinks, releases moderate tannins',
            bestFor: 'Nature style, biotopes',
            tips: [
              'Soak to remove tannins',
              'May need weighing down initially',
              'Great for attaching moss',
            ],
          ),
          _WoodCard(
            name: 'Spider Wood',
            description: 'Thin, branching wood resembling tree roots.',
            characteristics: 'Lightweight, floats initially, releases tannins',
            bestFor: 'Nature style, iwagumi accent, nano tanks',
            tips: [
              'WILL float - soak for weeks or weigh down',
              'Delicate - handle carefully',
              'Creates dramatic effect',
            ],
          ),
          _WoodCard(
            name: 'Manzanita',
            description: 'Branching hardwood with smooth, twisted branches.',
            characteristics: 'Sinks eventually, minimal tannins',
            bestFor: 'Nature style, tall tanks',
            tips: [
              'Very hard and durable',
              'Often needs soaking',
              'Beautiful natural branching',
            ],
          ),
          _WoodCard(
            name: 'Cholla Wood',
            description: 'Hollow, tubular cactus skeleton.',
            characteristics: 'Sinks quickly, breaks down over time',
            bestFor: 'Shrimp tanks, fry hiding',
            tips: [
              'Shrimp love it',
              'Will decompose - replace every 6-12 months',
              'Biofilm grows on it (food for shrimp)',
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Preparing hardscape
          Text('Preparation', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),

          AppCard(
            padding: AppCardPadding.standard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Preparing Rocks', style: AppTypography.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                _PrepStep(
                  step: '1',
                  text: 'Scrub with brush and water (no soap!)',
                ),
                _PrepStep(
                  step: '2',
                  text: 'Boil small rocks for 10-15 minutes',
                ),
                _PrepStep(
                  step: '3',
                  text: 'Pour boiling water over large rocks',
                ),
                _PrepStep(
                  step: '4',
                  text: 'Test with vinegar - fizzing means calcium',
                ),

                const SizedBox(height: AppSpacing.md),

                Text('Preparing Driftwood', style: AppTypography.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                _PrepStep(step: '1', text: 'Scrub off any loose material'),
                _PrepStep(
                  step: '2',
                  text: 'Boil if small enough (removes tannins faster)',
                ),
                _PrepStep(
                  step: '3',
                  text: 'Soak in bucket - change water daily',
                ),
                _PrepStep(
                  step: '4',
                  text: 'Soak until it sinks (days to weeks)',
                ),
                _PrepStep(
                  step: '5',
                  text: 'Or weigh down with rocks/suction cups',
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Aquascaping tips
          Text('Design Tips', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),

          _TipCard(
            title: 'Rule of Thirds',
            description: 'Place focal points at 1/3 intersections, not center.',
            icon: Icons.grid_on,
          ),
          _TipCard(
            title: 'Golden Ratio',
            description:
                'Main feature at ~62% from one side creates natural balance.',
            icon: Icons.auto_awesome,
          ),
          _TipCard(
            title: 'Odd Numbers',
            description:
                'Use odd numbers of rocks/wood pieces (3, 5, 7) for natural look.',
            icon: Icons.filter_3,
          ),
          _TipCard(
            title: 'Height Variation',
            description:
                'Vary heights - tall in back, short in front. Create depth.',
            icon: Icons.trending_up,
          ),
          _TipCard(
            title: 'Negative Space',
            description: 'Leave empty areas. Don\'t fill every space.',
            icon: Icons.crop_free,
          ),
          _TipCard(
            title: 'Single Type',
            description:
                'Use one type of rock for cohesive look. Mixing can look cluttered.',
            icon: Icons.category,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Warning
          AppCard(
            backgroundColor: AppOverlays.warning10,
            padding: AppCardPadding.standard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber, color: AppColors.warning),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Safety Notes', style: AppTypography.headlineSmall),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm2),
                Text(
                  '• Never use rocks from parking lots or roadsides (contaminated)\n'
                  '• Avoid metal ores or rocks with metallic veins\n'
                  '• Secure heavy rocks - they can crack glass if they fall\n'
                  '• Test unknown rocks: vinegar fizz = calcium = affects water\n'
                  '• Don\'t collect wood from treated/painted sources\n'
                  '• Weigh down floating wood - fish can get trapped',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
    ];
  }
}

class _RockCard extends StatelessWidget {
  final String name;
  final String description;
  final String affectsWater;
  final String bestFor;
  final List<String> tips;

  const _RockCard({
    required this.name,
    required this.description,
    required this.affectsWater,
    required this.bestFor,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm2),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppOverlays.grey20,
            borderRadius: AppRadius.smallRadius,
          ),
          child: Icon(Icons.terrain, color: context.textSecondary),
        ),
        title: Text(name, style: AppTypography.labelLarge),
        subtitle: Text(
          description,
          style: AppTypography.bodySmall,
          maxLines: 2,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(label: 'Water effect', value: affectsWater),
                _DetailRow(label: 'Best for', value: bestFor),
                const SizedBox(height: AppSpacing.sm),
                ...tips.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check, size: AppIconSizes.xs, color: AppColors.success),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(t, style: AppTypography.bodySmall),
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
    );
  }
}

class _WoodCard extends StatelessWidget {
  final String name;
  final String description;
  final String characteristics;
  final String bestFor;
  final List<String> tips;

  const _WoodCard({
    required this.name,
    required this.description,
    required this.characteristics,
    required this.bestFor,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm2),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppOverlays.brown20,
            borderRadius: AppRadius.smallRadius,
          ),
          child: const Icon(Icons.park, color: DanioColors.coralAccent),
        ),
        title: Text(name, style: AppTypography.labelLarge),
        subtitle: Text(
          description,
          style: AppTypography.bodySmall,
          maxLines: 2,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(label: 'Characteristics', value: characteristics),
                _DetailRow(label: 'Best for', value: bestFor),
                const SizedBox(height: AppSpacing.sm),
                ...tips.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check, size: AppIconSizes.xs, color: AppColors.success),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(t, style: AppTypography.bodySmall),
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
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}

class _PrepStep extends StatelessWidget {
  final String step;
  final String text;

  const _PrepStep({required this.step, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppOverlays.primary10,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _TipCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.sm2),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.labelLarge),
                  Text(description, style: AppTypography.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
