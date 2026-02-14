import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_card.dart';

class AcclimationGuideScreen extends StatelessWidget {
  const AcclimationGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fish Acclimation Guide')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
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
                    Icon(Icons.info_outline, color: AppColors.info),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Why Acclimate?',
                      style: AppTypography.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Fish are sensitive to sudden changes in water chemistry and temperature. '
                  'Proper acclimation reduces stress and prevents shock, which can be fatal.',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Method 1: Float
          Text(
            'Method 1: Float & Release',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Best for: Hardy fish, short transit times',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),

          _StepCard(
            step: 1,
            title: 'Float the bag',
            description:
                'Turn off tank lights. Float the sealed bag in your tank for 15-20 minutes to equalize temperature.',
            icon: Icons.water,
            duration: '15-20 min',
          ),
          _StepCard(
            step: 2,
            title: 'Open and add tank water',
            description:
                'Open the bag, roll down the edges to create an air pocket. Add 1/2 cup of tank water every 5 minutes.',
            icon: Icons.add,
            duration: '15-20 min',
          ),
          _StepCard(
            step: 3,
            title: 'Net and release',
            description:
                'Net the fish and release into the tank. Discard the bag water — don\'t add it to your tank.',
            icon: Icons.catching_pokemon,
            duration: '1 min',
          ),

          const SizedBox(height: AppSpacing.xl),

          // Method 2: Drip
          Text(
            'Method 2: Drip Acclimation',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Best for: Sensitive fish, shrimp, marine fish, large pH/hardness differences',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),

          _StepCard(
            step: 1,
            title: 'Float to equalize temperature',
            description: 'Float the sealed bag for 15 minutes.',
            icon: Icons.water,
            duration: '15 min',
          ),
          _StepCard(
            step: 2,
            title: 'Transfer to bucket',
            description:
                'Pour fish and bag water into a clean bucket. The water should cover the fish.',
            icon: Icons.delete_outline,
            duration: '1 min',
          ),
          _StepCard(
            step: 3,
            title: 'Set up drip line',
            description:
                'Use airline tubing with a loose knot or valve. Start a siphon from tank to bucket, dripping 2-4 drops per second.',
            icon: Icons.water_drop,
            duration: '1 min',
          ),
          _StepCard(
            step: 4,
            title: 'Drip until doubled',
            description:
                'Let water drip until the volume in the bucket has doubled. This takes about 1 hour.',
            icon: Icons.timer,
            duration: '45-60 min',
          ),
          _StepCard(
            step: 5,
            title: 'Discard half and repeat',
            description:
                'For very sensitive species (shrimp), discard half the water and repeat the drip process.',
            icon: Icons.replay,
            duration: '45-60 min',
          ),
          _StepCard(
            step: 6,
            title: 'Net and release',
            description:
                'Gently net the fish and release. Never add bucket water to your tank.',
            icon: Icons.catching_pokemon,
            duration: '1 min',
          ),

          const SizedBox(height: AppSpacing.xl),

          // Tips
          Text('Tips for Success', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),

          _TipCard(
            icon: Icons.lightbulb_outline,
            tip:
                'Keep lights off for several hours after adding new fish to reduce stress.',
          ),
          _TipCard(
            icon: Icons.no_food,
            tip:
                'Don\'t feed new fish for 24 hours — they won\'t eat while stressed.',
          ),
          _TipCard(
            icon: Icons.visibility,
            tip:
                'Watch for signs of stress: rapid breathing, hiding, color loss, erratic swimming.',
          ),
          _TipCard(
            icon: Icons.water_drop,
            tip:
                'Never add store water to your tank — it may contain diseases or parasites.',
          ),
          _TipCard(
            icon: Icons.schedule,
            tip: 'Longer acclimation is better. When in doubt, take more time.',
          ),
          _TipCard(
            icon: Icons.local_hospital,
            tip:
                'Consider a quarantine tank for new fish to prevent disease spread.',
          ),

          const SizedBox(height: AppSpacing.xl),

          // Sensitive species
          Text('Extra Care For', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),

          AppCard(
            padding: AppCardPadding.standard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SensitiveItem(
                  species: 'Shrimp',
                  note:
                      'Extremely sensitive to parameter changes. Always drip acclimate for 2+ hours.',
                ),
                const Divider(),
                _SensitiveItem(
                  species: 'Discus',
                  note:
                      'Sensitive to pH and temperature. Drip acclimate and maintain pristine water.',
                ),
                const Divider(),
                _SensitiveItem(
                  species: 'Wild-caught fish',
                  note:
                      'Often more sensitive than captive-bred. Extended drip recommended.',
                ),
                const Divider(),
                _SensitiveItem(
                  species: 'Marine fish',
                  note:
                      'Salinity and pH critical. Drip acclimate all marine species.',
                ),
                const Divider(),
                _SensitiveItem(
                  species: 'Plecos',
                  note:
                      'Can be sensitive. Float longer and acclimate slowly.',
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

class _StepCard extends StatelessWidget {
  final int step;
  final String title;
  final String description;
  final IconData icon;
  final String duration;

  const _StepCard({
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppOverlays.primary10,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$step',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title, style: AppTypography.labelLarge),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: AppRadius.smallRadius,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(duration, style: AppTypography.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(description, style: AppTypography.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final String tip;

  const _TipCard({required this.icon, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Text(tip, style: AppTypography.bodyMedium)),
          ],
        ),
      ),
    );
  }
}

class _SensitiveItem extends StatelessWidget {
  final String species;
  final String note;

  const _SensitiveItem({required this.species, required this.note});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(species, style: AppTypography.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(note, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
