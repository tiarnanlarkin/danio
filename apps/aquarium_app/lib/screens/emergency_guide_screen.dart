import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_card.dart';

class EmergencyGuideScreen extends StatelessWidget {
  const EmergencyGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Guide'),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            backgroundColor: AppOverlays.error10,
            padding: AppCardPadding.standard,
            child: Row(
              children: [
                Icon(Icons.emergency, size: 32, color: AppColors.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Quick reference for urgent aquarium situations. When in doubt: large water change.',
                    style: AppTypography.bodyMedium,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          _EmergencyCard(
            title: '🚨 Ammonia/Nitrite Spike',
            urgency: 'CRITICAL',
            symptoms: 'Fish gasping, lethargy, red gills, deaths',
            immediateActions: [
              'Large water change NOW (50-75%)',
              'Add Seachem Prime (2-5x dose) to detoxify',
              'Add airstone for oxygen',
              'Stop feeding',
              'Don\'t clean filter',
            ],
            followUp:
                'Daily 25-50% water changes until 0. Add bottled bacteria.',
          ),

          _EmergencyCard(
            title: '🌡️ Heater Malfunction (Too Hot)',
            urgency: 'CRITICAL',
            symptoms: 'Fish gasping at surface, erratic swimming, temp >32°C',
            immediateActions: [
              'Unplug heater immediately',
              'Float frozen water bottles (sealed) in tank',
              'Increase aeration (warm water holds less O2)',
              'Remove lid for evaporative cooling',
              'Partial cool water change (match within 3-4°C)',
            ],
            followUp: 'Replace heater. Lower temp gradually (max 2°C/hour).',
          ),

          _EmergencyCard(
            title: '❄️ Heater Failure (Too Cold)',
            urgency: 'HIGH',
            symptoms: 'Lethargic fish, not eating, huddling, temp <20°C',
            immediateActions: [
              'Check heater is plugged in and set correctly',
              'Wrap tank in blankets for insulation',
              'Float sealed containers of warm water',
              'Use spare heater if available',
            ],
            followUp: 'Raise temp gradually (max 2°C/hour). Replace heater.',
          ),

          _EmergencyCard(
            title: '⚡ Power Outage',
            urgency: 'MODERATE-HIGH',
            symptoms: 'No filter, heater, or lights',
            immediateActions: [
              'Wrap tank in blankets to retain heat',
              'Don\'t feed (no filtration = ammonia builds up)',
              'Manually aerate: pour water back and forth between buckets',
              'Battery-powered air pump if available',
              'Keep filter media wet (put in tank water)',
            ],
            followUp:
                'When power returns: restart slowly, test water, small water change.',
          ),

          _EmergencyCard(
            title: '🧪 Chemical Contamination',
            urgency: 'CRITICAL',
            symptoms: 'Sudden deaths, fish acting erratically, unusual smell',
            immediateActions: [
              'Massive water change (75-90%)',
              'Add fresh activated carbon to filter',
              'Heavy dechlorinator dose',
              'Identify source (cleaning products, sprays, hands)',
            ],
            followUp:
                'Multiple large water changes over next 24 hours. Consider complete restart if severe.',
          ),

          _EmergencyCard(
            title: '💧 Tank Leak',
            urgency: 'HIGH',
            symptoms: 'Water on floor, dropping water level',
            immediateActions: [
              'Place towels around tank',
              'Prepare emergency container (bucket, bin, spare tank)',
              'Transfer fish if leak is severe',
              'Lower water level below leak if possible',
              'Unplug equipment before water reaches outlets',
            ],
            followUp:
                'Small crack: may be repairable with aquarium silicone when empty. Large crack: new tank needed.',
          ),

          _EmergencyCard(
            title: '🦠 Disease Outbreak',
            urgency: 'HIGH',
            symptoms: 'Multiple fish showing symptoms, rapid spread',
            immediateActions: [
              'Identify disease if possible',
              'Isolate severely affected fish',
              'Large water change (50%)',
              'Raise temperature slightly (speeds up ich lifecycle)',
              'Add appropriate medication',
            ],
            followUp:
                'Complete full treatment course. Quarantine new additions in future.',
          ),

          _EmergencyCard(
            title: '🐟 Fish Jumped Out',
            urgency: 'TIME-SENSITIVE',
            symptoms: 'Fish on floor, possibly still alive',
            immediateActions: [
              'Wet hands before handling',
              'Gently return to tank',
              'Even if appears dead, try — they can survive longer than you think',
              'Add stress coat/slime coat product',
              'Dim lights, provide hiding spots',
            ],
            followUp: 'Get a lid! Monitor fish for infections at wound sites.',
          ),

          _EmergencyCard(
            title: '🌊 Chlorine Accident',
            urgency: 'CRITICAL',
            symptoms:
                'Fish gasping, erratic behavior immediately after water change',
            immediateActions: [
              'Add dechlorinator immediately (double dose)',
              'Add another dose of Prime or similar',
              'Increase aeration',
              'If severe: 50% water change with treated water',
            ],
            followUp:
                'Always add dechlorinator BEFORE adding fish or to water BEFORE adding to tank.',
          ),

          _EmergencyCard(
            title: '☠️ Mass Fish Death',
            urgency: 'CRITICAL',
            symptoms: 'Multiple fish dead or dying rapidly',
            immediateActions: [
              'Remove dead fish immediately',
              'Test water (ammonia, nitrite, pH, temp)',
              'Large water change (50%+)',
              'Check for contamination sources',
              'Check heater and filter functioning',
              'Move survivors to quarantine if possible',
            ],
            followUp:
                'Investigate cause before adding new fish. May need to restart cycle.',
          ),

          const SizedBox(height: AppSpacing.lg),

          AppCard(
            padding: AppCardPadding.standard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency Kit Checklist',
                  style: AppTypography.headlineSmall,
                ),
                const SizedBox(height: 12),
                _CheckItem(
                  text: 'Extra dechlorinator (Seachem Prime recommended)',
                ),
                _CheckItem(text: 'Spare heater'),
                _CheckItem(text: 'Battery-powered air pump'),
                _CheckItem(text: 'Hospital/quarantine tank'),
                _CheckItem(
                  text: 'Basic medications (ich treatment, antibacterial)',
                ),
                _CheckItem(text: 'Activated carbon'),
                _CheckItem(text: 'Clean buckets'),
                _CheckItem(text: 'Test kit'),
                _CheckItem(text: 'Aquarium salt'),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  final String title;
  final String urgency;
  final String symptoms;
  final List<String> immediateActions;
  final String followUp;

  const _EmergencyCard({
    required this.title,
    required this.urgency,
    required this.symptoms,
    required this.immediateActions,
    required this.followUp,
  });

  Color get _urgencyColor {
    switch (urgency) {
      case 'CRITICAL':
        return AppColors.error;
      case 'HIGH':
        return AppColors.warning;
      default:
        return AppColors.paramWarning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _urgencyColor,
            borderRadius: AppRadius.xsRadius,
          ),
          child: Text(
            urgency,
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ),
        title: Text(title, style: AppTypography.labelLarge),
        subtitle: Text(
          'Symptoms: $symptoms',
          style: AppTypography.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Symptoms:', style: AppTypography.labelLarge),
                Text(symptoms, style: AppTypography.bodySmall),
                const SizedBox(height: 12),
                Text(
                  'IMMEDIATE ACTIONS:',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                ...immediateActions.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppOverlays.error10,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${e.key + 1}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.error,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(e.value, style: AppTypography.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppOverlays.info10,
                    borderRadius: AppRadius.smallRadius,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.update, size: 16, color: AppColors.info),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Follow-up: $followUp',
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

class _CheckItem extends StatelessWidget {
  final String text;

  const _CheckItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            Icons.check_box_outline_blank,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }
}
