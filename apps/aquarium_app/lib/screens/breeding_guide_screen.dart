import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BreedingGuideScreen extends StatelessWidget {
  const BreedingGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fish Breeding Guide')),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
                      Icon(Icons.favorite, color: AppColors.info),
                      const SizedBox(width: 8),
                      Text('Breeding Basics', style: AppTypography.headlineSmall),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Breeding fish can be rewarding! Most fish breed readily in the right conditions. '
                    'Key factors: healthy parents, proper diet, and appropriate environment.',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Breeding types
          Text('Breeding Methods', style: AppTypography.headlineMedium),
          const SizedBox(height: 16),

          _MethodCard(
            title: 'Livebearers',
            icon: Icons.child_friendly,
            description: 'Give birth to free-swimming fry. Easiest to breed.',
            examples: 'Guppies, Mollies, Platies, Swordtails, Endlers',
            tips: [
              'Males have modified anal fin (gonopodium)',
              'Females store sperm — can have multiple batches',
              'Provide hiding spots (plants, breeding boxes)',
              'Separate pregnant females or provide dense plants',
              'Adults will eat fry — protection needed',
            ],
          ),
          _MethodCard(
            title: 'Egg Scatterers',
            icon: Icons.scatter_plot,
            description: 'Scatter eggs over plants/substrate. Parents often eat eggs.',
            examples: 'Tetras, Danios, Barbs, Rasboras',
            tips: [
              'Use spawning mops or fine-leaved plants',
              'Marbles on bottom catch eggs safely',
              'Remove parents after spawning',
              'Eggs hatch in 24-72 hours typically',
              'Fry need infusoria then baby brine shrimp',
            ],
          ),
          _MethodCard(
            title: 'Egg Depositors',
            icon: Icons.egg,
            description: 'Lay eggs on surfaces (rocks, leaves, glass). Often guard eggs.',
            examples: 'Corydoras, Angelfish, Discus, Bristlenose Plecos',
            tips: [
              'Provide flat surfaces for egg laying',
              'Some species guard eggs, others don\'t',
              'Corydoras: T-position spawning behavior',
              'Angelfish: Both parents often guard',
              'Plecos: Male guards eggs in caves',
            ],
          ),
          _MethodCard(
            title: 'Mouthbrooders',
            icon: Icons.face,
            description: 'Parent holds eggs/fry in mouth for protection.',
            examples: 'African Cichlids, Betta (some), Arowanas',
            tips: [
              'Female (usually) carries eggs in mouth',
              'Don\'t feed holding parent — they fast',
              'Fry released after 2-4 weeks',
              'Can strip eggs from mouth if needed',
              'Holding female may be stressed',
            ],
          ),
          _MethodCard(
            title: 'Bubble Nesters',
            icon: Icons.bubble_chart,
            description: 'Build floating bubble nests for eggs.',
            examples: 'Bettas, Gouramis',
            tips: [
              'Male builds nest, attracts female',
              'Spawning embrace under nest',
              'Male guards nest and fry',
              'Remove female after spawning',
              'Keep water still — bubbles fragile',
            ],
          ),

          const SizedBox(height: 24),

          // General conditioning
          Text('Conditioning Breeders', style: AppTypography.headlineMedium),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ConditionItem(
                    title: 'Diet',
                    description: 'Feed high-protein foods: live/frozen brine shrimp, bloodworms, daphnia. Multiple small meals daily.',
                  ),
                  const Divider(),
                  _ConditionItem(
                    title: 'Water Quality',
                    description: 'Pristine water, frequent small changes. Many species triggered by cooler water change.',
                  ),
                  const Divider(),
                  _ConditionItem(
                    title: 'Temperature',
                    description: 'Slight increase (1-2°C) can trigger breeding. Simulate rainy season.',
                  ),
                  const Divider(),
                  _ConditionItem(
                    title: 'Ratio',
                    description: 'Usually 1 male to 2-3 females. Reduces stress on single female.',
                  ),
                  const Divider(),
                  _ConditionItem(
                    title: 'Privacy',
                    description: 'Dim lighting, hiding spots, separate breeding tank often helps.',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Raising fry
          Text('Raising Fry', style: AppTypography.headlineMedium),
          const SizedBox(height: 16),

          _FryStageCard(
            stage: 'Day 1-3',
            title: 'Egg/Yolk Sac Stage',
            feeding: 'No feeding needed — fry absorb yolk sac',
            care: 'Keep water clean, gentle aeration, low light',
          ),
          _FryStageCard(
            stage: 'Day 3-7',
            title: 'First Feeding',
            feeding: 'Infusoria, liquid fry food, green water, vinegar eels',
            care: 'Feed small amounts multiple times daily',
          ),
          _FryStageCard(
            stage: 'Week 1-2',
            title: 'Growing',
            feeding: 'Baby brine shrimp, microworms, crushed flakes',
            care: 'Frequent small water changes, remove uneaten food',
          ),
          _FryStageCard(
            stage: 'Week 3+',
            title: 'Juvenile',
            feeding: 'Crushed flakes, small pellets, frozen foods',
            care: 'Separate by size if needed, regular maintenance',
          ),

          const SizedBox(height: 24),

          // Easy breeders
          Text('Easiest Fish to Breed', style: AppTypography.headlineMedium),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _EasyBreederRow(
                    fish: 'Guppies',
                    difficulty: 'Very Easy',
                    notes: 'Will breed constantly. Separate sexes to control population.',
                  ),
                  const Divider(),
                  _EasyBreederRow(
                    fish: 'Platies',
                    difficulty: 'Very Easy',
                    notes: 'Prolific livebearers. Fry large enough to survive.',
                  ),
                  const Divider(),
                  _EasyBreederRow(
                    fish: 'Convict Cichlids',
                    difficulty: 'Easy',
                    notes: 'Aggressive parents protect fry. Cave spawners.',
                  ),
                  const Divider(),
                  _EasyBreederRow(
                    fish: 'Bristlenose Plecos',
                    difficulty: 'Easy',
                    notes: 'Male guards eggs in cave. Large fry.',
                  ),
                  const Divider(),
                  _EasyBreederRow(
                    fish: 'Cherry Shrimp',
                    difficulty: 'Easy',
                    notes: 'Breed readily in planted tanks. No intervention needed.',
                  ),
                  const Divider(),
                  _EasyBreederRow(
                    fish: 'Corydoras',
                    difficulty: 'Moderate',
                    notes: 'Cool water change triggers spawning. Eggs on glass.',
                  ),
                  const Divider(),
                  _EasyBreederRow(
                    fish: 'Bettas',
                    difficulty: 'Moderate',
                    notes: 'Male builds bubble nest. Remove female after spawning.',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Warning
          Card(
            color: AppColors.warning.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Text('Before You Breed', style: AppTypography.headlineSmall),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Have a plan for the fry — can you home them?\n'
                    '• Breeding tanks and supplies add cost\n'
                    '• Livebearers can quickly overpopulate\n'
                    '• Quality over quantity — cull runts humanely\n'
                    '• Don\'t release into wild — ever',
                    style: AppTypography.bodyMedium,
                  ),
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

class _MethodCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final String examples;
  final List<String> tips;

  const _MethodCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.examples,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: AppTypography.labelLarge),
        subtitle: Text(description, style: AppTypography.bodySmall),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Examples: $examples', 
                  style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic)),
                const SizedBox(height: 12),
                ...tips.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check, size: 16, color: AppColors.success),
                      const SizedBox(width: 8),
                      Expanded(child: Text(t, style: AppTypography.bodySmall)),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConditionItem extends StatelessWidget {
  final String title;
  final String description;

  const _ConditionItem({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.labelLarge),
          const SizedBox(height: 4),
          Text(description, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}

class _FryStageCard extends StatelessWidget {
  final String stage;
  final String title;
  final String feeding;
  final String care;

  const _FryStageCard({
    required this.stage,
    required this.title,
    required this.feeding,
    required this.care,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(stage, style: AppTypography.bodySmall.copyWith(color: AppColors.secondary)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.labelLarge),
                  const SizedBox(height: 4),
                  Text('🍼 $feeding', style: AppTypography.bodySmall),
                  Text('🏥 $care', style: AppTypography.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EasyBreederRow extends StatelessWidget {
  final String fish;
  final String difficulty;
  final String notes;

  const _EasyBreederRow({
    required this.fish,
    required this.difficulty,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fish, style: AppTypography.labelLarge),
                Text(difficulty, style: AppTypography.bodySmall.copyWith(color: AppColors.success)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(notes, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}
