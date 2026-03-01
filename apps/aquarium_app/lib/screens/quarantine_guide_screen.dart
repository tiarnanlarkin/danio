import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_card.dart';

class QuarantineGuideScreen extends StatelessWidget {
  const QuarantineGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quarantine Guide')),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          // Why quarantine
          AppCard(
            backgroundColor: AppOverlays.warning10,
            padding: AppCardPadding.standard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield, color: AppColors.warning),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Why Quarantine?',
                      style: AppTypography.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'New fish often carry diseases or parasites that may not show symptoms immediately. '
                  'Quarantine protects your existing fish from potentially devastating infections. '
                  'A single sick fish can wipe out an entire tank.',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Setup
          Text('Quarantine Tank Setup', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),

          _SetupCard(
            title: 'Tank Size',
            description:
                '10-20 gallons is ideal. Smaller for small fish, larger for big fish.',
            icon: Icons.water,
          ),
          _SetupCard(
            title: 'Filtration',
            description:
                'Sponge filter recommended - easy to move, provides biological filtration, gentle flow.',
            icon: Icons.filter_alt,
          ),
          _SetupCard(
            title: 'Heater',
            description:
                'Adjustable heater to match main tank temperature. May need higher temps for treatment.',
            icon: Icons.thermostat,
          ),
          _SetupCard(
            title: 'Decor',
            description:
                'Minimal - PVC pipes or cheap plants for hiding. Easy to sterilize between uses.',
            icon: Icons.weekend,
          ),
          _SetupCard(
            title: 'Lighting',
            description:
                'Basic light or ambient room light. Keep dim to reduce stress.',
            icon: Icons.lightbulb,
          ),
          _SetupCard(
            title: 'No Substrate',
            description:
                'Bare bottom is easier to clean and observe fish. Detritus is visible.',
            icon: Icons.layers_clear,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Protocol
          Text('Quarantine Protocol', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),

          _ProtocolStep(
            week: '1',
            title: 'Observation Week',
            tasks: [
              'Add new fish to quarantine tank',
              'Observe closely for symptoms',
              'Feed sparingly - watch for appetite',
              'Test water every 2-3 days',
              'Note any unusual behavior',
            ],
          ),
          _ProtocolStep(
            week: '2',
            title: 'Prophylactic Treatment (Optional)',
            tasks: [
              'Some hobbyists treat all new fish preventatively',
              'General anti-parasitic (PraziPro for internal parasites)',
              'Ich treatment (even if no symptoms)',
              'Continue observation',
            ],
          ),
          _ProtocolStep(
            week: '3-4',
            title: 'Continued Observation',
            tasks: [
              'Most diseases show within 2-4 weeks',
              'Fish should be eating well',
              'Colors should improve as stress decreases',
              'Activity level should be normal',
            ],
          ),
          _ProtocolStep(
            week: '4+',
            title: 'Release to Main Tank',
            tasks: [
              'If no symptoms after 4 weeks, fish is likely healthy',
              'Acclimate to main tank parameters',
              'Continue monitoring in main tank',
              'Sterilize quarantine tank for next use',
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // What to watch for
          Text('Symptoms to Watch For', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),

          AppCard(
            padding: AppCardPadding.standard,
            child: Column(
              children: [
                _SymptomRow(symptom: 'White spots', indicates: 'Ich'),
                const Divider(),
                _SymptomRow(
                  symptom: 'Gold dust coating',
                  indicates: 'Velvet',
                ),
                const Divider(),
                _SymptomRow(
                  symptom: 'Frayed/rotting fins',
                  indicates: 'Fin rot',
                ),
                const Divider(),
                _SymptomRow(
                  symptom: 'Cottony growths',
                  indicates: 'Fungal infection',
                ),
                const Divider(),
                _SymptomRow(
                  symptom: 'Flashing/scratching',
                  indicates: 'Parasites',
                ),
                const Divider(),
                _SymptomRow(
                  symptom: 'Rapid breathing',
                  indicates: 'Gill flukes, stress, ammonia',
                ),
                const Divider(),
                _SymptomRow(
                  symptom: 'Not eating',
                  indicates: 'Stress, internal parasites, illness',
                ),
                const Divider(),
                _SymptomRow(
                  symptom: 'White stringy feces',
                  indicates: 'Internal parasites',
                ),
                const Divider(),
                _SymptomRow(
                  symptom: 'Sunken belly',
                  indicates: 'Internal parasites, wasting',
                ),
                const Divider(),
                _SymptomRow(
                  symptom: 'Swollen belly',
                  indicates: 'Bloat, dropsy, parasites',
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Common medications
          Text('Common QT Medications', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),

          _MedCard(
            name: 'PraziPro / Praziquantel',
            treats: 'Internal parasites, flukes, tapeworms',
            notes: 'Safe for most fish. Invertebrate safe.',
          ),
          _MedCard(
            name: 'Ich-X / Malachite Green',
            treats: 'Ich, velvet, mild fungal',
            notes: 'Stains silicone. Not for scaleless fish at full dose.',
          ),
          _MedCard(
            name: 'Metroplex / Metronidazole',
            treats: 'Internal parasites, hexamita, hole in head',
            notes: 'Can be mixed with food for internal treatment.',
          ),
          _MedCard(
            name: 'Kanaplex / Kanamycin',
            treats: 'Bacterial infections, fin rot, popeye',
            notes: 'Broad spectrum antibiotic. Can affect filter bacteria.',
          ),
          _MedCard(
            name: 'Furan-2 / Nitrofurazone',
            treats: 'Bacterial infections, open wounds',
            notes: 'Stains water yellow. Light sensitive.',
          ),
          _MedCard(
            name: 'Aquarium Salt',
            treats: 'Mild ich, stress, nitrite poisoning',
            notes:
                'Not for scaleless fish, plants, or snails. 1 tbsp per 5 gal.',
          ),

          const SizedBox(height: AppSpacing.lg),

          // Tips
          AppCard(
            backgroundColor: AppOverlays.info10,
            padding: AppCardPadding.standard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Pro Tips', style: AppTypography.headlineSmall),
                  ],
                ),
                const SizedBox(height: 12),
                _TipItem(
                  text:
                      'Keep a cycled sponge filter in your main tank - move it to QT when needed',
                ),
                _TipItem(
                  text:
                      'Match QT temperature and pH to main tank to reduce acclimation stress',
                ),
                _TipItem(
                  text:
                      'Don\'t share nets, siphons, or equipment between QT and main tank',
                ),
                _TipItem(
                  text:
                      'Quarantine plants too - they can carry snails, parasites, and pesticides',
                ),
                _TipItem(
                  text:
                      'Take photos of fish when they arrive for comparison later',
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

class _SetupCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _SetupCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.sm2),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
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

class _ProtocolStep extends StatelessWidget {
  final String week;
  final String title;
  final List<String> tasks;

  const _ProtocolStep({
    required this.week,
    required this.title,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppOverlays.primary10,
                borderRadius: AppRadius.smallRadius,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Week', style: AppTypography.bodySmall),
                  Text(
                    week,
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  ...tasks.map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: AppTypography.bodySmall),
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
      ),
    );
  }
}

class _SymptomRow extends StatelessWidget {
  final String symptom;
  final String indicates;

  const _SymptomRow({required this.symptom, required this.indicates});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(symptom, style: AppTypography.bodyMedium)),
          Icon(Icons.arrow_forward, size: AppIconSizes.xs, color: AppColors.textHint),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              indicates,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedCard extends StatelessWidget {
  final String name;
  final String treats;
  final String notes;

  const _MedCard({
    required this.name,
    required this.treats,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.sm2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: AppTypography.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Treats: $treats',
              style: AppTypography.bodySmall.copyWith(color: AppColors.success),
            ),
            Text(notes, style: AppTypography.bodySmall),
          ],
        ),
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, size: AppIconSizes.xs, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}
