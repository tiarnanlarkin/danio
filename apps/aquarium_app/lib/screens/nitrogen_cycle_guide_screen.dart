import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NitrogenCycleGuideScreen extends StatelessWidget {
  const NitrogenCycleGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nitrogen Cycle Guide')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro
            Card(
              color: AppColors.info.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: AppColors.info),
                        const SizedBox(width: 8),
                        Text('What is the Nitrogen Cycle?', 
                          style: AppTypography.headlineSmall.copyWith(color: AppColors.info)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The nitrogen cycle is the process by which beneficial bacteria convert toxic fish waste (ammonia) into less harmful substances. '
                      'A "cycled" tank has enough bacteria to process all the ammonia your fish produce.',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // The cycle stages
            Text('The Cycle', style: AppTypography.headlineMedium),
            const SizedBox(height: 16),

            _CycleStage(
              number: 1,
              title: 'Ammonia (NH₃)',
              subtitle: 'Toxic — burns gills, causes stress',
              description: 'Fish waste, uneaten food, and decaying plants produce ammonia. '
                  'Even small amounts (0.25 ppm+) are harmful.',
              color: AppColors.error,
              icon: Icons.warning,
            ),

            _CycleArrow(),

            _CycleStage(
              number: 2,
              title: 'Nitrite (NO₂)',
              subtitle: 'Toxic — prevents oxygen absorption',
              description: 'Nitrosomonas bacteria convert ammonia to nitrite. '
                  'Still toxic but shows the cycle is progressing.',
              color: AppColors.warning,
              icon: Icons.science,
            ),

            _CycleArrow(),

            _CycleStage(
              number: 3,
              title: 'Nitrate (NO₃)',
              subtitle: 'Safe in low amounts — removed by water changes',
              description: 'Nitrobacter bacteria convert nitrite to nitrate. '
                  'Nitrate is much less toxic and removed during water changes.',
              color: AppColors.success,
              icon: Icons.check_circle,
            ),

            const SizedBox(height: 32),

            // How to cycle
            Text('How to Cycle Your Tank', style: AppTypography.headlineMedium),
            const SizedBox(height: 16),

            _MethodCard(
              title: 'Fishless Cycling (Recommended)',
              duration: '4-8 weeks',
              steps: [
                'Set up tank with filter, heater, and substrate',
                'Add ammonia source (fish food or pure ammonia)',
                'Dose to 2-4 ppm ammonia',
                'Test every 2-3 days',
                'Wait for ammonia and nitrite to reach 0',
                'Do a large water change before adding fish',
              ],
              pros: ['No fish harmed', 'More reliable'],
              cons: ['Takes patience', 'Need ammonia source'],
            ),

            const SizedBox(height: 16),

            _MethodCard(
              title: 'Fish-In Cycling',
              duration: '6-8 weeks',
              steps: [
                'Add 1-2 hardy fish (not recommended)',
                'Test water daily',
                'Do 25-50% water changes when ammonia/nitrite detected',
                'Use water conditioner like Seachem Prime',
                'Add fish slowly over several weeks',
              ],
              pros: ['Fish from day one'],
              cons: ['Stressful for fish', 'Requires daily monitoring', 'Fish may die'],
            ),

            const SizedBox(height: 32),

            // Signs of completion
            Text('Signs Your Tank is Cycled', style: AppTypography.headlineMedium),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _CheckItem(text: 'Ammonia reads 0 ppm'),
                    _CheckItem(text: 'Nitrite reads 0 ppm'),
                    _CheckItem(text: 'Nitrate is present (5-40 ppm)'),
                    _CheckItem(text: 'Tank can process 2 ppm ammonia in 24 hours'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Tips
            Text('Tips for Success', style: AppTypography.headlineMedium),
            const SizedBox(height: 16),

            _TipCard(
              icon: Icons.thermostat,
              tip: 'Keep temperature at 26-28°C — bacteria grow faster in warmth.',
            ),
            _TipCard(
              icon: Icons.air,
              tip: 'Run the filter 24/7 — bacteria live in the filter media.',
            ),
            _TipCard(
              icon: Icons.cleaning_services,
              tip: 'Never replace all filter media at once — you\'ll lose your bacteria.',
            ),
            _TipCard(
              icon: Icons.water_drop,
              tip: 'Use dechlorinator — chlorine kills beneficial bacteria.',
            ),
            _TipCard(
              icon: Icons.speed,
              tip: 'Add bacteria starter (Seachem Stability, etc.) to speed things up.',
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _CycleStage extends StatelessWidget {
  final int number;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final IconData icon;

  const _CycleStage({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: AppTypography.headlineSmall.copyWith(color: color),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.labelLarge),
                  Text(subtitle, style: AppTypography.bodySmall.copyWith(color: color)),
                  const SizedBox(height: 8),
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

class _CycleArrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.arrow_downward, color: AppColors.textHint, size: 24),
            Text('Bacteria convert', style: AppTypography.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final String title;
  final String duration;
  final List<String> steps;
  final List<String> pros;
  final List<String> cons;

  const _MethodCard({
    required this.title,
    required this.duration,
    required this.steps,
    required this.pros,
    required this.cons,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: AppTypography.headlineSmall)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(duration, style: AppTypography.bodySmall),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...steps.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${e.key + 1}. ', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(e.value, style: AppTypography.bodyMedium)),
                ],
              ),
            )),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('✓ Pros', style: AppTypography.labelLarge.copyWith(color: AppColors.success, fontSize: 13)),
                      ...pros.map((p) => Text('• $p', style: AppTypography.bodySmall)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('✗ Cons', style: AppTypography.labelLarge.copyWith(color: AppColors.error, fontSize: 13)),
                      ...cons.map((c) => Text('• $c', style: AppTypography.bodySmall)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 20),
          const SizedBox(width: 12),
          Text(text, style: AppTypography.bodyMedium),
        ],
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
