import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _buildItems().length,
        itemBuilder: (context, index) => _buildItems()[index],
      ),
    );
  }

  List<Widget> _buildItems() {
    return const [
          _FaqSection(
            title: 'Getting Started',
            items: [
              _FaqItem(
                question: 'How long should I wait before adding fish?',
                answer:
                    'You need to cycle your tank first, which typically takes 4-8 weeks. '
                    'During this time, beneficial bacteria build up to process fish waste. '
                    'Use a test kit to confirm ammonia and nitrite are at 0 ppm before adding fish.',
              ),
              _FaqItem(
                question: 'What fish are good for beginners?',
                answer:
                    'Hardy fish like Bettas, Guppies, Platies, Corydoras catfish, and Zebra Danios '
                    'are great for beginners. They tolerate a wider range of conditions and are forgiving '
                    'of minor mistakes.',
              ),
              _FaqItem(
                question: 'How many fish can I keep?',
                answer:
                    'A common guideline is 1 inch of fish per gallon (2.5cm per 4L), but this is very rough. '
                    'Consider adult size, swimming space needs, bioload, and filtration capacity. '
                    'When in doubt, understock.',
              ),
            ],
          ),

          _FaqSection(
            title: 'Water Quality',
            items: [
              _FaqItem(
                question: 'How often should I change the water?',
                answer:
                    '20-30% weekly is a good baseline for most tanks. Heavily stocked tanks may need '
                    'more frequent changes. Lightly stocked, planted tanks might get away with less. '
                    'Test your water to find the right schedule.',
              ),
              _FaqItem(
                question: 'What are ideal water parameters?',
                answer:
                    'For most tropical freshwater fish:\n'
                    '• Temperature: 24-26°C (75-79°F)\n'
                    '• pH: 6.5-7.5\n'
                    '• Ammonia: 0 ppm\n'
                    '• Nitrite: 0 ppm\n'
                    '• Nitrate: <20 ppm\n\n'
                    'Research your specific species as requirements vary.',
              ),
              _FaqItem(
                question: 'My ammonia/nitrite won\'t go down. Help!',
                answer:
                    'Do a large water change (50%) immediately to protect fish. Then:\n'
                    '• Check that your filter is running and has adequate media\n'
                    '• Make sure you haven\'t killed beneficial bacteria (chlorinated water, over-cleaning)\n'
                    '• Reduce feeding\n'
                    '• Consider if the tank is overstocked\n'
                    '• Be patient — the cycle may need to re-establish',
              ),
            ],
          ),

          _FaqSection(
            title: 'Feeding',
            items: [
              _FaqItem(
                question: 'How often should I feed my fish?',
                answer:
                    'Most adult fish do well with 1-2 small feedings per day. Feed only what they can '
                    'consume in 2-3 minutes. Overfeeding is the #1 beginner mistake — it pollutes water '
                    'and causes health issues.',
              ),
              _FaqItem(
                question: 'My fish always seem hungry. Should I feed more?',
                answer:
                    'Fish are opportunistic and will always beg for food — it\'s instinct. '
                    'A healthy fish with a slightly rounded belly is well-fed. Stick to your schedule '
                    'and don\'t fall for their tricks!',
              ),
              _FaqItem(
                question: 'Can I use vacation feeders?',
                answer:
                    'Those white blocks are generally not recommended — they cloud water and cause '
                    'ammonia spikes. For short trips (up to 2 weeks), healthy adult fish can go without food. '
                    'For longer absences, use an automatic feeder (tested beforehand) or a fish sitter.',
              ),
            ],
          ),

          _FaqSection(
            title: 'Equipment',
            items: [
              _FaqItem(
                question: 'What filter should I get?',
                answer:
                    'Get a filter rated for more than your tank size. Common types:\n'
                    '• Hang-on-back (HOB): Easy, good for most tanks\n'
                    '• Sponge filter: Great for shrimp/fry, needs air pump\n'
                    '• Canister: Powerful, best for larger tanks\n'
                    '• Internal: Compact, good for small tanks\n\n'
                    'Filter flow should turn over tank volume 4-6× per hour.',
              ),
              _FaqItem(
                question: 'Do I need a heater?',
                answer:
                    'For tropical fish, yes — they need stable temperatures around 24-26°C. '
                    'Get a heater rated for your tank size (usually 3-5 watts per gallon). '
                    'Coldwater fish like goldfish don\'t need heaters at room temperature.',
              ),
              _FaqItem(
                question: 'How often should I clean the filter?',
                answer:
                    'Rinse filter media in old tank water (never tap water!) every 2-4 weeks or when '
                    'flow decreases. Never replace all media at once — you\'ll lose beneficial bacteria. '
                    'Stagger replacements if you have multiple media types.',
              ),
            ],
          ),

          _FaqSection(
            title: 'Common Problems',
            items: [
              _FaqItem(
                question: 'My water is cloudy. What\'s wrong?',
                answer:
                    'Common causes:\n'
                    '• White/gray: Bacterial bloom (often in new tanks, usually clears on its own)\n'
                    '• Green: Algae bloom (too much light/nutrients)\n'
                    '• After water change: Stirred up substrate or temperature difference\n\n'
                    'Don\'t do massive water changes for bacterial blooms — just wait it out.',
              ),
              _FaqItem(
                question: 'I have algae everywhere!',
                answer:
                    'Algae needs light and nutrients. To reduce it:\n'
                    '• Reduce light period to 6-8 hours\n'
                    '• Avoid direct sunlight on tank\n'
                    '• Don\'t overfeed\n'
                    '• Add live plants (they compete for nutrients)\n'
                    '• Consider algae-eating fish/snails\n'
                    '• Manual removal during water changes',
              ),
              _FaqItem(
                question: 'My fish is sick. What do I do?',
                answer:
                    '1. Observe symptoms carefully (spots, fins, behavior)\n'
                    '2. Test water parameters — poor water is often the cause\n'
                    '3. Do a water change (good first step for most issues)\n'
                    '4. Isolate sick fish if possible (quarantine tank)\n'
                    '5. Research the specific disease before medicating\n'
                    '6. Don\'t panic-dose multiple medications',
              ),
            ],
          ),

          _FaqSection(
            title: 'Plants',
            items: [
              _FaqItem(
                question: 'Do I need CO2 for plants?',
                answer:
                    'Not necessarily. Many plants thrive without added CO2:\n'
                    '• Java Fern, Anubias, Java Moss, Cryptocoryne, Vallisneria, Amazon Sword\n\n'
                    'CO2 helps for demanding plants and faster growth, but a "low-tech" planted tank '
                    'can be beautiful with the right plant choices.',
              ),
              _FaqItem(
                question: 'My plants are dying/melting. Why?',
                answer:
                    'Common causes:\n'
                    '• Transition shock (many plants melt then regrow)\n'
                    '• Not enough light\n'
                    '• Nutrient deficiency (consider root tabs or liquid ferts)\n'
                    '• Wrong planting (don\'t bury rhizome on Anubias/Java Fern)\n'
                    '• Too much/little of something\n\n'
                    'Give new plants a few weeks to adjust.',
              ),
            ],
          ),

          SizedBox(height: AppSpacing.xxl),
        ];
  }
}

class _FaqSection extends StatelessWidget {
  final String title;
  final List<_FaqItem> items;

  const _FaqSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(title, style: AppTypography.headlineSmall),
        ),
        ...items,
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: AppRadius.mediumRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: AppTypography.labelLarge,
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 12),
                Text(widget.answer, style: AppTypography.bodyMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
