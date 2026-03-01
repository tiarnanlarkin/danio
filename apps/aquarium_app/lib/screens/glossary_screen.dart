import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  List<_GlossaryTerm> get _filteredTerms {
    var results = _allTerms;

    if (_searchQuery.isNotEmpty) {
      results = results
          .where(
            (t) =>
                t.term.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                t.definition.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    if (_selectedCategory != null) {
      results = results.where((t) => t.category == _selectedCategory).toList();
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final terms = _filteredTerms;
    final categories = _allTerms.map((t) => t.category).toSet().toList()
      ..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Glossary')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search terms...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.mediumRadius,
                ),
                filled: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedCategory == null,
                  onSelected: (_) => setState(() => _selectedCategory = null),
                ),
                const SizedBox(width: AppSpacing.sm),
                ...categories.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(c),
                      selected: _selectedCategory == c,
                      onSelected: (_) => setState(
                        () => _selectedCategory = _selectedCategory == c
                            ? null
                            : c,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              '${terms.length} terms',
              style: AppTypography.bodySmall,
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: terms.length,
              itemBuilder: (ctx, i) => _TermCard(term: terms[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermCard extends StatelessWidget {
  final _GlossaryTerm term;

  const _TermCard({required this.term});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(term.term, style: AppTypography.labelLarge),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppOverlays.primary10,
                    borderRadius: AppRadius.smallRadius,
                  ),
                  child: Text(
                    term.category,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(term.definition, style: AppTypography.bodyMedium),
            if (term.example != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Example: ${term.example}',
                style: AppTypography.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GlossaryTerm {
  final String term;
  final String definition;
  final String category;
  final String? example;

  const _GlossaryTerm({
    required this.term,
    required this.definition,
    required this.category,
    this.example,
  });
}

final _allTerms = [
  // Water Chemistry
  const _GlossaryTerm(
    term: 'Ammonia (NH₃)',
    definition:
        'Toxic compound produced by fish waste, decaying matter, and uneaten food. Should always be 0 ppm in a cycled tank.',
    category: 'Chemistry',
  ),
  const _GlossaryTerm(
    term: 'Nitrite (NO₂)',
    definition:
        'Intermediate product in the nitrogen cycle. Produced when bacteria convert ammonia. Toxic - should be 0 ppm.',
    category: 'Chemistry',
  ),
  const _GlossaryTerm(
    term: 'Nitrate (NO₃)',
    definition:
        'End product of nitrogen cycle. Less toxic but builds up over time. Removed by water changes and plants.',
    category: 'Chemistry',
    example: 'Keep below 40 ppm with regular water changes.',
  ),
  const _GlossaryTerm(
    term: 'pH',
    definition:
        'Measure of water acidity/alkalinity. Scale 0-14, with 7 neutral. Most fish prefer 6.5-7.5.',
    category: 'Chemistry',
  ),
  const _GlossaryTerm(
    term: 'GH (General Hardness)',
    definition:
        'Measure of dissolved minerals (calcium, magnesium). Affects fish osmoregulation and plant health.',
    category: 'Chemistry',
    example: 'Soft water: 0-8 dGH. Hard water: 12+ dGH.',
  ),
  const _GlossaryTerm(
    term: 'KH (Carbonate Hardness)',
    definition:
        'Buffering capacity of water. Prevents pH swings. Low KH can cause pH crashes.',
    category: 'Chemistry',
  ),
  const _GlossaryTerm(
    term: 'TDS',
    definition:
        'Total Dissolved Solids. Measures all dissolved substances in water. Higher TDS = more minerals.',
    category: 'Chemistry',
  ),
  const _GlossaryTerm(
    term: 'Buffering',
    definition:
        'Water\'s ability to resist pH changes. Higher KH = better buffering.',
    category: 'Chemistry',
  ),

  // Nitrogen Cycle
  const _GlossaryTerm(
    term: 'Nitrogen Cycle',
    definition:
        'Process by which beneficial bacteria convert ammonia → nitrite → nitrate. Essential for healthy tanks.',
    category: 'Cycling',
  ),
  const _GlossaryTerm(
    term: 'Cycling',
    definition:
        'Establishing beneficial bacteria in a new tank. Takes 4-8 weeks.',
    category: 'Cycling',
  ),
  const _GlossaryTerm(
    term: 'Fishless Cycling',
    definition:
        'Cycling a tank using ammonia without fish. Safer and more reliable.',
    category: 'Cycling',
  ),
  const _GlossaryTerm(
    term: 'New Tank Syndrome',
    definition: 'Fish deaths in uncycled tanks due to ammonia/nitrite spikes.',
    category: 'Cycling',
  ),
  const _GlossaryTerm(
    term: 'Mini Cycle',
    definition:
        'Temporary ammonia/nitrite spike after disturbing filter media or adding too many fish.',
    category: 'Cycling',
  ),
  const _GlossaryTerm(
    term: 'Beneficial Bacteria',
    definition:
        'Bacteria that convert ammonia to nitrite (Nitrosomonas) and nitrite to nitrate (Nitrobacter).',
    category: 'Cycling',
  ),

  // Equipment
  const _GlossaryTerm(
    term: 'HOB Filter',
    definition:
        'Hang-On-Back filter. Hangs on tank rim, draws water up and returns via waterfall.',
    category: 'Equipment',
  ),
  const _GlossaryTerm(
    term: 'Canister Filter',
    definition:
        'External filter with large media capacity. Connected via hoses.',
    category: 'Equipment',
  ),
  const _GlossaryTerm(
    term: 'Sponge Filter',
    definition:
        'Air-driven filter using porous sponge. Great biological filtration, fry-safe.',
    category: 'Equipment',
  ),
  const _GlossaryTerm(
    term: 'Bioload',
    definition:
        'Amount of waste produced by tank inhabitants. High bioload = more filtration needed.',
    category: 'Equipment',
  ),
  const _GlossaryTerm(
    term: 'GPH',
    definition: 'Gallons Per Hour. Measure of filter flow rate.',
    category: 'Equipment',
    example: 'Aim for 4-10x tank volume per hour.',
  ),
  const _GlossaryTerm(
    term: 'Powerhead',
    definition: 'Pump that creates water circulation without filtration.',
    category: 'Equipment',
  ),
  const _GlossaryTerm(
    term: 'Airstone',
    definition:
        'Porous stone that creates fine bubbles when connected to air pump.',
    category: 'Equipment',
  ),

  // Fish
  const _GlossaryTerm(
    term: 'Livebearer',
    definition:
        'Fish that gives birth to free-swimming fry rather than laying eggs.',
    category: 'Fish',
    example: 'Guppies, mollies, platies.',
  ),
  const _GlossaryTerm(
    term: 'Egg Layer',
    definition: 'Fish that lays eggs for external fertilization.',
    category: 'Fish',
  ),
  const _GlossaryTerm(
    term: 'Schooling Fish',
    definition:
        'Fish that naturally swim in coordinated groups. Need 6+ for proper behavior.',
    category: 'Fish',
    example: 'Tetras, rasboras, corydoras.',
  ),
  const _GlossaryTerm(
    term: 'Shoaling Fish',
    definition:
        'Fish that prefer to be in groups but don\'t swim in tight formation.',
    category: 'Fish',
  ),
  const _GlossaryTerm(
    term: 'Bottom Dweller',
    definition:
        'Fish that spends most time at tank bottom. Often needs sand substrate.',
    category: 'Fish',
    example: 'Corydoras, loaches, plecos.',
  ),
  const _GlossaryTerm(
    term: 'Community Fish',
    definition: 'Peaceful fish suitable for mixed-species tanks.',
    category: 'Fish',
  ),
  const _GlossaryTerm(
    term: 'Territorial',
    definition: 'Fish that claims and defends an area. May attack intruders.',
    category: 'Fish',
  ),
  const _GlossaryTerm(
    term: 'Fin Nipper',
    definition:
        'Fish that bites fins of other fish. Avoid with long-finned tankmates.',
    category: 'Fish',
    example: 'Tiger barbs, serpae tetras.',
  ),

  // Plants
  const _GlossaryTerm(
    term: 'Rhizome',
    definition:
        'Horizontal stem from which roots and leaves grow. Never bury - attach to hardscape.',
    category: 'Plants',
    example: 'Java fern, anubias, bucephalandra.',
  ),
  const _GlossaryTerm(
    term: 'Carpet Plant',
    definition:
        'Low-growing plant that spreads horizontally to cover substrate.',
    category: 'Plants',
    example: 'Monte Carlo, dwarf hairgrass, HC Cuba.',
  ),
  const _GlossaryTerm(
    term: 'Stem Plant',
    definition:
        'Fast-growing plant with leaves along a central stem. Propagated by cuttings.',
    category: 'Plants',
    example: 'Rotala, Ludwigia, water wisteria.',
  ),
  const _GlossaryTerm(
    term: 'Root Tabs',
    definition:
        'Fertilizer capsules placed in substrate for root-feeding plants.',
    category: 'Plants',
  ),
  const _GlossaryTerm(
    term: 'CO₂ Injection',
    definition: 'Adding carbon dioxide to water to enhance plant growth.',
    category: 'Plants',
  ),
  const _GlossaryTerm(
    term: 'Emersed',
    definition:
        'Grown with leaves above water. Many aquarium plants are sold emersed.',
    category: 'Plants',
  ),
  const _GlossaryTerm(
    term: 'Submersed',
    definition:
        'Grown fully underwater. Plants often change form when transitioning.',
    category: 'Plants',
  ),
  const _GlossaryTerm(
    term: 'Melt',
    definition:
        'When plant leaves die off, often during transition from emersed to submersed.',
    category: 'Plants',
  ),

  // Disease
  const _GlossaryTerm(
    term: 'Ich (White Spot)',
    definition:
        'Common parasite appearing as white salt-grain spots. Highly contagious.',
    category: 'Disease',
  ),
  const _GlossaryTerm(
    term: 'Velvet',
    definition:
        'Parasitic infection appearing as gold dust. Often fatal if untreated.',
    category: 'Disease',
  ),
  const _GlossaryTerm(
    term: 'Dropsy',
    definition:
        'Symptom of organ failure - swollen body with raised scales (pinecone appearance).',
    category: 'Disease',
  ),
  const _GlossaryTerm(
    term: 'Fin Rot',
    definition:
        'Bacterial infection causing frayed, rotting fins. Usually from poor water quality.',
    category: 'Disease',
  ),
  const _GlossaryTerm(
    term: 'Flashing',
    definition:
        'Fish rubbing against objects. Sign of irritation, often parasites.',
    category: 'Disease',
  ),
  const _GlossaryTerm(
    term: 'Quarantine (QT)',
    definition:
        'Isolating new fish to observe for disease before adding to main tank.',
    category: 'Disease',
  ),

  // Aquascaping
  const _GlossaryTerm(
    term: 'Hardscape',
    definition: 'Non-living decorative elements: rocks, driftwood, etc.',
    category: 'Aquascaping',
  ),
  const _GlossaryTerm(
    term: 'Iwagumi',
    definition:
        'Japanese aquascaping style using rocks as primary focus with carpet plants.',
    category: 'Aquascaping',
  ),
  const _GlossaryTerm(
    term: 'Nature Style',
    definition:
        'Aquascaping style recreating natural landscapes with plants, rocks, and wood.',
    category: 'Aquascaping',
  ),
  const _GlossaryTerm(
    term: 'Biotope',
    definition: 'Tank designed to replicate a specific natural habitat.',
    category: 'Aquascaping',
    example: 'Amazon blackwater biotope, Lake Malawi biotope.',
  ),
  const _GlossaryTerm(
    term: 'Dry Start Method',
    definition:
        'Growing carpet plants emersed before flooding. Promotes rooting.',
    category: 'Aquascaping',
  ),
  const _GlossaryTerm(
    term: 'Tannins',
    definition:
        'Brown compounds released by driftwood. Lowers pH, tints water tea-colored.',
    category: 'Aquascaping',
  ),

  // General
  const _GlossaryTerm(
    term: 'Acclimation',
    definition:
        'Gradually adjusting fish to new water parameters when introducing to tank.',
    category: 'General',
  ),
  const _GlossaryTerm(
    term: 'Stocking',
    definition:
        'Number and type of fish in a tank. Overstocking causes problems.',
    category: 'General',
  ),
  const _GlossaryTerm(
    term: 'Water Change',
    definition:
        'Removing and replacing portion of tank water. Essential maintenance.',
    category: 'General',
    example: 'Typically 20-30% weekly.',
  ),
  const _GlossaryTerm(
    term: 'Dechlorinator',
    definition: 'Chemical that neutralizes chlorine/chloramine in tap water.',
    category: 'General',
  ),
  const _GlossaryTerm(
    term: 'Brackish',
    definition: 'Water between freshwater and saltwater in salinity.',
    category: 'General',
    example: 'Specific gravity ~1.005-1.015.',
  ),
  const _GlossaryTerm(
    term: 'Fry',
    definition: 'Baby fish.',
    category: 'General',
  ),
  const _GlossaryTerm(
    term: 'Nano Tank',
    definition: 'Small aquarium, typically under 40 liters (10 gallons).',
    category: 'General',
  ),
];
