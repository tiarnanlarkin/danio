import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_card.dart';

class QuickStartGuideScreen extends StatelessWidget {
  const QuickStartGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Start Guide')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            backgroundColor: AppOverlays.primary10,
            padding: AppCardPadding.standard,
            child: Column(
              children: [
                Icon(
                  Icons.rocket_launch,
                  size: AppIconSizes.xl,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.sm2),
                Text(
                  'Your First Aquarium',
                  style: AppTypography.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Setting up an aquarium is exciting! Follow these steps for a successful start.',
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          _StepCard(
            step: 1,
            title: 'Choose Your Tank',
            duration: 'Day 1',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BulletPoint(
                  text: 'Bigger is better - easier to maintain stable water',
                ),
                _BulletPoint(text: 'Minimum 40L (10 gal) for beginners'),
                _BulletPoint(
                  text: 'Consider where you\'ll put it (level, sturdy surface)',
                ),
                _BulletPoint(
                  text: '1L of water = 1kg weight - plan accordingly',
                ),
                const SizedBox(height: AppSpacing.sm),
                _TipBox(
                  text:
                      'Starter kit bundles often include filter, heater, and light.',
                ),
              ],
            ),
          ),

          _StepCard(
            step: 2,
            title: 'Get Your Equipment',
            duration: 'Day 1',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Essential:', style: AppTypography.labelLarge),
                _BulletPoint(text: 'Filter (sized for your tank or larger)'),
                _BulletPoint(text: 'Heater (for tropical fish)'),
                _BulletPoint(text: 'Thermometer'),
                _BulletPoint(text: 'Water conditioner/dechlorinator'),
                _BulletPoint(text: 'Test kit (liquid preferred)'),
                _BulletPoint(text: 'Substrate (gravel or sand)'),
                _BulletPoint(text: 'Bucket (dedicated to aquarium use)'),
                const SizedBox(height: AppSpacing.sm),
                Text('Nice to have:', style: AppTypography.labelLarge),
                _BulletPoint(text: 'Light (essential if keeping plants)'),
                _BulletPoint(text: 'Gravel vacuum/siphon'),
                _BulletPoint(text: 'Algae scraper'),
                _BulletPoint(text: 'Net'),
              ],
            ),
          ),

          _StepCard(
            step: 3,
            title: 'Set Up Your Tank',
            duration: 'Day 1',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NumberedStep(
                  num: 1,
                  text: 'Place tank on level, sturdy surface away from windows',
                ),
                _NumberedStep(
                  num: 2,
                  text: 'Rinse substrate thoroughly (no soap!)',
                ),
                _NumberedStep(num: 3, text: 'Add substrate (5-8cm depth)'),
                _NumberedStep(num: 4, text: 'Add hardscape (rocks, driftwood)'),
                _NumberedStep(
                  num: 5,
                  text:
                      'Fill with water - pour onto plate to avoid disturbing substrate',
                ),
                _NumberedStep(num: 6, text: 'Add dechlorinator immediately'),
                _NumberedStep(num: 7, text: 'Install filter and heater'),
                _NumberedStep(num: 8, text: 'Add plants if desired'),
                _NumberedStep(num: 9, text: 'Turn everything on'),
              ],
            ),
          ),

          _StepCard(
            step: 4,
            title: 'Cycle Your Tank',
            duration: '4-8 weeks',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This is the most important step! Cycling grows beneficial bacteria that keep your fish alive.',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm2),
                _NumberedStep(
                  num: 1,
                  text: 'Add ammonia source (fish food or pure ammonia)',
                ),
                _NumberedStep(num: 2, text: 'Test water every 2-3 days'),
                _NumberedStep(
                  num: 3,
                  text: 'Wait for ammonia spike, then nitrite spike',
                ),
                _NumberedStep(
                  num: 4,
                  text:
                      'Cycle is complete when ammonia = 0, nitrite = 0, nitrate > 0',
                ),
                const SizedBox(height: AppSpacing.sm),
                _WarningBox(
                  text:
                      'DO NOT add fish until the cycle is complete. This is the #1 beginner mistake.',
                ),
              ],
            ),
          ),

          _StepCard(
            step: 5,
            title: 'Choose Your Fish',
            duration: 'Research during cycling',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good beginner fish:', style: AppTypography.labelLarge),
                _BulletPoint(text: 'Guppies, platies, mollies (livebearers)'),
                _BulletPoint(
                  text: 'Tetras (neons, cardinals) - need groups of 6+',
                ),
                _BulletPoint(text: 'Corydoras - need groups of 6+, need sand'),
                _BulletPoint(text: 'Betta - single male only, no fin nippers'),
                _BulletPoint(text: 'Cherry barbs, zebra danios'),
                const SizedBox(height: AppSpacing.sm),
                Text('Consider:', style: AppTypography.labelLarge),
                _BulletPoint(text: 'Adult size - research how big they get'),
                _BulletPoint(text: 'Compatibility - will they get along?'),
                _BulletPoint(text: 'Requirements - temperature, pH, space'),
                _BulletPoint(text: 'Schooling needs - some need groups'),
              ],
            ),
          ),

          _StepCard(
            step: 6,
            title: 'Add Your First Fish',
            duration: 'After cycling complete',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NumberedStep(
                  num: 1,
                  text: 'Buy from reputable store - avoid sick-looking fish',
                ),
                _NumberedStep(
                  num: 2,
                  text:
                      'Float bag for 15-20 minutes (temperature equalization)',
                ),
                _NumberedStep(
                  num: 3,
                  text: 'Add tank water to bag gradually over 20-30 minutes',
                ),
                _NumberedStep(
                  num: 4,
                  text: 'Net fish into tank - discard bag water',
                ),
                _NumberedStep(num: 5, text: 'Keep lights off for a few hours'),
                _NumberedStep(num: 6, text: 'Don\'t feed for 24 hours'),
                const SizedBox(height: AppSpacing.sm),
                _TipBox(
                  text:
                      'Add fish slowly over weeks - don\'t stock all at once!',
                ),
              ],
            ),
          ),

          _StepCard(
            step: 7,
            title: 'Ongoing Maintenance',
            duration: 'Weekly',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weekly:', style: AppTypography.labelLarge),
                _BulletPoint(
                  text: 'Test water (at least ammonia, nitrite, nitrate)',
                ),
                _BulletPoint(text: '20-25% water change'),
                _BulletPoint(text: 'Vacuum substrate (avoid planted areas)'),
                _BulletPoint(text: 'Clean glass if needed'),
                const SizedBox(height: AppSpacing.sm),
                Text('Monthly:', style: AppTypography.labelLarge),
                _BulletPoint(
                  text:
                      'Rinse filter media in old tank water (never tap water)',
                ),
                _BulletPoint(text: 'Trim plants'),
                _BulletPoint(text: 'Check equipment'),
                const SizedBox(height: AppSpacing.sm),
                Text('Daily:', style: AppTypography.labelLarge),
                _BulletPoint(
                  text: 'Feed once or twice (only what they eat in 2 minutes)',
                ),
                _BulletPoint(text: 'Check temperature'),
                _BulletPoint(text: 'Observe fish for problems'),
                _BulletPoint(text: 'Count fish'),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          AppCard(
            backgroundColor: AppOverlays.error10,
            padding: AppCardPadding.standard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: AppColors.error),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Common Beginner Mistakes',
                      style: AppTypography.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm2),
                _MistakeItem(
                  mistake: 'Adding fish before cycling',
                  result: 'Fish die from ammonia poisoning',
                ),
                _MistakeItem(
                  mistake: 'Overfeeding',
                  result: 'Ammonia spikes, obesity, water quality issues',
                ),
                _MistakeItem(
                  mistake: 'Overstocking',
                  result: 'Stress, aggression, poor water quality',
                ),
                _MistakeItem(
                  mistake: 'Cleaning filter in tap water',
                  result: 'Kills beneficial bacteria',
                ),
                _MistakeItem(
                  mistake: 'Changing too much water at once',
                  result: 'Stress, parameter swings',
                ),
                _MistakeItem(
                  mistake: 'Not researching fish',
                  result: 'Incompatible tankmates, wrong conditions',
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
  final String duration;
  final Widget content;

  const _StepCard({
    required this.step,
    required this.title,
    required this.duration,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$step',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.headlineSmall),
                      Text(
                        duration,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            content,
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
      padding: const EdgeInsets.only(bottom: AppSpacing.xs2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppOverlays.primary10,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$num',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }
}

class _TipBox extends StatelessWidget {
  final String text;

  const _TipBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm3),
      decoration: BoxDecoration(
        color: AppOverlays.info10,
        borderRadius: AppRadius.smallRadius,
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb,
            size: AppIconSizes.xs,
            color: context.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}

class _WarningBox extends StatelessWidget {
  final String text;

  const _WarningBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm3),
      decoration: BoxDecoration(
        color: AppOverlays.error10,
        borderRadius: AppRadius.smallRadius,
      ),
      child: Row(
        children: [
          Icon(Icons.warning, size: AppIconSizes.xs, color: AppColors.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MistakeItem extends StatelessWidget {
  final String mistake;
  final String result;

  const _MistakeItem({required this.mistake, required this.result});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.close, size: AppIconSizes.xs, color: AppColors.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTypography.bodySmall.copyWith(
                  color: context.textPrimary,
                ),
                children: [
                  TextSpan(
                    text: mistake,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' → $result'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
