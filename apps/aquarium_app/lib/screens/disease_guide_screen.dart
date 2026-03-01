import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DiseaseGuideScreen extends StatefulWidget {
  const DiseaseGuideScreen({super.key});

  @override
  State<DiseaseGuideScreen> createState() => _DiseaseGuideScreenState();
}

class _DiseaseGuideScreenState extends State<DiseaseGuideScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final diseases = _allDiseases
        .where(
          (d) =>
              d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              d.symptoms.any(
                (s) => s.toLowerCase().contains(_searchQuery.toLowerCase()),
              ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Fish Disease Guide')),
      body: Column(
        children: [
          // Search
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by disease or symptom...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.mediumRadius,
                ),
                filled: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // Disclaimer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              color: AppOverlays.warning10,
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.sm2),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: AppColors.warning,
                      size: AppIconSizes.sm,
                    ),
                    const SizedBox(width: AppSpacing.sm2),
                    Expanded(
                      child: Text(
                        'This guide is for reference only. Consult an aquatic vet for serious cases.',
                        style: AppTypography.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(AppSpacing.md),
              itemCount: diseases.length,
              itemBuilder: (ctx, i) => _DiseaseCard(disease: diseases[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiseaseCard extends StatelessWidget {
  final _Disease disease;

  const _DiseaseCard({required this.disease});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: disease.severityColor.withAlpha(26),
            borderRadius: AppRadius.smallRadius,
          ),
          child: Icon(disease.icon, color: disease.severityColor, size: 24),
        ),
        title: Text(disease.name, style: AppTypography.labelLarge),
        subtitle: Text(disease.cause, style: AppTypography.bodySmall),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Severity
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: disease.severityColor,
                        borderRadius: AppRadius.smallRadius,
                      ),
                      child: Text(
                        disease.severity,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      disease.contagious ? '⚠️ Contagious' : '✓ Not contagious',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Symptoms
                Text('Symptoms', style: AppTypography.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: disease.symptoms
                      .map(
                        (s) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: AppRadius.mediumRadius,
                          ),
                          child: Text(s, style: AppTypography.bodySmall),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: AppSpacing.md),

                // Treatment
                Text('Treatment', style: AppTypography.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                ...disease.treatments.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: AppIconSizes.xs,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(t, style: AppTypography.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Prevention
                Text('Prevention', style: AppTypography.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                ...disease.prevention.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: AppTypography.bodySmall),
                        Expanded(
                          child: Text(p, style: AppTypography.bodySmall),
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

class _Disease {
  final String name;
  final String cause;
  final String severity;
  final Color severityColor;
  final bool contagious;
  final IconData icon;
  final List<String> symptoms;
  final List<String> treatments;
  final List<String> prevention;

  const _Disease({
    required this.name,
    required this.cause,
    required this.severity,
    required this.severityColor,
    required this.contagious,
    required this.icon,
    required this.symptoms,
    required this.treatments,
    required this.prevention,
  });
}

final _allDiseases = [
  _Disease(
    name: 'Ich (White Spot Disease)',
    cause: 'Parasite (Ichthyophthirius multifiliis)',
    severity: 'Moderate',
    severityColor: AppColors.warning,
    contagious: true,
    icon: Icons.blur_on,
    symptoms: [
      'White spots like salt grains',
      'Flashing/rubbing on objects',
      'Clamped fins',
      'Lethargy',
      'Loss of appetite',
    ],
    treatments: [
      'Raise temperature to 28-30°C gradually (speeds up parasite lifecycle)',
      'Add aquarium salt (1 tsp per gallon)',
      'Use ich medication (malachite green, formalin)',
      'Treat entire tank for 10-14 days',
      'Increase aeration (warm water holds less oxygen)',
    ],
    prevention: [
      'Quarantine new fish',
      'Avoid temperature swings',
      'Maintain good water quality',
      'Don\'t stress fish',
    ],
  ),
  _Disease(
    name: 'Fin Rot',
    cause: 'Bacterial infection (often secondary)',
    severity: 'Moderate',
    severityColor: AppColors.warning,
    contagious: false,
    icon: Icons.cut,
    symptoms: [
      'Ragged, frayed fins',
      'White edges on fins',
      'Fins shortening',
      'Redness at fin base',
      'Lethargy',
    ],
    treatments: [
      'Improve water quality immediately (water changes)',
      'Add aquarium salt (1 tsp per gallon)',
      'For severe cases: antibacterial medication (API Fin & Body Cure)',
      'Isolate affected fish if possible',
      'Clean fin damage with diluted betadine (advanced)',
    ],
    prevention: [
      'Regular water changes',
      'Don\'t overstock',
      'Avoid fin-nipping tankmates',
      'Good filtration',
    ],
  ),
  _Disease(
    name: 'Dropsy',
    cause: 'Organ failure / bacterial infection',
    severity: 'Severe',
    severityColor: AppColors.error,
    contagious: false,
    icon: Icons.warning,
    symptoms: [
      'Swollen belly',
      'Pinecone-like raised scales',
      'Bulging eyes',
      'Lethargy',
      'Loss of appetite',
    ],
    treatments: [
      'Often fatal by the time symptoms appear',
      'Isolate immediately',
      'Epsom salt baths (1 tbsp per gallon)',
      'Antibiotics (kanamycin) for bacterial cause',
      'Keep water pristine',
      'Euthanasia may be kindest option',
    ],
    prevention: [
      'Maintain excellent water quality',
      'Balanced diet',
      'Reduce stress',
      'Regular observation',
    ],
  ),
  _Disease(
    name: 'Velvet (Gold Dust Disease)',
    cause: 'Parasite (Oodinium)',
    severity: 'Severe',
    severityColor: AppColors.error,
    contagious: true,
    icon: Icons.auto_awesome,
    symptoms: [
      'Gold/rust dust coating',
      'Flashing/scratching',
      'Rapid breathing',
      'Clamped fins',
      'Lethargy',
    ],
    treatments: [
      'Dim lights or cover tank (parasite needs light)',
      'Raise temperature to 28-30°C',
      'Copper-based medication (toxic to invertebrates!)',
      'Treat for 2 weeks minimum',
      'Increase aeration',
    ],
    prevention: [
      'Quarantine new fish',
      'Stable temperature',
      'Low stress',
      'Good water quality',
    ],
  ),
  _Disease(
    name: 'Swim Bladder Disorder',
    cause: 'Overfeeding, constipation, infection, or genetics',
    severity: 'Mild-Moderate',
    severityColor: AppColors.paramWarning,
    contagious: false,
    icon: Icons.swap_vert,
    symptoms: [
      'Floating upside down',
      'Sinking to bottom',
      'Swimming sideways',
      'Difficulty maintaining position',
      'Bloated belly',
    ],
    treatments: [
      'Fast for 2-3 days',
      'Feed blanched, deshelled pea (fiber helps constipation)',
      'Epsom salt bath (1 tbsp per gallon for 15 mins)',
      'Lower water level to reduce effort',
      'If bacterial: antibiotics',
    ],
    prevention: [
      'Don\'t overfeed',
      'Soak pellets before feeding',
      'Varied diet',
      'Avoid low-quality food',
    ],
  ),
  _Disease(
    name: 'Columnaris (Mouth Fungus)',
    cause: 'Bacteria (Flavobacterium columnare)',
    severity: 'Severe',
    severityColor: AppColors.error,
    contagious: true,
    icon: Icons.coronavirus,
    symptoms: [
      'White/grey patches (mouth, body, fins)',
      'Cottony growths',
      'Fin erosion',
      'Saddle-shaped lesions',
      'Rapid death',
    ],
    treatments: [
      'Lower temperature (slows bacteria)',
      'Salt treatment (1 tbsp per 5 gallons)',
      'Antibiotics (kanamycin, furan-2)',
      'Treat early - progresses fast',
      'Remove carbon filtration during treatment',
    ],
    prevention: [
      'Quarantine new fish',
      'Avoid overcrowding',
      'Good oxygenation',
      'Handle fish gently',
    ],
  ),
  _Disease(
    name: 'Fungal Infection',
    cause: 'Fungi (Saprolegnia, etc.)',
    severity: 'Moderate',
    severityColor: AppColors.warning,
    contagious: false,
    icon: Icons.cloud,
    symptoms: [
      'Cottony white growths',
      'Usually on wounds/damaged areas',
      'May spread if untreated',
    ],
    treatments: [
      'Improve water quality',
      'Salt bath (1 tbsp per gallon)',
      'Antifungal medication (methylene blue, Pimafix)',
      'Treat underlying injury',
      'Remove any dead/dying tissue',
    ],
    prevention: [
      'Avoid injuries',
      'Remove sharp decorations',
      'Good water quality',
      'Don\'t overcrowd',
    ],
  ),
  _Disease(
    name: 'Popeye (Exophthalmia)',
    cause: 'Injury, infection, or poor water quality',
    severity: 'Moderate',
    severityColor: AppColors.warning,
    contagious: false,
    icon: Icons.visibility,
    symptoms: [
      'One or both eyes bulging',
      'Cloudy eyes',
      'Eye may appear to "pop"',
    ],
    treatments: [
      'If one eye: likely injury - clean water and time',
      'If both eyes: likely infection or water quality',
      'Improve water quality immediately',
      'Epsom salt (1 tbsp per 5 gallons)',
      'Antibiotics for bacterial infection',
    ],
    prevention: [
      'Stable water parameters',
      'Avoid sharp decorations',
      'Regular water changes',
    ],
  ),
  _Disease(
    name: 'Anchor Worms',
    cause: 'Parasitic copepod (Lernaea)',
    severity: 'Moderate',
    severityColor: AppColors.warning,
    contagious: true,
    icon: Icons.pest_control,
    symptoms: [
      'Visible worm-like protrusions',
      'Redness/inflammation at attachment',
      'Scratching on objects',
      'Ulcers',
    ],
    treatments: [
      'Remove visible worms with tweezers (carefully!)',
      'Treat wound with antiseptic',
      'Medication: Dimilin, potassium permanganate',
      'Treat whole tank (eggs in water)',
    ],
    prevention: [
      'Quarantine new fish',
      'Inspect fish before adding',
      'Don\'t add wild-caught plants without treatment',
    ],
  ),
  _Disease(
    name: 'Hole in the Head (HITH)',
    cause: 'Flagellate parasites + poor nutrition/water',
    severity: 'Moderate-Severe',
    severityColor: AppColors.warning,
    contagious: false,
    icon: Icons.radio_button_unchecked,
    symptoms: [
      'Pits/holes in head',
      'White stringy feces',
      'Loss of appetite',
      'Color fading',
      'Common in cichlids',
    ],
    treatments: [
      'Improve water quality (major factor)',
      'Metronidazole treatment',
      'Improve diet (vitamin-enriched foods)',
      'Reduce stress',
      'Can heal if caught early',
    ],
    prevention: [
      'Varied, vitamin-rich diet',
      'Excellent water quality',
      'Low stress',
      'Proper tank size',
    ],
  ),
];
