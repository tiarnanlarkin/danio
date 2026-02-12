import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_card.dart';

class AlgaeGuideScreen extends StatelessWidget {
  const AlgaeGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Algae Identification & Control')),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
                    Icon(Icons.eco, color: AppColors.info),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Algae Basics', style: AppTypography.headlineSmall),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Some algae is normal and healthy — it means your tank is alive! '
                  'Problems occur when algae grows out of control due to imbalances in light, nutrients, or CO2.',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Algae types
          _AlgaeCard(
            name: 'Green Spot Algae (GSA)',
            appearance:
                'Hard green spots on glass, slow-growing plants, and hardscape',
            color: Colors.green,
            causes: [
              'Low phosphate',
              'High light',
              'Old bulbs with shifted spectrum',
            ],
            solutions: [
              'Increase phosphate dosing',
              'Reduce light intensity or duration',
              'Scrape off with razor blade (glass only)',
              'Nerite snails eat it slowly',
            ],
            prevention: 'Maintain adequate phosphate levels (1-2 ppm)',
          ),
          _AlgaeCard(
            name: 'Green Dust Algae (GDA)',
            appearance:
                'Soft green film on glass that wipes off easily, returns quickly',
            color: Colors.lightGreen,
            causes: ['New tank syndrome', 'Unstable CO2', 'Nutrient imbalance'],
            solutions: [
              'Wait 3-4 weeks without wiping (let it complete lifecycle)',
              'Then do large water change and wipe clean',
              'Stabilize CO2 and nutrients',
            ],
            prevention: 'Patience — often resolves on its own in mature tanks',
          ),
          _AlgaeCard(
            name: 'Green Water',
            appearance: 'Cloudy green water, can\'t see through tank',
            color: Colors.green.shade300,
            causes: [
              'Excess light (especially direct sunlight)',
              'High ammonia/nutrients',
              'New tank',
            ],
            solutions: [
              'UV sterilizer (most effective)',
              'Complete blackout for 3-4 days',
              'Large water changes',
              'Daphnia (eat the algae)',
              'Fine filter floss or diatom filter',
            ],
            prevention:
                'Avoid direct sunlight, control nutrients, proper cycling',
          ),
          _AlgaeCard(
            name: 'Hair/Thread Algae',
            appearance: 'Long green filaments, looks like hair or threads',
            color: Colors.green.shade600,
            causes: [
              'Excess light',
              'Low CO2',
              'Ammonia spikes',
              'Nutrient imbalance',
            ],
            solutions: [
              'Manually remove by twirling on toothbrush',
              'Reduce light period',
              'Increase CO2 if planted',
              'Amano shrimp and certain fish eat it',
              'Spot treat with hydrogen peroxide or Excel',
            ],
            prevention: 'Balance light, CO2, and nutrients',
          ),
          _AlgaeCard(
            name: 'Black Beard Algae (BBA)',
            appearance:
                'Dark fuzzy tufts on edges of plants, equipment, hardscape',
            color: Colors.grey.shade800,
            causes: ['Fluctuating CO2', 'Low/unstable CO2', 'Poor flow'],
            solutions: [
              'Stabilize CO2 levels (consistency is key)',
              'Spot treat with Excel/hydrogen peroxide',
              'Remove affected leaves',
              'Siamese Algae Eaters (true SAE) eat it',
              'Increase flow in affected areas',
            ],
            prevention: 'Consistent CO2 levels, good circulation',
          ),
          _AlgaeCard(
            name: 'Staghorn Algae',
            appearance: 'Grey/green branching strands, looks like deer antlers',
            color: Colors.grey,
            causes: ['Low CO2', 'Poor circulation', 'Organic waste buildup'],
            solutions: [
              'Increase CO2',
              'Improve flow',
              'Spot treat with Excel',
              'Manual removal',
              'Amano shrimp help',
            ],
            prevention: 'Adequate CO2, good flow, clean tank',
          ),
          _AlgaeCard(
            name: 'Blue-Green Algae (Cyanobacteria)',
            appearance:
                'Slimy blue-green sheets, strong musty smell, peels off in sheets',
            color: Colors.teal,
            causes: [
              'Low nitrate',
              'Poor circulation',
              'Dirty substrate',
              'Excess organics',
            ],
            solutions: [
              'Blackout for 3 days (cover tank completely)',
              'Erythromycin antibiotic treatment',
              'Increase nitrate if very low',
              'Improve flow and gravel vacuum',
              'Manual removal before treatment',
            ],
            prevention:
                'Maintain nitrates >5ppm, good circulation, clean substrate',
          ),
          _AlgaeCard(
            name: 'Brown Diatoms',
            appearance:
                'Brown dusty coating on everything, common in new tanks',
            color: Colors.brown,
            causes: [
              'New tank (silicates in water)',
              'Low light',
              'High silicates',
            ],
            solutions: [
              'Usually resolves on its own in 4-8 weeks',
              'Otocinclus, nerite snails love it',
              'Wipe off during water changes',
              'Increase light slightly',
            ],
            prevention: 'Time — very common in cycling tanks and goes away',
          ),
          _AlgaeCard(
            name: 'Green Fuzz Algae',
            appearance: 'Short fuzzy green carpet on plants and surfaces',
            color: Colors.lightGreen.shade400,
            causes: [
              'Imbalanced nutrients',
              'Inconsistent CO2',
              'Excess light',
            ],
            solutions: [
              'Balance nutrients (usually low nitrogen)',
              'Stabilize CO2',
              'Amano shrimp, snails, otos help',
              'Manual removal',
            ],
            prevention: 'Balanced fertilization, consistent CO2',
          ),
          _AlgaeCard(
            name: 'Rhizoclonium',
            appearance: 'Fine cottony threads, often confused with hair algae',
            color: Colors.green.shade200,
            causes: ['Very low CO2', 'New setup', 'Ammonia from soil'],
            solutions: [
              'Increase CO2 significantly',
              'Manual removal',
              'Amano shrimp',
              'Often seen in new aquasoil setups',
            ],
            prevention: 'Start with adequate CO2, especially with new soil',
          ),

          const SizedBox(height: AppSpacing.lg),

          // Algae eaters
          Text('Algae-Eating Crew', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          _CrewCard(
            name: 'Amano Shrimp',
            eats: 'Hair algae, most soft algae',
            notes:
                'Best algae eaters. Need groups of 5+. Won\'t breed in freshwater.',
          ),
          _CrewCard(
            name: 'Nerite Snails',
            eats: 'Green spot, diatoms, general film',
            notes:
                'Excellent cleaners. Leave white eggs on hardscape (won\'t hatch in freshwater).',
          ),
          _CrewCard(
            name: 'Otocinclus',
            eats: 'Diatoms, soft green algae',
            notes:
                'Peaceful, need groups of 6+. Sensitive — add to mature tanks only.',
          ),
          _CrewCard(
            name: 'Siamese Algae Eater',
            eats: 'BBA, hair algae (when young)',
            notes:
                'True SAE only. Gets large (15cm), may stop eating algae when older.',
          ),
          _CrewCard(
            name: 'Bristlenose Pleco',
            eats: 'General algae, wood',
            notes: 'Needs driftwood. Good general cleaner. Max 12cm.',
          ),
          _CrewCard(
            name: 'Mystery Snails',
            eats: 'Leftover food, decaying plants, some algae',
            notes: 'More scavenger than algae eater. Won\'t harm live plants.',
          ),

          const SizedBox(height: AppSpacing.lg),

          // Prevention tips
          Text('Prevention Checklist', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: AppCardPadding.standard,
            child: Column(
              children: [
                _ChecklistItem(
                  text: 'Light: 6-8 hours max, no direct sunlight',
                ),
                _ChecklistItem(text: 'CO2: Consistent levels if injecting'),
                _ChecklistItem(text: 'Nutrients: Balanced N:P:K ratio'),
                _ChecklistItem(text: 'Flow: No dead spots'),
                _ChecklistItem(text: 'Maintenance: Regular water changes'),
                _ChecklistItem(text: 'Stocking: Don\'t overfeed'),
                _ChecklistItem(text: 'Plants: Fast growers outcompete algae'),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _AlgaeCard extends StatelessWidget {
  final String name;
  final String appearance;
  final Color color;
  final List<String> causes;
  final List<String> solutions;
  final String prevention;

  const _AlgaeCard({
    required this.name,
    required this.appearance,
    required this.color,
    required this.causes,
    required this.solutions,
    required this.prevention,
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
            color: color.withOpacity(0.3),
            borderRadius: AppRadius.smallRadius,
            border: Border.all(color: color, width: 2),
          ),
        ),
        title: Text(name, style: AppTypography.labelLarge),
        subtitle: Text(appearance, style: AppTypography.bodySmall, maxLines: 2),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Causes',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                ...causes.map(
                  (c) => Text('• $c', style: AppTypography.bodySmall),
                ),

                const SizedBox(height: 12),

                Text(
                  'Solutions',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                ...solutions.map(
                  (s) => Text('• $s', style: AppTypography.bodySmall),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppOverlays.info10,
                    borderRadius: AppRadius.smallRadius,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shield, size: 16, color: AppColors.info),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Prevention: $prevention',
                          style: AppTypography.bodySmall,
                        ),
                      ),
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

class _CrewCard extends StatelessWidget {
  final String name;
  final String eats;
  final String notes;

  const _CrewCard({
    required this.name,
    required this.eats,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppOverlays.success10,
                borderRadius: AppRadius.smallRadius,
              ),
              child: const Icon(
                Icons.pest_control,
                color: AppColors.success,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTypography.labelLarge),
                  Text(
                    'Eats: $eats',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.success,
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

class _ChecklistItem extends StatelessWidget {
  final String text;

  const _ChecklistItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_box_outlined, size: 20, color: AppColors.success),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }
}
