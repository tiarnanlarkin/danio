import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EquipmentGuideScreen extends StatelessWidget {
  const EquipmentGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equipment Guide')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Filters
          _EquipmentSection(
            title: 'Filtration',
            icon: Icons.filter_alt,
            items: [
              _EquipmentItem(
                name: 'Hang-On-Back (HOB) Filter',
                description:
                    'Hangs on tank rim, draws water up and returns it via waterfall.',
                pros: [
                  'Easy to maintain',
                  'Good surface agitation',
                  'Affordable',
                  'Easy to install',
                ],
                cons: [
                  'Can be noisy',
                  'Takes up back space',
                  'Limited media capacity',
                ],
                bestFor: 'Beginners, tanks up to 200L',
                maintenance:
                    'Rinse media monthly in tank water. Replace cartridges every 4-6 weeks.',
              ),
              _EquipmentItem(
                name: 'Canister Filter',
                description:
                    'External filter with large media capacity, connected via hoses.',
                pros: [
                  'High capacity',
                  'Quiet',
                  'Versatile media',
                  'Out of sight',
                ],
                cons: [
                  'Expensive',
                  'Harder to clean',
                  'Potential leaks',
                  'Learning curve',
                ],
                bestFor: 'Medium to large tanks, planted tanks',
                maintenance:
                    'Clean every 2-3 months. Check hoses and seals regularly.',
              ),
              _EquipmentItem(
                name: 'Sponge Filter',
                description:
                    'Air-driven filter using porous sponge for mechanical/biological filtration.',
                pros: [
                  'Shrimp/fry safe',
                  'Cheap',
                  'Reliable',
                  'Great biological filtration',
                ],
                cons: [
                  'Needs air pump',
                  'Not pretty',
                  'Limited mechanical filtration',
                ],
                bestFor: 'Breeding tanks, shrimp tanks, hospital tanks',
                maintenance: 'Squeeze sponge in old tank water monthly.',
              ),
              _EquipmentItem(
                name: 'Internal Filter',
                description: 'Submersible filter that sits inside the tank.',
                pros: [
                  'Compact',
                  'Good for small tanks',
                  'No external equipment',
                ],
                cons: ['Takes tank space', 'Small media capacity', 'Visible'],
                bestFor: 'Small tanks, quarantine setups',
                maintenance: 'Rinse media every 2-4 weeks.',
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Heating
          _EquipmentSection(
            title: 'Heating',
            icon: Icons.thermostat,
            items: [
              _EquipmentItem(
                name: 'Submersible Heater',
                description:
                    'Glass or titanium heater that sits fully underwater.',
                pros: ['Efficient', 'Accurate', 'Widely available'],
                cons: ['Can fail (stuck on)', 'Glass can break', 'Visible'],
                bestFor: 'Most tropical tanks',
                maintenance:
                    'Check temperature regularly. Replace every 2-3 years.',
              ),
              _EquipmentItem(
                name: 'Inline Heater',
                description:
                    'Installs in canister filter hose, heats water externally.',
                pros: ['Hidden', 'Safe for fish', 'Even heating'],
                cons: ['Expensive', 'Requires canister filter'],
                bestFor: 'Planted tanks, display tanks',
                maintenance:
                    'Check connections. Monitor with separate thermometer.',
              ),
              _EquipmentItem(
                name: 'Heating Mat',
                description:
                    'Goes under the tank to provide gentle heat from below.',
                pros: [
                  'Safe',
                  'Good for planted tanks',
                  'Promotes root growth',
                ],
                cons: ['Weak heating power', 'Can\'t adjust mid-cycle'],
                bestFor: 'Planted tanks, small tanks',
                maintenance: 'Minimal — check functionality occasionally.',
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Lighting
          _EquipmentSection(
            title: 'Lighting',
            icon: Icons.wb_sunny,
            items: [
              _EquipmentItem(
                name: 'LED Light',
                description:
                    'Energy-efficient lighting, often with adjustable spectrum/intensity.',
                pros: [
                  'Low energy',
                  'Long-lasting',
                  'Cool running',
                  'Customizable',
                ],
                cons: [
                  'Upfront cost',
                  'Some lack intensity for demanding plants',
                ],
                bestFor: 'All tanks, planted tanks',
                maintenance: 'Wipe dust monthly. Replace after 3-5 years.',
              ),
              _EquipmentItem(
                name: 'T5/T8 Fluorescent',
                description:
                    'Tube lights, once the standard for planted tanks.',
                pros: ['Even coverage', 'Good spectrum', 'Proven for plants'],
                cons: [
                  'Bulbs need replacement yearly',
                  'Less efficient than LED',
                ],
                bestFor: 'Planted tanks (legacy setups)',
                maintenance: 'Replace bulbs every 6-12 months.',
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Aeration
          _EquipmentSection(
            title: 'Aeration',
            icon: Icons.bubble_chart,
            items: [
              _EquipmentItem(
                name: 'Air Pump + Airstone',
                description:
                    'Pumps air through a stone to create bubbles, increasing oxygen.',
                pros: ['Increases oxygen', 'Adds movement', 'Affordable'],
                cons: ['Noisy', 'Drives off CO2', 'Aesthetic preference'],
                bestFor: 'Heavily stocked tanks, warm water, night use',
                maintenance:
                    'Replace airstone when clogged. Check tubing annually.',
              ),
              _EquipmentItem(
                name: 'Wavemaker/Powerhead',
                description:
                    'Creates water movement without surface disruption.',
                pros: ['Good flow', 'No CO2 loss', 'Prevents dead spots'],
                cons: ['Can stress slow swimmers', 'Uses electricity'],
                bestFor: 'Planted tanks, reef tanks',
                maintenance: 'Clean impeller monthly.',
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // CO2
          _EquipmentSection(
            title: 'CO2 Systems',
            icon: Icons.eco,
            items: [
              _EquipmentItem(
                name: 'Pressurized CO2',
                description:
                    'Regulated CO2 from a cylinder, most precise method.',
                pros: ['Consistent', 'Adjustable', 'Long-lasting'],
                cons: [
                  'Expensive setup',
                  'Learning curve',
                  'Requires monitoring',
                ],
                bestFor: 'Serious planted tanks',
                maintenance:
                    'Check regulator, tubing, diffuser monthly. Refill cylinder as needed.',
              ),
              _EquipmentItem(
                name: 'DIY CO2 (Citric Acid/Yeast)',
                description:
                    'Budget CO2 using chemical or biological reaction.',
                pros: ['Cheap', 'Good starter', 'No special equipment'],
                cons: [
                  'Inconsistent',
                  'Requires frequent refills',
                  'Risk of dumping',
                ],
                bestFor: 'Budget planted tanks, testing if CO2 helps',
                maintenance: 'Refill mixture every 2-4 weeks.',
              ),
              _EquipmentItem(
                name: 'Liquid Carbon (Excel)',
                description: 'Glutaraldehyde-based liquid CO2 supplement.',
                pros: ['Easy', 'Algae control', 'No equipment'],
                cons: [
                  'Less effective than gas',
                  'Daily dosing',
                  'Can kill some plants',
                ],
                bestFor: 'Low-tech planted tanks',
                maintenance: 'Daily dosing required.',
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Testing
          _EquipmentSection(
            title: 'Testing',
            icon: Icons.science,
            items: [
              _EquipmentItem(
                name: 'Liquid Test Kit',
                description: 'Reagent-based tests for precise readings.',
                pros: ['Accurate', 'Economical long-term', 'Multiple tests'],
                cons: ['Time-consuming', 'Learning curve'],
                bestFor: 'Regular testing, cycling',
                maintenance: 'Store properly. Check expiration dates.',
              ),
              _EquipmentItem(
                name: 'Test Strips',
                description:
                    'Quick dip-and-read strips for multiple parameters.',
                pros: ['Fast', 'Easy', 'Convenient'],
                cons: [
                  'Less accurate',
                  'Expensive per test',
                  'Can be hard to read',
                ],
                bestFor: 'Quick checks, beginners',
                maintenance: 'Store in dry place. Use before expiration.',
              ),
              _EquipmentItem(
                name: 'Digital Meters',
                description: 'Electronic probes for pH, TDS, temperature.',
                pros: [
                  'Instant readings',
                  'Reusable',
                  'Accurate when calibrated',
                ],
                cons: ['Requires calibration', 'Battery/probe replacement'],
                bestFor: 'Frequent testing, sensitive setups',
                maintenance: 'Calibrate monthly. Store probes properly.',
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _EquipmentSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_EquipmentItem> items;

  const _EquipmentSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(title, style: AppTypography.headlineMedium),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _EquipmentCard(item: item)),
      ],
    );
  }
}

class _EquipmentItem {
  final String name;
  final String description;
  final List<String> pros;
  final List<String> cons;
  final String bestFor;
  final String maintenance;

  const _EquipmentItem({
    required this.name,
    required this.description,
    required this.pros,
    required this.cons,
    required this.bestFor,
    required this.maintenance,
  });
}

class _EquipmentCard extends StatelessWidget {
  final _EquipmentItem item;

  const _EquipmentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(item.name, style: AppTypography.labelLarge),
        subtitle: Text(item.description, style: AppTypography.bodySmall),
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
                          ...item.pros.map(
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
                          ...item.cons.map(
                            (c) => Text('• $c', style: AppTypography.bodySmall),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: AppRadius.smallRadius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Best for: ${item.bestFor}',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Maintenance: ${item.maintenance}',
                        style: AppTypography.bodySmall,
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
