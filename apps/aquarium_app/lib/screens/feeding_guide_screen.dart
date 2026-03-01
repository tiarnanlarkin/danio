import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_card.dart';

class FeedingGuideScreen extends StatelessWidget {
  const FeedingGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feeding Guide')),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _buildItems().length,
        itemBuilder: (context, index) => _buildItems()[index],
      ),
    );
  }

  List<Widget> _buildItems() {
    return [
          // Golden rule
          AppCard(
            backgroundColor: AppOverlays.warning10,
            padding: AppCardPadding.standard,
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: AppColors.warning),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'The Golden Rule',
                      style: AppTypography.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Feed only what fish can consume in 2-3 minutes. '
                  'Overfeeding is the #1 cause of poor water quality in aquariums.',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Frequency
          Text('How Often to Feed', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),

          _FrequencyCard(
            fishType: 'Adult tropical fish',
            frequency: '1-2× daily',
            notes: 'Most fish do fine with once daily feeding',
          ),
          _FrequencyCard(
            fishType: 'Fry/juveniles',
            frequency: '3-4× daily',
            notes: 'Small frequent meals for growing fish',
          ),
          _FrequencyCard(
            fishType: 'Bettas',
            frequency: '1-2× daily',
            notes: 'Skip 1 day per week to prevent bloat',
          ),
          _FrequencyCard(
            fishType: 'Corydoras/bottom feeders',
            frequency: '1× daily (evening)',
            notes: 'Feed sinking pellets after lights out',
          ),
          _FrequencyCard(
            fishType: 'Plecos',
            frequency: 'Every 2-3 days',
            notes: 'Algae wafers or vegetables at night',
          ),
          _FrequencyCard(
            fishType: 'Shrimp',
            frequency: 'Every 2-3 days',
            notes: 'They graze on biofilm between feedings',
          ),

          const SizedBox(height: AppSpacing.lg),

          // Food types
          Text('Food Types', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),

          _FoodTypeCard(
            name: 'Flakes',
            icon: Icons.layers,
            suitableFor: 'Surface and mid-water feeders',
            pros: ['Convenient', 'Variety of formulas', 'Most fish accept'],
            cons: [
              'Degrades water quality quickly',
              'Loses nutrients over time',
            ],
            tips: 'Crush for smaller fish. Remove uneaten flakes.',
          ),
          _FoodTypeCard(
            name: 'Pellets',
            icon: Icons.circle,
            suitableFor: 'Most tropical fish',
            pros: ['Less messy', 'Holds nutrients better', 'Portion control'],
            cons: ['Some fish won\'t accept', 'Can expand in stomach'],
            tips: 'Soak briefly before feeding to prevent bloat.',
          ),
          _FoodTypeCard(
            name: 'Frozen Foods',
            icon: Icons.ac_unit,
            suitableFor: 'Carnivores, picky eaters',
            pros: ['High protein', 'Entices fussy fish', 'Good variety'],
            cons: ['Requires freezer', 'Can cloud water', 'More expensive'],
            tips: 'Thaw in tank water, drain liquid before feeding.',
          ),
          _FoodTypeCard(
            name: 'Live Foods',
            icon: Icons.bug_report,
            suitableFor: 'Carnivores, breeding conditioning',
            pros: [
              'Natural hunting behavior',
              'Highly nutritious',
              'Great for fry',
            ],
            cons: ['Disease risk', 'Requires culturing', 'Expensive'],
            tips: 'Quarantine or culture your own for safety.',
          ),
          _FoodTypeCard(
            name: 'Vegetables',
            icon: Icons.eco,
            suitableFor: 'Herbivores, plecos, snails',
            pros: ['Cheap', 'Natural fiber', 'Good variety'],
            cons: ['Can cloud water', 'Remove uneaten portions'],
            tips: 'Blanch zucchini, cucumber, or peas. Remove after 24h.',
          ),
          _FoodTypeCard(
            name: 'Algae Wafers',
            icon: Icons.grass,
            suitableFor: 'Plecos, snails, shrimp, otos',
            pros: ['Sinks quickly', 'Long-lasting', 'Complete nutrition'],
            cons: ['Other fish may steal', 'Can break apart'],
            tips: 'Drop in after lights out for nocturnal feeders.',
          ),

          const SizedBox(height: AppSpacing.lg),

          // Common mistakes
          Text('Common Mistakes', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),

          AppCard(
            padding: AppCardPadding.standard,
            child: Column(
              children: [
                _MistakeItem(
                  mistake: 'Overfeeding',
                  consequence: 'Ammonia spikes, algae blooms, obese fish',
                  fix: 'Feed less, skip a day weekly, remove uneaten food',
                ),
                const Divider(),
                _MistakeItem(
                  mistake: 'Only one food type',
                  consequence: 'Nutritional deficiencies',
                  fix: 'Rotate between 2-3 different foods',
                ),
                const Divider(),
                _MistakeItem(
                  mistake: 'Ignoring bottom feeders',
                  consequence: 'Starvation, aggression',
                  fix: 'Provide sinking foods specifically for them',
                ),
                const Divider(),
                _MistakeItem(
                  mistake: 'Feeding right after lights on',
                  consequence: 'Fish may not be active/hungry',
                  fix: 'Wait 30 mins after lights on',
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Fasting
          AppCard(
            backgroundColor: AppOverlays.info10,
            padding: AppCardPadding.standard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.no_food, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Fasting Days', style: AppTypography.headlineSmall),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Skipping 1-2 feeding days per week is actually beneficial:',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '• Gives digestive system a rest',
                  style: AppTypography.bodySmall,
                ),
                Text(
                  '• Helps prevent bloat (especially bettas)',
                  style: AppTypography.bodySmall,
                ),
                Text(
                  '• Encourages scavenging behavior',
                  style: AppTypography.bodySmall,
                ),
                Text(
                  '• Fish can go 1-2 weeks without food if needed',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
    ];
  }
}

class _FrequencyCard extends StatelessWidget {
  final String fishType;
  final String frequency;
  final String notes;

  const _FrequencyCard({
    required this.fishType,
    required this.frequency,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(fishType, style: AppTypography.labelLarge),
        subtitle: Text(notes, style: AppTypography.bodySmall),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppOverlays.primary10,
            borderRadius: AppRadius.mediumRadius,
          ),
          child: Text(
            frequency,
            style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _FoodTypeCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final String suitableFor;
  final List<String> pros;
  final List<String> cons;
  final String tips;

  const _FoodTypeCard({
    required this.name,
    required this.icon,
    required this.suitableFor,
    required this.pros,
    required this.cons,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(name, style: AppTypography.labelLarge),
        subtitle: Text(suitableFor, style: AppTypography.bodySmall),
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
                              fontSize: 13,
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
                              fontSize: 13,
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
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: AppRadius.smallRadius,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: AppIconSizes.xs,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(tips, style: AppTypography.bodySmall),
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

class _MistakeItem extends StatelessWidget {
  final String mistake;
  final String consequence;
  final String fix;

  const _MistakeItem({
    required this.mistake,
    required this.consequence,
    required this.fix,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.close, size: AppIconSizes.xs, color: AppColors.error),
              const SizedBox(width: AppSpacing.sm),
              Text(mistake, style: AppTypography.labelLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '→ $consequence',
            style: AppTypography.bodySmall.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '✓ $fix',
            style: AppTypography.bodySmall.copyWith(color: AppColors.success),
          ),
        ],
      ),
    );
  }
}
