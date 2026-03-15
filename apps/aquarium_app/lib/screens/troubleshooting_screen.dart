import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_card.dart';

class TroubleshootingScreen extends StatelessWidget {
  const TroubleshootingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Troubleshooting')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            'Common Problems & Solutions',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.md),

          _ProblemCard(
            problem: 'Cloudy Water',
            causes: [
              'Bacterial bloom (new tank or after cleaning)',
              'Overfeeding',
              'Overstocking',
              'Dead fish/plant decay',
              'Substrate not rinsed',
            ],
            solutions: [
              'Wait 24-48 hours - often clears on its own',
              'Check for dead fish or rotting plants',
              'Reduce feeding',
              'Do 25% water change',
              'Check filter is working',
              'Add activated carbon temporarily',
            ],
          ),
          _ProblemCard(
            problem: 'Green Water',
            causes: [
              'Algae bloom (phytoplankton)',
              'Excess light (especially direct sunlight)',
              'High nutrients',
            ],
            solutions: [
              'UV sterilizer (most effective)',
              'Complete blackout for 3-4 days',
              'Large water changes',
              'Block direct sunlight',
              'Reduce light period',
            ],
          ),
          _ProblemCard(
            problem: 'Fish Gasping at Surface',
            causes: [
              'Low oxygen',
              'Ammonia/nitrite spike',
              'High temperature',
              'Gill disease',
            ],
            solutions: [
              'Increase aeration immediately',
              'Test water - do water change if ammonia/nitrite present',
              'Check heater - lower temp if too high',
              'Add airstone or lower water level for splash',
              'Check for gill flukes if water params OK',
            ],
          ),
          _ProblemCard(
            problem: 'Fish Not Eating',
            causes: [
              'Stress (new fish, tankmates, water quality)',
              'Disease',
              'Wrong food type',
              'Temperature too cold',
            ],
            solutions: [
              'New fish: wait 24-48 hours, keep lights dim',
              'Check water parameters',
              'Try different food (live/frozen often entices)',
              'Check temperature',
              'Look for disease symptoms',
              'Reduce aggression from tankmates',
            ],
          ),
          _ProblemCard(
            problem: 'Fish Hiding All the Time',
            causes: [
              'Stress',
              'Bullying/aggression',
              'Inadequate hiding spots',
              'Too much light',
              'New environment',
            ],
            solutions: [
              'Add more hiding spots (plants, caves)',
              'Identify and remove aggressor',
              'Dim lights or add floating plants',
              'Give new fish time to adjust (1-2 weeks)',
              'Check water parameters',
            ],
          ),
          _ProblemCard(
            problem: 'Ammonia Won\'t Go Down',
            causes: [
              'Tank not cycled',
              'Filter crashed/cleaned too aggressively',
              'Overstocking',
              'Overfeeding',
              'Dead fish/decaying matter',
            ],
            solutions: [
              'Daily water changes (25-50%)',
              'Use Seachem Prime to detoxify',
              'Add bottled bacteria',
              'Reduce feeding',
              'Remove dead fish/plants',
              'Don\'t clean filter media - just rinse in tank water',
            ],
          ),
          _ProblemCard(
            problem: 'pH Keeps Crashing',
            causes: [
              'Low KH (no buffering capacity)',
              'Overstocking/high bioload',
              'Infrequent water changes',
              'Acidic substrate/driftwood',
            ],
            solutions: [
              'Test KH - if below 4, raise it',
              'Add crushed coral to filter',
              'More frequent water changes',
              'Baking soda (carefully) to raise KH',
              'Remove excess driftwood',
            ],
          ),
          _ProblemCard(
            problem: 'Heater Not Heating',
            causes: [
              'Heater too small for tank',
              'Thermostat failed',
              'Not fully submerged',
              'Heater broken',
            ],
            solutions: [
              'Check wattage (3-5W per gallon)',
              'Test with separate thermometer',
              'Ensure fully submerged if required',
              'Try adjusting thermostat',
              'Replace heater if old (2-3 years)',
            ],
          ),
          _ProblemCard(
            problem: 'Filter Making Noise',
            causes: [
              'Low water level',
              'Air in impeller',
              'Dirty impeller',
              'Impeller damaged',
            ],
            solutions: [
              'Top up water level',
              'Prime filter - tilt to release air',
              'Clean impeller and housing',
              'Replace impeller if damaged',
              'Check intake isn\'t clogged',
            ],
          ),
          _ProblemCard(
            problem: 'Plants Melting',
            causes: [
              'Transition from emersed to submersed',
              'Nutrient deficiency',
              'Wrong parameters (CO2, light)',
              'Damaged during shipping',
            ],
            solutions: [
              'Normal for new plants - wait for new growth',
              'Remove dead leaves',
              'Check lighting and nutrients',
              'Add root tabs for root feeders',
              'Ensure CO2 if high-light setup',
            ],
          ),
          _ProblemCard(
            problem: 'Plants Not Growing',
            causes: [
              'Insufficient light',
              'Nutrient deficiency',
              'No CO2 for demanding plants',
              'Wrong substrate',
            ],
            solutions: [
              'Check light intensity and duration (6-8 hrs)',
              'Add fertilizer (liquid + root tabs)',
              'Consider CO2 for demanding species',
              'Check if plant suits your setup',
            ],
          ),
          _ProblemCard(
            problem: 'Snail Infestation',
            causes: ['Hitchhiked on plants', 'Overfeeding'],
            solutions: [
              'Reduce feeding (less food = fewer snails)',
              'Manual removal',
              'Lettuce trap (leave overnight, remove with snails)',
              'Assassin snails eat pest snails',
              'Avoid copper treatments in planted tanks',
            ],
          ),
          _ProblemCard(
            problem: 'Fish Jumping Out',
            causes: [
              'Poor water quality',
              'Aggression',
              'Spooked',
              'Natural behavior (some species)',
            ],
            solutions: [
              'Get a lid or lower water level',
              'Check water parameters',
              'Identify aggression and separate',
              'Add more hiding spots',
              'Some fish (hatchetfish, etc.) are jumpers - always use lid',
            ],
          ),
          _ProblemCard(
            problem: 'Sudden Fish Deaths',
            causes: [
              'Ammonia/nitrite spike',
              'Temperature swing',
              'Contamination (soap, spray, etc.)',
              'Disease outbreak',
              'Old tank syndrome',
            ],
            solutions: [
              'Test water immediately',
              'Large water change with dechlorinator',
              'Check for contamination sources',
              'Quarantine remaining fish',
              'Check heater functioning',
              'Look for disease symptoms on survivors',
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          AppCard(
            backgroundColor: AppOverlays.info10,
            padding: AppCardPadding.standard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: context.textSecondary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('General Tips', style: AppTypography.headlineSmall),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm2),
                Text(
                  '• When in doubt, do a water change\n'
                  '• Test water before making changes\n'
                  '• Make changes gradually, not all at once\n'
                  '• Observe fish behavior - they tell you when something\'s wrong\n'
                  '• Keep a log to track patterns\n'
                  '• Quarantine new additions',
                  style: AppTypography.bodyMedium,
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

class _ProblemCard extends StatelessWidget {
  final String problem;
  final List<String> causes;
  final List<String> solutions;

  const _ProblemCard({
    required this.problem,
    required this.causes,
    required this.solutions,
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
            color: AppOverlays.warning10,
            borderRadius: AppRadius.smallRadius,
          ),
          child: const Icon(Icons.help_outline, color: AppColors.warning),
        ),
        title: Text(problem, style: AppTypography.labelLarge),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Possible Causes',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                ...causes.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: AppTypography.bodySmall),
                        Expanded(
                          child: Text(c, style: AppTypography.bodySmall),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm2),
                Text(
                  'Solutions',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                ...solutions.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check, size: 14, color: AppColors.success),
                        const SizedBox(width: AppSpacing.xs2),
                        Expanded(
                          child: Text(s, style: AppTypography.bodySmall),
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
