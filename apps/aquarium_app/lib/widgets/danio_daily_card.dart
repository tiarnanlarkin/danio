import 'dart:math';
import 'package:flutter/material.dart';
import '../data/daily_tips.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_card.dart';

/// "Danio Daily" - a daily briefing card for the home screen.
///
/// Generates fresh content each day using a deterministic seed,
/// so content is consistent throughout the day but refreshes at midnight.
/// No other aquarium app offers this kind of daily engagement mechanic.
class DanioDailyCard extends StatelessWidget {
  const DanioDailyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final rng = Random(seed);

    // Pick daily content
    final tip = _pickTip(rng);
    final fact = _pickFact(rng);
    final seasonal = _getSeasonalTip(now.month);
    final motivation = _pickMotivation(rng);

    return AppCard(
      border: Border.all(color: AppColors.primary.withAlpha(40)),
      backgroundColor: AppColors.primary.withAlpha(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryAlpha10,
                  borderRadius: AppRadius.smallRadius,
                ),
                child: const Icon(
                  Icons.wb_sunny_rounded,
                  color: AppColors.primary,
                  size: AppIconSizes.sm,
                ),
              ),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Danio Daily',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(_formatDate(now), style: AppTypography.bodySmall),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Tip of the day
          _DailySection(
            emoji: '\u{1F4A1}',
            title: tip.title,
            content: tip.content,
          ),

          const SizedBox(height: AppSpacing.sm2),

          // Did you know?
          _DailySection(
            emoji: '\u{1F41F}',
            title: 'Did You Know?',
            content: fact,
          ),

          const SizedBox(height: AppSpacing.sm2),

          // Seasonal tip
          _DailySection(
            emoji: _seasonEmoji(now.month),
            title: 'Seasonal',
            content: seasonal,
          ),

          const SizedBox(height: AppSpacing.sm2),

          // Motivation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm2),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(15),
              borderRadius: AppRadius.smallRadius,
            ),
            child: Text(
              motivation,
              style: AppTypography.bodySmall.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.success,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  DailyTip _pickTip(Random rng) {
    final tips = DailyTips.all;
    return tips[rng.nextInt(tips.length)];
  }

  String _pickFact(Random rng) {
    const facts = [
      'Clownfish can change their sex - dominant females lead the group.',
      'Goldfish can recognise their owners and distinguish between faces.',
      'The Siamese fighting fish (Betta) builds bubble nests to protect eggs.',
      'Neon tetras were so popular in the 1930s they were worth their weight in gold.',
      'Corydoras catfish can breathe through their intestines by gulping air.',
      'A single filter sponge hosts millions of beneficial bacteria.',
      'The aquarium hobby generates over \$6 billion in revenue worldwide.',
      'Plecos have armoured plates instead of scales for protection.',
      'Cherry shrimp can live up to 2 years in a well-maintained tank.',
      'Angelfish mate for life and both parents guard the eggs.',
      'The smallest aquarium fish, Paedocypris, is just 7.9mm long.',
      'Fish can feel pain and have excellent memories - not just 3 seconds!',
      'Guppies were named after Robert John Lechmere Guppy who sent specimens to the British Museum.',
      'Oscars are one of the most intelligent aquarium fish and can be trained.',
      'Snails have up to 20,000 teeth arranged on a ribbon-like structure called a radula.',
      'Live plants produce oxygen during the day and absorb CO2, improving water quality.',
      'The pH scale is logarithmic - pH 6 is 10x more acidic than pH 7.',
      'Cycling a tank mimics the nitrogen cycle that occurs naturally in rivers and lakes.',
      'The average freshwater aquarium contains more bacteria cells than fish cells.',
      'Danio rerio (zebrafish) share 70% of their genes with humans.',
      'The oldest recorded goldfish lived to be 43 years old.',
      'Bristlenose plecos are better algae eaters than common plecos and stay smaller.',
      'Ramshorn snails come in blue, pink, red, and leopard varieties.',
      'Assassin snails will hunt and eat pest snails, making them a natural pest control.',
      'Java moss grows in almost any conditions and is perfect for beginner aquascapes.',
      'The Walstad method uses soil and plants to create a self-sustaining ecosystem.',
      'Shrimp are incredibly sensitive to copper - check medications before dosing.',
      'Aquarium salt (NaCl) can help treat ich and some bacterial infections.',
      'A mature sponge filter can cycle a new tank in days when transferred.',
      'Driftwood lowers pH naturally by releasing tannins - great for blackwater setups.',
    ];
    return facts[rng.nextInt(facts.length)];
  }

  String _getSeasonalTip(int month) {
    if (month >= 3 && month <= 5) {
      const tips = [
        'Spring is breeding season for many species - watch for courtship behaviour!',
        'Longer daylight hours may increase algae. Consider adjusting your timer.',
        'Great time to set up a new tank - warm weather speeds cycling.',
      ];
      return tips[month % tips.length];
    } else if (month >= 6 && month <= 8) {
      const tips = [
        'Hot weather can raise tank temps. Watch for overheating above 30C.',
        'Good time for outdoor pond maintenance and summer feeding schedules.',
        'Holiday? Set up an auto-feeder and ask someone to check your tanks.',
      ];
      return tips[month % tips.length];
    } else if (month >= 9 && month <= 11) {
      const tips = [
        'Autumn is a great time to trim and replant your aquarium plants.',
        'As temperatures drop, check your heater is working properly.',
        'Falling leaves outside? Great time for a blackwater biotope with leaf litter!',
      ];
      return tips[month % tips.length];
    } else {
      const tips = [
        'Winter heating bills? Your tank heater works harder now - check temperature daily.',
        'Short days mean less natural light. Algae problems often ease in winter.',
        'A great time to plan next year\'s aquascaping projects!',
      ];
      return tips[month % tips.length];
    }
  }

  String _pickMotivation(Random rng) {
    const messages = [
      'Every water test is a step toward mastery. Keep going!',
      'Your fish are lucky to have someone who cares enough to learn.',
      'The best fishkeepers never stop learning. You are on the right track.',
      'A healthy tank is a work of art. You are the artist.',
      'Small consistent effort beats big occasional effort. Log that water test!',
      'You are already better than 90% of fishkeepers just by using this app.',
      'Remember: patience is the most important tool in fishkeeping.',
      'Every expert was once a beginner. Keep swimming!',
    ];
    return messages[rng.nextInt(messages.length)];
  }

  String _formatDate(DateTime now) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  String _seasonEmoji(int month) {
    if (month >= 3 && month <= 5) return '\u{1F331}';
    if (month >= 6 && month <= 8) return '\u{2600}\u{FE0F}';
    if (month >= 9 && month <= 11) return '\u{1F342}';
    return '\u{2744}\u{FE0F}';
  }
}

class _DailySection extends StatelessWidget {
  final String emoji;
  final String title;
  final String content;

  const _DailySection({
    required this.emoji,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: Theme.of(context).textTheme.titleLarge!.copyWith()),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(content, style: AppTypography.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
