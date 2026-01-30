import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VacationGuideScreen extends StatelessWidget {
  const VacationGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vacation Planning')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: AppColors.info.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.flight, size: 32, color: AppColors.info),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Planning ahead ensures your fish stay healthy while you\'re away. Most tanks can handle 1-2 weeks without intervention.',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text('How Long Can Fish Go Without Food?', style: AppTypography.headlineMedium),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DurationRow(fish: 'Adult tropical fish', duration: '1-2 weeks', notes: 'Healthy adults handle fasting well'),
                  const Divider(),
                  _DurationRow(fish: 'Goldfish', duration: '2 weeks+', notes: 'Very resilient, slow metabolism'),
                  const Divider(),
                  _DurationRow(fish: 'Bettas', duration: '1-2 weeks', notes: 'Often overfed anyway'),
                  const Divider(),
                  _DurationRow(fish: 'Fry/juveniles', duration: '2-3 days max', notes: 'Need frequent feeding'),
                  const Divider(),
                  _DurationRow(fish: 'Shrimp', duration: '2+ weeks', notes: 'Graze on biofilm, algae'),
                  const Divider(),
                  _DurationRow(fish: 'Plecos', duration: '1-2 weeks', notes: 'Add driftwood, algae wafers before leaving'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text('Before You Leave', style: AppTypography.headlineMedium),
          const SizedBox(height: 16),

          _ChecklistSection(
            title: '1 Week Before',
            items: [
              'Do a large water change (30-50%)',
              'Clean filter media (in tank water)',
              'Trim plants if needed',
              'Test water parameters — address any issues',
              'Check all equipment is working properly',
            ],
          ),

          _ChecklistSection(
            title: '1-2 Days Before',
            items: [
              'Another 20-25% water change',
              'Clean glass',
              'Remove any dead plant matter',
              'Check heater setting',
              'Top off water level',
              'Feed normally (don\'t overfeed "to stock up")',
            ],
          ),

          _ChecklistSection(
            title: 'Day of Departure',
            items: [
              'Final feeding (normal amount)',
              'Check temperature',
              'Ensure filter is running',
              'Set light timer (6-8 hours)',
              'Close blinds if direct sunlight is an issue',
              'Unplug any unnecessary equipment',
            ],
          ),

          const SizedBox(height: 24),

          Text('Feeding Options', style: AppTypography.headlineMedium),
          const SizedBox(height: 16),

          _OptionCard(
            title: 'No Feeding (Short Trips)',
            duration: '3-7 days',
            pros: ['Safest option', 'No overfeeding risk', 'No water quality issues'],
            cons: ['Fish may be hungry when you return'],
            tip: 'Healthy adult fish can easily go a week without food.',
          ),

          _OptionCard(
            title: 'Automatic Feeder',
            duration: '1-3 weeks',
            pros: ['Consistent feeding', 'Set and forget', 'Adjustable portions'],
            cons: ['Can malfunction', 'May dump food', 'Needs testing before trip'],
            tip: 'Test for at least a week before relying on it. Use less food than normal.',
          ),

          _OptionCard(
            title: 'Vacation Feeder Blocks',
            duration: 'Not recommended',
            pros: ['Cheap', 'Easy to use'],
            cons: ['Cloud water badly', 'Can cause ammonia spikes', 'Fish often ignore them'],
            tip: 'Avoid these — they cause more problems than they solve.',
          ),

          _OptionCard(
            title: 'Fish Sitter',
            duration: '1+ weeks',
            pros: ['Can handle emergencies', 'Check equipment', 'Proper feeding'],
            cons: ['Risk of overfeeding', 'Must be trained', 'Availability'],
            tip: 'Pre-portion food in daily containers. Less is more — they WILL overfeed.',
          ),

          const SizedBox(height: 24),

          Text('If Using a Fish Sitter', style: AppTypography.headlineMedium),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BulletPoint(text: 'Pre-portion ALL food in labeled daily containers'),
                  _BulletPoint(text: 'Write clear instructions — feeding only, no maintenance'),
                  _BulletPoint(text: 'Show them where NOT to stick their hands'),
                  _BulletPoint(text: 'Leave your contact info'),
                  _BulletPoint(text: 'Leave emergency contact (local fish store, etc.)'),
                  _BulletPoint(text: '"If in doubt, skip feeding" as golden rule'),
                  _BulletPoint(text: 'Tell them what normal fish behavior looks like'),
                  _BulletPoint(text: 'DO NOT ask them to do water changes'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text('Extended Absences (2+ Weeks)', style: AppTypography.headlineMedium),
          const SizedBox(height: 16),

          Card(
            color: AppColors.warning.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Additional Precautions:', style: AppTypography.labelLarge),
                  const SizedBox(height: 8),
                  _BulletPoint(text: 'Have someone check tank every few days'),
                  _BulletPoint(text: 'Automatic feeder + fish sitter combo'),
                  _BulletPoint(text: 'Consider reducing light period to slow algae'),
                  _BulletPoint(text: 'Add extra plants (floating plants good)'),
                  _BulletPoint(text: 'Set up camera to check remotely'),
                  _BulletPoint(text: 'Have backup equipment available'),
                  _BulletPoint(text: 'Leave water change supplies ready (just in case)'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text('When You Return', style: AppTypography.headlineMedium),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NumberedStep(num: 1, text: 'Check all fish are present and healthy'),
                  _NumberedStep(num: 2, text: 'Check temperature'),
                  _NumberedStep(num: 3, text: 'Test water parameters'),
                  _NumberedStep(num: 4, text: 'Do a water change (25-30%)'),
                  _NumberedStep(num: 5, text: 'Resume normal feeding gradually'),
                  _NumberedStep(num: 6, text: 'Check equipment is working'),
                  _NumberedStep(num: 7, text: 'Clean glass, trim plants if needed'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _DurationRow extends StatelessWidget {
  final String fish;
  final String duration;
  final String notes;

  const _DurationRow({required this.fish, required this.duration, required this.notes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(fish, style: AppTypography.labelLarge),
          ),
          Expanded(
            flex: 1,
            child: Text(duration, style: AppTypography.bodyMedium.copyWith(color: AppColors.success)),
          ),
          Expanded(
            flex: 2,
            child: Text(notes, style: AppTypography.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _ChecklistSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const _ChecklistSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.headlineSmall),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.check_box_outline_blank, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item, style: AppTypography.bodyMedium)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String duration;
  final List<String> pros;
  final List<String> cons;
  final String tip;

  const _OptionCard({
    required this.title,
    required this.duration,
    required this.pros,
    required this.cons,
    required this.tip,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(width: 16),
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
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, size: 14, color: AppColors.info),
                  const SizedBox(width: 6),
                  Expanded(child: Text(tip, style: AppTypography.bodySmall)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: AppTypography.bodyMedium),
          Expanded(child: Text(text, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }
}

class _NumberedStep extends StatelessWidget {
  final int num;
  final String text;

  const _NumberedStep({required this.num, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$num',
                style: AppTypography.bodySmall.copyWith(color: AppColors.primary, fontSize: 11),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }
}
